/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras

	module TEMDRAW : template display

	draw_tem, draw_alltem, draw_ctrls, draw_ctrl
	rect2scr, scr2rect, scale_tem, scale_line, scale_ctrl
	snap_tem, snap_ctrl, clip_ctrl, calc_ctrl, calc_xbut
	joy_limitx, draw_graph, pt_x_max

******************************************************************************/

overlay "tem"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "temdefs.h"		/* template stuff */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */
#include "scan.h"			/* keyboard scan codes */

/* variables in tem1.c ......................................................*/

extern int tem_x,tem_y,tem_w,tem_h;
extern CTRLHEADER ctrlheader;
extern MAC_RECT mac_rect;
extern int curr_page,curr_mem;
extern long curr_leng;
extern int curr_nctrl,curr_nvctrl;
extern int temsnap_x,temsnap_y;
extern int temsnapx,temsnapy,temoutl,temtofit;
extern temdebug;

#if TEMFLAG

/* draw all of current page .................................................*/

draw_alltem()
{
	draw_tem(tem_x,tem_y,tem_x+tem_w-1,tem_y+tem_h-1);
}	/* end draw_alltem() */

/* draw (some of) current page ..............................................*/

draw_tem(x1,y1,x2,y2)
int x1,y1,x2,y2;	/* clipping rectangle */
{
	int w,h;
	register int i;

	/* convert negative rectangle to positive */
	if (x1>x2) { i=x1; x1=x2; x2=i; }
	if (y1>y2) { i=y1; y1=y2; y2=i; }

	/* intersect rectangle with work area not including pallette */
	if (set_clip2(tem_x,tem_y,tem_x+tem_w-1,tem_y+tem_h-1,&x1,&y1,&x2,&y2))
	{
		w= x2-x1+1;
		h= y2-y1+1;

		HIDEMOUSE;

		/* draw matte */
		fill_rect(x1,y1,w,h,0);

		draw_ctrls(x1,y1,x2,y2);

		SHOWMOUSE;
	}

	/* turn off VDI clipping */
	vs_clip(gl_hand,0,0L);

}	/* end draw_tem() */

/* draw controls on current page ............................................*/

draw_ctrls(x1,y1,x2,y2)
int x1,y1,x2,y2;		/* clipping */
{
	register long ptr;
	register int i,type,temp;
	register CTRLHEADER *ctrl;
	int x1c,y1c,x2c,y2c,h,w;

	ptr= heap[curr_mem].start;
	for (i=0; i<curr_nctrl; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		type= ctrl->type;
		if ((type>=0)&&(type!=CTYP_DUMMY))	/* if visible and not dummy */
		{
			/* intersect screen redraw rect with control rect */
			rect2scr(ptr+sizeof(ctrlheader),&x1c,&x2c,&y1c,&y2c);
			if (x1c>x2c) { temp=x1c; x1c=x2c; x2c=temp; }
			if (y1c>y2c) { temp=y1c; y1c=y2c; y2c=temp; }
			if (set_clip2(x1,y1,x2,y2,&x1c,&y1c,&x2c,&y2c))
				draw_ctrl(type,ptr+sizeof(ctrlheader),x1c,y1c,x2c,y2c);
		}
		ptr += ctrl->length;
	}
}	/* end draw_ctrls() */

/* draw a control on current page ...........................................*/

