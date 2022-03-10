/*
 *	BBS Level One - IO & Misc functions
 *	(LazyBBS Project)
 *
 *	Public domain: may be copied and sold freely
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>

#include "bbs.h"
#include "sysdep.h"
#include "miscio.h"
#include "msg.h"   /* proto for the_end() */
#include "login.h" /* proto for the_end() */

/* =================================================== GLOBAL VARIABLES */

/* max download */
static int maxdownload=D_MAXDOWN;

int get_maxdown(void )
{
	return maxdownload;
}

void set_maxdown(int m)
{
	maxdownload=m;
}

int get_newdown(void )
{
	return (((maxdownload/6)/10)*10); /* 1/6 max, nearest decade */
}

/* endsession: end of session time */
static clock_t endsession=0;

clock_t get_endsession(void)
{
	return endsession;
}

void set_endsession(int minutes)
{
	endsession=clock()+(minutes*60*CLK_TCK);
}

/* netarea: netmail area */
static char netarea_ptr[BBSSTR];/* used by display_login and main */

char *get_netarea(void)
{
	return (char *)netarea_ptr;	
}

void set_netarea(char *net)
{
	strcpy(netarea_ptr,net);
}

/* god: sysop with privileges */
int godflag=0;

/* Set god (sysop) status */

void setgod(void )
{
	godflag++;
}

/* Get god flag */

int isgod(void )
{
	return godflag;
}

/* tempfile: return temporary file name (*must* be the same each time) */
static char ntempfile[BBSSTR];

char *tempfile(void )
{
	sprintf(ntempfile,"lbbs.%d",getpid());
	return ntempfile;
}

/* ============================================================== DATE */

/*
 *	today: returns the nb of days since 1/1/70
 */
 
int today(void)
{
	long t;
	t=(long)timenix(NULL)/86400;
	return (int)t;
}

/* ==================================================== EMERGENCY EXIT */

void the_end()
{
	logline(3,"Exiting BBS");
	close_areas();
	close_login();
	close_the_log();
	hangup();
	exit(0);
}

/* ==================================================== INPUT ROUTINES */

int dowatchcarrier=0;
int passwd_echo=0;

/*
 *	getstring: input a string from user of mxlenght==BBSSTR
 */

int getpasswdstring(char *str)
{
	int ret;
	
	passwd_echo=1; /* bahhhhhhh, awful :-) */
	ret=getstring(str);
	passwd_echo=0;
	return ret;
}

int getstring(char *s)
{
	int pos,key;

	sysdep_flushin();
	fflush(stdout);
	
	pos=0;
	while(1)
	{
		key=getkey();
	
		if(key<0)
		{
			*s=0;
			return BBSFAIL;
		}
		else if(key==10 || key==13) /* return cr|lf */
		{
			s[pos++]=0;
			return BBSOK;
		}
		else if(key==8)	/* backspace */
		{
			if(pos>0)
			{
				pos--;
				out_char(' '); out_char(8);/* delete char */
				if(ECHOCHAR) out_char(key);
			}
		}	
		else if(isokchar(key) && (pos<BBSSTR-2))
		{
			s[pos++]=(char) key;
			if(ECHOCHAR) out_char(key);
		}
		else
			out_char(7); /* bip */
	}
}

int isokchar(int c)
{
	if(c>=0x20 && c<127)
		return 1;
	return 0;
}

void enable_watch(void)
{
	dowatchcarrier++;
}

int carrier(void )
{
	if(!dowatchcarrier)
		return 1;
	return !(sysdep_carrier());	
}

int getkey(void) /* get a key */
{
	unsigned char mychar;
	int n;
	clock_t end;
	
	fflush(stdout);
	
	end=clock()+(CLK_TCK*S_TIMEOUT);
	
	do {
		n=sysdep_getchar(&mychar);
	} while(n==BBSFAIL && clock()<end && carrier());
	
	mychar&=0x7F; /* strip 8th bit */
	
	if(n==BBSFAIL)
	{
		out_printf("Timeout or carrier loss!!!\n");
		logline(1,"User didn't react / carrier lost");
		the_end();
	}
	
	if(clock()>get_endsession())
	{
		out_printf("End of session time, bye!");
		logline(1,"End of session time");
		the_end(); /* => hangup */
	}
	
	if(!carrier())
	{
		logline(1,"Lost carrier");
		the_end();
	}
	
	if(mychar==4)
	{
		logline(1,"User quit with control-d");
		the_end();
	}
	
#ifdef DO_ECHO_MYSELF
	/* don't echo ESC and password chars */
	if(!passwd_echo && mychar!=0x1B)
		out_char(mychar);
	else
		out_char('.');
#endif

	return (int) mychar;
}

