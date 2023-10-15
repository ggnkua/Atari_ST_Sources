/*  WRAP_CPX.C
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
#pragma warn -rpt 
#include "wrapcpx.rsh"
#pragma warn +rpt 

#define MAX_MWERT 99
#define MAX_FWERT 20
#define MAX_WRAP 99

/* Eine handvoll Prototypen */
CPXINFO * cdecl cpx_init(XCPB *Xcpb);
WORD cdecl cpx_call(GRECT *re); 
void save_par(void);
void do_ok(void);
int do_cpx_alert(OBJECT *o,int e);
int do_speeder(GRECT *rect,int d);
int do_setrs(GRECT *rect);
int fselect(char *fname, char *text);

static void init_dialog(void); 
static int handle_dialog(WORD button, WORD *msg);
static int ap=0;

/* Globale Variablen */
GRECT   *w_rect;        /* Die Koordinaten des Fensters.        */
XCPB    *xcpb;          /* Zeiger auf die XControl-Funktionen.  */
CPXINFO cpxinfo;        /* Zeiger auf unsere Funktionen fÅr     */
                        /* XControl.                            */
MFORM   mzeiger;        /* Parkplatz fÅr den Mauszeiger.        */
char *items[20];        /* Zeiger-Feld fÅr die PopUp-MenÅs.     */

int akt_slide;          /* aktueller Slider.                    */
int vslide;             /* Wert fÅr den vertikalen Slider.      */
INF *inf,               /* Zeiger auf die COOKIE-Struktur.      */
    inf_back;

OBJECT  *dialog,        /* Zeiger auf unsere Dialoge.           */
        *speeder,
        *setrs,
        *info;
        
/* Externe Variablen aus dem Assemblerteil */
extern INF ainf;
long (*bsetv)(void);

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
        if((*xcpb->getcookie)('WrAp',(long *)(&inf)))
        {
            if(!inf->fix)
            {
                bsetv=inf->set_vec;
                if(ainf.set_vec)memcpy(inf,&ainf,sizeof(inf_back));
                inf->fix=TRUE;
                bsetv();
            }
        }
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
    speeder=(OBJECT *)rs_trindex[SPEEDER];
    setrs=(OBJECT *)rs_trindex[SETRS232];
    info=(OBJECT *)rs_trindex[PINFO];

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

    
    if(!(*xcpb->getcookie)('WrAp',(long *)(&inf)))
    {
        form_alert(1,"[3][ |Sorry,|WRAPMOUS.PRG fehlt][ Okay ]");
        return(FALSE);
    }
    memcpy(&inf_back,inf,sizeof(inf_back));
    ap=inf->sa.tiefe;
    
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
    memcpy(inf,&inf_back,sizeof(inf_back));
    return(FALSE);
} /* cpx_call */

