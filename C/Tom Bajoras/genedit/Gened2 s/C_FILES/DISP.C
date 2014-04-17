/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                         Copyright 1990/1991 Tom Bajoras

	module DISP :  high-level graphics

	draw_screen, draw_file, draw_names
	draw_vbar, draw_hbar, draw_window
	draw_studio

	build_names, build_1name, build_vbar, build_hbar

******************************************************************************/

overlay "misc"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* build and draw entire screen .............................................*/

draw_screen()
{
	draw_window(0);
	draw_window(1);
	draw_studio(-1);
}

/* draw studio description ..................................................*/

draw_studio(which)
int which; /* 0-(NDEVPERSCR-1), -1 all */
{
	register int i;
	int x,y;
	char name[16];

	HIDEMOUSE;
	if (which<0)
	{
		for (i=0; i<NDEVPERSCR; i++)
			draw_studio(i);
	}
	else
	{
		x= studio_x5 + (charw/2);
		y= 10*rez*which + studio_y2;
		y += charh/2;
		y -= rez;
		vdi_font(1);
		vst_alignment(gl_hand,0,5,&dummy,&dummy);
		strcpy(name,studioLink[which+studioHome].name);
		pad_str(15,name,' ');
		v_gtext(gl_hand,x,y,name);
		vst_alignment(gl_hand,0,0,&dummy,&dummy);
		vdi_font(0);
	}
	SHOWMOUSE;
}	/* end draw_studio() */

/* build/home/draw a window .................................................*/
/* clears patchselect */

draw_window(side)
register int side;	/* 0= left, 1= right */
{
	draw_file(side);									/* window file names */
	set_bytes(patchselect[side],MAXNPATS,0);	/* patch names */
	build_names(side);
	draw_names(side,-1);
	build_vbar(side);								/* scroll bars and sliders */
	draw_vbar(side);
	build_hbar(side);
	draw_hbar(side);
}	/* end draw_window() */

/* draw window file name ....................................................*/

draw_file(side)
register int side;	/* 0= left, 1= right */
{
	char line[13];

	copy_bytes(&windfile[side][0],line,13L);
	pad_str(12,line,' ');
	gr_text(line,windname_x[side],windname_y);

}	/* end draw_file() */

/* draw patch names .........................................................*/
/* must be done after build_names() */

draw_names(side,pat)
register int side;	/* 0 left, 1 right */
int pat;					/* which patch to draw (-1 for all) */
{
	register int i,j,y;
	register char *namebuf;
	char linebuf[40];	/* 40 < window_w */
	int x,leng,patx;

	y= window_y;
	x= window_x[side];
	namebuf= (char*)(heap[namemem[side]].start);
	leng= nameleng[side];
	patx= pnumber_x[side]/charw + 1;

	j= homepatch[side];
	namebuf += (j*leng);
	for (i=0; (i<window_h)&&(j<npatches[side]); i++,j++,y+=charh,namebuf+=leng)
	{
		if ((pat<0)||(pat==j))
		{
			/* patch name */
			asm { move.w i,-(a7)
					move.w j,-(a7) }
			for (i=0,j=homechar[side]; (i<window_w)&&(j<leng); i++,j++)
				linebuf[i]= namebuf[j];
			for (; i<window_w; i++) linebuf[i]=' ';
			linebuf[window_w]=0;
			asm { move.w (a7)+,j
					move.w (a7)+,i }
			gr_text(linebuf,x,y);
			if (patchselect[side][j]) xortext(window_w,x,y);

			/* patch number */
			if (!itop(j,windpnumfmt[side],linebuf)) strcpy(linebuf,"       ");
			pad_str(7,linebuf,' ');
			gr_text(linebuf,patx,y);
		}	/* end if this patch should be drawn */
	}	/* end for */

	/* if we're drawing the whole bank, the rest is blank */
	if (pat<0)
	{
		for (j=0; j<window_w; j++) linebuf[j]=' ';
		linebuf[window_w]=0;
		for (; i<window_h; i++,y+=charh)
		{
			gr_text(linebuf,x,y);
			gr_text("       ",patx,y);
		}
	}

}	/* end draw_names() */

