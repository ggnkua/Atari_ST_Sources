/* Druckausgabe (auch VDI/Metafile) */
/*****************************************************************************
*
*											  7UP
*									  Modul: PRINTER.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#if GEMDOS
#include <tos.h>
#else
#include <bios.h>
#include <alloc.h>
#endif

#include "alert.h"

#include "windows.h"
#include "forms.h"
#include "7UP.h"

void _V_opnwk(int work_in[], int *handle, int work_out[]);
int open_work (int device);
void close_work (int handle, int device);
char *expandfkey(WINDOW *wp, char *str, int page);
char *split_fname(char *name);
int getfilename(char *pathname, char * pattern, char *fname, const char *meldung);
char *change_ext(char *name, char *ext);
char *change_name(char *name, char *newname);

#define TEXT	  0  /* windowtype */
#define GRAPHIC  1
#define PRT		0
#define DESK	  0
#define TRUE	  1
#define FALSE	 0
#define VERTICAL 1

#define SPOOLER_ACK 101
#define WM_BACKDROPPED	31		/* Message vom Eventhandler */

#define SCREEN			1
#define PLOTTER		 11
#define PRINTER		 21
#define METAFILE		31
#define CAMERA		  41
#define TABLET		  51

#define FONT_SYSTEM	1						 /* GEM System Font */
#define FONT_SWISS	 2						 /* Swiss Font */
#define FONT_DUTCH	14						 /* Dutch Font */

#define BELL 7
#define FORMFEED 0x0C
#define LINEFEED '\n'
#define BLANK	 ' '
#define RESET	 "\\@"
#define ESC		0x01
#define X_MIN 8
#define Y_MIN 0 /*(3*ch)*/
#define UNPRINTABLE_LINES 0  /* 2 mit Fontfix und DJ5. Ohne Fontfix > 3 */

extern int gl_apid;
extern char alertstr[];
extern char iostring[],iostr2[];
extern OBJECT *gdospop,*paperpop,*distpop,*layout;
extern int work_in[103],work_out[57];
extern int boxh,windials;

int zl=80,bl=72,or=4,kz=0,fz=0,ur=4,lr=0,zz=64,
	 pageoffset=0,fpage=1,lpage=9999,copies=1,fcol=1,lcol=512;	 /* auch fÅr Preview */

int act_dev=POPNO, act_paper=POPBASIS/*POPLETT*/, act_dist=POPD1;

#define MAXDEVICES 32

typedef struct
{
   int flags;
   int state;
   int retcode;
	char devname[25];
	int devno;
}TGDOSINFO;

typedef struct
{
   long count;
   TGDOSINFO gdosinfo[MAXDEVICES];
}TSCROLLIST;

TSCROLLIST *scrollist=NULL;

typedef struct
{
	int w,h;
}PAPERSIZE;

static PAPERSIZE ps[]=
{
/* OUTPUT	 */
		0,   0,  /* Default-Einstellung des Treibers */
	2100,3048,  /* Letter */
	2159,3556,  /* Legal  */
	2159,1397,  /* Half	*/
	3380,3048,  /* Ledger */
	2970,4200,  /* DIN A3 */
	2100,2970,  /* DIN A4 */
	1485,2100,  /* DIN A5 */
	1820,2500,  /* DIN B5 */
	3553,2794	/* Wide	*/
};

static int msgbuf[8];
static MEVENT mevent=
{
	MU_TIMER|MU_KEYBD|MU_BUTTON|MU_MESAG,
	2,1,1,
	0,0,0,0,0,
	0,0,0,0,0,
	msgbuf,
	25L,
	0,0,0,0,0,0,
/* nur der VollstÑndigkeit halber die Variablen von XGEM */
	0,0,0,0,0,
	0,
	0L,
	0L,0L
};

int is_busy(void)
{
#if GEMDOS
	return(Cprnos());
#else
	return((biosprint(2,0,0) == 0x90) | (biosprint(2,0,1) == 0x90));
							/* LPT1		oder		 LPT2 */
#endif
}

int FPRINTF(FILE* fp, const char *fmt, ...)
{
	va_list argptr;
	register int i,cnt;

	va_start(argptr,fmt);
	cnt=vsprintf(iostr2,fmt,argptr);
	if(scrollist->gdosinfo[POPNO-1].state & SELECTED/*gdospop[POPNO].ob_state & CHECKED*/) /* keine Zeichenkonvertierung */
		fprintf(fp,"%s",iostr2);
	if(scrollist->gdosinfo[POPIBM-1].state & SELECTED/*gdospop[POPIBM].ob_state & CHECKED*/) /* IBM Druckeranpassung */
	{
		for(i=0; i<cnt; i++)
		{
			switch((unsigned char)iostr2[i])
			{
				case 0x9E: /* · */
					fprintf(fp,"·");
					break;
				case 0xDD: /* › */
					fprintf(fp,"%c",0x15);
					break;
				default:
					fprintf(fp,"%c",iostr2[i]);
					break;
			}
		}
	}
	if(scrollist->gdosinfo[POPEPS-1].state & SELECTED/*gdospop[POPEPS].ob_state & CHECKED*/) /* EPSON Druckeranpassung */
	{
		for(i=0; i<cnt; i++)
		{
			switch((unsigned char)iostr2[i])
			{
				case 0x81: /* Å */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x7D,0x1B,0x52,0x00);
					break;
				case 0x84: /* Ñ */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x7B,0x1B,0x52,0x00);
					break;
				case 0x8E: /* é */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x5B,0x1B,0x52,0x00);
					break;
				case 0x94: /* î */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x7C,0x1B,0x52,0x00);
					break;
				case 0x99: /* ô */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x5C,0x1B,0x52,0x00);
					break;
				case 0x9A: /* ö */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x5D,0x1B,0x52,0x00);
					break;
				case 0x9E: /* · */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x7E,0x1B,0x52,0x00);
					break;
				case 0xDD: /* › */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x40,0x1B,0x52,0x00);
					break;
				case 0xE1: /* · */
					fprintf(fp,"%c%c%c%c%c%c%c",0x1B,0x52,0x02,0x7E,0x1B,0x52,0x00);
					break;
				default:
					fprintf(fp,"%c",iostr2[i]);
					break;
			}
		}
	}
	va_end(argptr);
	return(cnt);
}

print_block(WINDOW *wp, LINESTRUCT *beg, LINESTRUCT *end)
{
	int ret, kstate;
	LINESTRUCT *line;
/*
#if GEMDOS
	FILE *stdprn;
#endif
*/
	graf_mouse(BUSY_BEE,0L);

	if(!scrollist)
		scan_assignsys(layout, gdospop);

	if(wp && beg && end)
	{
		line=beg;
		if(is_busy())
		{
			graf_mkstate(&ret, &ret, &ret, &kstate); /* Shifttaste? */
/*
#if GEMDOS
			stdprn=fopen("PRN:","w");
#endif
*/
			do
			{
				strcpy(iostring,&line->string[line->begcol]);
				iostring[line->endcol-line->begcol]=0;
				FPRINTF(stdprn,"\r%s\r\n",iostring);
				line=line->next;
			}
			while(line!=end->next);
			fflush(stdprn);
			if(kstate & (K_LSHIFT|K_RSHIFT))		/* bei gedrÅckter Shifttaste... */
				FPRINTF(stdprn,"%c",FORMFEED);	  /* ...FORMFEED senden */
/*
#if GEMDOS
			fclose(stdprn);
#endif
*/
		}
		else
			form_alert(1,Aprinter[0]);
	}
	graf_mouse(ARROW,0L);
}

spool(char *filename, int copies, int mode)
{
	unsigned int spoolmsg[8];
	int accid;
	accid=appl_find("CALCLOCK");/* genau 8 Buchstaben, sonst mit BLANKS auffÅllen */
	if(accid<0)
		accid=appl_find("1STGUIDE");/* genau 8 Buchstaben, sonst mit BLANKS auffÅllen */
	if(accid>=0)
	{
		spoolmsg[0]=100;
		spoolmsg[1]=gl_apid;
		spoolmsg[2]=0;		 /* lt. DRI -1, darf aber nicht so sein! */
		spoolmsg[3]=strlen(filename);
#if MSDOS
		spoolmsg[5]=(unsigned int)((long)filename >> 16);
		spoolmsg[4]=(unsigned int)((long)filename & 0xffff);
#else
		spoolmsg[4]=(unsigned int)((long)filename >> 16);
		spoolmsg[5]=(unsigned int)((long)filename & 0xffff);
#endif
		spoolmsg[6]=copies;
		spoolmsg[7]=mode;
#if OLDTOS
		wind_update(END_UPDATE);
#endif
		appl_write(accid,16,spoolmsg);
#if OLDTOS
		wind_update(BEG_UPDATE);
#endif
	}
	else
		form_alert(1,Aprinter[1]);
}

