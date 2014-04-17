/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	Module DISK
   NOTE:  MidiPlexer must be disabled/enabled around all disk functions!

	ex_delete, ex_copyfile, ex_creatf, ex_deletf
	ex_format, ex_paths, ex_prefs
	ex_autoload
	load_inf, load_cdr
	load_file, save_file, getfile, new_ext, new_exta, ext_ok
	Flength, Nfiles
	dsetpath, Dgetpath

******************************************************************************/

overlay "file"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

long load_file(),Flength();

/* delete file(s) ...........................................................*/

ex_delete()
{
#if DISKFLAG
	char filename[13],pathname[80];
	int saveMP;

	if (midiplexer) saveMP=MPoff();

	filename[0]=0;
	/* uses drive and path from most recent disk function */
	if (getfile(pathname,filename,ALL_EXT,DEL_TITL)>0)
	{
		if (big_alert(1,CHEKDEL1,filename,CHEKDEL2)==1)
		{
			/* delete all files with this pathname (pathname might contain
				wild card characters) -- error message only for first one */
			graf_mouse(BEE_MOUSE);
			if (Fdelete(pathname))
				big_alert(1,BADDEL1,filename,BADDEL2);
			else
				while (!Fdelete(pathname)) ;
			graf_mouse(ARROWMOUSE);
		}
	}

	if (midiplexer&&saveMP) MPon();

#endif
}  /* end ex_delete() */

/* format a disk ............................................................*/

ex_format()
{
#if DISKFLAG
	register int trackno,i,driveno,nsides;
	int error,saveMP;
	char progress[80],trackstr[3];

	if (do_dial(fmtaddr,-1,0L) == CANFMT) return;
	if (midiplexer) saveMP=MPoff();

/* drive A (0) or B (1) ? */
	driveno= whichbutton(fmtaddr,DRIVEA,2);
/* single (0) or double (1) sided ? */
	nsides= whichbutton(fmtaddr,SIDE1,2);

	graf_mouse(BEE_MOUSE);
	
/* format 80 tracks, 9 sectors per track, 1 or 2 sides, drive A or B,
	abort on any error */
	trackno= 0;
	copy_words(scrbase,cnxscrsave,800L);	/* save progress display area */
	set_words(scrbase,800L,0);
	do
	{
		strcpy(progress,FMT_MSG);
		itoa(trackno,trackstr,2);
		strcat(progress,trackstr);
		strcat(progress,FMT2_MSG);
		gr_text(progress,40-strlen(progress)/2,1);			/* centered */
		for (i=error=0; !error&&(i<=nsides); i++)
			if (Flopfmt(scrsave,0L,driveno,9,trackno,i,1,0x87654321L,0xe5e5))
				error=1;
		if (getmouse(&dummy,&dummy)) error=2; /* abort on mouse button */
	}
	while ( ((++trackno)<80) && !error);
	copy_words(cnxscrsave,scrbase,800L);	/* restore progress display area */

	if (!error)
	{
		set_words(scrsave,4608L,0);
		if (Flopwr(scrsave,0L,driveno,1,0,0,9)) error=1;    /* zero the FAT */
		if (!error)
		{
			if (Flopwr(scrsave,0L,driveno,1,1,0,9)) error=1;
			if (!error)
			{
				Protobt(scrsave,0x01000000,2+nsides,0);   /* write a boot sector */
				if (Flopwr(scrsave,0L,driveno,1,0,0,1)) error=1;
			}
		}
	}

	waitmouse();	/* in case formatting was aborted via mouse */
	graf_mouse(ARROWMOUSE);
	if (!error) make_tone();					/* no error */
	if (error==1) form_alert(1,BADFMT);		/* error */
	if (error==2) form_alert(1,BADFMT2);	/* aborted */
	if (midiplexer&&saveMP) MPon();

#endif
}	/* end ex_format() */

/* set paths ................................................................*/

