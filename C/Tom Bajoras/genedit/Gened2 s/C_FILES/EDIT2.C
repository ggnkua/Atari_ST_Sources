/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                         Copyright 1990/1991 Tom Bajoras

	module EDIT2 : editor middle level

	hndl_ctrl

	hndl_joy, hndl_grph, hndl_slid, hndl_knob, hndl_moment, hndl_numb

	hndl_midi, hndl_linked

******************************************************************************/

overlay "edit"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "scan.h"			/* keyboard scan codes */
#include "temdefs.h"		/* template stuff */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* local globals ............................................................*/

char *strpool;
EBDT *ebdt;
int editcolor;
long pageptr;
long *addrtable;
int ebdt_list[MAXNVALS],midi_list[MAXNVALS];
int editctrl_i;

/* in tem.c .................................................................*/

extern int curr_page,curr_mem;
extern int temoutl;
extern MAC_RECT mac_rect;

/* in edit1.c ...............................................................*/

extern int edit_side,edit_pat;
extern int edit_chng;
extern int edit_orig;
extern int edit_chan;
extern int origmem,chgtabmem,ptabmem,addrmem,backmem;
extern int chgtabn;

#if (EDITFLAG*TEMFLAG)

/* handle mouse clicked on control ..........................................*/
/* returns 1 edit buffer changed, 0= not changed */