draw_ctrl(type,ptr,x1c,y1c,x2c,y2c)
int type;					/* CTYP_xxxx >0 and not dummy */
register long ptr;		/* --> past control header */
int x1c,y1c,x2c,y2c;		/* clipping rectangle */
{
	register int i,j,but;
	int x[MAXNCALC],y[MAXNCALC],w[MAXNCALC],h[MAXNCALC];
	int x0,y0,w0,h0;
	int val,low,high,color,options;
	int xc,yc,xr,yr;
	int x1,x2,y1,y2;
	char active[MAXNPOINTS];
	int xline[MAXNPOINTS],yline[MAXNPOINTS];
	PT_INFO *pt_info;
	int font,selected;
	char *str,*strpool;
	char numb_buf[10];
	long strx;
	int xy[10];

	CTRL_LINE *line_ptr;
	CTRL_RECT *rect_ptr;
	CTRL_TEXT *text_ptr;
	CTRL_NUMB *numb_ptr;
	CTRL_KNOB *knob_ptr;
	CTRL_SLID *slid_ptr;
	CTRL_IBUT *ibut_ptr;
	CTRL_CBUT *cbut_ptr;
	CTRL_GRPH *grph_ptr;
	CTRL_JOY  *joy_ptr ;

	/* get control screen coordinates */
	calc_ctrl(type,ptr,x,y,w,h);
	x0= x[0];
	y0= y[0];
	w0= w[0];
	h0= h[0];

	/* color */
	color= ((MAC_RECT*)(ptr))->color;
	vdi_colors(color);
	vst_alignment(gl_hand,0,5,&dummy,&dummy);

	/* options bits */
	options= ((MAC_RECT*)(ptr))->options;

	HIDEMOUSE;
	switch (type)
	{
		case CTYP_LINE:
		line_ptr= (CTRL_LINE*)(ptr);
		draw_line(line_ptr->style,x0,y0,w0,h0);
		type= CTYP_DUMMY;	/* don't outline a line control */
		break;

		case CTYP_RECT:
		rect_ptr= (CTRL_RECT*)(ptr);
		fill_box(x0,y0,w0,h0,min(rect_ptr->fill,MAXRECTFILL));
		break;

		case CTYP_TEXT:
		strpool= (char*)( heap[ temmem[ seg_to_mem(idTEMSTRG) ] ].start );
		text_ptr= (CTRL_TEXT*)(ptr);
		font= text_ptr->font;
		val=	(text_ptr->val).val;
		low= (text_ptr->val).low;
		high= (text_ptr->val).high;
		if (val<low) val=low;
		if (val>high) val=high;
		strx= text_ptr->str[val];
		str= strx<0L ? "" : strpool+strx ;
		vdi_font(font);
		/* different values in same text can have different lengths */
		fill_rect(x0,y0,w0,h0,0);
		v_gwraptext(x0,y0,w0,h0,str);
		break;

		case CTYP_NUMB:
		numb_ptr= (CTRL_NUMB*)(ptr);
		font= numb_ptr->font;
		val=	(numb_ptr->val).val;
		low= (numb_ptr->val).low;
		high= (numb_ptr->val).high;
		if (val<low) val=low;
		if (val>high) val=high;
		encode_numb(str=numb_buf,val,low,high);
		vdi_font(font);
		if (font==1) swap_char(str,'0','O');
		v_gtext(gl_hand,x0,y0,str);
		break;

		case CTYP_KNOB:
		xc= x[1];		/* center */
		yc= y[1];
		/* radius -- slightly undersized, because the GEM ellipse routines'
			roundoff errors take the ellipse outside the control's rectangle */
		xr= w0/2 - 1;
		yr= h0/2 - 1;
		vsf_interior(gl_hand,0);
	   vsf_perimeter(gl_hand,0);
		v_ellipse(gl_hand,xc,yc,xr,yr);
		v_ellarc(gl_hand,xc,yc,xr,yr,0,MAXANGLE);
		v_ellarc(gl_hand,xc,yc,xr-2,yr-rez,0,MAXANGLE);
		vswr_mode(gl_hand,3);
		draw_line(0xFFFF,x[1],y[1],w[1],h[1]);
		vswr_mode(gl_hand,1);
		break;

		case CTYP_SLID:
		slid_ptr= (CTRL_SLID*)(ptr);
		j= 2 * (w0>h0) ;							/* horizontal? */
		draw_tri(x[1],y[1],w[1],h[1],j);		/* decrement nipple */
		draw_tri(x[2],y[2],w[2],h[2],j+1);	/* increment nipple */
		fill_box(x[3],y[3],w[3],h[3],2);		/* scroll bar */
		fill_box(x[4]+1,y[4]+1,w[4]-1,h[4]-1,0);		/* slider */
		break;

		case CTYP_IBUT:
		case CTYP_CBUT:
		strpool= (char*)( heap[ temmem[ seg_to_mem(idTEMSTRG) ] ].start );
		ibut_ptr= (CTRL_IBUT*)(ptr);
		cbut_ptr= (CTRL_CBUT*)(ptr);
		draw_xbut(ibut_ptr->nrows,ibut_ptr->ncols,&x[1],&y[1],&w[1],&h[1]);
		vsf_style(gl_hand,1);		/* solid fill for selected button */
	   vsf_interior(gl_hand,1);
		vdi_font(ibut_ptr->font);
		/* text in each button */
		for (i=0,but=1; i<(ibut_ptr->nrows); i++)
		{
			for (j=0; j<(ibut_ptr->ncols); j++,but++)
			{
				if (type==CTYP_CBUT)
				{
					val= (cbut_ptr->val).val;
					strx= cbut_ptr->str[but-1];
					str= strx<0L ? "" : strpool+strx ;
					selected= val==but;
				}
				else
				{
					val= (ibut_ptr->xval[but-1]).val.val ;
					strx= (ibut_ptr->xval[but-1]).str;
					str= strx<0L ? "" : strpool+strx ;
					selected= val == (ibut_ptr->xval[but-1]).val.high ;
				}
				x1= x[but];
				y1= y[but];
				x2= x1 + w[but] - 1 ;
				y2= y1 + h[but] - 1 ;
				/* intersect control rect with button rect */
				vst_color(gl_hand,selected ? 1 : color);
				if (set_clip2(x1c,y1c,x2c,y2c,&x1,&y1,&x2,&y2))
					center_text(str,x[but],y[but],w[but],h[but]);
				set_clip(x1c,y1c,x2c-x1c+1,y2c-y1c+1);
				if (selected) xor_rect(x[but]+2,y[but]+2,w[but]-4,h[but]-4);
			}
		}
		break;

		case CTYP_GRPH:
		fill_rect(x0,y0,w0,h0,0);
		grph_ptr= (CTRL_GRPH*)(ptr);
		y2= y0+h0-1;
		x2= x0+w0-1;
		draw_box(0xFFFF,0xFFFF,x0,y0,x2,y2);	/* outline */
		i= grph_ptr->xaxis;
		if (i>=0) /* x-axis */
		{
			j= ival_to_val(i,0,100,y2,y0);
			draw_line(0xAAAA,x0,j,w0,1);
		}
		i= grph_ptr->yaxis;
		if (i>=0) /* y-axis */
		{
			j= ival_to_val(i,0,100,x0,x2);
			draw_line(0xAAAA,j,y0,1,h0);
		}
		j= grph_ptr->npoints;
		for (i=0; i<j; i++)
		{
			pt_info= &( (grph_ptr->xxval[i]).pt_info );
			active[i]= pt_info->active;
			if ( (pt_info->xmode==PTFIXED) && (pt_info->xline) )
				xline[i]= x[i+1];
			else
				xline[i]= -1;
			if ( (pt_info->ymode==PTFIXED) && (pt_info->yline) )
				yline[i]= y[i+1];
			else
				yline[i]= -1;
		}
		/* draw pts */
		draw_graph(j,active,&x[1],&y[1]);
		/* draw vertical and horizontal lines through pts */
		for (i=0; i<j; i++)
		{
			if (xline[i]>=0) draw_line(0xC0C0,xline[i],y0,1,h0);
			if (yline[i]>=0) draw_line(0xC0C0,x0,yline[i],w0,1);
		}
		break;

		case CTYP_JOY:
		joy_ptr= (CTRL_JOY*)(ptr);
		for (i=0; i<2; i++)
		{
			/* set up diamond */
			xy[0]= xy[4]= xy[8]= x[i] + w[i]/2 ;
			xy[1]= xy[9]= y[i];
			xy[2]= x[i] + w[i] - 1 ;
			xy[3]= xy[7]= y[i] + h[i]/2 ;
			xy[5]= y[i] + h[i] - 1 ;
			xy[6]= x[i];
			vsf_style(gl_hand,i);
			vsf_interior(gl_hand,i);
			v_fillarea(gl_hand,4,xy);
			if (i==0) v_pline(gl_hand,5,xy);		/* border */
		}
		break;

		default:
		type= CTYP_DUMMY;	/* don't outline unknown control type */

	}	/* end switch (type) */
	SHOWMOUSE;

	/* restore VDI attributes */
	vst_alignment(gl_hand,0,0,&dummy,&dummy);
	vdi_colors(1);										/* normal VDI colors */
	vdi_font(0); 										/* normal size font */

	/* selected */
	if (options&1) xor_rect(x0,y0,w0,h0);

	/* outlined */
	if (temoutl&&(type!=CTYP_DUMMY))
		draw_box(0xFFFF,0xFFFF,x0,y0,x0+w0-1,y0+h0-1);

}	/* end draw_ctrl() */

