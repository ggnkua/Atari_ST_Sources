/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module TEMEDIT : low level template editing

	edit_ctrl
	edctrlline, edctrlrect, edctrltext, edctrlnumb, edctrlknfd,
	edctrlxbut, edctrlgrph, edctrljoy
	val_to_ed, edit_value, editstrged

******************************************************************************/

overlay "temedit"

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
extern XXVAL_INFO xxval_info;
extern int curr_page,curr_mem,strgedmem,midistrgmem,valedmem,ed_mem;
extern long curr_leng;
extern int curr_nctrl,curr_nvctrl;

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

#if TEMFLAG

/* local globals ............................................................*/

extern edctrlline(),edctrlrect(),edctrltext(),edctrlnumb(),edctrlknfd();
extern edctrlxbut(),edctrlgrph(),edctrljoy();
long edctrlfunc[12]= {	/* edit function jump table */
	(long)(&edctrlline),
	(long)(&edctrlrect),
	0L,	/* unused */
	(long)(&edctrltext),
	(long)(&edctrlnumb),
	(long)(&edctrlknfd),
	0L,	/* unused */
	(long)(&edctrlknfd),
	(long)(&edctrlxbut),
	(long)(&edctrlxbut),
	(long)(&edctrlgrph),
	(long)(&edctrljoy ),
};

/* value edit buffer contains maximum number of val_info's for
	the type of control being edited.  The buffer is divided into 3 parts:
	val_info's, ebdt controls (1 for each val_info), midi controls (1 for
	each val_info) */
int n_ed_val;					/* how many val_info's in value edit buffer */
VAL_INFO *ed_val;
CTRL_EBDT *ed_ebdt;
CTRL_MIDI *ed_midi;

/* control edit buffer contains copy of control being edited, without header */
int ed_type;					/* what type of control is being edited */
int ed_ctrl_i;					/* control # being edited */
int ed_leng;					/* bytes in control being edited, without header */

/* string edit buffer contains null-padded null-term'd strings */
STR256 *ed_strg;
int n_ed_strg;

/* midi string edit buffer contains null-padded null-term'd strings */
STR256 *ed_mstrg;

/* init'd val_info */
VAL_INFO initvalinfo= {
	0,0,100,		/* val, low, high */
	0,				/* invert */
	-1,-1,-1		/* linkpage,linkctrl,linkval */
};
/* init'd EBDT control */
CTRL_EBDT initebdtctrl= {
	-1,				/* index */
	-1,-1,-1,		/* linkpage,linkctrl,linkval */
	0					/* undo */
};
/* init'd MIDI control */
CTRL_MIDI initmidictrl= {
	0,127,1,			/* low, high, delta */
	-1,-1,-1,		/* linkpage,linkctrl,linkval */
	-1L				/* str */
};
/* init'd PT_INFO */
PT_INFO initpt_info= {
	PTFOLLOW,100,0,	/* xmode, xfactor, xline */
	PTFULL,100,0,		/* ymode, yfactor, yline */
	1,0					/* active, rfu */
};

/* edit a control on current page ...........................................*/

edit_ctrl(ptr,ctrl_i)
long ptr;	/* --> control header */
int ctrl_i;	/* control number */
{
	int x1,y1,x2,y2;
	int x1b,y1b,x2b,y2b;
	int result;
	CTRLHEADER *ctrl;
	long templong;
	register int i;
	CTRL_EBDT *ebdt;
	int link_i[MAXNVALS];
	long ctrli2addr();

	/* get basic info about the control we're editing */
	ed_ctrl_i= ctrl_i;						/* which control it is */
	ctrl= (CTRLHEADER*)(ptr);				/* --> control header */
	ed_type= ctrl->type;						/* what type of control it is */
	ed_leng= ctrl->length - sizeof(ctrlheader) ;	/* how big it is */

	/* invisible control can't be edited (this shouldn't happen) */
	if (ed_type<0) return;

	ptr += sizeof(ctrlheader);				/* --> rect */

	/* unedited screen domain */
	rect2scr(ptr,&x1,&x2,&y1,&y2);

	/* copy control-to-be-edited to control edit buffer */
	if (ed_leng>MAXEDLENG)
	{
		form_alert(1,BADEDLENG);
		return;
	}
	copy_bytes(ptr,heap[ed_mem].start,(long)ed_leng);
	set_clip(tem_x,tem_y,tem_w,tem_h);
	xor_rect(x1,y1,x2-x1+1,y2-y1+1);

	/* edit functions can't play with heap, because ctrl must remain valid */
	asm {
		move.w	ed_type(a4),d0
		lsl.w		#2,d0						; index into jump table
		lea		edctrlfunc(a4),a0
		move.l	0(a0,d0),a0
		jsr		(a0)
		move.w	d0,result(a6)
	}
	set_clip(tem_x,tem_y,tem_w,tem_h);
	xor_rect(x1,y1,x2-x1+1,y2-y1+1);
	if (!result) return;	/* cancelled */

	result=0;					/* default: editing failed */
	graf_mouse(BEE_MOUSE);	/* this might take a while */

	/* delete old control and all controls it is linked to */
	_del_ctrl(ctrl,ctrl_i);
	/* find where old control was (may have moved, because deleted linked-to
		controls may have been before ctrl_i */
	ctrl_i= min(ctrl_i,curr_nctrl);
	ptr= ctrl_i==curr_nctrl ? heap[curr_mem].start+curr_leng :
									  ctrli2addr(ctrl_i,heap[curr_mem].start,0);

	/* put new control in same place as old */
	ctrlheader.type= ed_type;
	ctrlheader.length= ed_leng + sizeof(ctrlheader);
	if (!insert_ctrl(&ctrlheader,heap[ed_mem].start,ed_leng,ptr))
		goto editctrlexit;
	curr_nctrl++;
	curr_nvctrl++;

	/* init links */
	adjust_ctrl(ptr,0,curr_page,-1);
	adjust_page(heap[curr_mem].start,curr_leng,4,ctrl_i,dummy);
	adjust_ctrl(ptr,0,curr_page,ctrl_i);

	/* append strings to string pool / update indexes inside edited control */
	if (!append_strgs(ctrl_i,strgedmem,ed_type,n_ed_strg,ed_midi))
		form_alert(1,BADAPPSTRG);

	/* append midi strings to string pool / update indexes inside edit buffer */
	if (!append_strgs(dummy,midistrgmem,CTYP_MIDI,n_ed_val,ed_midi))
		form_alert(1,BADAPPSTRG);

	/* heaps may have moved, so find edited control */
	ptr= ctrli2addr(ctrl_i,heap[curr_mem].start,0);

	/* control may have new minimum size */
	clip_ctrl(ed_type,ptr+sizeof(ctrlheader));
	rect2scr(ptr+sizeof(ctrlheader),&x1b,&x2b,&y1b,&y2b);
	x1= min(x1,x1b);
	y1= min(y1,y1b);
	x2= max(x2,x2b);
	y2= max(y2,y2b);

	result=1;		/* editing has at least partially succeeded */

	/* do ebdt and midi control(s) fit? */
	templong= 0L;
	for (i=0; i<n_ed_val; i++)
	{
		if (ed_ebdt[i].index>=0)
			templong += (sizeof(initebdtctrl)+sizeof(ctrlheader));
		if (ed_midi[i].str>=0L)
			templong += (sizeof(initmidictrl)+sizeof(ctrlheader));
	}
	if ( (templong+curr_leng) > heap[curr_mem].nbytes )
	{
		form_alert(1,BADMEM2);
		goto editctrlexit;
	}

	/* append ebdt control(s) */
	ctrlheader.type= CTYP_EBDT;
	ctrlheader.length= sizeof(initebdtctrl) + sizeof(ctrlheader) ;
	for (i=0; i<n_ed_val; i++)
	{
		link_i[i]= ctrl_i;
		if (ed_ebdt[i].index>=0)
		{
			/* ebdt control linked back to visible control */
			ed_ebdt[i].linkpage= curr_page;
			ed_ebdt[i].linkctrl= ctrl_i;
			ed_ebdt[i].linkval= i;
			/* visible control linked forward to ebdt control */
			adjust_ctrl(ptr,3,i,link_i[i]=curr_nctrl);
			insert_ctrl(&ctrlheader,ed_ebdt+i,sizeof(initebdtctrl),-1L);
			curr_nctrl++;
		}
	}

	/* append midi control(s) */
	ctrlheader.type= CTYP_MIDI;
	ctrlheader.length= sizeof(initmidictrl) + sizeof(ctrlheader) ;
	for (i=0; i<n_ed_val; i++)
	{
		if (ed_midi[i].str>=0L)
		{
			ed_midi[i].linkpage= curr_page;
			ed_midi[i].linkctrl= link_i[i];
			ed_midi[i].linkval= i;
			adjust_ctrl(ptr,3,i,curr_nctrl);
			insert_ctrl(&ctrlheader,ed_midi+i,sizeof(initmidictrl),-1L);
			curr_nctrl++;
		}
	}

editctrlexit:
	graf_mouse(ARROWMOUSE);
	if (result)
	{
		draw_tem(x1,y1,x2,y2);
		change_flag[temCHANGE]= 1;
	}
}	/* end edit_ctrl() */

/* edit a line control ......................................................*/
/* returns 1= ok, 0= cancel */