void hangup(void )
{
	if(dowatchcarrier)
		sysdep_hangup();
}

/* ================================================== OUTPUT ROUTINES */

void out_printf(char *line, ...)
{
	char	temp[1000];
	va_list param;
	
	/* process */
	va_start(param, line);
	vsprintf(temp, line, param);
	va_end(param);
	
	out_string(temp);
}

void out_string(unsigned char *s)
{
	while(*s)
	{
		out_char(*s);
		s++;
	}
}

void out_char(unsigned char s)
{
	if(s=='\n')	/* \n to crlf */
		sysdep_putchar('\r');

	sysdep_putchar(s);
}
 
/* =================================================== STRING PARSING */

/*
 * Insert one space at the beginning of a string
 */
 
void strspins(char *str)
{
	int maxlen,i;
	
	maxlen=strlen(str);
	
	for(i=maxlen+1;i>=0;i--)
		str[i+1]=str[i];
	str[0]=' ';
}

/*
 *	file function that makes a path from ambigous string
 */
 
void addslash(char *s)
{
	if(*s)
	{
		if(s[strlen(s)-1]!=SYSSEPAR)
			strcat(s,SYSSTRSEPAR);
	}
}

/* 
 *	findword: put in _copy_ the start of _string_ before 0 or '@' 
 *
 *	returns NULL if endofstr or next pointer
 */
 
char *findword(char *copy, char *string)
{
	int len=0; /* nb of chars to copy */
	
	if(!string)
		return NULL;
		
	while(string[len])
	{
		if(string[len]==BBSSEPAR) 
			break;
		len++;
	}
	
	if(len<BBSSTR)
	{
		strncpy(copy,string,len);
		copy[len]=0;
	}
	else
		strcpy(copy,"string too long");
	
	if(string[len]==0)
		return NULL;
	else
		return string+len+1;
}

/*
 *	iscomment: is this char a comment?
 */
 
int iscomment(char c)
{
	switch(c)
	{
		case '#':
		case ';':
		return 1;
	}
	return 0;
}

/*
 *	strcln: remove a char from string
 */

void strcln(char *string, char c)
{
	char *s=string;
	while(*s)
	{
		if((c!=-1 && *s==c) || (c==-1 && *s<0x20 && *s>0))
			strcpy(s,s+1);
		s++;
	}
}

/* find next string format "plouf <tab>tralala ; comment */

char *nextstr(char *str)
{
	char* s=str;
	
	while((*s!='\0') && (*s!=' ') && (*s!='\x09'))
		s++;
		
	if(*s=='\0')
		return NULL;

	while((*s==' ') || (*s=='\x09'))
		s++;
	
	if((*s=='\0') || (*s==';'))
		return NULL;
		
	return s;
}

/* copy string until space */

void strspacecpy(char *dest, char *srce)
{
	int i=0,j=0;
	
	while((srce[i]!='\0') && (srce[i]!=' ') && (srce[i]!='\x09') && (i<BBSSTR))
	{
/* fixme: unsigned  char ? */
		if(srce[i]>' ')
		{
			dest[j]=srce[i];
			j++;
		}
		i++;
	} 
	dest[i]='\0';
}

/* ================================================= LOG FILE FUNCTIONS */

FILE *logfile=NULL;
int loglevel=0;

/* logline: Log a line in the logfile and output to screen */

void logline (int level, char *line, ...)
{
	time_t	timer;
	char	temp[100], out[100],tdate[20];
	va_list param;
	struct tm *tim;
	
	char ls[]=" -+*=!";
	
	if(!logfile)
		return;	/* error */
		
	/* process */
	va_start(param, line);
	vsprintf(temp, line, param);
	va_end(param);
	time (&timer);
	tim = localtime (&timer);
	strftime (tdate, 20, "%d %b %H:%M:%S", tim);
	sprintf (out, "%c %s LBBS %s\n", ls[level], tdate, temp);

	/* log to file */
	fputs(out,logfile);
#ifdef DEBUG
	fflush(logfile);
#endif
}
 
/* openlog: create logfile */

int open_the_log(char *nm, int level)
{
	loglevel=level;
	logfile=fopen(nm,"a");
	if(logfile)
		return BBSOK;
	
	printf("\0x7\0x7Can't open logfile!\n");
	return BBSFAIL;
}

/* closelog: close logfile */

void close_the_log(void )
{
	if(logfile)
		fclose(logfile);
}
