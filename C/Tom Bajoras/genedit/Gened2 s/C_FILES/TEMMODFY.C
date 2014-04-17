/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module TEMMODFY : template modification

	add_ctrl, size_ctrl, move_ctrl, copy_ctrl
	del_ctrl, _del_ctrl, __del_ctrl
	front_ctrl
	insert_ctrl, adjust_page, adjust_ctrl
	find_vals, find_links, find_strgs, findebdtmidi
	_findebdtmidi, clean_pool,	debug_tem, hivTest
	ctrli2addr, ctrladdr2i
	append_strgs, copy_links

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

/* variables in tem.c .......................................................*/

extern int tem_x,tem_y,tem_w,tem_h;
extern CTRLHEADER ctrlheader;
extern MAC_RECT mac_rect;
extern VAL_INFO val_info;
extern XVAL_INFO xval_info;
extern int curr_page,curr_mem;
extern long curr_leng;
extern int curr_nctrl,curr_nvctrl;
extern int temsnap_x,temsnap_y,temdelsafe;

extern CTRL_LINE ctrl_line;	/* the pallette */
extern CTRL_RECT ctrl_rect;
extern CTRL_SLID ctrl_slid;
extern CTRL_KNOB ctrl_knob;
extern CTRL_TEXT ctrl_text;
extern CTRL_NUMB ctrl_numb;
extern CTRL_IBUT ctrl_ibut;
extern CTRL_CBUT ctrl_cbut;
extern CTRL_GRPH ctrl_grph;
extern CTRL_JOY  ctrl_joy ;

/* local globals ............................................................*/

CTRL_LINE *line_ptr;		/* these are declared global just so I don't have */
CTRL_RECT *rect_ptr;		/* to repeatedly declare them as local.  They're not */
CTRL_TEXT *text_ptr;		/* shared across functions */
CTRL_NUMB *numb_ptr;
CTRL_KNOB *knob_ptr;
CTRL_SLID *slid_ptr;
CTRL_IBUT *ibut_ptr;
CTRL_CBUT *cbut_ptr;
CTRL_GRPH *grph_ptr;
CTRL_JOY  *joy_ptr ;
CTRL_EBDT *ebdt_ptr;
CTRL_MIDI *midi_ptr;

long ctrl_ptr[12]= {
	(long)(&ctrl_line),
	(long)(&ctrl_rect),
	0L,	/* unused */
	(long)(&ctrl_text),
	(long)(&ctrl_numb),
	(long)(&ctrl_knob),
	0L,	/* unused */
	(long)(&ctrl_slid),
	(long)(&ctrl_ibut),
	(long)(&ctrl_cbut),
	(long)(&ctrl_grph),
	(long)(&ctrl_joy ),
};
int ctrl_length[12]= {
	sizeof(ctrl_line),
	sizeof(ctrl_rect),
	0,		/* unused */
	sizeof(ctrl_text),
	sizeof(ctrl_numb),
	sizeof(ctrl_knob),
	0,		/* unused */
	sizeof(ctrl_slid),
	sizeof(ctrl_ibut),
	sizeof(ctrl_cbut),
	sizeof(ctrl_grph),
	sizeof(ctrl_joy ),
};

int debugline;			/* debugging terminal */

#if TEMFLAG

/* add a control to current page ............................................*/
/* returns # of added control, -1 if error or cancelled */

add_ctrl(type,mx,my)
int type;	/* CTYP_xxxx */
int mx,my;	/* mouse absolute screen coordinates */
{
	int x1,y1,x2,y2;
	int tem_x1,tem_y1,tem_x2,tem_y2;
	int temp,length;
	long ptr,new_ctrl;

	/* user-interface for creating control's rectangle */
	tem_x1= tem_x;
	tem_y1= tem_y;
	tem_x2= tem_x + tem_w - 1 ;
	tem_y2= tem_y + tem_h - 1 ;
	x2= x1= mx; y2= y1= my; /* start with 1x1 rectangle */
	tem_prompt(ADDCTRLMSG);
	HIDEMOUSE;
	if (type==CTYP_LINE)
	{
		rubberline(x1,y1,&x2,&y2,tem_x1,tem_y1,tem_x2,tem_y2);
		if (y2<y1)
		{
			temp=x1; x1=x2; x2=temp;
			temp=y1; y1=y2; y2=temp;
		}
	}
	else
	{
		rubberbox(mx,my,&x2,&y2,tem_x1,tem_y1,tem_x2,tem_y2);
		x1= min(mx,x2);		/* rectangle must be positive */
		x2= max(mx,x2);
		y1= min(my,y2);
		y2= max(my,y2);
	}
	SHOWMOUSE;
	tem_prompt(TEM_MSG);
	if (Kbshift(-1)&K_ALT) return -1;	/* <Alternate> = abort */

	/* get control from pallette */
	ptr= ctrl_ptr[type];
	length= ctrl_length[type];
	ctrlheader.type= type;
	ctrlheader.length= length + sizeof(ctrlheader) ;

	/* convert to relative coordinates */
	scr2rect(x1,x2,y1,y2,ptr);
	snap_ctrl(type,ptr,temsnap_x,temsnap_y);
	rect2scr(ptr,&x1,&x2,&y1,&y2);	

	/* add control to end of current page */
	new_ctrl= heap[curr_mem].start + curr_leng;	/* where it will go */
	if (!insert_ctrl(&ctrlheader,ptr,length,-1L)) return -1;
	adjust_ctrl(new_ctrl,0,curr_page,curr_nctrl);
	temp= curr_nctrl;
	curr_nctrl++;
	curr_nvctrl++;
	draw_tem(x1,y1,x2,y2);
	change_flag[temCHANGE]= 1;
	return temp;
}	/* end add_ctrl() */

/* delete a control from current page .......................................*/

