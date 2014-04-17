/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module EBDT : EBDT editor

	do_ebdt, do_ebdtkey, draw_ebdt, draw_1ebdt, ebdt_slider
	ebdt_curs, edit_ebdt, decode_ebdt, encode_ebdt
	re_ebdt, del_ebdt, adjust_ebdt, n_of_ebdt

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

/* local globals ............................................................*/

EBDT *ebdtptr;
int n_ebdt,maxn_ebdt;
int ebdt_mem;
int home_ebdt,ebdt_cursor,ebdt_nrows;
char ebdtcursor[2]= { 3, 0 };	/* arrow pointing to right */
int ebdt_x[NEBDTCOLS],ebdt_y;
int ebdtcol[NEBDTCOLS]= {
	EBDTCOL1,EBDTCOL2,EBDTCOL3,EBDTCOL4,EBDTCOL5
};
int ebdtcursx;			/* text column for cursor */
EBDT init_ebdt= {
	0L,
	"                               ",
	1,
	0L,0L
} ;
int fieldleng[NEBDTCOLS]= { 5, 31, 1, 6, 6 };

/* variables in tem .........................................................*/

extern long curr_leng;
extern int curr_mem,curr_page,curr_nctrls;
extern CTRLHEADER ctrlheader;

/* edit the edbt ............................................................*/
/* must be called from within template editor */

