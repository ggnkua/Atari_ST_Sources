/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module EDIT3 : editor bottom level

	Entry points:
	
	page_table, editbufok, clipedbuf, geteditval,
	seteditval, fakeeditbuf, getebdtsize, setallvals, initeditbuf
	find_e_m

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

/* in tem.c .................................................................*/

extern int curr_mem,curr_nctrl;

/* in edit1.c ...............................................................*/

extern int edit_orig,origmem,backmem,chgtabmem,ptabmem,addrmem;
extern int chgtabn;

/* build control/ebdt link table ............................................*/
/* returns 0= ok, 1= error */

page_table()
{
#if (EDITFLAG*TEMFLAG)
	register int i,j;
	register long n,ctrlptr;
	register long *longptr;
	register EBDTLINK *ptabptr;
	long currpageptr,maxntable,dummlong;
	int type,nvals,ebdtindex,ebdt_i;
	CTRLHEADER ctrlheader;
	VAL_INFO *val[MAXNVALS];

	/* build page address offset table */
	if (!change_mem(addrmem,4L*curr_nctrl)) return 1;
	longptr= (long*)(heap[addrmem].start);
	ctrlptr= heap[curr_mem].start;
	for (i=0; i<curr_nctrl; i++,longptr++)
	{
		*longptr = i ? longptr[-1]+j : 0L ;
		j= ((CTRLHEADER*)(ctrlptr))->length;
		ctrlptr += j;
	}

	/* build linked list of ebdt/valinfo -- */

	/* -- allocate largest possible table */
	fill_mem(ptabmem);
	ptabptr= (EBDTLINK*)(heap[ptabmem].start);
	maxntable= heap[ptabmem].nbytes / sizeof(*ptabptr) ;

	/* -- first part of table is for the ebdt itself */
	n= n_of_ebdt(&dummlong);
	if (n>maxntable) n= maxntable= 0;	/* loops skipped, returns error */
	for (i=0; i<n; i++)
	{
		ptabptr[i].next= i;
		ptabptr[i].ctrl_i= -1;	/* means ebdt */
	}

	/* -- rest of table is for ctrl valinfo's */
	longptr= (long*)(heap[addrmem].start);
	currpageptr= heap[curr_mem].start;
	for (i=0; (i<curr_nctrl)&&(n<maxntable); i++)
	{
		ctrlptr= currpageptr + longptr[i] ;
		type= ((CTRLHEADER*)(ctrlptr))->type;
		if (type>=0) /* visible */
		{
			nvals= find_vals(type,ctrlptr+sizeof(ctrlheader),val);
			for (j=0; (j<nvals)&&(n<maxntable); j++)
			{
				find_e_m(i,val[j],&ebdt_i,&dummy);
				if (ebdt_i>=0)
				{
					ctrlptr= currpageptr + longptr[ebdt_i];
					ebdtindex= ( (CTRL_EBDT*)(ctrlptr+sizeof(ctrlheader)) )->index;
					ptabptr[n].ctrl_i= i;
					ptabptr[n].val_i= j;
					ptabptr[n].next= ptabptr[ebdtindex].next;
					ptabptr[ebdtindex].next= n;
					n++;
				}
			}
		}
	}
	if (n==maxntable)
	{
		form_alert(1,BADMEM2);
		n=0;
	}
	change_mem(ptabmem,n*sizeof(*ptabptr));

	return (n==maxntable)||(!maxntable);
#endif
}	/* end page_table() */

/* check edit buffer against ebdt ...........................................*/
/* returns 0= ok, 1= error (alert box inside here) */

editbufok()
{
#if (EDITFLAG*TEMFLAG)
	int error=1;
	long ebdtleng,getebdtsize();

	ebdtleng= getebdtsize();

	if (heap[editmem].nbytes < ebdtleng)
		form_alert(1,BADEBDTLENG);
	else
		error= clipedbuf(1);
	return error;
#else
	return 0;
#endif
}	/* end editbufok() */

/* compare/clip edit buffer against ebdt ....................................*/
/* returns 1= bad, 0= ok */

clipedbuf(clip_ok)
int clip_ok;	/* 1= error messages, 2= aborts without error message */
{
#if (EDITFLAG*TEMFLAG)
	register int i;
	register long templong,ptr;
	register EBDT *ebdt;
	int n_ebdt;
	long val,low,high,geteditval();
	long last_low,last_high;

	n_ebdt= n_of_ebdt(&val);
	ebdt= (EBDT*)(val);

	ptr= heap[editmem].start;

	for (i=0; i<n_ebdt; i++,ebdt++)
	{
		low= ebdt->low;
		high= ebdt->high;
		if (i && (ebdt->offset == (ebdt-1)->offset) )
		{
			low= min(low,last_low);
			high= max(high,last_high);
		}
		last_low=low;
		last_high=high;
		if ((i<(n_ebdt-1)) && (ebdt->offset == (ebdt+1)->offset) ) continue;

		val= geteditval(ebdt,ptr);
		if ((val<low)||(val>high))
		{
			if (clip_ok==1) clip_ok= clip_error(ebdt,val);
			if (clip_ok==2) return 1;
			if (val<low) val=low;
			if (val>high) val=high;
			seteditval(ebdt,ptr,val);
		}
	}
#endif
	return 0;
}	/* end clipedbuf() */

