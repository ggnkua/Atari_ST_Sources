/*  SND_CPX.C
 *  Das CPX-Modul zur Steuerung von GEMSOUND.PRG
 *
 *  aus: GEM Sound
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
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
#include "sounds.h"
#include "sndcpx.h"
#pragma warn -rpt 
#include "sndcpx.rsh"
#pragma warn +rpt 


/* Eine handvoll Prototypen */
CPXINFO * cdecl cpx_init(XCPB *Xcpb);
WORD cdecl cpx_call(GRECT *re); 
void save_par(void);
void ch_vtext(void);
void do_ok(void);
void init_dialog(void); 
int handle_dialog(WORD button, WORD *msg);
int do_cpx_alert(OBJECT *o,int e);

/* Globale Variablen */
GRECT   *w_rect;        /* Die Koordinaten des Fensters.        */
XCPB    *xcpb;          /* Zeiger auf die XControl-Funktionen.  */
CPXINFO cpxinfo;        /* Zeiger auf unsere Funktionen fr     */
                        /* XControl.                            */
MFORM   mzeiger;        /* Parkplatz fr den Mauszeiger.        */
char *items[MAX_SAMP];  /* Zeiger-Feld fr die PopUp-Mens.     */
char so[MAX_SAMP][20];  /* Area fr die Sound-Namen.            */
char go[MAX_SAMP][20];  /* Area fr die AES-Namen.              */

struct GPAR             /* Nummern und Namen der AES-Aufrufe.   */
{
    int nr;
    char name[9];
} gp[MAX_SAMP]=
{
    {0,  "L™SCHEN"},
    {-1, "SysBell"},
    {-2, "T_Click"},
    {30, "Menu_Bar"},
    {33, "Menu_Tno"},
    {50, "Form_Do"},
    {51, "F_Dial"},
    {52, "F_Alert"},
    {53, "F_Error"},
    {56, "F_Button"},
    {70, "Graf_Rub"},
    {71, "Graf_Dra"},
    {72, "Graf_Mbo"},
    {73, "Graf_Gro"},
    {74, "Graf_Shr"},
    {78, "Graf_Mou"},
    {90, "Fsel_Inp"},
    {91, "Fsel_ExI"},
    {101,"W_Open"},
    {102,"W_Close"}
};

int vslide;             /* Wert fr den vertikalen Slider.      */
C_SOUNDS *si,           /* Zeiger auf die COOKIE-Struktur.      */
         si_back;

OBJECT  *dialog,        /* Zeiger auf unsere Dialoge.           */
        *info;
        
/* Externe Variablen aus dem Assemblerteil */
extern struct 
{
    int r_flag;
    int ruhe;
    int nr[MAX_SAMP];
    int sound[MAX_SAMP];
    int an[MAX_SAMP];
} sound_inf;

