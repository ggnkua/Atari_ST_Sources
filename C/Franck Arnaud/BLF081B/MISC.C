/* 
 *	BloufGate
 *	Misc functions 
 *
 *	Public Domain: may be copied and sold freely
 */

#include	"blouf.h"

/* 
 * fgets who don't stop when string is full 
 */

char *fblfgets(char *str, size_t len, FILE *fl)
{
	int idx=0;
	unsigned char mychar;
	
	while(!feof(fl))
	{
		if(fread(&mychar,1,1,fl)!=1)
			break;
			
		if((size_t)idx<(len-1))
			str[idx++]=(char) mychar;	
		
		if(mychar=='\n')
			break;
	}
	str[idx]=0;
	
	if(idx)
		return str;

	return NULL;
}

/*
 *	remove ending slash
 */
 
void killslash(char *str)
{
	if(str[strlen(str)-1]==BLF_DSEPAR)
		str[strlen(str)-1]=0;
}

/* 
 *	create rfc file 
 */

FILE *create_rfcfile(char *path, char *ext)
{
	FILE *a;
	unsigned long	i=0,loop=0;
	char out[BLFSTR];

	i=(unsigned long)time(NULL);

	do {
		i++;
		loop++;
		sprintf (out, "%s%cA%lx.%s", path, BLF_DSEPAR, i, ext);
	} while (!access(out,0) && loop<1000);
		
	if(loop>=1000)
	{
		logline("!Can't find a new rfc file name.");
		return NULL;
	}
		
	a = fopen(out,"wb");
	if(!out)
	{
		logline("!Can't open %s",out);	
		return NULL;
	}
	return a;
}

/* 
 *	From a message of Burt Juda in the UFGATE echo 
 *
 *	crlf to cr in a string
 *	convert pc accents
 */

void mksoftcr (char *text) {
	int c1 = 0;		/* counter since last CR */
	int c2 = 0;	   /* counter since last SPACE */
	char *t, *s;

/*
 * ++tb: the pointer `s' is anchored to the last space found. Every
 * 78 chars, this space is replaced by a soft break. This could
 * cause problems if no space has been found, ie if the first line of
 * the message is a word longer than that.
 */
   
	s = NULL;

	for (t=text; *t; t++)
	{
		c1++;
		c2++;
		if (*t == '\01')
			*t = '-';
		if ((*t=='‚')
			|| (*t=='Š')
			|| (*t=='ˆ')
			|| (*t=='‰')
			|| (*t=='Š')) *t='e';
		if ((*t=='Œ')
			|| (*t=='')
			|| (*t=='‹')) *t='i';
		if ((*t=='—')
			|| (*t=='–')) *t='u';
		if ((*t=='…')
			|| (*t=='ƒ')) *t='a';
		if (*t=='‡') *t='c';
		if ((*t=='“')
			|| (*t=='”')
			|| (*t=='•')) *t='o';
	  
		/* remove 8th bit */
		*t = *t & 0x7f;

		if ((*t == '\n') || (*t == '\r'))
		{
			c1 = 0;/* reset counters */
			c2 = 0;
			continue;
		}
		else
		{
			if ((*t == ' ') || (*t == '\t'))
			{
				s = t;
				c2 = 0;
				continue;
			}
			else
			{
				if ((c1 > 78) && (s != NULL))
				{
					*s = '\n';
					c1 = c2;
					continue;
				}
			}
		}
		/* todo: convert "ansi" graphics to ascii graphics :) */
	}
}

/*
 * Remove control codes 
 */

void clean_string(char *s)
{
	int i=0;
	
	while(s[i])
	{
		if(s[i]<32)
		{
			if(i==((int) strlen(s)-1)) /* last char */
			{
				s[i--]=0;
				break;
			}
			else
				s[i]=' ';
		}
		/* if(ispunct(s[i])) s[i]='_'; */
		i++;
	}
}

/* used to clean a string, config file? */

void strip(char *line)
{
	int    i;

	if (line[0] != 0) {
		i=0;
		line[strlen(line)-1]='\0';	   /* remove ending \n */
		while ((line[i]!='\0') && (line[i]!=';'))
			i++;
		line[i] = '\0'; i--;
		while ((i>=0) && ((line[i]==' ') || (line[i]=='\t')))
			i--;
		line[i+1] = '\0';
	}
}

int token(char *tok, char *line) /* !=0 si la ligne commence par token */
{
	int i=0;
	/* case insignifiant */
	while (tok[i]!='\0') {
		if (tolower((int)tok[i]) != tolower((int)line[i]))
			return (0);
		i++;
	}
	while ((line[i]==' ') || (line[i]=='\t'))
		i++;
	return i;
}

/* fputiw: read a word in PKT, machine independant byte order */

void fputiw (WORD b, FILE *a)
{
	fputc (b & 0xff, a);
	fputc (b >> 8, a);
}

/* fgetiw: write a word in PKT */

WORD fgetiw (FILE *fi)
{
	int c;
	c = fgetc (fi);
	return (c + (fgetc(fi)<<8));
}

void fgetf (char *str, int max, FILE *fi)
{
	unsigned char c;
	int  i=0;

	while ((i < max) && ((c=(unsigned char) fgetc(fi)) != '\0')) {
		if ((c != '\n') && ((c-128) != '\n'))
			if (c == '\r') 
				*str++ = '\n';
			else   
				*str++ = c;
		i++;
	}
	*str = '\0';
	if(i>=max)
		logline("!fgetf() overflow!");
}

/* strscan: return index of char a in line, -1 if not found */
/* fixme: should use strxchr ? */

int strscan (char a, char *line)
{
	int i=0;
	while ((*line != a) && (*line != '\0')) { i++; line++; }
	if (*line == '\0') return (-1); else return (i);
}

/* logfile routines */
 
FILE *logfile=NULL;

int openlog(char *lfname)
{
	logfile=fopen(lfname,"a");
	if(!logfile)
	{
		printf("can't open logfile.\n");
		return FAIL;
	}
	
	return SUCCESS;
}

void closelog(void )
{
	if(logfile)
		fclose(logfile);
}

/* logline: Log a line in the logfile and output to screen */

void logline(const char line[], ...)
{
	time_t	timer;
	char	temp[500], out[500],tdate[20];
	va_list param;
	struct tm *tim;
	
	/* process */
	va_start (param, line);
	vsprintf (temp, line+1, param);
	va_end (param);
	time (&timer);
	tim = localtime (&timer);
	strftime (tdate, 20, "%d %b %H:%M:%S", tim);
	sprintf (out, "%c %s BLF  %s", line[0], tdate, temp);
	
	/* log */
	if(logfile)
	{
		fputs(out,logfile);
		fputc('\n',logfile);
	}
	
	puts(out);
}

/* eof */