/* 					GLIB LIBRARY MODUL 2 12.10.1992					*/

#include <stdio.h>
#include <aes.h>
#include <vdi.h>
#include <stdlib.h>
#include <string.h>

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

typedef struct
	{
	int 	im_version,im_headlength,im_nplanes;
	int		im_patlen,im_pixwidth,im_pixheight,im_scanwidth,im_nlines;
	} IMGHEADER;

extern WIND slots[W_ANZ];
extern GRECT t1,t2;
extern int wh,icx,icy,charw,charh,cw,ch;
extern int gl_wchar,gl_hchar,gl_wbox,gl_hbox;
extern int phys_handle,vdi_handle;
extern int x_desk,y_desk,w_desk,h_desk;
extern int msgbuff[8];
extern int mox,moy,mokstate,mobutton,mclicks,bmask,bstate,breturn;
extern int kstate,kreturn;
extern int cntrl[12],initin[128],ptsin[128],intout[128],ptsout[128];
extern int work_in[11],work_out[57],pxyarray[10];
extern int event,m1flag,m2flag,m1x,m1y,m1w,m1h,m2x,m2y,m2w,m2h,mreturn;
extern int lowcount,hicount;
extern int timeinfo;

extern int rc_intersect(GRECT *rc1,GRECT *rc2);
extern void g_newdesk(OBJECT *desk,int startob,int depth,int flag);
extern void g_deskdraw(OBJECT *desk,int startob,int depth);
extern void g_icondraw(int h,OBJECT *icon,int startob,int depht);
extern void g_rubberbox(OBJECT *tree,int startob,int depth,int x,int y,
			   int w,int h,int xstep,int ystep,int flag);
extern void g_swap(int *a,int *b);
extern int  g_test(int x,int y,int w,int h,OBJECT *desk,int d);
extern int g_icon(OBJECT *icon,int index,int startob,int depth,
			int x,int y,int clicks,int flag,
			OBJECT *desk,int dstartob,int ddepth,
			int ix,int iy,int iw,int ih);
extern void g_c_wind(int x,int y,int w,int h);
extern void g_cwork(int h);
extern int g_find_new_slot(void);
extern int g_find_slot(void);
extern int g_find_handle(int h);
extern void g_slidesize(int h);
extern void g_sldpos(int h);
extern void g_windpos(int h);
extern void g_scroll(int x,int y,int w,int h,int anz,int dir,int flag); 
extern int g_windcset(int h,int flag);
extern int g_varset(int h);
extern int g_wind_open(int h,int kind);
extern void g_rast(int *x,int *y,int rx,int ry);
extern int g_anz_rect(int h);
extern void g_calc_redraw(int h,int v,void (*a1f)(int v));
extern int g_wind_close(int h);
extern int g_full_window(int h);
extern void g_redraw(int slot,void(*a1f)(int v));
extern void g_top(int slot);
extern void g_wclose(int slot);
extern void g_full(int slot);
extern void g_rfull(int slot,int rx,int ry,int rw,int rh);
extern void g_hslide(int slot,void(*a1f)(void));
extern void g_vslide(int slot,void(*a1f)(void));
extern void g_size(int slot,int min_w,int min_h,int rx,int ry);
extern int g_init(int anz,int x,int y,int w,int h,int kind);
extern int g_rsrc_init(char *name);
extern void g_mouse(int flag);
extern void g_update(int flag);
extern void g_clip(int x,int y,int x2,int y2,int flag);
extern int g_multi(int flag,int (*a1f)(void),int (*b1f)(void),int (*c1f)(void),
			int (*d1f)(void),int (*e1f)(void),int (*f1f)(void),
			int (*g1f)(void),int (*h1f)(void),int (*i1f)(void),
			int (*j1f)(void),int (*k1f)(int evt));
extern void g_invert_state(OBJECT *objc,int index,int flag);
extern int g_hndl_dial(OBJECT *objc,int o,int (*a1f)(int ex));
extern int g_dummy(void);
extern int g_cwindows(void);
extern void g_exit(void);

static int all_slot;
void (*all_a1f)(int slot);
void (*all_b1f)(void);
int nplanes = 1;
			
