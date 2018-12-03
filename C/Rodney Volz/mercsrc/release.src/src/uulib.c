/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [uulib.c]
 */

#include "define.h"
overlay "uulibrary"

#ifndef MWC
extern char *_base;
#else
#define _base (BP)
#endif


char quiet = 0;
char mint = 0;



#ifndef MWC
static char *findenv(var)
register char *var;
/*
 *	INTERNAL FUNCTION.  This function attempts to locate <var> in
 *	the environment.  If <var> is not found, NULL is returned.  If
 *	the environment is NULL, NULL is returned.  If <var> is found,
 *	a pointer to the beginning of <var> in the environment is returned.
 *	BOTH MS-DOS AND TOS ENVIRONMENT FORMATS ARE ACCOMODATED.
 */
{
	register char *p;
	register int len;
	char *_envp;

	_envp = *(char **)(_base + 44l);
	
	p = _envp;

	len = strlen(var);
	while(*p)
	{
		if((p[len] == '=') && !strncmp(p, var, len))
			return(p);
		while(*p++);
	}
	return(NULL);
}


char *getenv(var)
char *var;
{
	register char *p, *q;
	register int len;

	len = strlen(var);

	if(p = findenv(var))
	{
		p += (len + 1);
		if(*p == '\0')		/* TOS env format or empty value */
		{
			q = p+1;
			if(*q == '\0')		/* empty value + end of env */
				return(p);
			while(*q && (*q != '='))
				++q;
			if(*q)			/* empty value */
				return(p);
			else			/* TOS env format */
				return(p+1);
			}
		}
	return(p);
}

#endif MWC





setquiet()
{
	extern char quiet;
	char *cp,c;

	if (!(cp = getenv("QUIET")))
		return(0);

	c = toupper(*cp);
	
	quiet = (c == 'T' || c == '1' || c == 'o') ? 1 : 0;
}


lower(s)		/* Zeichenkette LOWERn */
char s[];
{
#if 1
	int i;
	char c;
	i = 0;
	
	while (s[i] != 0)
	{
		if ((s[i] > 64) && (s[i] < 91))
		{
			c = s[i];
			s[i] = c + 32;
		}
		++i;
	}
#else
	while (*s)
		*s = tolower(*s++);	/* Klappt aus irgendeinem Grund nicht. */
#endif
}

upper(s)		/* Zeichenkette UPPERn */
char s[];
{
#if 1
	int i;
	char c;

	i = 0;

	while (s[i] != '\0')
	{
		if ((s[i] > 96) && (s[i] < 123))
		{
			c = s[i];
			s[i] = c - 32;
		}
		++i;
	}
#else
	while (*s)
		*s = toupper(*s++);
#endif
}


long seek(handl,as)	/* Pointer in der Datei setzen */
int handl;
long as;
{
	return((long)gemdos(0x42,(unsigned long)as,handl,0));
}

log(txt,file)
char txt[],file[];
{
	static char logdir[LLEN],l = 0;
	static char s[LLEN],s2[LLEN];
	int fp;

	if (!l)
	{    
		getconf(5,logdir);
		sys_impdirn(logdir);
		++l;
	}
		
	sprintf(s,"%s%s",logdir,file);

	if (exist(s) == TRUE)
		fp = open(s,4);
	else
		fp = open(s,1);

	if (fp <= 0)
	{
		pen(ROT);
		send("Error opening ");
		send(logdir);
		send(" as output.");
		cr(1);
		pen(WEISS);
		exit(-1);
	}
	
	
	sd(s2);
	
	sprintf(s,"%s %s",s2,txt);
	putline(fp,s);
	close(fp);
}



long sys_fread(handle,cnt,buffer)	/* Read from file */
int handle;
long cnt;
char *buffer;
{
#if 0
	long gemdos();
#endif
	return(gemdos(0x3f,handle,cnt,buffer));
}


sys_fwrite(hande,cnt,buffer)	/* Write to file */
int hande;
long cnt;
char *buffer;
{
	gemdos(0x40,hande,cnt,buffer);
}


char *ownmalloc(anzahl)
long anzahl;
{
	long l;
#ifndef MWC
	long gemdos();
#endif
	
	l = gemdos((int)0x48,(long)anzahl);
	if (l <= 0l)
	{
		send("\033E");
		cr(2);
		pen(ROT);
		send("*** MERCURY UUCP:");
		cr(2);
		send("*** Out of internal memory. ***");
		cr(2);
		send("*** SYSTEM HALTED.");
		cr(2);
		pen(WEISS);
		send("Failed allocating ");
		sendl((long)anzahl);
		send(" bytes of memory.");
		cr(1);
		send("You may try foldr100.prg to fix up the problem.");
		cr(1);
		exit(2);
	}
	return((char *)l);
}



