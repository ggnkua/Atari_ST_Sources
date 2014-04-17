/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                         Copyright 1990/1991 Tom Bajoras

	module MAIN :	-- Highest level stuff
						-- stuff called during startup/cleanup/hybriswitch

   WARNING:  Don't optimize!

	entry points :	main, startup, exec, finishup, acc_loop, new_mvec

******************************************************************************/

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "temdefs.h"		/* template stuff */
#include "scan.h"			/* keyboard scan codes */
#include "genedit.h"		/* created by RCS */
#include "globals.h"		/* global variables */

/* local globals ............................................................*/

int cols_saved,savecolor[16],newcolor[16];
int messbuf[8];	/* messages from GEM */

/* extern ...................................................................*/

	/* declared in AESBIND (in syslib) */
extern int *pioff, *iioff, *pooff, *iooff;
extern int int_in[],int_out[];

	/* declared in INIT (in syslib) */
extern long *_base;

/* main entry point .........................................................*/

main()
{
	char *badptr, *startup();

	/* copyright message (each line has to be even # chars) */
	asm {
	bra	skip_cright
		dc.b	'G','e','n','E','d','i','t',' '
		dc.b	' ','C','o','p','y','r','i','g','h','t'
		dc.b	' ','1','9','9','0','-','1','9','9','1'
		dc.b	' ','T','o','m',' ','B','a','j','o','r','a','s'
	skip_cright:
	}

	badptr= startup(0);
	if (badptr>0L) form_alert(1,badptr);
	if (!badptr) exec();
	finishup();

	/* tell HybriSwitch that we are really quitting */
	_base[2]= -1L;

}  /* end main() */

/* initialization ...........................................................*/
/* returns 0L successful, -1L failure without alert, >0L failure with pointer
	to alert */