ex_paths()
{
#if DISKFLAG
	int done,mstate,edit_obj,exit_obj;
	register int i,temp;
#define NPATHS 7
	char *ptr[NPATHS];
	static int obj[NPATHS]= {
		PATHCNX,PATHMAC,PATHTEM,PATHLDAT,PATHRDAT,PATHMIDI,PATHMULT
	};
	static int *drive[NPATHS]= {
		&cnx_drive,&mac_drive,&tem_drive,
		&ldat_drive,&rdat_drive,&midi_drive,&mlt_drive
	};
	static char *path[NPATHS]= {
		cnx_path,mac_path,tem_path,
		ldat_path,rdat_path,midi_path,mlt_path
	};
	static int findobj[NPATHS]= {
		FINDCNX,FINDMAC,FINDTEM,FINDLDAT,FINDRDAT,FINDMIDI,FINDMULT
	};
	static char *title[NPATHS]= {
		FINDCNXMSG,FINDMACMSG,FINDTEMMSG,FINDLDATMSG,
		FINDRDATMSG,FINDMIDIMSG,FINDMULTMSG
	};
	static char *ext[NPATHS]= {
		CNXF_EXT, MAXC_EXT, TE_EXT, ALL_EXT, ALL_EXT, ALL_EXT, MLX_EXT
	};
	char filename[13],pathname[80];

	for (i=0; i<NPATHS; i++)
	{
		ptr[i]= pathaddr[obj[i]].ob_spec;
		ptr[i][0]= 'A' + *drive[i];
		ptr[i][1]= ':';
		strcpy(ptr[i]+2,path[i]);
	}
	/* draw dialog box, centered */
	putdial(pathaddr,-1,0);
	
	edit_obj= -1;
	done=0;
	do
	{
		waitmouse();	/* no mouse repeat */
		exit_obj= my_form_do(pathaddr,&edit_obj,&mstate,0,&dummy);
		switch (exit_obj)
		{
			case OKPATH:
			for (i=0; i<NPATHS; i++)
			{
				if (ptr[i][1]==':')
				{
					temp= ptr[i][0]-'A';
					if ((temp>=0)&&(temp<16)) *drive[i]=temp;
					strcpy(path[i],ptr[i]+2);
				}
				else
					strcpy(path[i],ptr[i]);
			}
			case CANPATH:		done=1; break;

			default:
			for (i=0; i<NPATHS; i++) if (exit_obj==findobj[i]) break;
			putdial(0L,0,exit_obj);
			Dsetdrv(ptr[i][0]-'A');
			if (ptr[i][1]==':')
				dsetpath(ptr[i]+2);
			else
				dsetpath(ptr[i]);
			filename[0]=0;
			if (getfile(pathname,filename,ext[i],title[i]))
			{
				ptr[i][0]= (temp=Dgetdrv()) + 'A';
				ptr[i][1]= ':';
				Dgetpath(ptr[i]+2,temp+1);
				if (!ptr[i][2])
				{
					ptr[i][2]='\\';
					ptr[i][3]=0;
				}
			}
			putdial(pathaddr,-1,0);

		}	/* end switch */
	}
	while (!done);
	putdial(0L,0,exit_obj);

#endif
}  /* end ex_paths() */

/* copy a file ..............................................................*/

ex_copyfile()
{
#if DISKFLAG
	char filename[13],pathname[80];
	long filestart,fileleng;
	int saveMP;

	if (midiplexer) saveMP=MPoff();

	tempmem= -1;
	filename[0]=0;
	/* uses drive and path from most recent disk function */
	if (getfile(pathname,filename,ALL_EXT,COPYFRMMSG)>0)
	{
		if (load_file(pathname,filename))
		{
			if (getfile(pathname,filename,ALL_EXT,COPYTOMSG)>0)
			{
				filestart=	heap[tempmem].start;
				fileleng=	heap[tempmem].nbytes;
				save_file(filename,pathname,1,&filestart,&fileleng);
			}
		}
	}

	if (tempmem>=0) dealloc_mem(tempmem);
	graf_mouse(ARROWMOUSE);

	if (midiplexer&&saveMP) MPon();

#endif
}	/* end ex_copyfile() */

/* rename a file ............................................................*/

