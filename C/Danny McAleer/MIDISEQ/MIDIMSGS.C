/*
 *
 *	MIDI message routines for Mini-MIDI sequencer...
 *	this file processes all of the messages sent by the
 *	Atari to the connected MIDI synthesizer, and the
 *	function for reading the time from the system clock
 *
 *
 */

#include "globals.h"

void note_off(BYTE channel, BYTE note)
{
	midi_out(0x80+channel);		/* note off message plus channel number */
	midi_out(note);
	midi_out(0x20);				/* note-off velocity! */
}

void note_on(BYTE channel, BYTE note, BYTE vel)
{
	midi_out(0x90+channel);		/* note on message plus channel number */
	midi_out(note);
	midi_out(vel);
}

void send_program_change(BYTE channel, BYTE patch)
{
	midi_out(0xc0+channel);
	midi_out(patch);
}


unsigned long clock_timer(void)
{
	unsigned long *old_ssp = Super(0L);
	unsigned long time_value = *((unsigned long*)0x04BA);
	Super(old_ssp);
	return time_value;
}

void all_notes_off(void)
{
	int x;
	for(x=0;x<16;x++){
		midi_out(0xb0+x);
		midi_out(0x7b);
		midi_out(0);
	}
}
