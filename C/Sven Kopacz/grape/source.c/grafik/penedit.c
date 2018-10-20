#include <grape_h.h>
#include "grape.h"
#include "ple.h"
#include "penedit.h"
#include "penpal.h"
#include "maininit.h"
#include "xrsrc.h"
#include "gpenic.h"

/* Pen-Editor */

void open_ple(int ob)
{
	OBJECT *oimages;
	xrsrc_gaddr(0,GIMAGES, &oimages, xrsrc);
	
	opledit[GEE1].ob_state&=(~SELECTED);
	opledit[GEE2].ob_state&=(~SELECTED);
	opledit[GEE3].ob_state&=(~SELECTED);
	opledit[GEE4].ob_state&=(~SELECTED);
	opledit[GEE1-1+ple.curve_type].ob_state|=SELECTED;

	opledit[GEP1].ob_flags&=(~HIDETREE);
	opledit[GEP2].ob_flags&=(~HIDETREE);
	opledit[GEP3].ob_flags&=(~HIDETREE);
	switch(ple.curve_type)
	{
		case 4:
			opledit[GEP1].ob_flags|=HIDETREE;
		case 1:
			opledit[GEP3].ob_flags|=HIDETREE;
		case 2:
			opledit[GEP2].ob_flags|=HIDETREE;
		break;
	}
	
	opledit[GEP1].ob_y=opledit[GEGRAPH].ob_height-ple.y1-1;
	opledit[GEP2].ob_x=ple.x2;
	opledit[GEP2].ob_y=opledit[GEGRAPH].ob_height-ple.y2-1;
	opledit[GEP3].ob_y=opledit[GEGRAPH].ob_height-ple.y3-1;
	
	switch(ob)
	{
		case GPSIZE:
			strcpy(opledit[GETITEL].ob_spec.free_string,"Werkzeug-Grîûe");
			opledit[GELO].ob_spec.bitblk->bi_pdata=oimages[GISMALL+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GEHI].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GELO].ob_spec.bitblk->bi_color=9;
			opledit[GEHI].ob_spec.bitblk->bi_color=9;
		break;
		case GPCOL:
			strcpy(opledit[GETITEL].ob_spec.free_string,"Farb-IntensitÑt");
			opledit[GELO].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GEHI].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GELO].ob_spec.bitblk->bi_color=0;
			opledit[GEHI].ob_spec.bitblk->bi_color=1;
		break;
		case GPRED:
			strcpy(opledit[GETITEL].ob_spec.free_string,"Magenta-IntensitÑt");
			opledit[GELO].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GEHI].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GELO].ob_spec.bitblk->bi_color=0;
			opledit[GEHI].ob_spec.bitblk->bi_color=7;
		break;
		case GPYELLOW:
			strcpy(opledit[GETITEL].ob_spec.free_string,"Gelb-IntensitÑt");
			opledit[GELO].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GEHI].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GELO].ob_spec.bitblk->bi_color=0;
			opledit[GEHI].ob_spec.bitblk->bi_color=6;
		break;
		case GPBLUE:
			strcpy(opledit[GETITEL].ob_spec.free_string,"Cyan-IntensitÑt");
			opledit[GELO].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GEHI].ob_spec.bitblk->bi_pdata=oimages[GIBIG+pgp.form].ob_spec.bitblk->bi_pdata;
			opledit[GELO].ob_spec.bitblk->bi_color=0;
			opledit[GEHI].ob_spec.bitblk->bi_color=5;
		break;
	}


	if(!wpledit.open)
		w_open(&wpledit);
	else
	{
		w_top(&wpledit);
		s_redraw(&wpledit);
	}
}

void sl_fspeed(int a)
{
	if((!a) && (pen.f_speed))
	{
		otool[GPLED].ob_spec.bitblk->bi_color=11; /* 3= hell */
		w_objc_draw(&wtool, GPLED, 2, sx, sy, sw, sh);
	}
	else if((a) && (!pen.f_speed))
	{
		otool[GPLED].ob_spec.bitblk->bi_color=3; /* 3= hell */
		w_objc_draw(&wtool, GPLED, 2, sx, sy, sw, sh);
	}
	pen.f_speed=a;
}