edctrlline()
{
	register int i;
	register CTRL_LINE *ptr;
	static int fixed;

	/* run-time resource modification */
	if (!fixed&&(rez==1))
	{
		fix_icons(lineaddr);
		fixed=1;
	}

	ptr= (CTRL_LINE*)(heap[ed_mem].start);

	/* encode into dialog box */
	i= ptr->style == 0xFFFF ? 0 : 1 ;
	set_rbutton(lineaddr,LINESTL0,2,i);
	i= min((ptr->rect).color,3);
	set_rbutton(lineaddr,LINECLR0,4,i);

	if (do_dial(lineaddr,-1)==CANLINE) return 0;

	/* decode out of dialog box */
	i= whichbutton(lineaddr,LINESTL0,2);
	ptr->style= i==0 ? 0xFFFF : 0xAAAA ;
	(ptr->rect).color= whichbutton(lineaddr,LINECLR0,4);

	n_ed_val= n_ed_strg= 0;
	return 1;

}	/* end edctrlline() */

/* edit a rectangle control .................................................*/
/* returns 1= ok, 0= cancel */

edctrlrect()
{
	register int i;
	register CTRL_RECT *ptr;
	int fill,fillx,filly,fillw,fillh;
	int done,mstate,edit_obj,exit_obj;

	ptr= (CTRL_RECT*)(heap[ed_mem].start);

	/* encode into dialog box */
	fill= ptr->fill;
	if (fill>MAXRECTFILL) fill=0;
	i= min((ptr->rect).color,3);
	set_rbutton(rectaddr,RECTCLR0,4,i);

	putdial(rectaddr,1,0);
	objc_offset(rectaddr,RECTFILL,&fillx,&filly);
	fillw= rectaddr[RECTFILL].ob_width;
	fillh= rectaddr[RECTFILL].ob_height;
	fill_rect(fillx,filly,fillw,fillh,fill);

	done=0;
	edit_obj= -1;
	do
	{
		switch( exit_obj=my_form_do(rectaddr,&edit_obj,&mstate,0,&dummy) )
		{
			case 1:
			slide_dial(rectaddr);
			objc_offset(rectaddr,RECTFILL,&fillx,&filly);
			fill_rect(fillx,filly,fillw,fillh,fill);
			break;

			case OKRECT:
			case CANRECT: done=1; break;

			case RECTFILL:
			fill += mstate;
			if (fill<0) fill=MAXRECTFILL;
			if (fill>MAXRECTFILL) fill=0;
			fill_rect(fillx,filly,fillw,fillh,fill);
         waitmouse();

		}	/* end switch (exit_obj) */
	}
	while (!done);
	putdial(0L,0,exit_obj);
	if (exit_obj==CANRECT) return 0;

	/* decode out of dialog box */
	ptr->fill= fill;
	(ptr->rect).color= whichbutton(rectaddr,RECTCLR0,4);

	n_ed_val= n_ed_strg= 0;
	return 1;

}	/* end edctrlrect() */

/* edit a text control ......................................................*/
/* returns 1= ok, 0= cancel */

edctrltext()
{
	register int i,j;
	register CTRL_TEXT *ptr;
	char *strpool,*strptr;
	int exit_obj,done;
	int nstrings,maxnstrings,thisleng;
	long strgedleng,strx;

	ptr= (CTRL_TEXT*)(heap[ed_mem].start);

	/* how many string indexes, how many can fit in control edit buffer */
	nstrings= (ed_leng - sizeof(ctrl_text))/4 + 1 ;
	maxnstrings= (MAXEDLENG - sizeof(ctrl_text))/4 + 1 ;
	maxnstrings= min(maxnstrings,1000); /* editstrged() can't handle > 1000 */
	if (nstrings>maxnstrings)
	{
		form_alert(1,BADEDLENG);
		return 0;
	}

	/* encode into value edit buffer, but not into string edit buffer */
	val_to_ed(ed_ctrl_i,&(ptr->val),0L,0L,1,1,&(ptr->str[0]),0,0);

	/* encode into string edit buffer: strings are null-term'd and
		concatenated, strings are variable length instead of 256 */
	strptr= (char*)(heap[strgedmem].start);
	strgedleng= heap[strgedmem].nbytes;
	set_words(strptr,strgedleng/2,0);
	strpool= (char*)( heap[ temmem[ seg_to_mem(idTEMSTRG) ] ].start );
	for (i=j=0; i<nstrings; i++)
	{
		strx= ptr->str[i];
		if (strx<0L)
		{
			if ( (j+2) > strgedleng ) break;
			strptr[j++]= -1;
			strptr[j++]= 0;
		}
		else
		{
			thisleng= strlen(strpool+strx)+1;	/* include null term */
			if ( (j+thisleng) > strgedleng ) break;
			strcpy(strptr+j,strpool+strx);
			j += thisleng ;
		}
	}
	if (i<nstrings)
	{
		form_alert(1,BADEDLENG);
		return 0;
	}
	for (; i<maxnstrings; i++) ptr->str[i]= -1L;

	/* encode into dialog box */
	strcpy(((TEDINFO*)(numbaddr[NUMBTITL].ob_spec))->te_ptext,TEXT_MSG);
	set_rbutton(numbaddr,NUMBFNT0,2,ptr->font);
	i= min((ptr->rect).color,3);
	set_rbutton(numbaddr,NUMBCLR0,4,i);
	sel_obj( ((ptr->rect).options)&OUTPUT_BIT, numbaddr, NUMBOUTP);
	sel_obj( ((ptr->rect).options)&VALIDT_BIT, numbaddr, NUMBVLDT);

	numbaddr[NUMBTEXT].ob_flags &= ~HIDETREE;

	done=0;
	do
	{
		switch (exit_obj= do_movedial(numbaddr,-1,0))
		{
			case CANNUMB:
			case OKNUMB:	done=1; break;
			case NUMBVAL:	edit_value(TEXT_MSG,0,0,-1); break;
			case NUMBTEXT: nstrings= editstrged(nstrings,maxnstrings);
		}
	}
	while (!done);
	if (exit_obj==CANNUMB) return 0;

	/* decode out of dialog box */
	ptr->font= whichbutton(numbaddr,NUMBFNT0,2);
	(ptr->rect).color= whichbutton(numbaddr,NUMBCLR0,4);
	if (is_obj_sel(numbaddr,NUMBOUTP))
		(ptr->rect).options |= OUTPUT_BIT;
	else
		(ptr->rect).options &= ~OUTPUT_BIT;
	if (is_obj_sel(numbaddr,NUMBVLDT))
		(ptr->rect).options |= VALIDT_BIT;
	else
		(ptr->rect).options &= ~VALIDT_BIT;

	/* decode out of value edit buffer */
	ed_val[0].val= ed_val[0].low= 0;
	ed_val[0].high= nstrings-1;
	ptr->val= ed_val[0];
	ed_leng= sizeof(ctrl_text) + 4L*(nstrings-1);
	n_ed_val= 1;
	n_ed_strg= nstrings;
	return 1;

}	/* end edctrltext() */

/* edit a number control ....................................................*/
/* returns 1= ok, 0= cancel */

edctrlnumb()
{
	register int i;
	register CTRL_NUMB *ptr;
	int exit_obj;

	ptr= (CTRL_NUMB*)(heap[ed_mem].start);

	/* encode into value edit buffer */
	val_to_ed(ed_ctrl_i,&(ptr->val),0L,0L,1,1,0L,0,0);

	/* encode into dialog box */
	strcpy(((TEDINFO*)(numbaddr[NUMBTITL].ob_spec))->te_ptext,NUMBER_MSG);
	set_rbutton(numbaddr,NUMBFNT0,2,ptr->font);
	i= min((ptr->rect).color,3);
	set_rbutton(numbaddr,NUMBCLR0,4,i);
	sel_obj( ((ptr->rect).options)&OUTPUT_BIT, numbaddr, NUMBOUTP);
	sel_obj( ((ptr->rect).options)&VALIDT_BIT, numbaddr, NUMBVLDT);

	numbaddr[NUMBTEXT].ob_flags |= HIDETREE;

	do
	{
		exit_obj= do_movedial(numbaddr,-1,0);
		if (exit_obj==NUMBVAL) edit_value(NUMBER_MSG,1,0,-1);
	}
	while (exit_obj==NUMBVAL);
	if (exit_obj==CANNUMB) return 0;

	/* decode out of dialog box */
	ptr->font= whichbutton(numbaddr,NUMBFNT0,2);
	(ptr->rect).color= whichbutton(numbaddr,NUMBCLR0,4);
	if (is_obj_sel(numbaddr,NUMBOUTP))
		(ptr->rect).options |= OUTPUT_BIT;
	else
		(ptr->rect).options &= ~OUTPUT_BIT;
	if (is_obj_sel(numbaddr,NUMBVLDT))
		(ptr->rect).options |= VALIDT_BIT;
	else
		(ptr->rect).options &= ~VALIDT_BIT;

	/* decode out of value edit buffer */
	ptr->val= ed_val[0];
	n_ed_val=1;
	n_ed_strg=0;
	return 1;

}	/* end edctrlnumb() */

/* edit a knob or slider control ............................................*/
/* returns 1= ok, 0= cancel */

