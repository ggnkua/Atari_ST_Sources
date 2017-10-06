#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "header.h"
#include "sysdep.h"
#include "graphics.h"

char fktext [10][64];

#define MAXHIST 32
char history [MAXHIST][128];
int act_history=0,hist=0;
extern int outputing;

void cpy (char *dest, char *source)
{	memmove(dest,source,strlen(source)+1);
}

void put_history (char *s)
{	int i;
	if (act_history>=MAXHIST)
	{	for (i=0; i<MAXHIST-1; i++) strcpy(history[i],history[i+1]);
		act_history=MAXHIST-1;
		hist--; if (hist<0) hist=0;
	}
	strcpy(history[act_history],s);
	if (hist==act_history) hist++;
	act_history++;
}

void prompt (void)
{	if (!outputing) gprint("\n>");
	if (!udf) output(">");
	else output("udf>");
}

void left (int n)
{	int i;
	for (i=0; i<n; i++) move_cl();
}

void right (int n)
{	int i;
	for (i=0; i<n; i++) move_cr();
}

void fkinsert (int i, int *pos, char *s)
{	char *p;
	p=fktext[i];
	if (strlen(s)+strlen(p)>=254) return;
	cpy(s+*pos+strlen(p),s+*pos); memmove(s+*pos,p,strlen(p));
	output1("%s",p); *pos+=(int)strlen(p);
}

char helpstart[256];
char helpextend[16][16];
int helpn=0,helpnext=0,helphist=-1;
int dohelp (char start[256], char extend[16][16]);

void edithelp (char *s, int *pos, int *shorter)
/* extend the command at cursor position */
{	char *start,*end,*p;
	int i,l;
	/* search history */
	l=(int)strlen(s);
	helphist=-1;
	for (i=act_history-1; i>=0; i--)
		if (!strncmp(history[i],s,l))
		{	helphist=i;
			break;
		}	
	start=end=p=s+(*pos);
	while (start>s && (isalpha(*(start-1)) || isdigit(*(start-1))))
		start--;
	while (isdigit(*start)) start++;
	while (isalpha(*end) || isdigit(*end)) end++;
	if (start>s+(*pos) || start>=end) return;
	while (p<end) { move_cr(); (*pos)++; p++; }
	memmove(helpstart,start,end-start);
	helpstart[end-start]=0;
	helpn=dohelp(helpstart,helpextend);
	helpnext=0;
}

void edit (char *s)
{	int pos,scan,shorter;
	char ch,chs[2]="a",*p=0;
	s[0]=0; pos=0;
	prompt();
	edit_on();
	helpn=0; helphist=-1;
	while (1)
	{	ch=wait_key(&scan);
		if (scan!=help && helpnext<helpn) helpn=0;
		if (scan==enter) break;
		shorter=0;
		if (isprint(ch) && strlen(s)<254)
		{	cpy(s+pos+1,s+pos);
			s[pos]=ch; pos++;
			chs[0]=ch;
			cursor_off(); gprint(chs);
		}
		else
		{	switch (scan)
			{	case cursor_left :
					if (pos) { pos--; move_cl(); }; continue;
			    case cursor_right : /* cursor right */
			    	if (s[pos]) { pos++; move_cr(); }; continue;
				case word_right : /* a word to the right */
				{	while (s[pos] && s[pos]!=' ')
					{	pos++; move_cr(); }
					while (s[pos]==' ')
					{	pos++; move_cr(); }
					continue;
				}
				case word_left : /* a word to the right */
				{	if (pos) { pos--; move_cl(); }
					while (pos && s[pos]==' ')
					{	pos--; move_cl(); }
					while (pos && s[pos]!=' ')
					{	pos--; move_cl(); }
					if (pos) { pos++; move_cr(); }
					continue;
				}
			    case backspace :
			    	if (pos)
			    	{	pos--;
			    		cpy(s+pos,s+pos+1); 
			    		move_cl(); shorter=1;
			    	}
			    	break;
			    case delete :
			    	if (s[pos])
			    	{	cpy(s+pos,s+pos+1); shorter=1;
			    	}
			    	break;
			    case cursor_up :
			    	if (hist) { hist--; strcpy(s,history[hist]); 
			    			shorter=1; }
			    	cursor_off(); left(pos); pos=0; goto cont;
			    case cursor_down :
			    	if (hist<act_history-1) 
			    		{ hist++; strcpy(s,history[hist]); shorter=1; } 
			    	cursor_off(); left(pos); pos=0; goto cont;
			    case clear_home :
			    case escape :
			    	cursor_off();
			    	left(pos); pos=0; s[0]=0;
			    	shorter=1; hist=act_history;
			    	goto cont;
			    case line_end :
			    	while (s[pos]) { pos++; move_cr(); }
			    	continue;
			    case line_start :
			    	left(pos); pos=0;
			    	continue;
			    case switch_screen :
			    	edit_off(); show_graphics(); edit_on(); break;
			    case help :
			    	if (helpnext>=helpn && helphist<0)
			    	{	edithelp(s,&pos,&shorter);
			    		p=0;
			    	}
			    	if (helphist>=0)
			    	{	cursor_off();
			    		strcpy(s,history[helphist]);
			    		hist=helphist;
			    		p=s+pos;
			    		output1("%s",p);
			    		pos+=(int)strlen(p);
			    		shorter=1;
			    		helphist=-1; goto cont;
			    	}
			    	else if (helpnext<helpn)
			    	{	cursor_off();
			    		if (p)
			    		{	left((int)strlen(p));
			    			pos-=(int)strlen(p);
			    			cpy(s+pos,s+pos+strlen(p));
			    		}
			    		p=helpextend[helpnext++];
			    		if (strlen(s)+strlen(p)>=254)
			    		{	p=0; helpn=0; break;
			    		}
						cpy(s+pos+strlen(p),s+pos);
						memmove(s+pos,p,strlen(p));
						output1("%s",p);
						pos+=(int)strlen(p);
						shorter=1;
						goto cont;
			    	}
			    	break;
			    case fk1 : fkinsert(0,&pos,s); break;
			    case fk2 : fkinsert(1,&pos,s); break;
			    case fk3 : fkinsert(2,&pos,s); break;
			    case fk4 : fkinsert(3,&pos,s); break;
			    case fk5 : fkinsert(4,&pos,s); break;
			    case fk6 : fkinsert(5,&pos,s); break;
			    case fk7 : fkinsert(6,&pos,s); break;
			    case fk8 : fkinsert(7,&pos,s); break;
			    case fk9 : fkinsert(8,&pos,s); break;
			    case fk10 : fkinsert(9,&pos,s); break;
			}
			cursor_off();
		}
		cont: gprint(s+pos);
		if (shorter) clear_eol();
		left((int)strlen(s+pos));
		cursor_on();
	}
	put_history(s);
	if (outfile)
	{	fprintf(outfile,"%s",s);
	}
	edit_off();
	output("\n");
}
