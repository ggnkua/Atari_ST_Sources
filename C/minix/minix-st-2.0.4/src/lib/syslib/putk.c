/* A server must occasionally print some message.  It uses a simple version of 
 * printf() found in the system library that calls putk() to output characters.
 * Printing is done by doing SYS_PUTS, and not by going through FS.
 *
 * This routine can only be used by servers such as MM or FS.  The kernel
 * must define its own putk().
 */

#include "syslib.h"
#include <minix/callnr.h>
#include <minix/minlib.h>

/*===========================================================================*
 *				putk					     *
 *===========================================================================*/
void putk(c)
int c;
{
/* Accumulate another character.  If 0 or buffer full, print it. */

  static size_t buf_count;	/* # characters in the buffer */
  static char print_buf[80];	/* output is buffered here */
  message m;

  if ((c == 0 && buf_count > 0) || buf_count == sizeof(print_buf)) {
	/* Send the buffer to the system task, or, if this process is not a
	 * server yet, to standard error.
	 */
	m.m1_i1 = buf_count;
	m.m1_p1 = print_buf;
	m.m_type = SYS_PUTS;
	if (_sendrec(SYSTASK, &m) != 0) {
		m.m1_i1 = 2;
		m.m1_i2 = buf_count;
		m.m1_p1 = print_buf;
		m.m_type = WRITE;
		(void) _sendrec(FS, &m);
	}
	buf_count = 0;
  }
  if (c != 0) print_buf[buf_count++] = c;
}
