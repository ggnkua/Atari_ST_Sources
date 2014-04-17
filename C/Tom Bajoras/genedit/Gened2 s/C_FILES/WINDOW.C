/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990/1991 Tom Bajoras

	module WINDOW :  window menu commands, and related

	ex_clear, ex_export, ex_windopts, ex_print, ex_duplic
	ex_infowind, ex_devwind, ex_sortwind

	choose_side, putpgetp

******************************************************************************/

overlay "file"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "scan.h"			/* keyboard scan codes */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

extern char *alertstr[];	/* in file.c */

/* used in ex_duplic */
typedef struct {
	int link;
	int side;
	int pat;
} DUPLISTRUCT;

/* clear window(s) ..........................................................*/

ex_clear(side)
register int side;	/* -1= both, 0= left, 1= right */
{
	register int from,to;
	int ch_flag;

	switch (side)
	{
		case -1: from=0; to=1; break;
		case  0:	from=0; to=0; break;
		case  1:	from=1; to=1;
	}

	for (side=from; side<=to; side++)
	{
		ch_flag= side ? rdatCHANGE : ldatCHANGE ;
		if (heap[windatamem[side]].nbytes)
		{
			if (change_flag[ch_flag])
			{
				if (form_alert(1,alertstr[side])==2) continue;
			}
			else
			{
				if (form_alert(1,side ? CHEKCLRRW : CHEKCLRLW)==2) continue;
			}
		}
		change_mem(windcnxmem[side],0L);
		change_mem(windatamem[side],0L);
		initcnxname(-1,windcnxname[side]);
		windfile[side][0]=0;
		init_device(&wind_device[side]);
		if (npatches[side])
			draw_window(side);
		else
			draw_file(side);
		change_flag[ch_flag]=0;
	}
}	/* end ex_clear() */

/* window device ............................................................*/

ex_devwind()
{
	register int side;

	/* choose side */
	side= choose_side(CHEKINFO);
	if (side>=0)
		edit_studio(side+NDEVICES);
}

/* window info ..............................................................*/

ex_infowind(side)
int side;				/* 0= left, 1= right */
{
	register int i;
	char *fnamptr,*cnamptr,*tnamptr,*sizeptr,*chanptr;
	long oldsize,newsize,atol();
	int datahand,cnxhand;
	int result;
	char tempfnam[13];
	NAMEDCONST *foundptr;
	long cnxstart,cnxend,segstart,segend;
	long find_const();

	datahand= windatamem[side];
	cnxhand= windcnxmem[side];

	/* encode into dialog box */
	((TEDINFO*)(windaddr[WINDTITL].ob_spec))->te_ptext=
		side ? NAME_MSG2 : NAME_MSG1 ;
	fnamptr= ((TEDINFO*)(windaddr[WINDFNAM].ob_spec))->te_ptext;
	cnamptr= windaddr[WINDCNAM].ob_spec;
	tnamptr= windaddr[WINDTNAM].ob_spec;
	sizeptr= ((TEDINFO*)(windaddr[WINDSIZE].ob_spec))->te_ptext;
	ltoa(oldsize=heap[datahand].nbytes,sizeptr,-1);
	encodefname(windfile[side],fnamptr);
	copy_bytes(windcnxname[side],cnamptr,(long)NCHPERCNX);
	cnamptr[NCHPERCNX]=0;
	strcpy(tnamptr,NONE_MSG);
	cnxstart= heap[cnxhand].start;
	cnxend= cnxstart + heap[cnxhand].nbytes;
	if (_findcnxseg((int)cnxCNST,cnxstart,cnxend,&segstart,&segend))
	{
		foundptr= (NAMEDCONST*)find_const(C_TEMLINK,segstart,segend-segstart);
		if (foundptr) strcpy(tnamptr,foundptr->value);
	}

	/* interact with dialog box */
	do
	{
		result= do_dial(windaddr,WINDFNAM) == OKWIND ;
		if (result)
			if (decodefname(fnamptr,tempfnam))
				result= -1;
		if (result<0) form_alert(1,BADNAME);
	}
	while (result<0);

	if (result)
	{
		/* decode out of dialog box */
		strcpy(windfile[side],tempfnam);
		/* optionally resize window */
		newsize= atol(sizeptr);
		if ( (newsize>=0L) && (newsize!=oldsize) )
		{
			result=2;
			if (newsize<oldsize)		/* shrink:  warning! */
				if (form_alert(2,CHEKRESIZE)==2) result=1;
			if (result==2)
				if (!change_mem(datahand,newsize))
					result=1;
			if (result==2)
				if (newsize>oldsize)		/* expand:  clear added data */
					set_bytes(heap[datahand].start+oldsize,newsize-oldsize,0);
		}
	}

	/* redraw */
	if (result==1) draw_file(side);
	if (result==2) draw_window(side);

}	/* end ex_infowind() */