draw_graph(npts,active,x,y)
int npts;
char active[];
register int *x,*y;
{
	register int i,temp;
	int xy[4];
	int xpt,ypt,xprev,yprev;

	HIDEMOUSE;
	vsm_type(gl_hand,4);	/* square markers */
	for (i=0; i<npts; i++)
	{
		xpt= *x++;
		ypt= *y++;
		xy[0]= xprev;
		xy[1]= yprev;
		xy[2]= xpt;
		xy[3]= ypt;
		if (i) v_pline(gl_hand,2,xy);
		xprev=xpt;
		yprev=ypt;
		if (active[i]) v_pmarker(gl_hand,1,&xy[2]);
	}	/* end loop through pts */

	vsm_type(gl_hand,1);	/* pt markers */
	SHOWMOUSE;

}	/* end draw_graph() */

setfixpts(xfix,npts,xxval,x0,x2)
int xfix[];
int npts;
XXVAL_INFO *xxval;
int x0,x2;
{
	register int i;
	int xprev;

	xprev= 0;
	for (i=0; i<npts; i++)
	{
		if (xxval[i].pt_info.xmode==PTFIXED)
		{
			xfix[i]= ival_to_val(xxval[i].pt_info.xfactor,0,100,x0,x2);
			xprev= xfix[i]= max(xfix[i],xprev);
		}
		else
			xfix[i]= -1;
	}
}	/* end setfixpts() */

