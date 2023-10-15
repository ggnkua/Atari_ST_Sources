/*  3D_CPX.C
 *  Einstellung der 3D-Effekte!
 *
 *  (c) MÑrz 1993 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  Vertrieb nur durch das TOS-Magazin!
 *
 *  Erstellt mit Pure C
 */
 
#include <new_aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <portab.h>
#include "cpx.h"
#include "3d_rsc.h"
#pragma warn -rpt 
#include "3d_rsc.rsh"
#pragma warn +rpt 

#define TRUE 1
#define FALSE 0

typedef struct
{
	int ges;
	int par[10];
}PREF;

extern PREF pref;

/* Eine handvoll Prototypen */
CPXINFO * cdecl cpx_init(XCPB *Xcpb);
WORD cdecl cpx_call(GRECT *re); 

void save_cpx(void);
void init_dialog(void);
void save_par(void);
void draw_obj(OBJECT *o, int s, int t);
void restore_par(void);
int handle_dialog(WORD button, WORD *msg);

/* Globale Variablen */
GRECT   *w_rect;        /* Die Koordinaten des Fensters.        */
XCPB    *xcpb;          /* Zeiger auf die XControl-Funktionen.  */
CPXINFO cpxinfo;        /* Zeiger auf unsere Funktionen fÅr     */
                        /* XControl.                            */
int dumy,ls;

OBJECT  *dialog;        /* Zeiger auf unsere Dialoge.           */
        
/* Externe Variablen aus dem Assemblerteil */

CPXINFO * cdecl cpx_init(XCPB *Xcpb)
/* Diese Funktion wird wÑhrend der XControl-Initialisierung und */
/* bei jeder Aktivierung unseres CPX-Moduls als erstes          */
/* gestartet. Sie erhÑlt einen Zeiger auf die CPX-Funktionen    */
/* und muû einen Zeiger auf die eigenen Funktionen oder NULL    */
/* bzw. 1 zurÅckgeben.                                          */
{
    xcpb=Xcpb;


    if(xcpb->booting)
    /* Dieses Flag zeigt an, ob es der erste Aufruf (wÑhrend der*/
    /* XControl-Initialisierung) ist.                           */
    {
    	/* Die gesicherten Werte setzen */
    	if(pref.ges) restore_par();

        /* WÑhrend der Initialisierung muû eine 1 zurÅckgegeben */
        /* werden, wenn das CPX-Modul nicht set_only sein soll. */
        return ((CPXINFO *)1);
    }
    if(!xcpb->SkipRshFix)
    /* In diesem Flag wird festgehalten, ob der OBJECT-Baum     */
    /* schon angepaût wurde.                                    */
    {
        /* Wir passen den OBJECT-Baum an.                       */
        (*xcpb->rsh_fix)(NUM_OBS,NUM_FRSTR,NUM_FRIMG,NUM_TREE,
                         rs_object,rs_tedinfo,rs_strings,rs_iconblk,
                         rs_bitblk,rs_frstr,rs_frimg,rs_trindex,
                         rs_imdope);
    }
    dialog=(OBJECT *)rs_trindex[DIALOG];

    /* In die CPXINFO-Struktur mÅssen unsere Funktionen ein-    */
    /* getragen werden.                                         */
    cpxinfo.cpx_call    =cpx_call;
    cpxinfo.cpx_draw    =NULL;
    cpxinfo.cpx_wmove   =NULL;
    cpxinfo.cpx_timer   =NULL;
    cpxinfo.cpx_key     =NULL;
    cpxinfo.cpx_button  =NULL;
    cpxinfo.cpx_m1      =NULL;
    cpxinfo.cpx_m2      =NULL;
    cpxinfo.cpx_hook    =NULL;
    cpxinfo.cpx_close   =NULL;
    
    /* Mit der RÅckgabe unserer Funktionen melden wir uns beim  */
    /* XControl an.                                             */
    return(&cpxinfo);
} /* cpx_init */

