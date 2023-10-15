/*  WMSP_CPX.C
 *  Das CPX-Modul zur Steuerung von WRAPMOUSE
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  FÅr's TOS-Magazin
 *
 *  Erstellt mit Pure C
 */
 
#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <portab.h>
#include "cpx.h"
#include "wrapauto.h"
#include "wrapcpx.h"

#define MAX_MWERT 99
#define MAX_FWERT 40
#define MAX_WRAP 99

struct foobar
{
    WORD    dummy;
    WORD    *image;
};

/* Eine handvoll Prototypen */
void save_par(void);
void do_ok(void);
int do_cpx_alert(OBJECT *o,int e);

static void ch_mtext(void);
static void ch_ftext(void);
static void ch_ltext(void);
static void ch_rtext(void);
static void ch_utext(void);
static void ch_otext(void);
static void init_dialog(void); 
static int handle_dialog(WORD button, WORD *msg);

/* Externe Variablen */
extern GRECT   *w_rect;     /* Die Koordinaten des Fensters.        */
extern XCPB    *xcpb;       /* Zeiger auf die XControl-Funktionen.  */
extern CPXINFO cpxinfo;     /* Zeiger auf unsere Funktionen fÅr     */
                            /* XControl.                            */
extern MFORM   mzeiger;     /* Parkplatz fÅr den Mauszeiger.        */
extern char *items[20];     /* Zeiger-Feld fÅr die PopUp-MenÅs.     */

extern INF *inf,            /* Zeiger auf die COOKIE-Struktur.      */
        inf_back;


extern OBJECT *speeder;         /* Zeiger auf unsere Dialoge.           */
        
/* Globale Variablen */
static int akt_slide;       /* aktueller Slider.                    */
static int vslide;          /* Wert fÅr den vertikalen Slider.      */
static int dev;             /* Welche Maus hÑttens gern             */

