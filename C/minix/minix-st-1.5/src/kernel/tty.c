/* This file contains the terminal driver, both for the IBM console and regular
 * ASCII terminals.  It is split into two sections, a device-independent part
 * and a device-dependent part.  The device-independent part accepts
 * characters to be printed from programs and queues them in a standard way
 * for device-dependent output.  It also accepts input and queues it for
 * programs. This file contains 2 main entry points: tty_task() and keyboard().
 * When a key is struck on a terminal, an interrupt to an assembly language
 * routine is generated.  This routine saves the machine state and registers
 * and calls keyboard(), which enters the character in an internal table, and
 * then sends a message to the terminal task.  The main program of the terminal
 * task is tty_task(). It accepts not only messages about typed input, but
 * also requests to read and write from terminals, etc. 
 *
 * The device-dependent part interfaces with the IBM console and ASCII
 * terminals.  The IBM keyboard is unusual in that keystrokes yield key numbers
 * rather than ASCII codes, and furthermore, an interrupt is generated when a
 * key is depressed and again when it is released.  The IBM display is memory
 * mapped, so outputting characters such as line feed, backspace and bell are
 * tricky.
 *
 * The valid messages and their parameters are:
 *
 *   HARD_INT:     a character has been typed (character arrived interrupt)
 *   TTY_READ:     a process wants to read from a terminal
 *   TTY_WRITE:    a process wants to write on a terminal
 *   TTY_IOCTL:    a process wants to change a terminal's parameters
 *   TTY_SETPGRP:  indicate a change in a control terminal
 *   CANCEL:       terminate a previous incomplete system call immediately
 *
 *    m_type      TTY_LINE   PROC_NR    COUNT   TTY_SPEK  TTY_FLAGS  ADDRESS
 * |-------------+---------+---------+---------+---------+---------+---------|
 * | HARD_INT    |minor dev|         |         |         |         |         |
 * |-------------+---------+---------+---------+---------+---------+---------|
 * | TTY_READ    |minor dev| proc nr |  count  |         |         | buf ptr |
 * |-------------+---------+---------+---------+---------+---------+---------|
 * | TTY_WRITE   |minor dev| proc nr |  count  |         |         | buf ptr |
 * |-------------+---------+---------+---------+---------+---------+---------|
 * | TTY_IOCTL   |minor dev| proc nr |func code|erase etc|  flags  |         |
 * |-------------+---------+---------+---------+---------+---------+---------|
 * | TTY_SETPGRP |minor dev| proc nr |         |         |         |         |
 * |-------------+---------+---------+---------+---------+---------+---------
 * | CANCEL      |minor dev| proc nr |         |         |         |         |
 * ---------------------------------------------------------------------------
 */

#include "kernel.h"
#include <signal.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include <sgtty.h>
#include "proc.h"
#include "tty.h"
#if (CHIP == INTEL)
#include "ttymaps.h"
#endif

PUBLIC  void finish();
PUBLIC  void tty_reply();
PUBLIC  void sigchar();
PRIVATE void do_int();
PRIVATE void charint();
PRIVATE void in_char();
PRIVATE void echo();
PRIVATE void do_read();
PRIVATE void do_write();
PRIVATE void do_ioctl();
PRIVATE void do_setpgrp();
PRIVATE void do_cancel();

/*===========================================================================*
 *				tty_task				     *
 *===========================================================================*/
PUBLIC void tty_task()
{
/* Main routine of the terminal task. */

  message tty_mess;		/* buffer for all incoming messages */
  register struct tty_struct *tp;

  output_done = 0;
  tty_init();			/* initialize */
  init_rs232();
  while (TRUE) {
	receive(ANY, &tty_mess);
	tp = &tty_struct[tty_mess.TTY_LINE];
	switch(tty_mess.m_type) {
	    case HARD_INT:	do_int();			break;
	    case TTY_READ:	do_read(tp, &tty_mess);		break;
	    case TTY_WRITE:	do_write(tp, &tty_mess);	break;
	    case TTY_IOCTL:	do_ioctl(tp, &tty_mess);	break;
	    case TTY_SETPGRP:   do_setpgrp(tp, &tty_mess);	break;
	    case CANCEL:	do_cancel(tp, &tty_mess);	break;
	    default:		tty_reply(TASK_REPLY, tty_mess.m_source, 
					tty_mess.PROC_NR, EINVAL, 0L, 0L);
	}
  }
}


