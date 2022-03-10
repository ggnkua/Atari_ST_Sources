/*
 *	Login & New user questions routines
 *	(LazyBBS Project)
 *
 *	Public domain: may be copied and sold freely
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <ctype.h>

#include "bbs.h"	/* config */
#include "miscio.h" /* level 1 */

#include "login.h"	/* prototypes */
#include "msg.h"	/* is_newmail() */

/* ================================================== LOGIN ROUTINES */

BBSLOGIN user;		/* the current user */
int got_it=0;		/* there's a user to save */
int guest=0;		/* current user is guest */
int hasnewmail=0;	/* user has new private mail */

/*
 *	get_login:	load login from file
 */
 
int get_login(void )
{
	FILE *lf;
	char temp[BBSSTR];
	char tempdigit[BBSSTR];
	char start[BBSSTR];
	char *next;
	
	lf=fopen(LOGINFILE,"r");
	if(!lf) 
	{
		logline(1,"Can't find login file");
		return BBSFAIL;
	}
	
	sprintf(start,"%s%c%s%c", user.first_name,BBSSEPAR,user.last_name,BBSSEPAR);
	
	while(fgets(temp,BBSSTR,lf)!=NULL)
	{

		if(!iscomment(*temp) && !strnicmp(start,temp,strlen(start)))
		{ /* got it */
			next=findword(user.first_name,temp); 
			if(next)
			{
				next=findword(user.last_name,next);
				if(next)
				{
					next=findword(user.password,next);
					if(next)
					{
						next=findword(user.address,next);
						if(next)
						{				
							next=findword(user.flags,next);
							if(next)
							{
								next=findword(tempdigit,next);
								user.last_login=atoi(tempdigit);
								if(next)
								{
									next=findword(tempdigit,next);
									user.downkb=atoi(tempdigit);
									if(user.last_login!=today() && user.downkb>=0)
										user.downkb=0;
									if(next)
									{
										findword(tempdigit,next);
										user.calls=atoi(tempdigit);
											got_it++;
										user.calls++;
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	fclose(lf);
	
	if(got_it)
		return BBSOK;
	return BBSFAIL;	
}

/*
 * 	save/update login
 */
 
int close_login(void )
{
	FILE *lf,*tf;
	char start[BBSSTR], temp[BBSSTR];
	
	if(got_it && !guest)
	{
		lf=fopen(LOGINFILE,"r");
		if(!lf) 
			logline(1,"Creating login file");
		
		
		tf=fopen(tempfile(),"w");
		if(!tf) 
			logline(1,"Can't open temp file");
		else
		{
			sprintf(start,"%s%c%s", user.first_name,BBSSEPAR,user.last_name);

			if(lf)
			{		
				while(fgets(temp,BBSSTR,lf)!=NULL)
				{
					if(!iscomment(*temp) && strnicmp(start,temp,strlen(start)))
					{ /* not got it */
						if(fputs(temp,tf)) 
							logline(1,"write error in login file");
					}
				}
			}
	
			fprintf(tf,"%s%c%s%c%s%c%s%c%s%c%d%c%d%c%d\n",	
					user.first_name,BBSSEPAR,user.last_name,BBSSEPAR,
					user.password,BBSSEPAR,user.address,BBSSEPAR,
					user.flags,BBSSEPAR,today(),BBSSEPAR,user.downkb,
					BBSSEPAR,user.calls);
			fclose(tf);
		}
		remove(LOGINFILE);
		
		if(lf)
			fclose(lf);
					
		rename(tempfile(), LOGINFILE);
	}
	return BBSOK;
}

void display_login(void )
{
	int diffdays;
	int nmail,newnmail;
	if(!got_it) return;
	
	diffdays=today()-user.last_login;
	
	if(guest)
		out_printf("\n\nGuest User logged in.\n");
	else
		out_printf("\n\n%s %s from %s logged in.\n",
			user.first_name, user.last_name, user.address);
	
	if(is_newmail(get_netarea(),&nmail,&newnmail)==BBSOK)
	{
		if(newnmail) /* bip for new mail */
		{
			/* set mail var */
			hasnewmail++;
			
			out_printf("Netmail        : %d messages (%d new)\n\0x07",
				nmail,newnmail);
		}
		else
			out_printf("Netmail        : %d messages\n",nmail);
	}
	
	if(user.flags[0])
		out_printf("User flags     : %s\n",user.flags);
		
	if(user.last_login==0)
		out_printf("Last login     : never.\n");
	else if(diffdays)
		out_printf("Last login     : %d day(s) ago.\n",diffdays);
	else
		out_printf("Last login     : today.\n");
		
	out_printf("Call number    : %d.\n",user.calls);

	if(user.downkb>=0)
		out_printf("Download credit: %d Kilobytes.\n\n",get_maxdown()-user.downkb);
	else
		out_printf("Download credit: None.\n\n");
	
	/* security check on 1st call */
	if(nmail && (user.last_login==0))
	{
		guest++;
		logline(4,"WARNING: New user has netmail!!!");
		out_printf("\nSECURITY PROBLEM: You are a new user and mail to you has been found\n");
		out_printf("in the netmail area. So, you are downgraded to guest user status.\n");
		out_printf("Send a netmail to your sysop for a permanent account.\n");
	}
	
	out_printf("\nHit [Return]\n");
	getkey();
}

int open_login(void )
{
	char temp[BBSSTR];
	int try,error;
	int try_1st=0;
	int got_user=0;
	
	/* init default values for newusers/guest */
	*user.flags=0;
	user.calls=1;
	user.last_login=0;
	
buggy_goto: /* fixme goto */
	try=MAXTRIES;
	do {
		out_printf("\n\nEnter your first name (example: \"Robert\")\n>");
		error=getstring(user.first_name);
		if(error==BBSOK)
		{	
			if(strchr(user.first_name,' ')==NULL && strlen(user.first_name)>1)
			{
				got_user++;
				break;
			}
		}
		try--;
	} while(try>=0 && error==BBSOK);
	
	if(got_user)
	{
		strcln(user.first_name,BBSSEPAR);
		strcln(user.first_name,' ');
		strlwr(user.first_name);
		*user.first_name=toupper(*user.first_name);
		
		if(strcmp(user.first_name,"Guest")==0)
		{
			strcpy(user.last_name,"User");
			strcpy(user.password,"-junk-");
			strcpy(user.address,"Unknown");
			user.downkb=-1;
			got_it++;
			guest++;	
			logline(2,"Guest User logged in");
			return BBSOK;
		}
		else
		{ /* !guest user */
			try=MAXTRIES;got_user=0;
			do {
				out_printf("\n\nEnter your last name (example: \"De.Niro\")\n>");
				if(BBSOK==(error=getstring(user.last_name)))
				{	
					if(strchr(user.last_name,' ')==NULL && strlen(user.last_name)>1)
					{
						got_user++;
						break;
					}	
				}
			} while(try-->=0 && error==BBSOK);

			if(got_user)
			{
				strcln(user.last_name,BBSSEPAR);
				strcln(user.last_name,' ');
				strlwr(user.last_name);
				*user.last_name=toupper(*user.last_name);
				
				if(get_login()==BBSOK)
				{
					try=MAXTRIES;
					while(try)
					{
						out_printf("\n\nEnter password\n>");
						if(getpasswdstring(temp)!=BBSOK)
							return BBSFAIL;
						if(strcmp(strlwr(temp),strlwr(user.password))==0)
						{
							display_login();
							logline(1,"%s %s from %s logged in.",user.first_name,user.last_name,user.address);
							return BBSOK;
						}
						logline(1,"Password error %s %s : %s",user.first_name,user.last_name,
									temp);
						try--;
					}
					out_printf("\n\nGo play somewhere else!\n");
					return BBSFAIL;
				}
				out_printf("\n\n%s %s not in user base, do you want to login as a new user [Y/n]?",
					user.first_name,user.last_name);
				if(tolower(getkey()=='n'))
				{
					if(try_1st==0)
					{
						try_1st++;
	/* fixme */			goto buggy_goto;
					}
					else
						return BBSFAIL;
				}
				else
				{	/* new user */
					try=MAXTRIES;
					while(try)
					{
						out_printf("\n\nChoose a password\n>");
						if(getpasswdstring(temp)==BBSFAIL)
							return BBSFAIL;
						out_printf("\n\nOnce again...\n>");
						if(getpasswdstring(user.password)==BBSFAIL)
							return BBSFAIL;
						if(strcmp(strlwr(temp),strlwr(user.password))==0)
							break;
						try--;
					}
					if(!try)
						logline(1,"Password matching failed");
					out_printf("\n\nEnter your city and country (example: \"Novosibirsk, Russia\")\n>");
					if(getstring(user.address)==BBSOK)
					{
						user_questions();
						user.downkb=get_maxdown()-get_newdown();
						got_it++;
						display_login();
						logline(1,"New user %s %s from %s logged in",
							    		user.first_name,user.last_name,user.address);
						return BBSOK;
					}
				}
			}
		} /* !guest */
	}
	return BBSFAIL;
}

int change_password(void )
{
	char pw[BBSSTR],pw2[BBSSTR];
	
	out_printf(CLS_STRING);
	logline(3,"User changing password");
	
	if(!got_it)
		return BBSFAIL;
	if(guest)
	{
		out_printf("Guest user can't change password!!\n\n[Return]\n");
		getkey();
		return BBSOK;
	}
	
	out_printf("\n\nChoose a password\n>");
	if(getpasswdstring(pw)==BBSFAIL)
		return BBSFAIL;
	if(strlen(pw)<3)
	{
		printf("\nPassword too short, change canceled! Hit a key.\n");
		getkey();
		return BBSFAIL;
	}
	out_printf("\n\nOnce again...\n>");
	if(getpasswdstring(pw2)==BBSFAIL)
		return BBSFAIL;	
	
	if(strcmp(pw,pw2)==0)
	{
		logline(2,"Password changed");
		strcpy(user.password,pw);
		out_printf("\n\nPassword changed, squish [Return].\n");
		getkey();
		return BBSOK;
	}
	
	out_printf("\nPasswords don't match?\n[Return]\n");
	getkey();
	return BBSFAIL;
}

int get_ulastlogin(void )
{
	if(got_it)
		return user.last_login;
	else
		return 0;
}

static char nstore[2*BBSSTR+1];

char *get_uname(void )
{
	if(!got_it)
		strcpy(nstore,"Unknown");
	
	strcpy(nstore, user.first_name);
	strcat(nstore, " ");
	strcat(nstore, user.last_name);
	return nstore;
}

int get_ucredit(int kilobytes)
{
	if(!got_it || user.downkb<0)
		return BBSFAIL;
		
	if(kilobytes<(get_maxdown()-user.downkb)) /* ok, for standard file */
	{
		user.downkb+=kilobytes;
		return BBSOK;
	}

	if(kilobytes>get_maxdown() && user.downkb==0) /* allows 1 file >limit /day excluding all other */
	{
		user.downkb=get_maxdown();
		return BBSOK;
	}
		
	return BBSFAIL; /* nope */
}

int get_uflag(char flag)
{
	int i=0;
	while(user.flags[i])
	{
		if(user.flags[i]==flag)
			return BBSOK;
		i++;
	}
	return BBSFAIL;
}

int is_uguest(void )
{
	return guest;
}

int has_new_mail(void )
{
	return hasnewmail;
}

void reset_new_mail(void )
{
	int junk,newm;
	
	hasnewmail=0;
	
	if(is_newmail(get_netarea(),&junk,&newm)==BBSOK)
	{
		if(newm) /* bip for new mail */
			hasnewmail++;
	}
}

/* ============================================== USER QUESTION ROUTINE */

int user_questions()
{
	FILE *question;
	FILE *answer;
	char *temp=malloc(BBSSTR*5+1);
	char ansstr[BBSSTR];
	char *ptr;
	int qnb=1;
	int errorfl=0;
	
	if(!temp)
	{
		logline(1,"no more memory for user_questions");
		return BBSFAIL;
	}
	
	question=fopen(QUESTFILE,"r");
	if(!question)
	{
		logline(1,"Can't read user questions file");
		errorfl++;
	}
	else
	{
		answer=fopen(ANSWERFILE,"a");
		if(!answer)
		{
			logline(1,"Can't open answers file");
			errorfl++;
		}
		else
		{
			fprintf(answer,"----- New User %s answering new user questions:\n",get_uname());
	
			out_printf("\n");
			while(fgets(temp,BBSSTR*5,question)!=NULL)
			{
				if(!iscomment(*temp))
				{
					strcln(temp,-1); /* remove end \n */
				
					/* replace all "\n" by <cr><lf> */
					ptr=strstr(temp,"\\n");
					while(ptr) 
					{
						ptr[0]=0x0d;
						ptr[1]=0x0a;
						ptr=strstr(ptr+2,"\\n");
					}
			
					out_printf("\n\n%s\n\n>",temp);
			
					if(getstring(ansstr)==BBSFAIL)
					{
						errorfl++;
						break;
					}
					else
					{
						fprintf(answer, "%d : %s\n", qnb, ansstr);
						qnb++;
					}
				}
			}
	
			fclose(answer);
		}
		fclose(question);
	}
	
	free(temp);
	
	if(errorfl)
		return BBSFAIL;
		
	return BBSOK;
} 
