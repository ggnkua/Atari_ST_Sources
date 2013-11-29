/* #define MDEBUG   /*JR - 06/21/96 */
#ifdef MDEBUG
	#define DEBUG
#endif

#ifdef DEBUG
	#define ERR_MSGS
#endif

/* 
** init.c for Inet-Module
** Initialisation for HTML.APP browser inet-module
** 
** Copyright (C) 1995, Stephane Boisson. All Rights reserved.
** Login <boisson@worldnet.net>
** 
** Started on  Sun Aug 27 23:41:30 1995 Stephane Boisson
** Last update Mon Aug 28 00:44:10 1995 Stephane Boisson
** 
** This file can be redistributed under the terms of the GNU General
** Public Licence.
*/

/* Includes for Cab. */
#include "module.h"

/* Includes for STiK. */
#ifdef NEW_STIK
	#include <basepage.h>	/* new stik */
	#include "transpor.h"	/* new stik */
#else
	#include "transprt.h"
#endif

/* Includes for me... :-) */
#include "http.h"

#include <unistd.h>     /* JR */
#include <stdlib.h> /* JR */
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <ext.h>
#include <oserr.h> /* JR */
#include <dos.h>   /* JR */
#include <time.h>  /* JR */

/*--- Prototypes ---*/
/* For Cab */
long ___CDECL init_module(url_methods_t *out, browser_info_t *in, char *path);
long ___CDECL get_url_info(char *url, long *timep, long *sizep, char *type);
void ___CDECL get_version(char **authorp, long *versionp, long *datep);
long ___CDECL get_url(char *url, char *filename);
long ___CDECL post(char *url,char *content, char *enctype, char *filename);
void ___CDECL restore_module(void);
/* For me */
int parse_header(char header[], URL_info *info);
time_t parse_date(char *date_string);
void clear_info(URL_info *info);
void split_URL(char *URL, URL_components *components);
static long init_drivers(void);
int http_proxy_cfg(char *ps, int pslen, int *pp);
int ftp_proxy_cfg(char *ps, int pslen, int *pp);
int16 open_connection(char *server, int port, int TOS);
long http_get(char *URL, char *content, char *enctype, char *file, int method);

/*--- Global variables ---*/
/* For Cab */
	browser_info_t *browser;
/* For STiK */
	DRV_LIST *drivers = (DRV_LIST *)NULL;
	TPL *tpl = (TPL *)NULL;
/* For me */
	static char user_agent[256];
	URL_info info;		/* moved outside 6/25/97 jr */


/* ----------------------------------------------------------------- ** 
** init_module - Initialize the module (called by browser)           ** 
** ----------------------------------------------------------------- */
long ___CDECL init_module(out, in, path)
url_methods_t *out;	/* struture to fill */
browser_info_t *in;	/* infos about browser */
char *path;		/* module path, '\' terminated */
{
	int ftp_proxy_port;
	char ftp_proxy[256];

  /*--- Set browser info variable ---*/
  browser = in;

  /*--- Fill URL methods structure ---*/
/*  out->restore = restore_module;*/
  out->get_url = get_url;
/*  out->get_url_info = get_url_info;*/
  out->get_version = get_version;
  out->post = post;

  /*--- Initialize other stuffs here ---*/
	Supexec(init_drivers);

	/* See if we got a value. */
	if (drivers == (DRV_LIST *)NULL) {
		#ifdef MDEBUG
			Cconws("STiK is not loaded\r\n");
		#endif
		return (0);
	}

	/* Check Magic number	*/
	if (strcmp(MAGIC, drivers->magic)) {
		#ifdef MDEBUG			/* JR - 06/21/96 */
			Cconws("Magic string doesn't match!\r\n");
		#endif
		return (0);
	}

	/* the "TRANSPORT" layer
	 * driver.  If this seems unnecessarily complicated, it's
	 * because I tried to create today, what I would like to
	 * use later on.  In future, there will be multiple
	 * drivers accessible via this method.  With luck, your
	 * code will still work with future versions of my software.
	 */

	tpl = (TPL *)get_dftab(TRANSPORT_DRIVER);
	if (tpl == (TPL *)NULL) {
		#ifdef MDEBUG			/* JR - 06/21/96 */
			Cconws("Transport layer *not* loaded\r\n");
		#endif
		return (0);
	}
	sprintf(user_agent, "User-Agent: NEWSie/0.96  STiK/%s\r\n", tpl->version);
	info.authorization[0]=0;

  /*--- Return support ---*/
	if (ftp_proxy_cfg(ftp_proxy, 256, &ftp_proxy_port)==TRUE)
		return(SUPPORT_HTTP|SUPPORT_FTP);

  return(SUPPORT_HTTP);
}


