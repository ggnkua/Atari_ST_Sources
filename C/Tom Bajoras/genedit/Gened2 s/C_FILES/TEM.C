/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module TEM :				high/medium level template stuff

	ex_loadtem, ex_savetem, ex_edittem, init_tem

	do_temkey, do_temwork, do_tempal, do_temopts, tem_prompt, do_temglob

	load_tem, setup_side, scan_page,	new_page, new_ctrl, new_side, expand_curr
	set_curr, find_ctrl, drag_ctrl, clrcurrpage, copycurrpage
	match_tem, is_tem_loaded, load_linktem

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

/* local globals ............................................................*/

int pal_x,pal_y,pal_w,pal_h;	/* pallette coordinates */
int tem_x,tem_y,tem_w,tem_h;	/* work area coordinates */
int pal_side=1;					/* pallette: 1 left, 2 right, <0 off screen */
int curr_ctrl=3;					/* currently selected control type on pallette */
int curr_page;						/* page currently being edited (0-7) */
int curr_mem;						/* heap containing page being edited */
long curr_leng;					/* bytes used in current page */
int curr_nctrl;					/* how many controls on current page */
int curr_nvctrl;					/* how many visible controls on current page */
int strgedmem;						/* heap containing string edit buffer */
int midistrgmem;					/* heap containing midi string edit buffer */
int valedmem;						/* heap containing value edit buffer */
int temscrmem;						/* screen save buffer */
int ed_mem;							/* control edit buffer */

	/* pallette interface */
int tem1icn[NTEMCTRLS/2]= {
	TEM1ICN1,TEM1ICN2,TEM1ICN3,TEM1ICN4,TEM1ICN5
};
int tem1ctrl[NTEMCTRLS]= {		/* controls on pallette */
	TEM1LINE, TEM1RECT, TEM1TEXT, TEM1NUMB,
	TEM1KNOB, TEM1SLID, TEM1GRPH, TEM1JOY ,
	TEM1CBUT, TEM1IBUT
};
int tem1_ctyp[NTEMCTRLS]= {
	CTYP_LINE, CTYP_RECT, CTYP_TEXT, CTYP_NUMB,
	CTYP_KNOB, CTYP_SLID, CTYP_GRPH, CTYP_JOY ,
	CTYP_CBUT, CTYP_IBUT
};
/* key equivalents for pallette icons (use letters) */
char tem1scan[NTEMCTRLS]= {
	SCAN_L, SCAN_B, SCAN_T, SCAN_N,
	SCAN_K, SCAN_S, SCAN_E, SCAN_J,
	SCAN_C, SCAN_I
};

	/* prototypes */
CTRLHEADER ctrlheader;
MAC_RECT mac_rect;
VAL_INFO val_info;
XVAL_INFO xval_info;
XXVAL_INFO xxval_info;

	/* the pallette */
CTRL_LINE ctrl_line= {
	0,0,0,0,0,1,	/* mac_rect */
	0xFFFF			/* style */
};
CTRL_RECT ctrl_rect= {
	0,0,0,0,0,1,	/* mac_rect */
	0					/* fill */
};
CTRL_SLID ctrl_slid= {
	0,0,0,0,0,1,	/* mac_rect */
						/* val_info */
	0,0,100,			/* val,low,high */
	0,					/* invert */
	0,0,0				/* linkpage,linkctrl,linkval */
};
CTRL_KNOB ctrl_knob= {
	0,0,0,0,0,1,	/* mac_rect */
						/* val_info */
	0,0,100,			/* val,low,high */
	0,					/* invert */
	0,0,0				/* linkpage,linkctrl,linkval */
};
CTRL_TEXT ctrl_text= {
	0,0,0,0,0,1,	/* mac_rect */
	0,					/* font */
						/* val_info */
	0,0,0,			/* val,low,high */
	0,					/* invert */
	0,0,0,			/* linkpage,linkctrl,linkval */
	{				/* string[] */
		-1L
	}
};
CTRL_NUMB ctrl_numb= {
	0,0,0,0,0,1,	/* mac_rect */
	0,					/* font */
						/* val_info */
	0,0,100,			/* val,low,high */
	0,					/* invert */
	0,0,0				/* linkpage,linkctrl,linkval */
};
CTRL_IBUT ctrl_ibut= {
	0,0,0,0,0,1,	/* mac_rect */
	0,					/* font */
	1,1,0,			/* nrows,ncols,minbut */
	{					/* xval_info[] */
						/* val_info */
		0,0,1,		/* val,low,high */
		0,				/* invert */
		0,0,0,		/* linkpage,linkctrl,linkval */
		-1L			/* string */
	}
};
CTRL_CBUT ctrl_cbut= {
	0,0,0,0,0,1,	/* mac_rect */
	0,					/* font */
	1,1,0,			/* nrows,ncols,minbut */
						/* val_info */
	0,0,1,			/* val,low,high */
	0,					/* invert */
	0,0,0,			/* linkpage,linkctrl,linkval */
	{					/* string[] */
		-1L
	}
};
CTRL_GRPH ctrl_grph= {
	0,0,0,0,0,1,	/* mac_rect */
	0,0,				/* y-axis, x-axis */
	1,					/* npoints */
	{					/* xxval_info[] */
		50,0,100,	/* val,low,high */
		0,				/* invert */
		0,0,0,		/* linkpage,linkctrl,linkval */
		50,0,100,	/* val,low,high */
		0,				/* invert */
		0,0,0,		/* linkpage,linkctrl,linkval */
		PTFOLLOW,100,0,	/* xmode, xfactor, xline */
		PTFULL,100,0,		/* ymode, yfactor, yline */
		1,0					/* active, rfu */
	}
};
CTRL_JOY  ctrl_joy = {
	0,0,0,0,0,1,	/* mac_rect */
	{
						/* val_info[0] */
		50,0,100,	/* val,low,high */
		0,				/* invert */
		0,0,0,		/* linkpage,linkctrl,linkval */
						/* val_info[1] */
		50,0,100,	/* val,low,high */
		0,				/* invert */
		0,0,0			/* linkpage,linkctrl,linkval */
	}
};

/* template options */
int temsnap_x=2;
int temsnap_y=2;
int temsnapx=0;
int temsnapy=0;
int temoutl=0;
int temdelsafe=1;
int temtofit=1;
int temdebug=0;

