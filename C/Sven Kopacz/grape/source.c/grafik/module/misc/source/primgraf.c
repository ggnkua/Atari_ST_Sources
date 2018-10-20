#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "primgraf.rsh"

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
	
	/* Farbfeld auf schwarz initialisieren */

	b=((U_OB*)(otree[COL1]_UP_))->color.w*otree[COL1].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(otree[COL1]_UP_))->color.r[a]=255;
		((U_OB*)(otree[COL1]_UP_))->color.g[a]=255;
		((U_OB*)(otree[COL1]_UP_))->color.b[a]=255;
	}
	
	otree[V1].ob_state|=SELECTED;
}

void cdecl mod_quit(void)
{
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		case V1: case V2: case V3: case V4:
		case V5: case V6: case V7: case V8:
		case V9: case V10: case V11: case V12:
		case -COL1:
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
	register uchar *cc=c, *mm=m, *yy=y, grey, sc, sm, sy;
	register int	ww=area->g_w;
	register unsigned long ldif;
	int	steps;
	unsigned long  rad1, rad2;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;
	double kp, kc;

	if(prv==1) /* Detailansicht nicht m”glich */
		return(0);

	ldif=(long)w-(long)area->g_w;
	
	if((mm==NULL) && (yy==NULL))
	{ /* Grau-Ebene */
		/* RGB->Grey Hibyte(77*R+151*G+28*B) */
		rad1=255-((U_OB*)(otree[COL1]_UP_))->color.r[0];
		rad1*=77;
		rad2=255-((U_OB*)(otree[COL1]_UP_))->color.g[0];
		rad2*=151;
		rad1+=rad2;
		rad2=255-((U_OB*)(otree[COL1]_UP_))->color.b[0];
		rad2*=28;
		rad1+=rad2;
		rad1>>=8;
		grey=255-rad1;
		cc+=start;
		if(otree[V1].ob_state & SELECTED) /* Rechteck */
		{
			for(yc=area->g_h; yc > 0; --yc)
			{
				if((yc==area->g_h)||(yc==1))
					for(xc=ww; xc > 0; --xc)
						*cc++=grey;
				else
				{cc[0]=grey; cc[ww-1]=grey; cc+=ww;}
				cc+=ldif;
			}
			return(1);
		}
		if(otree[V2].ob_state & SELECTED) /* Rechteck gefllt */
		{
			for(yc=area->g_h; yc > 0; --yc)
			{
				for(xc=ww; xc > 0; --xc)
					*cc++=grey;
				cc+=ldif;
			}
			return(1);
		}
		if(otree[V3].ob_state & SELECTED) /* Kreis */
		{
			if(area->g_w < area->g_h)
				steps=area->g_w/2;
			else
				steps=area->g_h/2;
			for(yc=area->g_h; yc > 0; --yc)
			{
				rad2=area->g_h/2-yc; rad2*=rad2; /* y^2 */
				for(xc=ww; xc > 0; --xc)
				{
					rad1=ww/2-xc; rad1*=rad1;	/* x^2 */
					rad1+=rad2;	/* x^2+y^2 */
					rad1=(long)sqrt(rad1);	/* Wurzel=Radius */
					if(rad1==steps)	/* Auf dem Kreis */ 
						*cc++=grey;
					else
						++cc;
				}
				cc+=ldif;
			}
			return(1);
		}
		if(otree[V4].ob_state & SELECTED) /* Kreis gefllt */
		{
			if(area->g_w < area->g_h)
				steps=area->g_w/2-1;
			else
				steps=area->g_h/2-1;
			for(yc=area->g_h; yc > 0; --yc)
			{
				rad2=area->g_h/2-yc; rad2*=rad2; /* y^2 */
				for(xc=ww; xc > 0; --xc)
				{
					rad1=ww/2-xc; rad1*=rad1;	/* x^2 */
					rad1+=rad2;	/* x^2+y^2 */
					rad1=(long)sqrt(rad1);	/* Wurzel=Radius */
					if(rad1<steps)	/* Innerhalb des Kreises */ 
						*cc++=grey;
					else
						++cc;
				}
				cc+=ldif;
			}
			return(1);
		}
		if(otree[V5].ob_state & SELECTED) /* Linie lu-ro */
		{
			if(area->g_w < area->g_h)
			{/* šber Y gehen */
				kp=(double)area->g_w/(double)area->g_h;
				kc=ww-1;
				for(yc=area->g_h; yc > 0; --yc)
				{
					cc[(long)kc]=grey;
					kc-=kp;
					cc+=ldif+ww;
				}
			}
			else
			{/* šber X gehen */
				kp=(double)area->g_h/(double)area->g_w;
				kc=0;rad2=0;
				for(xc=area->g_w-1; xc >= 0; --xc)
				{
					cc[xc+(long)rad2]=grey;
					kc+=kp;
					if(kc>1){kc-=1; rad2+=ldif+ww;}
				}
			}
			return(1);
		}
		if(otree[V6].ob_state & SELECTED) /* Linie lo-ru */
		{
			if(area->g_w < area->g_h)
			{/* šber Y gehen */
				kp=(double)area->g_w/(double)area->g_h;
				kc=0;
				for(yc=area->g_h; yc > 0; --yc)
				{
					cc[(long)kc]=grey;
					kc+=kp;
					cc+=ldif+ww;
				}
			}
			else
			{/* šber X gehen */
				kp=(double)area->g_h/(double)area->g_w;
				kc=0;rad2=0;
				for(xc=0; xc < area->g_w; ++xc)
				{
					cc[xc+(long)rad2]=grey;
					kc+=kp;
					if(kc>1){kc-=1; rad2+=ldif+ww;}
				}
			}
			return(1);
		}

		if(otree[V7].ob_state & SELECTED) /* Linie links */
		{
			ldif+=ww;
			for(yc=area->g_h; yc > 0; --yc)
			{
				*cc=grey;
				cc+=ldif;
			}
			return(1);
		}
		if(otree[V8].ob_state & SELECTED) /* Linie mitte */
		{
			ldif+=ww;
			cc+=area->g_w/2;
			for(yc=area->g_h; yc > 0; --yc)
			{
				*cc=grey;
				cc+=ldif;
			}
			return(1);
		}
		if(otree[V9].ob_state & SELECTED) /* Linie rechts */
		{
			ldif+=ww;
			cc+=area->g_w-1;
			for(yc=area->g_h; yc > 0; --yc)
			{
				*cc=grey;
				cc+=ldif;
			}
			return(1);
		}

		if(otree[V10].ob_state & SELECTED) /* Linie oben */
		{
			for(xc=area->g_w; xc > 0; --xc) *cc++=grey;
			return(1);
		}

		if(otree[V11].ob_state & SELECTED) /* Linie mitte */
		{
			start=area->g_h/2; rad1=ldif+ww; start*=rad1;
			cc+=start;
			for(xc=area->g_w; xc > 0; --xc) *cc++=grey;
			return(1);
		}

		if(otree[V12].ob_state & SELECTED) /* Linie unten */
		{
			start=area->g_h-1; rad1=ldif+ww; start*=rad1;
			cc+=start;
			for(xc=area->g_w; xc > 0; --xc) *cc++=grey;
			return(1);
		}
		return(1);
	}


	/* Farbig */

	
	cc+=start; mm+=start; yy+=start;

	sc=((U_OB*)(otree[COL1]_UP_))->color.b[0];
	sm=((U_OB*)(otree[COL1]_UP_))->color.r[0];
	sy=((U_OB*)(otree[COL1]_UP_))->color.g[0];

	if(otree[V1].ob_state & SELECTED) /* Rechteck */
	{
		for(yc=area->g_h; yc > 0; --yc)
		{
			if((yc==area->g_h)||(yc==1))
			{
				for(xc=ww; xc > 0; --xc)
				{	*cc++=sc; *mm++=sm; *yy++=sy;}
				
			}
			else
			{
				cc[0]=sc; cc[ww-1]=sc; cc+=ww;
				mm[0]=sm; mm[ww-1]=sm; mm+=ww;
				yy[0]=sy; yy[ww-1]=sy; yy+=ww;
			}
			cc+=ldif; mm+=ldif; yy+=ldif;
		}
		return(1);
	}
	if(otree[V2].ob_state & SELECTED) /* Rechteck gefllt */
	{
		for(yc=area->g_h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
			{	*cc++=sc; *mm++=sm; *yy++=sy;}
			cc+=ldif; mm+=ldif; yy+=ldif;
		}
		return(1);
	}
	if(otree[V3].ob_state & SELECTED) 	/* Kreis */
	{
		if(area->g_w < area->g_h)
			steps=area->g_w/2-1;
		else
			steps=area->g_h/2-1;
		for(yc=area->g_h; yc > 0; --yc)
		{
			rad2=area->g_h/2-yc; rad2*=rad2; /* y^2 */
			for(xc=ww; xc > 0; --xc)
			{
				rad1=ww/2-xc; rad1*=rad1;	/* x^2 */
				rad1+=rad2;	/* x^2+y^2 */
				rad1=(long)sqrt(rad1);	/* Wurzel=Radius */
				if(rad1==steps)	/* Innerhalb des Kreises */ 
				{ *cc++=sc; *mm++=sm; *yy++=sy; }
				else
				{	++cc; ++mm; ++yy;}
			}
			cc+=ldif; mm+=ldif; yy+=ldif;
		}
		return(1);
	}		
	if(otree[V4].ob_state & SELECTED) 	/* Kreis gefllt */
	{
		if(area->g_w < area->g_h)
			steps=area->g_w/2;
		else
			steps=area->g_h/2;
		for(yc=area->g_h; yc > 0; --yc)
		{
			rad2=area->g_h/2-yc; rad2*=rad2; /* y^2 */
			for(xc=ww; xc > 0; --xc)
			{
				rad1=ww/2-xc; rad1*=rad1;	/* x^2 */
				rad1+=rad2;	/* x^2+y^2 */
				rad1=(long)sqrt(rad1);	/* Wurzel=Radius */
				if(rad1<steps)	/* Innerhalb des Kreises */ 
				{ *cc++=sc; *mm++=sm; *yy++=sy; }
				else
				{	++cc; ++mm; ++yy;}
			}
			cc+=ldif; mm+=ldif; yy+=ldif;
		}
		return(1);
	}		

	if(otree[V5].ob_state & SELECTED) /* Linie lu-ro */
	{
		if(area->g_w < area->g_h)
		{/* šber Y gehen */
			kp=(double)area->g_w/(double)area->g_h;
			kc=ww-1;
			for(yc=area->g_h; yc > 0; --yc)
			{
				cc[(long)kc]=sc; mm[(long)kc]=sm; yy[(long)kc]=sy;
				kc-=kp;
				cc+=ldif+ww; mm+=ldif+ww; yy+=ldif+ww;
			}
		}
		else
		{/* šber X gehen */
			kp=(double)area->g_h/(double)area->g_w;
			kc=0;rad2=0;
			for(xc=area->g_w-1; xc >= 0; --xc)
			{
				cc[xc+(long)rad2]=sc; mm[xc+(long)rad2]=sm; yy[xc+(long)rad2]=sy;
				kc+=kp;
				if(kc>1){kc-=1; rad2+=ldif+ww;}
			}
		}
		return(1);
	}
	if(otree[V6].ob_state & SELECTED) /* Linie lo-ru */
	{
		if(area->g_w < area->g_h)
		{/* šber Y gehen */
			kp=(double)area->g_w/(double)area->g_h;
			kc=0;
			for(yc=area->g_h; yc > 0; --yc)
			{
				cc[(long)kc]=sc; mm[(long)kc]=sm; yy[(long)kc]=sy;
				kc+=kp;
				cc+=ldif+ww; mm+=ldif+ww; yy+=ldif+ww;
			}
		}
		else
		{/* šber X gehen */
			kp=(double)area->g_h/(double)area->g_w;
			kc=0;rad2=0;
			for(xc=0; xc < area->g_w; ++xc)
			{
				cc[xc+(long)rad2]=sc; mm[xc+(long)rad2]=sm; yy[xc+(long)rad2]=sy;
				kc+=kp;
				if(kc>1){kc-=1; rad2+=ldif+ww;}
			}
		}
		return(1);
	}

	if(otree[V7].ob_state & SELECTED) /* Linie links */
	{
		ldif+=ww;
		for(yc=area->g_h; yc > 0; --yc)
		{
			*cc=sc;*mm=sm;*yy=sy;
			cc+=ldif;mm+=ldif;yy+=ldif;
		}
		return(1);
	}
	if(otree[V8].ob_state & SELECTED) /* Linie mitte */
	{
		ldif+=ww;
		cc+=area->g_w/2;mm+=area->g_w/2;yy+=area->g_w/2;
		for(yc=area->g_h; yc > 0; --yc)
		{
			*cc=sc;*mm=sm;*yy=sy;
			cc+=ldif;mm+=ldif;yy+=ldif;
		}
		return(1);
	}
	if(otree[V9].ob_state & SELECTED) /* Linie rechts */
	{
		ldif+=ww;
		cc+=area->g_w-1;mm+=area->g_w-1;yy+=area->g_w-1;
		for(yc=area->g_h; yc > 0; --yc)
		{
			*cc=sc;*mm=sm;*yy=sy;
			cc+=ldif;mm+=ldif;yy+=ldif;
		}
		return(1);
	}

	if(otree[V10].ob_state & SELECTED) /* Linie oben */
	{
		for(xc=area->g_w; xc > 0; --xc) {*cc++=sc;*mm++=sm;*yy++=sy;}
		return(1);
	}

	if(otree[V11].ob_state & SELECTED) /* Linie mitte */
	{
		start=area->g_h/2; start*=ldif+ww;
		cc+=start;mm+=start;yy+=start;
		for(xc=area->g_w; xc > 0; --xc) {*cc++=sc;*mm++=sm;*yy++=sy;}
		return(1);
	}

	if(otree[V12].ob_state & SELECTED) /* Linie unten */
	{
		start=area->g_h-1; start*=ldif+ww;
		cc+=start;mm+=start;yy+=start;
		for(xc=area->g_w; xc > 0; --xc) {*cc++=sc;*mm++=sm;*yy++=sy;}
		return(1);
	}

	return(1);
}
