/* INET must occasionally print some message.  It uses the standard library
 * routine prink().  (The name "printf" is really a macro defined as "printk").
 * Printing is done by calling the TTY task directly, not going through FS.
 */

#include "inet.h"

#define BUF_SIZE          100	/* print buffer size */

PRIVATE int buf_count;		/* # characters in the buffer */
PRIVATE char print_buf[BUF_SIZE];	/* output is buffered here */
PRIVATE message putch_msg;	/* used for message to TTY task */

FORWARD _PROTOTYPE (void flush, (void) );
_PROTOTYPE (void putk, (int c) );


/*===========================================================================*
 *				putk					     *
 *===========================================================================*/
PUBLIC void putk(c)
int c;
{
/* Accumulate another character.  If 0 or buffer full, print it. */

  if (c == 0 || buf_count == BUF_SIZE) flush();
  if (c == '\n') putk('\r');
  if (c != 0) print_buf[buf_count++] = c;
}


/*===========================================================================*
 *				flush					     *
 *===========================================================================*/
PRIVATE void flush()
{
/* Flush the print buffer by calling TTY task. */

  if (buf_count == 0) return;
  putch_msg.m_type = DEV_WRITE;
  putch_msg.PROC_NR  = this_proc;
  putch_msg.TTY_LINE = 0;
  putch_msg.ADDRESS  = print_buf;
  putch_msg.COUNT = buf_count;
  sendrec(TTY, &putch_msg);
  if (putch_msg.REP_STATUS == SUSPEND)
	receive(TTY, &putch_msg);
  buf_count = 0;
}