/* ----------------------------------------------------------------- ** 
** get_version - Returns infos about module                          ** 
** ----------------------------------------------------------------- */
void ___CDECL get_version(authorp, versionp, datep)
char **authorp;	/* 4x30 chars separated by '|' */
long *versionp;	/* Version number in BCD format (V1.15 -> 0x00011500) */
long *datep;	/* Date in BCD format (0xYYYYMMDD) */
{
  *versionp = 0x00011000L;
  *datep = 0x19951021L;
  *authorp =
  	"Tim Newsome|http://www.cybercomm.net/~drz/|drz@raven.cybercomm.net";
}


/* ----------------------------------------------------------------- ** 
** restore_module - De-initialization                                ** 
**                  (freeing memory, closing files, etc...)          ** 
** ----------------------------------------------------------------- */
void ___CDECL restore_module()
{
}


/* ----------------------------------------------------------------- ** 
** get_url - Fetch URL and write it as a HTML file                   ** 
**           Returns 0 if OK, else `errno'                           **
** ----------------------------------------------------------------- */
long ___CDECL get_url(url, filename)
char *url;		/* URL to fetch */
char *filename;		/* file to write to */
{
	#ifdef MDEBUG
	/*	printf("%cH\n\n", 27);	*/	/* home the cursor */
	#endif
  return(http_get(url, "", "", filename, GET_METHOD));
}

/*  this is temporary because of the dostime differences between 
	Pure C and Lattice C    JR
*/
typedef struct dostime
 {
  int date;
  int time;
 } DOSTIME;

/* I have to move these definitions outside http_get to prevent an
	'stack overflow' condition upon execution.  JR
	buffer[512] -> buffer[2048]  JR
*/
	char header[2048], buffer[2048], my_header[2048], http_proxy[256];
	char new_file[128]; /* was 1024 */

