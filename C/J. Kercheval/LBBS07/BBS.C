/*
 *	LazyBBS - The Ultimate BBS for Lazy People
 *	------------------------------------------
 *
 *	LazyBBS is a very simple BBS program for a Pandora Fidonet 
 *	message base (used by Led, Qbbs, Bermuda, IOS, etc on the Atari
 *	ST). And FILES.BBS-like download areas. It should be portable 
 *	on most operating systems supporting unix-like libraries,
 *	ANSI C libraries and compilers. It is especially useful 
 *	with the Fidonet package "Bermuda". The code is ugly, but 
 *	that's LAZYbbs :-).
 *
 *	Public domain: this program may be copied and sold freely.
 *	Suggestion: read the fine manual & state on modified versions 
 *	that these are not the original version and change the version 
 *	string in bbs.h.
 *
 *	Porting: 
 *	1) edit sysdep.c bbs.h
 *	2) compile sysdep.c miscio.c login.c linedit.c match.c msg.c bbs.c
 *	3) link to bbs
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>

#include <dirent.h> 	/* POSIX directory for download */
#include <sys/types.h>	/* for download's stat() */
#include <sys/stat.h>

#ifdef UNIX
#include <sys/ioctl.h>		/* for raw mode */
#include <termios.h>
#endif

#include "bbs.h"		/* constants & config */

#include "match.h"		/* regular expression library */
#include "linedit.h" 	/* line editor module */
#include "login.h"		/* login module */
#include "msg.h"		/* message module */
#include "sysdep.h"		/* LEVEL 0: low level, in main and download */
#include "miscio.h"		/* LEVEL 1: Misc and IO */

#define DEBUG /**/

#ifdef LATTICE /* for atari Lattice C 5 */
unsigned long _STACK=16000;
#endif

/* =================================================== PROTOTYPES */

int more(char *, int );
int upload(char *);
void do_download(char *);
int download(char *);
void global_download(char *);
int readmail(char *,char *,char *,int );
int writemail(char *,char *,char *,char *);
void lazyprompt(char *);
int domenu(char *,char *,char *);
void chat(void);
int main(int, char **);



/* ============================================================= MORE */

int more(char *text, int domore)
{
	char oneline[BBSSTR];
	FILE *txt;
	int line=1,capture=0,key=1,neubauten=1;
	
	if(!text)
		return BBSFAIL;
		
	txt=fopen(text,"r");
	if(!txt)
		return BBSFAIL;
	
	out_printf(CLS_STRING);
	
	while(fgets(oneline,BBSSTR,txt))
	{
		if(strlen(oneline)>79)
			strcpy(oneline+78,"\n");
		out_string(oneline);
		if(line%MORELINE==0 && domore)
		{ /* prompt */
			out_printf("\nMore? [Y]es [N]o [C]apture ");
			key=tolower(getkey());
			if(key=='c')
				capture++;
			if((key!='y') && (key!='\r') && (key!=' '))
			{
				neubauten=0; /* no enter return */
				break;
			}
			if(key<0)
				break;
			out_printf("\n");
		}
		line++;
	}
	fclose(txt);

	if(key<0)
		return BBSFAIL;
	else if(capture)
		more(text,0);
	
	if(domore && neubauten)
	{
		out_printf("\nEnter [Return].\n");
		if(getkey()<0)
			return BBSFAIL;
	}
	
	return BBSOK;
}

/* ======================================================= DOWNLOAD */

int upload(char *path)
{
	char temp[BBSSTR];
	int ret;
	
	out_printf(CLS_STRING);
	
	if(is_uguest())
	{
		out_printf("Guest user can't upload\n[Return]\n");
		getkey();
		return BBSOK;
	}
	
	out_printf( "\nEnter the name and description of the file who wanna upload or\n"
			"or enter to abort (example: \"unix.c PD source for a Unix system Vr5 clone\"\n>");
	if(getstring(temp)==BBSFAIL)
		return BBSFAIL;
	if(strlen(temp)<5)
		return BBSFAIL;
	
	logline(2,"User trying to upload %s",temp);
	ret=z_upload(path);
	logline(2,"User %s uploaded a file (protocol return=%d)",get_uname(),ret);
	
	return BBSOK;	
}