do_ebdt()
{
#if EBDTFLAG
	int done,edit_obj,exit_obj,mstate,key,kstate,mousey;
	int undo_mem,undo_n,y;
	long dummylong;
	register int i,j;
	register EBDT *iptr;
	static int lastpacktype=1; /* 1= from start, 2= from cursor */

	/* shrink curr_page */
	change_mem(curr_mem,curr_leng);

	/* get handle and size of ebdt */
	ebdt_mem= temmem[ seg_to_mem(idTEMEBDT) ] ;
	n_ebdt= n_of_ebdt(&dummylong);

	/* create an undo buffer */
	undo_n= -1;
	undo_mem= alloc_mem(0L);
	if (undo_mem>=0)
		if (copy_mem(ebdt_mem,undo_mem))
			undo_n= n_ebdt;
	if (undo_n<0) goto exit_ebdt;

	/* expand ebdt, compute maxn_ebdt and ebdtptr */
	expand_ebdt();

	/* backup indexes of all ebdt controls */
	adjust_ebdt(2,dummy);

	/* how many entries can be displayed? */
	ebdt_nrows= ebdtaddr[EBDTCOL1].ob_height / charh ;

	/* draw the dialog box shell */
	home_ebdt= 0;
	ebdt_slider(0);
	tem_prompt(EBDT_TITL);
	ebdtaddr[0].ob_y= 200*rez - (temheader.page_h - 2) ;
	ebdtaddr[0].ob_x= 320 - ebdtaddr[0].ob_width/2 ;
	putdial(ebdtaddr,1,0);

	/* find things */
	objc_offset(ebdtaddr,EBDTCURS,&ebdtcursx,&dummy);
	ebdtcursx= ebdtcursx/charw + 1 ;
	for (i=0; i<NEBDTCOLS; i++)
	{
		objc_offset(ebdtaddr,ebdtcol[i],&ebdt_x[i],&ebdt_y);
		ebdt_x[i] = ebdt_x[i]/charw + 1 ;
		if (i==0) ebdt_x[i] += 1;	/* the '+' of offset isn't editable */
		if (i==2) ebdt_x[i] += 2;	/* center the "bytes" column */
	}
	ebdt_y++;

	/* position the cursor and draw it */
	ebdt_cursor= 0;
	ebdt_curs(1);

	/* draw the entries */
	draw_ebdt();

	done=0;
	edit_obj= -1;
	do
	{
		key=0;
		*keyb_head= *keyb_tail;			/* no type-ahead */
		exit_obj= my_form_do(ebdtaddr,&edit_obj,&mstate,1,&key);
		kstate = Kbshift(-1)&0x0F;	/* alt/ctrl/shift */
		if (key) exit_obj= do_ebdtkey(key,kstate);
		switch (exit_obj)
		{
			case -1:				/* already handled in do_ebdtkey() */
			break;

			case EBDTEXIT:		/* exit */
			done=1;
			break;

			case EBDTUP  :		/* scroll list up/down by single entry */
			case EBDTDOWN:
			i= exit_obj==EBDTUP ? -1 : 1 ;
			i += home_ebdt;
			if ((i>=0)&&(i<=n_ebdt))
			{
				re_ebdt(i,ebdt_cursor);
				mstate=0;	/* allow mouse repeat */
			}
			break;

			case EBDTVSLD:		/* interact with vertical slider */
			i= hndl_slider(home_ebdt,n_ebdt+1,ebdtaddr,EBDTVSLD,EBDTVSCR);
			if (i!=home_ebdt) re_ebdt(i,ebdt_cursor);
			break;

			case EBDTVSCR:		/* scroll list by half screen */
			getmouse(&dummy,&mousey);
			i= mousey;
			objc_offset(ebdtaddr,EBDTVSLD,&dummy,&y);
			i= i<y ? -ebdt_nrows/2 : ebdt_nrows/2 ;
			i += home_ebdt;
			if (i<0) i=0;
			if (i>n_ebdt) i= n_ebdt;
			re_ebdt(i,ebdt_cursor);
			mstate=0;	/* allow mouse repeat */
			break;

			case EBDTINIT:
			if (!n_ebdt) break;
			if (form_alert(1,INITEBDT)==1)
			{
				n_ebdt= 0;
				adjust_ebdt(4,dummy);	/* init indexes of all ebdt controls */
				re_ebdt(0,0);
				change_flag[temCHANGE]= 1;
			}
			break;

			case EBDTIMPT:
			putdial(0L,0,exit_obj);
			i= n_ebdt;
			import_ebdt();
			/* if ebdt got smaller, delete links to entries that were lost */
			for (j=n_ebdt; j<i; j++) adjust_ebdt(0,j);
			putdial(ebdtaddr,1,0);
			ebdt_cursor= 0;
			ebdt_curs(1);
			draw_ebdt();
			break;

			case EBDTEXPT:
			if (!n_ebdt) break;
			putdial(0L,0,exit_obj);
			export_ebdt();
			putdial(ebdtaddr,1,0);
			ebdt_curs(1);
			draw_ebdt();
			break;
			
			case EBDTPACK:
			if (!n_ebdt) break;
			i= form_alert(lastpacktype,PACKEBDT);
			if (i==3) break;
			lastpacktype= i;
			i= i==1 ? 1 : ebdt_cursor+1 ;	/* start packing where */
			iptr= ebdtptr+i;
			for (; i<n_ebdt; i++,iptr++)
			{
				iptr[0].offset= iptr[-1].offset + iptr[-1].length ;
				if ( (iptr[0].length>1) && (iptr[0].offset&1) ) iptr[0].offset++;
			}
			draw_ebdt();
			change_flag[temCHANGE]= 1;
			break;

			case EBDTUNDO:
			if (form_alert(1,UNDOEBDT)==1)
			{
				n_ebdt= undo_n;
				copy_words(heap[undo_mem].start,ebdtptr,heap[undo_mem].nbytes/2);
				adjust_ebdt(3,dummy);	/* undo indexes of ebdt controls */
				re_ebdt(0,0);
			}
			break;

			default:
			getmouse(&dummy,&mousey);
			i= (mousey - ebdt_y) / charh ;
			i= (i<ebdt_nrows) ? i+home_ebdt : -1 ;
			if ((i>=0)&&(i<=n_ebdt))
			{
				y= ebdt_y + charh*(i-home_ebdt);
				if (mstate>0)
				{
					for (j=0; j<NEBDTCOLS; j++) if (exit_obj==ebdtcol[j]) break;
					if ((j<NEBDTCOLS)&&(i<n_ebdt))
					{
						ebdt_curs(0);
						ebdt_cursor=i;
						ebdt_curs(1);
						edit_ebdt(i,y,j);
					}
				}
				else
				{
					if (kstate==0)
					{
						ebdt_curs(0);
						ebdt_cursor=i;
						ebdt_curs(1);
					}
					if (kstate==K_ALT)
					{
						if (i<n_ebdt)
						{
							del_ebdt(i);
							mstate=0; /* allow auto-repeat */
						}
					}
				}	/* end if mstate */
			}
				
		}	/* end switch (exit_obj) */
		if (mstate) waitmouse();
	}
	while (!done);

	putdial(0L,0,exit_obj);
	tem_prompt(0L);

exit_ebdt:
	dealloc_mem(undo_mem);
	/* shrink ebdt */
	change_mem(ebdt_mem,(long)n_ebdt*sizeof(init_ebdt));
	/* expand curr_page (curr_leng hasn't changed) */
	fill_mem(curr_mem);
#endif
}	/* end do_ebdt() */

