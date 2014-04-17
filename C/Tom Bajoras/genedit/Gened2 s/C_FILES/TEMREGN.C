/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module TEMREGN : template region editing

	sel_region, edit_region, move_region
	sel_ctrls, desel_ctrls, resel_ctrls
	toggle1ctrl
	setctrlbit, clrctrlbit, isctrlbit
	clear_region

	_temreg functions

******************************************************************************/

overlay "temregn"

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

extern int ndatabyte[];	/* in monitor.c -- move to globals !!!	 */

/* in tem.c */
extern int temdelsafe;
extern int tem_x,tem_y,tem_w,tem_h;
extern int curr_mem;
extern int curr_page;
extern int curr_nctrl,curr_nvctrl;
extern long curr_leng;
extern int temsnap_x,temsnap_y;

/* local globals ............................................................*/

CTRLHEADER *first_ctrl;		/* pointer to first control in region */
int first_i;					/* # of first control in region */

/* these are valid only during edit_region() */
int nselected;
int new_region;
MAC_RECT reg_rect;

#define NREGFUNCS 20
char *regionstr[NREGFUNCS]= {		/* #define these !!! */
	"Delete",
	"Move:  by mouse",
	"Move:  numeric",
   "Copy:  by mouse",
	"Copy:  numeric",
	"Duplicate:  by mouse",
	"Duplicate:  numeric",
   "Pull to Front",
	"Push to Back",
	"Copy to Page N",
	"Duplicate to Page N",
   "Unlink EBDT",
   "Unlink MIDI",
	"Shift EBDT Links",
   "Change Color",
	"Change Font",
   "Snap",
   "Convert Control Type",
	"Borderize",
	"Learn"
};
char *newtypestr[4]= {		/* #define these !!! */
	"Number (small)",
	"Number (normal)",
	"Slider",
	"Knob"
};
extern dele_temreg();
extern movM_temreg(),movN_temreg();
extern cpyM_temreg(),cpyN_temreg(),cpyP_temreg();
extern dupM_temreg(),dupN_temreg(),dupP_temreg();
extern frnt_temreg(),back_temreg();
extern no_e_temreg(),no_m_temreg(),ebdt_temreg(),colr_temreg(),font_temreg();
extern snap_temreg(),type_temreg(),bord_temreg();
extern lern_temreg();
long regionfunc[NREGFUNCS]= {
	(long)(&dele_temreg),
	(long)(&movM_temreg),
	(long)(&movN_temreg),
   (long)(&cpyM_temreg),
   (long)(&cpyN_temreg),
	(long)(&dupM_temreg),
	(long)(&dupN_temreg),
   (long)(&frnt_temreg),
	(long)(&back_temreg),
	(long)(&cpyP_temreg),
	(long)(&dupP_temreg),
   (long)(&no_e_temreg),
   (long)(&no_m_temreg),
	(long)(&ebdt_temreg),
   (long)(&colr_temreg),
	(long)(&font_temreg),
   (long)(&snap_temreg),
   (long)(&type_temreg),
	(long)(&bord_temreg),
	(long)(&lern_temreg)
};

#if TEMFLAG

/* rubberbox a region .......................................................*/

sel_region(mx,my)
int mx,my;
{
	int x1,y1,x2,y2;
	int x1b,y1b,x2b,y2b;

	/* get rid of any existing region */
	clear_region(1);

	tem_prompt(SLCTRGNMSG);
	HIDEMOUSE;
	x2= mx;	y2= my;
	rubberbox(mx,my,&x2,&y2,tem_x,tem_y,tem_x+tem_w-1,tem_y+tem_h-1);
	SHOWMOUSE;
	tem_prompt(0L);
	if (Kbshift(-1)&K_ALT) return;	/* aborted */

	x1= min(mx,x2);		/* rectangle must be positive */
	x2= max(mx,x2);
	y1= min(my,y2);
	y2= max(my,y2);

	/* select any controls in this rectangle -- if any, redraw them */
	if (sel_ctrls(x1,x2,y1,y2)) draw_tem(x1,y1,x2,y2);

}	/* end sel_region() */

/* (de)select one control ...................................................*/

toggle1ctrl(ctrl)
CTRLHEADER *ctrl;
{
	int x1,y1,x2,y2;

	/* toggle its selection */
	if (isctrlbit(ctrl,0))
		clrctrlbit(ctrl,0);
	else
		setctrlbit(ctrl,0);

	/* redraw it */
	rect2scr((long)ctrl+sizeof(*ctrl),&x1,&x2,&y1,&y2);
	draw_tem(x1,y1,x2,y2);

}	/* end toggle1ctrl() */

/* select controls in region ................................................*/
/* returns 1= at least one control in region, 0= no controls in region */

sel_ctrls(reg_x1,reg_x2,reg_y1,reg_y2)
int reg_x1,reg_x2,reg_y1,reg_y2;
{
	register long ptr;
	register int i,temp;
	register CTRLHEADER *ctrl;
	int x1,x2,y1,y2;
	int result=0;

	ptr= heap[curr_mem].start;

	for (i=0; i<curr_nctrls; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( ctrl->type >= 0 )	/* if visible */
		{
			rect2scr(ptr+sizeof(*ctrl),&x1,&x2,&y1,&y2);
			/* convert to positive rectangle */
			if (x1>x2) { temp=x1; x1=x2; x2=temp; }
			if (y1>y2) { temp=y1; y1=y2; y2=temp; }
			if ((x1>=reg_x1)&&(x2<=reg_x2)&&
				 (y1>=reg_y1)&&(y2<=reg_y2))
			{
				result=1;
				setctrlbit(ptr,0);
			}
		}	/* end if visible */
		ptr += ctrl->length;
	}	/* end loop through all controls */
	return result;
}	/* end sel_ctrls() */

/* reselect controls (copy option bit 1 to bit 0) ...........................*/