edctrlknfd()
{
	char *titl_ptr;
	register int i;
	register CTRL_SLID *ptr;
	int exit_obj;

	ptr= (CTRL_SLID*)(heap[ed_mem].start);

	/* encode into value edit buffer */
	val_to_ed(ed_ctrl_i,&(ptr->val),0L,0L,1,1,0L,0,0);

	/* encode into dialog box */
	titl_ptr= ((TEDINFO*)(knfdaddr[KNFDTITL].ob_spec))->te_ptext;
	strcpy(titl_ptr,ed_type==CTYP_KNOB ? KNOB_MSG : SLIDER_MSG);
	i= min((ptr->rect).color,3);
	set_rbutton(knfdaddr,KNFDCLR0,4,i);
	sel_obj( ((ptr->rect).options)&OUTPUT_BIT, knfdaddr, KNFDOUTP);
	sel_obj( ((ptr->rect).options)&VALIDT_BIT, knfdaddr, KNFDVLDT);

	do
	{
		exit_obj= do_movedial(knfdaddr,-1,0);
		if (exit_obj==KNFDVAL) edit_value(titl_ptr,1,0,-1);
	}
	while (exit_obj==KNFDVAL);
	if (exit_obj==CANKNFD) return 0;

	/* decode out of dialog box */
	(ptr->rect).color= whichbutton(knfdaddr,KNFDCLR0,4);
	if (is_obj_sel(knfdaddr,KNFDOUTP))
		(ptr->rect).options |= OUTPUT_BIT;
	else
		(ptr->rect).options &= ~OUTPUT_BIT;
	if (is_obj_sel(knfdaddr,KNFDVLDT))
		(ptr->rect).options |= VALIDT_BIT;
	else
		(ptr->rect).options &= ~VALIDT_BIT;

	/* decode out of value edit buffer */
	ptr->val= ed_val[0];
	n_ed_val=1;
	n_ed_strg=0;
	return 1;

}	/* end edctrlknfd() */

/* edit an independent or combined button set control .......................*/
/* returns 1= ok, 0= cancel */

edctrlxbut()
{
	CTRL_CBUT *cbut;
	CTRL_IBUT *ibut;
	char *titl_ptr,*nrow_ptr,*ncol_ptr,*flag_ptr;
	register int i,j;
	int exit_obj,edit_obj,done,mstate;
	static char *flag_msg[2]= { MOMENTMSG, MINBUT1MSG };
	int xbut[MAXNBUTROW*MAXNBUTCOL];
	int ybut[MAXNBUTROW*MAXNBUTCOL];
	int wbut[MAXNBUTROW*MAXNBUTCOL];
	int hbut[MAXNBUTROW*MAXNBUTCOL];
	int x,y,row_i,col_i;
	char valtitle[80],ibuf[3];
	int which_val,which_str;
	char valindex[MAXNBUTROW][MAXNBUTCOL];
	int sortarray[MAXNBUTROW*MAXNBUTCOL];

	/* CTRL_CBUT and CTRL_IBUT identical up til val_info stuff */
	cbut= (CTRL_CBUT*)(heap[ed_mem].start);
	ibut= (CTRL_IBUT*)(heap[ed_mem].start);

	/* encode into value/string edit buffers */
	i= cbut->nrows * cbut->ncols ;
	if (ed_type==CTYP_IBUT)
		val_to_ed(ed_ctrl_i,0L,&(ibut->xval[0]),0L,i,MAXNBUTROW*MAXNBUTCOL,
			0L,i,MAXNBUTROW*MAXNBUTCOL);
	else
		val_to_ed(ed_ctrl_i,&(cbut->val),0L,0L,1,1,
			&(cbut->str[0]),i,MAXNBUTROW*MAXNBUTCOL);

	/* map edit buffer linear array into buttons 2-d array */
	for (row_i=j=0; row_i<MAXNBUTROW; row_i++)
		for (col_i=0; col_i<MAXNBUTCOL; col_i++)
			valindex[row_i][col_i]= (row_i<(cbut->nrows))&&(col_i<(cbut->ncols)) ?
				j++ : i++ ;

	/* encode into dialog box */
	titl_ptr= ((TEDINFO*)(butnaddr[BUTNTITL].ob_spec))->te_ptext;
	nrow_ptr= butnaddr[BUTNNROW].ob_spec;
	ncol_ptr= butnaddr[BUTNNCOL].ob_spec;
	flag_ptr= butnaddr[BUTNFLAG].ob_spec;
	strcpy(titl_ptr,ed_type==CTYP_IBUT ? IBUT_MSG : CBUT_MSG);
	set_rbutton(butnaddr,BUTNFNT0,2,cbut->font);
	i= min((cbut->rect).color,3);
	set_rbutton(butnaddr,BUTNCLR0,4,i);
	sel_obj( ((cbut->rect).options)&OUTPUT_BIT, butnaddr, BUTNOUTP);
	sel_obj( ((cbut->rect).options)&VALIDT_BIT, butnaddr, BUTNVLDT);
	sel_obj(cbut->flag,butnaddr,BUTNFLAG);
	itoa(cbut->nrows,nrow_ptr,1);
	itoa(cbut->ncols,ncol_ptr,1);
	strcpy(flag_ptr,flag_msg[(cbut->nrows*cbut->ncols)>1]);

	putdial(butnaddr,1,0);
	drawxbutarea(cbut->nrows,cbut->ncols,xbut,ybut,wbut,hbut,valindex);

	done=0;
	edit_obj= -1;
	do
	{
		switch( exit_obj=my_form_do(butnaddr,&edit_obj,&mstate,0,&dummy) )
		{
			case 1:
			slide_dial(butnaddr);
			drawxbutarea(cbut->nrows,cbut->ncols,xbut,ybut,wbut,hbut,valindex);
			break;

			case OKBUTN:
			case CANBUTN: done=1; break;

			case BUTNAREA:
			getmouse(&x,&y);
			for (i=(cbut->nrows*cbut->ncols)-1; i>=0; i--)
				if (in_rect(x,y,xbut[i],ybut[i],wbut[i],hbut[i])) break;
			if (i>=0)
			{
				strcpy(valtitle,titl_ptr);
				row_i= i / cbut->ncols;
				col_i= i % cbut->ncols;
				if (ed_type==CTYP_IBUT)
				{
					strcat(valtitle,": ");
					strcat(valtitle,ROW_MSG);
					itoa(row_i+1,ibuf,2);
					strcat(valtitle,ibuf);
					strcat(valtitle,COL_MSG);
					itoa(col_i+1,ibuf,2);
					strcat(valtitle,ibuf);
					strcat(valtitle," ");
				}
				which_str= valindex[row_i][col_i];
				which_val= ed_type==CTYP_IBUT ? which_str : 0 ;
				putdial(0L,0,exit_obj);
				edit_value(valtitle,ed_type==CTYP_IBUT,which_val,which_str);
				putdial(butnaddr,1,0);
				drawxbutarea(cbut->nrows,cbut->ncols,xbut,ybut,wbut,hbut,valindex);
			}
			break;

			case BUTNNROW:
			i= cbut->nrows + mstate;
			if (i>MAXNBUTROW) i=1;
			if (i<1) i=MAXNBUTROW;
			cbut->nrows= i;
			itoa(i,nrow_ptr,1);
			strcpy(flag_ptr,flag_msg[(i*cbut->ncols)>1]);
			draw_object(butnaddr,BUTNNROW);
			draw_object(butnaddr,BUTNAREA);
			drawxbutarea(i,cbut->ncols,xbut,ybut,wbut,hbut,valindex);
			draw_object(butnaddr,BUTNFLAG);
			break;

			case BUTNNCOL:
			i= cbut->ncols + mstate;
			if (i>MAXNBUTCOL) i=1;
			if (i<1) i=MAXNBUTCOL;
			cbut->ncols= i;
			itoa(i,ncol_ptr,1);
			strcpy(flag_ptr,flag_msg[(i*cbut->nrows)>1]);
			draw_object(butnaddr,BUTNNCOL);
			draw_object(butnaddr,BUTNAREA);
			drawxbutarea(cbut->nrows,i,xbut,ybut,wbut,hbut,valindex);
			draw_object(butnaddr,BUTNFLAG);

		}	/* end switch (exit_obj) */
	}
	while (!done);
	putdial(0L,0,exit_obj);
	if (exit_obj==CANBUTN) return 0;

	/* decode out of dialog box */
	(cbut->rect).color= whichbutton(butnaddr,BUTNCLR0,4);
	if (is_obj_sel(butnaddr,BUTNOUTP))
		(cbut->rect).options |= OUTPUT_BIT;
	else
		(cbut->rect).options &= ~OUTPUT_BIT;
	if (is_obj_sel(butnaddr,BUTNVLDT))
		(cbut->rect).options |= VALIDT_BIT;
	else
		(cbut->rect).options &= ~VALIDT_BIT;

	cbut->font= whichbutton(butnaddr,BUTNFNT0,2);
	cbut->flag= is_obj_sel(butnaddr,BUTNFLAG);
	i= cbut->nrows * cbut->ncols ;
	if (ed_type==CTYP_CBUT)
	{
		ed_leng= sizeof(ctrl_cbut) + 4L*(i-1);
		/* enforce "1 must be set" flag */
		ed_val[0].low= cbut->flag && (i>1) ;
		ed_val[0].high= i; 
		ed_val[0].val= ed_val[0].low;
		cbut->val= ed_val[0];
	}
	else
	{
		ed_leng= sizeof(ctrl_ibut) + (i-1)*sizeof(xval_info);
		for (row_i=j=0; row_i<(ibut->nrows); row_i++)
		{
			for (col_i=0; col_i<(ibut->ncols); col_i++,j++)
			{
				x= valindex[row_i][col_i];
				copy_bytes(&ed_val[x],&(ibut->xval[j]),(long)sizeof(val_info));
			}
		}

		/* clear all buttons */
		asm { move.w i,-(a7) }
		for (i--; i>=0; i--)
			(ibut->xval[i]).val.val= (ibut->xval[i]).val.low;
		asm { move.w (a7)+,i }

		/* enforce "1 must be set" flag */
		if ( ibut->flag && (i>1) )
			(ibut->xval[0]).val.val= (ibut->xval[0]).val.high;

	}
	/* sort ed_ebdt, ed_midi, ed_strg */
	for (row_i=j=0; row_i<MAXNBUTROW; row_i++)
		for (col_i=0; col_i<MAXNBUTCOL; col_i++)
			sortarray[ valindex[row_i][col_i] ]=
				(row_i<(cbut->nrows))&&(col_i<(cbut->ncols)) ? j++ : 32767 ;
	n_ed_strg= cbut->nrows * cbut->ncols ;
	if (ed_type==CTYP_IBUT)
	{
		sort_xbut(sortarray,1,1,1);
		n_ed_val= n_ed_strg;
	}
	else
	{
		sort_xbut(sortarray,0,0,1);
		n_ed_val= 1;
	}
	return 1;

}	/* end edctrlxbut() */