char *startup(sw)
int sw;			/* non-0 if returning from HybriSwitch */
{
	register long templong;
	register int i,j;
	int work_in[11],work_out[57];
	int x,y,w,h;
	int loclplexer;
	long find_vbl(),malloc256();
	int saveA4(),_init();
	int start_prot(),end_prot(),tran_prot();	/* copy protection */

/* copy protection */
#if PROTFLAG
	if (!sw)
	{
		i= checksum(&start_prot,&end_prot);	/* = $11c0 (move.b d0,) */
		asm {
			lea		tran_prot,a0
			move.w	i,(a0)
		}
	}
#endif

/* initialize global variables */
	windhndl=ap_id= (-1);		/* window not open, application not init'd */

/* initialize AES, get an i.d. # */
	if ( (ap_id=appl_init()) < 0 ) return BADINIT;

/* get the VDI handle */
	gl_hand= graf_handle(&dummy,&dummy,&dummy,&dummy);

/* open the VDI virtual workstation */
	for (i=0; i<10; i++) work_in[i]=1;
	work_in[10]=2;
	v_opnvwk(work_in,&gl_hand,work_out);

/* get pointer to screen memory (must also be done after returning from
	switcher -- screen may have moved due to RAM disk */
	scrbase= Logbase();

/* get pointers to keyboard buffer head and tail */
	keyb_head= (int*)Iorec(1) + 3;
	keyb_tail= keyb_head+1;

/* get screen resolution -- runs only in medium or high rez */
	rez= Getrez();
	if ((rez<1)||(rez>2)) return BADREZ;
	if (work_out[0]!=639) return BADREZ;
	if (work_out[1]!=(200*rez-1)) return BADREZ;

	vdi_font(0);	/* sets charw and charh */
	init_gr();						/* self-modify fast graphics */

/* initialize line A */
	asm {
		dc.w		0xA000
		move.l	a0,Abase(a4)				; pointer to line A variables
		suba.l	#348,a0
		move.l	a0,Mstate(a4)           ; pointer to mouse button byte
		suba.l	#254,a0
		move.l	a0,Mousex(a4)           ; pointer to mouse x-coord word
		addq.l	#2,a0
		move.l	a0,Mousey(a4)           ; pointer to mouse y-coord word
		move.w	rez(a4),d0
		lsl.w		#2,d0
		movea.l	0(a1,d0),a0					; --> system font header
		move.l	76(a0),fontptr(a4)		; --> system font (for this rez)
	}

/* restore colors after switching back in */
	if (sw) set_colors(newcolor);

/* check for midi "operating system" (SoftLink, etc.) */
	midi_opsys= which_opsys();

/* midiplexer there? (don't even look if non-standard operating system) */
	if (sw)
		loclplexer= midiplexer;
	else
	{
		loclplexer= midi_opsys ? 0 : MPinit();
	}

/* memory allocation and disk i/o */
	if (!sw)
	{
	/* copy protection: pre-phase */
#if PROTFLAG
		set_rs232(1);
		if (!sync_check())
		{
			set_rs232(0);
			return (char*)(-1L);
		}
#endif
	/* load the resource file */
		if ( !rsrc_load(RSRCFILE) ) return BADRSRC ;
	/* All trees are named xxxxTREE; addresses named xxxxaddr */
		rsrc_gaddr(R_TREE,MENUTREE,&menuaddr);
		rsrc_gaddr(R_TREE,INFOTREE,&infoaddr);
		rsrc_gaddr(R_TREE, FMTTREE,&fmtaddr );
		rsrc_gaddr(R_TREE,MIDITREE,&midiaddr);
		rsrc_gaddr(R_TREE,MONITREE,&moniaddr);
		rsrc_gaddr(R_TREE,PATHTREE,&pathaddr);
		rsrc_gaddr(R_TREE,MACRTREE,&macraddr);
		rsrc_gaddr(R_TREE,CNXLTREE,&cnxladdr);
		rsrc_gaddr(R_TREE,VERYTREE,&veryaddr);
		rsrc_gaddr(R_TREE,FNAMTREE,&fnamaddr);
		rsrc_gaddr(R_TREE,MULTTREE,&multaddr);
		rsrc_gaddr(R_TREE,QUITTREE,&quitaddr);
		rsrc_gaddr(R_TREE,EBDTTREE,&ebdtaddr);
		rsrc_gaddr(R_TREE,NONGTREE,&nongaddr);
		rsrc_gaddr(R_TREE,CNXETREE,&cnxeaddr);
		rsrc_gaddr(R_TREE,PNAMTREE,&pnamaddr);
		rsrc_gaddr(R_TREE,TEM1TREE,&tem1addr);
		rsrc_gaddr(R_TREE,RECTTREE,&rectaddr);
		rsrc_gaddr(R_TREE,LINETREE,&lineaddr);
		rsrc_gaddr(R_TREE,KNFDTREE,&knfdaddr);
		rsrc_gaddr(R_TREE,TOPTTREE,&toptaddr);
		rsrc_gaddr(R_TREE,VALTREE ,&valaddr );
		rsrc_gaddr(R_TREE,NUMBTREE,&numbaddr);
		rsrc_gaddr(R_TREE,BUTNTREE,&butnaddr);
		rsrc_gaddr(R_TREE,GRPHTREE,&grphaddr);
		rsrc_gaddr(R_TREE,JOYTREE ,&joyaddr );
		rsrc_gaddr(R_TREE,TEXTTREE,&textaddr);
		rsrc_gaddr(R_TREE,SEGTREE ,&segaddr );
		rsrc_gaddr(R_TREE,EDITTREE,&editaddr);
		rsrc_gaddr(R_TREE,POPTREE ,&popaddr );
		rsrc_gaddr(R_TREE,WINDTREE,&windaddr);
		rsrc_gaddr(R_TREE,WOPTTREE,&woptaddr);
		rsrc_gaddr(R_TREE,PREFTREE,&prefaddr);
		rsrc_gaddr(R_TREE,GETNTREE,&getnaddr);
		rsrc_gaddr(R_TREE,STUTREE ,&stuaddr );

	/* screen-save buffer must be on page boundary for physbasing */
		scrsave= malloc256(SCRLENG);
		if (!scrsave) return BADMEM;

	/* quarter-screen-save buffer for during cnx execution */
		cnxscrsave= Malloc(SCRLENG/4);
		if (!cnxscrsave) return BADMEM;

	/* midi transmit buffer */
		tran_head= (char*)(malloc256(256L));
		if (!tran_head) return BADMEM;
		tran_tail= tran_head;

	/* midi thru buffer */
		thru_head= (char*)malloc256(256L);
		if (!thru_head) return BADMEM;
		thru_tail= thru_head;

	/* midi receive buffer (reuse Megamax's _init) */
		asm {
			lea		_init,a0				; --> jmp xxxxxx
			move.l	2(a0),a0				; xxxxxx
			move.l	a0,recv_start(a4)
			move.l	a0,recv_head(a4)
			move.l	a0,recv_tail(a4)
		}
		/* look for rts at end of _init:  2nd one; 1st is a global variable */
		asm { move.l a0,recv_end(a4) }
		while ( *(int*)(recv_end) != 0x4e75 ) recv_end+=2;
		recv_end+=2;
		while ( *(int*)(recv_end) != 0x4e75 ) recv_end+=2;
		recv_end+=2;

	/* macro buffers */
		macrobuf= (char*)Malloc(MAXLENG);
		if (!macrobuf) return BADMEM;
		macrclip= (char*)Malloc(MACRLENG);
		if (!macrclip) return BADMEM;

	/* studio setup */
		templong= NDEVICES * sizeof(DEV_STRUCT);
		studioDev= (DEV_STRUCT*)Malloc(templong);
		if (!studioDev) return BADMEM;		
		templong= NDEVICES * sizeof(CONFIG_LINK);
		studioLink= (CONFIG_LINK*)Malloc(templong);
		if (!studioLink) return BADMEM;		

	/* midiplexer buffers */
		if (loclplexer)
		{
			MP_bhead= malloc256(4*256L);
			if (!MP_bhead) return BADMEM;
			MP_btail= MP_bhead;
	      MP_chead= MP_ctail= MP_bhead+256;
	      MP_dhead= MP_dtail= MP_chead+256;
		}

	/* grab all remaining memory (but leave some for fsel_input) */
		templong= Malloc(-1L) - GEMMEM;
		if (!init_mem(templong)) return BADMEM;
		/* NOTE: no more Malloc's can be done after this line */

	/* copy protection:  sync box */
#if PROTFLAG
		sync_protect();
		set_rs232(0);
#endif
	}	/* end if !sw */

/* check for availability of HybriSwitch */
	sw_ptr= find_vbl(0xABADBEEFL);
	menu_ienable(menuaddr,GESWITCH,sw_ptr!=0L);

/* no internal sequencer if non-standard midi operating system */
	if (midi_opsys)
	{
		menuaddr[GERECSEQ].ob_state |= DISABLED ;
		menuaddr[GEPLYSEQ].ob_state |= DISABLED ;
		menuaddr[GELODSEQ].ob_state |= DISABLED ;
		menuaddr[GESAVSEQ].ob_state |= DISABLED ;
	}

/* get location of desk accessory part of desk menu */
	menu_hi_y= 8*rez + 2;
	menu_lo_x= menuaddr[2].ob_x;
	menu_hi_x= menu_lo_x + menuaddr[2].ob_width - 1;
	i= menuaddr[ menuaddr[1].ob_next ].ob_head;
	acc_lo_x= menuaddr[i].ob_x;
	acc_hi_x= acc_lo_x - 1 + menuaddr[i].ob_width;
	acc_lo_y= menu_hi_y + 1 + 16*rez;
	acc_hi_y= menu_hi_y + menuaddr[i].ob_height;

/* how many menu titles? */
	for (i=0; menuaddr[i].ob_type!=G_TITLE; i++) ;
	for (nmenutitl=0; menuaddr[i].ob_type==G_TITLE; i++) nmenutitl++;

/* save Megamax's A4 */
	asm {
		lea		saveA4(PC),a0
		move.l	a4,(a0)
	}

/* throw away spurious interrupts */
	*(long*)(0x60)= (long)(&an_rte);

/* install custom mouse and midi handlers */
	installmvec(1);
	installmidi(1);

	if (!sw)
	{
		init_macros();						/* macros */
		seqmem= alloc_mem(0L);			/* internal sequencer */
		cnxlclpmem= alloc_mem(0L);		/* CNXL clipboard */
		cnxeclpmem= alloc_mem(0L);		/* CNXE clipboard */
		mainclpmem= alloc_mem(0L);		/* main clipboard */
		cnxmem= alloc_mem(0L);			/* CNX buffer */
		init_cnxs();
		editmem= alloc_mem(0L);			/* edit buffer */
		for (i=0; i<NTEMSEGS; i++)		/* TEM */
			temmem[i]= alloc_mem(0L);
		init_tem();
	/* main screen windows */
		for (i=0; i<2; i++)
		{
			windcnxmem[i]= alloc_mem(0L);		/* config */
			windatamem[i]= alloc_mem(0L);		/* data */
			init_device(&wind_device[i]);
			namemem[i]= alloc_mem(0L);			/* patch names */
			initcnxname(-1,windcnxname[i]);
		}
	/* studio description */
		for (i=0; i<NDEVICES; i++) init_studio(i);
	/* copy protection:  disk */
#if PROTFLAG
		if ( disk_protect() == ('K'+'I'+'T'+'Y') )
			return (char*)(-1L);
#endif
	/* code resource */
		cdrmem= alloc_mem(0L);
		load_cdr(CDRFILE);

	/* default drives and paths for all disk functions */
		orig_drive= Dgetdrv();
		mlt_drive=midi_drive=cnx_drive=mac_drive=
			tem_drive=ldat_drive=rdat_drive=i= orig_drive;
		Dgetpath(orig_path,i+1);
		strcpy(mlt_path,orig_path);
		strcpy(midi_path,orig_path);
		strcpy(cnx_path,orig_path);
		strcpy(mac_path,orig_path);
		strcpy(tem_path,orig_path);
		strcpy(ldat_path,orig_path);
		strcpy(rdat_path,orig_path);

	/* override paths from INF file, which has two possible names */
		if (load_inf(INFFILE1))
			load_inf(INFFILE2);

	/* studio description */
		if (load_stu(STUFILE1))
			load_stu(STUFILE2);

	/* AUTOLOAD files */
		no_alerts=1;
		ex_autoload();
		no_alerts=0;

	/* load screen */
		cols_saved= load_screen();
		if (!cols_saved) return BADSCR;
	}	/* end if !sw */

	/* disable menu drop-down, and then draw menu bar */
	menu_drop(1);
	midi_motv(0);
	menu_bar(menuaddr,1);

	/* partless window fills entire screen except menu bar */
	wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
	windhndl= wind_create(0,x,y,w,h);
	if (windhndl<0) return BADWIND;
	wind_open(windhndl,x,y,w,h);
	evnt_mesag(messbuf);				/* ignore redraw message */

	/* initialize screen */
	if (!sw)
	{
	/* draggables */
		for (i=0; i<NHOTSPOTS; i++)
		{
			hotspoty[i] *= rez;
			hotspoth[i] *= rez;
		}
	/* window titles */
		windname_y *= rez;
	/* scroll bars and window work areas */
		window_y *= rez;
		area_y *= rez;
		pnumber_y *= rez;
		vscroll_y *= rez;
		area_h *= rez;
		pnumber_h *= rez;
		vscroll_h *= rez;
		hscroll_y *= rez;
		hscroll_h *= rez;
		up_y *= rez;
		up_h *= rez;
		down_y *= rez;
		down_h *= rez;
	/* main screen clipboard */
		mainclip_y *= rez;
		mainclip_h *= rez;
	/* studio description */
		studio_y1 *= rez;
		studio_y2 *= rez;
		studio_y3 *= rez;
		draw_screen();
	}

	/* enable midiplexer (if there is one) */
	if (midiplexer=loclplexer) MPon();

	/* starting mouse icon */
	graf_mouse(ARROWMOUSE);

	/* success */
#if DEMOFLAG
	form_alert(1,CHEKDEMO);
#endif
	return (char*)(0L);

}  /* end startup() */

