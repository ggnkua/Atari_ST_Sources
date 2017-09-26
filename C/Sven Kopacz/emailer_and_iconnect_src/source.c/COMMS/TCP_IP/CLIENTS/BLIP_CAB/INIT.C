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
** Modified by Sven Kopacz, 16.02.1997
** Last update 30.06.1998
**
** This file can be redistributed under the terms of the GNU General
** Public Licence.
*/

/* Version BCD xx.xx */
#define LVERSION    0x00010700L
#define LDATE    0x19981803L

#include "module.h"#include <tos.h>#include <stdio.h>#include <stdarg.h>
#include <string.h>
#include <stdlib.h>#include <ctype.h>#include <time.h>#include <sockinit.h>
#include <inet.h>#include <netdb.h>
#include <usis.h>

#include "blip_cab.h"

/*--- Prototypes ---*/
long ___CDECL init_module(url_methods_t *out, browser_info_t *in, char *path);
void ___CDECL get_version(char **authorp, long *versionp, long *datep);
void ___CDECL restore_module(void);

long ___CDECL get_url_info(char *url, long *timep, long *sizep, char *type);

long ___CDECL get_url(char *url, char *filename);
long ___CDECL get_url_cookie(char *url, char *filename, char *cookie);
long ___CDECL get_url_if_modified(char *url, char *filename, long *timep);
long ___CDECL get_url_ifmod_cookie(char *url, char *filename, long *timep, char *cookie);

long ___CDECL post(char *url,char *content, char *enctype, char *filename);
long ___CDECL post_cookie(char *url,char *content, char *enctype, char *filename, char *cookie);

long ___CDECL mailto(char *url, char *subject, char *filename);
/*--- Global variables ---*/
browser_info_t *browser;
int http_port, smtp_port, nntp_port;

extern char *user_agent;

int	debhand=-1;

void debug_on(void)
{
	if(debhand==-1)	debhand=(int)Fcreate("DEBUG.LOG",0);
	if(debhand < 0) debhand=-1;
}
void debug_off(void)
{
	if(debhand != -1) Fclose(debhand);
	debhand=-1;
}

void Dftext(char *c)
{
	if(debhand < 0) return;
	Fwrite(debhand, strlen(c), c);
}
void Dfnumber(long i)
{
	char l[32];
	if(debhand < 0) return;
	ltoa(i, l, 10);
	Fwrite(debhand, strlen(l), l);
}

/* ----------------------------------------------------------------- ** 
** init_module - Initialize the module (called by browser)           ** 
** ----------------------------------------------------------------- */
long ___CDECL init_module(out, in, path)
url_methods_t *out;	/* struture to fill */
browser_info_t *in;	/* infos about browser */
char *path;		/* module path, '\' terminated */
{
	servent	*se;
	USIS_REQUEST	ur;
	long		lversion=LVERSION+0x30303030l;

	/* Supress warning */
	if(path);
		
  /*--- Set browser info variable ---*/
  browser = in;
	_BasPag=(BASPAG*)(in->basepage);

  /*--- Fill URL methods structure ---*/
  out->restore = restore_module;
  out->get_version = get_version;

  out->get_url_info = get_url_info;
  out->get_url = get_url;
  out->get_url_cookie=get_url_cookie;
  out->get_url_if_modified = get_url_if_modified;
  out->get_url_ifmod_cookie = get_url_ifmod_cookie;

  out->post = post;
  out->post_cookie = post_cookie;

  out->mailto = mailto;

  /*--- Initialize other stuffs here ---*/
  if(sock_init() < 0)
  	return(0);
  	
	se=getservbyname("http", "tcp");
	if(se==NULL)
		http_port=DEFAULT_HTTP_PORT;
	else
		http_port=se->s_port;
	se=getservbyname("smtp", "tcp");
	if(se==NULL)
		smtp_port=DEFAULT_SMTP_PORT;
	else
		smtp_port=se->s_port;
	se=getservbyname("nntp", "tcp");
	if(se==NULL)
		nntp_port=DEFAULT_NNTP_PORT;
	else
		nntp_port=se->s_port;
  
	/* Version of CAB */  strncpy(&(user_agent[17]), (char*)&(in->version), 2);  strncpy(&(user_agent[20]), &(((char*)&(in->version))[2]), 2);	/* Version of OVL */
	strncpy(&(user_agent[34]), (char*)&lversion, 2);
	strncpy(&(user_agent[37]), &(((char*)&lversion)[2]), 2);
	
  /* Write proxies and servers */
  if(in->proxy)
  {
  	ur.request=UR_PROXY_IP;
  	ur.free1="ftp";
  	ur.free2=NULL;
  	if(usis_query(&ur)==UA_FOUND) strcpy(in->proxy->ftp_proxy, inet_ntoa(ur.ip));
  	ur.free1="http";
  	if(usis_query(&ur)==UA_FOUND) strcpy(in->proxy->http_proxy, inet_ntoa(ur.ip));  	ur.free1="wais";
  	if(usis_query(&ur)==UA_FOUND) strcpy(in->proxy->wais_proxy, inet_ntoa(ur.ip));  	ur.free1="gopher";
  	if(usis_query(&ur)==UA_FOUND) strcpy(in->proxy->gopher_proxy, inet_ntoa(ur.ip));  	ur.free1="news";
  	if(usis_query(&ur)==UA_FOUND) strcpy(in->proxy->news_proxy, inet_ntoa(ur.ip));
  	ur.request=UR_SMTP_IP;
  	if(usis_query(&ur)==UA_FOUND)	strcpy(in->proxy->smtp_server, inet_ntoa(ur.ip));
  	ur.request=UR_NEWS_IP;
  	if(usis_query(&ur)==UA_FOUND)	strcpy(in->proxy->nntp_server, inet_ntoa(ur.ip));
  }
  
  /*--- Return support ---*/
  return(SUPPORT_HTTP|SUPPORT_MAILTO|SUPPORT_NNTP);
}


