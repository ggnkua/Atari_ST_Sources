/*******************************************************************
 *  UTEXTRA.C                                                      *
 *                                                                 *
 * This file contains misc. functions needed for the BERMUDA       *
 * software. See LICENSE for information about distribution.       *
 *                                                                 *
 * Written by Jac Kersing                                          *
 *******************************************************************/

/*
#pragma warn -par
#pragma warn -sus
*/

#define MAILER		/* VP */
#include "pandora.h"

#if     TC
#include <dir.h>
#include <dos.h>
#include <sys\stat.h>
#endif

#if UNIX
#include <sys/dir.h>
#include <time.h>
#endif

#if STTC
#include <ext.h>
#include <tos.h>
#endif

#if	BWIN32
#include <process.h>
#include <time.h>
#include <io.h>
#endif

#define __PROTO__ 1
#include "utextra.pro"

extern int loglevel;
extern FILE *log;                       /* used for logging */

#define LP              *(unsigned long *)
#define IP              (unsigned long)*(unsigned int *)


void setstamp(name,buf) char *name,*buf;
{
#if     MEGAMAX
        int f;
        if((f=Fopen(name,2))<0) return;
        Fdatime(f,buf,1);
        Fclose(f);
#endif
}

#ifdef LINN
static void conv(getal,p,base,unsign,low)   /* Local function of doprint    */
int low;
#else
static void conv(getal,p,base,unsign)   /* Local function of doprint    */
#endif
unsigned long getal;                    /* convert number to ascii      */
char *p;
int base;
int unsign;
{
        char buf[10], *t = &buf[9], sign=getal&0x80000000L && !unsign;
        char ch;
        *t = 0;
        if (sign) getal = -((long)getal);
        do {
                ch=(char)(getal % base);
#ifdef LINN
                *--t = (ch < 10) ? ch+'0' : ch-10+(low?'a':'A');
#else
                *--t = (ch < 10) ? ch+'0' : ch-10+'A';
#endif
                getal /= base;
        }
        while (getal);
        if (sign) *--t='-';
        strcpy(p,t);
}

char *mon[12] =
{
        "Jan","Feb","Mar","Apr","May","Jun",
        "Jul","Aug","Sep","Oct","Nov","Dec"
};

static void cdecl iprint(outp,fmt,arg)        /* needed for internal print    */
#if __PROTO__
void (*outp)(char);
#else
void (*outp)();
#endif
char *fmt, *arg;
{
        doprint(outp, fmt, &arg);
}