/* export raw window ........................................................*/

ex_export()
{
	int side;
	char filename[13],pathname[80];
	int temp,asc_mem;
	long leng,addr;
	static int type=1;	/* 1= binary, 2= ascii */
	char *ext;
	register char *bin_ptr,*asc_ptr;
	register long bin_leng,asc_leng;
	long bin2ascii();

	/* choose a side */
	side= choose_side(CHEKRAW);
	if (side<0) return;

	temp= windatamem[side];
	leng= heap[temp].nbytes;

	/* export as binary or ascii? */
	type= form_alert(type,CHEKRAWTYP);
	asc_mem= -1;

	/* convert to ascii */
	if (type==2)
	{
		asc_mem= alloc_mem( 2*leng + 2*(leng/80) );
		if (asc_mem<0) return;
		graf_mouse(BEE_MOUSE);
		leng= bin2ascii(heap[temp].start,heap[asc_mem].start,leng,1,1);
		addr= heap[asc_mem].start;
		ext= TXT_EXT;
		graf_mouse(ARROWMOUSE);
	}
	else	/* save as binary */
	{
		addr= heap[temp].start;
		ext= RAW_EXT;
	}

	/* write it to disk */
	strcpy(filename,windfile[side]);
	new_ext(filename,ext);
	Dsetdrv(side ? rdat_drive : ldat_drive);
	dsetpath(side ? rdat_path : ldat_path);
	if (getfile(pathname,filename,ext,side ? RRAW_TITL : LRAW_TITL)>0)
	{
		temp= Dgetdrv();
		if (side)
			rdat_drive= temp;
		else
			ldat_drive= temp;
		Dgetpath(side ? rdat_path : ldat_path, temp+1 );

		save_file(filename,pathname,1,&addr,&leng);
	}
	dealloc_mem(asc_mem);
}	/* end ex_export() */

/* window options ...........................................................*/

ex_windopts()
{
	#define NOPTS 7
	register int i,temp;
	register char *ptr;
	static int opt_obj[NOPTS]= {
		WOPTLODC, WOPTLODD, WOPTSAVC, WOPTSAVD, WOPTPATL, WOPTPATR, WOPT1PRT
	};
	static char *opt_ptr[NOPTS]= {
		&windlodc, &windlodd, &windsavc, &windsavd,
		&windpatsend[0], &windpatsend[1], &windprt1col
	};
	static int opt_edit[2]= { WOPTCHNL, WOPTCHNR };

	set_rbutton(woptaddr,WOPTLINK,3,windlink+1);
	for (i=0; i<NOPTS; i++)
		sel_obj(*opt_ptr[i],woptaddr,opt_obj[i]);
	for (i=0; i<2; i++)
	{
		ptr= ((TEDINFO*)(woptaddr[opt_edit[i]].ob_spec))->te_ptext;
		if (windpatchan[i]<0)
			strcpy(ptr,"--");
		else
			itoa(windpatchan[i]+1,ptr,2);
	}

	do_dial(woptaddr,WOPTCHNL);

	windlink= whichbutton(woptaddr,WOPTLINK,3) - 1;
	for (i=0; i<NOPTS; i++)
		*opt_ptr[i]= is_obj_sel(woptaddr,opt_obj[i]);
	for (i=0; i<2; i++)
	{
		ptr= ((TEDINFO*)(woptaddr[opt_edit[i]].ob_spec))->te_ptext;
		temp= atoi(ptr);
		windpatchan[i]= ((temp>=1)&&(temp<=16)) ? temp-1 : -1 ;
	}

}	/* end ex_windopts() */

/* find duplicate patches ...................................................*/

