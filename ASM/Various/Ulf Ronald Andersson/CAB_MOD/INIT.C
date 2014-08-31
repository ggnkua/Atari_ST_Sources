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

#include <unistd.h>
#include "module.h"


/*--- Prototypes ---*/
long ___CDECL init_module(url_methods_t *out, browser_info_t *in, char *path);
long ___CDECL get_url_info(char *url, long *timep, long *sizep, char *type);
void ___CDECL get_version(char **authorp, long *versionp, long *datep);
long ___CDECL get_url(char *url, char *filename);
long ___CDECL post(char *url,char *content, char *enctype, char *filename);
void ___CDECL restore_module(void);
long ___CDECL mailto(char *url, char *subject, char *filename);
long ___CDECL get_url_if_modified(char *url, char *filename, long *time);

/*--- Global variables ---*/
browser_info_t *browser;

/* ----------------------------------------------------------------- **
** init_module - Initialize the module (called by browser)           **
** ----------------------------------------------------------------- */
long ___CDECL init_module(out, in, path)
url_methods_t *out;  /* struture to fill */
browser_info_t *in;  /* infos about browser */
char *path;    /* module path, '\' terminated */
{
  /*--- Set browser info variable ---*/
  browser = in;

  /*--- Fill URL methods structure ---*/
  out->restore = restore_module;
  out->get_url = get_url;
  out->get_url_info = get_url_info;
  out->get_version = get_version;
  out->mailto = mailto;
  out->post = post;
  out->get_url_if_modified = get_url_if_modified;

  /*--- Initialize other stuffs here ---*/

  /*--- Return support ---*/
  return(SUPPORT_HTTP|SUPPORT_FTP);
}

/* ----------------------------------------------------------------- **
** mailto - Sends file <filename> as mail to url                     **
** ----------------------------------------------------------------- */
long ___CDECL mailto(url, subject, filename);
char *url;         /* URL: 'mailto:user@address' */
char *subject;     /* Subject for mail */
char *filename;    /* File */
{

  return 0;
}


/* ----------------------------------------------------------------- **
** get_version - Returns infos about module                          **
** ----------------------------------------------------------------- */
void ___CDECL get_version(authorp, versionp, datep)
char **authorp;   /* 4x30 chars separated by '|' */
long *versionp;   /* Version number in BCD format (V1.15 -> 0x00011500) */
long *datep;   /* Date in BCD format (0xYYYYMMDD) */
{
   *versionp = 0x00010000L;
   *datep = 0x19950827L;
   *authorp = "Stephane Boisson|EMAIL: boisson@worldnet.net";
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
char *url;     /* URL to fetch */
char *filename;      /* file to write to */
{
  return 0;
}


/* ----------------------------------------------------------------- **
** post    - Post FORM, fetch result and write it as a HTML file     **
**           Returns 0 if OK, else `errno'                           **
** ----------------------------------------------------------------- */
long ___CDECL post(url, content, enctype, filename);
char *url;           /* URL to fetch */
char *content;      /* data to post */
char *enctype;      /* format of data */
char *filename;      /* file to write to */
{
  return 0;
}


/* ----------------------------------------------------------------- **
** get_url_info - Retreive infos for an URL                          **
**                Returns 0 if OK, else `errno'                      **
** ----------------------------------------------------------------- */
long ___CDECL get_url_info(url, timep, sizep, type)
char *url;  /* URL */
long *timep;   /* UNIX time */
long *sizep;   /* size of data */
char *type; /* mime type (max len = 250), empty string if unknow */
{
  return 0;
}


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