#if EBDTFLAG

/* draw (some of) ebdt ......................................................*/

draw_ebdt()
{
	register int i,y,n;
	char buf[40];

	HIDEMOUSE;

	y= ebdt_y;
	for (i=home_ebdt,n=0; (i<n_ebdt)&&(n<ebdt_nrows); i++,n++,y+=charh)
		draw_1ebdt(ebdtptr+i,y);

	for (; n<ebdt_nrows; n++,y+=charh)
	{
		gr_text(" ",ebdt_x[0]-1,y);	/* wipe the '+' */
		for (i=0; i<NEBDTCOLS; i++)
		{
			set_bytes(buf,(long)fieldleng[i],' ');
			buf[fieldleng[i]]=0;
			gr_text(buf,ebdt_x[i],y);
		}
	}
	SHOWMOUSE;
}	/* end draw_ebdt() */

/* draw 1 EBDT entry ........................................................*/

draw_1ebdt(ebdt,y)
EBDT *ebdt;
int y;
{
	register int i;
	char field[NEBDTCOLS][32];

	decode_ebdt(ebdt,field);

	HIDEMOUSE;
	outchar('+',ebdt_x[0]-1,y);
	for (i=0; i<NEBDTCOLS; i++) gr_text(field[i],ebdt_x[i],y);
	SHOWMOUSE;
}	/* end draw_1ebdt() */

/* compute ebdt slider size and position ....................................*/

ebdt_slider(draw)
int draw;
{
	int h= ebdtaddr[EBDTVSCR].ob_height;
	int w= ebdtaddr[EBDTVSCR].ob_width;

	set_slider(n_ebdt+1,ebdt_nrows,home_ebdt,0,h,w,
				&ebdtaddr[EBDTVSLD].ob_height,&ebdtaddr[EBDTVSLD].ob_y);
	if (draw) draw_object(ebdtaddr,EBDTVSCR);
}	/* end ebdt_slider() */

/* handle key typed in ebdt dialog .........................................*/
/* returns equivalent object */

do_ebdtkey(key,kstate)
register int key;		/* high byte is scan, low byte is ascii */
int kstate;				/* modifier keys */
{
	int exit_obj= -1;
	register int i,scan;
	register EBDT *iptr;

	scan= key>>8;	/* scan */
	key &= 0xFF;	/* ascii */

	switch (scan)
	{
		case SCAN_ESC:		exit_obj= EBDTEXIT;	break;
		case SCAN_UNDO:	exit_obj= EBDTUNDO;	break;
		case SCAN_CLR :	exit_obj= EBDTINIT;	break;
		case SCAN_P:		exit_obj= EBDTPACK;	break;
		case SCAN_I:		exit_obj= EBDTIMPT;	break;
		case SCAN_E:		exit_obj= EBDTEXPT;	break;

		case SCAN_UP:
		if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT)) exit_obj= EBDTUP;
		if (kstate==K_CTRL)
		{
			i= home_ebdt - ebdt_nrows/2;
			if (i<0) i=0;
			re_ebdt(i,ebdt_cursor);
		}
		if (!kstate)
		{
			if (ebdt_cursor>=1)
			{
				ebdt_curs(0);
				ebdt_cursor--;
				if (ebdt_cursor<home_ebdt)
				{
					home_ebdt--;
					draw_ebdt();
					ebdt_slider(1);
				}
				ebdt_curs(1);
			}
		}
		break;

		case SCAN_DOWN:
		if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT)) exit_obj= EBDTDOWN;
		if (kstate==K_CTRL)
		{
			i= home_ebdt + ebdt_nrows/2;
			if (i>n_ebdt) i= n_ebdt;
			re_ebdt(i,ebdt_cursor);
		}
		if (!kstate)
		{
			if (ebdt_cursor<n_ebdt)
			{
				ebdt_curs(0);
				ebdt_cursor++;
				if (ebdt_cursor>=(home_ebdt+ebdt_nrows))
				{
					home_ebdt++;
					draw_ebdt();
					ebdt_slider(1);
				}
				ebdt_curs(1);
			}
		}
		break;

		case SCAN_DEL:			/* delete cursor's entry */
		if (!n_ebdt) break;	/* no entries to be deleted */
		if (ebdt_cursor<n_ebdt) del_ebdt(ebdt_cursor);
		break;

		case SCAN_INS:
		if ( (n_ebdt+1) >= maxn_ebdt )
			form_alert(1,BADMEM2);
		else
		{
			ebdt_curs(0);
			if (ebdt_cursor==n_ebdt)
				*(ebdtptr+n_ebdt++)= init_ebdt;
			else
			{
				/* insert init_ebdt before cursor */
				iptr= ebdtptr+n_ebdt;
				for (i=n_ebdt; i>ebdt_cursor; i--,iptr--) iptr[0]= iptr[-1];
				*(ebdtptr+ebdt_cursor)= init_ebdt;
				n_ebdt++;
				adjust_ebdt(1,ebdt_cursor); /* adjust ctrl references to ebdt */
			}
			draw_ebdt();
			ebdt_slider(1);
			change_flag[temCHANGE]= 1;
			do_ebdtkey(SCAN_SPACE<<8,0);
			/* move cursor down */
			return do_ebdtkey(SCAN_DOWN<<8,0);
		}
		break;

		case SCAN_SPACE:	/* edit the cursor's entry */
		if (ebdt_cursor<n_ebdt)
		{
			i= ebdt_y + charh*(ebdt_cursor-home_ebdt);
			edit_ebdt(ebdt_cursor,i,1);
		}
	}
	return exit_obj;

}	/* end do_ebdtkey() */