void init_pened(void)
{
	int	sl_width=opened[GPFVB].ob_width-opened[GPFVS].ob_width;
	
	/* Reset */
	
	opened[GPSQR].ob_state &= (~SELECTED);
	opened[GPRND].ob_state &= (~SELECTED);
	opened[GPLR].ob_state &= (~SELECTED);
	opened[GPRL].ob_state &= (~SELECTED);

	opened[GPSET].ob_state &= (~SELECTED);
	opened[GPFLOW].ob_state &= (~SELECTED);
	opened[GPADD].ob_state &= (~SELECTED);
	opened[GPSUB].ob_state &= (~SELECTED);
	opened[GPQOPT].ob_state &= (~SELECTED);

	opened[GPOTCOL].ob_state &= (~SELECTED);
	opened[GPOTLAS].ob_state &= (~SELECTED);
	opened[GPOTLIN].ob_state &= (~SELECTED);
	opened[GPOTFS].ob_state &= (~SELECTED);

	opened[GPTA].ob_state &= (~SELECTED);
	opened[GPTC].ob_state &= (~SELECTED);
	opened[GPTS].ob_state &= (~SELECTED);
	opened[GPTK].ob_state &= (~SELECTED);

	opened[GPRSH].ob_state &= (~SELECTED);
	opened[GPRSB].ob_state &= (~SELECTED);
	
	switch(pgp.form)
	{
		case 0:
			opened[GPSQR].ob_state |= SELECTED;
		break;
		case 1:
			opened[GPRND].ob_state |= SELECTED;
		break;
		case 2:
			opened[GPLR].ob_state |= SELECTED;
		break;
		case 3:
			opened[GPRL].ob_state |= SELECTED;
		break;
	}
	
	switch(pgp.d_type)
	{
		case 0:
			opened[GPSET].ob_state |= SELECTED;
		break;
		case 1:
			opened[GPFLOW].ob_state |= SELECTED;
		break;
		case 2:
			opened[GPADD].ob_state |= SELECTED;
		break;
		case 3:
			opened[GPSUB].ob_state |= SELECTED;
		break;
	}
	
	opened[GPFVS].ob_x=(sl_width*pgp.verlust)/32;
	opened[GPVWS].ob_x=(sl_width*pgp.wischen)/32;
	opened[GPHS].ob_x=(sl_width*pgp.randhell)/32;
	opened[GPRS].ob_x=(sl_width*pgp.rauschen)/32;
	
	if(pgp.rs_bunt)
		opened[GPRSB].ob_state |= SELECTED;
	else
		opened[GPRSH].ob_state |= SELECTED;
	
	if(pgp.q_opt)
		opened[GPQOPT].ob_state |= SELECTED;
	
	if(pgp.col_ok)
		opened[GPOTCOL].ob_state |= SELECTED;
	if(pgp.las_ok)
		opened[GPOTLAS].ob_state |= SELECTED;
	if(pgp.line > -1)
		opened[GPOTLIN].ob_state |= SELECTED;
	if(pgp.f_speed > -1)
		opened[GPOTFS].ob_state |= SELECTED;
	
	/* Icon */
	((CICONBLK*)opened[GPICON].ob_spec.iconblk)->mainlist->col_data=
		((CICONBLK*)oicons[pgp.oicon+ICON_1].ob_spec.iconblk)->mainlist->col_data;
	((CICONBLK*)opened[GPICON].ob_spec.iconblk)->mainlist->col_mask=
		((CICONBLK*)oicons[pgp.oicon+ICON_1].ob_spec.iconblk)->mainlist->col_mask;
	/* Merker */
	opened[GPM1].ob_spec.bitblk->bi_pdata=omerk[pgp.om1+MERK_1].ob_spec.bitblk->bi_pdata;
	opened[GPM2].ob_spec.bitblk->bi_pdata=omerk[pgp.om2+MERK_1].ob_spec.bitblk->bi_pdata;
	/* Name */
	strcpy(opened[GPNAME].ob_spec.tedinfo->te_ptext, pgp.name);
	/* Taste */
	strcpy(opened[GPTK].ob_spec.tedinfo->te_ptext, pgp.keyname);
	/* Umschalttasten */
	if(pgp.okbs)
		opened[GPTA+pgp.okbs-1].ob_state |= SELECTED;
		
	/* Disablings */
	
	if(pgp.d_type == 1)
		opened[GPOTFS].ob_state &= (~DISABLED);
	else
		opened[GPOTFS].ob_state |= DISABLED;
	
	if(pgp.form == 0)
		opened[GPQOPT].ob_state &= (~DISABLED);
	else
		opened[GPQOPT].ob_state |= DISABLED;
}

