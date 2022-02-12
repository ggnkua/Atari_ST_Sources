/* file.c
 *
 * This file is part of ftpd.
 *
 * This file handles:
 *
 *      ALLO APPE CDUP CWD  DELE LIST MDTM MODE MKD  NLST PWD REST RETR
 *      RMD  RNFR RNTO SITE SIZE STAT STOR STOU STRU SYST TYPE
 *
 * 01/25/96 Initial Release	Michael Temari, <temari@ix.netcom.com>
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <net/hton.h>
#include <net/gen/in.h>
#include <net/gen/inet.h>
#include <net/gen/tcp.h>

#include "ftpd.h"
#include "access.h"
#include "file.h"
#include "net.h"

_PROTOTYPE(static int fdxcmd, (char *xcmd, char *args));
_PROTOTYPE(static int endfdxcmd, (int fd));
_PROTOTYPE(static int asciisize, (char *filename, unsigned long *filesize));
_PROTOTYPE(static int cnvtfile, (char *name, char **name2));
_PROTOTYPE(static int procfile, (char *name));
_PROTOTYPE(static int sendfile, (char *name, int xmode));
_PROTOTYPE(static int recvfile, (char *name, int xmode));
_PROTOTYPE(static char *uniqname, (void));
_PROTOTYPE(static int docrc, (char *buff, int xmode));
_PROTOTYPE(static char *path, (char *fname));

#define	SEND_FILE	0
#define	SEND_NLST	1
#define	SEND_LIST	2

#define	RECV_FILE	0
#define	RECV_APND	1
#define	RECV_UNIQ	2

#define	CNVT_ERROR	0
#define	CNVT_NONE	1
#define	CNVT_TAR	2
#define	CNVT_TAR_Z	3
#define	CNVT_COMP	4
#define	CNVT_TAR_GZ	5
#define	CNVT_GZIP	6
#define	CNVT_UNCOMP	7


#define	CMD_SH		"/bin/sh"
#define	CMD_NLST	"ls"
#define	CMD_LIST	"ls -lA"
#define	CMD_CRC		"crc"

static char *msg550 = "550 %s %s.\r\n";

static unsigned long file_restart = 0;

static char rnfr[256];
static char buffer[8192];
static char bufout[8192];

static cmdpid = -1;

/* allocate, we don't need no stink'n allocate */
int doALLO(buff)
char *buff;
{
   printf("202 ALLO command not needed at this site.\r\n");

   return(GOOD);
}

/* append to a file if it exists */
int doAPPE(buff)
char *buff;
{
   return(recvfile(buff, RECV_APND));
}

/* change to parent directory */
int doCDUP(buff)
char *buff;
{
   if(ChkLoggedIn())
	return(GOOD);

   return(doCWD(".."));
}

/* change directory */
int doCWD(buff)
char *buff;
{
   if(ChkLoggedIn())
	return(GOOD);

   if(chdir(buff))
	printf(msg550, buff, strerror(errno));
   else
	printf("250 %s command okay.\r\n", line);

   return(GOOD);
}

/* remove a file */
int doDELE(buff)
char *buff;
{
   if(ChkLoggedIn())
	return(GOOD);

   if(unlink(buff))
	printf(msg550, buff, strerror(errno));
   else {
	printf("250 File \"%s\" deleted.\r\n", buff);
	logit("DELE", path(buff));
   }

   return(GOOD);
}

/* directory listing */
int doLIST(buff)
char *buff;
{
   file_restart = 0;

   return(sendfile(buff, SEND_LIST));
}

/* file modification time, btw when will this be put into an RFC */
int doMDTM(buff)
char *buff;
{
struct stat st;
struct tm *t;

   if(ChkLoggedIn())
	return(GOOD);

   if(stat(buff, &st)) {
	printf(msg550, buff, strerror(errno));
	return(GOOD);
   }

   if((st.st_mode & S_IFMT) != S_IFREG) {
	printf("550 Not a regular file.\r\n");
	return(GOOD);
   }

   t = gmtime(&st.st_mtime);

   printf("215 %04d%02d%02d%02d%02d%02d\r\n",
	t->tm_year+1900, t->tm_mon+1, t->tm_mday,
	t->tm_hour, t->tm_min, t->tm_sec);

   return(GOOD);
}

/* mode */
int doMODE(buff)
char *buff;
{
   switch(*buff) {
	case 's':
	case 'S':
		printf("200 Mode set to %c.\r\n", *buff);
		break;
	default:
		printf("501 Unknown mode %c.\r\n", *buff);
   }

   return(GOOD);
}