long http_get(URL, content, enctype, file, method)
char *URL;
char *content;
char *enctype;
char *file;
int method;
{
	int16 x, cn=-1;
	time_t timeout;

	URL_components URL_comps;
	DOSTIME filetime;
	struct tm *urltime;
	char *new_file_ptr;
	int file_handle, status=1, header_pos=0, http_proxy_port;
	long bytes_read=0, return_code=0;
	int bytes_available, eof=0;
	int proxy;
	int sbuf=sizeof(buffer);
    
	#ifdef DEBUG
		/* printf("%cH\n\n", 27); */	/* home the cursor */
	#endif

	#ifdef DEBUG
		printf("URL: \"%s\"\nFile: \"%s\" \n", URL, file);
	#endif

	split_URL(URL, &URL_comps);

	proxy=http_proxy_cfg(http_proxy, 256, &http_proxy_port);
	#ifdef MDEBUG
		if (proxy==TRUE)
			printf("Using %s:%d as proxy.", http_proxy, http_proxy_port);
	#endif

	if (proxy==TRUE) {
		strncpy(URL_comps.server, http_proxy, 256);
		URL_comps.port=http_proxy_port;
	}
	#ifdef MDEBUG
		printf("That's %s:%d.\n", URL_comps.server, URL_comps.port);
	#endif

	/* Get the stuff and stick it in a file. */
	file_handle=(int) Fcreate(file, 0);
	if (file_handle<0) {
		#ifdef ERR_MSGS
			printf("Couldn't create %s!\n", file);
		#endif
		return(1);
	}

	if (carrier_detect()>=0) {
		cn=open_connection(URL_comps.server, URL_comps.port, 0); }

	#ifdef MDEBUG
		printf("open_connection() returned %hi \n", cn);
	#endif
	if (cn<0) {
		#ifdef ERR_MSGS
			printf("open_connection() returns: %s\n", get_err_text(cn));
		#endif
		Fclose(file_handle);
		return(1);
	}

	#ifdef MDEBUG
		printf("Creating header...\n");
		if(method==POST_METHOD) {
			printf("enctype: %s\n", enctype);
			printf("strlen(content): %ld\n", strlen(content));
		}
	#endif
	if (method==GET_METHOD) {
		if (proxy==TRUE)
			sprintf(my_header, "GET %s HTTP/1.0\r\nAccept: */*\r\n%s\r\n", URL, user_agent);
		else
			sprintf(my_header, "GET %s HTTP/1.0\r\nHost: %s\r\nAccept: */*\r\n%s\r\n", URL_comps.URI, URL_comps.server, user_agent);
	} else if (method==POST_METHOD) {
		if (proxy==TRUE)
			sprintf(my_header, "POST %s HTTP/1.0\r\nContent-Length: %ld\r\nContent-Encoding: %s\r\n%s\r\n\r\n",
				URL, strlen(content), enctype, user_agent);
		else
			sprintf(my_header, "POST %s HTTP/1.0\r\nContent-Length: %ld\r\nContent-Encoding: %s\r\n%s\r\n\r\n",
				URL_comps.URI, strlen(content), enctype, user_agent);
		#ifdef MDEBUG
			printf("%s", my_header);
		#endif
	}
	browser->msg_status(5, 0);	/* Sending request... */

	if (info.authorization[0]) {	/* is there something in info.authorization? */
		strcat( my_header, "Authorization: " );
		strcat( my_header, info.authorization );
		strcat( my_header, "\r\n" );
	}
	#ifdef MDEBUG
		printf ( "Calling TCP_send with header:\n%s\n", my_header );
	#endif
	x = TCP_send(cn, my_header, (int16) strlen(my_header));
	#ifdef MDEBUG
		printf ( "returned from TCP_send %hi \n", x );
	#endif
	if (method==POST_METHOD) {
		#ifdef MDEBUG
			printf("Sending %ld bytes using the POST method.\n", strlen(content));
		#endif
		x = TCP_send(cn, content, (int16) strlen(content));
	}

	timeout=clock()+30*CLK_TCK;	/* 30 was 120 second timeout */

	browser->msg_status(2,0); /* Getting data... */
	while (eof==0) {
		bytes_available=CNbyte_count(cn);
		/* printf("received %hd bytes \n", bytes_available ); */

		if (handle_escape_events()==27) { eof=4; }
		/*
		if (Bconstat(2)==-1 && (Bconin(2) & 0xFF)==27) { eof=4;	}
		*/
		if (clock()>timeout) {
			eof=2;
			#ifdef MDEBUG
				printf("Timeout!\n");
			#endif
		} else if (bytes_available==E_EOF) {
			#ifdef MDEBUG
				printf("EOF!\n");
			#endif
			eof=1;
		} else if (bytes_available<E_NODATA) {
			#ifdef ERR_MSGS
				printf("CNbyte_count() returns: %hd %s\n", get_err_text(bytes_available));
			#endif
			eof=3;
		} else if (bytes_available>0) {
			timeout=clock()+15*CLK_TCK;	/* timeout 15 was 60s after last char */
			if (status==2) {
				if (bytes_available>sbuf) { bytes_available=sbuf; }
				if (CNget_block(cn, buffer, bytes_available)>=E_NODATA) {
					Fwrite(file_handle, bytes_available, &buffer);
					bytes_read+=bytes_available;
					browser->msg_status(2, bytes_read);
				} else {
					#ifdef ERR_MSGS
						printf("Error in CNget_block()!\n");
					#endif
					eof=3;
				}
			} else {
				x = CNget_char(cn);
				if (x<E_NODATA) {
					#ifdef ERR_MSGS
						printf("CNget_char() returns: %hd %s\n", get_err_text(x));
					#endif
					eof=3;
				} else
					header[header_pos++]=(char) x;
			}
			if (status==1) {
				if (strncmp(&header[header_pos-4], "\r\n\r\n", 4)==0 ||
				    strncmp(&header[header_pos-4], "\n\r\n\r", 4)==0 ||
				    strncmp(&header[header_pos-2], "\r\r", 2)==0 ||
				    strncmp(&header[header_pos-2], "\n\n", 2)==0) {
					header[header_pos]=0;
					#ifdef MDEBUG
						printf("End of header.\n");
					#endif
					status++;
				} else if (header_pos>2000) {
					Fwrite(file_handle, header_pos, header);
					status++;
				}
			}
		}
	}

	if (eof>1) {	/* timeout or worse*/
		x = (int16)TCP_close(cn, 2);
		if (x < 0) {
			#ifdef MDEBUG
				printf("TCP_close() returns: %hd %s\n", get_err_text(x));
			#endif
		}
		#ifdef MDEBUG
			printf("Fclose returns %i\n", Fclose(file_handle));
		#else
			/**** I might get a bug here! ****/
			if((x=(int16)Fclose(file_handle))<0) {
				#ifdef ERR_MSGS
					printf("Error with Fclose! (%i)\n", x);
				#endif
			}
		#endif
		return(eof);
	}

	x = (int16)TCP_close(cn, 2);
	if (x<E_EOF) {
		#ifdef ERR_MSGS
			printf("TCP_close() returns: %hd %s\n", get_err_text(x));
		#endif
	}

	#ifdef MDEBUG
		printf("Parsing header...\n");
	#endif
/*	if ((x=parse_header(header, &info))!=FALSE) { */
	if ((return_code=parse_header(header, &info))!=FALSE) {
		if (info.last_modified>info.date) {
			urltime=gmtime(&(info.last_modified));
			#ifdef MDEBUG
				printf("%s", ctime(&(info.last_modified)));
			#endif
		} else {
			urltime=gmtime(&(info.date));
			#ifdef MDEBUG
				printf("%s", ctime(&(info.date)));
			#endif
		}
		#ifdef MDEBUG
			printf("%s", asctime(urltime));
		#endif

		/* filetime.time=(urltime->tm_sec)/2;
		filetime.time+=(urltime->tm_min)<<5;
		filetime.time+=(urltime->tm_hour)<<11;
		filetime.date=(urltime->tm_mday);
		filetime.date+=((urltime->tm_mon)+1)<<5;
		filetime.date+=((urltime->tm_year)-80)<<9;
		Fdatime(&filetime, file_handle, 1); */

		if (strlen(info.location)>0) {
			#ifdef DEBUG
				printf("Location: %s\n", info.location);
			#endif
			strcpy(new_file, file);
			if ((return_code=browser->new_url(info.location, &new_file_ptr))==0) {
				return_code=-1;
				strcpy(new_file, new_file_ptr);
			}
		}
	}

	#ifdef MDEBUG
		printf("Fclose returns %d\n", Fclose(file_handle));
	#else
		if((x=(int16)Fclose(file_handle))<0)
			browser->msg_error(x);
	#endif

	if (return_code==-1) {		/* get the info from elsewhere */
		#ifdef DEBUG
			printf("Get %s as %s\n", info.location, new_file);
		#endif
		if (method==GET_METHOD)
			return_code=get_url(info.location, new_file);
		else if (method==POST_METHOD)
			return_code=post(info.location, content, enctype, new_file);
		/*Fdelete(file);*/
	}/* else if (return_code!=0)
		Fdelete(file);*/
	#ifdef MDEBUG
		printf("Hit a key.\n");
		Bconin(2);
	#endif
	return(return_code); /* return(0)     if getting data was successful,     */
              /* return(errno) if it fails, return an error number */
} 


