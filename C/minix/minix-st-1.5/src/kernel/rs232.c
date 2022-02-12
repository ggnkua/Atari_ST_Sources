#include "kernel.h"
#include <signal.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include <sgtty.h>
#include "proc.h"
#include "tty.h"
#if (CHIP == M68000)
#include "staddr.h"
#include "stmfp.h"
#endif

/* Definitions used by the RS232 driver. */
#define	RS_BUF_SIZE		 256	/* output buffer per serial line */
#define SPARE                     16	/* leave room in buffer for echoes */
#define THRESHOLD                 20	/* # chars to accumulate before msg */

#if (CHIP != M68000)
#define PRIMARY                0x3F8	/* I/O port of primary RS232 */
#define SECONDARY              0x2F8	/* I/O port of secondary RS232 */

/* Constants relating to the 8250. */
#define	RS232_RATE_DIVISOR	   0	/* address of baud rate divisor reg */
#define	RS232_TRANSMIT_HOLDING	   0	/* address of transmitter holding reg*/
#define	RS232_RECEIVER_DATA_REG	   0	/* address of receiver data register */
#define	RS232_INTERRUPTS	   1	/* address of interrupt enable reg */
#define	RS232_INTERRUPT_ID_REG	   2	/* address of interrupt id register */
#define	RS232_LINE_CONTROL	   3	/* address of line control register */
#define	RS232_MODEM_CONTROL	   4	/* address of modem control register */
#define	RS232_LINE_STATUS	   5	/* address of line status register */
#define	RS232_MODEM_STATUS	   6	/* address of modem status register */
#define	LINE_CONTROLS		0x0B	/* odd parity,1 stop bit,8 data bits */
#define	MODEM_CONTROLS		0x0B	/* RTS & DTR */
#define	ADDRESS_DIVISOR		0x80	/* value to address divisor */
#define HOLDING_REG_EMPTY       0x20	/* transmitter holding reg empty */
#define	RS232_INTERRUPT_CLASSES	0x03	/* receiver Data Ready & xmt empty */
#define	UART_FREQ  	     115200L	/* UART timer frequency */
#endif

#define DEF_BAUD                1200	/* default baud rate */

/* Line control setting related constants. */
#define ODD			   0
#define	EVEN			   1
#define NONE			  -1
#define	PARITY_TYPE_SHIFT	   4	/* shift count for parity_type bit */
#define	STOP_BITS_SHIFT		   2	/* shift count for # stop_bits */
#define DATA_LEN                   8	/* how much to shift sg_mode for len */

#if (CHIP != M68000)
#define	PARITY_ON_OFF		0x08	/* position of parity bit in line reg*/

/* RS232 interrupt types. */
#define MODEM_STATUS            0x00	/* UART modem status change */
#define TRANSMITTER_READY	0x02	/* transmitter ready to accept data */
#define RECEIVER_READY		0x04	/* data received interrupt */
#define LINE_STATUS             0x06	/* UART line status change */
#define INT_TYPE_MASK		0x06	/* mask to mask out interrupt type */
#define	INT_PENDING		0x01	/* position of interrupt-pending bit */

/* Status register values. */
#define DATA_REGISTER_EMPTY	0x20	/* mask to see if data reg is empty */
#define DATA_RECEIVED		0x01	/* mask to see if data has arrived */
#endif

#if (CHIP == M68000)
#define SIAIN(c)	(c) = MFP->mf_udr
#define SIAOUT(c)	{lastchar = (c); MFP->mf_udr = lastchar;}
#endif

/* Global variables used by the RS232 driver. */
#if (CHIP != M68000)
PRIVATE int first_rs_write_int_seen = FALSE;
#endif

PRIVATE struct rs_struct{
  int rs_base;			/* 0x3F8 for primary, 0x2F8 secondary*/
				/* unused on ST */
  int rs_busy;			/* line is idle or not */
  int rs_left;			/* # chars left in buffer to output */
  char *rs_next;		/* pointer to next char to output */
  char rs_buf[RS_BUF_SIZE];	/* output buffer */
} rs_struct[NR_RS_LINES];

#if (CHIP == M68000)

PRIVATE int dummy;	/* to read error chars in */
PRIVATE int lastchar;	/* save last outputted char for retry */