_getinfo(file,nr,string,offset)
char *file,*string;
int nr,offset;
{
	int inh,i;
	char s[LLEN],*cp;
	static char *path[] =
	{
				"\\etc\\",
				"\\mercury\\",
				"C:\\etc\\",
				"C:\\mercury\\",
				"D:\\etc\\",
				"D:\\mercury\\",
				"E:\\etc\\",
				"E:\\mercury\\",
#if 0	/* Genug der Sucherei... */
				"F:\\etc\\",
				"F:\\mercury\\",
				"G:\\etc\\",
				"G:\\mercury\\",
				"H:\\etc\\",
				"H:\\mercury\\",
				"I:\\etc\\",
				"I:\\mercury\\",
#endif
				"A:\\etc\\",
				"A:\\mercury\\",
				""
	};


	/* See, if we find our parameters in the environment */
	if (offset && ((cp = getenv(envsearch[offset + nr - 1])) != NULL))
	{
		strcpy(cp,string);
		return(0);
	}


	i = 0;
	while (*path[i])
	{
		strcpy(path[i++],s);
		stradd(file,s);
	 	if ((inh = open(s,2)) > 0)
			break;
	}
	
	if (inh < 0)
	{
		pen(ROT);
		send(file);
		send(": Not found.");
		cr(1);
		printf("Entry %d may alternatively be set by\n",nr);
		printf("environment-variable '%s'.\n\n",envsearch[offset + nr - 1]);

		send(file);
		send(" may be placed in an \\etc or \\mercury folder");
		cr(1);
		send("of drive C:, D:, E: or A:");
		cr(1);
		pen(WEISS);

		exit(2);
	}

	i = 0;
	while(getline(inh,s) != -1)
	{
		if (val(s) == nr)
		{
			strcpys(s,string,linstr(s,'"') + 1,rinstr(s,'"') - 1);
			++i;
			break;
		}
	}
	close(inh);

	if (!i)
	{
		pen(ROT);

		printf("Failed looking for entry %d in %s.\n",nr,file);
		printf("Entry %d may alternatively be set by\n",nr);
		printf("environment-variable '%s'.\n\n",envsearch[offset + nr - 1]);
		pen(WEISS);

		exit(2);
	}
	
}


dwait()
{
}




deb()
{
}



lineput(handle,is,flag)
int handle,flag;
char *is;
{
	static unsigned char ees[LLEN];
	long c;
	int n;
	
	strcpy(is,ees);
	n = strlen(ees);

	if (flag)
		ees[n++] = 13;		/* CR anhaengen */

	ees[n++] = 10;		/* LF anhaengen */
	ees[n] = '\0';		/* String abschliessen mit '\0' */
	c = n;
	
	sys_fwrite(handle,c,ees);		/* Schreiben!! */
}






int sys_rnd(n)	/* Zufallszahl von 0..n erzeugen */
int n;
{
	long c,xbios();
	int i;

	c = xbios(17);	/* Xbios-Random */
	
	i = c % n;	/* c mod n muesste eine Zahl zwischen 0 und n */
			/* als Rest ergeben. :-) */
	return(i);
}



sys_impdirn(s)	/* Improve directory-name (evt. append '\') */
unsigned char s[];
{
	int i;
	i = strlen(s) - 1;
	
	if (i == -1)
	{
		strcpy("\\",s);
		return;
	}
	
	if (s[i++] != '\\')
	{
		s[i++] = '\\';
		s[i++] = '\0';
	}
}






sys_fcopy(f1,f2)		/* System-Filecopy */
char f1[],f2[];
{
	long len,anz;
	char *buffer;
	char s[LLEN];
	int inh,outh;

	
	buffer = (char *)malloc(4100l);
		
	anz = 4096l;
	
	inh = open(f1,2);	/* Open in Read-only */
	if (inh < 0)
	{
		cr(1);
		send("Error in sys_fcopy ");
		send(VERSION);
		cr(1);
		send("Couldn't open: ");
		send(f2);
		send(" as input.");
		cr(1);
		send("Error: ");
		sendd(inh);
		cr(1);
		return(-1);
	}
		

	outh = open(f2,1);	/* Open out create */
	if (outh <= 0)
	{
		cr(1);
		send("Error in sys_fcopy ");
		send(VERSION);
		cr(1);
		send("Couldn't open: ");
		send(f2);
		send(" for output.");
		cr(1);
		send("Error: ");
		sendd(outh);
		cr(1);
		gemerror(outh);
		return(-1);
		close(inh);
	}	

	len = anz;
	while (len >= anz)
	{
		len = (long)sys_fread(inh,anz,buffer);
		sys_fwrite(outh,len,buffer);
	}
	
	close(inh);
	close(outh);

	sprintf(s,"sys_fcopy(%s,%s)",f1,f2);
	log(s,"system");

	mfree(buffer);
}


sys_remove(s)	/* <s> l”schen */
char *s;
{
	int i;
	
	i = gemdos(65,s);
	return(i);
}