del_ctrl(ptr,ctrl_i)
long ptr;	/* --> control header */
int ctrl_i;	/* control number */
{
	int x1,x2,y1,y2;
	int mstate,w,h;

	rect2scr(ptr+sizeof(ctrlheader),&x1,&x2,&y1,&y2);		/* screen domain */

	/* delete safety */
	if (temdelsafe)
	{
		tem_prompt(DELCTRLMSG);
		HIDEMOUSE;
		w= x2-x1+1;		h= y2-y1+1;
		mstate= slide_box(&x1,&y1,w,h,x1,y1,w,h,0,0L,0L,0L,0L,0L,0L,0L,0L);
		SHOWMOUSE;
		tem_prompt(TEM_MSG);
		if (mstate!=3) return;
	}
	_del_ctrl(ptr,ctrl_i);											/* delete it */
	draw_tem(x1,y1,x2,y2);											/* redraw */
	change_flag[temCHANGE]=1;										/* changed */

}	/* end del_ctrl() */

/* delete a control and all associated ebdt/midi controls ...................*/

_del_ctrl(ptr,ctrl_i)
long ptr;	/* --> control header */
int ctrl_i;	/* control number */
{
	CTRLHEADER *ctrl;
	register int i,j,n;
	int n_link,link_i[2*MAXNVALS],link_dummy[2*MAXNVALS];
	long ebdt,midi,link_ptr[2*MAXNVALS];
	long ctrli2addr();

	ctrl= (CTRLHEADER*)(ptr);

	/* find all ebdt and midi controls linked to this control */
	n_link= _findebdtmidi(ctrl_i,ctrl->type,ptr+sizeof(ctrlheader),
								 link_ptr,link_i,link_dummy,link_dummy);

	/* delete all linked controls, in reverse order so that
		link_ptr[] remains valid throughout this loop */
	for (i=0; i<n_link; i++)
	{
		j= max_word(n_link,link_i);
		n= link_i[j];
		link_i[j]= -1;
		__del_ctrl(link_ptr[j]-sizeof(ctrlheader),n);
		if (ctrl_i>n) ctrl_i--;
	}

	/* last but not least, delete the visible control */
	ptr= ctrli2addr(ctrl_i,heap[curr_mem].start,0);
	__del_ctrl(ptr,ctrl_i);
	curr_nvctrl--;

}	/* end _del_ctrl() */

/* low level delete a control ...............................................*/

__del_ctrl(ptr,ctrl_i)
long ptr;			/* --> control header */
int ctrl_i;			/* control # to be deleted */
{
	long length,ptr2,length2;
	CTRLHEADER *ctrl;

	ctrl= (CTRLHEADER*)(ptr);

	/* how many bytes to be deleted */
	length= ctrl->length;

	/* delete it */
	ptr2= ptr+length;	/* --> 1st byte past what's to be deleted */
	length2= curr_leng-(ptr2-heap[curr_mem].start);
	copy_words(ptr2,ptr,length2/2);
	curr_nctrl--;
	curr_leng -= length;

	/* decrement links after ctrl_i */
	adjust_page(heap[curr_mem].start,curr_leng,2,ctrl_i,dummy);

}	/* end __del_ctrl() */

/* move control to start/end of list ........................................*/

front_ctrl(front,ptr,ctrl_i)
int front;	/* 1= to end of list, 0= to start of list */
long ptr;	/* --> control header */
int ctrl_i;	/* control number */
{
	long ptr2,length2;
	int length;
	CTRLHEADER *ctrl;

	ctrl= (CTRLHEADER*)(ptr);

	/* copy control to buffer */
	length= ctrl->length;
	copy_bytes(ptr,cnxscrsave,(long)length);

	/* delete it */
	ptr2= ptr+length;	/* --> 1st byte past what's to be deleted */
	length2= curr_leng-(ptr2-heap[curr_mem].start);
	copy_words(ptr2,ptr,length2/2);
	curr_leng -= length;

	if (front)
	{
		/* insert it at end of list */
		insert_ctrl(0L,cnxscrsave,length,-1L);
		adjust_page(heap[curr_mem].start,curr_leng,6,ctrl_i,curr_nctrl-1);
	}
	else
	{
		/* insert it at start of list */
		insert_ctrl(0L,cnxscrsave,length,heap[curr_mem].start);
		adjust_page(heap[curr_mem].start,curr_leng,5,ctrl_i,0);
	}
}	/* end front_ctrl() */

/* resize a control on current page .........................................*/

