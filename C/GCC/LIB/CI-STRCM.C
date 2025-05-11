
/* like strcmp, but case-insensitive */

#include <ctype.h>

static char char_upcase(ch)
char ch;
{
  if (islower(ch))
	return(toupper(ch));
    else
	return(ch);
}

int
ci_strcmp(s1, s2)
char	* s1;
char	* s2;
{
  char ch1, ch2;

  if (!s1 && s2) return(-1);
  if (!s2 && s1) return(1);
  if (!s1 && !s2) return(0);
  while (char_upcase(*s1) == char_upcase(*s2++))
	if (!*s1++)
		return 0;
  return *s1 - *--s2;
}
