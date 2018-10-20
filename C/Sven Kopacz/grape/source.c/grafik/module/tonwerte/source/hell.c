#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "hell.rsh"
#define X 1
#define Y 2

#define otree (&rs_object[0])

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);
int		sx, sy, sw, sh;

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
	otree[SLIDE].ob_x=otree[BAR].ob_width/2-otree[SLIDE].ob_width/2;
	strcpy(otree[SLIDE].ob_spec.tedinfo->te_ptext, "0");
	wind_get(0, WF_WORKXYWH, &sx, &sy, &sw, &sh);
}

void cdecl mod_quit(void)
{
}

void	slide(OBJECT *tree, int ob, int min, int max, int now, void(*newval)(int now2))
{/* dir ist X oder Y, min und max sind min und max Werte (z.B.1,10)*/
 /* now ist der jetzige Wert (z.B.3), width ist die Breite/Hîhe*/
 /* des Parents abzÅglich des Sliders und dann noch die Funktion, */
 /* die einen neuen Wert bearbeitet */
	int		mx,my,ms,mk, mx2, my2, off, now2, width, dir;
	float	ps;

	if(tree[ob-1].ob_width == tree[ob].ob_width)
	{
		dir=Y;
		width=tree[ob-1].ob_height-tree[ob].ob_height;
	}
	else
	{
		dir=X;
		width=tree[ob-1].ob_width-tree[ob].ob_width;
	}
		
	if(width)
	{
		graf_mouse(FLAT_HAND,NULL);
		graf_mkstate(&mx,&my,&ms,&mk);
		ps=(float)((float)width/(float)((float)max-(float)min));
		if (dir == X)
			off=(int)((float)((float)mx-(float)ps*(float)now));
		else if (dir == Y)
			off=(int)((float)((float)my-(float)ps*(float)now));
		now2=now;
	
		while(ms & 1)
		{
			graf_mkstate(&mx2,&my2,&ms,&mk);
			if ((dir == X) && (mx2 != mx))
			{/* Ausrechnen, ob auch rel-pos neu ist */
				mx=mx2;
				mx=mx-off;
				now2=(int)((float)((float)mx/(float)ps));
			}
			else if ((dir == Y) && (my2 != my))
			{/* Ausrechnen, ob auch rel-pos neu ist */
				my=my2;
				my=my-off;
				now2=(int)((float)((float)my/(float)ps));
			}
			if (now2 < min)
				now2=min;
			if (now2 > max)
				now2=max;
			if (now2 != now)
			{
				now=now2;
				if(dir == X)
					tree[ob].ob_x=(int)((float)((float)now*(float)ps));
				else
					tree[ob].ob_y=(int)((float)((float)now*(float)ps));
				objc_draw(tree, ob-1, 2, sx, sy, sw, sh);
				newval(now2);
			}
		}
		graf_mouse(ARROW,NULL);
	}
}

void	bar(OBJECT *tree, int ob, int min, int max, void(*newval)(int now2))
{/* Berechnet den Wert fÅr einen Direkt-Klick in den Slider */
 /* Setzt den Slider (als Objektnummer wird das erste Child des */
 /* Bars angenommen) und macht mit slide() weiter */
 
 int	width, dif, mx, my, ox, oy, dum, val;
 float	ps, vl;
 
 	graf_mkstate(&mx, &my, &dum, &dum);
 	objc_offset(tree, ob, &ox, &oy);
 	mx-=ox; my-=oy;
 	mx-=tree[ob+1].ob_width/2;
 	my-=tree[ob+1].ob_height/2;
 	if(mx < 0) mx=0;
 	if(my < 0) my=0;
 	
	if(tree[ob].ob_width == tree[ob+1].ob_width)
	{
		width=tree[ob].ob_height-tree[ob+1].ob_height;
		if(my > width) my=width;
		/* Slider setzen */
		val=tree[ob+1].ob_y=my;
	}
	else
	{
		width=tree[ob].ob_width-tree[ob+1].ob_width;
		if(mx > width) mx=width;
		/* Slider setzen */
		val=tree[ob+1].ob_x=mx;
	}
	
	objc_draw(tree, ob, 8, sx, sy, sw, sh);

	/* Position berechnen */
	dif=max-min;
	
	/* Wert berechnen */
	ps=(float)((float)dif/(float)width);
	vl=ps*(float)val; val=(int)vl;
	if(val > max) val=max;
	newval(val);
	
	slide(tree, ob+1, min, max, val, newval);
}

void newval(int now)
{
	itoa(now-128, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	objc_draw(otree, SLIDE, 2, sx, sy, sw, sh);
	_G_ update_preview();
}

void setval(int val)
{
	long p;
	
	p=otree[BAR].ob_width-otree[SLIDE].ob_width; /* Max-OB-X */
	p*=(long)val;	/* max_ob_x * val */
	p/=255l;			/* max_ob_x*val/255=ob_x */
	otree[SLIDE].ob_x=(int)p;
	itoa(val-128, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	objc_draw(otree, BAR, 2, sx, sy, sw, sh);
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
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
			slide(otree, SLIDE, 0, 255, atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)+128, newval);
		break;
		case BAR:
			bar(otree, BAR, 0, 255, newval);
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

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	register uchar *cc=c, *mm=m, *yy=y, hell, max;
	register int	ww=area->g_w;
	register long ldif=(long)w-(long)area->g_w;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;

	xc=atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext);

	if(cc && mm && yy)
	{
		cc+=start;
		mm+=start;
		yy+=start;
		
		if(xc > 0)
		{/* Heller */
			hell=xc;
			for(yc=area->g_h; yc > 0; --yc)
			{
				for(xc=ww; xc > 0; --xc)
				{
					if(*cc > hell)	*cc++-=hell;
					else	*cc++=0;
					if(*mm > hell)	*mm++-=hell;
					else	*mm++=0;
					if(*yy > hell)	*yy++-=hell;
					else	*yy++=0;
				}
				cc+=ldif;	mm+=ldif;	yy+=ldif;
			}
		}
		else
		{/* Dunkler */
			hell=-xc;
			max=255-hell;
			for(yc=area->g_h; yc > 0; --yc)
			{
				for(xc=ww; xc > 0; --xc)
				{
					if(*cc < max)	*cc++ +=hell;
					else	*cc++=255;
					if(*mm < max)	*mm++ +=hell;
					else	*mm++=255;
					if(*yy < max)	*yy++ +=hell;
					else	*yy++=255;
				}
				cc+=ldif;	mm+=ldif;	yy+=ldif;
			}
		}
	}
	else
	{
		cc+=start;
		
		if(xc > 0)
		{/* Heller */
			hell=xc;
			for(yc=area->g_h; yc > 0; --yc)
			{
				for(xc=ww; xc > 0; --xc)
				{
					if(*cc > hell)	*cc++-=hell;
					else	*cc++=0;
				}
			}
			cc+=ldif;
		}
		else
		{/* Dunkler */
			hell=-xc;
			max=255-hell;
			for(yc=area->g_h; yc > 0; --yc)
			{
				for(xc=ww; xc > 0; --xc)
				{
					if(*cc < max)	*cc++ +=hell;
					else	*cc++=255;
				}
			}
			cc+=ldif;
		}
	}
	return(1);
}

