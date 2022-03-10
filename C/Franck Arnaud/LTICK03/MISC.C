/*
 *	Misc functions for LazyTick/LazyFix
 *	(LazyTick/LazyFix Project)
 *   
 *	Public Domain: may be copied and sold freely
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<portab.h>
#include	<ctype.h>
#include	<string.h>
#include    <stdarg.h>

#include	"qbbs.h"
#include	"tick.h"
#include 	"misc.h"
#include	"config.h"

#define timenix(a) time(a)

#define MSGSIZE 32000	 /* Max message size */
#define BUFSIZE 1024 	 /* Copy buffer */
#define USEPID			 /* define to use ^PID kludge */
#define PIDSTR	LAZYNAME /* PID name */
#define PIDVER  LAZYVERS /* PID version */

/* ================================================= FILE ECHOLIST */
/* open_areas: load <path>fareas.bbs
   close_areas: release buffers
   get_area: return pointer to area field or NULL
   debug_areas: print buffer */

ECHOLIST *el=NULL;
int maxel=0;

void close_areas(void )
{
	if(el)
		free(el);
}

ECHOLIST *get_area(char *areatag)
{
	int i;
	if(!el)
		return NULL;
	
	for(i=0;i<maxel;i++)
	{
		if(stricmp(areatag,el[i].name)==0)
			return (el+i);
	}
	return NULL;
}

int debug_areas(void )
{
	int i;
	
	if(!el)
		return BBSFAIL;
	
	printf("Debugging ECHOLIST\n");
	
	for(i=0;i<maxel;i++)
	{
		FIDONODE *currentnode;
		
		printf("Farea: %s; path: %s; group: %s; line: %d-%d\n",
			el[i].name,el[i].file,el[i].group,el[i].line,el[i].modify);
		printf(" desc: %s\n",el[i].desc);
		printf(" nodes: ");
		
		currentnode=el[i].firstnode;
		while(currentnode)
		{
			printf("[%d]%d:%d/%d.%d ",
				currentnode->position,currentnode->zone,
				currentnode->net,currentnode->node,
				currentnode->point);
			currentnode=currentnode->next;
		}
		printf("\n");
	}
	return BBSOK;
}

int open_areas(char *path)
{
	FILE *abbs;
	char curgroup[BBSSTR];
	char curdesc[BBSSTR];
	char buffer[200];
	int curarea=0;
	char *ptr;
	int tmpzone,tmpnet,tmpnode,tmppoint;
	int curline=0;
	FIDONODE *currentnode;
	
	el=malloc(sizeof(ECHOLIST)*MAXECHO+1);
	if(!el)
	{
		logline(5,"Can't malloc echolist!");
		the_end(242);
	}
	
	strcpy(curgroup,"none");
	strcpy(curdesc,"No description.");
	
	abbs=fopen(path,"r");
	if(abbs)
	{
		if(fgets(buffer,199,abbs)!=NULL)
		{ /* skip origin line */	
			while(fgets(buffer,199,abbs)!=NULL)
			{
				curline++; /* current areas.bbs line number */
				
				strcln(buffer,-1);
				if(iscomment(*buffer))
					;
				else if(buffer[0]=='-')
				{
					if(strnicmp(buffer,"-group",(size_t) strlen("-group"))==0)
					{ /* got new flags */
						ptr=nextstr(buffer);
						if(ptr)
						{
							if(strlen(ptr)>8)
								ptr[8]=0;
							strlwr(ptr);
							strspacecpy(curgroup,ptr);
						}
					}
					
					if(strnicmp(buffer,"-desc",(size_t) strlen("-desc"))==0)
					{ /* got desc */
						ptr=nextstr(buffer);
						if(ptr)
						{
							if(strlen(ptr)>=BBSSTR-1)
								ptr[BBSSTR-2]=0;
							strcpy(curdesc,ptr);
						}
					}				
				}
				else /* got an area */
				{
#ifndef GET_PASSTHRU
					if(strnicmp(buffer,"passthru",strlen("passthru")))
#endif
					{ /* !passthru area */
						strspacecpy(el[curarea].file,buffer);
						ptr=nextstr(buffer);
						if(ptr)
						{
							el[curarea].modify=0;
							el[curarea].line=curline;
							strcpy(el[curarea].group,curgroup);
							strcpy(el[curarea].desc,curdesc);
							strspacecpy(el[curarea].name,ptr);

							/* search node number list */
							el[curarea].firstnode=NULL;

							while((ptr=nextstr(ptr))!=NULL)
							{
								if(getaddress(ptr,&tmpzone,&tmpnet,&tmpnode,&tmppoint))
								{
									/* allocate new node */
									if(el[curarea].firstnode==NULL)
									{	
										currentnode=el[curarea].firstnode=malloc(sizeof(FIDONODE));
									}
									else
									{
										currentnode->next=malloc(sizeof(FIDONODE));
										currentnode=currentnode->next;
									}
									
									/* check malloc */
									if(!currentnode)
									{
										logline(5,"Malloc error while loading fareas.bbs");
										the_end(242);
									}
									
									currentnode->next=NULL;
									currentnode->position=(int)(strlen(buffer)-strlen(ptr));
									currentnode->zone=tmpzone;
									currentnode->net=tmpnet;
									currentnode->node=tmpnode;
									currentnode->point=tmppoint;
								}
								else
									logline(2,"Bad node number in fareas.bbs: %s",ptr);
							}

							/* next area */
							if(curarea<(MAXECHO-2))
								curarea++;
						}
					} /* passthru */
					/* reset desc */
					strcpy(curdesc,"No description.");
				} /* got */
			}
		}
		fclose(abbs);	
		el[curarea].file[0]=0; /* end of list marker */
		
	}
	else
		return BBSFAIL;
		
	maxel=curarea;
	return BBSOK;
}