static int draftprint(OBJECT *tree1, OBJECT *tree2, OBJECT *tree3, WINDOW *wp, FILE *fp)
{
	register LINESTRUCT *line;
	int i,k,m,pages,ret,blanks,inrange,mouse_click;
	long lines,chars,count=1;
	char c1,c2,*str;
	FILE *save;
	int event,wh,result=TRUE;
	extern int dial_handle;
/*
	graf_mouse(BUSY_BEE,NULL);
*/
	save=fp;													  /* Filepointer retten */
	form_write(tree1,PRTNAME,(char *)Wname(wp),FALSE);
	form_write(tree1,PRTPAGE,"",FALSE);
	tree1[ROOT+1].ob_flags|=HIDETREE;
	form_exopen(tree1,FALSE);
	Wtxtsize(wp,&lines,&chars);
	pages=lines%zz ? (lines/zz)+1 : lines/zz;			/* Anzahl der Seiten */
	line=wp->fstr;
	for(i=0;i<pages;i++)											/* fÅr jede Seite */
	{
		event=evnt_event(&mevent);
/*
		wind_update(BEG_UPDATE);
*/
		if(event & MU_MESAG)
		{
			if((msgbuf[0] != MN_SELECTED) && (msgbuf[0] < 50)) /* AP_TERM */
			{
				if(msgbuf[3]==dial_handle) /* Dialogfenster */
				{
					switch(msgbuf[0])
					{
						case WM_BACKDROPPED: /* nein, niemals */
							break;
						case WM_REDRAW:
							fwind_redraw(tree1,msgbuf[3],&msgbuf[4]);
							break;
						case WM_MOVED:
							fwind_move(tree1,msgbuf[3],&msgbuf[4]);
							break;
						case WM_TOPPED:
							wind_set(msgbuf[3],WF_TOP,0,0,0,0);
							break;
					}
				}
				else /* aber kein Schlie·en oder Toppen */
					if(msgbuf[0]!=WM_CLOSED && msgbuf[0]!=WM_TOPPED)
						Wwindmsg(Wp(msgbuf[3]),msgbuf);
			}
		}
		if(event&MU_KEYBD || event&MU_BUTTON)
		{
			if((mevent.e_kr>>8)==ESC ||							 /* ESC gedrÅckt? */
				 objc_find(tree1,ROOT,MAX_DEPTH,mevent.e_mx,mevent.e_my)==PRTESC)
			{
				objc_change(tree1,PRTESC,0,tree1->ob_x,tree1->ob_y,
													tree1->ob_width,tree1->ob_height,
													tree1[PRTESC].ob_state|SELECTED,TRUE);
				if(form_alert(2,Aprinter[4])==2)
				{
/*
					wind_update(END_UPDATE);
*/
					result=FALSE;
					goto ENDE;
				}
				objc_change(tree1,PRTESC,0,tree1->ob_x,tree1->ob_y,
													tree1->ob_width,tree1->ob_height,
													tree1[PRTESC].ob_state&~SELECTED,TRUE);
			}
		}
/*
		wind_update(END_UPDATE);
*/
		if(i+1+pageoffset <fpage)							  /* von, bis drucken */
		{
			fp=NULL;
			inrange=FALSE;
		}
		else
		{
			fp=save;
			inrange=TRUE;
		}
		if(i+1+pageoffset >lpage)
		{
			goto ENDE;
		}

		if(inrange && !(tree3[PRNALLP].ob_state&SELECTED)) /* wenn nicht alle Seiten */
		{
			if(tree3[PRNPAIR].ob_state&SELECTED)		  /* nur gerade Seiten */
			{
				if((i+1+pageoffset)%2)					  /* bei ungerade weiter */
					fp=NULL;
				else
					fp=save;
			}
			else												  /* nur ungerade Seiten */
			{
				if(!((i+1+pageoffset)%2))					 /* bei gerade weiter */
					fp=NULL;
				else
					fp=save;
			}
		}

		if(fp)
		{
			sprintf(alertstr,"%d",i+1);				 /* Seitennummer anzeigen */
			form_write(tree1,PRTPAGE,alertstr,TRUE);
		}

		for(k=0;k<or;k++)
			if(fp) FPRINTF(fp,"\r\n");								/* oberer Rand */
		if(kz)																 /* Kopfzeile */
		{
			str=expandfkey(wp,form_read(tree2,PRNKZSTR,alertstr),i+1+pageoffset);
			ret=strlen(str);
			if(tree2[PRNKZL].ob_state&SELECTED)							/* links */
				blanks=lr;
			if(tree2[PRNKZM].ob_state&SELECTED)							/* mitte */
				blanks=lr+(zl-ret)/2;
			if(tree2[PRNKZR].ob_state&SELECTED)						  /* rechts */
				blanks=(lr+zl-ret);

			if(tree3[PRNALT].ob_state&SELECTED)
			{
				if(!((i+1+pageoffset)%2))	/* bei geraden Seiten vertauschen */
				{
					if(tree2[PRNKZR].ob_state&SELECTED)				  /* rechts */
						blanks=lr;
					if(tree2[PRNKZL].ob_state&SELECTED)					/* links */
						blanks=(lr+zl-ret);
				}
			}

			for(k=0; k<blanks; k++)
				if(fp) FPRINTF(fp," ");										/* BLANK */

			if(i==0) /* erste seite */
			{
				if(!(tree3[PRNKFBEG].ob_state&SELECTED))			/* Kopfzeile */
				{
					if(fp)
						FPRINTF(fp,"\r\n");				  /* !KZ in erster Zeile */
				}
				else
					if(fp)
						FPRINTF(fp,"%s\r\n",str);			 /* Kopfzeile drucken */
			}
			else
				if(fp)
					FPRINTF(fp,"%s\r\n",str);				 /* Kopfzeile drucken */
			for(k=0; k<(kz-1); k++)
				if(fp) FPRINTF(fp,"\r\n");								 /* rest KZ */
		}
		for(k=0; k<zz && line; k++, line=line->next,count++)
		{
			if(*line->string!=FORMFEED)
			{
				if(tree3[PRNCUT].ob_state&SELECTED)/* Åberlange Zeilen abschneiden */
				{
					if(zl<line->used)
					{
						c1=line->string[zl];
						line->string[zl]=0;
					}
				}
				for(m=0;m<lr;m++)
					if(fp) FPRINTF(fp," ");				  /* BLANK, linker Rand */

				if(lcol<line->used)
				{
					c2=line->string[lcol];							 /* Druckspalte */
					line->string[lcol]=0;
				}

				if(tree3[PRNNUM].ob_state & SELECTED)	/* Zeilennummerierung */
					if(fp) FPRINTF(fp,"%5ld: ",count);

				if((fcol-1)<line->used)
				{
					if(fp) FPRINTF(fp,"%s\r\n",&line->string[fcol-1]); /* Zeilen drucken */
				}
				else
				{
					if(fp) FPRINTF(fp,"\r\n");					  /* CRLF drucken */
				}
				if(lcol<line->used)
					line->string[lcol]=c2;

				if(tree3[PRNCUT].ob_state&SELECTED)
				{
					if(zl<line->used)
					{
						line->string[zl]=c1;
					}
				}
			}
			else
			{
				line=line->next;
				lines+=(zz-k);							  /* ...Zeilenzahl erhîhen */
				pages=lines%zz ? (lines/zz)+1 : lines/zz;/* Anzahl der Seiten */
				break;					  /* Seite beenden, aber FF nicht senden */
			}
		} /* for(k - zz) */
		if(i<(pages-1))
		{
			for(; k<zz; k++)								  /* evtl. Leerzeilen */
				if(fp) FPRINTF(fp,"\r\n");
		}
		else /* wenn letzte Seite... */
		{
			if(fz || tree3[PRNFF].ob_state&SELECTED)/* nur bei FZ oder Knopf */
				for(; k<zz; k++)								 /* evtl. Leerzeilen */
					if(fp) FPRINTF(fp,"\r\n");
		}
		if(fz)																  /* Fu·zeile */
		{
			str=expandfkey(wp,form_read(tree2,PRNFZSTR,alertstr),i+1+pageoffset);
			ret=strlen(str);
			for(k=0; k<(fz-1); k++)
				if(fp) FPRINTF(fp,"\r\n");						 /* Fu·leerzeilen */
			if(tree2[PRNFZL].ob_state&SELECTED)							/* links */
				blanks=lr;
			if(tree2[PRNFZM].ob_state&SELECTED)							/* mitte */
				blanks=lr+(zl-ret)/2;
			if(tree2[PRNFZR].ob_state&SELECTED)						  /* rechts */
				blanks=(lr+zl-ret);

			if(tree3[PRNALT].ob_state&SELECTED)
			{
				if(!((i+1+pageoffset)%2))			  /* bei geraden Seiten vertauschen */
				{
					if(tree2[PRNFZR].ob_state&SELECTED)				  /* rechts */
						blanks=lr;
					if(tree2[PRNFZL].ob_state&SELECTED)					/* links */
						blanks=(lr+zl-ret);
				}
			}
			for(k=0; k<blanks; k++)
				if(fp) FPRINTF(fp," ");											/* FZ */
			if(i==0) /* erste Zeile */
			{
				if(!(tree3[PRNKFBEG].ob_state&SELECTED))			/* Fu·zeile? */
				{
					if(fp)
						FPRINTF(fp,"\r\n");									  /* nein */
				}
				else
					if(fp)
						FPRINTF(fp,"%s\r\n",str);			  /* Fu·zeile drucken */
			}
			else
				if(fp)
					FPRINTF(fp,"%s\r\n",str);				  /* Fu·zeile drucken */
		}/* fz */

		if(!(tree3[PRNFILE].ob_state&SELECTED))		/* wenn NICHT in Datei */
		{
			if(i<(pages-1))
			{
				if(ur)											 /* nur wenn unterer Rand */
					if(fp) FPRINTF(fp,"%c",FORMFEED);			  /* Seitenvorschub */
			}
			else
			{
				if(fz || tree3[PRNFF].ob_state&SELECTED)	 /* FF am Textende? */
					if(fp) FPRINTF(fp,"%c",FORMFEED);		  /* Seitenvorschub */
			}
		}
		else  /* in Datei drucken */
		{
			if(i<(pages-1))
			{													 /* nur wenn unterer Rand */
				for(k=0;k<ur;k++)
					if(fp) FPRINTF(fp,"\r\n");					 /* unterer Rand */
			}
		}
		if(tree3[PRNPAUSE].ob_state&SELECTED)
			if(form_alert(2,Aprinter[2])==1)
			{
				result=FALSE;
				goto ENDE;
			}
	}
ENDE:
	fp=save;
	fflush(fp);															 /* rausrotzen */
	form_exclose(tree1,-1,FALSE);
	tree1[PRTESC].ob_state&=~SELECTED;								/* Bit lîschen! */
/*
	graf_mouse(ARROW,NULL);
*/
	return(result);
}

