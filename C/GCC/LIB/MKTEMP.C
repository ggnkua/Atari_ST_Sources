
/* well, this is a complete crock of shit too. */

#include "stdio.h"
#include "types.h"
#include "stat.h"

char * mktemp(pattern)
char * pattern;
{
  char template[64];
  char result[64];
  char * p, * q;
  int tempnum;
  struct stat ignored;

/* first copy the name in, searching for the "XXX..." */
  for (p = pattern, q = (char * )&template ; *p ; p++)
	{
	if (*p == 'X')
		break;
	*q++ = *p;
	}
  *q++ = '%';
  *q++ = 'd';
  while (*p && (*p == 'X'))
	p++;
/* copy the rest */
  for ( ; *p ; )
	*q++ = *p++;
  *q = '\0';

/* generate the name, but don't try forever if they gave us something
   completely bogus. */
  for (tempnum = 0 ; tempnum < 100 ; tempnum++)
	{
	sprintf(&result, &template, tempnum);
  	if (stat(&result, &ignored) != 0)
		break;
	}
  if (tempnum >= 100)		/* lost */
	return(0L);
  strcpy(pattern, &result);
  return(pattern);
}
