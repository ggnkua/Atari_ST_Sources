#include "module.h"#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <time.h>
#include <sockinit.h>
#include <socket.h>
#include <sfcntl.h>
#include <types.h>
#include <sockios.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <atarierr.h>
#include <sockerr.h>
#include <ext.h>
#include <url_aid.h>
#include <usis.h>
#include "blip_cab.h"

#define TOUT_SEK 90
#define CONNECT_COUNT	200		/* Counts in 100ms for Connection-Timeout */
#define HEAD_BUF	4096			/* Buffer-size for HTTP-Header */

const char *user_agent="Mozilla/3.0 (CAB xx.xx; I-Con.OVL xx.xx; MagiC)";

extern int debhand;

char	act_host[256];
char	glob_buf[5001];
char	last_realm[128];

/* Atari to ISO-8859-1 */
char r_iso8859_1[]=
{
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
	16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, '\!', '\"', '\#', '\$', '\%', '\&', '\'', '\(', '\)', '\*', '\+', '\,', '\-', '\.', '\/',
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '\:', '\;', '\<', '\=', '\>', '\?',
  '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
  'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '\[', '\\', '\]', '\^', '\_',
  '\`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
  'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '\{', '\|', '\}', '\~', 127,
  
	/* 128-143 */
	199, 252, 233, 226, 228, 224, 229, 231, 234, 235, 232, 239, 238, 236, 196, 197,
	/* 144-159 */
	201, 230, 198, 244, 246, 242, 251, 249, 255, 214, 220, 162, 163, 165, 223, 'f',
	/* 160-175 */
	225, 237, 243, 250, 241, 209, 'a', 'o', 191, '-', '-', 189, 188, 161, 171, 187,
	/* 176-191 */
	227, 245, 216, 248, 'o', 'O', 192, 195, 213, 168, 180, '+', 167, 169, 174, '?',
	/* 192-207 */
	'i', 'I', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', 
	/* 208-225 */
	'?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', 167, '\^', '?', '?', 223,
	/* 226-241 */
	'?', 182, '?', '?', 181, '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', 177,
	/* 242-255 */
	'>', '<', '?', '?', 247, '=', 176, 176, '.', '?', '?', 178, 179, 175
};

char	base64_encode[]=
{
 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q',
 'R','S','T','U','V','W','X','Y','Z',
 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q',
 'r','s','t','u','v','w','x','y','z',
 '0','1','2','3','4','5','6','7','8','9','+','/'
};

char *mstrncat(char *dst, char *src, int n)
{/* H„ngt immer 0 an */
	char	*mem=dst;
	
	dst+=strlen(dst);
	while(n--)
		*dst++=*src++;
	*dst=0;

	return(mem);
}

char	*time_to_a(long utime, char *buf)
{
	char	mbuf[30];
		
	strcpy(mbuf, ctime((time_t*)&utime));
	buf[0]=0;
	
	/* Copy Day's name */
	mstrncat(buf, mbuf, 3);
	/* comma+space */
	strcat(buf, ", ");
	/* day */
	mstrncat(buf, &(mbuf[8]), 2); strcat(buf, " ");
	/* month's name */
	mstrncat(buf, &(mbuf[4]),3); strcat(buf, " ");
	/* year */
	mstrncat(buf, &(mbuf[20]), 4); strcat(buf, " ");
	/* time */
	mstrncat(buf, &(mbuf[11]), 8);
	/* final */
	strcat(buf, " GMT");
	
	return(buf);
}

