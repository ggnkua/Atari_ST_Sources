/********************************************************************
	DX-ED.C  Copyright (c) 1987 by EMC

	This is the third attempt at a GEM application

*********************************************************************/

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include "dx.h"
#include "dxed.h"

/*********************************************************************
   DEFINES
*********************************************************************/

#define WI_KIND		(SIZER|MOVER|FULLER|CLOSER|NAME|UPARROW|DNARROW|VSLIDE)

#define NO_WINDOW (-1)

#define MIN_WIDTH  (2*gl_wbox)
#define MIN_HEIGHT (3*gl_hbox)
#define N_LINES 23

char ver[]="DXED  ver 0.91";	/*	program revision number	*/
extern int	gl_apid;
extern int patch;
extern int midi_ch;
int	gl_hchar;
int	gl_wchar;
int	gl_wbox;
int	gl_hbox;	/* system sizes */

int 	phys_handle;	/* physical workstation handle */
int	top_window;	/* handle of topped window */

int	xdesk,ydesk,hdesk,wdesk;
int res;
static int cur_line;
long menu_addr;		/*	pointer to Menu tree	*/

int	keycode;	/* keycode returned by event-keyboard */
int	mx,my;		/* mouse x and y pos. */
int	butdown;	/* button state tested for, UP/DOWN */
int	ret;		/* dummy return variable */

int	hidden;		/* current state of cursor */


int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];	/* storage wasted for idiotic bindings */

int pxyarray[10];	/* input point array */

/*
	menu flags
*/
int mf_play_pb,mf_play_rec;	/*	sequencer selections	*/
int mf_pr_prt,mf_pr_bnd,mf_pr_mwh,mf_pr_fct,mf_pr_bth,mf_pr_aft,mf_pr_oth;
int mf_md_lfo,mf_md_pev,mf_md_oth;
int mf_o_envl,mf_o_freq,mf_o_scal,mf_o_sens,mf_o_opr;	/*operator*/
int mf_m_smch,mf_m_gbnk,mf_m_sbnk;	/*	midi stuff	*/
int mf_f_sbnk,mf_f_lbnk,mf_f_open,mf_f_new,mf_f_save,mf_f_arng,mf_f_quit;
extern char temp[128],edit[155],pedit[94],bulk_buff[4096];

menu_update()
{
	menu_ienable(menu_addr,M_O_ENVL,mf_o_envl);
	menu_ienable(menu_addr,M_O_FREQ,mf_o_freq);
	menu_ienable(menu_addr,M_O_SCAL,mf_o_scal);
	menu_ienable(menu_addr,M_O_SENS,mf_o_sens);
	menu_ienable(menu_addr,PLAY_PB,mf_play_pb);
}

hide_mouse()
{
	if(! hidden){
		graf_mouse(M_OFF,0x0L);
		hidden=TRUE;
	}
}

show_mouse()
{
	if(hidden){
		graf_mouse(M_ON,0x0L);
		hidden=FALSE;
	}
}

open_vwork()
{
	static int work_in[11];	/* Input to GSX parameter array */
	static int work_out[57];	/* Output from GSX parameter array */
	int i,handle;

	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
	return(handle);
}

/****************************************************************
	 set clipping rectangle
****************************************************************/
set_clip(vw,x,y,w,h)
int vw,x,y,w,h;
{
	int clip[4];

	clip[0]=x;
	clip[1]=y;
	clip[2]=x+w - 1;
	clip[3]=y+h - 1;
	vs_clip(vw,1,clip);
}

/****************************************************************
	open window
****************************************************************/
int open_window(x,y,w,h,name,kind)
int x,y,w,h,kind;	/*	coordinates of window	*/
char *name;
{
	int wh,size;

	wh=wind_create(kind,x,y,w,h);
	wind_set(wh, WF_NAME,name,0,0);
	graf_growbox(x+w/2,y+h/2,gl_wbox,gl_hbox,x,y,w,h);
	wind_open(wh,x,y,w,h);
	wind_get(wh,WF_WORKXYWH,&x,&y,&w,&h);
	slide_size(h/gl_hchar,N_LINES,&size);
	wind_set(wh,WF_VSLSIZE,size,0,0,0);
	return(wh);
}

