/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module PATCH : patch menu commands (except Edit)

	ex_name,	ex_random, ex_distort, ex_average

	do_random

******************************************************************************/

overlay "event"

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

/* edit name(s) of selected patches .........................................*/

ex_name(side)
int side;	/* 0= left, 1= right */
{
	register int i,j;
	TEDINFO *tedinfo;
	char ptext[MAXNAMLENG+1],ptmplt[MAXNAMLENG+1],pvalid[MAXNAMLENG+1];
	char title[80],linebuf[10];
	int leng,exit_obj;
	char *nameptr;

	leng= nameleng[side];
	if (!leng) return;									/* patches not named */
	nameptr= (char*)(heap[namemem[side]].start);	/* --> this side's names */

	/* format dialog box editable text fields */
	tedinfo= (TEDINFO*)(pnamaddr[PNAMNAME].ob_spec);
	tedinfo->te_ptext= ptext;
	tedinfo->te_ptmplt= ptmplt;
	tedinfo->te_pvalid= pvalid;
	tedinfo->te_txtlen= leng+1;
	tedinfo->te_tmplen= leng+1;
	set_bytes(ptmplt,(long)leng,'_'); ptmplt[leng]=0;
	set_bytes(pvalid,(long)leng,'X'); pvalid[leng]=0;
	pnamaddr[PNAMNAME].ob_width= charw*(leng+1);

	((TEDINFO*)(pnamaddr[PNAMTITL].ob_spec))->te_ptext = title;
	exit_obj= OKPNAM;
	for (i=0; i<npatches[side]; i++)
	{
		if (patchselect[side][i])
		{
			strcpy(title,NAMEPATMSG);
			if (!itop(i,windpnumfmt[side],linebuf)) linebuf[0]=0;
			strcat(title,linebuf);
			strcat(title,":");
			j= pnamaddr[0].ob_width= charw * (4+max(leng,strlen(title)));
			pnamaddr[PNAMTITL].ob_width= pnamaddr[0].ob_width;
			form_center(pnamaddr,&dummy,&dummy,&dummy,&dummy);
			pnamaddr[PNAMBOX ].ob_x= pnamaddr[0].ob_width/2
									 - pnamaddr[PNAMBOX ].ob_width/2 ;
			/* current patch name */
			if (exit_obj!=RESTPNAM)
			{
				copy_bytes(nameptr+i*leng,ptext,(long)leng); ptext[leng]=0;
				exit_obj= do_dial(pnamaddr,PNAMNAME);
				if (exit_obj==CANPNAM ) break;
				if (exit_obj==SKIPPNAM) continue;
			}
			pad_str((int)MAXNAMLENG,ptext,' ');
			copy_bytes(ptext,nameptr+i*leng,(long)leng);
			/* mark this patch */
			patchselect[side][i]= -1;
		}
	}

	/* scan through marked patches */
	graf_mouse(BEE_MOUSE);
	for (i=0; i<npatches[side]; i++)
	{
		if (patchselect[side][i]<0)
		{
			/* get edit buffer out of data buffer */
			if (!putpgetp((int)(cnxGETP),side,i)) break;

			/* putpgetp() may have moved heap blocks */
			nameptr= (char*)(heap[namemem[side]].start);

			/* copy new name to pvalid, pad with spaces */
			copy_bytes(nameptr+leng*i,pvalid,(long)leng);
			for (j=0; j<leng; j++) if (!pvalid[j]) break;
			for (; j<leng; j++) pvalid[j]=' ';

			/* copy name to edit buffer */
			copy_bytes(pvalid,heap[editmem].start+nameoffset[side],(long)leng);
			copy_bytes(pvalid,nameptr+leng*i,(long)leng);

			/* put edit buffer back into data buffer */
			if (!putpgetp((int)(cnxPUTP),side,i)) break;
			build_1name(side,i);

			/* window has been changed */
			change_flag[side ? rdatCHANGE : ldatCHANGE]= 1;
		}
	}
	/* unmark patches */
	for (i=0; i<npatches[side]; i++)
		if (patchselect[side][i]<0) patchselect[side][i]= 1;

	graf_mouse(ARROWMOUSE);

	change_mem(editmem,0L);	/* shrink edit buffer */
	draw_names(side,-1);

}	/* end ex_name() */

/* randomize ................................................................*/