/* (un)draw ebdt cursor .....................................................*/

ebdt_curs(draw)
int draw;	/* 1= draw, 0= undraw */
{
	gr_text(draw ? ebdtcursor : " ",
				ebdtcursx,ebdt_y+charh*(ebdt_cursor-home_ebdt));
}	/* end ebdt_curs() */

/* edit an entry ............................................................*/

edit_ebdt(which,y,curs_field)
int which;	/* which entry: 0 - (n_ebdt-1) */
int y;		/* its y-coord */
int curs_field;	/* which field to start cursor in */
{
	char field[NEBDTCOLS][32];
	int curs_char;
	long templong;
	int key,done,kstate;
	register int temp,asci,scan;
	EBDT tempebdt;

	HIDEMOUSE;

	decode_ebdt(ebdtptr+which,field);

	/* init cursor */
	curs_char= 0;
again:
	key=done=0;
	while (!done)
	{
		xortext(1,ebdt_x[curs_field]+curs_char,y);	/* show cursor */
		if (!key)	/* if no key left over from "double case" */
		{
			templong= Crawcin();
			kstate= Kbshift(-1)&0x0F;
			key= templong | (templong>>8);
		}
		scan= key>>8;
		asci= key&0xFF;
		key=0;		/* clear unless "double case" */
		xortext(1,ebdt_x[curs_field]+curs_char,y);	/* hide cursor */
		switch (scan)
		{
			case SCAN_ESC:		done= -1;	break;	/* cancel */

			case SCAN_CR:
			case SCAN_ENTER:	done= 1;		break;	/* keep */

			case SCAN_RIGHT:			/* move cursor by character */
			case SCAN_LEFT:
			curs_char += (scan==SCAN_RIGHT ? 1 : -1) ;
			if (curs_char>=fieldleng[curs_field])
			{
				curs_field++;
				if (curs_field==NEBDTCOLS) curs_field=0;
				curs_char=0;
			}
			if (curs_char<0)
			{
				curs_field--;
				if (curs_field<0) curs_field= NEBDTCOLS-1;
				curs_char= fieldleng[curs_field]-1;
			}
			break;

			case SCAN_TAB:		/* move cursor by field */
			curs_field += ( (kstate==K_LSHIFT)||(kstate==K_RSHIFT) ? -1 : 1 ) ;
			if (curs_field<0) curs_field= NEBDTCOLS-1;
			if (curs_field==NEBDTCOLS) curs_field=0;
			curs_char= 0;
			break;

			case SCAN_BS:
			outchar(' ',ebdt_x[curs_field]+curs_char,y);
			field[curs_field][curs_char]=' ';
			/* move cursor backward -- fake next key SCAN_LEFT */
			kstate=0;
			key= SCAN_LEFT<<8;
			break;

			default:
			if ((asci>=' ')&&(asci<='~'))
			{
				outchar(asci,ebdt_x[curs_field]+curs_char,y);
				field[curs_field][curs_char]= asci;
				/* move cursor forward -- fake next key SCAN_RIGHT */
				kstate=0;
				key= SCAN_RIGHT<<8;
			}
		}	/* end switch (scan) */
	}	/* end while (!done) */
	if (done==1)	/* try to keep it */
	{
		if (encode_ebdt(field,&tempebdt))
		{
			*(ebdtptr+which)= tempebdt;
			change_flag[temCHANGE]=1;
		}
		else
		{
			Cconout(7);
			goto again;
		}
	}
	draw_1ebdt(ebdtptr+which,y);
	SHOWMOUSE;
}	/* end edit_ebdt() */

