#include <grape_h.h>
#include "grape.h"
#include "undo.h"
#include "penedit.h"
#include "maininit.h"
#include "gpenic.h"

/* Stift erzeugen */

void make_pen(PEN_PARAMETER *p)
{

	TIP	*ttip;
	int	c, e, f, x, y, rd, rrr, rnd, grz, off, tmp;
	int	pp, r, g, b, ppp[256], dupe[256];

	/* 0-255 aus Grîûenpolynom auf 0-64 anpassen */
	/* und dupe-feld initialisieren */
	/* GGf. alten Pinsel freigeben */
	for(x=0; x < 256; ++x)
	{
		ppp[x]=p->plp.y[x]/4;
		dupe[x]=-1;
		if(pen.tip[x])
			free(pen.tip[x]);
	}

	pen_width=64;

	/* Doppelte rausfinden */
	for(x=0; x < 255; ++x)
	{
		for(y=x+1; y < 256; ++y)
		{
			if( (ppp[y]==ppp[x]) &&
					(p->plr.y[y]==p->plr.y[x]) &&
					(p->plg.y[y]==p->plg.y[x]) &&
					(p->plb.y[y]==p->plb.y[x])
				)
				dupe[y]=x;
		}
	}
	for(c = 0; c < 256; ++c)
	{
		if(dupe[c] > -1)
		{
			pen.tip[c]=pen.tip[dupe[c]];
			continue;
		}
		pp=ppp[c];
		r=p->plr.y[c];
		g=p->plg.y[c];
		b=p->plb.y[c];

		ttip=(TIP*)calloc(sizeof(TIP), 1);
		if(!ttip)
		{
			form_alert(1,"[3][Grape:|Nicht genug Speicher|fÅr Werkzeug!][Abbruch]");
			return;
		}
		
		e=pp/2;
		f=pp-e;
		if(!p->form)
			ttip->square=1;
		else
			ttip->square=0;
		ttip->du=e;
		ttip->dd=f;
		ttip->dl=e;
		ttip->dr=f;
		ttip->max=f+1;

		if(!p->form)
		{ /* Eckig */
			rd=pp/2;	/* Mittelpunkt fÅr Randaufhellung*/
			for(e=0; e <= pp; ++e)
			{
				for(f=0; f <= pp; ++f)
				{
					off=e*64+f;
					if(p->rs_bunt)
					{
						rnd=random(32)+1;
						if(rnd < p->rauschen)
						{
							ttip->red[off]=random(256);
							ttip->yellow[off]=random(256);
							ttip->blue[off]=random(256);
						}
						else
						{
							ttip->red[off]=r;
							ttip->yellow[off]=g;
							ttip->blue[off]=b;
						}
					}
					else
					{
						if(p->rauschen)
							rnd=random(p->rauschen);
						else
							rnd=0;
						tmp=ttip->red[off]=r-rnd;
						if(tmp <  0) ttip->red[off]=0;
						tmp=ttip->yellow[off]=g-rnd;
						if(tmp < 0) ttip->yellow[off]=0;
						tmp=ttip->blue[off]=b-rnd;
						if(tmp < 0) ttip->blue[off]=0;
					}
					if(p->randhell)
					{/* Randaufhellung */
						x=abs(f-rd); y=abs(e-rd);
						rrr=((32-p->randhell)*rd)/32; /* Grenzwert */
						if((x >= rrr) && (y >= rrr))
						{
							if(x < y)
								rnd=(y-rrr)*16;
							else
								rnd=(x-rrr)*16;

							tmp=ttip->red[off]=ttip->red[off]-rnd;
							if(tmp < 0) ttip->red[off]=0;
							tmp=ttip->yellow[off]=ttip->yellow[off]-rnd;
							if(tmp < 0) ttip->yellow[off]=0;
							tmp=ttip->blue[off]=ttip->blue[off]-rnd;
							if(tmp < 0) ttip->blue[off]=0;
						}
						else if(x >= rrr)
						{
							rnd=(x-rrr)*16;
							tmp=ttip->red[off]=ttip->red[off]-rnd;
							if(tmp < 0) ttip->red[off]=0;
							tmp=ttip->yellow[off]=ttip->yellow[off]-rnd;
							if(tmp < 0) ttip->yellow[off]=0;
							tmp=ttip->blue[off]=ttip->blue[off]-rnd;
							if(tmp < 0) ttip->blue[off]=0;
						}
						else if(y >= rrr)
						{
							rnd=(y-rrr)*16;
							tmp=ttip->red[off]=ttip->red[off]-rnd;
							if(tmp < 0) ttip->red[off]=0;
							tmp=ttip->yellow[off]=ttip->yellow[off]-rnd;
							if(tmp < 0) ttip->yellow[off]=0;
							tmp=ttip->blue[off]=ttip->blue[off]-rnd;
							if(tmp < 0) ttip->blue[off]=0;
						}
					}
				}
			}
		}
		else
		{ /* Rund */
			/* Radius */
			rd=pp/2;
			grz=((32-p->randhell)*rd); /* Grenzwert fÅr Aufhellung*/
			for(e=0; e <= pp; ++e)
			{
				/* Ist-y */
				y=e-rd;
				for(f=0; f <= pp; ++f)
				{
					off=e*64+f;
					x=f-rd;
					x=x*x+y*y;
					if(((rd < 8) && (x == rd*rd)) || (x < rd*rd))
					{
						if(p->rs_bunt)
						{
							rnd=random(32)+1;
							if(rnd < p->rauschen)
							{
								ttip->red[off]=random(256);
								ttip->yellow[off]=random(256);
								ttip->blue[off]=random(256);
							}
							else
							{
								ttip->red[off]=r;
								ttip->yellow[off]=g;
								ttip->blue[off]=b;
							}
						}
						else
						{
							if(p->rauschen)
								rnd=random(p->rauschen);
							else
								rnd=0;
							tmp=ttip->red[off]=r-rnd;
							if(tmp < 0) ttip->red[off]=0;
							tmp=ttip->yellow[off]=g-rnd;
							if(tmp < 0) ttip->yellow[off]=0;
							tmp=ttip->blue[off]=b-rnd;
							if(tmp < 0) ttip->blue[off]=0;
						}
						if(p->randhell)
						{/* Randaufhellung */
							/* Abstand zum Mittelpunkt */
							x=f-rd;
							x=x*x+y*y; x=square_root[x];
							if(x*32 > grz)
							{
								ttip->red[off]-=(r*(x-grz/32))/rd;
								ttip->yellow[off]-=(g*(x-grz/32))/rd;
								ttip->blue[off]-=(b*(x-grz/32))/rd;
							}
						}
					}
				}
			}
		}
		pen.tip[c]=ttip;
	}
	
	pen.d_type=p->d_type;
	pen.q_opt=p->q_opt;
	if(p->col_ok)
	{
		pen.col.red=p->col.red;
		pen.col.yellow=p->col.yellow;
		pen.col.blue=p->col.blue;
		fill_col_ob();
	}
	if(p->las_ok)
	{
		pen.col.lasur=p->col.lasur;
		otool[GPLASUR].ob_state&=(~SELECTED);
		otool[GPOPAQUE].ob_state&=(~SELECTED);
		if(p->col.lasur)
			otool[GPLASUR].ob_state|=SELECTED;
		else
			otool[GPOPAQUE].ob_state|=SELECTED;
	}
	if(p->line > -1)
	{
		pen.line=p->line;
		if(p->step > -1)
			pen.step=p->step;
		otool[GPLAUS].ob_state &=(~SELECTED);
		otool[GPLGROB].ob_state &=(~SELECTED);
		otool[GPLFEIN].ob_state &=(~SELECTED);
		if(pen.line)
		{
			if(pen.step == 2)
				otool[GPLGROB].ob_state |= SELECTED;
			else
				otool[GPLFEIN].ob_state |= SELECTED;
		}
		else
			otool[GPLAUS].ob_state |= SELECTED;
	}
	if(p->f_speed > -1)
	{
		pen.f_speed=p->f_speed;
		otool[GPFSS].ob_x=((otool[GPFSB].ob_width-otool[GPFSS].ob_width)*pen.f_speed)/32;
	}

	pen.verlust=p->verlust;
	pen.wischen=p->wischen;

	if(pen.d_type == 1)	/* Flowspeed aktivieren */
	{
		otool[GPFSB].ob_state &= (~DISABLED);
		otool[GPFSS].ob_state &= (~DISABLED);
		if(pen.f_speed)
			otool[GPLED].ob_spec.bitblk->bi_color=3; /* 3= hell */
		else
			otool[GPLED].ob_spec.bitblk->bi_color=11; /* 11= dunkel */
	}
	else
	{
		otool[GPFSB].ob_state |= DISABLED;
		otool[GPFSS].ob_state |= DISABLED;
		otool[GPLED].ob_spec.bitblk->bi_color=2; /* 2= rot */
	}
	
	/* Icon, Merker und Text Åbernehmen */
	/* Objekt belegen */
	/* Icon */
	((CICONBLK*)otool[GPPEN].ob_spec.iconblk)->mainlist->col_data=
		((CICONBLK*)oicons[p->oicon+ICON_1].ob_spec.iconblk)->mainlist->col_data;
	((CICONBLK*)otool[GPPEN].ob_spec.iconblk)->mainlist->col_mask=
		((CICONBLK*)oicons[p->oicon+ICON_1].ob_spec.iconblk)->mainlist->col_mask;
	/* Merker */
	otool[GPMERK1].ob_spec.bitblk->bi_pdata=omerk[p->om1+MERK_1].ob_spec.bitblk->bi_pdata;
	otool[GPMERK2].ob_spec.bitblk->bi_pdata=omerk[p->om2+MERK_1].ob_spec.bitblk->bi_pdata;
	/* Name */
	strcpy(otool[GPPNAME].ob_spec.tedinfo->te_ptext, p->name);
	
	s_redraw(&wtool);

	if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES2].ob_state & SELECTED))
	{
		free_undo();
		clear_undo();
		init_undo();
	}
}
