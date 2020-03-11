/*
 *	'interface' code for MIDI sequencer
 *
 *	this code draws the on-screen menu, as well
 *	as handling most of the text redraws, and the
 *	Atari keyboard input for editing settings...
 *	it's all pretty self-explanatory!
 *	
 *
 */

#include "globals.h"

extern TRACK 	trk;


void 	draw_menu(void);
void	move_cursor(int, int);
int 	keybd_input(char, short);


void draw_menu(void)
{
	int x;
	printf("\033H\033f\n Mini-MIDI sequencer");
	printf("\n ----------------------------------------");
	printf("\n tempo      : %3d bpm       [-]/[+]", trk.tempo);
	printf("\n play mode  : stopped       [f]/[b]/[r]");
	printf("\n transpose  : %3d semitones [1]/[2]", trk.transpose);
	printf("\n channel    : %3d           [3]/[4]", trk.channel+1);
	printf("\n program    : %3d           [5]/[6]", trk.patch);
	printf("\n ----------------------------------------\n");
	printf("\n track note data:");
	printf("\n ----------------------------------------\n ");
	for(x=0;x<8;x++)	printf(" %3d", trk.note[x]);
	printf("\n\n ----------------------------------------");
	printf("\n other controls:");
	printf("\n [x]... exit program\n [a]... send all-notes off");
	printf("\n [s]... stop sequencer\n [d]... delete note");
}


int keybd_input(char k, short ctr)
{
	switch(k)
	{
		case 'x':	return 0;
		case 'a':
			all_notes_off();
			break;
		case 'd':
			trk.note[ctr] = trk.vel[ctr] = 0;
			move_cursor(12, ctr*4 + 1);
			printf(" %3d ", trk.note[ctr]);
		case '=':	
			if(++trk.tempo > 300)	trk.tempo = 300; 	
			move_cursor(3, 14);	
			printf("%3d", trk.tempo);
			break;
		case '-':	
			if(--trk.tempo < 40)	trk.tempo = 40;		
			move_cursor(3, 14);
			printf("%3d", trk.tempo);
			break;
		case 'f': 
			if(((trk.playmode&0x02)>>1) == ON)	break;
		    trk.playmode = 0x02;
			move_cursor(4, 14);
			printf("forwards ");
			break;
		case 'b':
			if(((trk.playmode&0x04)>>2) == ON)	break;
			trk.playmode = 0x04;
			move_cursor(4, 14);
			printf("backwards");
			break;
		case 'r':
			if(((trk.playmode&0x08)>>3) == ON) 	break;
			trk.playmode = 0x08;
			move_cursor(4, 14);
			printf("random   ");
			break;
		case 's':
			if((trk.playmode&0x01)==ON)	break;
			trk.playmode = 0x01;
			move_cursor(4, 14);
			printf("stopped  ");
			all_notes_off();
			break;
		case '2':
			if(++trk.transpose > 24)	trk.transpose = 24;
			move_cursor(5, 14);
			printf("%3d", trk.transpose);
			break;
		case '1':
			if(--trk.transpose < -24)	trk.transpose = -24;
			move_cursor(5, 14);
			printf("%3d", trk.transpose);
			break;
		case '3':
			if(--trk.channel < 0)	trk.channel = 0;
			move_cursor(6, 14);
			printf("%3d", trk.channel+1);
			send_program_change(trk.channel, trk.patch);
			break;
		case '4':
			if(++trk.channel > 15)	trk.channel = 15;
			move_cursor(6, 14);
			printf("%3d", trk.channel+1);
			send_program_change(trk.channel, trk.patch);
			break;
		case '5':
			if(--trk.patch < 0)		trk.patch = 0;
			move_cursor(7, 14);
			printf("%3d", trk.patch);
			send_program_change(trk.channel, trk.patch);
			break;
		case '6':
			if(++trk.patch > 127)	trk.patch = 127;
			move_cursor(7, 14);
			printf("%3d", trk.patch);
			send_program_change(trk.channel, trk.patch);
			break;
		default:
			break;
	}
	return 1;
}



void move_cursor(int x, int y)
{
	/* redraw cursor in the new screen position */
	printf("\033Y%c%c", (char)(32+x), (char)(32+y) );
}
