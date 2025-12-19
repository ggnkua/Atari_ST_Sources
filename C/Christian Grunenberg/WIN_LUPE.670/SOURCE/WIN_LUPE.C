
/* #define SPEED 1 */

#ifdef SPEED
long clock(void);
char string[80];
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <e_gem.h>

#define CICONBLK	ICONBLK

#ifdef GERMAN

#include "win_rsc.c"
#include "win_rsc.h"

#else

#include "english.c"
#include "english.h"

#endif

#define ELEMENTE NAME|CLOSER|SMALLER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|HSLIDE|LFARROW|RTARROW

struct mem
{
	void	*memory;
	void	*form;
} buf[2];

typedef struct
{
	int 	object[9],value[9];
	int 	shift,maske,faktor;
	int 	freq,dial;
	GRECT	border;
	int		xres,yres,mode;
} _setup_;

_setup_ Setup =
{
	{ REALTIME,MOUSE,WROUND,SLIDER,COMPT,INVERS,FOLLOW,BOXES,MONOFF },
	{ TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE},
	2,0,3,
	100,AUTO_DIAL,
	{0,0,0,0},
	0,0,0
};

#define INFO_LEN sizeof(_setup_)

extern char *help[];
extern int	help_lines;

WIN		*win;

int		vhandle;
int		p_faktor,longs,il_offset,lines,line_h,old_line = -1,first_line = 0,scroll;
int		z_x,z_y,z_w,z_h,xoff,yoff,open_cnt=0,new_freq,bytes,period;
long	last_time;

long	zoom_x,zoom_y,zoom_w,zoom_h;
long	tab_v[2048];
char	*ind_tab[256];
GRECT	rc_list[256];
int		w_max_w,w_max_h;

boolean valid;
DIAINFO	dialog_info,winlupe_info,help_info,opt_info,*return_info,*wins[8];

void	do_slide(OBJECT *,int,int,int,int);
void	do_help(OBJECT *,int,int,int,int);

#define SCANUP		(72<<8)
#define SCANDOWN	(80<<8)
#define SCANLEFT	(75<<8)
#define SCANRIGHT	(77<<8)
#define CTRLLEFT	(115<<8)
#define CTRLRIGHT	(116<<8)
#define SCANHOME	(71<<8)

SLKEY sl_help_keys[] = {
{ SCANUP, 0, SL_UP },
{ SCANDOWN, 0, SL_DOWN },
{ SCANUP, K_RSHIFT|K_LSHIFT, SL_PG_UP },
{ SCANDOWN, K_RSHIFT|K_LSHIFT , SL_PG_DN },
{ SCANUP, K_CTRL, SL_START },
{ SCANDOWN, K_CTRL, SL_END },
{ SCANHOME, 0, SL_START },
{ SCANHOME, K_RSHIFT|K_LSHIFT, SL_END} };

SLKEY sl_freq_keys[] = {
{ SCANLEFT, 0, SL_UP },
{ SCANRIGHT, 0, SL_DOWN },
{ CTRLLEFT, K_CTRL, SL_START },
{ CTRLRIGHT, K_CTRL, SL_END }};

SLINFO sl_help = {&help_info,HELPPAR,HELPSLID,HELPUP,HELPDOWN,0,0,0,
				  VERT_SLIDER,SL_LINEAR,100,0,do_help,&sl_help_keys[0],8};
SLINFO *sl_help_list[] = {&sl_help,NULL};

SLINFO sl_freq = {&opt_info,PARENT,SLIDE,LEFT,RIGHT,99,1,100,
				  HOR_SLIDER,SL_LINEAR,100,0,do_slide,&sl_freq_keys[0],4};
SLINFO *sl_freq_list[] = {&sl_freq,NULL};

MFDB	source,buffer,zoomfm,stdfm;
GRECT	window,old,zoom_area;
OBJECT	*dialog_tree,*info_tree,*help_tree,*opt_tree;

char	entry[]		= "  WinLupe 6.70 ";
char	*title		= entry+1;
char	*version	= entry+10;
char	*inf_file	= "A:\WIN_LUPE.INF";

#ifdef GERMAN

char	*init_err	= "[1][ | Fehler bei der | Initialisierung ! ][ Ok ]";

char	*win_err	= "Konnte kein Fenster|”ffnen!]";
char	*work_err	= "Konnte keine Work-|station ”ffnen!]";
char	*mem_err	= "Nicht genug Speicher|fr Bildschirmpuffer!";
char	*file_err	= "Konnte WIN_LUPE.INF|nicht ”ffnen!";
char	*rw_error	= "Schreib-/Lesefehler!";

#else

char	*init_err	= "[1][ | Error during | initialisation ! ][ Ok ]";

char	*win_err	= "No more windows|available!";
char	*work_err	= "Couldn't open|workstation!";
char	*mem_err	= "Not enough memory!";
char	*file_err	= "Couldn't read|WIN_LUPE.INF!";
char	*rw_error	= "Read-/Write-Error!";

#endif

int cdecl	 draw_help(PARMBLK *);
USERBLK		 helpblk = {draw_help,0};

void	zoom_var(int,int,int,int *,long *);
void	zoom_inter(int,int,int,int *,long *);
void	zoom_pixel(int,int,int,int *,long *);
void	init_zoom_var(void);
void	init_zoom_pixel(int,int);
long	cache_flush(void);

boolean alloc_buf(long,struct mem *);
void	init_mfdb(int,int,int,void *,MFDB *);
void	planes_tab(int);
void	open_lupewindow(void);
void	close_lupewindow(int);
void	draw_window(GRECT *);
void	calc_coords(boolean);
void	set_slider(boolean,boolean,boolean);
void	wind_size(GRECT *);
void	dialog(void);
void	l_min(long *,long);
void	mouse_pos(long *,long *,int);
void	scale(int *,int,int);
void	load_info(void);
void	save_info(void);
int		do_messag(XEVENT *);
int		init_msg(XEVENT *,int);
void	get_value(boolean);
void	set_value(boolean);
void	dia_close(int);
void	calc_xy(void);
void	calc_wh(void);
void	val_2_str(char *,int);
void	calc_vars(void);
void	slider_pos(void);
void	set_window(boolean);
void	exitus(void);
void	info(void);

