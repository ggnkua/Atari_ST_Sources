/*	kiovgem.c 1.0		*/
/*
 * KERMIT IO package for the VME-10 using GEMDOS
 *
 * Original adaptation from the TERM.C supplied with CPM
 */

#include <portab.h>

#define DEFESC	    0x1D    /* Default escape character for CONNECT */

/* Version string */

BYTE *sccsid = "VME-10 GEMDOS Kermit version 3.0(5) 8/6/85";

EXTERN BYTE escchr;
EXTERN WORD lecho;
EXTERN WORD image;

/* aux port status reg and char available flag */

#define AUX_ST	(*(char *)0xf1c1cd)
#define RXCHAR	1
#define TXMPTY	4

/* aux port control reg */

#define AUX_CTL	(*(char *)0xf1c1cd)
#define EOI	0x38
#define RXINTEN	0x18
#define NOSINTS	0

/* aux port I/O */

#define AUX_CH	(*(char *)0xf1c1c9)

/* VME/10 control register 6 */

#define VME_CR6	(*(char *)0xf19f11)
#define INT4EN	0xc0

#define XON	0x11
#define XOFF	0x13
#define SIZE	32767

BYTE	ibuff[SIZE];	/* serial input buffer */
BYTE	*ibpins, *ibpext; /* insert into and extract from buffer pointers */
WORD	ichar;		/* flag indicating character available in buffer */
WORD	oblkd;		/* flag blocking serial output */
WORD	iblkd;		/* flag indicating serial input blocked */
WORD	cr6;		/* original vme/10 cr6 contents */

WORD num_ticks, tim_set, tim_alarm, ticks_sec;

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

/* send character to serial port */

sputc(ch)
BYTE ch;
{
    if ( !((ch == XON) || (ch == XOFF)) )
	while ( oblkd )
	    ;
    while ( !(AUX_ST & TXMPTY) )
	    ;
    AUX_CH = ch;
}

/* get character from serial buffer */

char sgetc()
{
    BYTE ch;

    if ( iblkd )
	if ( ibpext < ibpins ) {
	    if ( SIZE - (long)(ibpins - ibpext) > 500 ) {
		sputc(XON);
		iblkd = NO;
	    }
	}
    else if ( (long)(ibpext - ibpins) > 500 ) {
	sputc(XON);
	iblkd = NO;
    }

    while ( !ichar )
	;

    ch = *ibpext;
    seti();
    if ( ibpext++ == ibuff + SIZE )
	ibpext = ibuff;
    if ( ibpext == ibpins )
	ichar = NO;
    clri();
    return(ch);
}

/* serial port interrupt handler */
/* assumes only input interrupts */

serint()
{
    BYTE ch;

    while ( AUX_ST & RXCHAR ) {
	ch = AUX_CH;

	if ( ch == XOFF ) oblkd = YES;

	else if ( ch == XON ) oblkd = NO;

	else if ( !ichar || (ibpext != ibpins) ) {
	    /* if buffer was full we lose char */
	    *ibpins = ch;
	    if ( ibpins++ == ibuff + SIZE )
		ibpins = ibuff;
	    ichar = YES;
	}

	/* WARNING: sending char with ints disabled could lose input? */

	if ( !iblkd )
	    if ( ibpext < ibpins ) {
		if ( SIZE - (long)(ibpins - ibpext ) < 300 ) {
		    sputc(XOFF);
		    iblkd = YES;
		}
	    }
	    else if ( (long)(ibpext - ibpins) < 300 ) {
		sputc(XOFF);
		iblkd = YES;
	    }
    }

    /* send end of interrupt to serial port */

    AUX_CTL = EOI;
}

/* dinit */

dinit() {
    /* Turn off the I/O system and disable interrupts */

    while ( !(AUX_ST & TXMPTY) )	/* Wait out pending */
	    ;
    AUX_CTL = 1;		/* select ser port cr1 */
    AUX_CTL = NOSINTS;	/* disable ser port ints */
    setvmecr(6,cr6);	/* restore vme/10 cr6 */
    resvecs();		/* restore interrupt vectors */

    tim_dinit();
}


/* Initialize */

init() {
    m400init();

    /* Initialize the I/O system and enable interrupts */

    cr6 = VME_CR6;
    ibpins = ibuff;
    ibpext = ibuff;
    ichar = NO;
    oblkd = NO;
    iblkd = NO;
    setivecs();

    /* enable interrupts */

    AUX_CTL = 1;		/* select ser port cr1 */
    AUX_CTL = RXINTEN;	/* enable RX interrupts */

    setvmecr(6, cr6 | INT4EN); /* enable I/O chan INT3 */

    /* Assign the default escape character */

    escchr = DEFESC;

    /* Initialize the timer */

    tim_set = FALSE;
    tim_alarm = FALSE;

    ticks_sec = tim_init();
}

/* main terminal loop */

connect()
{
    extern LONG trap();
    LONG lch;
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
	if ( ichar ) {
	    ch = sgetc() & 0x7F;
	    if (image && ch < 32 && ch != 13 && ch != 10) {
		ch+=64;
		trap(6,'^');
	    }
	    trap(6,ch);
	}

	if (lch = trap(6,0xFF)) {
	    ch = lch;
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
			trap(6,'^');
		    }
		    trap(6,ch);
		}
	    }
	}
    }
}