/* ----------------------------------------------------------------- ** 
** get_version - Returns infos about module                          ** 
** ----------------------------------------------------------------- */
void ___CDECL get_version(authorp, versionp, datep)
char **authorp;	/* 4x30 chars separated by '|' */
long *versionp;	/* Version number in BCD format (V1.15 -> 0x00011500) */
long *datep;	/* Date in BCD format (0xYYYYMMDD) */
{
   *versionp = LVERSION;
   *datep = LDATE;
   *authorp = "CAB on I-Con|by Sven Kopacz";
}


/* ----------------------------------------------------------------- ** 
** restore_module - De-initialization                                ** 
**                  (freeing memory, closing files, etc...)          ** 
** ----------------------------------------------------------------- */
void ___CDECL restore_module()
{
	debug_off();
}


/* ----------------------------------------------------------------- ** 
** get_url - Fetch URL and write it as a HTML file                   ** 
**           Returns 0 if OK, else `errno'                           **
** ----------------------------------------------------------------- */
long ___CDECL get_url(url, filename)
char *url;		/* URL to fetch */
char *filename;		/* file to write to */
{
	Dftext("Call: GET "); Dftext(url); Dftext("\r\n");
	
	if(strnicmp(url, "news", 4))
		return(download_url(url, filename, NULL));
	return(download_news(url, filename));
}
long ___CDECL get_url_cookie(url, filename, cookie)
char *url;		/* URL to fetch */
char *filename;		/* file to write to */
char *cookie;
{
	Dftext("Call: GET_C "); Dftext(url); Dftext("\r\n");
	
	if(strnicmp(url, "news", 4))
		return(download_url(url, filename, cookie));
	return(download_news(url, filename));
}

/* ----------------------------------------------------------------- ** 
** get_url_if_modified - Fetch URL and write it as a HTML file                   ** 
**           						 Returns 0 if OK, else `errno'                           **
** ----------------------------------------------------------------- */
long ___CDECL get_url_if_modified(url, filename, timep)
char *url;				/* URL to fetch */
char *filename;		/* file to write to */
long *timep;				/* Timepointer of cached file */
{
	Dftext("Call: GET_IF_MOD "); Dftext(url); Dftext("\r\n");

	if(strnicmp(url, "news", 4))
		return(download_mod_url(url, filename, timep, NULL));
	return(download_news(url, filename));
}
long ___CDECL get_url_ifmod_cookie(url, filename, timep, cookie)
char *url;				/* URL to fetch */
char *filename;		/* file to write to */
long *timep;				/* Timepointer of cached file */
char *cookie;
{
	Dftext("Call: GET_IF_MOD_C "); Dftext(url); Dftext("\r\n");

	if(strnicmp(url, "news", 4))
		return(download_mod_url(url, filename, timep, cookie));
	return(download_news(url, filename));
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
  return(post_data(url, content, enctype, filename, NULL));
}
long ___CDECL post_cookie(url, content, enctype, filename, cookie)
char *url;     		/* URL to fetch */
char *content;      /* data to post */
char *enctype;      /* format of data */
char *filename;		/* file to write to */
char *cookie;
{
  return(post_data(url, content, enctype, filename, cookie));
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
	RECV_INFO	rinf;
	
	Dftext("Call: GET_INFO "); Dftext(url); Dftext("\r\n");

	if(header_of_url(url, &rinf)<0)
		return(-1);
		
	*sizep=rinf.size;
	strcpy(type,rinf.cont_type);
	*timep=rinf.timestamp;
  return 0;
}

/* ----------------------------------------------------------------- **** mailto - Sends file <filename> as mail to url                     **** ----------------------------------------------------------------- */long ___CDECL mailto(url, subject, filename)char *url;         /* URL: 'mailto:user@address' */char *subject;     /* Subject for mail */char *filename;    /* File */{	Dftext("Call: MAIL\r\n");
  return(send_mail(url, subject, filename));}
/* ----------------------------------------------------------------- ** 
** main - Doesn't useful, but take care that others functions don't  ** 
**        get `swallowed' by compiler optimizations                  ** 
** ----------------------------------------------------------------- */
int main()
{
  static void *array[] = {
    "Needs HTML.APP to run\r\n",
    (void *)BROWSER_MAGIC1, (void *)BROWSER_MAGIC2,
    (void *)BROWSER_MAGIC3, (void *)BROWSER_MAGIC4, init_module};
  
  write(1, array[0], strlen(array[0]));
  return 1;
}
