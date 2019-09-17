/*   Atari Falcon 030     */
/* DMA Sound Test Program */
/*   ½ Paul Brookes 1994  */
/* Tested on TOS 4.01 4Mb */
/*      Lattice C 5.6     */  
/*   No special compiler  */
/*     options needed     */
/* ---------------------- */
/* Bare bones program to show how to record sound using the Falcon's CODEC,   */
/* and play it back again. Modify the Devconnect() command to experiment with */
/* different sampling rates etc . Change size_of_buffer to increase/decrease  */ 
/* the maximum length of the sample. */

#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>

#define size_of_buffer 	327680		/* Change to effect the sample length */

/* defines for the source parameter of the Devconnect function */
#define dma_playback	0
#define dsp_transmit	1
#define external_input	2
#define adc 			3

/* defines for the destination parameter of the Devconnect function (bitwise) */
/* i.e. you can have several destinations by ORing the bits together...       */
#define dma_record 		0x01
#define dsp_receive		0x02
#define external_output	0x04
#define dac				0x08

/* defines for the source clock parameter of the Devconnect function */
#define internal_25MHz	0
#define external_clock	1
#define internal_32MHz  2

/* defines for the protocol parameter of the Devconnect function */
#define handshake 		0
#define no_handshake	1

/* defines for the Setmode function */
#define _8_bit_stereo	0
#define _16_bit_stereo	1
#define _8_bit_mono		2

/* defines for the mode parameter of the Soundcmd function */
#define left_attenuation 	0
#define right_attenuation	1
#define left_gain			2
#define right_gain			3
#define adder_input			4
#define adc_input			5
#define set_prescale		6

/* defines for the data parameter of the Soundcmd function (bitwise) */
#define matrix_in			0x02
#define adc_in				0x01

#define psg_left			0x02
#define psg_right			0x01
#define microphone_left		0x00
#define microphone_right 	0x00
#define microphones			0x00

/* defines for the Setbuffer command */
#define play_mode			0
#define record_mode			1

/* defines for Buffoper (bitwise) */
#define play_enable			0x01
#define play_repeat			0x02
#define record_enable		0x04
#define record_repeat		0x08

main()
{

int *start_buffer,*end_buffer;      /* pointers to the start and the */
								    /* end of the sound buffer */
struct tape_type {					/* make the structure for the */
long play_buf;						/* Buffptr function which returns */
long rec_buf;						/* the play & record buffer pointers */
long reserv1;
long reserv2;
}*bufpos;

if( NULL == (start_buffer=malloc(size_of_buffer))) {  /* ask for some RAM  */
printf("Unable to allocate memory for sample \n");	  /* none available !  */
exit(-9);											  /* terminate program */
}
end_buffer = start_buffer + size_of_buffer;			  /* calculate end */


Buffoper(0);						/* flush the sound system's 32 byte FIFO */
Sndstatus(1);						/* reset : DSP tristate, gain=attenuation=0, matrix connections reset */
									/* adderin disabled, mode = 8bit stereo, play/record tracks = track 0 */
									/* monitor track = track 0, interrupts & buffer mode disabled */ 
Setmode(_16_bit_stereo);			/* sample PLAYBACK resolution = 16 bit stereo */

/* The following command sets the switch matric source to be the A to D. The destination is set */
/* so we hear the sound and record it, using the 25.175MHz clock and a prescaler of 5 giving approx 16KHz */
/* I can only get this program to work with handshaking disabled (TOS 4.01 bug ?)*/

Devconnect(adc,(dac||dma_record),internal_25MHz,5,no_handshake);	
Soundcmd(adder_input,adc_in);		/* the adder input must be from the ADC - without this nothing happens */
Soundcmd(left_attenuation,240); 	/* Left attenuation = maximum (note: NOT 255) */
Soundcmd(right_attenuation,240); 	/* Right attenuation = maximum */
Soundcmd(adc_input,microphones);	/* ADC input from microphone inputs */
Soundcmd(left_gain,128);			/* left gain : max is 240 */
Soundcmd(right_gain,128);			/* right gain : max is 240 */
Settrack(0,0);						/* record track = track 0, play track = track 0 */
Setbuffer(record_mode,start_buffer,end_buffer);		/* set up record buffer limits */
Buffoper(record_enable);							/* RECORD */
while(Buffoper(-1) !=0);			/* wait for recording to end */
printf("Recording made. Time to play it back...\n");

Devconnect(dma_playback,dac,internal_25MHz,5,no_handshake);		/* DMA to DAC */
Soundcmd(adder_input,matrix_in);					/* Adder input from Matrix */
Setbuffer(play_mode,start_buffer,end_buffer);		/* set up playback buffer */
Buffoper(play_enable);								/* PLAY */
}
