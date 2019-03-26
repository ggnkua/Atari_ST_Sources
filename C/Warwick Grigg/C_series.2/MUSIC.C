/*
 *	ST Format - C Tutorial
 *
 *	Example program number 2 - calling BIOS, XBIOS and GEMDOS
 *
 *	Sound chip program
 *
 *	Author: Warwick Grigg
 *
 *	Date written: 20th December 1989
 *
 */

#include <osbind.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/*
 *	 Layout for organ keys.
 *
 *	 A#  C#D#  F#G#A#  C#D#
 *	A B C D E F G A B C D
 *
 */

char *kcp;		/* Pointer to keyclick system variable	*/
long supsp;		/* Supervisor stack pointer		*/
char clicksave;		/* Place to save status of keyclick	*/
int volume = 12;	/* Sound chip volume setting		*/
int r7save;		/* Place to save contents of sound reg7 */

static void intro()
{
    printf("\n");
    printf("ST Format C programming tutorial, Example 2 \n");
    printf("Simple sound chip organ\n");
    printf("\n");
    printf("      KEY MAPPING\n");
    printf(" a   d f   h j k   ; '\n");
    printf(" A#  C#D#  F#G#A#  C#D#\n");
    printf("A B C D E F G A B C D\n");
    printf("\\ z x c v b n m , . /\n");
    printf("\n");
    printf("Press 'q' to quit\n");
}

static void setup()
{
    /*
     * Setup sound chip
     */

    r7save = Giaccess(0, 0x07);			/* Save contents for later */
    Giaccess((r7save&0xc0) | 0x3e, 0x87);	/* Enable channel A only   */

    /*
     * Setup key click status
     */

    supsp = Super(0L);		/* Enter privileged supervisor mode	*/
    kcp = (char *)0x484;	/* Pointer to keyclick system variable	*/
    clicksave = *kcp;		/* Preserve keyclick status		*/
    *kcp = *kcp & 0xfe;		/* Turn off keyclick			*/
    Super(supsp);		/* Return to user mode			*/
}

static void play_note(note)
int note;
{
    static float Afreq = 440.0;	/* Frequency of A note = 440 Hz		*/
    float freq;			/* Frequency of key pressed	    	*/
    int period;			/* Period for sound chip @ 125kHz	*/
    clock_t note_stime;		/* System clock time when note started	*/

    /*
     * Play note, then wait till key press
     */

    freq = Afreq * pow(2.0, note/12.0);
    period = floor((125000.0/freq)+0.5);
    Giaccess(period&255, 0x80);
    Giaccess(period>>8, 0x81);
    Giaccess(volume, 0x88);
    note_stime = clock();				/* Remember time    */
    while (!Bconstat(2)) {				/* Until key press  */
    	if (clock()-note_stime >= CLK_TCK/10) {		/* Timeout?         */
            break;					/* 0.1 seconds gone */
    	}
    }	 
    Giaccess(0, 0x88);					/* Turn off sound   */
}

static void tidy_up()
{
    supsp = Super(0L);		/* Enter privileged supervisor mode	*/
    *kcp = clicksave;		/* Restore keyclick status		*/
    Super(supsp);		/* Return to user mode			*/

    Giaccess(r7save, 0x87);	/* Restore enable register	*/
}

static char kbd[] = "\\azxdcfvbhnjmk,.;/'";	
				/* ST keys in order of pitch	*/

main()
{
    char *p;	/* Search pointer	   	*/
    int c;	/* Buffer for reading key press	*/
    int ix;	/* Index into keyboard array	*/

    intro();	/* Inform user			*/
    setup();	/* Setup sound and key click	*/

    while ((c=(Bconin(2)&0xFF)) != 'q') { /* Until quit requested	*/

        /*
         * Find keypress
         */

        p = &kbd[0];		/* Start of note sequence	*/
        while (*p!='\0') {	/* Do until end of string	*/
	    if (*p == c) {	/* If this is the key code	*/
		ix = p-&kbd[0];	/* Pointer arithmetic		*/
		play_note(ix);
		break;		/* Stop searching for key code	*/
	    }
	    p++;		/* Next note in sequence	*/
	}
    }

    tidy_up();
}