/* ========================================================= FILE COPY */

int copyfile(char *one,char *two)
{
	FILE *onef;
	FILE *twof;
	unsigned char bufc;
	int error=0;
	
	unsigned long count=0;
	time_t timer;
	char tdate[BBSSTR];
	
	onef=fopen(one,"rb");
	if(!onef)
	{
		logline(4,"Can't open %s",one);
		return BBSFAIL;
	}
	else
	{
		twof=fopen(two,"wb");
		if(!twof)
		{
			logline(4,"Can't open %s",two);
			error++;
		}
		else
		{
			time (&timer);
	  		strftime (tdate, 20, "%d %b %H:%M:%S", localtime(&timer));
	  		printf("$ %s %s Copying",tdate,LAZYLGID);
			while(fread(&bufc,1,1,onef)==1)
			{
				fwrite(&bufc,1,1,twof);
				if(((count++)%25000)==0)
            		printf(".");
			}
			printf("\n");
			  
			if(ferror(twof))
			{
				logline(4,"Error while processing %s",two);
				error++;
			}
			fclose(twof);
		}
		
		if(ferror(onef))
		{
			logline(4,"Error while processing %s",one);
			error++;
		}
		fclose(onef);
	}
	
	if(error)
		return BBSFAIL;
	return BBSOK;
}

/* ====================================================== POST MESSAGE */
/* postmsg: post a mail msg */