size_ctrl(ptr,mx,my)
long ptr;	/* --> control header */
int mx,my;	/* mouse absolute screen coordinates */
{
	CTRLHEADER *ctrl;
	int type,x1,y1,x2,y2,xmid,ymid;
	int tem_x1,tem_x2,tem_y1,tem_y2;
	int temp,quad;
	long dist1,dist2;

	/* what kind of control? (line or non-line) */
	ctrl= (CTRLHEADER*)(ptr);
	type= ctrl->type;

	/* current position and size */
	rect2scr(ptr+sizeof(ctrlheader),&x1,&x2,&y1,&y2);

	/* limits */
	tem_x1= tem_x;
	tem_y1= tem_y;
	tem_x2= tem_x + tem_w - 1 ;
	tem_y2= tem_y + tem_h - 1 ;

	/* user-interface for resizing */
	if (type==CTYP_LINE)
	{
		tem_prompt(SIZECTRLMSG);
		HIDEMOUSE;
		/* closer to which end? (anchor the opposite end) */
		dist1= (long)(mx-x1)*(mx-x1) + (long)(my-y1)*(my-y1) ;
		dist2= (long)(mx-x2)*(mx-x2) + (long)(my-y2)*(my-y2) ;
		if (dist1<dist2)
			rubberline(x2,y2,&x1,&y1,tem_x1,tem_y1,tem_x2,tem_y2);
		else
			rubberline(x1,y1,&x2,&y2,tem_x1,tem_y1,tem_x2,tem_y2);
		SHOWMOUSE;
		tem_prompt(TEM_MSG);
		if (y2<y1)
		{
			temp=x1; x1=x2; x2=temp;
			temp=y1; y1=y2; y2=temp;
		}
	}
	else	/* other than line type */
	{
		/* quadrant: 0= upper L, 1= lower L, 2= upper R, 3= lower R */
		xmid= (x1+x2)/2;		ymid= (y1+y2)/2;
		quad= (mx>=x1-2) && (mx<=xmid) ? 0 : 2 ;		/* left or right */
		if ( (my<=y2+2) && (my>=ymid) ) quad++;		/* upper or lower */
		tem_prompt(SIZECTRLMSG);
		HIDEMOUSE;
		switch (quad)
		{
			case 0: rubberbox(x2,y2,&x1,&y1,tem_x1,tem_y1,tem_x2,tem_y2); break;
			case 1: rubberbox(x2,y1,&x1,&y2,tem_x1,tem_y1,tem_x2,tem_y2); break;
			case 2: rubberbox(x1,y2,&x2,&y1,tem_x1,tem_y1,tem_x2,tem_y2); break;
			case 3: rubberbox(x1,y1,&x2,&y2,tem_x1,tem_y1,tem_x2,tem_y2);
		}
		SHOWMOUSE;
		tem_prompt(TEM_MSG);
		if (x2<x1) { temp=x1; x1=x2; x2=temp; }
		if (y2<y1) { temp=y1; y1=y2; y2=temp; }
	}
	if ( Kbshift(-1) & K_ALT ) return;	/* abort on <Alternate> */

	move_ctrl(ptr,x1,x2,y1,y2,1);

}	/* end size_ctrl() */

/* move/resize control (after user-interface) ...............................*/

move_ctrl(ptr,new_x1,new_x2,new_y1,new_y2,redraw)
long ptr;								/* --> control header */
int new_x1,new_x2,new_y1,new_y2;	/* absolute screen coordinates */
int redraw;
{
	CTRLHEADER *ctrl;
	MAC_RECT *rect;
	int type;
	int x1,y1,x2,y2;

	ctrl= (CTRLHEADER*)(ptr);
	rect= (MAC_RECT*)(ptr+sizeof(ctrlheader));

	/* swap in fake invisible control */
	type= ctrl->type;
	ctrl->type = CTYP_DUMMY;

	/* old screen domain */
	rect2scr(rect,&x1,&x2,&y1,&y2);
	if (redraw) draw_tem(x1,y1,x2,y2);

	/* swap in real control type */
	ctrl->type= type;

	/* move it */
	scr2rect(new_x1,new_x2,new_y1,new_y2,rect);
	snap_ctrl(type,rect,temsnap_x,temsnap_y);
	rect2scr(rect,&x1,&x2,&y1,&y2);

	/* redraw new screen domain */
	if (redraw) draw_tem(x1,y1,x2,y2);

	change_flag[temCHANGE]= 1;

}	/* end move_ctrl() */

/* copy control .............................................................*/
/* returns 1= failed due to memory overflow (error message inside here),
	0= ok */

copy_ctrl(from_ptr,x1,x2,y1,y2,redraw,links)
long from_ptr;		/* --> control header */
int x1,x2,y1,y2;	/* absolute screen coordinates */
int redraw;			/* whether to redraw after copying */
int links;			/* whether to copy linked controls */
{
	register long templong;
	CTRLHEADER *ctrl;
	long to_ptr;
	int nlinks;
	CTRL_EBDT *ebdtctrl;
	CTRL_MIDI *midictrl;
	int old_ctrl_i,temp;
	long copy_links();

	ctrl= (CTRLHEADER*)(from_ptr);

	/* check for memory overflow */
	templong= ctrl->length ;
	if (links)
	{
		temp= sizeof(*ctrl) + sizeof(*ebdtctrl) ;
		templong += (MAXNVALS*temp) ;
		temp= sizeof(*ctrl) + sizeof(*midictrl) ;
		templong += (MAXNVALS*temp) ;
	}
	if ( (curr_leng + templong ) > heap[curr_mem].nbytes )
	{
		form_alert(1,BADMEM2);
		return 1;
	}

	/* copy control to end of current page */
	to_ptr= heap[curr_mem].start+curr_leng ;
	templong= ctrl->length ;
	copy_bytes(from_ptr,to_ptr,templong);
	curr_nctrl++;
	curr_nvctrl++;
	curr_leng += templong;

	/* copy or init links */
	if (links)
	{
		old_ctrl_i= ctrladdr2i(from_ptr);
		curr_leng += copy_links(from_ptr,old_ctrl_i,to_ptr,
											curr_nctrl,curr_page,&nlinks);
		curr_nctrl += nlinks;
	}
	else
		adjust_ctrl(to_ptr,0,curr_page,curr_nctrl-1);

	/* copied control's new position */
	ctrl= (CTRLHEADER*)(from_ptr);
	to_ptr += sizeof(*ctrl);
	scr2rect(x1,x2,y1,y2,to_ptr);
	snap_ctrl(ctrl->type,to_ptr,temsnap_x,temsnap_y);
	rect2scr(to_ptr,&x1,&x2,&y1,&y2);

	if (redraw) draw_tem(x1,y1,x2,y2);
	change_flag[temCHANGE]= 1;
	return 0;

}	/* end copy_ctrl() */

/* insert control(s) in current page ........................................*/
/* returns 1= success, 0= not enough memory, error message inside here */
/* changes curr_leng */

