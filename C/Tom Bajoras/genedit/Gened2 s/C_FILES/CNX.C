/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module CNX : configuration list / editor

	ex_loadcnx, ex_savecnx, ex_editcnx, init_cnxs
	cnxtocnx, cnftocnx, cnxl_names, cnxl_cursor
	load_cnx, from_cnx, to_cnx
	cnxl_key, drag_cnx, print_cnxl, init_cnx, initcnxname
	choose_cnx, find_cnxextent

******************************************************************************/

overlay "cnx"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */
#include "scan.h"			/* keyboard scan codes */

/* local globals ............................................................*/

int cnxlname[NCNXCOLS]=  { CNXLNAM1, CNXLNAM2, CNXLNAM3 };
int cnxlicon[NCNXICONS]= { CNXLALL , CNXLTRSH, CNXLCLIP, CNXLLEFT,
									CNXLRGHT, CNXLPRNT };
int cnxlhotx[NCNXHOT],cnxlhoty[NCNXHOT];
int cnxlhotw[NCNXHOT],cnxlhoth[NCNXHOT];
int cnxlcursx;					/* character position of text edit cursor */
int cnxlcursn;					/* which slot text edit cursor is in */
long tempcnxleng;				/* single config being copied */
char tempcnxname[NCHPERCNX];
int cnxtempmem;
int nclp_x,nclp_y;			/* center of clipboard */
char windcnxchng[2];			/* window cnx changed while on cnx list page? */

/* local defines ............................................................*/

#define CNXL_ALL	(NCNX+0)	/* indexes into cnxlhotx/y/w/h arrays */
#define CNXL_TRSH	(NCNX+1)
#define CNXL_CLIP	(NCNX+2)
#define CNXL_LEFT	(NCNX+3)
#define CNXL_RGHT	(NCNX+4)
#define CNXL_PRNT	(NCNX+5)

typedef struct {				/* CNX record header + some of its data */
	long type,length;		/* record header */
	int number;
	char name[20];
}	CNXRECORD;

/* load CNX/CNF file ........................................................*/

ex_loadcnx()
{
#if CNXFLAG
	char filename[13],pathname[80];
	int error;
	long load_file();

	/* overwrite changed cnx bank? */
	if (change_flag[cnxCHANGE])
		if (form_alert(1,CHNGECNX)==2) return;

	filename[0]=0;
	tempmem= -1;
	Dsetdrv(cnx_drive); dsetpath(cnx_path);
	if (getfile(pathname,filename,CNXF_EXT,CLDETITL)>0)
	{
		cnx_drive=Dgetdrv(); Dgetpath(cnx_path,cnx_drive+1);
		load_cnx(pathname,filename);
	}
	dealloc_mem(tempmem);
#endif
}	/* end ex_loadcnx() */

/* load CNX/CNF file (also called during autoload) ..........................*/
/* returns 1= error, 0= ok */

load_cnx(pathname,filename)
char *pathname,*filename;
{
#if CNXFLAG
	int error=1;
	long filestart;

	if (load_file(pathname,filename))
	{
		filestart= heap[tempmem].start;
		if ( *(long*)(filestart) == CNXMAGIC )
			error= cnxtocnx(0L);
		else
		{
			if ( *(long*)(filestart+MACBINLENG) == CNXMAGIC )
				error= cnxtocnx(MACBINLENG);
			else
			{
				error= cnftocnx();
				if (!error) new_ext(filename,CNX_EXT);
			}
		}
		if (error)
		{
			init_cnxs();
			change_mem(cnxmem,0L);
		}
		else
		{
			strcpy(cnxfile,filename);
			change_flag[cnxCHANGE]=0;
		}
	}
	return error;
#endif
}	/* end load_cnx() */

/* copy CNX from tempmem buffer to cnxmem buffer ............................*/
/* returns 0= ok, 1= error */

cnxtocnx(file_offset)
long file_offset;
{
	register long ptr,templong;
	register int i;
	int thisnumb;
	FILEHEADER *header;
	CNXRECORD *cnxrecord;
	RECHEADER recheader;
	long thisleng;

	/* error if file version too high */
	header= (FILEHEADER*)(heap[tempmem].start + file_offset);
	if (header->version > cnxheader.version )
	{
		form_alert(1,BADVERSION);
		return 1;
	}

	/* --> first record */
	ptr= heap[tempmem].start + file_offset + sizeof(cnxheader);
	cnxrecord= (CNXRECORD*)ptr;
	templong= 0L;				/* accumulate total length */
	while ( cnxrecord->type == idCNX )
	{
		thisleng= cnxrecord->length ;
		templong += (thisleng-2-NCHPERCNX) ;
		ptr += ( thisleng + sizeof(recheader) ) ;
		cnxrecord= (CNXRECORD*)ptr;
	}
	if (!change_mem(cnxmem,templong)) return 1;

	/* --> first record */
	ptr= heap[tempmem].start + file_offset + sizeof(cnxheader);
	cnxrecord= (CNXRECORD*)ptr;
	templong= 0L;	/* accumulate offset */
	for (i=0; i<NCNX; i++) initcnxname(i,0L);			/* init all names */
	i= 0;				/* start counting configs */
	while ( cnxrecord->type == idCNX )
	{
		/* configs will be in order, but some may be missing */
		thisnumb= cnxrecord->number;
		if (thisnumb>=NCNX) break;
		while (i<thisnumb) cnxoffset[i++]=templong;

		thisleng= cnxrecord->length - 2 - NCHPERCNX ;
		copy_bytes(ptr+sizeof(*cnxrecord),heap[cnxmem].start+templong,thisleng);
		cnxoffset[i]=templong;
		templong += thisleng ;
		copy_bytes(cnxrecord->name,cnxname[i],(long)NCHPERCNX);
		ptr += ( cnxrecord->length + sizeof(recheader) ) ;
		cnxrecord= (CNXRECORD*)ptr;
		i++;
	}
	while (i<=NCNX) cnxoffset[i++]=templong;

	return 0;

}	/* end cnxtocnx() */