scalxfactors(xfac,npts,xxval)
int xfac[];
int npts;
register XXVAL_INFO *xxval;
{
	register int i,j,sum;

	sum= -1;
	for (i=0; i<npts; i++)
	{
		if (xxval[i].pt_info.xmode==PTFOLLOW)
		{
			if (sum<0)
			{
				for (sum=0,j=i; j<npts; j++)
				{
					if (xxval[j].pt_info.xmode==PTFIXED) break;
					sum += xxval[j].pt_info.xfactor;
				}
			}
			xfac[i]= ival_to_val(xxval[i].pt_info.xfactor,0,sum,0,100);
		}
		else
			sum= -1;
	}
}	/* end scalxfactors() */

/* find parts of a control ..................................................*/
/* returns # of entries in x,y,w,h arrays (always >0) */

calc_ctrl(type,ctrl,x,y,w,h)
int type;	/* visible CTYP_xxxx */
long ctrl;	/* --> past header */
int *x,*y,*w,*h;
{
	register int i,j,k;
	int x1,x2,y1,y2,w1,h1;
	int ncols,nrows;
	int xc,yc,xr,yr,xmin,xmax;
	int xprev,yprev,xprevfix,npts,xfac[MAXNPOINTS],xfix[MAXNPOINTS];
	PT_INFO *pt_info;
	CTRL_SLID *slid_ptr;
	CTRL_IBUT *ibut_ptr;
	CTRL_JOY  *joy_ptr;
	CTRL_GRPH *grph_ptr;
	CTRL_KNOB *knob_ptr;
	XXVAL_INFO *xxval;

	/* first entry in arrays is control outline */
	i=0;
	rect2scr(ctrl,&x1,&x2,&y1,&y2);
	x[i]= x1;
	y[i]= y1;
	w1= w[i]= x2-x1+1;					/* might be <0 for a line */
	h1= h[i++]= y2-y1+1;

	/* these have only one part */
	if ( (type==CTYP_NUMB) || (type==CTYP_TEXT) || (type==CTYP_LINE) ||
		  (type==CTYP_RECT) ) return 1;

	switch (type)
	{
		case CTYP_SLID:
		slid_ptr= (CTRL_SLID*)ctrl;
		if (w1<h1)		/* vertical */
		{
			j= min(w1/(3-rez),2*charh);	/* nipple height */
			j= min(j,h1/3);
			j= max(j,0);
			/* decrement nipple */
			x[i]= x1;	y[i]= y2-j;		w[i]= w1;	h[i++]= j;
			/* increment nipple */
			x[i]= x1;	y[i]= y1;		w[i]= w1;	h[i++]= j;
			/* scroll bar */
			x[i]= x1;	y[i]= y1+j;		w[i]= w1;	h[i++]= h1 - 2*j ;
			/* slider */
			y[i]= scalvalinfo(&(slid_ptr->val),y2-2*j,y1+j);
			x[i]= x1;					w[i]= w1-1;		h[i++]= j;
		}
		else					/* horizontal */
		{
			j= min(h1*(3-rez),2*charh);	/* nipple width */
			j= min(j,w1/3);
			j= max(j,0);
			/* decrement nipple */
			x[i]=	x1;		y[i]= y1;	w[i]= j;				h[i++]= h1;
			/* increment nipple */
			x[i]=	x2-j;		y[i]= y1;	w[i]= j;				h[i++]= h1;
			/* scroll bar */
			x[i]=	x1+j;		y[i]= y1;	w[i]= w1 - 2*j;	h[i++]= h1;
			/* slider */
			x[i]= scalvalinfo(&(slid_ptr->val),x1+j,x2-2*j);
			y[i]= y1;	w[i]=	j;			h[i++]= h1-1;
		}
		break;

		case CTYP_IBUT:
		case CTYP_CBUT:	/* nrows, ncols same place in both structures */
		ibut_ptr= (CTRL_IBUT*)ctrl;
		ncols= ibut_ptr->ncols;
		nrows= ibut_ptr->nrows;
		calc_xbut(x1,y1,w1,h1,nrows,ncols,&x[1],&y[1],&w[1],&h[1]);
		i= 1 + nrows*ncols;
		break;

		case CTYP_GRPH:
		grph_ptr= (CTRL_GRPH*)ctrl;
		y2= y1+h1-1;		/* bottom edge */
		x2= x1+w1-1;		/* right edge */
		xprev= xprevfix= x1;
		yprev= y2;
		npts= grph_ptr->npoints;
		xxval= &(grph_ptr->xxval[0]);
		setfixpts(xfix,npts,xxval,x1,x2);
		scalxfactors(xfac,npts,xxval);
		for (j=0; j<npts; j++)
		{
			pt_info= &( (grph_ptr->xxval[j]).pt_info );
			if (pt_info->xmode==PTFIXED)
				xprevfix= x[i]= xfix[j];
			else
			{
				k= pt_x_max(j,npts,xxval,xfix,x1,x2);
				x[i]= scalvalinfo( &((grph_ptr->xxval[j]).xval),xprev,xprev+k);
			}
			switch (pt_info->ymode)
			{
				case PTFIXED:
				y[i]= ival_to_val(pt_info->yfactor,0,100,y2,y1);
				break;

				case PTFOLLOW:
				y[i]= yprev;
				break;

				case PTFULL:
				y[i]= scalvalinfo( &((grph_ptr->xxval[j]).yval),y2,y1);
			}
			xprev= x[i];
			yprev= y[i];
			w[i]= h[i]= 1;	/* pt */
			i++;
		}	/* end loop through pts */
		break;

		case CTYP_KNOB:
		knob_ptr= (CTRL_KNOB*)(ctrl);
		xc= x1 + w1/2;		/* center */
		yc= y1 + h1/2;
		x[i]=xc;		y[i]=yc;
		/* radius */
		xr= w1/2 - 1;
		yr= h1/2 - 1;
		j= scalvalinfo(&(knob_ptr->val),0,MAXANGLE-KNOBANGLE);
		j= MAXANGLE - MAXANGLE/4 - KNOBANGLE/2 - j ;
		if (j<0) j+=MAXANGLE;
		j /= 10 ;	/* degrees */
		yr--;
		xr--;
		/* !!!...
		w[i]= 1 + (xr*(long)iCosine(j))/32000L ;
		h[i++]= 1 - (yr*(long)iSine(j))/32000L ;
		...*/
		xr -= 2;
		yr -= rez;
		w[i]= 1 + (xr*(long)iCosine(j))/32000L ;
		h[i++]= 1 - (yr*(long)iSine(j))/32000L ;
		break;

		case CTYP_JOY:
		joy_ptr= (CTRL_JOY*)(ctrl);
		j= JOYSTICKW/(3-rez);
		xc= scalvalinfo(&(joy_ptr->val[0]),x1+JOYSTICKW,x2-JOYSTICKW);
		yc= scalvalinfo(&(joy_ptr->val[1]),y2-j,y1+j);
		joy_limitx(yc,x1+w1/2,y1+h1/2,w1/2,h1/2,&xmin,&xmax);
		if (xc>xmax) xc= xmax;
		if (xc<xmin) xc= xmin;
		w[i]= 1 | (2*(JOYSTICKW-1));
		h[i]= 1 | (2*((JOYSTICKW-1)/(3-rez)));
		x[i]= xc - w[i]/2;
		y[i]= yc - h[i]/2;
		i++;

	}	/* end switch (type) */
	return i;
}	/* end calc_ctrl() */