void g_arrow(int slot,void(*a1f)(int slot),void(*b1f)(void));
int g_structset(int handle,int full,int open,int used,int x,
				int y,int w,int h,int rfull,int workx,int worky,
				int workw,int workh,int xa,int ya,int hslide,
				int vslide,int hslrast,int vslrast,int xstep,int ystep,int hslsize,
				int vslsize,long dw,long dh,long fdx,long fdy,long fwx,
				long fwy,char *name,char *info,int *free,void *freeptr);
void g_move(int slot,int rx,int ry);
char *g_get(int x,int y,int w,int h);
void g_put(char *addr,int x,int y,int w,int h);
int g_popup_menu(int x,int y,OBJECT *tree,int startob,int depth);
int g_windall(void);
int g_dialdummy(int e);
void g_owind(int slot,int kind);
void *g_load_image(register unsigned char *img,
		register IMGHEADER *hdr);

void g_arrow(int slot,void(*a1f)(int slot),void(*b1f)(void))
	{
	int whole;
	
	switch(msgbuff[4])
		{
		case WA_UPPAGE	:
		case WA_UPLINE	: if(!slots[slot].fwy) 
							return;
						  break;		
		case WA_DNPAGE	:
		case WA_DNLINE	: if(slots[slot].fwy + slots[slot].workh >= 
							slots[slot].dh)
							return;
						  break;
		case WA_LFPAGE	:
		case WA_LFLINE	: if(!slots[slot].fwx)
							return;
				 		 break;
		case WA_RTPAGE	:
		case WA_RTLINE	: if(slots[slot].fwx + slots[slot].workw >= 
							slots[slot].dw)
							return;
				  		break;
		}
	whole = g_anz_rect(slots[slot].handle) - 1;
	switch(msgbuff[4])
		{
		case WA_UPLINE:
				if(slots[slot].fwy - slots[slot].ystep >= slots[slot].fdy)
					{
					slots[slot].fwy -= slots[slot].ystep;
					if(!whole)
						{
						g_scroll(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].ya,
							slots[slot].workw - slots[slot].xa,
							slots[slot].workh - slots[slot].ya - 
							slots[slot].ystep,slots[slot].ystep,DOWN,
								SFLAG);
						g_clip(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].ya,
							slots[slot].workx + slots[slot].workw - 1,
							slots[slot].worky + slots[slot].ya + 
							slots[slot].ystep,TRUE);
						a1f(slot);			
						g_clip(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].ya,
							slots[slot].workx + slots[slot].workw - 1,
							slots[slot].worky + slots[slot].ya + 
							slots[slot].ystep,FALSE);
						}
					else b1f();
					}
				else if(slots[slot].vslsize < 1000)
					{
					slots[slot].fwy = slots[slot].fdy;
					b1f();
					}
				g_sldpos(slots[slot].handle);
				wind_set(slots[slot].handle,WF_VSLIDE,slots[slot].vslide,0,0,0);	
				break;
		case WA_DNLINE:	
				if(slots[slot].fwy + slots[slot].workh - 
					slots[slot].ya- 1 + slots[slot].ystep <= 
					slots[slot].fdy + slots[slot].dh - 1)
					{
					slots[slot].fwy += slots[slot].ystep;
					if(!whole)
						{
						g_scroll(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].ya 
							+ slots[slot].ystep,
							slots[slot].workw - slots[slot].xa,
							slots[slot].workh - slots[slot].ya - 
							slots[slot].ystep,
						    slots[slot].ystep,UP,SFLAG);
						g_clip(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].workh - 
							slots[slot].ystep - 1,
							slots[slot].workx + slots[slot].workw - 1,
							slots[slot].worky + slots[slot].workh - 1,
							TRUE);
						a1f(slot);			
						g_clip(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].workh - 
							slots[slot].ystep - 1,
							slots[slot].workx + slots[slot].workw - 1,
							slots[slot].worky + slots[slot].workh - 1,
							FALSE);
						}
					else b1f();
					}
				else if(slots[slot].vslsize < 1000)
					{
					slots[slot].fwy = slots[slot].fdy + slots[slot].dh
								    - slots[slot].workh 
								    + slots[slot].ya;
					b1f();
					}			   	
				g_sldpos(slots[slot].handle);
				wind_set(slots[slot].handle,WF_VSLIDE,slots[slot].vslide,0,0,0);
				break;
		case WA_UPPAGE:	
				slots[slot].fwy -= slots[slot].workh + slots[slot].ya;
				slots[slot].fwy = (slots[slot].fwy < slots[slot].fdy) 
					? slots[slot].fdy : slots[slot].fwy;
				g_sldpos(slots[slot].handle);
				b1f();
				wind_set(slots[slot].handle,WF_VSLIDE,slots[slot].vslide,0,
																	   0,0);
				break;
		case WA_DNPAGE:	
				slots[slot].fwy += slots[slot].workh - slots[slot].ya;
				slots[slot].fwy = (slots[slot].fwy + slots[slot].workh
				 - slots[slot].ya > slots[slot].fdy + slots[slot].dh) 
				? slots[slot].fdy + slots[slot].dh - slots[slot].workh
				+ slots[slot].ya : slots[slot].fwy;
				g_sldpos(slots[slot].handle);
				b1f();
				wind_set(slots[slot].handle,WF_VSLIDE,slots[slot].vslide,0,0,0);
				break;	
		case WA_LFLINE:	
				if(slots[slot].fwx - slots[slot].xstep >= 
													slots[slot].fdx)
					{
					slots[slot].fwx -= slots[slot].xstep;
					if(!whole)
						{
						g_scroll(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].ya,
							slots[slot].workw - slots[slot].xa - 
							slots[slot].xstep,slots[slot].workh - 
							slots[slot].ya,slots[slot].xstep,RIGHT,SFLAG);
						g_clip(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].ya,
							slots[slot].workx + slots[slot].xa + 
							slots[slot].xstep,
							slots[slot].worky + slots[slot].workh - 1,
							TRUE);
						a1f(slot);			
						g_clip(slots[slot].workx + slots[slot].xa,
							slots[slot].worky + slots[slot].ya,
							slots[slot].workx + slots[slot].xa + 
							slots[slot].xstep,
							slots[slot].worky + slots[slot].workh - 1,
							FALSE);
						}
					else b1f();
					}
				else if(slots[slot].hslsize < 1000)
					{
					slots[slot].fwx = slots[slot].fdx;
					b1f();
					}
				g_sldpos(slots[slot].handle);
				wind_set(slots[slot].handle,WF_HSLIDE,slots[slot].hslide,0,0,0);	
				break;
		case WA_RTLINE:	
				if(slots[slot].fwx + slots[slot].workw - 
					slots[slot].xa - 1 + slots[slot].xstep 
					<= slots[slot].fdx + slots[slot].dw - 1)
					{
					slots[slot].fwx += slots[slot].xstep;
					if(!whole)
						{
						g_scroll(slots[slot].workx + slots[slot].xa + 
							slots[slot].xstep,slots[slot].worky + 
							slots[slot].ya,slots[slot].workw - 
							slots[slot].xa - slots[slot].xstep,
							slots[slot].workh - slots[slot].ya,
							slots[slot].xstep,LEFT,SFLAG);
						g_clip(slots[slot].workx +
						 slots[slot].workw - slots[slot].xstep - 1,
						 slots[slot].worky + slots[slot].ya,
							slots[slot].workx + slots[slot].workw - 1,
							slots[slot].worky + slots[slot].workh - 1,
							TRUE);
						a1f(slot);			
						g_clip(slots[slot].workx +
						 slots[slot].workw - slots[slot].xstep - 1,
						 slots[slot].worky + slots[slot].ya,
							slots[slot].workx + slots[slot].workw - 1,
							slots[slot].worky + slots[slot].workh - 1,
							FALSE);
						}
					else b1f();
					}
				else if(slots[slot].hslsize < 1000)
					{
					slots[slot].fwx = slots[slot].fdx + 
							slots[slot].dw - slots[slot].workw 
							+ slots[slot].xa;
					b1f();
					}
				g_sldpos(slots[slot].handle);
				wind_set(slots[slot].handle,WF_HSLIDE,slots[slot].hslide,0,0,0);				   	
				break;
		case WA_LFPAGE:
				slots[slot].fwx -= slots[slot].workw + slots[slot].xa;
				slots[slot].fwx = (slots[slot].fwx < slots[slot].fdx) 
					? slots[slot].fdx : slots[slot].fwx;
				g_sldpos(slots[slot].handle);
				b1f();
				wind_set(slots[slot].handle,WF_HSLIDE,slots[slot].hslide,0,0,0);
				break;
		case WA_RTPAGE:	
				slots[slot].fwx += slots[slot].workw - slots[slot].xa;
				slots[slot].fwx = (slots[slot].fwx + slots[slot].workw
				- slots[slot].xa > slots[slot].fdx + slots[slot].dw)
			    ? slots[slot].fdx + slots[slot].dw - slots[slot].workw
				+ slots[slot].xa : slots[slot].fwx;
				g_sldpos(slots[slot].handle);
				b1f();
				wind_set(slots[slot].handle,WF_HSLIDE,slots[slot].hslide,0,0,0);
				break;
		}
	}				
				
