/*
 *  Copyright (c) 2004, Dennis Kuschel.
 *  All rights reserved. 
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *   3. The name of the author may not be used to endorse or promote
 *      products derived from this software without specific prior written
 *      permission. 
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 *  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 *  INDIRECT,  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 *  OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * @file    ftpd.c
 * @author  Dennis Kuschel
 * @brief   FTP demon for embedded devices
 *
 * This software is from http://mycpu.mikrocontroller.net.
 * Please send questions and bug reports to dennis_k@freenet.de.
 */

#include "config.h"
#include "ftpd.h"

#undef DEBUG

#ifdef NETWORK
#ifdef LWIP
#ifdef FTP_SERVER

/*---------------------------------------------------------------------------
 *  DEFINES
 *-------------------------------------------------------------------------*/

#define FTP_PORT        21
#define FTP_MAXCON      10
#define FTP_TIMEOUT     600
#define MAX_BLOCKSIZE   4096
#define FTP_INPBUFSIZE  256
#define FTP_FNAMESIZE   FS_MAXFNAMELEN
#define MAX_NAMESIZE    16



/*---------------------------------------------------------------------------
 *  TYPEDEFS
 *-------------------------------------------------------------------------*/

/* forward declaration */
typedef struct connection_s  connection_t;
typedef struct transfer_s    transfer_t;

typedef void (*CMDFUNC_t)(connection_t *conn, char *param);


typedef struct {
  char       name[8];
  u16_t      arg;
  u16_t      auth;
  CMDFUNC_t  cmdfunc;
} CMDINFO_t;


/* List link header.
 * This structure is equal to the
 * head of struct connection_s and
 * struct transfer_s.
 */
typedef struct lelem_s  lelem_t;
struct lelem_s
{
  lelem_t   *prev;
  lelem_t   *next;
};


#define INIT_LIST_HEAD(head) \
  do { (head)->prev = head; (head)->next = head; } while(0)
#define END_OF_LIST(head, elem)  ((void*)(head) == (void*)(elem))
#define NEXT_LIST_ELEM(elem, type)   \
          (type)(void*)((lelem_t*)(void*)(elem))->next
#define PREV_LIST_ELEM(elem, type)   \
          (type)(void*)((lelem_t*)(void*)(elem))->prev
#define FIRST_LIST_ELEM(head, type)  NEXT_LIST_ELEM(head, type)
#define LAST_LIST_ELEM(head, type)   PREV_LIST_ELEM(head, type)


/* This structure describes a connection.
 */
struct connection_s
{
  lelem_t               list;
  transfer_t            *transfer;
  portTickType          lastTrans;
  int                   sock;
  u16_t                 auth;
  u16_t                 buflen;
  u32_t                 resumePos;
  char                  username[(MAX_NAMESIZE+1+3)&~3];
  char                  rxbuffer[FTP_INPBUFSIZE];
  char                  renfrom[FTP_FNAMESIZE];
#if FS_SUBDIRECTORIES
  char                  curpath[FTP_FNAMESIZE];
#endif
};


/* This structure describes a file transfer.
 */
struct transfer_s
{
  lelem_t               list;
  connection_t          *owner;
  u16_t                 state;
  u16_t                 spare;
  u16_t                 append;
  u16_t                 upload;
  u32_t                 size;
  u32_t                 pos;
  u32_t                 dlbufpos;
  u32_t                 dlbufremain;
  portTickType          starttime;
  struct sockaddr_in    sin;
  int                   sock;
  sint_t                wrDisabled;
  sint_t                filehandle;
  sint_t                dirhandle;
  sint_t                dirlisting;
  char                  dlbuf[MAX_BLOCKSIZE];
  char                  filename[FTP_FNAMESIZE];
};

/* transfer states */
#define TSTATE_NONE         0
#define TSTATE_GOTPASV      1
#define TSTATE_WAITONPASV   2
#define TSTATE_GOTPORT      3
#define TSTATE_WAITFORPORT  4
#define TSTATE_TRANSFER     5



/*---------------------------------------------------------------------------
 *  FUNCTION PROTOTYPES
 *-------------------------------------------------------------------------*/

static sint_t  ft_newServerSocket(void);
static sint_t  ft_fdSanity(void);
static void    ft_listAddTail(lelem_t *headelem, lelem_t *elem);
static void    ft_listAddHead(lelem_t *headelem, lelem_t *elem);
static void    ft_listDel(lelem_t *elem);
static sint_t  ft_processCtrlConnections(fd_set *clientset, int fdcount);
static sint_t  ft_processDataConnections(fd_set* clientset, int fdcount);
static sint_t  ft_handleUpload(transfer_t *tran);
static sint_t  ft_handleDownload(transfer_t *tran);
static void    ft_acceptClient(void);
static void    ft_timeout(void);
static void    ft_initTransfer(transfer_t *tran);
static void    ft_prepTransfer(transfer_t *tran);
static void    ft_execStore(connection_t *conn, char *param, sint_t appflag);
static void    ft_getFilename(connection_t *conn, char *param, char *dst);
static void    ft_execCommand(connection_t *conn);
static void    ft_removeRxbufBytes(connection_t *conn, u16_t count);
static void    ft_reply(connection_t *conn, u16_t num, const char *fmt, ...);
static void    ft_destroyConnection(connection_t *conn);
static void    ft_destroyTransfer(transfer_t *tran);
static sint_t  ft_addSendSocket(const int sock);
static sint_t  ft_addSocket(const int sock);
static void    ft_delSocket(const int sock);
static void    ft_abortTransfer(connection_t *conn);
static sint_t  ft_getNextDirEntry(transfer_t *tran, char *buf);
static sint_t  ft_newConnection(int socket);
static transfer_t*   ft_newTransfer(int socket, connection_t *conn);
static transfer_t*   ft_setupNewTransfer(connection_t *conn);
static void    ft_doListing(connection_t *conn, char *param,sint_t fulllist);
#if FS_SUBDIRECTORIES
static sint_t  ft_changeCurrentPath(connection_t *conn, char *path);
#endif

static void    ftcmd_abor(connection_t *conn, char *param);
static void    ftcmd_acct(connection_t *conn, char *param);
static void    ftcmd_allo(connection_t *conn, char *param);
static void    ftcmd_appe(connection_t *conn, char *param);
static void    ftcmd_cdup(connection_t *conn, char *param);
static void    ftcmd_cwd (connection_t *conn, char *param);
static void    ftcmd_dele(connection_t *conn, char *param);
static void    ftcmd_help(connection_t *conn, char *param);
static void    ftcmd_list(connection_t *conn, char *param);
static void    ftcmd_mdtm(connection_t *conn, char *param);
static void    ftcmd_mkd (connection_t *conn, char *param);
static void    ftcmd_mode(connection_t *conn, char *param);
static void    ftcmd_nlst(connection_t *conn, char *param);
static void    ftcmd_noop(connection_t *conn, char *param);
static void    ftcmd_rnfr(connection_t *conn, char *param);
static void    ftcmd_rnto(connection_t *conn, char *param);
static void    ftcmd_pass(connection_t *conn, char *param);
static void    ftcmd_pasv(connection_t *conn, char *param);
static void    ftcmd_port(connection_t *conn, char *param);
static void    ftcmd_pwd (connection_t *conn, char *param);
static void    ftcmd_quit(connection_t *conn, char *param);
static void    ftcmd_rein(connection_t *conn, char *param);
static void    ftcmd_rest(connection_t *conn, char *param);
static void    ftcmd_retr(connection_t *conn, char *param);
static void    ftcmd_rmd (connection_t *conn, char *param);
static void    ftcmd_size(connection_t *conn, char *param);
static void    ftcmd_stat(connection_t *conn, char *param);
static void    ftcmd_stor(connection_t *conn, char *param);
static void    ftcmd_stru(connection_t *conn, char *param);
static void    ftcmd_syst(connection_t *conn, char *param);
static void    ftcmd_type(connection_t *conn, char *param);
static void    ftcmd_user(connection_t *conn, char *param);



/*---------------------------------------------------------------------------
 *  GLOBAL VARIABLES
 *-------------------------------------------------------------------------*/

static lelem_t      connListRoot_g;
static lelem_t      transfListRoot_g;

static fd_set       globalSocketSet;
static fd_set       globalSocketSendSet;
static int          serverSocket_g;
static u32_t        open_connections_g;
static sint_t       blockedTrans_g;

#define UPLOADBUF_SIZE   0x4000
//static char         upload_buf_g[UPLOADBUF_SIZE];
static char         *upload_buf_g;

#define REPLYBUF_SIZE    0x200
static char         reply_buf_g[REPLYBUF_SIZE];

static volatile sint_t  ftpd_terminate_request_g;
static volatile sint_t  ftpd_running_g;

static char         parambuf_g[FTP_INPBUFSIZE];
static char         tempbuf_g[FTP_INPBUFSIZE];