/* import ebdt from an ascii file ...........................................*/

import_ebdt()
{
	char filename[13],pathname[80];

	/* shrink ebdt so that there's memory for file to be loaded into */
	change_mem(ebdt_mem,(long)n_ebdt*sizeof(init_ebdt));

	tempmem= -1;
	filename[0]=0;
	Dsetdrv(tem_drive); dsetpath(tem_path);
	if (getfile(pathname,filename,TXT_EXT,IMPEBDTMSG)>0)
	{
		if (load_file(pathname,filename))
		{
			expand_ebdt();
			asci2ebdt();
			home_ebdt= 0;
			ebdt_slider(0);
		}
	}
	dealloc_mem(tempmem);
	expand_ebdt();
}	/* end import_ebdt() */

asci2ebdt()
{
	char *ptr,*endptr,*ptr2;
	char field[NEBDTCOLS][32];
	int error=0;

	if (n_ebdt)
		if (form_alert(1,CHEKRPLEBDT)==1) n_ebdt=0;

	/* start and end of ascii file */
	ptr= (char*)(heap[tempmem].start);
	endptr= ptr + heap[tempmem].nbytes;

	/* is there at least one in this file? */
	for (; ptr<endptr; ptr++) if (ptr[0]==DQUOTE) break;
	if (ptr==endptr) error=1;

	graf_mouse(BEE_MOUSE);
	while (!error&&(ptr<endptr))
	{
		/* name */
		for (; ptr<endptr; ptr++) if (ptr[0]==DQUOTE) break;
		if (ptr==endptr) break;
		ptr2= ptr+1;
		for (ptr++; ptr<endptr; ptr++) if (ptr[0]==DQUOTE) break;
		if (ptr==endptr) { error=1; break; }
		ptr[0]=0;
		if (strlen(ptr2)>31) { error=1; break; }
		strcpy(field[1],ptr2);
		pad_str(31,field[1],' ');

		/* length */
		error= _asci2ebdt(&ptr,endptr,field[2]);
		/* offset */
		if (!error) error= _asci2ebdt(&ptr,endptr,field[0]);
		/* low */
		if (!error) error= _asci2ebdt(&ptr,endptr,field[3]);
		/* high */
		if (!error) error= _asci2ebdt(&ptr,endptr,field[4]);
		/* don't let ebdt overflow */
		if (!error) if (n_ebdt==maxn_ebdt) error=2;
		if (!error) error= !encode_ebdt(field,ebdtptr+n_ebdt);
		if (!error) n_ebdt++;
	}	/* end while */
	graf_mouse(ARROWMOUSE);
	/* parse error */
	if (error==1) form_alert(1,BADIMPEBDT);
	/* ebdt overflow error */
	if (error==2) form_alert(1,BADNEBDT);

}	/* end asci2ebdt() */

_asci2ebdt(ptr,endptr,field)
char **ptr;
char *endptr;
char *field;
{
	char *ptr1,*ptr2;
	int error=1;

	ptr1= *ptr;
	for (ptr1++; ptr1<endptr; ptr1++) if (ptr1[0]>' ') break;
	if (ptr1<endptr)
	{
		ptr2= ptr1;
		for (ptr1++; ptr1<endptr; ptr1++) if (ptr1[0]<=' ') break;
		if (ptr1<endptr)
		{
			ptr1[0]=0;
			if (strlen(ptr2)<=31)
			{
				strcpy(field,ptr2);
				error=0;
			}
		}
	}
	*ptr= ptr1;
	return error;
}	/* end _asci2ebdt() */

/* export ebdt to an ascii file .............................................*/