resel_ctrls()
{
	register long ptr;
	register int i;
	register CTRLHEADER *ctrl;

	ptr= heap[curr_mem].start;
	for (i=0; i<curr_nctrls; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type >= 0) && isctrlbit(ptr,1) )
		{
			clrctrlbit(ptr,1);
			setctrlbit(ptr,0);
		}
		ptr += ctrl->length;
	}
}	/* end resel_ctrls() */

/* deselect controls in region ..............................................*/
/* returns 1= at least one control in region, 0= no controls in region */

desel_ctrls(mem,nbytes)
int mem;			/* heap block containing page */
register long nbytes;	/* # bytes in page (might be < heap[mem].nbytes) */
{
	register long ptr;
	register int i;
	register CTRLHEADER *ctrl;
	int result=0;

	ptr= heap[mem].start;
	while (nbytes>2L)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if (ctrl->type >= 0)
		{
			if (isctrlbit(ptr,0))
			{
				result=1;
				clrctrlbit(ptr,0);
			}
		}
		ptr += ctrl->length;
		nbytes -= ctrl->length;
	}	/* end loop through all controls */
	return result;
}	/* end desel_ctrls() */

/* set option bit in a control ..............................................*/

setctrlbit(ptr,whichbit)
CTRLHEADER *ptr;	/* --> ctrlheader (visible) */
int whichbit;		/* 0-7 */
{
	MAC_RECT *rect;

	if (isctrlbit(ptr,whichbit)) return; /* already set */

	rect= (MAC_RECT*)( (long)ptr + sizeof(*ptr) );
	rect->options |= (1<<whichbit);
}	/* end setctrlbit() */

/* clear option bit in a control ............................................*/

clrctrlbit(ptr,whichbit)
CTRLHEADER *ptr;	/* --> ctrlheader (visible) */
int whichbit;		/* 0-7 */
{
	MAC_RECT *rect;

	if (!isctrlbit(ptr,whichbit)) return; /* already clear */
	rect= (MAC_RECT*)( (long)ptr + sizeof(*ptr) );
	rect->options &= ~(1<<whichbit);
}	/* end clrctrlbit() */

/* is an option bit in a control set? .......................................*/
/* returns non-0= yes, 0= no */

isctrlbit(ptr,whichbit)
CTRLHEADER *ptr;	/* --> ctrlheader (visible) */
int whichbit;		/* 0-7 */
{
	MAC_RECT *rect;
	rect= (MAC_RECT*)( (long)ptr + sizeof(*ptr) );
	return rect->options & (1<<whichbit);
}	/* end isctrlbit() */

/* deselect (and redraw) region .............................................*/

clear_region(draw)
int draw;	/* 1= draw, 0= don't draw */
{
	if (draw) find_temreg(&reg_rect);

	if (desel_ctrls(curr_mem,curr_leng))
		if (draw)
			draw_tem(reg_rect.x1,reg_rect.y1,reg_rect.x2,reg_rect.y2);

}	/* end clear_region() */

/* smallest rectangle containing all selected controls ......................*/

find_temreg(rect)
register MAC_RECT *rect;
{
	register long ptr,nbytes;
	register int i;
	register CTRLHEADER *ctrl;
	int x1,y1,x2,y2;

	/* start with absurd values */
	rect->x1= 0x7FFF;
	rect->x2= -1;
	rect->y1= 0x7FFF;
	rect->y2= -1;

	ptr= heap[curr_mem].start;
	nbytes= curr_leng;
	while (nbytes>2L)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if (ctrl->type >= 0)
		{
			if (isctrlbit(ptr,0))
			{
				rect2scr(ptr+sizeof(*ctrl),&x1,&x2,&y1,&y2);
				rect->x1= min(rect->x1,x1);
				rect->y1= min(rect->y1,y1);
				rect->x2= max(rect->x2,x2);
				rect->y2= max(rect->y2,y2);
			}
		}
		ptr += ctrl->length;
		nbytes -= ctrl->length;
	}	/* end loop through all controls */

}	/* end find_temreg() */

/* region edit ..............................................................*/

edit_region()
{
	static int last_func;
	int this_func,result;

	/* how many controls selected? */
	nselected= nsel_temreg(&first_ctrl,&first_i);

	/* no selected controls: don't do anything */
	if (!nselected) return;

	/* do what to selected controls? */
	this_func= pop_up(TREGCHOOSE,last_func,NREGFUNCS,0L,0,regionstr);
	if (this_func<0) return;	/* cancelled */
	last_func= this_func;

	/* default is no new region */
	new_region=0;
	find_temreg(&reg_rect);

	asm {
		move.w	this_func(a6),d0
		lsl.w		#2,d0						; index into jump table
		lea		regionfunc(a4),a0
		move.l	0(a0,d0),a0
		jsr		(a0)
		move.w	d0,result(a6)
	}

	if (result)
	{
		change_flag[temCHANGE]= 1;
		if (new_region)
		{	/* un-draw old region, find new region */
			draw_tem(reg_rect.x1,reg_rect.y1,reg_rect.x2,reg_rect.y2);
			find_temreg(&reg_rect);
		}
		if (result==1) draw_tem(reg_rect.x1,reg_rect.y1,reg_rect.x2,reg_rect.y2);
	}
}	/* end edit_region() */

/* move a region, with redraw ...............................................*/

move_region(h_shift,v_shift)
int h_shift,v_shift;
{
	/* how many controls selected? */
	nselected= nsel_temreg(&first_ctrl,&first_i);

	/* no selected controls: don't do anything */
	if (!nselected) return;

	find_temreg(&reg_rect);
	if ( shft_temreg(h_shift,v_shift,0,0) )
	{
		change_flag[temCHANGE]= 1;
		draw_tem(reg_rect.x1,reg_rect.y1,reg_rect.x2,reg_rect.y2);
		find_temreg(&reg_rect);
		draw_tem(reg_rect.x1,reg_rect.y1,reg_rect.x2,reg_rect.y2);
	}
}	/* end move_region() */

/* delete region ............................................................*/
/* returns 0= cancelled, 1= did it */