void get_pened(void)
{
	/* Parameter zurÅcksetzen */
	pgp.col_ok=0; pgp.las_ok=0;
	pgp.line=pgp.step=pgp.f_speed=-1;
	pgp.q_opt=0;
	/* Parameter auslesen	*/
	/* Form */
	if(opened[GPSQR].ob_state & SELECTED)
		pgp.form=0;
	else if(opened[GPRND].ob_state & SELECTED)
		pgp.form=1;
	else if(opened[GPLR].ob_state & SELECTED)
		pgp.form=2;
	else if(opened[GPRL].ob_state & SELECTED)
		pgp.form=3;

	/* Art */
	if(opened[GPSET].ob_state & SELECTED)
		pgp.d_type=0;
	else if(opened[GPFLOW].ob_state & SELECTED)
		pgp.d_type=1;
	else if(opened[GPADD].ob_state & SELECTED)
		pgp.d_type=2;
	else if(opened[GPSUB].ob_state & SELECTED)
		pgp.d_type=3;

	if(opened[GPQOPT].ob_state & SELECTED)
		pgp.q_opt=1;

	/* Feste Parameter */
	if(opened[GPOTCOL].ob_state & SELECTED)
	{
		pgp.col_ok=1;
		pgp.col.red=pen.col.red;
		pgp.col.yellow=pen.col.yellow;
		pgp.col.blue=pen.col.blue;
	}
	if(opened[GPOTLAS].ob_state & SELECTED)
	{
		pgp.las_ok=1;
		pgp.col.lasur=pen.col.lasur;
	}
	if(opened[GPOTLIN].ob_state & SELECTED)
	{
		pgp.line=pen.line; pgp.step=pen.step;
	}
	if(opened[GPOTFS].ob_state & SELECTED)
		pgp.f_speed=pen.f_speed;
	
	/* Anzeige Parameter */
	strcpy(pgp.name, opened[GPNAME].ob_spec.tedinfo->te_ptext);
	strcpy(pgp.keyname, opened[GPTK].ob_spec.tedinfo->te_ptext);
}