/* make a directory */
int doMKD(buff)
char *buff;
{
   mode_t mask;

   if(ChkLoggedIn())
	return(GOOD);

   if(anonymous)
	mask = umask(0000);

   if(mkdir(buff, 0777))
	printf(msg550, buff, strerror(errno));
   else {
	printf("257 \"%s\" directory created.\r\n", buff);
	logit("MKD ", path(buff));
   }

   if(anonymous)
	(void) umask(mask);

   return(GOOD);
}

/* name listing */
int doNLST(buff)
char *buff;
{
   file_restart = 0;

   return(sendfile(buff, SEND_NLST));
}

/* where are we */
int doPWD(buff)
char *buff;
{
char dir[128];

   if(ChkLoggedIn())
	return(GOOD);

   if(getcwd(dir, sizeof(dir)) == (char *)NULL)
	printf(msg550, buff, strerror(errno));
   else
	printf("257 \"%s\" is current directory.\r\n", dir);

   return(GOOD);
}

/* restart command */
int doREST(buff)
char *buff;
{
   if(ChkLoggedIn())
	return(GOOD);

   file_restart = atol(buff);

   printf("350 Next file transfer will restart at %lu.\r\n", file_restart);

   return(GOOD);
}

/* they want a file */
int doRETR(buff)
char *buff;
{
   return(sendfile(buff, SEND_FILE));
}

/* remove a directory */
int doRMD(buff)
char *buff;
{
   if(ChkLoggedIn())
	return(GOOD);

   if(rmdir(buff))
	printf(msg550, buff, strerror(errno));
   else {
	printf("250 Directory \"%s\" deleted.\r\n", buff);
	logit("RMD ", path(buff));
   }

   return(GOOD);
}

/* rename from */
int doRNFR(buff)
char *buff;
{
   if(ChkLoggedIn())
	return(GOOD);

   strncpy(rnfr, buff, sizeof(rnfr));
   rnfr[sizeof(rnfr)-1] = '\0';

   printf("350 Got RNFR waiting for RNTO.\r\n");

   return(GOOD);
}

/* rename to */
int doRNTO(buff)
char *buff;
{
   if(ChkLoggedIn())
	return(GOOD);

   if(rnfr[0] == '\0') {
	printf("550 Rename failed.\r\n");
	return(GOOD);
   }

   if(rename(rnfr, buff) < 0)
	printf("550 Rename failed. Error %s\r\n", strerror(errno));
   else {
	printf("250 Renamed %s to %s.\r\n", rnfr, buff);
	logit("RNFR", path(rnfr));
	logit("RNTO", path(buff));
   }

   rnfr[0] = '\0';

   return(GOOD);
}

static int docrc(buff, xmode)
char *buff;
int xmode;
{
unsigned short cs;
long fs;
int fd;
int s;
char *p;

   if((fd = fdxcmd(CMD_CRC, buff)) < 0) {
	printf("501 Could not obtain CRC.\r\n");
	return(GOOD);
   }

   if(xmode == 0)
	printf("201-SITE CRC \"%s\"\r\n", buff);

   while(1) {
	p = buffer;
	while(1) {
		if((s = read(fd, p, 1)) != 1) {
			if(xmode == 0)
				printf("201 SITE CRC DONE.\r\n");
			else
				printf("501 Could not obtain CRC.\r\n");

			endfdxcmd(fd);

			return(GOOD);
		}
		if(*p == '\n') {
			*p++ = '\r';
			*p++ = '\n';
			*p = '\0';
			break;
		}
		p++;
	}

	if(xmode != 0)
		break;

	printf("    %s", buffer);
   }

   cs = atoi(buffer);

   fs = atol(buffer+6);

   printf("201 CRC %05u %ld.\r\n", cs, fs);

   endfdxcmd(fd);

   return(GOOD);
}

/* site specific */
int doSITE(buff)
char *buff;
{
char *args;

   strncpy(line, buff, sizeof(line));

   cvtline(&args);

   if(!strcmp(line, "CRC") || !strcmp(line, "CCRC"))
	return(docrc(args, strcmp(line, "CRC")));

   printf("501 Unknown SITE command %s.\r\n", line);


   return(GOOD);
}

