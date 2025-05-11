/* Subroutines needed by GCC output code on some machines.  */
/* Compile this file with the Unix C compiler!  */

#include "config.h"

/* These definitions work for machines where an SF value is
   returned in the same register as an int.  */

#ifndef SFVALUE  
#define SFVALUE int
#endif

#ifndef INTIFY
#define INTIFY(FLOATVAL)  (intify.f = (FLOATVAL), intify.i)
#endif

union double_di { double d; int i[2]; };
union flt_or_int { int i; float f; };

#ifdef WORDS_BIG_ENDIAN
#define HIGH 0
#define LOW 1
#else
#define HIGH 1
#define LOW 0
#endif

#ifdef L_eprintf
#include <stdio.h>
/* This is used by the `assert' macro.  */
void
_eprintf (string, line)
     char *string;
     int line;
{
  fprintf (stderr, string, line);
}
#endif

#ifdef L_umulsi3
_umulsi3 (a, b)
     unsigned a, b;
{
  return a * b;
}
#endif

#ifdef L_mulsi3
_mulsi3 (a, b)
     int a, b;
{
  return a * b;
}
#endif

#ifdef L_udivsi3
_udivsi3 (a, b)
     unsigned a, b;
{
  return a / b;
}
#endif

#ifdef L_divsi3
_divsi3 (a, b)
     int a, b;
{
  return a / b;
}
#endif

#ifdef L_umodsi3
_umodsi3 (a, b)
     unsigned a, b;
{
  return a % b;
}
#endif

#ifdef L_modsi3
_modsi3 (a, b)
     int a, b;
{
  return a % b;
}
#endif

#ifdef L_lshrsi3
_lshrsi3 (a, b)
     unsigned a, b;
{
  return a >> b;
}
#endif

#ifdef L_lshlsi3
_lshlsi3 (a, b)
     unsigned a, b;
{
  return a << b;
}
#endif

#ifdef L_ashrsi3
_ashrsi3 (a, b)
     int a, b;
{
  return a >> b;
}
#endif

#ifdef L_ashlsi3
_ashlsi3 (a, b)
     int a, b;
{
  return a << b;
}
#endif

#ifdef L_divdf3
double
_divdf3 (a, b)
     double a, b;
{
  return a / b;
}
#endif

#ifdef L_muldf3
double
_muldf3 (a, b)
     double a, b;
{
  return a * b;
}
#endif

#ifdef L_negdf2
double
_negdf2 (a)
     double a;
{
  return -a;
}
#endif

#ifdef L_adddf3
double
_adddf3 (a, b)
     double a, b;
{
  return a + b;
}
#endif

#ifdef L_subdf3
double
_subdf3 (a, b)
     double a, b;
{
  return a - b;
}
#endif

#ifdef L_cmpdf2
int
_cmpdf2 (a, b)
     double a, b;
{
  if (a > b)
    return 1;
  else if (a < b)
    return -1;
  return 0;
}
#endif

#ifdef L_fixunsdfsi
_fixunsdfsi (a)
     double a;
{
  return (unsigned int) a;
}
#endif

#ifdef L_fixunsdfdi
double
_fixunsdfdi (a)
     double a;
{
  union double_di u;
  u.i[LOW] = (unsigned int) a;
  u.i[HIGH] = 0;
  return u.d;
}
#endif

#ifdef L_fixdfsi
_fixdfsi (a)
     double a;
{
  return (int) a;
}
#endif

#ifdef L_fixdfdi
double
_fixdfdi (a)
     double a;
{
  union double_di u;
  u.i[LOW] = (int) a;
  u.i[HIGH] = (int) a < 0 ? -1 : 0;
  return u.d;
}
#endif

#ifdef L_floatsidf
double
_floatsidf (a)
     int a;
{
  return (double) a;
}
#endif

#ifdef L_floatdidf
double
_floatdidf (u)
     union double_di u;
{
  register double hi
    = ((double) u.i[HIGH]) * (double) 0x10000 * (double) 0x10000;
  register double low = (unsigned int) u.i[LOW];
  return hi + low;
}
#endif

#ifdef L_addsf3
SFVALUE
_addsf3 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  return INTIFY (a.f + b.f);
}
#endif

#ifdef L_negsf2
SFVALUE
_negsf2 (a)
     union flt_or_int a;
{
  union flt_or_int intify;
  return INTIFY (-a.f);
}
#endif

#ifdef L_subsf3
SFVALUE
_subsf3 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  return INTIFY (a.f - b.f);
}
#endif

#ifdef L_cmpsf2
SFVALUE
_cmpsf2 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  if (a.f > b.f)
    return 1;
  else if (a.f < b.f)
    return -1;
  return 0;
}
#endif

#ifdef L_mulsf3
SFVALUE
_mulsf3 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  return INTIFY (a.f * b.f);
}
#endif

#ifdef L_divsf3
SFVALUE
_divsf3 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  return INTIFY (a.f / b.f);
}
#endif

#ifdef L_truncdfsf2
SFVALUE
_truncdfsf2 (a)
     double a;
{
  union flt_or_int intify;
  return INTIFY (a);
}
#endif

#ifdef L_extendsfdf2
double
_extendsfdf2 (a)
     union flt_or_int a;
{
  union flt_or_int intify;
  return a.f;
}
#endif