int g_structset(int handle,int full,int open,int used,int x,int y,
				int w,int h,int rfull,int workx,int worky,int workw,
				int workh,int xa,int ya,int hslide,int vslide,
				int hslrast,int vslrast,int xstep,int ystep,
				int hslsize,int vslsize,long dw,long dh,long fdx,
				long fdy,long fwx,long fwy,char *name,
				char *info,int *free,void *freeptr)
	{
	long tf = FALSE,i;
	
	if(handle < 0)
		{
		tf = TRUE;
		handle = g_find_handle(handle);				
		}
	i = full >= 0 ? slots[handle].full = full : 0;
	i = rfull>= 0 ? slots[handle].rfull = rfull : 0;
	i = open >= 0 ? slots[handle].open = open : 0;
	i = used >= 0 ? slots[handle].used = used : 0;
	i = x    >= 0 ? slots[handle].x = x : 0;
	i = y    >= 0 ? slots[handle].y = y : 0;
	i = w    >= 0 ? slots[handle].w = w : 0;
	i = h    >= 0 ? slots[handle].h = h : 0;
	i = workx>= 0 ? slots[handle].workx = workx : 0;
	i = worky>= 0 ? slots[handle].worky = worky : 0;
	i = workw>= 0 ? slots[handle].workw = workw : 0;
	i = workh>= 0 ? slots[handle].workh = workh : 0;
	i = xa>= 0 ? slots[handle].xa = xa : 0;
	i = ya>= 0 ? slots[handle].ya = ya : 0;
	i = hslide>=0 ? slots[handle].hslide = hslide : 0;
	i = vslide>=0 ? slots[handle].vslide = vslide : 0;
	i = hslrast>= 0 ? slots[handle].hslrast = hslrast : 0;
	i = vslrast>= 0 ? slots[handle].vslrast = vslrast : 0;
	i = xstep>= 0 ? slots[handle].xstep = xstep : 0;
	i = ystep>= 0 ? slots[handle].ystep = ystep : 0;
	i = hslsize >= 0 || hslsize == -1 ? slots[handle].hslsize = 
									(long) hslsize : 0;
	i = vslsize >= 0 || vslsize == -1 ? slots[handle].vslsize =
									(long) vslsize : 0;
	slots[handle].dh = dh > 0 ? dh : 1;
	slots[handle].dw = dw > 0 ? dw : 1;
	i = fdx	>= 0 ? slots[handle].fdx = fdx : 0;
	i = fdy  >= 0 ? slots[handle].fdy = fdy : 0;
	i = fwx  >= 0 ? slots[handle].fwx = fwx : 0;
	i = fwy  >= 0 ? slots[handle].fwy = fwy : 0;
	name = name != NULL ? slots[handle].name = name : NULL;
	info = info != NULL ? slots[handle].info = info : NULL;
	if(free != NULL)
		for(i = 0;i < 8;i++)
			slots[handle].free[i] = *free++;
	freeptr = freeptr != NULL ? slots[handle].freeptr = freeptr :NULL;
	if(tf)
		return(handle);
	return(slots[handle].handle);				 															
	}