insert_ctrl(ptr1,ptr2,length,ptr3)
long ptr1;		/* 0L or --> control header */
long ptr2;		/* --> anything */
int length;		/* # bytes in ptr2 */
long ptr3;		/* where in list to be inserted, -1L means end of list */
{
	register long templong;

	if (ptr3<0L) ptr3= heap[curr_mem].start + curr_leng ;

	templong= length;
	if (ptr1) templong += sizeof(ctrlheader);
	if ( (templong+curr_leng) > heap[curr_mem].nbytes )
	{
		form_alert(1,BADMEM2);
		return 0;
	}
	if (ptr1)
	{
		insert_bytes((long)sizeof(ctrlheader),ptr1,ptr3,
						 heap[curr_mem].start+curr_leng);
		ptr3 += sizeof(ctrlheader);
		curr_leng += sizeof(ctrlheader);
	}
	insert_bytes((long)length,ptr2,ptr3,
						 heap[curr_mem].start+curr_leng);
	curr_leng += length;
	return 1;

}	/* end insert_ctrl() */

/* debug current page .......................................................*/

debug_tem()
{
	char buf[6];
	register int ctrl_i;
	register long ptr;
	register CTRLHEADER *ctrl;

	HIDEMOUSE;
	save_screen(0,200*rez-1);
	set_longs(scrbase,SCRLENG/4,0L);
	Cconout(0x1b); Cconout(0x45);		/* home terminal */
	debugline=0;

	ptr= heap[curr_mem].start;
	for (ctrl_i=0; ctrl_i<curr_nctrl; ctrl_i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		debugAline(ctrl->type,ctrl_i);
		adjust_ctrl(ptr,-1,ctrl->type,ctrl_i);
		ptr += ctrl->length;
		if (debugline<0) break;
	}	/* end scan through page */

	if (debugline>=0)
	{
		Cconws("\n\rType a key.");
		Crawcin();
	}

	rest_screen(0,200*rez-1);
	SHOWMOUSE;

}	/* end debug_tem() */

/* check current page for bad links .........................................*/
/* returns how many bad controls */

hivTest()
{
	register int ctrl_i;
	register long ptr;
	register CTRLHEADER *ctrl;
	int error=0;
	char errbuf[6];

	ptr= heap[curr_mem].start;
	for (ctrl_i=0; ctrl_i<curr_nctrl; ctrl_i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if (adjust_ctrl(ptr,-2,ctrl->type,ctrl_i))
		{
			error++;
			setctrlbit(ptr,0);
		}
		ptr += ctrl->length;
	}	/* end scan through page */

	if (error)
	{
		itoa(error,errbuf,5);
		if (big_alert(1,BADHIV1,errbuf,BADHIV2)==2)
			hivFix();
	}
	return error;
}	/* end hivTest() */

/* fix bad links on current page ............................................*/

hivFix()
{
	register int ctrl_i;
	register long ptr;
	register CTRLHEADER *ctrl;

	ptr= heap[curr_mem].start;
	for (ctrl_i=0; ctrl_i<curr_nctrl; ctrl_i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		if (adjust_ctrl(ptr,-2,ctrl->type,ctrl_i))
			adjust_ctrl(ptr,1,curr_page,ctrl_i);
		ptr += ctrl->length;
	}	/* end scan through page */

}	/* end hivFix() */

/* adjust all links on a page ...............................................*/

adjust_page(ptr,nbytes,op,arg1,arg2)
register long ptr;		/* --> what's to be adjusted */
register long nbytes;	/* length of what's to be adjusted */
int op;						/* do what? */
int arg1,arg2;				/* arguments for what we're doing */
{
	CTRLHEADER *ctrl;

	while (nbytes>2L)
	{
		ctrl= (CTRLHEADER*)(ptr);
		adjust_ctrl(ptr,op,arg1,arg2);
		ptr += ctrl->length;
		nbytes -= ctrl->length;
	}	/* end scan through page */
}	/* end adjust_page() */

/* adjust a control's links .................................................*/
/* returns 1= error, 0= ok */

adjust_ctrl(ctrl,op,arg1,arg2)
CTRLHEADER *ctrl;		/* --> control header */
register int op;		/* do what? */
int arg1,arg2;			/* arguments for what we're doing */
{
	register int i,j,nlinks;
	int *linkpage[MAXNVALS],*linkctrl[MAXNVALS],*linkval[MAXNVALS];
	int error=0;

	/* how many links and where are they */
	nlinks= find_links(ctrl->type,(long)(ctrl)+sizeof(ctrlheader),
						  linkpage,linkctrl,linkval);

	switch (op)
	{
		case -2:			/* check for bad links */
		for (i=0; i<nlinks; i++)
			if ( hivCtrl(arg1, arg2, *(linkctrl[i]) ) )
				error=1;
		break;

		case -1:			/* debug */
		for (i=0; (i<nlinks)&&(debugline>=0); i++)
			debugBline(arg1,arg2,*(linkpage[i]),*(linkctrl[i]),*(linkval[i]));
		break;
		
		case 0:			/* set page, control, val */
		for (i=0; i<nlinks; i++)
		{
			*(linkpage[i])= arg1;
			*(linkctrl[i])= arg2;
			*(linkval[i])= 0;
		}
		break;

		case 1:			/* set page and/or control */
		for (i=0; i<nlinks; i++)
		{
			if (arg1>=0) *(linkpage[i])= arg1;
			if (arg2>=0) *(linkctrl[i])= arg2;
		}
		break;

		case 2:			/* decrement any control > arg1 */
		for (i=0; i<nlinks; i++)
			if ( *(linkctrl[i]) > arg1 ) (*(linkctrl[i]))--;
		break;

		case 3:			/* set control link for a given val */
		*(linkctrl[arg1])= arg2;
		break;

		case 4:			/* increment any control >= a given control # */
		for (i=0; i<nlinks; i++)
			if ( (*(linkctrl[i])) >= arg1 ) (*(linkctrl[i]))++;
		break;

		case 5:			/* increment any control < a given control #,
								replace control arg1 with arg2 */
		for (i=0; i<nlinks; i++)
		{
			j= *(linkctrl[i]);
			if (j<arg1) (*(linkctrl[i]))++;
			if (j==arg1) (*(linkctrl[i]))= arg2;
		}
		break;

		case 6:			/* decrement any control between arg1 and arg2,
								replace control arg1 with arg2 */
		for (i=0; i<nlinks; i++)
		{
			j= *(linkctrl[i]);
			if ((j>arg1)&&(j<=arg2)) (*(linkctrl[i]))--;
			if (j==arg1) (*(linkctrl[i]))= arg2;
		}
	}	/* end switch (op) */

	return error;

}	/* end adjust_ctrl() */

