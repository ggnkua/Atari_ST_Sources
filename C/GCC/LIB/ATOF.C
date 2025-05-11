
/* jrd's kludgy atof */

#include <ctype.h>

double atof(str)
char * str;
{
  int neg = 0;
  int one = 1, ten = 10;
  double accum, factor;
  char c;

  while (isspace(*str)) str++;

  if (*str == '-') 
	{
	neg = 1;
	str++;
	}

  accum = 0;
  for ( ; ((c = *str++) && (isdigit(c))) ; )
	{
	accum = accum * 10 + (c - '0');
	}
  if (c != '.')
	return(accum);

  factor = (double )one / (double )ten;
  for ( ; ((c = *str++) && (isdigit(c))) ; )
	{
	accum = accum + ((c - '0') * factor);
	factor = factor / 10;
	}

  if (neg)
	accum = -accum;
  return(accum);
}