void do_download(char *file)
{
	long zesize;
	int ret;
	struct stat mystat;
		
	if(stat(file,&mystat))
	{
		out_printf("\nFile does not exist in this area! Hit [Return]\n");
		getkey();
	}
	else if(strchr(file,'*') || strchr(file,'?') || strchr(file,' '))
	{
		out_printf("\nWildcards and multiple files not allowed. Hit [Return]\n");
		getkey();
	}
	else
	{	
		zesize=mystat.st_size/1024;
		if(get_ucredit((int) zesize)==BBSFAIL)
		{
			out_printf("\nFile too large for today, try again later. Hit a key.\n\n");
			getkey();
			logline(3,"User tried to download over his/her credit limit! (size=%ld kb)",
					zesize);
		}
		else
		{
			ret=z_download(file);
			logline(3,"User downloaded file %s - %ld kb (protocol return=%d)",
					file, zesize, ret); 
		}
	}
}

int download(char *area)
{
	int line=1,key;
	struct stat mystat;
	char area2[BBSSTR];
	char *temp;
	char file[BBSSTR];
	char filebbs[BBSSTR];
	FILE *fbbs;
	int flag=0,domore=0;
	
	/* clean copy of area */
	strcpy(area2,area);
	addslash(area2);
	
	strcpy(filebbs,area2);
	strcat(filebbs,FILESBBS);
	
	fbbs=fopen(filebbs,"r");
	if(!fbbs)
	{
		logline(1,"Can't find files.bbs in area %s",area);
		return BBSFAIL;
	}
	
	temp=malloc(BBSSTR*10);
	if(!temp)
	{
		logline(1,"Can't malloc temp buffer in download()");
		return BBSFAIL;
	}
	
	out_printf(CLS_STRING);
	
	while(!flag)
	{
		if(fgets(temp,BBSSTR*5,fbbs))
		{
			if(!isalnum(*temp)) /* thats a comment */
			{
				if(strlen(temp)>75)
					strcpy(temp+72,"\n");
				out_string(temp);
			}
			else
			{ /* that's a file name */
				char filen[BBSSTR];
				char unknown[BBSSTR];
				char date[BBSSTR];
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
					if(line%MORELINE==0)
						domore++;
					if(desc[idx]==' ')
						lastspace=idx;
				
					if((idx-lastcut)>FBBSCUTLEN)
					{
						int j;

						for(j=0;j<FBBSSTART;j++)
							strspins(desc+lastspace+1+j);
						desc[lastspace+1]='\n';
						lastcut=idx=lastspace+FBBSSTART;
						
						line++;
					}
					idx++;
				}
				
				if(stat(file,&mystat))
					out_printf("%-12.12s *** MISSING *** %s\n",filen,desc);
				else
				{
					strftime(date,BBSSTR,"%d %b %y",localtime(&mystat.st_ctime));
					out_printf("%-12.12s %6ld %s %s\n",filen,(long) mystat.st_size,date,desc);
				}
			}
		}
		else
			flag++;
			
		/* MORE PROMPT */
		if(line%MORELINE==0 || flag || domore)
		{
			domore=0;
			out_printf("\nMore? [Y]es [N]o [Z]modem download ");
			key=tolower(getkey());
			
			if(key=='z')
			{ /* download */
				if(is_uguest())
				{
					out_printf("\nGuest user can't download!\n[Return]\n");
					getkey();
				}
				else
				{
					out_printf("\n\nEnter the name of the file you want to download with Zmodem:\n>");
					if(getstring(temp)==BBSOK)
					{
						strcpy(file,area2);
						strcat(file,temp);
						if(strlen(temp)>1) /* a name */
						{	
							do_download(file);
							break; /* quit */
						}
					} /* getstring */
				} /* guest */
			} /* download */
			
			if(key!='y')
				break;
			if(key<0)
				break;
			out_printf("\n");
		} /* more */
		line++;
	} /* lines */

	free(temp);
	fclose(fbbs);
	
	return BBSOK;
}

