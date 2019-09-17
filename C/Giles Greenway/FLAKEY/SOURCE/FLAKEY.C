#include<aes.h>
#include<vdi.h>
#include<stdlib.h>
#include<stdio.h>
#include<math.h>
#include"flk_res.h"
#include"flk_res.c"

#define KIND NAME|CLOSE|FULL|INFO|MOVE|SIZE

#define SIN_THETA 0.86602554
#define COS_THETA -0.5
#define SIN_ALPHA 0.86602554
#define COS_ALPHA 0.5

void do_menu(short);
void ego_trip();
void options();
void fill_win(short,short,short,short);
void koch(int,short,short,short,short);
void win_change(short,short,short,short,short);

short vdi_hand,win_x,win_y,win_w,win_h,wrk_x,wrk_y,wrk_w,wrk_h,
full_x,full_y,full_w,full_h,x_cen,y_cen;

int id,run,depth,sides,win_hand,any_data;

char infstr[80];

MFDB crt,paste;

int main()
{

	short msg[8],wrk_in[11],wrk_out[57],nplanes,junk;

	int xpix,ypix;

	run = 1; depth = 4; any_data = 0;

	id = appl_init();
	rsrc_init();
	menu_bar(FLK_MEN,1);

	graf_mouse(0,0);

	vdi_hand = graf_handle(&junk,&junk,&junk,&junk);
	wrk_in[10] = 2;
	v_opnvwk(wrk_in,&vdi_hand,wrk_out);

	vsf_color(vdi_hand,WHITE);
	vsf_interior(vdi_hand,8);
	vsf_style(vdi_hand,2);
	vsl_color(vdi_hand,BLACK);
	vsl_type(vdi_hand,SOLID);
	
	xpix = wrk_out[0]; ypix = wrk_out[1];

	vq_extnd(vdi_hand,1,wrk_out);
	nplanes = wrk_out[4];	

	if (xpix > 639 || ypix > 399)
	{
		win_w = 639; win_h = 399; win_x = (xpix - win_w) / 2;
		win_y = (ypix - win_h) / 2;
	}
	else
		wind_get(DESK,WF_WXYWH,&win_x,&win_y,&win_w,&win_h);
	
	wind_calc(WC_WORK,KIND,win_x,win_y,win_w,win_h,
	&wrk_x,&wrk_y,&wrk_w,&wrk_h);

	full_x = win_x; full_y = win_y; full_w = win_w; full_h = win_h;

	win_hand = wind_create(KIND,win_x,win_y,win_w,win_h);

	if (win_hand < 0)
	{
		form_alert(1,"[1][Couldn't open the window !][ DRAT !]");
		goto NO_WIN;
	}


	crt.fd_addr = NULL;

	paste.fd_wdwidth = (wrk_w + 15) / 16;
	paste.fd_w = paste.fd_wdwidth / 16;
	paste.fd_h = wrk_h;
	paste.fd_stand = 0;
	paste.fd_nplanes = nplanes;
	paste.fd_addr = calloc(paste.fd_wdwidth * wrk_h * nplanes,2);


	wind_title(win_hand," FLAKEY ");
	wind_open(win_hand,win_x,win_y,win_w,win_h);
		

	while(run)
	{
		evnt_mesag(msg);

		switch(msg[0])
		{
			case MN_SELECTED: do_menu(msg[4]);
			menu_tnormal(FLK_MEN,msg[3],1); break;

			case WM_CLOSED: if (msg[3] == win_hand) run = 0; break;

			case WM_REDRAW: if (msg[3] == win_hand)
			fill_win(msg[4],msg[5],msg[6],msg[7]); break;

			case WM_TOPPED: 
			if (msg[3] == win_hand)
			{
				wind_set(win_hand,WF_TOP,&junk,&junk,&junk,&junk);
				wind_info(win_hand,infstr);
			}		
			break;

			case WM_MOVED: 
			case WM_SIZED:
			if (msg[3] == win_hand)									
			win_change(msg[0],msg[4],msg[5],msg[6],msg[7]);
			break;

			case WM_FULLED:
			if (msg[3] == win_hand)
			{
				if (win_w >= full_w && win_h >= full_h)
				{
					wind_get(win_hand,WF_PXYWH,&win_x,&win_y,&win_w,&win_h);
					win_change(WM_SIZED,win_x,win_y,win_w,win_h);
				}
				else
					win_change(WM_SIZED,full_x,full_y,full_w,full_h);	
			}

		}
	}


	wind_close(win_hand);
	wind_delete(win_hand);

	NO_WIN:

	free(paste.fd_addr);

	v_clsvwk(vdi_hand);

	menu_bar(FLK_MEN,0);
	appl_exit();
	
	return 0;

}

