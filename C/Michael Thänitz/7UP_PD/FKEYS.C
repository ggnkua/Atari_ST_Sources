/* Funktionstastenbelegung */
/*****************************************************************************
*
*											  7UP
*										Modul: FKEYS.C
*									 (c) by TheoSoft '91
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <aes.h>
#if GEMDOS
#include <tos.h>
#endif

#include "alert.h"
#include "windows.h"
#include "forms.h"
#include "7UP.h"

#include "language.h"
#include "undo.h"

#define F1	 0x803B
#define F10	 0x8044
#define SF1	 0x8254 /*11.6.94 Bugfix*/
#define SF10 0x825D
#define ESC	 27
#define TAB	 9
#define CR   0x0D

char *expandfkey(WINDOW *wp, char *str, int page);
void hndl_fkeymenu(OBJECT *tree, int start);
char *split_fname(char *name);
int fkeys(WINDOW *wp, int ks, int kr, LINESTRUCT **begcut, LINESTRUCT **endcut);

extern OBJECT *fkeymenu;
extern char alertstr[],iostring[];
extern int windials;

static char fkeystat[10]=
{
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE
};

static char sfkeystat[10]=
{
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE,
	FALSE
};

static char *dayoftheweek[]=
{
	SONNTAG,
	MONTAG,
	DIENSTAG,
	MITTWOCH,
	DONNERSTAG,
	FREITAG,
	SONNABEND
};

char *datetime(char what)
{
	long timer;
	struct tm *tp;
	static char str[16]="";

	time(&timer);
	tp=localtime(&timer);
	switch(what)
	{
		case 's':
			sprintf(str,"%02d",tp->tm_sec);
			break;
		case 'm':
			sprintf(str,"%02d",tp->tm_min);
			break;
		case 'h':
			sprintf(str,"%02d",tp->tm_hour);
			break;
		case 'T':
			sprintf(str,"%02d",tp->tm_mday);
			break;
		case 'M':
			sprintf(str,"%02d",tp->tm_mon+1);
			break;
		case 'J':
			sprintf(str,"%d",tp->tm_year);
			break;
		case 'W':
			sprintf(str,"%s",dayoftheweek[tp->tm_wday]);
			break;
		case 'D':
			sprintf(str,"%d",tp->tm_yday+1);
			break;
	}
	return(str);
}

char *expandfkey(WINDOW *wp, char *string, int page)
{
	register int i,k;
	char code, expanded[161];

	k=strlen(string);
	strcpy(expanded,string);

	for(i=0; i<k; i++)
	{
		if(expanded[i]=='%')
		{
			switch(code=expanded[i+1])
			{
				case 's':
				case 'm':
				case 'h':
				case 'T':
				case 'M':
				case 'J':
				case 'W':
				case 'D':
					if(!expanded[i+2])
						strcpy(&expanded[i],datetime(code));
					else
					{
						strcpy(&expanded[i],&expanded[i+2]);
						strins(expanded,datetime(code),i);
						k+=(strlen(datetime(code))-2);
					}
					break;
				case 'F':					  /* Pfadname */
					if(!expanded[i+2])
						strcpy(&expanded[i],(char *)Wname(wp));
					else
					{
						strcpy(&expanded[i],&expanded[i+2]);
						strins(expanded,(char *)Wname(wp),i);
						k+=(strlen((char *)Wname(wp))-2);
					}
					break;
				case 'f':					 /* Name */
					strcpy(iostring,(char *)split_fname((char *)Wname(wp)));
					if(!expanded[i+2])
						strcpy(&expanded[i],iostring);
					else
					{
						strcpy(&expanded[i],&expanded[i+2]);
						strins(expanded,iostring,i);
						k+=(strlen(iostring)-2);
					}
					break;
				case 'p':
					itoa(page,iostring,10);
					if(!expanded[i+2])
						strcpy(&expanded[i],iostring);
					else
					{
						strcpy(&expanded[i],&expanded[i+2]);
						strins(expanded,iostring,i);
						k+=(strlen(iostring)-2);
					}
					break;
				case '%':
					strcpy(&expanded[i],&expanded[i+1]);
					k--;
					break;
				default:
					break;
			}
		}
	}
	strcpy(string, expanded);
	return(string);
}
/*
void _keyoff(void);
void _keyon(void);
*/
int newfkey(char c)
{
	register int i=0;
	switch(c)
	{
		case '0':
			i++;
		case '9':
			i++;
		case '8':
			i++;
		case '7':
			i++;
		case '6':
			i++;
		case '5':
			i++;
		case '4':
			i++;
		case '3':
			i++;
		case '2':
			i++;
		case '1':
			return(i);
			break;
	}
	return(-1);
}

