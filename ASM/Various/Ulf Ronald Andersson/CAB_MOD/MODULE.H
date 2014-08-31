/*
** module.h for Inet-Module
** API header for HTML.APP browser inet-module
**
** Copyright (C) 1995, Stephane Boisson. All Rights reserved.
** Login <boisson@worldnet.net>
**
** Started on  Sun Aug 27 22:21:42 1995 Stephane Boisson
** Last update Sun Oct 29 16:20:52 1995 Stephane Boisson
**
** This file can be redistributed under the terms of the GNU General
** Public Licence.
*/

#ifndef __BROWSER_INET_API__H__
#define __BROWSER_INET_API__H__

/*--- Macro for prototyping ---*/
#ifdef __PUREC__
#  define ___CDECL cdecl
#else
#  define ___CDECL
#endif


/*--- Magic values ---*/
#define BROWSER_MAGIC1 0x48744d6cL
#define BROWSER_MAGIC2 0x2f577757L
#define BROWSER_MAGIC3 0x2d42724fL
#define BROWSER_MAGIC4 0x77536552L  /* -> CAB must Mshrink     */
#define BROWSER_MAGIC4BIS 0x77536572L  /* -> CAB must not Mshrink */

/*--- Init codes ---*/
#define SUPPORT_PEXEC 1    /* module uses pexec() to call another prog */
#define SUPPORT_HTTP 2
#define SUPPORT_FTP 4
#define SUPPORT_GOPHER 8
#define SUPPORT_WAIS 16
#define SUPPORT_MAILTO 32
#define SUPPORT_NNTP 64
#define SUPPORT_TELNET 128

/*--- Messages types for `msg_status' ---*/
#define STATUS_CONNECTING_HOST 1
#define STATUS_RECEIVING_DATA 2     /* val = bytes received */
#define STATUS_WAITING_RESPONSE 3
#define STATUS_RESOLVING_HOST 4
#define STATUS_SENDING_REQUEST 5
#define STATUS_FORMATTING_TEXT 6
#define STATUS_LOADING_IMAGE 7
#define STATUS_WAITINGFORDATA 10   /* val = timeout */
#define STATUS_DATALENGTH 12345    /* val = length of data */

/*--- Alert boxes for `alert_box' ---*/
#define ALERT_ABORT 0      /* [2][Abort?][Yes|No] */

/*--- Request types for `ask_user' ---*/
#define REQUEST_NAME 0     /* Document protected, enter name (account) */
#define REQUEST_PASSWORD 1 /* Document protected, enter password       */

/*--- Internal images bullets ---*/
#define BULLET_FOLDER "<img src=\"internal-gopher-menu\">"
#define BULLET_TEXT "<img src=\"internal-gopher-text\">"
#define BULLET_IMAGE "<img src=\"internal-gopher-image\">"
#define BULLET_MOVIE "<img src=\"internal-gopher-movie\">"
#define BULLET_SOUND "<img src=\"internal-gopher-sound\">"
#define BULLET_INDEX "<img src=\"internal-gopher-index\">"
#define BULLET_BINARY "<img src=\"internal-gopher-binary\">"
#define BULLET_UNKNOW "<img src=\"internal-gopher-unknown\">"


/*--- Module functions used by the browser ---*/
typedef struct
{
  void ___CDECL (*restore)(void);
  long ___CDECL (*get_url)(char *url, char *filename);
  long ___CDECL (*get_url_info)(char *url, long *time, long *size, char *mime);
  void ___CDECL (*get_version)(char **author, long *version, long *date);
  long ___CDECL (*post)(char *url, char *content, char *enctype, char *filename);
  long ___CDECL (*mailto)(char *url, char *subject, char *filename);
  long ___CDECL (*get_url_if_modified)(char *url, char *filename, long *time);
  long reserved[3];
} url_methods_t;


/*--- Browser functions intended to be used by module ---*/

typdef struct
{
   char *ftp_proxy;
   char *http_proxy;
   char *wais_proxy;
   char *gopher_proxy;
   char *news_proxy;
   char *no_proxy;
   char *smtp_server;
   char *nntp_server;
} proxy_url;

typedef struct
{
  /*___AES arrays in case of GEM use___*/
  int *aes_control;
  int *aes_global;
  int *aes_intin;
  int *aes_intout;
  long   *aes_addrin;
  long   *aes_addrout;

  /*___Init AES in case of GEM use___*/
  void   ___CDECL (*aes_crystal)(void);

  /*___Send AES messages to browser___*/
  void   ___CDECL (*aes_messages)(int *msg);

  /*___Display error message (see errno.h)___*/
  void   ___CDECL (*msg_error)(long errno);

  /*___Display status message___*/
  void   ___CDECL (*msg_status)(long no, long val);

  /*___Sleeps for `time' msec, returns pointer to AES msg___*/
  /* 0L -> no message, go on / -1L -> no messages abort */
  long   ___CDECL (*aes_events)(long msec);

  /*___Alert box___*/
  long   ___CDECL (*alert_box)(long button, long msg);

  /*___Use in case of pexec(0, ...)___*/
  void   ___CDECL (*begin_pexec)();
  void   ___CDECL (*end_pexec)();

  /*___Clear cache to get at least `size' bytes free___*/
  /* -1 -> failure / 0 -> OK */
  int ___CDECL (*clear_cache)(long size);

  /*___Get a new filename for spcific URL___*/
  /* -1 -> already cached / 0 -> OK */
  int ___CDECL (*new_url)(char *url, char **file);

  /*___Ask user for a text entry ___*/
  /* 1 -> OK button / 0 -> CANCEL button / -1 -> error*/
  int ___CDECL (*ask_user)(long msg, char **answer);

  /*___Address of the basepage of the module__*/
  long basepage;

  /*___*reloadflag is 1 if the user wants to reload the page___*/
  int *reloadflag;

  /*___ Version of CAB in ASCII format. V1.30 is 0x30313330  ___*/
  long version;

  /*___ Pointer to the proxy information ___*/
  proxy_url *proxy;

  /*___ Tell CAB, that it is now online or offline ___*/
  void ___CDECL (*online)(int state);

  /*___Reserved for future uses___*/
  long   reserved[3];
} browser_info_t;


#endif /* !__BROWSER_INET_API__H__ */