void do_menu(short item)
{
	switch(item)	
	{
		case QUIT: run = 0; break;
		case FLK_DSK: ego_trip(); break;
		case SET_OPT: options(); break;
	}
}

void ego_trip()
{

	short x1,y1,w1,h1;
	int x,y,w,h,junk;

	form_center(FLK_ABT,&x1,&y1,&w1,&h1);
	x = x1; y = y1; w = w1; h = h1;
	form_dial(FMD_START,junk,junk,junk,junk,x,y,w,h);
	objc_draw(FLK_ABT,ROOT,MAX_DEPTH,x,y,w,h);
	form_do(FLK_ABT,0);
	form_dial(FMD_FINISH,junk,junk,junk,junk,x,y,w,h);
	FLK_ABT[ABT_OK].ob_state &= ~SELECTED;

}

void options()
{
	short x1,y1,w1,h1,msg[8],crud;
	int x,y,w,h,new_depth,junk;

	TEDINFO *txt;

	form_center(FLK_FRM,&x1,&y1,&w1,&h1);
	x = x1; y = y1; w = w1; h = h1;
	form_dial(FMD_START,junk,junk,junk,junk,x,y,w,h);
	objc_draw(FLK_FRM,ROOT,MAX_DEPTH,x,y,w,h);
	form_do(FLK_FRM,0);
	form_dial(FMD_FINISH,junk,junk,junk,junk,x,y,w,h);
	FLK_FRM[FLK_OK].ob_state &= ~SELECTED;

	
	txt = FLK_FRM[DEP_BOX].ob_spec;
	new_depth = atoi(txt->te_ptext);

	if (depth != new_depth)
	{
		depth = new_depth;

		any_data = 0;

		wind_set(win_hand,WF_TOP,&crud,&crud,&crud,&crud);
		
		msg[0] = WM_REDRAW; msg[1] = id;
		msg[2] = 0; msg[3] = win_hand;
		msg[4] = wrk_x; msg[5] = wrk_y;
		msg[6] = wrk_w; msg[7] = wrk_h;

		appl_write(id,sizeof(msg),msg);

	}
}

