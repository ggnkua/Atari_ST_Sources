/*                    GLIB Version vom 21.7.1992                 */

#ifndef __GLIB
#define __GLIB
#include <stdio.h>
#include <aes.h>
#include <vdi.h>

#undef W_NAME
#undef W_INFO
#undef W_CURRXYWH
#undef W_HSLIDE
#undef W_VSLIDE
#undef W_TOP
#undef W_NEWDESK
#undef W_HSLSIZE
#undef W_VSLSIZE
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
extern int swidth,shight;
extern void (*all_a1f)(int slot);
extern void (*all_b1f)(void);
extern int nplanes;
				
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
extern int g_structset(int handle,int full,int open,int used,int x,
				int y,int w,int h,int rfull,int workx,int worky,
				int workw,int workh,int xa,int ya,int hslide,
				int vslide,int hslrast,int vslrast,int xstep,int ystep,int hslsize,
				int vslsize,long dw,long dh,long fdx,long fdy,long fwx,
				long fwy,char *name,char *info,int *free,void *freeptr);
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
extern void g_arrow(int slot,void(*a1f)(int slot),void(*b1f)(void));
extern void g_hslide(int slot,void(*a1f)(void));
extern void g_vslide(int slot,void(*a1f)(void));
extern void g_size(int slot,int min_w,int min_h,int rx,int ry);
extern void g_move(int slot,int rx,int ry);
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
extern char *g_get(int x,int y,int w,int h);
extern void g_put(char *addr,int x,int y,int w,int h);
extern int g_popup_menu(int x,int y,OBJECT *tree,int startob,int depth);
extern int g_windall(void);
extern int g_dialdummy(int e);
extern void g_owind(int slot,int kind);
extern void *g_load_image(register unsigned char *img,
				register IMGHEADER *hdr);
#endif