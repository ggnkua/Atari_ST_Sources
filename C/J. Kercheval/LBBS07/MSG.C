/*
 *	Read/Write a Pandora message base
 *	(LazyBBS Project)
 *   
 *	Public Domain: may be copied and sold freely
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
/*#include	<portab.h>*/
#include	<ctype.h>
#include	<string.h>

#include	<sys/types.h>	/* for (empty) display in echolist */
#include	<sys/stat.h>

#include	"qbbs.h"

#include	"bbs.h"
#include	"login.h"
#include	"miscio.h"
#include 	"msg.h"
#include    "linedit.h" /* edit_file() */
#include	"sysdep.h"	/* timenix() */

#define MAXLINE 23		 /* max line / screen */
#define HEADLEN 6		 /* displayed message header len */

#define MLINLEN 79		 /* display message line len */
#define MSGSIZE 32000	 /* Max message size */
#define MSGLINE (MSGSIZE/(MLINLEN+1))

#define BUFSIZE 1024 	 /* Copy buffer */
#define USEPID			 /* define to use ^PID kludge */
#define PIDSTR	LAZYNAME /* PID name */
#define PIDVER  LAZYVERS /* PID version */

/* ===================================================== ECHOLIST */

ECHOLIST *el=NULL;
int maxel=0;

void close_areas(void )
{
	if(el)
		free(el);
}

ECHOLIST *choose_area(char *group)
{
	char temp[BBSSTR];
	int i;
	int j=1;
	int empty=0;
	struct stat mystat;
	ECHOLIST *found=NULL;
	int *numbers=malloc((maxel+1)*sizeof(int));
	
	if(!numbers)
	{
		logline(1,"Can't malloc in choose_area");
		return NULL;
		
	}
	if(!el)
	{
		free(numbers);
		return NULL;
	}
	
	out_printf(CLS_STRING);
	
	out_printf(" #  | Area              | Description\n"
	       "----+-------------------+------------------------------------\n");
	for(i=0;i<maxel;i++)
	{
		int bool;
		
		if(group)
			bool=stricmp(group,el[i].group);
		if(!bool || !group)
		{
			empty=0;
			
			strcpy(temp,el[i].file);
			strcat(temp,".HDR");
			
			/* display no number if message base !exist or empty */
			if(!stat(temp,&mystat))
			{ /* does exist */
				if(mystat.st_size==0)
					empty++;
			}
			else
				empty++;
			
			if(empty)	
				out_printf(" %2d | %-17.17s | %s (empty)\n",j,el[i].name,el[i].desc);
			else 
				out_printf(" %2d | %-17.17s | %s\n",j,el[i].name,el[i].desc);
			numbers[j]=i;
			j++;
		}
	}
	out_printf("\nType the number of your area or <return> to exit: ");
	if(getstring(temp)==BBSOK)
	{
		int tt;
		tt=atoi(temp); 
		if(tt>0 && tt<j)
			found=el+numbers[tt];
	}
	
	free(numbers);
	return found;
}