ex_duplic()
{
	register int i,j,npats;
	int resultmem;
	DUPLISTRUCT *result;
	long offset1,nbytes1,offset2,nbytes2;
	long buffer1,buffer2;
	int nduplic;
	char initpatname[MAXNAMLENG];
	static int chooseduplic=1,duplictype=1;
	int iside,ipat,jside,jpat;
	int crc1,crc2;
	unsigned int *checksums;

	/* use temporary buffer for checksums */
	checksums= (unsigned int*)cnxscrsave;

/* !!! make initpatname a global variable saved in INF file
	-- use it in other situations also */
	set_bytes(initpatname,MAXNAMLENG,'-');

	/* can't do this if there are no patches in either window */
	npats= npatches[0] + npatches[1] ;
	if (!npats) return;

	/* if comparing two windows, are they comparable? */
	if (npatches[0] && npatches[1])
	{
		if ( (nameoffset[0]!=nameoffset[1]) ||
			  (nameleng[0]!=nameleng[1]) ||
			  (editleng[0]!=editleng[1])
		)
		{
			form_alert(1,BADDUPLIC);
			return;
		}
	}

	/* compare names / data / names+data ? */
	duplictype= form_alert(duplictype,DUPLICTYPE);

	/* compute offset and length of each part of patch that will be compared */
	i= npatches[0] ? 0 : 1 ;
	offset1= 0;
	if (duplictype==2) /* ignore names in comparison */
	{
		nbytes1= nameoffset[i];
		offset2= nameoffset[i] + nameleng[i] ;
		nbytes2= editleng[i] - offset2 ;
	}
	else					/* include names in comparison */
	{
		nbytes1= 0;
		offset2= 0;
		nbytes2= editleng[i];
	}

	/* allocate structure to store results */
	resultmem= alloc_mem((long)npats*sizeof(*result));
	if (resultmem<0) return;

	graf_mouse(BEE_MOUSE);

	/* compute checksums */
	for (i=0; i<npatches[0]; i++)
	{
		if (!putpgetp((int)cnxGETP,0,i)) goto bad_duplic;
		checksums[i]= sum_dupl(offset1,nbytes1,offset2,nbytes2);
	}
	for (i=0; i<npatches[1]; i++)
	{
		if (!putpgetp((int)cnxGETP,1,i)) goto bad_duplic;
		checksums[i+MAXNPATS]= sum_dupl(offset1,nbytes1,offset2,nbytes2);
	}

	/* start with no duplicates */
	result= (DUPLISTRUCT*)(heap[resultmem].start);
	for (i=0; i<npats; i++)
	{
		result[i].link= i;
		if (npatches[0]&&npatches[1])
		{
			result[i].side= i>=npatches[0];
			result[i].pat= (i>=npatches[0]) ? (i-npatches[0]) : i ;
		}
		else
		{
			result[i].side= npatches[0] ? 0 : 1 ;
			result[i].pat= i;
		}
	}

	/* search */
	for (nduplic=i=0; i<npats; i++)
	{
		/* this patch has already been found duplicate to a previous patch? */
		if (result[i].link != i) continue;
		iside= result[i].side;
		ipat= result[i].pat;

		/* compare names only */
		if (duplictype==1)
		{
			for (j=i+1; j<npats; j++)
			{
				jside= result[j].side;
				jpat= result[j].pat;
				if (!comp_bytes(heap[namemem[iside]].start + ipat*nameleng[iside],
									heap[namemem[jside]].start + jpat*nameleng[jside],
									(long)(nameleng[iside]) )
				)
				{
					nduplic++;
					result[j].link= result[i].link;
				}
			}
			continue;
		}

		for (j= i+1; j<npats; j++)
		{
			jside= result[j].side;
			jpat= result[j].pat;

			/* compare the two edit buffers but ignore patch name */
			if ( checksums[iside*MAXNPATS+ipat] ==
				  checksums[jside*MAXNPATS+jpat]
			)
			{
				if (!putpgetp((int)cnxGETP,iside,ipat)) goto bad_duplic;
				crc1= crc_dupl(offset1,nbytes1,offset2,nbytes2);
				if (!putpgetp((int)cnxGETP,jside,jpat)) goto bad_duplic;
				crc2= crc_dupl(offset1,nbytes1,offset2,nbytes2);
				result= (DUPLISTRUCT*)(heap[resultmem].start);
				if (crc1==crc2)
				{
					nduplic++;
					result[j].link= result[i].link;
				}
			}
		}
	}

	if (nduplic)
	{
		switch (chooseduplic=form_alert(chooseduplic,CHOOSEDUPLIC))
		{
			case 1: name_duplic(resultmem,npats,0L         ); break;
			case 2: name_duplic(resultmem,npats,initpatname);
		}
	}
	else
		form_alert(1,NODUPLIC);

bad_duplic:
	graf_mouse(ARROWMOUSE);
	dealloc_mem(resultmem);

}	/* end ex_duplic() */

