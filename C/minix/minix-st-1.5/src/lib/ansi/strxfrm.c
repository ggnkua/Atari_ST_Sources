/* strxfrm.c */
/* Transforms s2 into s1.  The effect is to make strcmp() act on the     */
/* transformed strings exactly as strcoll() does on original strings.    */
/* WARNING: This is a bogus implementation, since I have no idea what	 */
/*          ANSI is prattling about with respect to locale.              */

#include <string.h>

size_t strxfrm(s1, s2, n)
char *s1;
_CONST char *s2;
size_t n;
{
  strncpy(s1, s2, n);
  return strlen(s2);
}