/* ----------------------------------------------------------------- ** 
** post    - Post FORM, fetch result and write it as a HTML file     ** 
**           Returns 0 if OK, else `errno'                           **
** ----------------------------------------------------------------- */
long ___CDECL post(url, content, enctype, filename)
char *url;     		/* URL to fetch */
char *content;      /* data to post */
char *enctype;      /* format of data */
char *filename;		/* file to write to */
{
	#ifdef MDEBUG
	/*	printf("%cH\n\n", 27); */	/* home the cursor */
		printf("url: %s\ncontent: %s\nenctype: %s\nfilename: %s\n",
			url, content, enctype, filename);
	#endif
  return(http_get(url, content, enctype, filename, POST_METHOD));
}


/* ----------------------------------------------------------------- ** 
** get_url_info - Retreive infos for an URL                          ** 
**                Returns 0 if OK, else `errno'                      **
** ----------------------------------------------------------------- */
long ___CDECL get_url_info(url, timep, sizep, type)
char *url;	/* URL */
long *timep;	/* UNIX time */
long *sizep;	/* size of data */
char *type;	/* mime type (max len = 250), empty string if unknow */
{
  return 0;
}


/* ----------------------------------------------------------------- ** 
** main - Doesn't useful, but take care that others functions don't  ** 
**        get `swallowed' by compiler optimizations                  ** 
** ----------------------------------------------------------------- */
/*
int main()
{
	static void *array[] = {
    "You need a Web Browser to run\r\n",
    (void *)BROWSER_MAGIC1, (void *)BROWSER_MAGIC2,
    (void *)BROWSER_MAGIC3, (void *)BROWSER_MAGIC4, init_module};
  
  write(1, array[0], strlen(array[0]));
  return 1;
}
*/
/************************************************************************
	This is where my private routines start
************************************************************************/

