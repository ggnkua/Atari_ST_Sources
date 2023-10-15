/* COL_ICON.C
 *
 * Hauptteil
 *
 * MÑrz 1993 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * FÅr's TOS-Magazin
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <portab.h>
#include <tos.h>
#include "new_aes.h"
#include "col_icon.h"
#include "ci_rsc.h"

extern HWINDOW *win[MAX_WINDOW];    /* Zeiger auf die Fensterliste  */
extern int gl_hchar;				/* Die Hîhe der Buchstaben		*/

static OBJECT *menu,*dialog,*info;
static int main_win,speed=5;

static void do_info(void);


int handle_menu(int *buf)
/* Verwaltung der MenÅleiste				*/
/* buf	ist der Nachrichtenbuffer des AES	*/
{
	switch(buf[4])
	{
		case MINFO: do_info(); break;
		case MENDE: return(FALSE);
		default:
			break;
	}
	menu_tnormal(menu,buf[3],TRUE);
	return(TRUE);
}/* handle_menu */

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

static void set_slider(OBJECT *o,int v,int s,int g,int a)
{
	long hv;
	
	hv=o[v].ob_height-o[s].ob_height;

	if(!g) o[s].ob_y=0;
	else o[s].ob_y=(int)((((hv*1000L)/a)*g)/1000L);
	sprintf(o[s].ob_spec.free_string,"%i",g);
}/* set_slider */

static int slide_it(OBJECT *o,int v, int s, int d, int w)
{
	int i;
	
	o[s].ob_state|=SELECTED;
	draw_obj(o,s,1,w);
	i=graf_slidebox(o,v,s,d);
	o[s].ob_state&=~SELECTED;
	return(i);
}/* slide_it */

static int vater_click(OBJECT *o,int s,int w)
{
	int vx,vy,mx,my,d;
	
	graf_mkstate(&mx,&my,&d,&d); 
	objc_offset(o,s,&vx,&vy);
	if(my<vy) return(-w);
	return(w);
}/* vater_click */

static int wm_button(int f,int w)
/* Button-Handler fÅr's Hauptfenster */
{

    f&=0x7fff;

    switch(f)
    {
    	
		case S_SOHN: case S_VATER:
			if(f==S_SOHN)speed=(int)((long)slide_it(dialog,S_VATER,S_SOHN,1,w)*15L/1000L);
			else speed+=vater_click(dialog,S_SOHN,1);
			if(speed<0) speed=0;
			if(speed>9) speed=9;
			set_slider(dialog,S_VATER,S_SOHN,speed,9);
			draw_obj(dialog,S_VATER,MAX_DEPTH,w);
			return(TRUE);
		case D_INFO:
			do_info();
			break;		
		case D_OKAY:
		    dialog[f].ob_state &= ~SELECTED;
		    return(FALSE);
		default:
			break;	
    }
    dialog[f].ob_state &= ~SELECTED;
    draw_obj(dialog,f,1,w);
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
    else if(scan==0x48 || scan==0x50)
    {
			if(scan==0x50) speed++;
			else speed--;
			if(speed<0) speed=0;
			if(speed>9) speed=9;
			set_slider(dialog,S_VATER,S_SOHN,speed,9);
			draw_obj(dialog,S_VATER,MAX_DEPTH,w);
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
    mw.title=" Farb-Icons ";
    if(!open_window(&mw)) return;
    main_win=mw.nr;
    loop();
    menu_bar(menu,FALSE);
} /* gem_main */

void init_dialog(void)
{
 	rsrc_gaddr(0,MENU1,&menu);
 	rsrc_gaddr(0,DIALOG,&dialog);
 	rsrc_gaddr(0,EINFO,&info);
 	dialog[COLICN2].ob_flags |= HIDETREE; 
 	dialog[COLICN1].ob_flags &=~HIDETREE; 
 	dialog[COLICN1].ob_y=dialog[COLICN2].ob_y;
	set_slider(dialog,S_VATER,S_SOHN,speed,9);
}/* init_dialog */

void do_timer(void)
/* Wenn die Zeit gekommen ist..... */
{
	static int tick=0;
	static int count=0;

	if(!speed) return;
	if(count<(9-speed))
	{
		if(++count>9) count=0;
		return;
	}
	count=0;

	switch(tick)
	{
		case 0:
 			dialog[COLICN2].ob_flags |= HIDETREE; 
 			dialog[COLICN1].ob_flags &=~HIDETREE; 
 			dialog[COLICN1].ob_state &=~SELECTED; 
 			dialog[COLICN2].ob_state &=~SELECTED; 
			break;
		case 1:
 			dialog[COLICN2].ob_flags &=~HIDETREE; 
 			dialog[COLICN1].ob_flags |= HIDETREE; 
 			dialog[COLICN1].ob_state &=~SELECTED; 
 			dialog[COLICN2].ob_state &=~SELECTED; 
			break;
		case 2:
 			dialog[COLICN2].ob_flags &=~HIDETREE; 
 			dialog[COLICN1].ob_flags |= HIDETREE; 
 			dialog[COLICN1].ob_state &=~SELECTED; 
 			dialog[COLICN2].ob_state |= SELECTED; 
			break;
		case 3:
 			dialog[COLICN2].ob_flags |= HIDETREE; 
 			dialog[COLICN1].ob_flags &=~HIDETREE; 
 			dialog[COLICN1].ob_state |= SELECTED; 
 			dialog[COLICN2].ob_state &=~SELECTED; 
			break;
		default:
			 break;
	}
 	if(dialog[COLICN1].ob_flags & HIDETREE)	draw_obj(dialog,COLICN2,1,main_win);
	else draw_obj(dialog,COLICN1,1,main_win);
	if(++tick>3) tick=0;
}/* do_timer */