export_ebdt()
{
	char filename[13],pathname[80];
	long addr[1],leng[1];

	/* shrink ebdt so that there's memory for file to be built */
	change_mem(ebdt_mem,(long)n_ebdt*sizeof(init_ebdt));

	if (ebdt2asci())
	{
		strcpy(filename,temfile);
		new_ext(filename,TXT_EXT);
		Dsetdrv(tem_drive); dsetpath(tem_path);
		if (getfile(pathname,filename,TXT_EXT,EXPEBDTMSG)>0)
		{
			addr[0]= heap[tempmem].start;
			leng[0]= heap[tempmem].nbytes;
			save_file(filename,pathname,1,addr,leng);
		}
		dealloc_mem(tempmem);
	}

	expand_ebdt();

}	/* end export_ebdt() */

/* returns 1= ok, 0= error */
ebdt2asci()
{
	register int i;
	register char *ptr,*lineptr;
	EBDT *ebdt;
	char field[NEBDTCOLS][32];
	char line[80];
	static char pad[7]= "      ";

	tempmem= alloc_mem(74L*n_ebdt);
	if (tempmem<0) return 0;
	ptr= (char*)(heap[tempmem].start);
	ebdt= (EBDT*)(heap[ebdt_mem].start);

	graf_mouse(BEE_MOUSE);

	for (i=0; i<n_ebdt; i++,ebdt++,ptr+=74)
	{
		decode_ebdt(ebdt,field);
		lineptr= line;

		/* name */
		*lineptr++ = DQUOTE;													/* [ 0] */
		copy_bytes(field[1],lineptr,31L); lineptr+=31;				/* [ 1] */
		*lineptr++ = DQUOTE;													/* [32] */

		/* length */
		copy_bytes(pad,lineptr,5L); lineptr+=5;						/* [33] */
		*lineptr++ = field[2][0];											/* [38] */

		/* offset */
		copy_bytes(pad,lineptr,5L); lineptr+=5;						/* [39] */
		copy_bytes(field[0],lineptr,5L); lineptr+=5;					/* [44] */

		/* low */
		copy_bytes(pad,lineptr,5L); lineptr+=5;						/* [49] */
		copy_bytes(field[3],lineptr,6L); lineptr+=6;					/* [54] */

		/* high */
		copy_bytes(pad,lineptr,6L); lineptr+=6;						/* [60] */
		copy_bytes(field[4],lineptr,6L); lineptr+=6;					/* [66] */

		*lineptr++ = 0x0D;													/* [72] */
		*lineptr++ = 0x0A;													/* [73] */
		*lineptr++ = 0;														/* [74] */

		strcpy(ptr,line);
	}

	graf_mouse(ARROWMOUSE);

	return 1;
}	/* end ebdt2asci() */

/* encode an EBDT entry .....................................................*/
/* returns 1= ok, 0= error */

encode_ebdt(field,ebdt)
char field[NEBDTCOLS][32];
EBDT *ebdt;		/* may get trashed if returns 0 */
{
	register long low,high,offset;
	int temp,sign,length;
	long atol();

	offset= atol(field[0]);
	if ( (offset<0L) || (offset>99999L) ) return 0;
	ebdt->offset= offset;

	copy_bytes(field[1],ebdt->name,31L);
	(ebdt->name)[31]=0;

	length= atoi(field[2]);
	if ( (length<1) || (length>4) ) return 0;
	if (length==3) return 0;
	if ( (length>1) && (offset&1) ) return 0;
	ebdt->length= length;

	sign= field[3][0];
	if ( (sign!='+') && (sign!='-') )	/* no sign: assume positive */
		low= atol(&field[3][0]);
	else
		low= atol(&field[3][1]);
	if ( (low<0L) || (low>99999L) ) return 0;
	if (sign=='-') low= -low;
	ebdt->low= low;

	sign= field[4][0];
	if ( (sign!='+') && (sign!='-') )	/* no sign: assume positive */
		high= atol(&field[4][0]);
	else
		high= atol(&field[4][1]);
	if ( (high<0L) || (high>99999L) ) return 0;
	if (sign=='-') high= -high;
	if (high<low) return 0;
	ebdt->high= high;

	sign= (low<0L) || (high<0L) ;
	temp= max( bytes_for(sign,low) , bytes_for(sign,high) );
	if (temp>length) return 0;

	return 1;
}	/* end encode_ebdt() */

/* change home and/or cursor, then redraw ...................................*/