static char *make_print_name(char *pname, char *name, char *ext)
{
	int k;
	strcpy(pname,name);
	k=strlen(pname);
	if(pname[k-1]=='.')
		pname[k-1]=0;
	if(pname[k-2]=='.')
		pname[k-2]=0;
	if(pname[k-3]=='.')
		pname[k-3]=0;
	if(pname[k-4]=='.')
		pname[k-4]=0;
	strcat(pname,ext);
	return(pname);
}

void hndl_prtmenu(OBJECT *tree1, OBJECT *tree2, OBJECT *tree3, WINDOW *wp)
{
	FILE *fp;
	static char filename[PATH_MAX];	  /* wg. Spooler */
	int exit_obj;
	int a,b,c,d,e,f,g,h,i,j,k,l,m,kstate;
	int x,y,mx,my,ret,done=FALSE;
	static char fpattern[13]="";
	LINESTRUCT *line,*beg,*end;

#if GEMDOS
	int buff[2048];
#endif

	if(!wp)
	  return;
	if((act_dev>=POP21 && !vq_gdos()) ||
		(act_dev>gdospop->ob_height/boxh)) /* ein Drucker weniger in Assign.sys */
	{  /* Assign.sys fehlt wohl, und Seitenlayout wurde noch nicht beachtet */
		form_alert(1,Aprinter[3]);
		return;
	}
	if(act_dev>=POP21 || (appl_find("CALCLOCK")<0 && appl_find("1STGUIDE")<0))
	{  /* nicht bei GDOS oder wenn die Spoolaccs fehlen */
		tree3[PRNBACK].ob_state&=~SELECTED;
		tree3[PRNBACK].ob_state|= DISABLED;
		tree3[PRNDEL].ob_state&=~SELECTED;
		tree3[PRNDEL].ob_state|= DISABLED;
	}
	else
	{
		tree3[PRNBACK].ob_state&=~DISABLED;
		tree3[PRNDEL ].ob_state&=~DISABLED;
	}
	sprintf(tree3[PRNPGOFF].ob_spec.tedinfo->te_ptext,"%0004d",pageoffset);
	sprintf(tree3[PRNFROM].ob_spec.tedinfo->te_ptext,"%0004d",fpage);
	sprintf(tree3[PRNTO].ob_spec.tedinfo->te_ptext,"%0004d",lpage);
	sprintf(tree3[PRNFCOL].ob_spec.tedinfo->te_ptext,"%003d",fcol);
	sprintf(tree3[PRNLCOL].ob_spec.tedinfo->te_ptext,"%003d",lcol);
	sprintf(tree3[PRNCOPY].ob_spec.tedinfo->te_ptext,"%02d",copies);
	a=tree3[PRNNUM  ].ob_state; /* Objektstati fÅr ABBRUCH merken */
	b=tree3[PRNFILE ].ob_state;
	c=tree3[PRNBACK ].ob_state;
	d=tree3[PRNDEL  ].ob_state;
	e=tree3[PRNKFBEG].ob_state;
	f=tree3[PRNALT  ].ob_state;
	g=tree3[PRNCUT  ].ob_state;
	h=tree3[PRNALLP ].ob_state;
	i=tree3[PRNPAIR ].ob_state;
	j=tree3[PRNUNPA ].ob_state;
	k=tree3[PRNPAUSE].ob_state;
	l=tree3[PRNFF	].ob_state;

	if(!scrollist)
		scan_assignsys(layout, gdospop);
	  
	form_exopen(tree3,0);
	do
	{
		exit_obj=(form_exdo(tree3,0)&0x7fff);
		switch(exit_obj)
		{
			case PRN2HELP:
				form_alert(1,Aprinter[6]);
				objc_change(tree3,exit_obj,0,tree3->ob_x,tree3->ob_y,
					tree3->ob_width,tree3->ob_height,tree3[exit_obj].ob_state&~SELECTED,TRUE);
				break;
			case PRN2ABBR:
			case PRN2OK:
				done=TRUE;
				break;
		}
	}
	while(!done);
	form_exclose(tree3,exit_obj,0);
	if(exit_obj!=PRN2OK)
	{
		tree3[PRNNUM  ].ob_state=a; /* alles rÅckgÑngig machen */
		tree3[PRNFILE ].ob_state=b;
		tree3[PRNBACK ].ob_state=c;
		tree3[PRNDEL  ].ob_state=d;
		tree3[PRNKFBEG].ob_state=e;
		tree3[PRNALT  ].ob_state=f;
		tree3[PRNCUT  ].ob_state=g;
		tree3[PRNALLP ].ob_state=h;
		tree3[PRNPAIR ].ob_state=i;
		tree3[PRNUNPA ].ob_state=j;
		tree3[PRNPAUSE].ob_state=k;
		tree3[PRNFF	].ob_state=l;
		return;
	}
	if(windials)
	{
		mevent.e_flags|=MU_MESAG;
		graf_mouse(M_OFF,0L);
		Wcursor(wp);		 /* ausschalten */
		evnt_event(&mevent); /* Dummyaufruf um Redraw zu killen */
		Wredraw(wp,&msgbuf[4]);
		Wcursor(wp);		 /* einschalten */
		graf_mouse(M_ON,0L);
	}
	else
		mevent.e_flags&=~MU_MESAG;
	pageoffset=atoi(form_read(tree3,PRNPGOFF,alertstr));
	fpage=atoi(form_read(tree3,PRNFROM,alertstr));
	lpage=atoi(form_read(tree3,PRNTO,alertstr));
	if(fpage>lpage || fpage==0 || lpage==0)
	{
		form_alert(1,Aprinter[7]);
		fpage=1;
		lpage=9999;
		return;
	}
	fcol=atoi(form_read(tree3,PRNFCOL,alertstr));
	lcol=atoi(form_read(tree3,PRNLCOL,alertstr));
	if(fcol>lcol || fcol==0 || lcol==0 || lcol>512)
	{
		form_alert(1,Aprinter[8]);
		fcol=1;
		lcol=512;
		return;
	}
	copies=atoi(form_read(tree3,PRNCOPY,alertstr));
	if(copies==0)
	{
		form_alert(1,Aprinter[9]);
		copies=1;
		return;
	}
	if(act_dev>=POP21)
	{
		if(tree3[PRNFILE].ob_state&SELECTED)
		{
			make_print_name(alertstr,(char *)Wname(wp),".GEM");
			filename[0]=0;
			strcpy(fpattern,"*.GEM");
			if(getfilename(filename,fpattern,split_fname(alertstr),fselmsg[19]))
			{
				gdosprint(tree1,tree2,tree3,wp,METAFILE,filename);
			}
		}
		else
		{
			for(m=0; m<copies; m++)
			{
				sprintf(alertstr,"%d",m+1);
				form_write(tree1,PRTCOPY,alertstr,FALSE);
				make_print_name(filename,(char *)Wname(wp),".GEM");
				if(!gdosprint(tree1,tree2,tree3,wp,v_getdevice(scrollist)/*act_dev-POP21+21*/,filename))
					break;
			}
		}
	}
	else
	{
		if(tree3[PRNBACK].ob_state&SELECTED)
		{
			make_print_name(filename,(char *)Wname(wp),".PRN");
			if((fp=fopen(filename,"wb"))!=NULL)
			{
#if GEMDOS
				if(setvbuf(fp,NULL,_IOFBF,32*1024L-1))
					setvbuf(fp,buff,_IOFBF,sizeof(buff));
#endif
				draftprint(tree1,tree2,tree3,wp,fp);
				fclose(fp);
				spool(filename,copies,tree3[PRNDEL].ob_state&SELECTED?TRUE:FALSE);
			}
			else
				form_alert(1,Aprinter[10]);
			return;
		}
		if(tree3[PRNFILE].ob_state&SELECTED)
		{
			filename[0]=0;
			strcpy(fpattern,"*.PRN");
			if(getfilename(filename,fpattern,"@",fselmsg[20]))
			{
				if((fp=fopen(filename,"wb"))!=NULL)
				{
#if GEMDOS
					if(setvbuf(fp,NULL,_IOFBF,32*1024L-1))
						setvbuf(fp,buff,_IOFBF,sizeof(buff));
#endif
					draftprint(tree1,tree2,tree3,wp,fp);
					fclose(fp);
				}
				else
					form_alert(1,Aprinter[11]);
			}
			return;
		}

#if GEMDOS
		Ongibit(32); /* Deskjet erwache! aber nur einmal, statt in is_busy() */
#endif
		while(!is_busy())
		{
			if(form_alert(2,Aprinter[5])==1)
				return;
#if GEMDOS
			Ongibit(32); /* Deskjet erwache! aber nur einmal, statt in is_busy() */
#endif
		}
		if(tree3[PRNNOFORM].ob_state&SELECTED)
		{
			for(m=0; m<copies; m++)
			{
				line=wp->fstr;
				if(is_busy())
				{
					graf_mkstate(&ret, &ret, &ret, &kstate); /* Shifttaste? */
					do
					{
						FPRINTF(stdprn,"\r%s\r\n",line->string);
						line=line->next;
					}
					while(line!=NULL);
					fflush(stdprn);
					if(kstate & (K_LSHIFT|K_RSHIFT))		/* bei gedrÅckter Shifttaste... */
						FPRINTF(stdprn,"%c",FORMFEED);	  /* ...FORMFEED senden */
				}
				else
				{
					form_alert(1,Aprinter[0]);
					return;
				}
			}
		}
		else
		{
			for(m=0; m<copies; m++)
			{
				sprintf(alertstr,"%d",m+1);
				form_write(tree1,PRTCOPY,alertstr,FALSE);
				if(!draftprint(tree1,tree2,tree3,wp,stdprn))
					break;
			}
		}
	}
	return;
}