/* returns 1= ok, 0= error */
load_screen()
{
	register int i,result,col;
	int colors[17];	/* first word is not used */

	i=Fopen(rez==2 ? SCRMFILE : SCRCFILE , 0);
	result= i>0 ;
	if (result)
	{
		result= Fread(i,34L,colors)==34L;	/* degas header */
		if (result)
		{
			/* save old colors, get new ones */
			for (col=0; col<16; col++)
			{
				savecolor[col]= Setcolor(col,-1);
				newcolor[col]= colors[col+1];
			}
			/* read rest of screen file */
			result= Fread(i,SCRLENG,scrsave) == SCRLENG ;
			if (result)
			{
				/* install colors */
				set_colors(newcolor);
				/* copy screen file to screen */
				linefade(scrsave);
			}
		}
		Fclose(i);
	}
	return result;
}	/* end load_screen() */

/* clean up and terminate ...................................................*/

finishup()
{
	int savethru;

	/* must be done in this order, else recv'ing midi during this can crash */
	savethru=midithru;
	midithru=0;
	if (savethru) thru_nts_off();		/* turn off thru */
	if (midiplexer) MPoff();			/* disable midiplexer (if there is one) */
	installmvec(0);
	installmidi(0);
	midithru=savethru;
	midi_motv(1);							/* restore normal mouse and midi */
	menu_drop(0);							/* allow menu drop-down */

	/* close and delete our window, close all other windows */
	for (int_in[0]=windhndl; int_in[0]>0; 
		wind_get(0,WF_TOP,int_in,&dummy,&dummy,&dummy) )
	{
		crys_if( 102 );  /* wind_close */
		if (int_in[0]==windhndl) crys_if( 103 );  /* wind_delete */
	}

	contrl[0]= 101;						/* close VDI workstation */
	contrl[1]= 0;
	contrl[3]= 0;
	contrl[6]= gl_hand;
	vdi();

	if (ap_id >=0) crys_if(19);		/* appl_exit */

	if (orig_drive>=0)					/* restore original drive and path */
	{
		Dsetdrv(orig_drive);
		dsetpath(orig_path);
	}

	if (cols_saved) Setpalette(savecolor);	/* restore colors */

}  /* end finishup() */