/* load TEM file ............................................................*/

ex_loadtem()
{
#if TEMFLAG
	char filename[13],pathname[80];
	long load_file();

	/* overwrite changed template? */
	if (change_flag[temCHANGE])
		if (form_alert(1,CHNGETEM)==2) return;

	filename[0]=0;
	Dsetdrv(tem_drive); dsetpath(tem_path);
	tempmem= -1;
	if (getfile(pathname,filename,TE_EXT,TLDETITL)>0)
	{
		tem_drive=Dgetdrv(); Dgetpath(tem_path,tem_drive+1);
		if (load_file(pathname,filename))
		{
			if (load_tem(filename))
			{
				strcpy(temfile,filename);
			}
		}	/* end if file loaded successfully */
	}	/* end if ok from file selector */

	dealloc_mem(tempmem);

#endif
}	/* end ex_loadtem() */

/* parse template out of TEM file in tempmem ................................*/
/* returns 1= ok, 0= error (error message inside here) */

load_tem(filename)
char *filename;
{
#if TEMFLAG
	register char *ptr;
	register int i,k;
	register long j,leng;
	long n;
	int error,seg,mem;
	TEMHEADER temp;
	int correct_w,correct_h,wrong_w,wrong_h;
	long templength;
	int file_offset=0;
	long segleng[NTEMSEGS],segoffset[NTEMSEGS];
	int segtype[NTEMSEGS];

	/* current width and height of page */
	correct_w= temheader.page_w;
	correct_h= temheader.page_h;

	/* is this a template file?  If not, skip Mac header and check again */
	temp= *(TEMHEADER*)(heap[tempmem].start + file_offset);
	if (temp.magic != TEMMAGIC ) file_offset= MACBINLENG;
	temp= *(TEMHEADER*)(heap[tempmem].start + file_offset);
	if (temp.magic != TEMMAGIC )
	{
		big_alert(1,BADREAD1,filename,BADREAD2);
		return 0;
	}
	if ( temp.version > temheader.version )
	{
		form_alert(1,BADVERSION);
		return 0;
	}
	wrong_w= temp.page_w;
	wrong_h= temp.page_h;

	/* get rid of TEM in memory */
	for (i=0; i<NTEMSEGS; i++) change_mem(temmem[i],0L);

	/* this file's global record may be incomplete */
	templength= sizeof(dataheader) + 8 + temp.recleng + file_offset ;

	/* find start of and length of segments in tempmem */
	ptr= (char*)( heap[tempmem].start + templength );
	n= heap[tempmem].nbytes - templength;
	k=0;
	for (j=0; j<n; j+=leng)
	{
		seg= *(long*)(ptr+j);
		j += 4;
		if (seg==idEND) break;
		leng= *(long*)(ptr+j);
		j += 4;
		i= seg_to_mem(seg);
		if (i>=0)			/* known seg type */
		{
			segleng[k]=leng;
			segtype[k]=i;
			segoffset[k++]=j;
		}
	}

	/* copy segments from tempmem to template (ok if no segments) */
	/* do this in reverse order, so that as tempmem shrinks temmem[] grows */
	for (k--,error=0; (k>=0)&&!error; k--)
	{
		i= segtype[k];
		leng= segleng[k];
		error= !change_mem(temmem[i],leng);
		if (!error)
		{
			copy_words(heap[tempmem].start+templength+segoffset[k],
							heap[temmem[i]].start,leng/2);
			error= !change_mem(tempmem,heap[tempmem].nbytes-leng);
		}
	}

	/* scale all pages */
	if (!error)
	{
		/* scaling needed? */
		if ( (correct_w!=wrong_w) || (correct_h!=wrong_h) )
		{
			form_alert(1,MUSTSCALE);
			graf_mouse(BEE_MOUSE);
			menuprompt(SCALE_MSG);
			for (i=0; i<NTEMPAGES; i++)
			{
				mem= temmem[ seg_to_mem(idTEMPAGE0+i) ] ;
				scale_tem(heap[mem].start,heap[mem].nbytes,
							correct_w,wrong_w,correct_h,wrong_h);
			}
			menuprompt(0L);
			graf_mouse(ARROWMOUSE);
		}
	}
	if (error)
		init_tem();
	else
	{
		init_temheader(1,1);
		copy_bytes(&temp,&temheader,templength);
		init_temheader(1,0);	/* the uneditable part */
	}
	if (!error) change_flag[temCHANGE]= curr_page= 0;
	return !error;
#endif
}	/* end load_tem() */

/* load a template linked to a configuration ................................*/
/* returns 1= ok, 0= error  -- error message inside here */

match_tem(side,functype)
int side;					/* 0=left, 1=right window */
int functype;				/* 0 edit, 1 randomize, 2 distort, 3 average */
{
	int result;
	register int temp;
	static int oldchoice=1;
	char *windtemname;
	char alertstr[200],file1[13],file2[13];
	NAMEDCONST *foundptr;
	long find_const();
	long cnxstart,cnxend,segstart,segend;
	static char *funcname[4]= { EDIT_MSG, RAND_MSG, DIST_MSG, AVER_MSG };

	/* find what template (if any) this config is linked to --
		foundptr=0L for configs created before genedit 1.1 */
	temp= windcnxmem[side];
	cnxstart= heap[temp].start;
	cnxend= cnxstart + heap[temp].nbytes;
	foundptr= (NAMEDCONST*)(0L);
	if (_findcnxseg((int)cnxCNST,cnxstart,cnxend,&segstart,&segend))
		foundptr= (NAMEDCONST*)find_const(C_TEMLINK,segstart,segend-segstart);

	result=0;
	if (foundptr && (windlink+1))		/* 1.1 config, and linking turned on */
	{
		windtemname= foundptr->value;
		if (windtemname[0])			/* this is an editing config */
		{
			/* compare two file names, without comparing last character */
			strcpy(file1,windtemname);
			strcpy(file2,temfile);
			temp= strlen(file1);
			if (temp) file1[temp-1]=0;
			temp= strlen(file2);
			if (temp) file2[temp-1]=0;
			if (!strcmp(file1,file2))	/* correct template is already loaded */
				result=1;
			else								/* wrong template is loaded */
			{
				strcpy(alertstr,CHEKMATCH1);
				strcat(alertstr,windtemname);
				strcat(alertstr,CHEKMATCH2);
				strcat(alertstr,temfile);
				strcat(alertstr,CHEKMATCH3);
				/* current template unusable, or prompting turned off */
				if ( (windlink==0) || !is_tem_loaded(functype) )
					temp=1;
				else
				{
					temp= form_alert(oldchoice,alertstr);
					if (temp!=3) oldchoice=temp;
				}
				if (temp==1) result= load_linktem(windtemname);
				if (temp==2) result=1;
			}
		}
		else	/* organizing config */
			big_alert(1,BADMATCH1,funcname[functype],BADMATCH2);
	}
	else	/* 1.0 config or template linking turned off */
		result=1;

	if (result) result= is_tem_loaded(functype);
	return result;

}	/* end match_tem() */