sys_rename(a,b)	/* Rename files */
char *a,*b;
{
	return(gemdos(86,0,a,b));
}



#if 0
sys_rmdir(s)	/* Ordner <s> l”schen */
char *s;
{
	return(gemdos(58,s));
}
#else
#define sys_rmdir(s)	gemdos(58,s)
#endif


sys_mkdir(s)	/* Ordner <s> machen */
char *s;
{
	char s2[LLEN];
	int i;

	i = gemdos(57,s);

	sprintf(s2,"mkdir: %s",s);
	log(s2,"system");
	return(i);
}

#define sys_getatr(fn)	gemdos(0x43,fn,0,7);

sys_chmod(fn,m)	/* Attribut der Datei <fn> setzen */
char m;
char fn[];
{
	return(gemdos(0x43,fn,1,m));
}


sys_chdir(s)	/* Directory <s> aufrufen */
char s[];
{
	return(gemdos(59,s));
}
	


sys_pwd(s)	/* Pfad in <s> zurueckgeben */
char s[];
{
	gemdos(71,s,0);
}

stradd(s1,s2)	/* s1 an s2 anhaengen */
char s1[],s2[];
{
	int i,n;
	i = 0;
	n = strlen((char *)s2);
	
	while (s1[i] != '\0')
	{
		s2[n] = s1[i];
		++n;
		++i;
	}
	s2[n] = '\0';
}


linstr(s,arg)	/* arg in s suchen (von links her) */
char s[],arg;
{
	int i;
	
	i = 0;
	while (s[i] != 0)
	{
		if (s[i] == arg)
			return(i);
		
		++i;
	}
	return(-1);
}


rinstr(s,arg)	/* arg in s suchen (von rechts her) */
char s[],arg;
{
	int i;
	
	i = strlen(s);
	while (i >= 0)
	{
		if (s[i] == arg)
			return(i);
		
		--i;
	}
	return(-1);
}


snext()	/* Search next */
{
	int i;
	i = gemdos(79);				/* Snext */
	return(i);		/* evtl. Fehlermeldung zurckgeben */
}


struct dta *getdta()
{
	struct dta *gemdos();
	
	return((struct dta *)gemdos(47));
}



dtaxtr(name,laenge,attribut)	/* Extract Disk Transfer Area (DTA) */
char *name;
long *laenge;
char *attribut;
{
	struct dta *d;

	d = (struct dta *)getdta();
	strcpys((char *)d->fname,(char *)name,0,13);
	lower((char *)name);
	*laenge = (long)(d->length);
	*attribut = (long)(d->atr);
}

long fsize(s)
char *s;
{
	int i;
	char name[LLEN];
	long laenge;
	char atr;
	
	i = sfirst(s);

	if (i == 0)
	{
		dtaxtr(name,&laenge,&atr);
	}

	return(laenge);
}


gemerror(i)	/* Eventuelle Errors anzeigen */
{
	char dd[LLEN];
	
	dd[0] = '\0';
	
	switch(i) {
				case -32:
				{
					strcpy("Invalid function number.",dd);
					break;
				}
				
				case -33:
				{
					strcpy("File not found.",dd);
					break;
				}
				
				case -34:
				{
					strcpy("Directory not found.",dd);
					break;
				}
				
				case -35:
				{
					strcpy("Too many files opened.",dd);
					break;
				}
				
				case -36:
				{
					strcpy("Invalid attempt.",dd);
					break;
				}
				
				case -37:
				{
					strcpy("No more handles free.",dd);
					break;
				}
				
				case -39:
				{
					strcpy("Memory full.",dd);
					break;
				}
				
				case -46:
				{
					strcpy("Invalid drive.",dd);
					break;
				}
		}
	
	if (dd[0] != 0)
	{
		send(dd);
		cr(1);
	}
}


reverse(s)	/* Zeichenkette umkehren */
char s[];	/* funktioniert einwandfrei. */
{
	int c,i,j;
	for (i = 0, j = strlen(s)-1; i < j; i++, j--)
	{
		c = s[i];
		s[i] = s[j];
		s[j] = c;
	}
}



strcpys(s1,s2,nn1,nn2)	/* nn1. bis zur nn2. Pos. (incl.) kopieren */
char s1[],s2[];			/* 100%-ig OK! */
int nn1,nn2;
{
	int p1,p2,ns1,ns2;
	ns1 = nn1;
	ns2 = nn2;
	
	p1 = nn1;	/* an der Stelle nn1 beginnen, */
	p2 = 0;		/* und bei Position 0. beginnen zu schreiben. */
	
	while (s1[p1] && (p1 <= nn2))
	{
		s2[p2] = s1[p1];
		++p1;
		++p2;
	}
	s2[p2] = '\0';
}