/* file size, btw when will this be put into an RFC */
int doSIZE(buff)
char *buff;
{
struct stat st;
unsigned long filesize;

   if(ChkLoggedIn())
	return(GOOD);

   if(stat(buff, &st)) {
	printf(msg550, buff, strerror(errno));
	return(GOOD);
   }

   if((st.st_mode & S_IFMT) != S_IFREG) {
	printf("550 Not a regular file.\r\n");
	return(GOOD);
   }

   filesize = st.st_size;

   if(type == TYPE_A)
	if(asciisize(buff, &filesize))
		return(GOOD);

   printf("215 %lu\r\n", filesize);

   return(GOOD);
}

/* server status, or file status */
int doSTAT(buff)
char *buff;
{
time_t now;
struct tm *tm;
int fd;
int s;

   if(!*buff) {
	(void) time(&now);
	tm = localtime(&now);
	printf("211-%s(%s:%u) FTP server status:\r\n",
		myhostname, inet_ntoa(myipaddr), ntohs(myport));
	printf("    Version %s  ", FtpdVersion);
	printf("%s, %02d %s %d %02d:%02d:%02d %s\r\n", days[tm->tm_wday],
		tm->tm_mday, months[tm->tm_mon], 1900+tm->tm_year,
		tm->tm_hour, tm->tm_min, tm->tm_sec, tzname[tm->tm_isdst]);
	printf("    Connected to %s:%u\r\n", inet_ntoa(rmtipaddr), ntohs(rmtport));
	if(!loggedin)
		printf("    Not logged in\r\n");
	else
		printf("    Logged in %s\r\n", username);
	printf("    TYPE: %s\r\n",(type == TYPE_A) ? "Ascii" : "Binary");
	printf("211 End of status\r\n");
	return(GOOD);
   }

   if(ChkLoggedIn())
	return(GOOD);

   printf("211-Status of %s:\r\n", buff);

   if((fd = fdxcmd(CMD_LIST, buff)) < 0)
	printf("   Could not retrieve status");
   else {
	while((s = read(fd, buffer, 1)) == 1) {
		if(*buffer == '\n')
			printf("\r\n");
		else
			printf("%c", *buffer);
	}
	endfdxcmd(fd);
   }

   printf("211 End of status\r\n");

   return(GOOD);
}

/* hey look, we're getting a file */
int doSTOR(buff)
char *buff;
{
   return(recvfile(buff, RECV_FILE));
}

/* hey, get a file unique */
int doSTOU(buff)
char *buff;
{
   return(recvfile(buff, RECV_UNIQ));
}

/* structure */
int doSTRU(buff)
char *buff;
{
   switch(*buff) {
	case 'f':
	case 'F':
		printf("200 Structure set to %c.\r\n", *buff);
		break;
	default:
		printf("501 Unknown structure %c.\r\n", *buff);
   }

   return(GOOD);
}

/* we're UNIX and proud of it! */
int doSYST(buff)
char *buff;
{
   printf("215 UNIX Type: L8\r\n");

   return(GOOD);
}

/* change transfer type */
int doTYPE(buff)
char *buff;
{
   if(*(buff+1) != '\0') {
	printf("501 Syntax error in parameters.\r\n");
	return(GOOD);
   }

   switch(*buff) {
	case 'A':
	case 'a':
		type = TYPE_A;
		printf("200 Type set to A.\r\n");
		break;
	case 'I':
	case 'i':
		type = TYPE_I;
		printf("200 Type set to I.\r\n");
		break;
	default:
		printf("501 Invalid type %c.\r\n", *buff);
   }

   return(GOOD);
}

static int fdxcmd(xcmd, args)
char *xcmd;
char *args;
{
char cmd[512];
char *argv[5];
int fds[2];
char *smallenv[] = { "PATH=/bin:/usr/bin:/usr/local/bin", NULL, NULL };

   if ((smallenv[1] = getenv("TZ")) != NULL) smallenv[1] -= 3;	/* ouch... */

   sprintf(cmd, "%s %s", xcmd, args);

   argv[0] = CMD_SH;
   argv[1] = "-c";
   argv[2] = cmd;
   argv[3] = (char *)NULL;

   if(pipe(fds) < 0)
	return(-1);

   if((cmdpid = fork()) < 0) {
	close(fds[0]);
	close(fds[1]);
	return(-1);
   }

   if(cmdpid == 0) { /* Child */
	close(fds[0]);
	close(0);
	open("/dev/null", O_RDONLY);
	dup2(fds[1], 1);
	dup2(fds[1], 2);
	close(fds[1]);
	execve(argv[0], argv, smallenv);
	exit(0);
   }

   close(fds[1]);

   return(fds[0]);
}