/* draw vertical scroll bar and slider ......................................*/
/* must be done after build_vbar() */

draw_vbar(side)
int side;	/* 0 left, 1 right */
{
	int x,y,w,h,y1,y2,y3,y4;

	y1= vscroll_y;
	y2= vslide_y[side];
	y3= y2+vslide_h[side];
	y4= y1+vscroll_h-1;

	if (y1<y2) fill_rect(vscroll_x[side],y1,vscroll_w,y2-y1,2);
	if (y2<y3)
	{
		x= vslide_x[side];
		y= vslide_y[side];
		w= vslide_w[side];
		h= vslide_h[side];
		fill_rect(x,y,w,h,0);
		draw_box(0xFFFF,0xFFFF,x,y,x+w-1,y+h-1);
	}
	if (y3<y4) fill_rect(vscroll_x[side],y3,vscroll_w,y4-y3,2);

}	/* end draw_vbar() */

/* draw horizontal scroll bar and slider ....................................*/
/* must be done after build_hbar() */

draw_hbar(side)
int side;	/* 0 left, 1 right */
{
	int x,y,w,h,x1,x2,x3,x4;

	x1= hscroll_x[side];
	x2= hslide_x[side];
	x3= x2+hslide_w[side];
	x4= x1+hscroll_w-1;

	if (x1<x2) fill_rect(x1,hscroll_y,x2-x1,hscroll_h,2);
	if (x2<x3)
	{
		x= hslide_x[side];
		y= hslide_y[side];
		w= hslide_w[side];
		h= hslide_h[side];
		fill_rect(x,y,w,h,0);
		draw_box(0xFFFF,0xFFFF,x,y,x+w-1,y+h-1);
	}
	if (x3<x4) fill_rect(x3,hscroll_y,x4-x3,hscroll_h,2);

}	/* end draw_hbar() */

/* calculate vertical slider size and position ..............................*/
/* must be done after build_names() */

build_vbar(side)
int side;	/* 0 left, 1 right */
{
	/* these don't change */
	vslide_x[side]= vscroll_x[side];
	vslide_w[side]= vscroll_w;
	set_slider(npatches[side],window_h,homepatch[side],vscroll_y,vscroll_h,
					vscroll_w,&vslide_h[side],&vslide_y[side]);
}	/* end build_vbar() */

/* calculate horizontal slider size and position ............................*/
/* must be done after build_names() */

build_hbar(side)
int side;	/* 0 left, 1 right */
{
	/* these don't change */
	hslide_y[side]= hscroll_y;
	hslide_h[side]= hscroll_h;

	set_slider(nameleng[side],window_w,homechar[side],hscroll_x[side],hscroll_w,
					hscroll_h,&hslide_w[side],&hslide_x[side]);
}	/* end build_hbar() */

/* build patch name buffer ..................................................*/