/* main control loop ........................................................*/

exec()
{
	register int event,inmenu,mstate,mlock;
	char done,scr_saved;
	int mousex,mousey,kstate,key,oldmstate=0;
	unsigned int midibyte;

	/* HybriSwitch auto-quit feature */
	if (sw_ptr && *(int*)(sw_ptr+38L) ) ex_switch(-1);

	/* loop until user requests quit */
	for (scr_saved=done=0; !done; )
	{
		/* copy protection: trash vectors */
#if PROTFLAG
		trash_vecs();
#endif

		if (Deskacc)
		{
			Mfree(cnxscrsave);		/* give some memory to non-genp accessory */
			allmenus(0);				/* disable all menu entries */
			/* loan some memory to genpatch accessory */
			allow_genp(1);
			evnt_timer(200,0);		/* 200 empirically */
			acc_loop();					/* returns when all desk acc's are gone */
			allow_genp(0);				/* take memory back from genpatch acc */
			rest_screen(menu_hi_y+1,200*rez-1);
			set_colors(newcolor);	/* control panel may have changed colors */
			scr_saved=0;
			allmenus(1);				/* re-enable menu entries */
			Deskacc=0;
			if (cnxscrsave!=Malloc(SCRLENG/4)) form_alert(1,BADACCESS);
			do_midi(0xFF);	/* reset status tracking */
		}

		getmouse(&mousex,&mousey);				/* get mouse location */
		mlock= menulock();						/* any menus dropped down? */

		/* interract with menu bar */
		inmenu= (mousey<=menu_hi_y) &&
				  (mousex>=menu_lo_x) && (mousex<=menu_hi_x) ;
		if (inmenu)
		{
			if (!scr_saved) save_screen(menu_hi_y+1,200*rez-1);
			scr_saved=1;
			if (midiplexer) MPoff();
			midi_motv(1);
			menu_drop(0); /* allow menu drop down */
		}
		else
		{
			if (!mlock)
			{
				menu_drop(1); /* disable menu drop down */
				midi_motv(0);
				if (midiplexer) MPon();
				scr_saved=0;
			}
		}

		/* detect either mouse button */
		mstate= getmouse(&mousex,&mousey);
		if ( !mlock && mstate && !inmenu && !oldmstate )
		{
			mstate= do_mouse(mousex,mousey,mstate);
			do_midi(0xFF);	/* reset status tracking */
			scr_saved=0;
			if (!mstate) wait(10L);
		}
		oldmstate=mstate;

		/* Check for incoming messages and keys */
		event= evnt_multi(MU_MESAG|MU_KEYBD|MU_TIMER,
								0,0,0,0,0,0,0,0,0,0,0,0,0,
				 messbuf,1,0,&dummy,&dummy,&dummy,&kstate,&key,&dummy);

		kstate &= 0x0F;	/* alt/ctrl/shift */
		/* handle menu selection or key, but not if mouse in menu bar */
		if ( !inmenu )
		{
			if ( (event&MU_MESAG) && (messbuf[0]==MN_SELECTED) )
			{
				menu_drop(1); /* disable menu drop down */
				midi_motv(0);
				if (midiplexer) MPon();
				waitmouse();
				done= do_menu(messbuf);
				do_midi(0xFF);	/* reset status tracking */
				scr_saved=0;
			}
			if ( (event&MU_KEYBD) && !mlock )
			{
				done= do_key(key,kstate);
				do_midi(0xFF);	/* reset status tracking */
				scr_saved=0;
			}
		}

		/* handle midi, but not if mouse in menu bar */
		if ( !inmenu && !mlock )
		{
			midibyte= recv_byte() & 0xFF ;
			if (midibyte!=0xFF) do_midi(midibyte);
		}
		else
			do_midi(0xFF);	/* reset status tracking */

	}  /* end until done */
}  /* end exec() */