/* constrain joy stick indicator to diamond .................................*/

joy_limitx(y,xc,yc,h,k,xmin,xmax)
int y,xc,yc,h,k;
int *xmin,*xmax;
{
	register long templong;
	long hyhk,kxc;

	hyhk= (long)h*abs(y-yc) + (long)h*k;
	kxc= (long)k*xc;

	templong= ( kxc - hyhk ) / k ;
	templong= xc-h + (xc-h) - templong ;
	*xmin= templong + JOYSTICKW ;

	templong= ( kxc + hyhk ) / k ;
	templong= xc+h + xc+h - templong ;
	*xmax= templong - JOYSTICKW ;

}	/* end joy_limitx() */

/* x range of movable point on graph ........................................*/
/* returns pixels (>=0) */

pt_x_max(which,npts,xxval,x,x1,x2)
int which,npts;
XXVAL_INFO *xxval;
int x[];			/* absolute x-coord's (only the fixed ones need to be valid) */
int x1,x2;
{
	register int i;
	int xprevfix,xnextfix;
	int xfac[MAXNPOINTS];

	scalxfactors(xfac,npts,xxval);
	for (i= which-1; i>=0; i--) if (xxval[i].pt_info.xmode==PTFIXED) break;
	xprevfix= i>=0 ? x[i] : x1 ;
	for (i= which+1; i<npts; i++) if (xxval[i].pt_info.xmode==PTFIXED) break;
	xnextfix= i<npts ? x[i] : x2 ;
	i= ival_to_val(xfac[which],0,100,0,xnextfix-xprevfix);
	return ival_to_val(xxval[which].xval.high,xxval[which].xval.low,
							xxval[which].xval.high,0,i);
}	/* end pt_x_max() */