ex_rename()
{
#if DISKFLAG
	char fromfile[13],frompath[80];
	char tofile[13],topath[80];
	int hand,saveMP;

	if (midiplexer) saveMP=MPoff();

	fromfile[0]=0;
	/* uses drive and path from most recent disk function */
	if (getfile(frompath,fromfile,ALL_EXT,RENFRMTITL)>0)
	{
		graf_mouse(BEE_MOUSE);
		hand= Fopen(frompath,0);
		if (hand<0)
			big_alert(1,BADOPEN1,fromfile,BADOPEN2);
		else
		{
			Fclose(hand);
			graf_mouse(ARROWMOUSE);
			strcpy(tofile,fromfile);
			if (getfile(topath,tofile,ALL_EXT,RENTOTITL)>0)
			{
				graf_mouse(BEE_MOUSE);
				if (Frename(0,frompath,topath))
					big_alert(1,BADRENAME1,tofile,BADRENAME2);
			}
		}
	}	/* end if got a file from file selector */
	graf_mouse(ARROWMOUSE);
	if (midiplexer&&saveMP) MPon();

#endif
}	/* end ex_rename() */

/* create/delete folder .....................................................*/

ex_creatf()
{
	do_creatf(1);
}
ex_deletf()
{
	do_creatf(0);
}
do_creatf(create)
int create;	/* 1= create, 0= delete */
{
#if DISKFLAG
	char filename[13],pathname[80];
	int error,saveMP;

	if (midiplexer) saveMP=MPoff();

	filename[0]=0;
	/* uses drive and path from most recent disk function */
	if (getfile(pathname,filename,ALL_EXT,create ? CREDIRTITL : DELDIRTITL)>0)
	{
		if (!create)
			create= big_alert(1,CHEKDELF1,filename,CHEKDELF2)==1 ? 0 : -1 ;
		if (create>=0)
		{
			graf_mouse(BEE_MOUSE);
			error= create ? Dcreate(pathname) : Ddelete(pathname);
			graf_mouse(ARROWMOUSE);
			if (error)
			{
				if (create)
					big_alert(1,BADCREDIR1,filename,BADCREDIR2);
				else
					big_alert(1,BADDELDIR1,filename,BADDELDIR2);
			}
		}
	}
	if (midiplexer&&saveMP) MPon();
#endif
}	/* end do_creatf() */

/* edit user preferences ....................................................*/

ex_prefs()
{
	int done,mstate,edit_obj,exit_obj;
	int temp;
	char *ptr;

	/* encode into dialog */
	encode_prefs();

	/* draw dialog box, centered */
	putdial(prefaddr,-1,0);
	
	edit_obj= PREFFILE;
	done=0;
	do
	{
		waitmouse();	/* no mouse repeat */
		exit_obj= my_form_do(prefaddr,&edit_obj,&mstate,0,&dummy);
		switch (exit_obj)
		{
			case PREFEXIT:
			done=1;
			break;
			
			case PREFLOAD:
			putdial(0L,0,exit_obj);
			do_loadinf();
			encode_prefs();
			putdial(prefaddr,-1,0);
			break;
			
			case PREFSAVE:
			putdial(0L,0,exit_obj);
			decode_prefs();
			do_saveinf();
			encode_prefs();
			putdial(prefaddr,-1,0);
			break;

			case PREFDLY:
			mrpt_delay= 127 - hndl_slider(127-mrpt_delay,128,
													prefaddr,PREFDLY,PREFDLY2);
			encode_prefs();
			draw_object(prefaddr,PREFDLY2);
			break;

			case PREFRPT:
			mrpt_rate= 127 - hndl_slider(127-mrpt_rate,128,
												  prefaddr,PREFRPT,PREFRPT2);
			encode_prefs();
			draw_object(prefaddr,PREFRPT2);

		}	/* end switch */
	}
	while (!done);
	putdial(0L,0,exit_obj);
	decode_prefs();
}	/* end ex_prefs() */

decode_prefs()
{
	char *ptr;

	ptr= ((TEDINFO*)(prefaddr[PREFFILE].ob_spec))->te_ptext;
	if (ptr[0]) strcpy(defdataname,ptr);
	tone_disabled= !is_obj_sel(prefaddr,PREFTONE);
	chase_disabled= !is_obj_sel(prefaddr,PREFCHAS);
	quit_prot= is_obj_sel(prefaddr,PREFQUIT);
	edmouseinvrt= is_obj_sel(prefaddr,PREFEDIT);
}