PUBLIC  void rs_flush();
PUBLIC  void rs_out_char();
PUBLIC  void rs_sig();
PUBLIC  void init_rs232();
PUBLIC  void set_uart();
PRIVATE	void rs_read_int();
PRIVATE	void rs_write_int();
PRIVATE void rs_feed();
PRIVATE	void start_rs232();
PRIVATE	void serial_out();
PRIVATE void rs_expand();
PRIVATE	void config_rs232();

PUBLIC void
siaint(type)
int    type;	       /* interrupt type */
{
	register unsigned char  code;
	register struct tty_struct	*tp;
	int s = lock();

	switch (type & 0x00FF)
	{
		case 0x00:	       /* receive buffer full */
			rs_read_int(SERIAL1);
			break;
		case 0x01:	       /* receive error */
			printf("sia: receive error: status=%x\r\n", MFP->mf_rsr);
			MFP->mf_rsr &= R_ENA;
			SIAIN(dummy); /* discard char in case of overrun */
			break;
		case 0x02:	       /* transmit buffer empty */
			rs_write_int(SERIAL1);
			break;
		case 0x03:	       /* transmit error */
			code = MFP->mf_tsr;
			if (code & ~(T_ENA | T_UE | T_EMPTY))
			{
			    printf("sia: transmit error: status=%x\r\n", code);
			    SIAOUT(lastchar);	/* retry */
			}
			break;
	}
	restore(s);
}

#else
/*===========================================================================*
 *				rs232				 	     *
 *===========================================================================*/
PUBLIC void rs232(unit)
int unit;				/* which unit caused the interrupt */
{
/* When an RS232 interrupt occurs, mpx88.s catches it and calls rs232().
 * Because more than one interrupt condition can occur at the same
 * time, the conditions are presented in the interrupt-identification
 * register in priority order, we have to keep scanning until the 
 * interrupt-pending bit goes down.  Only one communications port is really
 * supported here because the other vector is used by the Ethernet.
 */

  int interrupt_type, t, old_state, val;
  struct rs_struct *rs;

  old_state = lock();
  rs = &rs_struct[unit - NR_CONS];
  while (TRUE) {
	port_in(rs->rs_base + RS232_INTERRUPT_ID_REG, &interrupt_type); 
	if ((interrupt_type & INT_PENDING) == 1) break;	/* 1 = no interrupt */
	t = interrupt_type & INT_TYPE_MASK;
	switch(t) {
	    case RECEIVER_READY:	/* a character has arrived */
		rs_read_int(unit);
		break;

	    case TRANSMITTER_READY:	/* a character has been output */
		rs_write_int(unit);
		break;

	    case LINE_STATUS:		/* line status event, (disabled) */
		port_in(rs_struct[unit-1].rs_base + RS232_LINE_STATUS, &val);
		printf("RS 232 line status event %x\n", val);
		break;

	    case MODEM_STATUS:		/* modem status event, (disabled) */
		port_in(rs_struct[unit-1].rs_base + RS232_MODEM_STATUS, &val);
		printf("RS 232 modem status event %x\n", val);
		break;
	}
  }
  restore(old_state);
}
#endif


/*===========================================================================*
 *				rs_read_int			 	     *
 *===========================================================================*/
PRIVATE	void rs_read_int(line)
int line;
{
  int val, k, base;

  base = rs_struct[line - NR_CONS].rs_base;

  /* Fetch the character from the RS232 hardware. */
#if (CHIP == M68000)
  SIAIN(val);
#else
  port_in(base + RS232_RECEIVER_DATA_REG, &val);
#endif

  /* Store the character in memory so the task can get at it later */
  if ((k = tty_buf_count(tty_driver_buf)) < tty_buf_max(tty_driver_buf)) {
	/* There is room to store this character, do it */
	k = k + k;			/* each entry contains two bytes */
	tty_driver_buf[k + 4] = val;	/* store the ascii code */
	tty_driver_buf[k + 5] = line;	/* tell wich line it came from */ 
	tty_buf_count(tty_driver_buf)++;		/* increment counter */

	if (tty_buf_count(tty_driver_buf) < THRESHOLD) {
		/* Don't send message.  Just accumulate.  Let clock do it. */
		INT_CTL_ENABLE;
		flush_flag++;
		return;
	}
	rs_flush();			/* send TTY task a message */
  } else {
	/* Too many character have been buffered. Discard excess */
	INT_CTL_ENABLE;
  }
}