long	a_to_time(char *s){/* Taken from weblib */	struct	tm	time;	int	i;	char	day[128];	char	month[20];	char	*monthtab[12]={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};	char	*n;	if(s[3]!=' '&&s[3]!=',')		{		n=s;		while(*n)			{			if(*n=='-'||*n==':')				*n=' ';			n++;			}		time.tm_mon=0;		sscanf(s,"%s %d %s %d %d %d %d GMT",day,&time.tm_mday, month, &time.tm_year, &time.tm_hour, &time.tm_min,&time.tm_sec);		for(i=0;i<12;i++)			{			if(!stricmp(month,monthtab[i]))				time.tm_mon=i;			}		time.tm_isdst=0;	/* daylight saving is never in effect in GMT */		return mktime(&time);		}	else	if(s[3]==',')		{		n=s;		while(*n)			{			if(*n=='-'||*n==':')				*n=' ';			n++;			}		time.tm_mon=0;		sscanf(s,"%s %d %s %d %d %d %d GMT",day,&time.tm_mday, month, &time.tm_year, &time.tm_hour, &time.tm_min,&time.tm_sec);		time.tm_year-=1900;		for(i=0;i<12;i++)			{			if(!stricmp(month,monthtab[i]))				time.tm_mon=i;			}		time.tm_isdst=0;	/* daylight saving is never in effect in GMT */		return mktime(&time);		}	n=s;	while(*n)		{		if(*n=='-'||*n==':')			*n=' ';		n++;		}	time.tm_mon=0;	sscanf(s,"%s %s  %d %d %d %d %d",day,month,&time.tm_mday,&time.tm_hour,&time.tm_min,&time.tm_sec,&time.tm_year);	time.tm_year-=1900;	for(i=0;i<12;i++)		{		if(!stricmp(month,monthtab[i]))			time.tm_mon=i;		}	time.tm_isdst=0;	/* daylight saving is never in effect in GMT */	return mktime(&time);}
void terminate(char *s)
{
	while(*s)
	{
		if((*s==10)||(*s==13))
		{
			*s=0;
			return;
		}
		++s;
	}
}

int get_cook_para(char **head, char **para)
{
	char *x, mem, buf[256];

	buf[0]=0;	
	*para=buf;
	x=strchr(*head, '='); if(x==NULL) {*head=&(*head[strlen(*head)]);return(0);}
	*head=x+1;
	while((**head==' ')||(**head==9)) ++*head;
	x=*head;
	while(*x && (*x!=';')) ++x;
	mem=*x; *x=0;
	if(strlen(*head) < 256) 
		strcpy(buf, *head);
	*x=mem; 
	*head=x; 
	return(buf[0]);
}

void extract_cookie(char *head, char *url)
{
	#define NAME_MLEN 128
	#define VAL_MLEN 128
	
	char *m1, *x, *y, mem;
	char name[NAME_MLEN+1], *val, value[VAL_MLEN+1], *exp, expires[32], path[512], domain[128], secure;

	/* Defaults */
	val=NULL;
	exp=NULL;
	secure=0;
	strcpy(domain, act_host);
	x=strstr(url, "://"); 
	if(x==NULL) x=url;
	else 
	{
		y=x+3; x=strchr(y, '/');
	}
	if(x==NULL)
		strcpy(path, "/");
	else
	{/* Nur bis zum letzten "/" kopieren (aussschliežlich!) */
		y=path;
		do
		{
			*y++=*x++;
			*y=0;
		}while(*x && (*x!='/'));
	}

	/* Start */		
	while((*head==' ')||(*head==9)) ++head;
	
	m1=strchr(head, 13); 
	if(m1==NULL) m1=strchr(head, 10);
	if(m1) *m1=0;

	/* Get NAME and VALUE */
	x=head;
	while(*x && (*x!='=') && (*x!=';')) ++x;
	mem=*x; *x=0;
	if(strlen(head) > NAME_MLEN) {*x=mem; goto _exit_cookie;}
	strcpy(name, head);
	if(name[0]) while(name[strlen(name)-1]==' ') name[strlen(name)-1]=0;
	*x=mem;
	head=x;
	if(mem=='=')
	{ /* Get VALUE */
		++head; while((*head==' ') || (*head==9)) ++head;
		x=head;
		while(*x && (*x!=';')) ++x;
		mem=*x; *x=0;
		if(strlen(head) > VAL_MLEN) {*x=mem; goto _exit_cookie;}
		strcpy(value, head);
		*x=mem;
		head=x;
		val=value;
	}

	/* Parameter ermitteln */
	while(*head)
	{
		/* N„chster Parameter */
		while(*head && (*head != ';')) ++head;
		if(*head==';')	/* N„chster */
		{
			++head;
			while((*head==' ')||(*head==9)) ++head;
			if(!strnicmp(head, "expires", 7))
			{
				if(get_cook_para(&head, &x))
				{/* Format "Wdy, DD-Mon-YYYY HH:MM:SS GMT" */
					/* (my.yahoo: "Weekday, DD-Mon-YY HH:MM:SS GMT") */
					strncpy(expires, x, 3);
					expires[3]=','; expires[4]=' '; expires[5]=0;
					x=strchr(x, ','); if(x==NULL) goto _exit_cookie;
					++x; while(*x==' ')++x;
					if(x[9]==' ')	/* Jahr nur zweistellig */
					{
						strncat(expires, x, 7); x+=7;
						if(atoi(x-2) < 98)
						{	expires[12]='1'; expires[13]='9'; expires[14]=0;}
						else
						{	expires[12]='2'; expires[13]='0'; expires[14]=0;}
						strcat(expires, x);
					}
					else
						strcat(expires, x);
					exp=expires;
				}
			}
			else if(!strnicmp(head, "Path", 4))
			{
				if(get_cook_para(&head, &x))
					strcpy(path, x);
			}
			else if(!strnicmp(head, "Domain", 6))
			{
				if(get_cook_para(&head, &x))
				{
					/* Check for embedded dot */
					y=strchr(x+1, '.'); 
					if(y==NULL) goto _exit_cookie;
					if(y==x+strlen(x)-1) goto _exit_cookie;
					/* Check for domain */
					if(strnicmp(x, act_host+(strlen(act_host)-strlen(x)), strlen(x))) goto _exit_cookie;
					strcpy(domain, x);
				}
			}
			else if(!strnicmp(head, "Secure", 6))
			{
				secure=1;
				head+=6;
			}
			else
			{/* Quoted Parameter bergehen */
				get_cook_para(&head, &x);
			}
		}
	}
	
	browser->set_cookie(url, name, val, exp, path, domain, secure);

_exit_cookie:
	if(m1) *m1=13;
}

