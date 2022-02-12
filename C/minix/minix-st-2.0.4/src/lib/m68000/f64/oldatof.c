
/* jrd's kludgy atof */

#include <ctype.h>

#define maybe_negate(num,flg) ((flg) ? -(num) : (num))

double atof(str)
char * str;
{
  int neg = 0;
  int one = 1, ten = 10;
  double accum, factor, tenth;
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
	accum = accum * (double)ten + (c - '0');
	}
  if (c != '.')
	return(maybe_negate(accum, neg));

  factor = tenth = /* 0.1; */ (double )one / (double )ten; 

  for ( ; ((c = *str++) && (isdigit(c))) ; )
	{
	accum = accum + ((c - '0') * factor);
	factor = factor * tenth;
	}

  return(maybe_negate(accum,neg));
}
