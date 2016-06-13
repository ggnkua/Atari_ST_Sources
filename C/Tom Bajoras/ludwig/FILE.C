/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	filestuf -- disk i/o and HybriSwitch interface

	ex_load, ex_save, ex_drive, ex_delete, ex_format, ex_switch,
	ex_sng,
	getfile, new_ext, load_header, load_data, save_file, do_ldsv

******************************************************************************/

overlay "file"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"

extern char *_base;		/* in init */
extern long init_ssp;	/* in init */

/* load a Ludwig file .......................................................*/

ex_load()
{
	char *titlptr,*fnameptr;
	char filename[13],pathname[80];
	int filehand,nsegs;
	long templong;
	long directory[2*MAXNSEG];
	register int i,j;

	if (midiplex>=0) MPoff();

	/* pointers to text fields */
	titlptr= ((TEDINFO*)(ldsvaddr[LDSVTITL].ob_spec))->te_ptext;
	fnameptr= ((TEDINFO*)(ldsvaddr[LDSVFILE].ob_spec))->te_ptext;
	strcpy(titlptr,LOAD_MSG);

	filename[0]=0;
	if (getfile(pathname,filename,FILE_EXT,LOAD_TITL))
	{
		graf_mouse(BEE_MOUSE);
		templong= Fopen(pathname,0);
		graf_mouse(ARROWMOUSE);
		if (templong<0L)
			big_alert(1,BADOPEN1,filename,BADOPEN2);
		else
		{
			filehand=templong;
			if (nsegs=load_header(filehand,filename,directory))
			{
			/* enable buttons for existing data segments */
				for (i=0; i<NSEG; i++)
				{
					if ( (i<nsegs) && directory[2*i] )
					{
						ldsvaddr[ldsvobj[i]].ob_state &= ~DISABLED;
						ldsvaddr[ldsvobj[i]].ob_state |= SELECTED;
					}
					else
					{
						ldsvaddr[ldsvobj[i]].ob_state |= DISABLED;
						ldsvaddr[ldsvobj[i]].ob_state &= ~SELECTED;
					}
				}
				strcpy(fnameptr,filename);
				if (do_ldsv()==OKLDSV)
				{
					/* clear out and count unwanted directory listings */
					for (i=j=0; i<NSEG; i++)
						if ( !(ldsvaddr[ldsvobj[i]].ob_state & SELECTED) )
						{ directory[2*i]=0L; j++; }
					/* optionally init all segments before loading */
					if (j)
						if (form_alert(1,CHEKINALL)==1)
							for (i=0; i<NSEG; i++) def_seg(i);

					load_data(filehand,filename,directory,8L+8L*nsegs);
					draw_screen();
					menu_icheck(menuaddr,LUSYNC,masterdata[M_SYNC]);
					menu_icheck(menuaddr,LUPATCH,j=masterdata[M_PATCH]);
					menu_icheck(menuaddr,LU_LINK,masterdata[M_LINK]);
					if (j) send_patches();
					midithru= masterdata[M_THRUON];
					thruchan= masterdata[M_THRUCHON] ? 
									masterdata[M_THRUCHAN]-1 : -1 ;
					if (midiplex>=0) thruport= masterdata[M_PLEXER];
					strcpy(songname,filename);
					disp_name();
				}	/* end if OK from dialog box */
			}	/* end if header loaded */
			Fclose(filehand);
		}	/* end if file opened */
	}	/* end if OK from file selector */

	if (midiplex>=0) MPon();

}	/* end ex_load() */

/* auto-load a Ludwig file ..................................................*/
/* returns non-0 for success, 0 failed */

auto_load(filename)
char *filename;
{
	long templong;
	int filehand;
	long directory[2*MAXNSEG];
	int nsegs;
	register int i=0;	/* return code */

	graf_mouse(BEE_MOUSE);
	templong= Fopen(filename,0);
	graf_mouse(ARROWMOUSE);
	if (templong>=0L)
	{
		filehand=templong;
		if (nsegs=load_header(filehand,filename,directory))
		{
			load_data(filehand,filename,directory,8L+8L*nsegs);
			draw_screen();
			menu_icheck(menuaddr,LUSYNC,masterdata[M_SYNC]);
			menu_icheck(menuaddr,LUPATCH,i=masterdata[M_PATCH]);
			menu_icheck(menuaddr,LU_LINK,masterdata[M_LINK]);
			if (i) send_patches();
			i=1;	/* success */
		}
		Fclose(filehand);
	}
	return(i);
}	/* end auto_load() */