strcpy(a,b)		/* Zeichenkette kopieren */
char *a,*b;		/* funktioniert einwandfrei. */
{	
	while (*a)
		*b++ = *a++;
	
	*b = '\0';
}



strcmp(a,b)		/* Zeichenketten vergleichen */
char *a,*b;
{
	int len,i;

	len = strlen(a);

	if (strlen(b) != len)
		return(FALSE);
	
	i = 0;
	while ((*a++ == *b++) && (i < len))
		++i;

	return((i == len) ? TRUE : FALSE);
}




cr(a)		/* Carriage Return u. LF ausgeben */
int a;
{
	int n;

	n = a;
	while (n--)
	{
		out(13);
		out(10);
	}
}



sendd(i)	/* Integer ausgeben */
int i;
{
	char c[10];
	str(i,c);
	send(c);
}


sendl(i)	/* Long ausgeben */
long i;
{
	char c[20];
	strl((long)i,c);
	send(c);
}


char inp()	/* Zeichen holen */
{
	return(get(0));
}

instat()	/* schauen, ob ein Zeichen da ist */
{
	if (bios(1,2) != 0)
		return(TRUE);
	else
		return(FALSE);
}



rec(p)	/* Zeichenkette von der IO holen */
char p[];
{
	char a;					/* Zwischenvariable */
	int i,n;
	
	n = 0;
	a = 0;
	while (1)
	{
		if ((a = inp()) == -1)
			return(-1);
		
		if ((a == 13) || (a == 10))
			break;			/* Bei Return abbrechen */

		
		if ((a == 127) || (a == 8))
		{
			if (n > 0)
				--n;
		}
		else
			p[n++] = a;
	}
	
	p[n] = '\0';	/* Ende der Zeichenkette markieren */
}

send(s)		/* Zeichenkette mit Hilfe von "OUT" senden */
char *s;
{
	while (*s)
		out(*s++);
}



strmul(s,n,s2)	/* 's' <n> mal in 's2' schreiben. */
char s,s2[];
int n;
{
	int i;
	i = 0;
	
	while (i < n)
		s2[i++] = s;

	s2[i] = '\0';
}


strlen(s)	/* Laenge einer Zeichenkette berechnen */
char *s;
{
	int i = 0;

	while (*s++)
		++i;

	return(i);
}



mfree(storage)			/* Speicher zurckgeben */
long storage;
{
	gemdos(73,storage);
}



pause(n)	/* n Sekunden warten */
int n;
{
	int s;
	s = sec();
	s += n;
	while (sec() < s)
		;
}
	

unspace(s)
char s[];
{
	char d[LLEN],d2[LLEN];

	while (linstr(s,' ') != -1)
	{
		strcpys(s,d,0,linstr(s,' ') - 1);
		strcpys(s,d2,linstr(s,' ') + 1,strlen(s));
		strcpy(d,s);
		stradd(d2,s);
	}
}

open(fna,modus)	/* File zum lesen oder schreiben ”ffnen */
int modus;
char fna[];
{
	int handle,n,i;
	static char atr,du[LLEN],fname[LLEN];
	long dummy;

	strcpy((char *)fna,(char *)fname);

	switch(modus)
	{
	case 1:
	{
		handle = gemdos(0x3c,(char *)fname,(int)0);	/* Gemdos 'FCREATE' */
		break;
	}
	
	case 2:
	{
		handle = gemdos(0x3d,(char *)fname,0);	/* Gemdos 'FOPEN' R/O */
		break;
	}
	
	case 3:
	{
		handle = gemdos(0x3d,(char *)fname,2);	/* Gemdos 'FOPEN' R/W */
		break;
	}
	
	case 4:
	{
		if (exist(fname))
			;

		dtaxtr(du,&dummy,&atr);			/* Dateilaenge holen */
		handle = gemdos(0x3d,(char *)fname,2);	/* s. o. */

		if (handle > 0)
			seek(handle,(long)dummy);
	}
	}

#if 0
	sendd(handle);
	cr(1);
#endif
	
	return(handle);
}




long rseek(handle,rel)	/* Pointer relativ verschieben */
int handle;
long rel;
{
	return(gemdos(0x42,(long)rel,handle,1));
}


close(handle)	/* Datei schliessen */
int handle;
{
	return(gemdos(0x3e,handle));
}


get(handy)	/* einzelnes Zeichen von der Floppy lesen */
int handy;
{
	long rd;
	char c[2];
	char i;
	
	rd = gemdos(0x3f,handy,1l,c);	/* Die Parameterfolge ist OK. */
	
	if (rd <= 0l)
		return(-1);
	else
		return(c[0]);
	
}




put(handle,c)	/* einzelnes Zeichen auf Diskette schreiben */
int handle;
char c;
{
	gemdos(0x40,handle,1l,&c);
}


unsigned long pos(handle)
int handle;
{
#ifndef MWC
	unsigned long gemdos();
#endif
	return((long)gemdos(0x42,(long)0l,handle,1));
}