sort_xbut(sort,ebdt,midi,strg)
int *sort;
int ebdt,midi,strg;
{
	register int i;
	int temp;
	CTRL_EBDT tempebdt;
	CTRL_MIDI tempmidi;
	STR256 tempstrg;

	for (i=0; i<(MAXNBUTROW*MAXNBUTCOL-1); )
	{
		if ( sort[i] > sort[i+1] )
		{
			temp= sort[i];		sort[i]= sort[i+1];		sort[i+1]= temp;
			if (ebdt)
			{
				tempebdt= ed_ebdt[i];
				ed_ebdt[i]= ed_ebdt[i+1];
				ed_ebdt[i+1]= tempebdt;
			}
			if (midi)
			{
				tempmidi= ed_midi[i];
				ed_midi[i]= ed_midi[i+1];
				ed_midi[i+1]= tempmidi;
				tempstrg= ed_mstrg[i];
				ed_mstrg[i]= ed_mstrg[i+1];
				ed_mstrg[i+1]= tempstrg;
			}
			if (strg)
			{
				tempstrg= ed_strg[i];
				ed_strg[i]= ed_strg[i+1];
				ed_strg[i+1]= tempstrg;
			}
			i=0;
		}
		else
			i++;
	}
}	/* end sortebdtmidi() */

drawxbutarea(nrows,ncols,xbut,ybut,wbut,hbut,valindex)
int nrows,ncols;
int *xbut,*ybut,*wbut,*hbut;	/* output */
char valindex[MAXNBUTROW][MAXNBUTCOL];
{
	int x,y;
	register int i,j,but;
	char *str;
	int xb,yb;

	objc_offset(butnaddr,BUTNAREA,&x,&y);
	set_clip(0,0,640,200*rez);	/* because buttons might be partly off screen */
	HIDEMOUSE;
	calc_xbut(x+2,y+2,
				 butnaddr[BUTNAREA].ob_width-2,butnaddr[BUTNAREA].ob_height-2,
				 nrows,ncols,xbut,ybut,wbut,hbut);
	draw_xbut(nrows,ncols,xbut,ybut,wbut,hbut);
	/* show text */
	vst_alignment(gl_hand,0,5,&dummy,&dummy);	/* top alignment */
	for (i=but=0; i<nrows; i++)
	{
		for (j=0; j<ncols; j++,but++)
		{
			str= (char*)( ed_strg + valindex[i][j] );
			if (str[0]>0)
			{
				xb= xbut[but];
				yb= ybut[but];
				set_clip(xb,yb,wbut[but],hbut[but]);
				center_text(str,xb,yb,wbut[but],hbut[but]);
			}
		}
	}
	vst_alignment(gl_hand,0,0,&dummy,&dummy);	/* bottom alignment */
	vs_clip(gl_hand,0,0L);
	SHOWMOUSE;

}	/* end drawxbutarea() */

/* edit a graph control .....................................................*/
/* returns 1= ok, 0= cancel */

edctrlgrph()
{
	register CTRL_GRPH *ptr;
	register int i,temp;
	int exit_obj,edit_obj,done,mstate;
	int color,xaxis,yaxis,npoints;
	int which_pt;
	PT_INFO pt_info[MAXNPOINTS];
	char *xaxisptr,*nptsptr,*yaxisptr;
	char val_title[60];

	ptr= (CTRL_GRPH*)(heap[ed_mem].start);
	npoints= ptr->npoints;

	val_to_ed(ed_ctrl_i,0L,0L,&(ptr->xxval[0]),2*npoints,2*MAXNPOINTS,0L,0,0);

	/* encode non-pt info into dialog box -- */
	/* -- color */
	i= min((ptr->rect).color,3);
	set_rbutton(grphaddr,GRPHCLR0,4,i);
	/* -- output only */
	sel_obj( ((ptr->rect).options)&OUTPUT_BIT, grphaddr, GRPHOUTP);
	sel_obj( ((ptr->rect).options)&VALIDT_BIT, grphaddr, GRPHVLDT);
	/* -- x axis */
	xaxisptr= ((TEDINFO*)(grphaddr[GRPHXAXI].ob_spec))->te_ptext;
	i= ptr->xaxis;
	if (i>=0)
		itoa(i,xaxisptr,3);
	else
		strcpy(xaxisptr,"***");
	/* -- y axis */
	yaxisptr= ((TEDINFO*)(grphaddr[GRPHYAXI].ob_spec))->te_ptext;
	i= ptr->yaxis;
	if (i>=0)
		itoa(i,yaxisptr,3);
	else
		strcpy(yaxisptr,"***");
	/* -- how many pts */
	nptsptr= grphaddr[GRPHNPTS].ob_spec;
	itoa(npoints,nptsptr,2);

	/* build pt info */
	for (i=0; i<MAXNPOINTS; i++)
		pt_info[i]= i<npoints ? (ptr->xxval[i]).pt_info : initpt_info ;

	/* encode pt info into dialog box */
	which_pt= 0;
	enc_pt_info(&pt_info[which_pt],which_pt);

	putdial(grphaddr,1,0);

	done=0;
	edit_obj= GRPHXAXI;
	do
	{
		exit_obj= my_form_do(grphaddr,&edit_obj,&mstate,0,&dummy);
		if ( Kbshift(-1) & (K_LSHIFT|K_RSHIFT) ) mstate *= 10 ;
		switch (exit_obj)
		{
			case 1:
			slide_dial(grphaddr);
			break;

			case OKGRPH:
			case CANGRPH:			done=1; break;

			case GRPHVALX:
			case GRPHVALY:
			strcpy(val_title,GRPHPT_MSG);
			strcat(val_title,exit_obj==GRPHVALX ? "X " : "Y ");
			strcat(val_title,grphaddr[GRPHPT].ob_spec);
			strcat(val_title," ");
			i= 2*which_pt + (exit_obj==GRPHVALY) ;
			putdial(0L,0,exit_obj);
			edit_value(val_title,1,i,-1);
			putdial(grphaddr,1,0);
			break;

			case GRPHNPTS:
			i= npoints+mstate;
			if (i<1) i= MAXNPOINTS;
			if (i>MAXNPOINTS) i= 1;
			if (i<(which_pt+1)) i= which_pt+1;
			if (i!=npoints)
			{
				npoints= i;
				itoa(npoints,nptsptr,2);
				draw_object(grphaddr,GRPHNPTS);
				mstate=0;
			}
			break;			

			case GRPHPT:
			i= which_pt+mstate;
			if (i<0) i= npoints-1;
			if (i>(npoints-1)) i=0;
			if (i!=which_pt)
			{
				dec_pt_info(&pt_info[which_pt]);
				which_pt=i;
				enc_pt_info(&pt_info[which_pt],which_pt);
				draw_object(grphaddr,GRPHPT);
				draw_object(grphaddr,GRPHAREA);
				mstate=0;
			}

		}	/* end switch (exit_obj) */
		if (mstate) waitmouse();
	}
	while (!done);
	putdial(0L,0,exit_obj);
	if (exit_obj==CANGRPH) return 0;

	/* decode non-pt info out of dialog box -- */
	/* -- color */
	(ptr->rect).color= whichbutton(grphaddr,GRPHCLR0,4);
	/* -- output only */
	if (is_obj_sel(grphaddr,GRPHOUTP))
		(ptr->rect).options |= OUTPUT_BIT;
	else
		(ptr->rect).options &= ~OUTPUT_BIT;
	if (is_obj_sel(grphaddr,GRPHVLDT))
		(ptr->rect).options |= VALIDT_BIT;
	else
		(ptr->rect).options &= ~VALIDT_BIT;

	/* -- x-axis */
	i= atoi(xaxisptr);
	ptr->xaxis= min(i,100);
	/* -- y-axis */
	i= atoi(yaxisptr);
	ptr->yaxis= min(i,100);
	/* -- how many pts */
	ptr->npoints= npoints;

	/* decode pt info for which_pt */
	dec_pt_info(&pt_info[which_pt]);

	/* copy pt info back into control */
	for (i=0; i<npoints; i++) (ptr->xxval[i]).pt_info= pt_info[i];

	/* just to make it look nice, smear points around */
	for (i=0; i<npoints; i++)
	{
		if (pt_info[i].xmode==PTFOLLOW)
			ed_val[2*i].val= ( ed_val[2*i].low + ed_val[2*i].high ) / 2;
		if (pt_info[i].ymode==PTFULL)
			ed_val[2*i+1].val= ( ed_val[2*i+1].low + ed_val[2*i+1].high ) / 2 ;
	}

	/* decode out of value edit buffer (ed_leng won't be > MAXEDLENG) */
	for (i=0; i<npoints; i++)
	{
		(ptr->xxval[i]).xval= ed_val[2*i];
		(ptr->xxval[i]).yval= ed_val[2*i+1];
	}
	ed_leng= sizeof(ctrl_grph) + sizeof(xxval_info)*(npoints-1) ;
	n_ed_val= 2*npoints;
	n_ed_strg= 0;

	return 1;

}	/* end edctrlgrph() */