void cdecl doprint(outp,fmt,arg)                   /* Print internal format        */
#if __PROTO__
void (*outp)(char);
#else
void (*outp)();
#endif
char *fmt, *arg;
{
        register int  width, precision, uselong;
        register char *p,*pos,left,dot,pad;
        char    buf[128];
        struct date d;
        struct time t;

        getdate(&d);
        gettime(&t);

 p = fmt-1;
 while (*++p) {
  if (*p=='%') {
   p++;
   uselong=width=precision=0;
   pad = ' ';
   if (*p=='%') { (*outp)('%'); continue; }
   left = *p=='-';
   if ( left ) p++;
   if ( *p=='0' ) pad='0';
   while ( isdigit(*p) ) width = width * 10 + *p++ - '0';
   dot = *p=='.';
   if ( dot ) {
    p++;
    while ( isdigit(*p) ) precision = precision * 10 + *p++ - '0';
   }
   uselong= *p=='l';
   if ( uselong ) p++;
   switch (*p) {
    case 'D' :  uselong++;
    case 'd' :  conv( uselong ? *(long *)arg : (long)*(int *)arg, buf, 10, 0, 0);
                arg += uselong ? sizeof(long) : sizeof(int);
                break;
    case 'U' :  uselong++;
    case 'u' :  conv( uselong ? LP arg : IP arg, buf, 10, 1, 0);
                arg += uselong ? sizeof(long) : sizeof(int);
                break;
    case 'X' :  uselong++;
    case 'x' :  conv( uselong ? LP arg : IP arg, buf, 0x10, 1, 0);
                arg += uselong ? sizeof(long) : sizeof(int);
                break;
#ifdef LINN
	/* Y is lowercase hexadecimal, for use while numbering outbound directory a la Binkley */
    case 'Y' :  uselong++;
    case 'y' :  conv( uselong ? LP arg : IP arg, buf, 0x10, 1, 1);
                arg += uselong ? sizeof(long) : sizeof(int);
                break;
#endif
    case 'O' :  uselong++;
    case 'o' :  conv( uselong ? LP arg : IP arg, buf, 8, 1, 0);
                arg += uselong ? sizeof(long) : sizeof(int);
                break;
    case 'Z' :  uselong++;
    case 'z' :  conv( uselong ? LP arg : IP arg, buf, 36, 1, 0);
                arg += uselong ? sizeof(long) : sizeof(int);
                break;
    case 'c' :  buf[0] = *(int *)arg;
                buf[1] = 0;
                arg += sizeof(int);             /* Char on stack == int */
                break;
    case 's' :  strncpy(buf,*(char **)arg,127);
                buf[127]=0;
                arg += sizeof(char *);
                if (dot) buf[precision] = 0;
                break;
   }
   width -= (int)strlen(buf);
   if (!left) while (width-->0) (*outp)(pad);   /* left padding         */
   pos=buf;
   while (*pos) (*outp)( *pos++ );              /* buffer               */
   if (left) while (width-->0) (*outp)(pad);    /* right padding        */
   continue;
  }
  if (*p=='$')
   switch (*++p) {
    case '$' : (*outp)('$'); break;
    case 't' : iprint(outp, "%02d:%02d:%02d", t.ti_hour, t.ti_min, t.ti_sec); break;
    case 'd' : iprint(outp, "%02d-%02d-%02d", d.da_day, d.da_mon, d.da_year-1900); break;
    case 'D' : iprint(outp, "%02d", d.da_day); break;
    case 'm' : iprint(outp, "%03s", mon[d.da_mon-1]); break;
#ifdef LINN	/* some more options used in pack.c */
    case 'T' : iprint(outp, "%02d:%02d", t.ti_hour, t.ti_min); break;
    case 'y' : iprint(outp, "%02d", d.da_year); break;
#endif
  }
  else (*outp)(*p);
 }
}

static char *prtstr[2];                 /* Must be array: Time/Date!    */
static int prtcnt = -1;                 /* points to current buffer     */

static void putSTR(c)                   /* Append char to string        */
char c;
{
        *prtstr[prtcnt]++ = c;
}

void cdecl fmprint(buf,fmt,args)              /* print format to string       */
char *buf, *fmt, *args;
{
        prtstr[++prtcnt] = buf;
        doprint(putSTR, fmt, args);
        *prtstr[prtcnt--] = 0;          /* add string terminator        */
}

void cdecl sprint(buf,fmt,args)               /* print format to string       */
char *buf, *fmt, *args;
{
        prtstr[++prtcnt] = buf;
        doprint(putSTR, fmt, &args);
        *prtstr[prtcnt--] = 0;          /* add string terminator        */
}

extern char progname[];

void cdecl message(level,fmt,arg)             /* display a message to screen */
int level;                              /* and to logfile */
char *fmt, *arg;
{
    char buf[255];

    sprint(buf,"%c $D $m $t %3.3s  ", *fmt,progname);
    fmprint(&buf[strlen(buf)], &fmt[1], &arg);

    if (level>=loglevel && log)
    {
        fprintf(log, "%s\n", buf);
        fflush(log);
    }

    print("%s\n",buf);
}

void cdecl clprint(fmt,arg)
char *fmt, *arg;
{
    char buf[255];

    fmprint(buf, fmt, &arg);

    if (loglevel<1 && log)
    {
        fprintf(log, "%s", buf);
        fflush(log);
    }

    print("%s",buf);
}

void cdecl print(fmt, args)
char *fmt, *args;
{
#if     MEGAMAX | MWC
        char buffer[255];

        fmprint(buffer, fmt, &args);
        fprintf(stdout,"%s", buffer);
        fflush(stdout);
#endif
#if     TC | STTC | UNIX | BWIN32
        vprintf(fmt, &args);
#endif
}

static char fname[20];  /* name of the file found by ffirst, fnext */
#if     MEGAMAX | MWC
static char tdta[80];
#endif
#if     TC | STTC
static  struct ffblk FF;
#endif
#if		BWIN32
static	struct _finddata_t FF;
static  long	win32fh;
#endif

#if	UNIX
/* from Ben Stuyts's port of Binkley */
char curr_filename[256],
     curr_pathname[256];
DIR *dirp = NULL;

