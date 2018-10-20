#include <stddef.h>
#include <stdlib.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "sw_diff.rsh"
#define X 1
#define Y 2

#define otree (&rs_object[0])

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);

int		do_diffus1(uchar *c, uchar *m, uchar *y, int w, GRECT *area);
int		do_diffus2(uchar *c, uchar *m, uchar *y, int w, GRECT *area);
int		do_diffus3(uchar *c, uchar *m, uchar *y, int w, GRECT *area);


int		global[80];
int		fs_0err[512][4], fs_1err[512][4];	/* Floyd-Steinberg Fehlertabelle */
unsigned int mul77[256], mul151[256], mul28[256];

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
	for(a=0; a < 256; ++a)
	{
		mul77[a]=a*77;
		mul151[a]=a*151;
		mul28[a]=a*28;
	}
	
	otree[DIFF1].ob_state |= SELECTED;
	
	otree[GO].ob_y-=otree[DIFF1].ob_y/2;
	otree[DIFF2].ob_y-=otree[DIFF1].ob_y/2;
	otree[DIFF3].ob_y-=otree[DIFF1].ob_y/2;
	otree[DIFF1].ob_y-=otree[DIFF1].ob_y/2;
}

void cdecl mod_quit(void)
{
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		case DIFF1:
		case DIFF2:
		case DIFF3:
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
				return(0);/* Undo schlug fehl */
		return(do_function2(c,m,y,w,h,area,-1));
	}
	else
		return(0);
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
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
	register int	grey, *lerr, derr, ww=area->g_w;
	register unsigned int *m77=mul77, *m151=mul151, *m28=mul28;
	register long ldif=(long)w-(long)area->g_w;
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
				grey=(unsigned char)((m77[*cc]+m151[*mm]+m28[*yy])>>8);
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
	register int	grey, *lerr, derr, ww=area->g_w;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int *m77=mul77, *m151=mul151, *m28=mul28;
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
				grey=(unsigned char)((m77[*cc]+m151[*mm]+m28[*yy])>>8);
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
	register int	grey, *lerr, derr, ww=area->g_w;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int *m77=mul77, *m151=mul151, *m28=mul28;
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
				grey=(unsigned char)((m77[*cc]+m151[*mm]+m28[*yy])>>8);
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
	register int	grey, *lerr, derr, derr2, ww=area->g_w;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int *m77=mul77, *m151=mul151, *m28=mul28;
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
				grey=(unsigned char)((m77[*cc]+m151[*mm]+m28[*yy])>>8);
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