void parse_header(char *head, RECV_INFO *rinf)
{/* Header must stop with \0 */
	char *f, *x;
	char	time[80], loc_buf[512];

	Dftext("\r\nParsing header\r\n");	

	/* Exchange all CR/LF followed by white-space by space */
	f=head;
	while(*f)
	{
		if((*f==13)||(*f==10))
		{
			x=f; while((*x==13)||(*x==10))++x;
			if((*x==' ')||(*x==9))
				while((*f==13)||(*f==10)) *f++=' ';
			else
				f=x;
		}
		else
			++f;
	}

	/* Done. Default Head-fields */
	rinf->http_vers=10*atoi(&(head[5]));
	f=strchr(head, '.');	/* Should find prepending small version */
	if(f != NULL)
		rinf->http_vers+=(*(f+1) - 48);
		
	f=strchr(head, ' ');	/* Should find SP preceding return code */
	if(f==NULL) return;		/* Bad luck */
	rinf->res_code=atoi(f+1);
	
	/* Find second line */
	while((*head!=13)&&(*head!=10)&&(*head))++head;
	while(*head && ((*head==13)||(*head==10)))++head;
	
	rinf->timestamp=-1;
	rinf->size=-1;
	rinf->cont_encod[0]=rinf->cont_type[0]=rinf->location[0]=
	rinf->cont_encod[249]=rinf->cont_type[249]=rinf->location[512]=0;
	rinf->basic_auth=0;
	
	while(*head)
	{
		if(!strnicmp(head, "Last-Modified:",14))
		{
			strncpy(time, head+15,79);
			time[79]=0;
			rinf->timestamp=a_to_time(time);
		}

		if(!strnicmp(head, "Date:",5))
		{
			strncpy(time, head+6,79);
			time[79]=0;
			rinf->timestamp=a_to_time(time);
		}

		if(!strnicmp(head, "Content-length:",15))
			rinf->size=atol(head+16);
	
		if(!strnicmp(head, "Content-encoding:",17))
		{
			strncpy(rinf->cont_encod, head+18, 249);
			terminate(rinf->cont_encod);
		}
		
		if(!strnicmp(head, "Content-type:",13))
		{
			strncpy(rinf->cont_type, head+14, 249);
			terminate(rinf->cont_type);
		}
			
		if(!strnicmp(head, "Location:",9))
		{
			strncpy(rinf->location, head+10, 511);
			terminate(rinf->location);
			if(rinf->location[0]=='/')	/* Relative Angabe */
			{
				strcpy(loc_buf, "http://");
				strcat(loc_buf, act_host);
				strcat(loc_buf, rinf->location);
				strcpy(rinf->location, loc_buf);
			}
		}
		
		if(!strnicmp(head, "WWW-Authenticate: Basic", 23))
		{
			rinf->basic_auth=1;
			strncpy(rinf->auth_realm, head+23, 127);
			rinf->auth_realm[127]=0;
		}

/* Source aus "COOKIE2.C" wieder zurck kopieren!		
		if(!strnicmp(head, "Set-Cookie2:", 12))
		{
			extract_cookie2(head+12, rinf->url);
		}
*/

		if(!strnicmp(head, "Set-Cookie:", 11))
		{
			extract_cookie(head+11, rinf->url);
		}

		/* Find next line */
		while((*head!=13)&&(*head!=10)&&(*head))++head;
		while(*head && ((*head==13)||(*head==10)))++head;
	}
}