#if FS_SUBDIRECTORIES
static char         fnamebuf_g[FTP_FNAMESIZE*2];
#endif

static char         username_g[(MAX_NAMESIZE+1+3)&~3];
static char         password_g[(MAX_NAMESIZE+1+3)&~3];

static const char   month_g[13][4] = { "???",
 "Jan","Feb","Mar","Apr","May","Jun",
 "Jul","Aug","Sep","Oct","Nov","Dec"
};

static const CMDINFO_t cmdtable_g[] = 
{
  { "user", 1, 0, ftcmd_user },
  { "pass", 1, 1, ftcmd_pass },
  { "retr", 1, 3, ftcmd_retr },
  { "acct", 1, 0, ftcmd_acct },
  { "port", 1, 3, ftcmd_port },
  { "pasv", 0, 3, ftcmd_pasv },
  { "pwd" , 0, 3, ftcmd_pwd  },
  { "xpwd", 0, 3, ftcmd_pwd  },
  { "cwd" , 1, 3, ftcmd_cwd  },
  { "xcwd", 1, 3, ftcmd_cwd  },
  { "cdup", 0, 3, ftcmd_cdup },
  { "rest", 1, 3, ftcmd_rest },
  { "list", 0, 3, ftcmd_list },
  { "nlst", 0, 3, ftcmd_nlst },
  { "type", 1, 3, ftcmd_type },
  { "mode", 1, 3, ftcmd_mode },
  { "stru", 1, 3, ftcmd_stru },
  { "size", 1, 3, ftcmd_size },
  { "mdtm", 1, 3, ftcmd_mdtm },
  { "abor", 0, 3, ftcmd_abor },
  { "dele", 1, 4, ftcmd_dele },
  { "rnfr", 1, 4, ftcmd_rnfr },
  { "rnto", 1, 4, ftcmd_rnto },
  { "mkd" , 1, 4, ftcmd_mkd  },
  { "xmkd", 1, 4, ftcmd_mkd  },
  { "rmd" , 1, 4, ftcmd_rmd  },
  { "xrmd", 1, 4, ftcmd_rmd  },
  { "allo", 1, 2, ftcmd_allo },
  { "stat", 0, 0, ftcmd_stat },
  { "noop", 0, 0, ftcmd_noop },
  { "syst", 0, 0, ftcmd_syst },
  { "help", 0, 0, ftcmd_help },
  { "quit", 0, 0, ftcmd_quit },
  { "rein", 0, 0, ftcmd_rein },
  { "stor", 1, 4, ftcmd_stor },
  { "appe", 1, 4, ftcmd_appe },
  { ""    , 0, 0, NULL       }
};



/*---------------------------------------------------------------------------
 *  FUNCTION IMPLEMENTATION
 *-------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------
 *  FTP COMMANDS
 *-------------------------------------------------------------------------*/

/* Handle the ABOR command.
 */
static void ftcmd_abor(connection_t *conn, char *param)
{
  (void) param;
  if (conn->transfer != NULL)
  {
    ft_abortTransfer(conn);
  }
  ft_reply(conn, 226, "ABOR successful.");
}


/* Handle the ACCT command.
 * This command is not handled by us, since we will
 * never ask the client for an account identification.
 */
static void ftcmd_acct(connection_t *conn, char *param)
{
  (void) param;
  ft_reply(conn, 202, "ACCT not supported.");
}


/* Handle the ALLO command.
 * We do not need forward allocation, so we behave
 * like a NOOP (see RFC959).
 */
static void ftcmd_allo(connection_t *conn, char *param)
{
  (void) param;
  ft_reply(conn, 200, "ALLO not necessary, OK.");
}


/* Handle the APPE command.
 * Note that the function ft_execStore() does the rest.
 */
static void ftcmd_appe(connection_t *conn, char *param)
{
  (void) param;
  ft_execStore(conn, param, 1);
}

static char *fixPathNameDos(char *pathname)
{
	static char path[256];
	char *p = path;
  while(*pathname)
  {
    if(*pathname == '/')
    {
      *p++ = '\\';
      pathname++;
    }
    else
      *p++ = *pathname++;
  }
  *p = '\0';
  return(path);
}

#if FS_SUBDIRECTORIES

static sint_t buildPathName(char *outbuf, const char *pathname, const char *filename)
{
  sint_t s = 0, d = 0;
  const char *p, *f;
  char   b, c;

  p = pathname;
  f = filename;
  if ((*f == '/') || (*f == '\\'))
  {
    p = filename;
    f = NULL;
  }

  while ((p[s] == '/') || (p[s] == '\\') ||
         (p[s] == ' ')) s++;

  while ((c = p[s++]) != 0)
  {
    if ((c == '?') || (c == '*') || (d >= (FS_MAXFNAMELEN-4)))
    {
      *outbuf = 0;
      return -1;
    }
    if (c == '\\')
      c = '/';

    if ((c == '/') && (s > 1) &&
        ((p[s-2] == '/') || (p[s-2] == '\\')))
    {
      continue;
    }

    if ((d == 0) || (outbuf[d-1] == '/'))
    {
      if (c == '.')
      {
        b = p[s];
        if ((b == '/') || (b == '\\') || (b == 0))
        {
          s += 1;
          continue;
        }
        if ((b == '.') &&
            ((p[s+1] == '\\') || (p[s+1] == '/') ||
             (p[s+1] == 0)))
        {
          if ((d > 0) && (outbuf[d-1] == '/')) d--;
          while ((d > 0) && (outbuf[d-1] != '/')) d--;
          if (p[s+1] == 0)
            break;
          s += 2;
          continue;
        }
      }
    }

    if ((d != 0) || (c != '/'))
    {
      outbuf[d++] = c;
    }
  }

  if ((d > 0) && (outbuf[d-1] != '/'))
    outbuf[d++] = '/';

  if (f == NULL)
  {
    d--;
  }
  else
  {
    s = 0;
    while ((f[s] == '/') || (f[s] == '\\') ||
           (f[s] == ' ')) s++;

    if ((f[s] == '.') &&
        ((f[s+1] == 0) ||
         ((f[s+1] == '.') && (f[s+2] == '0'))))
    {
      *outbuf = 0;
      return -1;
    }
    while (f[s] != 0)
    {
      outbuf[d++] = f[s++];
    }
  }

  outbuf[d] = 0;
  return d;
}

#endif /* FS_SUBDIRECTORIES */


#if FS_SUBDIRECTORIES

/* Change the current working directory.
 */
static sint_t ft_changeCurrentPath(connection_t *conn, char *path)
{
  sint_t i;
  char   c;

  if ((*path == '/') || (*path == '\\'))
  {
    i = buildPathName(fnamebuf_g, path, "");
  }
  else
  {
    strcpy(fnamebuf_g, conn->curpath);
    strcat(fnamebuf_g, "/");
    strcat(fnamebuf_g, path);
    i = buildPathName(fnamebuf_g, fnamebuf_g, "");
  }

  if (i < 0)
    return -1;

  if (i > 0)
  {
    c = fnamebuf_g[i-1];
    if (c == '/')
      fnamebuf_g[i-1] = 0;
  }

  if (*fnamebuf_g != 0)
  {
    if (Fsfirst(fixPathNameDos(fnamebuf_g), FA_SUBDIR) < 0)
      return -1;
  }
  strcpy(conn->curpath, fnamebuf_g);
  return 0;
}

#endif /* FS_SUBDIRECTORIES */


/* Handle a CDUP command.
 */
static void ftcmd_cdup(connection_t *conn, char *param)
{
  (void) param;

#if FS_SUBDIRECTORIES

  if (ft_changeCurrentPath(conn, "..") == 0)
  {
    ft_reply(conn, 250, "CDUP successful.");
  }
  else
  {
    ft_reply(conn, 550, "CDUP failed.");
  }

#else /* FS_SUBDIRECTORIES */

  /* subdirectorys are not supported */
  ft_reply(conn, 250, "CDUP successful.");

#endif
}


/* Handle CWD command.
 */
static void ftcmd_cwd(connection_t *conn, char *param)
{
#if  FS_SUBDIRECTORIES 
 
  if (ft_changeCurrentPath(conn, param) == 0)
  {
    ft_reply(conn, 250, "CWD successful.");
  }
  else
  {
    ft_reply(conn, 550, "Path not found.");
  }

#else /* FS_SUBDIRECTORIES */

  (void) param;
  ft_reply(conn, 250, "CWD successful.");

#endif /* FS_SUBDIRECTORIES */
}


/* Handle the DELE command.
 */
static void ftcmd_dele(connection_t *conn, char *param)
{
  sint_t rc = -1;

  ft_getFilename(conn, param, tempbuf_g);
  if (*tempbuf_g != 0)
  {
    rc = Fdelete(tempbuf_g);
  }
  if (rc < 0)
  {
    ft_reply(conn, 550, "File unavailable.");
  }
  else
  {
    ft_reply(conn, 250, "File deleted.");
  }
}