/* load file header .........................................................*/
/* returns # of data segments, 0= error */

load_header(filehand,filename,filebuf)
int filehand;
char *filename;
long *filebuf;
{
	int nsegs;
	long templong;

/* read magic long */
	graf_mouse(BEE_MOUSE);
	templong= Fread(filehand,4L,filebuf);
	graf_mouse(ARROWMOUSE);
	if (templong!=4L)
	{
		big_alert(1,BADREAD1,filename,BADREAD2);
		return(0);
	}
/* check for magic */
	if ( filebuf[0] != MAGIC )
	{
		form_alert(1,BADMAGIC);
		return(0);
	}
/* read directory length */
	graf_mouse(BEE_MOUSE);
	templong= Fread(filehand,4L,filebuf);
	graf_mouse(ARROWMOUSE);
	if (templong!=4L)
	{
		big_alert(1,BADREAD1,filename,BADREAD2);
		return(0);
	}
	nsegs= filebuf[0];
	if (nsegs>MAXNSEG)
	{
		form_alert(1,BADNSEG);
		return(0);
	}
/* read directory */
	graf_mouse(BEE_MOUSE);
	templong= Fread(filehand,8L*nsegs,filebuf);
	graf_mouse(ARROWMOUSE);
	if (templong!=(8L*nsegs))
	{
		big_alert(1,BADREAD1,filename,BADREAD2);
		return(0);
	}
	return(nsegs);	/* success */
}	/* end load_header() */

/* load data segments from Ludwig file ......................................*/

load_data(filehand,filename,directory,datastart)
int filehand;
char *filename;
long *directory;	/* non-0 entry for each segment that is to be loaded */
long datastart;	/* from start of file to start of first data segment */
{
	register int i;
	long leng;

	graf_mouse(BEE_MOUSE);
	for (i=0; i<NSEG; i++)
		if (leng=directory[2*i])
		{
			Fseek( datastart+directory[2*i+1],filehand,0);
			def_seg(i);	/* init in case segment is incomplete or read fails */
			if ( Fread(filehand,leng,segptr[i]) != leng ) break;
		}
	graf_mouse(ARROWMOUSE);

	if (i<NSEG) big_alert(1,BADREAD1,filename,BADREAD2);

}	/* end load_data() */

/* save a Ludwig file (user-interface) ......................................*/

ex_save()
{
	char *titlptr,*fnameptr;
	char filename[13],pathname[80];
	long templong;
	int filehand,nseg;
	int segflags[NSEG];
	register int i;

#if DEMOFLAG
	form_alert(1,DEMOMSG);
#else

	if (midiplex>=0) MPoff();

	/* pointers to text fields */
	titlptr= ((TEDINFO*)(ldsvaddr[LDSVTITL].ob_spec))->te_ptext;
	fnameptr= ((TEDINFO*)(ldsvaddr[LDSVFILE].ob_spec))->te_ptext;
	strcpy(titlptr,SAVE_MSG);

	filename[0]=0;
	if (getfile(pathname,filename,FILE_EXT,SAVE_TITL))
	{
		new_ext(pathname,FILE_EXT);   new_ext(filename,FILE_EXT);
		strcpy(fnameptr,filename);
		/* enable all buttons */
		for (i=0; i<NSEG; i++) ldsvaddr[ldsvobj[i]].ob_state &= ~DISABLED;
		if (do_ldsv()==OKLDSV)
		{
			/* save which segments? */
			nseg=0;
			for (i=0; i<NSEG; i++)
				if (segflags[i] = (ldsvaddr[ldsvobj[i]].ob_state & SELECTED) )
					nseg++;
			if (nseg)
			{
				graf_mouse(BEE_MOUSE);
				templong= Fopen(pathname,1);
				graf_mouse(ARROWMOUSE);
				filehand=(-1);
				if (templong<0L)
				{  /* file does not exist yet, so try to create it */
					graf_mouse(BEE_MOUSE);
					templong= Fcreate(pathname,0);
					graf_mouse(ARROWMOUSE);
					if (templong<0L)
						big_alert(1,BADCREAT1,filename,BADCREAT2);
					else
						filehand=templong;
				}
				else
				{  /* file already exists -- replace it? */
					filehand=templong;
					if (big_alert(1,CHEKREPL1,filename,CHEKREPL2)==2)
					{
						Fclose(filehand);
						filehand=(-1);
					}
					else
					{
						graf_mouse(BEE_MOUSE);
						filehand= Fcreate(pathname,0);
						graf_mouse(ARROWMOUSE);
						if (filehand<0) big_alert(1,BADWRITE1,filename,BADWRITE2);
					}
				}
				if (filehand>=0)
				{
					save_file(filehand,filename,segflags);
					Fclose(filehand);
					strcpy(songname,filename);
					disp_name();
				}
			}	/* end if saving more than zero segments */
		}	/* end if OK from dialog box */
	}	/* end if OK from file selector */

	if (midiplex>=0) MPon();

#endif
}	/* end ex_save() */