/* convert CNF bank (tempmem) to CNX bank (cnxmem) ..........................*/
/* returns 0: ok, non-0: error */

cnftocnx()
{
#if CNXFLAG
	register char *fromptr;
	register long *toptr;
	register int i,n;
	register long templong,newsize;
	long convertcnf();
	long maxsize;
	int error,seg;
	long cnxleng[NCNX];
	static long segtype[2]= { cnxTRAN, cnxRECV };
	char *nptr;

	init_cnxs();	/* start with default */
	set_longs(cnxleng,(long)(NCNX),0L);

	/* expand CNX buffer */
	fill_mem(cnxmem);
	maxsize= heap[cnxmem].nbytes;

	newsize=0L;			/* total cnx length (code + segtypes + seglengs) */
	fromptr= (char*)(heap[tempmem].start);
	toptr= (long*)(heap[cnxmem].start);

	for (error=i=0; !error&&(i<NCNF); i++)
	{
		n= *(int*)(fromptr);			/* # bytes in transmit set */
		if ( (n<0) || (n&1) ) { error=1; break; }	/* weird */
		/* --> prompt / addl offset byte, apparently shared between
			recv and tran segments! */
		nptr= fromptr+2;

		/* CNX name */
		fromptr += 3;
		copy_bytes(fromptr,cnxname[i],(long)(NCHPERCNX));
		fromptr += (NCHPERCNX+1);

		for (seg=0; seg<=1; seg++)
		{
			templong= convertcnf(fromptr,nptr,0L,n,0);	/* calc length of code */
			if (templong<0L) return 1;					/* err msg inside convertcnf */
			if (templong)
			{
				newsize += (8+templong);			/* accumulate size of cnxmem */
				cnxleng[i] += (8+templong);		/* accumulate size of this cnx */
				if (newsize>maxsize) { error=2; break; }			/* too big */
				*toptr++= segtype[seg];									/* seg type */
				*toptr++= templong;										/* seg length */
				convertcnf(fromptr,nptr,toptr,n,1);					/* code */
				toptr = (long*)( (long)toptr + templong );
			}
			fromptr+=n;
			if (!seg)
			{
				n= *(int*)(fromptr);					/* # bytes in receive segment */
				fromptr+=2;
				if ( (n<0) || (n&1) ) { error=1; break; }	/* weird */
			}
		}
	}
	switch (error)
	{
		case 0:
		if (change_mem(cnxmem,newsize))	/* cnxoffset[0]=0L in init_cnxs above */
			for (i=0; i<NCNX; i++) cnxoffset[i+1]= cnxoffset[i]+cnxleng[i];
		else
			error=1;
		break;

		case 1:
		case 2:
		form_alert( 1, error==1 ? BADINSTR : BADMEM2 );
	}	/* end switch (error) */
	return error;
#endif
}	/* end cnftocnx() */

/* save CNX file ............................................................*/

ex_savecnx()
{
#if CNXFLAG
	char filename[13],pathname[80];
	long addr[1+2*NCNX+1],leng[1+2*NCNX+1];
	CNXRECORD cnxrecord[NCNX];
	RECHEADER recheader;	/* prototype */
	register int i,j;
	long thisleng;
	long end_record= idEND;

	strcpy(filename,cnxfile);
	Dsetdrv(cnx_drive);
	dsetpath(cnx_path);
	if (getfile(pathname,filename,CNX_EXT,CSAVTITL)>0)
	{
		cnx_drive=Dgetdrv();
		Dgetpath(cnx_path,cnx_drive+1);

		j=0;	/* count how many blocks to be written to disk */
		addr[j]= (long)(&cnxheader);	/* first block is file header */
		leng[j++]= sizeof(cnxheader);
		/* other blocks:  2 for each config (record header + data) */
		for (i=0; i<NCNX; i++)
		{
			if (!iscnxinit(i))
			{
				thisleng= cnxoffset[i+1] - cnxoffset[i] ;
				cnxrecord[i].type= idCNX;
				cnxrecord[i].length= thisleng + 2 + NCHPERCNX ;
				cnxrecord[i].number= i;
				copy_bytes(cnxname[i],cnxrecord[i].name,(long)NCHPERCNX);
				addr[j]= (long)(&cnxrecord[i]);
				leng[j++]= sizeof(cnxrecord[i]);
				addr[j]= heap[cnxmem].start+cnxoffset[i];
				leng[j++]= thisleng;
			}
		}
		addr[j]= (long)(&end_record);
		leng[j++]= 4;
		if (save_file(filename,pathname,j,addr,leng))
		{
			change_flag[cnxCHANGE]=0;
			strcpy(cnxfile,filename);
		}
	}	/* end if got a file from file selector */
#endif
}	/* end ex_savecnx() */