void fill_win(short xx,short yy,short ww,short hh)
{
	short box[8],x,y,rad;
	

	GRECT rec1,rec2;

	graf_mouse(256,0);
	wind_update(BEG_UPDATE);

	if (any_data == 0)
	{

		
		box[0] = wrk_x; box[1] = wrk_y;
		box[2] = wrk_x + wrk_w - 1; box[3] = wrk_y + wrk_h - 1;
	

		sprintf(infstr," Koch snowflake depth %d.",depth);
		
		wind_info(win_hand,infstr);

		v_bar(vdi_hand,box);

		x_cen = wrk_x + wrk_w / 2;
		y_cen = wrk_y + wrk_h / 2;

		rad = wrk_h / 2;

		x = (int)(rad * SIN_THETA);
		y = (int)(rad * COS_THETA);


		koch(depth,0,rad,x,y);
		koch(depth,x,y,-x,y);
		koch(depth,-x,y,0,rad);	

		box[0] = wrk_x; box[1] = wrk_y;
		box[2] = wrk_x + wrk_w - 1; box[3] = wrk_y + wrk_h - 1;
		box[4] = 0; box[5] = 0; box[6] = wrk_w - 1; box[7] = wrk_h - 1;

		vro_cpyfm(vdi_hand,S_ONLY,box,&crt,&paste);
	

		any_data = 1;
		

	}
	else
	{
		rec1.g_x = xx; rec1.g_y = yy;
		rec1.g_w = ww; rec1.g_h = hh;

		wind_get(win_hand,WF_FIRSTXYWH,&rec2.g_x,&rec2.g_y,
		&rec2.g_w,&rec2.g_h);

		while(rec2.g_w && rec2.g_h)
		{
			if(rc_intersect(&rec1,&rec2))
			{
				box[0] = rec2.g_x - wrk_x;
				box[1] = rec2.g_y - wrk_y;
				box[2] = box[0] + rec2.g_w - 1;
				box[3] = box[1] + rec2.g_h - 1;
				box[4] = rec2.g_x;
				box[5] = rec2.g_y;
				box[6] = rec2.g_x + rec2.g_w - 1;
				box[7] = rec2.g_y + rec2.g_h - 1;

				vro_cpyfm(vdi_hand,S_ONLY,box,&paste,&crt);
			}

			wind_get(win_hand,WF_NEXTXYWH,&rec2.g_x,&rec2.g_y,
			&rec2.g_w,&rec2.g_h);

		}

	}

	wind_update(END_UPDATE);
	graf_mouse(257,0);


} 

void koch(int deep,short x1,short y1,short x2,short y2)
{

	short line[4],dx,dy,dh,dk,h1,k1,h2,k2;

	int deeper;

	
	if (deep == 0)
	{
		line[0] = x1 + x_cen;
		line[1] = y_cen - y1;
 		line[2] = x2 + x_cen;
 		line[3] = y_cen - y2;

		v_pline(vdi_hand,2,line);
	}
	else
	{
		deeper = deep - 1;

		dx = x2 - x1; dy = y2 - y1;

		dh = dx / 3; 
		dk = dy / 3;

		h1 = x1; k1 = y1;
		h2 = h1 + dh; k2 = k1 + dk;

		koch(deeper,h1,k1,h2,k2);

		dh = h2 - h1; dk = k2 - k1;

		h1 = h2; k1 = k2;

		h2 = h1 + (int)(dh * COS_ALPHA + dk * -SIN_ALPHA);
		k2 = k1 + (int)(dk * COS_ALPHA - dh * -SIN_ALPHA);

		koch(deeper,h1,k1,h2,k2);

		
		dh = h2 -h1; dk = k2 - k1;

		h1 = h2; k1 = k2;

		h2 = h1 + (int)(dh * COS_THETA + dk * SIN_THETA);
		k2 = k1 + (int)(dk * COS_THETA - dh * SIN_THETA);

		koch(deeper,h1,k1,h2,k2);
								
		koch(deeper,h2,k2,x2,y2);

	}


}


void win_change(short mes,short x,short y,short w,short h)
{
	short msg[8];

	if (w >= 160 && h >= 100 && w >= h)
	{
	


		wind_set(win_hand,WF_CXYWH,x,y,w,h);
		win_x = x; win_y = y; win_w = w; win_h = h;	

		wind_get(win_hand,WF_WXYWH,&wrk_x,&wrk_y,&wrk_w,&wrk_h);

		if (mes == WM_SIZED)
		{
			any_data = 0;
			msg[0] = WM_REDRAW; msg[1] = id; msg[2] = 0; msg[3] = win_hand;
			msg[4] = wrk_x; msg[5] = wrk_y; msg[6] = wrk_w; msg[7] = wrk_h;
			appl_write(id,sizeof(msg),msg);
		}
	}
}                              