/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/
do_redraw(wh,vw,xc,yc,wc,hc)
int wh,vw,xc,yc,wc,hc;
{
	GRECT t1,t2;

	hide_mouse();
	wind_update(TRUE);
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	wind_get(wh,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h)
	{
		if (rc_intersect(&t2,&t1))
		{
			set_clip(vw,t1.g_x,t1.g_y,t1.g_w,t1.g_h);
			do_display(wh,vw,cur_line);
		}
		wind_get(wh,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	}
	wind_update(FALSE);
	show_mouse();
}

/****************************************************************/
/*		Accessory Init. Until First Event_Multi		*/
/****************************************************************/
main()
{
	int wh,vw;
	char *ptr;
	OBJECT *box_ptr;

	appl_init();
	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	if(rsrc_load("DXED.RSC") == 0)
	{
		form_alert(1,"[3][Could not open Resouce File][OK]");
		exit(1);
	}
	rsrc_gaddr(0,MENU_TRE,&menu_addr);
	menu_bar(menu_addr,1);
	mf_o_freq = FALSE;
	mf_o_envl = FALSE;
	mf_o_scal = FALSE;
	mf_o_sens = FALSE;
	mf_play_pb = FALSE;
	menu_update();	/*	disable certain things in menu bar	*/
	setup_midi();
	/*
		init some global variables
	*/
	cur_line = 0;
	res = Getrez();
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	vw = open_vwork();
	graf_mouse(ARROW,0x0L);
	set_midi_ch(vw);	/*	ask user what midi channel to use	*/
	do_new(vw);
	ptr = &bulk_buff[patch * 128];
	bulk2ed(ptr,edit);
	edit_send(midi_ch,edit);
	wh = open_window(xdesk,ydesk,wdesk,hdesk,"DX-ED",WI_KIND);
	/*
		set revision number in dialog box
	*/
	rsrc_gaddr(R_TREE,ABOUT_DX,&box_ptr);
	strcpy(box_ptr[VERSION].ob_spec,ver);

	hidden=FALSE;
	butdown=TRUE;

	multi(wh,vw);
	rsrc_free();
	do_cleanup(wh,vw);
}


/****************************************************************/
/* dispatches all accessory tasks				*/
/****************************************************************/
multi(wh,vw)
int wh;	/*	window handle	*/
int vw;	/*	virtual workstation handle	*/
{
	int event,dummy;
	int x,y,w,h;
	int m[10];	/*	message buffer	*/
	int	xold,yold,hold,wold;	/*	old size of window	*/
	int	fulled;		/* current state of window */
	int size;	/*	size of vertical slider	*/
	int quit;

	quit = FALSE;
	wind_get(wh,WF_WORKXYWH,&x,&y,&w,&h);
	fulled=FALSE;
	do
	{
		event = evnt_multi(MU_MESAG | MU_BUTTON | MU_KEYBD,
			1,1,butdown,
			0,0,0,0,0,
			0,0,0,0,0,
			m,0,0,&mx,&my,&ret,&ret,&keycode,&ret);
		wind_update(TRUE);
		if (event & MU_MESAG)	/*	was some sort of message	*/
	  		switch (m[0])
			{
				case MN_SELECTED:
					quit = do_menu(m[3],m[4],wh,vw);
					break;
				case WM_REDRAW:
	    			do_redraw(wh,vw,m[4],m[5],m[6],m[7]);
					set_clip(vw,x,y,w,h);
	    			break;
				case WM_NEWTOP:
				case WM_TOPPED:
	    			wind_set(wh,WF_TOP,0,0,0,0);
	    			break;
				case WM_SIZED:
				case WM_MOVED:
					if(m[6]<MIN_WIDTH)m[6]=MIN_WIDTH;
					if(m[7]<MIN_HEIGHT)m[7]=MIN_HEIGHT;
					wind_set(wh,WF_CURRXYWH,m[4],m[5],m[6],m[7]);
					wind_get(wh,WF_WORKXYWH,&x,&y,&w,&h);
					slide_size(h/gl_hchar,N_LINES,&size);
					wind_set(wh,WF_VSLSIZE,size,0,0,0);
					set_clip(vw,x,y,w,h);
	    			break;
				case WM_ARROWED:
					do_arrows(m[4],wh,vw,N_LINES,&dummy,&cur_line);
					do_display(wh,vw,cur_line);
					break;
				case WM_VSLID:
					v_touched(wh,vw,m[4],N_LINES,&cur_line);
					wind_set(wh,WF_VSLIDE,m[4],0,0,0);
					do_display(wh,vw,cur_line);
					break;
				case WM_FULLED:
					if(fulled)
					{
						wind_calc(WC_WORK,WI_KIND,xold,yold,wold,hold,
						&x,&y,&w,&h);
						wind_set(wh,WF_CURRXYWH,xold,yold,wold,hold);
					}
					else
					{
						wind_calc(WC_BORDER,WI_KIND,x,y,w,h,
						&xold,&yold,&wold,&hold);
						wind_calc(WC_WORK,WI_KIND,xdesk,ydesk,wdesk,hdesk,
						&x,&y,&w,&h);
						wind_set(wh,WF_CURRXYWH,xdesk,ydesk,wdesk,hdesk);
	    			}
					wind_get(wh,WF_WORKXYWH,&x,&y,&w,&h);
					slide_size(h/gl_hchar,N_LINES,&size);
					wind_set(wh,WF_VSLSIZE,size,0,0,0);
					set_clip(vw,x,y,w,h);
	    			fulled ^= TRUE;
	    			break;
			} /* switch (m[0]) */
			if ((event & MU_BUTTON)&&(wh == top_window))
	  			if(butdown)
					butdown = FALSE;
	  		else
				butdown = TRUE;
			if(event & MU_KEYBD)
			{
	     		do_redraw(wh,vw,x,y,w,h);
			}
			wind_update(FALSE);
		}while(!((event & MU_MESAG) && (m[0] == WM_CLOSED)) && (!quit));
	wind_close(wh);
 	graf_shrinkbox(x+w/2,y+h/2,gl_wbox,gl_hbox,x,y,w,h);
	wind_delete(wh);
	v_clsvwk(vw);
	appl_exit();
}

/****************************************************************

	draw the display on the screen

****************************************************************/
do_display(wh,vw,cl)
int wh,vw,cl;
{
	int x,y,w,h;	/*	window coordinates	*/
	int i,j,xy[4],off;

	/*	displays the data in the voice buffer in the window
	*/
	off = cl * 8 * res;
	wind_get(wh,WF_WORKXYWH,&x,&y,&w,&h);
	xy[0] = x;
	xy[1] = y;
	xy[2] = w + x - 1;
	xy[3] = y + h - 1;
	vsf_interior(vw,2);
	vsf_style(vw,8);
	vsf_color(vw,0);
	v_bar(vw,xy);
	y = y - off;
	for(i=0;i<3;++i)
	{
		disp_opr(vw,wh,x + i * 184,y + (7 * res) +1,&edit[i * 21],6 - i);
	}
	for(j = 0,i=3;i<6;++i,++j)
	{
		disp_opr(vw,wh,x + j * 184,y + (103 * res) +1,&edit[i * 21],6 - i);
	}
	vsl_color(vw,1);
	vsl_ends(vw,0,0);
	vsl_type(vw,1);
	vsl_width(vw,3);
	xy[0] = x + 180;
	xy[2] = xy[0];
	xy[1] = y;
	xy[3] = y + 416;
	v_pline(vw,2,xy);
	xy[0] = xy[0] + 184;
	xy[2] = xy[0];
	v_pline(vw,2,xy);
	xy[0] = xy[0] + 188;
	xy[2] = xy[0];
	v_pline(vw,2,xy);
	xy[0] = x;
	xy[2] = x + 552;
	xy[1] = y + 92 * res;
	xy[3] = xy[1];
	v_pline(vw,2,xy);
}

disp_opr(vw,wh,x,y,data,index)
int vw,wh;	/*	screen handles	*/
int x,y;	/*	start position of display	*/
char data[];	/*	data for operator	*/
int index;	/*	which operator	*/
{
	int tx,ty;
	int i;
	char t1[10],t2[10];	/*	more temp arrays	*/
	int pxy[10];

	tx = x;
	ty = y;
	sprintf(temp,"        OPERATOR %1d",index);
	v_gtext(vw,tx,ty,temp);
	ty += 8 * res;
	v_gtext(vw,tx,ty," ENVELOPE");
	ty += 8 * res;
	for(i=0;i<4;++i)
	{
		sprintf(temp,"R%c:%2d L%c:%2d",'1' + i,data[0 + i],'1' + i,data[4 + i]);
		v_gtext(vw,tx,ty,temp);
		ty += 8 * res;
	}
	v_gtext(vw,tx,ty,"   SCALING");
	ty += 8 * res;
	get_bp(t1,data[8]);
	sprintf(temp,"BP:%s LD:%2d RD:%2d",t1,data[9],data[10]);
	v_gtext(vw,tx,ty,temp);
	ty += 8 * res;
	get_lc(t1,data[11]);
	get_lc(t2,data[12]);
	sprintf(temp,"LC:%s RC:%s RS:%2d",t1,t2,data[13]);
	v_gtext(vw,tx,ty,temp);
	ty += 8 * res;
	v_gtext(vw,tx,ty," SENSITIVITY");
	ty += 8 * res;
	sprintf(temp,"AMS:%2d VEL:%2d",data[14],data[15]);
	v_gtext(vw,tx,ty,temp);
	ty = y + 16 * res;	/*	reset row variable	*/
	tx = x + 96;
	v_gtext(vw,tx,ty,"  FREQ");
	freqset(t1,data[18],data[19],data[17]);
	ty += 8 * res;
	sprintf(temp," %s",t1);
	v_gtext(vw,tx,ty,temp);
	ty += 8 * res;
	v_gtext(vw,tx,ty,"DETUNE");
	ty += 8 * res;
	sprintf(temp,"  %2d",data[20]);
	v_gtext(vw,tx,ty,temp);
	ty = y + 72 * res;	/*	reset coordinates	*/
	tx = x + 112;
	v_gtext(vw,tx,ty," LEVEL");
	ty += 8 * res;
	sprintf(temp,"   %2d",data[16]);
	v_gtext(vw,tx,ty,temp);
	/*
		OK now lets draw some lines to make the screen pretty
	*/
	vsl_width(vw,1);
	vsl_type(vw,1);
	vsl_ends(vw,0,0);
	vsl_color(vw,1);
	pxy[0] = x;
	pxy[1] = y + 1 * res;
	pxy[2] = x + 184;
	pxy[3] = pxy[1];
	v_pline(vw,2,pxy);
	pxy[0] = x + 92;
	pxy[2] = pxy[0];
	pxy[3] = pxy[1] + 40 * res;
	v_pline(vw,2,pxy);
	pxy[0] = x;
	pxy[1] = pxy[3];
	pxy[2] = x + 184;
	v_pline(vw,2,pxy);
	pxy[1] = y + 65 * res;
	pxy[3] = pxy[1];
	v_pline(vw,2,pxy);
	pxy[0] = x + 108;
	pxy[2] = pxy[0];
	pxy[3] = pxy[1] + 16 * res;
	v_pline(vw,2,pxy);
}

/*********************************************************

	handle the menu

********************************************************/

do_menu(title,item,whand,vw)
int title,item,whand,vw;
{
	int ret;

	ret = 0;
	switch(title)
	{
		case M_FILE:
			ret = do_file_menu(item,whand,vw);
			break;
		case M_ED:
			ret = do_ed_menu(item,whand,vw);
			break;
		case M_EDIT:
			ret = do_edit_menu(item,whand,vw);
			break;
		case M_MIDI:
			ret = do_midi_menu(item,whand,vw);
			break;
		case M_MODULA:
			ret = do_modu_menu(item,whand,vw);
			break;
		case M_PERFRM:
			ret = do_perf_menu(item,whand,vw);
			break;
		case M_PLAY:
			ret = do_play_menu(item,whand,vw);
			break;
		case M_DESK:
			ret = do_desk_menu(item,whand,vw);
			break;
	}
	menu_tnormal(menu_addr,title,1);
	menu_tnormal(menu_addr,item,1);
	return(ret);
}

do_desk_menu(item,whand,vw)
int item,whand,vw;
{
	OBJECT *box_ptr;
	int result;
	long temp;

	switch(item)
	{
		case M_D_INFO:
			rsrc_gaddr(R_TREE,ABOUT_DX,&box_ptr);
			result = do_dialog(box_ptr,0);
			box_ptr[result].ob_state = NORMAL;
			break;
	}
	return(0);
}

do_play_menu(item,whand,vw)
int item,whand,vw;
{
	char str[256];

	switch(item)
	{
		case PLAY_PB:
			play(vw);
			break;
		case PLAY_REC:
			record(vw);
			mf_play_pb = TRUE;
			menu_update();
			break;
	}
	return(0);
}

do_ed_menu(item,whand,vw)
int item,whand,vw;
{
	switch(item)
	{
		case ED_VOICE:
			ed_voice(vw,1);	/*	copy voice by number to edit buff	*/
			do_display(whand,vw,cur_line);
			break;
		case ED_SAVE:
			save_ed(vw);		/*	save edit buffer to bank buffer by number	*/
			break;
	}
	return(0);
}

do_perf_menu(item,whand,vw)
int item,whand,vw;
{

	switch(item)
	{
		case M_PR_PRT:
			do_portamento(vw);
			break;
		case M_PR_BND:
			do_bender(vw);
			break;
		case M_PR_MWH:
			do_wheel(vw);
			break;
		case M_PR_FCT:
			do_foot(vw);
			break;
		case M_PR_BTH:
			do_breath(vw);
			break;
		case M_PR_AFT:
			do_after(vw);
			break;
		case M_PR_OTH:
			do_pother(vw);
			break;
	}
	return(0);
}

do_modu_menu(item,whand,vw)
int item,whand,vw;
{

	switch(item)
	{
		case M_MD_LFO:
			do_lfo(vw);
			break;
		case M_MD_PEV:
			do_pitch_env(vw);
			break;
		case M_MD_OTH:
			do_other(vw);
			break;
	}
	return(0);
}

do_edit_menu(item,whand,vw)
int item,whand,vw;
{

	switch(item)
	{
		case M_O_ENVL:
			do_op_envelope(vw);	/*	perform operation on evelope diag box	*/
			break;
		case M_O_FREQ:
			do_op_freq(vw);	/*	perform oper on freq diag box	*/
			break;
		case M_O_SCAL:
			do_scale(vw);
			break;
		case M_O_SENS:
			do_sensitiv(vw);
			break;
		case M_O_OPR:
			do_operator(vw);
			break;
	}
	return(0);
}

do_midi_menu(item,whand,vw)
int item,whand,vw;
{

	switch(item)
	{
		case M_M_SMCH:
			set_midi_ch(vw);
			break;
		case M_M_SBNK:
			send_bank(vw);
			break;
		case M_M_PATC:
			ed_voice(vw,0);
			break;
	}
	return(0);
}

do_file_menu(item,whand,vw)
int item,whand,vw;
{
	switch(item)
	{
		case M_F_SBNK:
			save_bank(vw);
			break;
		case M_F_OPEN:
			do_open(vw);
			break;
		case M_F_NEW:
			do_new(vw);
			break;
		case M_F_ARNG:
			arrange_bank(vw);
			break;
		case M_F_QUIT:
			return(1);
			break;
	}
	return(0);
}

int do_dialog(dialog,start)
OBJECT *dialog;
int start;
{
	int cx,cy,cw,ch,result;

	if (dialog == (OBJECT *)(0))
	{
		form_alert(1,"[1][Null pointer ERROR][OK]");
		return(0);
	}
	else
	{
		form_center(dialog,&cx,&cy,&cw,&ch);
		form_dial(FMD_START,cx,cy,0,0,cx,cy,cw,ch);
		form_dial(FMD_GROW,cx,cy,0,0,cx,cy,cw,ch);
		objc_draw(dialog,0,10,cx,cy,cw,ch);
		result = form_do(dialog,start);
		form_dial(FMD_SHRINK,cx,cy,0,0,cx,cy,cw,ch);
		form_dial(FMD_FINISH,cx,cy,0,0,cx,cy,cw,ch);
		return(result);
	}
}