dele_temreg()
{
	register int i;
	register long ptr;
	register CTRLHEADER *ctrl;

	/* delete these controls? (wait for mouse button or key press) */
	if (temdelsafe)
	{
		tem_prompt(DELREGNMSG);
		while ( !(i=getmouse(&dummy,&dummy)) && (*keyb_head==*keyb_tail) ) ;
		if (i)
			i= i==1 ? SCAN_CR : SCAN_ESC ;
		else
			i= Crawcin() >> 16 ;
		tem_prompt(0L);
		if (i!=SCAN_CR) return 0;
	}

	ptr= heap[curr_mem].start;

	graf_mouse(BEE_MOUSE);
	tem_prompt(DELREG_MSG);
	for (i=0; (i<curr_nctrls)&&nselected; )
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type >= 0) && (isctrlbit(ptr,0)) )
		{
			_del_ctrl(ptr,i);		/* messes up everything, restart scan */
			nselected--;
			i=0;
			ptr= heap[curr_mem].start;
		}
		else
		{
			i++;
			ptr += ctrl->length;
		}
	}	/* end loop through all controls */
	tem_prompt(0L);
	graf_mouse(ARROWMOUSE);
	return 1;
}	/* end dele_temreg() */

/* move (drag with mouse) region ............................................*/
/* returns 0= cancelled, 1= did it */

movM_temreg()
{
	return drag_temreg(0,0);
}

/* copy move (drag with mouse) region .......................................*/
/* returns 0= cancelled, 1= did it */

cpyM_temreg()
{
	return drag_temreg(1,0);
}
dupM_temreg()
{
	return drag_temreg(1,1);
}

/* move (numerically) region ................................................*/
/* returns 0= cancelled, 1= did it */

movN_temreg()
{
	static int h_shift=0,v_shift=0;
	int w,h;

	w= temheader.page_w;
	h= temheader.page_h;
	h_shift= getNumber(HMOVEMSG,-w,w,h_shift);
	v_shift= getNumber(VMOVEMSG,-h,h,v_shift);
	if ( !h_shift && !v_shift ) return 0;
	return shft_temreg(h_shift,v_shift,0,0);
}	/* end movN_temreg() */

/* copy (numerically) region ................................................*/
/* returns 0= cancelled, 1= did it */

cpyN_temreg()
{
	static int h_shift=0,v_shift=0;
	int w,h;

	w= temheader.page_w;
	h= temheader.page_h;
	h_shift= getNumber(HCOPYMSG,-w,w,h_shift);
	v_shift= getNumber(VCOPYMSG,-h,h,v_shift);
	if ( !h_shift && !v_shift ) return 0;
	return shft_temreg(h_shift,v_shift,1,0);
}	/* end cpyN_temreg() */
dupN_temreg()
{
	static int h_shift=0,v_shift=0;
	int w,h;

	w= temheader.page_w;
	h= temheader.page_h;
	h_shift= getNumber(HDUPEMSG,-w,w,h_shift);
	v_shift= getNumber(VDUPEMSG,-h,h,v_shift);
	if ( !h_shift && !v_shift ) return 0;
	return shft_temreg(h_shift,v_shift,1,1);
}	/* end dupN_temreg() */

/* pull region to "front" ...................................................*/
/* returns 1 */

frnt_temreg()
{
	return frnt_back(1);
}

/* push region to "back" ....................................................*/
/* returns 1 */

back_temreg()
{
	return frnt_back(0);
}

frnt_back(front)
int front;	/* 1= front, 0= back */
{
	register int i;
	register long ptr;
	register CTRLHEADER *ctrl;
	int this_sel;

	graf_mouse(BEE_MOUSE);

	ptr= heap[curr_mem].start;
	this_sel=0;
	for (i=0; (i<curr_nctrls)&&nselected; )
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type >= 0) && isctrlbit(ptr,0) )
		{
			this_sel++;
			if (front || (this_sel==nselected) )
			{
				clrctrlbit(ptr,0);
				setctrlbit(ptr,1);		/* mark for later re-selection */
				front_ctrl(front,ptr,i);
				nselected--;
				i= this_sel= 0;
				ptr= heap[curr_mem].start;
				continue;
			}
		}
		i++;
		ptr += ctrl->length;
	}	/* end loop through all controls */

	resel_ctrls(); /* re-select region */

	graf_mouse(ARROWMOUSE);
	return 1;
}	/* end frnt_back() */

/* change color(s) ..........................................................*/
/* returns 0= cancelled, 1= did it */

colr_temreg()
{
	int result=0;
	int newcolors[4];
	register int i,j;
	int key,x;
	static char *prompt2[4]= {
		" 0 ", " 1 ", " 2 ", " 3 "
	};
	static int promptcolor[4]= {
		WH_ON_BL, BL_ON_WH, RD_ON_WH, GR_ON_WH
	};
	register long ptr;
	CTRLHEADER *ctrl;
	MAC_RECT *rect;

	/* build list of new colors */
	x= strlen(COLRCHNGMSG);
	for (i=0; i<4; i++) x += strlen(prompt2[i]);
	x= 40 - (x/2) ;
	for (i=0; i<4; i++)
	{
		tem_prompt("");
		gr_color= promptcolor[i];
		gr_text(COLRCHNGMSG,x,1);
		for (j=0; j<4; j++)
		{
			gr_color=promptcolor[j];
			gr_text(prompt2[j],x+strlen(COLRCHNGMSG)+3*j,1);
		}
		gr_color= BL_ON_WH;
		key= Crawcin() & 0xFF ;
		tem_prompt(0L);
		key -= '0' ;
		if ((key>=0)&&(key<=3)&&(key!=i))
		{
			result=1;
			newcolors[i]=key;
		}
		else
			newcolors[i]=i;
	}
	if (!result) return 0;

	graf_mouse(BEE_MOUSE);
	ptr= heap[curr_mem].start;
	result=0;
	for (i=0; (i<curr_nctrls)&&nselected; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type>=0) && (isctrlbit(ptr,0)) )
		{
			rect= (MAC_RECT*)(ptr+sizeof(*ctrl)) ;
			rect->color= newcolors[ rect->color ] ;
			result= 1;
			nselected--;
		}
		ptr += ctrl->length;
	}	/* end loop through all controls */
	graf_mouse(ARROWMOUSE);
	return result;

}	/* end colr_temreg() */