enc_pt_info(pt_info,which)
register PT_INFO *pt_info;
int which;
{
	register int temp;
	char *ptr;

	itoa(which+1,grphaddr[GRPHPT].ob_spec,2);
	if (which)
	{
		grphaddr[GRPHYLNK].ob_flags |= (TOUCHEXIT|SELECTABLE);
		grphaddr[GRPHYMOD].ob_state &= ~DISABLED;
	}
	else
	{
		grphaddr[GRPHYLNK].ob_flags &= ~(TOUCHEXIT|SELECTABLE);
		grphaddr[GRPHYMOD].ob_state |= DISABLED;
	}
	sel_obj(pt_info->active,grphaddr,GRPHACTV);
	temp= pt_info->xmode;
	sel_obj(temp==PTFIXED,grphaddr,GRPHXFIX);
	sel_obj(temp==PTFOLLOW,grphaddr,GRPHXMOV);
	sel_obj(pt_info->xline,grphaddr,GRPHVLIN);
	sel_obj(pt_info->yline,grphaddr,GRPHHLIN);
	temp= pt_info->ymode;
	sel_obj(temp==PTFIXED,grphaddr,GRPHYFIX);
	sel_obj(temp==PTFOLLOW,grphaddr,GRPHYLNK);
	sel_obj(temp==PTFULL,grphaddr,GRPHYFUL);
	ptr= ((TEDINFO*)(grphaddr[GRPHXFAC].ob_spec))->te_ptext;
	itoa(pt_info->xfactor,ptr,3);
	ptr= ((TEDINFO*)(grphaddr[GRPHYFXN].ob_spec))->te_ptext;
	itoa(pt_info->yfactor,ptr,3);
}	/* end enc_pt_info() */

dec_pt_info(pt_info)
register PT_INFO *pt_info;
{
	register int temp;
	char *ptr;

	pt_info->active= is_obj_sel(grphaddr,GRPHACTV);
	pt_info->xmode= is_obj_sel(grphaddr,GRPHXFIX) ? PTFIXED : PTFOLLOW ;
	pt_info->xline= is_obj_sel(grphaddr,GRPHVLIN);
	pt_info->yline= is_obj_sel(grphaddr,GRPHHLIN);
	if (is_obj_sel(grphaddr,GRPHYFIX)) temp= PTFIXED;
	if (is_obj_sel(grphaddr,GRPHYLNK)) temp= PTFOLLOW;
	if (is_obj_sel(grphaddr,GRPHYFUL)) temp= PTFULL;
	pt_info->ymode= temp;
	ptr= ((TEDINFO*)(grphaddr[GRPHXFAC].ob_spec))->te_ptext;
	temp= atoi(ptr);
	temp= min(temp,100);
	pt_info->xfactor= max(temp,0);
	ptr= ((TEDINFO*)(grphaddr[GRPHYFXN].ob_spec))->te_ptext;
	temp= atoi(ptr);
	temp= min(temp,100);
	pt_info->yfactor= max(temp,0);
}	/* end dec_pt_info() */

/* edit a joystick control ..................................................*/
/* returns 1= ok, 0= cancel */

edctrljoy()
{
	register CTRL_JOY *ptr;
	register int i;
	int exit_obj;
	static char *joyvaltitl[2]= { JOY_X_MSG , JOY_Y_MSG };

	ptr= (CTRL_JOY*)(heap[ed_mem].start);

	/* encode into value edit buffer */
	val_to_ed(ed_ctrl_i,&(ptr->val[0]),0L,0L,2,2,0L,0,0);

	/* encode into dialog box */
	i= min((ptr->rect).color,3);
	set_rbutton(joyaddr,JOYCLR0,4,i);
	sel_obj( ((ptr->rect).options)&OUTPUT_BIT, joyaddr, JOYOUTP);
	sel_obj( ((ptr->rect).options)&VALIDT_BIT, joyaddr, JOYVLDT);

	do
	{
		exit_obj= do_movedial(joyaddr,-1,0);
		if ( (exit_obj==JOYVALX)	|| (exit_obj==JOYVALY) )
			edit_value(joyvaltitl[exit_obj==JOYVALY],1,exit_obj==JOYVALY,-1);
	}
	while ((exit_obj!=OKJOY)&&(exit_obj!=CANJOY));
	if (exit_obj==CANJOY) return 0;

	/* decode out of dialog box */
	(ptr->rect).color= whichbutton(joyaddr,JOYCLR0,4);
	if (is_obj_sel(joyaddr,JOYOUTP))
		(ptr->rect).options |= OUTPUT_BIT;
	else
		(ptr->rect).options &= ~OUTPUT_BIT;
	if (is_obj_sel(joyaddr,JOYVLDT))
		(ptr->rect).options |= VALIDT_BIT;
	else
		(ptr->rect).options &= ~VALIDT_BIT;

	/* just to make it look nice, center the indicator */
	for (i=0; i<2; i++) ed_val[i].val= (ed_val[i].low+ed_val[i].high)/2;

	/* decode out of value edit buffer */
	copy_bytes(ed_val,&(ptr->val[0]),2L*sizeof(val_info));
	n_ed_val= 2;
	n_ed_strg= 0;
	return 1;

}	/* end edctrljoy() */

/* encode into value/string edit buffers ....................................*/

val_to_ed(ctrl_i,val,xval,xxval,nval,maxnval,str,nstr,maxnstr)
int ctrl_i;			/* which control this is */
VAL_INFO *val;			/* --> VALs in control, or 0L */
XVAL_INFO *xval;		/* --> XVALs in control, or 0L */
XXVAL_INFO *xxval;	/* --> XXVALs in control, or 0L */
int nval;			/* how many [X]VAL's the control has */
int maxnval;		/* how many [X]VAL's the control can have */
long *str;			/* --> first string in control, 0L if control has XVAL's */
int nstr;		/* how many strings the control has, = nval if it has XVAL's */
int maxnstr;	/* how many strings the control can have */
{
	register int i,j;
	char *strpool,*strptr;
	CTRL_EBDT *ebdt;
	CTRL_MIDI *midi;
	long strx;

	/* format value edit buffer */
	ed_val= (VAL_INFO*)(heap[valedmem].start);
	ed_ebdt= (CTRL_EBDT*)(ed_val+maxnval);
	ed_midi= (CTRL_MIDI*)(ed_ebdt+maxnval);
	n_ed_val= maxnval;

	/* build ed_val */
	for (i=0; i<maxnval; i++)
	{
		if (i<nval)
		{
			if (val) ed_val[i]= val[i];
			if (xval) ed_val[i]= xval[i].val;
			if (xxval)
				ed_val[i]= i&1 ? xxval[i/2].yval : xxval[i/2].xval ;
		}
		else
			ed_val[i]= initvalinfo;
	}

	/* build ed_ebdt and ed_midi */
	for (i=0; i<maxnval; i++)
	{
		findebdtmidi(ctrl_i,ed_val[i].linkctrl,&ebdt,&midi,&dummy,&dummy);
		ed_ebdt[i]= ebdt ? *ebdt : initebdtctrl ;
		ed_midi[i]= midi ? *midi : initmidictrl ;
	}

	/* build string edit buffer */
	strpool= (char*)( heap[ temmem[ seg_to_mem(idTEMSTRG) ] ].start );
	strptr= (char*)(heap[strgedmem].start);
	ed_strg= (STR256*)strptr;
	for (i=0; i<maxnstr; i++,strptr+=(MAXSTRLENG+1))
	{
		if (i>=nstr)
			strx= -1L;
		else
		{
			if (str)
				strx= str[i];
			else
				strx= xval[i].str;
		}
		set_bytes(strptr,MAXSTRLENG+1L,0);
		if (strx>=0L) strcpy(strptr,strpool+strx);
		if (!strptr[0]) strptr[0]= -1;
	}
	n_ed_strg=maxnstr;

	/* build midi string edit buffer */
	strptr= (char*)(heap[midistrgmem].start);
	ed_mstrg= (STR256*)strptr;
	for (i=0; i<maxnval; i++,strptr+=(MAXSTRLENG+1))
	{
		strx= ed_midi[i].str;
		set_bytes(strptr,MAXSTRLENG+1L,0);
		if (strx>=0L) strcpy(strptr,strpool+strx);
		if (!strptr[0]) strptr[0]= -1;
	}
}	/* end val_to_ed() */

/* edit control's value information .........................................*/

