/* AESDEMO.C
 *
 * Hauptteil
 *
 * Oktober 1992 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * FÅr's TOS-Magazin
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <portab.h>
#include <tos.h>
#include "new_aes.h"
#include "aesd.h"

#include "aesd_rsc.rh"
#include "aesd_rsc.rsh"

extern HWINDOW *win[MAX_WINDOW];    /* Zeiger auf die Fensterliste  */
extern int gl_hchar;                /* Die Hîhe der Buchstaben      */

static OBJECT *menu;                /* Die MenÅleiste               */
static OBJECT *dialog;              /* Der Hauptdialog              */
static OBJECT *info;                /* Der Informationdialog        */
static OBJECT *submen;              /* Die SUB/POPUP-MenÅs          */

static void do_info(void);          /* Ein Prototyp                 */


int handle_menu(int *buf)
/* Verwaltung der MenÅleiste                */
/* buf  ist der Nachrichtenbuffer des AES   */
{
    static MN_SET ms;
    int i;

    if(buf[3]==MT3)
    {
        /* Es werden die aktuellen Werte ausgelesen! */
        menu_settings(FALSE,&ms);
        
        switch(buf[4])
        {
            case DID0: case DID100: case DID200:case DID400: case DID500:
            for(i=DID0;i<=DID500;i++)menu_icheck(submen,i,FALSE);
            menu_icheck(submen,buf[4],TRUE);
            switch(buf[4])
            {
                case DID0:ms.Display=0;break;
                case DID100:ms.Display=100;break;
                case DID200:ms.Display=200;break;
                case DID400:ms.Display=400;break;
                case DID500:ms.Display=500;break;
            }
            
            case DRD0:case DRD1:case DRD2:case DRD5:case DRD10:
            for(i=DRD0;i<=DRD10;i++)menu_icheck(submen,i,FALSE);
            menu_icheck(submen,buf[4],TRUE);
            switch(buf[4])
            {   
                case DRD0:ms.Drag=0;break;
                case DRD1:ms.Drag=1000;break;
                case DRD2:ms.Drag=2000;break;
                case DRD5:ms.Drag=5000;break;
                case DRD10:ms.Drag=10000;break;
            }
            
            case CLD0:case CLD125:case CLD250:case CLD500:case CLD750:
            for(i=CLD0;i<=CLD750;i++)menu_icheck(submen,i,FALSE);
            menu_icheck(submen,buf[4],TRUE);
            switch(buf[4])
            {
                case CLD0:ms.Delay=0;break;
                case CLD125:ms.Delay=125;break;
                case CLD250:ms.Delay=250;break;
                case CLD500:ms.Delay=500;break;
                case CLD750:ms.Delay=750;break;
            }

            case SCD0:case SCD100:case SCD200:case SCD400:case SCD500:
            for(i=SCD0;i<=SCD500;i++)menu_icheck(submen,i,FALSE);
            menu_icheck(submen,buf[4],TRUE);
            switch(buf[4])
            {
                case SCD0:ms.Speed=0;break;
                case SCD100:ms.Speed=100;break;
                case SCD200:ms.Speed=200;break;
                case SCD400:ms.Speed=400;break;
                case SCD500:ms.Speed=500;break;
            }

            case SCH5:case SCH8:case SCH16:
            for(i=SCH5;i<=SCH16;i++)menu_icheck(submen,i,FALSE);
            menu_icheck(submen,buf[4],TRUE);
            switch(buf[4])
            {
                case SCH5:ms.Height=4;break;
                case SCH8:ms.Height=8;break;
                case SCH16:ms.Height=18;break;
            }
        }
        /* Die Werte werden gesetzt */
        menu_settings(TRUE,&ms);
    }
    else
    {
        switch(buf[4])
        {
            case MINFO: do_info(); break;
            case MENDE: return(FALSE);
            default:
                break;
        }
    }
    menu_tnormal(menu,buf[3],TRUE);
    return(TRUE);
}/* handle_menu */

int popup_button(OBJECT* bb,int b,OBJECT *o,int m,int i,int s)
/* ôffnet ein PopUp-MenÅ an einem Button    */
/* bb ist der Baum des Buttons              */
/* b  die Objektnummer des Buttons          */
/* o  der Baum des PopUp-MenÅs              */
/* m  die Objektnummer des PopUp-MenÅs      */
/* i  das start Objekt                      */
/* s  scrollen oder nicht.....              */
{
    int x,y;
    MENU m1,m2;
    
    m1.mn_tree=o;
    m1.mn_menu=m;
    m1.mn_item=i;
    m1.mn_scroll=s;

    objc_offset(bb,b,&x,&y);
    if(menu_popup(&m1,x,y,&m2))
        return(m2.mn_item);
    return(FALSE);
}/* popup_button */

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
    else if(scan==0x61)
    {
        close_window(win[w]->handle);
        return(!win[w]->end);
    }
    return(TRUE);
}/* al_tast */

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
        iw.title=" AESD / Info ";
        if(!open_window(&iw)) return;
    }
} /* do_info */