/* template debugger ........................................................*/

debugAline(type,ctrl_i)
int type,ctrl_i;
{
	char line[80];
	char ibuf[10];
	static char *vtypestr[13]= {
		"Line", "Rect", "????", "Text", "Numb", "Knob", "????", "Slid", "Ibut",
		"Cbut", "Grph", "Joy ", "Scal"
	};
	static char *itypestr[4]= {
		"????", "Ebdt", "Code", "Midi"
	};

	strcpy(line,"Ctrl# ");
	itoa(ctrl_i,ibuf,5);
	strcat(line,ibuf);
	strcat(line,"      Type ");
	if (type>=0)
		strcat(line,vtypestr[type]);
	else
		strcat(line,itypestr[-type]);
	debugws(line,0);
}	/* end debugAline() */

/* is a control linked incorrectly? .........................................*/

hivCtrl(type,ctrl_i,linkctrl)
int type,ctrl_i;
int linkctrl;
{
	int error;
	long ebdt,midi;
	int ebdt_i,midi_i;

	if (type>=0) /* visible */
		error= findebdtmidi(ctrl_i,linkctrl,&ebdt,&midi,&ebdt_i,&midi_i);
	else
		error= 0;
	if ( (linkctrl<0) || (linkctrl>=curr_nctrl) ) error=1;
	return error;
}

debugBline(type,ctrl_i,linkpage,linkctrl,linkval)
int type,ctrl_i;
int linkpage,linkctrl,linkval;
{
	char line[80];
	char ibuf[10];
	int error;

	strcpy(line,"          ");
	strcat(line,"linkpage= ");
	itoa(linkpage,ibuf,5);
	strcat(line,ibuf);

	strcat(line,"   ");
	strcat(line,"linkctrl= ");
	itoa(linkctrl,ibuf,5);
	strcat(line,ibuf);

	strcat(line,"   ");
	strcat(line,"linkval= ");
	itoa(linkval,ibuf,5);
	strcat(line,ibuf);

	/* bad control? */
	error= hivCtrl(type,ctrl_i,linkctrl);

	debugws(line,error);
}	/* end debugBline() */

debugws(line,error)
char *line;
int error;
{
	Cconws("\n\r");
	if (error) Cconws("*** ");
	Cconws(line);
	debugline++;
	if (debugline==23)
	{
		Cconws("\n\rType a key -- ESC to abort");
		debugline= (Crawcin()&0xFF) == 0x1b ? -1 : 0 ;
	}
}	/* end debugws() */

/* find links in a control ..................................................*/
/* returns # of links */

find_links(type,ptr,linkpage,linkctrl,linkval)
int type;			/* CTYP_xxxx */
long ptr;			/* --> control (past header) */
int **linkpage,**linkctrl,**linkval;	/* found links */
{
	register int i;
	int nval;
	VAL_INFO *val[MAXNVALS];

	/* these have links but no valinfo's */
	if (type==CTYP_EBDT)
	{
		ebdt_ptr=		(CTRL_EBDT*)(ptr);
		linkpage[0]=	&(ebdt_ptr->linkpage);
		linkctrl[0]=	&(ebdt_ptr->linkctrl);
		linkval[0]=		&(ebdt_ptr->linkval);
		return 1;
	}
	if (type==CTYP_MIDI)
	{
		midi_ptr=		(CTRL_MIDI*)(ptr);
		linkpage[0]=	&(midi_ptr->linkpage);
		linkctrl[0]=	&(midi_ptr->linkctrl);
		linkval[0]=		&(midi_ptr->linkval);
		return 1;
	}

	/* other controls have valinfo's */
	nval= find_vals(type,ptr,val);
	for (i=0; i<nval; i++)
	{
		linkpage[i]= &(val[i]->linkpage);
		linkctrl[i]= &(val[i]->linkctrl);
		linkval[i]= &(val[i]->linkval);
	}
	return nval;
}	/* end find_links() */

/* find [x]valinfo's in a control ...........................................*/
/* returns # [x]valinfo's found (>=0) */

find_vals(type,ptr,val)
int type;			/* CTYP_xxxx */
long ptr;			/* --> after ctrl header */
VAL_INFO *val[];	/* found [x]valinfo's */
{
	register int i,nval=0;

	switch (type)
	{
		case CTYP_SLID:
		case CTYP_KNOB:
		slid_ptr= (CTRL_SLID*)(ptr);
		val[nval++]= &(slid_ptr->val);
		break;

		case CTYP_TEXT:
		case CTYP_NUMB:
		text_ptr= (CTRL_TEXT*)(ptr);
		val[nval++]= &(text_ptr->val);
		break;
		
		case CTYP_GRPH:
		grph_ptr= (CTRL_GRPH*)(ptr);
		i= 2*(grph_ptr->npoints);
		for (nval=0; nval<i; nval++)
		{
			if (nval&1)
				val[nval]= &( (grph_ptr->xxval[nval/2]).yval );
			else
				val[nval]= &( (grph_ptr->xxval[nval/2]).xval );
		}
		break;
		
		case CTYP_JOY :
		joy_ptr= (CTRL_JOY*)(ptr);
		for (nval=0; nval<2; nval++) val[nval]= &(joy_ptr->val[nval]);
		break;
		
		case CTYP_CBUT:
		cbut_ptr= (CTRL_CBUT*)(ptr);
		val[nval++]= &(cbut_ptr->val);
		break;
		
		case CTYP_IBUT:
		ibut_ptr= (CTRL_IBUT*)(ptr);
		i= (ibut_ptr->nrows)*(ibut_ptr->ncols);
		for (nval=0; nval<i; nval++)
			val[nval]= (VAL_INFO*)(   &(ibut_ptr->xval[nval])   ) ;

	}	/* end switch (type) */

	return nval;

}	/* end find_vals() */