/* unlink from EBDT or MIDI .................................................*/
/* returns 0= cancelled, -1= did it (no redraw) */

no_e_temreg()
{
	return unlk_temreg(0);
}
no_m_temreg()
{
	return unlk_temreg(1);
}
unlk_temreg(type)
int type;	/* 0= EBDT, 1= MIDI */
{
	register int i;
	register long ptr;
	register CTRLHEADER *ctrl;
	int result=0;

	ptr= heap[curr_mem].start;
	graf_mouse(BEE_MOUSE);
	for (i=0; (i<curr_nctrls)&&nselected; )
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type >= 0) && (isctrlbit(ptr,0)) )
		{
			clrctrlbit(ptr,0);
			setctrlbit(ptr,1);		/* mark for later re-selection */
			nselected--;
		/* unlinking actually means deleting controls, messes up control list
			so restart scan */
			if (unlk_ctrl(ptr,i,type))
			{
				result= -1;
				i=0;
				ptr= heap[curr_mem].start;
				continue;
			}
		}
		i++;
		ptr += ctrl->length;
	}	/* end loop through all controls */

	resel_ctrls(); /* re-select region */

	graf_mouse(ARROWMOUSE);
	return result;
}	/* end unlk_temreg() */

unlk_ctrl(ptr,ctrl_i,type)
long ptr;	/* --> ctrlheader */
int ctrl_i;
int type;	/* 0= EBDT, 1= MIDI */
{
	register int j;
	int result=0;
	int nlinks,ebdt_i,midi_i;
	CTRLHEADER *ctrl;
	int *linkpage[MAXNVALS],*linkctrl[MAXNVALS],*linkval[MAXNVALS];
	CTRL_EBDT *ebdtctrl;
	CTRL_MIDI *midictrl;

	ctrl= (CTRLHEADER*)(ptr);
	nlinks= find_links(ctrl->type,ptr+sizeof(*ctrl),linkpage,linkctrl,linkval);

	for (j=0; j<nlinks; j++)
	{
		findebdtmidi(ctrl_i,*(linkctrl[j]),
								&ebdtctrl,&midictrl,&ebdt_i,&midi_i);
		if ( midictrl && type )
		{
			if (ebdtctrl)
			{
				ebdtctrl->linkctrl= ctrl_i;
				*(linkctrl[j])= ebdt_i;
			}
			else
				*(linkctrl[j])= ctrl_i;
			__del_ctrl((long)(midictrl)-sizeof(*ctrl),midi_i);
			result=1;
			if (midi_i<ctrl_i)
			{
				ctrl_i--;
				ptr -= ( sizeof(*midictrl) + sizeof(*ctrl) ) ;
				ctrl= (CTRLHEADER*)(ptr);
				nlinks= find_links(ctrl->type,ptr+sizeof(*ctrl),
								linkpage,linkctrl,linkval);
			}
		}
		if ( ebdtctrl && !type )
		{
			if (midictrl)
			{
				midictrl->linkctrl= ctrl_i;
				*(linkctrl[j])= midi_i;
			}
			else
				*(linkctrl[j])= ctrl_i;
			__del_ctrl((long)(ebdtctrl)-sizeof(*ctrl),ebdt_i);
			result=1;
			if (ebdt_i<ctrl_i)
			{
				ctrl_i--;
				ptr -= ( sizeof(*ebdtctrl) + sizeof(*ctrl) ) ;
				ctrl= (CTRLHEADER*)(ptr);
				nlinks= find_links(ctrl->type,ptr+sizeof(*ctrl),
								linkpage,linkctrl,linkval);
			}
		}
	}
	return result;
}	/* end unlk_ctrl() */

/* shift EBDT links .........................................................*/
/* returns 0= cancelled, -1= did it (no redraw) */

ebdt_temreg()
{
	static int offset=0;
	int nlinks,n_ebdt;
	long old_index,new_index;
	register long ptr;
	register int i,j;
	int result=0;
	CTRLHEADER *ctrl;
	CTRL_EBDT *ebdtctrl;
	CTRL_MIDI *midictrl;
	int warningflag=0;
	int *linkpage[MAXNVALS],*linkctrl[MAXNVALS],*linkval[MAXNVALS];
	long dummlong;

	/* shift by how much? */
	offset= getNumber(SHFTEBDTMSG,-32768,32767,offset);
	if (offset==0) return result;

	n_ebdt= n_of_ebdt(&dummlong);
	graf_mouse(BEE_MOUSE);
	ptr= heap[curr_mem].start;
	for (i=0; (i<curr_nctrls)&&nselected; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type >= 0) && (isctrlbit(ptr,0)) )
		{
			nlinks= find_links(ctrl->type,ptr+sizeof(*ctrl),
										linkpage,linkctrl,linkval);
			for (j=0; j<nlinks; j++)
			{
				findebdtmidi(i,*(linkctrl[j]),
								&ebdtctrl,&midictrl,&dummy,&dummy);
				if (ebdtctrl)
				{
					old_index= ebdtctrl->index;
					new_index= old_index + offset ;
					if ( (new_index<0L) || (new_index>=n_ebdt) )
					{
						if (!warningflag) warningflag= form_alert(1,CHEKSHFTCLP);
						if (warningflag==1) new_index= old_index;
						new_index= max(0L,new_index);
						new_index= min(n_ebdt-1L,new_index);
					}
					ebdtctrl->index= new_index;
					if (new_index!=old_index) result= -1;
				}
			}
			nselected--;
		}	/* end if control visible and selected */
		ptr += ctrl->length;
	}
	return result;
}	/* end ebdt_temreg() */

