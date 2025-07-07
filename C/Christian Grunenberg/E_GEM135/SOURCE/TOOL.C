
#include <time.h>
#include "proto.h"

static int clipping_area[4];

char _upper(char ch)
{
	if (ch>='a')
	{
		if(ch>'z')
		{
			if (ch=='„')
				return('Ž');
			else if (ch=='”')
				return('™');
			else if (ch=='')
				return('š');
		}
		else
			return(ch-32);
	}

	return(ch);
}

char _lower(char ch)
{
	if (ch>='A')
	{
		if(ch>'Z')
		{
			if (ch=='Ž')
				return('„');
			else if (ch=='™')
				return('”');
			else if (ch=='š')
				return('');
		}
		else
			return(ch+32);
	}

	return(ch);
}

void _bitblt(OBJECT *tree,MFDB *form,boolean flag)
{
	reg int pxy[8],*ptr=pxy;
	reg int x = tree->ob_x - 3,y = tree->ob_y - 3;
	reg int w = tree->ob_width + 5,h = tree->ob_height + 5;
	
	graf_mouse(M_OFF,NULL);

	if (flag)
	{
		*ptr++ = x;
		*ptr++ = y;
		*ptr++ = x + w;
		*ptr++ = y + h;
		*ptr++ = 0;
		*ptr++ = 0;
		*ptr++ = w;
		*ptr   = h;
		vro_cpyfm(x_handle,3,pxy,screen,form);
	}
	else
	{
		*ptr++ = 0;
		*ptr++ = 0;
		*ptr++ = w;
		*ptr++ = h;
		*ptr++ = x;
		*ptr++ = y;
		*ptr++ = x + w;
		*ptr   = y + h;
		vro_cpyfm(x_handle,3,pxy,form,screen);
	}

	graf_mouse(M_ON,NULL);
}

void _line(int x1,int y1,int x2,int y2)
{
	reg int pxy[4];
	
	pxy[0] = x1;
	pxy[1] = y1;
	pxy[2] = x2;
	pxy[3] = y2;
	v_pline(x_handle,2,pxy);
}

void _bar(int x,int y,int w,int h,int interior,int color)
{
	reg int pxy[4];

	vsf_interior(x_handle,interior);
	vsf_color(x_handle,color);	
	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + w;
	pxy[3] = y + h;
	v_bar(x_handle,pxy);
}

void _rectangle(int sx,int sy,int dx,int dy)
{
	reg int pxy[10];

	pxy[0] = pxy[6] = pxy[8] = sx;
	pxy[1] = pxy[3] = pxy[9] = sy;
	pxy[2] = pxy[4] = dx;
	pxy[5] = pxy[7] = dy;
	v_pline(x_handle,5,pxy);
}

void _vdi_attr(int mode,int wid,int col)
{
	vswr_mode(x_handle,mode);
	vsl_width(x_handle,wid);
	vsl_color(x_handle,col);
}

void _text_attr(int font,int height,int color)
{
	int dummy;

	vst_font(x_handle,font);

	if (height>0)
		vst_height(x_handle,height,&dummy,&dummy,&dummy,&dummy);
	else
		vst_point(x_handle,-height,&dummy,&dummy,&dummy,&dummy);
	vst_color(x_handle,color);
}

void _beg_ctrl()
{
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
}

void _end_ctrl()
{
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

int _mouse_but(void)
{
	int but,dummy;

	if (!_back_win)
		graf_mkstate(&dummy,&dummy,&but,&dummy);
	else
		vq_mouse(x_handle,&but,&dummy,&dummy);

	return(but);
}

void _mouse_pos(reg int *x,reg int *y)
{
	int dummy;
	graf_mkstate(x,y,&dummy,&dummy);
}

void _no_click()
{
	int dummy;
	if (_mouse_but() & 1)
		evnt_button(1,1,0,&dummy,&dummy,&dummy,&dummy);
}

/*************************/

int min(int v_1,int v_2)
{
	if (v_1<v_2)
		return(v_1);
	else
		return(v_2);
}

int max(int v_1,int v_2)
{
	if (v_1>v_2)
		return(v_1);
	else
		return(v_2);
}

void Min(int *var,int val)
{
	if (*var>val)
		*var = val;
}

void Max(int *var,int val)
{
	if (*var<val)
		*var = val;
}

int scan_2_ascii(int scan,int state)
{
	reg KEYTAB *keytab = Keytbl((void *) -1l,(void *) -1l,(void *) -1l);

	if (state)
	{
		scan = (int) (((unsigned) scan)>>8);
		if ((scan>=120) && (scan<=131))
			scan -= 118;

		if (state & 3)
			scan = (int) *(keytab->shift+scan);
		else
			scan = (int) *(keytab->unshift+scan);
	}

	scan &= 0xff;
	if (scan>='a')
	{
		if (scan<='z')
			scan -= 32;
		else if (scan=='„')
			scan='Ž';
		else if (scan=='”')
			scan='™';
		else if (scan=='')
			scan='š';
	}
	return(scan);
}

void mfdb(MFDB *fm,int *adr,int w,int h,int st,int pl)
{
	fm->fd_addr		= adr;
	fm->fd_w		= (w+15) & 0xfff0;
	fm->fd_h		= h;
	fm->fd_wdwidth	= fm->fd_w>>4;
	fm->fd_stand	= st;
	fm->fd_nplanes	= pl;
}

long mfdb_size(MFDB *fm)
{
	return ((long) (fm->fd_wdwidth<<1) * (long) fm->fd_h * (long) fm->fd_nplanes);
}

int Event_Multi(EVENT *event,long last)
{
	reg int events;
	clock_t timer;

	if (event->ev_mflags & MU_TIMER)
	{
		clock_t interval;

		interval = event->ev_mthicount;
		interval <<= 16;
		interval |= event->ev_mtlocount;
		interval /= 5;

		if (last>0)
			timer = last + interval;
		else
			timer = clock() + interval;
	}

	do
	{
	 	events = EvntMulti(event);

		if ((events & MU_BUTTON) && _back_win && !event->ev_mbstate && !_bevent)
		{
			if (_mouse_but() & event->ev_bmask)
				events &= ~MU_BUTTON;
		}

		if ((event->ev_mflags & MU_TIMER) && !(events & MU_TIMER) && clock()>=timer)
			events |= MU_TIMER;
	} while(!events);

	return (events);
}

void rc_sc_clear(GRECT *dest)
{
	rc_sc_copy(dest,dest->g_x,dest->g_y,0);
}

void rc_sc_invert(GRECT *dest)
{
	rc_sc_copy(dest,dest->g_x,dest->g_y,D_INVERT);
}

void rc_sc_copy(GRECT *source,int dx,int dy,int mode)
{
	reg GRECT work = *source;

	if (rc_intersect(&desk,&work))
	{
		reg GRECT dest;

		dest.g_x = dx;
		dest.g_y = dy;
		dest.g_w = work.g_w;
		dest.g_h = work.g_h;
		
		if (rc_intersect(&desk,&dest))
		{
			reg int pxy[8];

			rc_grect_to_array(&work,pxy);
			rc_grect_to_array(&dest,pxy+4);
			vro_cpyfm(x_handle,mode,pxy,screen,screen);
		}
	}
}

void save_clipping(int *area)
{
	reg long *clip=(long *) clipping_area;

	*((long *) area)++ = *clip++;
	*((long *) area)++ = *clip++;
}

void restore_clipping(int *area)
{
	reg long *clip=(long *) clipping_area;

	vs_clip(x_handle,1,area);
	*clip++ = *((long *) area)++;
	*clip++ = *((long *) area)++;
}
