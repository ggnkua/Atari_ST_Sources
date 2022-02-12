/* FS must occasionally print some message.  It uses a special version of
 * the standard library routine printf() that calls putk() to print characters.
 * Printing is done by calling the TTY task directly, not going through FS.
 */

#include "fs.h"
#include <minix/com.h>

/*===========================================================================*
 *				putk					     *
 *===========================================================================*/
PUBLIC void putk(c)
int c;
{
/* Accumulate another character.  If 0 or buffer full, print it. */

  static size_t buf_count;	/* # characters in the buffer */
  static char print_buf[80];    /* output is buffered here */

  if ((c == 0 && buf_count > 0) || buf_count == sizeof(print_buf)) {
	/* Flush the print buffer by writing it to /dev/tty00. */
	(void) dev_io(DEV_WRITE, (4 << MAJOR), FS_PROC_NR,
					print_buf, 0L, buf_count, 0);
	buf_count = 0;
  }
  if (c == '\n') putk('\r');
  if (c != 0) print_buf[buf_count++] = c;
}