/* find string indexes in a control .........................................*/
/* returns # of str's */

find_strgs(type,ptr,which,str)
int type;		/* CTYP_xxxx */
long ptr;		/* --> control (past header) */
int which;		/* which string to find, -1 for all */
long **str;		/* found string indexes, 0L means return nstr but don't find */
{
	int nstr=0;
	VAL_INFO *val;
	register int i,j;

	switch (type)
	{
		case CTYP_TEXT:
		text_ptr= (CTRL_TEXT*)(ptr);
		val= &(text_ptr->val);
		nstr= val->high + 1 ;
		if (str)
			for (i=j=0; i<nstr; i++)
				if ((which<0)||(which==i))
					str[j++]= &(text_ptr->str[i]) ;
		break;
		
		case CTYP_CBUT:
		cbut_ptr= (CTRL_CBUT*)(ptr);
		nstr= cbut_ptr->nrows * cbut_ptr->ncols ;
		if (str)
			for (i=j=0; i<nstr; i++)
				if ((which<0)||(which==i))
					str[j++]= &(cbut_ptr->str[i]) ;
		break;
		
		case CTYP_IBUT:
		ibut_ptr= (CTRL_IBUT*)(ptr);
		nstr= ibut_ptr->nrows * ibut_ptr->ncols;
		if (str)
			for (i=j=0; i<nstr; i++)
				if ((which<0)||(which==i))				
					str[j++]= &( (ibut_ptr->xval[i]).str ) ;
		break;

		case CTYP_MIDI:
		midi_ptr= (CTRL_MIDI*)(ptr);
		nstr=1;
		if (str)
			if ((which<0)||(which==0))							
				str[0]= &(midi_ptr->str);

	}	/* end switch (type) */
	return nstr;
}	/* end find_strgs() */

/* convert control number to absolute address ...............................*/
/* returns pointer to control header */

long ctrli2addr(i,ptr,iref)
int i;					/* control to be found, 0 - (curr_nctrl-1) */
register long ptr;	/* address of control # iref */
register int iref;
{
	CTRLHEADER *ctrl;

	/* can't scan backwards, so scan forward from start */
	if (iref>i)
	{
		iref=0;
		ptr= heap[curr_mem].start;
	}
	while (iref<i)
	{
		ctrl= (CTRLHEADER*)(ptr);
		ptr += ctrl->length;
		iref++;
	}
	return ptr;
}	/* end ctrli2addr() */

/* convert control address to number ........................................*/
/* returns number, -1 for error */

ctrladdr2i(findptr)
long findptr;	/* --> ctrl header */
{
	register long ptr;
	register int i;

	ptr= heap[curr_mem].start;
	for (i=0; i<curr_nctrls; i++)
	{
		if (ptr==findptr) break;
		ptr += ((CTRLHEADER*)(ptr))->length;
	}
	return i==curr_nctrls ? -1 : i ;
}	/* end ctrladdr2i() */

/* find EBDT and MIDI controls linked to by a value .........................*/
/* this assumes the only possible chains are:
	(1) ctrl-->ctrl
	(2) ctrl-->ebdt-->ctrl
	(3) ctrl-->midi-->ctrl
	(4) ctrl-->ebdt-->midi-->ctrl
	(5) ctrl-->midi-->ebdt-->ctrl

	These chains return 0 (good); any other chain returns 1 (error)
*/
findebdtmidi(startlink,link,ebdtctrl,midictrl,ebdtctrli,midictrli)
int startlink;					/* which control this is */
register int link;			/* which control this control is linked to */
CTRL_EBDT **ebdtctrl;		/* output: found EBDT control, 0L if none found */
CTRL_MIDI **midictrl;		/* output: found MIDI control, 0L if none found */
int *ebdtctrli,*midictrli;	/* output: found control #s (-1 if none found) */
{
	register long refptr;
	register int ref_i;
	long ctrli2addr();
	CTRLHEADER *ctrl;
	int error=0;

	*ebdtctrl= (CTRL_EBDT*)(0L);	/* default: nothing found */
	*midictrl= (CTRL_MIDI*)(0L);
	*ebdtctrli= -1;
	*midictrli= -1;

	refptr= heap[curr_mem].start;	/* control 0 is at start of current page */
	ref_i= 0;

	while ((link>=0)&&(link!=startlink))
	{
		refptr= ctrli2addr(link,refptr,ref_i);
		ref_i= link;
		ctrl= (CTRLHEADER*)(refptr);
		switch (ctrl->type)
		{
			case CTYP_EBDT: /* multiple EBDT links overwrite (shouldn't happen) */
			if (*ebdtctrl) error=1;
			*ebdtctrl= (CTRL_EBDT*)(refptr+sizeof(ctrlheader));
			*ebdtctrli=link;
			link= (*ebdtctrl)->linkctrl;
			break;
			
			case CTYP_MIDI: /* multiple MIDI links overwrite (shouldn't happen) */
			if (*midictrl) error=1;
			*midictrl= (CTRL_MIDI*)(refptr+sizeof(ctrlheader));
			*midictrli=link;
			link= (*midictrl)->linkctrl;
			break;
			
			default:			/* shouldn't happen in this version */
			error=1;
			link= -1;
		}	/* end switch (type) */
	}	/* end while threading through link */
	return error;
}	/* end findebdtmidi() */