/* find a config by its extension ...........................................*/
/* returns (0-(NCNX-1)), -1 none found */

find_cnxextent(extent)
char *extent;
{
	register int i;

	for (i=0; i<NCNX; i++)
		if ( !(comp_bytes(&cnxname[i][NCHPERCNX-3], extent, 3L)) )
			return i;
	return -1;
}

/* choose a non-empty config ................................................*/
/* returns 0-(NCNX-1), -1 cancel */

choose_cnx(def_cnxnum)
int def_cnxnum;	/* default config #, -1 none */
{
	register int i,n;
	int def_i;
	int which;
	char *the_names[NCNX];
	char *tempnames;

	/* buffer for null-term'd config names */
	tempnames= (char*)cnxscrsave;

	/* find and count all non-empty configs, copy their names to buffer */		
	def_i= -1;
	for (n=i=0; i<NCNX; i++)
	{
		if ( cnxoffset[i+1] - cnxoffset[i] )
		{
			if (i==def_cnxnum) def_i=n;
			copy_bytes(&cnxname[i][0],tempnames,(long)(NCHPERCNX));
			the_names[n++]= tempnames;
			tempnames[NCHPERCNX]=0;
			tempnames += (NCHPERCNX+1);
		}
	}

	/* all the configs are empty! */
	if (n==0) return -1;

	/* choose one */
	which= pop_up(CHOOSECNXMSG,def_i,n,0L,0,the_names);

	/* convert chosen one to config slot # */
	if (which<0)
		i= -1;
	else
	{
		for (i=n=0; i<NCNX; i++)
		{
			if ( cnxoffset[i+1] - cnxoffset[i] )
			{
				if (which==n) break;
				n++;
			}
		}
	}
	return i;
}

/* CNX list editor ..........................................................*/