encode_prefs()
{
	register int w1,w2;
	char *ptr;

	w1= prefaddr[PREFDLY ].ob_width;
	w2= prefaddr[PREFDLY2].ob_width;
	prefaddr[PREFDLY ].ob_x= ival_to_val(mrpt_delay,127,0,0,w2-w1);

	w1= prefaddr[PREFRPT ].ob_width;
	w2= prefaddr[PREFRPT2].ob_width;
	prefaddr[PREFRPT ].ob_x= ival_to_val(mrpt_rate,127,0,0,w2-w1);

	ptr= ((TEDINFO*)(prefaddr[PREFFILE].ob_spec))->te_ptext;
	strcpy(ptr,defdataname);
	sel_obj(!tone_disabled,prefaddr,PREFTONE);
	sel_obj(!chase_disabled,prefaddr,PREFCHAS);
	sel_obj(quit_prot,prefaddr,PREFQUIT);
	sel_obj(edmouseinvrt,prefaddr,PREFEDIT);
}	/* end encode_prefs() */

do_loadinf()
{
#if DISKFLAG
	char filename[13],pathname[80];
	int saveMP;

	if (midiplexer) saveMP=MPoff();

	filename[0]=0;
	Dsetdrv(orig_drive); dsetpath(orig_path);
	if (getfile(pathname,filename,INF_EXT,INFLTITL)>0)
	{
		switch ( load_inf(pathname) )
		{
			case 1: big_alert(1,BADREAD1,filename,BADREAD2); break;
			case 2: big_alert(1,BADOPEN1,filename,BADOPEN2);
		}
	}
	if (midiplexer&&saveMP) MPon();

#endif
}	/* end do_loadinf() */

do_saveinf()
{
#if DISKFLAG
	char filename[13],pathname[80];
	long filestart,fileleng;
	register char *ptr;
	register int i;
	int saveMP;

	if (midiplexer) saveMP=MPoff();

	strcpy(filename,INFFILE1);
	Dsetdrv(orig_drive); dsetpath(orig_path);
	if (getfile(pathname,filename,INF_EXT,INFSTITL)>0)
	{
		set_bytes(scrsave,INFLENG,0);	/* clear out oversized INF file */
		ptr= (char*)(scrsave);
		asm {
			move.l	#INFMAGIC,(ptr)+
			move.b	#1,(ptr)+				; file format version #
			move.b	#0,(ptr)+
			move.w	mlt_drive(a4),(ptr)+
			move.w	midi_drive(a4),(ptr)+
			move.w	cnx_drive(a4),(ptr)+
			move.w	mac_drive(a4),(ptr)+
			move.w	tem_drive(a4),(ptr)+
			move.w	ldat_drive(a4),(ptr)+
			move.w	rdat_drive(a4),(ptr)+
		}
		copy_bytes(mlt_path, scrsave+61 ,41L);
		copy_bytes(midi_path,scrsave+102,41L);
		copy_bytes(cnx_path, scrsave+143,41L);
		copy_bytes(mac_path, scrsave+184,41L);
		copy_bytes(tem_path, scrsave+225,41L);
		copy_bytes(ldat_path,scrsave+266,41L);
		copy_bytes(rdat_path,scrsave+307,41L);
		ptr= (char*)(scrsave) + 348;
		asm {
			move.b	midithru(a4),(ptr)+
			move.b	thruchan(a4),(ptr)+
			move.w	midi_speed(a4),(ptr)+
			move.b	midi_tport(a4),(ptr)+
			move.b	midi_rport(a4),(ptr)+
			move.w	midi_filter(a4),(ptr)+
			move.b	thru_tport(a4),(ptr)+
			move.b	thru_rport(a4),(ptr)+
			move.b	windsavc(a4),d0			; invert these so that default=ON
			eori.b	#1,d0
			move.b	d0,(ptr)+
			move.b	windsavd(a4),d0
			eori.b	#1,d0
			move.b	d0,(ptr)+
			move.b	windlodc(a4),d0
			eori.b	#1,d0
			move.b	d0,(ptr)+
			move.b	windlodd(a4),d0
			eori.b	#1,d0
			move.b	d0,(ptr)+
			move.b	windlink(a4),(ptr)+
		}
		for (i=0; i<2; i++)
		{
			*ptr++ = windpatsend[i] ;
			*ptr++ = windpatchan[i] ;
		}
		*ptr++ = mrpt_delay;
		*ptr++ = mrpt_rate;
		copy_bytes(defdataname,ptr,9L);
		ptr += 9;
		*ptr++ = tone_disabled;
		*ptr++ = chase_disabled;
		*ptr++ = quit_prot;
		*ptr++ = edmouseinvrt;
		*ptr++ = windprt1col;
		*ptr++ = midipchan;
		*ptr++ = midi_pport;
		*ptr++ = midipdelay;

		filestart=	scrsave;
		fileleng=	INFLENG;
		save_file(filename,pathname,1,&filestart,&fileleng);
	}
	if (midiplexer&&saveMP) MPon();
#endif
}	/* end do_saveinf() */