/* Same as close if not cmd child started */
static int endfdxcmd(fd)
int fd;
{
int s;
int cs;

   close(fd);

   if(cmdpid == -1)
	return(0);

   s = waitpid(cmdpid, &cs, 0);

   cmdpid = -1;

   return(0);
}

/* returns 1 = size could not be determined, */
/*         0 = size determined and in filesize */
static int asciisize(filename, filesize)
char *filename;
unsigned long *filesize;
{
unsigned long count;
int fd;
char *p, *pp;
int cnt;

   if((fd = open(filename, O_RDONLY)) < 0) {
	printf(msg550, filename, strerror(errno));
	return(1);
   }

   count = 0;

   while((cnt = read(fd, buffer, sizeof(buffer))) > 0) {
	count += cnt;
	p = buffer;
	while(cnt > 0)
		if((pp = memchr(p, '\n', cnt)) != (char *)NULL) {
			count++;
			cnt = cnt - 1 - (pp - p);
			p = pp + 1;
		} else
			break;
   }

   if(cnt == 0) {
	*filesize = count;
	close(fd);
	return(0);
   }

   printf(msg550, filename, strerror(errno));

   close(fd);

   return(1);
}

/* see if we need to run a command to convert the file */
static int cnvtfile(name, name2)
char *name;
char **name2;
{
struct stat st;
static char fname[256];
char *p;
int mode;

   if(!stat(name, &st))			/* file exists can't be a conversion */
   	if((st.st_mode & S_IFMT) != S_IFREG) {	/* must be regular file */
		printf("550 Not a regular file.\r\n");
		return(CNVT_ERROR);
	} else
		return(CNVT_NONE);

   if(errno != ENOENT) {	/* doesn't exist is okay, others are not */
	printf(msg550, name, strerror(errno));
	return(CNVT_ERROR);
   }

   /* find out what kind of conversion */
   strncpy(fname, name, sizeof(fname));
   fname[sizeof(fname)-1] = '\0';

   p = fname + strlen(fname);
   mode = CNVT_ERROR;
   while(p > fname && mode == CNVT_ERROR) {
	if(*p == '.') {
		if(!strcmp(p, ".tar"))
			mode = CNVT_TAR;
		else
		if(!strcmp(p, ".tar.Z"))
			mode = CNVT_TAR_Z;
		else
		if(!strcmp(p, ".Z"))
			mode = CNVT_COMP;
		else
		if(!strcmp(p, ".tar.gz"))
			mode = CNVT_TAR_GZ;
		else
		if(!strcmp(p, ".gz"))
			mode = CNVT_GZIP;

		if (mode != CNVT_ERROR) {
			/* is there a file to convert? */
			*p = '\0';
			if (!stat(fname, &st)) break;
			*p = '.';
			mode = CNVT_ERROR;
		}
	}
	p--;
   }

   if(mode == CNVT_ERROR) {
	printf(msg550, fname, strerror(errno));
	return(mode);
   }

   if(mode == CNVT_COMP || mode == CNVT_GZIP || mode == CNVT_UNCOMP)
	if((st.st_mode & S_IFMT) != S_IFREG) {
		printf("550 Not a regular file.\r\n");
		return(CNVT_ERROR);
	}

   *name2 = fname;

   return(mode);
}

static int procfile(name)
char *name;
{
int fd;
char *name2;
static char command[512];
char *cdcmd, *cmdfmt;
int ftype;

   ftype = cnvtfile(name, &name2);
 
   /* don't let tar use a full pathname */
   cdcmd = "";
   switch(ftype) {
	case CNVT_TAR:
	case CNVT_TAR_Z:
	case CNVT_TAR_GZ:
		if (name2[0] == '/') {
			while (*name2 == '/') name2++;
			cdcmd = "cd / &&";
		}
   }

   /* format for a command to run; use two %s arguments for a 'cd /' and the
    * file to process
    */
   switch(ftype) {
	case CNVT_TAR:
		cmdfmt = "%s tar cf - %s";
		break;
	case CNVT_TAR_Z:
		cmdfmt = "%s tar cf - %s | compress -q";
		break;
	case CNVT_COMP:
		cmdfmt = "%s compress -cq %s";
		break;
	case CNVT_TAR_GZ:
		cmdfmt = "%s tar cf - %s | gzip";
		break;
	case CNVT_GZIP:
		cmdfmt = "%s gzip -c %s";
		break;
	case CNVT_UNCOMP:
		cmdfmt = "%s compress -dcq %s";
		break;
	case CNVT_NONE:
		cmdfmt = NULL;
		break;
	case CNVT_ERROR:
	default:
		return(-1);
   }

   if(cmdfmt != NULL) {
	sprintf(command, cmdfmt, cdcmd, name2);
	fd = fdxcmd(command, "");
   } else {
	fd = open(name, O_RDONLY);
   }

   if(fd < 0)
	printf(msg550, name, strerror(errno));

   return(fd);
}