char field[256], entry[256], line[512];  /* JR moved outside - stack space */
int parse_header(char header[], URL_info *info)
{
	/* char field[256], entry[256], line[512], */
	char tmp[4];
	int header_pos=0, line_pos, return_code=0, line_number=0;
	size_t index;
	double http_version=0;
	int eoh=0;

	clear_info(info);

	#ifdef MDEBUG
		printf("Let's go! (%d)\n", eoh);
	#endif

	while (eoh==0) {
		/* Get a full line */
		#ifdef MDEBUG
			printf("Get line...\n");
		#endif
		for (line_pos=0; header[header_pos]!='\n' &&
		                  header[header_pos]!='\r'; header_pos++) {
			line[line_pos++]=header[header_pos];
		}
		/* If it's a /r/n or /n/r combo, then increment header_pos twice
		 * so we don't get a zero-length line next time... */
		if ((header[header_pos+1]=='\n' && header[header_pos]=='\r') ||
		    (header[header_pos+1]=='\r' && header[header_pos]=='\n')) {
			header_pos+=2;
			#ifdef MDEBUG
				printf("Skipping two...");
			#endif
		} else {
			header_pos++;
			#ifdef MDEBUG
				printf("Skipping one...");
			#endif
		}
		line[line_pos]=0;
		#ifdef MDEBUG
			printf("%s (%d)\n", line, (int) strlen(line));
		#endif

		if (line_pos==0)
			eoh=1;
		else if (line_number++==0) {
			/* HTTP header, not a field. */
			tmp[3]=0;
			if (strncmp("HTTP/", line, 5)==0) {
				http_version=atof(strncpy(tmp, &line[5], 3));
			}
			if (http_version==1.0) {
				return_code=atoi(strncpy(tmp, &line[9], 3));
			} else {
				return_code=FALSE;
			}
		} else {
			/* Copy all bytes up to and not including the ":" into field[] */
			index=strcspn(line, ":");
			if (index>0) {
				strncpy(field, line, index);
				field[index]=0;
	
				/* Copy the rest into entry[] */
				strcpy(entry, &line[index+2]);
				
				#ifdef MDEBUG
					printf("%s: %s\n", field, entry);
				#endif
	
				if (strcmpi("Content-Encoding", field)==0)
					strcpy(info->content_encoding, entry);
				else if (strcmpi("Content-Length", field)==0)
					info->content_length=atol(entry);
				else if (strcmpi("Content-Type", field)==0)
					strcpy(info->content_type, entry);
				else if (strcmpi("Location", field)==0)
					strcpy(info->location, entry);
				else if (strcmpi("MIME-Version", field)==0)
					info->mime_version=atof(entry);
				else if (strcmpi("Pragma", field)==0)
					strcpy(info->pragma, entry);
				else if (strcmpi("Server", field)==0)
					strcpy(info->server, entry);
				else if (strcmpi("WWW-Authenticate", field)==0)
					strcpy(info->www_authenticate, entry);
				else if (strcmpi("Last-Modified", field)==0) {
					info->last_modified=parse_date(entry);
					#ifdef MDEBUG
						printf("%s\n", entry);
					#endif
				} else if (strcmpi("Date", field))
					info->date=parse_date(entry);
				else if (strcmpi("Expires", field))
					info->expires=parse_date(entry);
			} else {
				eoh=1;
			}
		}
	}
	return(return_code);
}

