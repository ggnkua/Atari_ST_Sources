/* Coded in LAttice 5.52 */

/* All Code bits are Written by RoadKill (Christian G. Rountree)
 * This is free ware. use it as you please. this demonstrates how to 
 * put a dialog into a window (Floating Dialog) and interact with it
 *
 * Version 2 update 26 April 93
 *  	Bugs fixed thanks to Robert Gallagher's sharp eyes.
 *		I also added code to keep track of which window is on top.
 * 		with out it, the dialog will interfere with other windows
 *
 * This is the Floating Toolbox I use in a program that I may or may 
 * not release Share Ware (Meaning I get NO money). Please don't use
 * my tool box in your programs. Design your own!
 *
 *
 * Be carefull! If you allow the user to move the window far enough, 
 * the dialog will go off the screen, and Gem will crash!
 * 
 * You can contact me on Genie at C.ROUNTREE2, or on the Forum Net
 * in the programming forums.
 */

#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <fltdialg.h>

int Redraw_wind(short,GRECT *); void Quit();
short WORK_OUT[58],HANDLE;
short WTOP; /* this variable keeps track of which window is on top */
int W_HANDLE;
short W_X=150,W_Y=50,W_W,W_H,FX,FY,FW,FH;
int AP_ID; /* APPLICATION ID */
short wc,hc,xc,yc,PXYARRAY[8],P[8],JUNK,old=TLDRAW;
short WORK_IN[11] = {1,1,1,1,1,1,1,1,1,1,2};
OBJECT *ADDR, *MENU_ADDR, *TOOLADDR;
short MSG[10]; /* message pipe */