re_ebdt(home,curs)
int home;	/* new home */
int curs;	/* new cursor */
{
	ebdt_curs(0);			/* erase old cursor */
	home_ebdt= home;		/* change home */
	ebdt_slider(1);		/* reposition and redraw slider */
	draw_ebdt();			/* redraw list */
	ebdt_cursor= curs;	/* change cursor */
	/* force legal cursor position */
	ebdt_cursor= max(ebdt_cursor,home_ebdt);
	ebdt_cursor= min(ebdt_cursor,home_ebdt+ebdt_nrows-1);
	ebdt_cursor= min(ebdt_cursor,n_ebdt);
	ebdt_curs(1);			/* draw new cursor */
}	/* end re_ebdt() */

/* delete one entry and redraw ..............................................*/

del_ebdt(i)
register int i;		/* which entry to delete: 0 - (n_ebdt-1) */
{
	register EBDT *iptr;

	adjust_ebdt(0,i); /* adjust ctrl references to ebdt */
	iptr= ebdtptr+i;
	for (i++; i<n_ebdt; i++,iptr++) iptr[0]= iptr[1];
	n_ebdt--;
	re_ebdt(home_ebdt,ebdt_cursor);
	change_flag[temCHANGE]= 1;
}	/* end del_ebdt() */

/* adjust control references to ebdt ........................................*/

adjust_ebdt(op,arg)
int op;		/* what to do */
int arg;		/* to what */
{
	register int i,mem;

	for (i=0; i<NTEMPAGES; i++)
	{
		mem= temmem[ seg_to_mem(idTEMPAGE0+i) ];
		adjust_1ebdt(heap[mem].start,heap[mem].nbytes,op,arg);
	}
}	/* end adjust_ebdt() */

adjust_1ebdt(ptr,leng,op,arg)
register long ptr,leng;
int op,arg;
{
	CTRLHEADER *ctrl;
	CTRL_EBDT *ebdt;
	int length,index;

	while (leng>sizeof(ctrlheader))
	{
		ctrl= (CTRLHEADER*)(ptr);
		length= ctrl->length;
		if ( ctrl->type == CTYP_EBDT )
		{
			ebdt= (CTRL_EBDT*)(ptr+sizeof(*ctrl));
			index= ebdt->index;
			switch (op)
			{
				case 0:	/* delete */
				if (index==arg) ebdt->index= -1;	/* delete this one */
				if (index>arg) (ebdt->index)--;	/* delete before this one */
				break;
				
				case 1:	/* insert */
				if (index>=arg) (ebdt->index)++;	/* insert before this one */
				break;
				
				case 2:	/* backup */
				ebdt->undo= index;
				break;
				
				case 3:	/* undo */
				ebdt->index= ebdt->undo;
				break;
				
				case 4:	/* init */
				ebdt->index= -1;
			}	/* end switch (op) */
		}	/* end if this control is an EBDT control */
		ptr += length;
		leng -= length;
	}	/* end loop through all controls on this page */
}	/* end adjust_1ebdt() */

/* expand ebdt, compute maxn_ebdt and ebdtptr ...............................*/

expand_ebdt()
{
	fill_mem(ebdt_mem);
	maxn_ebdt= n_of_ebdt(&ebdtptr);
}	/* end expand_ebdt() */

#endif

/* where and how big is EBDT? ...............................................*/
/* returns # of entries */

n_of_ebdt(ptr)
long *ptr;
{
#if EBDTFLAG
	register int i;
	register long templong;
	EBDT *ebdt;

	i= temmem[ seg_to_mem(idTEMEBDT) ] ;
	*ptr= heap[i].start;
	templong= heap[i].nbytes / sizeof(*ebdt) ;
	if (templong>0x7fffL) templong=0x7fffL;
	return (int)templong;
#else
	return 0;
#endif
}	/* end n_of_ebdt() */

/* decode an EBDT entry .....................................................*/

decode_ebdt(ebdt,field)
EBDT *ebdt;
char field[NEBDTCOLS][32];
{
	register long templong;
	register int i;

	ltoa(ebdt->offset,field[0],5);

	copy_bytes(ebdt->name,field[1],31L);
	pad_str(31,field[1],' ');

	itoa(ebdt->length,field[2],1);

	for (i=3; i<=4; i++)
	{
		templong= i==3 ? ebdt->low : ebdt->high ;
		if (templong>=0L)
			field[i][0]= '+';
		else
		{
			field[i][0]= '-';
			templong= -templong;
		}
		ltoa(templong,&field[i][1],5);
	}
}	/* end decode_ebdt() */

/* EOF */