/* is there a template in memory? ...........................................*/
/* returns 1= yes, 0= no */

is_tem_loaded(functype)
int functype;	/* 0 = edit, >0 = randomize/average/distort/etc. */
{
	register int i,mem;
	int result=0;
	long templong;

	if (functype)	/* automated editing requires EBDT */
		result= n_of_ebdt(&templong)>0 ;
	else				/* manual editing requires controls */
	{
		for (i=0; i<NTEMPAGES; i++)
		{
			mem= temmem[ seg_to_mem(idTEMPAGE0+i) ] ;
			if (heap[mem].nbytes) break;
		}
		result= i<NTEMPAGES;	/* was a non-empty page found? */
	}
	return result;

}	/* end is_tem_loaded() */

/* load template linked to a configuration ..................................*/
/* returns 1= loaded successfully, 0= error/cancel (error message inside) */

load_linktem(windtemname)
char *windtemname;
{
	char filename[13],pathname[80];
	int result=0;
	register int i,ch;

	if (change_flag[temCHANGE])
		if (form_alert(1,CHNGETEM)==2) return 0;

	Dsetdrv(tem_drive); dsetpath(tem_path);
	strcpy(filename,windtemname);

	/* if exactly one file is found, skip file selector */
	pathname[0]= tem_drive+'A';
	pathname[1]= ':';
	pathname[2]= 0;
	strcat(pathname,tem_path);
	strcat(pathname,"\\");
	strcat(pathname,filename);
	if (Nfiles(pathname)!=1)
	{
		filename[0]=0;
		if ( getfile(pathname,filename,windtemname,TLDETITL) <= 0 ) return 0;
	}

	/* load filename, no user interface */
	no_alerts=1;
	tempmem= -1;
	if (load_file(pathname,filename))
	{
		if (load_tem(filename))
		{
			strcpy(temfile,filename);
			result=1;
		}
	}
	dealloc_mem(tempmem);
	no_alerts=0;
	if (!result) big_alert(1,BADREAD1,filename,BADREAD2);
	return result;
}	/* end load_linktem() */

/* save TEM file ............................................................*/

ex_savetem()
{
#if TEMFLAG
	char filename[13],pathname[80];
	long addr[2+2*NTEMSEGS],leng[2+2*NTEMSEGS],seginfo[2*NTEMSEGS];
	register int i,j;
	long seg,nbytes;
	int mem;
	long end_of_tem= -1L;
	char ext[4];

	strcpy(filename,temfile);
	Dsetdrv(tem_drive); dsetpath(tem_path);

	/* directory line shows same extension as current template file name */
	for (i=strlen(filename)-1; (i>0) && (filename[i]!='.'); i--) ;
	if (i>0)
		strcpy(ext,&filename[i+1]);
	else
		strcpy(ext,"");

	if (getfile(pathname,filename,ext,TSAVTITL)>0)
	{
		tem_drive=Dgetdrv(); Dgetpath(tem_path,tem_drive+1);

		j=0;
		addr[j]= (long)(&temheader);
		leng[j++]= sizeof(temheader);
		for (i=0; i<NTEMSEGS; i++)
		{
			mem= temmem[i];
			if (nbytes=heap[mem].nbytes)
			{
				seg= mem_to_seg(i);
				seginfo[2*i]= seg;
				seginfo[2*i+1]= nbytes;
				addr[j]= (long)(&seginfo[2*i]);
				leng[j++]= 8L;
				addr[j]= heap[mem].start;
				leng[j++]= nbytes;
			}
		}
		addr[j]= (long)(&end_of_tem);	leng[j++]= 4L;		/* mark end of file */
		if (save_file(filename,pathname,j,addr,leng))
		{
			change_flag[temCHANGE]=0;
			strcpy(temfile,filename);
		}
	}	/* end if ok from file selector */

#endif
}	/* end ex_savetem() */

/* TEM editor ...............................................................*/