/* load INF file (with no user interface, also called from startup) .........*/

load_inf(pathname)	/* returns 1= can't read, 2= can't open, 0= ok */
char *pathname;
{
	register int i;
	int error=0;
	register char *ptr;
	char inf_version;

	i= Fopen(pathname,0);
	if (i>=0)
	{
		error= Fread(i,INFLENG,scrsave) != INFLENG ;
		Fclose(i);
	}
	else
		error=2;
	if (!error) error=  *(long*)(scrsave) != INFMAGIC ;
	if (!error)
	{
		asm {
			movea.l	scrsave(a4),a0
			addq.w	#4,a0					; skip magic
			move.b	(a0)+,inf_version(a6)
			addq.w	#1,a0
			move.w	(a0)+,mlt_drive(a4)
			move.w	(a0)+,midi_drive(a4)
			move.w	(a0)+,cnx_drive(a4)
			move.w	(a0)+,mac_drive(a4)
			move.w	(a0)+,tem_drive(a4)
			move.w	(a0)+,ldat_drive(a4)
			move.w	(a0)+,rdat_drive(a4)
		}
		copy_bytes(scrsave+61 ,mlt_path,41L);
		copy_bytes(scrsave+102,midi_path,41L);
		copy_bytes(scrsave+143,cnx_path,41L);
		copy_bytes(scrsave+184,mac_path,41L);
		copy_bytes(scrsave+225,tem_path,41L);
		copy_bytes(scrsave+266,ldat_path,41L);
		copy_bytes(scrsave+307,rdat_path,41L);
		ptr= (char*)scrsave + 348;
		midithru= *ptr++;
		thruchan= *ptr++;
		midi_speed= *(int*)(ptr); ptr+=2;

		i= *ptr++;
		i= max(i,0);
		i= min(i,3);
		midi_tport= i;

		i= *ptr++;
		i= max(i,0);
		i= min(i,1);
		midi_rport=i;

		midi_filter= *(int*)(ptr);		ptr+=2;

		i= *ptr++;
		i= max(i,0);
		i= min(i,3);
		thru_tport=i;

		i= *ptr++;
		i= max(i,0);
		i= min(i,1);
		thru_rport=i;

		windsavc= !(*ptr++);				/* invert these so that default=ON */
		windsavd= !(*ptr++);
		windlodc= !(*ptr++);
		windlodd= !(*ptr++);
		windlink= *ptr++;
		for (i=0; i<2; i++)
		{
			windpatsend[i]= *ptr++;
			windpatchan[i]= *ptr++;
		}
		i= *ptr++;
		if (inf_version) mrpt_delay=i;
		i= *ptr++;
		if (inf_version) mrpt_rate=i;
		if (ptr[0]) copy_bytes(ptr,defdataname,9L);
		ptr += 9;
		tone_disabled= *ptr++;
		chase_disabled= *ptr++;
		quit_prot= *ptr++;
		edmouseinvrt= *ptr++;
		windprt1col= *ptr++;

		midipchan= *ptr++;

		i= *ptr++;
		i= max(i,0);
		i= min(i,3);
		midi_pport= i;

		midipdelay= *ptr++;

		/* for each drive:  If it's not valid, reset the drive and path */
		valid_drive(&mlt_drive,mlt_path);
		valid_drive(&midi_drive,midi_path);
		valid_drive(&cnx_drive,cnx_path);
		valid_drive(&mac_drive,mac_path);
		valid_drive(&tem_drive,tem_path);
		valid_drive(&ldat_drive,ldat_path);
		valid_drive(&rdat_drive,rdat_path);

	}	/* end if no error */
	return error;
}	/* end load_inf() */

