
/* fgets */

#include <file.h>
#include "std-guts.h"

char * fgets(buf, nbytes, fd)
char * buf;
int nbytes;
struct file * fd;
{
  int c;
  char * b = buf;
  int crflag = 0;		/* more kludgery for eunuchsisms */
  int anything = 0;

#ifdef DEBUG
  fprintf(stderr, "fgets(%X, %d, %X)", buf, nbytes, fd);
#endif

  if (feof(fd))
	{
#ifdef DEBUG
	fprintf(stderr, "->EOF\n");
#endif
	return(NULL);
	}

  for ( ; nbytes > 0 ; nbytes--)
	{
	c = fgetc(fd);
/*
#ifdef DEBUG
	fprintf(stderr, " '%02X'", c);
#endif
*/
	if (c == EOF)
		{
		goto done;
		}
	if (c == '\r')
		{
		crflag = 1;
		}
	    else
		{
		if (crflag & (c != '\n'))
			*b++ = '\r';
		crflag = 0;	/* fucks up when reading a string of cr's.
				   BFD.  */

		anything = 1;
		*b++ = c;
		if (c == '\n')
			goto done;
		}
	}
done:
  *b++ = '\0';
  if (anything)
  	return(buf);
    else
    	return(NULL);
}

char * gets(buf)
char * buf;
{
  fgets(buf, 99999999, stdin);
  return(buf);
}

