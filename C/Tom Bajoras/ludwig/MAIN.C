/******************************************************************************

                                    Ludwig
												
												  by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module: MAIN -- highest level stuff

	main, startup, finishup, exec, acc_loop

	functions called only during initialization:

	read_alloc, flip_bl3, bl2_to_bl3, init_funcs

******************************************************************************/

overlay "main"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "globals.h"
#include "params.h"

/* imported from GEM */
extern int *pioff, *iioff, *pooff, *iooff;
extern int int_in[],int_out[],control[],global[];
extern long addr_in[], addr_out[];
extern char *_base;

	/* for copy protection */
int errcnt,chrcnt,crc,_plover();
int our8, our12, our16, our20, our24, our28, our32, our36;

/* main entry point .........................................................*/

main()
{
	if (startup(0))
		exec();   /* if init'n succeeded, do body of program */
	else
	{ asm { move.l _base(a4),a0		move.l #-1,8(a0) } }
	finishup();               /* clean up before exiting back to desktop */
}  /* end main() */

/* initialize ...............................................................*/
/* return 1 for success, 0 for failure */

startup(sw)
int sw;			/* non-0 if returning from switcher */
{
	register int i,j;
	register char *badptr;
	register long templong;

	int loc_in[11],loc_out[57];
	int saveA4(),crys_if(),newmvec(),_init(),transmit(),plover();
	int alock(),protect2();
	int x,y,w,h;
	int nvbls,error;
	long *vblqueue;
	char *read_alloc();
	char auto_name[81];
	long tmplong;

/* initialize global variables */
	windhndl=ap_id= (-1);		/* window not open, application not init'd */
	wait_for=1;						/* mouse interrupt waiting for button down */
	save_spur=0L;					/* no custom interrupts or saved timer D (yet) */
	save_butv= save_motv=0L;	/* no saved butv/motv (yet) */
	savectl_d= savedat_d= 0L;	/* no saved timer D stuff (yet) */
	savemvec= 0L;					/* no saved mouse vector (yet) */
	save_tran= 0L;					/* no saved midi vector (yet) */
	midiplex= -1;					/* no midiplexer */

/* initialize AES, get an i.d. # */
	if ( (ap_id=appl_init()) < 0 ) {  badptr= BADINIT; goto bad_ret;  }

/* return from switcher: skip around copy protection */
	if (sw) goto sw_skip1;

/* save timer D settings */
	savectl_d= *(char*)(0xFFFFFA1DL);
	savedat_d= get_baud();

/* SYNCBOX file */
#if ALOCKFLAG
	if ( (templong=Fopen("\\SYNCBOX",0)) > 0L )
	{
		Fclose(i=templong);
		while (plover()) if (form_alert(1,CHEKBOX)==2) return(0);
	}
#endif

/* optional sync box copy protection */
#if BETAFLAG
	asm {
		jsr		plover
		ext.l		d0
		move.l	d0,16
	}
#endif

/* check for anything in main segment has been modified */
#if ALOCKFLAG
	asm {
		move.l	2(a5),a0				; --> start of main segment
		move.l	a0,a1
		adda.l	#MAINLENGW*2,a1	; --> end of area to be CRC'd
		clr.w		D0						; init CRC
	addcrc:
		cmpa.l	A0,A1					; done crc'ing?
		beq		donecrc
		move.b	(A0)+,D2				; byte to be computed into CRC
		moveq		#7,D1
	crcloop:
		lsl.b		#1,D2
		roxl.w	#1,D0
		bcc		skipcrc
		eori.w	#0x8130,D0
	skipcrc:
		dbf		D1,crcloop
		bra		addcrc
	donecrc:
		move.w	D0,maincrc(a4)

		move.l	2(a5),a0				; --> start of main segment
		clr.w		mainchksum(a4)		; initialize checksum
		move.l	#MAINLENGW,d0		; approximate length of main segment (words)
	sumloop:
		move.w	(a0)+,d1
		eor.w		d1,mainchksum(a4)
		subq.l	#1,d0
		bgt		sumloop

	/* should return d0= 0L */
		jsr		plover
	/* returns d0.w= 9efc if plover returned 0L */
		jsr		alock
	/* returns d0.w= 9efc = high word of suba.w #X,a7 */
		jsr		protect2
	/* these are used in interrupt code */
		move.w	d0,our8(a4)
		move.w	d0,our12(a4)
		move.w	d0,our16(a4)
		move.w	d0,our20(a4)
		move.w	d0,our24(a4)
		move.w	d0,our28(a4)
		move.w	d0,our32(a4)
		move.w	d0,our36(a4)
	}
#endif

sw_skip1:
#if ALOCKFLAG
	asm {
	/* restore */
		move.w	our8(a4),8
		move.w	our12(a4),12
		move.w	our16(a4),16
		move.w	our20(a4),20
		move.w	our24(a4),24
		move.w	our28(a4),28
		move.w	our32(a4),32
		move.w	our36(a4),36
	}
#endif

/* get the VDI handle */
	crys_if(77);  /* graf_handle */
	gl_hand= int_out[0];

/* open the VDI virtual workstation */
	set_words(loc_in,10,1);
	loc_in[10]= 2;
	iioff= loc_in;   iooff= loc_out;   pooff= loc_out + 45;
	contrl[0] = 100;   contrl[1] = 0;   contrl[3] = 11;   contrl[6]= gl_hand;
	vdi();
	gl_hand = contrl[6];    
	iioff= intin;   iooff= intout;   pooff= ptsout;   pioff= ptsin;

/* get pointer to screen memory (must also be done after returning from
	switcher -- screen may have moved due to RAM disk */
	scrbase= Logbase();

/* get screen resolution -- can't run in low res */
	if ( !(rez= Getrez()) )	{  badptr= BADREZ; goto bad_ret;  }
	bytesperline= 160 / rez ;
	wind_y= rez==2 ? wind2_y : wind1_y ;	/* window positions */
	val_y=  rez==2 ? val2_y : val1_y ;		/* parameter positions */
	tag_y=  rez==2 ? tag2_y : tag1_y ;		/* window tag positions */
	if (rez==2) init_gr();						/* self-modify fast graphics */

/* return from switcher: skip around disk i/o and Malloc's */
	if (sw) goto sw_skip2;

/* load the resource file */
	if ( !rsrc_load(RSRCNAME) ) {  badptr= BADRSRC; goto bad_ret;  }

/* get addresses of all trees in resource */
/* all trees named xxxxTREE, addresses named xxxxaddr */
	rsrc_gaddr(R_TREE,MENUTREE,&menuaddr);
	if (rez==2)
		rsrc_gaddr(R_TREE,INFMTREE,&infoaddr);
	else
		rsrc_gaddr(R_TREE,INFCTREE,&infoaddr);
	rsrc_gaddr(R_TREE,FMTTREE ,&fmtaddr );
	rsrc_gaddr(R_TREE,DRIVTREE,&drivaddr);
	rsrc_gaddr(R_TREE,LDSVTREE,&ldsvaddr);
	rsrc_gaddr(R_TREE,GRPTREE ,&grpaddr );
	rsrc_gaddr(R_TREE,VELOTREE,&veloaddr);
	rsrc_gaddr(R_TREE,COPYTREE,&copyaddr);
	rsrc_gaddr(R_TREE,SCALTREE,&scaladdr);
	rsrc_gaddr(R_TREE,EDPTREE ,&edpaddr );
	rsrc_gaddr(R_TREE,EDRTREE ,&edraddr );
	rsrc_gaddr(R_TREE,TEMPTREE,&tempaddr);
	rsrc_gaddr(R_TREE,TRAKTREE,&trakaddr);
	rsrc_gaddr(R_TREE,FILLTREE,&filladdr);
	rsrc_gaddr(R_TREE,SYNCTREE,&syncaddr);
	rsrc_gaddr(R_TREE,THRUTREE,&thruaddr);
	rsrc_gaddr(R_TREE,SHARTREE,&sharaddr);

/* allocate buffers */
	/* reuse Megamax's _init (256+256+(3*256)+PITCHLENG) */
	asm {
		lea		_init,a0				; --> jmp xxxxxx
		move.l	2(a0),d0				; xxxxxx
		add.l		#256,d0
		andi.l	#0xffffff00L,d0	; 256-byte aligned
		move.l	d0,tranbuf(a4)
		/* midiplexer transmit buffers */
		add.l		#256,d0
		move.l	d0,MPtrBbuf(a4)
      move.l	d0,MPtrBhead(a4)
      move.l	d0,MPtrBtail(a4)

		add.l		#256,d0
      move.l	d0,MPtrBlim(a4) 
		move.l	d0,MPtrCbuf(a4)
      move.l	d0,MPtrChead(a4)
      move.l	d0,MPtrCtail(a4)

		add.l		#256,d0
      move.l	d0,MPtrClim(a4) 
		move.l	d0,MPtrDbuf(a4)
      move.l	d0,MPtrDhead(a4)
      move.l	d0,MPtrDtail(a4)

		add.l		#256,d0
      move.l	d0,MPtrDlim(a4)
		move.l	d0,pitchdata(a4)
	}

	badptr= BADMEM;
	/* screen-save buffer must be on page boundary for physbasing */
	if ( !(scrsave=Malloc(SCRLENG+256L)) ) goto bad_ret;
	scrsave+=256L;
	scrsave&=0xffffff00L;
	if ( !(loopcnt=(char*)Malloc(NSEQ*2L*NCELL)) ) goto bad_ret;
	if ( !(notestat=(char*)Malloc(128L*NSEQ)) ) goto bad_ret;
	if ( !(seqdata=(char*)Malloc(SEQLENG)) ) goto bad_ret;
	if ( !(nonrdata=(char*)Malloc(NONRLENG)) ) goto bad_ret;
	if ( !(masterdata=(char*)Malloc(MASTERLENG)) ) goto bad_ret;
 	if ( !(rhythmdata=(char*)Malloc(RHYTHMLENG)) ) goto bad_ret;
	if ( !(recstart=(char*)Malloc(RECLENG)) ) goto bad_ret;
	recend= recstart+RECLENG;
	wind_seq=  masterdata+M_SEQ;
	wind_type= masterdata+M_TYPE;

/* load window frames */
	badptr=(char*)0L;	/* error message is inside read_alloc() */
	windptr[P_TYPE]= read_alloc(rez==2 ? PWINDNAME2 : PWINDNAME1,
											&windleng[P_TYPE]) ;
	if (!windptr[P_TYPE]) goto bad_ret;
	/* Rhythm window is same as pitch window */
	windptr[R_TYPE]= windptr[P_TYPE];
	windleng[R_TYPE]= windleng[P_TYPE];
	windptr[V_TYPE]= read_alloc(rez==2 ? VWINDNAME2 : VWINDNAME1,
											&windleng[V_TYPE]) ;
	if (!windptr[V_TYPE]) goto bad_ret;
	/* skip Degas block file headers */
	templong= rez==2 ? BL3HEADLNG : BL2HEADLNG ;
	for (i=0; i<NTYPE; i++)
	{
		windptr[i]+=templong;
		windleng[i]-=templong;
	}
	if (rez!=2)
	{
		bl2_to_bl3(windptr[P_TYPE],windleng[P_TYPE]);
		bl2_to_bl3(windptr[V_TYPE],windleng[V_TYPE]);
	}
	/* flip window frames, so that draw_wind() can be insanely fast */
	flip_bl3(P_TYPE,windptr,windleng);
	windleng[R_TYPE]/=32;
	flip_bl3(V_TYPE,windptr,windleng);

/* load fake dialog boxes */
	badptr=(char*)0L;	/* error message is inside read_alloc() */
	for (i=0; i<NDIAL; i++)
	{
		dialptr[i]= read_alloc( rez==2 ? dialname3[i] : dialname2[i],
										&dialleng[i] );
		if (!dialptr[i]) goto bad_ret;
		/* skip Degas block file headers */
		templong= rez==2 ? BL3HEADLNG : BL2HEADLNG ;
		dialptr[i]+=templong;
		dialleng[i]-=templong;
		if (rez!=2) bl2_to_bl3(dialptr[i],dialleng[i]);
		/* flip dialog boxes, so that draw_dial() can be insanely fast */
		flip_bl3(i,dialptr,dialleng);
	}

/* allocate all remaining memory for play buffers */
	badptr= BADMEM;
	templong= Malloc(-1L) - GEMMEM;
	if (templong < MINPLAY) goto bad_ret;
	templong /= NSEQ;
	templong &= 0xfffffff0L;	/* each play buffer divisible by 16 */
	for (i=0; i<NSEQ; i++)
	{
	 	if ( !(playstart[i]=(long*)Malloc(templong)) ) goto bad_ret;
		playend[i]= playstart[i] + templong/4;
		playtail[i]=playhead[i]=playstart[i];	/* play buffer empty */
	}

/* pointers to keyboard head and tail */
	keyb_head= (int*)Iorec(1) + 3;
	keyb_tail= keyb_head+1;

/* set up pointers into parameter structures */
	for (i=0; i<NSEQ; i++)
	{
		seq1data[i]= seqdata + i*SEQ1LENG;
		nonr1data[i]= nonrdata + i*NONR1LENG;
	}
	for (i=0; i<NGRP; i++)
	{
		pitch1data[i]= pitchdata + i*PITCH1LENG;
		rhyth1data[i]= rhythmdata + i*RHYTH1LENG;
	}
	for (i=0; i<NSEQ; i++)
	{
		segptr[i]= seq1data[i];
		segleng[i]= SEQ1LENG;
	}
	segptr[NSEQ]= nonrdata;
	segleng[NSEQ]= NONRLENG;
	segptr[NSEQ+1]= masterdata;
	segleng[NSEQ+1]= MASTERLENG;
	segptr[NSEQ+2]= pitchdata;
	segleng[NSEQ+2]= PITCHLENG;
	segptr[NSEQ+3]= rhythmdata;
	segleng[NSEQ+3]= RHYTHMLENG;

/* init line A */
	asm {
		dc.w    0xA000                   ; init line A
		move.l  A0,Abase(a4)
		suba.l  #348,a0
		move.l  a0,Mstate(a4)            ; pointer to mouse button byte
		suba.l  #0xFE,a0
		move.l  a0,Mousex(a4)            ; pointer to mouse x-coord word
		addq.l  #2,a0
		move.l  a0,Mousey(a4)            ; pointer to mouse y-coord word
		move.w  rez(a4),d0
		lsl.w	  #2,d0
		movea.l	0(a1,d0),a0					; --> system font header
		move.l	76(a0),fontptr(a4)		; --> system font (for this rez)
	}

/* must be done before installing custom mouse vector */
	asm {		lea     saveA4,a0			move.l  a4,(a0)		}

sw_skip2:

/* starting mouse icon */
	graf_mouse(ARROWMOUSE);

/* check for availability of HybriSwitch */
	menu_ienable(menuaddr,LUSWITCH,0);
	sw_ptr=0L;
	nvbls= *(int*)(0x454L);
	vblqueue= (long*)(*(long*)(0x456L));
	for (nvbls--; nvbls>=0; nvbls--)
		if (templong=vblqueue[nvbls])
			if ( *(int*)(templong) == 0x4e75 )
				if ( *(long*)(templong+2L) == 0xABADBEEFL )
				{
					sw_ptr= templong+6L;
					menu_ienable(menuaddr,LUSWITCH,1);
					break;
				}

/* is there a midiplexer? */
	midiplex= MPinit();	/* -1 if no */

/* size the window to fill the whole screen except menu bar */
	wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
	windhndl= wind_create(0,x,y,w,h);
	if (windhndl<0) {  badptr= BADWIND; goto bad_ret;  }

/* return from switcher: skip parameter init'n */
	if (sw) goto sw_skip3;

	/* initialize p_func and r_func arrays */
	init_funcs();

/* build tempo table */
	for (i=0; i<NTEMPO; i++)
	{
		set_bytes(&tempodivs[i][0],8,(i+24)/8);
		for (j=0; j<((i+24)%8)-1; j++) tempodivs[i][j]++;
	}

/* default parameters */
	for (i=0; i<NSEG; i++) def_seg(i);
	if (auto_load(AUTOFILE))
		strcpy(songname,AUTOFILE);
	else
		strcpy(songname,INITNAME);

sw_skip3:
	/* open the window */
	wind_open(windhndl,x,y,w,h);
	/* but ignore redraw message */
	evnt_mesag(messbuf);

/* disable menu drop-down (must be done before menu_bar() */
	menu_drop(0);

/* put up menu bar (but not if switching during play mode) */
	if (!play_mode)
	{
		menu_bar(menuaddr,1);
		disp_name();
	}

/* get location of menu bar */
	menu_hi_y= 8*rez + 2;
	menu_lo_x= menuaddr[2].ob_x;
	menu_hi_x= menu_lo_x + menuaddr[2].ob_width - 1;

/* get location of desk accessory portion of desk menu */
	i= menuaddr[ menuaddr[1].ob_next ].ob_head;
	acc_lo_x= menuaddr[i].ob_x;
	acc_hi_x= acc_lo_x - 1 + menuaddr[i].ob_width;
	acc_lo_y= menu_hi_y + 1 + 16*rez;
	acc_hi_y= menu_hi_y + menuaddr[i].ob_height;

/* save the butv/motv vectors */
	save_butv= *(long*)(Abase-58L);
	save_motv= *(long*)(Abase-50L);

/* custom interrupts */
	asm {										/* spurious interrupt */
		move.l	0x60,save_spur(a4)
		lea		an_rte,a0
		move.l	a0,0x60
		bra		skip_rte
	an_rte:
		rte
	skip_rte:
	}

  	templong= Kbdvbase();					/* mouse interrupt */
	savemvec= *( (long*)(templong+16L) );
#if BETAFLAG
	tmplong= 16L;
	if (sw)
		*(long*)(templong+16L)= (long)(&newmvec);
	else
		*(long*)(templong+16L)= (long)(&newmvec) + *(long*)(tmplong);
#else
	*(long*)(templong+16L)= (long)(&newmvec);
#endif
	tranhead=trantail=tranbuf;				/* clear out transmit buffer */
	save_tran= *( (long*)(templong+28L) );		/* midi interrupt */
	*(long*)(templong+28L)= (long)(&transmit);

/* return from switcher: skip window init'n */
	if (sw) goto sw_skip4;

/* draw window frames, tags, and parameters */
	draw_screen();

sw_skip4:

/* turn on midiplexer */
	if (midiplex>=0) MPon();

/* success */
#if DEMOFLAG
	if (!sw) form_alert(1,DEMOMSG2);
#endif
	return(1);

/* failure */
bad_ret:
	if (badptr) form_alert(1,badptr);
	return(0);

}  /* end startup() */

/* clean up and terminate ...................................................*/

finishup()
{
	/* allow menu drop-down */
	menu_drop(1);

	/* turn off midiplexer */
	if (midiplex>=0) MPoff();

	/* clean up after sync protection */
	Offgibit(0xef);
	*(int*)(Iorec(0)+6L)= *(int*)(Iorec(0)+8L);

	/* restore system stuff */
	if (save_spur) *((long*)(0x60L))= save_spur;
	if (savemvec) *((long*)(Kbdvbase()+16L))= savemvec;
	if (save_tran) *((long*)(Kbdvbase()+28L))= save_tran;
	if (savectl_d)	*(char*)(0xFFFFFA1DL) = savectl_d;
	if (savedat_d)	*(char*)(0xFFFFFA25L) = savedat_d;
	if (save_butv) *(long*)(Abase-58L)= save_butv;
	if (save_motv) *(long*)(Abase-50L)= save_motv;

	/* close and delete our window, close all other windows */
	for (int_in[0]=windhndl; int_in[0]>0; 
		wind_get(0,WF_TOP,int_in,&dummy,&dummy,&dummy) )
	{
		crys_if( 102 );  /* wind_close */
		if (int_in[0]==windhndl) crys_if( 103 );  /* wind_delete */
	}

	/* close VDI workstation */
	asm {
		lea		contrl(a4),a0
		move.w	#101,(a0)
		clr.w		2(a0)
		clr.w		6(a0)
		move.w	gl_hand(a4),12(a0)
	}
	vdi();
	
	/* clean up AES */
	if (ap_id >=0) crys_if(19);		/* appl_exit */

}  /* end finishup() */

/* main control loop ........................................................*/

exec()
{
	register int event,inmenu,mstate,mlock;
	char done,scr_saved;
	int mousex,mousey,kstate,key;
	long new_tran;
	char new_ctl_d,new_dat_d;

/* HybriSwitch auto-quit feature */
	if (sw_ptr && *(int*)(sw_ptr+38L) ) ex_switch(-1);

/* loop until user requests quit */
	for (scr_saved=done=0; !done; )
	{
		if (deskacc)      	  /* deskacc set in mouse interrupt */
		{
			Freezex=Freezey=1;  /* wait for type 1 desk acc, while waiting */
			waitmouse();        /* do not allow mouse into menu bar */
			allmenus(0);        /* disable any menu entries that aren't already */
			Offgibit(0xef);
			*(int*)(Iorec(0)+6L)= *(int*)(Iorec(0)+8L);
			if (midiplex>=0) MPoff();
			new_tran= *((long*)(Kbdvbase()+28L)) ;
			new_ctl_d= *(char*)(0xFFFFFA1DL) ;
			new_dat_d= get_baud();
			*((long*)(Kbdvbase()+28L))= save_tran;
			*(char*)(0xFFFFFA1DL) = savectl_d;
			*(char*)(0xFFFFFA25L) = savedat_d;
			Mfree(loopcnt);
			allow_gp(1);
			Freezex=Freezey=0;
			acc_loop();   		  /* wait until all desk acc's are gone */
			scr_saved=0;
			*((long*)(Kbdvbase()+28L))= new_tran;
			*(char*)(0xFFFFFA1DL) = new_ctl_d;
			*(char*)(0xFFFFFA25L) = new_dat_d;
			allow_gp(0);
			if ( Malloc(NSEQ*2L*NCELL) != (long)(loopcnt) )
				form_alert(1,BADACCESS);
			if (midiplex>=0) MPon();
			allmenus(1);		  /* re-enable menu entries */
		}

		mstate= getmouse(&mousex,&mousey);   /* get mouse buttons and location */
		mlock=  menulock();                  /* any menus dropped down? */

	/* interract with menu bar (but not if edit or fill in progress) */
		inmenu= (mousey<=menu_hi_y) && (mousex>=menu_lo_x)
					&& (mousex<=menu_hi_x) && !editmode && !fillmode;
		if (inmenu)
		{
			if (!scr_saved) qsave_screen(menu_hi_y+1,200*rez-1);
			scr_saved=1;
			menu_drop(1);
		}
		else
		{
			if (!mlock)
			{
				menu_drop(0);
				scr_saved=0;
			}
		}

	/* detect either mouse button */
		if ( !mlock && mstate && !inmenu )
		{
			mstate=do_mouse(mousex,mousey,mstate);
			scr_saved=0;
		}

	/* Check for incoming messages and keys */
		event= evnt_multi(MU_MESAG|MU_KEYBD|MU_TIMER,
								0,0,0,0,0,0,0,0,0,0,0,0,0,
				 &messbuf,0,0,&dummy,&dummy,&dummy,&kstate,&key,&dummy);    

	/* handle message or key, but not if mouse in menu bar */
		if ( !inmenu )
		{
			if ( (event&MU_MESAG) && (messbuf[0]==MN_SELECTED) )
			{
				menu_drop(0);
				waitmouse();
				done= do_menu();
				scr_saved=0;
			}
			if ( (event&MU_KEYBD) && !mlock )
			{
				do_key(key,kstate);
				scr_saved=0;
			}
		}

	/* Prevent mouse button auto-repeat */
		if (mstate) while (getmouse(&dummy,&dummy)) evnt_timer(0,0);

	}  /* end until done */
}  /* end exec() */

/* wait for all desk accessories to finish ..................................*/

acc_loop()
{
	register int done;
	int messbuf[8];
	register long hz200;
	int event,top;
	static int maxdone=4;

	/* restart if a new desk acc starts just as the last one was finishing */
restart:
	done=0;

	do     
	{
		menu_drop(1);
		hz200= *(long*)(0x4ba);
		event= evnt_multi(MU_MESAG|MU_TIMER,
								0,0,0,0,0,0,0,0,0,0,0,0,0,
				 messbuf,50,0,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
		if (event&MU_MESAG)
		{
			if (messbuf[0]==WM_REDRAW)
			{
				menu_drop(0);
				re_window(messbuf[4],messbuf[5],messbuf[6],messbuf[7]);
				menu_drop(1);
			}
		}
		hz200= *(long*)(0x4ba) - hz200 ;
		menu_drop(0);
		if (hz200<12L)
		{
			wind_get(0,WF_TOP,&top,&dummy,&dummy,&dummy);
			if (top==windhndl)
			{
				done++;
				deskacc=0;
			}
			else
				done=0;
		}
		else
			done=0;
	}
	while (done<maxdone);
	qrest_screen(menu_hi_y+1,200*rez-1);

	/* sneaky user tried to run another desk acc while first one was closing */
	if (deskacc) goto restart;

}  /* end acc_loop() */

/* allocate buffer for and read file into ...................................*/

char *read_alloc(pathname,leng)	/* returns pointer to buffer, 0L for error */
char *pathname;
long *leng;		/* returned length of file */
{
	long templong,fileleng,filebuf;
	long result=0L;	/* default: error */
	int filehand;

	templong=Fopen(pathname,0);
	if (templong<=0L)
		form_alert(1,BADSCR);
	else
	{
		filehand=templong;
		fileleng=Fseek(0L,filehand,2);
		Fseek(0L,filehand,0);				/* rewind */
		filebuf=Malloc(fileleng);
		if (!filebuf)
			form_alert(1,BADMEM);
		else
		{
			if (Fread(filehand,fileleng,filebuf)!=fileleng)
				form_alert(1,BADSCR);
			else
			{
				result=filebuf;
				*leng= fileleng;
			}
		}
		Fclose(filehand);
	}
	return((char*)result);
}	/* end read_alloc() */

/* flip a BL3 file ..........................................................*/

flip_bl3(i,ptr,leng)
int i;	/* window  # */
long **ptr,*leng;
{
	register long *to_buf,*from_buf;
	register int j;

	leng[i] /= 4;	/* # of longs */
	to_buf= (long*)scrsave - 8 ;
	from_buf= ptr[i];
	from_buf += leng[i];
	for (j=0; j<leng[i]/8; j++) copy_longs(from_buf-=8,to_buf+=8,8);
	copy_longs(scrsave,ptr[i],(int)leng[i]);
	leng[i]/=8;
}	/* end flip_bl3() */

/* convert a BL2 file to BL3 format .........................................*/

bl2_to_bl3(ptr,leng)
int *ptr;		/* --> bl2 */
long leng;		/* # bytes in bl2 */
{
	register int *to_ptr;
	register int row,col;
	char *saveptr,*charptr;

	saveptr= (char*)ptr;
	to_ptr= (int*)scrsave;
	for (row=0; row<(leng/80); row++,ptr+=40)
		for (col=0; col<40; col++,ptr++)
		{
			*to_ptr++ = ptr[0];
			*to_ptr++ = ptr[40];
		}

	charptr= (char*)scrsave;
	for (; leng>0L; leng--) *saveptr++ = *charptr++;
}	/* end bl2_to_bl3 */

/* initialize p_func and r_func arrays ......................................*/

init_funcs()
{
	int pfunc_U(), pfuncdum(), pfunc_R(),pfunc_AC(),pfunc_UC();
	int pfunc_DU(),pfunc_DD(),pfunc_FD(),pfunc_CU(),pfunc_CD();
	int pfunc_RF(),pfunc_EX(),pfunc_HL(),pfunc_RV();
	int pfunc_TA(),pfunc_TB(),pfunc_EO(),pfunc_WM(),pfunc_NR();
	int pfunc_HA(),pfunc_HB(),pfunc_X() ,pfunc_A();
	int pfunc_EC(),pfunc_I() ,pfunc_M() ,pfunc_DR(),pfunc_SR();

	int rfunc_U(), rfuncdum(), rfunc_R(), rfunc_SW(), rfunc_RO();
	int rfunc_RV() ,rfunc_TA(),rfunc_TB(),rfunc_EV(),rfunc_OD();
	int rfunc_NR(),rfunc_DR(),rfunc_SR(),rfunc_X();
	int rfunc_A() ,rfunc_SP(),rfunc_EC(),rfunc_M() ,rfunc_I();
	int rfunc_DM(),rfunc_DU(),rfunc_RN(),rfunc_PD();
	int rfunc_RT(),rfunc_WR(),rfunc_B() ,rfunc_RD(),rfunc_LS();

	asm {
		lea p_func(a4),a0
		lea pfunc_U,a1			move.l a1,(a0)+
		lea pfuncdum,a1		move.l a1,(a0)+
		lea pfuncdum,a1		move.l a1,(a0)+
		lea pfunc_R,a1			move.l a1,(a0)+
		lea pfuncdum,a1		move.l a1,(a0)+
		lea pfunc_A,a1			move.l a1,(a0)+
		lea pfunc_RF,a1		move.l a1,(a0)+
		lea pfunc_EX,a1		move.l a1,(a0)+
		lea pfunc_HL,a1		move.l a1,(a0)+
		lea pfunc_AC,a1		move.l a1,(a0)+
		lea pfunc_RV,a1		move.l a1,(a0)+
		lea pfunc_X,a1			move.l a1,(a0)+
		lea pfunc_TA,a1		move.l a1,(a0)+
		lea pfunc_TB,a1		move.l a1,(a0)+
		lea pfunc_EO,a1		move.l a1,(a0)+
		lea pfunc_WM,a1		move.l a1,(a0)+
		lea pfunc_DU,a1		move.l a1,(a0)+
		lea pfunc_DD,a1		move.l a1,(a0)+
		lea pfunc_FD,a1		move.l a1,(a0)+
		lea pfunc_UC,a1		move.l a1,(a0)+
		lea pfunc_NR,a1		move.l a1,(a0)+
		lea pfunc_DR,a1		move.l a1,(a0)+
		lea pfunc_SR,a1		move.l a1,(a0)+
		lea pfunc_I,a1			move.l a1,(a0)+
		lea pfunc_M,a1			move.l a1,(a0)+
		lea pfunc_EC,a1		move.l a1,(a0)+
		lea pfunc_CU,a1		move.l a1,(a0)+
		lea pfunc_CD,a1		move.l a1,(a0)+
		lea pfunc_HA,a1		move.l a1,(a0)+
		lea pfunc_HB,a1		move.l a1,(a0)+

		lea r_func(a4),a0
		lea rfunc_U,a1			move.l a1,(a0)+
		lea rfuncdum,a1		move.l a1,(a0)+
		lea rfuncdum,a1		move.l a1,(a0)+
		lea rfunc_R,a1			move.l a1,(a0)+
		lea rfuncdum,a1		move.l a1,(a0)+
		lea rfunc_A,a1			move.l a1,(a0)+
		lea rfunc_DM,a1		move.l a1,(a0)+
		lea rfunc_DU,a1		move.l a1,(a0)+
		lea rfunc_RN,a1		move.l a1,(a0)+
		lea rfunc_LS,a1		move.l a1,(a0)+
		lea rfunc_RV,a1		move.l a1,(a0)+
		lea rfunc_X,a1			move.l a1,(a0)+
		lea rfunc_TA,a1		move.l a1,(a0)+
		lea rfunc_TB,a1		move.l a1,(a0)+
		lea rfunc_EV,a1		move.l a1,(a0)+
		lea rfunc_OD,a1		move.l a1,(a0)+
		lea rfunc_RT,a1		move.l a1,(a0)+
		lea rfunc_WR,a1		move.l a1,(a0)+
		lea rfunc_RD,a1		move.l a1,(a0)+
		lea rfunc_RO,a1		move.l a1,(a0)+
		lea rfunc_NR,a1		move.l a1,(a0)+
		lea rfunc_DR,a1		move.l a1,(a0)+
		lea rfunc_SR,a1		move.l a1,(a0)+
		lea rfunc_I,a1			move.l a1,(a0)+
		lea rfunc_M,a1			move.l a1,(a0)+
		lea rfunc_EC,a1		move.l a1,(a0)+
		lea rfunc_SP,a1		move.l a1,(a0)+
		lea rfunc_PD,a1		move.l a1,(a0)+
		lea rfunc_B,a1			move.l a1,(a0)+
		lea rfunc_SW,a1		move.l a1,(a0)+
	}
}	/* end init_funcs() */

/* get rs232 baud rate */

get_baud()
{
	register char i,j;

	for (i=j=0; i<100; i++) j= max(j,*(char*)( 0xfffa25L ));
	for (i=1; j>i; i<<=1) ;
	return(i);

}	/* end get_baud() */

/* return 0 for there IS a box, not 0 for there is no box */

plover()
{
	register char i,j;
	int result,_plover();

	i= *(char*)( Iorec(0)+32L );
	j= *(char*)( 0xfffa29L );

	result= _plover();

	*(char*)( Iorec(0)+32L ) = i;
	*(char*)( 0xfffa29L ) = j;

	return(result);
}	/* end plover() */

asm {
_plover:
	bsr		clrcrc		
	move.w	#0,errcnt(a4)
	move.w	#36,chrcnt(a4)

	move.w	#-1,-(a7)
	move.w	#1,-(a7)
	move.w	#1,-(a7)
	move.w	#0x88,-(a7)
	move.w	#0,-(a7)
	move.w	#1,-(a7)
	move.w	#15,-(a7)
	trap		#14
	adda.l	#14,a7

	move.w	#24,-(a7)
	move.w	#30,-(a7)
	trap		#14
	addq.l	#4,a7

	move.w	#0x1b,d0	
	bsr		xmit
 
	move.w	#10000,d0
dumb:			nop
	dbf		d0,dumb	

rubbish:
	bsr		rcvstat	
	tst.w		d0
	beq		empty	

	bsr		recv	
	bra		rubbish	

empty:
	move.w	#63,d0	
	bsr		xmit

copywait:
	bsr		crwait	
	cmpi.b	#':',d0	
	bne		copywait

docrc:
	bsr		crwait	
	bsr		addcrc	
	subq.w	#1,chrcnt(a4)
	bne		docrc	

	bsr		fincrc
	move.w	crc(a4),d0
	ori.l		#0xff0000,d0
	subi.l	#0xFF008F,d0
	rts		

xmit:
	move.w	d0,-(a7)
	move.w	#1,-(a7)
	move.w	#3,-(a7)
	trap		#13
	addq.l	#6,a7
	rts

recv:
	move.w	#1,-(a7)
	move.w	#2,-(a7)
	trap		#13
	addq.l	#4,a7
	rts

rcvstat:
	move.w	#1,-(a7)
	move.w	#1,-(a7)
	trap		#13
	addq.l	#4,a7
	rts

crwait:
	bsr		rcvstat
	tst.w		d0
	beq		nogo	
	move.w	#0,errcnt(a4)
	bra		recv	

nogo:
	move.w	errcnt(a4),d0
	addq.w	#1,d0	
	cmpi.w	#5000,d0
	bne		stillgo	
	addq.l	#4,a7	
	moveq		#1,d0	
	rts		
stillgo:
	move.w	d0,errcnt(a4)
	bra		crwait	

clrcrc:
	move.w	#0,crc(a4)
	rts

addcrc:
	moveq		#7,d1
	move.w	crc(a4),d2
crcloop:
	lsl.b		#1,d0
	roxl.w	#1,d2
	bcc		skipit
	eori.w	#0x8005,d2
skipit:
	dbf		d1,crcloop
	move.w	d2,crc(a4)
	rts
	
fincrc:
	moveq		#0,d0
	bsr		addcrc
	moveq		#0,d0
	bsr		addcrc
	rts

}	/* end _plover() */

/* give some memory to genpatch accessory ...................................*/

allow_gp(yesno)
int yesno;
{
	register int i;
	register long *longptr;
	long memstart,memavail,templong;

	/* find genpatch accessory */
	for (i=12; i<18; i++)
	{
		longptr= (long*)( ((long)(menuaddr[i].ob_spec)&0xfffffffeL) + 12L );
		if ( longptr[0]=='GENP' ) break;
	}

	if (i<18)
	{
		if (yesno)
		{
			/* find track having largest unused memory */
			memavail= -1L;
			for (i=0; i<NSEQ; i++)
			{
				templong= (long)(playend[i]) - (long)(playtail[i]);
				if (templong>memavail)
				{
					memavail= templong;
					memstart= (long)(playtail[i]);
				}
			}
			longptr[2]= memstart;
			longptr[3]= memavail;
		}
		else
			longptr[2]= longptr[3]= 0L;
	}
}	/* end allow_gp() */

/* EOF main.c */