/* Handle the HELP command (not supported by us).
 */
static void ftcmd_help(connection_t *conn, char *param)
{
  (void) param;
  ft_reply(conn, 214, "Sorry, no help available, "
                      "please use standard FTP commands.");
}


/* Handle the LIST command.
 */
static void ftcmd_list(connection_t *conn, char *param)
{
  ft_doListing(conn, param, 1);
}


/* Handle the MDTM command (not yet supported by us).
 */
static void ftcmd_mdtm(connection_t *conn, char *param)
{
  (void) param;
  ft_reply(conn, 502, "Command not implemented.");
}


/* Handle the MKD command.
 */
static void ftcmd_mkd(connection_t *conn, char *param)
{
#if FS_SUBDIRECTORIES

  if (buildPathName(fnamebuf_g, conn->curpath, param) >= 0)
  {
    if (Dcreate(fixPathNameDos(fnamebuf_g)) == 0)
    {
      ft_reply(conn, 257, "\"%s\" created.", fnamebuf_g);
      return;
    }
  }
  ft_reply(conn, 550, "Failed to create directory.");

#else /* FS_SUBDIRECTORIES */

  (void) param;
  ft_reply(conn, 502, "Command not implemented.");

#endif /* FS_SUBDIRECTORIES */
}


/* Handle the MODE command.
 * (we support only the stream mode)
 */
static void ftcmd_mode(connection_t *conn, char *param)
{
  (void) param;
  if ((*param == 'S') || (*param == 's'))
  {
    ft_reply(conn, 200, "Mode is STREAM.");
  }
  else
  {
    ft_reply(conn, 504, "Unknown mode.");
  }
}


/* Handle the NLST command.
 */ 
static void ftcmd_nlst(connection_t *conn, char *param)
{
  ft_doListing(conn, param, 0);
}


/* Handle the NOOP command.
 */
static void ftcmd_noop(connection_t *conn, char *param)
{
  (void) param;
  ft_reply(conn, 200, "NOOP command successful.");
}


/* Handle the PASS command, check for password.
 */
static void ftcmd_pass(connection_t *conn, char *param)
{
  char  *pass = (char*) param;
  sint_t i;

  i = (sint_t) strlen(pass);
  while ((i > 0) && (pass[i-1] == ' ')) i--;
  pass[i] = 0;

  if (conn->auth == 2)
  {
    if ((strcmp(username_g, conn->username) == 0) &&
        (strcmp(password_g, pass) == 0))
    {
      conn->auth = 4;
    }
    else
    {
      conn->auth = 0;
    }
  }
  else
  if (conn->auth == 1)
  {
    conn->auth = (i > 0) ? 3 : 0;
  }

  if (conn->auth == 0)
  {
    ft_reply(conn, 530, "Login incorrect.");
  }
  else
  {
    ft_reply(conn, 230, "User logged in.");
  }
}


/* This code is shared by ftcmd_pasv and ftcmd_port.
 */
static transfer_t* ft_setupNewTransfer(connection_t *conn)
{
  unsigned long one = 1;
  int s;

  if ((conn->transfer != NULL) &&
      (conn->transfer->state >= TSTATE_WAITFORPORT))
  {
    ft_reply(conn, 500, "Sorry, only one transfer allowed per connection.");
  }

  s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (s < 0)
  {
    ft_reply(conn, 500, "Socket error.");
    return NULL;
  }

  ft_destroyTransfer(conn->transfer);

  conn->transfer = ft_newTransfer(s, conn);
  if (conn->transfer == NULL)
  {
    ft_reply(conn, 500, "Out of memory error.");
    close(s);
    return NULL;
  }

  /* set nonblocking transfer */
  ioctlsocket(s, FIONBIO, (void*) &one);

  return conn->transfer;
}


/* Handle the PASV command.
 */
static void ftcmd_pasv(connection_t *conn, char *param)
{
  transfer_t *tran;
  struct sockaddr_in addr;
  unsigned long ip, port;
  int len;

  tran = ft_setupNewTransfer(conn);
  if (tran == NULL)
    return;

  ft_addSocket(tran->sock);

  /* setup socket */
  memset(&addr, 0, sizeof(addr));
  len = sizeof(addr);
  if (getsockname(conn->sock, (struct sockaddr*)&addr, &len))
  {
    ft_reply(conn, 500, "Socket error.");
    return;
  }

  addr.sin_port = 0;
  if (bind(tran->sock, (struct sockaddr *)&addr, sizeof(struct sockaddr)) < 0)
  {
    ft_reply(conn, 500, "Socket error.");
    return;
  }

  len = sizeof(addr);
  if (getsockname(tran->sock, (struct sockaddr *)&addr, &len) < 0)
  {
    ft_reply(conn, 500, "Socket error.");
    return;
  }

  if (listen(tran->sock, 1) < 0)
  {
    ft_reply(conn, 500, "Socket error.");
    return;
  }

  tran->state = TSTATE_GOTPASV;
  ip = (unsigned long) htonl(addr.sin_addr.s_addr);
  port = (unsigned long) htons(addr.sin_port);

  ft_reply(conn, 227, "Entering passive mode (%u,%u,%u,%u,%u,%u)",
           (ip >> 24) & 0xFF, (ip >> 16) & 0xFF, (ip >> 8) & 0xFF, ip & 0xFF,
           (port >> 8) & 0xFF, port & 0xFF);
}


/* Handle the PORT command.
 */
static void ftcmd_port(connection_t *conn, char *param)
{
  unsigned long one = 1;
  transfer_t *tran;
  struct sockaddr_in sin;
  short unsigned int a0, a1, a2, a3, p0, p1, t[6];
  int   len, i =0;
  char *s = param;

  for(i = 0; i < 6; i++)
  {
    t[i] = (short unsigned int)strtoul(s, NULL, 10);
    while((*s >= '0') && (*s <= '9'))
      s++;
    if((*s++ != ',') && (i != 5))
    {
      ft_reply(conn, 501, "Parse error.");
      return;
    }
  }
  a0 = t[0]; a1 = t[1]; a2 = t[2]; a3 = t[3]; p0 = t[4]; p1 = t[5];

  tran = ft_setupNewTransfer(conn);
  if (tran == NULL)
    return;

  /* bind socket to our FTP data port, port 20. */

  len = sizeof(sin);
  memset(&sin, 0, sizeof(sin));
  if (getsockname(conn->sock, (struct sockaddr*)&sin, &len) < 0)
  {
    ft_reply(conn, 500, "Socket error.");
    return;
  }

  setsockopt(tran->sock, SOL_SOCKET, SO_REUSEADDR, (void*) &one, sizeof(one));

  sin.sin_port = FTP_PORT - 1;
  bind(tran->sock, (struct sockaddr*)&sin, sizeof(sin));

  tran->sin.sin_family = AF_INET;
  tran->sin.sin_addr.s_addr = htonl(
    ((a0 & 0xFF) << 24) + ((a1 & 0xFF) << 16) +
    ((a2 & 0xFF) <<  8) + ((a3 & 0xFF)) );
  tran->sin.sin_port = htons((unsigned short)
    (((p0 & 0xFF) << 8) + (p1 & 0xFF)) );
  tran->state = TSTATE_GOTPORT;

  ft_reply(conn, 200, "PORT command OK.");
}


/* Handle PWD command (print current path).
 * Paths are not supported by us, so we are always in the root dir.
 */
static void ftcmd_pwd(connection_t *conn, char *param)
{
  (void) param;
#if FS_SUBDIRECTORIES
  ft_reply(conn, 257, "\"/%s\" is current working directory.", conn->curpath);
#else
  ft_reply(conn, 257, "\"/\" is current working directory.");
#endif
}


/* Handles the QUIT command
 * (shut down the control and data connection)
 */
static void ftcmd_quit(connection_t *conn, char *param)
{
  (void) param;
  if (conn->transfer != NULL)
  {
    ft_abortTransfer(conn);
  }
  ft_reply(conn, 221, "Have a nice day!");
  ft_destroyConnection(conn);
}


/* Handle the REIN command
 * (do nearly a full reset of the connection)
 */
static void ftcmd_rein(connection_t *conn, char *param)
{
  if (conn->transfer != NULL)
  {
    /* Note: This is not compliant to RFC959 */
    ft_abortTransfer(conn);
  }

  conn->buflen    = 0;
  conn->auth      = 0;
  conn->resumePos = 0;
#if FS_SUBDIRECTORIES
  conn->curpath[0]  = 0;
#endif
  conn->lastTrans = xTaskGetTickCount();
  ft_reply(conn, 220, "FTPD ready.");
}


/* Handle a REST command.
 */
static void ftcmd_rest(connection_t *conn, char *param)
{
  char *p;
  u32_t pos = strtoul(param, &p, 10);
#if 0
  if (p != param)
  {
    ft_reply(conn, 501, "Parse error.");
  }
  else
#endif
  {
    conn->resumePos = pos;
    ft_reply(conn, 350, "Setting resume at %u bytes.", conn->resumePos);
  }
}


