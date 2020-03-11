/*
 *	Atari Computing MIDI programming in C tutorial
 *	½1998 Danny McAleer
 *	This code is freeware - feel free to tamper and use as you please!
 *	
 *	This is a simple program to decipher MIDI messages...
 *	It should hopefully explain the way most common MIDI messages
 *	are received and sent, so you can then use this knowledge in your
 *	own MIDI programs (ones that are more interesting than this!!!)
 *
 *	Compiled and written using Lattice C
 *
 */

#include <osbind.h>
#include <stdio.h>

#define 	midi_in()	Bconin(3)
#define		midi_out(x)	Bconout(3, x)
#define		poll_midi()	Bconstat(3)
#define		poll_kbd()	Bconstat(2)
#define		check_kbd()	Bconin(2)
#define 	BYTE		unsigned char

/*  ** 	function declarations  **  */
void 	main(void);
void	draw_menu(void);
void 	evnt_loop(void);
void	process_midi_msg(BYTE);
void 	print_controller(BYTE);
void 	print_sysex(BYTE);


void main(void)
{
	draw_menu();
	evnt_loop();
	exit(1);
}
	
void draw_menu(void)
{
	printf("\033H\033f\n MIDI monitor ");
	printf("\n press [x] to exit");
}

void evnt_loop(void)
{
	BYTE 		m;
	char		k;

	while(1)
	{
		if(poll_kbd()!=0){
			k = check_kbd();
			if(k == 'x')	break;
		}
		if(poll_midi()!=0){
			m = midi_in();
			/* first, check that the message received isn't active sensing! */
			if(m!=0xfe)	process_midi_msg(m);
		}
	}
}

void process_midi_msg(BYTE m)
{
	BYTE 	channel, msg;
	BYTE	midibuff[2048];	
	int		x;
	
	/* if a channel message is sent, filter out the channel */
	if( m >= 0x80)
	{
		channel = (m&0x0f) + 1; /* find channel number */
		msg 	= m&0xf0;		/* remove channel and ascertain message */
	}

	switch(msg)
	{
		case 0xc0:
			/* 
			 * 	this is a program change, and these 
			 * 	have one data byte that holds the patch number
			 */
			midibuff[0] = midi_in();
			printf("\033E\n\n program change #%3d received on channel %2d", midibuff[0], channel);
			break;

		case 0x90:
			/*
			 * 	note on message - this is followed by two data bytes:
			 * 	first the note number, then the velocity
			 */
			for(x=0;x<2;x++)	midibuff[x] = midi_in();
			if(midibuff[1]>0)
				printf("\033E\n\n note on  number %3d of velocity %3d received on channel %2d", midibuff[0], midibuff[1], channel);
			else printf("\033E\n\n note off number %3d received on channel %2d", midibuff[0], channel);
			break;

		case 0x80:
			/*
 			 * 	note off message - note that some synthesizers send
			 * 	not on messages with a velocity of zero - it's the same thing, 
			 * 	although this time, a release velocity can be specified
			 */
			for(x=0;x<2;x++)	midibuff[x] = midi_in();
			printf("\033E\n\n note off number %3d of velocity %3d received on channel %2d", midibuff[0], midibuff[1], channel);
			break;

		case 0xa0:
			/*
 			 *	polyphonic aftertouch is followed by two data bytes,
			 * 	the first for the note, the second, the value of the aftertouch
			 */
			for(x=0;x<2;x++)	midibuff[x] = midi_in();
			printf("\033E\n\n polyphonic aftertouch on note %3d of value %3d received on channel %2d", midibuff[0], midibuff[1], channel);	
			break;
		
		case 0xd0:
			/* 
			 *	channel aftertouch: this type of aftertouch is
			 *	globally applied to all notes on one channel, so 
			 *	it only has one data byte for the value
			 */
			midibuff[0] = midi_in();
			printf("\033E\n\n channel aftertouch of value %3d received on channel %2d", midibuff[0], channel);
			break;

		case 0xe0:
			/*
			 *	pitch bend wheel - followed by two data bytes, 
			 *	that are joined together to form one value (since the range 
			 *	of the pitch bend is greater than 128 it needs two bytes!)
			 */
			for(x=0;x<2;x++)	midibuff[x] = midi_in();
			printf("\033E\n\n pitch bend on channel %2d ", channel);
			break;

		case 0xb0:
			/*
			 *	controller message: there are 128 MIDI controllers,
			 *	some of which are defined, others are not. The first
			 *	data byte specifies the controller number, the second
			 *	is the value of that controller
			 */
			for(x=0;x<2;x++)	midibuff[x] = midi_in();
			printf("\033E\n\n control change value %3d received on channel %2d", midibuff[1], channel);
			print_controller(midibuff[0]);
			break;

			/* 
			 *	below are some system messages - these aren't
			 *	channel specific...
			 */
		case 0xf8:
			printf("\n received MIDI clock message");
			break;
		case 0xfa:
			printf("\n received sequencer start message");
			break;
		case 0xfb:
			printf("\n received sequencer continue message");
			break;
		case 0xfc:
			printf("\n received sequencer stop message");
			break;

		case 0xf0:
			printf("\033E\n\n received system exclusive message");
			for(x=0;x<2048;x++){
				midibuff[x] = midi_in();
				if(midibuff[x] == 0xf7)	break;
			}
			printf("\n manufacturer's ID : %2d ", midibuff[0]);
			print_sysex(midibuff[0]);
			printf("\n model number      : %3d", midibuff[1]);
			printf("\n unit number       : %3d", midibuff[2]);
			printf("\n number of bytes   : %3d", x);
			break;
		default:
			break;
	}
	Vsync();

}

void print_sysex(BYTE m)
{
	char *str;
	/*
	 *	each manufacturer has its own ID for system exclusives
	 *	so that a message meant for a Korg, for example, will
	 *	be ignored by a Roland synth, and so on...
	 *	Further, each model and revision of model has its own number too!
	 *	Below are just a few...
  	 */
	switch(m)
	{
		case 0x07:	str = "Kurzweil";	break;
		case 0x0f:	str = "Ensoniq";	break;
		case 0x10:	str = "Oberheim";	break;
		case 0x18:	str = "E-mu";		break;
		case 0x1a:	str = "ART";		break;
		case 0x40:	str = "Kawai";		break;
		case 0x41:	str = "Roland";		break;
		case 0x42:	str = "Korg";		break;
		case 0x43:	str = "Yamaha";		break;
		case 0x44:
		case 0x45:	str = "Casio";		break;
		default: str = "Unrecognised";	break;
	}
	printf("(%s)", str);
}

void print_controller(BYTE m)
{
	char *str;
	switch(m)
	{
		/* 	
		 *	below are just a few of the more commonly 
		 *	used controller types - there are loads more!
		 */
		case 0x01:	str = "modulation wheel";	break;
		case 0x02:	str = "breath controller";	break;
		case 0x04:	str = "foot controller";	break;
		case 0x05:	str = "portamento time";	break;
		case 0x07:	str = "volume";				break;
		case 0x0a:	str = "pan";				break;
		case 0x0b:	str = "expression pedal";	break;
		case 0x40:	str = "damper pedal";		break;
		case 0x41:	str = "portamento on/off";	break;
		case 0x79:	str = "reset all controllers";	break;
		case 0x7a:	str = "local on/off trigger";	break;
		case 0x7b:	str = "all notes off";			break;
		default:	str = "undefined or unrecognised";	break;
	}
	printf("\n message type is %s", str);
}