void g_move(int slot,int rx,int ry)
	{
	int flag = slots[slot].kind;
	
	slots[slot].x = msgbuff[4];
	slots[slot].y = msgbuff[5];
	wind_calc(TRUE,flag,slots[slot].x,slots[slot].y,msgbuff[6],
				msgbuff[7],&slots[slot].workx,&slots[slot].worky,
				&slots[slot].workw,&slots[slot].workh);
	g_rast(&slots[slot].workx,&slots[slot].worky,rx,ry);
	wind_calc(FALSE,flag,slots[slot].workx,slots[slot].worky,
				slots[slot].workw,slots[slot].workh,&slots[slot].x,
				&slots[slot].y,&slots[slot].w,&slots[slot].h);
	slots[slot].x = slots[slot].x < x_desk ? slots[slot].x + rx : 
														slots[slot].x;
	slots[slot].y = slots[slot].y < y_desk ? slots[slot].y + ry : 
														slots[slot].y;
	wind_set(slots[slot].handle,WF_CURRXYWH,slots[slot].x,
				slots[slot].y,slots[slot].w,slots[slot].h);
	g_varset(slots[slot].handle);
	}
char *g_get(int x,int y,int w,int h)
	{
	MFDB m1,m2;

	g_update(TRUE);
	m1.fd_addr = NULL;
	m2.fd_w = w;
	m2.fd_h = h;
	m2.fd_nplanes = nplanes;
	m2.fd_wdwidth = w / 16 + (w % 16 != 0);
	m2.fd_addr = malloc(m2.fd_nplanes * m2.fd_wdwidth * 2 * m2.fd_h);
	if(m2.fd_addr == NULL) return(NULL);
	pxyarray[0] = x,pxyarray[1] = y,pxyarray[2] = x + w - 1;
	pxyarray[3] = y + h - 1;
	pxyarray[4] = 0,pxyarray[5] = 0,pxyarray[6] = w - 1;
	pxyarray[7] = h - 1;
	vro_cpyfm(vdi_handle,SFLAG,pxyarray,&m1,&m2);
	g_update(FALSE);
	return(m2.fd_addr);
	}