/* Handle the RETR command.
 * This function simply opens the source file,
 * the download is done by the global state machine.
 */
static void ftcmd_retr(connection_t *conn, char *param)
{
  transfer_t *tran = conn->transfer;
  char *c;

  if ((tran == NULL) ||
      ((tran->state != TSTATE_GOTPASV) &&
       (tran->state != TSTATE_GOTPORT)))
  {
    ft_reply(conn, 425, "No data connection.");
    return;
  }

  tran->filehandle = -1;
  ft_getFilename(conn, param, tran->filename);

  if (conn->auth < 4)
  {
    c = tran->filename;
    while ((*c == '/') || (*c == '\\')) c++;
    if (strncmp(c, "public/", 7) != 0)
    {
      ft_reply(conn, 503, "Please login with USER and PASS.");
      return;
    }
  }

  if (*tran->filename != 0)
  {
#ifdef DEBUG
  	board_printf("Fopen %s\r\n", fixPathNameDos(tran->filename));
#endif  
    tran->filehandle = Fopen(fixPathNameDos(tran->filename), 0);
  }
  if (tran->filehandle < 0)
  {
    ft_reply(tran->owner, 550, "File unavailable.");
    ft_destroyTransfer(tran);
  }
  else
  {
    tran->upload = 0;
    tran->dirlisting = 0;
    ft_prepTransfer(tran);
  }
}


/* Handle the RMD command.
 */
static void ftcmd_rmd(connection_t *conn, char *param)
{
#if FS_SUBDIRECTORIES

  if (buildPathName(fnamebuf_g, conn->curpath, param) >= 0)
  {
    if (Ddelete(fixPathNameDos(fnamebuf_g)) == 0)
    {
      ft_reply(conn, 250, "Directory successfully removed.");
      return;
    }
  }
  ft_reply(conn, 550, "Failed to remove directory.");

#else /* FS_SUBDIRECTORIES */

  (void) param;
  ft_reply(conn, 502, "Command not implemented.");

#endif /* FS_SUBDIRECTORIES */
}


/* Handle the RNFR command.
 * (get the filename of the file to rename)
 */
static void ftcmd_rnfr(connection_t *conn, char *param)
{
  long fd;

  ft_getFilename(conn, param, conn->renfrom);
  fd = Fopen(fixPathNameDos(tempbuf_g), 0);
  if (fd >= 0)
  {
    Fclose(fd);
  } 
  if ((*conn->renfrom == 0) || (fd < 0))
  {
    conn->renfrom[0] = 0;
    ft_reply(conn, 550, "File unavailable.");
  }
  else
  {
    ft_reply(conn, 350, "File exists, send RNTO.");
  }
}


/* Handle the RNTO command.
 * (get filename to rename to and do the work)
 */
static void ftcmd_rnto(connection_t *conn, char *param)
{
  if (conn->renfrom[0] == 0)
  {
    ft_reply(conn, 503, "Need to send RNFR first.");
    return;
  }
  ft_getFilename(conn, param, tempbuf_g);
  if (*tempbuf_g == 0)
  {
    ft_reply(conn, 550, "New file name is illegal.");
  }
  else
  if (Frename(conn->renfrom, tempbuf_g) < 0)
  {
    ft_reply(conn, 550, "Failed to rename file.");
  }
  else
  {
    ft_reply(conn, 250, "File renamed.");
  }
  conn->renfrom[0] = 0;
}


/* Handle the SIZE command. This is a FTP extension.
 */
static void ftcmd_size(connection_t *conn, char *param)
{
  long fd, size = 0;

  ft_getFilename(conn, param, tempbuf_g);
  fd = Fopen(fixPathNameDos(tempbuf_g), 0);
  if (fd >= 0)
  {
    size = Fseek(0, fd, 2);
    Fclose(fd);
  } 
  if ((*tempbuf_g == 0) || (fd < 0) || (size < 0))
  {
    ft_reply(conn, 550, "File unavailable.");
  }
  else
  {
    ft_reply(conn, 213, "%l", size);
  }
}


/* Handle the STAT command.
 * This is a bit too complex for us, so we
 * reply with a 'disabled' message, because
 * we won't confess the command is not implemented...
 */
static void ftcmd_stat(connection_t *conn, char *param)
{
  (void) param;
  ft_reply(conn, 502, "STAT command disabled.");
}


/* Handle the STOR command.
 * Note that the function ft_execStore() does the rest.
 */
static void ftcmd_stor(connection_t *conn, char *param)
{
  (void) param;
  ft_execStore(conn, param, 0);
}


/* Handle the STRU command.
 * (we support only the file mode)
 */
static void ftcmd_stru(connection_t *conn, char *param)
{
  (void) param;
  if ((*param == 'F') || (*param == 'f'))
  {
    ft_reply(conn, 200, "Structure is FILE.");
  }
  else
  {
    ft_reply(conn, 504, "Unknown structure.");
  }
}


/* Handle the SYST command.
 * (we do not return a system identification)
 */
static void ftcmd_syst(connection_t *conn, char *param)
{
  (void) param;
  ft_reply(conn, 502, "Command disabled for security reason.");
}


/* Handle the TYPE command.
 */
static void ftcmd_type(connection_t *conn, char *param)
{
  (void) param;
  ft_reply(conn, 200, "TYPE ignored (always I)");
}


/* Handle the USER command, get user name.
 */
static void ftcmd_user(connection_t *conn, char *param)
{
  strncpy(conn->username, param, MAX_NAMESIZE);
  conn->username[MAX_NAMESIZE] = 0;

  if (strcmp(conn->username, "anonymous") == 0)
  {
    ft_reply(conn, 331, "Login OK, send password (your e-mail).");
    conn->auth = 1;
  }
  else
  {
    ft_reply(conn, 331, "Password required for %s.", conn->username);
    conn->auth = 2;
  }
}



/*---------------------------------------------------------------------------
 *  COMMAND LINE PARSER + TOOLS
 *-------------------------------------------------------------------------*/


/* Parse and execute a FTP command.
 */
static void ft_execCommand(connection_t *conn)
{
  const CMDINFO_t *cmd;
  sint_t p, w, e;
  u16_t i, j, len;

  /* remove all illegal characters
     from the beginning of the buffer */
  for (i = 0;
       ((i < conn->buflen) &&
       !((conn->rxbuffer[i] >= 'a') && (conn->rxbuffer[i] <= 'z')) &&
       !((conn->rxbuffer[i] >= 'A') && (conn->rxbuffer[i] <= 'Z')));
       i++);

  if (i > 0)
  {
    ft_removeRxbufBytes(conn, i);
  }

  /* test if parameters are following and
     find end of command (marked by LF or CR/LF) */
  for (w = 0, p = 0, e = 0, i = 0;
       i < conn->buflen;  i++)
  {
    if (conn->rxbuffer[i] != ' ')
    {
      p = w;
    }
    else
    {
      w = 1;
    }
    if ((conn->rxbuffer[i] == '\r') || (conn->rxbuffer[i] == '\n'))
    {
      e = 1;
      break;
    }
  }

  if (e == 0)
  {
    /* no valid command in the buffer */
    return;
  }
#ifdef DEBUG
  board_printf("ft_execCommand: %c%c%c%c\r\n",
   conn->rxbuffer[0], conn->rxbuffer[1], conn->rxbuffer[2], conn->rxbuffer[3]);
#endif
  for (cmd = cmdtable_g; cmd->cmdfunc != NULL; cmd++)
  {
    char name[10];

    len = (u16_t) strlen(cmd->name);
    for (j = 0; j < len; j++)
    {
      if((conn->rxbuffer[j] >= 'A') && (conn->rxbuffer[j] <= 'Z'))
        name[j] = conn->rxbuffer[j] + 0x20; /* tolower */
      else
        name[j] = conn->rxbuffer[j]; 
    }
    name[j] = '\0';
    if ((i < len) ||
        (strncmp(name, cmd->name, len) != 0) ||
        ((cmd->arg != 0) && (p == 0)))
    {
      continue;
    }

    if (conn->auth < cmd->auth)
    {
      ft_removeRxbufBytes(conn, i);
      ft_reply(conn, 503, "Please login with USER and PASS.");
      return;
    }

    while ((len < conn->buflen) && (conn->rxbuffer[len] == ' ')) len++;
    ft_removeRxbufBytes(conn, len);
    i -= len;

    strncpy(parambuf_g, conn->rxbuffer, i);
    parambuf_g[i] = 0;
    ft_removeRxbufBytes(conn, i);
    (cmd->cmdfunc)(conn, parambuf_g);
    return;
  }

  ft_reply(conn, 500, "Syntax error, command unrecognized.");
  ft_removeRxbufBytes(conn, i); 
}