sum_dupl(offset1,nbytes1,offset2,nbytes2)
long offset1,nbytes1,offset2,nbytes2;
{
	return
		checksum(heap[editmem].start+offset1,
						heap[editmem].start+offset1+nbytes1)
		 + checksum(heap[editmem].start+offset2,
						heap[editmem].start+offset2+nbytes2);
}
crc_dupl(offset1,nbytes1,offset2,nbytes2)
long offset1,nbytes1,offset2,nbytes2;
{
	return
		crc16(heap[editmem].start+offset1,
						heap[editmem].start+offset1+nbytes1)
		 + crc16(heap[editmem].start+offset2,
						heap[editmem].start+offset2+nbytes2);
}

name_duplic(resultmem,npats,name)
int resultmem;
int npats;
char *name;	/* --> patch name to be renamed to, 0L means link names */
{
	register DUPLISTRUCT *result;
	register int i,j;
	int iside,ipat,jside,jpat;
	int sidechanged[2];
	char *nameptr;
	char linebuf[MAXNAMLENG];
	static char *sidesymbol[2]= { "L  " , "R  " };

	sidechanged[0]= sidechanged[1]= 0;
	for (i=0; i<npats; i++)
	{
		result= (DUPLISTRUCT*)(heap[resultmem].start);
		j= result[i].link;
		if (i != j )
		{
			iside= result[i].side;
			ipat= result[i].pat;
			jside= result[j].side;
			jpat= result[j].pat;
			if (!putpgetp((int)(cnxGETP),iside,ipat)) break;
			result= (DUPLISTRUCT*)(heap[resultmem].start);
			if (name)
				nameptr= name;
			else
			{
				set_bytes(linebuf,(long)nameleng[iside],0);
				nameptr= sidesymbol[jside];
				strcpy(linebuf,nameptr);
				itop(jpat,windpnumfmt[jside],linebuf+strlen(nameptr));
				nameptr= linebuf;
			}
			copy_bytes(nameptr,heap[editmem].start+nameoffset[iside],
							(long)nameleng[iside]);
			if (!putpgetp((int)(cnxPUTP),iside,ipat)) break;
			result= (DUPLISTRUCT*)(heap[resultmem].start);
			change_flag[iside ? rdatCHANGE : ldatCHANGE]= 1;
			sidechanged[iside]=1;
		}
	}

	/* re-build and re-display window(s) containing changed patch names */
	for (i=0; i<2; i++)
		if (sidechanged[i])
			draw_window(i);

}	/* end name_duplic() */

/* sort by patch name .......................................................*/