int see_crlf(int *crlf, char *buf, int len)
{/* Accepts CRLFCRLF, CRCR, CRLFLF and LFLF as Header-End
		crlf:
		0=nothing
		1=cr1,2=lf1,3=cr2,4=lf2
		returns offset at which document starts in buffer or 0*/
	
	int a=0;
	
	while(a < len)
	{
		if(buf[a]==13)
		{
			if(*crlf==2) *crlf=3;	/* First CRLF */
			else if(*crlf==1)		/*	CRCR */
			{
				*crlf=4;
				return(a+1);
			}
			else *crlf=1;				/* First CR */
		}
		else if(buf[a]==10)
		{
			if(*crlf>=2)				/* CRLFCRLF or CRLFLF or LFLF */
			{
				 *crlf=4;
				 return(a+1);
			}
			else *crlf=2;				/* CRLF or LF */
		}
		else
			*crlf=0;
			
		++a;
	}
	return(0);
}

int msglen(char *msg)
{
	register int l=0;
	while(msg[l++]);
	return(l-1);
}

void	set_file_time(int dest_file, long timep)
{
	struct tm		ftime;
	DOSTIME			dtime;

	if(timep==-1) return;
	
	timezone=0;
	ftime=*localtime((time_t*)&timep); 
	
	dtime.time=ftime.tm_sec/2;
	dtime.time|=(ftime.tm_min << 5);
	dtime.time|=(ftime.tm_hour << 11);
	
	dtime.date=ftime.tm_mday;
	dtime.date|=((ftime.tm_mon+1) << 5);
	dtime.date|=((ftime.tm_year-2000)<<9);	/* 2000 should be 1980, strange... */

	Dftext("Set timestamp\r\n");
	
	Fdatime(&dtime, dest_file, 1);
}

