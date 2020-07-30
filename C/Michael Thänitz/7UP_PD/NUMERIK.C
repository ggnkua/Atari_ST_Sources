/* Numerischen Funktionen (numerisch bald mit Doppel-m ;-)) */
/* Im Resourcefile mu· es statt 'Gleichung lîsen', 'Ausdruck auswerten' hei·en */
/*****************************************************************************
*
*											  7UP
*										Modul: NUMERIK.C
*									 (c) by TheoSoft '91
*
*****************************************************************************/
#include <portab.h> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <aes.h>

#include "alert.h"
#include "7up.h"
#include "windows.h"
#include "forms.h"

#if GEMDOS

extern OBJECT *winmenu, *nummenu;
extern char alertstr[];
extern int cut;

double interpretiere(char *gleichung, int *fehler);

/* jetzt unnîtig, weil im Dialog einstellbar
static char dummy[]="MWST";
*/
static char  mwst[]="15.00";
static int	  nkst=2;			  /* 2 Nachkommastellen */
int komma;

int isnum(char c)
{
   if(nummenu[NUMNDT].ob_state & SELECTED) 		/* Notation: deutsch */
		return(isdigit(c) || (c=='+') || (c=='-') || (c=='.'));
	else
		return(isdigit(c) || (c=='+') || (c=='-') || (c==','));
}

static int isfloat(char *num)
{
	register int i,k=strlen(num);
	for(i=0; i<k; i++)
		if(!(isdigit(num[i]) || (num[i]=='-') || 
		                        (num[i]=='+') || 
		                        (num[i]=='.') || 
		                        (num[i]==',') || isspace(num[i])))
			return(FALSE);
	return(TRUE);
}

static void dt2ami(char *str)	   /* Dezimalkomma in Punkt verwandeln */
{										 /* und Tausenderseparatoren entfernen */
	register char *cp;
   if(nummenu[NUMNDT].ob_state & SELECTED) 		/* Notation: deutsch */
   {
	 	if(cp=strrchr(str,','))
		{
			*cp='.';
			while((cp-=4)>str)
				if(*cp=='.')
					memmove(cp,cp+1,strlen(cp+1)+1);
			return;
		}
	}
	else													  /* Notation: englisch */
	{
		if(cp=strrchr(str,'.'))
		{
			while((cp-=4)>str)
				if(*cp==',')
					memmove(cp,cp+1,strlen(cp+1)+1);
			return;
		}
	}
}

static void ami2dt(char *str)	  /* Dezimalpunkt in Komma verwandeln */
{
	register char *cp;
	if(nummenu[NUMNDT].ob_state & SELECTED)
		if(cp=strrchr(str,'.'))
			*cp=',';
}

static void tsep(char *str)
{
	register char *cp;
	if(nummenu[NUMTSEP].ob_state & SELECTED)
	{
		if(cp=strrchr(str,','))
		{
			while((cp-=3)>str)
			{
				memmove(cp+1,cp,strlen(cp)+1);
				*cp='.';
			}
			return;
		}
		if(cp=strrchr(str,'.'))
		{
			while((cp-=3)>str)
			{
				memmove(cp+1,cp,strlen(cp)+1);
				*cp=',';
			}
			return;
		}
	}
}

static void nconvert(char *str)
{
	ami2dt(str);						/* Dezimalpunkt in Komma verwandeln */
	tsep(str);									/* Tausendertrennung einfÅgen */
}

static int count(LINESTRUCT *begin, LINESTRUCT *end)
{
	LINESTRUCT *help;
	int count;

	for(count=0,help=begin; help!=end->next; help=help->next)
		if(help->begcol<help->used)
		{
			strncpy(alertstr,&help->string[help->begcol],min(help->endcol,help->used)-help->begcol);
			alertstr[min(help->endcol,help->used)-help->begcol]=0;
			if(isfloat(alertstr))
				count++;
			*alertstr=0;
		}
	return(count);
}

static double sum(LINESTRUCT *begin, LINESTRUCT *end)
{
	LINESTRUCT *help;
	double wert,summe;

	for(summe=0.0, help=begin; help!=end->next; help=help->next)
	{
		if(help->begcol<help->used)
		{
			strncpy(alertstr,&help->string[help->begcol],min(help->endcol,help->used)-help->begcol);
			alertstr[min(help->endcol,help->used)-help->begcol]=0;
			if(isfloat(alertstr))
			{
				dt2ami(alertstr);	  /* Dezimalkomma in Punkt verwandeln */
				sscanf(alertstr,"%lf",&wert);
				summe+=wert;
			}
			*alertstr=0;
		}
	}
	return(summe);
}

#define SQR(a) ((a)*(a))

