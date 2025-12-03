
#include <limits.h>
#include <ctype.h>
#include "global.h"
#include "ztype.h"

unsigned char Z_type[UCHAR_MAX + 1];

/* Z_type_init() -- initialize lookup table for extended ctype macros */
void Z_type_init()
{
  unsigned c;

  for (c = 0; c <= UCHAR_MAX; c++) {
    Z_type[c] = '\0';
    if (isalpha(c) || c == '_')
      Z_type[c] |= Z_ct1;
    if (isalnum(c) || c == '_')
      Z_type[c] |= Z_ct2;
    if (c == 'f' || c == 'F')
      Z_type[c] |= Z_fsx;
    if (c == 'U' || c == 'u')
      Z_type[c] |= Z_isx;
    if (c == 'L' || c == 'l')
      Z_type[c] |= (Z_fsx | Z_isx);
    if (c >= '0' && c <= '7')
      Z_type[c] |= Z_oct;
  }
}