hndl_ctrl(ctrl_i,ctrl,kstate,mst,mx,my)
int ctrl_i;
CTRLHEADER *ctrl;		/* --> ctrlheader */
int kstate,mst,mx,my;
{
	register int i,j;
	register long templong;

	char whichval[MAXNVALS];
	char *poptitle;

	int mstate,type,nval,nparts,nstr;
	int x1,x2,y1,y2,xslide,yslide,flag,nbuts;
	int x[MAXNCALC],y[MAXNCALC],w[MAXNCALC],h[MAXNCALC];
	int oldval[MAXNVALS];
	int result;
	int mrpt=0;		/* default is no mouse auto-repeat */

	long ctrlptr,newlow,newhigh;
	long editstart,editend;
	long delval[MAXNVALS],neweditval[MAXNVALS],low[MAXNVALS],high[MAXNVALS];
	long val_to_val(),geteditval();
	long *strx;

	CTRL_EBDT *ebdt_ptr;
	CTRL_TEXT *text_ptr;
	CTRL_CBUT *cbut_ptr;
	CTRL_IBUT *ibut_ptr;
	CTRL_GRPH *grph_ptr;
	CTRL_KNOB *knob_ptr;
	XXVAL_INFO *xxval;
	VAL_INFO *val[MAXNVALS];
	EBDT *this_ebdt;

	/* ignore click on output-only control */
	if (isctrlbit(ctrl,6)) return 0;

	/* --> past ctrl header */
	ctrlptr= (long)ctrl + sizeof(*ctrl);

	/* color */
	editcolor= ((MAC_RECT*)(ctrlptr))->color;

	/* find val_info's in control, don't handle if there are none */
	type= ctrl->type;
	nval= find_vals(type,ctrlptr,val);
	if (!nval)
	{
		waitmouse();
		return 0;
	}

	/* find parts of control that can be handled */
	nparts= calc_ctrl(type,ctrlptr,x,y,w,h);
	x1= x[0];
	y1= y[0];
	x2= x1 + w[0] - 1 ;
	y2= y1 + h[0] - 1 ;

	/* start with nothing changed, and find ebdt and midi ctrls */
	set_bytes(whichval,(long)MAXNVALS,0);
	for (i=0; i<nval; i++)
	{
		oldval[i]=	val[i]->val;
		low[i]=		val[i]->low;
		high[i]=		val[i]->high;
		delval[i]=	0;
		find_e_m(ctrl_i,val[i],&ebdt_list[i],&midi_list[i]);
	}

	/* set up local globals */
	strpool= (char*)(heap[ temmem[ seg_to_mem(idTEMSTRG) ] ].start);
	n_of_ebdt(&ebdt);
	pageptr= heap[curr_mem].start;
	addrtable= (long*)(heap[addrmem].start);
	editctrl_i= ctrl_i;

	/* convert L/R click to -1/+1 */
	mstate= but2val(mst);

	switch (type)
	{
		case CTYP_TEXT:
		templong= high[0]-low[0];
		if (!templong) break;			/* static text */
		switch (kstate)
		{
			case K_ALT:
			delval[0]= -oldval[0];
			break;
			
			case K_LSHIFT:
			case K_RSHIFT:
			text_ptr= (CTRL_TEXT*)(ctrlptr);
			nstr= high[0]-low[0]+1;
			strx= &(text_ptr->str[0]);
			/* convert to absolute string addresses, don't convert nulls */
			for (j=0; j<nstr; j++)
				if (strx[j]!=(-1L)) strx[j] += (long)strpool;
			/* construct title for pop-up */
			j= ebdt_list[0];
			if (j>=0)
			{
				ebdt_ptr= (CTRL_EBDT*)( pageptr + addrtable[j] + sizeof(*ctrl) );
				j= ebdt_ptr->index;
			}
			if (j<0)				/* not connected to an ebdt entry */
				poptitle= " ";
			else
				poptitle= (ebdt+j)->name;
			j= pop_up(poptitle,oldval[0],nstr,&dummy,0,strx);
			if (j<0) j=oldval[0];
			delval[0]= j-oldval[0];
			/* convert back to string pool offsets, don't convert nulls */
			for (j=0; j<nstr; j++)
				if (strx[j]!=(-1L)) strx[j] -= (long)strpool;
			mrpt= (high[0]-low[0])>1;
			break;
			
			default:
			if (isctrlbit(ctrl,5))
			{
				hndl_numb(CTYP_TEXT,mst,ctrlptr,val[0]);
				delval[0]= val[0]->val - oldval[0] ;
				val[0]->val= oldval[0];
			}
			else
			{
				delval[0]=mstate;
				mrpt=1;
			}
		}	/* end switch (kstate) */
		whichval[0]=1;
		break;

		case CTYP_NUMB:
		switch (kstate)
		{
			case K_ALT:
			templong= (low[0]<=0) && (high[0]>=0) ? 0 : low[0] ;
			delval[0]= templong-oldval[0];
			break;
			
			case K_LSHIFT:
			case K_RSHIFT:
			if ( high[0]-low[0] > 10 ) mstate *= 10;
			delval[0]= mstate;
			mrpt= (high[0]-low[0])>1;
			break;

			default:
			if (isctrlbit(ctrl,5))
			{
				hndl_numb(CTYP_NUMB,mst,ctrlptr,val[0]);
				delval[0]= val[0]->val - oldval[0] ;
				val[0]->val= oldval[0];
			}
			else
			{
				delval[0]=mstate;
				mrpt=1;
			}
		}	/* end switch (kstate) */
		whichval[0]=1;
		break;

		case CTYP_KNOB:
		knob_ptr= (CTRL_KNOB*)(ctrlptr);
		switch (kstate)
		{
			case K_ALT:
			templong= (low[0]<=0) && (high[0]>=0) ? 0 : low[0] ;
			delval[0]= templong-oldval[0];
			break;
			
			default:
			if (isctrlbit(ctrl,5))
				delval[0]= hndl_knob(ctrlptr,x,y,w,h,&(knob_ptr->val));
			else
			{
				delval[0]= mstate;
				mrpt=1;
			}

		}	/* end switch (kstate) */
		/* no wrap */
		templong= oldval[0]+delval[0];
		if (templong<low[0]) templong=low[0];
		if (templong>high[0]) templong=high[0];
		delval[0]= templong-oldval[0];
		whichval[0]=1;
		break;

		case CTYP_SLID:
		if (kstate==K_ALT)
		{
			templong= (low[0]<=0) && (high[0]>=0) ? 0 : low[0] ;
			delval[0]= templong-oldval[0];
			whichval[0]=1;
			break;
		}
		/* find slider before scroll bar */
		for (i=1; i<nparts; i++)
			if ( (i!=3) && in_rect(mx,my,x[i],y[i],w[i],h[i]) ) break;
		if (i==nparts) i=3;
		j= (kstate==K_LSHIFT) || (kstate==K_RSHIFT) ;
		switch (i)
		{
			case 1:	/* decrement */
			mstate= -1;
			if ( j && ((high[0]-low[0])>=20) )
				mstate *= (high[0]-low[0])/10 ;
			templong= oldval[0]+mstate;
			mrpt=1;
			break;
			
			case 2:	/* increment */
			mstate= 1;
			if ( j && ((high[0]-low[0])>=20) )
				mstate *= (high[0]-low[0])/10 ;
			templong= oldval[0]+mstate;
			mrpt=1;
			break;

			case 3:	/* scroll bar */
			xslide= x[4];
			yslide= y[4];
			if (w[0]>h[0])	/* horizontal */
				xslide= max(x[3],mx-w[4]/2);
			else
				yslide= max(y[3],my-h[4]/2);
			templong= val_of_slid(xslide,yslide,w[4],h[4],
							  x[3],y[3],w[3],h[3],(int)low[0],(int)high[0]);
			break;

			case 4:	/* slider */
			hndl_slid(x[4],y[4],w[4],h[4],x[3],y[3],w[3],h[3],val[0]);
			templong= val[0]->val;
			val[0]->val= oldval[0];
		}
		/* no wrap */
		if (templong<low[0])
		{
			templong=low[0];
			mrpt=0;
		}
		if (templong>high[0])
		{
			templong=high[0];
			mrpt=0;
		}
		delval[0]= templong-oldval[0];
		whichval[0]=1;
		break;

		case CTYP_IBUT:
		ibut_ptr= (CTRL_IBUT*)(ctrlptr);
		for (i=1; i<nparts; i++)
			if (in_rect(mx,my,x[i],y[i],w[i],h[i])) break;
		if (i==nparts) break;
		i--;	/* button # */
		flag= ibut_ptr->flag;
		nbuts= ibut_ptr->nrows * ibut_ptr->ncols ;
		if ( flag && (nbuts==1) )	/* momentary */
		{
			hndl_moment(ctrlptr,type,val[0]);
			whichval[0]=1;
			break;
		}
		if (oldval[i]==high[i])	/* clicked on selected button */
		{
			if (!flag)
			{
				delval[i]= low[i]-oldval[i];
				whichval[i]=1;
			}
		}
		else
		{
			for (j=0; j<nval; j++)
			{
				delval[j]= j==i ? high[j]-oldval[j] : low[j]-oldval[j] ;
				whichval[j]=1;
			}
		}
		break;

		case CTYP_CBUT:
		cbut_ptr= (CTRL_CBUT*)(ctrlptr);
		for (i=1; i<nparts; i++)
			if (in_rect(mx,my,x[i],y[i],w[i],h[i])) break;
		if (i==nparts) break;
		flag= cbut_ptr->flag;
		nbuts= cbut_ptr->nrows * cbut_ptr->ncols ;
		if ( flag && (nbuts==1) )	/* momentary */
		{
			hndl_moment(ctrlptr,type,val[0]);
			whichval[0]=1;
			break;
		}
		if (i==oldval[0])	/* clicked on selected button */
		{
			if (!flag)
			{
				delval[0]= -oldval[0];
				whichval[0]=1;
			}
		}
		else
		{
			delval[0]= i-oldval[0];
			whichval[0]=1;
		}
		break;

		case CTYP_GRPH:
		grph_ptr= (CTRL_GRPH*)(ctrlptr);
		xxval= &(grph_ptr->xxval[0]);
		if (kstate==K_ALT)		/* initialize active pts */
		{
			for (i=0; i<nval; i++)
				if (xxval[i/2].pt_info.active)
					val[i]->val= (low[i]<=0) && (high[i]>=0) ? 0 : low[i] ;
		}
		else
		{
			/* scan backwards in case pts overlap */
			for (i=nparts-1; i>=1; i--)
				if (in_rect(mx,my,x[i]-4,y[i]-3,9,7))
					if (xxval[i-1].pt_info.active) break;
			if (!i) break;
			hndl_grph(grph_ptr->npoints,i-1,xxval,&x[1],&y[1],
							grph_ptr->xaxis,grph_ptr->yaxis,x1,y1,x2,y2);
		}
		for (i=0; i<nval; i++)
		{
			templong= val[i]->val;
			delval[i]= templong-oldval[i];
			val[i]->val= oldval[i];
			whichval[i]= 1;
		}
		break;

		case CTYP_JOY:
		if (kstate==K_ALT)
			for (j=0; j<2; j++) val[j]->val= (low[j]+high[j])/2;
		else
			hndl_joy(x[1]+w[1]/2,y[1]+h[1]/2,x[0],y[0],w[0],h[0],val);
		for (j=0; j<2; j++)
		{
			templong= val[j]->val;
			delval[j]= templong-oldval[j];
			val[j]->val= oldval[j];
			whichval[j]= 1;
		}
	}	/* end switch (type) */

	/* update values in this control, update midi */
	for (result=j=0; j<nval; j++)
	{
		if (whichval[j])
		{
			newlow= low[j];
			newhigh= high[j];
			/* wrap around */
			templong= oldval[j] + delval[j];
			if (templong<newlow) templong=newhigh;
			if (templong>newhigh) templong=newlow;
			val[j]->val= templong;
			hndl_midi(j,val[j],1);
			result=1;
		}
	}
	if (!result) return 0;

	/* start and end of edit buffer */
	editstart= heap[editmem].start;
	templong=  heap[editmem].nbytes;
	editend= editstart + templong;

	/* backup edit buffer before it changes */
	copy_bytes(editstart,heap[backmem].start,templong);

	/* update edit buffer from this control, note whether anything changes */
	for (j=result=0; j<nval; j++)
	{
		if ( whichval[j] && (ebdt_list[j]>=0) )
		{
			newlow= low[j];
			newhigh= high[j];
			templong= val[j]->val;
			if (val[j]->invert)
			{
				asm {
					move.l	newlow(a6),d0
					move.l	newhigh(a6),newlow(a6)
					move.l	d0,newhigh(a6)
				}
			}
			ebdt_ptr= (CTRL_EBDT*)(pageptr+addrtable[ebdt_list[j]]+sizeof(*ctrl));
			this_ebdt= ebdt + ebdt_ptr->index ;
			templong= val_to_val(templong,newlow,newhigh,
										 this_ebdt->low,this_ebdt->high);
			/* info about first changed parameter, for validate segment */
			if (!result)
			{
				cnxvars[VAR_LPO]= this_ebdt->offset;
				cnxvars[VAR_LPV]= geteditval(this_ebdt,editstart);
			}
			seteditval(this_ebdt,editstart,templong);
			neweditval[j]=templong;
			result=1;
		}
	}

	/* always redraw this control */
	*(int*)(heap[chgtabmem].start)= ctrl_i;
	chgtabn=1;

	/* if there's a validate segment, run it */
	if ( !isctrlbit(ctrl,5) && (edit_side>=0) )
		exec_seg(windcnxmem[edit_side],(int)cnxVLDT,editstart,editend,
					editstart,editend,0L);

	/* if validate changed any parameter linked to this control, then we
		must recompute the values in this control -- otherwise don't,
		because that introduces rounding errors for ctrl val range != parameter
		range (ctrl sets parameter, parameter sets ctrl) */
	for (j=0; j<nval; j++)
	{
		if ( whichval[j] && (ebdt_list[j]>=0) )
		{
			ebdt_ptr= (CTRL_EBDT*)(pageptr+addrtable[ebdt_list[j]]+sizeof(*ctrl));
			this_ebdt= ebdt + ebdt_ptr->index ;
			templong= geteditval(this_ebdt,editstart);
			if (templong != neweditval[j] )
			{
				seteditval(this_ebdt,heap[backmem].start,templong+1);
				break;
			}
		}
	}

	/* set control values from edit buffer, mark which controls to be redrawn */
	setallvals(1,j==nval ? ctrl_i : -1);
	draw_chg();

	/* optional mouse repeat */
	if (!mrpt) waitmouse();

	return result;

}	/* end hndl_ctrl() */