/*===========================================================================*
 *				rs_flush	  		 	     *
 *===========================================================================*/
PUBLIC void rs_flush()
{
/* Flush the tty_driver_buf by sending a message to TTY.  This procedure can
 * be triggered locally, when a character arrives, or by the clock task.
 */
  int s = lock();

  /* Build and send the interrupt message */ 
  flush_flag = 0;
  if ((tty_buf_count(tty_driver_buf) == 0) && (output_done == 0)) return;	/* nothing to flush */
  interrupt(TTY);	/* send a message to the tty task */
  restore(s);
}


/*===========================================================================*
 *				rs_write_int	  		 	     *
 *===========================================================================*/
PRIVATE	void rs_write_int(line)
int line;
{
/* An output ready interrupt has occurred, or a write has been done to an idle
 * line.  In both cases, start the output.
 */

  int val;
  struct tty_struct *tp;
  struct rs_struct *rs;

#if (CHIP != M68000)
  if (first_rs_write_int_seen == FALSE) {
	first_rs_write_int_seen = TRUE;
	INT_CTL_ENABLE;
	return;
  }
#endif

  /* On the XT and clones, check for spurious write-completed interrupts. */
  rs = &rs_struct[line - NR_CONS];
#if (CHIP != M68000)
  port_in(rs->rs_base + RS232_LINE_STATUS, &val);
  if ( (val & HOLDING_REG_EMPTY) == 0) {
	INT_CTL_ENABLE;
	return;
  }
#endif

  /* If there are more characters in rs_buf, output the next one. */
  if (rs->rs_left > 0) {
	rs_feed(rs);			/* output the next char in rs_buf */
	INT_CTL_ENABLE;
	return;
  }

  /* The current rs_buf is finished.  See if the complete user buf is done. */
  tp = &tty_struct[line];
  rs->rs_busy = FALSE;
  rs->rs_next = &rs->rs_buf[0];
  if (tp->tty_outleft > 0) {
	serial_out(tp);			/* copy the next chunk to rs_buf */
	INT_CTL_ENABLE;
	return;
  }

  /* The current output buffer is finished.  Send a message to the tty task. */
  if (tp->tty_waiting == WAITING) {
	tp->tty_waiting = COMPLETED;	/* mark this line as done */
	output_done++;			/* # of RS232 lines now completed */
	interrupt(TTY);	/* send the message to the tty task */
  } else {
	INT_CTL_ENABLE;
  }
}


/*===========================================================================*
 *				rs_feed		  		 	     *
 *===========================================================================*/
PRIVATE void rs_feed(rs)
struct rs_struct *rs;			/* which line */
{
/* If there is more output queued, output the next character. */

  char byte;

  if (rs->rs_left > 0) {
#if (CHIP == M68000)
	SIAOUT(*rs->rs_next);
#else
	byte = *rs->rs_next;
	port_out(rs->rs_base + RS232_TRANSMIT_HOLDING, (int) byte);
#endif
	rs->rs_next++;
	rs->rs_left--;			/* one char done */
  }
}


/*===========================================================================*
 *				start_rs232				     * 
 *===========================================================================*/
PRIVATE	void start_rs232(tp)
struct tty_struct *tp;			/* which tty */
{
  int old_state;

  old_state = lock();
  serial_out(tp);
  restore(old_state);
}	


/*===========================================================================*
 *				serial_out				     * 
 *===========================================================================*/
