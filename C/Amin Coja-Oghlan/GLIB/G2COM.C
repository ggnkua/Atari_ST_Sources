/*                    GLIB Library Modul 1 12.10.1992			    */

#include <stdio.h>
#include <limits.h>
#include <aes.h>
#include <vdi.h>

enum {W_NAME = 1,W_INFO,W_CURRXYWH = 4,W_HSLIDE = 8,W_VSLIDE = 16,
	  W_TOP  = 32,W_NEWDESK = 64,W_HSLSIZE = 128,W_VSLSIZE = 256};
#define W_ANZ	256
#define TRUE	1
#define FALSE	0
#define NO_WIND (-1)
#define DESK	0
#define SFLAG	3
#define UP		1
#define DOWN	2
#define LEFT 	3
#define RIGHT	4

typedef struct  {
				int	handle,full,open,used,x,y,w,h,rfull;
				int kind;
				int workx,worky,workw,workh;
				int xa,ya;
				int hslide,vslide,hslrast,vslrast,xstep,ystep;
				long hslsize,vslsize;
				long dh,dw,fdy,fdx,fwx,fwy;
				char *name,*info;
				int free[8];
				void *freeptr;
				} WIND;

extern int nplanes;

WIND slots[W_ANZ];
GRECT t1,t2;
int ap_id;
int wh,icx,icy,ch,cw,charw,charh;
int gl_wchar,gl_hchar,gl_wbox,gl_hbox;
int phys_handle,vdi_handle;
int x_desk,y_desk,w_desk,h_desk;
int msgbuff[8];
int mox,moy,mokstate,mobutton,mclicks,bmask,bstate,breturn;
int kstate,kreturn;
int cntrl[12],initin[128],ptsin[128],intout[128],ptsout[128];
int work_in[11],work_out[57],pxyarray[10];
int event,m1flag,m2flag,m1x,m1y,m1w,m1h,m2x,m2y,m2w,m2h,mreturn;
int lowcount,hicount;
int timeinfo = 125;
int swidth = 639,shight = 399;

int rc_intersect(GRECT *rc1,GRECT *rc2);
void g_newdesk(OBJECT *desk,int startob,int depth,int flag);
void g_deskdraw(OBJECT *desk,int startob,int depth);
void g_icondraw(int h,OBJECT *icon,int startob,int depht);
void g_rubberbox(OBJECT *tree,int startob,int depth,int x,int y,
			   int w,int h,int xstep,int ystep,int flag);
void g_swap(int *a,int *b);
int g_test(int x,int y,int w,int h,OBJECT *desk,int d);
int g_icon(OBJECT *icon,int index,int startob,int depth,
			int x,int y,int clicks,int flag,
			OBJECT *desk,int dstartob,int ddepth,
			int ix,int iy,int iw,int ih);
void g_c_wind(int x,int y,int w,int h);
void g_cwork(int h);
int g_find_new_slot(void);
int g_find_slot(void);
int g_find_handle(int h);
void g_slidesize(int h);
void g_sldpos(int h);
void g_windpos(int h);
void g_scroll(int x,int y,int w,int h,int anz,int dir,int flag); 
int g_windcset(int h,int flag);
int g_varset(int h);
int g_wind_open(int h,int kind);
void g_rast(int *x,int *y,int rx,int ry);
int g_anz_rect(int h);
void g_calc_redraw(int h,int v,void (*a1f)(int v));
int g_wind_close(int h);
int g_full_window(int h);
void g_redraw(int slot,void(*a1f)(int v));
void g_top(int slot);
void g_wclose(int slot);
void g_full(int slot);
void g_rfull(int slot,int rx,int ry,int rw,int rh);
void g_hslide(int slot,void(*a1f)(void));
void g_vslide(int slot,void(*a1f)(void));
void g_size(int slot,int min_w,int min_h,int rx,int ry);
int g_init(int anz,int x,int y,int w,int h,int kind);
int g_rsrc_init(char *name);
void g_mouse(int flag);
void g_update(int flag);
void g_clip(int x,int y,int x2,int y2,int flag);
int g_multi(int flag,int (*a1f)(void),int (*b1f)(void),int (*c1f)(void),
			int (*d1f)(void),int (*e1f)(void),int (*f1f)(void),
			int (*g1f)(void),int (*h1f)(void),int (*i1f)(void),
			int (*j1f)(void),int (*k1f)(int evt));
void g_invert_state(OBJECT *objc,int index,int flag);
int g_hndl_dial(OBJECT *objc,int o,int (*a1f)(int ex));
int g_dummy(void);
int g_cwindows(void);
void g_exit(void);

