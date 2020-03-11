/*
 *	global function declarations and symbolic definitions
 *	for Atari Computing MIDI programming in C tutorial
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
#define		OFF			0
#define		ON			1


typedef struct {
	BYTE	note[8];
	BYTE	vel[8];
	char 	channel;
	short 	tempo;
	char	transpose;
	char	patch;
	char	playmode;
} TRACK;	


/* function declarations... */
unsigned long 	clock_timer(void);
void 			note_on(BYTE, BYTE, BYTE);
void 			note_off(BYTE, BYTE);
int 			check_midi_byte(BYTE, int);
void 			event_loop(void);
void 			draw_menu(void);
void			main(void);
int 			keybd_input(char, short);
void 			send_program_change(BYTE, BYTE);