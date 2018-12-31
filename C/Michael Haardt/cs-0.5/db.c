/* #includes */ /*{{{C}}}*//*{{{*/
#ifndef NO_POSIX_SOURCE
#undef _POSIX_SOURCE
#define _POSIX_SOURCE 1
#undef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 2
#endif

/* FreeBSD is broken because it requires the first two in this order */
#include <sys/types.h>
#include <sys/stat.h>
#include <assert.h>
#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "alloc.h"
#include "cat.h"
#include "db.h"
#include "getline.h"
#include "misc.h"
#include "scan.h"
/*}}}*/

/* #defines */ /*{{{*/
#define INCLUDE_DEPTH 3 /* #include nesting */
/*}}}*/

/* variables */ /*{{{*/
static struct
{
  dev_t device;
  ino_t inode;
  char *name;
  int scan;
} *src;
int srcs=0,srcsz=0;
/*}}}*/

/* writerec    -- write a record */ /*{{{*/
int writerec(FILE *fp, char tag, dev_t dev, ino_t inode, unsigned int line, const char *function, const char *str)
{
#ifdef BINARY_DB
  size_t sz;
  int x;

  assert(fp!=(FILE*)0);
  assert(str!=(const char*)0);
  fputc(tag,fp);
  fputc(dev&0xff,fp);
  fputc((dev>>8)&0xff,fp);
  fputc((dev>>16)&0xff,fp);
  fputc((dev>>24)&0xff,fp);
  fputc(inode&0xff,fp);
  fputc((inode>>8)&0xff,fp);
  fputc((inode>>16)&0xff,fp);
  fputc((inode>>24)&0xff,fp);
  fputc(line&0xff,fp);
  fputc((line>>8)&0xff,fp);
  fputc((line>>16)&0xff,fp);
  fputc(sz=(function ? strlen(function) : 0),fp);
  assert(sz<256);
  while (sz>0) { fputc(*function,fp); --sz; ++function; }
  sz=strlen(str);
  fputc(sz&0xff,fp);
  x=fputc((sz>>8)&0xff,fp);
  while (sz>0) { x=fputc(*str,fp); --sz; ++str; }
  return (x==EOF ? EOF : 0);
#endif
#ifdef ASCII_DB
  assert(fp!=(FILE*)0);
  assert(str!=(const char*)0);
  fprintf(fp,"%c:%u:%u:%d:%s:%s",tag,(unsigned)dev,(unsigned)inode,line,function ? function : "",str);
  return (fputc('\n',fp)==EOF ? EOF : 0);
#endif
}
/*}}}*/
/* readrec     -- read a record */ /*{{{*/
static int readrec(FILE *fp, int keysearch, char *tag, dev_t *dev, ino_t *inode, unsigned int *line, const char **fun, const char **st)
{
#ifdef BINARY_DB
  static char *function=(char*)0,*str=(char*)0;
  static size_t fsz=0,ssz=0;
  size_t sz;
  char *s;
  int c;

  for (;;)
  {
  if ((c=getc(fp))==EOF) return EOF;
  *tag=c;
  *dev=getc(fp);
  *dev=*dev|(getc(fp)<<8);
  *dev=*dev|(getc(fp)<<16);
  *dev=*dev|(getc(fp)<<24);
  *inode=getc(fp);
  *inode=*inode|(getc(fp)<<8);
  *inode=*inode|(getc(fp)<<16);
  *inode=*inode|(getc(fp)<<24);
  *line=getc(fp);
  *line=*line|(getc(fp)<<8);
  *line=*line|(getc(fp)<<16);
  if ((sz=getc(fp))+1>fsz) function=realloc(function,fsz=sz+1);
  if (sz==0) *fun=(char*)0; else *fun=function;
  s=function; while (sz>0) { *s++=getc(fp); --sz; } *s='\0';
  sz=getc(fp);
  sz=sz|(getc(fp)<<8);
  if (sz>=ssz) str=realloc(str,ssz=sz+1);
  s=str; while (sz>0) { *s++=getc(fp); --sz; } *s='\0';
  if (keysearch)
  {
    if (strcmp(*st,str)==0) return 0;
  }
  else
  {
    *st=str;
    return 0;
  }
  }
#endif
#ifdef ASCII_DB
  static char ln[1024],*s;
  size_t len;
  char *str;

  for (;;)
  {
  if (fgets(ln,sizeof(ln),fp)==(char*)0) return EOF;
  if ((len=strlen(ln)) && ln[len-1]=='\n') ln[len-1]='\0';
  *tag=ln[0];
  for (*dev=0,s=strtok(ln+2,":"); isdigit(*s); ++s) *dev=*dev*10+(*s-'0');
  for (*inode=0,s=strtok((char*)0,":"); isdigit(*s); ++s) *inode=*inode*10+(*s-'0');
  for (*line=0,s=strtok((char*)0,":"); isdigit(*s); ++s) *line=*line*10+(*s-'0');
  *fun=(*(s+1)==':' ? (char*)0 : strtok((char*)0,":"));
  str=strtok((char*)0,":");
  if (keysearch)
  {
    if (strcmp(*st,str)==0) return 0;
  }
  else
  {
    *st=str;
    return 0;
  }
  }
#endif
}
/*}}}*/