/* optimized redraw 1 control ...............................................*/

draw_1chg(ptr,type,x,y,w,h)
long ptr;					/* --> past ctrl header */
int type;
int x[],y[],w[],h[];		/* where control parts are before the change */
{
	int x1old,x2old,y1old,y2old;
	int x1new,x2new,y1new,y2new;

	set_clip(x[0],y[0],w[0],h[0]);
	switch (type)
	{
		case CTYP_KNOB:
		vswr_mode(gl_hand,3);
		draw_line(0xFFFF,x[1],y[1],w[1],h[1]);
		calc_ctrl(type,ptr,x,y,w,h);
		draw_line(0xFFFF,x[1],y[1],w[1],h[1]);
		vswr_mode(gl_hand,1);
		break;

		case CTYP_SLID:
		x1old= x[4];
		y1old= y[4];
		x2old= x[4]+w[4]-1;
		y2old= y[4]+h[4]-1;
		calc_ctrl(type,ptr,x,y,w,h);
		x1new= x[4];
		y1new= y[4];
		x2new= x[4]+w[4]-1;
		y2new= y[4]+h[4]-1;
		slider_chg(x1old,x2old,x1new,x2new,y1old,y2old,y1new,y2new);
		break;

		default:
		draw_ctrl(type,ptr,0,0,639,200*rez-1);

	}	/* end switch (type) */
	vs_clip(gl_hand,0,0L);

}	/* end draw_1chg() */

