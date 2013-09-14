/*********************************************************************/
/* CONTROL PANEL	 					     */
/*	started 4/1/85 R.Z.   Copyright ATARI Corp. 1985	     */
/* 	Clawed back to life after multiple anonymous butchers ..     */
/*	No Gaurantees for Nationalities beyond FRENCH.		     */
/*	    3/6/89  R.Z.					     */
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES						     */
/*********************************************************************/

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"

/*********************************************************************/
/* INTERNATIONAL VERSION FLAGS					     */
/*********************************************************************/

#define	USA	TRUE
#define	UK	FALSE
#define	GERMAN	FALSE
#define	ITALY	FALSE
#define	FRENCH	FALSE

#define	SPAIN	FALSE
#define	SWEDEN	FALSE
#define FINLAND	FALSE
#define NORWAY	FALSE	/* NORWEGIAN translation NOV. 1987 J.P. */
#define	TURKEY	FALSE
#define DENMARK FALSE	/* Last updated 1/7/88 J.P. */
#define ARABIC	FALSE	/* The Mad Arab .. 2/23/88  A.A. */

/*********************************************************************/
/* RESOURCE FILE						     */
/*********************************************************************/

#include "ctrl.rsc"

/*********************************************************************/
/* DEFINES						   	     */
/*********************************************************************/

#define WI_KIND	(NAME | CLOSER | MOVER)	/* window kind */

#define CR	13

#define OLD	0
#define NEW	1
#define ST_COLOR 0
#define ST_MOUSE 48
#define ST_BELL 49
#define ST_CLICK 50
#define ST_IRPT 51
#define ST_KRPT 52
#define NUM_STATES 53

#define NO_WINDOW (-1)
#define	REDRAW		1

#define	FAT	(0x020000L)

#define RMIX_POS (ctrl_objs[RMIX_SL].ob_y)
#define GMIX_POS (ctrl_objs[GMIX_SL].ob_y)
#define BMIX_POS (ctrl_objs[BMIX_SL].ob_y)
#define IRPT_POS (ctrl_objs[IRPT_SL].ob_x)
#define KRPT_POS (ctrl_objs[KRPT_SL].ob_x)
#define IIMG_POS (ctrl_objs[IRPT_MG].ob_x)
#define KIMG_POS (ctrl_objs[KRPT_MG].ob_x)

#define BUFSIZE	128
#define NEWMSG	99

/*********************************************************************/
/* EXTERNALS						   	     */
/*********************************************************************/

extern int	gl_apid;
extern int	donoise();
extern int	set_state();
extern int	val_slider();

/*********************************************************************/
/* GLOBAL VARIABLES					   	     */
/*********************************************************************/

int	gl_xclip;
int	gl_yclip;
int	gl_wclip;
int	gl_hclip;
int	gl_hchar;
int	gl_wchar;
int	gl_wbox;
int	gl_hbox;

int 	ctrl_id ;	/* control id */
int 	prtr_id ;	/* printer id */

int 	phys_handle;	/* physical workstation handle */
int 	handle;		/* virtual workstation handle */
int	wi_handle;	/* window handle */
int	top_window;	/* handle of topped window */
int	msgbuff[8];	/* event message buffer */
int	ret;		/* dummy return variable */
int	xdesk,ydesk,hdesk,wdesk;
int	xwind,ywind,hwind,wwind;
int	xwork,ywork,hwork,wwork;
int	mx,my;
int	num_colors;	/* number of colors in the current mode */

int	contrl[11];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];
int	work_in[11];	/* Input to GSX parameter array */
int 	work_out[57];	/* Output from GSX parameter array */
int	pxyarray[10];	/* input point array */

int	rgb[3];		/* temporary array for GSX color commands */
int	butdown;	/* button state tested for, UP/DOWN */
int 	color;		/* active color register */
int	year,month,day,hour,minute;	/* current date values */

int 	state[2][NUM_STATES];		/* control panel state, old & new */
int	rmix_val,gmix_val,bmix_val;	/* individual mixer values */

int	mix_max;	/* Maximum Color mixer value (7 or 15) */
int	mix_high;	/* Height of a mixer step (142 or 66) */
int	mix_slot;	/* Length of a shade (125 or 62) */

int	prtr_hi;	/* changeable shadow for PRTR_HI */
int	ctrl_hi;	/* changeable shadow for CTRL_HI */

char	config[6];
char	buffer[BUFSIZE];	/* buffer for Shell-get */
int	keycode;		/* keycode returned by event-keyboard */

char	baudvar;	/* baud number selected */
char	rsave[6];	/* 9600, full, no parity, 8 bits, none */	

#if ARABIC
char    *baudstr[] = { "±¹²°°","¹¶°°","´¸°°","³¶°°","²´°°","²°°°","±¸°°",
                        "±²°°","¶°°","³°°","²°°","±µ°","±³´","±±°","·µ","µ°"};
#else
char	*baudstr[] = { "19200","9600","4800","3600","2400","2000","1800",
			"1200","600","300","200","150","134","110","75","50"};
#endif

char	remap[] = {4,0,1,5,6,7,8,2,9,3,10,11,12,13,14,15};
char	remap2[] = {1,2,7,9,0,3,4,5,6,8,10,11,12,13,14,15};