edit_value(title,highlow,which_val,which_str)
char *title;		/* title for dialog box */
int highlow;		/* whether to allow editing low and high */
int which_val;		/* which val_info to edit */
int which_str;		/* which string to edit, -1 for none */
{
	register int i;
	int exit_obj,edit_obj,done,error;
	int low,high,midilow,midihigh,mididelta;
	char *lowptr,*highptr,*mlowptr,*mhighptr,*mupdptr;
	VAL_INFO *edval;
	CTRL_MIDI *edmidi;
	CTRL_EBDT *edebdt;
	char *edstrg,*edmstrg;
	char midistr[MAXSTRLENG+1],undostr[MAXSTRLENG+1],strgstr[MAXSTRLENG+1];
	static char midivalid[16+6+1+4+4+1]= {
		'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F',
		'a','b','c','d','e','f',
		'n',
		'w','x','y','z',
		's','t','u','v',
		0
	};
	int key,kstate,mstate;
	int n_ebdt,midioffset,strgoffset;
	long templong;
	TEXTEDFMT miditextfmt,strgtextfmt;
	EBDT *ebdt;

	/* dialog box title */
	strcpy( ((TEDINFO*)(valaddr[VALTITL].ob_spec))->te_ptext , title );

	/* what we're editing */
	edval=  ed_val + which_val;
	edebdt= ed_ebdt + which_val;
	edmidi= ed_midi + which_val;
	edmstrg= (char*)(ed_mstrg + which_val);
	edstrg= (char*)(ed_strg + which_str);	/* --> nonsense if which_str<0 */

	/* how many entries in ebdt? */
	n_ebdt= n_of_ebdt(&templong);

	/* build midistr */
	copy_bytes(edmstrg,midistr,MAXSTRLENG+1L);
	if (midistr[0]<0) midistr[0]=0;

	/* build string */
	if (which_str>=0)
	{
		copy_bytes(edstrg,strgstr,MAXSTRLENG+1L);
		if (strgstr[0]<0) strgstr[0]=0;
	}

	/* encode into dialog box */
	lowptr=	((TEDINFO*)(valaddr[VALLOW  ].ob_spec))->te_ptext ;
	highptr=	((TEDINFO*)(valaddr[VALHIGH ].ob_spec))->te_ptext ;
	mlowptr=	((TEDINFO*)(valaddr[VALMLOW ].ob_spec))->te_ptext ;
	mhighptr=((TEDINFO*)(valaddr[VALMHIGH].ob_spec))->te_ptext ;
	mupdptr= ((TEDINFO*)(valaddr[VALMUPD ].ob_spec))->te_ptext ;
	itoa(edval->low ,lowptr ,5);
	itoa(edval->high,highptr,5);
	itoa(edmidi->low ,mlowptr ,5);
	itoa(edmidi->high,mhighptr,5);
	itoa(edmidi->delta,mupdptr,3);
	sel_obj(edval->invert,valaddr,VALINVRT);
	edebdt->index= min(edebdt->index,n_ebdt-1); /* just in case */
	encode_parm(edebdt->index,0);

	/* whether there's a string */
	if (which_str>=0)
	{
		valaddr[VALSTRG ].ob_flags &= ~HIDETREE;
		valaddr[VALSTRNG].ob_flags &= ~HIDETREE;
	}
	else
	{
		valaddr[VALSTRG ].ob_flags |= HIDETREE;
		valaddr[VALSTRNG].ob_flags |= HIDETREE;
	}
	
	/* whether low and high are editable */
	if (highlow)
	{
		valaddr[VALLOW ].ob_flags &= ~HIDETREE;
		valaddr[VALHIGH].ob_flags &= ~HIDETREE;
		edit_obj= VALLOW ;
	}
	else
	{
		valaddr[VALLOW ].ob_flags |= HIDETREE;
		valaddr[VALHIGH].ob_flags |= HIDETREE;
		edit_obj= -1;
	}

	putdial(valaddr,1,0);

	/* find where midi string is displayed, and display it */
	objc_offset(valaddr,VALCODE,&miditextfmt.x,&miditextfmt.y);
	miditextfmt.x /= charw;
	miditextfmt.w= valaddr[VALCODE].ob_width / charw ;
	miditextfmt.spacing= 2;	/* "XX XX XX" format */
	miditextfmt.valid= midivalid;
	miditextfmt.fillchar= '_';
	miditextfmt.spacechar= ' ';
	miditextfmt.bell=1;
	text_edit(-1,0,midistr,MAXSTRLENG,midioffset=0,&miditextfmt);

	/* find where string is displayed, and display it */
	if (which_str>=0)
	{
		objc_offset(valaddr,VALSTRNG,&strgtextfmt.x,&strgtextfmt.y);
		strgtextfmt.x /= charw;
		strgtextfmt.w= valaddr[VALSTRNG].ob_width / charw ;
		strgtextfmt.spacing= 0;	/* XXXXXXX format */
		strgtextfmt.valid= (char*)0L;
		strgtextfmt.fillchar= '_';
		strgtextfmt.spacechar= ' ';
		strgtextfmt.bell=1;
		text_edit(-1,0,strgstr,MAXSTRLENG,strgoffset=0,&strgtextfmt);
	}

	done=0;
	do
	{
		exit_obj= my_form_do(valaddr,&edit_obj,&mstate,0,&dummy);
		kstate= Kbshift(-1)&0x0F;
		switch (exit_obj)
		{
			case 1:
			slide_dial(valaddr);
			objc_offset(valaddr,VALCODE,&miditextfmt.x,&miditextfmt.y);
			miditextfmt.x /= charw;
			text_edit(-1,0,midistr,MAXSTRLENG,midioffset=0,&miditextfmt);
			if (which_str>=0)
			{
				objc_offset(valaddr,VALSTRNG,&strgtextfmt.x,&strgtextfmt.y);
				strgtextfmt.x /= charw;
				text_edit(-1,0,strgstr,MAXSTRLENG,strgoffset=0,&strgtextfmt);
			}
			break;

			case VALEXIT : done=1; break;

			case VALPARM :
			if (n_ebdt)
			{
				if (kstate==K_ALT)
					i= -1;
				else
				{
					putdial(0L,0,exit_obj);
					i= choose_parm(n_ebdt,edebdt->index);
					kstate= Kbshift(-1) & (K_LSHIFT|K_RSHIFT) ;
					/* set control range = parameter range */
					if (highlow && (i>=0) && !kstate)
					{
						n_of_ebdt(&ebdt);
						ebdt += i;
						low= atoii(lowptr,&error);
						if (!error) high= atoii(highptr,&error);
						if (!error) error= high<=low ;
						if (error || ( (ebdt->high - ebdt->low)!=(high-low) ) )
						{
							templong= ebdt->low;
							if ( (templong>=(-32768L)) && (templong<=32767L) )
								itoa( (int)templong, lowptr, 5);
							templong= ebdt->high;
							if ( (templong>=(-32768L)) && (templong<=32767L) )
								itoa( (int)templong, highptr, 5);
						}
					}
					putdial(valaddr,1,0);
					text_edit(-1,0,midistr,MAXSTRLENG,midioffset,&miditextfmt);
					if (which_str>=0)
						text_edit(-1,0,strgstr,MAXSTRLENG,strgoffset,&strgtextfmt);
				}
				encode_parm(edebdt->index=i,1);
			}
			break;

			case VALSTRNG:
			text_edit(0,0,strgstr,MAXSTRLENG,strgoffset,&strgtextfmt);
			copy_bytes(strgstr,undostr,MAXSTRLENG+1L);
			while (!done)
			{
				templong= Crawcin();
				kstate= Kbshift(-1)&0x0F;
				switch (key=(templong>>16))
				{
					case SCAN_UNDO:
					copy_bytes(undostr,strgstr,MAXSTRLENG+1L);
					text_edit(0,0,strgstr,MAXSTRLENG,strgoffset=0,&strgtextfmt);
					break;

					case SCAN_CR:
					case SCAN_ENTER:
					done=1;
					break;
					
					default:
					key= templong | (key<<8) ;
					strgoffset= text_edit(key,kstate,strgstr,MAXSTRLENG,
											strgoffset,&strgtextfmt);
				}	/* end switch (key) */
			}
			text_edit(-1,0,strgstr,MAXSTRLENG,strgoffset,&strgtextfmt);
			done=0;
			break;

			case VALCODE :
			text_edit(0,0,midistr,MAXSTRLENG,midioffset,&miditextfmt);
			copy_bytes(midistr,undostr,MAXSTRLENG+1L);
			while (!done)
			{
				templong= Crawcin();
				kstate= Kbshift(-1)&0x0F;
				switch (key=(templong>>16))
				{
					case SCAN_UNDO:
					copy_bytes(undostr,midistr,MAXSTRLENG+1L);
					text_edit(0,0,midistr,MAXSTRLENG,midioffset=0,&miditextfmt);
					break;

					case SCAN_CR:
					case SCAN_ENTER:
					done=1;
					break;
					
					default:
					key= templong | (key<<8) ;
					midioffset= text_edit(key,kstate,midistr,MAXSTRLENG,
											midioffset,&miditextfmt);
				}	/* end switch (key) */
			}
			text_edit(-1,0,midistr,MAXSTRLENG,midioffset,&miditextfmt);
			done=0;

		}	/* end switch (exit_obj) */
		if (mstate && !done) waitmouse();
		/* when done, parse low and high */
		if (done&&highlow)
		{
			low= atoii(lowptr,&error);
			if (!error) high= atoii(highptr,&error);
			if (!error) error= high<=low ;
			if (error)
			{
				form_alert(1,BADVALRNGE);
				valaddr[VALEXIT].ob_state= done= 0;
				draw_object(valaddr,VALEXIT);
			}
		}
		if (done)
		{
			midilow= atoii(mlowptr,&error);
			if (!error) midihigh= atoii(mhighptr,&error);
			mididelta= max(0,atoi(mupdptr));
			if (error)
			{
				form_alert(1,BADVALRNGE);
				valaddr[VALEXIT].ob_state= done= 0;
				draw_object(valaddr,VALEXIT);
			}
		}	/* end if done */
	}
	while (!done);
	putdial(0L,0,exit_obj);

	/* decode value */
	if (highlow)
	{
		edval->val= edval->low= low;
		edval->high= high;
	}
	edval->invert= is_obj_sel(valaddr,VALINVRT);

	/* decode string */
	if (which_str>=0)
	{
		copy_bytes(strgstr,edstrg,MAXSTRLENG+1L);
		if (!edstrg[0]) edstrg[0]= -1;
	}

	/* decode midi control */
	edmidi->low= midilow;
	edmidi->high= midihigh;
	edmidi->delta= mididelta;

	/* decode midi string -- */
	/* -- force lower case hex constants to uppercase */
	for (i=0; i<MAXSTRLENG; i++)
	{
		key= midistr[i];
		if ((key>='a')&&(key<='f')) midistr[i]= key-'a'+'A';
	}
	/* -- convert null string to -1 term'd */
	copy_bytes(midistr,edmstrg,MAXSTRLENG+1L);
	edmidi->str= edmstrg[0] ? 0L : -1L ;
	if (!edmstrg[0])
		edmstrg[0]= -1;
	else /* -- append '0' to midistr if unfinished nibble */
	{
		i= strlen(edmstrg);
		if (i&1)
		{
			edmstrg[i++]= '0';
			edmstrg[i]= 0;
		}
	}

}	/* end edit_value() */