void spool_file(void)
{
	char filename[PATH_MAX];
	static char fpattern[13]="*.*";
	filename[0]=0;
	if(!getfilename(filename,fpattern,"",fselmsg[21]))
		return;
	spool(filename,1,FALSE);
}

#if GEMDOS
static int scan_assignsys(OBJECT *tree, OBJECT *pop)
{
	char *cp/*,devstr[4],assignsys[]="@:\\ASSIGN.SYS"*/;
	int i,first;
/*
	FILE *fp;
*/
	int handle,exists;
	char name[33];
	
	scrollist = (TSCROLLIST *)malloc(sizeof(TSCROLLIST));
	memset(scrollist,0,sizeof(TSCROLLIST));

	scrollist->count=3;
	
	scrollist->gdosinfo[0].state |= SELECTED;
	scrollist->gdosinfo[0].retcode=1;
#ifdef ENGLISH
	strcpy(scrollist->gdosinfo[0].devname,"  undefinied  ");
#else
	strcpy(scrollist->gdosinfo[0].devname,"  undefiniert ");
#endif
	scrollist->gdosinfo[0].devno=0;
	
	scrollist->gdosinfo[1].retcode=2;
	strcpy(scrollist->gdosinfo[1].devname,"  Epson ESC/P ");
	scrollist->gdosinfo[1].devno=0;

	scrollist->gdosinfo[2].retcode=3;
	strcpy(scrollist->gdosinfo[2].devname,"  IBM Pro     ");
	scrollist->gdosinfo[2].devno=0;
	
	if(vq_gdos())
	{
		graf_mouse(BUSY_BEE,NULL);
		first=TRUE;
		for(i=11; (i<100) && (scrollist->count<MAXDEVICES); i++)
		{
			if((handle=open_work(i))>0)
			{
				if(first && (i>=PRINTER) && (i<=PRINTER+10))
				{
					ps[0].w = (int)((long)work_out[0]*(long)work_out[3]/100);
					ps[0].h = (int)((long)work_out[1]*(long)work_out[4]/100);
/*
					sprintf((char *)pop[POPBASIS].ob_spec.index,
								"  %3d x %3d ",
								ps[0].w/10, ps[0].h/10);
*/
					sprintf((char *)tree[PRNPAPER].ob_spec.index,
								"  %3d x %3d ",
								ps[0].w/10, ps[0].h/10);

					first = FALSE;
				}
				scrollist->gdosinfo[scrollist->count].retcode=scrollist->count+1;
				scrollist->gdosinfo[scrollist->count].devno=i;
				if(vq_vgdos()==0x5F46534D) /* Abfragbar ab Vektor GDOS */
				{
					memset(name,0,sizeof(name));
					vqt_devinfo(handle,i,&exists,name);
					if(exists)
					{
						if((cp=strrchr(name,'.'))!=NULL) /* '.SYS' weg */
							*cp=0;
						sprintf(scrollist->gdosinfo[scrollist->count].devname,"  %2d %-8s  ",i,name);
					}
					else
						sprintf(scrollist->gdosinfo[scrollist->count].devname,"  %2d %-8s  ",i,"GDOS");
				}
				else
					sprintf(scrollist->gdosinfo[scrollist->count].devname,"  %2d %-8s  ",i,"GDOS");
				scrollist->count++;
				close_work(handle,i);
			}
		}
		unlink("GEMFILE.GEM");
		graf_mouse(ARROW,NULL);
	}
/*	
	devcount=0;
	assignsys[0]=(char)(getbootdev()+'A');
	if((fp=fopen(assignsys,"r"))!=NULL)
	{
		while(fgets(alertstr,PATH_MAX,fp))
		{
			if(*alertstr != ';') /* Kommentarzeile */
			{
				for(i=PRINTER; i<METAFILE; i++)
				{
					sprintf(devstr,"%2d",i);
					if(!strncmp(devstr,alertstr,2))
					{
						if(tolower(alertstr[2])=='r') /* residenter Treiber */
							sscanf(&alertstr[4],"%s",&alertstr[100]);
						else
							sscanf(&alertstr[3],"%s",&alertstr[100]);
						strcpy(alertstr,&alertstr[100]);
						if((cp=strrchr(alertstr,'.'))!=NULL)
							*(cp+1)=0;

						alertstr[strlen(alertstr)-1]=' ';
						sprintf((char *)tree[i-PRINTER+POP21].ob_spec.index+5L,
								  "%-8s",alertstr);
						devcount++;
						break;
					}
				}
			}
		}
		fclose(fp);
	}
*/
	return(scrollist->count);
}
#endif

int v_getdevice(TSCROLLIST *list)
{
	int i;
	for(i=3; i<list->count; i++)
		if(list->gdosinfo[i].state & SELECTED)
			return(list->gdosinfo[i].devno);
}

static void verify_printable_lines(WINDOW *wp)
{
	int device,i,handle,ret,ch,id,size;
	
	if(wp && act_dev>=POP21 && vq_gdos())
	{
		graf_mouse(BUSY_BEE,NULL);
		device=v_getdevice(scrollist);
		if((handle=open_work(device/*act_dev-POP21+PRINTER*/))>0)
		{
#if GEMDOS
			close_work(handle,device/*act_dev-POP21+PRINTER*/);
			_VDIParBlk.contrl[1] = 1;
			_VDIParBlk.ptsin [0] = (int)((long)ps[act_paper-POPBASIS/*POPLETT*/].w*100/work_out[3]);
			_VDIParBlk.ptsin [1] = (int)((long)ps[act_paper-POPBASIS/*POPLETT*/].h*100/work_out[4]);
			for (i = 0; i < 103; i++) work_in [i] = 1;
			work_in [0]  = device/*act_dev-POP21+PRINTER*/;				/* Devicehandle */
			work_in [10] = 2;								  /* Raster Koordinaten */
			work_in [11] = 255;		 /* OW_NOCHANGE parallel or serial port */
			_V_opnwk (work_in, &handle, work_out);	 /* physikalisch îffnen */
#endif
         if(vq_vgdos()==0x5F46534D)
            vst_scratch(handle,2); /* FSM Scratchbuffer auf null, sonst geht nicht */
			vst_load_fonts(handle,0);								 /* Fonts laden */
			id=vst_font(handle,wp->fontid);							 /* Font wÑhlen */
			size=vst_point(handle,wp->fontsize,&ret,&ret,&ret,&ch);		  /* pts */
			if(id!=wp->fontid || size!=wp->fontsize)
				form_alert(1,Aprinter[15]);		 /* Warnung ausgeben */
			else
			{
				if(act_dist==POPD1)
					bl=min(bl,(int)((long)ps[act_paper-POPBASIS/*POPLETT*/].h*100/work_out[4]/ch-UNPRINTABLE_LINES));
				if(act_dist==POPD1+1)
					bl=min(bl,(int)((long)ps[act_paper-POPBASIS/*POPLETT*/].h*100/work_out[4]/ch-UNPRINTABLE_LINES)*2/3);
				if(act_dist==POPD1+2)
					bl=min(bl,(int)((long)ps[act_paper-POPBASIS/*POPLETT*/].h*100/work_out[4]/ch-UNPRINTABLE_LINES)/2);
			}
			vst_unload_fonts(handle,0);						 /* Fonts freigeben */
			close_work(handle,device/*act_dev-POP21+PRINTER*/);
		}
		graf_mouse(ARROW,NULL);
	}
	return;
}

