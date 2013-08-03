/*	kiorbp.c 1.0		*/
/*
 * KERMIT IO package for the Atari RBP running GEM
 *
 */

#include <portab.h>

#define DEFESC	    0x1D    /* Default escape character for CONNECT */

/* Version string */

BYTE *sccsid = "Atari ST Kermit version 3.0(5) 8/6/85";

EXTERN BYTE escchr;
EXTERN WORD lecho;
EXTERN WORD image;

EXTERN WORD auxstat();
EXTERN BYTE rx1();
EXTERN VOID sputc();

EXTERN WORD constat();
EXTERN BYTE cgetc();
EXTERN VOID cputc();

EXTERN WORD tim_init();

WORD num_ticks, tim_set, tim_alarm, ticks_sec;

set_line(pointer)
BYTE **pointer;
{
    printf("Port selection not implemented in this KERMIT\n");
    dinit();
    exit(1);
}

set_baud(pointer)
BYTE **pointer;
{
    printf("Baud rate selection not implemented in this KERMIT\n");
    dinit();
    exit(1);
}

VOID timer_int()
{
    if(tim_set) {
	num_ticks--;
	if (!num_ticks) {
	    tim_alarm = TRUE;
	    tim_set = FALSE;
	}
    }
}

VOID sleep(time)
WORD time;
{
    set_timer(time);
    while (!tim_alarm) ;
}

VOID set_timer(time)
WORD time;
{
    tim_set = FALSE;
    tim_alarm = FALSE;

    num_ticks = ticks_sec * time;
    tim_set = TRUE;
}

VOID clear_timer()
{
    tim_set = FALSE;
    tim_alarm = FALSE;
}

/* dinit */

dinit() {
    tim_dinit();
}

/* Initialize */

init() {
    /* Assign the default escape character */

    escchr = DEFESC;

    /* Initialize the timer */

    tim_set = FALSE;
    tim_alarm = FALSE;

    ticks_sec = tim_init();
}

BYTE sgetc()
{
    while(!auxstat() && !tim_alarm);

    if (tim_alarm)
	return(0);
    else
	return(rx1());
}

/* main terminal loop */

connect()
{
    BYTE ch;
    static BYTE esc_str[3] = {0, 'c', 0};
    WORD esc_hit;

    esc_hit = FALSE;

    if (escchr < 32) {
	esc_str[0] = escchr + 64;
	printf("\nType Control-%s to exit connect mode.\n",esc_str);
    }
    else {
	esc_str[0] = escchr;
	printf("\nType %s to exit connect mode.\n",esc_str);
    }

    /* main loop */

    FOREVER {
	if ( auxstat() ) {
	    ch = rx1() & 0x7F;
	    if (image && ch < 32 && ch != 13 && ch != 10) {
		ch+=64;
		cputc('^');
	    }
	    cputc(ch);
	}

	if (constat()) {
	    ch=cgetc();
	    if (esc_hit) {
		if (ch == 'c' || ch == 'C')
		    break;
		else if (ch == escchr)
		    sputc(escchr);
		else if (ch == 'h' || ch == 'H')
		    lecho = !lecho;
		else if (ch == 'i' || ch == 'I')
		    image = !image;
		else if (ch == '?') {
		    printf("\n\tc = exit to micro");
		    printf("\n\th = toggle local echo");
		    printf("\n\ti = toggle image mode");
		    printf("\n\t? = this message");
		    printf("\n\ttyping the escape char again generates it\n");
		}
		esc_hit = FALSE;
	    }
	    else if (ch == escchr)
		esc_hit = TRUE;

	    else {
		sputc(ch);
		if (lecho) {
		    if (image && ch < 32 && ch != 13 && ch != 10) {
			ch+=64;
			cputc('^');
		    }
		    cputc(ch);
		}
	    }
	}
    }
}