CPXINFO * cdecl cpx_init(XCPB *Xcpb)
/* Diese Funktion wird w„hrend der XControl-Initialisierung und */
/* bei jeder Aktivierung unseres CPX-Moduls als erstes          */
/* gestartet. Sie erh„lt einen Zeiger auf die CPX-Funktionen    */
/* und muž einen Zeiger auf die eigenen Funktionen oder NULL    */
/* bzw. 1 zurckgeben.                                          */
{
    int i;
    xcpb=Xcpb;
    

    if(xcpb->booting)
    /* Dieses Flag zeigt an, ob es der erste Aufruf (w„hrend der*/
    /* XControl-Initialisierung) ist.                           */
    {
        /* Die gesicherten Werte werden gesetzt.                */
        if((*xcpb->getcookie)('GSND',(long *)(&si)))
        {
            if(!si->fix)
            {
                si->fix=TRUE;
                for(i=0;i<MAX_SAMP;i++)
                {
                    si->gem_inf[i].nr=0;
                    si->gem_inf[i].sound=0;
                    si->gem_inf[i].an=0;
                }
                si->r_flag=sound_inf.r_flag;
                si->ruhe=sound_inf.ruhe;
                for(i=0;i<MAX_SAMP;i++)
                {
                    if(sound_inf.sound[i] < si->max_sound)
                    {
                        si->gem_inf[i].nr=sound_inf.nr[i];
                        si->gem_inf[i].sound=sound_inf.sound[i];
                        si->gem_inf[i].an=sound_inf.an[i];
                    }
                }   
                Supexec(si->set_vec);
            }
        }
        /* W„hrend der Initialisierung muž eine 1 zurckgegeben */
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
    info=(OBJECT *)rs_trindex[PINFO];

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
{
    WORD msg[8];        /* Puffer fr Xform_do.                 */
    WORD button,        /* Welches Schweinderl „hh button.      */
         ende;          /* Flag fr's ENDE.                     */

    
    if(!(*xcpb->getcookie)('GSND',(long *)(&si)))
    {
        form_alert(1,"[3][ |Sorry,|GEMSOUND.PRG fehlt][ Okay ]");
        return(FALSE);
    }
    memcpy(&si_back,si,sizeof(si_back));

    /* Unser Dialog muž angepažt werden.                        */
    w_rect=rect;
    dialog[ROOT].ob_x=w_rect->g_x;
    dialog[ROOT].ob_y=w_rect->g_y;
    
    /* Initialisieren und zeichnen.                             */
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
    memcpy(si,&si_back,sizeof(si_back));
    return(FALSE);
} /* cpx_call */

WORD handle_dialog(WORD button, WORD *msg)
/* Hier behandeln wir die Objekte, die angeklickt wurden.       */
/* In button steht die Objekt-Nr. und in msg ein Zeiger auf     */
/* einen Messag-Buffer („hnlich wie evnt_mesag).                */
{
    GRECT r1;           /* Koordinaten-Feld.                    */
    WORD i,p,ox,oy;     /* Hilfsvariablen.                      */
    WORD mx,my,mk,kb;   /* Variablen fr das M„usekind.         */
    
    if((button!=-1)&&(button & 0x8000))
        button &= 0x7fff;

    switch(button)
    {
        case M_INFO:
            items[0]="  Info...       ";
            
            objc_offset(dialog,M_INFO,&r1.g_x,&r1.g_y);
            r1.g_y+=17;
            r1.g_w=dialog[M_INFO].ob_width;
            r1.g_h=dialog[M_INFO].ob_height;
            
            p=(*xcpb->Popup)(items,1,-1,3,&r1,w_rect);
            if(p==0) do_cpx_alert(info,0);

            dialog[button].ob_state &= ~SELECTED;
            objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            break;

        case M_OPTION:
            if(si->ruhe)
                items[0]="  Sounds Aus    ";
            else
                items[0]="  Sounds Ein    ";
            if(si->r_flag)
                items[1]="  SReset Ein    ";
            else
                items[1]="  SReset Aus    ";
            items[2]=    "  Sound spielen ";
            
            objc_offset(dialog,M_OPTION,&r1.g_x,&r1.g_y);
            r1.g_y+=17;
            r1.g_w=dialog[M_OPTION].ob_width;
            r1.g_h=dialog[M_OPTION].ob_height;
            
            p=(*xcpb->Popup)(items,3,-1,3,&r1,w_rect);
            if(p==0)
                si->ruhe=si->ruhe?0:1;
            else if(p==1)
                si->r_flag=si->r_flag?0:1;
            else if(p==2)
            {
                for(i=0;i<si->max_sound;i++) items[i]=so[i];
                p=(*xcpb->Popup)(items,si->max_sound,-1,3,&r1,w_rect);
                if(p!=-1)
                {
                    i=si->ruhe;
                    si->ruhe=TRUE;
                    si->play(&(si->sounds[p]),TRUE);
                    si->ruhe=i;
                }
            }
            dialog[button].ob_state &= ~SELECTED;
            objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
            break;
            
        case VMINUS:
            (*xcpb->Sl_arrow)(dialog,VVATER,VTEXT,button,-1,1,MAX_SAMP-3,&vslide,0,ch_vtext);
            break;
        case VPLUS:
            (*xcpb->Sl_arrow)(dialog,VVATER,VTEXT,button,1,1,MAX_SAMP-3,&vslide,0,ch_vtext);
            break;
        case VVATER:
            objc_offset(dialog,VTEXT,&ox,&oy);
            graf_mkstate(&mx,&my,&mk,&kb);
            p= my>oy ? -5 : 5;
            (*xcpb->Sl_arrow)(dialog,VVATER,VTEXT,-1,p,1,MAX_SAMP-3,&vslide,0,ch_vtext);
            break;
        case VTEXT:
            (*xcpb->MFsave)(MFSAVE, &mzeiger);
            graf_mouse(FLAT_HAND,NULL);
            (*xcpb->Sl_dragy)(dialog,VVATER,VTEXT,1,MAX_SAMP-3,&vslide,ch_vtext);
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
            if(button>=FLAG && button <=FLAG+3)
            {
                items[0]="  An  ";
                items[1]="  Aus ";
            
                objc_offset(dialog,button,&r1.g_x,&r1.g_y);
                r1.g_w=dialog[button].ob_width;
                r1.g_h=dialog[button].ob_height;
                i=MAX_SAMP-3-vslide+(button-FLAG);
                if(si->gem_inf[i].nr)
                {
                    p=(*xcpb->Popup)(items,2,si->gem_inf[i].an ? 0:1,3,&r1,w_rect);
                    if(p==0)
                    {
                        si->gem_inf[i].an=TRUE;
                        dialog[button].ob_spec.tedinfo->te_ptext="An";
                    }
                    else if(p==1)
                    {
                        si->gem_inf[i].an=FALSE;
                        dialog[button].ob_spec.tedinfo->te_ptext="Aus";
                    }
                    objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
                }
            }
            else if(button>=SOUND && button <=SOUND+3)
            {
                objc_offset(dialog,button,&r1.g_x,&r1.g_y);
                r1.g_w=dialog[button].ob_width;
                r1.g_h=dialog[button].ob_height;
                for(i=0;i<si->max_sound;i++) items[i]=so[i];
                i=MAX_SAMP-3-vslide+(button-SOUND);
                if(si->gem_inf[i].nr)
                {
                    p=(*xcpb->Popup)(items,si->max_sound,si->gem_inf[i].sound,3,&r1,w_rect);
                    if(p!=-1)
                    {
                        si->gem_inf[i].sound=p;
                        ch_vtext(); 
                        objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
                    }
                }
            }
            else if(button>=AES_NR && button <=AES_NR+3)
            {
                objc_offset(dialog,button,&r1.g_x,&r1.g_y);
                r1.g_w=dialog[button].ob_width;
                r1.g_h=dialog[button].ob_height;
                for(i=0;i<MAX_SAMP && gp[i].name[0];i++)
                {   
                    sprintf(go[i],"  %-8s ",gp[i].name);
                    items[i]=go[i];
                }
                p=(*xcpb->Popup)(items,i,-1,3,&r1,w_rect);
                i=MAX_SAMP-3-vslide+(button-AES_NR);
                if(p!=-1)
                {
                    si->gem_inf[i].nr=gp[p].nr;
                    ch_vtext(); 
                    objc_draw(dialog,button,MAX_DEPTH,w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
                }
            }
            else if(button==-1)
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
                                memcpy(si,&si_back,sizeof(si_back));
                                ch_vtext();
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

void init_dialog(void)
/* Der Dialog wird aufgebaut                                    */
{
    int i;
    vslide=MAX_SAMP-3;
    (*xcpb->Sl_size)(dialog,VVATER,VTEXT,MAX_SAMP-3,4,0,16);
    (*xcpb->Sl_y)(dialog,VVATER,VTEXT,vslide,1,MAX_SAMP-3,ch_vtext);
    for(i=0;i<si->max_sound;i++)
        sprintf(so[i],"  %-8s ",si->sounds[i].name);
} /* init_dialog */

void save_par(void)
/* Die Parameter werden von XControl an den Anfang des Daten-   */
/* segments gesichert. Bitte den Assemblerteil anschauen!       */
{
    int i;
    
    if((*xcpb->XGen_Alert)(SAVE_DEFAULTS))
    {
        sound_inf.r_flag=si->r_flag;
        sound_inf.ruhe=si->ruhe;
        for(i=0;i<MAX_SAMP;i++)
        {
            sound_inf.nr[i]=si->gem_inf[i].nr;
            sound_inf.sound[i]=si->gem_inf[i].sound;
            sound_inf.an[i]=si->gem_inf[i].an;
        }   
        if(!(*xcpb->CPX_Save)(&sound_inf,sizeof(sound_inf)))
            (*xcpb->XGen_Alert)(FILE_ERR);
    }
} /* save_par */

void ch_vtext(void)
/* ONLINE Slider   */
{
    int i,p,sp;

    sp=MAX_SAMP-3-vslide;
    for(i=0;(i<4) && (i+sp < MAX_SAMP);i++)
    {
        if(si->gem_inf[i+sp].nr)
        {
            for(p=0;p<MAX_SAMP;p++)
            {
                if(gp[p].nr==si->gem_inf[i+sp].nr)
                {
                    strncpy(dialog[AES_NR+i].ob_spec.tedinfo->te_ptext,gp[p].name,8);
                    break;
                }
            }
            if(p>=MAX_SAMP)
                itoa(si->gem_inf[i+sp].nr,dialog[AES_NR+i].ob_spec.tedinfo->te_ptext,10);
            strcpy(dialog[SOUND+i].ob_spec.tedinfo->te_ptext,si->sounds[si->gem_inf[i+sp].sound].name);
            if(si->gem_inf[i+sp].an)
                dialog[FLAG+i].ob_spec.tedinfo->te_ptext="An";
            else
                dialog[FLAG+i].ob_spec.tedinfo->te_ptext="Aus";
        }
        else
        {
            dialog[AES_NR+i].ob_spec.tedinfo->te_ptext[0]=0;
            dialog[SOUND+i].ob_spec.tedinfo->te_ptext[0]=0;
            dialog[FLAG+i].ob_spec.tedinfo->te_ptext="";
        }
    }
    objc_draw(dialog,DISPLAY,MAX_DEPTH,
                w_rect->g_x,w_rect->g_y,w_rect->g_w,w_rect->g_h);
} /* ch_vtext */

void do_ok(void)
{
    memcpy(&si_back,si,sizeof(si_back));
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