ex_editcnx()
{
#if CNXFLAG
	int exit_obj,edit_obj,mstate,done,mousex,mousey;
	int x,y,kstate,key;
	register int temp,i,side;
	register long templong;
	register char *ptr;
	static char fixed;
	char tempbuf[80],charbuf1[12],charbuf2[12];

	/* temporary buffer for copying configs */
	cnxtempmem= alloc_mem(0L);
	if (cnxtempmem<0) return;

	/* window configs not changed yet */
	windcnxchng[0]= windcnxchng[1]= 0;

	/* file name */
	strcpy(ptr=cnxladdr[CNXLTITL].ob_spec,CNXL_MSG);
	strcat(ptr,cnxfile);

	/* dialog box covers entire screen */
	full_dial(cnxladdr);

	/* compensate for rsrc_load not correctly scaling icons */
	/* use fix_icons() !!! */
	if ( (rez==1) && !fixed )
	{
		cnxladdr[CNXLICON].ob_height *= 2;

		cnxladdr[CNXLTRSH].ob_height *= 2;
		cnxladdr[CNXLPRNT].ob_height *= 2;
		cnxladdr[CNXLLEFT].ob_height *= 2;
		cnxladdr[CNXLRGHT].ob_height *= 2;
		cnxladdr[CNXLCLIP].ob_height *= 2;
		cnxladdr[CNXLALL ].ob_height *= 2;
		cnxladdr[CNXLLEFT].ob_y *= 2;
		cnxladdr[CNXLRGHT].ob_y *= 2;
		cnxladdr[CNXLCLIP].ob_y *= 2;
		cnxladdr[CNXLALL ].ob_y *= 2;
		fixed=1;
	}
	objc_offset(cnxladdr,CNXLCLIP,&nclp_x,&nclp_y);
	nclp_x += (cnxladdr[CNXLCLIP].ob_width/2);
	nclp_x -= charw;
	nclp_x /= charw;
	nclp_y += (cnxladdr[CNXLCLIP].ob_height/2);
	nclp_y -= charh/2;
	nclp_y += 3;

	/* display dialog */
	putdial(cnxladdr,1,0);
	encode_nclp();	/* # of cnx's on clipboard */

	/* find hot spots */
	for (i=temp=0; temp<NCNXCOLS; temp++)
	{
		objc_offset(cnxladdr,cnxlname[temp],&x,&y);
		asm { move.w temp,-(a7) }
		for (temp=0; temp<(NCNX/NCNXCOLS); temp++)
		{
			cnxlhotx[i]= x;
			cnxlhoty[i]= y + temp*charh;
			cnxlhotw[i]= charw*NCHPERCNX;
			cnxlhoth[i++]= charh;
		}
		asm { move.w (a7)+,temp }
	}
	for (temp=0; temp<NCNXICONS; temp++)
	{
		objc_offset(cnxladdr,cnxlicon[temp],&x,&y);
		cnxlhotx[i]= x;
		cnxlhoty[i]= y;
		cnxlhotw[i]=	cnxladdr[cnxlicon[temp]].ob_width;
		cnxlhoth[i++]=	cnxladdr[cnxlicon[temp]].ob_height;
	}
	/* draw names */
	cnxlcursx= cnxlcursn= 0;
	cnxl_names(-1);
	
	edit_obj= -1;
	done=0;
	do
	{
		key=0;			/* clear out previous key */
		exit_obj= my_form_do(cnxladdr,&edit_obj,&mstate,1,&key);
		getmouse(&mousex,&mousey);
		kstate= Kbshift(-1) & 0x0F;	/* only alt/ctrl/shift */
		if (key) exit_obj= cnxl_key(key,kstate);
		switch (exit_obj)
		{
			case CNXLEXIT:
			done=1;
			break;

			case CNXLALL :
			if (kstate==K_ALT)
				i= CNXL_TRSH;			/* alt-click = all to trash */
			else
				i= drag_cnx(CNXL_ALL);
			switch (i)
			{
				case -1:	break;		/* all to nowhere */

				case CNXL_TRSH:		/* all to trash */
				temp= form_alert(1,change_flag[cnxCHANGE] ? CHNGECNX : CHEKCINIT );
				if (temp==1)
				{
					init_cnxs();
					change_mem(cnxmem,0L);
					strcpy(ptr=cnxladdr[CNXLTITL].ob_spec,CNXL_MSG);
					draw_object(cnxladdr,CNXLTITL);
					cnxl_names(-1);
					change_flag[cnxCHANGE]=0;
				}
				break;

				case CNXL_CLIP:		/* all non-empty slots to clip */
				if (ncnxlclip==NCNX) break;	/* clip full */
				for (i=0; (i<NCNX)&&(ncnxlclip<NCNX); i++)	/* until clip full */
				{
					if (cnxoffset[i]!=cnxoffset[i+1])
					{
						temp= from_cnx(i);
						if (temp) temp= to_cnx(CNXL_CLIP);
						if (!temp) break;
					}
				}
				encode_nclp();
				break;

				case CNXL_PRNT:		/* all to printer */
				temp=1;
				while ( !(temp=Cprnos()) )
					if (form_alert(1,BADPRINT)!=1) break;
				if (temp) print_cnxl();
			}
			break;

			case CNXLCLIP:
			if (!ncnxlclip) break;	/* empty clipboard */
			switch (kstate)
			{
				case 0:					/* clip to somewhere */
				i=drag_cnx(CNXL_CLIP);
				break;
				
				case K_CTRL:			/* clip to first available slot */
				for (i=0; i<NCNX; i++) if (iscnxinit(i)) break;
				if (i==NCNX) i= -1;	/* no slots available */
				break;
				
				case K_ALT:				/* clip to trash */
				i= CNXL_TRSH;
				break;
				
				default:
				i= -1;
			}	/* end switch (kstate) */
			switch (i)
			{
				case -1: break;		/* clip to nowhere */

				case CNXL_ALL:			/* clip to available slots */
				HIDEMOUSE;
				for (i=0; (i<NCNX)&&ncnxlclip; i++)		/* until clip empty */
				{
					if (iscnxinit(i))
					{
						temp= from_cnx(CNXL_CLIP);
						if (temp) temp= to_cnx(i);
						if (!temp) break;
						change_flag[cnxCHANGE]=1;
					}
				}
				SHOWMOUSE;
				break;

				case CNXL_TRSH:		/* clip to trash */
				if (form_alert(1,CHEKCLRCLIP)==1)
				{
					set_longs(cnxlclpoff,(long)(NCNX+1),0L);
					change_mem(cnxlclpmem,0L);
					ncnxlclip=0;
				}
				break;

				default:					/* clip to L/R/slot */
				if (from_cnx(CNXL_CLIP)) to_cnx(i);
			}
			encode_nclp();
			break;

			case CNXLLEFT:
			case CNXLRGHT:
			temp= exit_obj==CNXLRGHT;		/* 0= left, 1= right */
			if (kstate==K_ALT)
				i= CNXL_TRSH;					/* alt-click = L/R to trash */
			else
				i=drag_cnx(CNXL_LEFT+temp);
			switch (i)
			{
				case -1:	break;				/* L/R to nowhere */

				case CNXL_TRSH:				/* L/R to trash */
				change_mem(windcnxmem[temp],0L);
				initcnxname(-1,windcnxname[temp]);
				windcnxchng[temp]=1;
				break;

				case CNXL_PRNT:				/* L/R to printer */
				templong= heap[i=windcnxmem[temp]].start;
				print_cnx(windcnxname[temp],templong,templong+heap[i].nbytes);
				break;

				default:							/* L/R to slot/clip/L/R */
				if (from_cnx(CNXL_LEFT+temp)) to_cnx(i);
				if (i==CNXL_CLIP) encode_nclp();
			}
			break;

			case CNXLNAM1:
			case CNXLNAM2:
			case CNXLNAM3:
			if (exit_obj==CNXLNAM1) temp=0;
			if (exit_obj==CNXLNAM2) temp=1;
			if (exit_obj==CNXLNAM3) temp=2;
			i= (mousey - cnxlhoty[0] ) / charh ;		/* row # */
			if ((i<0)||(i>=(NCNX/NCNXCOLS))) break;
			/* force mouse to vertical center of row */
			if (kstate!=K_ALT) setmouse(-1 , i*charh + cnxlhoty[0] + charh/2 );
			i += temp*(NCNX/NCNXCOLS);						/* slot # */
			temp=  (mousex-cnxlhotx[i])/charw;			/* character # */
		/* move cursor: new slot, new character */
			if (i!=cnxlcursn)
			{
				cnxl_cursor();
				cnxlcursx=temp;
				cnxlcursn=i;
				cnxl_cursor();
			}
		/* move cursor: same slot, new character */
			if (temp!=cnxlcursx)
			{
				cnxl_cursor();
				cnxlcursx=temp;
				cnxl_cursor();
			}
		/* checksum and size of slot */
			if (kstate==(K_LSHIFT|K_CTRL|K_ALT))
			{
				templong= heap[cnxmem].start;
/* !!!...
	temp= checksum(templong+cnxoffset[i],templong+cnxoffset[i+1]);
*/
				temp= crc16(templong+cnxoffset[i],templong+cnxoffset[i+1]);
				templong= cnxoffset[i+1] - cnxoffset[i];
				itoa(temp,charbuf1,-1);
				ltoa(templong,charbuf2,-1);
				strcpy(tempbuf,CNXCHKMSG1);
				strcat(tempbuf,charbuf1);
				strcat(tempbuf,CNXCHKMSG2);
				strcat(tempbuf,charbuf2);
				strcat(tempbuf,CNXCHKMSG3);
				menuprompt(tempbuf);
				waitmouse();
				while (!getmouse(&dummy,&dummy));
				menuprompt(0L);
				break;
			}
		/* edit the slot */
			if (mstate>0)
			{
				dealloc_mem(cnxtempmem);
				edit_cnx(i);
				cnxtempmem= alloc_mem(0L);	/* this shouldn't ever fail */
				objc_draw(cnxladdr,ROOT,MAX_DEPTH,0,0,640,200*rez);
				encode_nclp();
				cnxl_names(-1);
				waitmouse();
				break;
			}
		/* drag the slot */
			switch (kstate)
			{
				case K_ALT:
				temp=CNXL_TRSH; 			/* alt-click = init (with mouse repeat) */
				mstate=0;
				break;
				
				case K_CTRL:				/* control-click = copy to clip */
				case K_CTRL|K_LSHIFT:	/* control-shift-click = move to clip */
				case K_CTRL|K_RSHIFT:
				temp=CNXL_CLIP;
				break;
				
				case 0:
				case K_LSHIFT:
				case K_RSHIFT:
				temp= drag_cnx(i);	/* temp!=i */
				break;

				default: temp= -1;
			}	/* end switch kstate */
			switch (temp)		/* i= source, temp= destination (i!=temp) */
			{
				case -1:	break;				/* slot to nowhere */

				case CNXL_TRSH:				/* slot to trash */
				if (!iscnxinit(i))
				{
					init_cnx(i);
					cnxl_names(i);
					change_flag[cnxCHANGE]=1;
				}
				break;

				case CNXL_PRNT:				/* slot to printer */
				templong= heap[cnxmem].start;
				print_cnx(cnxname[i],templong+cnxoffset[i],templong+cnxoffset[i+1]);
				break;

				default:							/* slot to slot/L/R/clip */
				if (from_cnx(i))
				{
					if (to_cnx(temp))
					{
						if (kstate&(K_LSHIFT|K_RSHIFT))	/* shift-drag = "move" */
						{
							init_cnx(i);
							cnxl_names(i);
							change_flag[cnxCHANGE]=1;
						}
						if (temp==CNXL_CLIP) encode_nclp();
					}
				}
			}	/* end switch (destination) */
		}	/* end switch (exit_obj) */
		if (mstate) waitmouse();
	}
	while (!done);
	putdial(0L,0,exit_obj);
	dealloc_mem(cnxtempmem);

	/* window config(s) changed? */
	for (side=0; side<2; side++)
	{
		if (windcnxchng[side])
		{
			i= find_device(&windcnxname[side][NCHPERCNX-3]);
			if (i<0)
				init_device(&wind_device[side]);
			else
				wind_device[side]= studioDev[i];
			draw_window(side);
			change_flag[side ? rdatCHANGE : ldatCHANGE]= 1;
		}
	}
#endif
}	/* end ex_editcnx() */