valid_drive(drive,path)
int *drive;		/* 0=A, 1=B, etc. */
char *path;
{
	int nflops;
	long drvbits,bitmap;

	nflops= *(int*)(0x4A6);			/* 0/1/2 */
	drvbits= *(long*)(0x4C2);		/* bit 0=A, 1=B, 2=C */

	/* if drive B not attached, let's not pretend it is */
	if (nflops<2) drvbits &= ~2L;

	/* if drive and path not valid, set to where program is */
	bitmap= 1L << (*drive);
	if ( !(drvbits&bitmap) )
	{
		*drive= orig_drive;
		strcpy(path,orig_path);
	}
}	/* end valid_drive() */

/* autoload files ...........................................................*/

ex_autoload()
{
	char filename[13],pathname[80];
	int error;

	/* alt key skips autoload */
	if (Kbshift(-1)&K_ALT) return;

	/* configurations */
	strcpy(filename,AUTOFILE);
	strcat(filename,CNX_EXT);
	strcpy(pathname,AUTOFILE);
	strcat(pathname,CNX_EXT);
	Dsetdrv(cnx_drive); dsetpath(cnx_path);
	tempmem= -1;
	error= load_cnx(pathname,filename);
	dealloc_mem(tempmem);
	if (error)
	{
		Dsetdrv(orig_drive); dsetpath(orig_path);
		tempmem= -1;
		load_cnx(pathname,filename);
		dealloc_mem(tempmem);
	}

	/* macros */
	strcpy(filename,AUTOFILE);
	strcat(filename,MAX_EXT);
	strcpy(pathname,AUTOFILE);
	strcat(pathname,MAX_EXT);
	Dsetdrv(mac_drive); dsetpath(mac_path);
	tempmem= -1;
	error= load_macros(pathname,filename);
	dealloc_mem(tempmem);
	if (error)
	{
		Dsetdrv(orig_drive); dsetpath(orig_path);
		tempmem= -1;
		load_macros(pathname,filename);
		dealloc_mem(tempmem);
	}

	/* template */
	strcpy(filename,AUTOFILE);
	strcat(filename,TEM_EXT);
	strcpy(pathname,AUTOFILE);
	strcat(pathname,TEM_EXT);
	Dsetdrv(tem_drive); dsetpath(tem_path);
	tempmem= -1;
	error= !load_file(pathname,filename);
	if (error)
	{
		Dsetdrv(orig_drive); dsetpath(orig_path);
		tempmem= -1;
		error= !load_file(pathname,filename);
	}
	if (!error)
	{
		if (load_tem(filename))
		{
			new_ext(filename,TEM_EXT);
			strcpy(temfile,filename);
		}
	}
	dealloc_mem(tempmem);

	/* sequence */
	tempmem= -1;
	strcpy(filename,AUTOFILE);
	strcat(filename,SQC_EXT);
	strcpy(pathname,AUTOFILE);
	strcat(pathname,SQC_EXT);
	Dsetdrv(orig_drive); dsetpath(orig_path);
	if (load_file(pathname,filename)) load_sqc(filename);
	dealloc_mem(tempmem);

}	/* end ex_autoload() */

/* load code resource file (no user interface) ..............................*/

load_cdr(pathname)
char *pathname;
{
	register int hand,error;
	long templong;
	FILEHEADER *header;

	hand= Fopen(pathname,0);
	if (hand>=0)
	{
		templong= Flength(hand);
		error= !change_mem(cdrmem,templong);
		if (!error)
		{
			header= (FILEHEADER*)(heap[cdrmem].start);
			error= Fread(hand,templong,header) != templong ;
		}
		if (!error)
			error= (header->magic != CDRMAGIC ) ||
					 (header->machine != MACHINE ) ||
					 (header->version > CDRVERSION ) ;
		if (error)
			change_mem(cdrmem,0L);
		Fclose(hand);
	}
}	/* end load_cdr() */