/* save a Ludwig file (the dirty work) ......................................*/

save_file(filehand,filename,segs)
int filehand;
char *filename;
int *segs;	/* non-0 for each segment that is to be saved */
{
	long directory[2*MAXNSEG];
	register int i;
	long offset;
	int result=0;	/* default: error */

	graf_mouse(BEE_MOUSE);

	/* write magic and directory size */
	directory[0]=MAGIC;
	directory[1]=(long)NSEG;
	if (Fwrite(filehand,8L,directory)==8L)
	{
		/* build and write directory */
		offset=0L;
		for (i=0; i<NSEG; i++)
		{
			if ( directory[2*i] = segs[i] ? segleng[i] : 0L )
			{
				if (i==10) directory[2*i] -= PITCH1LENG*compr_pitch();
				if (i==11) directory[2*i] -= RHYTH1LENG*compr_rhyth();
			}
			directory[2*i+1]= offset;
			offset += directory[2*i];
		}
		if (Fwrite(filehand,8L*NSEG,directory)==(8L*NSEG))
		{
			/* write data segments that have non-zero length */
			for (i=0; i<NSEG; i++)
				if (offset=directory[2*i])
					if (Fwrite(filehand,offset,segptr[i])!=offset) break;
			result= i==NSEG;
		}
	}
	graf_mouse(ARROWMOUSE);

	if (!result) big_alert(1,BADWRITE1,filename,BADWRITE2);

}	/* end save_file() */

compr_pitch()		/* returns # of init'd pitch groups at end of pitchdata */
{
	register int i;
	char defpitch1[PITCH1LENG];

	def_pitch1(defpitch1);
	for (i= NGRP-1; i>=0; i--)
		if (comp_bytes(pitch1data[i],defpitch1,(int)(PITCH1LENG))) break;
	return (NGRP-1-i);

}	/* end compr_pitch() */

compr_rhyth()		/* returns # of init'd rhythm groups at end of rhythmdata */
{
	register int i;
	char defrhyth1[RHYTH1LENG];

	def_rhyth1(defrhyth1);
	for (i= NGRP-1; i>=0; i--)
		if (comp_bytes(rhyth1data[i],defrhyth1,(int)(RHYTH1LENG))) break;
	return (NGRP-1-i);

}	/* end compr_rhyth() */

/* change current drive .....................................................*/

ex_drive()
{
	register int i,j;
	int currdrive;

	currdrive= Dgetdrv();   /* = 0,1,etc. for drive A,B,etc. */
/* disable unavailable drives */
	j= Drvmap();
	for (i=0; i<16; i++)
		if (BITTEST(i,j))
		{
			drivaddr[ADRIVE+i].ob_state &= ~DISABLED;
			drivaddr[ADRIVE+i].ob_flags = SELECTABLE|EXIT;
			if (i==currdrive)	drivaddr[ADRIVE+i].ob_flags |= DEFAULT;
		}
		else
		{
			drivaddr[ADRIVE+i].ob_state = DISABLED;
			drivaddr[ADRIVE+i].ob_flags &= ~(SELECTABLE|EXIT|DEFAULT);
		}
/* set new drive */
	Dsetdrv( do_dial(drivaddr,(-1)) - ADRIVE );
}  /* end ex_drive() */