/* iname       -- inode to name mapping */ /*{{{*/
static const char *iname(dev_t device, ino_t inode)
{
  int i;

  for (i=0; i<srcs && (device!=src[i].device || inode!=src[i].inode); ++i);
  assert(i!=srcs);
  return (src[i].name);
}
/*}}}*/
/* identcheck  -- check a declared identifier for posix name space */ /*{{{*/
/* this function has to read the database sequentially */
static char *identcheck(const char *identifier)
{
  char msg[1024];
  
  msg[0]='\0';
  if (strncmp(identifier,"is",2)==0) sprintf(msg,"%s begins with is, which is reserved for <ctype.h>\n",identifier);
  else if (strncmp(identifier,"to",2)==0) sprintf(msg,"%s begins with to, which is reserved for <ctype.h>\n",identifier);
  else if (strncmp(identifier,"d_",2)==0) sprintf(msg,"%s begins with d_, which is reserved for <dirent.h>\n",identifier);
  else if (identifier[0]=='E' && isupper(identifier[1])) sprintf(msg,"%s begins with E followed by an uppercase letter, which should stay reserved for <errno.h>\n",identifier);
  else if (identifier[0]=='E' && isdigit(identifier[1])) sprintf(msg,"%s begins with E followed by a digit, which should stay reserved for <errno.h>\n",identifier);
  else if (strncmp(identifier,"l_",2)==0) sprintf(msg,"%s begins with l_, which is reserved for <fcntl.h>\n",identifier);
  else if (strncmp(identifier,"gr_",3)==0) sprintf(msg,"%s begins with gr_, which is reserved for <grp.h>\n",identifier);
  else if (strncmp(identifier,"pw_",3)==0) sprintf(msg,"%s begins with pw_, which is reserved for <pwd.h>\n",identifier);
  else if (strncmp(identifier,"sa_",3)==0) sprintf(msg,"%s begins with sa_, which is reserved for <signal.h>\n",identifier);
  else if (strncmp(identifier,"mem",3)==0) sprintf(msg,"%s begins with mem, which is reserved for <string.h>\n",identifier);
  else if (strncmp(identifier,"str",3)==0) sprintf(msg,"%s begins with str, which is reserved for <string.h>\n",identifier);
  else if (strncmp(identifier,"wcs",3)==0) sprintf(msg,"%s begins with wcs, which is reserved for <string.h>\n",identifier);
  else if (strncmp(identifier,"st_",3)==0) sprintf(msg,"%s begins with st_, which is reserved for <sys/stat.h>\n",identifier);
  else if (strncmp(identifier,"tms_",4)==0) sprintf(msg,"%s begins with tms_, which is reserved for <sys/times.h>\n",identifier);
  else if (strncmp(identifier,"c_",2)==0) sprintf(msg,"%s begins with c_, which should stay reserved for <termios.h>\n",identifier);
  else if (strncmp(identifier,"tm_",3)==0) sprintf(msg,"%s begins with tm_, which is reserved for <time.h>\n",identifier);
  else if (strncmp(identifier,"__",2)==0) sprintf(msg,"%s begins with __, which is reserved for the system\n",identifier);
  else if (identifier[0]=='_' && isupper(identifier[1]) && strcmp(identifier,"_POSIX_SOURCE") && strcmp(identifier,"_POSIX_C_SOURCE")) sprintf(msg,"%s begins with _ followed by an uppercase letter, which is reserved for the system\n",identifier);
  if (strlen(identifier)>=(size_t)4 && strcmp(identifier+strlen(identifier)-4,"_MAX")==0) sprintf(msg,"%s end with _MAX, which should stay reserved for <limits.h>\n",identifier);
  return (msg[0] ? mystrsave(msg) : (char*)0);
}
/*}}}*/
/* includes    -- does a file include another one? */ /*{{{*/
static int includes(int level, const char *file, const char *header, const char *indexfile)
{
  /* variables */ /*{{{*/
  FILE *fp;
  dev_t device;
  ino_t inode;
  unsigned int line;
  char tag;
  const char *fun,*ident;
  /*}}}*/

  if (level<=0) return 0;
  /* asserts */ /*{{{*/
  assert(file!=(const char*)0);
  assert(header!=(const char*)0);
  assert(indexfile!=(const char*)0);
  /*}}}*/
  if ((fp=fopen(indexfile,"r"))==(FILE*)0) /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CREATEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  ident=header;
  while (readrec(fp,1,&tag,&device,&inode,&line,&fun,&ident)!=EOF)
  {
    switch (tag)
    {
      case INCLUDE_HEADER: /*{{{*/
      {
        if (strcmp(iname(device,inode),file)==0)
        {
          if (strstr(ident,header) || includes(level-1,ident,header,indexfile))
          {
            fclose(fp);
            return 1;
          }
        }
        break;
      }
      /*}}}*/
    }
  }
  fclose(fp);
  return 0;
}
/*}}}*/
/* requireinc  -- check for required includes */ /*{{{*/
static char *requireinc(const char *identifier, const char *file, const char *indexfile)
{
  /* variables */ /*{{{*/
  struct
  {
    const char *keyword;
    const char *include1;
    const char *include2;
    const char *include3;
  } check[] =
  {
    { "assert", "assert.h", (const char*)0, (const char*)0 },
    { "abort", "stdlib.h", (const char*)0, (const char*)0 },
    { "abs", "stdlib.h", (const char*)0, (const char*)0 },
    { "access", "unistd.h", (const char*)0, (const char*)0 },
    { "acos", "math.h", (const char*)0, (const char*)0 },
    { "alarm", "unistd.h", (const char*)0, (const char*)0 },
    { "asctime", "time.h", (const char*)0, (const char*)0 },
    { "asin", "math.h", (const char*)0, (const char*)0 },
    { "atan", "math.h", (const char*)0, (const char*)0 },
    { "atan2", "math.h", (const char*)0, (const char*)0 },
    { "atexit", "stdlib.h", (const char*)0, (const char*)0 },
    { "atof", "stdlib.h", (const char*)0, (const char*)0 },
    { "atoi", "stdlib.h", (const char*)0, (const char*)0 },
    { "atol", "stdlib.h", (const char*)0, (const char*)0 },
    { "bsearch", "stdlib.h", (const char*)0, (const char*)0 },
    { "calloc", "stdlib.h", (const char*)0, (const char*)0 },
    { "cfgetispeed", "termios.h", (const char*)0, (const char*)0 },
    { "cfgetospeed", "termios.h", (const char*)0, (const char*)0 },
    { "cfsetispeed", "termios.h", (const char*)0, (const char*)0 },
    { "cfgetospeed", "termios.h", (const char*)0, (const char*)0 },
    { "chdir", "unistd.h", (const char*)0, (const char*)0 },
    { "chmod", "sys/types.h", "sys/stat.h", (const char*)0 },
    { "chown", "sys/types.h", "unistd.h", (const char*)0 },
    { "clearerr", "stdio.h", (const char*)0, (const char*)0 },
    { "clock", "time.h", (const char*)0, (const char*)0 },
    { "close", "unistd.h", (const char*)0, (const char*)0 },
    { "closedir", "sys/types.h", "dirent.h", (const char*)0 },
    { "cos", "math.h", (const char*)0, (const char*)0 },
    { "cosh", "math.h", (const char*)0, (const char*)0 },
    { "creat", "sys/types.h", "sys/stat.h", "fcntl.h" },
    { "ctermid", "stdio.h", (const char*)0, (const char*)0 },
    { "ctime", "time.h", (const char*)0, (const char*)0 },
    { "cuserid", "stdio.h", (const char*)0, (const char*)0 },
    { "difftime", "time.h", (const char*)0, (const char*)0 },
    { "div", "stdlib.h", (const char*)0, (const char*)0 },
    { "dup", "unistd.h", (const char*)0, (const char*)0 },
    { "dup2", "unistd.h", (const char*)0, (const char*)0 },
    { "errno", "errno.h", (const char*)0, (const char*)0 },
    { "execl", "unistd.h", (const char*)0, (const char*)0 },
    { "execle", "unistd.h", (const char*)0, (const char*)0 },
    { "execlp", "unistd.h", (const char*)0, (const char*)0 },
    { "execv", "unistd.h", (const char*)0, (const char*)0 },
    { "execve", "unistd.h", (const char*)0, (const char*)0 },
    { "execvp", "unistd.h", (const char*)0, (const char*)0 },
    { "exit", "stdlib.h", (const char*)0, (const char*)0 },
    { "_exit", "unistd.h", (const char*)0, (const char*)0 },
    { "exp", "math.h", (const char*)0, (const char*)0 },
    { "fabs", "math.h", (const char*)0, (const char*)0 },
    { "fclose", "stdio.h", (const char*)0, (const char*)0 },
    { "fcntl", "fcntl.h", "unistd.h", (const char*)0 },
    { "fdopen", "stdio.h", (const char*)0, (const char*)0 },
    { "feof", "stdio.h", (const char*)0, (const char*)0 },
    { "ferror", "stdio.h", (const char*)0, (const char*)0 },
    { "fflush", "stdio.h", (const char*)0, (const char*)0 },
    { "fgetc", "stdio.h", (const char*)0, (const char*)0 },
    { "fgetpos", "stdio.h", (const char*)0, (const char*)0 },
    { "fgets", "stdio.h", (const char*)0, (const char*)0 },
    { "fileno", "stdio.h", (const char*)0, (const char*)0 },
    { "floor", "math.h", (const char*)0, (const char*)0 },
    { "fmod", "math.h", (const char*)0, (const char*)0 },
    { "fopen", "stdio.h", (const char*)0, (const char*)0 },
    { "fork", "sys/types.h", "unistd.h", (const char*)0 },
    { "fpathconf", "unistd.h", (const char*)0, (const char*)0 },
    { "fprintf", "stdio.h", (const char*)0, (const char*)0 },
    { "fputc", "stdio.h", (const char*)0, (const char*)0 },
    { "fputs", "stdio.h", (const char*)0, (const char*)0 },
    { "fread", "stdio.h", (const char*)0, (const char*)0 },
    { "free", "stdlib.h", (const char*)0, (const char*)0 },
    { "fropen", "stdio.h", (const char*)0, (const char*)0 },
    { "frexp", "math.h", (const char*)0, (const char*)0 },
    { "fscanf", "stdio.h", (const char*)0, (const char*)0 },
    { "fseek", "stdio.h", (const char*)0, (const char*)0 },
    { "fsetpos", "stdio.h", (const char*)0, (const char*)0 },
    { "fstat", "sys/types.h", "sys/stat.h", (const char*)0 },
    { "ftell", "stdio.h", (const char*)0, (const char*)0 },
    { "fwrite", "stdio.h", (const char*)0, (const char*)0 },
    { "getc", "stdio.h", (const char*)0, (const char*)0 },
    { "getchar", "stdio.h", (const char*)0, (const char*)0 },
    { "getcwd", "unistd.h", (const char*)0, (const char*)0 },
    { "getegid", "sys/types.h", "unistd.h", (const char*)0 },
    { "getenv", "stdlib.h", (const char*)0, (const char*)0 },
    { "geteuid", "sys/types.h", "unistd.h", (const char*)0 },
    { "getgid", "sys/types.h", "unistd.h", (const char*)0 },
    { "getgrgid", "grp.h", (const char*)0, (const char*)0 },
    { "getgrnam", "grp.h", (const char*)0, (const char*)0 },
    { "getgroups", "sys/types.h", "unistd.h", (const char*)0 },
    { "getlogin", "unistd.h", (const char*)0, (const char*)0 },
    { "getpgrp", "sys/types.h", "unistd.h", (const char*)0 },
    { "getpid", "sys/types.h", "unistd.h", (const char*)0 },
    { "getppid", "sys/types.h", "unistd.h", (const char*)0 },
    { "getpwnam", "pwd.h", (const char*)0, (const char*)0 },
    { "getpwuid", "pwd.h", (const char*)0, (const char*)0 },
    { "gets", "stdio.h", (const char*)0, (const char*)0 },
    { "getuid", "sys/types.h", "unistd.h", (const char*)0 },
    { "gmtime", "time.h", (const char*)0, (const char*)0 },
    { "isalnum", "ctype.h", (const char*)0, (const char*)0 },
    { "isalpha", "ctype.h", (const char*)0, (const char*)0 },
    { "isatty", "unistd.h", (const char*)0, (const char*)0 },
    { "iscntrl", "ctype.h", (const char*)0, (const char*)0 },
    { "isdigit", "ctype.h", (const char*)0, (const char*)0 },
    { "isgraph", "ctype.h", (const char*)0, (const char*)0 },
    { "islower", "ctype.h", (const char*)0, (const char*)0 },
    { "isprint", "ctype.h", (const char*)0, (const char*)0 },
    { "ispunct", "ctype.h", (const char*)0, (const char*)0 },
    { "isspace", "ctype.h", (const char*)0, (const char*)0 },
    { "isupper", "ctype.h", (const char*)0, (const char*)0 },
    { "isxdigit", "ctype.h", (const char*)0, (const char*)0 },
    { "kill", "sys/types.h", "signal.h", (const char*)0 },
    { "labs", "stdlib.h", (const char*)0, (const char*)0 },
    { "ldexp", "math.h", (const char*)0, (const char*)0 },
    { "ldiv", "stdlib.h", (const char*)0, (const char*)0 },
    { "link", "unistd.h", (const char*)0, (const char*)0 },
    { "localeconv", "locale.h", (const char*)0, (const char*)0 },
    { "localtime", "time.h", (const char*)0, (const char*)0 },
    { "log", "math.h", (const char*)0, (const char*)0 },
    { "log10", "math.h", (const char*)0, (const char*)0 },
    { "longjmp", "setjmp.h", (const char*)0, (const char*)0 },
    { "lseek", "sys/types.h", "unistd.h", (const char*)0 },
    { "malloc", "stdlib.h", (const char*)0, (const char*)0 },
    { "mblen", "stdlib.h", (const char*)0, (const char*)0 },
    { "mbstowcs", "stdlib.h", (const char*)0, (const char*)0 },
    { "mbtowc", "stdlib.h", (const char*)0, (const char*)0 },
    { "memchr", "stdlib.h", (const char*)0, (const char*)0 },
    { "memcmp", "stdlib.h", (const char*)0, (const char*)0 },
    { "memcpy", "stdlib.h", (const char*)0, (const char*)0 },
    { "memmove", "stdlib.h", (const char*)0, (const char*)0 },
    { "memset", "stdlib.h", (const char*)0, (const char*)0 },
    { "mkdir", "sys/types.h", "sys/stat.h", (const char*)0 },
    { "mkfifo", "sys/types.h", "sys/stat.h", (const char*)0 },
    { "mktime", "time.h", (const char*)0, (const char*)0 },
    { "modf", "math.h", (const char*)0, (const char*)0 },
    { "open", "sys/types.h", "sys/stat.h", "fcntl.h" },
    { "opendir", "sys/types.h", "dirent.h", (const char*)0 },
    { "pathconf", "unistd.h", (const char*)0, (const char*)0 },
    { "pause", "unistd.h", (const char*)0, (const char*)0 },
    { "perror", "stdio.h", (const char*)0, (const char*)0 },
    { "pipe", "unistd.h", (const char*)0, (const char*)0 },
    { "pow", "math.h", (const char*)0, (const char*)0 },
    { "printf", "stdio.h", (const char*)0, (const char*)0 },
    { "putc", "stdio.h", (const char*)0, (const char*)0 },
    { "putchar", "stdio.h", (const char*)0, (const char*)0 },
    { "puts", "stdio.h", (const char*)0, (const char*)0 },
    { "qsort", "stdlib.h", (const char*)0, (const char*)0 },
    { "signal", "signal.h", (const char*)0, (const char*)0 },
    { "raise", "signal.h", (const char*)0, (const char*)0 },
    { "rand", "stdlib.h", (const char*)0, (const char*)0 },
    { "read", "unistd.h", (const char*)0, (const char*)0 },
    { "readdir", "sys/types.h", "dirent.h", (const char*)0 },
    { "ralloc", "stdlib.h", (const char*)0, (const char*)0 },
    { "remove", "stdio.h", (const char*)0, (const char*)0 },
    { "rename", "unistd.h", (const char*)0, (const char*)0 },
    { "rewind", "stdio.h", (const char*)0, (const char*)0 },
    { "rewinddir", "sys/types.h", "dirent.h", (const char*)0 },
    { "rmdir", "unistd.h", (const char*)0, (const char*)0 },
    { "scanf", "stdio.h", (const char*)0, (const char*)0 },
    { "setbuf", "stdio.h", (const char*)0, (const char*)0 },
    { "setgid", "sys/types.h", "unistd.h", (const char*)0 },
    { "setjmp", "setjmp.h", (const char*)0, (const char*)0 },
    { "setlocale", "locale.h", (const char*)0, (const char*)0 },
    { "setpgid", "sys/types.h", "unistd.h", (const char*)0 },
    { "setsid", "sys/types.h", "unistd.h", (const char*)0 },
    { "setuid", "sys/types.h", "unistd.h", (const char*)0 },
    { "setvbuf", "stdio.h", (const char*)0, (const char*)0 },
    { "sigaction", "signal.h", (const char*)0, (const char*)0 },
    { "sigaddset", "signal.h", (const char*)0, (const char*)0 },
    { "sigdelset", "signal.h", (const char*)0, (const char*)0 },
    { "sigemptyset", "signal.h", (const char*)0, (const char*)0 },
    { "sigfillset", "signal.h", (const char*)0, (const char*)0 },
    { "sigismember", "signal.h", (const char*)0, (const char*)0 },
    { "siglongjmp", "setjmp.h", (const char*)0, (const char*)0 },
    { "signal", "signal.h", (const char*)0, (const char*)0 },
    { "sigpending", "signal.h", (const char*)0, (const char*)0 },
    { "sigprocmask", "signal.h", (const char*)0, (const char*)0 },
    { "sigsetjmp", "setjmp.h", (const char*)0, (const char*)0 },
    { "sigsuspend", "signal.h", (const char*)0, (const char*)0 },
    { "sin", "math.h", (const char*)0, (const char*)0 },
    { "sinh", "math.h", (const char*)0, (const char*)0 },
    { "sleep", "unistd.h", (const char*)0, (const char*)0 },
    { "sprintf", "stdio.h", (const char*)0, (const char*)0 },
    { "sqrt", "math.h", (const char*)0, (const char*)0 },
    { "srand", "stdlib.h", (const char*)0, (const char*)0 },
    { "sscanf", "stdio.h", (const char*)0, (const char*)0 },
    { "stat", "sys/types.h", "sys/stat.h", (const char*)0 },
    { "strcat", "string.h", (const char*)0, (const char*)0 },
    { "strchr", "string.h", (const char*)0, (const char*)0 },
    { "strcmp", "string.h", (const char*)0, (const char*)0 },
    { "strcoll", "string.h", (const char*)0, (const char*)0 },
    { "strcpy", "string.h", (const char*)0, (const char*)0 },
    { "strcspn", "string.h", (const char*)0, (const char*)0 },
    { "strerror", "string.h", (const char*)0, (const char*)0 },
    { "strftime", "time.h", (const char*)0, (const char*)0 },
    { "strlen", "string.h", (const char*)0, (const char*)0 },
    { "strncat", "string.h", (const char*)0, (const char*)0 },
    { "strncmp", "string.h", (const char*)0, (const char*)0 },
    { "strcpy", "string.h", (const char*)0, (const char*)0 },
    { "strpbrk", "string.h", (const char*)0, (const char*)0 },
    { "strrchr", "string.h", (const char*)0, (const char*)0 },
    { "strspn", "string.h", (const char*)0, (const char*)0 },
    { "strstr", "string.h", (const char*)0, (const char*)0 },
    { "strtod", "stdlib.h", (const char*)0, (const char*)0 },
    { "strtok", "string.h", (const char*)0, (const char*)0 },
    { "strtol", "stdlib.h", (const char*)0, (const char*)0 },
    { "strtoul", "stdlib.h", (const char*)0, (const char*)0 },
    { "strxfrm", "string.h", (const char*)0, (const char*)0 },
    { "sysconf", "unistd.h", (const char*)0, (const char*)0 },
    { "system", "stdlib.h", (const char*)0, (const char*)0 },
    { "tan", "math.h", (const char*)0, (const char*)0 },
    { "tanh", "math.h", (const char*)0, (const char*)0 },
    { "tcdrain", "termios.h", "unistd.h", (const char*)0 },
    { "tcflow", "termios.h", "unistd.h", (const char*)0 },
    { "tcflush", "termios.h", "unistd.h", (const char*)0 },
    { "tcgetattr", "termios.h", "unistd.h", (const char*)0 },
    { "tcgetpgrp", "sys/types.h", "unistd.h", (const char*)0 },
    { "tcsendbreak", "termios.h", "unistd.h", (const char*)0 },
    { "tcsetattr", "termios.h", "unistd.h", (const char*)0 },
    { "tcsetpgrp", "sys/types.h", "unistd.h", (const char*)0 },
    { "time", "time.h", (const char*)0, (const char*)0 },
    { "times", "sys/times.h", (const char*)0, (const char*)0 },
    { "tmpfile", "stdio.h", (const char*)0, (const char*)0 },
    { "tmpnam", "stdio.h", (const char*)0, (const char*)0 },
    { "toupper", "ctype.h", (const char*)0, (const char*)0 },
    { "tolower", "ctype.h", (const char*)0, (const char*)0 },
    { "ttyname", "unistd.h", (const char*)0, (const char*)0 },
    { "tzset", "time.h", (const char*)0, (const char*)0 },
    { "umask", "sys/types.h", "sys/stat.h", (const char*)0 },
    { "uname", "sys/utsname.h", (const char*)0, (const char*)0 },
    { "ungetc", "stdio.h", (const char*)0, (const char*)0 },
    { "unlink", "unistd.h", (const char*)0, (const char*)0 },
    { "utime", "sys/types.h", "utime.h", (const char*)0 },
    { "va_arg", "stdarg.h", (const char*)0, (const char*)0 },
    { "va_end", "stdarg.h", (const char*)0, (const char*)0 },
    { "va_start", "stdarg.h", (const char*)0, (const char*)0 },
    { "vfprintf", "stdarg.h", "stdio.h", (const char*)0 },
    { "vprintf", "stdio.h", (const char*)0, (const char*)0 },
    { "vsprintf", "stdio.h", (const char*)0, (const char*)0 },
    { "wait", "sys/types.h", "sys/wait.h", (const char*)0 },
    { "waitpid", "sys/types.h", "sys/wait.h", (const char*)0 },
    { "wcstombs", "stdlib.h", (const char*)0, (const char*)0 },
    { "wctomb", "stdlib.h", (const char*)0, (const char*)0 },
    { "write", "unistd.h", (const char*)0, (const char*)0 },
  };
  int i;
  char msg[1024];
  /*}}}*/

  msg[0]='\0';
  for (i=0; i<(sizeof(check)/sizeof(check[0])) && strcmp(check[i].keyword,identifier); ++i);
  if (i<(sizeof(check)/sizeof(check[0])))
  {
    if (!includes(INCLUDE_DEPTH,file,check[i].include1,indexfile)) sprintf(msg,"%s used without including <%s>\n",check[i].keyword,check[i].include1);
    else if (check[i].include2 && !includes(INCLUDE_DEPTH,file,check[i].include2,indexfile)) sprintf(msg,"%s used without including <%s>\n",check[i].keyword,check[i].include2);
    else if (check[i].include3 && !includes(INCLUDE_DEPTH,file,check[i].include3,indexfile)) sprintf(msg,"%s used without including <%s>\n",check[i].keyword,check[i].include3);
  }
  return (msg[0] ? mystrsave(msg) : (char*)0);
}
/*}}}*/
/* updateentry -- update file database */ /*{{{*/
static void updateentry(dev_t device, ino_t inode, const char *name, int modified)
{
  int i;

  for (i=0; i<srcs && (device!=src[i].device || inode!=src[i].inode); ++i);
  if (i==srcs)
  {
    if (srcs==srcsz)
    {
      if (srcsz) src=xrealloc(src,sizeof(src[0])*(srcsz*=2));
      else src=xmalloc(sizeof(src[0])*(srcsz=64));
    }
    src[srcs].name=strcpy(xmalloc(strlen(name)+1),name);
    src[srcs].scan=modified;
    src[srcs].device=device;
    src[srcs].inode=inode;
    ++srcs;
  }
  else
  {
    if (strcmp(src[i].name,name))
    {
      free(src[i].name);
      src[i].name=strcpy(xmalloc(strlen(name)+1),name);
    }
    src[i].scan=modified;
  }
}
/*}}}*/
/* dirscan     -- scan files and directories to find removed/modified/new files */ /*{{{*/
static void dirscan(const char *indexfile, const char * const *file, int files, int force)
{
  /* variables */ /*{{{*/
  int i,j;
  time_t timestamp;
  struct stat statbuf;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(indexfile!=(const char*)0);
  assert(file!=(const char * const *)0);
  assert(files>0);
  /*}}}*/
  timestamp=(stat(indexfile,&statbuf)==-1 ? (time_t)0 : statbuf.st_mtime);
  for (i=0; i<srcs; ++i) src[i].scan=-1;
  /* scan all files and directories, updating entries */ /*{{{*/
  for (i=0; i<files; ++i)
  {
    if (stat(file[i],&statbuf)==-1) fprintf(stderr,STATFAIL,file[i],strerror(errno));
    else
    {
      if (S_ISREG(statbuf.st_mode)) updateentry(statbuf.st_dev,statbuf.st_ino,file[i],force || statbuf.st_mtime>timestamp);
      else if (S_ISDIR(statbuf.st_mode)) /* scan directory for files */ /*{{{*/
      {
        DIR *dir;

        if ((dir=opendir(file[i]))==(DIR*)0) fprintf(stderr,OPENFAIL,file[i],strerror(errno));
        else
        {
          size_t len;
          struct dirent *dirent;

          while ((dirent=readdir(dir)))
          {
            if ((len=strlen(dirent->d_name))>=3 && (strcmp(dirent->d_name+len-2,".c")==0 || strcmp(dirent->d_name+len-2,".h")==0))
            {
              char name[_POSIX_PATH_MAX];

              if (file[i][0]=='.' && file[i][1]=='\0') strcpy(name,dirent->d_name);
              else
              {
                strcpy(name,file[i]);
                strcat(name,"/");
                strcat(name,dirent->d_name);
              } 
              if (stat(name,&statbuf)==-1) fprintf(stderr,STATFAIL,name,strerror(errno));
              updateentry(statbuf.st_dev,statbuf.st_ino,name,force || statbuf.st_mtime>timestamp);
            }
          }
          closedir(dir);
        }
      }
      /*}}}*/
      else fprintf(stderr,NOTREGDIR,file[i]);
    }
  }
  /*}}}*/
  /* delete all removed files from the file database */ /*{{{*/
  for (i=0,j=0; i<srcs; ++i) if (src[i].scan==-1)
  {
    if (j<=i) j=i+1;
    while (j<srcs && (src[j].scan==-1)) ++j;
    if (j<srcs)
    {
      free(src[i].name);
      src[i]=src[j];
      ++j;
    }
    if (j==srcs)
    {
      for (j=i; j<srcs; ++j) free(src[j].name);
      srcs=i;
      break;
    }
  }
  /*}}}*/
}
/*}}}*/