ex_edittem()
{
#if TEMFLAG
	static int fixed;
	register int i,mstate,oldmstate;
	int mousex,mousey,mshape,done,event,key,kstate;
	long templong;

	/* center control editing dialogs */
	center_dial(valaddr);
	center_dial(textaddr);
	center_dial(lineaddr);
	center_dial(rectaddr);
	center_dial(numbaddr);
	center_dial(knfdaddr);
	center_dial(butnaddr);
	center_dial(grphaddr);
	center_dial(joyaddr);

	/* fix resource */
	if (!fixed)
	{
		if (rez==1)	/* color */
		{
			for (i=0; i<NTEMCTRLS/2; i++) tem1addr[tem1icn[i]].ob_height *= 2;
			fix_icons(tem1addr);
		}
		pal_y= tem1addr[0].ob_y= 200*rez - temheader.page_h;
		pal_h= tem1addr[0].ob_height= 200*rez - pal_y;
		pal_w= tem1addr[0].ob_width;
		i= tem1addr[TEM1EXIT].ob_y= tem_h - tem1addr[TEM1EXIT].ob_height - 1;
		i= tem1addr[TEM1SWAP].ob_y= i - tem1addr[TEM1SWAP].ob_height - rez;
		tem1addr[TEM1HIDE].ob_y= i;
		i= tem1addr[TEM1OPTS].ob_y= i - tem1addr[TEM1OPTS].ob_height - rez;
		i= tem1addr[TEM1REGN].ob_y= i - tem1addr[TEM1REGN].ob_height - rez;
		temsnapy= rez==2 ;
		fixed=1;
	}
	setup_side(pal_side);

	/* which control current? */
	for (i=0; i<NTEMCTRLS; i++)
		tem1addr[tem1ctrl[i]].ob_state= i==curr_ctrl ? SELECTED : 0 ;

	/* allocate buffers */
	strgedmem= midistrgmem= temscrmem= valedmem= ed_mem= -1;
	strgedmem= alloc_mem( (MAXSTRLENG+1L) * MAXNBUTROW * MAXNBUTCOL );
	if (strgedmem>=0)
		midistrgmem= alloc_mem( (MAXSTRLENG+1L) * MAXNBUTROW * MAXNBUTCOL );
	if (midistrgmem>=0)
		temscrmem= alloc_mem(SCRLENG);
	if (temscrmem>=0)
		valedmem= alloc_mem(SCRLENG/4);
	if (valedmem>=0)
		ed_mem= alloc_mem( MAXEDLENG );
	if (ed_mem<0)
	{
		dealloc_mem(strgedmem);
		dealloc_mem(midistrgmem);
		dealloc_mem(temscrmem);
		return;
	}

	/* draw template editor */
	HIDEMOUSE;
	copy_longs(scrbase,heap[temscrmem].start,SCRLENG/4);
	set_longs(scrbase,SCRLENG/4,0L);
	tem_prompt(0L);
	for (i=0; i<NTEMPAGES; i++)
		tem1addr[i+TEM1PAGE].ob_state= i==curr_page ? SELECTED : 0 ;
	if (pal_side>0) objc_draw(tem1addr,ROOT,MAX_DEPTH,0,0,640,200*rez);
	SHOWMOUSE;

	expand_curr();	/* expand curr_page */
	if (temdebug) hivTest();
	draw_alltem();	/* draw current page */

	/* start with arrow */
	waitmouse();
	tem_mouse(mshape=0);

	for (done=oldmstate=0; !done; )
	{
		/* Check for incoming keys */
		event= evnt_multi(MU_KEYBD|MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,
				 &dummy,0,0,&dummy,&dummy,&dummy,&kstate,&key,&dummy);
		kstate &= 0x0F;	/* alt/ctrl/shift */
		if (event&MU_KEYBD)
		{
			graf_mouse(ARROWMOUSE);	/* arrow needed for user-interface */
			done= do_temkey(key,kstate);
			tem_mouse(mshape);
		}

		mstate= getmouse(&mousex,&mousey);
		/* don't allow mouse into info line */
		if (mousey<tem_y)
		{
			mousey= *Mousey= tem_y;
			HIDEMOUSE; SHOWMOUSE;
		}

		/* mouse shape depends on kstate and where mouse is */
		if (in_rect(mousex,mousey,tem_x,tem_y,tem_w,tem_h))
		{
			switch (kstate)
			{
				case 0:			i=1;	break;
				case K_ALT:		i=2;	break;
				case K_RSHIFT:
				case K_LSHIFT: i=3;	break;
				case K_CTRL:	i=4;	

			}
			/* mouse icon for region mode */
			if (tem1addr[TEM1REGN].ob_state&SELECTED) i=5;
		}
		else
			i= 0;
		if (i!=mshape) tem_mouse(mshape=i);

		/* when button goes down do something */
		if (mstate&&!oldmstate)
		{
			if (in_rect(mousex,mousey,pal_x,pal_y,pal_w,pal_h))
				done= do_tempal(kstate,mstate,mousex,mousey);
			else
				if (mshape!=0) do_temwork(kstate,mstate,mousex,mousey);
			tem_mouse(mshape);
		}
		oldmstate=mstate;
	}	/* end while !done */
	graf_mouse(ARROWMOUSE);

	/* deselect region, but don't redraw */
	clear_region(0);

	/* restore screen */
	HIDEMOUSE;
	copy_longs(heap[temscrmem].start,scrbase,SCRLENG/4);
	SHOWMOUSE;

	/* deallocate buffers */
	dealloc_mem(strgedmem);
	dealloc_mem(midistrgmem);
	dealloc_mem(temscrmem);
	dealloc_mem(valedmem);
	dealloc_mem(ed_mem);

	/* compress string pool */
	if (Kbshift(-1)&K_ALT)
	{
		tempmem= alloc_mem(0L);
		if (tempmem>=0)
		{
			graf_mouse(BEE_MOUSE);
			fill_mem(tempmem);
			clean_pool();
			dealloc_mem(tempmem);
			graf_mouse(ARROWMOUSE);
		}
	}

#endif
}	/* end ex_edittem() */

/* initialize template ......................................................*/

init_tem()
{
#if TEMFLAG
	register int i;

	for (i=0; i<NTEMSEGS; i++) change_mem(temmem[i],0L);
	change_flag[temCHANGE]= temfile[0]= 0;
	init_temheader(1,1);
	curr_page=0;

#endif
}	/* end init_tem() */

#if TEMFLAG

/* initialize template header ...............................................*/

init_temheader(part1,part2)
int part1,part2;
{
	if (part1)
	{
		temheader.magic= TEMMAGIC;
		temheader.version= TEMVERSION;
		temheader.machine= MACHINE;
		temheader.rectype= idTEMGLOB;
		temheader.recleng= sizeof(temheader) - 8 - sizeof(dataheader) ;
		temheader.page_w= 640;
		temheader.page_h= 200*rez - (charh+rez);
		tem_h= temheader.page_h;
		tem_y= 200*rez - tem_h;
	}
	if (part2)
	{
		temheader.no_send= 0;
	}
}	/* end init_temheader() */

/* handle key typed .........................................................*/
/* returns 1=done, 0= not done */