void hndl_layout(OBJECT *tree, int start)
{
	int id,pt,i,handle,x,y,mx,my,ret,ch,exit_obj,done=FALSE;
	static int first=TRUE;
	WINDOW *wp;
	char str1[31],str2[31],str3[FILENAME_MAX],
	     *cp,pathname[PATH_MAX],filename[13];
	int A,B,C,D,E,F,G,H,I,J,K,L,M,N;
	/*static*/ char fpattern[FILENAME_MAX]="*.LAY";
	
/*
	extern int windials;
*/
	graf_mouse(BUSY_BEE,0L);
	wp=Wgettop();
	if(first)
	{
		search_env(pathname,"7UP.LAY",FALSE); /* READ */
		if(fexist(pathname)/* 23.10.94 shel_find(pathname)*/)
		{
			form_write(tree,PRNLAY,(char *)split_fname(pathname),FALSE);
			loadformat(tree,pathname);
		}
		else
			form_write(tree,PRNLAY,"",FALSE);
#if GEMDOS
		if(!scrollist)
			scan_assignsys(tree, gdospop);
		strcpy((char *)tree[PRNDRUCK].ob_spec.index, 
			scrollist->gdosinfo[POPNO-1].devname);

/*
		if(vq_gdos())
			i=scan_assignsys(gdospop)+PRINTER;
		else
			i=PRINTER;
		gdospop->ob_height=3*boxh+(i-PRINTER)*boxh;

		if(act_dev>gdospop->ob_height/boxh)
			act_dev=POPNO;
		if(act_dev>POPIBM && !vq_gdos()) /* Kein GDOS mehr da */
			act_dev=POPNO;
		if(act_dist>POPD1 && !vq_gdos()) /* Kein GDOS mehr da */
			act_dist=POPD1;
		if(act_dev>POPIBM)					/* Zeilenzahl einstellen */
			verify_printable_lines(wp);

		gdospop [act_dev  ].ob_state|=CHECKED;
		strcpy((char *)tree[PRNDRUCK].ob_spec.index,
				 (char *)gdospop[act_dev].ob_spec.index);
*/
#else
		gdospop->ob_height=3*boxh;
#endif
		first=FALSE;
	}

	if(wp)							 /* Falls Fenster offen... */
	{
		strcpy(filename,split_fname((char *)Wname(wp)));
		change_ext(filename,".LAY");
		search_env(pathname,filename,FALSE); /* READ */
		if(fexist(pathname)/* 23.10.94 shel_find(pathname)*/)
		{
			form_write(tree,PRNLAY,(char *)split_fname(pathname),FALSE);
			loadformat(tree,pathname);
		}
	}

	sprintf(tree[PRNZL].ob_spec.tedinfo->te_ptext,"%3d", A=zl);
	sprintf(tree[PRNBL].ob_spec.tedinfo->te_ptext,"%3d", B=bl);
	sprintf(tree[PRNOR].ob_spec.tedinfo->te_ptext,"%02d",C=or);
	sprintf(tree[PRNKZ].ob_spec.tedinfo->te_ptext,"%02d",D=kz);
	sprintf(tree[PRNFZ].ob_spec.tedinfo->te_ptext,"%02d",E=fz);
	sprintf(tree[PRNUR].ob_spec.tedinfo->te_ptext,"%02d",F=ur);
	sprintf(tree[PRNLR].ob_spec.tedinfo->te_ptext,"%02d",G=lr);
	sprintf(tree[PRNZZ].ob_spec.tedinfo->te_ptext,"%3d", H=zz);
	I=tree[PRNKZL].ob_state;
	J=tree[PRNKZM].ob_state;
	K=tree[PRNKZR].ob_state;
	L=tree[PRNFZL].ob_state;
	M=tree[PRNFZM].ob_state;
	N=tree[PRNFZR].ob_state;
	form_read(tree,PRNKZSTR,str1);
	form_read(tree,PRNFZSTR,str2);
	form_read(tree,PRNLAY,str3);

	if(act_dev<POP21)
	{
		tree[PRNPAPER].ob_state|=DISABLED;
		tree[PRNCIRC1].ob_state|=DISABLED;
		tree[PRNDIST ].ob_state|=DISABLED;
		tree[PRNCIRC3].ob_state|=DISABLED;
		tree[PRNPAPER].ob_flags&=~TOUCHEXIT;
		tree[PRNCIRC1].ob_flags&=~TOUCHEXIT;
		tree[PRNDIST ].ob_flags&=~TOUCHEXIT;
		tree[PRNCIRC3].ob_flags&=~TOUCHEXIT;
	}
	else
	{
		tree[PRNPAPER].ob_state&=~DISABLED;
		tree[PRNCIRC1].ob_state&=~DISABLED;
		tree[PRNDIST ].ob_state&=~DISABLED;
		tree[PRNCIRC3].ob_state&=~DISABLED;
		tree[PRNPAPER].ob_flags|=TOUCHEXIT;
		tree[PRNCIRC1].ob_flags|=TOUCHEXIT;
		tree[PRNDIST ].ob_flags|=TOUCHEXIT;
		tree[PRNCIRC3].ob_flags|=TOUCHEXIT;
	}

	graf_mouse(ARROW,0L);

	form_exopen(tree,0);
	do
	{
		exit_obj=(form_exdo(tree,start)&0x7FFF);
		switch(exit_obj)
		{
			case PRNPAPER:
				graf_mkstate(&mx,&my,&ret,&ret);
				objc_offset(tree,PRNPAPER,&x,&y);
				mx=x+tree[PRNPAPER].ob_width/2;
				my=y+(POPWIDE-POPBASIS+1)*boxh/2-(act_paper-POPBASIS/*POPLETT*/)*boxh;
				switch(ret=pop_exhndl(paperpop,mx,my,TRUE))
				{
					case POPBASIS:
					case POPLETT :
					case POPLEGA :
					case POPHALF :
					case POPLEDG :
					case POPA3	:
					case POPA4	:
					case POPA5	:
					case POPB5	:
					case POPWIDE :
						if(ret!=act_paper)
						{
							paperpop[act_paper].ob_state&=~CHECKED;
							act_paper=ret;
							paperpop[act_paper].ob_state|=CHECKED;
/*
							strcpy((char *)tree[PRNPAPER].ob_spec.index,
									 (char *)paperpop[ret].ob_spec.index);
*/
							sprintf((char *)tree[PRNPAPER].ob_spec.index,
										"  %3d x %3d ",
										ps[act_paper-1].w/10, ps[act_paper-1].h/10);

		               objc_draw(tree,PRNPAPER,0,x,y,
      		            		 tree[PRNPAPER].ob_width-1,tree[PRNPAPER].ob_height);
/*
							objc_update(tree,PRNPAPER,0);
*/
							verify_printable_lines(wp);
							goto BL;
						}
				}
				break;
			case PRNCIRC1:
				objc_offset(tree,PRNPAPER,&x,&y);
				paperpop[act_paper].ob_state&=~CHECKED;
				if(++act_paper>POPWIDE)
					act_paper=POPBASIS/*POPLETT*/;
				paperpop[act_paper].ob_state|=CHECKED;
				strcpy((char *)tree[PRNPAPER].ob_spec.index,
						 (char *)paperpop[act_paper].ob_spec.index);
				objc_draw(tree,PRNPAPER,0,x,y,
					tree[PRNPAPER].ob_width-1,tree[PRNPAPER].ob_height);
				objc_update(tree,PRNPAPER,0);
				verify_printable_lines(wp);
				evnt_timer(125,0);
				goto BL;
				break;
			case PRNCIRC2:
			case PRNDRUCK:
				graf_mkstate(&mx,&my,&ret,&ret);
				objc_offset(tree,PRNDRUCK,&x,&y);
				ret=listbox_hndl(tree,PRNDRUCK,scrollist);

				/*MT 11.5.95 weil kein TOUCHEXIT mehr*/
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,
					tree->ob_width,tree->ob_height,
					tree[exit_obj].ob_state&~SELECTED,TRUE);

				if((ret!=-1) && (act_dev!=ret))
            {
               act_dev=ret;
					strcpy((char *)tree[PRNDRUCK].ob_spec.index, 
						scrollist->gdosinfo[ret-1].devname);
               objc_draw(tree,PRNDRUCK,0,x,y,
                  tree[PRNDRUCK].ob_width-1,tree[PRNDRUCK].ob_height);

					if(act_dev<POP21)
					{
						tree[PRNPAPER].ob_state|=DISABLED;
						tree[PRNCIRC1].ob_state|=DISABLED;
						tree[PRNDIST ].ob_state|=DISABLED;
						tree[PRNCIRC3].ob_state|=DISABLED;
						tree[PRNPAPER].ob_flags&=~TOUCHEXIT;
						tree[PRNCIRC1].ob_flags&=~TOUCHEXIT;
						tree[PRNDIST ].ob_flags&=~TOUCHEXIT;
						tree[PRNCIRC3].ob_flags&=~TOUCHEXIT;
					}
					else
					{
						tree[PRNPAPER].ob_state&=~DISABLED;
						tree[PRNCIRC1].ob_state&=~DISABLED;
						tree[PRNDIST ].ob_state&=~DISABLED;
						tree[PRNCIRC3].ob_state&=~DISABLED;
						tree[PRNPAPER].ob_flags|=TOUCHEXIT;
						tree[PRNCIRC1].ob_flags|=TOUCHEXIT;
						tree[PRNDIST ].ob_flags|=TOUCHEXIT;
						tree[PRNCIRC3].ob_flags|=TOUCHEXIT;
					}
					objc_update(tree,PRNPAPER,0);
					objc_update(tree,PRNCIRC1,0);
					objc_update(tree,PRNDIST,0);
					objc_update(tree,PRNCIRC3,0);
					verify_printable_lines(wp);
					goto BL;
            }
/*
				graf_mkstate(&mx,&my,&ret,&ret);
				objc_offset(tree,PRNDRUCK,&x,&y);
				mx=x+tree[PRNDRUCK].ob_width/2;
				my=y+gdospop->ob_height/2-(act_dev-POPNO)*boxh;
				switch(ret=pop_exhndl(gdospop,mx,my,TRUE))
				{
					case POPNO:
					case POPEPS:
					case POPIBM:
					case POP21:
					case POP22:
					case POP23:
					case POP24:
					case POP25:
					case POP26:
					case POP27:
					case POP28:
					case POP29:
					case POP30:
						if(ret!=act_dev)
						{
							gdospop[act_dev].ob_state&=~CHECKED;
							act_dev=ret;
							gdospop[act_dev].ob_state|=CHECKED;
							strcpy((char *)tree[PRNDRUCK].ob_spec.index,
									 (char *)gdospop[ret].ob_spec.index);
							objc_update(tree,PRNDRUCK,0);
							if(act_dev<POP21)
							{
								tree[PRNPAPER].ob_state|=DISABLED;
								tree[PRNCIRC1].ob_state|=DISABLED;
								tree[PRNDIST ].ob_state|=DISABLED;
								tree[PRNCIRC3].ob_state|=DISABLED;
								tree[PRNPAPER].ob_flags&=~TOUCHEXIT;
								tree[PRNCIRC1].ob_flags&=~TOUCHEXIT;
								tree[PRNDIST ].ob_flags&=~TOUCHEXIT;
								tree[PRNCIRC3].ob_flags&=~TOUCHEXIT;
							}
							else
							{
								tree[PRNPAPER].ob_state&=~DISABLED;
								tree[PRNCIRC1].ob_state&=~DISABLED;
								tree[PRNDIST ].ob_state&=~DISABLED;
								tree[PRNCIRC3].ob_state&=~DISABLED;
								tree[PRNPAPER].ob_flags|=TOUCHEXIT;
								tree[PRNCIRC1].ob_flags|=TOUCHEXIT;
								tree[PRNDIST ].ob_flags|=TOUCHEXIT;
								tree[PRNCIRC3].ob_flags|=TOUCHEXIT;
							}
							objc_update(tree,PRNPAPER,0);
							objc_update(tree,PRNCIRC1,0);
							objc_update(tree,PRNDIST,0);
							objc_update(tree,PRNCIRC3,0);
							verify_printable_lines(wp);
							goto BL;
						}
				}
*/
				break;
/*
			case PRNCIRC2:
				gdospop[act_dev].ob_state&=~CHECKED;
				if(++act_dev>(POPNO+gdospop->ob_height/boxh)-1)
					act_dev=POPNO;
				gdospop[act_dev].ob_state|=CHECKED;
				strcpy((char *)tree[PRNDRUCK].ob_spec.index,
						 (char *)gdospop[act_dev].ob_spec.index);

				objc_update(tree,PRNDRUCK,0);
				if(act_dev<POP21)
				{
					tree[PRNPAPER].ob_state|=DISABLED;
					tree[PRNCIRC1].ob_state|=DISABLED;
					tree[PRNDIST ].ob_state|=DISABLED;
					tree[PRNCIRC3].ob_state|=DISABLED;
					tree[PRNPAPER].ob_flags&=~TOUCHEXIT;
					tree[PRNCIRC1].ob_flags&=~TOUCHEXIT;
					tree[PRNDIST ].ob_flags&=~TOUCHEXIT;
					tree[PRNCIRC3].ob_flags&=~TOUCHEXIT;
				}
				else
				{
					tree[PRNPAPER].ob_state&=~DISABLED;
					tree[PRNCIRC1].ob_state&=~DISABLED;
					tree[PRNDIST ].ob_state&=~DISABLED;
					tree[PRNCIRC3].ob_state&=~DISABLED;
					tree[PRNPAPER].ob_flags|=TOUCHEXIT;
					tree[PRNCIRC1].ob_flags|=TOUCHEXIT;
					tree[PRNDIST ].ob_flags|=TOUCHEXIT;
					tree[PRNCIRC3].ob_flags|=TOUCHEXIT;
				}
				objc_update(tree,PRNPAPER,0);
				objc_update(tree,PRNCIRC1,0);
				objc_update(tree,PRNDIST,0);
				objc_update(tree,PRNCIRC3,0);
				verify_printable_lines(wp);
				evnt_timer(125,0);
				goto BL;
				break;
*/
			case PRNDIST:
				graf_mkstate(&mx,&my,&ret,&ret);
				objc_offset(tree,PRNDIST,&x,&y);
				mx=x+tree[PRNDIST].ob_width/2;
				my=y+3*boxh/2-(act_dist-POPD1)*boxh;
				switch(ret=pop_exhndl(distpop,mx,my,TRUE))
				{
					case POPD1:
					case POPD1+1:
					case POPD1+2:
						if(ret!=act_dist)
						{
							distpop[act_dist].ob_state&=~CHECKED;
							act_dist=ret;
							distpop[act_dist].ob_state|=CHECKED;
							strcpy((char *)tree[PRNDIST].ob_spec.index,
									 (char *)distpop[ret].ob_spec.index);
		               objc_draw(tree,PRNDIST,0,x,y,
      		            		 tree[PRNDIST].ob_width-1,tree[PRNDIST].ob_height);
							objc_update(tree,PRNDIST,0);
							verify_printable_lines(wp);
							goto BL;
						}
				}
				break;
			case PRNCIRC3:
				objc_offset(tree,PRNDIST,&x,&y);
				distpop[act_dist].ob_state&=~CHECKED;
				if(++act_dist>(POPD1+2))
					act_dist=POPD1;
				distpop[act_dist].ob_state|=CHECKED;
				strcpy((char *)tree[PRNDIST].ob_spec.index,
						 (char *)distpop[act_dist].ob_spec.index);
				objc_draw(tree,PRNDIST,0,x,y,
							 tree[PRNDIST].ob_width-1,tree[PRNDIST].ob_height);
/*
				objc_update(tree,PRNDIST,0);
*/
				verify_printable_lines(wp);
				evnt_timer(125,0);
				goto BL;
				break;
			case PRNZLDN:
				if(--zl<32)
					zl=32;
				goto LR;
				break;
			case PRNZLUP:
				if(++zl>256)
					zl=256;
				goto LR;
				break;
			case PRNLRDN:
				if(--lr<0)
					lr=0;
				else
					zl++;
				goto LR;
				break;
			case PRNLRUP:
				if(++lr>32)
					lr=32;
				else
					zl--;
LR:
		sprintf(tree[PRNZL].ob_spec.tedinfo->te_ptext,"%3d",zl);
		objc_update(tree, PRNZL, 0);
		sprintf(tree[PRNLR].ob_spec.tedinfo->te_ptext,"%02d",lr);
		objc_update(tree, PRNLR, 0);
				break;
			case PRNBLDN:
				if(--bl<32)
					bl=32;
				goto BL;
				break;
			case PRNBLUP:
				if(++bl>136)
					bl=136;
BL:
		sprintf(tree[PRNBL].ob_spec.tedinfo->te_ptext,"%3d",bl);
		objc_update(tree, PRNBL, 0);
				break;
			case PRNORDN:
				if(--or<0)
					or=0;
				goto OR;
				break;
			case PRNORUP:
				if(++or>8)
					or=8;
OR:
		sprintf(tree[PRNOR].ob_spec.tedinfo->te_ptext,"%02d",or);
		objc_update(tree, PRNOR, 0);
				break;
			case PRNKZDN:
				if(--kz<0)
					kz=0;
				goto KZ;
				break;
			case PRNKZUP:
				if(++kz>8)
					kz=8;
KZ:
		sprintf(tree[PRNKZ].ob_spec.tedinfo->te_ptext,"%02d",kz);
		objc_update(tree, PRNKZ, 0);
				break;
			case PRNFZDN:
				if(--fz<0)
					fz=0;
				goto FZ;
				break;
			case PRNFZUP:
				if(++fz>8)
					fz=8;
FZ:
		sprintf(tree[PRNFZ].ob_spec.tedinfo->te_ptext,"%02d",fz);
		objc_update(tree, PRNFZ, 0);
				break;
			case PRNURDN:
				if(--ur<0)
					ur=0;
				goto UR;
				break;
			case PRNURUP:
				if(++ur>8)
					ur=8;
UR:
		sprintf(tree[PRNUR].ob_spec.tedinfo->te_ptext,"%02d",ur);
		objc_update(tree, PRNUR, 0);
				break;
			case PRNHELP:
				if(form_alert(2,Aprinter[12])==2)
					form_alert(1,Aprinter[13]);
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
				break;
			case PRNLOAD:
				alertstr[0]=0;
				search_env(alertstr,fpattern,FALSE); /* READ */
/* 29.5.94 */
				if( ! (strrchr(alertstr,'\\') || strrchr(alertstr,'/')))
					*alertstr=0;
				if(getfilename(alertstr,fpattern,"@",fselmsg[22]))
				{
					graf_mouse(BUSY_BEE,0L);
					form_write(tree,PRNLAY,(char *)split_fname(alertstr),TRUE);
					loadformat(tree,alertstr);
					objc_update(tree,PRNKZSTR,0);
					objc_update(tree,PRNFZSTR,0);
					objc_update(tree,PRNKZM,0);
					objc_update(tree,PRNKZR,0);
					objc_update(tree,PRNFZL,0);
					objc_update(tree,PRNFZM,0);
					objc_update(tree,PRNFZR,0);
					objc_update(tree,PRNZL,0);
					objc_update(tree,PRNBL,0);
					objc_update(tree,PRNOR,0);
					objc_update(tree,PRNKZ,0);
					objc_update(tree,PRNFZ,0);
					objc_update(tree,PRNUR,0);
					objc_update(tree,PRNLR,0);
					objc_update(tree,PRNZZ,0);
					graf_mouse(ARROW,0L);
				}
				tree[exit_obj].ob_state&=~SELECTED;
				if(!windials)
					objc_update(tree,ROOT,MAX_DEPTH);
				else
					objc_update(tree,exit_obj,0);
				break;
			case PRNSAVE:
				alertstr[0]=0;
				search_env(alertstr,fpattern,TRUE); /* SAVE */
/* 29.5.94 */
				if( ! (strrchr(alertstr,'\\') || strrchr(alertstr,'/')))
					*alertstr=0;
				if(getfilename(alertstr,fpattern,"@",fselmsg[23]))
				{
					graf_mouse(BUSY_BEE,0L);
					form_write(tree,PRNLAY,(char *)split_fname(alertstr),TRUE);
					saveformat(tree,alertstr);
					graf_mouse(ARROW,0L);
				}
				tree[exit_obj].ob_state&=~SELECTED;
				if(!windials)
					objc_update(tree,ROOT,MAX_DEPTH);
				else
					objc_update(tree,exit_obj,0);
				break;
			case PRNABBR:
			case PRNOK:
				done=TRUE;
				break;
		}
		zz=bl-or-kz-fz-ur;
		sprintf(tree[PRNZZ].ob_spec.tedinfo->te_ptext,"%3d",zz);
		objc_update(tree, PRNZZ, 0);
	}
	while(!done);
	form_exclose(tree,exit_obj,0);

	if(exit_obj==PRNABBR)
	{
		zl=A;
		bl=B;
		or=C;
		kz=D;
		fz=E;
		ur=F;
		lr=G;
		zz=H;
		tree[PRNKZL].ob_state=I;
		tree[PRNKZM].ob_state=J;
		tree[PRNKZR].ob_state=K;
		tree[PRNFZL].ob_state=L;
		tree[PRNFZM].ob_state=M;
		tree[PRNFZR].ob_state=N;
		form_write(tree,PRNKZSTR,str1,0);
		form_write(tree,PRNFZSTR,str2,0);
		form_write(tree,PRNLAY,str3,0);
	}
}