/* returns hot spot under mouse when button let up, -1 none .................*/

drag_cnx(which)
register int which;			/* CNXL_xxxx */
{
#if CNXFLAG
	register int nhot,i;
	int x,y,w,h,tempx,tempy;
	char dest[NCNXHOT];
	int hotx[NCNXHOT],hoty[NCNXHOT],hotw[NCNXHOT],hoth[NCNXHOT];

	/* build array of possible destinations: start with nothing */
	set_bytes(dest,(long)(NCNXHOT),0);
	/* all can't go to slots, but anything else can */
	set_bytes(dest,(long)(NCNX),which!=CNXL_ALL);
	/* anything can be dragged to trash */
	dest[CNXL_TRSH]= 1;
	/* anything except clip can be dragged to clip or printer */
	if (which!=CNXL_CLIP) dest[CNXL_CLIP]= dest[CNXL_PRNT]= 1;
	/* anything except all can be dragged to L/R */
	if (which!=CNXL_ALL) dest[CNXL_LEFT]= dest[CNXL_RGHT]= 1;
	/* only clip can go to all */
	if (which==CNXL_CLIP) dest[CNXL_ALL]= 1;
	dest[which]=0;			/* can't drag to self */
	if (ncnxlclip==NCNX) dest[CNXL_CLIP]=0;	/* can't drag to full clip */

	for (nhot=i=0; i<NCNXHOT; i++)
	{
		if (dest[i])
		{
			hotx[nhot]=		cnxlhotx[i];
			hoty[nhot]= 	cnxlhoty[i];
			hotw[nhot]= 	cnxlhotw[i];
			hoth[nhot++]=	cnxlhoth[i];
		}
	}

	/* coordinates of source */
	x= cnxlhotx[which];
	y= cnxlhoty[which];
	w= cnxlhotw[which];
	h= cnxlhoth[which];

	/* invert source */
	cnxl_cursor();				/* hide cursor */
	vswr_mode(gl_hand,3);
	fill_rect(x,y,w,h,1);
	vswr_mode(gl_hand,1);

	tempx=x; tempy=y;
	slide_box(&tempx,&tempy,w,h,0,0,640,200*rez,
				 nhot,hotx,hoty,hotw,hoth,hotx,hoty,hotw,hoth);

	/* re-invert source */
	vswr_mode(gl_hand,3);
	fill_rect(x,y,w,h,1);
	vswr_mode(gl_hand,1);
	cnxl_cursor();				/* show cursor */

	getmouse(&x,&y);
	for (i=0; i<NCNXHOT; i++)
		if (in_rect(x,y,cnxlhotx[i],cnxlhoty[i],cnxlhotw[i],cnxlhoth[i])) break;
	if ( (i==NCNXHOT) || !dest[i] ) i= -1;
	return i;
#endif
}	/* end drag_cnx() */