PRIVATE	void serial_out(tp)
register struct tty_struct *tp;	/* tells which terminal is to be used */
{
/* Copy as much data as possible to the output queue, then start I/O if
 * necessary.
 */
  int bytes = 0;
  int line;
  char c, *limit;
  register struct rs_struct *rs;
#if (CHIP == M68000)
  char *charptr = (char *)tp->tty_phys;
#else
  unsigned short segment, offset, offset1;
  extern char get_byte();
#endif

  if (tp->tty_inhibited != RUNNING) return;

  line = tp - &tty_struct[0];		/* line is index into tty_struct */
  rs = &rs_struct[line - NR_CONS];	/* 0 to NR_CONS - 1 are consoles */
  /* Copy bytes from user space to rs_buf. */
  limit = &rs->rs_buf[RS_BUF_SIZE - SPARE];
#if (CHIP != M68000)
  segment = (tp->tty_phys >> 4) & WORD_MASK;
  offset = tp->tty_phys & OFF_MASK;
  offset1 = offset;
#endif

  /* While there is still data to output and there is still room in buf, copy*/
  while (tp->tty_outleft > 0 && (rs->rs_next + rs->rs_left) < limit) {
#if (CHIP == M68000)
	c = *charptr++;
	bytes++;
#else
	c = get_byte(segment, offset);	/* fetch 1 byte */
	offset++;
#endif
	tp->tty_outleft--;
	if (c < ' ') {
		rs_expand(tp, rs, c);	/* insert the char in rs_buf */
	} else {
		*(rs->rs_next + rs->rs_left) = c;	/* avoid proc call */
		rs->rs_left++;
		tp->tty_column++;
	}
  }

#if (CHIP != M68000)
  bytes = offset - offset1;		/* does not include '\r' or tab exp */
#endif
  tp->tty_cum += bytes;			/* update cumulative total */
  tp->tty_phys += bytes;		/* next time, take different bytes */

  if (!rs->rs_busy) {			/* is the line idle? */
	rs->rs_busy = TRUE;		/* if so, mark it as busy */
	rs_feed(rs);			/* and start it going */
  }
}


/*===========================================================================*
 *				rs_out_char				     *
 *===========================================================================*/
PUBLIC void rs_out_char(tp, c)
register struct tty_struct *tp;	/* pointer to tty struct */
char c;				/* character to be output */
{
/* Output a character on an RS232 line. */

  int line, old_state;
  register struct rs_struct *rs;

  /* See if there is room to store a character, and if so, do it. */
  old_state = lock();
  line = tp - tty_struct;
  rs = &rs_struct[line - NR_CONS];
  if (rs->rs_next + rs->rs_left == &rs->rs_buf[RS_BUF_SIZE]) return;  /*full */
  rs_expand(tp, rs, c);

  if (!rs->rs_busy) {		/* if terminal line is idle, start it */
	rs->rs_busy = TRUE;
	rs_feed(rs);
  }
  restore(old_state);
}


/*===========================================================================*
 *				rs_expand				     *
 *===========================================================================*/
PRIVATE void rs_expand(tp, rs, c)
register struct tty_struct *tp;	/* pointer to tty struct */
register struct rs_struct *rs;	/* pointer to rs struct */
char c;				/* character to be output */
{
/* Some characters output to RS-232 lines need special processing, such as
 * tab expansion and LF to CR+CF mapping.  These things are done here.
 */

  int mode, count, count1;
  char *deposit;		/* where to deposit the next character */

  mode = tp->tty_mode;
  deposit = rs->rs_next + rs->rs_left;

  switch(c) {
	case '\b':
		tp->tty_column -= 2;	/* it is incremented later */
		break;

	case '\r':
		tp->tty_column = -1;	/* it is incremented below */
		break;

	case '\n':
		/* Check to see if LF has to be mapped to CR + LF. */
		if (mode & CRMOD) {
			*deposit++ = '\r';
			rs->rs_left++;
			tp->tty_column = -1;
		}
		break;

	case '\t':
	 	count = 8 - (tp->tty_column % 8);	/* # spaces */
		count1 = count;
		if ((mode & XTABS) == XTABS) {
			/* Tabs must be expanded. */
			while (count1--) *deposit++ = ' ';
			rs->rs_left += count;
			tp->tty_column += count;
			return;
		} else {
			/* Tabs are sent to the terminal hardware. */
			tp->tty_column += count - 1;
		}
  }

  /* Output character and update counters. */
  *deposit = c;			/* copy character to rs_buf */
  rs->rs_left++;		/* there is one more character to print */
  tp->tty_column++;		/* update column */
}


/*===========================================================================*
 *				tty_o_done				     *
 *===========================================================================*/