int postmsg(char *from, char *fromaddr, char *to, char *toaddr, char *subject, 
				char *arearad, char *msgtext, int private)
{
	FILE *hdr,*msg,*txt;
	int i,error;
	time_t curtm;
	size_t max;
	long offset,msgsize;
	int dzone=0,dnet=0,dnode=0,dpoint=0;
	int ozone=0,onet=0,onode=0,opoint=0;
	char *zebuffer;
	
	char areahdr[FILENAME_MAX];
	char areamsg[FILENAME_MAX];
	char temp[BBSSTR];
	char zerotemp=0;
	QBBS_MHEADER ourmsg;
	FIDONODE tmpnode;
	
	zebuffer=malloc(BUFSIZE+1);
	if(!zebuffer)
	{
		logline(5,"Can't malloc postmsg buffer");
		the_end(242);
	}
	
	/* convert addresses */
	if(toaddr)
		sscanf(toaddr,"%d:%d/%d.%d",&dzone,&dnet,&dnode,&dpoint);
	else
	{
		get_ouraddress(&tmpnode,0,0,0,0);
		dzone=tmpnode.zone;
		dnet=tmpnode.net,
		dnode=tmpnode.node;
		dpoint=tmpnode.point;
	}
	if(fromaddr)
		sscanf(fromaddr,"%d:%d/%d.%d",&ozone,&onet,&onode,&opoint);
	else
	{
		get_ouraddress(&tmpnode,dzone,dnet,dnode,dpoint);
		ozone=tmpnode.zone;
		onet=tmpnode.net,
		onode=tmpnode.node;
		opoint=tmpnode.point;
	}
	
	/* create area datafiles names */
	strcpy(areahdr,arearad);
	strcat(areahdr,".HDR");
	strcpy(areamsg,arearad);
	strcat(areamsg,".MSG");
	
	time(&curtm);
	msgsize=0;
	error=0;
	offset=0;
	
	/* old .msg size */
	msg=fopen(areamsg,"rb");
	if(msg)
	{
		fseek(msg,0,SEEK_END);
		offset=ftell(msg);
		if(offset<0)
			offset=0;
		fclose(msg);
	}
			
	/* we gonna write the text in the .msg file */
	msg=fopen(areamsg,"ab");
	if(msg)
	{
		time_t id;
		time(&id);
		
		/* Write MSGID kludge */
		if(opoint==0)
			sprintf(temp,"\01MSGID: %d:%d/%d %8.8lx\x0a",
				ozone,onet,onode,(long)id);
		else
			sprintf(temp,"\01MSGID: %d:%d/%d.%d %8.8lx\x0a",
				ozone,onet,onode,opoint,(long)id);
		
		if(fwrite(temp,(size_t) strlen(temp),1,msg)==1)
		{
			msgsize+=strlen(temp);
			
			/* Write PID kludge */
			#ifdef USEPID
			sprintf(temp,"\01PID: %s %s\x0a",PIDSTR,PIDVER);
			if(fwrite(temp,(size_t) strlen(temp),1,msg)==1)
				msgsize+=strlen(temp);
			else 
				error++;
			#endif
				
			/* Read the message itself and add to MSG */
			txt=fopen(msgtext,"r");
			if(txt)
			{
				error=0;
				do
           		{
               		max=fread(zebuffer,1,BUFSIZE,txt);
               		if(max>0)
               		{
						msgsize+=max;
						if(fwrite(zebuffer,1,max,msg)!=max)
							error++;
					}
					else if(max<0)
						error++;
					/* copy only the first MSGSIZE bytes */
           		} while((max==BUFSIZE) && (error==0) && msgsize<MSGSIZE);
				
				fclose(txt);
				
				/* Write Tearline */
#ifdef USETEAR
				if(!private)
				{
					sprintf(temp,"--- %s %s\x0a",PROGNAME,VERSTR);
					if(fwrite(temp,(size_t) strlen(temp),1,msg)!=1)
						error++;
					msgsize+=strlen(temp);
				}
#endif
#ifndef DONTUSEZERO
				zerotemp=0;
				if(fwrite(&zerotemp,(size_t)1,1,msg)!=1)
						error++;
				msgsize+=1;
#endif
			}
			else
				error++;							
		}
		else
			error++;
		
		
		fclose(msg);
	}
	else
		error++;
		
	if(!error)
	{
		/* Init header */
		strcpy(ourmsg.from,from);
		strcpy(ourmsg.to,to);
		strcpy(ourmsg.subject,subject);
		strftime(ourmsg.time,20,"%d %b %y  %H:%M:%S",localtime(&curtm));
		
		ourmsg.stamp=timenix(NULL); 
					/* fixme? number of seconds since 1/1/70 */
	
		ourmsg.reserved1=0; /* ? */
		ourmsg.reply_to=0; /* set by burep, etc */
		ourmsg.attrib=POSTFLAG;

		if(private)
			ourmsg.attrib|=PRVTFLAG;
					
		for(i=0;i<8;i++)
			ourmsg.mailer[i]=0;
		
		/* Set size and offset */
		ourmsg.size=(UWORD) msgsize;
		ourmsg.msgoffset=offset;
	
		
		ourmsg.read_count=0;
		ourmsg.cost=0;
		ourmsg.o_zone=(WORD) ozone;
		ourmsg.o_net=(WORD) onet;
		ourmsg.o_node=(WORD) onode;
		ourmsg.o_point=(WORD) opoint;
		
		if(dzone)
		{
			ourmsg.d_zone=(WORD) dzone;
			ourmsg.d_net=(WORD) dnet;
			ourmsg.d_node=(WORD) dnode;
			ourmsg.d_point=(WORD) dpoint;
		}
		else
		{
			ourmsg.d_zone=0; 
			ourmsg.d_net=0; 
			ourmsg.d_node=0; 
			ourmsg.d_point=0;
		}
	
		/* And write header */	
		hdr=fopen(areahdr,"ab");
		if(hdr)
		{
			if(fwrite(&ourmsg,sizeof(QBBS_MHEADER),1,hdr)!=1)
				error++;
			fclose(hdr);
		}
		else 
			error++;
	}
	
	free(zebuffer);
	
	if(error)
	{
		logline(4,"Error while trying to post message");
		return BBSFAIL;
	}
	
	return BBSOK;
}