slider_chg(x1old,x2old,x1new,x2new,y1old,y2old,y1new,y2new)
int x1old,x2old,x1new,x2new,y1old,y2old,y1new,y2new;
{
	int x1,x2,y1,y2;

	x1= x2new>x1old && x2new<x2old ? x2new : x1old ;
	x2= x1new>x1old && x1new<x2old ? x1new : x2old ;
	y1= y2new>y1old && y2new<y2old ? y2new : y1old ;
	y2= y1new>y1old && y1new<y2old ? y1new : y2old ;
	fill_rect(x1+1,y1+1,x2-x1,y2-y1,2);
	fill_box(x1new+1,y1new+1,x2new-x1new,y2new-y1new,0);
}	/* end slider_chg() */

/* handle mouse clicked on joystick .........................................*/

hndl_joy(x,y,x1,y1,w1,h1,val)
int x,y;				/* initial indicator position */
int x1,y1,w1,h1;	/* joystick position and size */
VAL_INFO *val[2];
{
	register int i;
	int new_x,new_y;
	int xmin,xmax,ymin,ymax;
	int mstate,oldmstate;
	int xc,yc;
	int h,k;

	/* center */
	xc= x1 + w1/2 ;
	yc= y1 + h1/2 ;

	/* width and height factors */
	h= w1/2;
	k= h1/2;

	ymin= yc - k + JOYSTICKW/(3-rez) ;
	ymax= yc + k - JOYSTICKW/(3-rez) ;

	HIDEMOUSE;

	/* init real-time midi */
	for (i=0; i<2; i++) hndl_midi(i,val[i],2);

	/* loop until mstate changes */
	oldmstate= getmouse(&dummy,&dummy);
	while (mstate=getmouse(&new_x,&new_y))
	{
		if (oldmstate!=mstate) break;
		if (new_y<ymin) new_y= ymin;
		if (new_y>ymax) new_y= ymax;
		joy_limitx(new_y,xc,yc,h,k,&xmin,&xmax);
		if (new_x<xmin) new_x= xmin;
		if (new_x>xmax) new_x= xmax;
		setmouse(new_x,new_y);
		if ((new_x!=x)||(new_y!=y))
		{
			/* move joystick */
			vdi_colors(0);
			drawjoyindic(x,y);
			vdi_colors(editcolor);
			drawjoyindic(x=new_x,y=new_y);

			/* update joystick values */
			val[0]->val= ival_to_val(x,x1+JOYSTICKW,x1+w1-JOYSTICKW-1,
												val[0]->low,val[0]->high);
			val[1]->val= ival_to_val(y,ymin,ymax,val[1]->high,val[1]->low);

			/* update midi and linked controls */
			for (i=0; i<2; i++)
			{
				hndl_midi(i,val[i],0);
				hndl_linked(i,val[i]);
			}
		}
	}

	/* erase joystick indicator (will be redrawn by hndl_ctrl) */
	vdi_colors(0);
	drawjoyindic(x,y);

	setmouse(x,y);
	SHOWMOUSE;

}	/* end hndl_joy() */

