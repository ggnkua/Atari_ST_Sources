#include <stddef.h>
#include <stdlib.h>
#include <vdi.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "histogrm.rsh"
#define X 1
#define Y 2

#define otree (&rs_object[0])


void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);
int		fill_percent(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);

int		cdecl draw_graph(PARMBLK *pb);

int		global[80], vdih;
uchar	percent[256];
unsigned int mul77[256], mul151[256], mul28[256];

static USERBLK ublock=
{
	draw_graph,
	0
};

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
	
	1,				/*	flags */
	&mod_fn,
	
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
	int a, dum, work_in[11], work_out[58];
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];

	for(a=0; a < 256; ++a)
	{
		mul77[a]=a*77;
		mul151[a]=a*151;
		mul28[a]=a*28;
	}

	/* Tabelle l”schen */
	for(a=0; a < 256; ++a)
		percent[a]=0;
	
	/* Dialog auf Absolutgr”že bringen */
	otree[0].ob_width=otree[FRAME].ob_x*2+256;
	otree[FRAME].ob_width=otree[GRAPH].ob_width=256;
	otree[FRAME].ob_height=otree[GRAPH].ob_height=101;
	otree[0].ob_height=otree[FRAME].ob_y+101+otree[GO].ob_height+16;
	otree[GO].ob_y=otree[FRAME].ob_y+otree[FRAME].ob_height+8;
	
	otree[GRAPH].ob_spec.userblk=&ublock;
	
	/* VDI aufmachen */
	vdih=graf_handle(&dum, &dum, &dum, &dum);
  for ( a = 0; a < 10; a++ )
  {
    work_in[a]  = 1;
  }
  work_in[10] = 2;
	v_opnvwk(work_in, &vdih, work_out);
}

void cdecl mod_quit(void)
{
	v_clsvwk(vdih);
}

int		cdecl draw_graph(PARMBLK *pblk)
{
	int	pxy[4], x;
	/* Kurve in kleinem Rahmen zeichnen */
		
	vswr_mode(vdih, 1);
	vsl_color(vdih, 1);
	vsl_width(vdih, 1);

	/* Clipping */
	pxy[0]=pblk->pb_xc;
	pxy[1]=pblk->pb_yc;
	pxy[2]=pblk->pb_xc+pblk->pb_wc-1;
	pxy[3]=pblk->pb_yc+pblk->pb_hc-1;
	vs_clip(vdih, 1, pxy);

	/* Grund-Kooridnaten Linie */
	pxy[0]=pxy[2]=pblk->pb_x;
	pxy[1]=pblk->pb_y+pblk->pb_h-1;

	/* Zeichnen */
	for(x=0; x < 256; ++x)
	{
		pxy[3]=pxy[1]-percent[x];
		v_pline(vdih, 2, pxy);
		++pxy[0];++pxy[2];
	}

	vs_clip(vdih, 0, pxy);
	
	return(0);
}


void cdecl dservice(int ob)
{
	if(ob==GO)
	{
		_G_ do_me(_ID_);
		_G_ d_unsel(_ID_, GO);
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
		fill_percent(c,m,y,w,h,area,-1);
		_G_ d_objc_draw(_ID_, FRAME);
	}
	return(0);
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	return(0);
}

int		fill_percent(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	long	count[256];
	register uchar *cc=c, *mm=m, *yy=y, grey;
	register int	ww=area->g_w;
	register long ldif=(long)w-(long)area->g_w, mul, *ctab=count;
	register unsigned int *m77=mul77, *m151=mul151, *m28=mul28;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;
	
	/* Tabelle l”schen */
	for(xc=255; xc>=0; --xc)
		ctab[xc]=0;
		
	if((mm==NULL) || (yy==NULL))
	{/* Ist ja schon Grau, nur noch z„hlen */
		cc+=start;
		for(yc=area->g_h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
				ctab[*cc++]++;
			cc+=ldif;
		}
	}
	else
	{/* Farbe->Umrechnen und z„hlen */
		cc+=start;
		mm+=start;
		yy+=start;
		
		for(yc=area->g_h; yc > 0; --yc)
		{
			for(xc=ww; xc > 0; --xc)
			{
				grey=(unsigned char)((m77[*cc++]+m151[*mm++]+m28[*yy++])>>8);
				ctab[grey]++;
			}
			cc+=ldif;
			mm+=ldif;
			yy+=ldif;
		}
	}

	/* Maximal-Wert finden */
	ldif=0;
	for(xc=255; xc>=0; --xc)
		if(ctab[xc]>ldif)ldif=ctab[xc];
		
	/* In Prozent umrechnen */
	/* count/max=percent/100 -> (count*100)/total=percent */
	for(xc=255; xc >=0; --xc)
	{
		mul=(long)ctab[xc]*100;
		mul/=ldif;
		percent[255-xc]=(uchar)mul;
	}
	
	return(0);
}