/****************************************************************/
/*  GSX UTILITY ROUTINES.					*/
/****************************************************************/
/* open virtual workstation					*/
/****************************************************************/
open_vwork()
{
int i;
	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
	num_colors = work_out[13];
	if(work_out[39] <= 512) {
		mix_max=7;
		mix_high=142;
		mix_slot=125; }
	else {
		mix_max=15;
		mix_high=66;
		mix_slot=62; }
}

/****************************************************************/
/* open window							*/
/****************************************************************/
open_window()
{
	wi_handle=wind_create(WI_KIND,xdesk,ydesk,wdesk,hdesk);

#if USA | UK | ITALY
	wind_set(wi_handle, WF_NAME," CONTROL PANEL ", 0, 0);
#endif
#if GERMAN
	wind_set(wi_handle, WF_NAME," KONTROLLFELD ", 0, 0);
#endif
#if FRENCH
	wind_set(wi_handle, WF_NAME," PANNEAU CONTROLE ", 0, 0);
#endif
#if SPAIN
	wind_set(wi_handle, WF_NAME," PANEL DE CONTROL ", 0, 0);
#endif
#if TURKEY
	wind_set(wi_handle, WF_NAME," KONTROL PANEL\235 ", 0, 0);
#endif
#if SWEDEN
	wind_set(wi_handle, WF_NAME," INST\216LLNINGAR ", 0, 0);
#endif
#if FINLAND
	wind_set(wi_handle, WF_NAME," S\204\204timet ", 0, 0);
#endif
#if NORWAY
	wind_set(wi_handle, WF_NAME," Kontrollfelt ", 0, 0);
#endif
#if DENMARK
	wind_set(wi_handle, WF_NAME," Kontrolpanel ", 0, 0);
#endif
#if ARABIC
        wind_set(wi_handle, WF_NAME," ñþÖÆÃ×Á õþÆÛ× ", 0, 0);
#endif

	wind_calc(WC_BORDER,WI_KIND,xdesk,ydesk,CTRL_WID,ctrl_hi,&xwind,&ywind,&wwind,&hwind);

	xwind+=(wdesk-wwind)/2;
	ywind+=(hdesk-hwind+16+4)/2;	/* RMS 4 to center on screen rs232 button */

	wind_open(wi_handle,xwind,ywind,wwind,hwind);
	graf_growbox(xwind+wwind/2,ywind+hwind/2,36,36,xwind,ywind,wwind,hwind);
}

/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/
do_redraw(object,xc,yc,wc,hc)
int object,xc,yc,wc,hc;
{
int x,y,w,h;
GRECT t1,t2;

	wind_get(wi_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	while (w && h) {
	  t1.g_x=x;
	  t1.g_y=y;
	  t1.g_w=w;
	  t1.g_h=h;
	  if (rc_intersect(&t2,&t1))
	    objc_draw(ctrl_objs,object,MAX_DEPTH,t1.g_x,t1.g_y,t1.g_w,t1.g_h);
	  wind_get(wi_handle,WF_NEXTXYWH,&x,&y,&w,&h);
	}
	pxyarray[0]=xwork;
	pxyarray[1]=ywork;
	pxyarray[2]=xwork+wwork-1;
	pxyarray[3]=ywork+hwork-1;
	vs_clip(handle,1,pxyarray);	/* set clipping */
}



/****************************************************************/
/* Sends the rs232 configuration to the vt52			*/
/* via the aes message (pipe?) system.				*/
/****************************************************************/
send_msg()
{
int	id,i;

	id = appl_find("EMULATOR");

	if(id != -1) {		/* there is a vt52 out there */
		msgbuff[0] = NEWMSG;
		for(i=0; i<=STBIT; i++) msgbuff[i+1] = rsave[i];
		appl_write(id,16,msgbuff);
		}
}

/****************************************************************/
/*		Accessory Init. Until First Event_Multi		*/
/****************************************************************/
main()
{
int i;

	appl_init();
	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);

	prtr_hi=PRTR_HI;
	ctrl_hi=CTRL_HI;

	if(gl_hchar>8){				/* HIGH RES */
		for(i=1;i<NUM_POBJS;i++){	/* adjust printer rsc */
			prnt_objs[i].ob_y *= 2;
			prnt_objs[i].ob_height *= 2;
		}
		for(i=0;i<NUM_RSOBJ;i++) { 	/* adjust rs232 configure rsc */
			   rs_objs[i].ob_height *= 2;
			   rs_objs[i].ob_y *= 2;
		}
		ctrl_objs[PRINTER].ob_height *=2; /* adjust printer button */
		prtr_hi *= 2;
		ctrl_objs[RS232].ob_height *=2;   /* adjust rs232 button */
		ctrl_hi += gl_hchar;		  /* adj height */
	}

	ctrl_objs[CROOT].ob_height=ctrl_hi;  /* set panel height */
	prnt_objs[CROOT].ob_height=prtr_hi;

	if(ctrl_obj[RMIX_SL].ob_height < gl_hchar)     /* text too large...   */
	{					       /* so switch to smaller*/
	    ctrl_objs[RMIX_SL].ob_spec->te_font = 5;   /* font*/
	    ctrl_objs[GMIX_SL].ob_spec->te_font = 5;
	    ctrl_objs[BMIX_SL].ob_spec->te_font = 5;
	    ctrl_objs[RTOP].ob_spec->te_font = 5;
	    ctrl_objs[GTOP].ob_spec->te_font = 5;
	    ctrl_objs[BTOP].ob_spec->te_font = 5;
	    ctrl_objs[RBOT].ob_spec->te_font = 5;
	    ctrl_objs[GBOT].ob_spec->te_font = 5;
	    ctrl_objs[BBOT].ob_spec->te_font = 5;
	}


#if USA | UK
	ctrl_id=menu_register(gl_apid,"  Control Panel");
#endif
#if GERMAN
	ctrl_id=menu_register(gl_apid,"  Kontrollfeld");
#endif
#if ITALY
	ctrl_id=menu_register(gl_apid,"  Control Panel");
#endif
#if FRENCH
	ctrl_id=menu_register(gl_apid,"  Panneau Controle");
#endif
#if SPAIN
	ctrl_id=menu_register(gl_apid,"  Panel de Control");
#endif
#if TURKEY
	ctrl_id=menu_register(gl_apid,"  Kontrol Paneli");
#endif
#if SWEDEN
	ctrl_id=menu_register(gl_apid,"  Inst\204llningar");
#endif
#if FINLAND
	ctrl_id=menu_register(gl_apid,"  S\204\204timet");
#endif
#if NORWAY
	ctrl_id=menu_register(gl_apid,"  Kontrollfelt");
#endif
#if DENMARK
	ctrl_id=menu_register(gl_apid,"  Kontrolpanel");
#endif
#if ARABIC
        ctrl_id=menu_register(gl_apid,"  ñþÖÆÃ×Á õþÆÛ×");
#endif

	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	wi_handle = NO_WINDOW;	/* accessory not opened yet */
	butdown=TRUE;
	color=0;

	open_vwork();
	read_in();		/* read in desktop.inf */
	set_up();		/* read & implement default settings */

	v_clsvwk(handle);
	set_bios();
        set_state();		/* jam MS RS232 values into hardware */
	multi();
}