ex_sortwind()
{
	register int i,j,temp,new_i;
	int leng,side,change;
	int savemem,editmem1,editmem2;
	char tempname[MAXNAMLENG];
	long nameptr;

	/* choose a side */
	side= choose_side(CHEKSORTWND);
	if (side<0) return;
	leng= nameleng[side];

	/* two edit buffers */
	savemem= editmem;
	editmem2= -1;
	editmem1= alloc_mem(0L);
	if (editmem1<0) goto bad_sort;
	editmem2= alloc_mem(0L);
	if (editmem2<0) goto bad_sort;

	/* sort by patch names */
	graf_mouse(BEE_MOUSE);
	for (change=i=0; i<npatches[side]; i++)
	{
		new_i= i;
		for (j=i+1; j<npatches[side]; j++)
		{
			nameptr= heap[namemem[side]].start;
			if (comp_names(nameptr+leng*new_i,nameptr+leng*j,leng)) new_i=j;
		}
		if (new_i!=i)
		{
			change=1;
			/* exchange patches i and new_i */
			editmem= editmem1;
			if (!putpgetp((int)(cnxGETP),side,i)) break;
			editmem= editmem2;
			if (!putpgetp((int)(cnxGETP),side,new_i)) break;
			if (!putpgetp((int)(cnxPUTP),side,i)) break;
			editmem= editmem1;
			if (!putpgetp((int)(cnxPUTP),side,new_i)) break;
			nameptr= heap[namemem[side]].start;
			copy_bytes(nameptr+leng*i,tempname,(long)leng);
			copy_bytes(nameptr+leng*new_i,nameptr+leng*i,(long)leng);
			copy_bytes(tempname,nameptr+leng*new_i,(long)leng);
		}
	}
	graf_mouse(ARROWMOUSE);

	/* re-build and re-display window (if it has changed) */
	if (change)
	{
		change_flag[side ? rdatCHANGE : ldatCHANGE]= 1;
		draw_window(side);
	}

bad_sort:
	dealloc_mem(editmem1);
	dealloc_mem(editmem2);
	editmem= savemem;

}	/* end ex_sortwind() */

/* returns 1 if name2 < name1, else returns 0 */
comp_names(name1,name2,nchs)
register char *name1,*name2;
register int nchs;
{
	register int ch1,ch2;

	for (; nchs>0; nchs--)
	{
		ch1= converttype( *name1++ );
		ch2= converttype( *name2++ );
		if (ch2<ch1) return 1;
		if (ch2>ch1) return 0;
	}
	return 0;

}	/* end comp_names() */

converttype(ch)
int ch;
{
	switch (typechar(ch))
	{
		case 2:	ch += ('A'-'a');	break;	/* convert to upper case */
		case 4:	ch += 2000;			break;	/* undisplayable */
		case 5:	ch += 1000;						/* punctuation */
	}
	return ch;
}

/* move this to misc !!! */
typechar(ch)
int ch;
{
	if ((ch>='0')&&(ch<='9')) return 0; /* numeric */
	if ((ch>='A')&&(ch<='Z')) return 1; /* upper alpha */
	if ((ch>='a')&&(ch<='z')) return 2; /* lower alpha */
	if (ch==' ') return 3;					/* space */
	if ((ch<0x20)||(ch>0x7E)) return 4; /* undisplayable */
	return 5;									/* punctuation, etc. */
}	/* end typechar() */

/* print window .............................................................*/

ex_print()
{
	register int i,c,r,side;
	int nrows,ncols;
	char linebuf[80];

	/* choose a side */
	side= choose_side(CHEKPRTWND);
	if (side<0) return;

	/* info about this side, format printing in columns */
	i= npatches[side];
	ncols= i>32 ? 80/(nameleng[side]+7+6) : 1 ;
	ncols= min(ncols,4);
	if (windprt1col) ncols=1;
	nrows= i/ncols;
	if (i%ncols) nrows++;

	waitmouse();
	i=1;
	while ( !(i=Cprnos()) )
		if (form_alert(1,BADPRINT)!=1) break;
	if (!i) return;

	menuprompt(NOWPRINTMSG);
	graf_mouse(BEE_MOUSE);

	/* reset printer pagination and print header */
	cprnwsrow=0;
	Cprnws(windfile[side],1);
	Cprnws(" ",1);

	for (r=0; r<nrows; r++)
	{
		/* mouse button aborts */
		if (getmouse(&dummy,&dummy))
		{
			cprnwsrow=0;
			break;
		}
		linebuf[0]=0;
		for (c=0; c<ncols; c++)
		{
			i= c*nrows + r;
			if (i>=npatches[side]) break;
			buildprint(linebuf,side,i);
		}
		/* print it */
		Cprnws(linebuf,1);
	}
	if (cprnwsrow) Cprnout(0x0C);	/* form feed at end */
	waitmouse();
	graf_mouse(ARROWMOUSE);
	menuprompt(0L);

}	/* end ex_print() */