#define VM_PAGESIZE 0
#define VM_COORDS	1

#if GEMDOS /* sind ab GEM 2.X in den Bindings */

static void _V_opnwk(int work_in[], int *handle, int work_out[])
{
	VDIPB vdipb=
	{
		_VDIParBlk.contrl,
		_VDIParBlk.intin,
		_VDIParBlk.ptsin,
		_VDIParBlk.intout,
		_VDIParBlk.ptsout
	};
	
	memmove(_VDIParBlk.intin,work_in,11*sizeof(int));
	_VDIParBlk.contrl[0] = 1;
/*	_VDIParBlk.contrl[1] = 0; */
	_VDIParBlk.contrl[3] = 11;

	vdi(&vdipb);
	*handle = _VDIParBlk.contrl[6];

	memmove(work_out,_VDIParBlk.intout,45*sizeof(int));
	memmove(&work_out[45],_VDIParBlk.ptsout,12*sizeof(int));
}

#else

int vq_gdos(void)
{
	return(1);
}

#endif

static int v_gdosprt(OBJECT *tree1, OBJECT *tree2, OBJECT *tree3, WINDOW *wp, int handle)
{
	register LINESTRUCT *line;
	int i,k,m,pages,ret,blanks,inrange,mouse_click;
	long lines,chars,count=1;
	char c1,c2,*str;
	int event,wh,result=TRUE;
	int save,x,y,cw,cw1,cw2,ch,maxlines,oldeffect=TXT_NORMAL;

	extern int dial_handle;

	save=handle;													  /* Filepointer retten */
	form_write(tree1,PRTNAME,(char *)Wname(wp),FALSE);
	form_write(tree1,PRTPAGE,"",FALSE);
	tree1[ROOT+1].ob_flags|=HIDETREE;
	
	form_exopen(tree1,FALSE);
	
	vst_point(handle,wp->fontsize,&ret,&ret,&ret,&ch); /* pts */
	vqt_width(handle,'W',&cw1,&ret,&ret);  /* Breite der Zeichen */
	vqt_width(handle,'I',&cw2,&ret,&ret);  /* Breite der Zeichen */
	cw=(cw1+cw2)/2;
	if(act_dist==POPD1)	/* Zeilenabstand = 1	*/
		ch=ch;
	if(act_dist==POPD1+1) /* Zeilenabstand = 1.5 */
		ch=ch*3/2;
	if(act_dist==POPD1+2) /* Zeilenabstand = 2	*/
		ch=ch*2;
#if GEMDOS
#else
	ch*=3;
	ch+=X_MIN;
#endif
	Wtxtsize(wp,&lines,&chars);
	pages=lines%zz ? (lines/zz)+1 : lines/zz;			/* Anzahl der Seiten */
	line=wp->fstr;
	for(i=0; i<pages; i++)							  /* fÅr jede Seite */
	{
		event=evnt_event(&mevent);
/*
		wind_update(BEG_UPDATE);
*/
		if(event & MU_MESAG)
		{
			if((msgbuf[0] != MN_SELECTED) && (msgbuf[0] < 50)) /* AP_TERM */
			{
				if(msgbuf[3]==dial_handle) /* Dialogfenster */
				{
					switch(msgbuf[0])
					{
						case WM_BACKDROPPED: /* nein, niemals */
							break;
						case WM_REDRAW:
							fwind_redraw(tree1,msgbuf[3],&msgbuf[4]);
							break;
						case WM_MOVED:
							fwind_move(tree1,msgbuf[3],&msgbuf[4]);
							break;
						case WM_TOPPED:
							wind_set(msgbuf[3],WF_TOP,0,0,0,0);
							break;
					}
				}
				else /* aber kein Schlie·en oder Toppen */
					if(msgbuf[0]!=WM_CLOSED && msgbuf[0]!=WM_TOPPED)
						Wwindmsg(Wp(msgbuf[3]),msgbuf);
			}
		}
		if(event&MU_KEYBD || event&MU_BUTTON)
		{
			if((mevent.e_kr>>8)==ESC ||							 /* ESC gedrÅckt? */
				 objc_find(tree1,ROOT,MAX_DEPTH,mevent.e_mx,mevent.e_my)==PRTESC)
			{
				objc_change(tree1,PRTESC,0,tree1->ob_x,tree1->ob_y,
													tree1->ob_width,tree1->ob_height,
													tree1[PRTESC].ob_state|SELECTED,TRUE);
				if(form_alert(2,Aprinter[4])==2)
				{
/*
					wind_update(END_UPDATE);
*/
					result=FALSE;
					goto ENDE;
				}
				objc_change(tree1,PRTESC,0,tree1->ob_x,tree1->ob_y,
													tree1->ob_width,tree1->ob_height,
													tree1[PRTESC].ob_state&~SELECTED,TRUE);
			}
		}
/*
		wind_update(END_UPDATE);
*/
		x=X_MIN;
		y=Y_MIN;
		if(i+1+pageoffset <fpage)							  /* von, bis drucken */
		{
			handle=0;
			inrange=FALSE;
		}
		else
		{
			handle=save;
			inrange=TRUE;
		}
		if(i+1+pageoffset >lpage)
		{
			goto ENDE;
		}
		if(handle)
		{
			vst_alignment(handle,0,5,&ret,&ret);	/* Ausrichtung */
			vst_rotation(handle,0);					 /* Winkel 0 */
			vswr_mode(handle,MD_REPLACE);			 /* replace */
			vst_color(handle,BLACK);					/* Farbe */
			vst_effects(handle,0);					  /* keine Attribute */
		}
		if(inrange && !(tree3[PRNALLP].ob_state&SELECTED)) /* wenn nicht alle Seiten */
		{
			if(tree3[PRNPAIR].ob_state&SELECTED)		  /* nur gerade Seiten */
			{
				if((i+1+pageoffset)%2)					  /* bei ungerade weiter */
					handle=0;
				else
					handle=save;
			}
			else												  /* nur ungerade Seiten */
			{
				if(!((i+1+pageoffset)%2))					 /* bei gerade weiter */
					handle=0;
				else
					handle=save;
			}
		}
		if(handle)
		{
			sprintf(alertstr,"%d",i+1);				 /* Seitennummer anzeigen */
			form_write(tree1,PRTPAGE,alertstr,TRUE);
		}
		y+=(or*ch);														 /* oberer Rand */
		if(kz)																 /* Kopfzeile */
		{
			str=expandfkey(wp,form_read(tree2,PRNKZSTR,alertstr),i+1+pageoffset);
			ret=strlen(str);
			if(tree2[PRNKZL].ob_state&SELECTED)							/* links */
				blanks=lr;
			if(tree2[PRNKZM].ob_state&SELECTED)							/* mitte */
				blanks=lr+(zl-ret)/2;
			if(tree2[PRNKZR].ob_state&SELECTED)						  /* rechts */
				blanks=(lr+zl-ret);
			if(tree3[PRNALT].ob_state&SELECTED)
			{
				if(!((i+1+pageoffset)%2))	/* bei geraden Seiten vertauschen */
				{
					if(tree2[PRNKZR].ob_state&SELECTED)				  /* rechts */
						blanks=lr;
					if(tree2[PRNKZL].ob_state&SELECTED)					/* links */
						blanks=(lr+zl-ret);
				}
			}
			x=max(X_MIN,X_MIN+blanks*cw);
			if(i==0) /* erste seite */
			{
				if(!(tree3[PRNKFBEG].ob_state&SELECTED))			/* Kopfzeile */
				{
					x=X_MIN;
					y+=ch;
				}
				else
				{
					if(handle)
						v_gtext(handle,x,y,str);
					x=X_MIN;
					y+=ch;
				}
			}
			else
			{
				if(handle)
					v_gtext(handle,x,y,str);
				x=X_MIN;
				y+=ch;
			}
			x=X_MIN;
			y+=(kz-1)*ch;
		}
		for(k=0; k<zz && line; k++, line=line->next,count++)
		{
			if(*line->string!=FORMFEED)
			{
				if(tree3[PRNCUT].ob_state&SELECTED)/* Åberlange Zeilen abschneiden */
				{
					if(zl<line->used)
					{
						c1=line->string[zl];
						line->string[zl]=0;
					}
				}
				x=max(X_MIN,lr*cw);
				if(lcol<line->used)
				{
					c2=line->string[lcol];							 /* Druckspalte */
					line->string[lcol]=0;
				}
				if(tree3[PRNNUM].ob_state & SELECTED)	/* Zeilennummerierung */
				{
					sprintf(alertstr,"%5ld: ",count);
					if(handle)
						v_gtext(handle,x,y,alertstr);
					x+=strlen(alertstr)*cw;
				}
				if((fcol-1)<line->used)
				{
					if(handle)
					{
						if(line->effect != oldeffect) /* normal, fett, kursiv */
						{
							vst_effects(handle, line->effect);
							oldeffect = line->effect;
						}
						v_gtext(handle,x,y,&line->string[fcol-1]);
					}
					x=X_MIN;
					y+=ch;
				}
				else
				{
					x=X_MIN;
					y+=ch;
				}
				if(lcol<line->used)
					line->string[lcol]=c2;
				if(tree3[PRNCUT].ob_state&SELECTED)
				{
					if(zl<line->used)
					{
						line->string[zl]=c1;
					}
				}
			}
			else
			{
				line=line->next;
				lines+=(zz-k);							  /* ...Zeilenzahl erhîhen */
				pages=lines%zz ? (lines/zz)+1 : lines/zz;/* Anzahl der Seiten */
				break;					  /* Seite beenden, aber FF nicht senden */
			}
		} /* for(k - zz) */
		if(i<(pages-1))
		{
			for(; k<zz; k++)								  /* evtl. Leerzeilen */
				x=X_MIN,y+=ch;
		}
		else /* wenn letzte Seite... */
		{
			if(fz || tree3[PRNFF].ob_state&SELECTED)/* nur bei FZ oder Knopf */
				for(; k<zz; k++)								  /* evtl. Leerzeilen */
					x=X_MIN,y+=ch;
		}
		if(fz)																  /* Fu·zeile */
		{
			str=expandfkey(wp,form_read(tree2,PRNFZSTR,alertstr),i+1+pageoffset);
			ret=strlen(str);
			x=X_MIN;
			y+=(fz-1)*ch;
			if(tree2[PRNFZL].ob_state&SELECTED)							/* links */
				blanks=lr;
			if(tree2[PRNFZM].ob_state&SELECTED)							/* mitte */
				blanks=lr+(zl-ret)/2;
			if(tree2[PRNFZR].ob_state&SELECTED)						  /* rechts */
				blanks=(lr+zl-ret);
			if(tree3[PRNALT].ob_state&SELECTED)
			{
				if(!((i+1+pageoffset)%2))			  /* bei geraden Seiten vertauschen */
				{
					if(tree2[PRNFZR].ob_state&SELECTED)				  /* rechts */
						blanks=lr;
					if(tree2[PRNFZL].ob_state&SELECTED)					/* links */
						blanks=(lr+zl-ret);
				}
			}
			x=max(X_MIN,X_MIN+blanks*cw);
			if(i==0) /* erste Zeile */
			{
				if(!(tree3[PRNKFBEG].ob_state&SELECTED))			/* Fu·zeile? */
				{
					x=X_MIN;
					y+=ch;
				}
				else
				{
					if(handle)
						v_gtext(handle,x,y,str);
					x=X_MIN;
					y+=ch;
				}
			}
			else
			{
				if(handle)
					v_gtext(handle,x,y,str);
				x=X_MIN;
				y+=ch;
			}
		}/* fz */
		if(handle && (i<(pages-1)))
		{
			v_updwk(handle);
			v_clrwk(handle);
		}
		if(tree3[PRNPAUSE].ob_state&SELECTED)
			if(form_alert(2,Aprinter[2])==1)
			{
				result=FALSE;
				goto ENDE;
			}
	}
ENDE:
	handle=save;
	form_exclose(tree1,-1,FALSE);
	tree1[PRTESC].ob_state&=~SELECTED;								/* Bit lîschen! */
	return(result);
}