end_exec()
{
	/* this function follows exec(), so that copy protection can find end of
		exec() */
}

/* wait for all desk accessories to finish ..................................*/

acc_loop()
{
	register int done;
	register long hz200;
	int event,top;

	/* normal MIDI */
	midi_motv(1);
	installmidi(0);

	for (done=0; done<4; )		/* 4 empirically */
	{
		menu_drop(0);
		hz200= *(long*)(HZ200);
		event= evnt_multi(MU_MESAG|MU_TIMER,
								0,0,0,0,0,0,0,0,0,0,0,0,0,
				 messbuf,50,0,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
		if (event&MU_MESAG)
		{
			if (messbuf[0]==WM_REDRAW)
			{
				menu_drop(1);
				re_window(messbuf[4],messbuf[5],messbuf[6],messbuf[7]);
				menu_drop(0);
			}
		}
		hz200= *(long*)(HZ200) - hz200 ;
		menu_drop(1);
		if (hz200<12L)
		{
			wind_get(0,WF_TOP,&top,&dummy,&dummy,&dummy);
			if (top==windhndl)
				done++;
			else
				done=0;
		}
		else
			done=0;
	}	/* end for */

	/* our MIDI */
	installmidi(1);
	midi_motv(0);

}  /* end acc_loop() */

/* loan memory to genpatch accessory ........................................*/

allow_genp(allow)
int allow;	/* 1 to loan, 0 to take back */
{
	long start,nbytes;
	long *longptr;
	register int i;
	static int genpmem= -1;

	start= nbytes= 0L;
	if (allow)
	{
		genpmem= alloc_mem(0L);
		if (genpmem>=0)
		{
			fill_mem(genpmem);
			start= heap[genpmem].start;
			nbytes= heap[genpmem].nbytes;
		}
	}
	else
	{
		if (genpmem>=0) dealloc_mem(genpmem);
		genpmem= -1;
	}

	/* find genpatch accessory(ies) */
	for (i=7+nmenutitl; i<13+nmenutitl; i++)
	{
		longptr= (long*)( ((long)(menuaddr[i].ob_spec)&0xfffffffeL) + 12L );
		if ( longptr[0]=='GENP' ) 
		{
			longptr[2]= start;
			longptr[3]= nbytes;
		}
	}

}	/* end allow_genp() */

/* storage for Megamax's A4 .................................................*/

saveA4()
{
	;
}	/* end saveA4() */

/* install/restore mouse vector .............................................*/

installmvec(yesno)
int yesno;	/* 1= install, 0= restore */
{
	register long templong,tmplong;
	int new_mvec();
	static int installed;

	if (yesno==installed) return;

  	templong= Kbdvbase() + 16 ;
	if (yesno)	/* install */
	{
		save_mvec= *(long*)(templong);
		*(long*)(templong)= (long)(&new_mvec);
	}
	else	/* restore */
	{
		if (save_mvec) *(long*)(templong)= save_mvec;
		save_mvec=0L;
	}
	installed=yesno;
}	/* end installmvec() */

/* install/restore midi vector ..............................................*/

installmidi(install)
int install;	/* 1= install, 0= restore */
{
	register long templong;
	int new_midi();
	static int nest=0;

	/* midi operating systems emulate normal system */
	if (midi_opsys) return;

	/* nesting */
	if (install)
		nest++;
	else
		nest--;
	if (nest>1) return;
	if (nest<0) { nest=0; return; }

  	templong= Kbdvbase() + 28 ;

	if (nest==1)	/* install */
	{
		save_midi= *(long*)(templong);
		*(long*)(templong)= (long)(new_midi);
	}
	if (nest==0)	/* restore */
	{
		if (save_midi) *(long*)(templong)= save_midi;
		save_midi=0L;
	}
}	/* end installmidi() */

/* custom mouse interrupt handler ...........................................*/

new_mvec()
{
	register int mstate,mousex,mousey,deskstate;
	static int Upx,Upy,Downx,Downy;
	static int Waitfor= 1;		/* mouse interrupt waiting for button down */

	/* 0(a0) = mstate= $F8 + button mask
		button mask = bit 0 set when right button down,
						  bit 1 set when left button down
		1(a0) = mx = deltaX (left is negative, right is positive)
		2(a0) = my = deltaY (up is negative, down is positive)
	*/

	asm {
		movem.l	a2-a6,-(a7)

		lea		saveA4(PC),a4
		move.l	(a4),a4

		move.w	SR,-(a7)
		tst.b		midiplexer(a4)
		beq		no_plexer
		andi.w	#0xFDFF,SR		; allow DMA interrupts
	no_plexer:
		move.l   save_mvec(a4),a2
		jsr      (a2)            ; call old mouse vector
		move.w	(a7)+,SR
	}

	mousex= *Mousex;
	mousey= *Mousey;
	mstate= 1 & *Mstate;  /* only the left button matters */
	deskstate = menuaddr[3].ob_state & SELECTED;		/* desk title */

	asm {
		tst.w    mstate               ; check to see if mouse buttons state
		beq      up                   ; matches the state we're waiting for
		tst.b    Waitfor(a4)          ; if not, exit
		beq      mvec_exit
												; waiting for button down, and we got it
		clr.b    Waitfor(a4)          ; next we're waiting for button up
		move.w   mousex,Downx(a4)     ; record mouse position when button went
		move.w   mousey,Downy(a4)     ; down

		cmp.w    acc_lo_x(a4),mousex  ; check for type 1 desk acc:
		blt      mvec_exit            ; button went down within desk acc
		cmp.w    acc_hi_x(a4),mousex  ; part of desk menu, while desk title
		bgt      mvec_exit            ; was selected
		cmp.w    acc_lo_y(a4),mousey
		blt      mvec_exit
		cmp.w    acc_hi_y(a4),mousey
		bgt      mvec_exit
		tst.b    deskstate
		beq      mvec_exit
		st       Deskacc(a4)
		bra      mvec_exit

up:
		tst.b    Waitfor(a4)
		bne      mvec_exit
												; waiting for button up, and we got it
		st       Waitfor(a4)          ; next we're waiting for button down
		move.w   mousex,Upx(a4)       ; record mouse position when button went
		move.w   mousey,Upy(a4)       ; up

		move.w   Downx(a4),d0         ; button went down in menu bar..
		cmp.w    menu_lo_x(a4),d0
		blt      mvec_exit
		cmp.w    menu_hi_x(a4),d0
		bgt      mvec_exit
		move.w   Downy(a4),d0
		cmp.w    menu_hi_y(a4),d0
		bgt      mvec_exit
		cmp.w    acc_lo_x(a4),mousex  ; ..and button went up in desk acc part
		blt      mvec_exit            ; of the desk menu..
		cmp.w    acc_hi_x(a4),mousex
		bgt      mvec_exit
		cmp.w    acc_lo_y(a4),mousey
		blt      mvec_exit
		cmp.w    acc_hi_y(a4),d0
		bgt      mvec_exit
		tst.b    deskstate            ; .. desk menu title was selected when
		beq      mvec_exit            ; the button went up
		st       Deskacc(a4)
mvec_exit:
		movem.l    (a7)+,a2-a6
	}

}  /* end new_mvec() */

/* EOF */