long request(ulong ip, int port, char *msg, char *entity, char *dest_path, RECV_INFO *rinf, int head_only)
{/* Return -1 on error, else 0. 
		0 means ULR_INFO contains at least http_vers and 
		file was written if doc contained an entity (if not, <size> will
		be 0) 
		dest_file can be -1 to supress output 
	*/

	time_t	now;
	sockaddr_in sad;
	int		s, ret, crlf_seen=0, crr, dest_file=-1;
	int		header_checked=0;
	long	tot_rcv=0, head_len=0;
	char	*buf=glob_buf, *wbuf, *f;
	static char head[HEAD_BUF];
	fd_set	mask;
	timeval	tout;

	s=socket(AF_INET, SOCK_STREAM, 0);
	rinf->res_code=-1;

	if(s < 0)
		return(-1);	/* General error */

	sfcntl(s,F_SETFL,O_NDELAY);

	/* connect to remote host */
	browser->msg_status(STATUS_CONNECTING_HOST,0);	sad.sin_family=AF_INET;	sad.sin_port=port; sad.sin_addr=ip;
	Dftext("Connect ");Dftext(inet_ntoa(ip));Dftext("\r\n");
	ret=to_connect(s, &sad, (int)sizeof(sockaddr_in));
	if(ret < 0)
	{
		sclose(s);
		return(-1);		/* See SOCKPRG.TXT for possible errors */
	}

	/* Send the message */
	Dftext("SENDING:\r\n");Dftext(msg);
	browser->msg_status(STATUS_SENDING_REQUEST,0);
	ret=swrite(s, msg, msglen(msg));
	if(ret < 0)
	{
		shutdown(s,2);
		sclose(s);
		return(-1);		/* See SOCKPRG.TXT for possible errors */
	}

	if(entity)
	{
		Dftext(entity); Dftext("\r\n");
		ret=swrite(s, entity, (int)strlen(entity));
		if(ret < 0)
		{	shutdown(s,2); sclose(s);	return(-1); }
		ret=swrite(s, "\r\n", 2);
		if(ret < 0)
		{	shutdown(s,2); sclose(s);	return(-1); }
	}

	/* Wait for TOUT_SEK seconds for reply or closing con */
	Dftext("---Result---\r\n");

	browser->msg_status(STATUS_WAITING_RESPONSE,0);	now=time(NULL);
	while(1)
	{
		FD_ZERO(&mask);
		FD_SET(s, &mask);
		tout.tv_sec=0;
		tout.tv_usec=0;
	
		ret=select(s+1, &mask, NULL, NULL, &tout);
		if(ret==0)
		{
			ret=(int)sread(s, buf, 5000);
			if(ret < 0)	/* Foreign closed, file should be received now */
				break;
			/* Maybe a segment just arrived between select and sread */
			if(ret > 0) goto _incoming;
			
			if(time(NULL)-now < TOUT_SEK)
			{/* Give CAB some time */
				if(browser->aes_events(100) == -1) /* User canceled */
				{
					shutdown(s,2);
					sclose(s);
					return(-1);
				}
				continue;
			}
			break;	/* Timeout */
		}

		/* Incoming data, reset timeout */
		
		ret=(int)sread(s, buf, 5000);
		if(ret < 0)	/* Foreign closed, file should be received now */
			break;
		
_incoming:
		now=time(NULL);

		if(ret==0)	/* Empty reply? Ignore (Timeout is done by select) */
			continue;

		if(debhand > -1) Fwrite(debhand, ret, buf);

		/* In HTTP0.9 the document will arrive right away. From HTTP1.0
			 on, a header starting off with "HTTP/" will arrive */
		if(header_checked==0)
		{
			strncpy(&(head[head_len]), buf, ret);
			head_len+=ret;
			if(head_len < 13) continue;	/* Wait for more data */
			header_checked=1;
			if(strncmp(head, "HTTP/",5))	/* Not equal->HTTP0.9 */
			{/* Write old head-bytes (which are no header) to file */
				if((head_len-ret > 0)&&(dest_file>-1))
				{
					if(dest_path != NULL)
					{
						if(dest_file < 0)
						{
							dest_file=(int)Fcreate(dest_path, 0);
							if(dest_file < 0)
							{
								shutdown(s,2);
								sclose(s);
								return(dest_file);
							}
						}
						Fwrite(dest_file, head_len-ret, head);
					}
				}
				/* Signal no header */
				head_len=-1;
				/* Fake up a seen header-fin */
				crlf_seen=4;
			}
			else	/* Get return-code */
			{
				f=strchr(head, ' ');	/* Should find SP preceding return code */
				if(f!=NULL)		/* Successfull */
					rinf->res_code=atoi(f+1);
				head_len-=ret;	/* Will be copied again by following code */
			}
		}
		
		wbuf=buf;		/* Write from wbuf to file */
		
		if(crlf_seen < 4)	/* Still receiving header */
		{/* Store header if space */
			crr=see_crlf(&crlf_seen,buf, ret);
			if(crr > 0) /* Header done, Document starts in buffer */
			{
				ret-=crr;
				wbuf=&(buf[crr]);
			}
			/* Copy header-part of buffer to header-buffer */
			if(crr > 0)
			{/* Only part of buffer */
				if(head_len+crr < HEAD_BUF)
				{	strncpy(&(head[head_len]), buf, crr); head_len+=crr;}
				else if(head_len < HEAD_BUF)
				{	strncpy(&(head[head_len]), buf, HEAD_BUF-head_len); head_len=HEAD_BUF;}
			}
			else
			{
				if(head_len+ret < HEAD_BUF)
				{	strncpy(&(head[head_len]), buf, ret); head_len+=ret;}
				else if(head_len < HEAD_BUF)
				{	strncpy(&(head[head_len]), buf, HEAD_BUF-head_len); head_len=HEAD_BUF;}
			}
			
			/* Check for complete header and get Info */
			if((crlf_seen==4) && (head_len > 4))
			{
				head[head_len]=0;
				parse_header(head, rinf);
				if(head_only)	/* Successfull */
				{
					shutdown(s, 2);
					sclose(s);
					return(0);
				}
				if(rinf->size > -1)
					browser->msg_status(STATUS_DATALENGTH,rinf->size);
			}
			
			if(ret==0)			/* Buffer ends with header */
				continue;
		}
			
		if(crlf_seen == 4)
		{	/* Write and count message */
			tot_rcv+=ret;
			if(dest_path != NULL)
			{
				if(dest_file < 0)
				{
					dest_file=(int)Fcreate(dest_path, 0);
					if(dest_file < 0)
					{
						Dftext("\r\n*File create error ");Dfnumber(dest_file);Dftext("*\r\n");
						shutdown(s,2);
						sclose(s);
						return(dest_file);
					}
				}
				Fwrite(dest_file, ret, wbuf);
			}
			browser->msg_status(STATUS_RECEIVING_DATA,tot_rcv);		}
	}

	shutdown(s,2);
	sclose(s);

	if(dest_file > -1)
		Fclose(dest_file);
		
	rinf->recv_bytes=tot_rcv;
	if(head_len==-1)
	{
		rinf->http_vers=9;
		if(tot_rcv > 0)
			return(0);
		return(-1);	/* Received nothing */
	}
	if(head_len < 5) 
		return(-1);	

	set_file_time(dest_file, rinf->timestamp);
	return(0);
}

