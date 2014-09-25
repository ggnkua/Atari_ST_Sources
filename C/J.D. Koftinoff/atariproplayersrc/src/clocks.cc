/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
/*	clocks.c
**
**	Handles all Xbtimer clock calls.
**  has the ability to set Xbtimer to whatever frequency
**  you want.
**
**	there is more accuracy for lower frequencies.
**
**	frequency range: 48 Hz to 614400 Hz.
**
**	call set_timer( long frequency ) to start the clocks
**	call unset_timer() to stop.
**
**	you can access and reset the clock by directly accessing
**		clock_ticks (long)
*/

#include <jk_sys.h>
#include <osbind.h>
#include <clocks.h>

#define SEND_INT_CLOCK 1

extern "C" void my_interrupt( void );


long clock_ticks;

#if SEND_INT_CLOCK
short clock_ticks_per_midi_clock=4;
short cur_midi_clock_tick_count=4; 
#endif


asm( "
	
	MFP 		=(0xfffffa00)
	S6850		=(0xfffffc00)
	MFP_CLOCK	=(2457600)


	Mgpip 		=(MFP+1)
	Maer		=(MFP+3)
	Mddr		=(MFP+5)
	
	Miera		=(MFP+7)
	Mierb		=(MFP+9)
	Mipra		=(MFP+0xb)
	Miprb		=(MFP+0xd)
	Misra		=(MFP+0xf)
	Misrb		=(MFP+0x11)
	Mimra		=(MFP+0x13)
	Mimrb		=(MFP+0x15)
	Mvr		=(MFP+0x17)
	
	Mtacr		=(MFP+0x19)
	Mtbcr		=(MFP+0x1b)
	Mtcdcr	 	=(MFP+0x1d)
	Mtadr		=(MFP+0x1f)
	Mtbdr		=(MFP+0x21)
	Mtcdr		=(MFP+0x23)
	Mtddr		=(MFP+0x25)
	
	
	Mscr		=(MFP+0x27)
	Mucr		=(MFP+0x29)
	Mrsr		=(MFP+0x2b)
	Mtsr		=(MFP+0x2d)
	Mudr		=(MFP+0x2f)
	
	
	Skeyctl		=(S6850)
	Skeybd		=(S6850+2)
	Smidictl	=(S6850+4)
	Smidi		=(S6850+6)


	IBit0		=0x100
	IBit1		=0x104
	IBit2		=0x108
	IBit3		=0x10c
	ITimerD		=0x110
	ITimerC		=0x114
	IBit4		=0x118
	IBit5		=0x11c
	ITimerB		=0x120
	ITxERR		=0x124
	ITxDATA		=0x128
	IRxERR		=0x12c
	IRxDATA		=0x130
	ITimerA		=0x134
	IBit6		=0x138
	IBit7		=0x13c
" );

#if SEND_INT_CLOCK
asm ("
_my_interrupt:
		movl	d0,sp@-
		addql	#1,_clock_ticks
		subqw	#1,_cur_midi_clock_tick_count

		jne	_my_interrupt_end
		
		movw	_clock_ticks_per_midi_clock,_cur_midi_clock_tick_count

_my_interrupt_loop:
		movb	Smidictl,d0
		btst	#1,d0
		jeq	_my_interrupt_loop
		
		movb	#0xf8,Smidi

_my_interrupt_end:	
		movl	sp@+,d0
		bclr	#5,0xfffa0f 
			/* Tell MFP the interrupt has been serviced	*/
		rte
");
#else
asm ("
_my_interrupt:
		addql	#1,_clock_ticks

		bclr	#5,0xfffa0f 
			/* Tell MFP the interrupt has been serviced	*/
		rte
");
#endif



void set_timer( long freq)
{
int cntrl, count;
static int prescales[]= {
	0, 4, 10, 16, 50, 64, 100, 200
};

	cntrl=0;
	
	if( freq<=614400 && freq>=2400 ) {
		cntrl=1;	/* divide by 4  	*/
		goto done;
	}
	if( freq<2400 && freq>=960 ) {
		cntrl=2;		/* divide by 10 	*/
		goto done;
	}
	if( freq<960  && freq>=600 ) {
		cntrl=3;		/* divide by 16 	*/
		goto done;
	}
	if( freq<600  && freq>=192 ) {
		cntrl=4;		/* divide by 50 	*/
		goto done;
	}
	if( freq<192  && freq>=150 ) {
		cntrl=5;		/* divide by 64 	*/
		goto done;
	}
	if( freq<150  && freq>=96  ) {
		cntrl=6;		/* divide by 100	*/
		goto done;
	}
		
	if( freq<96   && freq>=48  ) {
		cntrl=7; 		/* divide by 200	*/
		goto done;
	}
	
	if( cntrl==0 ) {
		return;
	}
	
done:
	/* entire range is not checked above; this is because if we
	** use (for example) divide by 50 instead of divide by 100
	** for the same frequency, our calculated count value will be
	** larger, giving us a more accurate clock
	*/
	
	count=2457600/(prescales[cntrl]*freq);

	Xbtimer(0, cntrl, count, my_interrupt );
}


void unset_timer()
{
	Xbtimer(0, 0, 0, NULL);
}

static short midi_byte;

static void _clock_midi_out()
{
	asm( "
		movw	sr,sp@-
		orw	#0x700,sr
_amy_loop:
		movb	Smidictl,d0
		btst	#1,d0
		jeq	_amy_loop
		
		movw	_midi_byte,d0
		movb	d0,Smidi
		movw	sp@+,sr
	" );
}

void clock_midi_out( short a )
{
	midi_byte=a;
	Supexec( _clock_midi_out );
}