int rc_intersect(GRECT *rc1,GRECT *rc2)
	{
	int x12,y12,x22,y22;
 	
	x12 = rc1 -> g_x + rc1 -> g_w - 1;
	x22 = rc2 -> g_x + rc2 -> g_w - 1;
	y12 = rc1 -> g_y + rc1 -> g_h - 1;
	y22 = rc2 -> g_y + rc2 -> g_h - 1;
	
	rc2 -> g_w = (x12 < x22) ? x12 : x22;
	rc2 -> g_h = (y12 < y22) ? y12 : y22;
	
	rc2 -> g_x = (rc1 -> g_x > rc2 -> g_x) ? rc1 -> g_x : rc2 -> g_x;
	rc2 -> g_y = (rc1 -> g_y > rc2 -> g_y) ? rc1 -> g_y : rc2 -> g_y;
	
	if(rc2 -> g_x > rc2 -> g_w || rc2 -> g_y > rc2 -> g_h)
		return(FALSE);
	return(TRUE);	
	}

void g_newdesk(OBJECT *desk,int startob,int depth,int flag)
	{
	if(flag)
		{
		desk -> ob_x = x_desk;
		desk -> ob_y = y_desk;
		desk -> ob_width = w_desk;
		desk -> ob_height= h_desk;
		}
	wind_set(DESK,WF_NEWDESK,(void *) desk,startob,0);
	g_deskdraw(desk,startob,depth);
	}	

void g_deskdraw(OBJECT *desk,int startob,int depth)
	{
	int x,y,w,h;
	
	wind_get(DESK,WF_FIRSTXYWH,&x,&y,&w,&h);
	while(w && h)
		{
		objc_draw(desk,startob,depth,x,y,w,h);
		wind_get(DESK,WF_NEXTXYWH,&x,&y,&w,&h);
		}
	}	

