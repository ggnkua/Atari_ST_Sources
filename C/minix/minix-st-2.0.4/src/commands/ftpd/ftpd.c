/* ftpd.c
 *
 * ftpd         An FTP server program for use with Minix.
 *
 * Usage:       Minix usage: tcpd ftp ftpd
 *
 * 06/14/92 Tnet Release	Michael Temari, <temari@ix.netcom.com>
 * 01/15/96 0.30		Michael Temari, <temari@ix.netcom.com>
 * 01/25/96 0.90		Michael Temari, <temari@ix.netcom.com>
 * 03/17/96 0.91		Michael Temari, <temari@ix.netcom.com>
 * 06/27/96 0.92		Michael Temari, <temari@ix.netcom.com>
 * 07/02/96 0.93		Michael Temari, <temari@ix.netcom.com>
 * 07/15/96 0.94		Michael Temari, <temari@ix.netcom.com>
 * 08/27/96 0.95		Michael Temari, <temari@ix.netcom.com>
 */

char *FtpdVersion = "0.95";

#include <sys/types.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <net/gen/in.h>
#include <net/gen/tcp.h>

#include "ftpd.h"
#include "access.h"
#include "file.h"
#include "net.h"

_PROTOTYPE(static void init, (void));
_PROTOTYPE(static int doHELP, (char *buff));
_PROTOTYPE(static int doNOOP, (char *buff));
_PROTOTYPE(static int doUNIMP, (char *buff));

/* The following defines the inactivity timeout in seconds */
#define	INACTIVITY_TIMEOUT	60*60