char *auth_encode(char *user, char *pass)
{
	static uchar buf[200], dst[256];
	long	cnt;
	uchar	*c, *d;
	uchar	x, x1, x2, x3, x4;
	
	strcpy((char*)buf, user); strcat((char*)buf, ":"); strcat((char*)buf, pass);

	c=buf; d=dst; 
	cnt=strlen((char*)buf);

	while(cnt)
	{
		if(cnt >= 3)
		{
			x=r_iso8859_1[*c++];
			x1=x>>2;
			x2=(x&3)<<4; x=r_iso8859_1[*c++];
			x2|=x>>4;
			x3=(x&15)<<2; x=r_iso8859_1[*c++];
			x3|=x>>6;
			x4=x&63;
			*d++=base64_encode[x1];			
			*d++=base64_encode[x2];			
			*d++=base64_encode[x3];			
			*d++=base64_encode[x4];			
			cnt-=3;
		}
		else if(cnt==2)
		{
			x=r_iso8859_1[*c++];
			x1=x>>2;
			x2=(x&3)<<4; x=r_iso8859_1[*c++];
			x2|=x>>4;
			x3=(x&15)<<2;
			*d++=base64_encode[x1];			
			*d++=base64_encode[x2];			
			*d++=base64_encode[x3];			
			*d++='=';			
			cnt=0;
		}
		else /* cnt==1 */
		{
			x=r_iso8859_1[*c++];
			x1=x>>2;
			x2=(x&3)<<4; 
			*d++=base64_encode[x1];			
			*d++=base64_encode[x2];			
			*d++='=';			
			*d++='=';			
			cnt=0;
		}
	}
	*d=0;
	return((char*)dst);
}