void g_put(char *addr,int x,int y,int w,int h)
	{
	MFDB m1,m2;

	g_update(TRUE);
	m1.fd_addr = NULL;
	m2.fd_w = w;
	m2.fd_h = h;
	m2.fd_nplanes = nplanes;
	m2.fd_wdwidth = w / 16 + (w % 16 != 0);
	m2.fd_addr = addr;
	pxyarray[0] = 0,pxyarray[1] = 0,pxyarray[2] = w - 1;
	pxyarray[3] = h - 1;
	pxyarray[4] = x,pxyarray[5] = y,pxyarray[6] = x + w - 1;
	pxyarray[7] = y + h - 1;
	vro_cpyfm(vdi_handle,SFLAG,pxyarray,&m2,&m1);
	g_update(FALSE);
	}

int g_popup_menu(int x,int y,OBJECT *tree,int startob,int depth)
	{
	int obj = NO_WIND,aobj = NO_WIND;
	int mx,my,mk,kk,h,w;
	char *buffer;

	g_update(TRUE);
	(tree + startob) -> ob_x = x;
	(tree + startob) -> ob_y = y;
	w = (tree + startob) -> ob_width + 10;
	h = (tree + startob) -> ob_height + 10;
	buffer = g_get(x - 5,y - 5,w,h);
	objc_draw(tree,startob,depth,x - 5,y - 5,w,h);		
	vswr_mode(vdi_handle,MD_XOR);
	vsf_interior(vdi_handle,2);
	vsf_style(vdi_handle,8);
	vsf_color(vdi_handle,1);
	g_update(FALSE);
	while(graf_mkstate(&mx,&my,&mk,&kk),mk)
		{
		obj = objc_find(tree,startob,depth,mx,my);
/*		if(mx + 16 >= x && my + 16 >= y && mx - 16 <= x + w - 1 && 
			my - 16 <= y + h - 1)
			v_hide_c(vdi_handle);
		else
			v_show_c(vdi_handle,0); */
		if(aobj != NO_WIND && aobj != obj)
			{
			pxyarray[0] = x + (tree + aobj) -> ob_x - 1;
			pxyarray[1] = y + (tree + aobj) -> ob_y - 1;
			pxyarray[2] = pxyarray[0] + (tree + aobj) -> ob_width + 1;
			pxyarray[3] = pxyarray[1] + (tree + aobj) -> ob_height + 1;
			v_hide_c(vdi_handle);
			v_bar(vdi_handle,pxyarray);
			v_show_c(vdi_handle,1);
			}
		if(obj != NO_WIND && obj != aobj)
			{
			if((tree + obj) -> ob_flags & SELECTABLE)
				{
				pxyarray[0] = x + (tree + obj) -> ob_x - 1;
				pxyarray[1] = y + (tree + obj) -> ob_y - 1;
				pxyarray[2] = pxyarray[0] + (tree + obj) -> ob_width + 1;
				pxyarray[3] = pxyarray[1] + (tree + obj) -> ob_height + 1;
				v_hide_c(vdi_handle);
				v_bar(vdi_handle,pxyarray);
				v_show_c(vdi_handle,1);
				}
			else
				obj = NO_WIND;
			}
		aobj = obj;
		}
	v_show_c(vdi_handle,0);
	g_put(buffer,x - 5,y - 5,w,h);
	free(buffer);
	return(obj);
	}

