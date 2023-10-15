/*  DEMO_CPX.C
 *  Ein Demo-CPX-Modul
 *
 *  aus: Wir basteln uns ein CPX
 *       CPX-Kurs Teil 1
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
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
#include "democpx.h"
#pragma warn -rpt 
#include "democpx.rsh"
#pragma warn +rpt 

#define TRUE 1
#define FALSE 0

/* Eine handvoll Prototypen */
CPXINFO * cdecl cpx_init(XCPB *Xcpb);
WORD cdecl cpx_call(GRECT *re); 
void save_par(void);
void ch_htext(void);
void ch_vtext(void);
void do_ok(void);
void init_dialog(void); 
WORD handle_dialog(WORD button, WORD *msg);

/* Globale Variablen */
GRECT   *w_rect;        /* Die Koordinaten des Fensters.        */
int     *cpx_buffer;    /* Dort lagert XControl die Daten.      */
XCPB    *xcpb;          /* Zeiger auf die XControl-Funktionen.  */
CPXINFO cpxinfo;        /* Zeiger auf unsere Funktionen fr     */
                        /* XControl.                            */
MFORM   mzeiger;        /* Parkplatz fr den Mauszeiger.        */

int hslide,             /* Wert fr den horizontalen Slider.    */
    vslide,             /* Wert fr den vertikalen Slider.      */
    popup;              /* Flag fr PopUp AN oder AUS.          */

OBJECT  *dialog;        /* Zeiger auf unseren Dialog.           */

/* Externe Variablen aus den Assemblerteil */
extern int  shslide,    /* Speicherplatz fr hslide.            */
            svslide,    /* Speicherplatz fr vslide             */
            spopup;     /* Speicherplatz fr popup              */


CPXINFO * cdecl cpx_init(XCPB *Xcpb)
/* Diese Funktion wird w„rend der XControl-Initialisierung und  */
/* bei jeder Aktivierung unseres CPX-Moduls als erstes          */
/* gestartet. Sie erh„lt einen Zeiger auf die CPX-Funktionen    */
/* und muž einen Zeiger auf die eigenen Funktionen oder NULL    */
/* bzw. 1 zurckgeben.                                          */
{
    xcpb=Xcpb;


    if(xcpb->booting)
    /* Dieses Flag zeigt an ob es der erste Aufruf (w„rend der  */
    /* XControl-Initialisierung) ist.                           */
    {
        /* Wir holen uns den Puffer-Bereich von XControl und    */
        /* legen in ihm die Startvorgaben ab.                   */
        cpx_buffer=(int *)(*xcpb->Get_Buffer)();
        cpx_buffer[0]=shslide;
        cpx_buffer[1]=svslide;
        cpx_buffer[2]=spopup;
        
        /* W„rend der Initialisierung muž eine 1 zurckgegeben  */
        /* werden, wenn das CPX-Modul nicht set_only sein soll. */
        return ((CPXINFO *)1);
    }

    if(!xcpb->SkipRshFix)
    /* In diesem Flag wird festgehalten, ob der OBJECT-Baum     */
    /* schon angepažt wurde.                                    */
    {
        /* Wir passen den OBJECT-Baum an.                       */
        (*xcpb->rsh_fix)(NUM_OBS,NUM_FRSTR,NUM_FRIMG,NUM_TREE,
                         rs_object,rs_tedinfo,rs_strings,rs_iconblk,
                         rs_bitblk,rs_frstr,rs_frimg,rs_trindex,
                         rs_imdope);
    }
    dialog=(OBJECT *)rs_trindex[DIALOG];

    /* In die CPXINFO-Struktur mssen unsere Funktionen ein-    */
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
    
    /* Mit der Rckgabe unserer Funktionen melden wir uns beim  */
    /* XControl an.                                             */
    return(&cpxinfo);
} /* cpx_init */