/* oh no, they're taking a file */
static int sendfile(name, xmode)
char *name;
int xmode;
{
char *fname;
int fd, s;
time_t datastart, dataend;
unsigned long datacount;
long kbs;
char c;
char *p;
char *op, *ope;
off_t sp;
int doascii;

   if(ChkLoggedIn()) 
	return(CleanUpData());

   switch(xmode) {
	case SEND_NLST:
		fname = "NLST";
		fd = fdxcmd(CMD_NLST, name);
		if(fd < 0)
			printf(msg550, name, strerror(errno));
		break;
	case SEND_LIST:
		fname = "LIST";
		fd = fdxcmd(CMD_LIST, name);
		if(fd < 0)
			printf(msg550, name, strerror(errno));
		break;
	default:
		fname = name;
		fd = procfile(name);
		if(fd < 0) {
			logit("FAIL", path(fname));
		} else {
			logit("SEND", path(fname));
			if (anonymous) {
				loganon(1);
				logit("SEND", path(fname));
				loganon(0);
			}
		}
   }

   if(fd < 0)
	return(CleanUpData());

   /* set file position at approriate spot */
   if(file_restart) {
	if(type == TYPE_A) {
		sp = 0;
		while(sp < file_restart) {
			sp++;
			s = read(fd, buffer, 1);
			if(s < 0) {
				printf(msg550, fname, strerror(errno));
				endfdxcmd(fd);
				file_restart = 0;
				return(CleanUpData());
			}
			if(s == 0) break;
			if(*buffer == '\n')
				sp++;
		}
	} else {
		sp = lseek(fd, file_restart, SEEK_SET);
		if(sp == -1) {
			printf(msg550, fname, strerror(errno));
			endfdxcmd(fd);
			file_restart = 0;
			return(CleanUpData());
		}
	}
	if(sp != file_restart) {
		printf("550 File restart point error. %lu not %lu\r\n", sp, file_restart);
		endfdxcmd(fd);
		file_restart = 0;
		return(CleanUpData());
	}
   }
   file_restart = 0;

   printf("150 File %s okay.  Opening data connection.\r\n", fname);
   fflush(stdout);

   if(DataConnect()) {
	endfdxcmd(fd);
	return(GOOD);
   }

#ifdef DEBUG
   fprintf(stderr, "ftpd: parent %d start sendfile \n", getpid());
#endif

   /* start transfer */
   doascii = (type == TYPE_A) ||
   	((xmode == SEND_LIST) || (xmode == SEND_NLST)); /* per RFC1123 4.1.2.7 */
   datacount = 0;
   time(&datastart);
   op = bufout; ope = bufout + sizeof(bufout) - 3;
   while((s = read(fd, buffer, sizeof(buffer))) > 0) {
	datacount += s;
	if(doascii) {
		p = buffer;
		while(s-- > 0) {
			c = *p++;
			if(c == '\n') {
				*op++ = '\r';
				datacount++;
			}
			*op++ = c;
			if(op >= ope) {
				write(ftpdata_fd, bufout, op - bufout);
				op = bufout;
			}
		}
	} else
		write(ftpdata_fd, buffer, s);
   }
   if(op > bufout)
	write(ftpdata_fd, bufout, op - bufout);
   time(&dataend);

#ifdef DEBUG
   fprintf(stderr, "ftpd: parent %d end sendfile \n", getpid());
#endif

   endfdxcmd(fd);
   close(ftpdata_fd);
   ftpdata_fd = -1;

   if(dataend == datastart) dataend++;
   kbs = (datacount * 100 / (dataend - datastart)) / 1024;

   if(s < 0)
	printf("451 Transfer aborted.\r\n");
   else
	printf("226 Transfer finished successfully. %ld.%02d KB/s\r\n",
		(long)(kbs / 100), (int)(kbs % 100));

   return(GOOD);
}

