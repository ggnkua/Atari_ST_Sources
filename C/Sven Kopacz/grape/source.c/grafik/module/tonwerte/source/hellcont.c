#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "hellcont.rsh"

#define otree (&rs_object[0])

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);

int		global[80];


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

char *itoa(int val, char *dst, int rad)
{
	int div=1, o=0;
	
	if(val < 0)
	{
		dst[o++]='-';
		val=-val;
	}
		
	while(div < val) div*=rad;
	if(div > val) div/=rad;
	while(div >= rad)
	{
		dst[o++]=val/div+48;
		val=val-(val/div)*div;
		div/=rad;
	}
	dst[o++]=val+48;
	dst[o]=0;
	return(dst);
}

int	atoi(const char *src)
{
	int m=0, val=0;
	
	if(*src=='-') 
	{ m=1; ++src;}
	while((*src>=48) && (*src<=57))
	{
		val*=10;
		val+=*src++ -48;
	}
	if(m) val=-val;
	return(val);	
}

void cdecl mod_init(void)
{
	int a;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];
	
	otree[GO].ob_y=(otree[0].ob_height+otree[BAR].ob_y+otree[BAR].ob_height-otree[GO].ob_height)/2;
	otree[CLIP].ob_state |= SELECTED;
	otree[CLIPLED].ob_spec.bitblk->bi_color=3; 	/* Hellgrn */
	otree[SLIDE].ob_x=otree[BAR].ob_width/2-otree[SLIDE].ob_width/2;
	strcpy(otree[SLIDE].ob_spec.tedinfo->te_ptext, "0");
	otree[SLIDE1].ob_x=otree[BAR1].ob_width/2-otree[SLIDE1].ob_width/2;
	strcpy(otree[SLIDE1].ob_spec.tedinfo->te_ptext, "0");
}

void cdecl mod_quit(void)
{
}

void cdecl newval(int now)
{
	itoa(now-128, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	_G_ d_objc_draw(_ID_, SLIDE);
}

void setval(int val)
{
	_G_ set_slide(_ID_, SLIDE, 0, 255, val);
	itoa(val-128, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	_G_ d_objc_draw(_ID_, BAR);
}

void cdecl newval1(int now)
{
	itoa(now-128, otree[SLIDE1].ob_spec.tedinfo->te_ptext, 10);
	_G_ d_objc_draw(_ID_, SLIDE1);
}

void setval1(int val)
{
	_G_ set_slide(_ID_, SLIDE1, 0, 255, val);
	itoa(val-128, otree[SLIDE1].ob_spec.tedinfo->te_ptext, 10);
	_G_ d_objc_draw(_ID_, BAR1);
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		/* Kontrast */
		case LEFT:
			if(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)== -128)
				break;
			setval(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)-1+128);
			_G_ update_preview();
		break;
		case RIGHT:
			if(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)== 127)
				break;
			setval(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)+1+128);
			_G_ update_preview();
		break;
		case SLIDE:
			_G_ slide(_ID_, SLIDE, 0, 255, atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)+128, newval);
		break;
		case BAR:
			_G_ bar(_ID_, BAR, 0, 255, newval);
		break;
		/* Helligkeit */
		case LEFT1:
			if(atoi(otree[SLIDE1].ob_spec.tedinfo->te_ptext)== -128)
				break;
			setval1(atoi(otree[SLIDE1].ob_spec.tedinfo->te_ptext)-1+128);
			_G_ update_preview();
		break;
		case RIGHT1:
			if(atoi(otree[SLIDE1].ob_spec.tedinfo->te_ptext)== 127)
				break;
			setval1(atoi(otree[SLIDE1].ob_spec.tedinfo->te_ptext)+1+128);
			_G_ update_preview();
		break;
		case SLIDE1:
			_G_ slide(_ID_, SLIDE1, 0, 255, atoi(otree[SLIDE1].ob_spec.tedinfo->te_ptext)+128, newval1);
		break;
		case BAR1:
			_G_ bar(_ID_, BAR1, 0, 255, newval1);
		break;
		case RESET:
			setval(128);
			setval1(128);
			_G_ update_preview();
			_G_ d_unsel(_ID_, RESET);
		break;
		case CLIP:
			_G_ update_preview();
			if(otree[CLIP].ob_state & SELECTED)
				otree[CLIPLED].ob_spec.bitblk->bi_color=3; 	/* Hellgrn */
			else
				otree[CLIPLED].ob_spec.bitblk->bi_color=11; 	/* Dunkelgrn */
			_G_ d_objc_draw(_ID_, CLIPLED);
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

void fill_table(uchar *table)
{
	register uchar	*tab=table;
	register int 		hell, ix;
	register long		c, azub, cont;
	
	/* Helligkeit */
	hell=256-(atoi(otree[SLIDE1].ob_spec.tedinfo->te_ptext)+128);
	/* Kontrast */
	cont=atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)+128;
	
	/* Geradengleichung: Steigung=(cont/128)^2, y(128)=hell*/
	/* ==> c=hell-(cont/128)^2*128  */
	c=(long)hell-((cont*cont)/128);
	
	if(otree[CLIP].ob_state & SELECTED)
	for(ix=0; ix < 256; ++ix)
	{/* Mit Clipping */
		azub=(ix*cont*cont)/(128*128)+c;
		if(azub < 0) azub=0;
		if(azub > 255) azub=255;
		tab[ix]=(uchar)azub;
	}
	else
	for(ix=0; ix < 256; ++ix)
	{/* Ohne Clipping */
		azub=(ix*cont*cont)/(128*128)+c;
		tab[ix]=(uchar)azub;
	}
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	register uchar *cc=c, *mm=m, *yy=y, table[256] ;
	register int	ww=area->g_w;
	register long ldif=(long)w-(long)area->g_w;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;
	
	fill_table(table);

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
			cc+=ldif;	mm+=ldif;	yy+=ldif;
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

