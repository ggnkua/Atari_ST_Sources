#include <lib.h>
#define longjerr	_longjerr
#define write		_write
#include <minix/minlib.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


_PROTOTYPE( void longjerr, (void));

PUBLIC void longjerr()
{
  static char errmsg[] = "longj error\n";

  write(2, errmsg, strlen(errmsg));	/* hope it's stderr */
  while(1) abort();		/* XXX - maybe just exit */
}