static double sdev(LINESTRUCT *begin, LINESTRUCT *end)
{
	LINESTRUCT *help;
	double summe=0,wert=0,x=0,mean=0;
	int n=0;
	if((n=count(begin, end)) == 0 || n == 1)
	{
		return(-1.0);
	}
	mean=sum(begin, end)/(double)(n);

	for(summe=0.0, help=begin; help!=end->next; help=help->next)
	{
		if(help->begcol<help->used)
		{
			strncpy(alertstr,&help->string[help->begcol],min(help->endcol,help->used)-help->begcol);
			alertstr[min(help->endcol,help->used)-help->begcol]=0;
			if(isfloat(alertstr))
			{
				dt2ami(alertstr);	  /* Dezimalkomma in Punkt verwandeln */
				sscanf(alertstr,"%lf",&wert);
				summe+=SQR((wert-mean));
			}
			*alertstr=0;
		}
	}
	return(sqrt(summe/(n-1)));
}

double steuer(LINESTRUCT *begin, LINESTRUCT *end)
{
	return(sum(begin, end)*(atof(mwst)/100));
}
#endif

static char *extract(char *beg, int n, char *gleichung)
{
   strncpy(gleichung,beg,min(n,63));
   gleichung[min(n,PATH_MAX)]=0;
   return(gleichung);
}

void rechnen(WINDOW * wp, OBJECT *tree, int operation, LINESTRUCT *begin, LINESTRUCT *end)
{
#if MSDOS
	return;
#else
	FILE *fp;
	char filename[PATH_MAX],openmodus[2],fmtstr[9]="%0.2lf\n";
	static int first=TRUE;
	int fehler, ret, kstate, n, wert1;
	double wert2,wert3,wert4,wert5,wert6;

	if(begin && end && !cut)
	{
		scrp_read(filename);
		if(!*filename)
		{
#if GEMDOS
			if(create_clip())
				scrp_read(filename);
			else
			{
				form_alert(1,Anumerik[0]);
				return;
			}
#endif
		}
		else
		{
			if(first) /* beim erstenmal Clipbrd lîschen */
			{
				scrp_clear();
				first=FALSE;
			}
		}
      complete_path(filename); /* evtl. Slash oder Backslash anhÑngen */
/*      
		if(filename[strlen(filename)-1]!='\\')
			strcat(filename,"\\");
*/
		strcat(filename,"SCRAP.TXT");
		graf_mkstate(&ret,&ret,&ret,&kstate);
		if(kstate & (K_LSHIFT|K_RSHIFT))/* bei gedrÅckter Shifttaste... */
			strcpy(openmodus,"a");					 /* an Datei anhÑngen,...*/
		else
			strcpy(openmodus,"w");				 /* ...sonst neue Datei		 */

      if(tree[NUMNORM].ob_state&SELECTED)  /* MWST lesen */
         form_read(tree,NUMMWSTN,mwst);
      if(tree[NUMERM ].ob_state&SELECTED)
         form_read(tree,NUMMWSTE,mwst);
		dt2ami(mwst); /* Dezimalkomma in Punkt wandeln, falls notwendig */

		fmtstr[3]=(char)nkst+'0';				 /* Nachkommastellen setzen */
		*alertstr=0;

		graf_mouse(BUSY_BEE,NULL);
		if((fp=fopen(filename,openmodus))!=NULL)
		{
			switch(operation)
			{
				case BLKCNT:
					fprintf(fp,"%d\n",wert1=count(begin, end));
					sprintf(alertstr,Anumerik[1],wert1);
					break;
				case BLKSUM:
					sprintf(alertstr,fmtstr,wert2=sum(begin, end));
					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
  					fprintf(fp,"%s",alertstr);
					sprintf(alertstr,Anumerik[2],wert2);
					break;
				case BLKMEAN:
					n=count(begin, end);
					if(n>1)
					{
						sprintf(alertstr,fmtstr,wert3=(sum(begin, end)/(double)n));
   					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
						fprintf(fp,"%s",alertstr);
						sprintf(alertstr,Anumerik[3],wert3);
					}
					else
						form_alert(1,Anumerik[4]);
					break;
				case BLKSDEV:
					wert4=sdev(begin, end);
					if(wert4>=0)
					{
						sprintf(alertstr,fmtstr,wert4);
   					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
						fprintf(fp,"%s",alertstr);
						sprintf(alertstr,Anumerik[5],wert4);
					}
					else
						 form_alert(1,Anumerik[6]);
					break;
				case BLKMWST:
					wert5=steuer(begin, end);
					if(wert5>=0)
					{
						sprintf(alertstr,fmtstr,wert5);
   					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
						fprintf(fp,"%s",alertstr);
						sprintf(alertstr,Anumerik[7],wert5);
					}
					else
						 form_alert(1,Anumerik[8]);
					break;
				case BLKINTER:
	            extract(&begin->string[begin->begcol], 
	                    begin->endcol-begin->begcol,
	                    filename);
					strcchg(filename,',','.'); /* Komma gegen Punkt */
					wert6=interpretiere(filename, &fehler);
					if(!fehler)
					{
						sprintf(alertstr,fmtstr,wert6);
   					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
						fprintf(fp,"%s",alertstr);
						sprintf(alertstr,Anumerik[13],wert6);
					}
					else
					{
/*
						sprintf(alertstr,Anumerik[15],(int)wert6);
						form_alert(1,alertstr);
*/
						sprintf(alertstr,Anumerik[15+fehler]);
						form_alert(1,alertstr);
						hide_blk(wp, begin, end);
						graf_mouse(M_OFF,NULL);
						Wcursor(wp);
						wp->col = (begin->begcol + (int)wert6) - wp->wfirst/wp->wscroll - 1;
						wp->cspos = Wshiftpage(wp,0,wp->cstr->used);
						Wcursor(wp);
						graf_mouse(M_ON,NULL);
						*alertstr=0;
					}
					break;
				case BLKALL:
					n=count(begin,end);
					if(n>1)
					{
						fprintf(fp,"%d\n",wert1=count(begin, end));

						sprintf(alertstr,fmtstr,wert2=sum(begin, end));
   					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
						fprintf(fp,"%s",alertstr);
	
						sprintf(alertstr,fmtstr,wert3=(sum(begin, end)/(double)n));
   					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
						fprintf(fp,"%s",alertstr);
	
						sprintf(alertstr,fmtstr,wert4=sdev(begin, end));
   					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
		 				fprintf(fp,"%s",alertstr);
	
						sprintf(alertstr,fmtstr,wert5=steuer(begin, end));
   					nconvert(alertstr); /* konvertieren entspr. der Einstellungen */
						fprintf(fp,"%s",alertstr);

						sprintf(alertstr,Anumerik[9],wert1,wert2,wert3,wert4,wert5);
					}
					else
						form_alert(1,Anumerik[4]);
					break;
			}
			fclose(fp);
			if(*alertstr)
				form_alert(1,alertstr);
		}
		else
			form_alert(1,Anumerik[10]);
		graf_mouse(ARROW,NULL);
	}
#endif
}