int ismetafile(int channel)
{
	return((channel>=METAFILE) && (channel<CAMERA));
}

int gdosprint(OBJECT *tree1, OBJECT *tree2, OBJECT *tree3, WINDOW *wp, int device, char *filename)
{
	int i,handle=0,add,id,pt,ret,ch,result/*,pxy[5],eff[3]*/;
/*
	char name[34];
*/
	if(wp)
	{
		if(vq_gdos())
		{
			graf_mouse(BUSY_BEE,NULL);
			if(!scrollist)
				scan_assignsys(tree2,gdospop);
			if(!ismetafile(device)/*!=METAFILE*/)					/* Also bei Druckern */
			{											 /* Papiergrî·e einstellen */
				handle=open_work(device);	  /* physikalisch îffnen */
#if GEMDOS
				if((handle>0) && (act_paper!=POPBASIS))/* bei POPBASIS nicht Ñndern */
				{
					close_work(handle,device);				/* Workstation schlie·en */
					_VDIParBlk.contrl[1] = 1;
					_VDIParBlk.ptsin [0] = (int)((long)ps[act_paper-POPBASIS/*POPLETT*/].w*100/work_out[3]);
					_VDIParBlk.ptsin [1] = (int)((long)ps[act_paper-POPBASIS/*POPLETT*/].h*100/work_out[4]);
					for (i = 0; i < 103; i++) work_in [i] = 1;
					work_in [0]  = device;									/* Devicehandle */
					work_in [10] = 2;								  /* Raster Koordinaten */
					work_in [11] = 255;		 /* OW_NOCHANGE parallel or serial port */
					_V_opnwk (work_in, &handle, work_out);  /* physikalisch îffnen */
				}
#endif
			}
			else
				handle=open_work(device);	  /* physikalisch îffnen */
			graf_mouse(ARROW,NULL);

			if(handle>0)
			{
				if(ismetafile(device)/*==METAFILE*/)							 /* bei Metafiles... */
				{
					vm_filename(handle,filename); /* Dateiname und Koordianten */

					v_meta_extents(handle,0,0,ps[act_paper-POPBASIS/*POPLETT*/].w-1,
													  ps[act_paper-POPBASIS/*POPLETT*/].h-1);
					vm_pagesize(handle,ps[act_paper-POPBASIS/*POPLETT*/].w,
											 ps[act_paper-POPBASIS/*POPLETT*/].h);
					vm_coords(handle,0,ps[act_paper-POPBASIS/*POPLETT*/].h-1,
											 ps[act_paper-POPBASIS/*POPLETT*/].w-1,0);
				}
            if(vq_vgdos()==0x5F46534D)
	            vst_scratch(handle,2); /* FSM Scratchbuffer auf null, sonst geht nicht */
				add=vst_load_fonts(handle,0);				/* Fonts laden */
				id=vst_font(handle,wp->fontid);			/* Font wÑhlen */
				pt=vst_point(handle,wp->fontsize,&ret,&ret,&ret,&ch); /* pts */
/*
				vqt_fontinfo(handle, &ret, &ret, pxy, &ret, eff);
				ch = pxy[0] + pxy[4] + 1;
*/
				if(id!=wp->fontid || pt!=wp->fontsize) /* irdendwas pa·te nicht */
				{
					if(ismetafile(device)/*==METAFILE*/)/* bei Metafiles... */
						form_alert(1,Aprinter[14]);		/* Warnung ausgeben */
					else
						form_alert(1,Aprinter[15]);		/* Warnung ausgeben */
					vst_unload_fonts(handle,0);			/* Fonts freigeben */
					close_work(handle,device);				/* Workstation schlie·en */
					if(ismetafile(device)/*==METAFILE*/)/* bei Metafiles... */
					{
						unlink(filename);
						cut_path(filename);
/*
						strcut(filename,'\\');
*/
						strcat(filename,"GEMFILE.GEM"); /* GEMFILE.GEM lîschen */
						unlink(filename);
						unlink("GEMFILE.GEM");
						strcpy(filename,"GEMFILE.GEM"); /* GEMFILE.GEM lîschen */
/* 23.10.94
						shel_find(filename);
*/
						if(*filename)
							unlink(filename);
					}
/*
					graf_mouse(ARROW,NULL);
*/
					return;									/* ...und abbrechen */
				}

				if(ismetafile(device)/*==METAFILE*/)/* Maximale Zeilenzahl korrigieren */
				{
					if(act_dist==POPD1)
						bl=min(bl,(ps[act_paper-POPBASIS/*POPLETT*/].h/ch-UNPRINTABLE_LINES));
					if(act_dist==POPD1+1)
						bl=min(bl,(ps[act_paper-POPBASIS/*POPLETT*/].h/ch-UNPRINTABLE_LINES)*2/3);
					if(act_dist==POPD1+2)
						bl=min(bl,(ps[act_paper-POPBASIS/*POPLETT*/].h/ch-UNPRINTABLE_LINES)/2);
					zz=bl-or-kz-fz-ur;
				}
				else
				{
					zz=bl-or-kz-fz-ur;
				}

				result=v_gdosprt(tree1,tree2,tree3,wp,handle); /* eigentliche Ausgabe */
WEITER:
				if(!ismetafile(device)/*!=METAFILE*/)  /* Seitenvorschub beim Drucken hinterher */
				{
					v_updwk(handle);
					v_clrwk(handle);
				}
				vst_unload_fonts(handle,0);					  /* Fonts freigeben */
				close_work(handle,device);				  /* Workstation schlie·en */
				if(ismetafile(device)/*==METAFILE*/)
				{
					cut_path(filename);
/*
					strcut(filename,'\\');
*/
					strcat(filename,"GEMFILE.GEM");		/* GEMFILE.GEM lîschen */
					unlink(filename);
					unlink("GEMFILE.GEM");
					strcpy(filename,"GEMFILE.GEM"); /* GEMFILE.GEM lîschen */
/* 23.10.94
					shel_find(filename);
*/
					if(*filename)
						unlink(filename);
				}
			}
			else
			{
				sprintf(alertstr,Aprinter[16],device);
				form_alert(1,alertstr);
			}
/*
			graf_mouse(ARROW,NULL);
*/
			return(result);
		}
		else
			form_alert(1,Aprinter[17]);
	}
	return(FALSE);
}
