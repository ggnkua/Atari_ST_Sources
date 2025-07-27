/*---------------------------------------------------------------------*\
|									|
| CPP -- a stand-alone C preprocessor					|
| Copyright (c) 1993 Hacker Ltd.		Author: Scott Bigham	|
|									|
| Permission is granted to anyone to use this software for any purpose	|
| on any computer system, and to redistribute it freely, with the	|
| following restrictions:						|
| - No charge may be made other than reasonable charges for repro-	|
|     duction.								|
| - Modified versions must be clearly marked as such.			|
| - The author is not responsible for any harmful consequences of	|
|     using this software, even if they result from defects therein.	|
|									|
| ztype.c -- extended ctype macros					|
\*---------------------------------------------------------------------*/

#include <limits.h>
#include <ctype.h>
#include "global.h"
#include "ztype.h"

unsigned char Z_type[UCHAR_MAX + 1];

/* Z_type_init() -- initialize lookup table for macros in ztype.h */
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
