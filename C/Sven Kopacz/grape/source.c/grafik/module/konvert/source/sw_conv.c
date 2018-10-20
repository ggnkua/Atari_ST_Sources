#include <stddef.h>
#include <stdlib.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "sw_conv.rsh"
#define X 1
#define Y 2

#define otree (&rs_object[0])

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);

int		do_diffus(uchar *c, uchar *m, uchar *y, int w, GRECT *area);
int		do_diffus1(uchar *c, uchar *m, uchar *y, int w, GRECT *area);
int		do_diffus2(uchar *c, uchar *m, uchar *y, int w, GRECT *area);
int		do_diffus3(uchar *c, uchar *m, uchar *y, int w, GRECT *area);

int		sx, sy, sw, sh;

int		global[80];
int		fs_0err[512][4], fs_1err[512][4];	/* Floyd-Steinberg Fehlertabelle */

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
	int a, b, c;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];
	
	for(a=0; a < 512; ++a)
	{
		b=a-255;
		fs_0err[a][0]=(b*7)/16;
		fs_0err[a][1]=(b*3)/16;
		fs_0err[a][2]=(b*5)/16;
		fs_0err[a][3]=b/16;
		c=b-255;
		fs_1err[a][0]=(c*7)/16;
		fs_1err[a][1]=(c*3)/16;
		fs_1err[a][2]=(c*5)/16;
		fs_1err[a][3]=c/16;
	}
	
	otree[SCHWELL].ob_state |= SELECTED;
	otree[DIFF1].ob_state |= SELECTED;
	
	otree[SCHWELL].ob_y=otree[BAR].ob_height/2;
	otree[DIFFUS].ob_y=otree[BAR].ob_y+otree[BAR].ob_height+(otree[DIFFUS].ob_height*5)/7;
	otree[SLIDE].ob_x=otree[BAR].ob_width/2-otree[SLIDE].ob_width/2;
	strcpy(otree[SLIDE].ob_spec.tedinfo->te_ptext, "128");
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
	itoa(now, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	objc_draw(otree, SLIDE, 2, sx, sy, sw, sh);
	if(otree[SCHWELL].ob_state & SELECTED)
		_G_ update_preview();
}

void setval(int val)
{
	long p;
	
	p=otree[BAR].ob_width-otree[SLIDE].ob_width; /* Max-OB-X */
	p*=(long)val;	/* max_ob_x * val */
	p/=255l;			/* max_ob_x*val/255=ob_x */
	otree[SLIDE].ob_x=(int)p;
	itoa(val, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	objc_draw(otree, BAR, 2, sx, sy, sw, sh);
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		case LEFT:
			if(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)== 0)
				break;
			setval(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)-1);
			if(otree[SCHWELL].ob_state & SELECTED)
				_G_ update_preview();
		break;
		case RIGHT:
			if(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)== 255)
				break;
			setval(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)+1);
			if(otree[SCHWELL].ob_state & SELECTED)
				_G_ update_preview();
		break;
		case DIFFUS:
		case SCHWELL:
			_G_ update_preview();
		break;
		case DIFF1:
		case DIFF2:
		case DIFF3:
			if(otree[DIFFUS].ob_state & SELECTED)
				_G_ update_preview();
		break;
		case SLIDE:
			slide(otree, SLIDE, 0, 255, atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext), newval);
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
	register uchar *cc=c, *mm=m, *yy=y, grey, schwell;
	register int	ww=area->g_w, cnst=255*77+255*151+255*28;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int mc;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;

	if(otree[DIFFUS].ob_state & SELECTED)
		return(do_diffus(c, m, y,  w, area));

	schwell=atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext);

	if(cc && mm && yy)
	{
		cc+=start;
		mm+=start;
		yy+=start;
		
		for(yc=area->g_h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
			{
				mc=cnst-((unsigned int)(*cc)*77+
									(unsigned int)(*mm)*151+
									(unsigned int)(*yy)*28);
				mc=mc >> 8;
				grey=(unsigned char)255-mc;
	
				if(grey >= schwell)
				{
					*cc++=255;
					*mm++=255;
					*yy++=255;
				}
				else
				{
					*cc++=0;
					*mm++=0;
					*yy++=0;
				}
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
			{
				if(*cc >= schwell)
					*cc++=255;
				else
					*cc++=0;
			}
			cc+=ldif;
		}
	}
	return(1);
}

int		do_diffus(uchar *c, uchar *m, uchar *y, int w, GRECT *area)
{
	if(otree[DIFF1].ob_state & SELECTED)
		return(do_diffus1(c,m,y,w,area));
	else if(otree[DIFF2].ob_state & SELECTED)
		return(do_diffus2(c,m,y,w,area));
	else
		return(do_diffus3(c,m,y,w,area));
}