void	open_dial(OBJECT *,DIAINFO *,int,int);
void	close_dial(DIAINFO *);
int		error(char *);

int error(char *txt)
{
	return (xalert(1,0,X_ICN_ERROR,NULL,BUTTONS_CENTERED,TRUE,title,txt,"[Ok"));
}

boolean alloc_buf(long size,struct mem *buf)
{
	register long adr;

	if ( (adr = (long) malloc(size)) > 0L )
	{
		buf->memory = (void *) adr;
		adr	 		= (adr+255) & 0xffffff00L;
		buf->form	= (void *) adr;
		return(TRUE);
	}
	return(FALSE);
}

void init_mfdb(int w,int h,int std,void *buf,MFDB *mfdb)
{
	mfdb->fd_addr 	= buf;
	mfdb->fd_w		= w;
	mfdb->fd_h		= h;
	mfdb->fd_wdwidth= w>>4;
	mfdb->fd_stand	= std;
}

void open_lupewindow()
{
	register long size;
	register int fkt,wid,hei;
	int d,x_res,y_res,x_max=0,y_max=0;

	wind_calc(WC_WORK,ELEMENTE,desk.g_x,desk.g_y,desk.g_w,desk.g_h,&d,&d,&x_res,&y_res);
	for (fkt=2;fkt<=32;fkt++)
	{
		wid  = x_res/fkt;
		wid += 15;
		wid &= 0xfff0;
		wid *= fkt;
		if (wid>x_max)
			x_max = wid;
		hei  = ((y_res+fkt-1)/fkt)*fkt;
		if (hei>y_max)
			y_max = hei;
	}

	size  = wid>>3;
	size *= (long) y_max;
	size *= (long) planes;
	size += 1024;

	if (alloc_buf(size,&buf[0])==TRUE)
	{
		if (alloc_buf(size,&buf[1])==TRUE)
		{
			int work_out[57];
			if (open_work(&vhandle,work_out))
			{
				vs_clip (vhandle,1,(int *) &clip);

				calc_vars();
				wind_calc(WC_WORK,ELEMENTE,Setup.border.g_x,Setup.border.g_y,Setup.border.g_w,Setup.border.g_h,
	 			 		  &window.g_x,&window.g_y,&window.g_w,&window.g_h);
	 			xoff = window.g_x - Setup.border.g_x;
	 			yoff = window.g_y - Setup.border.g_y;
	 			calc_wh();
				calc_coords(TRUE);

				if ((win=open_window(title,NULL,ELEMENTE,Setup.value[7],Setup.border.g_x,Setup.border.g_y,Setup.border.g_w,Setup.border.g_h))!=NULL)
				{
					if (menu_available)
						menu_ienable(menu,OPEN,0);

					if ((Setup.value[0]==TRUE) && (Setup.value[6]==TRUE))
						mouse_pos(&zoom_x,&zoom_y,TRUE);
					else
						zoom_x = zoom_y = z_x = z_y = 0;

					valid	= FALSE;
					old.g_x = -1;
					set_slider(FALSE,TRUE,FALSE);
					return;
				}
				else
				{
					close_work(vhandle);
					error(win_err);
				}
			}
			else
				error(work_err);
			free(buf[1].memory);
			free(buf[0].memory);
			return;
		}
		else
			free(buf[0].memory);
	}
	error(mem_err);
}

void close_lupewindow(int close)
{
	if (win!=NULL)
	{
		if (close)
			close_window(win,Setup.value[7]);
		win = NULL;

		close_work(vhandle);

		free(buf[1].memory);
		free(buf[0].memory);

		if (menu_available)
			menu_ienable(menu,OPEN,1);
	}
}

void calc_coords(boolean size)
{
	register int max;

	if (window.g_x < (max = desk.g_x + 16 + xoff))
		window.g_x = max;
	window.g_x &= 0xfff0;

	if (Setup.shift<5)
	{
		window.g_w &= 0xfff0;
		window.g_h &= Setup.maske;
	}
	else
	{
		switch (p_faktor)
		{
		case 2:
		case 4:
		case 8:
		case 16:
			window.g_w &= 0xfff0;
			break;
		case 6:
		case 12:
		case 24:
			window.g_w = ((window.g_w/3) & 0xfff8)*3;
			break;
		case 32:
			window.g_w &= 0xffe0;
			break;
		default:
			window.g_w -= window.g_w % p_faktor;
			break;
		}
		window.g_h -= window.g_h % p_faktor;
	}

	if (window.g_w<96)
		window.g_w = 96;

	while (window.g_h<96)
		window.g_h += p_faktor;

	wind_calc(WC_BORDER,ELEMENTE,window.g_x,window.g_y,window.g_w,window.g_h,
			  &Setup.border.g_x,&Setup.border.g_y,&Setup.border.g_w,&Setup.border.g_h);

	if (size==TRUE)
	{
		register int max = desk.g_x + desk.g_w - 1 - Setup.border.g_x;
		while (Setup.border.g_w>=max)
		{
			window.g_w -= p_faktor;
			Setup.border.g_w -= p_faktor;
		}

		max = desk.g_y + desk.g_h - 1 - Setup.border.g_y;
		while (Setup.border.g_h>=max)
		{
			window.g_h -= p_faktor;
			Setup.border.g_h -= p_faktor;
		}
	}
}

