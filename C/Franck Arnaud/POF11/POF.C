/*
 *	POF! - Plenty Of Files
 *	----------------------
 *
 *	POF! is a file list maker for BBS systems having files.bbs-like
 *	download areas.
 *
 *	Public domain: this program may be copied and sold freely.
 *
 *	Porting: under unix it should be easy, all defines are below, 
 *	and just compile with "cc -DUNIX -DNO_LDIFFTIME -o pof -c pof.c".
 *	Potential unix problems: long filenames, case.
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>

#include <sys/types.h>	/* for download */
#include <sys/stat.h>

/* all configuration is here */
#ifdef ATARI /* Atari ST */
#define POFVERS "1.1/tos"
#define SYSSEPAR '\\'
#define SYSSTRSEPAR "\\"
#endif
#ifdef UNIX /* Unix (tested on BSD,etc) */
#define POFVERS "1.1/unix"
#define SYSSEPAR '/'		/* directory separator */
#define SYSSTRSEPAR "/"
#define stricmp strcasecmp
#define strnicmp strncasecmp
#endif
#ifdef WIN32 /* Windows NT */
#define POFVERS "1.1/wnt"
#define SYSSEPAR '\\'
#define SYSSTRSEPAR "\\"
#endif

/*efine NO_LDIFFTIME */ 	/* define if you don't want to use the ansi difftime 
								that requires float point libs, and if your system
								time_t is in seconds since sometimes */

/* more config, don't change normally */
#define POFSTR 150
#define FILESBBS "files.bbs"
#define FBBSCUTLEN  45	/* download() */
#define FBBSSTRINGLEN 31
#ifdef NO_LDIFFTIME
#define difftime(a,b) (a-b)
#endif

#define DEBUG /**/

int total_files=0;
long total_kb=0;
int total_missing=0;

/* ================================================== UTILITY FUNCTIONS */

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

/*
 *	add a directory separator at the end of a string if !there
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
 * find next string format "plouf <tab>tralala ; comment 
 */

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

/*
 * copy string until space (in dest)
 */

