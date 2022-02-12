#include <lib.h>
#include <stdio.h>

void _cleanup()
{
  register int i;

  for (i = 0; i < NFILES; i++)
	if (_io_table[i] != (struct _io_buf *)NULL) fflush(_io_table[i]);
}