void set_slider(boolean flag,boolean slide,boolean size)
{
	register int max;

	if (flag==TRUE && Setup.value[2]==TRUE)
	{
		calc_coords(size);
		if (!(win->iconified & (ICONIFIED|ICFS)))
			wind_set(win->handle,WF_CURRXYWH,Setup.border.g_x,
			         Setup.border.g_y,Setup.border.g_w,Setup.border.g_h);
	}
	else
		wind_get(win->handle,WF_CURRXYWH,&Setup.border.g_x,
				 &Setup.border.g_y,&Setup.border.g_w,&Setup.border.g_h);
	calc_wh();

	l_min(&zoom_x,(long) w_max_w * (long) p_faktor);
	l_min(&zoom_y,(long) w_max_h * (long) p_faktor);
	calc_xy();

	max=(z_w+15) & 0xfff0;

	init_mfdb(max,z_h,0,buf[0].form,&buffer);
	init_mfdb(max,z_h,1,buf[1].form,&stdfm);
	if (Setup.shift<5)
		init_mfdb(max<<Setup.shift,z_h<<Setup.shift,1,buf[0].form,&zoomfm);
	else
		init_mfdb(max*p_faktor,z_h*p_faktor,1,buf[0].form,&zoomfm);

	source.fd_addr	= buf[1].form;
	source.fd_w		= zoomfm.fd_w;
	source.fd_h		= zoomfm.fd_h;
	source.fd_wdwidth = zoomfm.fd_wdwidth;
	source.fd_stand	= 0;

	if (!(win->iconified & (ICONIFIED|ICFS)))
	{
		if ((Setup.value[3]==TRUE) || (Setup.value[0]==FALSE) || (Setup.value[6]==FALSE))
		{
			register long pos;

			slider_pos();

			pos	= 1000 * (long) window.g_w;
			pos	/= zoom_w;
			wind_set(win->handle,WF_HSLSIZE,(int) pos);

			pos = 1000 * (long) window.g_h;
			pos	/= zoom_h;
			wind_set(win->handle,WF_VSLSIZE,(int) pos);
		}
		else if (slide==TRUE)
		{
			wind_set(win->handle,WF_HSLIDE,0);
			wind_set(win->handle,WF_VSLIDE,0);
			wind_set(win->handle,WF_HSLSIZE,1000);
			wind_set(win->handle,WF_VSLSIZE,1000);
		}
	}
}

void slider_pos()
{
	register long max,pos;

	l_min(&zoom_x,(max = (long) w_max_w * (long) p_faktor));
	pos 		= 1000 * zoom_x;
	pos 		/= max;
	wind_set(win->handle,WF_HSLIDE,(int) pos);

	l_min(&zoom_y,(max = (long) w_max_h * (long) p_faktor));
	pos			= 1000 * zoom_y;
	pos			/= max;
	wind_set(win->handle,WF_VSLIDE,(int) pos);
}

void calc_wh()
{
	z_w=(window.g_w+p_faktor-1);
	z_h=(window.g_h+p_faktor-1);

	if (Setup.shift<5)
	{
		z_w >>= Setup.shift;
		z_h >>= Setup.shift;
	}
	else
	{
		z_w /= p_faktor;
		z_h /= p_faktor;
	}

	w_max_w = max_w - z_w + 1;
	w_max_h = max_h - z_h + 1;
}

void calc_xy()
{
	register long x=zoom_x,y=zoom_y;

	if (Setup.shift<5)
	{
		x >>= Setup.shift;
		y >>= Setup.shift;
	}
	else
	{
		x /= p_faktor;
		y /= p_faktor;
	}

	z_x = (int) x;
	z_y = (int) y;
}

void draw_window(GRECT *area)
{
	int		 pxy[8],d;
	GRECT 	 work,wind = *area,mouse;
	register GRECT *w_ptr = &work;
	register int x,y,w,h,rc_idx = 0,*ptr;
	boolean	 update = (Setup.value[4]==TRUE || Setup.value[0]==FALSE);
	boolean	 hidem = (Setup.value[0]==FALSE || Setup.value[8]==TRUE),hidden;

	#ifdef SPEED
	long alltime = clock(),time;
	#endif

	if (update)
		wind_update(BEG_UPDATE);

	ptr = &(rc_list[0].g_x);
	wind_get(win->handle,WF_FIRSTXYWH,ptr,ptr+1,ptr+2,ptr+3);
	while ((ptr[2]>0) && (ptr[3]>0))
	{
		if (win->iconified & (ICONIFIED|ICFS))
			redraw_iconified(win->handle,iconified,(GRECT *) ptr);
		else
		{
			ptr += 4;
			rc_idx++;
		}
		wind_get(win->handle,WF_NEXTXYWH,ptr,ptr+1,ptr+2,ptr+3);
	}

	if (!(win->iconified & (ICONIFIED|ICFS)))
	{
		if (valid==FALSE)
		{
			register int wid=(z_w+15)>>4,idx=rc_idx;
			register int *orig;
			register long *copy;
			GRECT zoom;
	
			ptr = pxy;
			*ptr++ = z_x;
			*ptr++ = z_y;
			*ptr++ = z_x+z_w-1;
			*ptr++ = z_y+z_h-1;
			*ptr++ = 0;
			*ptr++ = 0;
			*ptr++ = z_w-1;
			*ptr   = z_h-1;
	
			if (pxy[2]>max_w)
			{
				pxy[0] -= pxy[2]-max_w;
				pxy[2]	= max_w;
			}
	
			if (pxy[3]>max_h)
			{
				pxy[1] -= pxy[3]-max_h;
				pxy[3]	= max_h;
			}
	
			if (Setup.value[1])
				vro_cpyfm(vhandle,3,pxy,screen,&buffer);
			else
			{
				graf_mouse(M_OFF,0L);
				vro_cpyfm(vhandle,3,pxy,screen,&buffer);
				graf_mouse(M_ON,0L);
			}
	
			zoom.g_x = z_x;
			zoom.g_y = z_y;
			zoom.g_w = z_w;
			zoom.g_h = z_h;
			rc_intersect(&zoom_area,&zoom);
			while (--idx>=0)
			{
				work = rc_list[idx];
				if (rc_intersect(&zoom,w_ptr))
				{
					ptr = pxy;
					*ptr++ = pxy[4] = w_ptr->g_x - z_x;
					*ptr++ = pxy[5] = w_ptr->g_y - z_y;
					*ptr++ = pxy[6] = pxy[0] + w_ptr->g_w - 1;
					*ptr   = pxy[7] = pxy[1] + w_ptr->g_h - 1;
					vro_cpyfm(vhandle,0,pxy,&buffer,&buffer);
				}
			}
	
			if (Setup.mode)
			{
				orig = (int *)  buf[0].form;
				copy = (long *) buf[1].form;
			}
			else
			{
				orig = (int *)  buf[1].form;
				copy = (long *) buf[0].form;
				vr_trnfm(vhandle,&buffer,&stdfm);
			}
	
			#ifdef SPEED
			time = clock();
			#endif
	
			switch (Setup.mode)
			{
			case 2:
				if (planes<8)
					zoom_var(wid*planes,z_h,1,orig,copy);
				else
					zoom_pixel(wid,z_h,bytes,orig,copy);
				break;
			case 3:
				zoom_inter(wid,z_h,planes,orig,copy);
				break;
			default:
				zoom_var(wid,z_h,planes,orig,copy);
			}
	
			#ifdef SPEED
			time = clock() - time;
			sprintf(string,"Zoom : %d ms",(int) (time*5));
			v_gtext(vhandle,0,32,string);
			#endif
	
			if (!Setup.mode)
				vr_trnfm(vhandle,&zoomfm,&source);
			valid = TRUE;
		}

		rc_intersect(&zoom_area,&wind);
		while (--rc_idx>=0)
		{
			w_ptr = &rc_list[rc_idx];
			if (rc_intersect(&wind,w_ptr))
			{
				x = w_ptr->g_x-window.g_x;
				y = w_ptr->g_y-window.g_y;
				w = w_ptr->g_w-1;
				h = w_ptr->g_h-1;
	
				ptr = pxy;
				*ptr++	= x;
				*ptr++	= y;
				*ptr++	= x+w;
				*ptr++	= y+h;
				*ptr++	= w_ptr->g_x;
				*ptr++	= w_ptr->g_y;
				*ptr++	= w_ptr->g_x+w;
				*ptr	= w_ptr->g_y+h;
	
				if (hidem)
					graf_mouse(M_OFF,0l);
				else
				{
					graf_mkstate(&mouse.g_x,&mouse.g_y,&d,&d);
					mouse.g_x -= 32; mouse.g_y -= 32;
					mouse.g_w = mouse.g_h = 64;
					if (mouse.g_x<0)
					{
						mouse.g_w += mouse.g_x;
						mouse.g_x  = 0;
					}
					if (mouse.g_y<0)
					{
						mouse.g_h += mouse.g_y;
						mouse.g_y  = 0;
					}
					if (rc_intersect(w_ptr,&mouse))
					{
						hidden = TRUE;
						graf_mouse(M_OFF,0l);
					}
					else
						hidden = FALSE;
				}
				vro_cpyfm(vhandle,3,pxy,&source,screen);
				if (hidem || hidden)
					graf_mouse(M_ON,0l);
			}
		}
	}

	if (update)
		wind_update(END_UPDATE);

	#ifdef SPEED
	alltime = clock() - alltime;
	sprintf(string,"All : %d ms",(int) (alltime*5));
	v_gtext(vhandle,120,32,string);
	#endif
}