/* copy region to another page (with or without links) ......................*/
/* returns 0= cancelled, -1= did it (no redraw) */

cpyP_temreg()
{
	return page_temreg(0);
}
dupP_temreg()
{
	return page_temreg(1);
}
page_temreg(links)
int links;
{
	register int i,j;
	register long from_ptr,to_ptr;
	register CTRLHEADER *ctrl;
	int dest_page,dest_mem,dest_nctrls,n_links,old_ctrl_i;
	long max_leng,dest_leng,length;
	int result=0;
	long linkleng,copy_links();
	CTRL_EBDT *ebdtctrl;
	CTRL_MIDI *midictrl;

	/* copy/duplicate to which page?  (no effect if to itself) */
	tem_prompt(COPY2PAGE);
	dest_page= (Crawcin()&0x7F) - '1' ;
	tem_prompt(0L);
	if ((dest_page<0)||(dest_page>=NTEMPAGES)||(dest_page==curr_page)) return 0;

	/* shrink source, expand destination */
	change_mem(curr_mem,curr_leng);
	dest_mem= temmem[ seg_to_mem(idTEMPAGE0+dest_page) ] ;
	scan_page(dest_mem,&dest_leng,&dest_nctrls,&dummy);
	fill_mem(dest_mem);
	max_leng= heap[dest_mem].nbytes;
	to_ptr= heap[dest_mem].start + dest_leng;

	/* worst case size of all linked controls */
	i= sizeof(*ctrl) + sizeof(*ebdtctrl);
	max_leng -= MAXNVALS*i;
	i= sizeof(*ctrl) + sizeof(*midictrl);
	max_leng -= MAXNVALS*i;

	graf_mouse(BEE_MOUSE);
	from_ptr= heap[curr_mem].start;
	for (i=0; (i<curr_nctrls)&&nselected; i++)
	{
		ctrl= (CTRLHEADER*)(from_ptr);
		length= ctrl->length;
		if ( (ctrl->type >= 0) && (isctrlbit(from_ptr,0)) )
		{
			if ( (dest_leng+length) > max_leng )
			{
				form_alert(1,BADMEM2);
				break;
			}
			else
			{
				copy_bytes(from_ptr,to_ptr,length);
				clrctrlbit(to_ptr,0);
				snap_ctrl(ctrl->type,to_ptr+sizeof(*ctrl),temsnap_x,temsnap_y);
				if (links)
				{
					old_ctrl_i= ctrladdr2i(from_ptr);
					dest_nctrls++;
					adjust_ctrl(to_ptr,1,dest_page,-1);
					linkleng= copy_links(from_ptr,old_ctrl_i,to_ptr,
													dest_nctrls,dest_page,&n_links);
					to_ptr += linkleng;
					dest_leng += linkleng;
					dest_nctrls += n_links;
				}
				else
				{
					adjust_ctrl(to_ptr,0,dest_page,dest_nctrls);
					dest_nctrls++;
				}
				to_ptr += length;
				dest_leng += length;
				result= -1;
			}
			nselected--;
		}
		from_ptr += length;
	}	/* end loop through all controls */
	graf_mouse(ARROWMOUSE);

	/* shrink destination, expand source */
	change_mem(dest_mem,dest_leng);
	expand_curr();

	return result;

}	/* end page_temreg() */

/* snap region ..............................................................*/
/* returns 1 */

snap_temreg()
{
	register long ptr;
	register int i;
	register CTRLHEADER *ctrl;

	graf_mouse(BEE_MOUSE);
	ptr= heap[curr_mem].start;
	for (i=0; (i<curr_nctrls)&&nselected; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type >= 0) && (isctrlbit(ptr,0)) )
		{
			snap_ctrl(ctrl->type,ptr+sizeof(*ctrl),temsnap_x,temsnap_y);
			new_region=1;
			nselected--;
		}
		ptr += ctrl->length;
	}	/* end loop through all controls */
	graf_mouse(ARROWMOUSE);

	return 1;
}	/* end snap_temreg() */

/* change font(s) ...........................................................*/
/* returns 0= cancelled, 1= did it */

font_temreg()
{
	int result=0;
	int newnormfont,newminifont;
	register long ptr;
	register int i;
	CTRLHEADER *ctrl;

	/* change normal font? */
	tem_prompt(CHFONT1MSG);
	i= (Crawcin()) >> 16 ;
	newnormfont= i==SCAN_Y ;
	tem_prompt(0L);

	/* change miniature font? */
	tem_prompt(CHFONT2MSG);
	i= (Crawcin()) >> 16 ;
	newminifont= i==SCAN_Y ;
	tem_prompt(0L);

	if ( !newminifont && !newnormfont ) return 0;

	graf_mouse(BEE_MOUSE);
	ptr= heap[curr_mem].start;
	for (i=0; (i<curr_nctrls)&&nselected; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type>=0) && (isctrlbit(ptr,0)) )
		{
			if (font_ctrl(ctrl->type,ptr+sizeof(*ctrl),newnormfont,newminifont))
				result= new_region= 1;
			nselected--;
		}
		ptr += ctrl->length;
	}	/* end loop through all controls */
	graf_mouse(ARROWMOUSE);
	return result;
}	/* end font_temreg() */

font_ctrl(type,ptr,newnormfont,newminifont)
int type;
long ptr;	/* --> past ctrl header */
int newnormfont,newminifont;		/* 1= change it, 0= don't change it */
{
	int result=0;
	CTRL_NUMB *ctrl_numb;
	CTRL_TEXT *ctrl_text;
	CTRL_IBUT *ctrl_ibut;
	CTRL_CBUT *ctrl_cbut;
	int *fontptr;

	switch (type)
	{
		case CTYP_NUMB:
		ctrl_numb= (CTRL_NUMB*)(ptr);
		fontptr= &(ctrl_numb->font);
		break;

		case CTYP_TEXT:
		ctrl_text= (CTRL_TEXT*)(ptr);
		fontptr= &(ctrl_text->font);
		break;

		case CTYP_IBUT:
		ctrl_ibut= (CTRL_IBUT*)(ptr);
		fontptr= &(ctrl_ibut->font);
		break;

		case CTYP_CBUT:
		ctrl_cbut= (CTRL_CBUT*)(ptr);
		fontptr= &(ctrl_cbut->font);
		break;

		default:	fontptr= (int*)(0L);

	}	/* end switch (type) */

	if (fontptr)
	{
		if (*fontptr)
		{
			if (newminifont) *fontptr=0;
		}
		else
		{
			if (newnormfont) *fontptr=1;
		}
		snap_ctrl(type,ptr,temsnap_x,temsnap_y);
		result=1;
	}
	return result;

}	/* end font_ctrl() */