void global_download(char *config)
{
	char temp[BBSSTR],user_pat[BBSSTR],file[BBSSTR];
	FILE *pof;
	DIR *mydir;
	struct dirent *ent;
	int stop_search=0;
	
	int file_found=0;
	char *file_ptr;
	char file_temp[BBSSTR];	
	char file_dname[BBSSTR];
	
	if(is_uguest())
	{
		out_printf("Guest user can't download. Hit [Return].\n\n");
		getkey();
		return;
	}
	if(!config[0])
	{
		logline(3,"No global download config file!");
		return;
	}
	
	out_printf(CLS_STRING);
	out_printf("\nGlobal downloading: scan the hardisk for a file (<return> to exit).\n\n"
			"Please enter the name of the file you want to \ndownload (example: THING*.LZH)\n\n>");
	if(getstring(user_pat)==BBSOK)
	{
		if(strlen(user_pat)<4)
		{
			if(strlen(user_pat)!=0)
			{
				out_printf("Name too short! Hit a key.\n");
				getkey();
			}
		}
		else
		{
			out_printf("\n\n");
			
			pof=fopen(config,"r");
			if(pof)
			{
				while(fgets(temp,BBSSTR,pof) && !stop_search)
				{
					strcln(temp,-1);
					if(temp[0]!=0 && temp[0]!='#' 
						&& temp[0]!=';' && temp[0]!='@')
					{/* pof line is a path */
						addslash(temp);
						out_printf("Searching in %s\n",temp);
						
						mydir=opendir(temp);
						if(!mydir)
							logline(2,"Bad directory %s",temp);
						else
						{
							while( ((ent=readdir(mydir))!=NULL) 
									&& (!stop_search))
							{
								file_found=0; /* reset file */
								
								/* is it a file we search? */
								file_ptr=user_pat;
								do {
									strspacecpy(file_temp,file_ptr);
									strcpy(file_dname,ent->d_name);
#ifndef CASE_SENSITIVE
									strlwr(file_temp);
									strlwr(file_dname);
#endif									
									if(match(file_temp,file_dname)==TRUE)
										file_found++;
								} while((file_ptr=nextstr(file_ptr))!=NULL);
								
								
								if(file_found)
								{/* got it */
									int key;
																	
									out_printf("Found %s: [A]bort [C]ontinue [Z]modem download ?",ent->d_name);
									key=tolower(getkey());
									out_printf("\n");
									switch(key)
									{
										case 'c':
										case ' ':
										case '\r':
										break;
										case 'z':
										strcpy(file,temp);
										strcat(file,ent->d_name);
										do_download(file);
										break;
										default:
										case 'a':
										stop_search++;
										break;
									}
								}
							}
							closedir(mydir);
						}
					}
				}
				fclose(pof);
			}
		}
	}
}

/* ================================================================= MAIL */

int readmail(char *command, char *netmail, char *fromaddr, int okwrite)
{
	ECHOLIST *entry;
	
	out_printf(CLS_STRING);
	
	if(stricmp(command,"_private"))
	{ /* echomail */
		do {
			out_printf(CLS_STRING);
			out_printf("Read an echomail area....\n\n");
			entry=choose_area(command);
			if(entry)
				read_messages(entry->name, entry->file, get_uname(), fromaddr, 0, okwrite);
		} while(entry);
	}
	else
	{ /* netmail */
		if(is_uguest())
		{
			out_printf("Guest user can't read netmail. Hit [Return]\n");
			getkey();
		}
		else
		{
			/* logline(5,"User reading netmail"); */
			read_messages("* Netmail *",netmail,get_uname(),fromaddr,1,1);
			/* init mail prompt */
			reset_new_mail();
		}
	}
	return BBSOK;
}

/*
 *	Write a mail message
 */