int init_msg(XEVENT *evt,int available)
{
	if (win!=NULL && !win->iconified && Setup.value[0] && (available & MU_TIMER2) && get_dialog_info(NULL,NULL,NULL)==TRUE)
	{
		evt->ev_mt2hicount = 0;
		evt->ev_mt2locount = period;
		evt->ev_mt2last = last_time;
		return (MU_MESAG|MU_KEYBD|MU_TIMER2);
	}
	else
		return (MU_MESAG|MU_KEYBD);
}

void open_dial(OBJECT *tree,DIAINFO *info,int center,int dial)
{
	SLINFO **slider;
	wins[open_cnt++] = info;

	if (info==&opt_info)
		slider = sl_freq_list;
	else if (info==&help_info)
		slider = sl_help_list;
	else
		slider = NULL;
	open_dialog(tree,info,title,center,(center<0) ? FALSE : Setup.value[7],dial,0,slider);
}

void close_dial(DIAINFO *info)
{
	register int i;

	for (i=0;i<open_cnt;i++)
		if (wins[i]==info)
			break;
	open_cnt--;
	for (;i<open_cnt;i++)
		wins[i] = wins[i+1];

	close_dialog(info,Setup.value[7]);
}

void dia_close(int button)
{
	close_dial(return_info);
	opt_tree[button].ob_state &= ~DISABLED;
	ob_draw_chg(&opt_info,button,NULL,FAIL,FALSE);
}

void do_slide(OBJECT *obj,int pos,int prev,int max_pos,int top)
{
	new_freq=sl_freq.sl_pos+1;
	val_2_str(obj->ob_spec.tedinfo->te_ptext,new_freq);
}

int cdecl draw_help(PARMBLK *pb)
{
	register int cnt_lines,start_line = first_line,delta_lines = (first_line>old_line) ? (first_line - old_line) : (old_line - first_line);
	register int x = pb->pb_x,y = pb->pb_y;

	v_set_text(small_font_id,small_font,-1,NULL);
	if (!scroll || (pb->pb_y+pb->pb_h)>max_h || delta_lines>=(lines-3) || delta_lines<=0)
		cnt_lines = lines;
	else
	{
		register GRECT source;
		register int dy = delta_lines*line_h;

		source.g_x = x;
		source.g_y = y;
		source.g_w = pb->pb_w;
		source.g_h = pb->pb_h - dy;

		if (first_line>old_line)
		{
			source.g_y += dy;
			rc_sc_copy(&source,x,y,3);
			if (pb->pb_hc>pb->pb_h)
				start_line += lines - delta_lines;
			else
			{
				start_line += ((pb->pb_yc + pb->pb_hc - y)/line_h)-delta_lines;
				delta_lines++;
			}
		}
		else
		{
			rc_sc_copy(&source,x,y + dy,3);
			if (pb->pb_hc<=pb->pb_h)
			{
				start_line += (pb->pb_yc - y)/line_h;
				delta_lines++;
			}
		}

		start_line = max(start_line,first_line);
		cnt_lines = min(delta_lines,help_lines-start_line);

		if (start_line-first_line+cnt_lines>lines)
			cnt_lines = lines-start_line+first_line;
	}

	{
		register GRECT clear;
		register int index;

		y += (start_line-first_line)*line_h;

		clear.g_x = x;
		clear.g_y = y;
		clear.g_w = pb->pb_w;
		clear.g_h = cnt_lines*line_h;
		rc_intersect((GRECT *) &pb->pb_x,&clear);
		rc_sc_clear(&clear);

		for (index=cnt_lines;--index>=0;y += line_h)
			v_gtext(x_handle,x,y,help[start_line++]);
	}
	return(0);
}