build_names(side)
register int side;	/* 0 left, 1 right */
{
	register int i;
	long dummlong;
	long start,end,initstart,initend,datastart,dataend;
   long ppb,nmo,nml,ebl;
	int cnxhand,datahand,namehand;

	/* relevant heap handles */
	cnxhand= windcnxmem[side];
	namehand= namemem[side];
	datahand= windatamem[side];

	/* init display variables as though no names */
	npatches[side]= homepatch[side]= nameleng[side]= homechar[side]= 0;
	change_mem(namehand,0L);

	/* can't build names if no data */
	if (!heap[datahand].nbytes) return;

	/* can't build names if no cnxINIT or cnxGETP segment */
	start= heap[cnxhand].start;
	end= start + heap[cnxhand].nbytes;
	if (!_findcnxseg((int)(cnxINIT),start,end,&initstart,&initend)) return;
	if (!_findcnxseg((int)(cnxGETP),start,end,&dummlong,&dummlong)) return;

	/* init the INIT variables */
   cnxvars[VAR_NMO]= cnxvars[VAR_NML]= cnxvars[VAR_EBL]= 0L;
	set_words(cnxpnumfmt.npatches,MAXNBANKS,0);
	set_longs(cnxpnumfmt.bankname,MAXNBANKS,0L);
	set_bytes(cnxpnumfmt.offset,MAXNBANKS,0);

	/* run INIT segment */
	datastart= heap[datahand].start;
	dataend= datastart + heap[datahand].nbytes;
	exec_cnx((int)(cnxINIT),initstart,initend,datastart,dataend,
				&dummy,&dummy,0L);
   if (cnxvars[VAR_ERR]) return;

	/* get INIT variables */
	for (i=ppb=0; i<MAXNBANKS; i++) ppb += cnxpnumfmt.npatches[i];
	nmo= cnxvars[VAR_NMO];
	nml= cnxvars[VAR_NML];
	ebl= cnxvars[VAR_EBL];

	/* check for invalid and conflicting values */
	if ( (ppb<=0L) || (ppb>MAXNPATS) ||
		  (nml<=0L) || (nml>MAXNAMLENG) ||
		  (ebl<=0L) || ((nml+nmo)>ebl)
	) return;

	/* resize edit buffer */
	if (!change_mem(editmem,ebl)) return;
	/* resize name buffer */
	if (!change_mem(namehand,ppb*nml))
	{
		change_mem(editmem,0L);
		return;
	}

	/* window variables */
	npatches[side]= ppb;
	nameleng[side]= nml;
	editleng[side]= ebl;
	nameoffset[side]= nmo;
	windpnumfmt[side]= cnxpnumfmt;

	/* build name buffer */
	graf_mouse(BEE_MOUSE);
	set_bytes(heap[namehand].start,ppb*nml,0);
	for (i=0; i<ppb; i++)
   	if (!build_1name(side,i)) break;
	graf_mouse(ARROWMOUSE);

	/* error:  get rid of patch names */
	if (i<ppb)
	{
		npatches[side]= homepatch[side]= nameleng[side]= homechar[side]= 0;
		change_mem(namehand,0L);
	}

}	/* end build_names() */

/* build 1 patch name .......................................................*/
/* warning: destroys edit buffer! */
/* returns 1= ok, 0= error */

build_1name(side,pat)
int side,pat;
{
	register int i;
	register char *nameptr;
	long datastart,dataend,editstart,editend;
	long nml,nmo;
	int result=0;

	i= windatamem[side];
	datastart= heap[i].start;
	dataend= datastart + heap[i].nbytes;
	editstart= heap[editmem].start;
	editend= editstart + heap[editmem].nbytes;
	nml= nameleng[side];
	nmo= nameoffset[side];
	nameptr= (char*)(heap[namemem[side]].start) + nml*pat ;

	/* GETP patch from bank to edit buffer */
	cnxvars[VAR_PAT]=pat;
	result= exec_seg(windcnxmem[side],(int)cnxGETP,
					 datastart,dataend,editstart,editend,0L);

	/* copy name from edit buffer to name buffer, convert nulls to spaces */
	if (result)
	{
		copy_bytes(editstart+nmo,nameptr,nml);
		/* convert embedded nulls to spaces */
		for (i=0; i<nml; i++)
			if (!nameptr[i]) nameptr[i]=' ';
	}
	/* GETP might have done character validation, PUTP edit buffer back */
	cnxvars[VAR_PAT]=pat;
	if (result)
		result= exec_seg(windcnxmem[side],(int)cnxPUTP,
					 datastart,dataend,editstart,editend,0L);
	return result;

}	/* end build_1name() */

/* EOF */