time_t parse_date(char *date_string)
{
	size_t index;
	char tmp[5]={0, 0, 0, 0, 0};
	struct tm time;

	if (strchr(date_string, '-')!=NULL) {
		/* Sunday, 06-Nov-94 08:49:37 GMT	RFC 850, obsoleted by RFC 1036 */
		index=strcspn(date_string, ",");
		time.tm_sec=atoi(strncpy(tmp, &date_string[index+18], 2));
		time.tm_min=atoi(strncpy(tmp, &date_string[index+15], 2));
		time.tm_hour=atoi(strncpy(tmp, &date_string[index+12], 2));
		time.tm_year=atoi(strncpy(tmp, &date_string[index+9], 2));
		time.tm_mday=atoi(strncpy(tmp, &date_string[index+2], 2));
	} else if (strchr(date_string, ',')!=NULL) {
		/* Sun, 06 Nov 1994 08:49:37 GMT    RFC 822, updated by RFC 1123 */
		time.tm_sec=atoi(strncpy(tmp, &date_string[23], 2));
		time.tm_min=atoi(strncpy(tmp, &date_string[20], 2));
		time.tm_hour=atoi(strncpy(tmp, &date_string[17], 2));
		time.tm_mday=atoi(strncpy(tmp, &date_string[5], 2));
		time.tm_year=atoi(strncpy(tmp, &date_string[12], 4))-1900;
	} else {
		/* Sun Nov  6 08:49:37 1994			ANSI C's asctime() format */
		time.tm_sec=atoi(strncpy(tmp, &date_string[17], 2));
		time.tm_min=atoi(strncpy(tmp, &date_string[14], 2));
		time.tm_hour=atoi(strncpy(tmp, &date_string[11], 2));
		time.tm_mday=atoi(strncpy(tmp, &date_string[8], 2));
		time.tm_year=atoi(strncpy(tmp, &date_string[20], 4))-1900;
	}
	/* The month is generic... */
	if (strstr(date_string, "Jan")>0)
		time.tm_mon=0;
	else if (strstr(date_string, "Feb")>0)
		time.tm_mon=1;
	else if (strstr(date_string, "Mar")>0)
		time.tm_mon=2;
	else if (strstr(date_string, "Apr")>0)
		time.tm_mon=3;
	else if (strstr(date_string, "May")>0)
		time.tm_mon=4;
	else if (strstr(date_string, "Jun")>0)
		time.tm_mon=5;
	else if (strstr(date_string, "Jul")>0)
		time.tm_mon=6;
	else if (strstr(date_string, "Aug")>0)
		time.tm_mon=7;
	else if (strstr(date_string, "Sep")>0)
		time.tm_mon=8;
	else if (strstr(date_string, "Oct")>0)
		time.tm_mon=9;
	else if (strstr(date_string, "Nov")>0)
		time.tm_mon=10;
	else
		time.tm_mon=11;
	/* DOSTIME is in 2 second intervals... */
	time.tm_sec=(time.tm_sec & 0xFFFE);
/*	printf("%ld\n", (long) mktime(&time));*/
	return(mktime(&time));
}

void clear_info(URL_info *info)
{
	info->content_encoding[0]=
	info->content_type[0]=
	info->location[0]=
	info->pragma[0]=
	info->server[0]=
	info->www_authenticate[0]=0;
	info->authorization[0]=0;
	info->mime_version=
	info->content_length=
	info->date=
	info->expires=
	info->last_modified=-1;
}