convert(s)	/* Dummy! :-) */
char s[];
{}


curs()
{
#if	FLASH
	xbios(21,1);
	xbios(21,4,60);
	xbios(21,2);
#else
	xbios(21,1);
	xbios(21,3);
#endif
}



sys_getdate()
{
	return(gemdos(0x2a));
}

char *sys_dayname(s)	/* Namen des Tages liefern */
char *s;
{
	static char *d[] = { "Sun","Mon","Tue","Wed","Thu","Fri","Sat" };
	if (s != (char *)0l)
		strcpy((char *)d[sys_dayweek()],s);
	else
		return((char *)d[sys_daywee()]);
}

sys_year()	/* Jahr in der Form '1989' */
{
	return(((sys_getdate() & (unsigned long)(65024)) / 512) + 1980);
}


sys_month()	/* Monat im Jahr */
{
	return((sys_getdate() & 480) / 32);
}

sys_dayofmonth()	/* Tag des Monats, also z. B. der 16. */
{
	return(sys_getdate() & 31);
}

sys_monthname(s)	/* Monatsnamen zurueckgeben */
char s[];
{
	static char *d[] =
			{
				"Jan","Feb",
				"Mar","Apr",
				"May","Jun",
				"Jul","Aug",
				"Sep","Oct",
				"Nov","Dec"
			};
	
	strcpy(d[sys_month() - 1],s);
}

sys_time(s)	/* Zeit in der Form '00:17:37' */
char s[];
{
#if 1
	char s2[LLEN],s3[LLEN];
	str(hour(),s2);
	strcpy("",s);
	if(s2[1] == '\0')
		strcpy("0",s);
	stradd(s2,s);
	stradd(":",s);
	
	str(min(),s2);
	if(s2[1] == '\0')
		stradd("0",s);
	stradd(s2,s);
	stradd(":",s);
	str(sec(),s2);
	if(s2[1] == '\0')
		stradd("0",s);
	stradd(s2,s);
#else
	time_t tt;
	struct tm *tim;

	time(&tt);
	tim = localtime(&tt);

	sprintf(s,"%02d:%02d:%02d",tim->tm_hour,tim->tm_min,tim->tm_sec);
#endif
}


#ifndef TIMEFUNCTIONS

sec()		/* Sekunden holen */
{
	int t;
	t = sys_gettime();
	return(2 * (t & 31));	/* Sekunden maskieren (unterste 5 Bit) */
}



min()		/* Minuten holen */
{
	int t;
	t = sys_gettime() / 32;
	return(t & 63);
}



hour()		/* Stunden holen */
{
	return((int)(((long)gemdos(44) & 63488l) / 2048));
}

#else

sec()		/* Sekunden holen */
{
	time_t tt;
	struct tm *tim;

	time(&tt);
	tim = localtime(&tt);

	return(tim->tm_sec);
}


min()		/* Minuten holen */
{
	time_t tt;
	struct tm *tim;

	time(&tt);
	tim = localtime(&tt);

	return(tim->tm_min);
}



hour()		/* Stunden holen */
{
	time_t tt;
	struct tm *tim;

	time(&tt);
	tim = localtime(&tt);

	return(tim->tm_hour);
}

#endif

sys_gettime()		/* Systemuhr auslesen */
{
	return(gemdos(44));
}



long timer()	/* System-Timer holen */
{
	long _timer();
	long xbios();

	return((long)xbios(38,_timer));
}


long _timer()
{
	return(*((long *)0x4ba));
}




sd(o)	/* Standard-Datum u. Zeit; z. B.: Fri Nov 10 1989 */
char o[];
{
	char s[30];
	strcpy("",s);
	strcpy("",o);

	sys_dayname(s);
	stradd(s,o);
	stradd(" ",o);
	
	sys_monthname(s);
	stradd(s,o);
	stradd(" ",o);
	
	str(sys_dayofmonth(),s);
	stradd(s,o);
	stradd(" ",o);
	
	sys_time(s);
	stradd(s,o);
	stradd(" ",o);
	
	str(sys_year(),s);
	stradd(s,o);
}