/* allocate tempmem and load file into it ...................................*/
/* returns file length (bytes), 0L= error (error message inside load_file) */

long load_file(pathname,filename)
char *pathname,*filename;
{
	register int i;
	register long templong;
	int hand,saveMP;
	long success=0L;

	if (midiplexer) saveMP=MPoff();

	graf_mouse(BEE_MOUSE);
	hand= Fopen(pathname,0);
	if (hand<0)
		big_alert(1,BADOPEN1,filename,BADOPEN2);
	else
	{
		templong= Flength(hand);
		tempmem= alloc_mem(templong);
		if (tempmem>=0)
		{
			if (Fread(hand,templong,heap[tempmem].start)==templong)
				success= templong;
			else
				big_alert(1,BADREAD1,filename,BADREAD2);
		}
	}
	if (hand>=0) Fclose(hand);
	graf_mouse(ARROWMOUSE);
	if (midiplexer&&saveMP) MPon();
	return success;
}	/* end load_file() */

/* high level save a file ...................................................*/
/* returns 1= successful, 0= error (error message inside save_file) */

save_file(filename,pathname,n,addr,leng)
char *filename,*pathname;
int n;					/* # of blocks to be written, <0 means no CHEKREPL */
long addr[],leng[];	/* address and length of each block to be written */
{
#if DEMOFLAG
	form_alert(1,CHEKDEMO);
	return 1;
#else
	register int i,hand;
	int filehand,saveMP,success=0;
	static int backup=1;	/* 1= replace, 2= backup */
	char backpath[80];

	if (midiplexer) saveMP=MPoff();
	graf_mouse(BEE_MOUSE);

	hand= Fopen(pathname,2);
	if (hand>=0)			/* file already exists: replace it? */
	{
		Fclose(hand);
		if (n<0)				/* replace without warning */
			hand= -1;
		else
		{
			i= big_alert(backup,CHEKREPL1,filename,CHEKREPL2);
			if (i<3) backup=i;	/* remember choice for next time default */
			if (i==2)				/* backup */
			{
				strcpy(backpath,pathname);
				new_ext(backpath,BAK_EXT);
				Fdelete(backpath);
				Frename(0,pathname,backpath);
			}
			if (i!=3) hand= -1;	/* replace */
		}
	}
	
	if (n<0) n= -n;
	if (hand<0)				/* create or replace file */
	{
		hand= Fcreate(pathname,0);
		if (hand<0)
			big_alert(1,BADCREAT1,filename,BADCREAT2);
		else
		{
			for (i=0; i<n; i++)
				if (Fwrite(hand,leng[i],addr[i])!=leng[i]) break;
			success= i==n;
			Fclose(hand);
			/* optionally delete partial file */
			if (!success)
				if (form_alert(1,BADWRITE)==2)
					Fdelete(pathname);
		}
	}
	graf_mouse(ARROWMOUSE);
	if (midiplexer&&saveMP) MPon();
	return success;
#endif
}	/* end save_file() */

/* item selector ............................................................*/
/* returns 1 OK, 0 cancel, -1 null file selected */

getfile(pathname,fname,ext,title)
char *pathname; /* output: full path name (up to 80 chars), if OK selected */
char *fname;    /* input: default file name
						 output: file name, if OK selected */
char *ext;	 	/* input: default extension for directory line
                   -- 3 characters or less means directory *.pathext
						 -- more than 3 characters means directory pathext */
