
/* does this replace some Eunuchs thing?  Who knows, in this kludge of a 
 * language.  In any event, input-scrub.c wants it; nobody else seems to use 
 * it.
 */

/* apparently Eunuchs has a similar thing, but their error numbers
   go up from 0.  We'll hack things a bit so as to allow negative offsets
   from sys_errlist to get the right strings here */

#include <errno.h>

int sys_nerr = -67;			/* min known error number */
int errno = 0;				/* current error num */

char * __gubbish = "No error";		/* see below */

char * _sys_errlist[] = 
	{
	"System error",			/* min-error minus 1 */
	"Error setting block size",	/* -67 */
	"Not an executable",
	"Internal error",
	"Bad arg",			/* -64 */
	"", "", "", "", "", "", "", "",	/* -63 .. -56 */
	"", "", "", "", "", "",		/* -55 .. -50 */
	"No more files",
	"Cross device rename",
	"",				/* -47 */
	"Invalid drive",
	"", "", "", "", "",
	"Memory fault",
	"Not enough memory",
	"",				/* -38 */
	"Invalid file handle",
	"Access denied",
	"Too many open files",
	"Path not found",
	"File not found",
	"Invalid function number",
	"", "", "", "", "", "", "", "",	/* -31 .. -24 */
	"", "", "", "", "", "", 	/* -23 .. -18 */
	"Insert disk",
	"Bad sectors",
	"Unknown device",
	"Media change",
	"Write protected",
	"Random bogons",
	"Read fault",
	"Write fault",
	"Paper out",
	"Sector not found",
	"Unknown media",
	"Seek error",
	"Bad request",
	"CRC error",
	"Unknown command",
	"Drive not ready",
	"Generic bogosity"		/* -1 */
	};
/* this, of course, must follow the above immediately.  We rely
   on GCC optimizing this into a reference to the duplicate string, above */
char * sys_errlist[] = 
	{
	"No error"
	};

char * sys_error(num)
int num;
{
  if ((num < sys_nerr) || (num > 0))
	num = 0;
  return(sys_errlist[num]);
}