ex_random(side)
int side;	/* 0= left, 1= right */
{
	register int pat,npats;
	int whichpat;
	long namleng,leng;
	char *nameptr;

	/* can't randomize without an ebdt */
	if (!match_tem(side,1)) return;

	leng= nameleng[side];
	namleng= min(nameleng[side],strlen(RANDNAME));

	waitmouse();
	graf_mouse(BEE_MOUSE);
	menuprompt(RANDOM_MSG);

	for (pat=npats=0; pat<npatches[side]; pat++)
	{
		/* abort on mouse */
		if (getmouse(&dummy,&dummy))
		{
			break;
			npats=0;	/* and don't send to midi */
		}
		if (patchselect[side][pat])
		{
			if (!putpgetp((int)(cnxDTOE),side,pat)) break;
			if (editbufok()) break;
			if (!do_random(0)) break;
			if (!putpgetp((int)(cnxETOD),side,pat)) break;
			/* count randomized patches and remember first one */
			npats++;
			if (npats==1) whichpat=pat;
			change_flag[side ? rdatCHANGE : ldatCHANGE]= 1;

			/* name (leng must be >0 if we could call this function!) */
			if (!putpgetp((int)(cnxGETP),side,pat)) break;
			nameptr= (char*)(heap[namemem[side]].start);
			nameptr += pat*leng ;
			set_bytes(nameptr,leng,' ');
			copy_bytes(RANDNAME,nameptr,namleng);
			copy_bytes(nameptr,heap[editmem].start+nameoffset[side],leng);
			if (!putpgetp((int)(cnxPUTP),side,pat)) break;
			build_1name(side,pat);
			draw_names(side,pat);
		}
	}

	/* if only 1 randomized patch, send to midi */
	if (npats==1)
		if (putpgetp((int)(cnxDTOE),side,whichpat))
			edittomidi(side);

	menuprompt(0L);
	graf_mouse(ARROWMOUSE);
	waitmouse();

	/* shrink edit buffer */
	change_mem(editmem,0L);

}	/* end ex_random() */

/* distort ..................................................................*/

ex_distort(side)
int side;	/* 0= left, 1= right */
{
	register int pat,npats;
	int whichpat;
	long leng;
	char *nameptr;

	/* can't distort without an ebdt */
	if (!match_tem(side,2)) return;

	leng= nameleng[side];

	waitmouse();
	graf_mouse(BEE_MOUSE);
	menuprompt(DISTORT_MSG);

	for (pat=npats=0; pat<npatches[side]; pat++)
	{
		/* abort on mouse */
		if (getmouse(&dummy,&dummy))
		{
			break;
			npats=0;	/* and don't send to midi */
		}
		if (patchselect[side][pat])
		{
			if (!putpgetp((int)(cnxDTOE),side,pat)) break;
			if (editbufok()) break;
			if (!do_random(1)) break;
			if (!putpgetp((int)(cnxETOD),side,pat)) break;
			/* count distorted patches, remember first one */
			npats++;
			if (npats==1) whichpat=pat;
			change_flag[side ? rdatCHANGE : ldatCHANGE]= 1;
			/* name (leng must be >0 if we could call this function!) */
			if (!putpgetp((int)(cnxGETP),side,pat)) break;
			nameptr= (char*)(heap[namemem[side]].start);
			nameptr += pat*leng ;
			nameptr[leng-1]= '%';
			copy_bytes(nameptr,heap[editmem].start+nameoffset[side],leng);
			if (!putpgetp((int)(cnxPUTP),side,pat)) break;
			build_1name(side,pat);
			draw_names(side,pat);
		}
	}

	/* if only 1 distorted patch, send to midi */
	if (npats==1)
		if (putpgetp((int)(cnxDTOE),side,whichpat))
			edittomidi(side);

	menuprompt(0L);
	graf_mouse(ARROWMOUSE);
	waitmouse();

	/* shrink edit buffer */
	change_mem(editmem,0L);

}	/* end ex_distort() */

/* average ..................................................................*/