long get_any(ulong ip, int port, char *url, char *command, char *path, RECV_INFO *rinf, char *add_head, char *add_entity, int head_only, char *cookie, char *auth)
{/* Return: 0=Ok, -1=Request-Fehler, 
		EFILNF=File auf Host nicht gefunden, CAB-Vorgabe f. Zieldatei
		wird gel”scht */
	static char user[64], pass[64], cmd[1024];
	char 	*inp;
	long	ret;

	if(rinf)
		strcpy(rinf->url, url);
	
	strcpy(cmd, command);
	strcat(cmd, url);
	strcat(cmd, " HTTP/1.0\r\n");
	if(auth)
	{
		strcat(cmd, "Authorization: Basic ");
		strcat(cmd, auth);
		strcat(cmd, "\r\n");
	}
	if(add_head)
		strcat(cmd, add_head);
	strcat(cmd, "User-Agent: ");
	strcat(cmd, user_agent);
	strcat(cmd, "\r\n");
	strcat(cmd, "Host: ");
	strcat(cmd, act_host);
	strcat(cmd, "\r\n");
	strcat(cmd, "Accept: */*\r\n");
	if(cookie)
	{
		strcat(cmd, "Cookie: ");
		strcat(cmd, cookie);
		strcat(cmd, "\r\n");
	}
	strcat(cmd, "\r\n");
	
	ret=request(ip, port, cmd, add_entity, path, rinf, head_only);

	if(rinf->res_code==304)
	{
		Dftext("\r\nNOT MOD\r\n");
		return(0);	/* Not modified */
	}
	
	if((rinf->res_code/100 == 3) && (rinf->location[0]))	/* Redirection */
	{
		if(browser->new_url_cookie(rinf->location, &path, &cookie)==0)	/* Fetch new doc*/
		{
			ret=1;	/* Fake up file time */
			return(download_mod_url(rinf->location, path, &ret, cookie));
		}
	}
	
	if((rinf->res_code==401) && (rinf->basic_auth==1) && (auth==NULL))
	{/* Authentication required */
		/* Already authenticated? */
		if(!strcmp(last_realm, rinf->auth_realm))
		{
			last_realm[0]=0;
			return(get_any(ip, port, url, command, path, rinf, add_head, add_entity, head_only, cookie, auth_encode(user, pass)));
		}

		strcpy(last_realm, rinf->auth_realm);
		if(browser->ask_user(0, &inp)==1)
		{
			strncpy(user, inp, 63); user[63]=0;
			if(browser->ask_user(1, &inp)==1)
			{
				strncpy(pass, inp, 63); pass[63]=0;
				return(get_any(ip, port, url, command, path, rinf, add_head, add_entity, head_only, cookie, auth_encode(user, pass)));
			}
		}
		last_realm[0]=0;
	}
	
	if(rinf->res_code==404) /* File not found */
	{
		Fdelete(path);
		return(EFILNF);
	}
	
	return(ret);
}

long get_page(ulong ip, int port, char *url, char *path, long timep, char *cookie)
{/* if timep is not 0, "If-Modified-Since" will be added */
	RECV_INFO	rinf;

	char	add_head[512], tbuf[30];

	Dftext("\r\n---Getting page---\r\n");	

	if(timep)
	{
		strcpy(add_head, "If-Modified-Since: ");
		strcat(add_head, time_to_a(timep, tbuf));
		strcat(add_head, "\r\n");
	}
	else
		add_head[0]=0;

	return(get_any(ip, port, url, "GET ", path, &rinf, add_head, NULL, 0, cookie, NULL));
}

long get_head(ulong ip, int port, char *url, RECV_INFO *rinf)
{
	Dftext("\r\n---Getting head---\r\n");
	return(get_any(ip, port, url, "HEAD ", NULL, rinf, NULL, NULL, 1, NULL, NULL));
}

/* 
**************
   VISIBLE
**************
*/

long download_url(char *url, char *path, char *cookie)
{
	int 					proxy=0;
	ulong					d_ip;
	URL						surl;
	USIS_REQUEST	ur;
	
	if(!strnicmp(url, "http://debug.log.on",19))
	{debug_on();browser->alert_box(1,1);return(-1);}
	if(!strnicmp(url, "http://debug.log.off", 20))
	{debug_off();browser->alert_box(1,1);return(-1);}

	if(parse_url(url, &surl, http_port, "http")==-1)
		return(-1);

	strcpy(act_host, surl.host);

	ur.request=UR_PROXY_IP;
	ur.free1="http";
	ur.free2=surl.host;
	if(usis_query(&ur)==UA_FOUND) 
		proxy=1;
	else
	{
		browser->msg_status(STATUS_RESOLVING_HOST,0);	
		d_ip=my_gethostbyname(surl.host);
		if(d_ip==0)
			return(-1);	/* Host not found */
	}
	
	if(proxy)
		return(get_page(ur.ip, ur.port, url, path, 0, cookie));

	return(get_page(d_ip, surl.port, surl.path, path, 0, cookie));
}