/* divide up rectangle into buttons .........................................*/

calc_xbut(x1,y1,w1,h1,nrows,ncols,x,y,w,h)
int x1,y1,w1,h1;	/* the rectangle */
int nrows,ncols;
int *x,*y,*w,*h;	/* output */
{
	int xcell,ycell,wcell,hcell,wbut,hbut;
	register int r,c;

	wcell= w1/ncols;
	hcell= h1/nrows;

	/* adjacent buttons don't touch */
	wbut= ncols>1 ? max(0,wcell-4) : wcell ;
	hbut= nrows>1 ? max(0,hcell-2*rez) : hcell ;

	ycell= y1;
	for (r=0; r<nrows; r++,ycell+=hcell)
	{
		xcell= x1;
		for (c=0; c<ncols; c++,xcell+=wcell)
		{
			*x++ = xcell;
			*y++ = ycell;
			*w++ = wbut;
			*h++ = hbut;
		}
	}
}	/* end calc_xbut() */

/* encode number control value ..............................................*/

encode_numb(buf,val,low,high)
char *buf;		/* --> where to encode */
int val;			/* value to be encoded */
int low,high;	/* value limits */
{
	int n;
	long longval,longlow,longhigh;

	longval=val;	longlow=low;	longhigh=high;

	if ( (longlow<0) || (longhigh<0) )	*buf++ = longval<0 ? '-' : '+' ;
	if (longval<0) longval= -longval;
	if (longlow<0) longlow= -longlow;
	if (longhigh<0) longhigh= -longhigh;
	n= max( ndigits(longlow) , ndigits(longhigh) ) ;
	ltoa(longval,buf,n);
}	/* end encode_numb() */

/* draw button array ........................................................*/

draw_xbut(nrows,ncols,x,y,w,h)
int nrows,ncols;
int x[],y[],w[],h[];
{
	register int r,c,i;

	for (r=i=0; r<nrows; r++)
	{
		for (c=0; c<ncols; c++,i++)
		{
			draw_box(0xFFFF,0xFFFF,x[i],y[i],x[i]+w[i]-1,y[i]+h[i]-1);
			fill_box(x[i]+1,y[i]+1,w[i]-2,h[i]-2,0);
		}
	}
}	/* end draw_xbut() */

