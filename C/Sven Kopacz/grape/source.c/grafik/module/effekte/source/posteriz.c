#include <stddef.h>
#include <stdlib.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "posteriz.rsh"
#define X 1
#define Y 2

#define otree (&rs_object[0])

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);


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

	otree[GO].ob_y=(otree[0].ob_height+otree[BAR].ob_y+otree[BAR].ob_height-otree[GO].ob_height)/2;
	otree[SLIDE].ob_x=otree[BAR].ob_width/2-otree[SLIDE].ob_width/2;
	strcpy(otree[SLIDE].ob_spec.tedinfo->te_ptext, "64");
}

void cdecl mod_quit(void)
{
}


void cdecl newval(int now)
{
	itoa(now, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	_G_ d_objc_draw(_ID_, SLIDE);
}

void setval(int val)
{
	_G_ set_slide(_ID_, SLIDE, 0, 255, val);
	newval(val);
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		case LEFT:
			if(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)== 2)
				break;
			setval(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)-1);
			_G_ update_preview();
		break;
		case RIGHT:
			if(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)== 128)
				break;
			setval(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)+1);
			_G_ update_preview();
		break;
		case SLIDE:
			_G_ slide(_ID_, SLIDE, 2, 128, atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext), newval);
		break;
		case BAR:
			_G_ bar(_ID_, BAR, 2, 128, newval);
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
				return(0);/* Undo schlug fehl */
		return(do_function2(c,m,y,w,h,area,-1));
	}
	else
		return(0);
}

void make_table(uchar *table)
{/* Erzeugt Mul/Div-Tabelle */
	register uchar a, *tab=table, fac;
	
	fac=(uchar)((int)((int)256/(int)atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)));
	a=255;
	do
	{
		tab[a]=(a/fac)*fac;
		--a;
	}while(a < 255);
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	uchar			mdtable[256];
	register uchar *cc=c, *mm=m, *yy=y, *table=mdtable;
	register int	ww=area->g_w;
	register long ldif=(long)w-(long)area->g_w;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;
	
	make_table(table);
	
	if(cc && mm && yy)
	{
		cc+=start;
		mm+=start;
		yy+=start;

		for(yc=area->g_h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
			{
				*cc++=table[*cc];
				*mm++=table[*mm];
				*yy++=table[*yy];
			}
			cc+=ldif;
			mm+=ldif;
			yy+=ldif;
		}
	}
	else
	{
		cc+=start;
		for(yc=area->g_h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
				*cc++=table[*cc];
			cc+=ldif;
		}
	}
	
	return(1);
}
