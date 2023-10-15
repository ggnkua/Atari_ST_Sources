/*  WMRS_CPX.C
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
#define MAX_FWERT 20
#define MAX_WRAP 99

struct foobar
{
    WORD    dummy;
    WORD    *image;
};

void do_ok(void);
/* Eine handvoll Prototypen */
static void init_setrs(void); 
static int handle_setrs(WORD button, WORD *msg);

/* Externe Variablen */
extern GRECT   *w_rect;     /* Die Koordinaten des Fensters.        */
extern XCPB    *xcpb;       /* Zeiger auf die XControl-Funktionen.  */
extern CPXINFO cpxinfo;     /* Zeiger auf unsere Funktionen fÅr     */
                            /* XControl.                            */
extern MFORM   mzeiger;     /* Parkplatz fÅr den Mauszeiger.        */
extern char *items[20];     /* Zeiger-Feld fÅr die PopUp-MenÅs.     */

extern INF *inf,            /* Zeiger auf die COOKIE-Struktur.      */
        inf_back;


extern OBJECT *setrs;       /* Zeiger auf unsere Dialoge.           */
        
/* Globale Variablen */

WORD do_setrs(GRECT *rect)
{
    WORD msg[8];        /* Puffer fÅr Xform_do.                 */
    WORD button,        /* Welches Schweinderl Ñhh button.      */
         ende;          /* Flag fÅr's ENDE.                     */

    /* Unser Dialog muû angepaût werden.                        */
    w_rect=rect;
    setrs[ROOT].ob_x=w_rect->g_x;
    setrs[ROOT].ob_y=w_rect->g_y;
    
    /* Initialisieren und zeichnen.                             */
    init_setrs();
    objc_draw(setrs,ROOT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    do
    { 
        /* Wir Åberlassen XControl die Verwaltung des Dialogs.  */
        button=(*xcpb->Xform_do)(setrs,0,msg);
        /* Nun mÅssen wir arbeiten.                             */
        ende=handle_setrs(button,msg);
    } while(!ende);
    if(ende==99) return(TRUE);    
    return(FALSE);
} /* do_setrs */

static WORD handle_setrs(WORD button, WORD *msg)
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
        case GLAETTEN:
            items[0]="  Aus ";
            items[1]="  An  ";
            objc_offset(setrs,button,&r1.g_x,&r1.g_y);
            r1.g_w=setrs[button].ob_width;
            r1.g_h=setrs[button].ob_height;
            p=(*xcpb->Popup)(items,2,inf->rsm_flag,3,&r1,w_rect);
            if(p==1)      setrs[button].ob_spec.free_string="An";
            else if(p==0) setrs[button].ob_spec.free_string="Aus";
            if(p!=-1)
            {
                inf->rsm_flag=p;
                objc_draw(setrs,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            break;
            
        case MICROSOF:  inf->ms_flag=TRUE; break;
        case MSYSTEM:   inf->ms_flag=FALSE; break;
        
        case MODEM1:    inf->rp_flag=1; break;
        case MODEM2:    inf->rp_flag=2; break;
        case SERIELL1:  inf->rp_flag=3; break;
        case SERIELL2:  inf->rp_flag=4; break;
        
        case ZURUECK3:
            /* Bei OKAY werden noch die Betriebsparameter       */
            /* gesichert                                        */
            do_ok();
            setrs[button].ob_state &= ~SELECTED;
            return(TRUE);
        case ABBRUCH3:
            memcpy(inf,&inf_back,sizeof(inf_back));
            setrs[button].ob_state &= ~SELECTED;
            return(TRUE);
        default:
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
                                init_setrs();
                                objc_draw(setrs,ROOT,MAX_DEPTH,
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
} /* handle_setrs */

static void init_setrs(void)
/* Der Dialog wird aufgebaut                                    */
{
    long ma=0;
    
    setrs[MODEM1].ob_state &=~SELECTED;
    setrs[MODEM2].ob_state &=~SELECTED;
    setrs[SERIELL1].ob_state &=~SELECTED;
    setrs[SERIELL2].ob_state &=~SELECTED;

    (*xcpb->getcookie)('_MCH',&ma);
    if(ma<=0x00010000L)
    {
        setrs[MODEM2].ob_state |= DISABLED;
        setrs[SERIELL1].ob_state |= DISABLED;
        setrs[SERIELL2].ob_state |= DISABLED;
        setrs[MODEM1].ob_state|=SELECTED;
    }
    else
    {
        if(ma<0x00020000L) setrs[SERIELL1].ob_state |= DISABLED;
        switch(inf->rp_flag)
        {
            case 1: setrs[MODEM1].ob_state|=SELECTED; break;
            case 2: setrs[MODEM2].ob_state|=SELECTED; break;
            case 3: setrs[SERIELL1].ob_state|=SELECTED; break;
            case 4: setrs[SERIELL2].ob_state|=SELECTED; break;
            default: break;
        }
    }
    if(inf->rsm_flag) setrs[GLAETTEN].ob_spec.free_string="An";    
    else              setrs[GLAETTEN].ob_spec.free_string="Aus";    
    if(inf->ms_flag)
    {
         setrs[MICROSOF].ob_state|=SELECTED;
         setrs[MSYSTEM].ob_state&=~SELECTED;
    }
    else
    {
         setrs[MSYSTEM].ob_state|=SELECTED;
         setrs[MICROSOF].ob_state&=~SELECTED;
    }
} /* init_setrs */