static int wm_button(int f,int w)
/* Button-Handler fÅr's Hauptfenster */
{

    if(f&0x8000)
    {
        f&=0x7fff;
    }

    switch(f)
    {
        case POPUP1:
            popup_button(dialog,f,submen,DPOPUP1,DPOPUP1+1,FALSE);
            break;
        case POPUP2:
            popup_button(dialog,f,submen,DPOPUP2,DPOPUP2+1,FALSE);
            break;
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
                do_info();        
                break;
            default:  break;
        }
    }
    else if(scan==0x61)
    {
        close_window(win[w]->handle);
        return(!win[w]->end);
    }
    return(TRUE);
}/* wm_tast */

void gem_main(void)
/* ôffnet das Hauptfenster */
{
    static HWINDOW mw;
    menu_bar(menu,TRUE);
    
    mw.obj=dialog;
    mw.do_button=wm_button;
    mw.do_wtast=wm_tast;
    mw.end=TRUE;
    mw.kind=NAME|CLOSER|MOVER;
    mw.title=" AES 4.0 ";
    if(!open_window(&mw)) return;
    loop();

    menu_bar(menu,FALSE);
} /* gem_main */

void init_dialog(void)
/* Initiallisiert unsere Dialoge */
{
    MENU md;
    MN_SET ms;
    int i;
    
    menu  =rs_trindex[MENU1];
    dialog=rs_trindex[DIALOG];
    info  =rs_trindex[EINFO];
    submen =rs_trindex[MENU2];
    
    if(gl_hchar<16) dialog[ROOT].ob_height+=dialog[TOS_LOGO].ob_height;

    for(i=0;i<NUM_OBS;i++)
        rsrc_obfix(&rs_object[i],0);
    
    md.mn_tree=submen;
    md.mn_menu=SUBM1;
    md.mn_item=SUBM1+1;
    md.mn_scroll=FALSE;
    menu_attach(TRUE,menu,MTEST1,&md);

    md.mn_tree=submen;
    md.mn_menu=SUBM2;
    md.mn_item=SUBM2+1;
    md.mn_scroll=TRUE;
    menu_attach(TRUE,menu,MTEST2,&md);

    md.mn_tree=submen;
    md.mn_menu=DIDELAY;
    md.mn_item=DIDELAY+1;
    md.mn_scroll=TRUE;
    menu_attach(TRUE,menu,MDIDELAY,&md);

    md.mn_tree=submen;
    md.mn_menu=DRDELAY;
    md.mn_item=DRDELAY+1;
    md.mn_scroll=TRUE;
    menu_attach(TRUE,menu,MDRDELAY,&md);

    md.mn_tree=submen;
    md.mn_menu=CLDELAY;
    md.mn_item=CLDELAY+1;
    md.mn_scroll=TRUE;
    menu_attach(TRUE,menu,MCLDELAY,&md);

    md.mn_tree=submen;
    md.mn_menu=SCDELAY;
    md.mn_item=SCDELAY+1;
    md.mn_scroll=TRUE;
    menu_attach(TRUE,menu,MSCDELAY,&md);

    md.mn_tree=submen;
    md.mn_menu=SCHEIGHT;
    md.mn_item=SCHEIGHT+1;
    md.mn_scroll=TRUE;
    menu_attach(TRUE,menu,MSCHEIGHT,&md);

    md.mn_tree=submen;
    md.mn_menu=DSUBM1;
    md.mn_item=DSUBM1+1;
    md.mn_scroll=TRUE;
    menu_attach(TRUE,submen,MPSUB,&md);

    ms.Display=200;
    ms.Drag=10000;
    ms.Delay=250;
    ms.Speed=0;
    ms.Height=5;
    
    menu_icheck(submen,DID200,TRUE);
    menu_icheck(submen,DRD10,TRUE);
    menu_icheck(submen,CLD250,TRUE);
    menu_icheck(submen,SCD0,TRUE);
    menu_icheck(submen,SCH5,TRUE);
    menu_settings(TRUE,&ms);

} /* init_dialog */

void do_timer(void)
/* Wenn die Zeit gekommen ist..... */
{
}/* do_timer */