void dial_pened(int ob)
{
	int x, y, f;
	PEN_PARAMETER *p;
	char	alert[255];
	
	switch(ob)
	{
		case GPMAKE:
			graf_mouse(BUSYBEE, NULL);
			get_pened();
			make_pen(&pgp);
			w_unsel(&wpened, GPMAKE);
			graf_mouse(ARROW, NULL);
		break;
		case GPSIZE:
			ple=pgp.plp;
			ple_target.p1=&pgp.plp;
			ple_target.p2=ple_target.p3=NULL;
			open_ple(ob);
		break;
		case GPCOL:
			/* PrÅfen, ob r,g,b gleich sind */
			f=0;
			for(x=0; x < opledit[GEGRAPH].ob_width; ++x)
				if(!((pgp.plr.y[x] == pgp.plg.y[x]) && (pgp.plg.y[x] == pgp.plb.y[x])))
					f=1;
			if(f)
			{
				if(form_alert(1,"[1][Grape:|Achtung! Diese Aktion zerstîrt|Ihre separaten RGB-Kurven!][OK|Abbruch]")-1)
					break;
				x=form_alert(1,"[2][Grape:|Welcher Verlauf soll als|Quelle benutzt werden?][Rot|GrÅn|Blau]");
				switch(x)
				{
					case 1:	ple=pgp.plr; break;
					case 2:	ple=pgp.plg; break;
					case 3:	ple=pgp.plb; break;
				}
			}
			else
				ple=pgp.plr;
			ple_target.p1=&pgp.plr;
			ple_target.p2=&pgp.plg;
			ple_target.p3=&pgp.plb;
			open_ple(ob);
		break;
		case GPRED:
			ple=pgp.plr;
			ple_target.p1=&pgp.plr;
			ple_target.p2=ple_target.p3=NULL;
			open_ple(ob);
		break;
		case GPYELLOW:
			ple=pgp.plg;
			ple_target.p1=&pgp.plg;
			ple_target.p2=ple_target.p3=NULL;
			open_ple(ob);
		break;
		case GPBLUE:
			ple=pgp.plb;
			ple_target.p1=&pgp.plb;
			ple_target.p2=ple_target.p3=NULL;
			open_ple(ob);
		break;
			
		case GPSQR:
		case GPRND:
		case GPLR:
		case GPRL:
			if(ob == GPSQR)
				opened[GPQOPT].ob_state&=(~DISABLED);
			else
				opened[GPQOPT].ob_state |= DISABLED;
			w_objc_draw(&wpened, GPQOPT, 8, sx, sy, sw, sh);
		break;
		
		case GPSET:
		case GPFLOW:
		case GPADD:
		case GPSUB:
			if(ob == GPFLOW)
				opened[GPOTFS].ob_state&=(~DISABLED);
			else
				opened[GPOTFS].ob_state |= DISABLED;
			w_objc_draw(&wpened, GPOTFS, 8, sx, sy, sw, sh);
		break;

		
		case GPFVS:
			slide(opened, ob, 0, 32, pgp.verlust, sl_sel_fv);
		break;
		case GPFVB:
			bar(&wpened, ob, 0, 32, sl_sel_fv);
		break;
		
		case GPVWS:
			slide(opened, ob, 0, 32, pgp.wischen, sl_sel_vw);
		break;			
		case GPVWB:
			bar(&wpened, ob, 0, 32, sl_sel_vw);
		break;			

		case GPRS:
			slide(opened, ob, 0, 32, pgp.rauschen, sl_sel_rs);
		break;			
		case GPRB:
			bar(&wpened, ob, 0, 32, sl_sel_rs);
		break;			

		case GPHS:
			slide(opened, ob, 0, 32, pgp.randhell, sl_sel_ah);
		break;			
		case GPHB:
			bar(&wpened, ob, 0, 32, sl_sel_ah);
		break;			

		case GPRSH:
		case GPRSB:
			pgp.rs_bunt=opened[GPRSB].ob_state & SELECTED;
		break;
		
		case GPICON:
			graf_mkstate(&x, &y, &f, &f);
			f=form_popup(oicons, x, y);
			if(f > -1)
			{
				pgp.oicon=f-ICON_1;
				((CICONBLK*)opened[GPICON].ob_spec.iconblk)->mainlist->col_data=
					((CICONBLK*)oicons[f].ob_spec.iconblk)->mainlist->col_data;
				((CICONBLK*)opened[GPICON].ob_spec.iconblk)->mainlist->col_mask=
					((CICONBLK*)oicons[f].ob_spec.iconblk)->mainlist->col_mask;
				w_objc_draw(&wpened, GPICON, 8, sx, sy, sw, sh);
			}
		break;
		case GPM1:
		case GPM2:
			graf_mkstate(&x, &y, &f, &f);
			f=form_popup(omerk, x, y);
			if(f > -1)
			{
				if(ob == GPM1)	pgp.om1=f-MERK_1;
				else						pgp.om2=f-MERK_1;
				opened[ob].ob_spec.bitblk->bi_pdata=omerk[f].ob_spec.bitblk->bi_pdata;
				w_objc_draw(&wpened, GPMS, 8, sx, sy, sw, sh);
			}
		break;
		case GPTA:
		case GPTC:
		case GPTS:
		/* Radiobuttons->Unsel falls bereits sel */
			if(pgp.okbs == ob-GPTA+1)
			{
				pgp.okbs=0;
				opened[ob].ob_state &=(~SELECTED);
				w_objc_draw(&wpened, GPTA-1, 8, sx, sy, sw, sh);
			}
			else
				pgp.okbs=ob-GPTA+1;
		break;
		
		case GPTK:
			form_alert(1,"[3][Gibt's noch nicht][Abbruch]");
			w_unsel(&wpened, ob);
		break;
		
		case GPSTORE:
			if(pens_obs.sel > -1)
			{
				p=find_pen(pens_obs.sel);
				strcpy(alert, "[2][Grape:|Soll der Stift|");
				strcat(alert, p->name);
				strcat(alert,"|Åberschrieben werden?][OK|Abbruch]");
				if(!(form_alert(1,alert)-1))
				{
					get_pened();
					*p=pgp;
					init_pen(pens_obs.sel);
				}
			}
			else
				form_alert(1,"[3][Grape:|Bitte selektieren Sie|zuerst ein Werkzeug!][Abbruch]");
			w_unsel(&wpened, GPSTORE);
		break;
		
		case GPENEDLS:
			get_pened();
			if(quick_io("Werkzeug", paths.penpar_path, &pgp, &pgp, sizeof(PEN_PARAMETER), magics.penpar) == QIOLOAD)
			{
				init_pened();
				s_redraw(&wpened);
			}
		break;
	}
}

void sl_sel_fv(int a)
{
	pgp.verlust=a;
}
void sl_sel_vw(int a)
{
	pgp.wischen=a;
}
void sl_sel_rs(int a)
{
	pgp.rauschen=a;
}
void sl_sel_ah(int a)
{
	pgp.randhell=a;
}
