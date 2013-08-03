#include <portab.h>

#define CTLS 0x13
#define CTLQ 0x11

#define DORX() *(rs232+7)

#define DOTX(ch) *(rs232+7) = ch

#define TXOFF() *(rs232+3) = 0x28

#define TXMT() (*(rs232+3) & 4)

#define RXRDY() rq.qcnt

#define STARTX() if (TXMT()) txint()

#define QSIZE 2048
#define NEARFULL 1990	/* ctl- s when buffer gets up to this */
#define NEAREMPTY 32	/* ctl- q when full buffer gets down to this */

#define DEFESC	    0x1D   /* Default escape character for CONNECT */

EXTERN WORD ser_init(), ser_dinit(), tim_init(); 

EXTERN BYTE escchr;
EXTERN WORD lecho;
EXTERN WORD image;

/* Version String */

BYTE *sccsid = "Lisa Kermit for DR-DOS version 3.0(5) 8/6/85";

char rx1();

BYTE *rs232 = { 0xFCD200 } ; /* LISA only */

WORD rctls, sctls;	/* received ctl-s, sent ctl-s */

WORD num_ticks, tim_set, tim_alarm, ticks_sec;

struct Q
{
    BYTE data[QSIZE];
    WORD front;
    WORD rear;
    WORD qcnt;
} rq,tq;

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

init()
{
    /* Initialize input */

    rq.front = rq.rear = rq.qcnt = 0; 
    tq.front = tq.rear = tq.qcnt = 0;

    ser_init();

    /* Assign the default escape character */

    escchr = DEFESC;

    /* Initialize the timer */

    tim_set = FALSE;
    tim_alarm = FALSE;

    ticks_sec = tim_init();
}

dinit()
{
    /* Wait out any pending transmit stuff */

    while (tq.qcnt) ;

    tim_dinit();
    ser_dinit();
}

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

    FOREVER {
	if (RXRDY()) {
	    ch = rx1() & 0x7F;
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
		if (ch == 8)
		    ch = 127;

		else if (ch == 127)
		    ch = 8;

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

BYTE sgetc()
{
    while(!RXRDY() && !tim_alarm);

    if (tim_alarm)
	return(0);
    else
	return(rx1());
}

nq(ch,qptr)
struct Q *qptr;
BYTE ch;
{
    qptr -> data[(qptr -> rear)++] = ch ;

    if ((qptr -> rear) == QSIZE)
	qptr -> rear = 0;

    qptr -> qcnt++ ;
}

BYTE dq(qptr)
struct Q *qptr;
{
    WORD q2;

    qptr -> qcnt-- ;
    q2 = qptr -> front++ ;

    if ((qptr -> front) == QSIZE)
	 qptr -> front = 0;

    return(qptr -> data[q2]);
}

rxint()
{
    BYTE ch;

    ch = DORX();

    switch(ch) {

	case CTLS:
	    rctls = TRUE;
	    break;

	case CTLQ:
	    rctls = FALSE;
	    STARTX();		/* start the transmitter */
	    break;

	default:
	    nq(ch,&rq);

	    if (!sctls)
		if (rq.qcnt > NEARFULL) {
		    sctls = TRUE;
		    DOTX(CTLS);
		}
    } /* end switch */
}

txint()
{
    if ((!rctls) && (tq.qcnt))		/* we have ch to send & not xoffed */
	return(DOTX(dq(&tq)));

    return(TXOFF());
}

BYTE rx1()
{
    BYTE c;

    c = dq(&rq);

    if (sctls)
	if (rq.qcnt < NEAREMPTY) {
	    sputc(CTLQ);
	    sctls = FALSE;
	}

    return(c);
}

sputc(ch)
BYTE ch;
{
    nq(ch,&tq);
    if (tq.qcnt == 1) STARTX();

    while (tq.qcnt > QSIZE - 10) ;
}