int newkey(int c1, int c2, int *state, int *key)
{
	switch(c1)
	{
		case 'A':
		case 'a':
			*state=K_ALT;
			*key=c2;
			break;
		case 'C':
		case 'c':
			*state=K_CTRL;
			*key=c2;
			break;
	}
}

int fkeys(WINDOW *wp, int ks, int kr, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	char *str,fstr[161];
	register int key,i,k,m,ret=FALSE;
	int nstate,nkey,fkey=0;
	
	if(wp && (kr & 0x8000))/* Scancodebit muž gesetzt sein */
	{
		if(kr>=F1 && kr<=F10)
		{
			key=(kr)-(F1);
			fkeystat[key]=TRUE;
			if(str=expandfkey(wp,form_read(fkeymenu,FKEY1+key,fstr),0))
			{
				k=strlen(str);
				if(k)
				{
					for(i=0; i<k; i++)
					{
						switch(str[i])
						{
							case '\\':
								switch(str[i+1])
								{
									case 'C': /* Cntrl ? */
									case 'c': /* Cntrl ? */
									case 'A': /* Alt ? */
									case 'a': /* Alt ? */
										newkey(__toupper(str[i+1]),__toupper(str[i+2]),&nstate,&nkey);
										hndl_keybd(nstate,nkey);
										break;
									case 'f':
										if((fkey=newfkey(str[i+2]))>=0)
										{
											if(!fkeystat[fkey])
											{
												fkeystat[fkey]=TRUE;
												fkeys(wp,0,((F1)+fkey),begcut,endcut);
												fkeystat[fkey]=FALSE;
											}
											i+=2;
										}
										else
											editor(wp,0,(int)str[i],begcut,endcut);
										break;
									case 'F':
										if((fkey=newfkey(str[i+2]))>=0)
										{
											if(!sfkeystat[fkey])
											{
												sfkeystat[fkey]=TRUE;
												fkeys(wp,K_LSHIFT,((SF1)+fkey),begcut,endcut);
												sfkeystat[fkey]=FALSE;
											}
											i+=2;
										}
										else
											editor(wp,0,(int)str[i],begcut,endcut);
										break;
									case 't':/* Text hinzuladen */
/* MT 18.6.95 */
										if(!*begcut && !*endcut)
										{
											switch(_read_blk(wp, &str[i+2], begcut, endcut))
											{
												case -1:	/* kein ram frei */
													sprintf(alertstr,Afkeys[1],split_fname(&str[i+2]));
													form_alert(1,alertstr); /* kein break, es geht weiter */
												case TRUE: /* ok */
													store_undo(wp, &undo, *begcut, *endcut, WINEDIT, EDITCUT);
													wp->w_state|=CHANGED;
													m=(*endcut)->used; /* merken, wird ben”tigt, geht aber verloren */
													graf_mouse(M_OFF,0L);
													Wcursor(wp);
													if((wp->w_state&COLUMN))
														paste_col(wp,*begcut,*endcut);
													else
														paste_blk(wp,*begcut,*endcut);
													Wcursor(wp);
													graf_mouse(M_ON,0L);
													(*endcut)->endcol=m;
													if(!(wp->w_state&COLUMN))
														hndl_blkfind(wp,*begcut,*endcut,SEAREND);
													else
														free_blk(wp,*begcut); /* Spaltenblock freigeben */
													graf_mouse(M_OFF,0L);
													Wcursor(wp);
													Wredraw(wp,&wp->xwork);
													Wcursor(wp);
													graf_mouse(M_ON,0L);
													break;
												case FALSE:
													sprintf(alertstr,Afkeys[2],(char *)split_fname(&str[i+2]));
													form_alert(1,alertstr);
													undo.item=FALSE;	/* EDITCUT */
													break;
											}
											*begcut=*endcut=NULL;
										}
										return(TRUE);/* raus, sonst wird auch der Dateiname eingefgt */
										break;
									default:
										editor(wp,0,(int)str[i],begcut,endcut);
										break;
								}
								break;
							case TAB:
								editor(wp,0,TAB,begcut,endcut);
								break;
							case ESC:
								editor(wp,0,ESC,begcut,endcut);
								break;
							case '\r': /* ^M == CR bercksichtigen */
								editor(wp,0,CR,begcut,endcut);
								break;
							default:
								editor(wp,0,(int)str[i],begcut,endcut);
								break;
						}
					}
				}
				else
				{
					fkeymenu[FKNORM ].ob_flags&=~HIDETREE;
					fkeymenu[FKSHIFT].ob_flags|=HIDETREE;
					if((*begcut) && (*endcut) && (*begcut)==(*endcut) && (*endcut)->begcol<(*endcut)->used)
					{
						strncpy(alertstr,&(*begcut)->string[(*begcut)->begcol],(*begcut)->endcol-(*begcut)->begcol);
						alertstr[(*begcut)->endcol-(*begcut)->begcol]=0;
						alertstr[fkeymenu[FKEY1+key].ob_spec.tedinfo->te_txtlen-1]=0;
						form_write(fkeymenu,FKEY1+key,alertstr,FALSE);
					}
					hndl_fkeymenu(fkeymenu,FKEY1+key);
				}
			}
			fkeystat[key]=FALSE;
			ret=TRUE;
		}
		if(kr>=SF1 && kr<=SF10)
		{
			key=(kr)-(SF1);
			sfkeystat[key]=TRUE;
			if(str=expandfkey(wp,form_read(fkeymenu,SFKEY1+key,fstr),0))
			{
				k=strlen(str);
				if(k)
				{
					for(i=0; i<k; i++)
					{
						switch(str[i])
						{
							case '\\':
								switch(str[i+1])
								{
									case 'C': /* Cntrl ? */
									case 'c': /* Cntrl ? */
									case 'A': /* Alt ? */
									case 'a': /* Alt ? */
										newkey(__toupper(str[i+1]),__toupper(str[i+2]),&nstate,&nkey);
										hndl_keybd(nstate,nkey);
										break;
									case 'f':
										if((fkey=newfkey(str[i+2]))>=0)
										{
											if(!fkeystat[fkey])
											{
												fkeystat[fkey]=TRUE;
												fkeys(wp,0,((F1)+fkey),begcut,endcut);
												fkeystat[fkey]=FALSE;
											}
											i+=2;
										}
										else
											editor(wp,0,(int)str[i],begcut,endcut);
										break;
									case 'F':
										if((fkey=newfkey(str[i+2]))>=0)
										{
											if(!sfkeystat[fkey])
											{
												sfkeystat[fkey]=TRUE;
												fkeys(wp,K_LSHIFT,((SF1)+fkey),begcut,endcut);
												sfkeystat[fkey]=FALSE;
											}
											i+=2;
										}
										else
											editor(wp,0,(int)str[i],begcut,endcut);
										break;
									case 't':/* Text hinzuladen */
/* MT 18.6.95 */
										if(!*begcut && !*endcut)
										{
											switch(_read_blk(wp, &str[i+2], begcut, endcut))
											{
												case -1:	/* kein ram frei */
													sprintf(alertstr,Afkeys[1],split_fname(&str[i+2]));
													form_alert(1,alertstr); /* kein break, es geht weiter */
												case TRUE: /* ok */
													store_undo(wp, &undo, *begcut, *endcut, WINEDIT, EDITCUT);
													wp->w_state|=CHANGED;
													m=(*endcut)->used; /* merken, wird ben”tigt, geht aber verloren */
													graf_mouse(M_OFF,0L);
													Wcursor(wp);
													if((wp->w_state&COLUMN))
														paste_col(wp,*begcut,*endcut);
													else
														paste_blk(wp,*begcut,*endcut);
													Wcursor(wp);
													graf_mouse(M_ON,0L);
													(*endcut)->endcol=m;
													if(!(wp->w_state&COLUMN))
														hndl_blkfind(wp,*begcut,*endcut,SEAREND);
													else
														free_blk(wp,*begcut); /* Spaltenblock freigeben */
													graf_mouse(M_OFF,0L);
													Wcursor(wp);
													Wredraw(wp,&wp->xwork);
													Wcursor(wp);
													graf_mouse(M_ON,0L);
													break;
												case FALSE:
													sprintf(alertstr,Afkeys[2],(char *)split_fname(&str[i+2]));
													form_alert(1,alertstr);
													undo.item=FALSE;	/* EDITCUT */
													break;
											}
											*begcut=*endcut=NULL;
										}
										return(TRUE);/* raus, sonst wird auch der Dateiname eingefgt */
										break;
									default:
										editor(wp,0,(int)str[i],begcut,endcut);
										break;
								}
								break;
							case TAB:
								editor(wp,0,TAB,begcut,endcut);
								break;
							case ESC:
								editor(wp,0,ESC,begcut,endcut);
								break;
							case '\r': /* ^M == CR bercksichtigen */
								editor(wp,0,CR,begcut,endcut);
								break;
							default:
								editor(wp,0,(int)str[i],begcut,endcut);
								break;
						}
					}
				}
				else
				{
					fkeymenu[FKNORM ].ob_flags|= HIDETREE;
					fkeymenu[FKSHIFT].ob_flags&=~HIDETREE;
					if((*begcut) && (*endcut) && (*begcut)==(*endcut) && (*endcut)->begcol<(*endcut)->used)
					{
						strncpy(alertstr,&(*begcut)->string[(*begcut)->begcol],(*begcut)->endcol-(*begcut)->begcol);
						alertstr[(*begcut)->endcol-(*begcut)->begcol]=0;
						alertstr[fkeymenu[SFKEY1+key].ob_spec.tedinfo->te_txtlen-1]=0;
						form_write(fkeymenu,SFKEY1+key,alertstr,FALSE);
					}
					hndl_fkeymenu(fkeymenu,SFKEY1+key);
				}
			}
			sfkeystat[key]=FALSE;
			ret=TRUE;
		}
	}
	return(ret);
}