static int recvfile(name, xmode)
char *name;
int xmode;
{
char *fname;
time_t datastart, dataend;
unsigned long datacount;
long kbs;
char c;
char *p;
char *op, *ope;
int fd, oflag;
int s;
int gotcr;
off_t sp;

   if(ChkLoggedIn())
	return(CleanUpData());

   fname = name;

   switch(xmode) {
	case RECV_APND:
		oflag = O_WRONLY | O_APPEND;
		break;
	case RECV_UNIQ:
		fname = uniqname();
		oflag = O_WRONLY | O_CREAT;
		break;
	default:
		oflag = O_WRONLY | O_CREAT | O_TRUNC;
   }

   if(file_restart)
	oflag = O_RDWR;

   fd = open(fname, oflag, 0666);

   if(fd < 0) {
	printf(msg550, fname, strerror(errno));
	return(CleanUpData());
   }

   /* log the received file */
   logit("RECV", path(fname));

   /* set file position at approriate spot */
   if(file_restart) {
	if(type == TYPE_A) {
		sp = 0;
		while(sp < file_restart) {
			sp++;
			s = read(fd, buffer, 1);
			if(s < 0) {
				printf(msg550, fname, strerror(errno));
				close(fd);
				file_restart = 0;
				return(CleanUpData());
			}
			if(s == 0) break;
			if(*buffer == '\n')
				sp++;
		}
	} else {
		sp = lseek(fd, file_restart, SEEK_SET);
		if(sp == -1) {
			printf(msg550, fname, strerror(errno));
			close(fd);
			file_restart = 0;
			return(CleanUpData());
		}
	}
	if(sp != file_restart) {
		printf("550 File restart point error. %lu not %lu\r\n", sp, file_restart);
		close(fd);
		file_restart = 0;
		return(CleanUpData());
	}
   }
   file_restart = 0;

   if(xmode == RECV_UNIQ)
   	printf("150 FILE: %s\r\n", fname);	/* per RFC1123 4.1.2.9 */
   else
	printf("150 File %s okay.  Opening data connection.\r\n", fname);
   fflush(stdout);

   if(DataConnect()) {
   	close(fd);
	return(GOOD);
   }

#ifdef DEBUG
   fprintf(stderr, "ftpd: parent %d start recvfile \n", getpid());
#endif

   /* start receiving file */
   datacount = 0;
   gotcr = 0;
   op = bufout; ope = bufout + sizeof(bufout) - 3;
   time(&datastart);
   while((s = read(ftpdata_fd, buffer, sizeof(buffer))) > 0) {
	datacount += s;
	if(type == TYPE_A) {
		p = buffer;
		while(s-- > 0) {
			c = *p++;
			if(gotcr) {
				gotcr = 0;
				if(c != '\n')
					*op++ = '\r';
			}
			if(c == '\r')
				gotcr = 1;
			else
				*op++ = c;
			if(op >= ope) {
				write(fd, bufout, op - bufout);
				op = bufout;
			}
		}
	} else
		write(fd, buffer, s);
   }
   if(gotcr)
	*op++ = '\r';
   if(op > bufout)
	write(fd, bufout, op - bufout);
   time(&dataend);

#ifdef DEBUG
   fprintf(stderr, "ftpd: parent %d end recvfile \n", getpid());
#endif

   close(fd);
   close(ftpdata_fd); 
   ftpdata_fd = -1;

   if(dataend == datastart) dataend++;
   kbs = (datacount * 100 / (dataend - datastart)) / 1024;

   if(s < 0)
	printf("451 Transfer aborted.\r\n");
   else {
	printf("226 Transfer finished successfully. ");
	if(xmode == RECV_UNIQ)
		printf("Unique file %s. ", fname);
	printf("%ld.%02d KB/s\r\n", (long)(kbs / 100), (int)(kbs % 100));
   }

   return(GOOD);
}

static char *uniqname()
{
static char uniq[14+1];
int i;
struct stat st;

   for(i = 0; i < 1000; i++) {
	sprintf(uniq, "ftpd%d%d", getpid(), i);
	if(stat(uniq, &st) == -1)
		return(uniq);
   }
   return(uniq);
}

static char *spath[256];
static char *path(fname)
char *fname;
{
char dir[128];

   if(fname[0] == '/')
	sprintf((char *)spath, "%s", fname);
   else {
	if(getcwd(dir, sizeof(dir)) == (char *)NULL)
		sprintf(dir, "???");

	if(dir[1] == '\0')
		sprintf((char *)spath, "/%s", fname);
	else
		sprintf((char *)spath, "%s/%s", dir, fname);
   }

   return((char *)spath);
}