static WORD handle_dialog(WORD button, WORD *msg)
/* Hier behandeln wir die Objekte, die angeklickt wurden.       */
/* In button steht die Objekt-Nr. und in msg ein Zeiger auf     */
/* einen Messag-Buffer (Ñhnlich wie evnt_mesag).                */
{
    static char sf[MAX_PROG][17];
    static char fn[20];
    GRECT r1;           /* Koordinaten-Feld.                    */
    WORD p;             /* Hilfsvariablen.                      */
    int i;
    
    if((button!=-1)&&(button & 0x8000))
        button &= 0x7fff;

    switch(button)
    {
        case SFILE:
            strcpy(sf[0],"  Neu           ");
            items[0]=sf[0];
            for(i=1;i<=MAX_PROG;i++)
            {
                if(inf->pf[i-1].name[0])
                {
                    items[i]=sf[i];
                    sf[i][0]=sf[i][1]=' ';
                    strcpy(&sf[i][2],inf->pf[i-1].name);
                    while(strlen(sf[i])<16) strcat(sf[i]," ");
                }
                else break;
            }
            objc_offset(dialog,button,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[button].ob_width;
            r1.g_h=dialog[button].ob_height;
            p=(*xcpb->Popup)(items,i,-1,3,&r1,w_rect);
            if(p>=0)
            {
                if(Kbshift(-1)&3)
                {
                    if(p>1)
                    {
                        ap=0;
                        if(form_alert(1,"[1][ |Wirklich lîschen][ Ja | Nein ]")==1)
                        {
                            for(i=p-1;i<MAX_PROG-1;i++)
                            {
                                strcpy(inf->pf[i].name,inf->pf[i+1].name);
                                inf->pf[i].c_flag=inf->pf[i+1].c_flag;
                                inf->pf[i].d_flag=inf->pf[i+1].d_flag;
                                inf->pf[i].t_flag=inf->pf[i+1].t_flag;
                            }
                        }
                    }
                }
                else
                {
                    if(p) ap=p-1;
                    else
                    {
                        if(i>=MAX_PROG-1) form_alert(1,"[3][ |Es kînnen keine Programme|mehr aufgenommen werden!][ OK ]");
                        else if(fselect(fn,"Programm wÑhlen"))
                        {
                            strcpy(inf->pf[i-1].name,fn);
                            ap=i-1;
                        }
                    }
                }
                init_dialog();
                objc_draw(dialog,ROOT,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            break;
            
        case M_INFO:
            items[0]="  Info... ";
            objc_offset(dialog,M_INFO,&r1.g_x,&r1.g_y);
            r1.g_y+=17;
            r1.g_w=dialog[M_INFO].ob_width;
            r1.g_h=dialog[M_INFO].ob_height;
            p=(*xcpb->Popup)(items,1,-1,3,&r1,w_rect);
            if(p==0) do_cpx_alert(info,0);
            dialog[button].ob_state &= ~SELECTED;
            objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            break;

        case M_SPEED:
            items[0]="  Atari Mouse ";
            items[1]="  RS232 Mouse ";
            items[2]="  Joystick    ";
            
            objc_offset(dialog,button,&r1.g_x,&r1.g_y);
            r1.g_y+=17;
            r1.g_w=dialog[button].ob_width;
            r1.g_h=dialog[button].ob_height;
            p=(*xcpb->Popup)(items,3,-1,3,&r1,w_rect);
            if(p>=0)
            {
                do_ok();
                if(do_speeder(w_rect,p)) return(TRUE);
                dialog[ROOT].ob_x=w_rect->g_x;
                dialog[ROOT].ob_y=w_rect->g_y;
                dialog[button].ob_state &= ~SELECTED;
                objc_draw(dialog,ROOT,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            dialog[button].ob_state &= ~SELECTED;
            objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            break;

        case RSSET:
            items[0]="  Einstellungen ";
            
            objc_offset(dialog,button,&r1.g_x,&r1.g_y);
            r1.g_y+=17;
            r1.g_w=dialog[button].ob_width;
            r1.g_h=dialog[button].ob_height;
            p=(*xcpb->Popup)(items,1,-1,3,&r1,w_rect);
            if(p>=0)
            {
                do_ok();
                if(do_setrs(w_rect)) return(TRUE);
                dialog[ROOT].ob_x=w_rect->g_x;
                dialog[ROOT].ob_y=w_rect->g_y;
                dialog[button].ob_state &= ~SELECTED;
                objc_draw(dialog,ROOT,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            dialog[button].ob_state &= ~SELECTED;
            objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            break;

        case TAUSCHEN: case JOYSTICK: case IBMMOUSE:
            items[0]="  Aus ";
            items[1]="  An  ";
            objc_offset(dialog,button,&r1.g_x,&r1.g_y);
            r1.g_w=dialog[button].ob_width;
            r1.g_h=dialog[button].ob_height;
            p=(*xcpb->Popup)(items,2,-1,3,&r1,w_rect);
            if(p==1)      dialog[button].ob_spec.free_string="An";
            else if(p==0) dialog[button].ob_spec.free_string="Aus";
            if(p!=-1)
            {
                if(button==TAUSCHEN) inf->pf[ap].c_flag=p;
                else if(button==JOYSTICK) inf->j_flag=p;
                else if(button==IBMMOUSE) inf->r_flag=p;
                objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            }
            break;
           
        case DOPPELK:
            if(dialog[button].ob_state & SELECTED) inf->pf[ap].d_flag=TRUE;
            else inf->pf[ap].d_flag=FALSE;
            break;
        case SHIFTL:
            if(dialog[button].ob_state & SELECTED) inf->pf[ap].t_flag|=1;
            else inf->pf[ap].t_flag&=~1;
            break;
        case SHIFTR:
            if(dialog[button].ob_state & SELECTED) inf->pf[ap].t_flag|=2;
            else inf->pf[ap].t_flag&=~2;
            break;
        case CONTROL:
            if(dialog[button].ob_state & SELECTED) inf->pf[ap].t_flag|=4;
            else inf->pf[ap].t_flag&=~4;
            break;
        case ALTERNAT:
            if(dialog[button].ob_state & SELECTED) inf->pf[ap].t_flag|=8;
            else inf->pf[ap].t_flag&=~8;
            break;

        case SICHERN:
            /* Wer sich fÅr's SICHERN interessiert, dem sei     */
            /* save_par() empfohlen.                            */
            save_par();
            dialog[button].ob_state &= ~SELECTED;
            objc_draw(dialog,button,1,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            break;
        case OKAY:
            /* Bei OKAY werden noch die Betriebsparameter       */
            /* gesichert                                        */
            do_ok();
            dialog[button].ob_state &= ~SELECTED;
            return(TRUE);
        case ABBRUCH:
            memcpy(inf,&inf_back,sizeof(inf_back));
            dialog[button].ob_state &= ~SELECTED;
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
                                memcpy(inf,&inf_back,sizeof(inf_back));
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
    return(FALSE);
} /* handle_dialog */

static void init_dialog(void)
/* Der Dialog wird aufgebaut                                    */
{
    static char aa[2][6]={"Aus","An"};     
    
    dialog[TAUSCHEN].ob_spec.free_string=aa[inf->pf[ap].c_flag];    
    dialog[JOYSTICK].ob_spec.free_string=aa[inf->j_flag];    
    dialog[IBMMOUSE].ob_spec.free_string=aa[inf->r_flag];    

    if(inf->pf[ap].d_flag) dialog[DOPPELK].ob_state |= SELECTED;
    else dialog[DOPPELK].ob_state &= ~SELECTED;
    if(inf->pf[ap].t_flag&1) dialog[SHIFTL].ob_state |= SELECTED;
    else dialog[SHIFTL].ob_state &= ~SELECTED;
    if(inf->pf[ap].t_flag&2) dialog[SHIFTR].ob_state |= SELECTED;
    else dialog[SHIFTR].ob_state &= ~SELECTED;
    if(inf->pf[ap].t_flag&4) dialog[CONTROL].ob_state |= SELECTED;
    else dialog[CONTROL].ob_state &= ~SELECTED;
    if(inf->pf[ap].t_flag&8) dialog[ALTERNAT].ob_state |= SELECTED;
    else dialog[ALTERNAT].ob_state &= ~SELECTED;
    
    dialog[SFILE].ob_spec.free_string=inf->pf[ap].name;
} /* init_dialog */

void save_par(void)
/* Die Parameter werden von XControl an den Anfang des Daten-   */
/* segments gesichert. Bitte den Assemblerteil anschauen!       */
{
    if((*xcpb->XGen_Alert)(SAVE_DEFAULTS))
    {
        if(!(*xcpb->CPX_Save)(inf,sizeof(ainf)))
            (*xcpb->XGen_Alert)(FILE_ERR);
    }
} /* save_par */

void do_ok(void)
{
    memcpy(&inf_back,inf,sizeof(inf_back));
} /* do_ok */

int do_cpx_alert(OBJECT *o,int e)
/* ALARM! ALARM!                                                */
/* Diese Funktion zeichnet und verwaltet eine Dialogbox im      */
/* XControl-Fenster                                             */
{
    int i,ox,oy,
        x,y,w,h;
    static MFORM mf;
    
    wind_update(BEG_MCTRL);
    wind_update(BEG_UPDATE);
    (*xcpb->MFsave)(MFSAVE, &mf);
    graf_mouse(ARROW,NULL);

    form_center(o,&x,&y,&w,&h); 
    ox=o[ROOT].ob_x-x;
    oy=o[ROOT].ob_y-y;
    x=w_rect->g_x+((w_rect->g_w-w)/2);
    y=w_rect->g_y+((w_rect->g_h-h)/2);
    o[ROOT].ob_x=x+ox;
    o[ROOT].ob_y=y+oy;

    form_dial(FMD_START,0,0,0,0,x,y,w,h);
    form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
    objc_draw(o,ROOT,MAX_DEPTH,x,y,w,h);
    i=form_do(o,e) & 0x7fff;
    o[i].ob_state &= ~SELECTED;
    form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);

    (*xcpb->MFsave)(MFRESTORE, &mf);
    wind_update(END_UPDATE);
    wind_update(END_MCTRL);

    return(i);
} /* do_cpx_alert */
