/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 


/* 	The New MIDI Library
**
** 	Copyright 1990 By J.D. Koftinoff Software, Ltd
**
** 	Started: August 5, 1990
**
*/

#include "world.h"

#ifdef atarist
#include <midi/midilib1.hh>
#include <atari/atarist.h>	// mfp, 6850 definitions
#include <atari/68kexc.h>  	// 68000 exception definitions


/*	Purpose:
**		Handles all low level and hi level MIDI
**		Communications.
**
**		Contains hooks so you can easily add in
**		your own input routines. 
**		Everything will be called asynchronously.
**
**		Automatically handles MIDI Parsing
**		and MIDI thru.
**
**	This library should not be used with the mouse yet
**	since both MIDI and the mouse are on the same interrupt,
**	lost MIDI data bytes will occur if fast mouse movements
**	are recorded.
**
**	This library does not use any 68901 MFP timers at all.
**	This means that this library will not supply you with any
**	tempo/timing information.
**
**	written for GNU G++
**	with 68K assembly in MIT syntax and Motorola syntax
*/


static void rx_parser( short byte );


//  Compiler Constants and options for library:

#define TX_INTERRUPT		TRUE
#define QUEUE_SIZE		8192
#define DEBUG			FALSE

asm("QUEUE_SIZE	= 8192");


//	Variable Definitions:


static short outQ_empty, outQ_next_in, outQ_next_out;
static uchar outQ_buffer[QUEUE_SIZE];

static short MIDI_inited=FALSE;
static short within_MIDI_rx=0;

MsgProc user_midi_msgin=NULL;

// static short (*user_msgin)( MIDIMessage )=NULL;

	/* 	user_msgin() is called like:
	**
	**		user_msgin( MIDIMessage theMessage );
	*/

	
	
	
////////////////////////////////////////////////////////////////
//
//	the low level MIDI Interrupt routines and such:
//
////////////////////////////////////////////////////////////////


extern void midi_sys();
extern void rx_midi_int();
extern void tx_midi_int();
extern void mousevec();	
extern void new_vbl();
extern void new_hbl();
extern void new_linea();
extern void new_linef();
extern void new_2960();


static short (*old_2960)();
static short (*old_linea)();
static short (*old_linef)();
static short (*old_hbl)();
static short (*old_vbl)();
static short (*old_mousevec)();
static short (*old_midisys)();
static short current_6850_state=0;



rx_MIDI_int()
{
	asm( "jsr _rx_midi_int" );
#if TX_INTERRUPT
	asm( "jsr _tx_midi_int" );
#endif
}