/* abort an active transfer and delete the broken file.
 */
static void ft_abortTransfer(connection_t *conn)
{
  transfer_t *tran = conn->transfer;

  ft_reply(conn, 426, "File transfer aborted.");

  if (tran->filehandle != -1)
  {
#ifdef DEBUG
  	board_printf("Fclose\r\n");
#endif  
    Fclose(tran->filehandle);
    tran->filehandle = -1;
  }
  if (tran->upload)
  {
#ifdef DEBUG
  	board_printf("Fdelete %S\r\n", fixPathNameDos(tran->filename));
#endif  
    Fdelete(fixPathNameDos(tran->filename));
  }
  ft_destroyTransfer(conn->transfer);
}


/* Execute the STOR or APPE command.
 */
static void ft_execStore(connection_t *conn, char *param, sint_t appflag)
{
  transfer_t *tran = conn->transfer;

  if ((tran == NULL) ||
      ((tran->state != TSTATE_GOTPASV) && (tran->state != TSTATE_GOTPORT)))
  {
    ft_reply(conn, 425, "No data connection.");
    return;
  }
  ft_getFilename(conn, param, tran->filename);
  if (*tran->filename == 0)
  {
    ft_reply(conn, 553, "File name not allowed.");
    return;
  }
#ifdef DEBUG
  board_printf("Fopen/Fcreate %s\r\n", fixPathNameDos(tran->filename));
#endif
  if ((appflag != 0) || (conn->resumePos > 0))
    tran->filehandle = Fopen(fixPathNameDos(tran->filename), 1);
  else
    tran->filehandle = Fcreate(fixPathNameDos(tran->filename), 0);
//                               FSO_WRONLY | FSO_CREAT |
//                               (((appflag != 0) ||
//                               (conn->resumePos > 0)) ? 0 : FSO_TRUNC));
  if (tran->filehandle < 0)
  {
    ft_reply(tran->owner, 550, "Failed to create file.");
  }
  else
  {
    tran->upload = 1;
    tran->append = appflag;
    ft_prepTransfer(tran);
  }
}


/* Initialize a file transfer (up- or download).
 * Retrieves the current file size, connects the socket, etc.
 */
static void ft_prepTransfer(transfer_t *tran)
{
  if (tran->filehandle >= 0)
  {
    tran->size = (u32_t) Fseek(0, tran->filehandle, 2);

    if ((tran->upload == 0) || (tran->append == 0) ||
        (tran->owner->resumePos != 0))
    {
#ifdef DEBUG
      board_printf("Fseek\r\n");
#endif  	
      Fseek((sint_t) tran->owner->resumePos, tran->filehandle, 0);
    }
  }
  else
  {
    tran->size = 0;
  }

  if (tran->state == TSTATE_GOTPASV)
  {
    tran->state = TSTATE_WAITONPASV;
  }
  else
  if (tran->state == TSTATE_GOTPORT)
  {
    tran->state = TSTATE_WAITFORPORT;
    connect(tran->sock, (struct sockaddr*)&tran->sin, sizeof(tran->sin));
    ft_addSendSocket(tran->sock);
  }
  tran->starttime = xTaskGetTickCount();
}


/* Do a directory listing.
 * If fulllist is set to 1, a ls -l is performed.
 */
static void ft_doListing(connection_t *conn, char *param, sint_t fulllist)
{
  transfer_t *tran = conn->transfer;
  char *fn, *c;
  sint_t i, ol;

  if ((tran == NULL) ||
      ((tran->state != TSTATE_GOTPASV) &&
       (tran->state != TSTATE_GOTPORT)))
  {
    ft_reply(conn, 425, "No data connection.");
    return;
  }

  fn = NULL;
  ol = 0;
  for (c = param; *c != 0; c++)
  {
    while (*c == ' ') c++;
    if (c[0] == '-')
    {
      if (((c[1] == 'l') || (c[1] == 'L')) &&
          ((c[2] == ' ') || (c[2] == 0)))
      {
        ol = 1;
        c++;
        continue;
      }
      while ((*c != ' ') && (*c != 0)) c++;
    }
    else
    {
      if (fn == NULL)
        fn = c;
    }
  }

  if (fn == NULL)
  {
    tran->filename[0] = '*';
    tran->filename[1] = '.';
    tran->filename[2] = '*';
    tran->filename[3] = '\0';
  }
  else
  {
    strcpy(tran->filename, fn);
    fn = tran->filename;
    for (i = 0; (fn[i] != ' ') && (fn[i] != 0); i++);
    if ((i > 0) && ((fn[i-1] == '/') || (fn[i-1] == '\\')))
      fn[i++] = '*';
    fn[i] = 0;
  }

  if (fulllist)
    ol = 1;

//  if (tran->dirhandle >= 0)
//    fsys_findclose(tran->dirhandle);
  tran->dirhandle = -1;
  tran->dirlisting = 1 + ol;
  tran->upload = 0;
  ft_prepTransfer(tran);
}


/* Get only the filename from the buffer
 * (remove the path name).
 */
static void ft_getFilename(connection_t *conn, char *param, char *dst)
{
#if FS_SUBDIRECTORIES 

  buildPathName(dst, conn->curpath, param);

#else /* FS_SUBDIRECTORIES */

  char *s = param;
  char *d = dst;

  (void) conn;

  while ((*s == '/') || (*s == '\\')) s++;
  while (*s != 0)
  {
    *d = (*s == '\\') ? '/' : *s;
    s++;
    if ((*d == '/') && (*s == 0))
    {
      d++;
      break;
    }
    d++;
  }
  *d = 0;

#endif /* FS_SUBDIRECTORIES */
}

#if 1

typedef struct
{
    int dest;
    void (*func)(char);
    char *loc;
} PRINTK_INFO;

#define DEST_CONSOLE    (1)
#define DEST_STRING     (2)

/* Send a numeric and human readable reply to the client.
 */
static void ft_reply(connection_t *conn, u16_t num, const char *fmt, ...)
{
  va_list args;
  int l;
  extern int printk(PRINTK_INFO *info, const char *fmt, va_list ap);

  PRINTK_INFO info;
  info.dest = DEST_STRING;
  info.loc = reply_buf_g+4;
  sprintf(reply_buf_g, "%03u ", num);
  va_start(args, fmt);
  printk(&info, fmt, args);
  *info.loc = '\0';
  va_end(args);

  l = strlen(reply_buf_g);
  reply_buf_g[l++] = '\r';
  reply_buf_g[l++] = '\n';
#ifdef DEBUG
  reply_buf_g[l] = '\0';
  board_printf("ft_reply: %s", reply_buf_g);  
#endif  
  conn->lastTrans = xTaskGetTickCount();
  if (send(conn->sock, reply_buf_g, l, 0) < 0)
  {
    if (errno == EPIPE)
    {
      ft_destroyConnection(conn);
    }
  }
}

#else

/* Send a numeric and human readable reply to the client.
 */
static void ft_reply(connection_t *conn, u16_t num, const char *fmt, ...)
{
  va_list args;
  int l;

  sprintf(reply_buf_g, "%03u ", num);
  va_start(args, fmt);
  vsprintf(reply_buf_g+4, fmt, args);
  va_end(args);
  l = strlen(reply_buf_g);
  reply_buf_g[l++] = '\r';
  reply_buf_g[l++] = '\n';
  conn->lastTrans = xTaskGetTickCount();
  if (send(conn->sock, reply_buf_g, l, 0) < 0)
  {
    if (errno == EPIPE)
    {
      ft_destroyConnection(conn);
    }
  }
}

#endif


/* Fill buffer with next line of directory listing
 */