char *days[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
char *months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
		  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

char line[512];

int type, format, mode, structure;
int ftpdata_fd = -1;
int loggedin, gotuser, anonymous;
char username[80];
char anonpass[128];

ipaddr_t myipaddr, rmtipaddr, dataaddr;
tcpport_t myport, rmtport, dataport;

char myhostname[256], rmthostname[256];

#define	FTPLOG		"/usr/adm/ftplog"
#define	AFTPLOG		"/usr/adm/aftplog"

int fd_ftplog, fd_aftplog, fd_curlog;

int timeout = 0;

_PROTOTYPE(static int doHELP, (char *buff));
_PROTOTYPE(int readline, (char **args));
_PROTOTYPE(void Timeout, (int sig));
_PROTOTYPE(int main, (int argc, char *argv[]));

struct commands {
	char *name;
	_PROTOTYPE(int (*func), (char *buff));
};

struct commands commands[] = {
	"ABOR", doUNIMP,
	"ACCT", doUNIMP,
	"ALLO", doALLO,
	"APPE", doAPPE,
	"CDUP", doCDUP,
	"CWD",  doCWD,
	"DELE", doDELE,
	"HELP", doHELP,
	"LIST", doLIST,
	"MDTM", doMDTM,
	"MKD",  doMKD,
	"MODE", doMODE,
	"NLST", doNLST,
	"NOOP", doNOOP,
	"PASS", doPASS,
	"PASV", doPASV,
	"PORT", doPORT,
	"PWD",  doPWD,
	"QUIT", doQUIT,
	"REIN", doUNIMP,
	"REST", doREST,
	"RETR", doRETR,
	"RMD",  doRMD,
	"RNFR", doRNFR,
	"RNTO", doRNTO,
	"SITE", doSITE,
	"SIZE", doSIZE,
	"SMNT", doUNIMP,
	"STAT", doSTAT,
	"STOR", doSTOR,
	"STOU", doSTOU,
	"STRU", doSTRU,
	"SYST", doSYST,
	"TYPE", doTYPE,
	"USER", doUSER,
	"XCUP", doCDUP,
	"XCWD", doCWD,
	"XMKD", doMKD,
	"XPWD", doPWD,
	"XRMD", doRMD,
	"",     (int (*)())0
};

static void init()
{
   loggedin = 0;
   gotuser = 0;
   anonymous = 0;
   type = TYPE_A;
   format = 0;
   mode = 0;
   structure = 0;
   ftpdata_fd = -1;
   username[0] = '\0';
   anonpass[0] = '\0';
}

/* nothing, nada, zilch... */
static int doNOOP(buff)
char *buff;
{
   printf("200 NOOP to you too!\r\n");

   return(GOOD);
}

/* giv'em help, what a USER! */
static int doHELP(buff)
char *buff;
{
struct commands *cmd;
char star;
int i;
char *space = "    ";

   printf("214-Here is a list of available ftp commands\r\n");
   printf("    Those with '*' are not yet implemented.\r\n");

   i = 0;
   for(cmd = commands; *cmd->name != '\0'; cmd++) {
	if(cmd->func == doUNIMP)
		star = '*';
	else
		star = ' ';
	printf("     %s%c%s", cmd->name, star, space + strlen(cmd->name));
	if(++i == 6) {
		printf("\r\n");
		i = 0;
	}
   }

   if(i)
	printf("\r\n");

   printf("214 That's all the help you get.\r\n");

   return(GOOD);
}

/* not implemented */
static int doUNIMP(buff)
char *buff;
{
   printf("502 Command \"%s\" not implemented!\r\n", line);

   return(GOOD);
}

/* convert line for use */
void cvtline(args)
char **args;
{
char *p;

   p = line + strlen(line) - 1;
   while(p != line)
	if(*p == '\r' || *p == '\n' || isspace(*p))
		*p-- = '\0';
	else
		break;
  p = line;
  while(*p && !isspace(*p)) {
	*p = toupper(*p);
	p++;
  }
  if(*p) {
	*p = '\0';
	p++;
	while(*p && isspace(*p))
		p++;
   }
   *args = p;

   return;
}

/* get a command from the client */
int readline(args)
char **args;
{
   char *nl;

   if (fgets(line, sizeof(line), stdin) == (char *)NULL)
	return(BAD);
   if ((nl = strchr(line, '\n')) == NULL)
	return(BAD);
   *nl = '\0';

   cvtline(args);

   return(GOOD);
}

/* signal handler for inactivity timeout */
void Timeout(sig)
int sig;
{
   timeout = 1;

   printf("421 Inactivity timer expired.\r\n");
}

/* logit */
void logit(type, parm)
char *type;
char *parm;
{
time_t now;
struct tm *tm;
char message[1024];

   if(fd_curlog == -1)
	return;

   time(&now);
   tm = localtime(&now);
   sprintf(message, "%s %s %2d %02d:%02d:%02d %d %s %s %s %s\n",
	days[tm->tm_wday],
	months[tm->tm_mon],
	tm->tm_mday,
	tm->tm_hour, tm->tm_min, tm->tm_sec,
	1900+tm->tm_year,
	rmthostname, anonymous ? anonpass : username, type, parm);
   (void) write(fd_curlog, message, strlen(message));
}

/* loganon */
void loganon(anon)
int anon;
{
   fd_curlog = anon ? fd_aftplog : fd_ftplog;
}

int main(argc, argv)
int argc;
char *argv[];
{
struct commands *cmd;
char *args;
int status;
time_t now;
struct tm *tm;
int s;

   GetNetInfo();

   /* open log file and anonymous log file if they exist */
   fd_ftplog = open(FTPLOG, O_WRONLY | O_APPEND);
   fd_aftplog = open(AFTPLOG, O_WRONLY | O_APPEND);
   loganon(0);

   /* Let's initialize some stuff */
   init();

   /* Log the connection */
   logit("CONNECT", "");

   /* Tell 'em we are ready */
   time(&now);
   tm = localtime(&now);
   printf("220 FTP service ready on %s at ", myhostname);
   printf("%s, %02d %s %d %02d:%02d:%02d %s\r\n", days[tm->tm_wday],
	tm->tm_mday, months[tm->tm_mon], 1900+tm->tm_year,
	tm->tm_hour, tm->tm_min, tm->tm_sec,
	tzname[tm->tm_isdst]);
   fflush(stdout);

   /* Loop here getting commands */
   while(1) {
	signal(SIGALRM, Timeout);
	alarm(INACTIVITY_TIMEOUT);
	if(readline(&args) != GOOD) {
		if(!timeout)
			printf("221 Control connection closing (EOF).\r\n");
		break;
	}
	alarm(0);
	for(cmd = commands; *cmd->name != '\0'; cmd++)
		if(!strcmp(line, cmd->name))
			break;
	if(*cmd->name != '\0')
		status = (*cmd->func)(args);
	else {
		printf("500 Command \"%s\" not recognized.\r\n", line);
		status = GOOD;
	}
	fflush(stdout);
	if(status != GOOD)
		break;
   }

   exit(1);
}
