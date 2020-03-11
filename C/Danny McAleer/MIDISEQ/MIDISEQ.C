/*
 *	Atari Computing MIDI programming in C tutorial
 *	½1998 by Danny McAleer
 *	this code is freeware - use and tamper with as you please!
 *	
 *	With any luck, this progrma will illustrate how easy it is
 *	to write a simple monophonic MIDI sequencer, and also the
 *	ease in which note data can be manipulated!
 *
 *
 *	compiled and written using Lattice C
 *	
 *	file	 : MIDISEQ.C
 *	routines : event loop, start-up code, and MIDI input analyser	
 *
 */

#include "globals.h"

TRACK trk;

void main(void)
{
	setup_parameters();
	draw_menu();
	evnt_loop();
	all_notes_off();
	exit(1);
}

void setup_parameters(void)
{
	trk.tempo		= 120;
	trk.playmode 	= 1;
	trk.transpose	= 0;
	trk.channel		= 0;
	trk.patch 		= 0;
}

void evnt_loop(void)
{
	BYTE 			m, n_off=0;
	char			k;
	unsigned long	timer = clock_timer();
	unsigned long	step;
	int				ctr = 0;

	while(1)
	{
		/*
		 *	first check for any input from the Atari keyboard
		 */
		if(poll_kbd()!=0){
			k = check_kbd();
			if(!keybd_input(k, ctr))	break;
		}
		/*
		 *	next, check the MIDI ports, and if something's there, 
		 *	and it's not active sensing ($fe), go see if it's a note...
		 */
		if(poll_midi()!=0){
			m = midi_in();
			if(m!=0xfe)
				process_midi_msg(m, ctr);
		}


		/* calculate 'step rate' based on tempo and system clock */
		step = (200.0 / ((float)trk.tempo/60.0)) / 4.0;

		/* 
 		 *	the sequencer will only play if bit '0' of the 
		 *	playmode variable is set to 0 (or OFF), since in the
		 *	sequencer this is play mode off!
 		 */
		if((trk.playmode&0x01)==OFF)
		{	
			/* if time has passed, play the next note... */
			if((timer + step) <= clock_timer())
			{
				if(n_off!=0)	note_off(trk.channel, n_off);

				/* 
				 *	if there's a valid note value (greater than 0)
				 *	play the note, then copy it with transposition
				 *	to the note off variable (so next time around
				 *	we can switch it off, even if the value in the 
				 *	array has been over-written...
				 */
				if(trk.note[ctr] > 0){
					note_on(trk.channel, trk.note[ctr]+trk.transpose, trk.vel[ctr]);
					n_off = trk.note[ctr] + trk.transpose;
				}
				/* delete existing cursor...	*/
				move_cursor(13, ctr*4 + 4);	
				printf(" ");
				if(trk.playmode==0x04){ if(--ctr<0)	ctr=7;	}
				else if(trk.playmode==0x02){ 	if(++ctr>7)	ctr=0;	}
				else ctr = rand()%8;
				/* ...and redraw it in the new position! */
				move_cursor(13, ctr*4 + 4);	
				printf("^");
				/* re-sample the system clock once a note has been played */
				timer = clock_timer();
			}
		}
	}
}


int process_midi_msg(BYTE m, int ctr)
{
	BYTE msg[2];

	/* if it's not a note-on, ignore it! */
	if(m!=0x90+trk.channel)	return 0;
	
	msg[0] = midi_in();
	msg[1] = midi_in();
	/* 
	 *	a note on with a velocity value of 0
	 *	is also a note off, so we don't want these either...
	 */
	if(!msg[1])	return 0;

	trk.note[ctr] = msg[0];
	trk.vel[ctr]  = msg[1];
	/* print new MIDI note to sequencer position on screen */
	move_cursor(12, ctr*4 + 1);
	printf(" %3d ", trk.note[ctr]);
	return 1;
}	