void do_help(OBJECT *obj,int pos,int prev,int max_pos,int top)
{
	old_line = first_line;
	first_line = pos;

	scroll = top;
	ob_draw_chg(&help_info,HELPVIEW,NULL,FAIL,top);
	scroll = FALSE;
}

void calc_vars()
{
	zoom_x = z_x;
	zoom_y = z_y;
	zoom_w = max_w+1;
	zoom_h = max_h+1;

	if (Setup.shift<5)
	{
		p_faktor = 1<<Setup.shift;

		zoom_x <<= Setup.shift;
		zoom_y <<= Setup.shift;
		zoom_w <<= Setup.shift;
		zoom_h <<= Setup.shift;
	}
	else
	{
		p_faktor = Setup.faktor;

		zoom_x  *= p_faktor;
		zoom_y  *= p_faktor;
		zoom_w  *= p_faktor;
		zoom_h  *= p_faktor;
	}

	longs = (p_faktor*(p_faktor-1))>>1;
	il_offset = (planes*(p_faktor-1))<<1;

	if (Setup.mode==2)
	{
		if (planes<8)
			planes_tab(planes);
		else
		{
			long cpu;

			bytes = (planes+7)>>3;
			init_zoom_pixel(bytes,Setup.value[5]);

			if (get_cookie('_CPU',&cpu)==TRUE && cpu>=20)
				Supexec(cache_flush);
		}
	}
	else
		planes_tab(1);

	Setup.maske  = ~(p_faktor-1);
}

void dialog()
{
	if (!open_cnt)
	{
		register int obj,double_click;

		open_dial(dialog_tree,&dialog_info,TRUE,Setup.dial);
		do
		{
			double_click = 0;
			obj = X_Form_Do(&return_info);

			if (obj==W_ABANDON)
				break;
			else if (obj!=W_CLOSED)
			{
				double_click = (obj & 0x8000);
				obj ^= double_click;
				return_info->di_tree[obj].ob_state &= ~SELECTED;
			}

			if (return_info==&winlupe_info)
				dia_close(INFOBUT);
			else if (return_info==&help_info)
				dia_close(HELP);
			else if (return_info==&opt_info)
			{
				switch (obj)
				{
				case INFOBUT:
				case HELP:
					opt_tree[obj].ob_state |= DISABLED;
					ob_draw_chg(&opt_info,obj,NULL,FAIL,FALSE);
					if (obj==INFOBUT)
						open_dial(info_tree,&winlupe_info,TRUE,(Setup.dial!=FLY_DIAL) ? (AUTO_DIAL|MODAL) : FLY_DIAL);
					else
						open_dial(help_tree,&help_info,TRUE,Setup.dial);
					break;
				default:
					if (obj!=OPTCANCL)
						get_value(FALSE);
					else
						set_value(FALSE);
					calc_vars();

					if (obj==OPTSET)
					{
						set_window(FALSE);
						ob_draw_chg(&opt_info,OPTSET,NULL,FAIL,FALSE);
					}
					else if (obj==SAVE)
					{
						if (dialog_info.di_flag>CLOSED)
						{
							get_value(TRUE);
							calc_vars();
						}
						set_window(FALSE);
						save_info();
						ob_draw_chg(&opt_info,SAVE,NULL,FAIL,FALSE);
					}
					else
					{
						close_dial(return_info);
						dialog_tree[SONSTIGE].ob_state &= ~DISABLED;
						ob_draw_chg(&dialog_info,SONSTIGE,NULL,FAIL,FALSE);
						if (obj!=OPTCANCL && Setup.dial==AUTO_DIAL)
						{
							switch (dialog_info.di_flag)
							{
							case OPENED:
							case FLYING:
								close_dial(&dialog_info);
								open_dial(dialog_tree,&dialog_info,FAIL,Setup.dial);
								set_window(FALSE);
								break;
							}
						}
					}
				}
			}
			else
			{
				switch (obj)
				{
				case SONSTIGE:
					dialog_tree[SONSTIGE].ob_state |= DISABLED;
					ob_draw_chg(&dialog_info,SONSTIGE,NULL,FAIL,FALSE);
					open_dial(opt_tree,&opt_info,TRUE,Setup.dial);
					break;
				case CANCEL:
					close_dial(return_info);
					set_value(FAIL);
					calc_vars();
					set_window(FALSE);
					break;
				default:
					get_value(TRUE);
					calc_vars();

					if (win==NULL)
					{
						if (obj==OKAY)
						{
							if (return_info->di_flag<WINDOW)
								close_dial(return_info);
							open_lupewindow();
						}

						if (obj!=SET)
							close_dial(return_info);
					}
					else
					{
						if (obj!=SET)
							close_dial(return_info);
						set_window(obj==SET ? FALSE : TRUE);
					}

					if (obj==SET)
					{
						ob_draw_chg(&dialog_info,SET,NULL,FAIL,FALSE);
						ob_draw_chg(&dialog_info,FAKTOR,NULL,FAIL,FALSE);
					}
				}
			}
		} while (open_cnt>0);
		dialog_tree[SONSTIGE].ob_state &= ~DISABLED;
		opt_tree[INFOBUT].ob_state &= ~DISABLED;
		opt_tree[HELP].ob_state &= ~DISABLED;
		if (obj==W_ABANDON)
			set_value(TRUE);
		open_cnt = 0;
	}
	else if (dialog_info.di_flag==WINDOW)
		wind_set(dialog_info.di_win->handle,WF_TOP);
	else if (dialog_info.di_flag==CLOSED)
		open_dial(dialog_tree,&dialog_info,TRUE,Setup.dial);
}

void set_window(boolean top)
{
	if (win!=NULL && get_dialog_info(NULL,NULL,NULL)==TRUE)
	{
		if ((Setup.value[0]==TRUE) && (Setup.value[6]==TRUE))
			mouse_pos(&zoom_x,&zoom_y,TRUE);
		valid = FALSE;
		if (top==TRUE)
			wind_set(win->handle,WF_TOP);
		set_slider(TRUE,TRUE,TRUE);
		draw_window(&window);
	}
}