#define FILENAMELEN 13

void unixize(char *dos, char *un)
{
	char *s, *d, ch;

	s = dos;	/* source */
	d = un;		/* dest */
	while(*s) {
		ch = *s++;
		switch(ch) {
			case '\\':
				*d++ = '/';		/* first change all \ into / */
				break;
			case '?':
				*d++ = '.';		/* any char as ? */
				break;
			case '.':
				*d++ = '\\';	/* dot as \. */
				*d++ = '.';
				break;
			case '*':
				*d++ = '.';		/* any seq of char as .* */
				*d++ = '*';
				break;
			default:
				if (isalpha(ch)) {
					/* we do pattern matching case insensitive */
					*d++ = '[';
					*d++ = toupper (ch);
					*d++ = tolower (ch);
					*d++ = ']';
				} else
					*d++ = ch;
				break;
		}
	}
	*d++ = '$';	/* end of line marker */
	*d = '\0';
}

void splitpath(char *path, char *file, char *dir)
{
	char *pos;

	file[0] = '\0';
	dir[0] = '\0';

	pos = rindex(path, '/');
	if (pos == 0)
		strcpy(file, path);
	else {
		*pos = '\0';
		strcpy(dir, path);
		pos++;
		strcpy(file, pos);
	}
}

/* checkfile returns TRUE when filename is correct */
int checkfile(struct direct *dp)
{
	char name[20];
	int res;

#ifdef RE_BSD
	re_comp(curr_filename);
#endif

	if(dp->d_namlen > FILENAMELEN)
		res = 0;
	else {
		strncpy(name, dp->d_name, dp->d_namlen);
		name[dp->d_namlen] = '\0';
#ifdef RE_BSD
		res = re_exec(name);
#else
		res = !recmp(curr_filename, name);
#endif
	}
	return res;
}
#endif	/* unix */

char *ffirst(name)
char *name;
{
#if     MEGAMAX | MWC
        char *hisdta= (char *)Fgetdta();        /* file info stored here */
        char *q,*p;                             /* used for copying */
        char *temp;

        Fsetdta(tdta);

        if (Fsfirst(name,7)!=-33l)
        {
                p=fname;
                for (q=(tdta+30);*q;) *p++=*q++;
                *p='\0';
                temp= fname;
        }
        else
                temp= NULL;

        Fsetdta(hisdta);
        return temp;
#endif
#if     TC | STTC
        if (findfirst(name, &FF, 0x27)==0)
        {
                strcpy(fname, FF.ff_name);
                return fname;
        }
        return NULL;
#endif
#if		UNIX
	char un[256];
	struct direct *dp;

	unixize(name, un);
	splitpath(name, un, curr_pathname);
	unixize (un, curr_filename);

	if(dirp)
		closedir(dirp); /* cleanup for previous usage */

	dirp = opendir(curr_pathname);
	if (!dirp)
		return NULL;
	for (dp = readdir(dirp); dp != NULL; dp = readdir(dirp))
		if (checkfile(dp))
			return dp->d_name;
	closedir(dirp);
	dirp = NULL;
	return NULL;
#endif
#if		BWIN32
        if ((win32fh=_findfirst(name, &FF))>=0)
        {
                strcpy(fname, FF.name);
                return fname;
        }
        return NULL;
#endif
}

char *fnext()
{
#if     MEGAMAX | MWC
        char *hisdta= (char *)Fgetdta();        /* file info stored here */
        char *q,*p;                             /* used for copying */
        char *temp;

        Fsetdta(tdta);

        if (Fsnext()==0l)
        {
                p=fname;
                for (q=(tdta+30);*q;) *p++=*q++;
                *p='\0';
                temp= fname;
        }
        else
                temp= NULL;

        Fsetdta(hisdta);
        return temp;
#endif
#if     TC | STTC
        if (findnext(&FF)==0)
        {
                strcpy(fname, FF.ff_name);
                return fname;
        }
        return NULL;
#endif
#if	UNIX
	struct direct *dp;

	if(!dirp)
		return NULL;

	for (dp = readdir(dirp); dp != NULL; dp = readdir(dirp))
		if (checkfile(dp))
			return dp->d_name;
	closedir(dirp);
	dirp = NULL;
	return NULL;
#endif
#if BWIN32
		if(win32fh<0)
			return NULL;
        if (_findnext(win32fh,&FF)==0)
        {
                strcpy(fname, FF.name);
                return fname;
        }
		_findclose(win32fh);
        return NULL;
#endif
}