static void set_3D_flags(OBJECT *tree)
{
	int i;
	
	tree[FKSHIFT].ob_flags |= 0x0400;
	tree[FKNORM ].ob_flags |= 0x0400;
	for(i=0; i<10; i++)
		tree[i+FKEY1].ob_flags |= 0x0400;
	for(i=10; i<20; i++)
		tree[i-10+SFKEY1].ob_flags |= 0x0400;
}

void _savesoftkeys(char *pathname)
{
	FILE *fp;
	int i;
	
	if((fp=fopen(pathname,"wb"))!=NULL)
	{
      graf_mouse(BUSY_BEE,NULL);
		for(i=FKEY1; i<=FKEY10; i++)
		{
			fputs(form_read(fkeymenu,i,pathname),fp);	  /* Fkttasten */
			fputs("\r\n",fp);
		}
		for(i=SFKEY1; i<=SFKEY10; i++)
		{
			fputs(form_read(fkeymenu,i,pathname),fp);
			fputs("\r\n",fp);
		}
		fclose(fp);
      graf_mouse(ARROW,NULL);
	}
}

void _loadsoftkeys(char *pathname)
{
	FILE *fp;
	int i;
		
	if((fp=fopen(pathname,"rb"))!=NULL)
	{
      graf_mouse(BUSY_BEE,NULL);
		for(i=FKEY1; i<=FKEY10; i++)
		{
			fgets(pathname,64,fp);
			pathname[strlen(pathname)-2]=0;
			form_write(fkeymenu,i,pathname,FALSE);
		}
		for(i=SFKEY1; i<=SFKEY10; i++)
		{
			fgets(pathname,64,fp);
			pathname[strlen(pathname)-2]=0;
			form_write(fkeymenu,i,pathname,FALSE);
		}
		fclose(fp);
      graf_mouse(ARROW,NULL);
	}
}

