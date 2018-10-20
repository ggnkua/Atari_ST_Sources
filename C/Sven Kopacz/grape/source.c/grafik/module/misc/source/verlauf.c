#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "verlauf.rsh"

#define otree (&rs_object[0])

typedef struct
{
	int						w; /* Gr”že auf n„chste 16 gerundet */
	long					*table_offset; /* Zeiger auf Offsettabelle fr Zeilen */
	unsigned char	*r, *g,	*b; 	/* Zeiger auf Speicher fr Farbfelder */
} COL_OB;

typedef struct
{
	int					type; 	/* 1=Grože Kurve, 2=Kleine Kurve, 3=Farbe */
	COL_OB			color;	/* Nur fr Farbe */
}U_OB; /* User-Objekt fr User-Defs */

/* Einfacherer Zugriff: */
#define _UP_ .ob_spec.userblk->ub_parm

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);


int		global[80];

uchar	*cmy=NULL;

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
	int a, b;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];
	
	/* Text 1 weiter runter setzen */
	otree[DOWN].ob_y+=otree[DOWN].ob_height/2;
	/* Untere Reihe weiter runter setzen */
	a=DOWN1;
	do otree[a].ob_y+=otree[a].ob_height/2;
	while(!(otree[a++].ob_flags & LASTOB));
	
	/* Farbfelder auf weiž-schwarz initialisieren */

	b=((U_OB*)(otree[COL1]_UP_))->color.w*otree[COL1].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(otree[COL1]_UP_))->color.r[a]=0;
		((U_OB*)(otree[COL1]_UP_))->color.g[a]=0;
		((U_OB*)(otree[COL1]_UP_))->color.b[a]=0;
		((U_OB*)(otree[COL2]_UP_))->color.r[a]=255;
		((U_OB*)(otree[COL2]_UP_))->color.g[a]=255;
		((U_OB*)(otree[COL2]_UP_))->color.b[a]=255;
	}
	
	otree[V1].ob_state|=SELECTED;
}

void cdecl mod_quit(void)
{
}