encode_parm(which,redraw)
int which,redraw;
{
	char field[NEBDTCOLS][32];
	EBDT *ebdt;
	char *ptr[4];
	static int parmobj[4]= { VALPARM2, VALPARM, VALPARM3, VALPARM4 };
	register int i;

	for (i=0; i<4; i++) ptr[i]= valaddr[parmobj[i]].ob_spec;

	if (which>=0)
	{
		n_of_ebdt(&ebdt);
		decode_ebdt(ebdt+which,field);
		strcpy(ptr[0],"+");
		strcat(ptr[0],field[0]);		/* offset */
		strcpy(ptr[1],field[1]);		/* name */
		strcpy(ptr[2],field[3]);		/* low */
		strcpy(ptr[3],field[4]);		/* high */
		valaddr[VALLH].ob_flags &= ~HIDETREE;
	}
	else
	{
		for (i=0; i<4; i++) strcpy(ptr[i]," ");
		valaddr[VALLH].ob_flags |= HIDETREE;
	}
	if (redraw)
	{
		for (i=0; i<4; i++) draw_object(valaddr,parmobj[i]);
		draw_object(valaddr,VALLH);
	}
}	/* end encode_parm() */

/* returns choice # (-1 cancel) */
choose_parm(n_ebdt,curr)
int n_ebdt,curr;
{
	int result;
	char *ptr;
	int inter;
	EBDT *ebdt;

	n_of_ebdt(&ebdt);
	ptr= ebdt->name;
	inter= sizeof(*ebdt);
	result= pop_up(CHOOSEPARM,curr,n_ebdt,ptr,inter,0L) ;
	if (result<0) result=curr;
	return result;
}	/* end choose_parm() */

/* edit list of strings for text control ....................................*/
/* returns # strings */

editstrged(nstrings,maxnstrings)
int nstrings,maxnstrings;
{
	register int i,j,endx;
	register char *str;

	int exit_obj,edit_obj,done;
	int key,kstate,mstate,mousey;
	int curs_x,curs_y,nrows;
	int text_x,numb_x,curs_i,home,offset;
	long maxleng,templong,newleng,oldleng;
	unsigned int nullstrg= 0xFF00;
	char strbuf[MAXSTRLENG+1],undobuf[MAXSTRLENG+1];
	TEXTEDFMT textfmt;
	int i2,y;

again:
	str= (char*)(heap[strgedmem].start);
	maxleng= heap[strgedmem].nbytes;
	i= findstrged(nstrings-1);				/* start of last string */
	endx= i + strlen(str+i) + 1 ;			/* offset to first available char */

	putdial(textaddr,1,0);

	/* find things */
	objc_offset(textaddr,TEXTCOL1,&curs_x,&curs_y);
	curs_x= curs_x/charw +1 ;
	curs_y++;
	objc_offset(textaddr,TEXTCOL2,&numb_x,&dummy);
	numb_x /= charw ;
	objc_offset(textaddr,TEXTCOL3,&text_x,&dummy);
	text_x /= charw ;
	nrows= textaddr[TEXTCOL1].ob_height / charh ;

	/* home the display */
	curs_i= home= 0;

	/* display text and numbers */
	edstrgdisp(text_x,numb_x,curs_y,nrows,home,nstrings,-1);

	/* display cursor */
	HIDEMOUSE;
	outchar(3,curs_x,curs_y+curs_i*charh);	
	SHOWMOUSE;

	edit_obj= -1;
	done=0;
	do
	{
		key=0;
		exit_obj= my_form_do(textaddr,&edit_obj,&mstate,1,&key);
		kstate= Kbshift(-1)&0x0F; /* shift/alt/ctrl */
		getmouse(&dummy,&mousey);
		key>>=8;	/* scan code */
		if (key) exit_obj= -1;
		switch (key)
		{
			case 0:	break;

			case SCAN_CR  :
			case SCAN_ENTER :
			exit_obj= TEXTEXIT;
			break;

			case SCAN_CLR :	exit_obj= TEXTCLR ; break;

			case SCAN_UP  :
			case SCAN_DOWN:
			if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT))	/* scroll list by row */
				exit_obj= key==SCAN_UP ? TEXTUP : TEXTDOWN ;
			if (!kstate)				/* cursor up/down with auto-scroll */
			{
				i= curs_i+home;
				if ( (key==SCAN_UP) && !i ) break;
				if ( (key==SCAN_DOWN) && (i==nstrings) ) break;
				HIDEMOUSE;
				outchar(' ',curs_x,curs_y+curs_i*charh);
				i= (key==SCAN_UP ? -1 : 1) ;
				if ((curs_i+i)<0)
					edstrgdisp(text_x,numb_x,curs_y,nrows,--home,nstrings,-1);
				else
				{
					if ((curs_i+i)>=nrows)
						edstrgdisp(text_x,numb_x,curs_y,nrows,++home,nstrings,-1);
					else
						curs_i += i ;
				}
				outchar(3,curs_x,curs_y+curs_i*charh);
				SHOWMOUSE;
			}
			if (kstate==K_CTRL)						/* scroll list to top/bottom */
			{
				i= key==SCAN_UP ? 0 : nstrings ;
				if (i!=home)
				{
					edstrgdisp(text_x,numb_x,curs_y,nrows,home=i,nstrings,-1);
					HIDEMOUSE;
					outchar(' ',curs_x,curs_y+curs_i*charh);
					curs_i= 0;
					outchar(3,curs_x,curs_y+curs_i*charh);
					SHOWMOUSE;
				}
			}
			break;
			
			case SCAN_DEL:
			if (nstrings>1)		/* can't delete last string */
			{
				i= curs_i+home;
				if (i<nstrings)	/* can't delete the null at end of list */
				{
					j= findstrged(i);		/* --> start of this string */
					endx -= (strlen(str+j)+1) ;
					i2= findstrged(i+1);
					/* delete in middle, close up hole */
					if (i<(nstrings-1)) copy_bytes(str+i2,str+j,maxleng-i2);
					nstrings--;
					edstrgdisp(text_x,numb_x,curs_y,nrows,home,nstrings,-1);
				}
			}
			break;

			case SCAN_INS:		/* insert null string */
			if ( (nstrings==maxnstrings) || (endx>(maxleng-2)) )
				form_alert(1,BADSTRGED);
			else
			{
				i= curs_i+home;
				if (i==nstrings)
					copy_bytes(&nullstrg,str+endx,2L);
				else
				{
					j= findstrged(i);	/* --> start of this string */
					insert_bytes(2L,&nullstrg,str+j,str+maxleng-2);
				}
				endx += 2;
				edstrgdisp(text_x,numb_x,curs_y,nrows,home,++nstrings,-1);
			}

			case SCAN_SPACE:	/* edit string at cursor */
			mousey= curs_y + curs_i*charh ;
			exit_obj= TEXTCOL3;

		}	/* end switch scan code */
		switch (exit_obj)
		{
			case 1:
			slide_dial(textaddr);
			objc_offset(textaddr,TEXTCOL1,&curs_x,&curs_y);
			curs_x= curs_x/charw +1 ;
			curs_y++;
			objc_offset(textaddr,TEXTCOL2,&numb_x,&dummy);
			numb_x /= charw ;
			objc_offset(textaddr,TEXTCOL3,&text_x,&dummy);
			text_x /= charw ;
			edstrgdisp(text_x,numb_x,curs_y,nrows,home,nstrings,-1);
			HIDEMOUSE;
			outchar(3,curs_x,curs_y+curs_i*charh);	
			SHOWMOUSE;
			break;

			case TEXTEXIT: done=1; break;

			case TEXTUP  :
			case TEXTDOWN:
			i= home + (exit_obj==TEXTUP ? -1 : 1);
			if ((i>=0)&&(i<=nstrings))
			{
				home=i;
				edstrgdisp(text_x,numb_x,curs_y,nrows,home,nstrings,-1);
				i= curs_i+home;
				i= max(i,home);
				i= min(i,nstrings);
				i= min(i,home+nrows-1);
				i -= home;
				if (i!=curs_i)
				{
					HIDEMOUSE;
					outchar(' ',curs_x,curs_y+curs_i*charh);
					curs_i= i;
					outchar(3,curs_x,curs_y+curs_i*charh);
					SHOWMOUSE;
				}
				mstate=0;	/* allow mouse repeat */
			}
			break;

			case TEXTVSCR:		/* scroll list by half screen */
			getmouse(&dummy,&mousey);
			i= mousey;
			objc_offset(textaddr,TEXTVSLD,&dummy,&y);
			i= i<y ? -nrows/2 : nrows/2 ;
			i += home;
			if (i<0) i=0;
			if (i>nstrings) i= nstrings;
			home=i;
			edstrgdisp(text_x,numb_x,curs_y,nrows,home,nstrings,-1);
			if (curs_i+home > nstrings )
			{
				HIDEMOUSE;
				outchar(' ',curs_x,curs_y+curs_i*charh);
				curs_i= nstrings-home;
				outchar(3,curs_x,curs_y+curs_i*charh);
				SHOWMOUSE;
			}
			mstate=0;	/* allow mouse repeat */
			break;

			case TEXTVSLD:
			i= hndl_slider(home,nstrings+1,textaddr,TEXTVSLD,TEXTVSCR);
			if (i!=home)
			{
				home=i;
				edstrgdisp(text_x,numb_x,curs_y,nrows,home,nstrings,-1);
				if (curs_i+home > nstrings )
				{
					HIDEMOUSE;
					outchar(' ',curs_x,curs_y+curs_i*charh);
					curs_i= nstrings-home;
					outchar(3,curs_x,curs_y+curs_i*charh);
					SHOWMOUSE;
				}
			}
			break;
			
			case TEXTCOL1:
			i= (mousey - curs_y) / charh ;
			if ((i<0)||(i>=nrows)) break;
			i += home;
			if ( (i<=nstrings) && (i!=(curs_i+home)) )
			{
				HIDEMOUSE;
				outchar(' ',curs_x,curs_y+curs_i*charh);
				curs_i= i-home;
				outchar(3,curs_x,curs_y+curs_i*charh);
				SHOWMOUSE;
			}
			break;

			case TEXTCOL3:
			i= (mousey - curs_y) / charh ;
			if ((i<0)||(i>=nrows)) break;
			i += home;
			if (i>=nstrings) break;
			textfmt.x= text_x;
			textfmt.y= curs_y + (i-home)*charh;
			textfmt.w= textaddr[TEXTCOL3].ob_width / charw - 1;
			textfmt.spacing= 0;	/* XXXXXXX format */
			textfmt.valid= (char*)0L;
			textfmt.fillchar= ' ';
			textfmt.spacechar= ' ';
			textfmt.bell=1;
			set_bytes(strbuf,MAXSTRLENG+1L,0);
			j= findstrged(i);	/* --> start of this string */
			strcpy(strbuf,str+j);
			if (strbuf[0]<0) strbuf[0]=0;
			text_edit(0,0,strbuf,MAXSTRLENG,offset=0,&textfmt);
			copy_bytes(strbuf,undobuf,MAXSTRLENG+1L);
			while (!done)
			{
				templong= Crawcin();
				switch (key=(templong>>16))
				{
					case SCAN_UNDO:
					copy_bytes(undobuf,strbuf,MAXSTRLENG+1L);
					text_edit(0,0,strbuf,MAXSTRLENG,offset=0,&textfmt);
					break;

					case SCAN_CR:
					case SCAN_ENTER:
					done=1;
					break;

					default:
					key= templong | (key<<8) ;
					kstate= Kbshift(-1)&0x0F;
					offset= text_edit(key,kstate,strbuf,MAXSTRLENG,
											offset,&textfmt);
				}	/* end switch (key) */
			}
			text_edit(-1,0,strbuf,MAXSTRLENG,offset=0,&textfmt);
			done=0;
			if (!strbuf[0]) copy_bytes(&nullstrg,strbuf,2L);
			oldleng= strlen(str+j)+1;
			newleng= strlen(strbuf)+1;
			if ( (endx-oldleng+newleng) > (maxleng-2) )
				form_alert(1,BADSTRGED);
			else
			{
				i2= findstrged(i+1);
				/* delete in middle, close up hole */
				if (i<(nstrings-1)) copy_bytes(str+i2,str+j,maxleng-i2);
				insert_bytes(newleng,strbuf,str+j,str+maxleng-newleng);
				endx += (newleng-oldleng) ;
			}
			break;

			case TEXTCLR :
			if (form_alert(1,CHEKCLRTEXT)==1)
			{
				set_words(str,maxleng/2,nullstrg);
				nstrings=1;
				HIDEMOUSE;
				outchar(' ',curs_x,curs_y+curs_i*charh);	
				curs_i= home= 0;
				edstrgdisp(text_x,numb_x,curs_y,nrows,home,nstrings,-1);
				outchar(3,curs_x,curs_y+curs_i*charh);
				endx= 2;
				SHOWMOUSE;
			}
			break;

			case TEXTIMPT:
			putdial(0L,0,exit_obj);
			nstrings= import_text(nstrings);
			goto again;

		}	/* end switch (exit_obj) */
		if (mstate) waitmouse();
	}
	while (!done);
	putdial(0L,0,exit_obj);

	return nstrings;

}	/* end editstrged() */