/* change control type ......................................................*/
/* returns 0= nothing happened, 1= something happened */

type_temreg()
{
	int warningflag=0;
	int result=0;
	int length,new_leng,new_type,nvals;
	CTRL_NUMB *new_numb;
	CTRL_SLID *new_slid;
	CTRL_KNOB *new_knob;
	VAL_INFO *new_val,*val[MAXNVALS];
	MAC_RECT *new_rect;
	register long ptr,ptr2;
	register int i;
	register CTRLHEADER *ctrl;

	/* use temp buffer for replacement control */
	new_numb= (CTRL_NUMB*)(cnxscrsave+sizeof(*ctrl));
	new_slid= (CTRL_SLID*)(cnxscrsave+sizeof(*ctrl));
	new_knob= (CTRL_KNOB*)(cnxscrsave+sizeof(*ctrl));

	/* choose replacement type */
	new_type= pop_up(TYPECHOOSE,-1,4,0L,0,newtypestr);
	if (new_type<0) return 0;	/* cancelled */

	ctrl= (CTRLHEADER*)(cnxscrsave);
	switch (new_type)
	{
		case 0:	/* miniature number */
		ctrl->type= CTYP_NUMB;
		ctrl->length= sizeof(*ctrl) + sizeof(*new_numb);
		new_numb->font= 1;
		new_val= &(new_numb->val);
		new_rect= &(new_numb->rect);
		break;

		case 1:	/* regular number */
		ctrl->type= CTYP_NUMB;
		ctrl->length= sizeof(*ctrl) + sizeof(*new_numb);
		new_numb->font= 0;
		new_val= &(new_numb->val);
		new_rect= &(new_numb->rect);
		break;

		case 2:	/* slider */
		ctrl->type= CTYP_SLID;
		ctrl->length= sizeof(*ctrl) + sizeof(*new_slid);
		new_val= &(new_slid->val);
		new_rect= &(new_slid->rect);
		break;

		case 3:	/* knob */
		ctrl->type= CTYP_KNOB;
		ctrl->length= sizeof(*ctrl) + sizeof(*new_knob);
		new_val= &(new_knob->val);
		new_rect= &(new_knob->rect);

	}	/* end switch (new_type) */
	new_leng= ctrl->length;
	new_type= ctrl->type;

	graf_mouse(BEE_MOUSE);
	ptr= heap[curr_mem].start;
	for (i=0; (i<curr_nctrls)&&nselected; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		ptr2= ptr + sizeof(*ctrl);
		length= ctrl->length;
		if ( (ctrl->type >= 0) && (isctrlbit(ptr,0)) )
		{
			nvals= find_vals(ctrl->type,ptr2,val);
			if ((nvals>1)&&!warningflag)
			{
				form_alert(1,BADMULTVAL);
				warningflag=1;
			}
			if (nvals==1)
			{
				/* check for memory overflow when increasing control length */
				if ((curr_leng-length+new_leng)>heap[curr_mem].nbytes)
				{
					form_alert(1,BADMEM2);
					break;
				}
				/* copy control's position, size, and value */
				copy_bytes(ptr2,new_rect,(long)(sizeof(*new_rect)));
				copy_bytes(val[0],new_val,(long)(sizeof(*new_val)));
				/* delete old control, insert new one */
				copy_bytes(ptr+length,ptr,
						curr_leng-(ptr+length-heap[curr_mem].start) );
				curr_leng -= length;
				insert_bytes((long)new_leng,cnxscrsave,ptr,
									heap[curr_mem].start+curr_leng);
				curr_leng += new_leng;
				length= new_leng;
				/* snap/clip */
				snap_ctrl(new_type,ptr2,temsnap_x,temsnap_y);
				new_region=1;
				result=1;
			}
			nselected--;
		}	/* end if control is visible and selected */
		ptr += length;
	}	/* end loop through all controls */
	graf_mouse(ARROWMOUSE);
	return result;
}	/* end type_temreg() */

/* add a white border behind each selected control ..........................*/
/* returns 0= nothing happened, 1= something happened */

bord_temreg()
{
	register long ptr;
	register int i;
	CTRLHEADER *ctrl;
	CTRLHEADER ctrlheader;
	CTRL_RECT ctrl_rect;
	int result=0;
	int x1,x2,y1,y2;

	/* build a rectangle control */
	ctrl_rect.fill= 0;			/* hollow */
	ctrl_rect.rect.color=0;		/* white */
	ctrlheader.type= CTYP_RECT;
	ctrlheader.length= sizeof(ctrlheader) + sizeof(ctrl_rect) ;

	graf_mouse(BEE_MOUSE);

	ptr= heap[curr_mem].start;
	for (i=0; (i<curr_nctrls)&&nselected; )
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type >= 0) && (isctrlbit(ptr,0)) )
		{
			clrctrlbit(ptr,0);
			setctrlbit(ptr,1);		/* mark for later re-selection */
			nselected--;

			/* get coordinates for rectangle */
			rect2scr(ptr+sizeof(*ctrl),&x1,&x2,&y1,&y2);
			x1= max(0,x1-2);
			x2= min(639,x2+2);
			y1= max(0,y1-rez);
			y2= min(200*rez-1,y2+rez);
			scr2rect(x1,x2,y1,y2,&(ctrl_rect.rect) );

			/* insert rectangle before selected control */
			if ( insert_ctrl(&ctrlheader,&ctrl_rect,sizeof(ctrl_rect),ptr) )
			{
				setctrlbit(ptr,1);		/* mark rectangle for later selection */
				curr_nctrl++;
				curr_nvctrl++;
				adjust_page(heap[curr_mem].start,curr_leng,4,i,dummy);
				result= new_region= 1;
			/* messes up control list; restart scan */
				i=0;
				ptr= heap[curr_mem].start;
				continue;
			}
		}
		i++;
		ptr += ctrl->length;
	}	/* end loop through all controls */

	resel_ctrls(); /* re-select region */

	return result;

}	/* end bord_temreg() */