drawjoyindic(x,y)
int x,y;
{
	int xy[8];

	xy[0]= x;
	xy[1]= y - JOYSTICKW/(3-rez) + 1 ;
	xy[2]= x + JOYSTICKW - 1;
	xy[3]= y;
	xy[4]= x;
	xy[5]= y + JOYSTICKW/(3-rez) - 1 ;
	xy[6]= x-JOYSTICKW+1;
	xy[7]= y;

	vsf_style(gl_hand,1);
   vsf_interior(gl_hand,1);
   v_fillarea(gl_hand,4,xy);

}	/* end drawjoyindic() */

/* handle mouse clicked on graph ............................................*/

hndl_grph(npts,which,xxval,x,y,xaxis,yaxis,x1,y1,x2,y2)
int npts,which;
XXVAL_INFO xxval[];
int x[],y[];			/* where the pts are */
int xaxis,yaxis;
int x1,y1,x2,y2;		/* graph borders */
{
	register int i,j;
	PT_INFO *pt_info;
	char active[MAXNPOINTS],xmode[MAXNPOINTS],ymode[MAXNPOINTS];
	int xfac[MAXNPOINTS];
	int xmin,xmax,ymin,ymax;
	int old_x,old_y,new_x,new_y,del_x,del_y;
	int mstate,oldmstate;
	int xprevfix,xnextfix;
	int grlow,grhigh;

	/* info about pts */
	for (i=0; i<npts; i++)
	{
		active[i]= xxval[i].pt_info.active;
		xmode[i]= xxval[i].pt_info.xmode;
		ymode[i]= xxval[i].pt_info.ymode;
	}
	scalxfactors(xfac,npts,xxval);

	/* limits for x movement */
	if (xmode[which]==PTFIXED)
		xmin= xmax= x[which];
	else
	{
		xmin= which ? x[which-1] : x1;
		/* xmax depends on 2 things -- */
		/* -- this pt's xfactor */
		xmax= xmin + pt_x_max(which,npts,xxval,x,x1,x2);
		/* -- and the last movable pt before fixed pt or end */
		for (j= which+1; j<npts; j++) if (xmode[j]==PTFIXED) break;
		xnextfix= j<npts ? x[j] : x2 ;
		xmax -= max(x[j-1]+xmax-x[which]-xnextfix,0);
	}

	/* limits for y movement */
	for (i=which; (ymode[i]==PTFOLLOW)&&(i>=0); i--) ;
	if ((i<0)||(ymode[i]==PTFULL))
	{
		ymin= y1;
		ymax= y2;
	}
	else
		ymin= ymax= y[i];

	HIDEMOUSE;

	/* init real-time midi */
	for (i=j=0; i<npts; i++)
	{
		hndl_midi(j++,&(xxval[i].xval),2);
		hndl_midi(j++,&(xxval[i].yval),2);
	}

	old_x= x[which];
	old_y= y[which];

	/* loop until mstate changes */
	oldmstate= getmouse(&dummy,&dummy);
	while (mstate=getmouse(&new_x,&new_y))
	{
		if (oldmstate!=mstate) break;
		if (new_y<ymin) new_y= ymin;
		if (new_y>ymax) new_y= ymax;
		if (new_x<xmin) new_x= xmin;
		if (new_x>xmax) new_x= xmax;
		setmouse(new_x,new_y);
		del_x= new_x-old_x;
		del_y= new_y-old_y;
		if ( !del_x && !del_y ) continue;

		/* erase old graph */
		vdi_colors(0);
		set_clip(x1,y1,x2-x1+1,y2-y1+1);
		draw_graph(npts,active,x,y);

		/* move this pt */
		x[which]= old_x= new_x;
		y[which]= old_y= new_y;

		/* change x of all following pts up to next fixed pt */
		for (i=which+1; i<npts; i++)
			if (xmode[i]==PTFOLLOW)
				x[i]+=del_x;
			else
				break;

		/* change y of all following linked pts */
		for (i=which+1; i<npts; i++)
			if (ymode[i]==PTFOLLOW)
				y[i]=y[which];
			else
				break;

		/* change y of all preceding linked pts */
		if (ymode[which]==PTFOLLOW)
		{
			for (i=which-1; i>=0; i--)
			{
				y[i]= y[which];
				if (ymode[i]!=PTFIXED) break;
			}
		}

		/* draw new graph */
		vdi_colors(editcolor);
		set_clip(x1,y1,x2-x1+1,y2-y1+1);
		draw_graph(npts,active,x,y);

		/* repair stuff --
		/* -- outline */
		draw_box(0xFFFF,0xFFFF,x1,y1,x2,y2);
		/* -- x-axis */
		if (xaxis>=0)
		{
			i= ival_to_val(xaxis,0,100,y2,y1);
			draw_line(0xAAAA,x1,i,x2-x1+1,1);
		}
		/* -- y-axis */
		if (yaxis>=0)
		{
			i= ival_to_val(yaxis,0,100,x1,x2);
			draw_line(0xAAAA,i,y1,1,y2-y1+1);
		}
		/* -- vertical and horizontal lines through pts */
		for (i=0; i<npts; i++)
		{
			if ( (xmode[i]==PTFIXED) && xxval[i].pt_info.xline )
				draw_line(0xC0C0,x[i],y1,1,y2-y1+1);
			if ( (ymode[i]==PTFIXED) && xxval[i].pt_info.yline )
				draw_line(0xC0C0,x1,y[i],x2-x1+1,1);
		}

		/* update values */
		for (i=0; i<npts; i++)
		{
			grlow= i ? x[i-1] : x1 ;
			grhigh= grlow + pt_x_max(i,npts,xxval,x,x1,x2);
			xxval[i].xval.val= ival_to_val(x[i],grlow,grhigh,
										 xxval[i].xval.low,xxval[i].xval.high);
			grlow= y2;
			grhigh= y1;
			xxval[i].yval.val= ival_to_val(y[i],grlow,grhigh,
										 xxval[i].yval.low,xxval[i].yval.high);
		}

		/* update midi and linked controls */
		for (i=j=0; i<npts; i++)
		{
			hndl_midi(j,&(xxval[i].xval),0);
			hndl_linked(j++,&(xxval[i].xval));
			hndl_midi(j,&(xxval[i].yval),0);
			hndl_linked(j++,&(xxval[i].yval));
		}

	}	/* end while mstate hasn't changed */

	/* erase graph (will be redrawn by hndl_ctrl) */
	vdi_colors(0);
	set_clip(x1,y1,x2-x1+1,y2-y1+1);
	draw_graph(npts,active,x,y);

	vs_clip(gl_hand,0,0L);
	SHOWMOUSE;

}	/* end hndl_grph() */