/* copy from slot/L/R/clip ..................................................*/
/* returns 1= ok, 0= error */

from_cnx(which)
int which;				/* CNXL_xxxx */
{
	long leng,cnxptr;
	char *nameptr;
	int temp;

	/* length of cnx */
	switch (which)
	{
		case CNXL_LEFT:
		case CNXL_RGHT:
		leng= heap[windcnxmem[which-CNXL_LEFT]].nbytes;
		break;

		case CNXL_CLIP:
		leng= cnxlclpoff[ncnxlclip] - cnxlclpoff[ncnxlclip-1];
		break;

		default:				/* slot */
		leng= cnxoffset[which+1] - cnxoffset[which];
	}

	/* adjust size of temporary buffer */
	if (!change_mem(cnxtempmem,leng)) return 0;
	tempcnxleng=leng;

	graf_mouse(BEE_MOUSE);

	/* source pointers */
	switch (which)
	{
		case CNXL_LEFT:
		case CNXL_RGHT:
		temp= which-CNXL_LEFT;	/* 0= left, 1= right */
		cnxptr= heap[windcnxmem[temp]].start;
		nameptr= &windcnxname[temp][0];
		break;

		case CNXL_CLIP:
		cnxptr= heap[cnxlclpmem].start + cnxlclpoff[ncnxlclip-1];
		nameptr= &cnxlclpname[ncnxlclip-1][0];
		ncnxlclip--;
		break;

		default:				/* slot */
		cnxptr= heap[cnxmem].start + cnxoffset[which];
		nameptr= &cnxname[which][0];
	}

	copy_words(cnxptr,heap[cnxtempmem].start,leng/2);
	copy_bytes(nameptr,tempcnxname,(long)(NCHPERCNX));

	if (which==CNXL_CLIP)
		change_mem(cnxlclpmem,heap[cnxlclpmem].nbytes-leng);

	graf_mouse(ARROWMOUSE);

	return 1;

}	/* end from_cnx() */

/* copy to slot/L/R/clip ....................................................*/
/* returns 1= ok, 0= error */