/* get scaled value from val_info ...........................................*/

scalvalinfo(val,low2,high2)
VAL_INFO *val;
int low2,high2;
{
	return
		ival_to_val(val->val,val->low,val->high,low2,high2);
}	/* end scalvalinfo() */

/* scale all controls on a page .............................................*/

scale_tem(ptr,nbytes,xnum,xden,ynum,yden)
register long ptr;		/* --> what's to be scaled */
register long nbytes;	/* # bytes in what's to be scaled */
int xnum,xden;				/* horizontal scaling ratio */
int ynum,yden;				/* vertical scaling ratio */
{
	CTRLHEADER *ctrl;
	long rect;
	int type;

	while (nbytes>sizeof(ctrlheader))
	{
		ctrl= (CTRLHEADER*)(ptr);
		type= ctrl->type;
		if (type>=0)	/* can't scale invisible controls */
		{
			rect= ptr+sizeof(ctrlheader);
			if (type==CTYP_LINE)
				scale_line(rect,xnum,xden,ynum,yden);
			else
				scale_ctrl(rect,xnum,xden,ynum,yden);
			snap_ctrl(type,rect,1,1);	/* keeps control on screen */
		}
		ptr += ctrl->length;
		nbytes -= ctrl->length;
	}	/* end scan through page */

}	/* end scale_tem() */

/* scale a line control .....................................................*/

scale_line(rect,xnum,xden,ynum,yden)
MAC_RECT *rect;
int xnum,xden,ynum,yden;
{
	register long temp;

	temp= rect->x1;	temp *= xnum;	temp /= xden;
	rect->x1= temp;

	temp= rect->x2;	temp *= xnum;	temp /= xden;
	rect->x2= temp;

	temp= rect->y1;	temp *= ynum;	temp /= yden;
	rect->y1= temp;

	temp= rect->y2;	temp *= ynum;	temp /= yden;
	rect->y2= temp;

}	/* end scale_line() */

/* scale a non-line control .................................................*/

scale_ctrl(rect,xnum,xden,ynum,yden)
MAC_RECT *rect;
int xnum,xden,ynum,yden;
{
	int x,y,w,h;

	x= rect->x1;
	y= rect->y1;
	w= rect->x2 - x + 1 ;
	h= rect->y2 - y + 1 ;

	rect->x1= ( (long)x * (long)xnum ) / xden ;
	rect->y1= ( (long)y * (long)ynum ) / yden ;
	rect->x2= rect->x1 - 1 + ( (long)w * (long)xnum ) / xden ;
	rect->y2= rect->y1 - 1 + ( (long)h * (long)ynum ) / yden ;

}	/* end scale_ctrl() */

/* snap/clip all controls on current page ...................................*/

snap_tem(snap,clip)
int snap,clip;
{
	register int i,type;
	register long ptr,rect;
	CTRLHEADER *ctrl;

	/* loop through all visible controls: snap, clip */
	ptr= heap[curr_mem].start;
	for (i=0; i<curr_nvctrl; )
	{
		ctrl= (CTRLHEADER*)(ptr);
		type= ctrl->type;
		if (type>=0)
		{
			rect= ptr + sizeof(ctrlheader);
			if (snap) snap_ctrl(type,rect,temsnap_x,temsnap_y);
			if (clip) clip_ctrl(type,rect);
			i++;
		}
		ptr += ctrl->length;
	}

}	/* end snap_tem() */

/* snap a control ...........................................................*/

snap_ctrl(type,rect,snap_x,snap_y)
int type;	/* CTYP_xxxx, >=0 */
MAC_RECT *rect;
int snap_x,snap_y;
{
	int x1,y1,x2,y2;
	int w,h;

	/* control's current rectangle */
	x1= rect->x1;
	x2= rect->x2;
	y1= rect->y1;
	y2= rect->y2;

	w= x2-x1+1;
	h= y2-y1+1;

	if (temsnapx)		/* snap_x guaranteed > 1 */
	{
		x1= quantize_val(x1,snap_x,0,639);
		if (type==CTYP_LINE)
			x2= quantize_val(x2,snap_x,0,639);
		else
		{
			x2= x1+w-1;
			while (x2>=640)
			{
				x2 -= snap_x;
				x1 -= snap_x;
			}
		}
	}
	if (temsnapy)		/* snap_y guaranteed > 1 */
	{
		y1= quantize_val(y1,snap_y,0,tem_h-1);
		if (type==CTYP_LINE)
			y2= quantize_val(y2,snap_y,0,tem_h-1);
		else
		{
			y2= y1+h-1;
			while (y2>=tem_h)
			{
				y2 -= snap_y;
				y1 -= snap_y;
			}
		}
	}

	/* control's new rectangle */
	rect->x1 = x1;
	rect->y1 = y1;
	rect->x2 = x2;
	rect->y2 = y2;

	clip_ctrl(type,rect);

}	/* end snap_ctrl() */