/* findid      -- find C symbol */ /*{{{*/
void findid(struct Lines *l, const char *id, const char *indexfile)
{
  /* variables */ /*{{{*/
  FILE *fp;
  dev_t device;
  ino_t inode;
  unsigned int line;
  const char *fun,*ident;
  char tag;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(l!=(struct Lines*)0);
  assert(id!=(const char*)0);
  assert(indexfile!=(const char*)0);
  /*}}}*/
  if ((fp=fopen(indexfile,"r"))==(FILE*)0) /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CREATEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  ident=id;
  while (readrec(fp,1,&tag,&device,&inode,&line,&fun,&ident)!=EOF)
  {
    switch (tag)
    {
      case STATIC_FUNCTION: /*{{{*/
      {
        printline(l,iname(device,inode),line,(char*)0,getline(iname(device,inode),line));
        break;
      }
      /*}}}*/
      case GLOBAL_FUNCTION: /*{{{*/
      {
        printline(l,iname(device,inode),line,(char*)0,getline(iname(device,inode),line));
        break;
      }
      /*}}}*/
      case IDENTIFIER:      /*{{{*/
      {
        printline(l,iname(device,inode),line,fun,getline(iname(device,inode),line));
        break;
      }
      /*}}}*/
      case FUNCTION_CALL:   /*{{{*/
      {
        printline(l,iname(device,inode),line,fun,getline(iname(device,inode),line));
        break;
      }
      /*}}}*/
    }
  }
  fclose(fp);
}
/*}}}*/
/* findcallee  -- find functions called by a function */ /*{{{*/
/* this function has to read the database sequentially */
void findcallee(struct Lines *l, const char *id, const char *indexfile)
{
  /* variables */ /*{{{*/
  FILE *fp;
  dev_t device;
  ino_t inode;
  unsigned int line;
  const char *fun,*ident;
  char tag;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(l!=(struct Lines*)0);
  assert(id!=(const char*)0);
  assert(indexfile!=(const char*)0);
  /*}}}*/
  if ((fp=fopen(indexfile,"r"))==(FILE*)0) /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CREATEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  while (readrec(fp,0,&tag,&device,&inode,&line,&fun,&ident)!=EOF)
  {
    switch (tag)
    {
      case FUNCTION_CALL: /*{{{*/
      {
        if (strcmp(id,fun)==0) printline(l,iname(device,inode),line,fun,getline(iname(device,inode),line));
        break;
      }
      /*}}}*/
    }
  }
  fclose(fp);
}
/*}}}*/
/* findcaller  -- find functions calling a function */ /*{{{*/
/* this could use the called function as key */
void findcaller(struct Lines *l, const char *id, const char *indexfile)
{
  /* variables */ /*{{{*/
  FILE *fp;
  dev_t device;
  ino_t inode;
  unsigned int line;
  const char *fun,*ident;
  char tag;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(l!=(struct Lines*)0);
  assert(id!=(const char*)0);
  assert(indexfile!=(const char*)0);
  /*}}}*/
  if ((fp=fopen(indexfile,"r"))==(FILE*)0) /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CREATEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  ident=id;
  while (readrec(fp,1,&tag,&device,&inode,&line,&fun,&ident)!=EOF)
  {
    switch (tag)
    {
      case FUNCTION_CALL: /*{{{*/
      {
        printline(l,iname(device,inode),line,fun,getline(iname(device,inode),line));
        break;
      }
      /*}}}*/
    }
  }
  fclose(fp);
}
/*}}}*/
/* findlit     -- find literal */ /*{{{*/
/* this function has to read the database sequentially */
void findlit(struct Lines *l, const char *literal, const char *indexfile)
{
  /* variables */ /*{{{*/
  FILE *fp;
  dev_t device;
  ino_t inode;
  unsigned int line;
  const char *fun,*ident;
  char tag;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(l!=(struct Lines*)0);
  assert(literal!=(const char*)0);
  assert(indexfile!=(const char*)0);
  /*}}}*/
  if ((fp=fopen(indexfile,"r"))==(FILE*)0) /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CREATEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  while (readrec(fp,0,&tag,&device,&inode,&line,&fun,&ident)!=EOF)
  {
    switch (tag)
    {
      case LITERAL: /*{{{*/
      {
        if (strstr(ident,literal)) printline(l,iname(device,inode),line,fun,getline(iname(device,inode),line));
        break;
      }
      /*}}}*/
    }
  }
  fclose(fp);
}
/*}}}*/
/* findinclude -- find files #including a file */ /*{{{*/
/* this could use the file as key */
void findinclude(struct Lines *l, const char *file, const char *indexfile)
{
  /* variables */ /*{{{*/
  FILE *fp;
  dev_t device;
  ino_t inode;
  unsigned int line;
  const char *fun,*ident;
  char tag;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(l!=(struct Lines*)0);
  assert(file!=(const char*)0);
  assert(indexfile!=(const char*)0);
  /*}}}*/
  if ((fp=fopen(indexfile,"r"))==(FILE*)0) /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CREATEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  ident=file;
  while (readrec(fp,1,&tag,&device,&inode,&line,&fun,&ident)!=EOF)
  {
    switch (tag)
    {
      case INCLUDE_HEADER: /*{{{*/
      {
        if (strstr(ident,file)) printline(l,iname(device,inode),line,fun,getline(iname(device,inode),line));
        break;
      }
      /*}}}*/
    }
  }
  fclose(fp);
}
/*}}}*/
/* findfile    -- find file */ /*{{{*/
void findfile(struct Lines *l, const char *literal)
{
  /* variables */ /*{{{*/
  int i;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(l!=(struct Lines*)0);
  assert(literal!=(const char*)0);
  /*}}}*/
  for (i=0; i<srcs; ++i)
  {
    if (strstr(src[i].name,literal)) printline(l,src[i].name,1,(char*)0,getline(src[i].name,1));
  }
}
/*}}}*/
/* findposix   -- find POSIX naming violations */ /*{{{*/
/* this function has to read the database sequentially */
void findposix(struct Lines *l, const char *indexfile)
{
  /* variables */ /*{{{*/
  FILE *fp;
  dev_t device;
  ino_t inode;
  unsigned int line;
  const char *fun,*ident;
  char tag,*msg;
  /*}}}*/

  /* asserts */ /*{{{*/
  assert(l!=(struct Lines*)0);
  assert(indexfile!=(const char*)0);
  /*}}}*/
  if ((fp=fopen(indexfile,"r"))==(FILE*)0)  /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CREATEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  while (readrec(fp,0,&tag,&device,&inode,&line,&fun,&ident)!=EOF)
  {
    switch (tag)
    {
      case IDENTIFIER:      
      case GLOBAL_FUNCTION:
      case STATIC_FUNCTION: /*{{{*/
      {
        if (fun==(char*)0 && (msg=identcheck(ident))!=(char*)0) printline(l,iname(device,inode),line,fun,msg);
        break;
      }
      /*}}}*/
      case FUNCTION_CALL: /*{{{*/
      {
        if ((msg=requireinc(ident,iname(device,inode),indexfile))!=(char*)0) printline(l,iname(device,inode),line,fun,msg);
        break;
      }
      /*}}}*/
    }
  }
  fclose(fp);
}
/*}}}*/
/* update      -- update object database */ /*{{{*/
void update(const char *indexfile, const char * const *file, int files, int force)
{
  /* variables */ /*{{{*/
  FILE *ifp,*ofp;
  dev_t device;
  ino_t inode;
  unsigned int line;
  const char *fun,*ident;
  char tag;
  int i;
  /*}}}*/

  dirscan(indexfile,file,files,force);
  for (i=0; i<srcs && src[i].scan==0; ++i);
  if (i==srcs) return;
  unlink("cs.tmp");
  rename(indexfile,"cs.tmp");
  if ((ofp=fopen(indexfile,"w"))==(FILE*)0) /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CREATEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  if ((ifp=fopen("cs.tmp","r")))
  {
    while (readrec(ifp,0,&tag,&device,&inode,&line,&fun,&ident)!=EOF)
    {
      for (i=0; i<srcs; ++i) if ((src[i].inode!=inode || src[i].device!=device) && src[i].scan==0)
      {
        writerec(ofp,tag,device,inode,line,fun,ident);
        break;
      }
    }
    if (fclose(ifp)==-1) /* cry and give up */ /*{{{*/
    {
      fprintf(stderr,CLOSEFAIL,indexfile,strerror(errno));
      exit(1);
    }
    /*}}}*/
  }
  for (i=0; i<srcs; ++i)
  {
    if (src[i].scan==1) parsefile(src[i].device,src[i].inode,src[i].name, ofp);
  }
  if (fclose(ofp)==-1)
  /* cry and give up */ /*{{{*/
  {
    fprintf(stderr,CLOSEFAIL,indexfile,strerror(errno));
    exit(1);
  }
  /*}}}*/
  unlink("cs.tmp");
}
/*}}}*/