int writemail(char *command, char *netmail, char *fromaddr, char *uucpgate)
{
	char toaddr[BBSSTR],name[BBSSTR],subject[BBSSTR];
	int private=0;
	int errorfl=0;
	ECHOLIST *entry;
	
	out_printf(CLS_STRING);
	if(is_uguest())
	{
		out_printf("Guest user can't write mail.\n\n[Return]\n");
		getkey();
		return BBSOK;
	}
	
	logline(5,"User trying to write mail (%s)",command);
	
	strcpy(toaddr,fromaddr); /* deflt */
	
	if(!strcmp(command,"_sysop") || !strcmp(command,"_local") || !strcmp(command,"_fido") || !strcmp(command,"_uucp"))
	{	
		private++;
		out_printf("\nLazyBBS Mail - Send a private mail\n\n\n");
	
		if(!strcmp(command,"_sysop"))
		{
			out_printf("Mail to sysop.\n");
			strcpy(name,"Sysop");
		}
		else
		{ 
			/* get to name */
			if(!strcmp(command,"_uucp"))
				out_printf("\nEnter INTERNET address of recipient (Example: \"cynthia@lazy.com\")\n>");
			else
				out_printf("\nWrite the name of the recipient of the message (example: \"Amelie.Cecile Vloupf\")\n>");
				
			if(getstring(name)==BBSFAIL)
				return BBSFAIL;
			out_printf("\n");
			
			/* no name? */
			if(strlen(name)<5)
				return BBSFAIL;
			
			if(strlen(name)>35)
			{
				out_printf("Name too long! Hit a key.\n");
				getkey();
				return BBSFAIL;
			}
		}
	
		if(strcmp(command,"_sysop") && strcmp(command,"_local") && strcmp(command,"_uucp"))
		{ /* get to address */
			out_printf("\n\nWrite the fidonet address of the recipient of\n"
					"the message (example: \"2:345/678.0\")\n>");
			if(getstring(toaddr)==BBSFAIL)
				return BBSFAIL;
				
			if((strlen(toaddr)<5) || (strlen(toaddr)>30))
				return BBSFAIL;
/* fixme: check nodelist? */
		}
		
		if(!strcmp(command,"_uucp"))
			strcpy(toaddr,uucpgate);
	}
	else
	{ /* echomail */
		out_printf("Write an echomail message to area....\n\n");
		entry=choose_area(command);
		if(!entry)
			return BBSFAIL;
		strcpy(name,"All");
	}
	
	out_printf("\n\nSubject of the message? (example: \"How are you?\")\n>");
	if(getstring(subject)==BBSFAIL)
		return BBSFAIL;
		
	if(strlen(subject)<3)
		return BBSFAIL;
		
	if(strlen(subject)>69)
	{
		out_printf("Subject too long. Message canceled. Hit [Return].\n");
		getkey();
		return BBSFAIL;
	}
	
	out_printf(CLS_STRING);
	
	out_printf("    This will be a %s message to %s.\n",private ? "PRIVATE" : "*PUBLIC*",
				private ? name : entry->name);
	out_printf("    Subject: %s.\n",subject);

	if(!strcmp(command,"_uucp"))
	{
		FILE *truc;
		truc=fopen(tempfile(),"w");
		if(!truc)
			return BBSFAIL;
		fprintf(truc,"To: %s",name);
		fclose(truc);
		strcpy(toaddr,uucpgate);
		strcpy(name,"Uucp");
	}	
	
	if(edit_file(tempfile())==BBSFAIL)
		errorfl++;
	else
	{
		out_printf("\n\nDo you want to send your mail to %s on %s? [Y/n]\n",
			name, private ? toaddr : entry->name);
		
		if(tolower(getkey())!='n')
		{	
			if(private)
				logline(2,"User %s wrote private mail to %s @ %s",get_uname(),name,toaddr);
			else
				logline(2,"User wrote echomail in area %s",entry->name);

			postmsg(get_uname(),fromaddr,name,toaddr,subject,
				private ? netmail : entry->file, tempfile(), private);
		}
	}	
	
	remove(tempfile());
	if(errorfl)
		return BBSFAIL;
	return BBSOK;
}

/* =================================================== MENU PROCESSOR */

void lazyprompt(char *pr)
{
	int i;
	if(!pr || !*pr)
		return;
		
	for(i=0;i<strlen(pr)-1;i++)
		out_char('=');
	out_char('>');
	for(i=0;i<strlen(pr);i++)
		out_char('\b');
	out_string(pr);
	out_char(' ');
}