int g_windall(void)
	{
	all_slot = g_find_handle(msgbuff[3]);
	if(all_slot == NO_WIND) return(FALSE);
	switch(msgbuff[0])
		{
		case WM_REDRAW  :	g_redraw(all_slot,all_a1f);
							break;
		case WM_TOPPED	:
		case WM_NEWTOP	:	g_top(all_slot);
							break;
		case WM_CLOSED	:	g_wclose(all_slot);
							break;
		case WM_FULLED	:	g_full(all_slot);
							break;
		case WM_ARROWED : 	g_arrow(all_slot,all_a1f,all_b1f);
							break;
		case WM_HSLID	:	g_hslide(all_slot,all_b1f);
							break;
		case WM_VSLID	: 	g_vslide(all_slot,all_b1f);
							break;
		case WM_SIZED	:	g_size(all_slot,4 * cw,4 * ch,1,1);
							break;
		case WM_MOVED	:	g_move(all_slot,1,1);
							break;
		}
	g_update(FALSE);
	return(FALSE);
	}

int g_dialdummy(int e)
	{
	e++;
	return(FALSE);
	}
	
void g_owind(int slot,int kind)
	{
	int i = 0;
	
	slots[slot].kind = kind;
	if(kind & NAME) i |= W_NAME;
	if(kind & INFO) i |= W_INFO;
	g_wind_open(slots[slot].handle,kind);
	g_windcset(slots[slot].handle,i | W_CURRXYWH);
	g_varset(slots[slot].handle);
	g_slidesize(slots[slot].handle); 
	g_sldpos(slots[slot].handle);
	i = 0;
	if(kind & HSLIDE) i |= W_HSLIDE | W_HSLSIZE;
	if(kind & VSLIDE) i |= W_VSLIDE | W_VSLSIZE;
	g_windcset(slots[slot].handle,i);
	}

void *g_load_image(register unsigned char *img,
	register IMGHEADER *hdr)
	{
	register int anz_z,line,bpl;
	long bwpl;
	unsigned char *pb;

	*hdr = *(IMGHEADER *)img,(int *)img += hdr->im_headlength;
	bpl = (hdr->im_scanwidth >> 3) + ((hdr->im_scanwidth & 7) != 0);
	bwpl = bpl + ((bpl & 1) != 0);
	if((pb = (unsigned char *)malloc(bwpl * hdr->im_nlines)) == NULL)
		return NULL;
	for(line = 0;line < hdr->im_nlines;line += anz_z)
		{
		register long ngb = 0;
		
		if(!*img && !img[1l] && img[2l] == 255)
			anz_z = img[3l],img += sizeof(int) + 2;
		else anz_z = 1;
		do
			{
			register unsigned char lb;
			register int i;

			lb = *img++;
			if(lb == 0)
				{
				register int j;
				
				for(i = 0,lb = *img++;i < lb;i++)
					for(j = 0;j < hdr->im_patlen;j++)
						pb[ngb++] = img[j];
				img += 2;
				}
			else if(lb == 128)
				{
				for(i = 0,lb = *img++;i < lb;i++) pb[ngb++] = img[i];
				(unsigned char *)img += lb;
				}
			else if(lb & 128) 
				for(i = 0;i < (lb & ~128);i++) pb[ngb++] = ~0;
			else for(i = 0;i < lb;i++) pb[ngb++] = 0;
			} while(ngb < bpl);
		for(ngb = 1;ngb < anz_z && line + ngb < hdr->im_nlines;ngb++)
			memcpy(pb += bwpl,pb,bwpl);
		pb += bwpl;
		}
	return pb - bwpl * hdr->im_nlines;
	}