long header_of_url(char *url, RECV_INFO *rinf)
{
	int						proxy=0;
	ulong					d_ip;
	URL						surl;
	USIS_REQUEST	ur;

	if(!strnicmp(url, "http://debug.log.on",19))
	{debug_on();browser->alert_box(1,1);return(-1);}
	if(!strnicmp(url, "http://debug.log.off", 20))
	{debug_off();browser->alert_box(1,1);return(-1);}

	if(parse_url(url, &surl, http_port, "http")==-1)
		return(-1);

	strcpy(act_host, surl.host);

	ur.request=UR_PROXY_IP;
	ur.free1="http";
	ur.free2=surl.host;
	if(usis_query(&ur)==UA_FOUND)
		proxy=1;
	else
	{
		browser->msg_status(STATUS_RESOLVING_HOST,0);	
		d_ip=my_gethostbyname(surl.host);
		if(d_ip==0)
			return(-1);	/* Host not found */
	}

	if(proxy)
		return(get_head(ur.ip, ur.port, url, rinf));

	return(get_head(d_ip, surl.port, surl.path, rinf));
}

long download_mod_url(char *url, char *path, long *timep, char *cookie)
{
	int 					proxy=0;
	ulong					d_ip;
	URL						surl;
	USIS_REQUEST	ur;

	if(!strnicmp(url, "http://debug.log.on",19))
	{debug_on();browser->alert_box(1,1);return(-1);}
	if(!strnicmp(url, "http://debug.log.off", 20))
	{debug_off();browser->alert_box(1,1);return(-1);}
	
	if(parse_url(url, &surl, http_port, "http")==-1)
		return(-1);

	strcpy(act_host, surl.host);

	ur.request=UR_PROXY_IP;
	ur.free1="http";
	ur.free2=surl.host;
	if(usis_query(&ur)==UA_FOUND)
	 proxy=1;
	else
	{
		browser->msg_status(STATUS_RESOLVING_HOST,0);	
		d_ip=my_gethostbyname(surl.host);
		if(d_ip==0)
			return(-1);	/* Host not found */
	}
	
	if(proxy==1) Dftext("Using proxy\r\n");
	else Dftext("No proxy\r\n");

	if(proxy)
		return(get_page(ur.ip, ur.port, url, path, *timep, cookie));

	return(get_page(d_ip, surl.port, surl.path, path, *timep, cookie));
}

long post_data(char *url, char *content, char *enctype, char *path, char *cookie)
{
	int 					proxy=0;
	ulong					d_ip;
	URL						surl;
	USIS_REQUEST	ur;
	RECV_INFO			rinf;
	char					add_head[2048], num[32];

	if(!strnicmp(url, "mailto", 6))
		return(send_mail(url, "No subject", path));
		
	if(parse_url(url, &surl, http_port, "http")==-1)
		return(-1);

	strcpy(act_host, surl.host);
	
	ur.request=UR_PROXY_IP;
	ur.free1="http";
	ur.free2=surl.host;
	if(usis_query(&ur)==UA_FOUND)
		 proxy=1;
	else
	{
		browser->msg_status(STATUS_RESOLVING_HOST,0);
		d_ip=my_gethostbyname(surl.host);
		if(d_ip==0)
			return(-1);	/* Host not found */
	}
	
	Dftext("\r\n---Getting Post---\r\n");

	strcpy(add_head, "Referer: ");
	strcat(add_head, url);
	strcat(add_head, "\r\n");
	strcat(add_head, "Content-length: ");
	strcat(add_head, itoa((int)strlen(content), num, 10));
	strcat(add_head, "\r\n");
	strcat(add_head, "Content-type: ");
	strcat(add_head, enctype);
	strcat(add_head, "\r\n");
	
	if(proxy)
		return(get_any(ur.ip, ur.port, url, "POST ", path, &rinf, add_head, content, 0, cookie, NULL));

	return(get_any(d_ip, surl.port, surl.path, "POST ", path, &rinf, add_head, content, 0, cookie, NULL));
}