int domenu(char *menu, char *command, char *prompt)
{
	FILE *txt;
	int curkey=0,found=0,i,userkey;
	struct domenuKey {
		int key;
		char command[BBSSTR];
	} *keys;
	char oneline[BBSSTR];
	
	*command=0;
		
	if(!menu)
		return BBSFAIL;

	keys=malloc(MAXKEYS*sizeof(struct domenuKey));
	if(!keys)
		return BBSFAIL;
	
	txt=fopen(menu,"r");
	if(!txt)
	{
		free(keys);
		return BBSFAIL;
	}
	
	out_printf(CLS_STRING);
	/* display remaining time at the top menu */
	out_printf("%d mn ",(get_endsession()-clock())/(CLK_TCK*60));
	/* display mail reminder */
	if(has_new_mail())
		out_printf("Mail! ");		
	
	while(fgets(oneline,BBSSTR,txt))
	{
		if(strlen(oneline)>79)
			strcpy(oneline+78,"\n");
		
		if(strncmp(oneline,"$/",2) && strncmp(oneline,"$#",2))
			out_string(oneline);
		else 
		{ /* that's a key */
			strcln(oneline,-1);

#ifdef OLD_CODE
			if(curkey<MAXKEYS)
			{
				if(strlen(oneline)>4);
				{
					keys[curkey].key=tolower(oneline[2]);
					strcpy(keys[curkey].command,oneline+4);
					curkey++;
				}
			}
#else
			if(curkey<MAXKEYS)
			{
				int i=1;
				int userhasfl=0;
				int thereisfl=0;
				
				while(oneline[i])
				{
					if(oneline[i]=='/') /* end of flags */
					{
						if(oneline[i+1] && (oneline[i+2]=='=') && oneline[i+3])
						{
							keys[curkey].key=tolower(oneline[i+1]);
							if(!thereisfl || userhasfl!=0)
								strcpy(keys[curkey].command,oneline+i+3);
							else
								strcpy(keys[curkey].command,"_forbidden");
							curkey++;
						}
					}
					
					if(isalpha(oneline[i])) /* this is a flag */
					{
						thereisfl++;
						if(get_uflag(oneline[i])==BBSOK)
							userhasfl++;
					}
					
					i++;
				}
			} /* END space in table */
#endif
		}
	}
	fclose(txt);
	
	lazyprompt(prompt);
	
	while(!found)
	{
		userkey=getkey();
		if(userkey<0)
			break;
#ifdef CHAT_HOTKEY
		if(user_key==CHAT_HOTKEY)
			chat();
#endif	
		out_char(8); /* backspace to delete the key */
	
		for(i=0;i<curkey;i++)
		{	
			if(tolower(userkey)==keys[i].key)
			{
				if(!strcmp(keys[i].command,"_forbidden"))
				{
					out_printf("\nYou must be granted access to this menu item.\n");
					lazyprompt(prompt);
				}
				else
				{
					strcpy(command,keys[i].command);
					found++;
				}
			}
		}
	}
	
	free(keys);
	
	if(userkey<0)
		return BBSFAIL;
	return BBSOK;
}

/* ============================================================ CHAT  */

int enablechat=0;

void chat(void )
{
	unsigned char truc;
	
	if(!enablechat)
		return;
		
	logline(4,"Entering chat mode");
	out_printf("\7"); /* call sysop */
	
	out_printf(CLS_STRING);
	out_printf("Entered chat mode. Type '%' to exit.\n\n");
	do {
		truc=getkey();
	} while(truc!='%' && truc!=3 && truc!=4);
}

/* ================================================================== */