do_temkey(key,kstate)
register int key,kstate;
{
	register int i,scan;
	int done=0;
	int h_shift,v_shift;

	scan= key>>8;	/* scan */
	key &= 0xFF;	/* asci */

	if (kstate==(K_CTRL|K_LSHIFT|K_ALT))
	{
		if (scan==SCAN_D) debug_tem();
	}	/* end if kstate==ctrl+shift+alt */

	if (kstate==K_CTRL)
	{
		switch (scan)
		{
			case SCAN_H:		new_side(-pal_side);	break;
			case SCAN_E:		do_ebdt();		break;
			case SCAN_G:		do_temglob();	break;

			case SCAN_O:
			case SCAN_Q:
			temoutl= !temoutl;
			if (temdebug) hivTest();
			draw_alltem();
			break;

			case SCAN_CLEFT: new_side(1); break;
			case SCAN_CRIGHT: new_side(2); break;

			case SCAN_R:
			tem1addr[TEM1REGN].ob_state ^= SELECTED ;
			if ( !(tem1addr[TEM1REGN].ob_state & SELECTED) ) clear_region(1);
			if (pal_side>0) draw_object(tem1addr,TEM1REGN);
			tem_prompt(0L);
		}	/* end switch (scan) */
	}	/* end if kstate==K_CTRL */

	if (kstate==K_ALT)
	{
		/* copy page, without warning */
		if ((scan>=SCAN_ALT1)&&(scan<=SCAN_ALT8))
		{
			scan -= SCAN_ALT1;
			if (scan!=curr_page) copycurr2i(scan);
		}
	}	/* end if kstate==K_ALT */

	if (kstate==0)
	{
		switch (scan)
		{
			case SCAN_ESC:
			change_mem(curr_mem,curr_leng);	/* shrink curr_page */
			done=1;
			break;

			case SCAN_HELP:	do_temopts();	break;
			case SCAN_CLR:		clrcurrpage();	break;

			case SCAN_LEFT:
			case SCAN_RIGHT:
			case SCAN_DOWN:
			case SCAN_UP:
			if (tem1addr[TEM1REGN].ob_state&SELECTED)
			{
				h_shift= v_shift= 0;
				if (scan==SCAN_LEFT ) h_shift= -1;
				if (scan==SCAN_RIGHT) h_shift=  1;
				if (scan==SCAN_DOWN ) v_shift=  1;
				if (scan==SCAN_UP   ) v_shift= -1;
				if (temsnapx) h_shift *= temsnap_x;
				if (temsnapy) v_shift *= temsnap_y;
				move_region(h_shift,v_shift);
			}
			break;

			default:
			/* change page */
			if ((key>='1')&&(key<='8'))
			{
				key -= '1';
				if (key!=curr_page) new_page(key);
				break;
			}
			/* change current control */
			for (i=0; i<NTEMCTRLS; i++)
				if (scan==tem1scan[i]) break;
			if ((i<NTEMCTRLS)&&(i!=curr_ctrl)) new_ctrl(i);
		}	/* end switch (scan) */
	}	/* end if kstate==0 */

	return done;

}	/* end do_temkey() */

/* handle mouse clicked in work area ........................................*/

do_temwork(kstate,mstate,mx,my)
int kstate,mstate,mx,my;
{
	int ctrl_i;
	CTRLHEADER *ctrl;
	long ctrli2addr();

	ctrl_i= find_ctrl(mx,my,&ctrl);

	/* region editing */
	if (tem1addr[TEM1REGN].ob_state & SELECTED)
	{
		if (mstate==1)
		{
			if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT))
			{
				if (ctrl) toggle1ctrl(ctrl);
			}
			else
				sel_region(mx,my);
		}
		else
			edit_region();
		return;
	}

	if (mstate==1)	/* left click */
	{
		switch (kstate)
		{
			case K_ALT:
			if (ctrl) del_ctrl(ctrl,ctrl_i);
			break;

			case K_RSHIFT:
			case K_LSHIFT:
			case K_CTRL:
			if (ctrl) drag_ctrl(ctrl,mx,my,kstate==K_CTRL);
			break;

			case 0:
			/* don't let val'd control overlay another control */
			if ( !ctrl || (ctrl->type==CTYP_LINE) || (ctrl->type==CTYP_RECT) )
				ctrl_i= add_ctrl(tem1_ctyp[curr_ctrl],mx,my);
		}
	}
	else			/* right click */
	{
		switch (kstate)
		{
			case 0:
			if (ctrl)
			{
				graf_mouse(ARROWMOUSE);
				edit_ctrl(ctrl,ctrl_i);
			}
			break;
			case K_RSHIFT:
			case K_LSHIFT: if (ctrl) size_ctrl(ctrl,mx,my); break;
		}
	}
}	/* end do_temwork() */

/* handle mouse clicked in pallette area ....................................*/
/* returns 1= exit, 0= continue */

do_tempal(kstate,mstate,mx,my)
int kstate,mstate,mx,my;
{
	register int i,exit_obj;
	int done=0;

	done=0;
	switch (exit_obj=objc_find(tem1addr,ROOT,MAX_DEPTH,mx,my))
	{
		case TEM1EBDT: do_ebdt();		break;
		case TEM1GLOB: do_temglob();	break;

		case TEM1OPTS:
		do_temopts();
		break;

		case TEM1EXIT:
		/* shrink curr_page */
		change_mem(curr_mem,curr_leng);
		done=1;
		break;

		case TEM1SWAP:
		switch (pal_side)
		{
			case  1: new_side( 2); break;
			case  2: new_side( 1); break;
			case -1: new_side(-2); break;
			case -2: new_side(-1);
		}
		break;

		case TEM1HIDE:
		new_side(-pal_side);
		break;

		case TEM1REGN:
		tem1addr[TEM1REGN].ob_state ^= SELECTED ;
		if ( !(tem1addr[TEM1REGN].ob_state & SELECTED) ) clear_region(1);
		draw_object(tem1addr,TEM1REGN);
		tem_prompt(0L);
		break;

		default:
		/* change current control */
		for (i=0; i<NTEMCTRLS; i++)
			if (exit_obj==tem1ctrl[i]) break;
		if (i<NTEMCTRLS)
		{
			if (mstate==1)
			{
				if (i!=curr_ctrl) new_ctrl(i);
			}
			else
			{
				;	/* R-click on control on pallette = ? !!! */
			}
			break;
		}
		/* change page */
		i= exit_obj-TEM1PAGE;
		if ((i>=0)&&(i<NTEMPAGES))
		{
			if (mstate==1)
			{
				if (i==curr_page)
				{
					if (kstate==K_ALT) clrcurrpage();
					if (kstate==0) copycurrpage();
				}
				else
					new_page(i);
			}
			else
			{
				;	/* edit page options such as color, etc. !!! */
			}
		}
	}	/* end switch (exit_obj) */
	waitmouse();
	return done;
}	/* end do_tempal() */