void planes_tab(int planes)
{
	register long zoom;
	register char *mem = (char *) tab_v,**ind = ind_tab;
	register int act,faktor,pixel,plane = planes,bits = 8;
	int		 maske,index,bit,byte,shift = 8-plane,offset = p_faktor & 0x01;
	boolean	 flag = Setup.value[5];

	{
		long cpu;
		init_zoom_var();
		if (get_cookie('_CPU',&cpu)==TRUE && cpu>=2)
			Supexec(cache_flush);
	}

	maske = ((1<<plane)-1)<<shift;
	for (index=0;index<256;index++)
	{
		*ind++  = mem;
		byte	= index;
		zoom = act = 0;

		if (flag)
			for(bit=bits;(bit-=plane)>=0;)
			{
				pixel = ((byte & maske)^maske)>>shift;
				byte <<= plane;

				for (faktor=p_faktor;--faktor>=0;)
				{
					zoom <<= plane;
					zoom  |= pixel;

					act += plane;
					while (act>=bits)
						*mem++	= (char) (zoom >> (act-=bits));
				}
			}
		else
			for(bit=bits;(bit-=plane)>=0;)
			{
				pixel = (byte & maske)>>shift;
				byte <<= plane;

				for (faktor=p_faktor;--faktor>=0;)
				{
					zoom <<= plane;
					zoom  |= pixel;

					act += plane;
					while (act>=bits)
						*mem++	= (char) (zoom >> (act-=bits));
				}
			}
		mem	+= offset;
	}
}

void get_value(boolean flag)
{
	if (flag==TRUE)
	{
		register int i;
		register char *num;

		Setup.shift = ob_radio(dialog_tree,PFAKTOR,FAIL) + 1;
		for (i=0;i<=8;i++)
			Setup.value[i] = (dialog_tree[Setup.object[i]].ob_state & SELECTED) ? TRUE : FALSE;

		num = dialog_tree[FAKTOR].ob_spec.tedinfo->te_ptext;i=0;
		while (*num)
		{
			i *= 10;
			i += (*num++) - 48;
		}
		if (i<2)
			Setup.faktor = 2;
		else if (i>32)
			Setup.faktor = 32;
		else
			Setup.faktor = i;
		val_2_str(dialog_tree[FAKTOR].ob_spec.tedinfo->te_ptext,Setup.faktor);
		p_faktor = Setup.faktor;
	}
	else
	{
		Setup.mode = ob_radio(opt_tree,PZMODE,FAIL);
		Setup.dial = (opt_tree[WIND].ob_state & SELECTED) ? AUTO_DIAL : FLY_DIAL;
		Setup.freq = new_freq;
		period = (1000/new_freq)-9;
	}
}

void val_2_str(char *d,int val)
{
	register int div;

	if ((div=val/100)>0)
	{
		*d++ = (char) (div + 48);
		*d++ = (char) (((val -= div*100)/10) + 48);
	}
	else if ((div=val/10)>0)
		*d++ = (char) (div + 48);
	*d++ = (char) ((val % 10) + 48);
	*d = 0;
}

void set_value(boolean all)
{
	if (all)
	{
		register int i;

		new_freq = Setup.freq;

		ob_radio(dialog_tree,PFAKTOR,Setup.shift-1);
		for(i=0;i<=8;i++)
		{
			if (Setup.value[i])
				dialog_tree[Setup.object[i]].ob_state |= SELECTED;
			else
				dialog_tree[Setup.object[i]].ob_state &= ~SELECTED;
		}
		val_2_str(dialog_tree[FAKTOR].ob_spec.tedinfo->te_ptext,Setup.faktor);
	}

	if (all>=0)
	{
		ob_radio(opt_tree,PZMODE,Setup.mode);

		opt_tree[WIND].ob_state &= ~SELECTED;
		opt_tree[FLY].ob_state &= ~SELECTED;

		if (Setup.dial==AUTO_DIAL)
			opt_tree[WIND].ob_state |= SELECTED;
		else
			opt_tree[FLY].ob_state |= SELECTED;

		opt_info.di_tree = opt_tree;
		help_info.di_tree = help_tree;

		sl_freq.sl_pos = Setup.freq-1;
		val_2_str(opt_tree[SLIDE].ob_spec.tedinfo->te_ptext,Setup.freq);
		period = (1000/new_freq)-9;

		graf_set_slider(&sl_freq,opt_tree,GRAF_SET);
		graf_set_slider(&sl_help,help_tree,GRAF_SET);
	}
}

void exitus()
{
	close_lupewindow(TRUE);

	while (--open_cnt>=0)
		close_dialog(wins[open_cnt],FALSE);

	if (_app)
	{
		menu_bar(menu,0);
		exit_gem();
		Pterm(0);
	}
}

void info()
{
	if (winlupe_info.di_flag>=WINDOW)
		wind_set(winlupe_info.di_win->handle,WF_TOP);
	else if (winlupe_info.di_flag==CLOSED)
	{
		if (open_cnt>0)
		{
			if (opt_info.di_flag>CLOSED)
			{
				opt_tree[INFOBUT].ob_state |= DISABLED;
				ob_draw_chg(&opt_info,INFOBUT,NULL,FAIL,FALSE);
			}
			open_dial(info_tree,&winlupe_info,TRUE,(Setup.dial!=FLY_DIAL) ? (AUTO_DIAL|MODAL) : FLY_DIAL);
		}
		else 
			xdialog(info_tree,title,TRUE,Setup.value[7],(Setup.dial!=FLY_DIAL) ? (AUTO_DIAL|MODAL) : FLY_DIAL);
	}
}