/* change function name, move to misc.c, use throughout !!! */
quantize_val(val,q,low,high)
int val,q,low,high;
{
	int rem;

	rem= val%q;
	if (rem<(q/2))
		val -= rem;
	else
		val += (q-rem);
	while (val<low) val += q;
	while (val>high) val -= q;
	return val;
}	/* end quantize_val() */

/* enforce min/max size for each type control ...............................*/

clip_ctrl(type,rect)
register int type;	/* CTYP_xxxx, >=0 */
register MAC_RECT *rect;
{
	register int i,w,h;
	CTRL_TEXT *text_ptr;
	CTRL_NUMB *numb_ptr;
	int low,high;
	char lowbuf[16],highbuf[16];	/* oversized */

	/* control's width and height */
	w= rect->x2 - rect->x1 + 1 ;
	h= rect->y2 - rect->y1 + 1 ;

	switch (type)
	{
		case CTYP_RECT:
		case CTYP_LINE:	break;	/* can be a pt */

		case CTYP_KNOB:				/* square, but accounting for aspect ratio */
		case CTYP_JOY :
		if (rez==1) h *= 2;
		w= min(w,h);
		h= w= max(w,2*JOYSTICKW+1);
		if (rez==1) h /= 2;
		w |= 1;		/* must be odd */
		h |= 1;
		break;
		
		case CTYP_TEXT:
		text_ptr= (CTRL_TEXT*)rect;
		vdi_font(text_ptr->font);
		w= max(w,charw);
		h= max(h,charh);
		if (temtofit)
		{
			h= quantize_val(h,charh+1,charh+1,0x7FFF)-1;
			w= quantize_val(w,charw,charw,0x7FFF);
		}
		break;

		case CTYP_NUMB:
		numb_ptr= (CTRL_NUMB*)rect;
		vdi_font(numb_ptr->font);
		w= max(w,charw);
		h= max(h,charh);
		if (temtofit)
		{
			h= charh;
			low= (numb_ptr->val).low;
			high= (numb_ptr->val).high;
			encode_numb(lowbuf,low,low,high);
			encode_numb(highbuf,high,low,high);
			w= charw * max(strlen(lowbuf),strlen(highbuf)) ;
		}
		break;

		case CTYP_SLID:
		w= max(w,3);
		h= max(h,3);
		/* dimension perpendicular to travel dimension must be odd */
		if (w<h)	/* vertical */
			w |= 1;
		else		/* horizontal */
			h |= 1;
		break;

		default:
		w= max(w,3);
		h= max(h,3);

	}	/* end switch (type) */
	vdi_font(0);

	rect->x1= max(rect->x1,0);
	rect->y1= max(rect->y1,0);
	rect->x2= min( 639 , rect->x1 + w - 1 );
	rect->y2= min( tem_h-1 , rect->y1 + h - 1 );

}	/* end clip_ctrl() */

/* convert MAC_RECT to absolute screen coordinates ..........................*/

rect2scr(rect,x1,x2,y1,y2)
register MAC_RECT *rect;
int *x1,*x2,*y1,*y2;
{
	*x1= rect->x1;
	*x2= rect->x2;
	*y1= rect->y1 + tem_y ;	/* absolute screen coordinates */
	*y2= rect->y2 + tem_y ;
}	/* end rect2scr() */

/* convert absolute screen coordinates to MAC_RECT ..........................*/

scr2rect(x1,x2,y1,y2,rect)
int x1,x2,y1,y2;
register MAC_RECT *rect;
{
	rect->x1= x1;
	rect->x2= x2;
	rect->y1= y1 - tem_y ;	/* relative coordinates */
	rect->y2= y2 - tem_y ;
}	/* end scr2rect() */

#endif

/* EOF */