void strspacecpy(char *dest, char *srce)
{
	int i=0,j=0;
	
	while((srce[i]!='\0') && (srce[i]!=' ') && (srce[i]!='\x09') && (i<POFSTR))
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

/* 
 * logline: Log a line in the logfile and output to screen 
 */

void logline(char *line, ...)
{
	time_t	timer;
	char	temp[100], out[100],tdate[20];
	va_list param;
	struct tm *tim;
	
	if(!logfile)
		return;	/* error */
		
	/* process */
	va_start(param, line);
	vsprintf(temp, line, param);
	va_end(param);
	time (&timer);
	tim = localtime (&timer);
	strftime (tdate, 20, "%d %b %H:%M:%S", tim);
	sprintf (out, "+ %s POF  %s", tdate, temp);

	/* log to file */
	fputs(out,logfile);
#ifdef DEBUG
	fflush(logfile);
#endif
}
 
/* 
 *	openlog: create logfile 
 */

void open_the_log(char *nm)
{
	logfile=fopen(nm,"a");
	if(logfile)
		return;
	
	printf("Can't open logfile!\n");
}

/* 
 * closelog: close logfile 
 */

void close_the_log(void )
{
	if(logfile)
		fclose(logfile);
}


/* 
 * process @ line 
 */

void include(char *text)
{
	char oneline[POFSTR];
	FILE *txt;
	
	if(!text)
		return;
		
	txt=fopen(text,"r");
	if(txt)
	{
		while(fgets(oneline,POFSTR,txt))
		{
			strcln(oneline,-1);
			if(strlen(oneline)>79)
				oneline[78]=0;
			puts(oneline);
		}
		fclose(txt);
	}
	else 
		logline("Error including text");
}

/* 
 * process area line 
 */

void doarea(char *area, int days)
{
	struct stat mystat;
	char area2[POFSTR];
	char *temp;
	char file[POFSTR];
	char filebbs[POFSTR];
	FILE *fbbs;
	time_t now;
	int i;
	
	int area_files=0;
	long area_kb=0;
		
	/* get now */
	time(&now);
	
	/* clean copy of area */
	strcpy(area2,area);
	addslash(area2);
	
	strcpy(filebbs,area2);
	strcat(filebbs,FILESBBS);
	
	fbbs=fopen(filebbs,"r");
	if(!fbbs)
		logline("Can't find %s in area %s",filebbs,area);
	else
	{
		temp=malloc((POFSTR*10)+1);
		if(!temp)
			logline("Can't malloc temp buffer in doarea()");
		else
		{
			while(fgets(temp,POFSTR*10,fbbs))
			{	
				if(!isalnum(*temp)) /* thats a comment */
				{
					strcln(temp,-1);
					if(strlen(temp)>75)
						temp[72]=0;
					puts(temp);
				}
				else
				{ /* that's a file name */
					char filen[POFSTR];
					char unknown[POFSTR];
					char date[POFSTR];
					char *desc;
					int lastspace,idx,lastcut;
			
					strcpy(unknown,"-none-");
				
					strcpy(file,area2); /* file <area>\<file> */
					strspacecpy(filen,temp);
					strcat(file,filen);
			
					desc=nextstr(temp); /* desc: description */
					if(!desc) desc=unknown;
					strcln(desc,-1);
			
					/* multiline */
					idx=0;
					lastspace=0;
					lastcut=0;
					while(desc[idx])
					{
						if(desc[idx]==' ')
							lastspace=idx;
				
						if((idx-lastcut)>FBBSCUTLEN)
						{
							for(i=0;i<FBBSSTRINGLEN;i++)
								strspins(desc+lastspace+1+i);
							desc[lastspace+1]='\n';
							lastcut=idx=lastspace+FBBSSTRINGLEN;
						}
						idx++;
					}
				
				
					if(stat(file,&mystat))
					{
						printf("%-12.12s *** MISSING *** %s\n",filen,desc);
						total_missing++;
					}
					else
					{
						if(	(days<=0) || 
							((difftime(now,mystat.st_mtime)/86400) <= days) )
						{
							#ifdef STANDARD_DE_MERDE
							 strftime(date,POFSTR,"%y-%m-%d",localtime(&mystat.st_mtime));
							#else
                             strftime(date,POFSTR,"%d %b %y",localtime(&mystat.st_mtime));
							#endif
							printf("%-12.12s %6ld %s %s\n",filen,(long) mystat.st_size,date,desc);
							area_files++;
							total_files++;
							area_kb+=mystat.st_size/1024;
							total_kb+=mystat.st_size/1024;
						}
					}
				}/* not a file name */
			} 
			free(temp);
		} /* malloc */
		fclose(fbbs);
	} /* file */
	
	printf("\n  Number of files in this area: %d\n",area_files);
	printf("  Size of the area: %ld KB\n\n\n",area_kb);
	
	return;
}

/*
 *	process .pof file
 */
 
void process(char *config, int days)
{
	FILE *txt;
	char date[POFSTR];
	char oneline[POFSTR];
	time_t now;
	
	int total_area=0;
	
	time(&now);
		
	if(!config)
		return;
	
	txt=fopen(config,"r");
	if(!txt)
	{
		logline("Can't read config file");
		return;
	}
	else
	{
		strftime(date,POFSTR,"%d %B %Y at %H:%M",localtime(&now));
		if(days<=0)
			printf(" Full filelist compiled on %s by POF! vers. %s.\n\n",date,POFVERS);
		else
			printf(" Filelist of NEW FILES SINCE %d DAYS compiled on %s.\n\n",days,date);
		
		while(fgets(oneline,POFSTR,txt))
		{
			if(strlen(oneline)>1)
			{
				strcln(oneline,-1);
				
				if(oneline[0]=='@')
					include(oneline+1);
				else if(oneline[0]=='#')
					puts(oneline+1);
				else if(oneline[0]==';')
					;
				else
				{
					doarea(oneline,days);
					total_area++;
				}
			}
		}
		fclose(txt);
	}
	
	printf("\n\n  Stats:\n  ------\n\n");
	printf("  Total number of files      : %d\n",total_files);
	printf("  Total size of listed files : %d KB\n",total_kb);
	printf("  Average file lenght        : %d KB\n",total_kb/total_files);
	printf("  Number of areas listed     : %d\n",total_area);
	printf("  Number of missing file(s)  : %d\n\n\n",total_missing);
	
	if(days<=0)
		printf(" Full filelist compiled on %s by POF! vers. %s.\n\n",date,POFVERS);
	else
		printf(" Filelist of NEW FILES SINCE %d DAYS compiled on %s.\n\n",days,date);
}

/* ============================================================= MAIN */

void usage(void )
{
	printf("pof: [-d<keepdays>] [-l<logfile>] config-file\n\n");
}

int main(int argc, char **argv)
{	
	char myconfig[POFSTR];
	int keepdays=0;
	int i;

	myconfig[0]=0;
	
	/* parse command line */
	for(i=1;i<argc;i++)
	{	
		if(!strnicmp(argv[i],"-l",2))
			open_the_log(argv[i]+2);
		else if(!strnicmp(argv[i],"-d",2))
			keepdays=atoi(argv[i]+2);
		else if(argv[i][0]!=0)
		{
			if(myconfig[0])
			{
				usage();
				return 1;
			}
			
			strcpy(myconfig,argv[i]);
		}
		else
		{
			usage();
			return 1;
		}
	}
	
	if(myconfig[0]==0)
	{
		usage();
		return 2;
	}
	
	process(myconfig,keepdays);
	
	if(keepdays<=0)
		logline("Full filelist produced. %d files, %d KB, %d missing.\n",
			total_files, total_kb, total_missing);
	else
		logline("Filelist (last %d). %d files, %d KB, %d missing.\n",
			keepdays, total_files, total_kb, total_missing);
	
	close_the_log();
	return 0;
}

/*eof*/