/* change pal_side ..........................................................*/

new_side(side)
int side;
{
	register int i,x,w;

	if (side!=pal_side)
	{
		if (pal_side>0)
		{
			tem_x=0; i=tem_w; tem_w=640;	/* so there's no clipping */
			x= pal_x-1; w=pal_w+2;
			draw_tem(x,tem_y,x+w-1,tem_y+tem_h-1);
			tem_w=i;
		}
		setup_side(pal_side=side);
		if (pal_side>0)
		{
			tem1addr[TEM1SWAP].ob_spec=
				(pal_side==1)||(pal_side==(-1)) ? ">>>>" : "<<<<" ;
			objc_draw(tem1addr,ROOT,MAX_DEPTH,0,0,640,200*rez);
		}
	}	/* end if side != pal_side */
}	/* end new_side() */

/* select pal_side/tem_w/pal_x/tem_x ........................................*/

setup_side(side)
int side;
{
	switch (side)
	{
		case 2:	/* right */
		tem_w= 638-pal_w;
		pal_x= tem1addr[0].ob_x= tem_w+1;
		tem_x= 0;
		break;

		case 1:	/* left */
		tem_w= 638-pal_w;
		pal_x= tem1addr[0].ob_x= 1;
		tem_x= pal_x + pal_w + 1;
		break;

		default:	/* off screen */
		tem_w= 640;
		pal_x= 1000;
		tem_x= 0;
	}
}	/* end setup_side() */

/* change page ..............................................................*/

new_page(page)
int page;
{
	int i;

	/* deselect region, but don't redraw */
	clear_region(0);

	/* shrink curr_page */
	change_mem(curr_mem,curr_leng);

	/* change current page button */
	i= TEM1PAGE+curr_page;
	tem1addr[i].ob_state= 0;
	if (pal_side>0) draw_object(tem1addr,i);

	curr_page=page;

	i= TEM1PAGE+curr_page;
	tem1addr[i].ob_state= SELECTED;
	if (pal_side>0) draw_object(tem1addr,i);

	expand_curr();	/* expand new curr_page */
	if (temdebug) hivTest();
	draw_alltem();	/* draw new curr_page */
}	/* end new_page() */

/* expand current page ......................................................*/

expand_curr()
{
	set_curr();
	fill_mem(curr_mem);
}	/* end expand_curr() */

/* set current page .........................................................*/

set_curr()
{
	curr_mem= temmem[ seg_to_mem(idTEMPAGE0+curr_page) ] ;
	scan_page(curr_mem,&curr_leng,&curr_nctrl,&curr_nvctrl);
}	/* end set_curr() */

/* scan through a page ......................................................*/

scan_page(mem,used,nctrls,nvisible)
int mem;			/* heap block to be scanned through, segtype is page */
long *used;		/* # bytes in heap block */
int *nctrls;	/* how many controls on this page */
int *nvisible;	/* how many of these controls are visible type */
{
	register CTRLHEADER *ctrl;
	register int n,v;
	register long leng,u;
	long thisleng;

	ctrl= (CTRLHEADER*)(heap[mem].start);
	leng= heap[mem].nbytes;		/* might be 2 bytes longer than used */
	n= v= u= 0;
	while (leng>sizeof(ctrlheader))
	{
		n++;										/* count controls */
		thisleng= ctrl->length;
		if ( (ctrl->type) >= 0 ) v++;		/* count visible controls */
		ctrl= (CTRLHEADER*)( (long)(ctrl) + thisleng );
		leng -= thisleng;
		u += thisleng;
	}
	*used= u;
	*nctrls= n;
	*nvisible= v;
}	/* end scan_page() */

/* change current control ...................................................*/

new_ctrl(ctrl)
int ctrl;
{
	register int temp,i;

	for (i=0; i<=1; i++)
	{
		temp= tem1ctrl[curr_ctrl];
		tem1addr[temp].ob_state= i*SELECTED;
		if (pal_side>0) draw_object(tem1addr,temp);
		curr_ctrl=ctrl;
	}
}	/* end new_ctrl() */

/* edit template options ....................................................*/

do_temopts()
{
	#define NFLAGS 6
	#define NEDIT 2
	register int i,temp;
	static int obj[NFLAGS]= {
		TOPTOUTL,TOPTSNX ,TOPTSNY, TOPTSAFE, TOPTFIT, TOPTBUG
	};
	static int *flags[NFLAGS]= {
		&temoutl,&temsnapx,&temsnapy,&temdelsafe,&temtofit,&temdebug
	};
	char *tedptr[NEDIT];
	static int tedobj[NEDIT]= {	TOPTSNPX, TOPTSNPY };
	static int *tedval[NEDIT]= { &temsnap_x,&temsnap_y };
	int oldsnap_x,oldsnap_y,oldtofit,oldoutl,oldbug,mustdraw=0;

	/* encode into dialog box */
	for (i=0; i<NFLAGS; i++)
		toptaddr[obj[i]].ob_state= *(flags[i]) ? SELECTED : 0 ;
	for (i=0; i<NEDIT; i++)
	{
		tedptr[i]= ((TEDINFO*)(toptaddr[tedobj[i]].ob_spec))->te_ptext;
		itoa(*(tedval[i]),tedptr[i],2);
	}

	/* save old values, old snapping undefined if snapping turned off */
	oldsnap_x= temsnapx ? temsnap_x : -1 ;
	oldsnap_y= temsnapy ? temsnap_y : -1 ;
	oldtofit= temtofit;
	oldoutl= temoutl;
	oldbug= temdebug;

again:
	if (do_dial(toptaddr,TOPTSNPX)==OKTOPT)
	{
		/* decode from dialog box */
		for (i=0; i<NFLAGS; i++)
			*(flags[i])= toptaddr[obj[i]].ob_state&SELECTED ? 1 : 0 ;
		for (i=0; i<NEDIT; i++)
		{
			temp= atoi(tedptr[i]);
			if ((temp<2)||(temp>99))
			{
				form_alert(1,BADSNAPVAL);
				goto again;
			}
			*(tedval[i])= temp;
		}

		/* if snapping changed, optionally snap all controls on curr page */
		if (!temsnapx) oldsnap_x= temsnap_x;
		if (!temsnapy) oldsnap_y= temsnap_y;
		if ((oldsnap_x!=temsnap_x)||(oldsnap_y!=temsnap_y))
		{
			if (form_alert(2,CHEKSNAP)==1)
			{
				snap_tem(1,1);
				mustdraw=1;
				oldtofit= temtofit;	/* snap_tem() includes fitting */
			}
		}
		if ((oldtofit!=temtofit)&&temtofit)
		{
			if (form_alert(2,CHEKTOFIT)==1)
			{
				snap_tem(0,1);	/* clip without snapping */
				mustdraw=1;
			}
		}
		if (oldoutl!=temoutl) mustdraw=1;

		/* if debugging has been turned on, run debugger */
		if ( !oldbug && temdebug ) hivTest();

		if (mustdraw) draw_alltem();
	}
}	/* end do_temopts() */