/* find all ebdt and midi controls linked to a given control ................*/
/* returns # of ebdt and midi controls found */

_findebdtmidi(ctrl_i,type,ptr,link_ptr,link_i,link_link,link_type)
int ctrl_i;				/* control # */
int type;				/* CTYP_xxxx */
long ptr;				/* --> past ctrl header */
long *link_ptr;		/* output: found controls */
int *link_i;			/* output: found control #s */
int *link_link;		/* output: which value the control is linked from */
int *link_type;		/* output: type of each control */
{
	register int i,n,n_link;
	long ebdt,midi;
	int ebdt_i,midi_i;
	int *linkpage[MAXNVALS],*linkctrl[MAXNVALS],*linkval[MAXNVALS];

	n= find_links(type,ptr,linkpage,linkctrl,linkval);
	for (i=n_link=0; i<n; i++)
	{
		findebdtmidi(ctrl_i,*(linkctrl[i]),&ebdt,&midi,&ebdt_i,&midi_i);
		if (ebdt)
		{
			link_ptr[n_link]= ebdt;
			link_link[n_link]= i;
			link_type[n_link]= CTYP_EBDT;
			link_i[n_link++]= ebdt_i;
		}
		if (midi)
		{
			link_ptr[n_link]= midi;
			link_link[n_link]= i;
			link_type[n_link]= CTYP_MIDI;
			link_i[n_link++]= midi_i;
		}
	}
	return n_link;
}	/* end _findebdtmidi() */

/* compress string pool .....................................................*/

clean_pool()
{
	register char *strpool;
	register POOL_INFO *info;
	register long offset;
	register int i;
	POOL_INFO proto;
	int strgmem,page,type,nstr,which;
	long strgleng,n,maxn,pageleng,pageptr,rect,templong;
	CTRLHEADER *ctrl;
	long *str[1];

	/* use tempmem heap (already enlarged) for info structure */
	maxn= heap[tempmem].nbytes/sizeof(proto);
	if (!maxn) return;
	info= (POOL_INFO*)(heap[tempmem].start);

	/* where is string pool and how big is it */
	strgmem= temmem[ seg_to_mem(idTEMSTRG) ] ;
	strpool= (char*)(heap[strgmem].start);
	strgleng= heap[strgmem].nbytes;
	if (!strgleng) return;

	/* scan string pool, build info structure */
	for (offset=n=0; (n<maxn)&&(offset<strgleng); )
	{
		/* find start of string */
		while ( (offset<strgleng) && !strpool[offset] ) offset++;
		if (offset<strgleng)
		{
			info[n].offset= info[n].new= offset;
			info[n++].used=0;
			/* find first byte past end of string */
			while ( (offset<strgleng) && strpool[offset] ) offset++;
			templong= offset+1;	/* where next string might start */
		}
	}
	if (n<1) return;				/* info structure empty -- shouldn't happen */
	if (n>=(maxn-1)) return;	/* info structure overflow */
	info[n].offset=templong;	/* needed for computing string lengths */

	/* scan pages, mark used strings */
	for (page=0; page<NTEMPAGES; page++)
	{
		i= temmem[ seg_to_mem(idTEMPAGE0+page) ] ;
		pageleng= heap[i].nbytes;
		pageptr= heap[i].start;
		while (pageleng>sizeof(ctrlheader))
		{
			ctrl= (CTRLHEADER*)(pageptr);
			type= ctrl->type;
			rect= pageptr + sizeof(ctrlheader);
			nstr= find_strgs(type,rect,-1,0L);
			for (i=0; i<nstr; i++)
			{
				find_strgs(type,rect,i,str);
				mark_used(info,n,*str[0],0,&dummy);
			}
			pageptr += ctrl->length;
			pageleng -= ctrl->length;
		}
	}

	/* compress */
	for (i=offset=0; i<n; i++)
	{
		if (info[i].used)
		{
			templong= (info[i+1].offset-info[i].offset);
			if (info[i].new!=offset)
			{
				info[i].new=offset;
				copy_bytes(strpool+info[i].offset,strpool+offset,templong);
			}
			offset += templong;
		}
	}
	strgleng=offset;

	/* scan all pages replace offsets with new */
	for (page=0; page<NTEMPAGES; page++)
	{
		i= temmem[ seg_to_mem(idTEMPAGE0+page) ] ;
		pageleng= heap[i].nbytes;
		pageptr= heap[i].start;
		while (pageleng>sizeof(ctrlheader))
		{
			ctrl= (CTRLHEADER*)(pageptr);
			type= ctrl->type;
			rect= pageptr + sizeof(ctrlheader);
			nstr= find_strgs(type,rect,-1,0L);
			for (i=0; i<nstr; i++)
			{
				find_strgs(type,rect,i,str);
				if (mark_used(info,n,*str[0],0,&which)) *str[0]= info[which].new;
			}
			pageptr += ctrl->length;
			pageleng -= ctrl->length;
		}
	}
	/* shrink string pool */
	change_mem(strgmem,strgleng);

}	/* end clean_pool() */

mark_used(info,n,strx,n0,which)
POOL_INFO *info;
long n,strx;
int n0;
int *which;	/* found index into info */
{
	long n2;

	if (n==0) return 0;
	if (n==1)
	{
		if (info[0].offset==strx)
		{
			info[0].used=1;
			*which= n0;
			return 1;
		}
		else
			return 0;
	}
	n2= n/2;
	if (info[n2].offset<=strx)
		return mark_used(info+n2,n-n2,strx,(int)(n0+n2),which);
	else
		return mark_used(info,n2,strx,n0,which);

}	/* end mark_used() */

/* append to string pool ....................................................*/
/* returns 1= ok, 0= overrun (some strings may be lost) */