int make_table(int isteps, int mode)
{/* mode 0=Grau, 1=Color */
 /* Return: 0=OK, sonst Fehler (No mem, 0 steps) */
 
	long mc, mm, my, ac, am, ay, steps=isteps;
	int	 step;

	if(cmy)
	{
		free(cmy);
		cmy=NULL;
	}
		
	if(steps==0)
		return(-1);

	cmy=(uchar*)malloc(steps*3);
	if(cmy==NULL) return(-1);
	mc=((U_OB*)(otree[COL2]_UP_))->color.b[0];
	mm=((U_OB*)(otree[COL2]_UP_))->color.r[0];
	my=((U_OB*)(otree[COL2]_UP_))->color.g[0];
	
	if(mode) /* Farbe */	
	{
		mc-=ac=((U_OB*)(otree[COL1]_UP_))->color.b[0];
		mm-=am=((U_OB*)(otree[COL1]_UP_))->color.r[0];
		my-=ay=((U_OB*)(otree[COL1]_UP_))->color.g[0];
	}
	else
	{/* Grau */
		mc=(mc*77+mm*151+my*28)>>8;
		ac=((U_OB*)(otree[COL1]_UP_))->color.b[0];
		am=((U_OB*)(otree[COL1]_UP_))->color.r[0];
		ay=((U_OB*)(otree[COL1]_UP_))->color.g[0];
		ac=am=ay=(ac*77+am*151+ay*28)>>8;
		mm=my=mc-=ac;
	}
	
	ac*=1024; am*=1024; ay*=1024;	/* Startwerte */
	mc*=1024; mm*=1024; my*=1024;	/* Steigungen */
		mc/=steps; mm/=steps; my/=steps;
	
	steps-=1; /* Endfarbe auslassen */
	steps*=3;
	for(step=0;step<steps;)
	{
		cmy[step++]=(uchar)(ac/1024);
		cmy[step++]=(uchar)(am/1024);
		cmy[step++]=(uchar)(ay/1024);
		ac+=mc; am+=mm; ay+=my;
	}

	/* Endfarbe wegen Rundungsfehlern explizit setzen */
	cmy[step++]=((U_OB*)(otree[COL2]_UP_))->color.b[0];
	cmy[step++]=((U_OB*)(otree[COL2]_UP_))->color.r[0];
	cmy[step]=((U_OB*)(otree[COL2]_UP_))->color.g[0];

	return(0);
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		case V1:
		case V2:
		case V3:
		case -COL1:
		case -COL2:
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
	
	if(!(_G_ undo_buf(area, l, mm, 1)))
		return(0);/* Undo schlug fehl */
	return(do_function2(c,m,y,w,h,area,-1));
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	register uchar *cc=c, *mm=m, *yy=y, *cmyt;
	register int	ww=area->g_w;
	register long ldif=(long)w-(long)area->g_w, rad1, rad2;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	int	 steps;
	register int xc,yc;

	if(prv==1) /* Detailansicht nicht m”glich */
		return(0);
		
	/* Anzahl der n”tigen Stufen berechnen */
	if(otree[V1].ob_state & SELECTED) /* Senkrecht */
		steps=area->g_h;
	else if(otree[V2].ob_state & SELECTED) /* Waagrecht */
		steps=area->g_w;
	else if(otree[V3].ob_state & SELECTED) /* Radial */
	{
		if(area->g_w < area->g_h)
			steps=area->g_w/2;
		else
			steps=area->g_h/2;
	}
	/*
	else	/* Polar */
	{
		if(area->g_w < area->g_h)
			steps=(int)((long)(314*(long)area->g_w)/100);
		else
			steps=(int)((long)(314*(long)area->g_h)/100);
	}
	*/
		
	if((mm==NULL) && (yy==NULL)) /* Grauverlauf */
	{
		if(make_table(steps,0)!=0) return(0);
		cc+=start;
		cmyt=cmy;	/* Tabelle laden */
	
		if(otree[V1].ob_state & SELECTED) /* Senkrecht */
		for(yc=area->g_h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
				*cc++=cmyt[0];
			cc+=ldif;
			cmyt+=3;
		}
		else if(otree[V2].ob_state & SELECTED) /* Waagrecht */
		for(yc=area->g_h; yc > 0; --yc)
		{
			cmyt=cmy;	/* Tabelle laden */
			for(xc=ww; xc > 0; --xc)
			{
				*cc++=*cmyt;
				cmyt+=3;
			}
			cc+=ldif;
		}
		else if(otree[V3].ob_state & SELECTED) /* Radial */
		for(yc=area->g_h; yc > 0; --yc)
		{
			rad2=area->g_h/2-yc; rad2*=rad2; /* y^2 */
			for(xc=ww; xc > 0; --xc)
			{
				rad1=ww/2-xc; rad1*=rad1;	/* x^2 */
				rad1+=rad2;	/* x^2+y^2 */
				rad1=(long)sqrt(rad1);	/* Wurzel=Radius */
				if(rad1<steps)	/* Innerhalb des Kreises */ 
				{
					rad1*=3;
					*cc++=cmyt[rad1];
				}
				else
					++cc;
			}
			cc+=ldif;
		}
		return(1);
	}

	if(make_table(steps,1)!=0) return(0);
	
	cc+=start;
	mm+=start;
	yy+=start;

	cmyt=cmy;	/* Tabelle laden */

	if(otree[V1].ob_state & SELECTED) /* Senkrecht */
	for(yc=area->g_h; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
		{
			*cc++=cmyt[0];
			*mm++=cmyt[1];
			*yy++=cmyt[2];
		}
		cc+=ldif;
		mm+=ldif;
		yy+=ldif;
		cmyt+=3;
	}
	else if(otree[V2].ob_state & SELECTED) /* Waagrecht */
	for(yc=area->g_h; yc > 0; --yc)
	{
		cmyt=cmy;	/* Tabelle laden */
		for(xc=ww; xc > 0; --xc)
		{
			*cc++=*cmyt++;
			*mm++=*cmyt++;
			*yy++=*cmyt++;
		}
		cc+=ldif;
		mm+=ldif;
		yy+=ldif;
	}
	else if(otree[V3].ob_state & SELECTED) /* Radial */
	for(yc=area->g_h; yc > 0; --yc)
	{
		rad2=area->g_h/2-yc; rad2*=rad2; /* y^2 */
		for(xc=ww; xc > 0; --xc)
		{
			rad1=ww/2-xc; rad1*=rad1;	/* x^2 */
			rad1+=rad2;	/* x^2+y^2 */
			rad1=(long)sqrt(rad1);	/* Wurzel=Radius */
			if(rad1<steps)	/* Innerhalb des Kreises */ 
			{
				rad1*=3;
				*cc++=cmyt[rad1];
				*mm++=cmyt[rad1+1];
				*yy++=cmyt[rad1+2];
			}
			else
			{++cc;++mm;++yy;}
		}
		cc+=ldif;
		mm+=ldif;
		yy+=ldif;
	}
	
	return(1);
}