ex_average(side)
int side;	/* 0= left, 1= right */
{
	register int i,pat;
	int npats;
	int pats[1+MAXNAVER];
	long leng,namleng,edleng,templong;

	/* can't average without an ebdt */
	if (!match_tem(side,3)) return;

	/* name info */
	leng= nameleng[side];
	namleng= min(nameleng[side],strlen(AVERNAME));

	/* find selected patches */
	for (pat=npats=0; (pat<npatches[side])&&(npats<=MAXNAVER); pat++)
		if (patchselect[side][pat])
			pats[npats++]=pat;
	/* must have at least two */
	if (npats<2)
	{
		form_alert(1,BADNAVER);
		return;
	}
	/* can't have more than MAXNAVER */
	if (npats>MAXNAVER)
	{
		if (form_alert(1,CHEKAVER)==2) return;
		npats=MAXNAVER;
	}

	/* multi-edit buffer divided into even chunks */
	edleng= editleng[side];
	if (edleng&1) edleng++;
	tempmem= alloc_mem(npats*edleng);
	if (tempmem<0) return;

	graf_mouse(BEE_MOUSE);

	/* build multi-edit-buffer */
	for (i=0; i<npats; i++)
	{
		pat= pats[i];
		if (!putpgetp((int)(cnxDTOE),side,pat)) break;
		if (editbufok()) break;
		copy_bytes(heap[editmem].start,heap[tempmem].start+i*edleng,edleng);
	}

	/* "mix down" the multi-edit-buffer */
	if (i==npats)
	{
		if (do_average(npats,edleng))
		{
		/* -- copy result on clipboard (temporarily) */
			copy_mem(editmem,mainclpmem);
		/* -- GETP window patch 0 to tempmem buffer */
			putpgetp((int)(cnxGETP),side,0);
			copy_mem(editmem,tempmem);
		/* -- ETOD clipboard to window patch 0 */
			copy_mem(mainclpmem,editmem);
			putpgetp((int)(cnxETOD),side,0);
		/* -- GETP window patch 0 to edit buffer */
			putpgetp((int)(cnxGETP),side,0);
		/* -- replace name in edit buffer */
			templong= heap[editmem].start + nameoffset[side];
			set_bytes(templong,leng,' ');
			copy_bytes(AVERNAME,templong,namleng);
		/* -- PUTP edit buffer to window patch 0 */
			putpgetp((int)(cnxPUTP),side,0);
		/* -- DTOE window patch 0 to edit buffer */
			putpgetp((int)(cnxDTOE),side,0);
		/* -- send edit buffer to midi */
			edittomidi(side);
		/* -- put result on clipboard (with patch name) */
			copy_mem(editmem,mainclpmem);
			set_bytes(clpname,leng,' ');
			copy_bytes(AVERNAME,clpname,namleng);
			clpnameleng= leng;
		/* -- PUTP tempmem buffer to window patch 0 */
			copy_mem(tempmem,editmem);
			putpgetp((int)(cnxPUTP),side,0);
		}
	}

	graf_mouse(ARROWMOUSE);

	/* shrink buffers */
	change_mem(editmem,0L);
	dealloc_mem(tempmem);

}	/* end ex_average() */

do_average(npats,leng)
int npats;		/* how many patches in tempmem */
long leng;		/* length of each patch in tempmem */
{
	register int i,j,n_ebdt;
	register long sum;
	register EBDT *ebdt;

	long templong;
	long editstart,editend;
	long tempstart[MAXNAVER];
	long geteditval();

	/* check for no ebdt already done in match_tem() */
	n_ebdt= n_of_ebdt(&templong);
	ebdt= (EBDT*)(templong);

	editstart= heap[editmem].start;
	editend= editstart + heap[editmem].nbytes;
	for (i=0; i<npats; i++) tempstart[i]= heap[tempmem].start + i*leng;

	for (i=0; i<n_ebdt; i++,ebdt++)
	{
		if ( ( ebdt->offset + ebdt->length ) <= editend )
		{
			if ( (ebdt->name)[0] != '*' )
			{
				sum=0L;
				for (j=0; j<npats; j++) sum += geteditval(ebdt,tempstart[j]);
				sum /= npats;
				seteditval(ebdt,editstart,sum);
			}
		}
	}
	return 1;
}	/* end do_average() */

/* randomize/distort edit buffer ............................................*/

do_random(op)
int op;	/* 0= randomize, 1= distort */
{
	register int i,n_ebdt;
	register EBDT *ebdt;
	long templong,low,high;
	long editstart,editend;
	long random(),geteditval();

	/* check for no ebdt already done in match_tem() */
	n_ebdt= n_of_ebdt(&templong);
	ebdt= (EBDT*)(templong);

	editstart= heap[editmem].start;
	editend= editstart + heap[editmem].nbytes;

	for (i=0; i<n_ebdt; i++,ebdt++)
	{
		if ( ( ebdt->offset + ebdt->length ) <= editend )
		{
			if ( (ebdt->name)[0] != '*' )
			{
				if (op==0)	/* randomize */
				{
					templong= ebdt->high - ebdt->low ;
					templong= ebdt->low + random(templong);
				}
				if (op==1)	/* distort */
				{
					templong= geteditval(ebdt,editstart);
					low= max(templong-1,ebdt->low);
					high= min(templong+1,ebdt->high);
					templong= low + random(high-low);
				}
				seteditval(ebdt,editstart,templong);
			}
		}
	}
	return 1;
}	/* end do_random() */

long random(top)
long top;
{
	static long randseed;
	register long seed= randseed;
	long result;

	/* first time called:  grab seed from system raw 200hz */
	if (!seed) {
		seed= *(long*)(0x4baL);
		seed |= (seed<<16);
	}
	/* this algorithm taken directly from BIOS */
	seed= 3141592621L*seed + 1L;
	randseed=seed;
	result= ((seed>>8)&127) % (top+1) ;
	return result;
}	/* end random() */

/* EOF */