char *title;	/* prompt at top of screen, 0L for none */
					/* also, if title = 0L, don't save/restore screen */
{
	char tmppath[256];
	char tmpname[13];
	char pathext[256];
	int exit_obj,error,saveMP;
	register int i;
	register int result=0;

	if (midiplexer) saveMP=MPoff();

	if (title) menuprompt(title);

	/* don't destroy ext -- it should be input only */
	strcpy(pathext,ext);

	/* build directory line */
	tmppath[0] = (i=Dgetdrv()) + 'A';
	tmppath[1] = ':';
	Dgetpath(&tmppath[2],i+1);
	strcat(tmppath,"\\");
	if (strlen(pathext)<=3) strcat(tmppath,"*.");
	strcat(tmppath,pathext);

	strcpy(tmpname,fname);
	if (title) save_screen(menu_hi_y+1,200*rez-1);
	midi_motv(1);	/* enable GEM */
	waitmouse();
	error= !fsel_input(tmppath,tmpname,&exit_obj);
	midi_motv(0);	/* disable GEM */
	if (title) rest_screen(menu_hi_y+1,200*rez-1);

	/* if no extension was typed, try to add one */
	if (ext_ok(pathext))
	{
		new_exta(tmppath,pathext);
		new_exta(tmpname,pathext);
	}

	/* path can't exceed drive+colon+38+null */
	if (strlen(tmppath)>38)
	{
		form_alert(1,BADPATH);
		error=1;
	}

	/* nonsense drive? */
	error= (tmppath[0]<'A') || (tmppath[0]>'P') ;

	if (exit_obj && !error)
	{
		/* chop off end of path */
		for (i=strlen(tmppath); (i>0); i--)
			if (tmppath[i]=='\\') break;
		if (i>=0)
		{
			tmppath[i+1]=0;
			/* update current drive and directory */
			Dsetdrv(tmppath[0]-'A'); dsetpath(&tmppath[2]);
			strcpy(pathname,tmppath);
			strcat(pathname,tmpname);        /* return selected full pathname */
			strcpy(fname,tmpname);           /* return file name */
			result= tmpname[0] ? 1 : -1 ;
		}
	}

	if (title) menuprompt(0L);
	if (midiplexer&&saveMP) MPon();
	return result;
}  /* end getfile() */

/* replace a filename extension .............................................*/

new_ext(name,ext)
char *name, *ext;
{
	register int i,j;

	j= strlen(name);
	for (i=j-1; i && (name[i]!='.'); i--) ;
	if (!i) name[i=j] = '.';
	strcpy(&name[++i],ext);
}  /* end new_ext() */

/* append but don't replace a filename extension ............................*/

new_exta(name,ext)
char *name, *ext;
{
	register int i;

	i= strlen(name) - 1;
	for (; i && (name[i]!='.'); i--) ;

	/* extension already there */
	if (i && name[i+1]) return;

	new_ext(name,ext);
}  /* end new_exta() */

/* file extension legal? ....................................................*/
/* returns 1= yes, 0= no */

ext_ok(ptr)
register char *ptr;	/* null-term'd */
{
	register char ch;

	while (ch= *ptr++)
	{
		if ( ((ch<'A')||(ch>'Z')) && ((ch<'0')||(ch>'9')) && (ch!='_') )
		{
			ptr[-1]=0;
			break;
		}
	}
	return 1;
}	/* end ext_ok() */

/* length of a file .........................................................*/
/* use throughout !!! */

long Flength(handle)
int handle;	/* file handle (must be open) */
{
	long templong;
	int saveMP;

	if (midiplexer) saveMP=MPoff();
	templong= Fseek(0L,handle,2);
	Fseek(0L,handle,0);						/* rewind */
	if (midiplexer&&saveMP) MPon();
	return templong;
}	/* end Flength() */

/* how many files match a given pathname ....................................*/

Nfiles(pathname)
char *pathname;
{
	int n=0;
	int saveMP;

	if (midiplexer) saveMP=MPoff();
	if ( !Fsfirst(pathname,0) )
	{
		n=1;
		while (!Fsnext()) n++;
	}
	if (midiplexer&&saveMP) MPon();
	return n;
}	/* end Nfiles() */

/* set current path .........................................................*/

dsetpath(path)
char *path;
{
	char localpath[41];
	int saveMP;

	if (midiplexer) saveMP=MPoff();
	copy_bytes(path,localpath,41L);
	if (!localpath[0])
	{
		localpath[0]='\\';
		localpath[1]=0;
	}
	Dsetpath(localpath);
	if (midiplexer&&saveMP) MPon();
}	/* end dsetpath() */

#undef Dgetpath
Dgetpath(path,drive)
char *path;
int drive;
{
	int saveMP;

	if (midiplexer) saveMP=MPoff();
	gemdos(0x47,path,drive);
	if (midiplexer&&saveMP) MPon();
}	/* end Dgetpath() */

/* EOF */