/* returns 0= go for it, 1= keep trying, 2= abort */

clip_error(ebdt,val)
EBDT *ebdt;
long val;
{
	char field[NEBDTCOLS][32];
	char errorline[80];
	int temp;

	decode_ebdt(ebdt,field);
	strcpy(errorline,"+");
	strcat(errorline,field[0]);	/* offset */
	strcat(errorline," ");
	strcat(errorline,field[1]);	/* parameter name */
	strcat(errorline," ");
	strcat(errorline,field[3]);	/* low */
	strcat(errorline," ");
	strcat(errorline,field[4]);	/* high */
	strcat(errorline," ");
	strcat(errorline,VAL_MSG);
	ltoa(val,field[0],5);
	strcat(errorline,field[0]);
	menuprompt(errorline);
	temp= form_alert(3,CHEKEBDTHL)-1;
	menuprompt(0L);
	return temp;
}	/* end clip_error() */

/* get value from edit buffer ...............................................*/

long geteditval(ebdt,ptr)
register EBDT *ebdt;		/* --> EBDT entry for this parameter */
register char *ptr;		/* --> start of edit buffer */
{
#if (EDITFLAG*TEMFLAG)
	register long val;
	register int length,signed;

	ptr += ebdt->offset ;
	signed= (ebdt->low<0) || (ebdt->high<0) ;
	length= ebdt->length;
	asm {
		tst.w    signed
		bne      get_sign
		clr.l		val
		move.b   (ptr),val					; unsigned byte
		lsr.w    #1,length
		bcs      lengthx
		move.w   (ptr),val					; unsigned word
		lsr.w    #1,length
		bcs      lengthx
		bra      length4
	get_sign:
		lsr.w    #1,length
		bcc      length2
		move.b   (ptr),val					; signed byte
		ext.w    val
		ext.l    val
		bra      lengthx
	length2:
		lsr.w    #1,length
		bcc      length4
		move.w   (ptr),val					; signed word
		ext.l    val
		bra      lengthx
	length4:
		move.l   (ptr),val					; long
	lengthx:
	}
	return val;
#endif
}	/* end geteditval() */

/* set value in edit buffer .................................................*/

seteditval(ebdt,ptr,val)
register EBDT *ebdt;
register long ptr,val;
{
#if (EDITFLAG*TEMFLAG)
	int signed;

	ptr += ebdt->offset ;
	signed= (ebdt->low<0) || (ebdt->high<0) ;
	switch (ebdt->length)
	{
		case 1:
		if (!signed) val &= 0xffL;
		*(char*)(ptr)= val;
		break;
		
		case 2:
		if (!signed) val &= 0xffffL;
		*(int*)(ptr)= val;
		break;
		
		case 4:
		*(long*)(ptr)= val;
	}
#endif
}	/* end seteditval() */

/* make fake edit buffer ....................................................*/
/* returns 0= ok, 1= error */

fakeeditbuf()
{
#if (EDITFLAG*TEMFLAG)
	int error=1;
	long ebdtleng,getebdtsize();

	ebdtleng= getebdtsize();
	if (change_mem(editmem,ebdtleng))
	{
		initeditbuf(heap[editmem].start,heap[editmem].start+ebdtleng);
		error=0;
	}
	return error;
#endif
}	/* end fakeeditbuf() */

/* highest offset+size in ebdt ..............................................*/
/* returns highest offset+size */

long getebdtsize()
{
#if (EDITFLAG*TEMFLAG)
	register EBDT *ebdt;
	register long templong,max_long;
	register int i;
	int n_ebdt;
	long temp;

	n_ebdt= n_of_ebdt(&temp);
	ebdt= (EBDT*)(temp);

	/* find largest offset+size */
	max_long= 0L;
	for (i=0; i<n_ebdt; i++,ebdt++)
	{
		templong= ebdt->offset + ebdt->length ;
		if (templong>max_long) max_long=templong;
	}
	return max_long;
#endif
}	/* end getebdtsize() */

/* set values of controls on current page ...................................*/
/* adds to chgtabmem, increases chgtabn */