/* delete a file ............................................................*/

ex_delete()
{
	char filename[13],pathname[80];
	long templong;

	if (midiplex>=0) MPoff();

	filename[0]=0;
	if (getfile(pathname,filename,FILE_EXT,DEL_TITL))
	{
		if (big_alert(1,CHEKDEL1,filename,CHEKDEL2)==1)
		{
			graf_mouse(BEE_MOUSE);
			templong= Fdelete(pathname);
			graf_mouse(ARROWMOUSE);
			if (templong) big_alert(1,BADDEL1,filename,BADDEL2);
		}
	}

	if (midiplex>=0) MPon();

}  /* end ex_delete() */

/* format a disk ............................................................*/

ex_format()
{
	register int trackno,i,driveno,nsides;
	int error;

/* 1st chance to abort */
	if (form_alert(1,CHEKFMT) == 2) return;
/* 2nd chance to abort */
	if (do_dial(fmtaddr,-1) == CANFMT) return;

	if (midiplex>=0) MPoff();

/* drive A (0) or B (1) ? */
	driveno = ( fmtaddr[DRIVEB].ob_state & SELECTED ) ? 1 : 0 ;
/* single (0) or double (1) sided ? */
	nsides =  ( fmtaddr[SIDE2].ob_state & SELECTED )  ? 1 : 0 ;

	graf_mouse(BEE_MOUSE);
	
/* format 80 tracks, 9 sectors per track, 1 or 2 sides, drive A or B,
	abort on any error */
	trackno= 0;
	do
	{
		for (i=error=0; !error&&(i<=nsides); i++)
			error= Flopfmt(scrsave,0L,driveno,9,trackno,i,1,0x87654321L,0xe5e5);
	}
	while ( ((++trackno)<80) && !error);

	if (!error)
	{
		set_words(scrsave,4608,0);
		error= Flopwr(scrsave,0L,driveno,1,0,0,9);    /* zero the FAT */
		if (!error)
		{
			error= Flopwr(scrsave,0L,driveno,1,1,0,9);  
			if (!error)
			{
				Protobt(scrsave,0x01000000,2+nsides,0);   /* write a boot sector */
				error= Flopwr(scrsave,0L,driveno,1,0,0,1);
			}
		}
	}

	if (midiplex>=0) MPon();

	graf_mouse(ARROWMOUSE);

/* if necessary, error message */
	if (error) form_alert(1,BADFMT);

}	/* end ex_format() */

/* HybriSwitch ..............................................................*/