void hndl_nummenu(OBJECT *tree, int start, int mode)
{
	int exit_obj,c,d,e,f,g;
	char a[6],b[2],h[6];

	form_read(tree,NUMMWSTN,a);
	form_read(tree,NUMMWSTE,h);
	form_read(tree,NUMKOMMA,b);
	c=tree[NUMNDT].ob_state;
	d=tree[NUMNAMI].ob_state;
	e=tree[NUMTSEP].ob_state;
	f=tree[NUMNORM].ob_state;
	g=tree[NUMERM ].ob_state;
	form_exopen(tree,mode);
	do
	{
		exit_obj=form_exdo(tree,start);
		switch(exit_obj)
		{
			case NUMHELP:
				if(form_alert(2,Anumerik[11])==2)
					form_alert(1,Anumerik[14]);
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
				break;
			default:
				break;
		}
	}
	while(exit_obj==NUMHELP);
	form_exclose(tree,exit_obj,mode);
	if(exit_obj==NUMABBR)
	{
		form_write(tree,NUMMWSTN,a,FALSE);
		form_write(tree,NUMMWSTE,h,FALSE);
		form_write(tree,NUMKOMMA,b,FALSE);
		tree[NUMNDT].ob_state=c;
		tree[NUMNAMI].ob_state=d;
		tree[NUMTSEP].ob_state=e;
		tree[NUMNORM].ob_state=f;
		tree[NUMERM ].ob_state=g;
	}
	else
	{
		form_read(tree, NUMMWSTN, mwst); /* MWST lesen */
		if(!isfloat(mwst))				  /* korrektes Format? */
		{
			form_alert(1,Anumerik[12]);
			form_write(tree,NUMMWSTN,a,FALSE); /* Nein, zurÅcksetzen */
		}
		form_read(tree, NUMMWSTE, mwst); /* MWST lesen */
		if(!isfloat(mwst))				  /* korrektes Format? */
		{
			form_alert(1,Anumerik[12]);
			form_write(tree,NUMMWSTE,h,FALSE); /* Nein, zurÅcksetzen */
		}
		nkst=atoi(form_read(tree,NUMKOMMA,b));/* Nachkommastellen lesen */
   	if(tree[NUMNDT].ob_state & SELECTED)
   	   komma=TRUE;
   	else
   	   komma=FALSE;
	}
}