edstrgdisp(text_x,numb_x,y,nrows,home,nstrings,which)
int text_x,numb_x,y,nrows;
int home,nstrings,which;
{
	register int i,j;
	char numbbuf[4];
	char textbuf[MAXSTRLENG+1];
	int w,h;

	w= textaddr[TEXTCOL3].ob_width / charw - 1;
	HIDEMOUSE;
	for (i=0,j=home; i<nrows; i++,j++,y+=charh)
	{
		if ( (which<0) || (which==j) )
		{
			if (j<nstrings)
			{
				strcpy(textbuf,heap[strgedmem].start+findstrged(j));
				pad_str(w,textbuf,' ');
				itoa(j,numbbuf,3);
			}
			else
			{
				set_bytes(textbuf,(long)w,' ');
				strcpy(numbbuf,"   ");
			}
			gr_text(numbbuf,numb_x,y);
			textbuf[w]=0;
			if (textbuf[0]<0) textbuf[0]=' ';
			gr_text(textbuf,text_x,y);
		}
	}
	SHOWMOUSE;

	/* vertical scroll bar and slider */
	h= textaddr[TEXTVSCR].ob_height;
	w= textaddr[TEXTVSCR].ob_width;
	set_slider(nstrings+1,nrows,home,0,h,w,
				&textaddr[TEXTVSLD].ob_height,&textaddr[TEXTVSLD].ob_y);
	draw_object(textaddr,TEXTVSCR);

}	/* end edstrgdisp() */

/* find start of a string in strgedmem heap .................................*/
/* returns offset to string */

findstrged(which)
register int which;	/* which string to find */
{
	register char *ptr;
	register int i;

	ptr= (char*)(heap[strgedmem].start);
	i=0;	/* assume string #0 is at start of buffer */
	for (; which>0; which--)
	{
		while ( ptr[i] ) i++;	/* find null at end of previous string */
		while ( !ptr[i] ) i++;	/* find start of this string */
	}
	return i;
}	/* end findstrged() */

/* import text file to strgedmem ............................................*/
/* returns # strings */

import_text(nstrings)
int nstrings;
{
	char filename[13],pathname[80];
	long templong,Flength();
	int hand;
	int saveMP;

	filename[0]=0;
	Dsetdrv(tem_drive); dsetpath(tem_path);
	if (getfile(pathname,filename,TXT_EXT,IMPTEXTMSG)>0)
	{
		if (midiplexer) saveMP=MPoff();
		hand= Fopen(pathname,0);
		if (hand<0)
			big_alert(1,BADOPEN1,filename,BADOPEN2);
		else
		{
			templong= Flength(hand);
			if (templong>8000L)
				form_alert(1,BADIMPTEXT);
			else
			{
				if ( Fread(hand,templong,cnxscrsave) != templong )
					big_alert(1,BADREAD1,filename,BADREAD2);
				else	/* convert to strgedmem format */
					nstrings= txt_to_strg(cnxscrsave,templong,strgedmem);
				Fclose(hand);
			}
		}
		if (midiplexer&&saveMP) MPon();
	}
	return nstrings;
}	/* end import_text() */

txt_to_strg(fromptr,fromleng,to_mem)
register char *fromptr;
long fromleng;
int to_mem;
{
	register char *toptr;
	register int i,n,lastch,ch;

	graf_mouse(BEE_MOUSE);
	toptr= (char*)(heap[to_mem].start);

	lastch= 0;	/* track whether previous character is displayable */
	for (i=n=0; (i<fromleng)&&(n<1000); i++) /* no more than 1000 strings */
	{
		ch= *fromptr++;
		if ((ch>=' ')&&(ch<=0x7E)) /* displayable ascii */
		{
			*toptr++ = ch;
			lastch=1;
		}
		else
		{
			if (lastch)					/* end of this string */
			{
				*toptr++ = 0;
				n++;
			}
			lastch=0;
		}
	}
	if (lastch)							/* if necessary, terminate the last string */
	{
		*toptr++ = 0;
		n++;
	}
	graf_mouse(ARROWMOUSE);
	return n;
}	/* end txt_to_strg() */

#endif

/* EOF */