void main()
{
	AP_ID=appl_init();		/* start AES */
	HANDLE=graf_handle(&wc, &hc, &JUNK, &JUNK);	/* find AES handle */
	v_opnvwk(WORK_IN, &HANDLE, WORK_OUT);			/* open workstation */

	graf_mouse(0,0); /* arrow */

	if(!rsrc_load("FLTDIALG.RSC")){ /* load resource */
	 		form_alert(1,"[1][||Can't find Pencil.RSC][OK]");
			Quit(); /* bye!! */
			}
	
	rsrc_gaddr(R_TREE,TOOLFORM,&TOOLADDR);
	form_center(TOOLADDR,&W_X,&W_Y,&W_W,&W_H); /* calc tool window */
	wind_calc(WC_BORDER,NAME|MOVE,W_X,W_Y,W_W,W_H,&W_X,&W_Y,&W_W,&W_H);
	W_HANDLE=wind_create(NAME|MOVE,W_X,W_Y,W_W,W_H);
	if(!W_HANDLE){ form_alert(1,"[1][Can't open Window!Close something, and|try again][OK]"); Quit();};

	/*	Wind title is specific to LAttice C. It sets the Window Title 
 	 *  without the messy long conversion to two words
 	 */
	wind_update(BEG_UPDATE); /* pause system AES draws */
	wind_title(W_HANDLE,"Look Ma! Floating Dialog!"); 
	wind_open(W_HANDLE,W_X,W_Y,W_W,W_H); /* Open Window */
	wind_calc(WC_WORK,NAME|MOVE,W_X,W_Y,W_W,W_H,&xc,&yc,&wc,&hc); /* Calc work area */
	TOOLADDR->ob_x = xc;	/* relocate object */
	TOOLADDR->ob_y = yc;	
	objc_draw(TOOLADDR,0,MAX_DEPTH,xc,yc,wc,hc); /* Draw dialog */

	wind_update(END_UPDATE); /* Re-instate AES */
	
	





while(1){/********   main loop *********************/
short x,y,button,temp,a;

button=0; MSG[0]=0;
evnt_multi(MU_BUTTON | MU_MESAG,1,0,1,0,0,0,0,0,0,0,0,0,0,MSG,0,0,&x,&y,&button,&JUNK,&JUNK,&JUNK);

	if(button==1)
	if(W_HANDLE==wind_find(x,y)){
			wind_get(HANDLE,WF_TOP,&WTOP,0,0,0); /* get current window */
			temp=objc_find(TOOLADDR,ROOT,MAX_DEPTH,x,y);
			if(temp != -1 && WTOP==W_HANDLE){  /* if nothing clicked */

			switch(temp){
			case TLLINE:
					objc_change(TOOLADDR,old,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLLINE,0,xc,yc,wc,hc,1,1);
					old=TLLINE;
					break;
			case TLCLINE:
					objc_change(TOOLADDR,old,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLCLINE,0,xc,yc,wc,hc,1,1);
					old=TLCLINE;
					break;
			case TLBOX:
					objc_change(TOOLADDR,old,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLBOX,0,xc,yc,wc,hc,1,1);
					old=TLBOX;
					break;
			case TLFBOX:
					objc_change(TOOLADDR,old,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLFBOX,0,xc,yc,wc,hc,1,1);
					old=TLFBOX;
					break;
			case TLDRAW:
					objc_change(TOOLADDR,old,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLDRAW,0,xc,yc,wc,hc,1,1);
					old=TLDRAW;
					break;
			case TLFILL:
					objc_change(TOOLADDR,old,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLFILL,0,xc,yc,wc,hc,1,1);
					old=TLFILL;
					break; 
			case TLCIRCLE:
					objc_change(TOOLADDR,old,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLCIRCLE,0,xc,yc,wc,hc,1,1);
					old=TLCIRCLE;
					break;
			case TLOVAL:
					objc_change(TOOLADDR,old,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLOVAL,0,xc,yc,wc,hc,1,1);
					old=TLOVAL;
					break; 
			case TLADD:
					objc_change(TOOLADDR,TLADD,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[0][|ADDA FRAME!][PRESS HERE]");
					objc_change(TOOLADDR,TLADD,0,xc,yc,wc,hc,0,1);
					break;
			case TLDELETE:
					objc_change(TOOLADDR,TLDELETE,0,xc,yc,wc,hc,1,1);			
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][Kill Frame with|extreme prejudice][*BANG*]");
					objc_change(TOOLADDR,TLDELETE,0,xc,yc,wc,hc,0,1);
					break;
			case TLGOTO:
					objc_change(TOOLADDR,TLGOTO,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][|WOW! Goto frame!|Wheeeeeee][Sigh]");
					objc_change(TOOLADDR,TLGOTO,0,xc,yc,wc,hc,0,1);
					break;
			case TLPLAY:
					objc_change(TOOLADDR,TLPLAY,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][|Play?!?|How about|Monopoly?][SURE!]");
					objc_change(TOOLADDR,TLPLAY,0,xc,yc,wc,hc,0,1);
					break;
			case TLCLEAR:
					objc_change(TOOLADDR,TLCLEAR,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][Nada on the|screen now!][GREAT!]");
					objc_change(TOOLADDR,TLCLEAR,0,xc,yc,wc,hc,0,1);
					break;
			case TLQUIT:
					objc_change(TOOLADDR,TLQUIT,0,xc,yc,wc,hc,1,1);
					a=form_alert(1,"[2][Are you sure you|want to quit??][Yes|Cancel]");
					if(a==1) Quit();			
					objc_change(TOOLADDR,TLQUIT,0,xc,yc,wc,hc,0,1);
					break;
			case TLWHITE:
					objc_change(TOOLADDR,TLBLACK,0,xc,yc,wc,hc,0,1);
					objc_change(TOOLADDR,TLWHITE,0,xc,yc,wc,hc,1,1);
					break;
			case TLBLACK:
					objc_change(TOOLADDR,TLBLACK,0,xc,yc,wc,hc,1,1);
					objc_change(TOOLADDR,TLWHITE,0,xc,yc,wc,hc,0,1);
					break;
			case TLFORWARD:
					objc_change(TOOLADDR,TLFORWARD,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					objc_change(TOOLADDR,TLFORWARD,0,xc,yc,wc,hc,0,1);
					break;
			case TLBACK:
					objc_change(TOOLADDR,TLBACK,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					objc_change(TOOLADDR,TLBACK,0,xc,yc,wc,hc,0,1);
					break;
			case TLCUT:
					objc_change(TOOLADDR,TLCUT,0,xc,yc,wc,hc,1,1);
					form_alert(1,"[1][How about your|Throat?][YEAH!!]");
					objc_change(TOOLADDR,TLCUT,0,xc,yc,wc,hc,0,1);
					break;
			case TLPASTE:
					objc_change(TOOLADDR,TLPASTE,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][Just click the|Damn button][GREAT!]");
					objc_change(TOOLADDR,TLPASTE,0,xc,yc,wc,hc,0,1);
					break;
			case TLSET:
					objc_change(TOOLADDR,TLSET,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][Settings][Aye]");
					objc_change(TOOLADDR,TLSET,0,xc,yc,wc,hc,0,1);
					break;	
			case TLSAVE:
					objc_change(TOOLADDR,TLSAVE,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][HELP][Saving..]");
					objc_change(TOOLADDR,TLSAVE,0,xc,yc,wc,hc,0,1);
					break;
			case TLLOAD:
					objc_change(TOOLADDR,TLLOAD,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][Load function][yea]");
					objc_change(TOOLADDR,TLLOAD,0,xc,yc,wc,hc,0,1);
					break;
			case TLNEW:
					objc_change(TOOLADDR,TLNEW,0,xc,yc,wc,hc,1,1);
					while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
					form_alert(1,"[1][Nothing is new|anymore][Yep]");
					objc_change(TOOLADDR,TLNEW,0,xc,yc,wc,hc,0,1);
					break;
				} /* end switch */
				/* you need this for safety! */
			while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
			}/* end second if */
		else while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
		}/* end first if */	
		while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 

switch(MSG[0]){  /* HANDLE MESSAGE EVENTS */
	case WM_MOVED:
		if(MSG[3]==W_HANDLE){
/* -2 and -12 on this to makes sure dialog doesn't leave screen */

			W_X=min(MSG[4],WORK_OUT[0]-2); W_Y=min(MSG[5],WORK_OUT[1]-12);
			wind_set(W_HANDLE,WF_CXYWH,W_X,W_Y,W_W,W_H);
			wind_calc(WC_WORK,NAME|MOVE,W_X,W_Y,W_W,W_H,&xc,&yc,&wc,&hc);
			TOOLADDR->ob_x = xc;	/* relocate object */
			TOOLADDR->ob_y = yc;	
			}
		break;
	case WM_REDRAW:
		if(MSG[3]==W_HANDLE){
		/* The Wind Redraw function is specific to Lattice 5!
		 * It's very cool. It takes care of calculating the 
		 * Areas to redraw!
		 */
		 	wind_update(BEG_UPDATE); /* Stop AES draws */
			wind_redraw(W_HANDLE,(GRECT *)&MSG[4],(void*)Redraw_wind);
			wind_update(END_UPDATE); /* restart AES */
		   	}
		break;
	case WM_TOPPED:
		if(MSG[3]=W_HANDLE){
		/* if window moved to top, then top window! */
			wind_set(W_HANDLE,WF_TOP,W_X,W_Y,W_W,W_H);
			}
		break;
	}/* end switch */




	} /* end while */


}/* end main */


/********************************************************/

void Quit(void)
{
short x,y,button=2;

	while(button!=0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
	v_hide_c(HANDLE); /* hide mouse */
	v_clrwk(HANDLE); /* clear screen */
	rsrc_gaddr(R_TREE,FORM2,&TOOLADDR);
	form_center(TOOLADDR,&W_X,&W_Y,&W_W,&W_H); /* calc tool window */
	objc_draw(TOOLADDR,0,MAX_DEPTH,W_X,W_Y,W_W,W_H);
	v_show_c(HANDLE,1); /* draw mouse */
	while(button==0) evnt_button(1,2,0,&x,&y,&button,&JUNK); 
	v_clsvwk(HANDLE);
	wind_delete(W_HANDLE);
	exit(0); /* bye!! */
	
} /* end quit */	

/****************************************/
int Redraw_wind	(short handle, GRECT *r)
{
	/* system passes rectangle. This draws it by doing object and clipping with passed box */
	objc_draw(TOOLADDR,0,MAX_DEPTH,r->g_x,r->g_y,r->g_w,r->g_h);
	return(1);
}