void loadsoftkeys(char *filename)
{
	char *cp,pathname[PATH_MAX];
	
   search_env(pathname,filename,FALSE); /* READ */
	_loadsoftkeys(pathname);
}

void hndl_fkeymenu(OBJECT *tree, int start)
{
	int x,y,exit_obj,i,done=FALSE;
	char *cp,keys[20][33];

	char filename[PATH_MAX]="";
	/*static*/ char fpattern[FILENAME_MAX]="*.*";


	if(tree[FKSHIFT].ob_flags & HIDETREE)
	{
		form_write(tree,FKEYSHFT,MIT_SHIFT,FALSE);
		if(!start)
			start=FKEY1;
	}
	else
	{
		form_write(tree,FKEYSHFT,OHNE_SHIFT,FALSE);
		if(!start)
			start=SFKEY1;
	}
	for(i=0; i<10; i++)
		form_read(tree,i+FKEY1,keys[i]);
	for(i=10; i<20; i++)
		form_read(tree,i-10+SFKEY1,keys[i]);
   
   set_3D_flags(tree);
  	
  	form_exopen(tree,0);
	do
	{
		exit_obj=form_exdo(tree,start);
		objc_offset(tree,ROOT,&x,&y);
		switch(exit_obj)
		{
			case FKEYLOAD:
				strcpy(fpattern,"*.SFK");
				find_7upinf(filename,"SFK",TRUE);
				if((cp=strrchr(filename,'\\'))!=NULL || (cp=strrchr(filename,'/'))!=NULL)
					strcpy(&cp[1],fpattern);
				else
					*filename=0;
				if(getfilename(filename,fpattern,"@",fselmsg[9]))
					_loadsoftkeys(filename);
				tree[exit_obj].ob_state&=~SELECTED;
				objc_update(tree,ROOT,MAX_DEPTH); /* Alles zeichnen! */
				break;
			case FKEYSAVE:
				strcpy(fpattern,"*.SFK");
				find_7upinf(filename,"SFK",TRUE);
				if((cp=strrchr(filename,'\\'))!=NULL || (cp=strrchr(filename,'/'))!=NULL)
					strcpy(&cp[1],fpattern);
				else
					*filename=0;
				if(getfilename(filename,fpattern,"@",fselmsg[8]))
					_savesoftkeys(filename);
				tree[exit_obj].ob_state&=~SELECTED;
				if(!windials)
					objc_update(tree,ROOT,MAX_DEPTH);
				else
					objc_update(tree,exit_obj,0);
				break;
			case FKEYSHFT:
				tree[FKSHIFT].ob_flags^=HIDETREE;
				tree[FKNORM ].ob_flags^=HIDETREE;
				tree[exit_obj].ob_state&=~SELECTED;
				if(tree[FKSHIFT].ob_flags & HIDETREE)
				{
					for(i=FKEY1; i<=FKEY10; i++)
						tree[i].ob_flags |= EDITABLE;
					for(i=SFKEY1; i<=SFKEY10; i++)
						tree[i].ob_flags &= ~EDITABLE;
					form_write(tree,FKEYSHFT,MIT_SHIFT,TRUE);
					start=FKEY1;
					objc_update(tree,ROOT/*FKNORM*/,MAX_DEPTH);
				}
				else
				{
					for(i=FKEY1; i<=FKEY10; i++)
						tree[i].ob_flags &= ~EDITABLE;
					for(i=SFKEY1; i<=SFKEY10; i++)
						tree[i].ob_flags |=  EDITABLE;
					form_write(tree,FKEYSHFT,OHNE_SHIFT,TRUE);
					start=SFKEY1;
					objc_update(tree,ROOT/*FKSHIFT*/,MAX_DEPTH);
				}
				break;
			case FKEYHELP:
				form_alert(1,Afkeys[0]);
				objc_change(tree,exit_obj,0,x,y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
				break;
			case FKEYOK:
			case FKEYABBR:
				done=TRUE;
				break;
		}
	}
	while(!done);
	form_exclose(tree,exit_obj,0);
	if(exit_obj==FKEYABBR)
	{
		for(i=0; i<10; i++)
			form_write(tree,i+FKEY1,keys[i],FALSE);
		for(i=10; i<20; i++)
			form_write(tree,i-10+SFKEY1,keys[i],FALSE);
	}
}