/* find which control mouse is pointing at ..................................*/
/* returns control #, -1 if none */

find_ctrl(mx,my,ptr_out)
int mx,my;		/* mouse absolute screen coordinates */
long *ptr_out;	/* returned --> found control header, 0L if none */
{
	register int i,found_i;
	register long ptr;
	CTRLHEADER *ctrl;
	int type;
	int x1,y1,x2,y2,x,y;
	long val_to_val();

	/* default: none found */
	*ptr_out= 0L ;
	found_i= -1;

	ptr= heap[curr_mem].start;
	for (i=0; i<curr_nctrls; i++)
	{
		ctrl= (CTRLHEADER*)(ptr);
		type= ctrl->type;
		if (type>=0)	/* if visible */
		{
			rect2scr(ptr+sizeof(ctrlheader),&x1,&x2,&y1,&y2);
			if (x2<x1) { x=x2; x2=x1; x1=x; }
			if (in_rect(mx,my,x1,y1,x2-x1+1,y2-y1+1))
			{
				if (type==CTYP_LINE)
				{
					if ( abs(x2-x1) > abs(y2-y1) )
					{
						y= val_to_val((long)mx,(long)x1,(long)x2,(long)y1,(long)y2);
						if ( abs(y-my) <=1 ) found_i= i;
					}
					else
					{
						x= val_to_val((long)my,(long)y1,(long)y2,(long)x1,(long)x2);
						if ( abs(x-mx) <= 1 ) found_i= i;
					}
				}
				else
					found_i=i;
				if (found_i==i) *ptr_out= ptr;
			}	/* end if mouse inside control's rectangle */
		}	/* end if visible */
		ptr += ctrl->length;
	}	/* end loop through all controls */

	return found_i;

}	/* end find_ctrl() */

/* clear the current page ...................................................*/

clrcurrpage()
{
	if (form_alert(1,CHEKCLRPAGE)==1)
	{
		curr_leng= 0L;
		curr_nctrl= curr_nvctrl= 0;
		draw_alltem();
	}
}	/* end clrcurrpage() */

/* copy the current page to another page ....................................*/

copycurrpage()
{
	register int i,nhot;
	int hotx[NTEMPAGES],hoty[NTEMPAGES],hotw[NTEMPAGES],hoth[NTEMPAGES];
	int w,h,mx,my;

	/* position and size of all valid destinations */
	w= tem1addr[TEM1PAGE].ob_width;
	h= tem1addr[TEM1PAGE].ob_height;
	for (i=nhot=0; i<NTEMPAGES; i++)
	{
		if (i!=curr_page)
		{
			objc_offset(tem1addr,TEM1PAGE+i,&hotx[nhot],&hoty[nhot]);
			hotw[nhot]= w;
			hoth[nhot++]= h;
		}
	}

	tem_prompt(COPYPAGEMSG);
	objc_offset(tem1addr,TEM1PAGE+curr_page,&mx,&my);
	HIDEMOUSE;
	slide_box(&mx,&my,w,h,0,0,640,200*rez,
						nhot,hotx,hoty,hotw,hoth,hotx,hoty,hotw,hoth);
	SHOWMOUSE;
	tem_prompt(0L);

	getmouse(&mx,&my);
	i= objc_find(tem1addr,ROOT,MAX_DEPTH,mx,my) - TEM1PAGE ;
	if ((i>=0)&&(i<NTEMPAGES)&&(i!=curr_page)) copycurr2i(i);

}	/* end copycurrpage() */

copycurr2i(i)
int i;	/* page to be copied to */
{
	int mem;
	char pagestr[2];

	pagestr[0]= '1'+i;
	pagestr[1]= 0;
	if (big_alert(1,CHEKCPPGE1,pagestr,CHEKCPPGE2)==1)
	{
		graf_mouse(BEE_MOUSE);
		change_mem(curr_mem,curr_leng);	/* shrink source */
		mem= temmem[ seg_to_mem(idTEMPAGE0+i) ] ;
		if (change_mem(mem,curr_leng))	/* expand destination */
		{
			copy_words(heap[curr_mem].start,heap[mem].start,
							heap[curr_mem].nbytes/2);
			/* change all linkpages on destination page */
			adjust_page(heap[mem].start,heap[mem].nbytes,1,i,-1);
			/* deselect all controls on destination page */
			desel_ctrls(mem,curr_leng);
			change_flag[temCHANGE]=1;
		}
		expand_curr();
		graf_mouse(ARROWMOUSE);
	}
}	/* end copycurr2i() */

/* user-interface for copy or move a control ................................*/

