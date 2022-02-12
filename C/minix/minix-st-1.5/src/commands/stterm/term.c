/* minix doesn't suport open(path, oflag, mode) so no NODELAY		*/

/* my work around is to run term as 2 procs one that reads /dev/tty1	*/
/* and one that writes to it.  Now if we block for reading it doesn't	*/
/* matter.								*/

/*
 * enhancements:
 * usage: term [-s speed] [-l line] [-e escape-char]
 *	defaults:
 *		speed:  9600      -- see const.h
 *		line :  /dev/tty1 -- see const.h
 *		escape: ~	  -- see const.h
 *		        escape char may be specified as three octal digits
 *
 *	term escapes: (see man tip) -- more to come
 *		escape-. or escape-CTRLD	terminate
 *		escape-!			escape to shell
 *		escape-#			send break
 *		escape-escape			send escape char
 *
 *	++jrb	bammi@dsrgsun.ces.cwru.edu
 */

#include <sys/types.h>
#include <signal.h>
#include <sgtty.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include "const.h"

#ifndef R_OK		/* access() modes */
#define R_OK 4
#define W_OK 2
#endif

char *i_am = "term"; 	   /* name used in err() */
extern void err();   	   /* error printing routine */
extern void s_line();	   /* set & save line characteristics   */
extern void r_line();	   /* reset saved  line characteristics */

static int rd_pid, wr_pid;	   /* reader/writer process id's */
static int line_fd;		   /* comm line file desc        */
static int con_fd;		   /* console   file desc        */

static struct sgttyb con, con_save, /* console line characteristics */
                   line, line_save; /* comm    line characteristics */

#ifdef __STDC__
void cleanup(int foo)
#else
int cleanup()
#endif
{
  r_line();
  kill(rd_pid, SIGTERM);
  kill(wr_pid, SIGTERM);

  exit(0);
}

void main(argc, argv)
int argc;
char **argv;
{
  int done, status;
  int speed = SPEED;
  char device[32];
  char esc[2];
  extern char *optarg;
  extern int getopt(), conv_speed(), conv_esc(), access();
  extern char *itoa();
  
  esc[0] = ESC;
  esc[1] = '\0';  
  strcpy(device, LINE);
  while((status = getopt(argc, argv,"s:l:e:")) != EOF)
  {
      switch(status)
      {
	case 's':
	  if((speed = conv_speed(optarg)) == EOF)
	  {
	      fprintf(stderr,"%s: invalid speed\n", optarg);
	      exit(1);
	  }
	  break;
	case 'l':
	  strncpy(device, optarg, (int)sizeof device); /* avoid screwage */
	  if(access(device, R_OK|W_OK) == EOF)
	  {
	      perror(optarg);
	      exit(2);
	  }
	  break;
	case 'e':
	  esc[0] = conv_esc(optarg);
	  break;
	default:
	  fprintf(stderr,
		  "usage: %s [-s speed] [-l line] [-e escape-char]\n", *argv);
	  exit(3);
      }
  }

  if((line_fd = open(device, O_RDWR)) < 0)
  {
      perror(device);
      exit(4);
  }
  con_fd = fileno(stdin);

  /* set line chars. semi-atomically */
  signal(SIGINT, SIG_IGN);
  signal(SIGQUIT, SIG_IGN);

  s_line(speed);
  
  signal(SIGINT, cleanup);
  signal(SIGQUIT, cleanup);

/* launch reader process */
  if (rd_pid = fork()) {
	if (rd_pid == -1)
		err("fork tty reader");
  } else {
        /* re-dir stdin */
      close(fileno(stdin));
      dup(line_fd);
#if 0
#ifdef TIOCSTART
  	if (ioctl(0, TIOCSTART, 0) == ERR)
		err("reset comm line");
#endif
#endif
	
	execlp("read_tty", "read_tty", (char *)0);
  }

/* launch writer process */
  if (wr_pid = fork()) {
	if (wr_pid == -1)
		err("fork tty writer");
  } else {
        /* re-dir stdout */
      close(fileno(stdout));
      dup(line_fd);
      execlp("write_tty", "write_tty", esc, itoa(rd_pid), (char *)0);
  }


  done = wait(&status);
  cleanup(1);
}

typedef struct
{
    char *str;
    int  spd;
} vspeeds;

static vspeeds valid_speeds[] = 
{
   { "110",  B110  },
   { "300",  B300  },
   { "1200", B1200 },
   { "2400", B2400 },
   { "4800", B4800 },
   { "9600", B9600 },
   { (char *)NULL, 0 }
};

/*
 * given a desired speed string, if valid return its Bspeed value
 * else EOF
 */
int conv_speed(s)
register char *s;
{
    register vspeeds *p = &valid_speeds[0];
    
    for(; p->str != (char *)NULL; p++)
	if(strcmp(s, p->str) == 0)
	    return p->spd;
    return EOF;
}

#include <ctype.h>
#define ISOCTAL(x)	(('0' <= (x)) && ((x) <= '7'))
/*
 * convert given string to char
 *	string maybe a char, or octal digits
 */
int conv_esc(s)
register char *s;
{
    register int val = 0;
    
    if(!isdigit(*s))
	return *s; /* ! octal */
    
    /* convert octal digs */
    do
    {
	if(!ISOCTAL(*s))
	{
	    fprintf(stderr,"escape char must be character/octal digits\n");
	    exit(4);
	}
	val = (val << 3) + (*s++ - '0');
    } while(isdigit(*s));

    return val;
}

/*
 * condition lines
 */
void s_line(speed)
int speed;
{
    if(ioctl(con_fd, TIOCGETP, &con) == EOF)
    {
	perror("console");
	exit(5);
    }
    if(ioctl(line_fd, TIOCGETP, &line) == EOF)
    {
	perror("comm line");
	exit(6);
    }
    con_save = con;
    line_save = line;

    con.sg_flags &= ~ECHO;
    con.sg_flags |= RAW;
    
    line.sg_flags &= ~ECHO;
    line.sg_flags |= RAW;
    line.sg_ispeed = line.sg_ospeed = speed;
    
    if(ioctl(con_fd, TIOCSETP, &con) == EOF)
    {
	perror("console");
	exit(7);
    }
    if(ioctl(line_fd, TIOCSETP, &line) == EOF)
    {
	perror("comm line");
	exit(8);
    }
}

/*
 * reset lines
 */
void r_line()
{
    if( (ioctl(con_fd, TIOCSETP, &con_save)   == EOF) ||
        (ioctl(line_fd, TIOCSETP, &line_save) == EOF))
    {
	fprintf(stderr,"warning: could not reset a line\n");
    }
}    