int do_messag(XEVENT *event)
{
	register int ev = event->ev_mwich,speed,*msg = event->ev_mmgpbuf;
	register int used = 0;

	long max,new_pos;
	int	v_h,pos;

	if (ev & MU_TIMER2)
	{
		last_time = event->ev_mt2last;

		if (Setup.value[6]==TRUE)
		{
			long x = event->ev_mmox,y = event->ev_mmoy;

			mouse_pos(&x,&y,FALSE);
			if ((x!=zoom_x) || (y!=zoom_y))
			{
				zoom_x = x;zoom_y = y;
				if ((Setup.value[3]==TRUE) || (Setup.value[0]==FALSE) || (Setup.value[6]==FALSE))
					slider_pos();
			}
		}

		valid = FALSE;
		draw_window(&window);
	}

	if (ev & MU_MESAG)
	{
		used |= MU_MESAG;

		switch (*msg)
		{
		case MN_SELECTED:
			menu_tnormal(menu,msg[3],1);
			switch (msg[4])
			{
			case INFOBOX:
				info();
				break;
			case SETUP:
				dialog();
				return(used);
			case QUIT:
				exitus();
				break;
			case OPEN:
				if (win==NULL)
				{
					get_value(TRUE);
					open_lupewindow();
				}
				break;
			}
			break;
		case AP_TERM:
		case AC_CLOSE:
			close_lupewindow(*msg==AP_TERM);
			break;
		case AC_OPEN:
			dialog();
			return(used);
		case WIN_CHANGED:
			if (win!=NULL && !win->iconified)
				set_slider(FALSE,TRUE,FALSE);
			break;
		case WM_REDRAW:
			draw_window((GRECT *) (msg+4));
			break;
		case WM_TOPPED:
			wind_set(win->handle,WF_TOP);
			break;
		case WM_BOTTOMED:
			wind_set(win->handle,WF_BOTTOM);
			break;
		case WM_CLOSED:
			close_lupewindow(TRUE);
			break;
		case WM_FULLED:
			{
				if (old.g_x>=desk.g_x && old.g_y>=desk.g_y &&
					 old.g_w<=desk.g_w && old.g_h<=desk.g_h)
				{
					wind_size(&old);
					old.g_x = -1;
				}
				else
				{
					old	= Setup.border;
					wind_size(&desk);
				}
				valid = FALSE;
				set_slider(TRUE,FALSE,TRUE);
			}
			break;
		case WM_ARROWED:
			if ((Setup.value[0]==FALSE) || (Setup.value[6]==FALSE))
			{
				max = p_faktor;
				switch(msg[4])
				{
				case WA_UPPAGE:
				case WA_DNPAGE:
				case WA_UPLINE:
				case WA_DNLINE:
				 	max	*= (long) w_max_h;
					v_h = TRUE;
					break;
				default:
					max	*= (long) w_max_w;
					v_h = FALSE;
					break;
				}

				for (;;)
				{
					speed = (winx && msg[5]<0) ? -msg[5] : 1;

					switch(msg[4])
					{
					case WA_UPPAGE:
						zoom_y -= window.g_h*speed;
						if (zoom_y<0) zoom_y=0;
						break;
					case WA_DNPAGE:
					  	zoom_y += window.g_h*speed;
						l_min(&zoom_y,max);
						break;
					case WA_UPLINE:
					  	zoom_y -= p_faktor*speed;
						if (zoom_y<0) zoom_y=0;
						break;
					case WA_DNLINE:
					  	zoom_y += p_faktor*speed;
						l_min(&zoom_y,max);
						break;
					case WA_LFPAGE:
					  	zoom_x -= window.g_w*speed;
						if (zoom_x<0) zoom_x=0;
						break;
					case WA_RTPAGE:
					  	zoom_x += window.g_w*speed;
						l_min(&zoom_x,max);
						break;
					case WA_LFLINE:
					  	zoom_x -= p_faktor*speed;
						if (zoom_x<0) zoom_x=0;
						break;
					case WA_RTLINE:
					  	zoom_x += p_faktor*speed;
						l_min(&zoom_x,max);
						break;
					}

					if (winx && msg[7]<0)
					{
						msg[4] = msg[6];
						msg[5] = msg[7];
						msg[7] = 0;
					}
					else
						break;
				}

				if (v_h == TRUE)
				{
					new_pos			= 1000 * zoom_y;
					new_pos			/= max;
					wind_set(win->handle,WF_VSLIDE,(int) new_pos);
				}
				else
				{
					new_pos			= 1000 * zoom_x;
					new_pos			/= max;
					wind_set(win->handle,WF_HSLIDE,(int) new_pos);
				}
				valid = FALSE;
				calc_xy();
				draw_window(&window);
			}
			break;
		case WM_HSLID:
			if ((Setup.value[0] == FALSE) || (Setup.value[6]==FALSE))
			{
				pos = msg[4];
				wind_set(win->handle,WF_HSLIDE,pos);
				zoom_x=(int) (((long) (zoom_w-window.g_w)*pos)/1000);
				valid = FALSE;
				calc_xy();
				draw_window(&window);
			}
			break;
		case WM_VSLID:
			if ((Setup.value[0] == FALSE) || (Setup.value[6]==FALSE))
			{
				pos = msg[4];
				wind_set(win->handle,WF_VSLIDE,pos);
				zoom_y=(int) (((long) (zoom_h-window.g_h)*pos)/1000);
				valid = FALSE;
				calc_xy();
				draw_window(&window);
			}
			break;
		case WM_MOVED:
		case WM_SIZED:
			wind_size((GRECT *) (msg+4));
			old.g_x = -1;
			valid	= FALSE;
			set_slider(TRUE,FALSE,*msg==WM_MOVED ? FALSE : TRUE);
			break;
		default:
			used &= ~MU_MESAG;
		}
	}

	if (ev & MU_KEYBD)
	{
		int ascii = scan_2_ascii(event->ev_mkreturn,event->ev_mmokstate);

		if (event->ev_mmokstate & K_ALT)
		{
			if (ascii=='P')
			{
				used |= MU_KEYBD;
				dialog();
				return(used);
			}
		}
		else if (event->ev_mmokstate & K_CTRL)
		{
			used |= MU_KEYBD;

			switch (ascii)
			{
			case 'I':
				info();
				break;
			case 'Q':
				exitus();
				break;
			case 'O':
				if (win==NULL)
				{
					get_value(TRUE);
					open_lupewindow();
				}
				break;
			default:
				used &= ~MU_KEYBD;
			}
		}
	}

	return (used);
}

void wind_size(GRECT *new)
{
	wind_calc(WC_WORK,ELEMENTE,new->g_x,new->g_y,new->g_w,new->g_h,
 		 			&window.g_x,&window.g_y,&window.g_w,&window.g_h);
	if ((win->iconified & (ICONIFIED|ICFS)) && Setup.value[2]==FALSE)
		wind_set(win->handle,WF_CURRXYWH,new->g_x,new->g_y,new->g_w,new->g_h);
}