to_cnx(which)
register int which;				/* CNXL_xxxx */
{
	long cnxptr,from_ptr,to_ptr,end_ptr,segtype,segleng;
	char *nameptr;
	register int i;
	register long templong;
	register char *ptr;
	int result;

	/* default: error */
	cnxptr= 0L;
	result=0;

	graf_mouse(BEE_MOUSE);

	/* copy to where? */
	switch (which)
	{
		case CNXL_LEFT:
		case CNXL_RGHT:
		i= which-CNXL_LEFT;		/* 0= left, 1= right */
		windcnxchng[i]=1;
		nameptr= &windcnxname[i][0];
		i= windcnxmem[i];
		if (change_mem(i,tempcnxleng)) cnxptr= heap[i].start;
		break;

		case CNXL_CLIP:
		if (ncnxlclip<NCNX)		/* can't drag to full clip */
		{
			templong= heap[cnxlclpmem].nbytes+tempcnxleng;
			if (change_mem(cnxlclpmem,templong))
			{
				cnxptr= heap[cnxlclpmem].start + templong - tempcnxleng;
				nameptr= &cnxlclpname[ncnxlclip][0];
				ncnxlclip++;
				for (i=ncnxlclip; i<=NCNX; i++)
					cnxlclpoff[i]= cnxlclpoff[ncnxlclip-1]+tempcnxleng;
			}
		}
		break;

		default:							/* slot */
		cnxptr= 0L;	/* in case change_mem() fails */
		nameptr= &cnxname[which][0];
		templong= tempcnxleng - (cnxoffset[which+1]-cnxoffset[which]) ;
		if (templong==0L)		/* no change in size */
			cnxptr= heap[cnxmem].start + cnxoffset[which];
		if (templong>0L)		/* slot gets bigger */
		{
			if (change_mem(cnxmem,heap[cnxmem].nbytes+templong))
			{
				/* insert bytes at end of cnx slot -- use insert_bytes() !!! */
				asm { move.l templong,-(a7) }
				for (ptr=(char*)(heap[cnxmem].start)+cnxoffset[NCNX]-1+templong;
					ptr>=(char*)(heap[cnxmem].start)+cnxoffset[which+1]+templong;
						ptr--) ptr[0]=ptr[-templong];
				asm { move.l (a7)+,templong }

				for (i=which+1; i<=NCNX; i++) cnxoffset[i]+=templong;
				cnxptr= heap[cnxmem].start + cnxoffset[which];
			}
		}
		if (templong < 0L)
		{
			/* delete -templong bytes at end of cnx slot */
			templong= -templong;

			for (ptr=(char*)(heap[cnxmem].start)+cnxoffset[which+1]-templong;
				ptr<=(char*)(heap[cnxmem].start)+cnxoffset[NCNX]-templong-1;
					ptr++) ptr[0]= ptr[templong];

			if (change_mem(cnxmem,heap[cnxmem].nbytes-templong))
			{
				for (i=which+1; i<=NCNX; i++) cnxoffset[i]-=templong;
				cnxptr= heap[cnxmem].start + cnxoffset[which];
			}
		}

	}	/* end switch (which) */

	if (cnxptr)
	{
		/* do the copy */
		copy_words(heap[cnxtempmem].start,cnxptr,tempcnxleng/2);
		copy_bytes(tempcnxname,nameptr,(long)(NCHPERCNX));

		/* redraw destination (if slot) */
		if (which<NCNX)
		{
			cnxl_names(which);
			change_flag[cnxCHANGE]=1;
		}
		result=1;
	}

	graf_mouse(ARROWMOUSE);

	return result;
}	/* end to_cnx() */

/* encode # cnx's on clipboard ..............................................*/

encode_nclp()
{
	char buf[3];

	if (ncnxlclip)
		itoa(ncnxlclip,buf,2);
	else
		strcpy(buf,"  ");
	gr_text(buf,nclp_x,nclp_y);

}	/* end encode_nclp() */

/* draw name(s) on CNX list page ............................................*/

cnxl_names(which)
int which;		/* -1 for all */
{
#if CNXFLAG
	register int i,j,c,r;
	char namebuf[NCHPERCNX+1];
	int x,y;

	HIDEMOUSE;
	for (i=c=0; c<NCNXCOLS; c++)
	{
		objc_offset(cnxladdr,cnxlname[c],&x,&y); x/=charw;
		for (r=0; r<(NCNX/NCNXCOLS); r++,i++,y+=charh)
		{
			if ((which<0)||(which==i))
			{
				for (j=0; j<(NCHPERCNX-3); j++)
				{
					namebuf[j]= cnxname[i][j];
					if (!namebuf[j]) namebuf[j]= '-';
				}
				namebuf[j]=0;
				gr_text(namebuf,x,y);
				for (; j<NCHPERCNX; j++)
				{
					namebuf[j]= cnxname[i][j];
					if (!namebuf[j]) namebuf[j]= '-';
				}
				namebuf[j]=0;
				gr_color= RD_ON_WH;
				x+=(NCHPERCNX-3);
				gr_text(&namebuf[NCHPERCNX-3],x,y);
				gr_color= BL_ON_WH;
				if (rez==2) halftext(3,x,y);
				x-=(NCHPERCNX-3);
				if (i==cnxlcursn) cnxl_cursor();	/* gr_text trashed cursor */
			}
		}
	}
	SHOWMOUSE;
#endif
}	/* end cnxl_names() */

/* handle key typed in cnxl dialog box ......................................*/