int main(int argc, char **argv)
{
	FILE *cf;
	int i;
	struct stat statbuf;
	char llog[BBSSTR];
	char aareas[BBSSTR];
	char topmenu[BBSSTR];
	char netarea[BBSSTR];
	char prompt[BBSSTR];
	char uugateway[BBSSTR];
	char pof_file[BBSSTR];
	char from[BBSSTR];
	char temp[BBSSTR];
	char *next;

#ifdef UNIX
 	/* set stdin in raw mode */
#if 0
  	struct sgttyb buf;
  	ioctl (0, TIOCGETP, &buf);
 	buf.sg_flags |= RAW;
  	ioctl (0, TIOCSETP, &buf);
#else
 	struct termios tios;
 	tcgetattr (0, &tios);
 	tios.c_lflag&= ~(ICANON+ECHOCTL);
 	tcsetattr (0, TCSANOW, &tios);
#endif
#endif
	
	/* default values */	
	strcpy(llog,DEFLOGFILE);
	strcpy(aareas,AREASFILE);
	strcpy(netarea,"netmail");
	strcpy(from,"2:345/678.9");
	strcpy(prompt,"LazyBBS>");
	uugateway[0]=0;
	pof_file[0]=0;

	/* init */
	set_endsession(D_TIMEOUT);
	strcpy(topmenu,TOPMENU);
	
	/* parse command line */
	for(i=1;i<argc;i++)
	{	
		if(!stricmp(argv[i],"-c"))
			enable_watch();
		if(!strnicmp(argv[i],"-d",2))
		{
			if(sysdep_dupeio(argv[i]+2)==BBSFAIL)
				printf("Can't dupe I/O\n");
			enablechat++;
		}
		if(!stricmp(argv[i],"-g"))
			setgod();
	}
		
	/* read config file */
	cf=fopen(CONFIGFILE,"r");
	if(!cf)
		printf("Can't read config file! Using default values\n");
	else
	{
		while(fgets(temp,BBSSTR,cf))
		{
			strcln(temp,-1);
			next=nextstr(temp);
			if(next && !iscomment(*temp))
			{
				if(!strnicmp(temp,"address",strlen("address")))
					strspacecpy(from,next);
				else if(!strnicmp(temp,"prompt",strlen("prompt")))
					strspacecpy(prompt,next);
				else if(!strnicmp(temp,"logfile",strlen("logfile")))
					strspacecpy(llog,next);
				else if(!strnicmp(temp,"areascfg",strlen("areascfg")))
					strspacecpy(aareas,next);
				else if(!strnicmp(temp,"netmail",strlen("netmail")))
					strspacecpy(netarea,next);
				else if(!strnicmp(temp,"uucpgate",strlen("netmail")))
					strspacecpy(uugateway,next);
				else if(!strnicmp(temp,"global",strlen("global")))
					strspacecpy(pof_file,next);
				else if(!strnicmp(temp,"maxdown",strlen("maxdown")))
					set_maxdown(atoi(next));
				else if(!strnicmp(temp,"maxtime",strlen("maxtime")))
					set_endsession(atoi(next));
			}
		}
		fclose(cf);
	}
	
	/* set net area ptr for other modules */
	set_netarea(netarea);
	
	/* init */
	open_the_log(llog,0);
	logline(4,"LazyBBS version %s started.",LAZYVERS);

	more(INTRO,0); /* optional welcome page */
	
	if(open_login()==BBSFAIL)
	{
		logline(1,"Login failed");
		close_the_log();
		return 10;
	}
	
	if(get_areas(aareas)==BBSFAIL)
		logline(1,"Can't read areas.bbs");
	
	/* print 1st page */
	if(more(WELCOME,1)!=BBSOK)
		logline(2,"Can't display welcome page");
	
	/* hotnews */
	if(!stat(HOTNEWS,&statbuf))
	{	/* there's hotnews */
		if((timet2nix(statbuf.st_mtime)/86400)>=get_ulastlogin())
			more(HOTNEWS,1);
	}
	
	/* start menu processor */
	{
		char comline[BBSSTR];
		char command[BBSSTR];
		char curmenu[BBSSTR];
		char *parameter;
		int status=BBSOK;
		
		strcpy(curmenu,topmenu);
		
		while(1)
		{
			if(domenu(curmenu,comline,prompt)==BBSFAIL)
				break;

			/* else command valid */
			parameter=nextstr(comline); /* parse! */
			if(parameter)
				strspacecpy(command,comline);
			else
				strcpy(command,comline);
				
			if(!stricmp(command,"top"))
				strcpy(curmenu,topmenu);
			else if(!stricmp(command,"gdown"))
				global_download(pof_file);
			else if(!stricmp(command,"hangup"))
				break;
			else if(!stricmp(command,"chat"))
				chat();
			else if(!stricmp(command,"info"))
			{
				out_printf(CLS_STRING);
				out_printf("LazyBBS - The Ultimate BBS for Lazy People\n\n"
						"Version    : %s\nCompiled on: %s\nPlatform   : %s\n\n",
						LAZYVERS,__DATE__,MACHINE);
				out_printf("Squeeze [Return]\n");
				getkey();
			}
			else if(!stricmp(command,"userinfo"))
				display_login();
			else if(!stricmp(command,"password"))
				change_password();
			else if(!parameter) /* only parametred command staying */
				logline(1,"syntax error in %s",curmenu);
			else if(!stricmp(command,"more"))
				status=more(parameter,1); 
			else if(!stricmp(command,"menu"))
				strcpy(curmenu,parameter);
			else if(!stricmp(command,"read"))
				status=readmail(parameter,netarea,from,0);
			else if(!stricmp(command,"readw"))
				status=readmail(parameter,netarea,from,1);
			else if(!stricmp(command,"download"))
				status=download(parameter);
			else if(!stricmp(command,"write"))
				status=writemail(parameter,netarea,from,uugateway);
			else if(!stricmp(command,"upload"))
				status=upload(parameter);
			else
			{
				logline(1,"Unknown command in %s (%s)",comline,curmenu);
				break;
			}
		}
	}
	
	if(more(BYE,0)!=BBSOK)
		logline(2,"Bye error");
			
	the_end();
	return 0;
}

/*eof*/