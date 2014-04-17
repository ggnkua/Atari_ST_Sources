/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                           Copyright 1990 Tom Bajoras

	module HSW :  HybriSwitch functions

	entry points :	ex_switch, find_mtst, play_mtst, find_vbl
						steinswitch

******************************************************************************/

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "externs.h"		/* global variables */

/* extern ...................................................................*/

	/* in INIT (in syslib) */
extern long init_ssp,*_base;

/* HybriSwitch ..............................................................*/

ex_switch(part)
int part;	/* where to switch to, -1 for unknown */
{
#if HSWFLAG
	long physbase;
	register int *iptr;
	long save10,save24;

	iptr= (int*)(sw_ptr);

	if (part==iptr[17]) return;	/* can't switch to yourself */
	if (part>=iptr[16]) part= -1;	/* nonexistent partition= hsw program */
	iptr[18]= part;					/* tell hsw where to switch to */
	iptr[20]= 0;						/* tell hsw that we know what we're doing */

	save_screen(0,200*rez-1);		/* snap the screen */
	/* finishup closes the window, but hide this by flipping screen */
	physbase= Physbase();
	Setscreen(-1L,scrsave,-1);

	if (!mshrinkamt) mshrinkamt= _base[2];

	asm {
		move.l	0x10,save10(a6)	; save illegal and trace vectors
		move.l	0x24,save24(a6)
		movem.l	d0-a6,-(a7)			; save all registers
		lea		saveA7(PC),a0
		move.l	a7,(a0)				; save a7
	}

	finishup();							/* almost quit */

	/* unhide the screen */	
	rest_screen(0,200*rez-1);
	Setscreen(-1L,physbase,-1);

	asm {
		lea		ret(PC),a0
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

	saveA7:		dc.l 0				; storage for a7
	ret:
		lea		saveA7(PC),a0
		move.l	(a0),-(a7)
		move.w	#32,-(a7)
		trap		#1						;	back to super mode (and restore a7)

		movem.l	(a7)+,d0-a6			; restore all registers
		move.l	save10(a6),0x10	; restore illegal and trace vectors
		move.l	save24(a6),0x24

		move.l	mshrinkamt(a4),-(A7)
		move.l	_base(a4),-(A7)
		clr.w		-(A7)
		move.w	#0x4a,-(A7)			; re-mshrink
		trap		#1
		adda.w	#12,A7
	}

	/* re-initialize */
	startup(1);
	/* has to be done after startup() because startup() draws menu bar */
	rest_screen(0,200*rez-1);

#endif
}	/* end ex_switch() */

/* Steinberg Switcher .......................................................*/

steinswitch()
{
	register int i;

	installmvec(0);

	/* switches out and back in during this! */
	for (i=0; i<100; i++)
	{
		menu_drop(0);
		evnt_multi(MU_TIMER,			/* try this !!! */
								0,0,0,0,0,0,0,0,0,0,0,0,0,
				 &dummy,1,0,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
/*		evnt_timer(10,0); !!! */
		menu_drop(1);
	}

	installmvec(1);
}	/* end steinswitch() */

/* is sequencer available for data sharing? .................................*/
/* finds MTST but not EZ-Track Plus */

long *find_mtst(which)		/* returns pointer to shared data, or 0L */
int *which;						/* returns partition # */
{
#if HSWFLAG
	register char *charptr;
	register int i;
	register long *longptr;

	if (!sw_ptr) return (long*)(0L);

	charptr= (char*)( ((long*)sw_ptr)[4] );	/* --> shared data table */
	for (i=0; i<16; i++,charptr+=8)
	{
		if ( *(int*)(charptr) < 51 )		/* any sequencer i.d. # */
		{
			longptr= (long*)(charptr+4);
			longptr= (long*)(longptr[0]&~1);
			if ((longptr[0]=='MTST')&&(longptr[5]=='MTST')) break;
		}
	}

	if (i==16)
		longptr= (long*)(0L);
	else
		*which=i;

	return longptr;
#else
	return (long*)(0L);
#endif
}	/* end find_mtst() */

/* play song in co-resident sequencer .......................................*/

play_mtst(overchan)
int overchan;	/* channel override for internal sequencer */
{
#if HSWFLAG
	long *find_mtst(),*found;
	int graf_mouse(),play_seq();
	int savemouse[37];

	/* otherwise sequencer stops */
	while (getmouse(&dummy,&dummy)) evnt_timer(0,0);

	/* play internal sequencer instead if mtst not found */
	if ( !(found=find_mtst(&dummy)) )
	{
		play_seq(overchan);
		return;
	}

	copy_words(Abase-856,savemouse,37L);	/* save mouse shape */
	/* restore vectors */
	installmvec(0);
	installmidi(0);
	midi_motv(1);
	if (midiplexer) MPoff();

	asm {
		movem.l	d0-a6,-(a7)
		move.l	found(a6),a6
      pea   	note_icon(a4)
		move.w   #255,-(A7)
		jsr		graf_mouse
	 	addq.w	#6,A7
		moveq		#7,d0			; stop by <return> or <enter> key or either button
		move.l	48(a6),a6	; address of play routine
		jsr		(a6)
		movem.l	(a7)+,d0-a6
	}

	/* re-install vectors */
	if (midiplexer) MPon();
	midi_motv(0);
	installmidi(1);
	installmvec(1);
	copy_words(savemouse,Abase-856,37L);	/* restore mouse shape */
	HIDEMOUSE; SHOWMOUSE;						/* for GEM to change mouse shape */
	waitmouse();
#endif
}	/* end play_mtst() */

/* find something put into vbl queue via Hybrid Arts technique ..............*/
/* returns pointer to what found, 0L error */

long find_vbl(magic)
long magic;
{
#if HSWFLAG
	register long *vblqueue;
	register int temp;
	register long templong,result;

	vblqueue= (long*)(*(long*)(0x456L));
	for (	temp= *(int*)(0x454L) , result=0L; (temp>0)&&!result; temp-- )
		if (templong=vblqueue[temp-1])
			if ( *(int*)(templong) == an_rts )
				if ( *(long*)(templong+2L) == magic )
					result= templong+6L;
	return result;
#else
	return 0L;
#endif
}	/* end find_vbl() */

/* EOF */
