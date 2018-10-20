#include <stddef.h>
#include <aes.h>
#include <moddef.h>
#include "spiegeln.rsh"

#define otree (&rs_object[0])

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);
int		mirror(uchar *pp, int ww, GRECT *area);

int				global[80];

static MODULE_FN mod_fn=
{
	mod_init,
	mod_quit,
	do_function1,
	do_function2
};

static MODULEBLK mblock=
{
	"GRAPEMODULE",
	'0101',
	/* name */
	"1234567890123456789012345678901",

	/* CICONBLK */
	NULL,NULL,NULL,0,0,0,0,0,0,0,0,0,0,0,NULL,
	/* mask_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* data_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* name */
	0,0,
	/* CICON */
	0,NULL,NULL,NULL,NULL,NULL,
	/* col_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* bw_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	
	0,&mod_fn,
	
	/* Objekt-Tree+Service */
	otree,
	dservice,
	
	/* global */
	NULL,
	/* Grape-Functions */
	NULL,
	/* id */
	0
};

void main(void)
{
	appl_init();
	if(mblock.magic[0])
		form_alert(1,"[3][Ich bin ein Grape-Modul!][Abbruch]");
	appl_exit();
}

void cdecl mod_init(void)
{
	int a;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];
		
	otree[HOR].ob_state |= SELECTED;
	otree[VER].ob_state &=(~SELECTED);
}

void cdecl mod_quit(void)
{
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		case HOR:
		case VER:
			_G_ update_preview();
		break;
		case GO:
			_G_ do_me(_ID_);
			_G_ d_unsel(_ID_, GO);
		break;
	}
}

int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm)
{
	int w, h;
	uchar *c, *m, *y;
	
	w=l->word_width;
	h=l->height;
	
	if(mm)
	{
		c=mm->mask;
		m=y=NULL;
	}
	else
	{
		c=l->blue;
		m=l->red;
		y=l->yellow;
	}
	
	if(c||m||y)
	{
		if(!(_G_ undo_buf(area, l, mm, 1)))
			return(0);	/* Undo schlug fehl */

		return(do_function2(c,m,y,w,h,area,-1));
	}
	else
		return(0);
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	int r=0;
	
	if(c)
		r=mirror(c,w,area);
	if(m)
		r=mirror(m,w,area);
	if(y)
		r=mirror(y,w,area);
				
	return(r);
}

int mirror(uchar *pp, int ww, GRECT *area)
{
	register uchar *p, *p2, b;
	register int	w, wp;
	register long ldif, bdif;
	long start;
	register int x,y;
	
	start=(long)ww*(long)area->g_y+(long)area->g_x;
	
	p=pp+start;

	w=area->g_w/2;
	wp=area->g_w-1;

	ldif=(long)ww-(long)w;
	
	if(otree[HOR].ob_state & SELECTED)
	{ /* Horizontal Spiegeln */
		for(y=area->g_h; y > 0; --y)
		{
			p2=p+wp;
			for(x=w; x > 0; --x)
			{
				b=*p;
				*p++=*p2;
				*p2--=b;
			}
			p+=ldif;
		}
	}

	if(otree[VER].ob_state & SELECTED)
	{ /* Vertikal Spiegeln */
		w=area->g_w;
		ldif=(long)ww-(long)w;
		bdif=(long)ww+(long)w;
		p=pp+start;
		p2=pp+(long)((long)(area->g_h-1)*(long)ww);
		for(y=area->g_h/2; y > 0; --y)
		{
			for(x=w; x > 0; --x)
			{
				b=*p;
				*p++=*p2;
				*p2++=b;
			}
			p+=ldif;
			p2-=bdif;
		}
	}
		
	return(1);
}