static sint_t ft_getNextDirEntry(transfer_t *tran, char *buf)
{
  static DTAINFO finfo;
  char name[14];
  int i;
  sint_t rc;
  char   d;

  *buf = 0;

  if (tran->dirhandle == -2)
    return 0;

#ifdef DEBUG    
  board_printf("ft_getNextDirEntry Fsetdta %s\r\n", tran->filename);
#endif
  if (tran->dirhandle < 0)
  {
    Fsetdta(&finfo); 
#if FS_SUBDIRECTORIES
    if (buildPathName(fnamebuf_g, tran->owner->curpath, tran->filename) >= 0)
    {
#ifdef DEBUG    
      board_printf("ft_getNextDirEntry Fsfirst(%s)\r\n", fixPathNameDos(fnamebuf_g));
#endif
      tran->dirhandle = Fsfirst(fixPathNameDos(fnamebuf_g), FA_SUBDIR|FA_RO);
    }
#else
    tran->dirhandle = Fsfirst(fixPathNameDos(tran->filename), FA_SUBDIR|FA_RO);
#endif
  }
  else
  {
    rc = Fsnext();
    if (rc < 0)
    {
      return 0;
    }
  }

  if (tran->dirhandle >= 0)
  {
    if (tran->dirlisting == 2)
    {
      /* long directory listing */
      d = (finfo.dt_fattr & FA_SUBDIR) ? 'd' : '-';
      if (finfo.dt_fattr & FA_RO)
      {
        sprintf(buf + strlen(buf),
                "%cr--r--r--   1 ftp      root     ", d);
      }
      else
      {
        sprintf(buf + strlen(buf),
                "%crw-rw-rw-   1 ftp      root     ", d);
      }

      sprintf(buf + strlen(buf), "%8lu ", (unsigned long) finfo.dt_fileln);
      sprintf(buf + strlen(buf), "%s %2u %02u:%02u ",
              month_g[(finfo.dt_date >> 5) & 0xF], 
              (uint_t) finfo.dt_date & 0x1F,
              (uint_t) (finfo.dt_time >> 11) & 0x1F,
              (uint_t) (finfo.dt_time >> 5) & 0x3F);

    }
    i = 0;
    while(finfo.dt_fname[i])
    {
      if((finfo.dt_fname[i] >= 'A') && (finfo.dt_fname[i] <= 'Z'))
        name[i] = finfo.dt_fname[i] + 0x20;
      else
        name[i] = finfo.dt_fname[i]; 
      i++;
    }
    name[i] = '\0';
    strcat(buf, name);
    strcat(buf, "\r\n");
#ifdef DEBUG
    board_printf("ft_getNextDirEntry => %s", buf);
#endif
  }
  else
  {
    tran->dirhandle = -2;
  }
  return strlen(buf);
}




/*---------------------------------------------------------------------------
 *  CONNECTION HANDLING
 *-------------------------------------------------------------------------*/


/* Add a socket to the global socket send set.
 */
static sint_t ft_addSendSocket(const int sock)
{
  if (sock >= 0)
  {
    FD_CLR(sock, &globalSocketSendSet);
    FD_SET(sock, &globalSocketSendSet);
    return 0;
  }
  return -1;
}


/* Add a socket to the global socket set.
 */
static sint_t ft_addSocket(const int sock)
{
  if (sock >= 0)
  {
    FD_CLR(sock, &globalSocketSet);
    FD_SET(sock, &globalSocketSet);
    return 0;
  }
  return -1;
}


/* Remove socket from fdsets and close it.
 */
static void ft_delSocket(const int sock)
{
  if (sock >= 0)
  {
    FD_CLR(sock, &globalSocketSet);
    FD_CLR(sock, &globalSocketSendSet);
    close(sock);
  }
}


/*-------------------------------------------------------------------------*/


/* Insert an element to the tail of a double linked list.
 */
static void ft_listAddTail(lelem_t *headelem, lelem_t *elem)
{
  elem->prev = headelem->prev;
  elem->next = headelem;
  headelem->prev->next = elem;
  headelem->prev = elem;
}


/* Insert an element to the head of a double linked list.
 */
static void ft_listAddHead(lelem_t *headelem, lelem_t *elem)
{
  elem->next = headelem->next;
  elem->prev = headelem;
  headelem->next->prev = elem;
  headelem->next = elem;
}


/* Remove an element from a double linked list
 * and free its memory.
 */
static void ft_listDel(lelem_t *elem)
{
  lelem_t *next = elem->next;
  lelem_t *prev = elem->prev;
  next->prev = prev;
  prev->next = next;
}


/*-------------------------------------------------------------------------*/


/* Create and initialize a new connection structure.
 * On success, the connection is established and a 220 status is sent.
 */
static sint_t ft_newConnection(int socket)
{
  unsigned long one = 1;
  connection_t *conn;

  if ((socket != -1) &&
      ((open_connections_g >= FTP_MAXCON) ||
       (open_connections_g >= FD_SETSIZE)))
  {
    /* too many connections opened */
    send(socket, "221 Maximum number of connections established, "
                 "try later again.\r\n", 65, 0);
    return -1;
  }

  conn = (connection_t *)(pvPortMalloc2(sizeof(connection_t)));
  if (conn == NULL)
    return -1;

  conn->transfer    = NULL;
  conn->sock        = socket;
  conn->buflen      = 0;
  conn->auth        = 0;
  conn->resumePos   = 0;
  conn->renfrom[0]  = 0;
  conn->lastTrans   = xTaskGetTickCount();
#if FS_SUBDIRECTORIES
  conn->curpath[0]  = 0;
#endif

  /* set nonblocking mode */
  ioctlsocket(socket, FIONBIO, (void*)&one);

  /* add socket and connection to list of active connections */
  ft_addSocket(socket);
  ft_listAddTail(&connListRoot_g, (lelem_t*)(void*)conn);
  open_connections_g++;

  ft_reply(conn, 220, "Connection established, FTPD ready.");
  return 0;
}


/* Create and initialize a new filetransfer structure.
 */
static transfer_t *ft_newTransfer(int socket, connection_t *conn)
{
  transfer_t *tran;

  tran = (transfer_t *)(pvPortMalloc2(sizeof(transfer_t)));
  if (tran == NULL)
    return NULL;

  tran->owner       = conn;
  tran->sock        = socket;
  tran->state       = TSTATE_NONE;
  tran->dlbufpos    = 0;
  tran->dlbufremain = 0;
  tran->filehandle  = -1;
  tran->dirhandle   = -1;
  tran->dirlisting  = 0;
  tran->wrDisabled  = 0;

  ft_listAddTail(&transfListRoot_g, (lelem_t*)(void*)tran);
  return tran;
}


/* Destroys a ctrl connection and
 * cleans up the connection structure.
 */
static void ft_destroyConnection(connection_t *conn)
{
  if (conn == NULL)
    return;

  if ((conn->sock >= 0) && (open_connections_g > 0))
  {
    open_connections_g--;
  }

  ft_delSocket(conn->sock);
  ft_destroyTransfer(conn->transfer);
  ft_listDel((lelem_t*)(void*)conn);
  vPortFree2(conn);
}


/* Destroys a data connection and
 * cleans up the connection structure.
 */
static void ft_destroyTransfer(transfer_t *tran)
{
#if defined(TCP_CORK) && defined(SOL_TCP)
  unsigned long zero = 0;
#endif

  if (tran == NULL)
    return;

  if (tran->sock >= 0)
  {
#if defined(TCP_CORK) && defined(SOL_TCP)
    /* ensure that all data is flushed out when closing the socket */
    setsockopt(tran->sock, SOL_TCP, TCP_CORK, (void *)&zero, sizeof(zero));
#endif
    ft_delSocket(tran->sock);
  }
  if (tran->filehandle != -1)
  {
#ifdef DEBUG
  	board_printf("Fclose\r\n");
#endif  	
    Fclose(tran->filehandle);
  }
  if (tran->dirhandle != -1)
  {
//    fsys_findclose(tran->dirhandle);
  }
  if (tran->owner != NULL)
  {
    tran->owner->transfer = NULL;
  }
  if (tran->wrDisabled != 0)
  {
    blockedTrans_g--;
  }
  ft_listDel((lelem_t*)(void*)tran);
  vPortFree2(tran);
}


/*-------------------------------------------------------------------------*/


/* This function processes all open control connections.
 * If data was received over the connection, it is
 * passed to the command line parser.
 */
static sint_t ft_processCtrlConnections(fd_set *clientset, int fdcount)
{
  connection_t *conn, *next;
  sint_t checked;
  int   bytes;

  next = FIRST_LIST_ELEM(&connListRoot_g, connection_t*);
  checked = 0;

  /* process all connections in the list */
  while (!END_OF_LIST(&connListRoot_g, next) && (checked < fdcount))
  {
    conn = next;
    next = NEXT_LIST_ELEM(conn, connection_t*);

    if (!FD_ISSET(conn->sock, clientset))
    {
      continue;
    }

    checked++;

    bytes = recv(conn->sock, conn->rxbuffer + conn->buflen,
                 (FTP_INPBUFSIZE-1) - conn->buflen, 0);

    if (bytes <= 0)
    {
      /* If no bytes are available or -1 is returned,
       * the client must have closed the connection since
       * select told us that there was something with the socket.
       */
      ft_destroyConnection(conn);
      continue;
    }

    /* safety check: buffer overrun (should never happen) */
    if ((conn->buflen + (u16_t) bytes) >= (FTP_INPBUFSIZE-1))
    {
      ft_reply(conn, 500, "Buffer error, connection shut down.");
      ft_destroyConnection(conn);
      continue;
    }
    conn->buflen += (u16_t) bytes;
    conn->lastTrans = xTaskGetTickCount();

    ft_execCommand(conn);
  }
  return checked;
}


/* Do a data connection upload.
 */
static sint_t ft_handleUpload(transfer_t *tran)
{
  int size;

  tran->owner->lastTrans = xTaskGetTickCount();

  size = recv(tran->sock, upload_buf_g, UPLOADBUF_SIZE, 0);
  if (size > 0)
  {
    tran->pos += (u32_t) size;
#ifdef DEBUG
    board_printf("Fwrite\r\n");
#endif    
    if (Fwrite(tran->filehandle, (sint_t) size, upload_buf_g) == size)
    {
      return 1;
    }
  }
  else
  if (size == 0)
  {
    return 0;
  }

  ft_abortTransfer(tran->owner);
  return 1;
} 


