/* 	The New MIDI Library header file
**
** 	Copyright 1990 By J.D. Koftinoff Software, Ltd
**
** 	Started: August 5, 1990
**
**	re-started: April 21, 1991 for GNU C++
**
*/

#ifndef __MIDI_MIDILIB1_HH
#define __MIDI_MIDILIB1_HH

#ifdef atarist

#include <midi/midi.hh>



typedef int (*MsgProc)( MIDIMessage );


//	Prototypes for the MIDI library routines.


short InitMIDI( void );
void KillMIDI( void );

void SendMIDIByte( register short );

overload SendMIDI;
void SendMIDI( MIDIMessage * );
void SendMIDI( MIDIMessage );

overload SendMIDISuper;
void SendMIDISuper( MIDIMessage * );
void SendMIDISuper( MIDIMessage );

void SendMIDIExclusive( uchar *buf, ushort len  );
void SendMIDIExclusiveSuper( uchar *buf, ushort len );
void SetMIDIUserMSGIn( MsgProc user_proc );

void AllNotesOff( void	);
void AllNotesOffSuper( void );

#endif

#endif