PUBLIC int tty_o_done()
{
/* A write request on an RS232 line has completed.  Send FS a message. */

  int replyee, caller, old_state;
  struct tty_struct *tp;

  /* See if any of the RS232 lines are complete.  Send at most one message. */
  old_state = lock();
  for (tp = &tty_struct[NR_CONS]; tp < &tty_struct[NR_CONS+NR_RS_LINES]; tp++){
	if (tp->tty_waiting == COMPLETED) {
		replyee = (int) tp->tty_otcaller;
		caller = (int) tp->tty_outproc;
		tty_reply(REVIVE, replyee, caller, tp->tty_cum, 0L, 0L);
		tp->tty_waiting = NOT_WAITING;
		output_done--;
		restore(old_state);
#if (CHIP == M68000)
		(proc_addr(tp->tty_outproc))->p_physio = 0;
#endif
		return(1);
	}
  }
  restore(old_state);
  return(0);
}

/*===========================================================================*
 *				rs_sig					     * 
 *===========================================================================*/
PUBLIC void rs_sig(tp)
struct tty_struct *tp;
{
/* Called when a DEL character is typed.  It resets the output. */

  int line;
  struct rs_struct *rs;

  line = tp - tty_struct;
  rs = &rs_struct[line - NR_CONS];
  rs->rs_left = 0;
  rs->rs_busy = FALSE;
  rs->rs_next = &rs->rs_buf[0];
}


/*===========================================================================*
 *				init_rs232				     * 
 *===========================================================================*/
PUBLIC void init_rs232()
{
  register struct tty_struct *tp;
  register struct rs_struct *rs;
  int line;

  for (tp = &tty_struct[NR_CONS]; tp < &tty_struct[NR_CONS+NR_RS_LINES]; tp++){
	tp->tty_inhead = tp->tty_inqueue;
	tp->tty_intail = tp->tty_inqueue;
/*	tp->tty_mode = CRMOD | XTABS | ECHO; */
	tp->tty_mode = RAW | BITS8;
	tp->tty_devstart = (int (*)())start_rs232;
	tp->tty_erase	= ERASE_CHAR;
	tp->tty_kill	= KILL_CHAR;
	tp->tty_intr	= INTR_CHAR;
	tp->tty_quit	= QUIT_CHAR;
	tp->tty_xon	= XON_CHAR;
	tp->tty_xoff	= XOFF_CHAR;
	tp->tty_eof	= EOT_CHAR;
	tp->tty_makebreak = ONE_INT;	/* RS232 only interrupts once/char */
  }

#if (CHIP == M68000)
  MFP->mf_scr	= 0x00;
  MFP->mf_tcdcr |= 0x01;
  MFP->mf_rsr	= R_ENA;
  MFP->mf_tsr	= T_ENA;
#else
#if NR_RS_LINES > 0
  rs_struct[0].rs_base = PRIMARY;
#endif
#if NR_RS_LINES > 1
  rs_struct[1].rs_base = SECONDARY;
#endif
#endif

  for (rs = &rs_struct[0]; rs < &rs_struct[NR_RS_LINES]; rs++) {
	line = rs - rs_struct + NR_CONS;
	rs->rs_next = & rs->rs_buf[0];
	rs->rs_left = 0;
	rs->rs_busy = FALSE;
	config_rs232(line, DEF_BAUD, DEF_BAUD, NONE, 1, 8);    /* set params */
#if (CHIP != M68000)
	port_out(rs->rs_base + RS232_MODEM_CONTROL, MODEM_CONTROLS);
	port_out(rs->rs_base + RS232_INTERRUPTS, RS232_INTERRUPT_CLASSES);
#endif
  }
}


/*===========================================================================*
 *				set_uart			 	     *
 *===========================================================================*/