/* user-interface for copy or move a region .................................*/
/* returns 1= controls copied/moved, 0= nothing changed */

drag_temreg(copy,links)
int copy,links;
{
	int new_x1,new_y1,new_x2,new_y2;
	int x1,y1,x2,y2;
	int del_x,del_y;
	register int i;
	char *ptr;

	/* wait for button to go down */
	if (copy)
		ptr= links ? DUPEREGNMSG : COPYREGNMSG ;
	else
		ptr= MOVEREGNMSG ;
	tem_prompt(ptr);
	while ( !getmouse(&dummy,&dummy) ) ;
	if (copy)
		ptr= links ? DUPECTLSMSG : COPYCTLSMSG ;
	else
		ptr= MOVECTLSMSG ;
	tem_prompt(ptr);

	new_x1= reg_rect.x1;	new_y1= reg_rect.y1;
	HIDEMOUSE;
	setmouse(new_x1,new_y1);
	slide_box(&new_x1,&new_y1,reg_rect.x2-reg_rect.x1+1,
									  reg_rect.y2-reg_rect.y1+1,
					0,tem_y,640,tem_h,0,0L,0L,0L,0L,0L,0L,0L,0L);
	SHOWMOUSE;
	tem_prompt(0L);
	if (Kbshift(-1)&K_ALT) return 0;	/* aborted */

	del_x= new_x1 - reg_rect.x1 ;
	del_y= new_y1 - reg_rect.y1 ;
	new_x2= reg_rect.x2 + del_x;
	new_y2= reg_rect.y2 + del_y;
	if (!del_x && !del_y) return 0;	/* no change */

	return shft_temreg(del_x,del_y,copy,links);
}	/* end drag_temreg() */

/* somehow combine this with drag_ctrl() in tem.c !!! */
shft_temreg(del_x,del_y,copy,links)
int del_x,del_y,copy,links;
{
	register CTRLHEADER *ctrl;
	register long ptr;
	register int i;
	int old_nctrls,error;
	int x1,y1,x2,y2;
	int result=0;

	graf_mouse(BEE_MOUSE);
	ptr= heap[curr_mem].start;
	old_nctrls=curr_nctrls; /* curr_nctrls increases during copying */
	for (i=error=0; (i<old_nctrls)&&!error&&nselected; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if ( (ctrl->type >= 0) && (isctrlbit(ptr,0)) )
		{
			rect2scr(ptr+sizeof(*ctrl),&x1,&x2,&y1,&y2);
			x1 += del_x ;
			x2 += del_x ;
			y1 += del_y ;
			y2 += del_y ;
			/* 0 means no redraw */
			if (copy)
				error=copy_ctrl(ptr,x1,x2,y1,y2,0,links);
			else
				move_ctrl(ptr,x1,x2,y1,y2,0);
			nselected--;
			result= new_region= 1;
		}
		ptr += ctrl->length;
	}	/* end loop through all controls */
	graf_mouse(ARROWMOUSE);

	return result;
}	/* end shft_temreg() */

/* how many selected controls ...............................................*/
/* returns how many */

nsel_temreg(ptr_out, ctrl_i_out)
long *ptr_out;
int *ctrl_i_out;
{
	int nselected=0;
	register long ptr,nbytes;
	register CTRLHEADER *ctrl;
	register int i;

	ptr= heap[curr_mem].start;
	nbytes= curr_leng;
	for (i=0; nbytes>2L; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if (ctrl->type >= 0)
		{
			if (isctrlbit(ptr,0))
			{
				nselected++;
				if (nselected==1)	/* mark first sel'd control */
				{
					*ptr_out= ptr;
					*ctrl_i_out=i;
				}
			}
		}
		ptr += ctrl->length;
		nbytes -= ctrl->length;
	}	/* end loop through all controls */
	return nselected;
}	/* end nsel_temreg() */

/* learn ....................................................................*/
/* returns 0= cancelled or error, -1= did it (no redraw) */

