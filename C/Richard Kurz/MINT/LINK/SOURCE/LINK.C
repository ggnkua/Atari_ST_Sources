/*
 * Link
 * Main-Teil
 * Oktober 1992 by Richard Kurz
 * fÅr's TOS-Magazin
 */

#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h>
#include <portab.h>

#include "mintbind.h"

#include "link.h"
#include "link_rsc.h"
#include "link_rsc.rh"
#include "link_rsc.rsh"

extern HWINDOW *win[MAX_WINDOW];    /* Zeiger auf die Fensterliste  */

int entrys;                         /* Anzahl der EintrÑge          */

static int ps_win;                  /* Die Nummer des Hauptfensters */
static OBJECT *dialog;              /* Der Hauptdialog              */
static OBJECT *help;                /* Der Dialog fÅr die Hilfe     */
static OBJECT *info;                /* Der Informationdialog        */
static OBJECT *meldung;             /* Der Fehlerdialog             */

static void do_hilfe(void);

static int al_button(int b,int w)
/* Allgemeiner Button-Handler */
{
    win[w]->obj[b].ob_state &= ~SELECTED;
    close_window(win[w]->handle);
    return(TRUE);
}/* al_button */

static int al_tast(int t,int w)
/* Allgemeiner Tasten-Handler */
{
    int ascii,scan;

    ascii=t<<8;ascii>>=8;
    scan=t>>8;
    
    if(Kbshift(-1) & 4)
    {
        ascii+=0x60;
        switch(ascii)
        {
            case 'q': return(FALSE);
            default:  break;
        }
    }
    else if(scan==0x62) do_hilfe();
    else if(scan==0x61)
    {
        close_window(win[w]->handle);
        return(!win[w]->end);
    }
    return(TRUE);
}/* al_tast */

void do_meldung(char *t1,char *t2,char *t3,char *t4)
/* ôffnet das Fehler-Fenster */
{
    static HWINDOW fw;

    meldung[FZ1].ob_spec.tedinfo->te_ptext=t1;
    meldung[FZ2].ob_spec.tedinfo->te_ptext=t2;
    meldung[FZ3].ob_spec.tedinfo->te_ptext=t3;
    meldung[FZ4].ob_spec.tedinfo->te_ptext=t4;

    if(fw.wopen)
    {
        wind_set(fw.handle,WF_TOP,0,0,0,0);
        draw_obj(meldung,ROOT,MAX_DEPTH,fw.nr);
    }
    else
    {
        fw.obj=meldung;
        fw.do_button=al_button;
        fw.do_wtast=al_tast;
        fw.kind=NAME|MOVER;
        fw.title=" Link / Meldung ";
        if(!open_window(&fw)) return;
    }
} /* do_fehler */

static void do_info(void)
/* ôffnet das Info-Fenster */
{
    static HWINDOW iw;
    
    if(iw.wopen) wind_set(iw.handle,WF_TOP,0,0,0,0);
    else
    {
        iw.obj=info;
        iw.do_button=al_button;
        iw.do_wtast=al_tast;
        iw.kind=NAME|MOVER;
        iw.title=" Link / Info ";
        if(!open_window(&iw)) return;
    }
} /* do_info */

static void do_hilfe(void)
/* ôffnet das Hilfe-Fenster */
{
    static HWINDOW hw;
    
    if(hw.wopen) wind_set(hw.handle,WF_TOP,0,0,0,0);
    else
    {
        hw.obj=help;
        hw.do_button=al_button;
        hw.do_wtast=al_tast;
        hw.kind=NAME|MOVER;
        hw.title=" Link / Hilfe ";
        if(!open_window(&hw)) return;
    }
} /* do_hilfe */

static int wm_button(int f,int w)
/* Button-Handler fÅr's Hauptfenster */
{

    if(f&0x8000)
    {
        f&=0x7fff;
    }

    switch(f)
    {
        case ENDE:
            dialog[f].ob_state &= ~SELECTED;
            return(FALSE);
        case HILFE: do_hilfe(); break;
        case BYRK: do_info(); break;
        case SYMBLINK: set_sym_link(); break;
        case READLINK: read_link(); break;
        case LOESCHEN: del_link(); break;
        default:
            break;

    }
    if(dialog[f].ob_state & SELECTED)
    {
        dialog[f].ob_state &= ~SELECTED;
        draw_obj(dialog,f,1,w);
    }
    return(TRUE);
} /* wm_button */

static void toggle_button(OBJECT *o, int d, int w)
{
    if(o[d].ob_state&SELECTED) o[d].ob_state &=~SELECTED;
    else o[d].ob_state |=SELECTED;
    draw_obj(o,d,1,w);
}/* toggle_button */

static int wm_tast(int t,int w)
/* Tasten-Handler fÅr's Hauptfenster */
{
    int ascii,scan;

    ascii=t<<8;ascii>>=8;
    scan=t>>8;
    
    if(Kbshift(-1) & 4)
    {
        ascii+=0x60;
        switch(ascii)
        {
            case 'q':
                return(FALSE);
            case 'i':
                toggle_button(dialog,BYRK,w);
                do_info();        
                toggle_button(dialog,BYRK,w);
                break;
            default:  break;
        }
    }
    else if(scan==0x62)
    {
        toggle_button(dialog,HILFE,w);
        do_hilfe();
        toggle_button(dialog,HILFE,w);
    }
    else if(scan==0x61) return(FALSE);
    return(TRUE);
}/* wm_tast */

void gem_main(void)
/* ôffnet das Hauptfenster */
{
    static HWINDOW mw;
    
    mw.obj=dialog;
    mw.do_button=wm_button;
    mw.do_wtast=wm_tast;
    mw.end=TRUE;
    mw.kind=NAME|CLOSER|MOVER;
    mw.title=" Link V1.0 ";
    if(!open_window(&mw)) return;
    ps_win=mw.nr;
    loop();
} /* gem_main */

void init_dialog(void)
/* Initiallisiert unsere Dialoge */
{
    int i;
    
    dialog=rs_trindex[DIALOG];
    help  =rs_trindex[HELP];
    info  =rs_trindex[EINFO];
    meldung=rs_trindex[MELDUNG];
    
    for(i=0;i<NUM_OBS;i++)
        rsrc_obfix(&rs_object[i],0);
} /* init_dialog */

void do_timer(void)
/* Wenn die Zeit gekommen ist..... */
{
}/* do_timer */