/* handle mouse clicked on momentary button .................................*/

hndl_moment(ctrlptr,type,val)
long ctrlptr;
int type;	/* CTYP_IBUT or CTYP_CBUT */
VAL_INFO *val;
{
	/* select and redraw button */
	val->val= type==CTYP_CBUT ? 1 : val->high ;
	draw_ctrl(type,ctrlptr,0,0,639,200*rez-1);

	/* send midi string */
	hndl_midi(0,val,1);

	waitmouse();
	
	/* deselect and redraw button */
	val->val= type==CTYP_CBUT ? 0 : val->low;
	draw_ctrl(type,ctrlptr,0,0,639,200*rez-1);

	/* midi string will be re-sent at end of hndl_ctrl */

}	/* end hndl_moment() */

/* handle mouse clicked on number or text ...................................*/

hndl_numb(type,mstate,ctrlptr,val)
int type;	/* CTYP_NUMB or CTYP_TEXT */
int mstate; /* 1=left, 2=right */
long ctrlptr;
register VAL_INFO *val;
{
	register int temp;

	/* init real-time midi */
	hndl_midi(0,val,2);

	/* loop until button up */
	do
	{
		mstate= but2val(mstate);
		temp= val->val + mstate ;
 		if (temp<val->low ) temp= val->high;
		if (temp>val->high) temp= val->low;
		if (temp!=val->val)
		{
			val->val= temp;
			draw_ctrl(type,ctrlptr,0,0,639,200*rez-1);
			hndl_midi(0,val,0);
			hndl_linked(0,val);
		}
	}
	while ( mstate= getwmouse(&dummy,&dummy) );

}	/* end hndl_numb() */

/* handle mouse clicked on slider ...........................................*/