/* ==================================================== EMERGENCY EXIT */

void the_end(int exitn)
{
	logline(3,"Exiting LazyTick");
	close_areas();
	close_the_log();
	exit(exitn);
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
 * fgets who don't stop when string is full 
 */

char *fticgets(char *str, size_t len, FILE *fl)
{
	int idx=0,mychar;
	
	while(!feof(fl))
	{
		if(EOF==(mychar=fgetc(fl)))
			break;
			
		if(idx<(len-1))
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
 * case insensitive comparison of string ENDINGS 
 */

int strendcmp(char *one, char *two)
{
	if(strlen(one)>strlen(two))
		return stricmp(one+(strlen(one)-strlen(two)),two);
	else
		return stricmp(two+(strlen(two)-strlen(one)),one);
}

/*
 * xtol hexa to int
 */
 
unsigned long xtol(char *str)
{
	unsigned long temp;
	
	temp = 0;
	while(*str && isalnum(*str))
	{
		temp *= 16;
		temp += isdigit(*str) ? *str-'0' : toupper(*str)-'A'+10;
		str++;
	}
	return temp;
}

/*
 *	like nextstr but skip first ':'
 */
 
char *nextstrtic(char *str)
{
	if(*str==':')
		str++;
	return nextstr(str);
}

/*
 *	for tic file processing
 */
 
int strticcmp(char *one, char *key)
{
	return strnicmp(one,key,strlen(key));
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
/* open_the_log: open logfile <name> with <level>
   close_the_log: close logfile 
   logline: log line with <level>, printf syntax */

FILE *logfile=NULL;
int loglevel=0;

/* logline: Log a line in the logfile and output to screen */

void logline (int level, char *line, ...)
{
	time_t	timer;
	char	temp[2*BBSSTR], out[2*BBSSTR],tdate[20];
	va_list param;
	struct tm *tim;
	
	char ls[]=" -+*=!";
		
	if(level>5) level=5;
	if(level<0) level=0;
	
	/* process */
	va_start(param, line);
	vsprintf(temp, line, param);
	va_end(param);
	time (&timer);
	tim = localtime (&timer);
	strftime (tdate, 20, "%d %b %H:%M:%S", tim);
	sprintf (out, "%c %s %s %s\n", ls[level], tdate, LAZYLGID, temp);

	/* log to file */
	if(logfile && level>0)
	{
		fputs(out,logfile);
#ifdef DEBUG
		fflush(logfile);
#endif
	}
	printf(out);
}
 
/* openlog: create logfile */

int open_the_log(char *nm, int level)
{
	loglevel=level;
	logfile=fopen(nm,"a");
	if(logfile)
		return BBSOK;
	
	printf("Can't open logfile!\n");
	return BBSFAIL;
}

/* closelog: close logfile */

void close_the_log(void )
{
	if(logfile)
		fclose(logfile);
}