/****************************************************************/
/* dispatches all accessory tasks				*/
/****************************************************************/
multi()
{
int event,obj_over;
int i,temp;
int x,y,w,h;

      while (TRUE) {
	event = evnt_multi(MU_MESAG | MU_BUTTON | MU_TIMER | MU_KEYBD,
			1,1,butdown,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuff,30000,0,&mx,&my,&ret,&ret,&keycode,&ret);

	wind_update(TRUE);		/* Lowell sez */

	wind_get(wi_handle,WF_TOP,&top_window,&ret,&ret,&ret);

	if (event & MU_TIMER){
		get_time();		/* get  GEMDOS time/date */
		show_time();
		if(wi_handle == top_window){
		   objc_draw(ctrl_objs, TIME, 1,xwork,ywork,wwork,hwork);
		   objc_draw(ctrl_objs, DATE, 1,xwork,ywork,wwork,hwork);
		}else
		   if(wi_handle != NO_WINDOW){
			do_redraw(TIME,xwork+ctrl_objs[TIME].ob_x,ywork+ctrl_objs[TIME].ob_y,ctrl_objs[TIME].ob_width,ctrl_objs[TIME].ob_height);
			do_redraw(DATE,xwork+ctrl_objs[DATE].ob_x,ywork+ctrl_objs[DATE].ob_y,ctrl_objs[DATE].ob_width,ctrl_objs[DATE].ob_height);
		   }
	}

	if (event & MU_MESAG)
	  switch (msgbuff[0]) {

	  case NEWMSG:		/* vt52 calling in */
		for(i=0; i<=STBIT; i++)	rsave[i] = (char) msgbuff[i+1];
		baudvar = remap2[rsave[BAUD]];	/* init baud variable */
		break;

	  case WM_REDRAW:
	    if (msgbuff[3] == wi_handle)
	      do_redraw(0,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
	    break;

	  case WM_NEWTOP:
	  case WM_TOPPED:
	    if (msgbuff[3] == wi_handle){
	      wind_set(wi_handle,WF_TOP,0,0,0,0);
		}
	    break;

	  case AC_CLOSE:
	    if((msgbuff[3] == ctrl_id)&&(wi_handle != NO_WINDOW)){
	      out_control();
	      v_clsvwk(handle);
	      wi_handle = NO_WINDOW;
	    }
	    break;

	  case WM_CLOSED:
	    if(msgbuff[3] == wi_handle){
	      out_control();
	      wind_close(wi_handle);
	      graf_shrinkbox(xwork+wwork/2,ywork+hwork/2,gl_wbox,gl_hbox,xwork,ywork,wwork,hwork);
	      wind_delete(wi_handle);
	      v_clsvwk(handle);
	      wi_handle = NO_WINDOW;
	    }
	    break;

	  case WM_MOVED:
	    if(msgbuff[3] == wi_handle){
	      wind_set(wi_handle,WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
	      wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	      ctrl_objs[ROOT].ob_x = xwork;
	      ctrl_objs[ROOT].ob_y = ywork;
	    }
	    break;

	  case AC_OPEN:
	    if (msgbuff[4] == ctrl_id){
	      set_state();		/* jam MS RS232 values into hardware */
	      if(wi_handle == NO_WINDOW){
		open_vwork();
		set_up();
		get_time();
		show_time();
	        open_window();
	        wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	        ctrl_objs[ROOT].ob_x = xwork;
	        ctrl_objs[ROOT].ob_y = ywork;
	      }
	      else	/* if already opened, for user convenience */
	        wind_set(wi_handle,WF_TOP,0,0,0,0);
	    }

	  } /* switch (msgbuff[0]) */

	if ((event & MU_BUTTON)&&(wi_handle == top_window))
	  if(butdown)
	   switch(obj_over = objc_find(ctrl_objs, 0, MAX_DEPTH, mx, my)){
	   case RMIX_SL:
		rmix_val = min(((1000 - graf_slidebox(ctrl_objs,RMIX,RMIX_SL,1))/mix_slot),mix_max);
		do_slider(rmix_val,RMIX,rmix_str,&RMIX_POS);
		setcolor();
		break;
	   case GMIX_SL:
		gmix_val = min(((1000 - graf_slidebox(ctrl_objs,GMIX,GMIX_SL,1))/mix_slot),mix_max);
		do_slider(gmix_val,GMIX,gmix_str,&GMIX_POS);
		setcolor();
		break;
	   case BMIX_SL:
		bmix_val = min(((1000 - graf_slidebox(ctrl_objs,BMIX,BMIX_SL,1))/mix_slot),mix_max);
		do_slider(bmix_val,BMIX,bmix_str,&BMIX_POS);
		setcolor();
		break;
	   case RBOT:
		rmix_val = max((rmix_val - 1),0);
		do_slider(rmix_val,RMIX,rmix_str,&RMIX_POS);
		setcolor();
		butdown = FALSE;
		break;
	   case RTOP:
		rmix_val = min((rmix_val + 1),mix_max);
		do_slider(rmix_val,RMIX,rmix_str,&RMIX_POS);
		setcolor();
		butdown = FALSE;
		break;
	   case GBOT:
		gmix_val = max((gmix_val - 1),0);
		do_slider(gmix_val,GMIX,gmix_str,&GMIX_POS);
		setcolor();
		butdown = FALSE;
		break;
	   case GTOP:
		gmix_val = min((gmix_val + 1),mix_max);
		do_slider(gmix_val,GMIX,gmix_str,&GMIX_POS);
		setcolor();
		butdown = FALSE;
		break;
	   case BBOT:
		bmix_val = max((bmix_val - 1),0);
		do_slider(bmix_val,BMIX,bmix_str,&BMIX_POS);
		setcolor();
		butdown = FALSE;
		break;
	   case BTOP:
		bmix_val = min((bmix_val + 1),mix_max);
		do_slider(bmix_val,BMIX,bmix_str,&BMIX_POS);
		setcolor();
		butdown = FALSE;
		break;
	   case IRPT_MG:
	   case IRPT_SL:
		set_rept((horz_slider(IRPT,IRPT_BX,IRPT_SL,&IRPT_POS,&IIMG_POS)/22+1),state[NEW][ST_KRPT]);
		break;
	   case KRPT_SL:
	   case KRPT_MG:
		set_rept(state[NEW][ST_IRPT],(horz_slider(KRPT,KRPT_BX,KRPT_SL,&KRPT_POS,&KIMG_POS)/50+1));
		break;
	   case MBOX0:
	   case MBOX1:
	   case MBOX2:
	   case MBOX3:
	   case MBOX4:
		for(i=MBOX0; i<=MBOX4; i++)
		  if(ctrl_objs[i].ob_state & SELECTED)
		   objc_change(ctrl_objs,i,0,xwork,ywork,wwork,hwork,NORMAL,1);
		objc_change(ctrl_objs,obj_over,0,xwork,ywork,wwork,hwork,SELECTED,1);
		state[NEW][ST_MOUSE]=obj_over-MBOX0;
		evnt_dclick(obj_over-MBOX0,1);
		butdown = FALSE;
		break;
	   case DATE:
	   case TIME:
		if(graf_watchbox(ctrl_objs,obj_over,SELECTED,NORMAL)){
		  form_do(ctrl_objs,obj_over);
		  objc_change(ctrl_objs,TIME,0,xwork,ywork,wwork,hwork,NORMAL,1);
		  objc_change(ctrl_objs,DATE,0,xwork,ywork,wwork,hwork,NORMAL,1);
		  set_time();
		  get_time();
		  show_time();
		  objc_draw(ctrl_objs, TIME, 1,xwork,ywork,wwork,hwork);
		  objc_draw(ctrl_objs, DATE, 1,xwork,ywork,wwork,hwork);
		}
		break;
	   case CLICK:
		state[NEW][ST_CLICK] ^= 1;
		set_noise();
		objc_draw(ctrl_objs, CLICK_BX, 1,xwork,ywork,wwork,hwork);
		butdown = FALSE;
		break;
	   case BELL:
		state[NEW][ST_BELL] ^= 1;
		set_noise();
		objc_draw(ctrl_objs, BELL_BX, 1,xwork,ywork,wwork,hwork);
		butdown = FALSE;
		break;
	   case CANCEL:
		if(graf_watchbox(ctrl_objs,obj_over,SELECTED,NORMAL)){
		  set_up();
		  ctrl_objs[CANCEL].ob_state=NORMAL;
		  do_redraw(0,xwork,ywork,wwork,hwork);
		}
		break;
	   case CLR0:
	   case CLR1:
	   case CLR2:
	   case CLR3:
	   case CLR4:
	   case CLR5:
	   case CLR6:
	   case CLR7:
	   case CLR8:
	   case CLR9:
	   case CLRA:
	   case CLRB:
	   case CLRC:
	   case CLRD:
	   case CLRE:
	   case CLRF:
		color= obj_over - CLR0;
		vq_color(handle,color,1,rgb);
		rmix_val = rgb[0]/mix_high;
		do_slider(rmix_val,RMIX,rmix_str,&RMIX_POS);
		gmix_val = rgb[1]/mix_high;
		do_slider(gmix_val,GMIX,gmix_str,&GMIX_POS);
		bmix_val = rgb[2]/mix_high;
		do_slider(bmix_val,BMIX,bmix_str,&BMIX_POS);
		for(temp=CLR1; temp<=CLRF;temp++)
		   if(!(ctrl_objs[temp].ob_spec & FAT)){
			ctrl_objs[temp].ob_spec ^= FAT;
			objc_draw(ctrl_objs, temp, MAX_DEPTH,xwork,ywork,wwork,hwork);
		   };
		if(ctrl_objs[CLR0].ob_x == ctrl_objs[CLR1].ob_x){
		   ctrl_objs[CLR0].ob_spec &= 0xff0fffL;
		   objc_draw(ctrl_objs,CLR0,MAX_DEPTH,xwork,ywork,wwork,hwork);
		   ctrl_objs[CLR0].ob_x += 3;
		   ctrl_objs[CLR0].ob_y += 3;
		   ctrl_objs[CLR0].ob_width -= 6;
		   ctrl_objs[CLR0].ob_height  -= 6;
		   ctrl_objs[CLR0].ob_spec |= 0x01000L;
		   objc_draw(ctrl_objs,CLR0,MAX_DEPTH,xwork,ywork,wwork,hwork);
		}
		if(color) ctrl_objs[obj_over].ob_spec ^= FAT;
		else {
		   ctrl_objs[CLR0].ob_x=ctrl_objs[CLR1].ob_x;
		   ctrl_objs[CLR0].ob_y=ctrl_objs[CLR2].ob_y;
		   ctrl_objs[CLR0].ob_width=ctrl_objs[CLR1].ob_width;
		   ctrl_objs[CLR0].ob_height=ctrl_objs[CLR1].ob_height;
		}
		objc_draw(ctrl_objs, obj_over, MAX_DEPTH,xwork,ywork,wwork,hwork);
		butdown = FALSE;
		break;

	case RS232:
		ctrl_objs[RS232].ob_state=SELECTED;
		objc_draw(ctrl_objs,RS232,0,xwork,ywork,wwork,hwork);
		rsconfig();
		ctrl_objs[RS232].ob_state=NORMAL;
		objc_draw(ctrl_objs,RS232,0,xwork,ywork,wwork,hwork);
	  break;
	case PRINTER:
		ctrl_objs[PRINTER].ob_state=SELECTED;
		objc_draw(ctrl_objs,PRINTER,0,xwork,ywork,wwork,hwork);
		set_bios();
		for(i=1;i<NUM_POBJS;prnt_objs[i++].ob_state=NORMAL);
		for(i=0;i<6;i++)
		  prnt_objs[(config[i] + 8) + 3*i].ob_state=SELECTED;
		form_center(prnt_objs,&x,&y,&w,&h);
		prnt_objs[ROOT].ob_x = x+3;
		prnt_objs[ROOT].ob_y = y+3;
		form_dial(FMD_START,0,0,36,36,x,y,w,h);
		form_dial(FMD_GROW,0,0,36,36,x,y,w,h);
		objc_draw(prnt_objs, 0, MAX_DEPTH, x,y,w,h);
		if(form_do(prnt_objs,0) == OK){
		   for(i=0;i<6;i++)
		     config[i]=(prnt_objs[8+3*i].ob_state & SELECTED) ? 0 : 1;
		   set_bios();
		   out_print();
		}
		form_dial(FMD_SHRINK,0,0,36,36,x,y,w,h);
		form_dial(FMD_FINISH,0,0,36,36,x,y,w,h);
		ctrl_objs[PRINTER].ob_state=NORMAL;
		objc_draw(ctrl_objs,PRINTER,0,xwork,ywork,wwork,hwork);
	    break;
	   default:
		butdown = FALSE;
		break;
	   } /* switch (objc_find) */
	  else butdown = TRUE;


	  if((event & MU_KEYBD)&&((keycode & 0xff)==CR)){
	     set_up();
	     do_redraw(0,xwork,ywork,wwork,hwork);
	  }
	
	wind_update(FALSE);		/* Lowell sez */

      } /* while (TRUE) */

}


/****************************************************************/
/* REPOSITION & REDRAW SLIDER					*/
/****************************************************************/
do_slider(newval,parent,string,pos)
int parent,newval,*pos;
char *string;
{
	val_slider(newval,string);
	*pos = mul_div(((mix_max - newval) * (mix_high+1)),(HMIX-HSLDR),1000);
	objc_draw(ctrl_objs,parent,MAX_DEPTH,xwork,ywork,wwork,hwork);
}
/****************************************************************/
/* HORIZONTAL SLIDER						*/
/****************************************************************/
horz_slider(box,parent,slider,pos,imgpos)
int box,parent,slider,*pos,*imgpos;
{
int temp;
	temp = graf_slidebox(ctrl_objs,parent,slider,0);
	*pos = *imgpos = mul_div(temp,(WRPT-WSLDR),1000);
	objc_draw(ctrl_objs,box,MAX_DEPTH,xwork,ywork,wwork,hwork);
	return(temp);
}

/****************************************************************/
/* SET A COLOR							*/
/****************************************************************/
setcolor()
{
int i;
	rgb[0] = rmix_val*mix_high;
	rgb[1] = gmix_val*mix_high;
	rgb[2] = bmix_val*mix_high;
	vs_color(handle,color,rgb);
	for(i=0;i<3;i++) state[NEW][3*color+i]=rgb[i];
}

/****************************************************************/
/* Set desired keyboard repeat rates to BIOS.			*/
/****************************************************************/
set_rept(initial,repeat)
int initial,repeat;
{
	Kbrate(initial,repeat);		/* set kbrate */
	state[NEW][ST_IRPT]=initial;
	state[NEW][ST_KRPT]=repeat;
}

/****************************************************************/
/* Get current time/date from GEMDOS.				*/
/****************************************************************/
get_time()
{
int temp;
	temp=Tgettime();			/* get GEMDOS time */
	minute= (0x03f & (temp >> 5));
	hour= (0x01f & (temp >> 11));
	temp=Tgetdate();			/* get GEMDOS date */
	day= 0x01f & temp;
	month= (0x0f & (temp >> 5));
	year= ((0x07f & (temp >> 9))+80)%100;
}

/****************************************************************/
/* Convert time/date to displayed values.			*/
/****************************************************************/
show_time()
{

#if USA
	my_itoa(&date[0],month,TRUE);
	my_itoa(&date[2],day,TRUE);
	my_itoa(&date[4],year,FALSE);
#endif
#if SWEDEN|FINLAND|ARABIC
	my_itoa(&date[0],year,FALSE);
	my_itoa(&date[2],month,FALSE);
	my_itoa(&date[4],day,FALSE);
#endif
#if UK|GERMAN|FRENCH|ITALY|SPAIN|TURKEY|NORWAY|DENMARK
	my_itoa(&date[0],day,TRUE);
	my_itoa(&date[2],month,TRUE);
	my_itoa(&date[4],year,FALSE);
#endif

#if USA | UK
	my_itoa(&time[2],minute,0);
	if(hour) my_itoa(&time[0],((hour>12) ? hour-12 : hour),1);
	else my_itoa(&time[0],12,1);
	time[4] = (hour < 12) ? 'A' : 'P' ;
#else
	my_itoa(&time[2],minute,FALSE);
	my_itoa(&time[0],hour,TRUE);
#endif
}

/****************************************************************/
/* Set displayed date to IKBD and GEMDOS.			*/
/****************************************************************/
set_time()
{
int miltime,ibmyr;

#if SWEDEN|FINLAND|ARABIC
	ibmyr = my_atoi(&date[0]);
#else
	ibmyr = my_atoi(&date[4]);
#endif

	ibmyr = (ibmyr<80) ? ibmyr+20 : ibmyr-80 ;
	ibmyr = ibmyr << 9;

#if USA
	ibmyr |= (my_atoi(&date[0]) & 15) << 5;	/* month */
	ibmyr |= (my_atoi(&date[2]) & 31);	/* day */
#endif
#if UK|GERMAN|FRENCH|ITALY|SPAIN|TURKEY|NORWAY|DENMARK
	ibmyr |= (my_atoi(&date[2]) & 15) << 5;	/* month */
	ibmyr |= (my_atoi(&date[0]) & 31);	/* day */
#endif
#if SWEDEN|FINLAND|ARABIC
	ibmyr |= (my_atoi(&date[2]) & 15) << 5;	/* month */
	ibmyr |= (my_atoi(&date[4]) & 31);	/* day */
#endif

	Tsetdate(ibmyr);			/* set GEMDOS date */
	miltime = my_atoi(&time[0]) & 31;

#if USA | UK
	if((time[4] == 'P') && (miltime < 12))miltime += 12;
	if((time[4] == 'A') && (miltime == 12))miltime = 0;
#endif

	miltime = (miltime << 11)|((my_atoi(&time[2])&63) << 5);
	Tsettime(miltime);			/* set GEMDOS time */
	Settime(((long)Tgetdate() << 16)|((long)Tgettime()));	/* set 	IKBD time and date */
}

#if ARABIC
/****************************************************************/
/* Converts values (0-99) to Arabic display chars               */
/****************************************************************/
my_itoa(ptr,val,suppress)
int     val,suppress;
char    *ptr;
{
        *ptr++ = (suppress && ((val/10) == 0)) ? ' ' : ((val/10) + 0xb0);
        *ptr = (val%10) + 0xb0;
}

/****************************************************************/
/* Convert Arabic chars to digits.                              */
/****************************************************************/
my_atoi(ptr)
char *ptr;
{
int temp;
        temp = (*ptr == ' ') ? 0 : 10*(*ptr - 0xb0);
        return(temp+(*++ptr - 0xb0));
}

#else

/****************************************************************/
/* Convert chars to digits.					*/
/****************************************************************/
my_atoi(ptr)
char *ptr;
{
int temp;
	temp = (*ptr == ' ') ? 0 : 10*(*ptr - '0');
	return(temp+(*++ptr - '0'));
}

/****************************************************************/
/* Converts values (0-99) to display chars			*/
/****************************************************************/
my_itoa(ptr,val,suppress)
int	val,suppress;
char	*ptr;
{
	*ptr++ = (suppress && ((val/10) == 0)) ? ' ' : ((val/10) + '0');
	*ptr = (val%10) + '0';
}
#endif

/****************************************************************/
/* Reads defaults from DESKTOP.INF.				*/
/****************************************************************/
read_in()
{
int i;
char *bufptr;
	shel_get(buffer,BUFSIZE);

	bufptr=buffer;			/* RS232 configure info */
	do while(*bufptr++ != '#'); while(*bufptr++ != 'a');
	for(i=0 ; i<=5 ; rsave[i++] = *bufptr++ - '0');
	baudvar = remap2[rsave[BAUD]];	/* init baud variable */

	bufptr=buffer;			/* Printer configure info */
	do while(*bufptr++ != '#'); while(*bufptr++ != 'b');
	for(i=0;i<6;config[i++]=(*bufptr++ - '0'));

	bufptr=buffer;			/* Control Panel configure info */
	do while(*bufptr++ != '#'); while(*bufptr++ != 'c');
	for(i=ST_COLOR;i<ST_MOUSE;state[OLD][i++]=(*bufptr++ - '0')*mix_high);
	for(i=ST_MOUSE;i<ST_IRPT;state[OLD][i++]=(*bufptr++ - '0'));
	state[OLD][ST_IRPT]=my_atoi(bufptr);
	bufptr += 2;
	state[OLD][ST_KRPT]=my_atoi(bufptr);
}

/****************************************************************/
/* Writes out new control panel defaults to DESKTOP.INF.	*/
/****************************************************************/
out_control()
{
int i,j;
char *bufptr;
	shel_get(buffer,BUFSIZE);
	bufptr=buffer;
						/* Only 16 colors*/
/*	for(i=0;i<num_colors;i++){*/		/* to read in frm*/
	for(i=0;i<16;i++){			/* desktop.inf   */
		vq_color(handle,i,1,rgb);	
		for(j=0;j<3;j++) state[NEW][3*i+j]=rgb[j];
	}

	for(i=0;i<NUM_STATES;i++) state[OLD][i] = state[NEW][i];

	do while(*bufptr++ != '#'); while(*bufptr++ != 'c');
	for(i=ST_COLOR;i<ST_MOUSE;*bufptr++ = (state[NEW][i++]/mix_high)+'0');
	for(i=ST_MOUSE;i<ST_IRPT;*bufptr++ = state[NEW][i++] + '0');
	my_itoa(bufptr,state[NEW][ST_IRPT],0);
	bufptr += 2;
	my_itoa(bufptr,state[NEW][ST_KRPT],0);

	shel_put(buffer,BUFSIZE);
}

/****************************************************************/
/* Writes out new printer defaults to DESKTOP.INF.		*/
/****************************************************************/
out_print()
{
int i;
char *bufptr;
	shel_get(buffer,BUFSIZE);
	bufptr=buffer;

	do while(*bufptr++ != '#'); while(*bufptr++ != 'b');
	for(i=0;i<6;*bufptr++ = config[i++] + '0');

	shel_put(buffer,BUFSIZE);
}

/****************************************************************/
/* Sets control panel to old-state.				*/
/****************************************************************/
set_up()
{
int i;
	for(i=0;i<NUM_STATES;i++) state[NEW][i] = state[OLD][i];
	for(i=0;i<16;i++) vs_color(handle,i,&state[OLD][3*i+ST_COLOR]);
	rmix_val = state[OLD][3*color]/mix_high;
	val_slider(rmix_val,rmix_str);
	RMIX_POS=mul_div((mix_high+1)*(mix_max-rmix_val),(HMIX-HSLDR),1000);
	gmix_val = state[OLD][3*color+1]/mix_high;
	val_slider(gmix_val,gmix_str);
	GMIX_POS=mul_div((mix_high+1)*(mix_max-gmix_val),(HMIX-HSLDR),1000);
	bmix_val = state[OLD][3*color+2]/mix_high;
	val_slider(bmix_val,bmix_str);
	BMIX_POS=mul_div((mix_high+1)*(mix_max-bmix_val),(HMIX-HSLDR),1000);
	set_noise();
	for(i=MBOX0;i<=MBOX4;ctrl_objs[i++].ob_state=NORMAL);
	ctrl_objs[(state[OLD][ST_MOUSE] + MBOX0)].ob_state=SELECTED;
	IRPT_POS=IIMG_POS=mul_div(22*(state[OLD][ST_IRPT]-1),(WRPT-WSLDR),1000);
	KRPT_POS=KIMG_POS=mul_div(50*(state[OLD][ST_KRPT]-1),(WRPT-WSLDR),1000);
	set_rept(state[OLD][ST_IRPT],state[OLD][ST_KRPT]);
}

/****************************************************************/
/* Sets noise bits in BIOS RAM & state in panel.		*/
/****************************************************************/
set_noise()
{

	donoise(state[NEW][ST_CLICK],state[NEW][ST_BELL]);
	ctrl_objs[CLICK].ob_spec = (state[NEW][ST_CLICK]) ? &stamps[8] : &stamps[9];
	ctrl_objs[BELL].ob_spec = (state[NEW][ST_BELL]) ? &stamps[6] : &stamps[7];
}

/****************************************************************/
/* sets BIOS to proper printer configuration.			*/
/****************************************************************/
set_bios()
{
	Setprt((int)((config[5] << 5)|(config[4] << 4)|(config[3] << 3)|(config[2] << 2)|(config[1] << 1)|config[0]));
}

/*
*
* These routines support the rs232 dialog box
*
*/


rsconfig()
{
	int	i;
	int	exit;
	int	x,y,w,h;

	exit = FALSE;
	set_dialog();
	rs_objs[RSCANCEL].ob_state = NORMAL;
	rs_objs[RSOK].ob_state =NORMAL;
	form_center(rs_objs,&x,&y,&w,&h);
	form_dial(FMD_START,0,0,36,36,x,y,w,h);
	form_dial(FMD_GROW,0,0,36,36,x,y,w,h);
	objc_draw(rs_objs, 0, MAX_DEPTH, x,y,w,h);

	do
	{
		switch(form_do(rs_objs,0))
		{
		case RSCANCEL:
			set_dialog();
			exit = TRUE;
			break;
		case RSOK:
			rec_change();
			exit = TRUE;
			break;

		case UPARROW:
			for(i=0; i<10000; i++);	/* delay loop */
			if( --baudvar < 0 ) baudvar = 15;
		 /* set string */
			rs_objs[BAUDIND].ob_spec = baudstr[baudvar];
			objc_draw(rs_objs,BAUDIND, 1,x,y,w,h);
			objc_change(rs_objs,UPARROW,0,x,y,w,h,OUTLINED,REDRAW);
			break;

		case DNARROW:
			for(i=0; i<10000; i++);	/* delay loop */
			if( baudvar++ >= 15 ) baudvar = 0;
		 /* set string */
			rs_objs[BAUDIND].ob_spec = baudstr[baudvar];
			objc_draw(rs_objs,BAUDIND, 1,x,y,w,h);
			objc_change(rs_objs,DNARROW,0,x,y,w,h,OUTLINED,REDRAW);
			break;
		}
	} while(!exit);
	form_dial(FMD_SHRINK,0,0,36,36,x,y,w,h);
	form_dial(FMD_FINISH,0,0,36,36,x,y,w,h);
}


rec_change()
{
int	i;


	rsave[BAUD] = remap[baudvar];	 /* save baudrate variable */

	for(i=SEL_PARITY;i<=END_PARITY;i++)
	  if(rs_objs[i].ob_state == SELECTED)
		rsave[PARITY] = (char)(i-SEL_PARITY);

	if(rs_objs[SEL_DUPLEX].ob_state == SELECTED) rsave[DUPLEX] = 0;
	else 					     rsave[DUPLEX] = 1;

	if(rs_objs[SEL_BIT].ob_state == SELECTED) rsave[STBIT] = 0;
	else					  rsave[STBIT] = 1;

	for(i=SEL_BCHAR;i<=END_BCHAR;i++)
		if(rs_objs[i].ob_state == SELECTED)
			rsave[BCHAR] = (char)(i-SEL_BCHAR);

	rsave[FLOW] = 0;		/* clear xon/xoff Rts/Cts */
	if(rs_objs[SEL_XON].ob_state == SELECTED) rsave[FLOW] |= 0x01;
	if(rs_objs[SEL_RTS].ob_state == SELECTED) rsave[FLOW] |= 0x02;

	put_inf();	/* store info for save desktop */
	set_state();	/* set hardware to reflect new change */
	send_msg();	/* send message to the vt52 */
}

set_dialog()
{
int	i;

	/* set all ob_states to NORMAL */

  	for(i=SEL_BAUD;i<NUM_RSOBJ;i++) rs_objs[i].ob_state = NORMAL;

	rs_objs[BAUDIND].ob_spec = baudstr[remap2[rsave[BAUD]]];

	rs_objs[SEL_DUPLEX+rsave[DUPLEX]].ob_state = SELECTED;
	rs_objs[SEL_PARITY+rsave[PARITY]].ob_state = SELECTED;
	rs_objs[SEL_BCHAR+rsave[BCHAR]].ob_state = SELECTED;
	rs_objs[SEL_BIT+rsave[STBIT]].ob_state = SELECTED;

	if((0x01 & rsave[FLOW]) != 0) rs_objs[SEL_XON].ob_state = SELECTED;
	else                            rs_objs[SEL_XON+1].ob_state = SELECTED;

	if(0x02 & rsave[FLOW]) rs_objs[SEL_RTS].ob_state = SELECTED;
	else                            rs_objs[SEL_RTS+1].ob_state = SELECTED;
}

put_inf()
{
char	*ptr_inf;
 int	i;

	shel_get(buffer, BUFSIZE);
	ptr_inf  = buffer;
	do while(*ptr_inf++ != '#'); while(*ptr_inf++ != 'a');
	for(i=0 ; i<=5 ; *ptr_inf++ = rsave[i++] + '0');

	shel_put(buffer, BUFSIZE);
}