WORD cdecl cpx_call(GRECT *rect)
{
    WORD msg[8];        /* Puffer fÅr Xform_do.                 */
    WORD button,        /* Welches Schweinderl Ñhh button.      */
         ende;          /* Flag fÅr's ENDE.                     */

    
    /* Unser Dialog muû angepaût werden.                        */
    w_rect=rect;
    dialog[ROOT].ob_x=w_rect->g_x;
    dialog[ROOT].ob_y=w_rect->g_y;
    
    /* Initialisieren und zeichnen.                             */
    init_dialog();
    objc_draw(dialog,ROOT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    do
    { 
        /* Wir Åberlassen XControl die Verwaltung des Dialogs.  */
        button=(*xcpb->Xform_do)(dialog,0,msg);
        /* Nun mÅssen wir arbeiten.                             */
        ende=handle_dialog(button,msg);
    } while(!ende);
    
    /* Ende unseres Moduls, XControl ist wieder an der Reihe.   */
    return(FALSE);
} /* cpx_call */

void show_wert(int w1, int w2)
{
    if(w1)dialog[WERT1].ob_flags &= ~HIDETREE;
    else dialog[WERT1].ob_flags |= HIDETREE;
    if(w2)dialog[WERT2].ob_flags &= ~HIDETREE;
    else dialog[WERT2].ob_flags |= HIDETREE;
}/* show_wert */

WORD handle_dialog(WORD button, WORD *msg)
/* Hier behandeln wir die Objekte, die angeklickt wurden.       */
/* In button steht die Objekt-Nr. und in msg ein Zeiger auf     */
/* einen Messag-Buffer (Ñhnlich wie evnt_mesag).                */
{
	static int s1,s2;
	static char t1[10],t2[10];
	int p;
    
    if((button!=-1)&&(button & 0x8000))
        button &= 0x7fff;

    switch(button)
    {
    	case S_LK3DIN:
    		objc_sysvar(0,LK3DIND,0,0,&s1,&s2);
    		ls=LK3DIND;
    		show_wert(TRUE,TRUE);
    		break;
     	case S_LK3DAC:
    		objc_sysvar(0,LK3DACT,0,0,&s1,&s2);
    		ls=LK3DACT;
    		show_wert(TRUE,TRUE);
    		break;
    	case S_INDBUT:
    		objc_sysvar(0,INDBUTCOL,0,0,&s1,&s2);
    		s2=0;
    		ls=INDBUTCOL;
    		show_wert(TRUE,FALSE);
    		break;
    	case S_ACTBUT:
    		objc_sysvar(0,ACTBUTCOL,0,0,&s1,&s2);
    		s2=0;
    		ls=ACTBUTCOL;
    		show_wert(TRUE,FALSE);
    		break;
    	case S_BACKGR:
    		objc_sysvar(0,BACKGRCOL,0,0,&s1,&s2);
    		s2=0;
    		ls=BACKGRCOL;
    		show_wert(TRUE,FALSE);
    		break;
    	case S_AD3DVA:
	  		objc_sysvar(0,AD3DVALUE,0,0,&s1,&s2);
    		ls=AD3DVALUE;
    		show_wert(TRUE,TRUE);
    		break;

        case SICHERN:
            /* Wer sich fÅr's SICHERN interessiert, dem sei     */
            /* save_cpx() empfohlen.                            */
            save_cpx();
            dialog[button].ob_state &= ~SELECTED;
            objc_draw(dialog,button,1,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            return(FALSE);
        case OKAY:
            /* Bei OKAY werden noch die Betriebsparameter       */
            /* gesichert                                        */
            dialog[button].ob_state &= ~SELECTED;
            return(TRUE);
        case ABBRUCH:
        	restore_par();
            dialog[button].ob_state &= ~SELECTED;
            return(TRUE);

		case S1PLUS: case S1MINUS: case S2PLUS: case S2MINUS:
 			if(ls<0 || ls==AD3DVALUE)
 			{
	  			dialog[button].ob_state&=~SELECTED;
	       		draw_obj(dialog,button,1);
 				return(FALSE);
 			}
       		switch(button)
       		{
		    	case S1PLUS: s1++; break;
    			case S1MINUS: s1--; break;
		    	case S2PLUS: s2++; break;
		    	case S2MINUS: s2--; break;
       		}
		    if(s1<0) s1=0;
		    if(s2<0) s2=0;
		    if(s1>256) s1=256;
		    if(s2>256) s2=256;
	  		objc_sysvar(1,ls,s1,s2,&p,&p);
	  		objc_sysvar(0,ls,0,0,&s1,&s2);
		    sprintf(t1,"%3i",s1);
		    sprintf(t2,"%3i",s2);
		    dialog[S1WERT].ob_spec.tedinfo->te_ptext=t1;
		    dialog[S2WERT].ob_spec.tedinfo->te_ptext=t2;
	  		dialog[button].ob_state&=~SELECTED;
	       	draw_obj(dialog,ROOT,MAX_DEPTH);
    		return(FALSE);

       default:
            if(button==-1)
            {
                switch(msg[0])
                {
                    case WM_CLOSED:
                    /* Wurde das Fenster geschlossen, wird das  */
                    /* wie OKAY behandelt.                      */
                    case AC_CLOSE:
                    /* Bei AC_CLOSE nichts wie raus! Wurde vom  */
                    /* Modul Speicher angefordert oder sind     */
                    /* Dateien geîffnet, unbedingt aufrÑumen!!  */
                        return(TRUE);
                    case CT_KEY:
                    /* Jemand hat eine Sondertaste gedrÅckt.    */
                    /* Help, Undo, Funktions-Tasten usw.        */
                        if(msg[3]==0x6200)      /* Help         */
                        {
                            form_alert(1,"[0][Hiiiiilfe !!!! ][ Ah ja ]");
                        }
                        else if(msg[3]==0x6100) /* Undo         */
                        {
                            p=form_alert(2,"[2][Undo oder nicht Undo|ist hier die Frage][ Ja | Nein ]");                            
                            if(p==1)
                            {
                            	restore_par();
                            	init_dialog();
                                objc_draw(dialog,ROOT,MAX_DEPTH,
                                    w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
                            }
                        }
                    default:
                        break;
                }
            }
            break;
    }
    sprintf(t1,"%3i",s1);
    sprintf(t2,"%3i",s2);
    dialog[S1WERT].ob_spec.tedinfo->te_ptext=t1;
    dialog[S2WERT].ob_spec.tedinfo->te_ptext=t2;
    draw_obj(dialog,WERTE,MAX_DEPTH);
    return(FALSE);
} /* handle_dialog */

void restore_par(void)
{
	objc_sysvar(1,LK3DIND,pref.par[0],pref.par[1],&dumy,&dumy);
	objc_sysvar(1,LK3DACT,pref.par[2],pref.par[3],&dumy,&dumy);
	objc_sysvar(1,INDBUTCOL,pref.par[4],pref.par[5],&dumy,&dumy);
	objc_sysvar(1,ACTBUTCOL,pref.par[6],pref.par[7],&dumy,&dumy);
	objc_sysvar(1,BACKGRCOL,pref.par[8],pref.par[9],&dumy,&dumy);
} /* restore_par */

void save_par(void)
{
	objc_sysvar(0,LK3DIND,0,0,&pref.par[0],&pref.par[1]);
	objc_sysvar(0,LK3DACT,0,0,&pref.par[2],&pref.par[3]);
	objc_sysvar(0,INDBUTCOL,0,0,&pref.par[4],&pref.par[5]);
	objc_sysvar(0,ACTBUTCOL,0,0,&pref.par[6],&pref.par[7]);
	objc_sysvar(0,BACKGRCOL,0,0,&pref.par[8],&pref.par[9]);
} /* save_par */

void save_cpx(void)
/* Die Parameter werden von XControl an den Anfang des Daten-   */
/* segments gesichert. Bitte den Assemblerteil anschauen!       */
{
	save_par();
	pref.ges=TRUE;
    if((*xcpb->XGen_Alert)(SAVE_DEFAULTS))
    {
        if(!(*xcpb->CPX_Save)(&pref,sizeof(pref)))
            (*xcpb->XGen_Alert)(FILE_ERR);
   }
} /* save_cpx */

void draw_obj(OBJECT *o, int s, int t)
{
    objc_draw(o,s,t,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
}/* draw_obj */

void init_dialog(void)
{
	dialog[S_LK3DIN].ob_state &= ~SELECTED;
	dialog[S_LK3DAC].ob_state &= ~SELECTED;
	dialog[S_INDBUT].ob_state &= ~SELECTED;
	dialog[S_ACTBUT].ob_state &= ~SELECTED;
	dialog[S_BACKGR].ob_state &= ~SELECTED;
	dialog[S_AD3DVA].ob_state &= ~SELECTED;

    dialog[WERT1].ob_flags |= HIDETREE;
    dialog[WERT2].ob_flags |= HIDETREE;
    save_par();
    ls=-1;

/* 3D-Flags fÅr das AES 3.31 */

	dialog[S_LK3DIN].ob_type |= 0x0100;
	dialog[S_LK3DAC].ob_type |= 0x0100;
	dialog[S_INDBUT].ob_type |= 0x0100;
	dialog[S_ACTBUT].ob_type |= 0x0100;
	dialog[S_BACKGR].ob_type |= 0x0100;
	dialog[S_AD3DVA].ob_type |= 0x0100;

	dialog[S1PLUS].ob_type |= 0x0200;
	dialog[S2PLUS].ob_type |= 0x0200;
	dialog[S1MINUS].ob_type |= 0x0200;
	dialog[S2MINUS].ob_type |= 0x0200;
	dialog[S1WERT].ob_type |= 0x0200;
	dialog[S2WERT].ob_type |= 0x0200;

	dialog[OKAY].ob_type |= 0x0200;
	dialog[ABBRUCH].ob_type |= 0x0200;
	dialog[SICHERN].ob_type |= 0x0200;
	dialog[HINTERGR].ob_type |= 0x0200;
	
}/* init_dialog */