hndl_slid(xslid,yslid,wslid,hslid,xscrl,yscrl,wscrl,hscrl,val)
int xslid,yslid,wslid,hslid;
int xscrl,yscrl,wscrl,hscrl;
VAL_INFO *val;
{
	int grlow,grhigh,grval;
	int new_x,new_y;
	int xmin,xmax,ymin,ymax;
	int mstate,oldmstate;
	int x1old,y1old,x1new,y1new;
	int x2old,y2old,x2new,y2new;

	if (hscrl>wscrl)	/* vertical */
	{
		xmin= xmax= xslid;
		ymin= yscrl;
		ymax= yscrl+hscrl-1-hslid;
	}
	else	/* horizontal */
	{
		ymin= ymax= yslid;
		xmin= xscrl;
		xmax= xscrl+wscrl-1-wslid;
	}

	HIDEMOUSE;
	setmouse(xslid,yslid);

	/* init real-time midi */
	hndl_midi(0,val,2);

	/* loop until mstate changes */
	oldmstate= getmouse(&dummy,&dummy);
	while (mstate=getmouse(&new_x,&new_y))
	{
		if (oldmstate!=mstate) break;
		if (new_x<xmin) new_x= xmin;
		if (new_x>xmax) new_x= xmax;
		if (new_y<ymin) new_y= ymin;
		if (new_y>ymax) new_y= ymax;
		setmouse(new_x,new_y);
		if ((new_x!=xslid)||(new_y!=yslid))
		{
			/* draw slider in new position */
			x1old= xslid;
			y1old= yslid;
			x2old= xslid+wslid-1;
			y2old= yslid+hslid-1;
			x1new= new_x;
			x2new= new_x+wslid-1;
			y1new= new_y;
			y2new= new_y+hslid-1;
			vdi_colors(editcolor);
			slider_chg(x1old,x2old,x1new,x2new,y1old,y2old,y1new,y2new);
			xslid= new_x;
			yslid= new_y;

			/* update slider value */
			val->val= val_of_slid(xslid,yslid,wslid,hslid,
							  xscrl,yscrl,wscrl,hscrl,val->low,val->high);

			/* update midi and linked controls */
			hndl_midi(0,val,0);
			hndl_linked(0,val);
		}
	}	/* end while mstate hasn't changed */

	/* erase slider (will be redrawn by hndl_ctrl) */
	vdi_colors(editcolor);
	fill_rect(xslid+1,yslid+1,wslid-1,hslid-1,2);
	setmouse(xslid+wslid/2,yslid+hslid/2);

	SHOWMOUSE;

}	/* end hndl_slid() */

val_of_slid(xslid,yslid,wslid,hslid,xscrl,yscrl,wscrl,hscrl,vallow,valhigh)
int xslid,yslid,wslid,hslid,xscrl,yscrl,wscrl,hscrl;
int vallow,valhigh;
{
	int grval,grlow,grhigh;

	if (hscrl>wscrl)	/* vertical */
	{
		grlow= yscrl+hscrl-1-hslid;
		grhigh= yscrl;
		grval= yslid;
	}
	else	/* horizontal */
	{
		grlow= xscrl;
		grhigh= xscrl+wscrl-1-wslid;
		grval= xslid;
	}

	return ival_to_val(grval,grlow,grhigh,vallow,valhigh);

}	/* end val_of_slid() */

/* handle mouse clicked on knob .............................................*/

/* returns change in value */
hndl_knob(ctrlptr,x,y,w,h,val)
long ctrlptr;	/* --> past ctrl header */
int x[],y[],w[],h[];
VAL_INFO *val;
{
	int mstate,kstate;
	int del;
	int newval,oldval,oldoldval,low,high;
	int firsttime=1;

	HIDEMOUSE;

	/* init real-time midi */
	hndl_midi(0,val,2);
	newval= oldval= oldoldval= val->val;
	high= val->high;
	low= val->low;

	/* loop until mouse buttons up */
	while (1)
	{
		mstate= getmouse(&dummy,&dummy) ;
		kstate= Kbshift(-1)&0x0F ;
		if (!mstate) break;
		del= but2val(mstate);
		if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT))
			if ( high-low > 20 )
				del *= (high-low)/10 ;

		newval= oldval+del;
		if (newval<low) newval=low;
		if (newval>high) newval=high;

		if (newval!=oldval)
		{
			/* erase old indicator */
			vswr_mode(gl_hand,3);
			draw_line(0xFFFF,x[1],y[1],w[1],h[1]);

			/* update control value */
			val->val= oldval= newval;
			/* draw new indicator */
			calc_ctrl(CTYP_KNOB,ctrlptr,x,y,w,h);
			vswr_mode(gl_hand,1);
			draw_line(0xFFFF,x[1],y[1],w[1],h[1]);

			/* update midi and linked controls */
			hndl_midi(0,val,0);
			hndl_linked(0,val);

			evnt_timer( firsttime ? 160 : 0 , 0 );
			firsttime=0;
		}
	}	/* end while mstate hasn't changed */

	/* erase indicator (will be redrawn by hndl_ctrl) */
	vswr_mode(gl_hand,3);
	draw_line(0xFFFF,x[1],y[1],w[1],h[1]);
	vswr_mode(gl_hand,1);

	SHOWMOUSE;
	return newval-oldoldval;

}	/* end hndl_knob() */

/* handle midi control ......................................................*/