ex_switch(part)
int part;	/* where to switch to, -1 for unknown */
{
	int finishup();
	char save_a=timer_a;
	char save_d=timer_d;
	long saveclock,save_but,save_mot;
	int savepause;
	unsigned int savetempo;
	int clock(),playclock();
	register int i;
	long physbase;

	/* can't switch to yourself */
	if ( part == *(int*)(sw_ptr+34L) ) return;
	/* nonexistent partition= HybriSwitch program */
	if ( part >= *(int*)(sw_ptr+32L) ) part=(-1);
	/* tell switcher where to switch to */
	*(int*)(sw_ptr+36L) = part;
	/* reassure switcher that we know what we're doing */
	*(int*)(sw_ptr+40L) = 0;

	/* save/install timer A */
	saveclock=masterclock;
	masterclock= 0L;
	savepause=play_pause;
	play_pause=1;
	throwaway=25;
	clockdivider=1;
	savetempo= masterdata[M_TEMPO];
	if (save_a)
	{
		for (i=0; i<NSEQ; i++) seq_off(i);
		asm {
			move.w  	#13,-(a7)
			move.w  	#26,-(a7)
			trap		#14
			addq.w  	#4,a7
		}
		timer_a=0;
	}
	if (save_d)
	{
		asm {
			move.w  	#4,-(a7)
			move.w  	#26,-(a7)
			trap		#14
			addq.w  	#4,a7
		}
		timer_d=0;
	}
	/* save butv1/motv */
	save_but= *(long*)(Abase-58L);
	save_mot= *(long*)(Abase-50L);

	/* snap the screen */
	qsave_screen(0,200*rez-1);
	/* finishup closes the window, but hide this by flipping screen */
	physbase= Physbase();
	Setscreen(-1L,scrsave,-1);

	if (!mshrinkamt) mshrinkamt= *( (long*)(_base+8L) );

	asm {
		movem.l	d0-a6,-(a7)			; save all registers
		lea		saveA7,a0
		move.l	a7,(a0)				; save a7
		jsr		finishup				; almost quit
	}

	/* unhide the screen */	
	qrest_screen(0,200*rez-1);
	Setscreen(-1L,physbase,-1);

	asm {
		lea		ret,a0
		move.l	_base(a4),a1
		move.l	a0,8(a1)				; re-entrance address

		move.l	init_ssp(a4),-(a7)
		move.w	#32,-(a7)
		trap		#1						; go to user mode
		addq.w	#6,a7

		clr.w		-(a7)
		move.l	mshrinkamt(a4),-(a7)
		move.w	#49,-(a7)
		trap		#1						; ptermres

	saveA7:		dc.w 0,0				; temporary storage for a7
	ret:
		lea		saveA7,a0
		move.l	(a0),-(a7)
		move.w	#32,-(a7)
		trap		#1						;	back to super mode (and restore a7)

		movem.l	(a7)+,d0-a6			; restore all registers

		move.l	mshrinkamt(a4),-(A7)
		move.l	_base(a4),-(A7)
		clr.w		-(A7)
		move.w	#0x4a,-(A7)			; mshrink
		trap		#1
		adda.w	#12,A7
	}

	/* restore screen */
	if (no_dissolve)
		qrest_screen(0,200*rez-1);
	else
	{
		HIDEMOUSE;
		asm { move.l	scrsave(a4),-(a7)
				movea.l	sw_ptr(a4),a0
				movea.l	(a0),a0
				jsr		(a0)
				addq.w	#4,a7 }
		SHOWMOUSE;
	}
	startup(1);

	/* restore butv/motv */
	*(long*)(Abase-58L)= save_but;
	*(long*)(Abase-50L)= save_mot;

	/* restore play */
	play_pause=savepause;
	masterclock=saveclock;
	set_tempo(savetempo);
	if (save_a)
	{
		asm {	
			pea		clock
			move.w  	#64,-(a7)   		; on 2400hz timer A
			move.w  	#3,-(a7)			; div 16
			clr.w   	-(a7)
			move.w  	#31,-(a7)
			trap		#14
			adda.w	#12,a7
		}
		timer_a=1;
	}
	if (save_d)
	{
		asm {	
			pea		playclock
			move.w  	#64,-(a7)
			move.w  	#5,-(a7)				; div 64
			move.w 	#3,-(a7)
			move.w  	#31,-(a7)
			trap		#14
			adda.w	#12,a7
		}
		timer_d=1;
	}

}	/* end ex_switch() */

/* save play buffer to a SNG file or to Keep Buffer .........................*/

ex_sng()
{
	register long templong;
	register long *longptr;
	register char *charptr;
	register int i,temp;

	char filename[13],pathname[80];
	int filehand;
	long *find_mtst();
	long *keepstart,*keepend,*keeptail,*fromstart,*fromend;
	int mtstpart,mtst;
	char line1[32],line2[32],line3[32];

#if DEMOFLAG
	form_alert(1,DEMOMSG);
#else

	longptr= sw_ptr ? find_mtst(&mtstpart) : (long*)(0L) ;
	if (longptr && (form_alert(1,CHEKSHAR)==1) )
	{
		mtst= longptr[5]=='MTST';	/* smptetrack or eztrack ? */
		for (i=0; i<NSEQ; i++)
		{
			if (mtst)
				sharaddr[SHARBUT0+i].ob_flags &= ~RBUTTON;
			else
			{
				sharaddr[SHARBUT0+i].ob_flags |= RBUTTON;
				sharaddr[SHARBUT0+i].ob_state &= ~SELECTED;
			}
		}
		if (!mtst) sharaddr[SHARBUT0].ob_state |= SELECTED;
				
	again:
		temp= do_dial(sharaddr,-1);
		if (temp==CANSHAR) return;
		if (temp==SHARINFO)
		{
			draw_summary();
			do_dial(trakaddr,-1);
			goto again;
		}

		for (i=0; i<NSEQ; i++)
		{
			if (sharaddr[SHARBUT0+i].ob_state & SELECTED)
			{
				/* copy selected track to sequencer's keep buffer */
				keepstart=	*(long**)( longptr[2] );
				keeptail=	*(long**)( longptr[3] );
				keepend=		*(long**)( longptr[4] );
				fromstart=	playstart[i];
				fromend=		playtail[i];
				if (keepstart!=keeptail)
					if (form_alert(1,CHEKKEEP)==2) return;
				while ( (keepstart<keepend-1) && (fromstart<fromend) )
					*keepstart++ = *fromstart++ ;
			/* if track didn't fit in keep buffer: truncate or cancel */
				if (keepstart==keepend)
					if (form_alert(1,CHEKSHARE)==2) goto again;
				*keepstart++ = 0L;	/* end of track */
				*(long**)( longptr[3] ) = keepstart;
			/* set flag telling mtst that it is receiving data */
				charptr= (char*)( ((long*)sw_ptr)[4] );
				charptr += 8*mtstpart;
				charptr[2]=1;
			/* tell mtst (but not ezt) to come back */
				if (mtst)
				{
					*(int*)( longptr+11 ) = *(int*)(sw_ptr+34L);
					strcpy(line1,SHARMSG1); strcat(line1,int1char[i+1]);
					longptr[6]= (long)(line1);
					longptr[7]= (long)(" ");
					strcpy(line2,SHARMSG2); strcat(line2,nonr1data[i]+N_NAME);
					longptr[8]= (long)(line2);
					strcpy(line3,SHARMSG3A);
					strcat(line3,int2char[*(int*)(nonr1data[i]+N_MIDICH)+1]);
					strcat(line3,SHARMSG3B);
					if (temp=nonr1data[i][N_PATCH]+1)
					{
						strcat(line3,int1char[temp/100]);
						strcat(line3,int2char[temp%100]);
					}
					else
						strcat(line3,"---");
					longptr[9]= (long)(line3);
					longptr[10]= (long)(nonr1data[i]+N_NAME);
					no_dissolve=1;	/* no screen dissolve effect on switch back */
				}
				menu_tnormal(menuaddr,LUFILE,1);
				ex_switch(mtstpart);
				no_dissolve=0;
			}	/* end if track button selected */
		}	/* end for all track buttons */
		if (!mtst) goto again;
		return;
	}

	if (midiplex>=0) MPoff();

	filename[0]=0;
	if ( getfile(pathname,filename,SNG_EXT,SNG_TITL) )
	{
		new_ext(pathname,SNG_EXT);   new_ext(filename,SNG_EXT);
		graf_mouse(BEE_MOUSE);
		templong= Fopen(pathname,1);
		graf_mouse(ARROWMOUSE);
		filehand=(-1);
		if (templong<0L)
		{  /* file does not exist yet, so try to create it */
			graf_mouse(BEE_MOUSE);
			templong= Fcreate(pathname,0);
			graf_mouse(ARROWMOUSE);
			if (templong<0L)
				big_alert(1,BADCREAT1,filename,BADCREAT2);
			else
				filehand=templong;
		}
		else
		{  /* file already exists -- replace it? */
			filehand=templong;
			if (big_alert(1,CHEKREPL1,filename,CHEKREPL2)==2)
			{
				Fclose(filehand);
				filehand=(-1);
			}
			else
			{
				graf_mouse(BEE_MOUSE);
				filehand= Fcreate(pathname,0);
				graf_mouse(ARROWMOUSE);
				if (filehand<0) big_alert(1,BADWRITE1,filename,BADWRITE2);
			}
		}
		if (filehand>=0)
		{
			save_sng(filehand);
			Fclose(filehand);
		}
	}

	if (midiplex>=0) MPon();

#endif
}	/* end ex_sng() */

/* is sequencer available for data sharing? .................................*/

long *find_mtst(which)		/* returns pointer to shared data, or 0L */
int *which;						/* returns partition # */
{
	char *charptr;
	register int i;
	long *longptr;

	charptr= (char*)( ((long*)sw_ptr)[4] );	/* --> shared data table */
	for (i=0; i<16; i++,charptr+=8)
		if ( *(int*)(charptr) < 51 )	/* i.d. # */
			if (!charptr[2] && charptr[3]) break;

	if (i==16) return( (long*)(0L) );
	*which=i;

	longptr= (long*)(charptr+4);
	longptr= (long*)(longptr[0]);						/* shared data */
	if (longptr[0]!='MTST') return((long*)(0L));	/* magic longword not found */

	return(longptr);
}	/* end find_mtst() */

save_sng(filehand)
int filehand;
{
	char *charptr;
	register int *intptr;
	register long *longptr;
	register int i,j;
	register long templong;
	int trakmagic=0x90;
	long longzero=0L;
	long trakleng[NSEQ];

	/* notes array is NSEQ*NCHD*16 bytes, which should be big enough */
	charptr= (char*)(notes);
	intptr= (int*)(charptr);
	longptr= (long*)(charptr);

	/* traks.info is 1704 bytes */
	set_bytes(charptr,1704,0);
	intptr[0]= 0x10;	/* traks.info section i.d. */
	intptr[1]= 60;		/* # tracks in mtst */
	for (i=0; i<NSEQ; i++)		/* track names */
		copy_bytes(nonr1data[i]+N_NAME,charptr+4+16*i,16);
	for (i=0; i<NSEQ; i++)		/* track lengths (including end-of-track) */
		trakleng[i]= longptr[241+i]=
			(long)(playtail[i]) - (long)(playstart[i]) + 4L ;
	longptr[423]=templong= 0x100L; /* track pointer base (any valid address) */
	for (i=0; i<NSEQ; i++)		/* track pointers */
	{
		longptr[302+i]=templong;
		templong += longptr[241+i];
	}
	longptr[424]= templong;		/* record buffer = after all tracks */
	set_bytes(charptr+1452,60,-1);	/* default mutes */
	for (i=0; i<NSEQ; i++)
		charptr[1452+i]= nonr1data[i][N_MUTE] ? -1 : 0 ;	/* mutes */
	set_bytes(charptr+1572,60,-1);	/* default channels */
	for (i=0; i<NSEQ; i++)
		charptr[1572+i]= *(int*)(nonr1data[i]+N_MIDICH);

	/* write traks.info to disk */
	graf_mouse(BEE_MOUSE);
	templong= Fwrite(filehand,1704L,charptr);
	graf_mouse(ARROWMOUSE);
	if (templong!=1704L) {	form_alert(1,BADSNG); return; }

	/* song.info is 60 bytes */
	set_bytes(charptr,60,0);
	intptr[0]= 0x20;		/* song.info section i.d. */
	charptr[2]= masterdata[M_TEMPO];	/* tempo */
	charptr[3]= masterdata[M_SYNC] ? -1 : 0 ;	/* midi sync output */
	charptr[4]= masterdata[M_THRUON];
	charptr[5]= masterdata[M_THRUCHON] ? masterdata[M_THRUCHAN] : -1 ;
	charptr[7]= masterdata[M_SYNC] ? 0 : -1 ;	/* metronome */
	longptr[3]= -1L;	/* delete safety */
	longptr[4]= -1L;	/* replace safety */
	longptr[5]= -1L;	/* back up file safety */
	strcpy(charptr+24,SNG_NAME);	/* song name */
	charptr[57]= 15;	/* song transpose exempt channel */
	intptr[29]= 1;		/* file version */

	/* write song.info to disk */
	graf_mouse(BEE_MOUSE);
	templong= Fwrite(filehand,60L,charptr);
	graf_mouse(ARROWMOUSE);
	if (templong!=60L)
	{	form_alert(1,BADSNG); return; }

	/* write 0x90 int to disk */
	graf_mouse(BEE_MOUSE);
	templong= Fwrite(filehand,2L,&trakmagic);
	graf_mouse(ARROWMOUSE);	
	if (templong!=2L) {	form_alert(1,BADSNG); return; }

	for (i=0; i<NSEQ; i++)
	{
		trakleng[i]-=4L;
		graf_mouse(BEE_MOUSE);
		templong= Fwrite(filehand,trakleng[i],playstart[i]);
		graf_mouse(ARROWMOUSE);		
		if (templong!=trakleng[i]) {	form_alert(1,BADSNG); return; }
		graf_mouse(BEE_MOUSE);
		templong= Fwrite(filehand,4L,&longzero);
		graf_mouse(ARROWMOUSE);
		if (templong!=4L) {	form_alert(1,BADSNG); return; }
	}

#endif
}	/* end ex_sng() */

/* item selector ............................................................*/
/* returns 1 OK, 0 cancel */

getfile(pathname,fname,pathext,title)
char *pathname; /* output: full path name, if OK selected */
char *fname;    /* input: file name on item selector right side,
						 output: file name, if OK selected */
char *pathext;	 /* input: default extension for directory line */
char *title;	/* prompt at top of screen, 0L for none */
{
	char tmppath[64];
	char tmpname[13];
	int exit_obj, error;
	register int i;
	int result=0;
	char menu_save[1600];

	/* change screen */
	if (title)
	{
		HIDEMOUSE;
		copy_bytes(scrbase,menu_save,1600);
		gr_text(title,0,1);
		SHOWMOUSE;
	}

/* build item selector's top line */
	tmppath[0] = (i=Dgetdrv()) + 'A';
	tmppath[1] = ':';
	Dgetpath(&tmppath[2],i+1);
	if (i<2) Dfree(scrsave,i+1);	/* else mediach problems with midiplexer */
	strcat(tmppath, "\\");
	strcat(tmppath,"*.");
	strcat(tmppath,pathext);

	strcpy(tmpname,fname);
	save_screen(1,menu_hi_y+1,200*rez-1); /* save screen behind item selector */
	error= fsel_input(tmppath,tmpname,&exit_obj);
	save_screen(0);
	if (!exit_obj || !error)
		goto exit;
	else
	{
		if (!tmpname[0]) goto exit;   /* null file name treated as cancel */
		/* search backwards along directory, looking for dot */
		for (i=strlen(tmppath)-1; ((tmppath[i]!='.') && (i>1)); i--);
		if (i<=1) goto exit;   /* couldn't find dot */
		if (tmppath[i-1]!='*') goto exit;  /* no '*' before the dot */
		tmppath[i-1]=0;   /* chop off end of pathname */
		if ((tmppath[0]<'A')||(tmppath[0]>'P')) goto exit;  /* nonsense drive */
		/* update current drive and directory */
		Dsetdrv(tmppath[0]-'A'); Dsetpath(&tmppath[2]);
		strcpy(pathname,tmppath);
		strcat(pathname,tmpname);        /* return selected full pathname */
		strcpy(fname,tmpname);           /* return file name */
		result=1;	/* success */
	}
exit:

	/* change screen back */
	if (title)
	{
		HIDEMOUSE;
		copy_bytes(menu_save,scrbase,1600);
		SHOWMOUSE;
	}

	return(result);
}  /* end getfile() */

/* replace a filename's extension ...........................................*/

new_ext(name,ext)
char *name, *ext;
{
	register int i,j;

	for (i=(j=strlen(name))-1; i && name[i] != '.'; i--);
	if (!i) name[i=j] = '.';
	strcpy(&name[++i],ext);
}  /* end new_ext() */

/* generic load/save dialog box .............................................*/

do_ldsv()	/* returns exit object number */
{
	int edit_obj,done,mstate,exit_obj;
	register int i;

	putdial(ldsvaddr,1,0);
	edit_obj= (-1);
	done=0;
	do
	{
		exit_obj= my_form_do(ldsvaddr,&edit_obj,&mstate);
		switch (exit_obj)
		{
			case OKLDSV:
			case CANLDSV:		done=1; break;

			case ALLLDSV:
			/* select all enabled buttons */
			for (i=0; i<11; i++)
				if ( !(ldsvaddr[LDSVBUT0+i].ob_state & DISABLED) )
				{
					ldsvaddr[LDSVBUT0+i].ob_state |= SELECTED;
					draw_object(ldsvaddr,LDSVBUT0+i);
				}
			waitmouse();
			break;

			case NONELDSV:
			/* de-select all enabled buttons */
			for (i=0; i<11; i++)
				if ( !(ldsvaddr[LDSVBUT0+i].ob_state & DISABLED) )
				{
					ldsvaddr[LDSVBUT0+i].ob_state &= ~SELECTED;
					draw_object(ldsvaddr,LDSVBUT0+i);
				}
			waitmouse();
		}
	}
	while (!done);
	waitmouse();
	putdial(0L,0,exit_obj);
	return(exit_obj);

}	/* end do_ldsv() */

/* EOF file.c */