append_strgs(ctrl_i,mem,type,n,ed_midi)
int ctrl_i;		/* which control has strings (it must have strings) */
int mem;			/* which heap has source strings */
int type;		/* type of control: midi or non-midi */
int n;			/* how many strings */
CTRL_MIDI *ed_midi;
{
	register char *strpool,*ed_str;
	register long maxstrgleng,strgleng;
	register int i,thisleng;
	long *str[1];
	long ptr,oldstr,ctrli2addr();
	int result,strgmem;

	if (!n) return 1;	/* no strings; no update */

	/* how big string pool? */
	strgmem= temmem[ seg_to_mem(idTEMSTRG) ] ;
	strgleng= heap[strgmem].nbytes;

	/* shrink current page, expand string pool */
	change_mem(curr_mem,curr_leng);
	fill_mem(strgmem);

	/* where is string pool, how big can it get */
	strpool= (char*)(heap[strgmem].start);
	maxstrgleng= heap[strgmem].nbytes;

	/* where is the control (past header) */
	if (type!=CTYP_MIDI)
		ptr= ctrli2addr(ctrl_i,heap[curr_mem].start,0) + sizeof(ctrlheader) ;

	/* where are the strings we're copying from */
	ed_str= (char*)(heap[mem].start);

	result=1;
	for (i=0; i<n; i++)
	{
		if (type==CTYP_MIDI)
			str[0]= &(ed_midi[i].str);
		else
			find_strgs(type,ptr,i,str);
		oldstr= *str[0];
		/* find start of next string */
		while ( !(*ed_str) ) ed_str++;
		thisleng= strlen(ed_str)+1;							/* includes null */
		if (ed_str[0]>0)	/* non-null string */
		{
			if ( (oldstr<0L) || (strcmp(strpool+oldstr,ed_str)) )
			{
				if ( (thisleng+strgleng) > maxstrgleng )	/* overflow */
				{
					result=0;
					*str[0]= -1L;
				}
				else
				{
					*str[0]= strgleng;
					strcpy(strpool+strgleng,ed_str);
					strgleng += thisleng ;
				}
			}
		}
		else
			*str[0]= -1L;
		ed_str += thisleng ;
	}

	/* shrink string pool, expand current page */
	change_mem(strgmem,strgleng);
	fill_mem(curr_mem);
	return result;

}	/* end append_strgs() */

/* control has already been copied, now copy its links */
/* copies to end of destination page */
/* can copy between pages! */
/* assumes destination won't overflow */
/* returns total size of linked controls that were copied */

long copy_links(from_ptr,old_ctrl_i,to_ptr,dest_nctrls,dest_page,n_newlinks)
long from_ptr;			/* --> old control (ctrlheader) */
int old_ctrl_i;		/* old control number */
long to_ptr;			/* --> new control (ctrlheader) */
int dest_nctrls;		/* how many controls on destination page (including
                        control that was just copied) */
int dest_page;			/* destination page # */
int *n_newlinks;		/* output: how many linked controls were copied */
{
	int nlinks,new_ctrl_i;
	CTRLHEADER *ctrl;
	register int i;
	int *linkpage[MAXNVALS],*linkctrl[MAXNVALS],*linkval[MAXNVALS];
	CTRL_EBDT *ebdtctrl;
	CTRL_MIDI *midictrl;
	long ebdtleng,midileng,linkleng;

	new_ctrl_i= dest_nctrls-1;

	/* get pointers to link fields in new control */
	ctrl= (CTRLHEADER*)(to_ptr);
	nlinks= find_links(ctrl->type,to_ptr+sizeof(*ctrl),
								linkpage,linkctrl,linkval);

	/* size of EBDT and MIDI controls, including control header */
	ebdtleng= sizeof(*ctrl) + sizeof(*ebdtctrl);
	midileng= sizeof(*ctrl) + sizeof(*midictrl);

	*n_newlinks= 0;
	linkleng=0L;
	ctrl= (CTRLHEADER*)(to_ptr);
	to_ptr += ctrl->length;

	for (i=0; i<nlinks; i++)
	{
		findebdtmidi(old_ctrl_i,*(linkctrl[i]),
							&ebdtctrl,&midictrl,&dummy,&dummy);

		/* if no ebdt or midi controls, link this control to itself */
		if ( !ebdtctrl && !midictrl )
			*(linkctrl[i])= new_ctrl_i;

		if (ebdtctrl)
		{
			(*n_newlinks)++;
			linkleng+=ebdtleng;
			ctrl= (CTRLHEADER*)( (long)(ebdtctrl) - sizeof(*ctrl) );
			copy_bytes(ctrl,to_ptr,ebdtleng);
			ebdtctrl= (CTRL_EBDT*)(to_ptr+sizeof(*ctrl));
			to_ptr += ebdtleng;
			dest_nctrls++;
			*(linkctrl[i])= dest_nctrls-1;
			ebdtctrl->linkctrl= new_ctrl_i;
			ebdtctrl->linkpage= dest_page;
		}
		if (midictrl)
		{
			(*n_newlinks)++;
			linkleng+=midileng;
			ctrl= (CTRLHEADER*)( (long)(midictrl) - sizeof(*ctrl) );
			copy_bytes(ctrl,to_ptr,midileng);
			midictrl= (CTRL_MIDI*)(to_ptr+sizeof(*ctrl));
			to_ptr += midileng;
			dest_nctrls++;
			midictrl->linkpage= dest_page;
			if (ebdtctrl)
			{
				midictrl->linkctrl= ebdtctrl->linkctrl;
				ebdtctrl->linkctrl= dest_nctrls-1;
			}
			else
			{
				*(linkctrl[i])= dest_nctrls-1;
				midictrl->linkctrl= new_ctrl_i;
			}
		}
	}
	return linkleng;
}	/* end copy_links() */
				
#endif

/* EOF */