hndl_midi(which,val,flag)
int which;
VAL_INFO *val;
int flag;		/* 0= send with delta handling */
					/* 1= send without delta handling */
					/* 2= init delta handling but don't send */
{
	int ctrllow,ctrlhigh,midi_val;
	register CTRL_MIDI *midi;
	static int oldmidival[MAXNVALS];
	char midistr[MAXSTRLENG+1];
	register int n,i,j;
	register char *ptr;
	CTRLHEADER *ctrl;

	/* find the midi control that is to be handled */
	i= midi_list[which];
	if (i<0) return;
	midi= (CTRL_MIDI*)( pageptr + addrtable[i] + sizeof(*ctrl) );

	/* optionally invert control's output */
	if (val->invert)
	{
		ctrllow= val->high;
		ctrlhigh= val->low;
	}
	else
	{
		ctrllow= val->low;
		ctrlhigh= val->high;
	}

	i= ival_to_val(val->val,ctrllow,ctrlhigh,midi->low,midi->high);
	n= midi->delta;

	if (!flag)		/* send only if delta exceeded */
	{
		if (!n) return;
		if ( abs(i-oldmidival[which]) < n ) return;
	}
	midi_val= oldmidival[which]= i;
	if (flag==2) return;	/* init delta tracking, but don't send */

	ptr= strpool + midi->str;
	n=0;
	while (i=*ptr++)
		if (j=*ptr++)
			midistr[n++]=
				(hndlmidinibl(i,midi_val)<<4) | hndlmidinibl(j,midi_val) ;
		else
			break;
	if (n) send_midi(midistr,n);
}	/* end hndl_midi() */

hndlmidinibl(ch,v)
register int ch;
register unsigned int v;
{
	register int i;
	unsigned int wNibble,xNibble,yNibble,zNibble;
	unsigned int sNibble,tNibble,uNibble,vNibble;

	zNibble= v & 0x0F;
	yNibble= (v>>4) & 0x0F;
	xNibble= (v>>8) & 0x0F;
	wNibble= (v>>12) & 0x0F;

	i= v%128;
	vNibble= i & 0x0F;
	uNibble= (i>>4) & 0x0F;
	i= (v/128) & 0x7F;
	tNibble= i & 0x0F;
	sNibble= (i>>4) & 0x0F;

	switch (ch)
	{
		case 'n':
		i= edit_side<0 ? edit_chan : wind_device[edit_side].midichan;
		if ((i<0)||(i>15)) i= 0;
		break;
		
		case 's': i=sNibble; break;
		case 't': i=tNibble; break;
		case 'u': i=uNibble; break;
		case 'v': i=vNibble; break;

		case 'w': i=wNibble; break;
		case 'x': i=xNibble; break;
		case 'y': i=yNibble; break;
		case 'z': i=zNibble; break;
		
		default:
		i= hexvalue(ch);
	}
	return i;
}	/* end hndlmidinibl() */

/* handle linked controls ...................................................*/

hndl_linked(val_i,val)
int val_i;
VAL_INFO *val;
{
	register EBDTLINK *ptabptr;
	register int i,j,k;
	int low1,high1,low2,high2,type,newval;
	int x[MAXNCALC],y[MAXNCALC],w[MAXNCALC],h[MAXNCALC];
	VAL_INFO *val2;
	long ctrlptr;
	VAL_INFO *valarray[MAXNVALS];
	CTRLHEADER *ctrlheader;

	/* optionally invert control's output */
	if (val->invert)
	{
		low1= val->high;
		high1= val->low;
	}
	else
	{
		low1= val->low;
		high1= val->high;
	}

	i= ebdt_list[val_i];
	if (i<0) return;
	i= ( (CTRL_EBDT*)( pageptr + addrtable[i] + sizeof(*ctrlheader) ) )->index;
	ptabptr= (EBDTLINK*)(heap[ptabmem].start);
	i= ptabptr[i].next;
	while ( (j=ptabptr[i].ctrl_i) >= 0 )
	{
		if (j!=editctrl_i)
		{
			k= ptabptr[i].val_i;
			ctrlptr= pageptr + addrtable[j] ;
			type= ((CTRLHEADER*)(ctrlptr))->type;
			ctrlptr += sizeof(*ctrlheader) ;
			find_vals(type,ctrlptr,valarray);
			val2= valarray[k];
			/* optionally invert control's input */
			if (val2->invert)
			{
				low2= val2->high;
				high2= val2->low;
			}
			else
			{
				low2= val2->low;
				high2= val2->high;
			}
			/* get linked control's new value, redraw only if value has changed */
			newval= ival_to_val(val->val,low1,high1,low2,high2);
			if (newval != val2->val)
			{
				calc_ctrl(type,ctrlptr,x,y,w,h);
				val2->val= newval;
				vdi_colors( ((MAC_RECT*)(ctrlptr))->color );
				draw_1chg(ctrlptr,type,x,y,w,h);
			}
		}
		i= ptabptr[i].next;
	}
}	/* end hndl_linked() */

/* move this to misc.c !!! */
but2val(mstate)
int mstate;
{
	mstate= mstate==1 ? -1 : 1 ;
	if (edmouseinvrt) mstate= -mstate;
	return mstate;
}

#endif

/* EOF */