/* Do a data connection download.
 */
static sint_t ft_handleDownload(transfer_t *tran)
{
#if defined(TCP_CORK) && defined(SOL_TCP)
  unsigned long zero = 0;
#endif
  sint_t moreToSend = 0;
  int   bytes, size;

  /* fill buffer */
  if (tran->dlbufremain == 0)
  {
    tran->dlbufpos = 0;
    if (tran->dirlisting)
    {
      bytes = ft_getNextDirEntry(tran, tran->dlbuf);
#ifdef DEBUG
      board_printf("dirlisting %d bytes\r\n", bytes);
#endif  	
    }
    else
    {
#ifdef DEBUG
      board_printf("Fread...");
#endif  	
      bytes = Fread(tran->filehandle, MAX_BLOCKSIZE, tran->dlbuf);
#ifdef DEBUG
      board_printf("%d bytes\r\n", bytes);
#endif  	
    }

    if (bytes >= MAX_BLOCKSIZE)
    {
      moreToSend = 1;
    }

    if (bytes > 0)
    {
      if (bytes > MAX_BLOCKSIZE)
        bytes = MAX_BLOCKSIZE;
      tran->dlbufremain = (u16_t) bytes;
    }
  }

  /* send data */
  if (tran->dlbufremain != 0)
  {
#if defined(TCP_CORK) && defined(SOL_TCP)
    /* flush buffer if we believe we send the last block */
    if (moreToSend == 0)
    {
      setsockopt(tran->sock, SOL_TCP, TCP_CORK, (void*)&zero, sizeof(zero));
    }
#endif

    size = send(tran->sock, tran->dlbuf + tran->dlbufpos, tran->dlbufremain, 0);

    if (size < 0)
    {
      if (errno == EWOULDBLOCK)
      {
        /* temporary disable write to the socket */
        FD_CLR(tran->sock, &globalSocketSendSet);
        tran->wrDisabled = 1;

        /* move transfer structure to the head of the list */
        if (tran != FIRST_LIST_ELEM(&transfListRoot_g, transfer_t*))
        {
          ft_listDel((lelem_t*)(void*)tran);
          ft_listAddHead(&transfListRoot_g, (lelem_t*)(void*)tran);
        }
        blockedTrans_g++;
      }
    }
    else
    if (size > 0)
    {
      if ((u16_t)size > tran->dlbufremain)
        size = (int) tran->dlbufremain;
      tran->dlbufpos += (u16_t) size;
      tran->dlbufremain -= (u16_t) size;

      tran->owner->lastTrans = xTaskGetTickCount();
    }
    moreToSend = 1;
  }

  return moreToSend;
}


/* This function processes all open data connections
 * and does the file up- or download for the clients that
 * are ready to send or receive data. This function handles
 * also newly set up data connections.
 */
static sint_t ft_processDataConnections(fd_set* clientset, int fdcount)
{
  transfer_t *tran, *next;
  struct sockaddr addr;
  unsigned long one = 1;
  sint_t checked;
  int   s, alen;
 
  next = FIRST_LIST_ELEM(&transfListRoot_g, transfer_t*);
  checked = 0;

  while (!END_OF_LIST(&transfListRoot_g, next) && (checked < fdcount))
  {
    tran = next;
    next = NEXT_LIST_ELEM(tran, transfer_t*);

    if ((tran->state <= TSTATE_GOTPASV) ||
        (tran->state == TSTATE_GOTPORT) ||
        !FD_ISSET(tran->sock, clientset))
    {
       continue;
    }

    checked++;
    FD_CLR(tran->sock, clientset);

    if (tran->state == TSTATE_WAITONPASV)
    {
      /* incoming PASV connection */
      alen = sizeof(addr);
      s = accept(tran->sock, (struct sockaddr*)&addr, &alen);

      ft_delSocket(tran->sock);

      if (s < 0)
      {
         ft_destroyTransfer(tran);
         continue;
      }

      tran->sock = s;
      ioctlsocket(tran->sock, FIONBIO, (void*)&one);
      ft_initTransfer(tran);

      if (tran->upload)
      {
        continue;
      }
    }

    if (tran->state < TSTATE_TRANSFER)
    {
      ft_initTransfer(tran);
      if (tran->upload)
      {
        continue;
      }
    }

    if (tran->upload)
    {
      if (ft_handleUpload(tran) != 0)
      {
        continue;
      }
    }
    else
    {
      if (ft_handleDownload(tran) != 0)
      {
        continue;
      }
    }

    /* The file transfer is done when one of the functions
     * ft_handleUpload or ft_handleDownload returned with zero.
     */
    ft_reply(tran->owner, 226, "Transfer complete.");
    tran->owner->lastTrans = xTaskGetTickCount();

    ft_destroyTransfer(tran);
  }

  return checked;
}


/*-------------------------------------------------------------------------*/


/* Accept and open a new connection to the next client.
 */
static void ft_acceptClient(void)
{
  struct sockaddr_in addr;
  int    s, alen;
  static sint_t errors = 0;

  alen = sizeof(addr);
  memset(&addr, 0, sizeof(addr));
  s = accept(serverSocket_g, (struct sockaddr *)&addr, &alen);

  if (s < 0)
  {
    if ((errno == EBADF
#ifdef EPIPE
       || errno == EPIPE
#endif
       ) && (++errors >= 3))
    {
      /* try to recover server socket on too much errors */
      ft_delSocket(serverSocket_g);
      serverSocket_g = ft_newServerSocket();
      errors = 0;
    }
  }
  else
  {
    errors = 0;
    if (ft_newConnection(s) != 0)
    {
      close(s);
    }
  }
}


/*-------------------------------------------------------------------------*/


/* Check for timed out connections,
 * and close them.
 */
static void ft_timeout(void)
{
  connection_t *conn, *next;
  portTickType now = xTaskGetTickCount();  
  long remain;

  /* run through the list of connections */
  next = FIRST_LIST_ELEM(&connListRoot_g, connection_t*);
  while (!END_OF_LIST(&connListRoot_g, next))
  {
    conn = next;
    next = NEXT_LIST_ELEM(conn, connection_t*);

    remain = (long)
             (conn->lastTrans + (FTP_TIMEOUT * configTICK_RATE_HZ)) -
             (long) now;

    if (remain <= 0)
    {
      ft_reply(conn, 421, "Timeout, closing connection.");
      ft_destroyConnection(conn);
    }
  }
}


/*-------------------------------------------------------------------------*/


/* This function removes some bytes from the
 * control connection input buffer. It is called
 * when the command line parser has finnished
 * executing a command.
 */
static void ft_removeRxbufBytes(connection_t *conn, u16_t count)
{
  sint_t i;
  if (conn->buflen <= count)
  {
    conn->buflen = 0;
  }
  else
  {
    conn->buflen -= count;
    for (i = 0; i < conn->buflen; i++)
      conn->rxbuffer[i] = conn->rxbuffer[count + i];
  }
}


/*-------------------------------------------------------------------------*/


/* create a new server socket that listens to incomming FTP requests.
 */
static int ft_newServerSocket(void)
{
  unsigned long one = 1;
  struct sockaddr_in addr;
  int s, err;
  
  s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (s < 0)
    return -1;

  setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (void*) &one, sizeof(one));
  ioctlsocket(s, FIONBIO, (void*) &one);    /* set nonblocking mode */

  memset(&addr, 0, sizeof(addr));
  addr.sin_family      = AF_INET;
  addr.sin_addr.s_addr = INADDR_ANY;
  addr.sin_port        = htons(FTP_PORT);

  err = bind(s, (struct sockaddr *)&addr, sizeof(struct sockaddr));
  if (err < 0)
  {
    if ((errno == ENOMEM) || (errno == EADDRINUSE))
    {
      /* wait some time and try again...*/
      vTaskDelay(configTICK_RATE_HZ/2);
      err = bind(s, (struct sockaddr *)&addr, sizeof(struct sockaddr));
    }
    if (err < 0)
    {
      close(s);
#ifdef DEBUG
      board_printf("Failed to bind server socket!\r\n");
#endif
      return -1;
    }
  }

  listen(s, 20);

  ft_addSocket(s);
  return s;
}


/*-------------------------------------------------------------------------*/


/* Initialize a data connection for sending.
 * No files and sockets are opened here, we just
 * set up the socket and initialize some values.
 * After initialization, we send the 150 reply.
 */