int		do_diffus1(uchar *c, uchar *m, uchar *y, int w, GRECT *area)
{/* Verteilung 1/2 r, 1/2 u */
	register uchar *cc=c, *mm=m, *yy=y;
	register int	grey, *lerr, derr, ww=area->g_w, cnst=255*77+255*151+255*28;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int mc;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;

	lerr=calloc(ww+1, sizeof(int));
	if(lerr==NULL) return(0);
	
	derr=0;
	
	if(cc && mm && yy)
	{
		cc+=start;
		mm+=start;
		yy+=start;
		
		for(yc=area->g_h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
			{
				mc=cnst-((unsigned int)(*cc)*77+
									(unsigned int)(*mm)*151+
									(unsigned int)(*yy)*28);
				mc=mc >> 8;
				grey=(unsigned char)255-mc;
				grey+=derr+lerr[xc];
				if(grey>0)
				{
					*cc++=255;
					*mm++=255;
					*yy++=255;
					lerr[xc]=derr=(grey-255)>>1;
				}
				else
				{
					*cc++=0;
					*mm++=0;
					*yy++=0;
					lerr[xc]=derr=grey>>1;
				}
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
			{
				grey=((int)*cc) +derr+lerr[xc];
				if(grey>0)
				{
					lerr[xc]=derr=(grey-255)>>1;
					*cc++=255;
				}
				else
				{
					lerr[xc]=derr=grey >> 1;
					*cc++=0;
				}
			}
			cc+=ldif;
		}
	}
	free(lerr);
	return(1);
}

int		do_diffus4(uchar *c, uchar *m, uchar *y, int w, GRECT *area)
{/* Verteilung 1/3 r,ru,u */
	register uchar *cc=c, *mm=m, *yy=y;
	register int	grey, *lerr, derr, ww=area->g_w, cnst=255*77+255*151+255*28;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int mc;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;

	lerr=calloc(ww+2, sizeof(int));
	if(lerr==NULL) return(0);
	
	derr=0;
	
	if(cc && mm && yy)
	{
		cc+=start;
		mm+=start;
		yy+=start;
		
		for(yc=area->g_h; yc > 0; --yc)
		{
			lerr[ww]=0;
			for(xc=ww; xc > 0; --xc)
			{
				mc=cnst-((unsigned int)(*cc)*77+
									(unsigned int)(*mm)*151+
									(unsigned int)(*yy)*28);
				mc=mc >> 8;
				grey=(unsigned char)255-mc;
				grey+=derr;
				if(grey>0)
				{
					grey-=255; grey*=4; grey/=6;
					derr=grey;
					derr+=lerr[xc-1];
					grey>>=2;
					lerr[xc]+=grey;
					lerr[xc-1]=grey;
					*cc++=255;
					*mm++=255;
					*yy++=255;
				}
				else
				{
					grey*=4; grey/=6;
					derr=grey;
					derr+=lerr[xc-1];
					grey>>=2;
					lerr[xc]+=grey;
					lerr[xc-1]=grey;
					*cc++=0;
					*mm++=0;
					*yy++=0;
				}
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
			lerr[ww]=0;
			for(xc=ww; xc > 0; --xc)
			{
				grey=((int)*cc) +derr;
				if(grey>0)
				{
					grey-=255; grey*=2; grey/=6;
					derr=grey;
					derr+=lerr[xc-1];
					grey>>=1;
					lerr[xc]+=grey;
					lerr[xc-1]=grey;
					*cc++=255;
				}
				else
				{
					grey*=2; grey/=6;
					derr=grey;
					derr+=lerr[xc-1];
					grey>>=1;
					lerr[xc]+=grey;
					lerr[xc-1]=grey;
					*cc++=0;
				}
			}
			cc+=ldif;
		}
	}
	free(lerr);
	return(1);
}

int		do_diffus3(uchar *c, uchar *m, uchar *y, int w, GRECT *area)
{/* Floyd-Steinberg Verteilung */
	register uchar *cc=c, *mm=m, *yy=y;
	register int	grey, *lerr, derr, ww=area->g_w, cnst=255*77+255*151+255*28;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int mc;
	register int	*f_err1=&(fs_1err[255][0]), *f_err0=&(fs_0err[255][0]);
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;

	lerr=calloc(ww+2, sizeof(int));
	if(lerr==NULL) return(0);
	
	derr=0;
	
	if(cc && mm && yy)
	{
		cc+=start;
		mm+=start;
		yy+=start;
		
		for(yc=area->g_h; yc > 0; --yc)
		{
			lerr[ww+1]=lerr[ww]=derr=0;
			for(xc=ww; xc > 0; --xc)
			{
				mc=cnst-((unsigned int)(*cc)*77+
									(unsigned int)(*mm)*151+
									(unsigned int)(*yy)*28);
				mc=mc >> 8;
				grey=(unsigned char)255-mc;
				grey+=derr;
				if(grey>0)
				{
					derr=lerr[xc-1];
					derr+=f_err1[(grey*4)];
					lerr[xc+1]+=f_err1[(grey*4)+1];
					lerr[xc]+=f_err1[(grey*4)+2];
					lerr[xc-1]=f_err1[(grey*4)+3];
					*cc++=255;
					*mm++=255;
					*yy++=255;
				}
				else
				{
					derr=lerr[xc-1];
					derr+=f_err0[(grey*4)];
					lerr[xc+1]+=f_err0[(grey*4)+1];
					lerr[xc]+=f_err0[(grey*4)+2];
					lerr[xc-1]=f_err0[(grey*4)+3];
					*cc++=0;
					*mm++=0;
					*yy++=0;
				}
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
			lerr[ww+1]=lerr[ww]=derr=0;
			for(xc=ww; xc > 0; --xc)
			{
				grey=((int)*cc) +derr;
				if(grey>0)
				{
					derr=lerr[xc-1];
					derr+=f_err1[(grey*4)];
					lerr[xc+1]+=f_err1[(grey*4)+1];
					lerr[xc]+=f_err1[(grey*4)+2];
					lerr[xc-1]=f_err1[(grey*4)+3];
					*cc++=255;
				}
				else
				{
					derr=lerr[xc-1];
					derr+=f_err0[(grey*4)];
					lerr[xc+1]+=f_err0[(grey*4)+1];
					lerr[xc]+=f_err0[(grey*4)+2];
					lerr[xc-1]=f_err0[(grey*4)+3];
					*cc++=0;
				}
			}
			cc+=ldif;
		}
	}
	free(lerr);
	return(1);
}

int		do_diffus2(uchar *c, uchar *m, uchar *y, int w, GRECT *area)
{/* Burkes Verteilung */
	register uchar *cc=c, *mm=m, *yy=y;
	register int	grey, *lerr, derr, derr2, ww=area->g_w, cnst=255*77+255*151+255*28;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int mc;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;

	lerr=calloc(ww+4, sizeof(int));
	if(lerr==NULL) return(0);
	++lerr;
	
	derr=0;
	
	if(cc && mm && yy)
	{
		cc+=start;
		mm+=start;
		yy+=start;
		
		for(yc=area->g_h; yc > 0; --yc)
		{
			lerr[ww+2]=lerr[ww+1]=lerr[ww]=lerr[ww-1]=derr=derr2=0;
			for(xc=ww; xc > 0; --xc)
			{
				mc=cnst-((unsigned int)(*cc)*77+
									(unsigned int)(*mm)*151+
									(unsigned int)(*yy)*28);
				mc=mc >> 8;
				grey=(unsigned char)255-mc;
				grey+=derr;
				if(grey>0)
				{
					grey-=255;
					derr=(grey*7)/28;
					derr+=derr2;
					derr2=(grey*6)/28;
					derr2+=lerr[xc-2];
					lerr[xc+2]+=(grey*2)/28;
					lerr[xc+1]+=(grey*4)/28;
					lerr[xc]+=(grey*5)/28;
					lerr[xc-1]+=(grey*3)/28;
					lerr[xc-2]=grey/28;
					*cc++=255;
					*mm++=255;
					*yy++=255;
				}
				else
				{
					derr=(grey*7)/28;
					derr+=derr2;
					derr2=(grey*6)/28;
					derr2+=lerr[xc-2];
					lerr[xc+2]+=(grey*2)/28;
					lerr[xc+1]+=(grey*4)/28;
					lerr[xc]+=(grey*5)/28;
					lerr[xc-1]+=(grey*3)/28;
					lerr[xc-2]=grey/28;
					*cc++=0;
					*mm++=0;
					*yy++=0;
				}
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
			lerr[ww+2]=lerr[ww+1]=lerr[ww]=lerr[ww-1]=derr=derr2=0;
			for(xc=ww; xc > 0; --xc)
			{
				grey=((int)*cc) +derr;
				if(grey>0)
				{
					grey-=255;
					derr=grey/4;
					derr+=derr2;
					derr2=grey/8;
					derr2+=lerr[xc-2];
					lerr[xc+2]+=grey/16;
					lerr[xc+1]+=grey/8;
					lerr[xc]+=grey/4;
					lerr[xc-1]+=grey/8;
					lerr[xc-2]=grey/16;
					*cc++=255;
				}
				else
				{
					derr=grey/4;
					derr+=derr2;
					derr2=grey/8;
					derr2+=lerr[xc-2];
					lerr[xc+2]+=grey/16;
					lerr[xc+1]+=grey/8;
					lerr[xc]+=grey/4;
					lerr[xc-1]+=grey/8;
					lerr[xc-2]=grey/16;
					*cc++=0;
				}
			}
			cc+=ldif;
		}
	}
	free(lerr);
	return(1);
}