/*===========================================================================*
 *				do_int					     *
 *===========================================================================*/
PRIVATE void do_int()
{
/* The TTY task can generate two kinds of interrupts:
 *	- a character has been typed on the console or an RS232 line
 *	- an RS232 line has completed a write request (on behalf of a user)
 * If either interrupt happens and the TTY task is idle, the task gets the
 * interrupt message immediately and processes it.  However, if the TTY
 * task is busy, a bit is set in 'busy_map' and the message pointer stored.
 * If multiple messages happen, the bit is only set once.  No input data is
 * lost even if this happens because all the input messages say is that there
 * is some input.  The actual input is in the tty_driver_buf array, so losing
 * a message just means that when the one interrupt-generated message is given
 * to the TTY task, it will find multiple characters in tty_driver_buf.
 *
 * The introduction of RS232 lines has complicated this situation somewhat. Now
 * a message can mean that some RS232 line has finished transmitting all the
 * output given to it.  If a character is typed at the instant an RS232 line
 * finishes, one of the two messages may be overwritten because MINIX only
 * provides single buffering for interrupt messages (in proc.c).To avoid losing
 * information, whenever an RS232 line finishes, the flag tty_waiting is set
 * to COMPLETED and kept that way until its completion is processed and a 
 * message sent to FS saying that output is done.  The number of RS232 lines in
 * COMPLETED state is kept in output_done, which is checked on each interrupt,
 * so that a lost HARD_INT line completion interrupt will be quickly
 * recovered.
 *
 * In short, when this procedure is called, it can check for RS232 line done
 * by inspecting output_done and it can check for characters in the input
 * buffer by inspecting tty_driver_buf[0].  Thus losing a message to the TTY
 * task is not serious because the underlying conditions are explicitly checked
 * for on each interrupt.
 */

  /* First check to see if any RS232 lines have completed. */
  if (output_done > 0) {
	/* If a message is sent to FS for RS232 done, don't process any input
	 * characters now for fear of sending a second message to FS, which 
	 * would be lost.
	 */
	if (tty_o_done()) {
		return;
	}
  }
  charint();			/* check for input characters */
}


/*===========================================================================*
 *				charint					     *
 *===========================================================================*/
PRIVATE void charint()
{
/* A character has been typed.  If a character is typed and the tty task is
 * not able to service it immediately, the character is accumulated within
 * the tty driver.  Thus multiple chars may be accumulated.  A single message
 * to the tty task may have to process several characters.
 */

  int m, n, count, replyee, caller, old_state;
  char *ptr, *copy_ptr, ch;
  struct tty_struct *tp;

  old_state = lock();
  ptr = tty_driver_buf;		/* pointer to accumulated char array */
  copy_ptr = tty_copy_buf;	/* ptr to shadow array where chars copied */
  n = tty_buf_count(ptr);	/* how many chars have been accumulated */
  count = n;			/* save the character count */
  n = n + n;			/* each char occupies 2 bytes */
  ptr += 4;			/* skip count field at start of array */
  while (n-- > 0)
	*copy_ptr++ = *ptr++;	/* copy the array to safety */
  ptr = tty_driver_buf;
  tty_buf_count(ptr) = 0;		/* accumulation count set to 0 */
  restore(old_state);

  /* Loop on the accumulated characters, processing each in turn. */
  if (count == 0) return;	/* on HARD_INT interrupt, count might be 0 */
  copy_ptr = tty_copy_buf;
  while (count-- > 0) {
	ch = *copy_ptr++;	/* get the character typed */
	n = *copy_ptr++;	/* get the line number it came in on */
	in_char(n, ch);		/* queue the char and echo it */

	/* See if a previously blocked reader can now be satisfied. */
	tp = &tty_struct[n];	/* pointer to struct for this character */
	if (tp->tty_inleft > 0 ) {	/* does anybody want input? */
		m = tp->tty_mode & (CBREAK | RAW);
		if (tp->tty_lfct > 0 || (m != 0 && tp->tty_incount > 0)) {
			m = rd_chars(tp);

			/* Tell hanging reader that chars have arrived. */
			replyee = (int) tp->tty_incaller;
			caller = (int) tp->tty_inproc;
			tty_reply(REVIVE, replyee, caller, m, 0L, 0L);
		}
	}
  }
}