static char *suffixes[8] = {
   "SU", "MO", "TU", "WE", "TH", "FR", "SA", NULL
};

#if     MEGAMAX || MSTRUPR
char *strupr(str)
char *str;
{
        char *p=str;
        while (*p)
        {
                if (isalpha(*p)) *p=toupper(*p);
                ++p;
        }
        return str;
}
#endif

#if MSTRDUP
char *strdup (char *s)
{
	char *t;
	t=malloc (strlen(s)+1);
	if (t != NULL)
		strcpy (t, s);
	return t;
}
#endif

#if UNIX | BWIN32
void getdate (struct date *date)
{
	struct tm *tim;
	time_t ze_time;

	time (&ze_time);
	tim = localtime (&ze_time);
	date->da_year = tim->tm_year;
	date->da_day = tim->tm_mday;
	date->da_mon = tim->tm_mon+1;
}

void gettime (struct time *timee)
{
	struct tm *tim;
	time_t ze_time;

	time (&ze_time);
	tim = localtime (&ze_time);
	timee->ti_min = tim->tm_min;
	timee->ti_hour = tim->tm_hour;
	timee->ti_hund = 0;
	timee->ti_sec = tim->tm_sec;
}
#endif

int is_arcmail (p, n)
char *p;
int n;
{
   int i;
   char c[128];

   if (!isdigit (p[n]))
      {
      return (0);
      }

   strcpy (c, p);
   strupr (c);

   for (i = n - 11; i < n - 3; i++)
      {
      if ((!isdigit(c[i])) && ((c[i] > 'F') || (c[i] < 'A')))
         return(0);
      }

   for (i = 0; i < 7; i++)
      {
      if (strnicmp (&c[n-2], suffixes[i], 2) == 0)
         break;
      }

   if (i >= 7)
      {
      return(0);
      }

   return (1);
}

int execute(prg,cmd)
char *prg, *cmd;
{
#if     TC | BWIN32
    char *arg[20], *p;
    int i;
#endif
    long result;

#if     MEGAMAX
    extern char *xenvistr;

    result= Pexec(0,prg,cmd,xenvistr);
    if (result < -30L)
#endif
#if     MWC | STTC
    extern char *environ;

    result= Pexec(0,prg,cmd,environ);
    if (result < -30L)
#endif
#if     TC | BWIN32
    i=2;
    arg[0]=prg;
    arg[1]=&cmd[1];
    for (p=&cmd[1]; *p; p++)
      if (isspace(*p))
      {
         *p='\0';
         arg[i++]=p+1;
         while (isspace( *(p+1) )) p++;
      }
    arg[i]=NULL;
    result = spawnv(0, prg, arg);
    if (result)
#endif
#if UNIX
    char tot[200];
    sprintf (tot, "%s %s", prg, cmd+1);	/* skip length of command */
    result = system(tot);
    if (result)
#endif
    {
        message(6,"!Program %s not found!", prg);
    }
    return (int)result;
}

int weekday(d) struct date *d;
{
        unsigned long df1;
        unsigned long day, month, year;

        day=d->da_day;
        month=d->da_mon;
        year=d->da_year;

        df1= 365l*year + 31L * (month-1) + day + 1;
        if (month>2)
        {
                df1 -= (4 * month + 23 ) / 10;
                ++year;
        }
        df1 += (year-1)/4;
        df1 -= ( 3 * ((year-1) / 100) + 1 ) / 4; /* friday == 1 */
        df1 += 4;

        return (int) (df1%7);
}

unsigned int ztoi(str,len)
char *str;
int len;
{
        unsigned int temp;

        temp=0;
        while (*str && len-- && isalnum(*str))
        {
                temp *= 36;
                temp += isdigit(*str) ? *str-'0' : toupper(*str)-'A'+10;
                ++str;
        }
        return temp;
}

int getadress(str, zone, net, node)
char *str;
int *net, *node, *zone;
{
        *zone= ztoi(str,2);
        *net = ztoi(str+2,3);
        *node= ztoi(str+5,3);
        return 0;
}

#if MC68000==1	/* changed from STTC vp */
unsigned inteli(x)
int x;
{
	return ( ((x << 8) & 0xFF00) | ((x >> 8) & 0x00FF) );
}
#endif