struct passwd *getpwent(line)
char *line;
{
	char *cp1,*cp2,*cp3;
	static struct passwd tmp;

	cp1 = line;

	cp2 = strchr(cp1,':');
	*cp2 = '\0';
	strcpy(cp1,tmp.pw_name);
#if DEBUG
	printf("%s\n",cp1);
#endif

	cp1 = ++cp2;
	cp2 = strchr(cp1,':');
	*cp2 = '\0';
	strcpy(cp1,tmp.pw_passwd);
#if DEBUG
	printf("%s\n",cp1);
#endif

	cp1 = ++cp2;
	cp2 = strchr(cp1,':');
	*cp2 = '\0';
	tmp.pw_uid = atoi(cp1);
#if DEBUG
	printf("%s\n",cp1);
#endif

	cp1 = ++cp2;
	cp2 = strchr(cp1,':');
	*cp2 = '\0';
	tmp.pw_gid = atoi(cp1);
#if DEBUG
	printf("%s\n",cp1);
#endif

	cp1 = ++cp2;
	cp2 = strchr(cp1,':');
	*cp2 = '\0';
	strcpy(cp1,tmp.pw_gecos);
#if DEBUG
	printf("%s\n",cp1);
#endif

	cp1 = ++cp2;
	cp2 = strchr(cp1,':');
	/* Allow 'D:\...\...\...\' */
	if ((int)(cp2 - cp1) == 1)
	{
		cp3 = ++cp2;
		cp2 = strchr(cp3,':');
	}
	*cp2 = '\0';
	strcpy(cp1,tmp.pw_dir);
#if DEBUG
	printf("%s\n",cp1);
#endif

	cp1 = ++cp2;
	for (cp3 = cp1; *cp3; cp3++)
	{
		if (*cp3 == 13 || *cp3 == 10)
		{
			*cp3 = '\0';
			break;
		}
	}

	strcpy(cp1,tmp.pw_shell);
#if DEBUG
	printf("%s\n",cp1);
#endif

	return(&tmp);
}



sys_getuid(name,home,fullname,shell,pw)
char name[],home[],fullname[],shell[],pw[];
{
	int inh;
	char pwd[LLEN],s[LLEN];
	struct passwd *tmp;

	getconf(9,pwd);

	inh = open(pwd,2);
	while (getline(inh,s) != -1)
	{
#if DEBUG
		printf("Read: %s\n",s);
#endif
		tmp = getpwent(s);
		if (strcmp(tmp->pw_name,name) == TRUE)
		{
#if DEBUG
			printf("Found user %s!\n",name);
#endif
			strcpy(tmp->pw_dir,home);
			strcpy(tmp->pw_gecos,fullname);
			strcpy(tmp->pw_shell,shell);
			strcpy(tmp->pw_passwd,pw);
			return(0);
		}
	}
	close(inh);

	return(-1);
}



noenv_exec(file,tail)	/* externes Programm aufrufen */
char file[],tail[];
{
	char l;
	char p[LLEN],s[LLEN];

	strcpy(" ",p);
	stradd(tail,p);
	p[0] = (char)127;

	return(gemdos(0x4b,0,(char *)file,(char *)p,"\0\0\0"));
}



sys_exec(file,tail)	/* externes Programm aufrufen */
char file[],tail[];
{
	char l;
	char p[LLEN];
	char *_envp;

	_envp = *(char **)(_base + 44l);

	sprintf(p," %s",tail);
	p[0] = (char)127;
#if 0
	return(gemdos(0x4b,0,(char *)file,(char *)p,(char *)_envp));
#else
	return(gemdos(0x4b,0,(char *)file,(char *)p,"\0\0\0"));
#endif
}


out(a)		/* Zeichen an IO-Port ausgeben */
char a;
{
#ifndef MWC
	if (a != 0)
		put(1,a);	/* Stdout verwenden */
#else
	putchar(a);
#endif
}


sys_uucp(source,dest,host)
char source[],dest[],host[];
{
	char spooldir[LLEN];
	static char s[LLEN],s2[LLEN],s3[LLEN];
	static char hosts[LLEN],seq[LLEN],tmp[LLEN];
	int inh,i,outh;
	
	getconf(15,hosts);

	inh = open(hosts,2);	/* Read UUCP-Hostsfile */
	
	if (inh < 0)
	{
		send("sys_uucp: Host file '");
		send(hosts);
		send("' does not exist.");
		cr(1);
		
		return(-1);
	}
	
	while (getline(inh,s) != -1)
	{
		strcpys(s,s2,0,linstr(s,'|') - 1);
		if (strcmp(s2,host) == TRUE)
			break;
	}
	close(inh);
	
	if (exist(source) != TRUE)
	{
		send("sys_uucp: Sourcefile '");
		send(source);
		send("' does not exist.");
		cr(1);
		return(-1);
	}
		
	if (strcmp(host,s2) != TRUE)
	{
		send("sys_uucp: Host '");
		send(host);
		send("' does not exist.");
		cr(1);
		return(-1);
	}
	
	strcpys(s,spooldir,rinstr(s,'|') + 1,strlen(s));
	
	sys_impdirn(spooldir);
	
	existing:
	strcpy(spooldir,s);
	mktmp(s);
	stradd(".d",s);
	
	if (exist(s) == TRUE)	/* In case file exists... */
		goto existing;
	
	strcpy(s,tmp);
	
		
	/* Update Controlfile */
	strcpy(spooldir,s2);
	stradd("work.c",s2);

 	if (exist(s2) != TRUE)
	{
		outh = open(s2,1);
	}
	else
	{
		outh = open(s2,4);
	}
	
	if (outh < 0)
	{
		pen(ROT);
		send("Error opening for output: ");
		send(s2);
		cr(1);
		pen(WEISS);
		return(-1);
	}
	
	strcpy("S ",s);
	strcpys(tmp,s2,rinstr(tmp,'\\') + 1,strlen(tmp));
	stradd(s2,s);
	
	stradd(" ",s);
	stradd(dest,s);
	stradd(" root - ",s);
	stradd(s2,s);
	stradd(" ",s);
	stradd(FILEMODE,s);
	
	putline(outh,s);
	close(outh);
	/* Updatet. */

	sprintf(s2,"uucp: %s (%ld bytes for %s)",s,(long)fsize(source),host);
	log(s2,"uucp");
	
	sys_fcopy(source,tmp);		/* Create the tmpfile in the
					   Spooldirectory */
}