WORD do_speeder(GRECT *rect,int d)
{
    WORD msg[8];        /* Puffer fÅr Xform_do.                 */
    WORD button,        /* Welches Schweinderl Ñhh button.      */
         ende;          /* Flag fÅr's ENDE.                     */


    dev=d;
        
    /* Unser Dialog muû angepaût werden.                        */
    w_rect=rect;
    speeder[ROOT].ob_x=w_rect->g_x;
    speeder[ROOT].ob_y=w_rect->g_y;
    
    /* Initialisieren und zeichnen.                             */
    init_dialog();
    objc_draw(speeder,ROOT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    do
    { 
        /* Wir Åberlassen XControl die Verwaltung des Dialogs.  */
        button=(*xcpb->Xform_do)(speeder,0,msg);
        /* Nun mÅssen wir arbeiten.                             */
        ende=handle_dialog(button,msg);
    } while(!ende);

    if(ende==99) return(TRUE);
    return(FALSE);
    
} /* do_speeder */

static WORD handle_dialog(WORD button, WORD *msg)
/* Hier behandeln wir die Objekte, die angeklickt wurden.       */
/* In button steht die Objekt-Nr. und in msg ein Zeiger auf     */
/* einen Messag-Buffer (Ñhnlich wie evnt_mesag).                */
{
    GRECT r1;           /* Koordinaten-Feld.                    */
    WORD p;             /* Hilfsvariablen.                      */
    
    if((button!=-1)&&(button & 0x8000))
        button &= 0x7fff;

    switch(button)
    {
        case ZURUECK:
            /* Bei OKAY werden noch die Betriebsparameter       */
            /* gesichert                                        */
            do_ok();
            speeder[button].ob_state &= ~SELECTED;
            return(TRUE);
        case ABBRUCH2:
            speeder[button].ob_state &= ~SELECTED;
            memcpy(inf,&inf_back,sizeof(inf_back));
            return(TRUE);

        case LP:
            (*xcpb->Sl_arrow)(speeder,LV,LT,button,1,0,MAX_WRAP,&inf->d[dev].rand[0],0,ch_ltext);
            break;
        case LM:
            (*xcpb->Sl_arrow)(speeder,LV,LT,button,-1,0,MAX_WRAP,&inf->d[dev].rand[0],0,ch_ltext);
            break;
        case RP:
            (*xcpb->Sl_arrow)(speeder,RV,RT,button,1,0,MAX_WRAP,&inf->d[dev].rand[1],0,ch_rtext);
            break;
        case RM:
            (*xcpb->Sl_arrow)(speeder,RV,RT,button,-1,0,MAX_WRAP,&inf->d[dev].rand[1],0,ch_rtext);
            break;
        case UP:
            (*xcpb->Sl_arrow)(speeder,UV,UT,button,1,0,MAX_WRAP,&inf->d[dev].rand[2],1,ch_utext);
            break;
        case UM:
            (*xcpb->Sl_arrow)(speeder,UV,UT,button,-1,0,MAX_WRAP,&inf->d[dev].rand[2],1,ch_utext);
            break;
        case OP:
            (*xcpb->Sl_arrow)(speeder,OV,OT,button,1,0,MAX_WRAP,&inf->d[dev].rand[3],1,ch_otext);
            break;
        case OM:
            (*xcpb->Sl_arrow)(speeder,OV,OT,button,-1,0,MAX_WRAP,&inf->d[dev].rand[3],1,ch_otext);
            break;
        case SFLAG:
            items[0]="  Aus ";
            items[1]="  An  ";
            objc_offset(speeder,SFLAG,&r1.g_x,&r1.g_y);
            r1.g_w=speeder[SFLAG].ob_width;
            r1.g_h=speeder[SFLAG].ob_height;
            p=(*xcpb->Popup)(items,2,inf->d[dev].s_flag,3,&r1,w_rect);
            if(p==1)
                speeder[SFLAG].ob_spec.free_string="An";
            else if(p==0)
                speeder[SFLAG].ob_spec.free_string="Aus";
            if(p!=-1)
            {
                inf->d[dev].s_flag=p;
                objc_draw(speeder,SFLAG,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            break;
        case WFLAG:
            items[0]="  Aus ";
            items[1]="  An  ";
            objc_offset(speeder,WFLAG,&r1.g_x,&r1.g_y);
            r1.g_w=speeder[WFLAG].ob_width;
            r1.g_h=speeder[WFLAG].ob_height;
            p=(*xcpb->Popup)(items,2,inf->d[dev].w_flag,3,&r1,w_rect);
            if(p==1)
                speeder[WFLAG].ob_spec.free_string="An";
            else if(p==0)
                speeder[WFLAG].ob_spec.free_string="Aus";
            if(p!=-1)
            {
                inf->d[dev].w_flag=p;
                objc_draw(speeder,WFLAG,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            break;
            
            
        default:
            if(button>=VM1 && button<VM1+6)
            {
                akt_slide=button-VM1;
                vslide=inf->d[dev].mw[akt_slide];
                (*xcpb->Sl_arrow)(speeder,VV1+akt_slide*2,VT1+akt_slide*2,button,-1,1,MAX_MWERT,&vslide,0,ch_mtext);
                inf->d[dev].mw[akt_slide]=vslide;
            }
            else if(button>=VP1 && button<VP1+6)
            {
                akt_slide=button-VP1;
                vslide=inf->d[dev].mw[akt_slide];
                (*xcpb->Sl_arrow)(speeder,VV1+akt_slide*2,VT1+akt_slide*2,button,1,1,MAX_MWERT,&vslide,0,ch_mtext);
                inf->d[dev].mw[akt_slide]=vslide;
            }
            else if(button>=FM1 && button<FM1+6)
            {
                akt_slide=button-FM1;
                vslide=inf->d[dev].mf[akt_slide];
                (*xcpb->Sl_arrow)(speeder,FV1+akt_slide*2,FT1+akt_slide*2,button,-1,1,MAX_FWERT,&vslide,0,ch_ftext);
                inf->d[dev].mf[akt_slide]=vslide;
            }
            else if(button>=FP1 && button<FP1+6)
            {
                akt_slide=button-FP1;
                vslide=inf->d[dev].mf[akt_slide];
                (*xcpb->Sl_arrow)(speeder,FV1+akt_slide*2,FT1+akt_slide*2,button,1,1,MAX_FWERT,&vslide,0,ch_ftext);
                inf->d[dev].mf[akt_slide]=vslide;
            }

            if(button==-1)
            {
                switch(msg[0])
                {
                    case WM_CLOSED:
                    /* Wurde das Fenster geschlossen, wird das  */
                    /* wie OKAY behandelt.                      */
                        do_ok();
                    case AC_CLOSE:
                    /* Bei AC_CLOSE nichts wie raus! Wurde vom  */
                    /* Modul Speicher angefordert oder sind     */
                    /* Dateien geîffnet, unbedingt aufrÑumen!!  */
                        return(99);
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
                                memcpy(inf,&inf_back,sizeof(inf_back));
                                init_dialog();
                                objc_draw(speeder,ROOT,MAX_DEPTH,
                                    w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
                            }
                        }
                    default:
                        break;
                }
            }
            break;
    }
    return(FALSE);
} /* handle_dialog */

static void init_dialog(void)
/* Der Dialog wird aufgebaut                                    */
{
    static char id[3][20]={"Atari Mouse","RS232 Mouse"," Joystick"};
    int i;

    if(dev==2)
    {
        speeder[FV1].ob_state |=DISABLED;    
        speeder[FT1].ob_state |=DISABLED;    
        speeder[FP1].ob_state |=DISABLED;    
        speeder[FM1].ob_state |=DISABLED;    
        speeder[FV1].ob_flags &=~TOUCHEXIT;    
        speeder[FT1].ob_flags &=~TOUCHEXIT;    
        speeder[FP1].ob_flags &=~TOUCHEXIT;    
        speeder[FM1].ob_flags &=~TOUCHEXIT;    
        
    }
    else
    {
        speeder[FV1].ob_state &=~DISABLED;    
        speeder[FT1].ob_state &=~DISABLED;    
        speeder[FP1].ob_state &=~DISABLED;    
        speeder[FM1].ob_state &=~DISABLED;    
        speeder[FV1].ob_flags |=TOUCHEXIT;    
        speeder[FT1].ob_flags |=TOUCHEXIT;    
        speeder[FP1].ob_flags |=TOUCHEXIT;    
        speeder[FM1].ob_flags |=TOUCHEXIT;    
    }
    for(i=0;i<6;i++)
    {
        akt_slide=i;
        vslide=inf->d[dev].mw[i];
        (*xcpb->Sl_size)(speeder,VV1+i*2,VT1+i*2,MAX_MWERT,4,0,16);
        (*xcpb->Sl_y)(speeder,VV1+i*2,VT1+i*2,vslide,1,MAX_MWERT,ch_mtext);
    }
    for(i=0;i<6;i++)
    {
        akt_slide=i;
        vslide=inf->d[dev].mf[i];
        (*xcpb->Sl_size)(speeder,FV1+i*2,FT1+i*2,MAX_FWERT,4,0,16);
        (*xcpb->Sl_y)(speeder,FV1+i*2,FT1+i*2,vslide,1,MAX_FWERT,ch_ftext);
    }
    (*xcpb->Sl_size)(speeder,LV,LT,MAX_WRAP,4,0,16);
    (*xcpb->Sl_y)(speeder,LV,LT,inf->d[dev].rand[0],1,MAX_WRAP,ch_ltext);
    (*xcpb->Sl_size)(speeder,RV,RT,MAX_WRAP,4,0,16);
    (*xcpb->Sl_y)(speeder,RV,RT,inf->d[dev].rand[1],1,MAX_WRAP,ch_rtext);
    (*xcpb->Sl_size)(speeder,UV,UT,MAX_WRAP,4,1,16);
    (*xcpb->Sl_x)(speeder,UV,UT,inf->d[dev].rand[2],1,MAX_WRAP,ch_utext);
    (*xcpb->Sl_size)(speeder,OV,UT,MAX_WRAP,4,1,16);
    (*xcpb->Sl_x)(speeder,OV,OT,inf->d[dev].rand[3],1,MAX_WRAP,ch_otext);

    if(inf->d[dev].s_flag) speeder[SFLAG].ob_spec.free_string="An";    
    else            speeder[SFLAG].ob_spec.free_string="Aus";    
    if(inf->d[dev].w_flag) speeder[WFLAG].ob_spec.free_string="An";    
    else            speeder[WFLAG].ob_spec.free_string="Aus";    
    
    speeder[KENNUNG].ob_spec.free_string=id[dev];    
} /* init_dialog */

static void ch_mtext(void)
/* ONLINE Slider   */
{
    sprintf(speeder[VT1+akt_slide*2].ob_spec.free_string,"%i",vslide);
    objc_draw(speeder,VT1+akt_slide*2,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    
} /* ch_mtext */

static void ch_ftext(void)
/* ONLINE Slider   */
{
    sprintf(speeder[FT1+akt_slide*2].ob_spec.free_string,"%i",vslide);
    objc_draw(speeder,FT1+akt_slide*2,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    
} /* ch_ftext */

static void ch_ltext(void)
/* ONLINE Slider   */
{
    sprintf(speeder[LT].ob_spec.free_string,"%i",inf->d[dev].rand[0]);
    objc_draw(speeder,LT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    
} /* ch_ltext */

static void ch_rtext(void)
/* ONLINE Slider   */
{
    sprintf(speeder[RT].ob_spec.free_string,"%i",inf->d[dev].rand[1]);
    objc_draw(speeder,RT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    
} /* ch_rtext */

static void ch_utext(void)
/* ONLINE Slider   */
{
    sprintf(speeder[UT].ob_spec.free_string,"%i",inf->d[dev].rand[2]);
    objc_draw(speeder,UT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    
} /* ch_utext */

static void ch_otext(void)
/* ONLINE Slider   */
{
    sprintf(speeder[OT].ob_spec.free_string,"%i",inf->d[dev].rand[3]);
    objc_draw(speeder,OT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    
} /* ch_ltext */