/*===========================================================================*
 *				in_char					     *
 *===========================================================================*/
PRIVATE void in_char(line, ch)
int line;			/* line number on which char arrived */
char ch;			/* scan code for character that arrived */
{
/* A character has just been typed in.  Process, save, and echo it. */

  register struct tty_struct *tp;
  int mode, sig, scode, c;
#if (CHIP != M68000)
  int make_break();
#endif

  scode = ch;			/* save the scan code */
  tp = &tty_struct[line];	/* set 'tp' to point to proper struct */

  /* Function keys are temporarily being used for debug dumps. */
#if (CHIP == M68000)
  if (line == OPERATOR && ch >= F1 && ch <= F10) { /* Check for function keys */
#else
  if (line == 0 && ch >= F1 && ch <= F10) {	/* Check for function keys */
#endif
	func_key(ch);		/* process function key */
	return;
  }
  if (tp->tty_incount >= TTY_IN_BYTES) return;	/* no room, discard char */
  mode = tp->tty_mode & (RAW | CBREAK);
#if (CHIP != M68000)
  if (tp->tty_makebreak == TWO_INTS) {
	c = make_break(ch);	/* console give 2 ints/ch */
	if (c == -1) return;
	ch = c;
  }
  else
#endif
	if (mode != RAW) ch &= 0177;	/* 7-bit chars except in raw mode */

  /* Processing for COOKED and CBREAK mode contains special checks. */
  if (mode == COOKED || mode == CBREAK) {
	/* Handle erase, kill and escape processing. */
	if (mode == COOKED) {
		/* First erase processing (rub out of last character). */
		if (ch == tp->tty_erase && tp->tty_escaped == NOT_ESCAPED) {
			if (chuck(tp) != -1) {	/* remove last char entered */
				echo(tp, '\b');	/* remove it from the screen */
				echo(tp, ' ');
				echo(tp, '\b');
			}
			return;
		}

		/* Now do kill processing (remove current line). */
		if (ch == tp->tty_kill && tp->tty_escaped == NOT_ESCAPED) {
			while( chuck(tp) == OK) /* keep looping */ ;
			echo(tp, tp->tty_kill);
			echo (tp, '\n');
			return;
		}

		/* Handle EOT and the escape symbol (backslash). */
		if (tp->tty_escaped == NOT_ESCAPED) {
			/* Normal case: previous char was not backslash. */
			if (ch == '\\') {
				/* An escaped symbol has just been typed. */
				tp->tty_escaped = ESCAPED;
				echo(tp, ch);
				return;	/* do not store the '\' */
			}
			/* CTRL-D means end-of-file, unless it is escaped. It
			 * is stored in the text as MARKER, and counts as a
			 * line feed in terms of knowing whether a full line
			 * has been typed already.
			 */
			if (ch == tp->tty_eof) {
				ch = MARKER;
				tp->tty_lfct++; /* counts as LF */
			}
		} else {
			/* Previous character was backslash. */
			tp->tty_escaped = NOT_ESCAPED;	/* turn escaping off */
			if (ch != tp->tty_erase && ch != tp->tty_kill &&
						   ch != tp->tty_eof) {
				/* Store the escape previously skipped over */
				*tp->tty_inhead++ = '\\';
				tp->tty_incount++;
				if (tp->tty_inhead ==
						&tp->tty_inqueue[TTY_IN_BYTES])
					tp->tty_inhead = tp->tty_inqueue;
			}
		}
	}
	/* Both COOKED and CBREAK modes come here; first map CR to LF. */
	if (ch == '\r' && (tp->tty_mode & CRMOD)) ch = '\n';

	/* Check for interrupt and quit characters. */
	if (ch == tp->tty_intr || ch == tp->tty_quit) {
		sig = (ch == tp->tty_intr ? SIGINT : SIGQUIT);
		sigchar(tp, sig);
		return;
	}

	/* Check for and process CTRL-S (terminal stop). */
	if (ch == tp->tty_xoff) {
		tp->tty_inhibited = STOPPED;
		return;
	}

	/* Check for and process CTRL-Q (terminal start). */
	if (tp->tty_inhibited == STOPPED) {
		tp->tty_inhibited = RUNNING;
		(*tp->tty_devstart)(tp);	/* resume output */
		return;
	}
  }

  /* All 3 modes come here. */
  if (ch == '\n') tp->tty_lfct++;	/* count line feeds */

#if (CHIP != M68000)
/* the ATARI ST deals with this in stkbd.c */
  /* The numeric pad generates ASCII escape sequences: ESC [ letter */
  if (line == 0 && scode >= SCODE1 && scode <= SCODE2 && 
		shift1 == 0 && shift2 == 0 && numlock == 0) {
	/* This key is to generate a three-character escape sequence. */
	*tp->tty_inhead++ = ESC; /* put ESC in the input queue */
	if (tp->tty_inhead == &tp->tty_inqueue[TTY_IN_BYTES])
		tp->tty_inhead = tp->tty_inqueue;      /* handle wraparound */
	tp->tty_incount++;
	echo(tp, 'E');
	*tp->tty_inhead++ = BRACKET; /* put ESC in the input queue */
	if (tp->tty_inhead == &tp->tty_inqueue[TTY_IN_BYTES])
		tp->tty_inhead = tp->tty_inqueue;      /* handle wraparound */
	tp->tty_incount++;
	echo(tp, BRACKET);
	ch = scode_map[scode-SCODE1];	/* generate the letter */
  }
#endif

  *tp->tty_inhead++ = ch;	/* save the character in the input queue */
  if (tp->tty_inhead == &tp->tty_inqueue[TTY_IN_BYTES])
	tp->tty_inhead = tp->tty_inqueue;	/* handle wraparound */
  tp->tty_incount++;
  echo(tp, ch);
}


#if (CHIP == INTEL)
/*===========================================================================*
 *				make_break				     *
 *===========================================================================*/
PRIVATE int make_break(ch)
char ch;			/* scan code of key just struck or released */
{
/* This routine can handle keyboards that interrupt only on key depression,
 * as well as keyboards that interrupt on key depression and key release.
 * For efficiency, the interrupt routine filters out most key releases.
 */

  int c, make, code;

  c = ch & 0177;		/* high-order bit set on key release */
  make = (ch & 0200 ? 0 : 1);	/* 1 when key depressed, 0 when key released */

  if (alt && keyb_type == DUTCH_EXT) 
	code = alt_c[c];
  else 
	code = (shift1 || shift2 ? sh[c] : unsh[c]);

  if (control && c < TOP_ROW) code = sh[c];	/* CTRL-(top row) */
  if (numlock && c > 70 && c < 0x56)
	code = (shift1 || shift2 ? unsh[c] : sh[c]);

  code &= BYTE;
  if (code < 0200 || code >= 0206) {
	/* Ordinary key, i.e. not shift, control, alt, etc. */
	if (capslock)
		if (code >= 'A' && code <= 'Z')
			code += 'a' - 'A';
		else if (code >= 'a' && code <= 'z')
			code -= 'a' - 'A';
	if (alt && keyb_type != DUTCH_EXT) code |= 0200;  /* alt ORs in 0200 */
	if (control) code &= 037;
	if (make == 0) code = -1;	/* key release */
	return(code);
  }

  /* Table entries 0200 - 0206 denote special actions. */
  switch(code - 0200) {
    case 0:	shift1 = make;		break;	/* shift key on left */
    case 1:	shift2 = make;		break;	/* shift key on right */
    case 2:	control = make;		break;	/* control */
    case 3:	alt = make;		break;	/* alt key */
    case 4:	if (make && caps_off) {
			capslock = 1 - capslock;
			set_leds();
		}
		caps_off = 1 - make;
		break;	/* caps lock */
    case 5:	if (make && num_off) {
			numlock  = 1 - numlock;
			set_leds();
		}
		num_off = 1 - make;
		break;	/* num lock */
  }
  return(-1);
}
#endif


/*===========================================================================*
 *				echo					     *
 *===========================================================================*/
PRIVATE void echo(tp, c)
register struct tty_struct *tp;	/* terminal on which to echo */
register char c;		/* character to echo */
{
/* Echo a character on the terminal. */

  if ( (tp->tty_mode & ECHO) == 0) return;	/* if no echoing, don't echo */
/* MARKER is meaningful only in cooked mode */
  if (c != MARKER || tp->tty_mode & (CBREAK | RAW)) {
	if (tp - tty_struct < NR_CONS)
	{
#if (CHIP == M68000)
		vducursor(0);
#endif
		out_char(tp, c);	/* echo to console */
#if (CHIP == M68000)
		vducursor(1);
#endif
	}
	else
		rs_out_char(tp, c);	/* echo to RS232 line */
  }
  flush(tp);			/* force character out onto the screen */
}


/*===========================================================================*
 *				chuck					     *
 *===========================================================================*/
PRIVATE int chuck(tp)
register struct tty_struct *tp;	/* from which tty should chars be removed */
{
/* Delete one character from the input queue.  Used for erase and kill. */

  char *prev;

  /* If input queue is empty, don't delete anything. */
  if (tp->tty_incount == 0) return(-1);

  /* Don't delete '\n' or '\r'. */
  prev = (tp->tty_inhead != tp->tty_inqueue ? tp->tty_inhead - 1 :
					     &tp->tty_inqueue[TTY_IN_BYTES-1]);
  if (*prev == '\n' || *prev == '\r') return(-1);
  tp->tty_inhead = prev;
  tp->tty_incount--;
  return(OK);			/* char erasure was possible */
}


/*===========================================================================*
 *				do_read					     *
 *===========================================================================*/
PRIVATE void do_read(tp, m_ptr)
register struct tty_struct *tp;	/* pointer to tty struct */
message *m_ptr;			/* pointer to message sent to the task */
{
/* A process wants to read from a terminal. */

  int code, caller;


  if (tp->tty_inleft > 0) {	/* if someone else is hanging, give up */
	tty_reply(TASK_REPLY, m_ptr->m_source, m_ptr->PROC_NR, EIO, 0L, 0L);
	return;
  }

  /* Copy information from the message to the tty struct. */
  tp->tty_incaller = m_ptr->m_source;
  tp->tty_inproc = m_ptr->PROC_NR;
  tp->tty_in_vir = m_ptr->ADDRESS;
  tp->tty_inleft = m_ptr->COUNT;

  /* Try to get chars.  This call either gets enough, or gets nothing. */
  code = rd_chars(tp);

  caller = (int) tp->tty_inproc;
  tty_reply(TASK_REPLY, m_ptr->m_source, caller, code, 0L, 0L);
}


/*===========================================================================*
 *				rd_chars				     *
 *===========================================================================*/
PRIVATE int rd_chars(tp)
register struct tty_struct *tp;	/* pointer to terminal to read from */
{
/* A process wants to read from a terminal.  First check if enough data is
 * available. If so, pass it to the user.  If not, send FS a message telling
 * it to suspend the user.  When enough data arrives later, the tty driver
 * copies it to the user space directly and notifies FS with a message.
 */

  int cooked, ct, user_ct, buf_ct, cum, enough, eot_seen;
  vir_bytes in_vir, left;
  phys_bytes user_phys, tty_phys;
  char ch, *tty_ptr;
  struct proc *rp;

  cooked = ( (tp->tty_mode & (RAW | CBREAK)) ? 0 : 1);	/* 1 iff COOKED mode */
  if (tp->tty_incount == 0 || (cooked && tp->tty_lfct == 0)) return(SUSPEND);
  rp = proc_addr(tp->tty_inproc);
  in_vir = (vir_bytes) tp-> tty_in_vir;
  left = (vir_bytes) tp->tty_inleft;
  if ( (user_phys = umap(rp, D, in_vir, left)) == 0) return(E_BAD_ADDR);
  tty_phys = umap(proc_addr(TTY), D, (vir_bytes) tty_buf, TTY_BUF_SIZE);
  cum = 0;
  enough = 0;
  eot_seen = 0;

  /* The outer loop iterates on buffers, one buffer load per iteration. */
  while (tp->tty_inleft > 0) {
	buf_ct = MIN(tp->tty_inleft, tp->tty_incount);
	buf_ct = MIN(buf_ct, TTY_BUF_SIZE);
	ct = 0;
	tty_ptr = tty_buf;

	/* The inner loop fills one buffer. */
	while(buf_ct-- > 0) {
		ch = *tp->tty_intail++;
		if (tp->tty_intail == &tp->tty_inqueue[TTY_IN_BYTES])
			tp->tty_intail = tp->tty_inqueue;
		*tty_ptr++ = ch;
		ct++;
		if (ch == '\n' || ch == MARKER && cooked) {
			tp->tty_lfct--;
			if (ch == MARKER) eot_seen++;
			enough++;	/* exit loop */
			if (cooked) break;	/* only provide 1 line */
		}
	}

	/* Copy one buffer to user space.  Be careful about CTRL-D.  In cooked
	 * mode it is not transmitted to user programs, and is not counted as
	 * a character as far as the count goes, but it does occupy space in 
	 * the driver's tables and must be counted there.
	 */
	user_ct = (eot_seen ? ct - 1 : ct);	/* bytes to copy to user */
	phys_copy(tty_phys, user_phys, (phys_bytes) user_ct);
	user_phys += user_ct;
	cum += user_ct;
	tp->tty_inleft -= ct;
	tp->tty_incount -= ct;
	if (tp->tty_incount == 0 || enough) break;
  }

  tp->tty_inleft = 0;
  return(cum);
}


/*===========================================================================*
 *				finish					     *
 *===========================================================================*/
PUBLIC void finish(tp, code)
register struct tty_struct *tp;	/* pointer to tty struct */
int code;			/* reply code */
{
/* A command has terminated (possibly due to DEL).  Tell caller. */

  int line, result, replyee, caller;

  tp->tty_rwords = 0;
  tp->tty_outleft = 0;
#if (CHIP == M68000)
  (proc_addr(tp->tty_outproc))->p_physio = 0;	/* enable (un)shadowing */
#endif
  if (tp->tty_waiting == NOT_WAITING) return;
  line = tp - tty_struct;
  result = (line < NR_CONS ? TASK_REPLY : REVIVE);
  replyee = (int) tp->tty_otcaller;
  caller = (int) tp->tty_outproc;
  tty_reply(result, replyee, caller, code, 0L, 0L);
  tp->tty_waiting = NOT_WAITING;
}


/*===========================================================================*
 *				do_write				     *
 *===========================================================================*/
PRIVATE void do_write(tp, m_ptr)
register struct tty_struct *tp;	/* pointer to tty struct */
message *m_ptr;			/* pointer to message sent to the task */
{
/* A process wants to write on a terminal. */

  vir_bytes out_vir, out_left;
  struct proc *rp;
  int caller,replyee;

  /* If the slot is already in use, better return an error than mess it up. */
  if (tp->tty_outleft > 0) {	/* if someone else is hanging, give up */
	tty_reply(TASK_REPLY, m_ptr->m_source, m_ptr->PROC_NR, EIO, 0L, 0L);
	return;
  }

  /* Copy message parameters to the tty structure. */
  tp->tty_otcaller = m_ptr->m_source;
  tp->tty_outproc = m_ptr->PROC_NR;
  tp->tty_out_vir = m_ptr->ADDRESS;
  tp->tty_outleft = m_ptr->COUNT;
  tp->tty_waiting = WAITING;
  tp->tty_cum = 0;

  /* Compute the physical address where the data is in user space. */
  rp = proc_addr(tp->tty_outproc);
  out_vir = (vir_bytes) tp->tty_out_vir;
  out_left = (vir_bytes) tp->tty_outleft;
  if ( (tp->tty_phys = umap(rp, D, out_vir, out_left)) == 0) {
	/* Buffer address provided by user is outside its address space. */
	tp->tty_cum = E_BAD_ADDR;
	tp->tty_outleft = 0;
  }

#if (CHIP == M68000)
  rp->p_physio = 1;	/* disable (un)shadowing */
#endif

  /* Copy characters from the user process to the terminal. */
  (*tp->tty_devstart)(tp);	/* copy data to queue and start I/O */

  /* If output is for a bitmapped terminal as the IBM-PC console, the output-
   * routine will return at once so there is no need to suspend the caller,
   * on ascii terminals however, the call is suspended and later revived.
   */
  if (m_ptr->TTY_LINE != 0) {
	caller = (int) tp->tty_outproc;
	replyee = (int) tp->tty_otcaller;
	tty_reply(TASK_REPLY, replyee, caller, SUSPEND, 0L, 0L);
  }
}


/*===========================================================================*
 *				do_ioctl				     *
 *===========================================================================*/
PRIVATE void do_ioctl(tp, m_ptr)
register struct tty_struct *tp;	/* pointer to tty_struct */
message *m_ptr;			/* pointer to message sent to task */
{
/* Perform IOCTL on this terminal. */

  long speed, flags, erki, erase, kill, intr, quit, xon, xoff, eof;
  int r;

  r = OK;
  flags = 0;
  erki = 0;
  switch(m_ptr->TTY_REQUEST) {
     case TIOCSETP:
	/* Set erase, kill, and flags. */
	tp->tty_erase = (char) ((m_ptr->TTY_SPEK >> 8) & BYTE);	/* erase  */
	tp->tty_kill  = (char) ((m_ptr->TTY_SPEK >> 0) & BYTE);	/* kill  */
	tp->tty_mode  = (int) m_ptr->TTY_FLAGS;	/* mode word */
	speed = (m_ptr->TTY_SPEK >> 16) & 0xFFFF;
	if (speed != 0) tp->tty_speed = speed;
	if (tp-tty_struct >= NR_CONS)
		set_uart((int)(tp - tty_struct), tp->tty_mode, tp->tty_speed);
	break;

     case TIOCSETC:
	/* Set intr, quit, xon, xoff, eof (brk not used). */
	tp->tty_intr = (char) ((m_ptr->TTY_SPEK >> 24) & BYTE);	/* interrupt */
	tp->tty_quit = (char) ((m_ptr->TTY_SPEK >> 16) & BYTE);	/* quit */
	tp->tty_xon  = (char) ((m_ptr->TTY_SPEK >>  8) & BYTE);	/* CTRL-S */
	tp->tty_xoff = (char) ((m_ptr->TTY_SPEK >>  0) & BYTE);	/* CTRL-Q */
	tp->tty_eof  = (char) ((m_ptr->TTY_FLAGS >> 8) & BYTE);	/* CTRL-D */
	break;

     case TIOCGETP:
	/* Get erase, kill, and flags. */
	erase = ((long) tp->tty_erase) & BYTE;
	kill  = ((long) tp->tty_kill) & BYTE;
	erki  = ((long) tp->tty_speed << 16) | (erase << 8) | kill;
	flags = (long) tp->tty_mode;
	break;

     case TIOCGETC:
	/* Get intr, quit, xon, xoff, eof. */
	intr  = ((long) tp->tty_intr) & BYTE;
	quit  = ((long) tp->tty_quit) & BYTE;
	xon   = ((long) tp->tty_xon)  & BYTE;
	xoff  = ((long) tp->tty_xoff) & BYTE;
	eof   = ((long) tp->tty_eof)  & BYTE;
	erki  = (intr << 24) | (quit << 16) | (xon << 8) | (xoff << 0);
	flags = (eof <<8);
	break;

     case TIOCFLUSH:
	/* quick hack for kermit */
	tty_buf_count(tty_driver_buf) = 0;	/* accumulation count set to 0 */
	break;

     default:
	r = EINVAL;
  }

  /* Send the reply. */
  tty_reply(TASK_REPLY, m_ptr->m_source, m_ptr->PROC_NR, r, flags, erki);
}


/*===========================================================================*
 *				do_setpgrp				     *
 *===========================================================================*/
PRIVATE void do_setpgrp(tp, m_ptr)
register struct tty_struct *tp; /* pointer to tty struct */
message *m_ptr;			/* pointer to message sent to task */
{
/* A control process group has changed */

   tp->tty_pgrp = m_ptr->TTY_PGRP;
   tty_reply(TASK_REPLY, m_ptr->m_source, m_ptr->PROC_NR, OK, 0L, 0L);
}


/*===========================================================================*
 *				do_cancel				     *
 *===========================================================================*/
PRIVATE void do_cancel(tp, m_ptr)
register struct tty_struct *tp;	/* pointer to tty_struct */
message *m_ptr;			/* pointer to message sent to task */
{
/* A signal has been sent to a process that is hanging trying to read or write.
 * The pending read or write must be finished off immediately.
 */

  int mode;

  /* First check to see if the process is indeed hanging.  If it is not, don't
   * reply (to avoid race conditions).
   */
  if (tp->tty_inleft == 0 && tp->tty_outleft == 0) return;

  /* Kill off input/output. */
  mode = m_ptr->COUNT;
  if (mode & R_BIT) {
	/* Process was reading when killed.  Clean up input. */
	tp->tty_inhead = tp->tty_inqueue;	/* discard all data */
	tp->tty_intail = tp->tty_inqueue;
	tp->tty_incount = 0;
	tp->tty_lfct = 0;
	tp->tty_inleft = 0;
	tp->tty_inhibited = RUNNING;
  }
  if (mode & W_BIT) {
	/* Process was writing when killed.  Clean up output. */
	tp->tty_outleft = 0;
	tp->tty_waiting = NOT_WAITING;	/* don't send reply */
  }
  tty_reply(TASK_REPLY, m_ptr->m_source, m_ptr->PROC_NR, EINTR, 0L, 0L);
}


/*===========================================================================*
 *				tty_reply				     *
 *===========================================================================*/
PUBLIC void tty_reply(code, replyee, proc_nr, status, extra, other)
int code;			/* TASK_REPLY or REVIVE */
int replyee;			/* destination address for the reply */
int proc_nr;			/* to whom should the reply go? */
int status;			/* reply code */
long extra;			/* extra value */
long other;			/* used for IOCTL replies */
{
/* Send a reply to a process that wanted to read or write data. */

  static message tty_mess;

  tty_mess.m_type = code;
  tty_mess.REP_PROC_NR = proc_nr;
  tty_mess.REP_STATUS = status;
  tty_mess.TTY_FLAGS = extra;	/* used by IOCTL for flags (mode) */
  tty_mess.TTY_SPEK = other;	/* used by IOCTL for erase and kill chars */
  send(replyee, &tty_mess);
}


/*===========================================================================*
 *				sigchar					     *
 *===========================================================================*/
PUBLIC void sigchar(tp, sig)
register struct tty_struct *tp;	/* pointer to tty_struct */
int sig;			/* SIGINT, SIGQUIT, or SIGKILL */
{
/* Process a SIGINT, SIGQUIT or SIGKILL char from the keyboard */

  tp->tty_inhibited = RUNNING;	/* do implied CRTL-Q */
  finish(tp, EINTR);		/* send reply */
  tp->tty_inhead = tp->tty_inqueue;	/* discard input */
  tp->tty_intail = tp->tty_inqueue;
  tp->tty_incount = 0;
  tp->tty_lfct = 0;
  if (tp >= &tty_struct[NR_CONS]) rs_sig(tp);	/* RS232 only */
  if (tp->tty_pgrp) cause_sig(tp->tty_pgrp, sig);
}
