#include <stddef.h>
#include <stdlib.h>
#include <vdi.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "fgraph.rsh"
#define X 1
#define Y 2

#define otree (&rs_object[0])


void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);
int		fill_values(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);

int		cdecl draw_graph(PARMBLK *pb);

int		global[80], vdih;
uchar	*values;
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

	values=malloc(800);
	
	for(a=0; a < 256; ++a)
	{
		mul77[a]=a*77;
		mul151[a]=a*151;
		mul28[a]=a*28;
	}

	/* Tabelle l”schen */
	for(a=0; a < 256; ++a)
		values[a]=0;
	
	/* Dialog auf Absolutgr”že bringen */
	otree[0].ob_width=otree[FRAME].ob_x*2+800;
	otree[FRAME].ob_width=otree[GRAPH].ob_width=800;
	otree[FRAME].ob_height=otree[GRAPH].ob_height=256;
	otree[0].ob_height=otree[FRAME].ob_y+256+16;
	
	otree[GRAPH].ob_spec.userblk=&ublock;
	
	strcpy(otree[LINE].ob_spec.tedinfo->te_ptext, "0");
	strcpy(otree[MAXIMUM].ob_spec.tedinfo->te_ptext, "0");
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
	free(values);
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
	pxy[3]=pblk->pb_y+pblk->pb_h-1;

	/* Zeichnen */
	for(x=0; x < 800; ++x)
	{
		pxy[1]=pxy[3];
		pxy[3]=pblk->pb_y+pblk->pb_h-1-values[x];
		v_pline(vdih, 2, pxy);
		++pxy[0];++pxy[2];
	}

	vs_clip(vdih, 0, pxy);
	
	return(0);
}


void cdecl dservice(int ob)
{
	int l;
	
	if(ob==UP)
	{
		l=atoi(otree[LINE].ob_spec.tedinfo->te_ptext);
		if(l>0)
		{
			--l;
			itoa(l, otree[LINE].ob_spec.tedinfo->te_ptext, 10);
			_G_ d_objc_draw(_ID_, LINE);
			_G_ do_me(_ID_);
		}
	}
	if(ob==DOWN)
	{
		l=atoi(otree[LINE].ob_spec.tedinfo->te_ptext);
		++l;
		itoa(l, otree[LINE].ob_spec.tedinfo->te_ptext, 10);
		_G_ d_objc_draw(_ID_, LINE);
		_G_ do_me(_ID_);
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
		fill_values(c,m,y,w,h,area,-1);
		_G_ d_objc_draw(_ID_, FRAME);
	}
	return(0);
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	return(0);
}

int		fill_values(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	register uchar *cc=c, *mm=m, *yy=y, grey, last, max=0;
	register int	ww=area->g_w;
	register unsigned int *m77=mul77, *m151=mul151, *m28=mul28;
	long start=(long)w*(long)atoi(otree[LINE].ob_spec.tedinfo->te_ptext);
	register int xc;
	
	if(atoi(otree[LINE].ob_spec.tedinfo->te_ptext) >= h)
	{
		itoa(h-1, otree[LINE].ob_spec.tedinfo->te_ptext, 10);
		_G_ d_objc_draw(_ID_, LINE);
		return(0);
	}
	
	--ww;
	if(ww > 800) ww=800;
	
	if((mm==NULL) || (yy==NULL))
	{/* Ist ja schon Grau, nur noch z„hlen */
		cc+=start;
		last=*cc;
		for(xc=ww; xc > 0; --xc)
		{
			if(last>*cc)
				values[ww-xc]=last-*cc;
			else
				values[ww-xc]=*cc-last;
			last=*cc++;
			if(values[ww-xc]>max) max=values[ww-xc];
		}
	}
	else
	{/* Farbe->Umrechnen und z„hlen */
		cc+=start;
		mm+=start;
		yy+=start;
		last=(unsigned char)((m77[*cc++]+m151[*mm++]+m28[*yy++])>>8);
		for(xc=ww; xc > 0; --xc)
		{
			grey=(unsigned char)((m77[*cc++]+m151[*mm++]+m28[*yy++])>>8);
			if(last>grey)
				values[ww-xc]=last-grey;
			else
				values[ww-xc]=grey-last;
			last=grey;
			if(values[ww-xc]>max) max=values[ww-xc];
		}
	}
	/* Rest l”schen */
	for(xc=ww-1; xc<800;++xc)
		values[xc]=0;

	itoa(max, otree[MAXIMUM].ob_spec.tedinfo->te_ptext, 10);
	_G_ d_objc_draw(_ID_, MAXIMUM);

	return(0);
}