void l_min(register long *var,register long val)
{
	if ((*var)>val)
		*var = val;
}

void mouse_pos(register long *x,register long *y,int pos)
{
	int	sx,sy,dummy;

	if (pos)
	{
		graf_mkstate(&sx,&sy,&dummy,&dummy);
		*x = sx - (z_w>>1);
		*y = sy - (z_h>>1);
	}
	else
	{
		*x -= (z_w>>1);
		*y -= (z_h>>1);
	}

	if ((*x)<0)
		*x=0;
	else
		l_min(x,w_max_w);

	if ((*y)<0)
		*y=0;
	else
		l_min(y,w_max_h);

	z_x = (int) *x;
	z_y = (int) *y;

	if (Setup.shift<5)
	{
		*x <<= Setup.shift;
		*y <<= Setup.shift;
	}
	else
	{
		*x *= p_faktor;
		*y *= p_faktor;
	}
}

void scale(int *var,int omax,int nmax)
{
	register long new=*var;
	new	*= nmax;
	*var = (int) (new/omax);
}

void load_info()
{
	char file[256];
	int	 x_res = (max_w+16) & 0xfff0 , y_res = max_h+1;
 	int  w = desk.g_w>>1,h = (desk.g_h>>1)-4;

	dialog_tree	= (OBJECT *) rs_trindex[DIALOG];
	info_tree	= (OBJECT *) rs_trindex[INFODIA];
	help_tree	= (OBJECT *) rs_trindex[HELPDIA];
	opt_tree	= (OBJECT *) rs_trindex[OPTIONEN];
	menu		= (OBJECT *) rs_trindex[MENU];
	iconified	= (OBJECT *) rs_trindex[WINICON];

	info_tree[DATE].ob_spec.tedinfo->te_ptext = __DATE__;
	strcpy(ob_get_text(info_tree,VERS,0)+8,version);
	wind_calc(WC_WORK,ELEMENTE,desk.g_x+w,desk.g_y+h,w,h,&window.g_x,&window.g_y,&window.g_w,&window.g_h);

	{
		register OBJECT *obj = help_tree + HELPVIEW;
		register int i;

		line_h = gr_sh+2;
		obj->ob_type = G_USERDEF;
		obj->ob_spec.userblk = &helpblk;

		i = obj->ob_height;
		sl_help.sl_page = lines = (i/line_h)-1;
		sl_help.sl_max = help_lines;
		obj->ob_y += (i - (obj->ob_height = lines*line_h))>>1;

		obj = help_tree + HELPPAR;
		obj->ob_y++;
		obj->ob_height -= 2;
	}

	strcpy(file,inf_file+2);
	if (shel_find(file))
	{
		int handle = open(file,O_RDONLY);
		if (handle>0)
		{
			if (read(handle,&Setup,INFO_LEN)<INFO_LEN)
				error(rw_error);
			else
			{
				scale(&Setup.border.g_x,Setup.xres,x_res);
				scale(&Setup.border.g_y,Setup.yres,y_res);
				scale(&Setup.border.g_w,Setup.xres,x_res);
				scale(&Setup.border.g_h,Setup.yres,y_res);
				wind_calc(WC_WORK,ELEMENTE,Setup.border.g_x,Setup.border.g_y,
						  Setup.border.g_w,Setup.border.g_h,
 		 				  &window.g_x,&window.g_y,&window.g_w,&window.g_h);
			}
			close(handle);
		}
	}

	if (Setup.shift<5)
		p_faktor = 1<<Setup.shift;
	else
		p_faktor = Setup.faktor;
	Setup.maske	 = ~(p_faktor-1);
	calc_coords(FALSE);

	if (planes<8 && planes!=1 && planes!=2 && planes!=4)
	{
		opt_tree[PIXELPCK].ob_state |= DISABLED;
		if (Setup.mode==2)
			Setup.mode = 0;
	}

	set_value(TRUE);

	source.fd_nplanes = buffer.fd_nplanes = zoomfm.fd_nplanes = stdfm.fd_nplanes = planes;
	Setup.xres	= x_res; Setup.yres	= y_res;
	zoom_area.g_x = zoom_area.g_y = 0;
	zoom_area.g_w = max_w+1;
	zoom_area.g_h = max_h+1;
	dialog_info.di_flag = help_info.di_flag = winlupe_info.di_flag = CLOSED;
}

void save_info()
{
	int	 handle;
	char *file = inf_file;

	if (_app)
		file += 2;
	else
	{
		long ssp;

		ssp = Super(NULL);
		*file = (char) (*((int *) 0x446)+65);
		Super((void *) ssp);
	}

	if ((handle = open(file,O_WRONLY|O_CREAT)) > 0)
	{
		if (write(handle,&Setup,INFO_LEN)<INFO_LEN)
			error(rw_error);
		close(handle);
	}
	else
		error(file_err);
}

void main()
{
	#ifdef GERMAN
	if (init_gem(entry,"WinLupe\0XDSC\0"\
	                   "1Bildschirmlupe\0","WIN_LUPE",0,0,0)==TRUE)
	#else
	if (init_gem(entry,"WinLupe\0XDSC\0"\
	                   "1Magnifying glass\0","WIN_ENG",0,0,0)==TRUE)
	#endif
	{
		wind_update(BEG_UPDATE);

		Event_Handler(init_msg, do_messag);
		CycleCloseWindows('W','U',WECHSELN,CLOSE);

		dial_options(TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE);
		rsrc_init(NUM_TREE,NUM_OBS,NUM_FRSTR,NUM_FRIMG,TEST_SCALING|DARK_SCALING,rs_strings,rs_frstr,rs_bitblk,
				  rs_frimg,rs_iconblk,rs_tedinfo,rs_object,(OBJECT **) rs_trindex,(RS_IMDOPE *) rs_imdope,8,16);
		load_info();
		menu_install(menu,TRUE);

		wind_update(END_UPDATE);

		Event_Multi(NULL);
	}
	else
		form_alert(1,init_err);
}