buildprint(ptr,side,i)
char *ptr;
int side,i;
{
	char linebuf[80];
	int leng;

	/* patch number */		
	if (!itop(i,windpnumfmt[side],linebuf)) strcpy(linebuf,"       ");
	pad_str(7,linebuf,' ');
	strcat(ptr,linebuf);

	/* patch name */
	leng= nameleng[side];
	copy_bytes(heap[namemem[side]].start+i*leng,linebuf,(long)leng);
	linebuf[leng]=0;
	strcat(ptr,linebuf);

	/* space between columns */
	strcat(ptr,"      ");
}	/* end buildprint() */

/* (un)extract edit buffer to/from bank .....................................*/
/* returns 1= ok, 0= error */

putpgetp(seg,side,pat)
register int seg;		/* cnxGETP, cnxPUTP, cnxDTOE, cnxETOD */
register int side;	/* 0= left, 1= right */
register int pat;		/* which patch to (un)extract */
{
	long datastart,dataend,editstart,editend,cnxstart,cnxend,initstart,initend;
	long templong,olddataleng;
	int result,datamem,cnxmem;

	/* patch must be within range */
	if (pat>=npatches[side]) return 0;

	datamem= windatamem[side];
	cnxmem= windcnxmem[side];

	/* cnxGETP or cnxDTOE: must allocate edit buffer */
	if ( (seg==cnxGETP) || (seg==cnxDTOE) )
	{
		cnxstart= heap[cnxmem].start;
		cnxend= cnxstart + heap[cnxmem].nbytes;
		if (!_findcnxseg((int)(cnxINIT),cnxstart,cnxend,&initstart,&initend))
			return 0;
		datastart= heap[datamem].start;
		dataend= datastart + heap[datamem].nbytes;
		exec_cnx((int)(cnxINIT),initstart,initend,datastart,dataend,
					&dummy,&dummy,0L);
	   if (cnxvars[VAR_ERR]) return 0;
		templong= cnxvars[VAR_EBL];
		if ( !(change_mem(editmem,templong)) ) return 0;
		editleng[side]=templong;
	}
	/* cnxPUTP or cnxETOD: enlarge data buf if it's smaller than edit buf */
	if ( (seg==cnxPUTP) || (seg==cnxETOD) )
	{
		olddataleng= heap[datamem].nbytes;
		if (olddataleng<editleng[side])
			if ( !(change_mem(datamem,editleng[side])) ) return 0;
	}

	/* start and end of edit buffer */
	editstart= heap[editmem].start;
	editend= editstart + heap[editmem].nbytes;

	/* start and end of data buffer */
	datastart= heap[datamem].start;
	dataend= datastart + heap[datamem].nbytes;

	/* patch number */
	cnxvars[VAR_PAT]=pat;

	/* init edit buffer before building it.  That way, parameters not set by
		the cnx code will have valid values */
	if (seg==cnxGETP) set_bytes(editstart,editleng[side],0);
	if (seg==cnxDTOE) initeditbuf(editstart,editend);

	/* if there's a Common segment, exec it first, then exec seg */
	result= exec_seg(windcnxmem[side],seg,datastart,dataend,
						editstart,editend,0L);
	if (result)
	{
		if ( (seg==cnxGETP) || (seg==cnxDTOE) )
		{
			templong= cnxvars[VAR_EBL];
			result= change_mem(editmem,templong);
			if (result) editleng[side]=templong;
		}
		if ( (seg==cnxPUTP) || (seg==cnxETOD) )
		{
			templong= cnxvars[VAR_PTR] ? cnxvars[VAR_PTR] : olddataleng ;
			result= change_mem(datamem,templong);
		}
	}
	return result;

}	/* end putpgetp() */

/* choose a window ..........................................................*/
/* returns 0= left, 1= right, -1= cancel */

choose_side(ptr)
char *ptr;	/* alert box string: cancel/left/right */
{
	register int side;
	int empty[2];
	static int def= 2;	/* previous choice */

	for (side=0; side<2; side++)
		empty[side]= !(heap[windatamem[side]].nbytes);
	switch ( 2*empty[0] + empty[1] )
	{
		case 0:	/* neither empty */
		def= form_alert(def,ptr);
		break;

		case 1:	/* right window empty */
		def=2;
		break;

		case 2:	/* left window empty */
		def=3;
		break;

		case 3:	/* both empty */
		def=1;
	}
	return def-2;
}	/* end choose_side() */

/* EOF */