static void ft_initTransfer(transfer_t *tran)
{
#ifdef SO_LINGER
  struct linger ling;
#endif
#ifdef SOL_TCP
#ifdef IPTOS_THROUGHPUT
  const int mode = IPTOS_THROUGHPUT;
#endif
  unsigned long zero = 0;
#ifdef TCP_CORK
  unsigned long one = 1;
#endif
#endif

#ifdef SOL_TCP
  /* set options for maximum throughput */
#ifdef IPTOS_THROUGHPUT
    setsockopt(tran->sock, SOL_IP, IP_TOS, (void *)&mode, sizeof(mode));
#endif
    setsockopt(tran->sock, SOL_TCP, TCP_NODELAY, (void *)&zero, sizeof(zero));
#ifdef TCP_CORK
    setsockopt(tran->sock, SOL_TCP, TCP_CORK, (void *)&one, sizeof(one));
#endif
#endif

  tran->state = TSTATE_TRANSFER;

  if (tran->upload)
  {
    FD_CLR(tran->sock, &globalSocketSendSet);
    ft_addSocket(tran->sock);
  }
  else
  {
    ft_addSendSocket(tran->sock);
  }

#ifdef SO_LINGER
  ling.l_onoff = 0;
  ling.l_linger = 0;
  setsockopt(tran->sock, SOL_SOCKET, SO_LINGER, (void*)&ling, sizeof(ling));
#endif

  if (tran->dirlisting != 0)
  {
    ft_reply(tran->owner, 150,
             "Opening ASCII mode data connection for directory listing.");
  }
  else
  {
    ft_reply(tran->owner, 150, "Opening BINARY mode data connection");
  }
  if (tran->filehandle >= 0)
  {
#ifdef DEBUG
    board_printf("Fseek\r\n");
#endif  
    Fseek((sint_t) tran->owner->resumePos, tran->filehandle, 0);
  }
  tran->owner->lastTrans = xTaskGetTickCount();
}


/*-------------------------------------------------------------------------*/


/* This function tries to remove all faulty
 * file handles from the file sets.
 */
static sint_t ft_fdSanity(void)
{
  struct timeval tv = {0,0};
  connection_t   *conn, *nextc;
  transfer_t     *tran, *nextt;
  fd_set         fds;
  char           buf;

  /* Test if the server socket has failed.
     If so, destroy the socket and create a new one. */
  FD_ZERO(&fds);
  FD_SET(serverSocket_g, &fds); 
  if (select(serverSocket_g, (void *)&fds, NULL, NULL, &tv) < 0)
  {
    FD_CLR(serverSocket_g, &globalSocketSet);
    close(serverSocket_g);
    serverSocket_g = ft_newServerSocket();
    if (serverSocket_g < 0)
      return -1;
  }
 
  /* close all faulty connections */
  nextc = FIRST_LIST_ELEM(&connListRoot_g, connection_t*);
  while (!END_OF_LIST(&connListRoot_g, nextc))
  {
    conn = nextc;
    nextc = NEXT_LIST_ELEM(conn, connection_t*);

    if ((recv(conn->sock, &buf, 0, 0) < 0) &&
        (errno == EBADF))
    {
      ft_destroyConnection(conn);
    }
  }

  /* close all faulty filetransfers */
  nextt = FIRST_LIST_ELEM(&transfListRoot_g, transfer_t*);
  while (!END_OF_LIST(&transfListRoot_g, nextt))
  {
    tran = nextt;
    nextt = NEXT_LIST_ELEM(tran, transfer_t*);

    if ((recv(tran->sock, &buf, 0, 0) < 0) &&
        (errno == EBADF))
    {
      ft_destroyTransfer(tran);
    }
  }

  return 0;
}


/* Returns nonzero when the ftpd is started.
 */
sint_t ftpd_running(void)
{
  return ftpd_running_g;
}


/* This function stoppes the FTP demon.
 */
sint_t ftpd_stop(void)
{
  sint_t i;
  
  if (ftpd_running_g == 0)
    return 0;
    
  ftpd_terminate_request_g = 1;
  for (i = 0; i < 22; i++)
  {
    vTaskDelay(configTICK_RATE_HZ/10);
    if (ftpd_running_g == 0)
    {
      if (upload_buf_g != NULL)
        vPortFree2(upload_buf_g);
      upload_buf_g = NULL;
      return 0;
    }
  }

  return -1; /* failed to stop FTPD */
}



/* main function. does all initialization.
 */
sint_t ftpd_start(char *username, char *password)
{
  connection_t  *conn, *nextc;
  transfer_t    *tran, *nextt;
  struct timeval timeout;
  portTickType   wctr, bctr, bt;
  fd_set         fds, fds_send;
  sint_t          i;

  if (ftpd_running_g != 0)
    return 0;  /* we are just up and running */

  ftpd_running_g = 1;

  if ((username == NULL) || (password == NULL))
    return -1;

  upload_buf_g = (char *)pvPortMalloc2(UPLOADBUF_SIZE);
  if (upload_buf_g == NULL)
    return -1;

  strncpy(username_g, username, MAX_NAMESIZE);
  strncpy(password_g, password, MAX_NAMESIZE);
  username_g[MAX_NAMESIZE] = 0;
  password_g[MAX_NAMESIZE] = 0;

  ftpd_terminate_request_g = 0;
  blockedTrans_g = 0;

  FD_ZERO(&globalSocketSet);
  FD_ZERO(&globalSocketSendSet);
  open_connections_g = 0;

  serverSocket_g = ft_newServerSocket();
  if (serverSocket_g < 0)
  {
    ftpd_running_g = 0;
    vPortFree2(upload_buf_g);
    return -1;
  }

  /* init lists */
  INIT_LIST_HEAD(&connListRoot_g);
  INIT_LIST_HEAD(&transfListRoot_g);

  bt = configTICK_RATE_HZ / 10;
  if (bt == 0) bt = 1;

  wctr = xTaskGetTickCount() + 30 * configTICK_RATE_HZ;
  bctr = xTaskGetTickCount() + bt;

  while (serverSocket_g >= 0)
  {
    /* load fds */
    fds = globalSocketSet;
    fds_send = globalSocketSendSet;
    
    /* wait and timeout after 1.1 second when there is no activity
     */
    timeout.tv_sec  = (blockedTrans_g == 0) ? 1 : 0;
    timeout.tv_usec = 100000;
    i = select(FD_SETSIZE, (void *)&fds, (void *)&fds_send, NULL, &timeout);

    if (ftpd_terminate_request_g != 0)
      break;

    if (i < 0)
    {
      if (errno == EBADF)
      {
        /* test for insane file descriptors */
        ft_fdSanity();
      }
      else
      if (errno != EINTR)
      {
#ifdef DEBUG
        board_printf("select() failed\r\n");
#endif
      }
      continue;
    }

    /* re-enable write for all temp. disabled connections */
    if (((long)bctr - (long)xTaskGetTickCount()) <= 0)
    {
      bctr += bt;
      tran = FIRST_LIST_ELEM(&transfListRoot_g, transfer_t*);
      while (blockedTrans_g > 0)
      {
        if (tran->wrDisabled != 0)
        {
          ft_addSendSocket(tran->sock);
          tran->wrDisabled = 0;
        }
        tran = NEXT_LIST_ELEM(tran, transfer_t*);
        blockedTrans_g--;
      }
    }

    /* remove any timed out sockets */
    if (((long)wctr - (long)xTaskGetTickCount()) <= 0)
    {
      wctr += (30*configTICK_RATE_HZ);
      ft_timeout();
    }

    if (i > 0)
    {
      /* first handle all sends... */
      i -= ft_processDataConnections(&fds_send, i);

      /* ... then the PASV connections and uploads ... */
      i -= ft_processDataConnections(&fds, i);

      /* ... and then the rest. */
      ft_processCtrlConnections(&fds, i);

      /* check for incomming connections */
      if (FD_ISSET(serverSocket_g, &fds))
      {
        ft_acceptClient();
        if (serverSocket_g < 0)
          break;
        i--;
      }
    }
  }

  /* cleanup everything and quit then */

  /* close server socket */
  if (serverSocket_g >= 0)
    close(serverSocket_g);

  /* close all connections */
  nextc = FIRST_LIST_ELEM(&connListRoot_g, connection_t*);
  while (!END_OF_LIST(&connListRoot_g, nextc))
  {
    conn = nextc;
    nextc = NEXT_LIST_ELEM(conn, connection_t*);
    if (conn->transfer != NULL)
    {
      ft_abortTransfer(conn);
    }
    ft_reply(conn, 421, "FTPD shut down.");
    ft_destroyConnection(conn);
  }

  /* close all filetransfers */
  nextt = FIRST_LIST_ELEM(&transfListRoot_g, transfer_t*);
  while (!END_OF_LIST(&transfListRoot_g, nextt))
  {
    tran = nextt;
    nextt = NEXT_LIST_ELEM(tran, transfer_t*);
    ft_destroyTransfer(tran);
  }

  ftpd_running_g = 0;
  return 0;
}

#endif /* FTP_SERVER */
#endif /* LWIP */
#endif /* NETWORK */