void split_URL(char *URL, URL_components *components)
{
	size_t colon_index, slash_index;

	colon_index=strcspn(URL, ":");
	strncpy(components->protocol, URL, colon_index);
	components->protocol[colon_index]=0;
	strcpy(components->URI, &URL[colon_index+3]);
	slash_index=strcspn(components->URI, "/");
	strncpy(components->server, components->URI, slash_index);
	components->server[slash_index]=0;
	strcpy(components->URI, &URL[colon_index+slash_index+3]);
	colon_index=strcspn(components->server, ":");
	if (colon_index<strlen(components->server)) {
		components->port=atoi(&(components->server[colon_index+1]));
		components->server[colon_index]=0;
	} else {
		components->port=80;
	}
}

typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

static long init_drivers(void)
{
	long i = 0;
	ck_entry *jar = *((ck_entry **) 0x5a0);

	while (jar[i].cktag) {
		if (!strncmp((char *)&jar[i].cktag, CJTAG, 4)) {
			drivers = (DRV_LIST *)jar[i].ckvalue;
			return (0);
		}
		++i;
	}
	return (0);	/* Pointless return value...	*/
}

int http_proxy_cfg(char *ps, int pslen, int *pp)
{
	char *ptr;

	#ifdef MDEBUG
		printf("Getting proxy...\n");
	#endif
	ptr = getvstr("HTTP_PROXY");
	if (ptr[0] == '0' || ptr[0] == '1')
		return (FALSE);
    strncpy(ps, ptr, (size_t)pslen);

	#ifdef MDEBUG
		printf("Getting proxy port...\n");
	#endif
    ptr = getvstr("HTTP_PROXY_PORT");
    /* If there is some kind of standard proxy port, then we could
     *use it as a default instead of return (FALSE) here...
     */
    if (ptr[0] == '0' || ptr[0] == '1')
        return (FALSE);
    *pp = atoi(ptr);

	#ifdef MDEBUG
		printf("Got proxy...\n");
	#endif
    return (TRUE);
}

int ftp_proxy_cfg(char *ps, int pslen, int *pp)
{
	char *ptr;

	ptr = getvstr("FTP_PROXY");
	if (ptr[0] == '0' || ptr[0] == '1')
		return (FALSE);
    strncpy(ps, ptr, (size_t)pslen);

    ptr = getvstr("FTP_PROXY_PORT");
    /* If there is some kind of standard proxy port, then we could
     *use it as a default instead of return (FALSE) here...
     */
    if (ptr[0] == '0' || ptr[0] == '1')
        return (FALSE);
    *pp = atoi(ptr);

    return (TRUE);
}

/** Resolves server into an IP address, then opens a connection to port
	of server, with TOS (magic variable, which should always be 0, ask
	Steve Adam about it). It returns a connection handle for following
	calls. If it's smaller than 0 then it's an error. */
int16 open_connection(char *server, int port, int TOS)
{
	int16 x, cn;
	uint32 addr;

	#ifdef MDEBUG
		printf("open_connection(%s, %i, %i)\n", server, port, TOS);
	#endif

	browser->msg_status(4,0);	/* Resolving... */
	x = resolve(server, (char **)NULL, &addr, 1);
	if (x<0) {
		#ifdef ERR_MSGS
			printf("Resolve for %s returns: %s\n", server, get_err_text(x));
		#endif
		return(x);
	}

	browser->msg_status(1, 0);	/* Opening connection... */
	cn=TCP_open(addr, port, TOS, 1024);
	if (cn<0) {
		#ifdef ERR_MSGS
			printf("TCP_open() returns: %d %s\n", cn, get_err_text(cn));
		#endif
		return(cn);
	} else {
		#ifdef ERR_MSGS
			printf("TCP connection handle is: %hd \n", cn );
		#endif
	}

	x = TCP_wait_state(cn, TESTABLISH, 60);
	if (x<0) {
		#ifdef ERR_MSGS
			printf("TCP_wait_state() returns: %d %s\n", x, get_err_text(x));
		#endif
		TCP_close(cn, 2);
		return(x);
	}

	return(cn);
}