int get_areas(char *path)
{
	FILE *abbs;
	char fname[BBSSTR];
	char curgroup[BBSSTR];
	char curdesc[BBSSTR];
	char buffer[200];
	int i;
	int curarea=0;
	char *ptr;
	
	el=malloc(sizeof(ECHOLIST)*MAXECHO+1);
	if(!el)
	{
		logline(1,"Can't malloc echolist!");
		return BBSFAIL;
	}
	
	strcpy(curgroup,"none");
	strcpy(fname,path);
	strcat(fname,"areas.bbs");
	
	strcpy(curdesc,"No description.");
	
	abbs=fopen(fname,"r");
	if(abbs)
	{
		if(fgets(buffer,199,abbs)!=NULL)
		{ /* skip origin line */	
			while(fgets(buffer,199,abbs)!=NULL)
			{
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
					if(strnicmp(buffer,"passthru",strlen("passthru")))
					{ /* !passthru area */
						strspacecpy(el[curarea].file,buffer);
						ptr=nextstr(buffer);
						if(ptr)
						{
							strcpy(el[curarea].group,curgroup);
							strcpy(el[curarea].desc,curdesc);
							strspacecpy(el[curarea].name,ptr);

#ifdef RESERVED_FOR_FUTURE			
							/* search zone number */
							el[curarea].zone=defzone;
							ptr=nextstr(ptr);
							if(ptr)
							{
								if((ptr[1]==':') || (ptr[2]==':') || (ptr[3]==':') || (ptr[4]==':'))
								{
									if(isdigit(*ptr))
										el[curarea].zone=atoi(ptr);
								}
							}
#endif

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
		
/* reset desc 
	for(i=0;i<curarea;i++)
		strcpy(el[i].desc, "Unknown.");
*/	
	/* reading areafix bbs for descritions */
	strcpy(fname,path);
	strcat(fname,"areafix.bbs");
	
	abbs=fopen(fname,"r");
	if(abbs)
	{
		char cmp[BBSSTR];
		
		while(fgets(buffer,199,abbs)!=NULL)
		{
			if(iscomment(*buffer))
			{
				strspacecpy(cmp,buffer);
				ptr=strchr(buffer,';');
				if(ptr)
				{
					if(strlen(ptr)>=BBSSTR-1)
						ptr[BBSSTR-2]='\0';
						
					for(i=0;i<curarea;i++)
					{
						if(stricmp(el[i].name, cmp)==0)
							strcpy(el[i].desc, ptr+1);
					}
				}
			}
		}
		fclose(abbs);
	}
		
	maxel=curarea;
	return BBSOK;
}
/* ======================================= post to a pandora message base */

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
	
	zebuffer=malloc(BUFSIZE+1);
	if(!zebuffer)
	{
		logline(1,"can't malloc postmsg buffer");
		return BBSFAIL;
	}
	
	/* convert addresses */
	if(toaddr)
		sscanf(toaddr,"%d:%d/%d.%d",&dzone,&dnet,&dnode,&dpoint);
	sscanf(fromaddr,"%d:%d/%d.%d",&ozone,&onet,&onode,&opoint);
	
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
		logline(1,"Error while trying to post message");
		return BBSFAIL;
	}
	
	return BBSOK;
}

/* ======================================================= message buffer */

#define BufLine(a) (buffer+xbufline[a])

#define IsNotKludge(a)	((*a!=1) && strncmp(a,"SEEN-BY:",(size_t)strlen("SEEN-BY:")))

/* load_msgbuf: <0 error */

int xbufline[MSGLINE]; 

/* unsigned bugs, why? */

int load_msgbuf(char *file, long index, unsigned int len, char *buffer)
{
	int line=0;
	FILE *ms;
	
	ms=fopen(file,"rb");
	if(ms)
	{
		/* set to index */
		if(fseek(ms,index,SEEK_SET)>=0)
		{
			if(fread(buffer,min(MSGSIZE-1,len),1,ms)!=1)
			{
				logline(1,"fread error while loading message text");
				*buffer=0;
				line=-1;
			} 
			else
			{ /* succesfully read */
				int lastspace=0;
				int mysize=0;
				
				line=1;
				xbufline[0]=0;
				
				while(mysize<min(MSGSIZE-1,len))
				{
					/* last space */
					if(buffer[mysize]==' ')
						lastspace=mysize;

					/* one more line for \n */
					if(buffer[mysize]=='\n')
					{
						xbufline[line]=lastspace=mysize+1;
						buffer[mysize]=0;
						line++;
					}
					
					/* one more line for long lines */
					if(mysize-xbufline[line-1]>=MLINLEN)
					{
						xbufline[line]=max(lastspace,mysize-(MLINLEN/3))+1;
						buffer[xbufline[line]-1]=0;
						line++;
					}
					
					/* clean */
					if(buffer[mysize]<0x20 && buffer[mysize]>1)
						buffer[mysize]='@';
				
					if(line>=MSGLINE-2)
						break; /* max # of lines */
									
					mysize++;
				}
			}
		}
		fclose(ms);
	}
	else
		line=-1;
	
	return line-1; /*fixed?*/
}

/* new mail */

int is_newmail(char *netarea, int *newm, int *newnewm)
{
	char fnam[BBSSTR];
	char user[BBSSTR];
	
	FILE *myfp;
	QBBS_MHEADER curhead;
	
	strcpy(fnam,netarea);
	strcat(fnam,".HDR");
	strcpy(user,get_uname());
	
	*newm=*newnewm=0;
	
	myfp=fopen(fnam,"rb");
	if(!myfp)
	{
		logline(4,"Can't open netmail header %s",fnam);
		return BBSFAIL;
	}
	
	while(fread(&curhead,sizeof(QBBS_MHEADER),1,myfp)==1)
	{
		if(stricmp(curhead.to,user)==0)
		{
			(*newm)++;
			if((curhead.attrib & RCVDFLAG)==0)
				(*newnewm)++;
		}
	}
	
	fclose(myfp);
	return BBSOK;
}

/* ============================================= display list of messages */

void list_messages(FILE *hd, char *from, int counter)
{
	QBBS_MHEADER header;
	char anskey;
	int end=0;
	int i;

	out_printf(CLS_STRING);
	out_printf("Nb  From                 To                   Subject\n"
		   "--------------------------------------------------------------------------\n");
	
	while(1)
	{
		i=2;
		while(i<MAXLINE)
		{
			if(fread(&header,sizeof(QBBS_MHEADER),1,hd)!=1)
			{
				end++;
				break;
			}
			counter++; /* increment display counter */

			
			if(
				(
					(	((header.attrib & PRVTFLAG)==0)		/* not pvt */
				 	||	(stricmp(from,header.from)==0) 		/* from guy */
				 	||  (stricmp(from,header.to)==0)  )		/* to guy */
					&&
					((header.attrib & KILLFLAG)==0) 
				)
			   	|| 
			   	isgod()
			   )
			{ 
				out_printf("%-3.3d %-20.20s %-20.20s %-30.30s\n",counter,header.from,header.to,header.subject);
				i++;
			}
		}
		
		if(end)
		{
			out_printf("\nEnd of list. Type [return].\n");
			getkey();
			break;
		}
		
		out_printf("\n[M]ore [B]ack to messages ?");
		
		anskey=toupper(getkey());
		if(anskey!='M' && anskey!=' ')
			break;
		
		out_printf("\n");
	} /* main loop */
}

/* ======================= read a message base, should log itself errors */

void read_messages(char *area, char *path, char *from, 
		char *fromaddr, int pvt, int okwrite)
{
	char *buffer;
	int msgidx,maxline;
	long nbmsg;
	int no=0;
	int did,nodisplay;
	int doquote=0;
	int previous=0;
	int havedisplayed=0;
	int true, curline,i;
	FILE *hd, *quotef;
	QBBS_MHEADER curhead;
	char areahdr[FILENAME_MAX];
	char areamsg[FILENAME_MAX];
	char entb[30];
	int retchar;
	
	buffer=malloc(MSGSIZE);
	if(buffer)
	{
		logline(3,"Reading area %s",area);
		out_printf(CLS_STRING);
		out_printf("Loading...\n");

		/* create area datafiles names */
		strcpy(areahdr,path);
		strcat(areahdr,".HDR");
		strcpy(areamsg,path);
		strcat(areamsg,".MSG");
	
		hd=fopen(areahdr,pvt ? "rb+" : "rb"); /* write to update rcvd flag */
		if(hd)
		{
			/* check empty */
			fseek(hd,0,SEEK_END);
			nbmsg=ftell(hd);
			if(nbmsg>0)
			{
				nbmsg=nbmsg/sizeof(QBBS_MHEADER);
				rewind(hd);
									
				msgidx=0;
				
				/* find "lastread", place on stamp based on last login */
				if(!pvt) /* echomail: first new message since last login (DAY(stamp)>LAST_LOGIN) */
				{
					int idx=0;
					int last=get_ulastlogin();
					
					while(fread(&curhead,sizeof(QBBS_MHEADER),1,hd)==1)
					{
						if(curhead.stamp/86400>=last)
						{
							msgidx=idx;
							break;
						}
						idx++;
					}
				}
				else /* pvt: 1st message !rcv */
				{
					int idx=0;
					
					while(fread(&curhead,sizeof(QBBS_MHEADER),1,hd)==1)
					{
						if( ((curhead.attrib & RCVDFLAG)==0)
						  && (stricmp(from,curhead.to)==0) )
						{
							msgidx=idx;
							break;
						}
						idx++;
					}
				}
				
				
				out_printf(CLS_STRING);
				
				/* message loop */
				do {
					nodisplay=0;
					
					/* read header msgidx */
					if(fseek(hd,sizeof(QBBS_MHEADER)*msgidx,SEEK_SET)<0)
					{
						logline(4,"fseek() error on %s",areahdr);
						break;
					}
					if(fread(&curhead,sizeof(QBBS_MHEADER),1,hd)!=1)
					{
						logline(4,"fread() error on %s",areahdr);
						break;
					}
					
					if(pvt) /* netmail */
					{
						if(
							!isgod()
						  &&
							( ((curhead.attrib & PRVTFLAG)==0)
							|| ((curhead.attrib & KILLFLAG)!=0)
							|| ( (stricmp(from,curhead.from)!=0)
					        && (stricmp(from,curhead.to)!=0) ) )
					      )
					      	nodisplay++;
						/*{
							if(msgidx<nbmsg-1)
								msgidx++;
							else
								break;
							nodisplay++; 
						}*/
/* fixme, afficher un msg ? */
					}
					else if((curhead.attrib & KILLFLAG) || 
						(curhead.attrib & PRVTFLAG))
						nodisplay++;
					
					if(nodisplay)/* search a displayable message */
					{ /* echomail */
						if(msgidx<nbmsg-1 && !previous)
							msgidx++;
						else if(msgidx>0 && previous)
							msgidx--;
						else
							break;
					}
					else
					{ /* display message */
						previous=0; /* we finally got one backwards, can reset flag */
						havedisplayed++;
							
						if(pvt) /* netmail: log & update rcvd flag */
						{
							if( ((curhead.attrib & RCVDFLAG)==0)
							  && (stricmp(from,curhead.to)==0) )
							{
								logline(1,"User reading netmail from %s to %s",
											curhead.from,curhead.to);
								curhead.attrib|=RCVDFLAG;
							
								/* update header */
								if(fseek(hd,sizeof(QBBS_MHEADER)*msgidx,SEEK_SET)<0)
								{
									logline(4,"fseek() error on %s",areahdr);
									break;
								}
								
								if(fwrite(&curhead,sizeof(QBBS_MHEADER),1,hd)!=1)
									logline(4,"Write error during rcvd flag update");
							}
						} /* end update rcvd flag */
					
						out_printf(CLS_STRING);
						/* display header */
						out_printf("[message %d/%d of %s]\n",
							msgidx+1,(int)nbmsg,area);
						
						if(pvt)
						{
							out_printf("From : %s on %d:%d/%d.%d\n",
								curhead.from,curhead.o_zone,curhead.o_net,
								curhead.o_node,curhead.o_point);
							out_printf("To   : %s on %d:%d/%d.%d\n",
								curhead.to,curhead.d_zone,curhead.d_net,
								curhead.d_node,curhead.d_point);
						}
						else
							out_printf("From : %s\nTo   : %s\n",curhead.from,curhead.to);
						
						out_printf("Date : %s\nSubj.: %s\n"
							"==========================================================================\n",
							curhead.time,curhead.subject);

						/* display message */
						true=1;
						curline=0;
						
					    /* load the message */
						maxline=load_msgbuf(areamsg,curhead.msgoffset,
								(unsigned int)curhead.size,buffer);
						
						if(maxline<=0)
						{
							out_printf(CLS_STRING);
							out_printf("No message.\n");
							break;
						}
						
						curline=i=0;
						while(i<(MAXLINE-HEADLEN))
						{
							if(curline>=maxline) 
								break;
							if(IsNotKludge(BufLine(curline)) || isgod())
							{
								out_string(BufLine(curline));
								out_printf("\n");
								i++;
							}
							curline++;
						}
						
						true=1;
						while(true) /* scroll loop inside message */
						{
							if(okwrite)
								out_printf("[M]ore [H]ome / [P]revious [N]ext [G]oto msg / [L]ist [R]eply [Q]uit ?");
							else
								out_printf("[M]ore [H]ome / [P]revious [N]ext [G]oto message / [L]ist [Q]uit ?"); 
							retchar=getkey();
							retchar=toupper(retchar);
							out_printf(ERASE_LINE);
							switch(retchar)
							{
								/* MORE of the message */
								case 'M':
								case ' ':
								case '\r': /* cr */
								did=0;
								for(i=0;i<MAXLINE-5;i++)
								{
									if(curline<maxline)
									{
										if(IsNotKludge(BufLine(curline)) || isgod())
										{
											out_string(BufLine(curline));
											out_printf("\n");
										}
										curline++;
										did++;
									}
									else
										break;
								}
								if(!did) /* if end of page, next message */
								{
									retchar='>';
									true=0;
								}
								break;
													
								/* MORE line */
								case '+':
								/* case DOWNARROW:*/
								if(curline<maxline)
								{
									out_string(BufLine(curline));
									out_printf("\n");
									curline++;
								}
								break;
								
								/* All other keys */
								case 'R': /* quote current mail */
								if(okwrite)
								{ /* if allowed to write */
									doquote++;
									quotef=fopen(tempfile(),"w");
									if(quotef)
									{
										fprintf(quotef,"In a message of <%s>, %s writes:\n\n",
											curhead.time,curhead.from);
										for(i=0;i<maxline;i++)
										{
											if(IsNotKludge(BufLine(i)))
												fprintf(quotef,"> %-65.65s\n",BufLine(i));
										}
										fclose(quotef);
									}
									else
										logline(3,"Can't open tempfile.");
								}
								/* end of processing after fclose()s */
								case 'P':
								case '<':
								/*case LEFTARROW:*/
								case 'N':
								case '>':
								/*case RIGHTARROW:*/
								case 'G':
								case 'Q':
								case '!':
								case 'H':
								case 'L':
								case '-':
								case '*':
								case 3: /* ctrl+C */
								true=0;
								break;
							}
						} /* end scroll loop inside message */
						
						if(retchar=='Q' || retchar=='\03' 
							|| retchar=='!' || retchar=='R')
							break; /* bye */
						else switch(retchar)
						{
							/* list messages */
							case 'L':
							list_messages(hd,from,msgidx+1); 
							/* HOME */
							case '*':
							case 'H':
							case '-':
							out_printf(CLS_STRING);
							break;
							
							/* previous message */
							case 'P':
							case '<':
							/* case LEFTARROW:*/
							if(msgidx>0)
							{
								msgidx--;
								previous++;
							}
							else
								out_printf("\7");
							break;

							/* next message */							
							case 'N':
							case '>':
							/* case RIGHTARROW:*/
							if(msgidx<nbmsg-1)
								msgidx++;
							else
								out_printf("\7");
							break;
							
							/* goto message */
							case 'G':
							out_printf(CLS_STRING);
							out_printf("\nGoto message number (<Return> to cancel)?");
							if(getstring(entb)==BBSOK)
							{
								msgidx=atoi(entb)-1;
								if(msgidx<0 || msgidx>=nbmsg)
									msgidx=0;
							}
							out_printf("\n");
							break;
						}
					} /* nodisplay */
				} while(retchar!='Q' && retchar!='\03' && retchar!='!');
				/* ctrl+C, Q */
			}
			else
				no++;
				
			fclose(hd);
		}
		else
			no++;
			
		/* finish quote processing */
		if(doquote)
		{
			char toaddr[BBSSTR];
	
			if(is_uguest())
			{
				out_printf(CLS_STRING);
				out_printf("Guest user can't quote mail.\n\n[Return]\n");
				getkey();
			}
			else
			{
				logline(5,"User trying to quote mail (%s)",area);
				out_printf("\n\nDo you really want to quote mail? [Y/n]");
	
				if(tolower(getkey())!='n')
				{
					out_printf(CLS_STRING);
					out_printf("    This will be a %s message to %s.\n",
							pvt ? "PRIVATE" : "*PUBLIC*", 
							pvt ? curhead.from : area);
							
					out_printf("    Subject: %s.\n",curhead.subject);
	
					sprintf(toaddr,"%d:%d/%d.%d",
								curhead.o_zone,curhead.o_net,
								curhead.o_node,curhead.o_point);
								
					if(edit_file(tempfile())==BBSOK)
					{
						out_printf("\n\nDo you want to send your mail to %s on %s [y/N]?\n",
							curhead.from, pvt ? toaddr : area);
		
						if(tolower(getkey())=='y')
						{
							if(pvt)
								logline(2,"User wrote netmail to %s",curhead.from);
							else
								logline(2,"User wrote echomail in area %s",area);
								
							postmsg(get_uname(),fromaddr,curhead.from,toaddr,
								curhead.subject,path,tempfile(),pvt);
						}
					}
				}
			}
			remove(tempfile());
		} /* quote */
		
		if(no)
		{
			logline(3,"No message base %s",areahdr);
			out_printf(CLS_STRING);
			out_printf("No message base!\n\n");
			out_printf("Type a key.\n");
			getkey();
		}
		
		if(pvt && !havedisplayed)
		{
			out_printf("You have no mail waiting! Hit [Return].\n");
			getkey();
		}
		
		free(buffer);
	}
	else
		logline(4,"Can't allocate message buffer");
}