lern_temreg()
{
	int nbytes,nvals,result;
	int strgmem;
	unsigned int minstrg[MAXSTRLENG/2],maxstrg[MAXSTRLENG/2];
	char midistrg[MAXSTRLENG];
	VAL_INFO *val[MAXNVALS];
	CTRL_MIDI midictrl;
	CTRLHEADER ctrlheader;
	long ptr2,oldstrleng;

	/* can only learn one control at a time */
	if (nselected>1)
	{
		form_alert(1,BADLEARN1);
		return 0;
	}

	/* the selected control must have exactly 1 value */
	ptr2= (long)first_ctrl + sizeof(*first_ctrl);
	nvals= find_vals(first_ctrl->type,ptr2,val);
	if (nvals!=1)
	{
		form_alert(1,BADLEARN3);
		return 0;
	}

	graf_mouse(BEE_MOUSE);
	tem_prompt(LEARNMSG);
	reset_midi();
	runningstat= -1;
	nbytes= do_learn(minstrg,maxstrg);
	tem_prompt(0L);
	graf_mouse(ARROWMOUSE);
	if (nbytes<0) form_alert(1,BADLEARN2);
	if (nbytes<=0) return 0;

	/* from minstrg and maxstrg build a midi control */
	if (!lern2midi(nbytes,minstrg,maxstrg,&midictrl,midistrg))
	{
		form_alert(1,BADLEARN2);
		return 0;
	}
	nbytes *= 2; /* takes two characters to encode each midi byte */

	/* if the selected control is already linked to a midi control, delete
		that midi control */
	unlk_temreg(1);

	/* append this midi control to the current page */
	ctrlheader.type= CTYP_MIDI;
	ctrlheader.length= sizeof(ctrlheader) + sizeof(midictrl);
	midictrl.linkpage= val[0]->linkpage;
	midictrl.linkctrl= val[0]->linkctrl;
	midictrl.linkval= val[0]->linkval ;
	if (!insert_ctrl(&ctrlheader,&midictrl,sizeof(midictrl),-1L)) return 0;
	val[0]->linkctrl= curr_nctrl;
	val[0]->linkpage= curr_page;
	val[0]->linkval= 0;
	if (midictrl.low<=midictrl.high)
	{
		val[0]->low= midictrl.low;
		val[0]->high= midictrl.high;
	   val[0]->invert= 0;
	}
	else
	{
		val[0]->low= midictrl.high;
		val[0]->high= midictrl.low;
		val[0]->invert= 1;
	}
	curr_nctrl++;

	/* append the midi string to end of string pool */
	change_mem(curr_mem,curr_leng);
	strgmem= temmem[ seg_to_mem(idTEMSTRG) ] ;
	oldstrleng= heap[strgmem].nbytes;
	if (change_mem(strgmem,oldstrleng+nbytes+1))
	{
		copy_bytes(midistrg,heap[strgmem].start+midictrl.str,nbytes+1L);
		result= -1;
	}
	else
		result=0;
	fill_mem(curr_mem);
	return result;
}	/* end lern_temreg() */

/* returns how many bytes, 0 cancel, -1 error */
do_learn(minstrg,maxstrg)
unsigned int *minstrg,*maxstrg;
{
	unsigned int midibyte;
	int mstate,ndata;
	register int i;
	register int statbyte=0;
	register int result= -1;

	/* start with ridiculous min and max */
	set_words(minstrg,(long)MAXSTRLENG/2,0xFF);
	set_words(maxstrg,(long)MAXSTRLENG/2,0x00);

	while (1)
	{
		/* handle midi overflow condition */
		if (midiovfl)
		{
			form_alert(1,BADOVFL);
			return 0;
		}
		midibyte= get_midi();	/* obeys filtering and input port */

 		/* no midi byte received */
		if (midibyte==0xFF)
		{
			mstate= getmouse(&dummy,&dummy);
			if (mstate>1) return 0;
			if (mstate==1)
			{
				if (statbyte==0) return 0;
				return result;
			}
			continue;
		}

		/* status byte received */
		if (midibyte&0x80)
		{
			/* if a status byte has already been received -- */
			if (statbyte)
			{
				/* close off a sysex message and wait for another */
				if ((midibyte==midiEOX)&&(statbyte==midiSOX))
				{
					minstrg[i]= maxstrg[i]= midiEOX;
					result= i+1;
					continue;
				}
				/* restart a message */
				if (midibyte==statbyte)
				{
					i=1;
					continue;
				}
			}
			statbyte= midibyte;
			if (statbyte==midiEOX) return -1;
			ndata= statbyte==midiSOX ? 1000 : ndatabyte[whichstat(statbyte)] ;
			minstrg[0]= maxstrg[0]= statbyte;
			if (ndata==0) return 1;
			i=1;
			continue;
		}

		/* data byte received */
		if ( midibyte < minstrg[i] ) minstrg[i]= midibyte;
		if ( midibyte > maxstrg[i] ) maxstrg[i]= midibyte;
		if (statbyte==midiSOX)
		{
			if (i==(MAXSTRLENG/2-1)) return -1;
			i++;
		}
		else
		{
			if (i==ndata)
			{
				result= i+1;
				i=1;
			}
			else
				i++;
		}
	}	/* end while (1) */
}	/* end do_learn() */

/* returns 0=error, 1=ok */
lern2midi(nbytes,minstrg,maxstrg,midictrl,midistrg)
int nbytes;
unsigned int *minstrg,*maxstrg;
CTRL_MIDI *midictrl;
char *midistrg;
{
	int strgmem;
	register int i;
	unsigned int ch;
	int nvar,high_i,low_i;

	nvar=0;
	for (i=nbytes-1; i>=0; i--)
	{
		/* constant byte? */
		if (minstrg[i]==maxstrg[i])
		{
			ch= minstrg[i];
			ch >>= 4;
			midistrg[2*i]= ch<10 ? ch+'0' : ch-10+'A' ;
			if ( (ch>=8) && (ch<=0xE) )
				midistrg[2*i+1]= 'n';
			else
			{
				ch= minstrg[i];
				ch &= 0x0F;
				midistrg[2*i+1]= ch<10 ? ch+'0' : ch-10+'A' ;
			}
		}
		else
		{
			nvar++;
			if (nvar==1)
			{
				midistrg[2*i]= 'u';
				midistrg[2*i+1]= 'v';
				low_i= i;
			}
			if (nvar==2)
			{
				midistrg[2*i]= 's';
				midistrg[2*i+1]= 't';
				high_i= i;
			}
			if (nvar>2) return 0;
		}
	}
	midistrg[2*nbytes]=0;

	if (nvar==0) /* no variable bytes */
	{
		midictrl->low=0;
		midictrl->high=127;
	}
	if (nvar==1) /* 1 variable byte */
	{
		midictrl->low= minstrg[low_i];
		midictrl->high= maxstrg[low_i];
	}
	if (nvar==2) /* 2 variable bytes */
	{
		midictrl->low= minstrg[low_i] + 128*minstrg[high_i];
		midictrl->high= maxstrg[low_i] + 128*maxstrg[high_i];
	}
	midictrl->delta=1;

	/* prepare to append midi string to the string pool */
	strgmem= temmem[ seg_to_mem(idTEMSTRG) ] ;
	midictrl->str= heap[strgmem].nbytes;
	return 1;
}

#endif

/* EOF */