setallvals(ifbackup,except_i)
int ifbackup;	/* 1= set value only if different than in backmem */
int except_i;	/* don't update this control */
{
#if (EDITFLAG*TEMFLAG)
	register int i,j,ctrl_i;
	register EBDT *ebdtptr;
	register EBDTLINK *ptabptr;
	long editptr,pageptr,backptr;
	int n;
	int *chgptr;
	long *addrptr;
	long edbufval,backval;
	long geteditval();

	chgptr= (int*)(heap[chgtabmem].start);
	editptr= heap[ edit_orig ? origmem : editmem ].start;
	backptr= heap[backmem].start;
	n= n_of_ebdt(&pageptr);
	ebdtptr= (EBDT*)(pageptr);
	pageptr= heap[curr_mem].start;
	ptabptr= (EBDTLINK*)(heap[ptabmem].start);
	addrptr= (long*)(heap[addrmem].start);

	for (i=0; i<n; i++,ebdtptr++)
	{
		j= ptabptr[i].next;
		if (i==j) continue;	/* nothing connected to this index on this page */
		edbufval= geteditval(ebdtptr,editptr);
		backval=  ifbackup ? geteditval(ebdtptr,backptr) : !edbufval ;
		while (j!=i)
		{
			ctrl_i= ptabptr[j].ctrl_i;
			if ( (ctrl_i!=except_i) && (edbufval!=backval) )
				if ( setctrlval(pageptr+addrptr[ctrl_i],ptabptr[j].val_i,
						ebdtptr->low,ebdtptr->high,edbufval) )
					chgptr[chgtabn++]= ctrl_i;
			j= ptabptr[j].next;
		}
	}
#endif
}	/* end setallvals() */

/* returns 1 if ctrl val changed, 0 if not */
setctrlval(ctrl,val_i,edbuflow,edbufhigh,edbufval)
CTRLHEADER *ctrl;
int val_i;
long edbuflow,edbufhigh,edbufval;
{
#if (EDITFLAG*TEMFLAG)
	register VAL_INFO *val;
	register long ctrllow,ctrlhigh,ctrlval;
	long val_to_val();
	VAL_INFO *vals[MAXNVALS];

	find_vals(ctrl->type,(long)(ctrl)+sizeof(*ctrl),vals);
	val= vals[val_i];

	ctrllow= val->low;
	ctrlhigh= val->high;
	if (val->invert)
	{
		asm { exg.l ctrllow,ctrlhigh }
	}
	/* new control value */
	ctrlval= val_to_val(edbufval,edbuflow,edbufhigh,ctrllow,ctrlhigh);
	/* if changed, update value inside control and mark changed */
	if (ctrlval!=val->val)
	{
		val->val= ctrlval;
		return 1;
	}
	return 0;

#endif
}	/* end setctrlval() */

/* force edit buffer to match EBDT ..........................................*/
/* called from putpgetp() also */

initeditbuf(editstart,editend)
long editstart,editend;
{
#if (EDITFLAG*TEMFLAG)
	register int i;
	register long templong;
	register EBDT *ebdt;
	int n_ebdt;
	long temp;

	n_ebdt= n_of_ebdt(&temp);
	ebdt= (EBDT*)(temp);

	/* EBDT might not cover all of buffer */
	temp= templong= editend-editstart;
	if (templong>4L)
	{
		temp= templong / 4;
		set_longs(editstart,temp,0L);
		set_bytes(editstart+4*temp,templong-4*temp,0);
	}
	else
		set_bytes(editstart,templong,0);
		
	for (i=0; i<n_ebdt; i++,ebdt++)
	{
		if ( ( ebdt->offset + ebdt->length ) <= templong )
		{
			temp= (ebdt->low <= 0) && (ebdt->high >= 0) ? 0 : ebdt->low ;
			seteditval(ebdt,editstart,temp);
		}
	}
#endif
}	/* end initeditbuf() */

/* find ebdt and/or midi control linked to a given valinfo ..................*/
/* requires page offset table already built in addrmem */

find_e_m(ctrl_i,val,ebdt_i,midi_i)
int ctrl_i;
VAL_INFO *val;
int *ebdt_i,*midi_i;		/* found control #s (-1 none) */
{
	register int linkctrl;
	register long *longptr;
	register long ctrlptr;
	long currpageptr;
	int type;
	CTRLHEADER ctrlheader;
	CTRL_EBDT *ebdtctrl;

	linkctrl= val->linkctrl;
	longptr= (long*)(heap[addrmem].start);
	currpageptr= heap[curr_mem].start;
	*ebdt_i= *midi_i= -1;

	while ( (linkctrl!=ctrl_i) && (linkctrl>=0) )
	{
		ctrlptr= currpageptr + longptr[linkctrl] ;
		type= ((CTRLHEADER*)(ctrlptr))->type;
		ctrlptr += sizeof(ctrlheader) ;
		switch (type)
		{
			case CTYP_EBDT:
			ebdtctrl= (CTRL_EBDT*)ctrlptr;
			/* not really linked */
			if (ebdtctrl->index>=0) *ebdt_i= linkctrl;
			linkctrl= ebdtctrl->linkctrl;
			break;
			
			case CTYP_MIDI:
			*midi_i= linkctrl;
			linkctrl= ((CTRL_MIDI*)(ctrlptr))->linkctrl;
			break;
			
			default: return;
		}
	}
}	/* end find_e_m() */

/* EOF */