asm( "
	.text

_mousevec:
	jsr _rx_midi_int
	movel	_old_mousevec,a1
	jsr	a1@
	jsr _rx_midi_int
	rts
	

_new_hbl:
	jsr	_rx_midi_int
	rte

_new_vbl:
	jsr 	_rx_midi_int
	movel	_old_vbl,sp@-
	rts

_new_linea:
	jsr	_rx_midi_int
	movel	_old_linea,sp@-
	rts

_new_linef:
/*	jsr 	_rx_midi_int */
	movel	_old_linef,sp@-
	rts

_new_2960:
	jsr _rx_midi_int
	movel	_old_2960,sp@-
	rts

	
_midi_sys:
	btst	#7,Smidictl		| did MIDI want int?	
	jeq	Ldone_midi_sys		| no, skip everything  
					|
	btst	#0,Smidictl		| is rcv reg full?	
	jeq	Lcheckm1		| no, check tx		
					|
	jsr	_rx_midi_int		| yes, handle rcv	
	jra	_midi_sys		| and check again!	
					|
Lcheckm1:				|
	btst	#1,Smidictl		| is tx reg empty?	
	jeq	Ldone_midi_sys		| no, end		
					|
	jsr	_tx_midi_int		| handle tx		

Ldone_midi_sys:
	rts
	
	
	
	
_rx_midi_int:	
	btst	#0,Smidictl		| does midi really have byte?
	jeq	Lrxdone1		| no, skip this whole mess
	
	tas	_within_MIDI_rx		| are we already in this routine?
	jne	Lrxdone1		| yes, don't process again

	moveml	D0-D3/A0-A3,sp@-	| save all the fucking registers	
				 	|
Lrxagain:				|
	clrw	D0		    	| prepare for data			
	btst	#5,Smidictl	    	| was there an overrun?	    	
	jeq	Lrxno_overrun	    	| no, skip.			
					|
	movel	0x44e,A0		| put dots on screen if overrun
	addl	#1,A0@			| happens
					|
				    	| what do we do if overrun?	
	moveb	Smidi,D0		|
	moveb	#0xfe,D0	    	| we replace it with FE!		
	jra	Lrxstore_it	    	| since 0xfe is normally filtered.	
					|
Lrxno_overrun:				|
	moveb	Smidi,D0	    	| read the received byte.		
					|
	cmpb	#0xfe,D0	    	| filter out active sensing.	
	jeq	Lrxskip_it		|
		
Lrxstore_it:
		| we gotta try to parse it.
		| if parsing finds a valid message, it will be sent
		| directly to the user_msgin procedure.
		|
		
		
	movel	d0,sp@-		    	| call parser program		
	jsr	_midi_rx_parser		|
	addql	#4,sp			|
					|
Lrxskip_it:				|
	jsr 	_tx_midi_int		| check for tx interrupt
					|
	btst	#0,Smidictl	    	| does midi still got a byte?	
	jne	Lrxagain	    	| if not zero, yes!		
					|
	moveml	sp@+,D0-D3/A0-A3    	| restore the regs
	clrw	_within_MIDI_rx		
Lrxdone1:
	rts
	
" );



#if TX_INTERRUPT
asm( "	
	
_tx_midi_int: 
	moveml	d0-d3/a0-a3,sp@-	| save the registers.		
					|
	tstw	_outQ_empty		| is the output queue empty?	
	jne	Ltxis_empty		| yes, tell the 6850 so.	
					|
	btst	#1,Smidictl		| does 6850 really want a byte?
	jeq	Ltxend			| no, end.			

| ok, read the next byte in the queue and send it out.		

	clrl	d1
	movew	_outQ_next_out,d1	| get off to next out of queue 
	lea	_outQ_buffer,a0		| get ptr to buffer		
					|
	addl	d1,a0			| kludge 'cuz gnu is weird  
	moveb	a0@,Smidi		| send it to 6850		
		
| now we gotta update next_out.

	addqw	#1,d1			| update it.			
	cmpw	#QUEUE_SIZE,d1		| is it at end of buffer?	
	jne	Ltxno_wrap		|
					|
	clrw	d1			| yes, wrap around.		
Ltxno_wrap:				|
	movew	d1,_outQ_next_out	| save new next_out value.	
					|
	cmpw	_outQ_next_in,d1	| is next_in==next_out?	
	jne	Ltxend			| no, we are done.		
					|
	movew	#TRUE,_outQ_empty	| yes, set empty flag		
					|
Ltxis_empty:				|
	moveb	#0x95,Smidictl          | shut off Tx interrupts	
	movew #0x95,_current_6850_state	| save flag as well.		

Ltxend:
	moveml sp@+,d0-d3/a0-a3
	rts
	.data
");
#else
asm("
_tx_midi_int:
	rts
");
#endif




static void init_lowlevel( void )
{
	
	asm volatile ( "
	movew	sr,sp@-
	orw	#0x700,sr
	
	movel	XLevel4,_old_vbl
	/* movel	#_new_vbl,XLevel4 */
	
	movel	XLevel2,_old_hbl
	/* movel	#_new_hbl,XLevel2 */

	movel	0x2960,_old_2960
	/*	movel	#_new_2960,0x2960 */
	
	movel	XLineF,_old_linef
	/* movel	#_new_linef,XLineF */
	
	movel	XLineA,_old_linea
	/* movel	#_new_linea,XLineA */
	
	/* moveb	#0x40,Mvr 	*/

	moveb	#3,Smidictl     	| reset MIDI port	
	moveb 	#0x95,Smidictl
	movew	#0x95,_current_6850_state
	
	movew	sp@+,sr
	" );
}

static void kill_lowlevel( void )
{

	asm volatile ( "

	movel	_old_vbl,XLevel4 
	movel	_old_hbl,XLevel2
	movel	_old_2960,0x2960
	movel	_old_linef,XLineF
	movel	_old_linea,XLineA
	
	movew	sr,sp@-
	orw	#0x700,sr
	moveb	#0x48,Mvr
	moveb	#3,Smidictl     	| reset MIDI port	
	moveb	#0x95,Smidictl
	movew	#0x95,_current_6850_state
	
	movew	sp@+,sr
	
	" );

}



// must call SendMIDIByte with int's off.

void SendMIDIByte( register short data )	// data=D0
{
#if TX_INTERRUPT
	asm volatile ( "

	tstw	_outQ_empty		| is output Q empty?		
	jeq	LSMstore_it		| no, store byte in queue 	
	btst	#1,Smidictl		| yes, is 6850 ready for it?	
	jeq	LSMstore_it		| no, store byte in queue	
	moveb	D0,Smidi		| yes, send it to 6850		
	jra	LSMend			| we are done			
					|
LSMstore_it:				|
	clrl	D1			|
	movew	_outQ_next_in,D1	| get next in offset of Q	
	lea	_outQ_buffer,a0		| get address of buffer	
	addl	D1,a0			| calculate position in buffer 
	moveb	D0,a0@			| store data in Queue		
	addqw	#1,d1			| calc next position in Queue	
	cmpw	#QUEUE_SIZE,d1		| wrap?			
	jne	LSMno_wrap		| no, don't			
					|
	clrl	d1			| yes, wrap. next_in=0		
LSMno_wrap:				|
	movew	d1,_outQ_next_in	| update next_in		
	clrw	_outQ_empty		| the Q is no longer empty	
					|
	moveb	#0xb5,Smidictl		| turn on tx interrupts	
	movew   #0xb5,_current_6850_state |
	
LSMend:
	"
	);
#else
	asm volatile ( "

Llpsend:
	btst	#1,Smidictl		| is 6850 ready?
	jeq	Llpsend			| no, loop
	moveb	D0,Smidi		| give byte to 6850
	"
	);
#endif

}


// InitMIDI() Simply initialize the MIDI port and start the
// Ball Rolling.


short InitMIDI( void )
{

	kbdvecs *k;

	if( MIDI_inited==FALSE )
	{
        	Blitmode(0);  		//  shut off bit blitter
		outQ_next_in=0;
		outQ_next_out=0;
		outQ_empty=TRUE;
		
		// now initialize the hardware
		// for proper interrupts.
		
		Supexec( init_lowlevel );
		
		k=Kbdvbase();
		old_midisys=k->midisys;
		old_mousevec=k->mousevec;
		(void *)k->midisys=(void *)midi_sys;
		(void *)k->mousevec=(void *)mousevec;
		
		MIDI_inited=TRUE;
		AllNotesOff();
		return( TRUE );	
	}
	return( FALSE );
}

void KillMIDI( void )
{
	void *save_usermsgin;
	kbdvecs *k;
	
	if( MIDI_inited==TRUE )
	{
		// remove the MIDI handler routines
		
		save_usermsgin=(void *)user_midi_msgin;
		
		user_midi_msgin=NULL;	   // also shuts off MIDI_thru
		AllNotesOff();
		
		while( !outQ_empty );
		
		k=Kbdvbase();
		k->midisys=old_midisys;
		k->mousevec=old_mousevec;
		
		Supexec( kill_lowlevel );
		
		MIDI_inited=FALSE;
		user_midi_msgin=save_usermsgin; // restore the user msgin proc
		
        	Blitmode(1);     	   // turn bit blitter back on
	}
	
}


void SetMIDIUserMSGIn( MsgProc user_proc )
{
	user_midi_msgin=user_proc;
}


////////////////////////////////////////////////////////////////
//
//	Medium level MIDI routines.
//
////////////////////////////////////////////////////////////////


static MIDIMessage m;

void midi_rx_parser( short data )
{
	static short state=0;
	MIDIMessage sys;
	register short stat;


	// here is the state machine which parses the MIDI bytes.
	// first here are the bytes that cause the state machine to
	// jump into state 0 (initial state), which causes the
	// machine to ignore all data until next status byte.
		
			
	if( data&0x80 )				// any type of status message?
	{
		stat=data&0xf0;
		
		if( stat==0xf0 )		// any type of system message?
		{
			if(  data==M_RESET 	// system reset
			  || data==M_SENSE	// not sense but overflow 
			//  || data==M_EXCL	// start of sys-ex
			//  || data==M_EOX	// end of sys-ex
				)
			{
				state=0;
				m.length=0;
				m.status=0;	// reset running status

				sys.length=1;
				sys.status=data;
					
				if( user_midi_msgin ) // tell the user
				{
					(*user_midi_msgin)( sys );
				}
				return;
			}
			if(  data==M_START	// any clock messages?
			  || data==M_STOP
			  || data==M_CONTINUE
			  || data==M_CLOCK
			  || data==M_TUNE	// or tune requests?
				)
			{
				// we use sys because these msgs may
				// interrupt long message

				sys.length=1;
				sys.status=data;
					
				if( user_midi_msgin )
				{
					(*user_midi_msgin)( sys );
				}
				return;
			}
		if( data==M_SPP			// song position pointer?
			)
		{
			state=3;		// means we expect two more
			m.length=1;
			m.status=data;
			return;
		}
		if(	data==M_SONG		// song number select?
			)
		{
			state=2;		// means we expect one more 
			m.length=1;
			m.status=data;
			return;
		}
			
			// if there is anything else, cause a reset.
			// this means communications is really fucked
			
			state=0;
			m.length=0;
			m.status=0;		// reset running status
			return;
		}
		
		// ok, so it wasn't a system message. it was a simple
		// real time channel message. how long is it going to be?
		
		
		// here are all the 3 byte messages.
		
		if(	stat==M_NOTE_OFF	
		    ||	stat==M_NOTE_ON
		    ||	stat==M_P_AFTER
		    ||	stat==M_CONTROL
		    || 	stat==M_BENDER
		  )
		{
			state=3;
			m.status=data;
			return;
		}
		
		// here are the two byte messages:
		
		if(	stat==M_PG
		    ||	stat==M_C_AFTER
			)
		{
			state=2;
			m.status=data;
			return;
		}
		
		// if there is anything else, cause a reset.
		// this means communications is really fucked
		
		state=0;
		m.length=0;
		m.status=0;	// reset running status
		return;
	}
	else	// here comes data bytes.
	{
		if( state==0 )	// we don't do anything at all.
		{
			return;
		}
		if( state==3 )	// we must read first data byte of 3 byte msg
		{
			m.byte1=data;
			state=4; 	// go into state 4 to read second byte
			return;
		}
		if( state==2 )	// we gotta read single data byte of 2 byte msg
		{
			m.length=2;
			m.byte1=data;
			
			state=2;	// keep running status active
			if( user_midi_msgin )
			{
				(*user_midi_msgin)( m );
			}
			return;
		}
		if( state==4 )
		{
			m.length=3;
			m.byte2=data;

			state=3;	// keep running status active	
			if( user_midi_msgin )
			{
				(*user_midi_msgin)( m );
			}
			return;
		}
	}

}


///////////////////////////////////////////////////////////////////
//
//	interface to the rest of the world. These routines
//	are the only routines here that are not 'static.'
//
///////////////////////////////////////////////////////////////////



	
void SendMIDISuper(
	MIDIMessage *msg )		// call from supervisor mode
{
	if( msg->length==0 )
		return;
		
	SHUT_OFF_INTS();
	
	switch( msg->length )
	{
	case 1:
		SendMIDIByte( msg->status );
		break;
	case 2:
		SendMIDIByte( msg->status );
		SendMIDIByte( msg->byte1 );
		break;
	case 3:
		SendMIDIByte( msg->status );
		SendMIDIByte( msg->byte1 );
		SendMIDIByte( msg->byte2 );
		break;

	}
	
	RESTORE_INTS();

}

void SendMIDISuper(
	MIDIMessage msg )		// call from supervisor mode
{
	if( msg.length==0 )
		return;
		
	SHUT_OFF_INTS();
	
	switch( msg.length )
	{
	case 1:
		SendMIDIByte( msg.status );
		break;
	case 2:
		SendMIDIByte( msg.status );
		SendMIDIByte( msg.byte1 );
		break;
	case 3:
		SendMIDIByte( msg.status );
		SendMIDIByte( msg.byte1 );
		SendMIDIByte( msg.byte2 );
		break;

	}
	
	RESTORE_INTS();
		

}

void SendMIDI( MIDIMessage *msg )
{
	if( msg->length==0 )
		return;
		
	long stack=Super(NULL);	// go in to supervisor mode
	
	SHUT_OFF_INTS();

	switch( msg->length )
	{
	case 1:
		SendMIDIByte( msg->status );
		break;
	case 2:
		SendMIDIByte( msg->status );
		SendMIDIByte( msg->byte1 );
		break;
	case 3:
		SendMIDIByte( msg->status );
		SendMIDIByte( msg->byte1 );
		SendMIDIByte( msg->byte2 );
		break;

	}

	RESTORE_INTS();
	Super( stack );	// get back out of Supervisor mode
}

void SendMIDI( MIDIMessage msg )
{
	if( msg.length==0 )
		return;

	long stack=Super(NULL);		
	SHUT_OFF_INTS();
	
	switch( msg.length )
	{
	case 1:
		SendMIDIByte( msg.status );
		break;
	case 2:
		SendMIDIByte( msg.status );
		SendMIDIByte( msg.byte1 );
		break;
	case 3:
		SendMIDIByte( msg.status );
		SendMIDIByte( msg.byte1 );
		SendMIDIByte( msg.byte2 );
		break;

	}
	
	RESTORE_INTS();

	Super( stack );	// get back out of Supervisor mode
}


void SendMIDIExclusive( uchar *buf, ushort len )
{
	long stack;
	register ushort i;
	register uchar *p;
	
	stack=Super(NULL);	// go in to supervisor mode
	
	SHUT_OFF_INTS();

	for( i=len, p=buf; i; --i,p++ )
	{
		SendMIDIByte( *p );
	}

	RESTORE_INTS();
	
	Super( stack );
}

void SendMIDIExclusiveSuper( uchar *buf, ushort len )
{
	register ushort i;
	register uchar *p;
	
	SHUT_OFF_INTS();

	for( i=len, p=buf; i; --i,p++ )
	{
		SendMIDIByte( *p );
	}
	 
	RESTORE_INTS();
	
}

void AllNotesOff( void )
{
ushort i;
MIDIMessage e;

	e.length=3;
	e.byte1=0x7b;
	e.byte2=0;

	for( i=0; i<16; i++ )
	{
		e.status=0xb0 | i;
		SendMIDI( e );
	}

}

void AllNotesOffSuper( void )
{
ushort i;
MIDIMessage e;

	e.length=3;
	e.byte1=0x7b;
	e.byte2=0;

	for( i=0; i<16; i++ )
	{
		e.status=0xb0 | i;
		SendMIDISuper( e );
	}

}


#endif