PUBLIC void set_uart(line, mode, speeds)
int line;			/* which line number (>= NR_CONS) */
int mode;			/* sgtty.h sg_mode word */
int speeds;			/* low byte is input speed, next is output */
{
/* Set the UART parameters. */
  int in_baud, out_baud, parity, stop_bits, data_bits;

  in_baud = 100 * (speeds & BYTE);
  if (in_baud == 100) in_baud = 110;
  out_baud = 100 * ((speeds >> 8) & BYTE);
  if (out_baud == 100) out_baud = 110;
  parity = NONE;
  if (mode & ODDP) parity = ODD;
  if (mode & EVENP) parity = EVEN;
  stop_bits = (in_baud == 110 ? 2 : 1);		/* not quite cricket */
  data_bits = 5 + ((mode >> DATA_LEN) & 03);
  config_rs232(line, in_baud, out_baud, parity, stop_bits, data_bits);
}


/*===========================================================================*
 *				config_rs232			 	     *
 *===========================================================================*/
PRIVATE	void config_rs232(line, in_baud, out_baud, parity, stop_bits, data_bits)
int line;			/* which tty */
int in_baud;			/* input speed: 110, 300, 1200, etc. */
int out_baud;			/* output speed: 110, 300, 1200, etc. */
int parity;			/* EVEN, ODD, or NONE */
int stop_bits;			/* 2 (110 baud) or 1 (other speeds) */
int data_bits;			/* 5, 6, 7, or 8 */
{
#if (CHIP == M68000)
  unsigned char mode = U_Q16; /* 1 stop bit; divide by 16 */
  switch (stop_bits)
  {
  case 1:
  	mode |= U_ST1;
	break;
  case 2:
  	mode |= U_ST2;
	break;
  }
  switch (data_bits)
  {
  case 5:
  	mode |= U_D5;
	break;
  case 6:
  	mode |= U_D6;
	break;
  case 7:
  	mode |= U_D7;
	break;
  case 8:
  	mode |= U_D8;
	break;
  }
  switch (parity)
  {
  case ODD:
  	mode |= U_PAR;
	break;
  case EVEN:
  	mode |= U_PAR | U_EVEN;
	break;
  case NONE:
	break;
  }
  MFP->mf_ucr = mode;
  
  switch(in_baud/100)
  {
    case B110 : MFP->mf_tddr = 0xaf; break;
    case B300 : MFP->mf_tddr = 0x40; break;
    case B1200: MFP->mf_tddr = 0x10; break;
    case B2400: MFP->mf_tddr = 0x08; break;
    case B4800: MFP->mf_tddr = 0x04; break;
    case B9600: MFP->mf_tddr = 0x02; break;
    default:    printf("sia line %d: %d speed unknown", line, in_baud);
		return;
  }
  tty_struct[line].tty_speed = ((out_baud/100) << 8) | (in_baud/100);

#else
/* Set various line control parameters for RS232 I/O.
 * If DataBits == 5 and StopBits == 2, UART will generate 1.5 stop bits
 * The 8250 can't handle split speed, but we have propagated both speeds
 * anyway for the benefit of future UART chips.
 */
  int line_controls = 0, base, freq;

  base = rs_struct[line - NR_CONS].rs_base;

  /* First tell line control register to address baud rate divisor */
  port_out(base + RS232_LINE_CONTROL, ADDRESS_DIVISOR);

  /* Now set the baud rate. */
  if (in_baud < 50) in_baud = DEF_BAUD;		/* prevent divide overflow */
  if (out_baud < 50) out_baud = DEF_BAUD;	/* prevent divide overflow */
  freq = (int) (UART_FREQ / in_baud);		/* UART can't hack 2 speeds  */
  port_out(base + RS232_RATE_DIVISOR, freq & BYTE);
  port_out(base + RS232_RATE_DIVISOR+1, (freq >> 8) & BYTE);
  tty_struct[line].tty_speed = ((out_baud/100) << 8) | (in_baud/100);

  /* Put parity_type bits in line_controls */
  if (parity != NONE) {
	line_controls |= PARITY_ON_OFF;
	line_controls |= (parity << PARITY_TYPE_SHIFT);
  }

  /* Put #stop_bits bits in line_controls */
  if (stop_bits == 1 || stop_bits == 2)
	line_controls |= (stop_bits - 1) << STOP_BITS_SHIFT;

  /* Put #data_bits bits in line_controls */
  if (data_bits >=5 && data_bits <= 8)
	line_controls |= (data_bits - 5);

  port_out(base + RS232_LINE_CONTROL, line_controls);
#endif
}