WORD cdecl cpx_call(GRECT *rect)
/* Hier steht der Hauptteil, er wird von XControl bei der       */
/* Aktivierung unseres Moduls nach cpx_init aufgerufen.         */
/* In *rect stehen die Koordinaten des XControl-Fensters.       */
/* Bei einem Xform_do-CPX (wie in unserem Fall), muž immer 0    */
/* zurckgegeben werden.                                        */
{
    WORD msg[8];        /* Puffer fr Xform_do.                 */
    WORD button,        /* Welches Schweinderl „hh button.      */
         ende;          /* Flag fr's ENDE.                     */

    /* Unser Dialog muž angepažt werden.                        */
    w_rect=rect;
    dialog[ROOT].ob_x=w_rect->g_x;
    dialog[ROOT].ob_y=w_rect->g_y;
    
    /* Initialiseren und zeichnen.                              */
    init_dialog();
    objc_draw(dialog,ROOT,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
    do
    { 
        /* Wir berlassen XControl die Verwaltung des Dialogs.  */
        button=(*xcpb->Xform_do)(dialog,0,msg);
        /* Nun mssen wir arbeiten.                             */
        ende=handle_dialog(button,msg);
    } while(!ende);
    
    /* Ende unseres Moduls, XControl ist wieder an der Reihe.   */
    return(FALSE);
} /* cpx_call */

WORD handle_dialog(WORD button, WORD *msg)
/* Hier behandeln wir die Objekte, die angeklickt wurden.       */
/* In button steht die Objekt-Nr. und in msg ein Zeiger auf     */
/* einen Messag-Buffer („hnlich wie evnt_mesag).                */
{
    GRECT r1;           /* Koordinaten-Feld.                    */
    WORD p,ox,oy;       /* Hilfsvariablen.                      */
    WORD mx,my,mk,kb;   /* Variablen fr das M„usekind.         */
    char *items[4];     /* Zeiger-Feld fr die PopUp-Mens.     */
    
    /* Das Ausmaskieren eines Doppel-Clicks gestaltet sich hier */
    /* etwas komplizierter als bei form_do, da Xform_do als     */
    /* Flag fr Nachrichten -1 liefert.                         */
    if((button!=-1)&&(button & 0x8000))
        button &= 0x7fff;

    switch(button)
    {
        /* Ein PopUp als Schalter!                              */
        case POPUP:
            /* Die einzelnen Menpunkte fr ein PopUp mssen    */
            /* immer gleich lang sein! Am Anfang mssen zwei    */
            /* Leerzeichen und am Ende mindestens eines stehen. */
            items[0]="  Aus ";
            items[1]="  An  ";
            
            /* XControl braucht die Koordinaten des PopUp-      */
            /* Buttons. Also lassen wir sie uns berechnen.      */
            objc_offset(dialog,POPUP,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[POPUP].ob_width;
            r1.g_h=dialog[POPUP].ob_height;
            
            /* Die Hauptarbeit bernimmt XControl (Atari sei    */
            /* Dank).                                           */
            p=(*xcpb->Popup)(items,2,popup,3,&r1,w_rect);
            
            /* Je nach ausgew„hlten Men-Punkt muž der Button   */
            /* noch ver„ndert und neu gezeichnet werden.        */
            if(p==1)
                dialog[POPUP].ob_spec.free_string="An";
            else if(p==0)
                dialog[POPUP].ob_spec.free_string="Aus";
            if(p!=-1)
            {
                popup=p;
                objc_draw(dialog,POPUP,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            break;

        /* Und schon wieder ein PopUp, aber diesmal nicht       */
        /* als Schalter, sondern als Men.                      */
        case MENU:
            /* Es gelten die gleichen Regeln wie bei POPUP.     */
            items[0]="  Info...       ";
            items[1]="  Hier k”nnten  ";
            items[2]="  Ihre Eintr„ge ";
            items[3]="  stehen!       ";
            
            objc_offset(dialog,MENU,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[MENU].ob_width;
            r1.g_h=dialog[MENU].ob_height;
            
            p=(*xcpb->Popup)(items,4,-1,3,&r1,w_rect);
            if(p==0)
                form_alert(1,"[1][Demo CPX-Modul|1992 by R.Kurz| |TOS Magazin][ Okay ]");               
            else if(p!=-1)
                form_alert(1,"[1][Selber machen|ist angesagt!][ Juchu ]");              
            break;
            
        /* Es wird glatt, wir schlittern ein wenig (horizontal) */
        /* XControl vereinfacht die Slider-Behandlung. (Toll)   */
        case HMINUS:
            (*xcpb->Sl_arrow)(dialog,HVATER,HTEXT,button,-1,0,80,&hslide,1,ch_htext);
            break;
        case HPLUS: 
            (*xcpb->Sl_arrow)(dialog,HVATER,HTEXT,button,1,0,80,&hslide,1,ch_htext);
            break;
        case HVATER:
            /* Wurde auf das 'Unterteil' des Sliders geklickt,  */
            /* muž noch berechnet werden, ob der User rauf oder */
            /* runter meint.                                    */
            objc_offset(dialog,HTEXT,&ox,&oy);
            graf_mkstate(&mx,&my,&mk,&kb);
            p= mx>ox ? 10: -10;
            (*xcpb->Sl_arrow)(dialog,HVATER,HTEXT,-1,p,0,80,&hslide,1,ch_htext);
            break;
        case HTEXT:
            /* Aha, jemand m”chte mit der Hand schieben.        */
            /* Wenn die Mausform ge„ndert wird, sollte die alte */
            /* Form gespeichert und danach wieder restauriert   */
            /* werden.                                          */
            (*xcpb->MFsave)(MFSAVE, &mzeiger);
            graf_mouse(FLAT_HAND,NULL);
            (*xcpb->Sl_dragx)(dialog,HVATER,HTEXT,1,80,&hslide,ch_htext);
            (*xcpb->MFsave)(MFRESTORE, &mzeiger);
            break;
        
        /* Noch ein Slider, aber diesmal vertikal.              */
        case VMINUS:
            (*xcpb->Sl_arrow)(dialog,VVATER,VTEXT,button,-1,1,40,&vslide,0,ch_vtext);
            break;
        case VPLUS:
            (*xcpb->Sl_arrow)(dialog,VVATER,VTEXT,button,1,1,40,&vslide,0,ch_vtext);
            break;
        case VVATER:
            objc_offset(dialog,VTEXT,&ox,&oy);
            graf_mkstate(&mx,&my,&mk,&kb);
            p= my>oy ? -5 : 5;
            (*xcpb->Sl_arrow)(dialog,VVATER,VTEXT,-1,p,1,40,&vslide,0,ch_vtext);
            break;
        case VTEXT:
            (*xcpb->MFsave)(MFSAVE, &mzeiger);
            graf_mouse(FLAT_HAND,NULL);
            (*xcpb->Sl_dragy)(dialog,VVATER,VTEXT,1,40,&vslide,ch_vtext);
            (*xcpb->MFsave)(MFRESTORE, &mzeiger);
            break;

        case SICHERN:
            /* Wer sich fr's SICHERN interessiert, dem sei     */
            /* save_par() empfohlen.                            */
            save_par();
            dialog[button].ob_state &= ~SELECTED;
            objc_draw(dialog,button,1,
                    w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            break;
        case OKAY:
            /* Bei OKAY werden noch die Betriebsparameter       */
            /* gesichert                                        */
            do_ok();
        case ABBRUCH:
            dialog[button].ob_state &= ~SELECTED;
            return(TRUE);

        default:
            /* Wenn Xform_do -1 zurckliefert, ist etwas im     */
            /* Busche, bzw. im Message-Puffer. Der Aufbau des   */
            /* Puffers ist „hnlich wie bei evnt_mesag.          */
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
                    /* Dateien ge”ffnet, unbedingt aufr„umen!!  */
                        return(TRUE);
                    case CT_KEY:
                    /* Jemand hat eine Sondertaste gedrckt.    */
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
                                init_dialog();
                                objc_draw(dialog,ROOT,MAX_DEPTH,
                                           w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
                            }
                        }
                    case WM_REDRAW:
                    /* Darum braucht sich ein Xform_do-Modul    */
                    /* nicht kmmern. Nur Event-Module haben    */
                    /* Arbeit damit.                            */
                    default:
                        break;
                }
            }
            break;
    }
    return(FALSE);
} /* handle_dialog */

void init_dialog(void)
/* Aus dem permanenten Puffer von XControl werden die Werte     */
/* geholt und der Object-Baum angepažt.                         */
{
    cpx_buffer=(int *)(*xcpb->Get_Buffer)();
    hslide=cpx_buffer[0];
    vslide=cpx_buffer[1];
    popup=cpx_buffer[2];
    

    (*xcpb->Sl_x)(dialog,HVATER,HTEXT,hslide,0,80,ch_htext);
    (*xcpb->Sl_y)(dialog,VVATER,VTEXT,vslide,1,40,ch_vtext);

    if(popup) dialog[POPUP].ob_spec.free_string="An";
    else      dialog[POPUP].ob_spec.free_string="Aus";
} /* init_dialog */

void save_par(void)
/* Die Parameter werden von XControl an den Anfang des Daten-   */
/* segmts gesichert. Bitte den Assemblerteil anschauen!         */
{
    if((*xcpb->XGen_Alert)(SAVE_DEFAULTS))
    {
        cpx_buffer[0]=hslide;
        cpx_buffer[1]=vslide;
        cpx_buffer[2]=popup;
        shslide=hslide;
        svslide=vslide;
        spopup=popup;

        if(!(*xcpb->CPX_Save)(&shslide,6))
            (*xcpb->XGen_Alert)(FILE_ERR);
    }
} /* save_par */

void ch_htext(void)
/* Aktualisiert den Text im horizontalen Slider.                */
{
    static char s[10];
    
    sprintf(s,"%i",hslide);
    dialog[HTEXT].ob_spec.free_string=s; 
} /* ch_htext */

void ch_vtext(void)
/* Aktualisiert den Text im vertikalen Slider.                  */
{
    static char s[10];
    
    sprintf(s,"%i",vslide);
    dialog[VTEXT].ob_spec.free_string=s; 
} /* ch_vtext */

void do_ok(void)
/* Sichert die Parameter im permanenten Puffer von XControl.    */
{
    cpx_buffer[0]=hslide;
    cpx_buffer[1]=vslide;
    cpx_buffer[2]=popup;
} /* do_ok */