filter(s)
char s[LLEN];
{
	char s2[LLEN],s3[LLEN];
	
	while (linstr(s,10) != -1)
	{
		strcpys(s,s2,0,linstr(s,10) - 1);
		strcpys(s,s3,linstr(s,10) + 1,strlen(s));
		stradd(s3,s2);
		strcpy(s2,s);
	}

	while (linstr(s,13) != -1)
	{
		strcpys(s,s2,0,linstr(s,13) - 1);
		strcpys(s,s3,linstr(s,13) + 1,strlen(s));
		stradd(s3,s2);
		strcpy(s2,s);
	}
}





sys_dayweek()
{
	int day, mon, year;
	int adj_mo, adj_yr, cent, cent_yrs;

	day = sys_dayofmonth();
	mon = sys_month();
	year = sys_year();
	
	adj_mo = (mon > 2) ? mon - 2 : mon + 10;
	adj_yr = (mon > 2) ? year    : year - 1;
	cent = adj_yr / 100;
	cent_yrs = adj_yr % 100;
	return (((((13 * adj_mo - 1) / 5) + day + cent_yrs +
		(cent_yrs / 4) + (cent / 4) - 2 * cent + 77) % 7));
}


lgetline(inh,buf)
int inh;
char *buf;
{
	while ((*buf++ = get(inh)) != 10);
	*(--buf) = '\0';
}

getline(inh,buf)		/* Eine Zeile in den <buf> lesen */
int inh;
char buf[];
{
	long g;
	int p,c;
	char s[LLEN + 2];
	long rd;

	if (inh < 0)
	{
		send("sys_getline was given wrong file handle. Internal error.");
		cr(1);
		strcpy("",buf);
		return(-1);
	}

	g = (long)pos(inh);
	
	rd = gemdos(0x3f,inh,(long)(LLEN),s);


	s[LLEN - 1] = '\0';	/* No bombs anymore! :-) */
	
	if (rd == 0)
	{
		seek(inh,(long)g);
		return(-1);
	}
	
	if (rd < 0l)
	{
		pen(ROT);
		cr(1);
		send("Fatal error while reading.");
		cr(1);
		send("Ffread() == ");
		sendl(rd);
		cr(1);
		pen(WEISS);
		return(-1);
	}
	
	
	c = 0;
	while ((s[c] != 13) && (s[c] != 10) && (c < rd))
		++c;
	
	p = (int)((long)rd - (int)c);

	if ((s[c] == 13) || (s[c + 1] == 13))	/* Filter ^M */
		--p;

	if (c < rd)
		rseek(inh,(long)(1 - p));

	
	s[c] = '\0';
	strcpy(s,buf);

	return(0);
}




mktmp(s)	/* Return a tmp filename */
char s[];
{
	char seq[LLEN],s2[LLEN],s3[5];
	sys_impdirn(s);

	do
	{
		strcpy(s,s2);
		strcpy("a",seq);
		while (strlen(seq) < 8)
		{
			str((int)sys_rnd(9),s3);
			stradd(s3,seq);
		}
		stradd(seq,s2);

	} while (exist(s2) == TRUE);

	strcpy(s2,s);
}


getage()	/* Get age of last accessed file via DTA */
{
	int *dta,year,month,day,d;
#ifndef MWC
	int *gemdos();
#endif

	long age,today;
	char s2[LLEN];


	dta = (int *)gemdos(47);
	dta = dta + 12l;
	d = *dta;
	
	year	= (d & (long)(65024)) / 512;
	month	= (d & 480) / 32;
	day	= (d & 31);

	age	= year * 365;
	age	+= month * 31;
	age	+= day;

	if (year < 1)
	{
		send("File has invalid time entry.");
		cr(1);
		return(-1);
	}
	
	d	= sys_getdate();
	year	= (d & (long)(65024)) / 512;
	month	= (d & 480) / 32;
	day	= (d & 31);

	today	= year * 365;
	today	+= month * 31;
	today	+= day;

	if (year < 1)
	{
		send("Invalid date set.");
		cr(1);
		return(-1);
	}

	if (today < age)
	{
		send("File has incorrect date.");
		cr(1);
		return(-1);
	}

	d = (int)(today - age);
	return((int)d);
}