void g_icondraw(int h,OBJECT *icon,int startob,int depht)
	{
	objc_offset(icon,startob,&t2.g_x,&t2.g_y);
	t2.g_w = icon -> ob_width;
	t2.g_h = icon -> ob_height;
	wind_get(h,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while(t1.g_w && t1.g_h)
		{
		rc_intersect(&t2,&t1);
		objc_draw(icon,startob,depht,t1.g_x,t1.g_y,
			t1.g_w - t1.g_x + 1,t1.g_h - t1.g_y + 1);
		wind_get(h,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
		}
	}

void g_rubberbox(OBJECT *tree,int startob,int depth,int x,int y,
               int w,int h,int xstep,int ystep,int flag)
	{
	int i,ay = y;
	
	for(;y < ay + h;y += ystep)
		for(i = x;i < x + w;i += xstep)
			{
			int o;
			
			if((o =objc_find(tree,startob,depth,i,y)) != 0)
				{
				(tree + o) -> ob_state |= SELECTED;
				if(flag)
					g_icondraw(DESK,(tree + o),0,0);
				}
			}
	if(!flag)
		g_deskdraw(tree,startob,depth);
	}

void g_swap(int *a,int *b)
	{
	int c;
	
	c = *a;
	*a = *b;
	*b = c;
	}

int g_test(int x,int y,int w,int h,OBJECT *desk,int d) /* d : depth */
	{
	int o,ob = NO_WIND;
	
	if((o = objc_find(desk,0,d,x,y)) != 0)
		ob = o;
	if((o = objc_find(desk,0,d,x + w / 2,y)) != 0)
		ob = o;
	if((o = objc_find(desk,0,d,x,y + h / 2)) != 0)
		ob = o;
	if((o = objc_find(desk,0,d,x,y + h)) != 0)
		ob = o;
	if((o = objc_find(desk,0,d,x + w,y)) != 0)
		ob = o;
	if((o = objc_find(desk,0,d,x + w,y + h / 2)) != 0)
		ob = o;
	if((o = objc_find(desk,0,d,x + w,y + h)) != 0)
		ob = o;
	if((o = objc_find(desk,0,d,x + w / 2,y + h)) != 0)
		ob = o;	
	return(ob);
	}
			
int g_icon(OBJECT *icon,int index,int startob,int depth,
			int x,int y,int clicks,int flag,
			OBJECT *desk,int dstartob,int ddepth,
			int ix,int iy,int iw,int ih)
	{
	int but,state;
		
	if(objc_find(desk,dstartob,ddepth,x,y) != index)
		{
		if(flag)
			{
			icon -> ob_state &= ~SELECTED;
			g_icondraw(DESK,desk,index,depth);
			}
		return(3);
		}
	else
		{	
		if (clicks == 2)
			return(2);
		else
		    {
		    evnt_timer(timeinfo,0);
			graf_mkstate(&x,&y,&but,&state);
			if(but & 1)
				{
				int ww = icon -> ob_width,hh = icon -> 
					ob_height;
				register int io = -1,o = -1,as = 0;

				v_hide_c(vdi_handle);
				while(graf_mkstate(&x,&y,&but,&state),but)
					{
					graf_movebox(ww,hh,x,y,x,y);
					io = objc_find(desk,dstartob,1,x,y);
					if(o != -1 && o != io)
						{
						int x_off,y_off;
						
						objc_offset(desk,o,&x_off,&y_off);
						(desk + o) -> ob_state = as;
						objc_draw(desk,o,8,ix,iy,iw,ih);
						form_dial(FMD_FINISH,0,0,0,0,x_off,y_off,
							(desk + o) -> ob_width,(desk + o) -> 
							ob_height);
						o = -1; 
						}
					if(io != -1 && io != o && io != index && 
					   (desk + io) -> ob_flags
					   & SELECTABLE && !((desk + io) -> ob_state &
					   DISABLED))
						{
						o = io;
						as = (desk + io) -> ob_state;
						(desk + io) -> ob_state |= SELECTED;
						objc_draw(desk,io,8,ix,iy,iw,ih);
						}
					}
				v_show_c(vdi_handle,1);
				x = x + (icon + startob) -> ob_width > ix + iw ? ix + 
					iw - icon -> ob_width: x;
				y = y + (icon + startob) -> ob_height > iy + ih ? iy + 
					ih - (icon + startob) -> ob_height: y;
				g_rast(&x,&y,16,16);
				x = x < ix ? ix - ix % 16 + 16 : x;
				y = y < iy ? iy - iy % 16 + 16 : y;
				o = g_test(x,y,16,16,desk,ddepth);
				if(o == NO_WIND || o == index)
					{
					int x_off,y_off;
					
					objc_offset(desk,index,&x_off,&y_off);
					icx = x - x_off + icon -> ob_x;
					icy = y - y_off + icon -> ob_y;			
					if(flag)
						{
						g_swap(&icon -> ob_x,&icx);
						g_swap(&icon -> ob_y,&icy);
						form_dial(FMD_FINISH,0,0,0,0,x_off,y_off,
								  icon -> ob_width,icon -> ob_height);
						g_icondraw(DESK,desk,index,depth);
						}
					return(0);
					}		 								 				 
				else
					{
					icx = x;
					icy = y;
					return(-o); 	
					}
				}
			else
				{
				icon -> ob_state ^= SELECTED;
				if(flag)
					g_icondraw(DESK,desk,index,depth);
				return(1);
				}
			}
		}
	}
	
void g_c_wind(int x,int y,int w,int h)
	{
	vswr_mode (vdi_handle,1);
	vsf_interior (vdi_handle,2);
	vsf_style (vdi_handle,8);
	vsf_color (vdi_handle,0);
	pxyarray[0] = (x > swidth - 1) ? swidth - 1 : x;
	pxyarray[1] = (y > shight - 1) ? shight - 1 : y;
	pxyarray[2] = (x + w - 1 > swidth - 1) ? swidth - 1 : (x + w - 1);
	pxyarray[3] = (y + h - 1 > shight - 1) ? shight - 1 : (y + h - 1);
	v_bar (vdi_handle,pxyarray);
	}
	
void g_cwork(int h)
	{
	int x,y,w,hi;
	
	wind_get(h,WF_WORKXYWH,&x,&y,&w,&hi);
	
	g_c_wind(x,y,w,hi);
	}	

int g_find_new_slot(void)
	{
	int i;
	
	for(i = 0;i < W_ANZ;i++)
		if(!slots[i].used)
			return(i);
	return(NO_WIND);
	}
	
int g_find_slot(void)
	{
	int i;
	
	for(i = 0; i < W_ANZ;i++)
		if(slots[i].used && !slots[i].open)
			return(i);
	return(NO_WIND);
	}					

int g_find_handle(int h)
	{
	int i;
	
	for(i = 0;i < W_ANZ;i++)
		if(slots[i].handle == h)
			return(i);
	return(NO_WIND);
	}	
		
void g_slidesize(int h)
	{
	int slot = g_find_handle(h);
	
	if(slot != NO_WIND)
		{
		float w = (long) slots[slot].workw - slots[slot].xa;
		float hi= (long) slots[slot].workh - slots[slot].ya;
		float dh= (long) slots[slot].dh;
		float dw= (long) slots[slot].dw;
		
		slots[slot].vslsize = dh ? 1000 * hi / dh + 0.5 : 1000;
		slots[slot].hslsize = dw ? 1000 * w / dw + 0.5 : 1000;
		slots[slot].vslsize = 
		 	(slots[slot].vslsize > 1000) ? 1000 : slots[slot].vslsize;
		slots[slot].hslsize =
			(slots[slot].hslsize > 1000) ? 1000 : slots[slot].hslsize;
		}
	}
	
void g_sldpos(int h)
	{
	int slot = g_find_handle(h);
	
	if(slot != NO_WIND)
		{
		float fwx,fwy;
		float dw = (float) slots[slot].dw,dh = (float) slots[slot].dh;
		float workw = (float) slots[slot].workw - slots[slot].xa,
			workh = (float) slots[slot].workh - slots[slot].ya;
		float fdx = slots[slot].fdx,fdy = slots[slot].fdy;
		
		slots[slot].fwx =
	    (slots[slot].fwx < slots[slot].fdx) ? 
						  slots[slot].fdx : slots[slot].fwx;
		slots[slot].fwy = 
		(slots[slot].fwy < slots[slot].fdy) ?
						  slots[slot].fdy : slots[slot].fwy;
		slots[slot].fwx = 
		(slots[slot].fwx > slots[slot].dw - slots[slot].fdx - slots[slot].workw + slots[slot].xa)				  				  
		    			  ? (slots[slot].dw - slots[slot].fdx - slots[slot].workw + slots[slot].xa)		
						  : slots[slot].fwx;
		slots[slot].fwy = 
		(slots[slot].fwy > slots[slot].dh - slots[slot].fdy - slots[slot].workh + slots[slot].ya)
						  ? (slots[slot].dh - slots[slot].fdy - slots[slot].workh + slots[slot].ya)
						  : slots[slot].fwy;
		fwx = (float) slots[slot].fwx;
		fwy = (float) slots[slot].fwy;
		
		slots[slot].hslide = 1000 * ((fwx - fdx) / (dw - workw)) + 0.5;
		slots[slot].vslide = 1000 * ((fwy - fdy) / (dh - workh)) + 0.5;
		slots[slot].hslide = (slots[slot].hslide > 1000) ? 1000 : 
												   slots[slot].hslide;
		slots[slot].vslide = (slots[slot].vslide > 1000) ? 1000 :
												   slots[slot].vslide;
		slots[slot].hslide = (slots[slot].hslide < 0) ? 0 : slots[slot].hslide;
		slots[slot].vslide = (slots[slot].vslide < 0) ? 0 : slots[slot].vslide;
		if(slots[slot].fwx < 0) slots[slot].fwx = 0;
		if(slots[slot].fwy < 0) slots[slot].fwy = 0;
		if(slots[slot].fdx < 0) slots[slot].fdx = 0;
		if(slots[slot].fdy < 0) slots[slot].fdy = 0;
		}
	}
	
void g_windpos(int h)
	{
	int slot = g_find_handle(h);
	
	if(slot != NO_WIND)
		{
		float hslide = slots[slot].hslide,vslide = slots[slot].vslide;
		float dw = slots[slot].dw,dh = slots[slot].dh;
		float fdx = slots[slot].fdx,fdy = slots[slot].fdy;
		float workw = slots[slot].workw - slots[slot].xa,
			workh = slots[slot].workh - slots[slot].ya;
		
		slots[slot].fwx = ((hslide * (dw - workw)) / 1000 + fdx + 0.5);
		slots[slot].fwy = ((vslide * (dh - workh)) / 1000 + fdy + 0.5);
		slots[slot].fwx = (slots[slot].fwx < slots[slot].fdx)
							? slots[slot].fdx : slots[slot].fwx;
		slots[slot].fwy = (slots[slot].fwy < slots[slot].fdy) 
							? slots[slot].fdy : slots[slot].fwy;
		if(slots[slot].fwx < 0) slots[slot].fwx = 0;
		if(slots[slot].fwy < 0) slots[slot].fwy = 0;
		if(slots[slot].fdx < 0) slots[slot].fdx = 0;
		if(slots[slot].fdy < 0) slots[slot].fdy = 0;
		}
	}	     	
	
void g_scroll(int x,int y,int w,int h,int anz,int dir,int flag)
	{
	MFDB m1,m2;
	
	g_clip(0,0,swidth,shight,TRUE);
	m1.fd_addr = m2.fd_addr = 0x0L;
	pxyarray[0] = x;
	pxyarray[1] = y;
	pxyarray[2] = x + w - 1;
	pxyarray[3] = y + h - 1;
	switch(dir)
		{
		case UP:	pxyarray[4] = x;
					pxyarray[5] = y - anz;
					pxyarray[6] = pxyarray[2];
					pxyarray[7] = pxyarray[3] - anz;
					break;
		case DOWN:	pxyarray[4] = x;
					pxyarray[5] = y + anz;
					pxyarray[6] = pxyarray[2];
					pxyarray[7] = pxyarray[3] + anz;
					break;
		case LEFT:  pxyarray[4] = x - anz;
					pxyarray[5] = y;
					pxyarray[6] = pxyarray[2] - anz;
					pxyarray[7] = pxyarray[3];
					break;
		case RIGHT: pxyarray[4] = x + anz;
					pxyarray[5] = y;
					pxyarray[6] = pxyarray[2] + anz;
					pxyarray[7] = pxyarray[3];
					break;
		}																
	vro_cpyfm(vdi_handle,flag,pxyarray,&m1,&m2);
	g_clip(0,0,swidth,shight,FALSE);
	}

int g_windcset(int h,int flag)
	{
	int slot = g_find_handle(h);
	int kind = slots[slot].kind;
	
	if(slot != NO_WIND)
		{
		if(flag & W_CURRXYWH)
			wind_set(h,WF_CURRXYWH,slots[slot].x,slots[slot].y,
						slots[slot].w,slots[slot].h);				
		if(flag & W_NAME && kind & NAME)
			wind_set(h,WF_NAME,(void *) slots[slot].name,0,0);
		if(flag & W_INFO && kind & INFO)
			wind_set(h,WF_INFO,(void *) slots[slot].info,0,0);	
		if(flag & W_HSLIDE && kind & HSLIDE)
			wind_set(h,WF_HSLIDE,slots[slot].hslide,0,0,0);
		if(flag & W_VSLIDE && kind & VSLIDE)
			wind_set(h,WF_VSLIDE,slots[slot].vslide,0,0,0);
		if(flag & W_HSLSIZE && kind & HSLIDE)
			wind_set(h,WF_HSLSIZE,(int) slots[slot].hslsize,0,0,0);
		if(flag & W_VSLSIZE && kind & VSLIDE)
			wind_set(h,WF_VSLSIZE,(int) slots[slot].vslsize,0,0,0);
		}
	return(slot);
	}											   

int g_varset(int h)
	{
	int slot = g_find_handle(h);
	int x,y,w,hi,kind;
	
	kind = slots[slot].kind;
	if(slot != NO_WIND)
		if(slots[slot].open && slots[slot].used)
			{
			wind_get(h,WF_CURRXYWH,&slots[slot].x,&slots[slot].y,
								   &slots[slot].w,&slots[slot].h);
			wind_get(h,WF_WORKXYWH,&slots[slot].workx,&slots[slot].worky,
								   &slots[slot].workw,&slots[slot].workh);
			if(kind & FULLER)
				{
				wind_get(h,WF_FULLXYWH,&x,&y,&w,&hi);
				if (slots[slot].x == x && slots[slot].y == y &&
				    slots[slot].w == w && slots[slot].h == hi)
				    slots[slot].full = TRUE;
				else
					slots[slot].full = FALSE;
				}    
			if(kind & HSLIDE)
				{
				wind_get(h,WF_HSLIDE,&slots[slot].hslide,0,0,0);
				wind_get(h,WF_HSLSIZE,&slots[slot].hslsize,0,0,0);
				slots[slot].hslsize = slots[slot].hslsize & 0xFFFF;
				}
			if(kind & VSLIDE)
				{
				wind_get(h,WF_VSLSIZE,&slots[slot].vslsize,0,0,0);
				wind_get(h,WF_VSLIDE,&slots[slot].vslide,0,0,0);
				slots[slot].vslsize = slots[slot].vslsize & 0xFFFF;
				}
			}
	return(slot);			
	}
	
int g_wind_open(int h,int kind)
	{
	int slot = g_find_handle(h);
	
	if(slot != NO_WIND && slots[slot].used && !slots[slot].open)
		{
		graf_growbox(10,10,40,40,slots[slot].x,slots[slot].y,
								 slots[slot].w,slots[slot].h);
		wind_open(h,slots[slot].x,slots[slot].y,slots[slot].w,
					slots[slot].h);
		slots[slot].used = slots[slot].open = TRUE;
		slots[slot].kind = kind;
		g_varset(h);
		}
	return(slot);
	}
	
void g_rast(int *x,int *y,int rx,int ry)
	{
	*x -= *x % rx;
	*y -= *y % ry;
	}

int g_anz_rect(int handle)
	{
	register i = 1,slot = g_find_handle(handle);
	int d,w,h,fw,fh;
	
	if(slot == NO_WIND) return NO_WIND;
	wind_get(handle,WF_FIRSTXYWH,&d,&d,&w,&h);
	fw = w,fh = h;
	for(;;)
		{
		wind_get(handle,WF_NEXTXYWH,&d,&d,&w,&h);
		if(!(w && h)) break;
		i++;
		}
	if(i == 1 && (fw != slots[slot].workw || fh != slots[slot].workh))
		i = INT_MAX;
	return i;
	}
	
void g_calc_redraw(int h,int v,void (*a1f)(int v))	
	{
	t2.g_x = msgbuff[4];
	t2.g_y = msgbuff[5];
	t2.g_w = msgbuff[6];
	t2.g_h = msgbuff[7];
	wind_get(h,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while(t1.g_w && t1.g_h)
		{
		if(rc_intersect(&t2,&t1))
			{
			g_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h,TRUE);
			a1f(v);
			}
		wind_get(h,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
		}	
	g_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h,FALSE);
	}
	
int g_wind_close(int h)
	{
	int slot = g_find_handle(h);
	
	if(slot != NO_WIND && slots[slot].used && slots[slot].open)
		{
		form_dial(FMD_SHRINK,slots[slot].x / 2,slots[slot].y / 2,
		slots[slot].w / 2,slots[slot].h / 2,slots[slot].x,
		slots[slot].y,slots[slot].w,slots[slot].h);
		
		wind_close(h);
		slots[slot].full = slots[slot].open = FALSE;
		}
	return(slot);
	}
				 
int g_full_window(int h)
	{
	int slot = g_find_handle(h);
	int x,y,w,hi;
	int kind = slots[slot].kind;
	
	if(slot != NO_WIND && slots[slot].used && slots[slot].open 
														   && kind & FULLER)
		{
		if(slots[slot].full)
			{
			wind_get(h,WF_PREVXYWH,&x,&y,&w,&hi);
			form_dial(FMD_SHRINK,x,y,w,hi,slots[slot].x,slots[slot].y,
								   slots[slot].w,slots[slot].h);
			}
		else
			{
			wind_get(h,WF_FULLXYWH,&x,&y,&w,&hi);
			graf_growbox(slots[slot].x,slots[slot].y,slots[slot].w,
						 slots[slot].h,x,y,w,hi);
			}
		wind_set(h,WF_CURRXYWH,x,y,w,hi);
		g_varset(h);
		}				 					   
	return(slot);
	}					 

void g_redraw(int slot,void(*a1f)(int v))	
	{
	g_calc_redraw(slots[slot].handle,slot,a1f);
	}

void g_top(int slot)
	{
	wind_set(slots[slot].handle,WF_TOP,slots[slot].handle,0,0,0);
	}
	
void g_wclose(int slot)
	{
	g_wind_close(slots[slot].handle);
	}
	
void g_full(int slot)
	{
	g_full_window(slots[slot].handle);
	g_slidesize(slots[slot].handle);
	g_sldpos(slots[slot].handle);
	g_windcset(slots[slot].handle,W_VSLIDE|W_HSLIDE|W_VSLSIZE|W_HSLSIZE);
	}

void g_rfull(int slot,int rx,int ry,int rw,int rh)
	{
	int x,y,w,hi;
	int flag = slots[slot].kind;
	
	if(slots[slot].rfull)
		{
		wind_get(slots[slot].handle,WF_PREVXYWH,&x,&y,&w,&hi);
		form_dial(FMD_SHRINK,x,y,w,hi,slots[slot].x,slots[slot].y,
							   slots[slot].w,slots[slot].h);
		}
	else
		{
		wind_get(slots[slot].handle,WF_FULLXYWH,&x,&y,&w,&hi);
		graf_growbox(slots[slot].x,slots[slot].y,slots[slot].w,
					 slots[slot].h,x,y,w,hi);
		}
	wind_calc(1,flag,x,y,w,hi,&x,&y,&w,&hi);	
	g_rast(&x,&y,rx,ry);
	g_rast(&w,&hi,rw,rh);
	wind_calc(0,flag,x,y,w,hi,&x,&y,&w,&hi);
	x = x < x_desk ? x + rx : x;
	y = y < y_desk ? y + ry : y;
	w = x + w > x_desk + w_desk ? w - rw : w;
	hi = y + hi > y_desk + h_desk ? hi - rh : hi;
	wind_set(slots[slot].handle,WF_CURRXYWH,x,y,w,hi);
	g_varset(slots[slot].handle);
	g_slidesize(slots[slot].handle);
	g_sldpos(slots[slot].handle);
	g_windcset(slots[slot].handle,W_VSLIDE|W_HSLIDE|W_VSLSIZE|
												W_HSLSIZE);
	slots[slot].rfull ^= 1;
	}		
	
void g_hslide(int slot,void(*a1f)(void))
	{
	slots[slot].hslide = msgbuff[4];
	wind_set(slots[slot].handle,WF_HSLIDE,slots[slot].hslide,0,0,0);
	g_windpos(slots[slot].handle);
	if(slots[slot].hslrast)
		slots[slot].fwx -= slots[slot].fwx % slots[slot].hslrast;
	g_sldpos(slots[slot].handle);
	wind_set(slots[slot].handle,WF_HSLIDE,slots[slot].hslide);
	a1f();
	}
	
void g_vslide(int slot,void(*a1f)(void))
	{
	slots[slot].vslide = msgbuff[4];
	wind_set(slots[slot].handle,WF_VSLIDE,slots[slot].vslide,0,0,0);
	g_windpos(slots[slot].handle);
	if(slots[slot].vslrast)
		slots[slot].fwy -= slots[slot].fwy % slots[slot].vslrast;
	g_sldpos(slots[slot].handle);
	wind_set(slots[slot].handle,WF_VSLIDE,slots[slot].vslide);
	a1f();
	}

void g_size(int slot,int min_w,int min_h,int rx,int ry)
	{
	int flag = slots[slot].kind;
	
	if(msgbuff[6] < min_w) msgbuff[6] = min_w;
	if(msgbuff[7] < min_h) msgbuff[7] = min_h;
	slots[slot].w = msgbuff[6];
	slots[slot].h = msgbuff[7];
	wind_calc(TRUE,flag,slots[slot].x,slots[slot].y,msgbuff[6],
			msgbuff[7],&slots[slot].workx,&slots[slot].worky,
			&slots[slot].workw,&slots[slot].workh);
	g_rast(&slots[slot].workw,&slots[slot].workh,rx,ry);
	wind_calc(FALSE,flag,slots[slot].workx,slots[slot].worky,
			slots[slot].workw,slots[slot].workh,&slots[slot].x,
			&slots[slot].y,&slots[slot].w,&slots[slot].h);
	g_slidesize(slots[slot].handle);
	g_sldpos(slots[slot].handle);
	g_windcset(slots[slot].handle,W_VSLIDE|W_HSLIDE|W_HSLSIZE|
									W_VSLSIZE|W_CURRXYWH);
	g_varset(slots[slot].handle);
	}
				 
int g_init(int anz,int x,int y,int w,int h,int kind)
	{
	WIND nullinit =	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,NULL,0,0,0,0,0,0,0,0,NULL};
	int i,slot;

	ap_id = appl_init();
	vdi_handle = phys_handle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
	for(i = 0;i < 10;work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk(work_in,&vdi_handle,work_out);
	swidth = work_out[0],shight = work_out[1];
	vq_extnd(vdi_handle,1,work_out);
	nplanes = work_out[4];
	vqt_attributes(vdi_handle,work_out);
	gl_wchar = work_out[6];
	gl_hchar = work_out[7];
	gl_wbox  = work_out[8];
	gl_hbox  = work_out[9];
	vst_height(vdi_handle,13,&charw,&charh,&cw,&ch);
	vst_rotation(vdi_handle,0);
	vst_font(vdi_handle,1);
	vst_effects(vdi_handle,0);
	graf_mouse(HOURGLASS, 0x0L);
	wind_get (DESK,WF_WORKXYWH,&x_desk,&y_desk,&w_desk,&h_desk);
	if(x == -1) x = x_desk;
	if(y == -1) y = y_desk;
	if(w == -1) w = w_desk;
	if(h == -1) h = h_desk;
	for(i = 0;i < W_ANZ;i++) slots[i] = nullinit;
	for(i = 0;i < anz;i++)
		if((slot = g_find_new_slot()) == NO_WIND ||
		(slots[slot].handle = wind_create(kind,x,y,w,h)) == FALSE)
			return(i); 	
		else
			{
			slots[slot].kind = kind;
			slots[slot].used = TRUE;
			}
	return(NO_WIND);
	}		
	
int g_rsrc_init(char *name)
	{
	rsrc_free();
	while(!rsrc_load(name))
		if(form_alert
	(2,"[3][ Resource - Datei | nicht gefunden][ABBRUCH|WEITER]") == 1)
			return(FALSE);
	return(TRUE);				
	}

void g_mouse(int flag)
	{
	if(flag == TRUE)
		v_show_c(vdi_handle,FALSE);
	else
		v_hide_c(vdi_handle);
	}		

void g_update(int flag)
	{
	if(flag == TRUE)
		wind_update(BEG_UPDATE);
	else
		wind_update(END_UPDATE);
	g_mouse(flag ^ TRUE);
	}		

void g_clip(int x,int y,int x2,int y2,int flag)
	{
	pxyarray[0] = x < 0 ? 0 : (x >= swidth ? swidth - 1 : x);
	pxyarray[1] = y < 0 ? 0 : (y >= shight ? shight - 1 : y);
	pxyarray[2] = x2 < 0 ? 0 : (x2 >= swidth ? swidth - 1 : x2);
	pxyarray[3] = y2 < 0 ? 0 : (y2 >= shight ? shight - 1 : y2);
	if(pxyarray[0] > pxyarray[2]) pxyarray[0] = pxyarray[2];
	if(pxyarray[1] > pxyarray[3]) pxyarray[1] = pxyarray[3];
	vs_clip(vdi_handle,flag,pxyarray);
	}

int g_multi(int flag,int (*a1f)(void),int (*b1f)(void),int (*c1f)(void),
			int (*d1f)(void),int (*e1f)(void),int (*f1f)(void),
			int (*g1f)(void),int (*h1f)(void),int (*i1f)(void),
			int (*j1f)(void),int (*k1f)(int evt))
	{
	int done = FALSE;
	
	do
		{
		event = evnt_multi(flag,mclicks,bmask,bstate,m1flag,m1x,m1y,m1w,
						   m1h,m2flag,m2x,m2y,m2w,m2h,msgbuff,lowcount,
						   hicount,&mox,&moy,&mobutton,&mokstate,&kreturn,
						   &breturn);
		g_update(TRUE);
		if(event & MU_MESAG)
			switch(msgbuff[0])
				{
				case MN_SELECTED:	done = a1f();
									break;
				case WM_REDRAW  :	done = b1f();
									break;
				case WM_TOPPED	:
				case WM_NEWTOP	:	done = c1f();
									break;
				case WM_CLOSED	:	done = d1f();
									break;
				case WM_FULLED	:	done = e1f();
									break;
				case WM_ARROWED : 	done = f1f();
									break;
				case WM_HSLID	:	done = g1f();
									break;
				case WM_VSLID	: 	done = h1f();
									break;
				case WM_SIZED	:	done = i1f();
									break;
				case WM_MOVED	:	done = j1f();
									break;
				default			:   done = k1f(event);		
				}																																 			  	 
		else
			done = k1f(event);
		} while(!done); 
	return(done);
	}		
				
void g_invert_state(OBJECT *objc,int index,int flag)
	{
	(objc + index) -> ob_state ^= flag;
	}

int g_hndl_dial(OBJECT *objc,int o,int (*a1f)(int ex))
	{
	int e,x,y,b,h;
	
	form_center(objc,&x,&y,&b,&h);
	form_dial(FMD_GROW,300,180,40,40,x,y,b,h);
	form_dial(FMD_START,x,y,b + 5,h + 5,x,y,b + 5,h + 5);
	objc_draw(objc,0,8,x,y,b + 5,h + 5);
	do
		;
	while(a1f(e = form_do(objc,o) & 0x7FFF));
		
	form_dial(FMD_SHRINK,300,180,40,40,x,y,b,h);
	form_dial(FMD_FINISH,x,y,b + 5,h + 5,x,y,b,h);
	return (e & 0x7FFF);
	}

int g_dummy(void)
	{
	g_update(FALSE);
	return(FALSE);
	}
					   
int g_cwindows(void)
	{
	int i,k = 0;
	
	for(i = 0;i < W_ANZ;i++)
		if(slots[i].used)
			{
			k++;
			if(slots[i].open)
				wind_close(slots[i].handle);
			wind_delete(slots[i].handle);
			slots[i].open = slots[i].used = FALSE;
			}	
	return(k);
	}
	
void g_exit(void)
	{
	g_cwindows();
	rsrc_free();
	v_clsvwk(vdi_handle);
	appl_exit();
	}				