drag_ctrl(ctrl,mx,my,copy)
long ctrl;	/* --> control header */
int mx,my,copy;
{
	int x1,x2,y1,y2;
	int new_x1,new_y1;
	int del_x,del_y;

	rect2scr(ctrl+sizeof(ctrlheader),&x1,&x2,&y1,&y2);
	if (y2<y1)	/* sliding box must be positive */
	{
		asm { move.w y1(a6),d0		move.w y2(a6),y1(a6)		move.w d0,y2(a6) }
	}
	new_x1= x1;
	new_y1= y1;
	tem_prompt(copy ? COPYCTRLMSG : MOVECTRLMSG );
	HIDEMOUSE;
	slide_box(&new_x1,&new_y1,x2-x1+1,y2-y1+1,0,tem_y,640,tem_h,
					0,0L,0L,0L,0L,0L,0L,0L,0L);
	SHOWMOUSE;
	tem_prompt(0L);
	if (Kbshift(-1)&K_ALT) return;	/* aborted */
	del_x= new_x1 - x1 ;
	del_y= new_y1 - y1 ;
	if (!del_x && !del_y) return;		/* no change */
	if (copy)
		copy_ctrl(ctrl,new_x1,x2+del_x,new_y1,y2+del_y,1,0);
	else
		move_ctrl(ctrl,new_x1,x2+del_x,new_y1,y2+del_y,1);
}	/* end drag_ctrl() */

/* convert seg type to temmem index .........................................*/
/* returns 0 - (NTEMSEGS-1) , -1 for unknown seg type */

seg_to_mem(seg)
int seg;
{
	switch (seg)
	{
		case idTEMSTRG   : return 0;	/* Justin wants string pool first in file */
		case idTEMEBDT   : return 1; /* and he wants EBDT second */
		case idTEMPAGE0+0:
		case idTEMPAGE0+1:
		case idTEMPAGE0+2:
		case idTEMPAGE0+3:
		case idTEMPAGE0+4:
		case idTEMPAGE0+5:
		case idTEMPAGE0+6:
		case idTEMPAGE0+7: return seg-idTEMPAGE0+2;
		default:			  return -1;
	}	/* end switch (seg) */
}	/* end seg_to_mem() */

/* convert temmem index to seg type .........................................*/
/* returns segtype */

mem_to_seg(mem)
int mem;		/* must be valid */
{
	switch (mem)
	{
		case 0: return idTEMSTRG ; /* Justin wants string pool first in file */
		case 1: return idTEMEBDT ; /* and he wants EBDT second */
		default: return idTEMPAGE0+mem-2 ;
	}	/* end switch (mem) */
}	/* end mem_to_seg() */

/* display prompt centered at top of screen .................................*/

tem_prompt(msg)
char *msg;
{
	register long templong;

	if (!msg) msg= tem1addr[TEM1REGN].ob_state&SELECTED ? TEMR_MSG : TEM_MSG ;
	HIDEMOUSE;
	templong= rez==2 ? 20 : 40 ;
	templong *= (200*rez - temheader.page_h) ;
	set_longs(scrbase,templong,0xFFFFFFFFL);
	gr_color= WH_ON_BL;
	gr_text(msg,40-strlen(msg)/2,0);		/* centered */
	gr_color= BL_ON_WH;
	SHOWMOUSE;
}	/* end tem_prompt() */

/* edit the template global record ..........................................*/

do_temglob()
{
	int oldsend;
	
	oldsend=	temheader.no_send;
	temheader.no_send= form_alert(temheader.no_send+1,CHEKTEMGLOB)-1;
	if ( oldsend != temheader.no_send ) change_flag[temCHANGE]=1;
}	/* end do_temglob() */

/* change mouse shape .......................................................*/

tem_mouse(mshape)
int mshape;
{
static int bow_icon[5+16+16]= {
0,7,1,0,1,
0x01c0, 0x0220, 0x02d0, 0x0488,
0x1484, 0x2A82, 0x5f7d, 0x8001,
0x5f7d, 0x2A82, 0x1484, 0x0488,
0x02d0, 0x0220, 0x01c0, 0x0000,
0x0000, 0x01c0, 0x0120, 0x0310,
0x0308, 0x1104, 0x2082, 0x7ffe,
0x2082, 0x1104, 0x0308, 0x0310,
0x0120, 0x01c0, 0x0000, 0x0000
};

static int cross_icon[5+16+16]= {
8,7,1,0,1,
0x0140, 0x0140, 0x0140, 0x0140,
0x0140, 0x0140, 0x7F7F, 0x0000,
0x7F7F, 0x0140, 0x0140, 0x0140,
0x0140, 0x0140, 0x0140, 0x0000,
0x0080, 0x0080, 0x0080, 0x0080,
0x0080, 0x0080, 0x0000, 0x7E3F,
0x0000, 0x0080, 0x0080, 0x0080,
0x0080, 0x0080, 0x0080, 0x0000
};

static int copy_icon[5+16+16]= {
2,7,1,0,1,
0x0092, 0x0124, 0x0248, 0x0490,
0x0920, 0x1240, 0x2480, 0x4900,
0x2480, 0x1240, 0x0920, 0x0490,
0x0248, 0x0124, 0x0092, 0x0000,
0x0000, 0x0092, 0x0124, 0x0248,
0x0490, 0x0920, 0x1240, 0x2480,
0x1240, 0x0920, 0x0490, 0x0248,
0x0124, 0x0092, 0x0000, 0x0000
};

static int move_icon[5+16+16]= {
8,7,1,0,1,
0x0140, 0x0220, 0x0550, 0x0360,
0x1144, 0x294A, 0x5F7D, 0x0000,
0x5F7D, 0x294A, 0x1144, 0x0360,
0x0550, 0x0220, 0x0140, 0x0000,
0x0080, 0x01C0, 0x02A0, 0x0080,
0x0080, 0x1084, 0x2002, 0x7E3F,
0x2002, 0x1084, 0x0080, 0x0080,
0x02A0, 0x01C0, 0x0080, 0x0000
};

static int region_icon[5+16+16]= {
8,7,1,0,1,
0x0080, 0x0000, 0x0080, 0x0000,
0x0080, 0x0000, 0x0080, 0x5555,
0x0080, 0x0000, 0x0080, 0x0000,
0x0080, 0x0000, 0x0080, 0x0000,
0x0000, 0x0080, 0x0000, 0x0080,
0x0000, 0x0080, 0x0000, 0x2A2A,
0x0000, 0x0080, 0x0000, 0x0080,
0x0000, 0x0080, 0x0000, 0x0000
};

static int *icons[5]= {
	cross_icon, bow_icon, move_icon, copy_icon, region_icon
};

	if (mshape)
		graf_mouse(255,icons[mshape-1]);
	else
		graf_mouse(ARROWMOUSE);

}	/* end tem_mouse() */

#endif

/* EOF */