beep()
{
	bell();
}

bell()
{
#if BELL
	static char beep[] = {
		0x00, 0x00,0x01, 0x01,0x02, 0x01,0x03, 0x01,
		0x04, 0x02,0x05, 0x01,0x07, 0x38,0x08, 0x10,
		0x09, 0x10,0x0A, 0x10,0x0B, 0x00,0x0C, 0x30,
		0x0D, 0x03,0xFF, 100,0x09,  0x00,0x0A, 0x00,
		0xFF, 0x00
	};
	xbios(32,beep);
#endif
}

pen(s)
int s;
{
#if COLOUR
	out('\033');
	out('b');
	out('A' + s);
#endif
}

flush()
{
}


munge(spool,ng,sr)
char *spool,*ng,*sr;
{
	char s[LLEN],s2[LLEN],s3[LLEN];
	
	strcpy(spool,s);
	sys_impdirn(s);

	if (ng[strlen(ng) - 1] == '.')
		ng[strlen(ng) - 1] = '\0';

	strcpy(ng,s2);
	stradd(".",s2);

	while(strlen(s2) != 0)
	{
		strcpys(s2,s3,0,linstr(s2,'.') - 1);
		s3[8] = '\0';
		stradd(s3,s);
		stradd("\\",s);
		strcpys(s2,s3,linstr(s2,'.') + 1,strlen(s2));
		strcpy(s3,s2);
	}
	strcpy(s,sr);
}



sys_incmkdir(d)
char *d;
{
	static char s[LLEN],s2[LLEN],s3[LLEN],s4[LLEN];
	int i;

	strcpy(d,s);
	sys_impdirn(s);
	s[strlen(s) - 1] = '\0';	/* Kill last '\' */
	strcpy(s,s2);
	strcpy("",s4);

	if (gemdos(78,s,(char)0x10) == 0)	/* Already existent? */
		return(0);

	while (sys_mkdir(s) != 0)
	{
		strcpys(s,s2,0,rinstr(s,'\\') - 1);

		/* Remember suppressed names. */
		strcpys(s,s3,rinstr(s,'\\'),strlen(s));
		stradd(s3,s4);
		
		strcpy(s2,s);

		if (linstr(s,'\\') == -1)
			return(-1);
	}

	while (strlen(s4) != 0)
	{
		strcpys(s4,s3,rinstr(s4,'\\'),strlen(s4));
		stradd(s3,s);

		if (sys_mkdir(s) != 0)
			return(-1);

		strcpys(s4,s3,0,rinstr(s4,'\\') - 1);
		strcpy(s3,s4);
	}
	sprintf(s2,"sys$incmkdir(%s)",d);
	log(s2,"system");
}


long df()
{
	long free;
	struct dfb {
			long freecluster;
			long totalcluster;
			long bytespersec;
			long secpercluster;
	} *dfbs;

	dfbs = (struct dfb *)malloc((long)sizeof(struct dfb));

	gemdos(0x36,dfbs,0);

	free = dfbs->freecluster;
	return(free);
}




bzero(p,l)
char *p;
long l;
{
	while (--l)
		*(p++) = 0;
}

int lw(c)
char c;
{
  if (c>='A' && c<='Z')
    return c+32;
  else return c;
}


whatnow(s,s2)
char *s,*s2;
{
	char s3[LLEN];
	int n;

	for (;;)
	{
		send(s);
		send(" ");
		rec(s3);
		cr(1);

		if ((linstr(s2,s3[0]) == -1) || (s3[0] == '\0'))
		{
			send("Please choose one of the");
			cr(1);
			send("following: ");
			strcpy(s2,s3);
			
			for (n = 0; s3[n]; ++n)
			{
				out('\"');
				out(s3[n]);
				out('\"');
				if (s3[n + 1])
					out(',');
				out(' ');
			}
			cr(2);
		}
		else
		{
			return(linstr(s2,s3[0]) + 1);
		}
	}
}



char *trim(s)
char s[];
{
	static char s2[LLEN],*p;

	p = s;
	
	while (*p == ' ')
		++p;

	strcpy(p,s2);
	strcpy(s2,s);

	while (s[strlen(s) - 1] == ' ')
		s[strlen(s) - 1] = '\0';

	return(s);
}






drot13(s)
char *s;
{
	char c;
	while (*s)
	{
		if (((*s >= 'a') && (*s <= 'z')) || ((*s >= 'A') && (*s <= 'Z')))
		{
			c = *s;
			c = ((c > 64) && (c < 91)) ? c + 32 : c;
			*s = (c > 'm') ? *s - 13 : *s + 13;
		}
		++s;
	}
}