cnxl_key(i,kstate)				/* returns equivalent object # */
register int i;					/* high byte is scan code, low byte is ascii */
int kstate;							/* modifier keys */
{
#if CNXFLAG
	register int asci,scan;
	int new_x,new_n;
	char tempbuf[NCHPERCNX+1];
	int x,y;

	asci= i&0xff;
	scan= i>>8;

	switch (scan)
	{
		case SCAN_ESC:
		return CNXLEXIT;

		case SCAN_CLR:
		initcnxname(cnxlcursn,0L);
		cnxlcursx=0;
		cnxl_names(cnxlcursn);
		scan=0;
		break;

		case SCAN_BS:
		cnxl_key(SCAN_LEFT<<8,0);
		asci= ' ';
		scan= -1;	/* so that default doesn't move cursor forward */
		/* falls through to default case */

		default:
		if ( (asci>=' ') && (asci<='~') )	/* replace character at cursor */
		{
			tempbuf[0]= cnxname[cnxlcursn][cnxlcursx]= asci;
			tempbuf[1]=0;
			x= cnxlhotx[cnxlcursn]/charw + cnxlcursx ;
			y= cnxlhoty[cnxlcursn];
			gr_color= cnxlcursx<(NCHPERCNX-3) ? BL_ON_WH : RD_ON_WH;
			gr_text(tempbuf,x,y);
			gr_color= BL_ON_WH;
			if ( (cnxlcursx>=(NCHPERCNX-3)) && (rez==2) ) halftext(1,x,y);
			cnxl_cursor();
			scan= scan>=0 ? SCAN_RIGHT : 0;		/* right, except for backspace */
			change_flag[cnxCHANGE]=1;
		}
	}	/* end switch (scan) */

	switch (scan)
	{
		case SCAN_RIGHT:
		case SCAN_LEFT:
		new_x= cnxlcursx + (scan==SCAN_RIGHT ? 1 : -1) ;
		new_n= cnxlcursn;
		if (new_x<0)
		{
			new_x= NCHPERCNX-1;
			new_n -= (NCNX/NCNXCOLS);
		}
		if (new_x==NCHPERCNX)
		{
			new_x=0;
			new_n += (NCNX/NCNXCOLS);
		}
		break;

		case SCAN_TAB:
		new_x= 0;
		i= NCNX/NCNXCOLS;
		if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT)) i= -i;
		new_n= cnxlcursn+i;
		if (new_n<0)
		{
			if (cnxlcursn==0)
				new_n= NCNX-1;
			else
			{
				new_n += (NCNX-1);
				if (new_n<0) new_n= NCNX-1 ;
			}
		}
		if (new_n>=NCNX)
		{
			if (cnxlcursn==(NCNX-1))
				new_n= 0;
			else
			{
				new_n -= (NCNX-1);
				if (new_n>=NCNX) new_n=0;
			}
		}
		break;

		case SCAN_UP:
		case SCAN_DOWN:
		new_n= cnxlcursn + (scan==SCAN_DOWN ? 1 : -1 ) ;
		new_x= cnxlcursx;
		break;

		default:			/* no effect */
		new_n= new_x= -1;
	}

	if ( (new_n>=0) && (new_n<NCNX) && (new_x>=0) && (new_x<NCHPERCNX) )
	{
		cnxl_cursor();
		cnxlcursn= new_n;
		cnxlcursx= new_x;
		cnxl_cursor();
	}

	return -1;
#endif
}	/* end cnxl_key() */

/* xor the single character cursor ..........................................*/

cnxl_cursor()
{
	xortext(1,cnxlhotx[cnxlcursn]/charw+cnxlcursx,cnxlhoty[cnxlcursn]);
}	/* end cnxl_cursor() */

/* print cnx list ...........................................................*/

print_cnxl()
{
#if CNXFLAG
	register int r,c,i;
	char line[3*NCHPERCNX+20];
	char namebuf[NCHPERCNX+1];

	menuprompt(NOWPRINTMSG);
	graf_mouse(BEE_MOUSE);
	Cprnws(cnxladdr[CNXLTITL].ob_spec,1);
	Cprnws(" ",1);

	for (r=0; r<(NCNX/NCNXCOLS); r++)
	{
		line[0]=0;
		for (c=0; c<NCNXCOLS; c++)
		{
			i= c*(NCNX/NCNXCOLS) + r;
			copy_bytes(&cnxname[i][0],namebuf,(long)(NCHPERCNX));
			namebuf[NCHPERCNX]=0;
			strcat(line,namebuf);
			strcat(line,"    ");
		}
		if (getmouse(&dummy,&dummy)) break;		/* mouse button aborts printing */
		Cprnws(line,1);
	}
	waitmouse();
	graf_mouse(ARROWMOUSE);
	menuprompt(0L);
#endif
}	/* end print_cnxl() */

/* initialize a single CNX ..................................................*/

init_cnx(i)
register int i;
{
#if CNXFLAG
	long oldsize;
	register long ptr1,ptr2;

	if (oldsize= cnxoffset[i+1]-cnxoffset[i])	/* if not already init'd */
	{
		/* delete the CNX from heap */
		ptr1= heap[cnxmem].start + cnxoffset[i];
		ptr2= ptr1+oldsize;
		copy_bytes(ptr2,ptr1,heap[cnxmem].start+cnxoffset[NCNX]-ptr2);
		change_mem(cnxmem,heap[cnxmem].nbytes-oldsize);

		/* update offsets */
		asm { move.w i,-(a7) }
		for (i++; i<=NCNX; i++) cnxoffset[i]-=oldsize;
		asm { move.w (a7)+,i }
	}

	/* name */
	initcnxname(i,0L);
#endif
}	/* end init_cnx() */

/* initialize a CNX name ....................................................*/

initcnxname(i,ptr)
int i;
char *ptr;
{
	if (i>=0) ptr= &cnxname[i][0];
	set_bytes(ptr,(long)NCHPERCNX,0);
}	/* end initcnxname() */

/* is a CNX slot empty and unnamed? .........................................*/
/* returns 1=yes, 0= no */

iscnxinit(i)
register int i;
{
	register int j;

	if ( cnxoffset[i+1] - cnxoffset[i] ) return 0;
	for (j=0; j<NCHPERCNX; j++) if (cnxname[i][j]) break;
	return j==NCHPERCNX;
}	/* end iscnxinit() */

/* initialize all CNXs ......................................................*/

init_cnxs()
{
	register int i;

	for (i=0; i<NCNX; i++) initcnxname(i,0L);
	set_longs(cnxoffset,(long)(NCNX+1),0L);
	change_flag[cnxCHANGE]= cnxfile[0]= 0;
}	/* end init_cnxs() */

/* EOF */
