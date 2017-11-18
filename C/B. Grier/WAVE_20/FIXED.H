/*
  These definitions are the implementation of
  a fixed point math system. This system has the
  accurracy to support ALL ST and TT resolutions.

  This system allows three times as many floating point
  operations using Mark Williams C on an ST.

  Because of improvements in the integer math capabilities of
  the 68010, 020, 030, and 040, these functions will still 
  provide an improvement over the 68882 co-processor on the TT,
  providing the compiler used takes advantage of these improvements.

  This system uses the low eight bits as the fraction, the
  middle sixteen bits as the whole number, and the eight upper
  most bits are scratch bits used during multiplies and
  divides.
*/

/*
  Define the type
*/
typedef long Fixed ;

/*
  Define the multiplicative dyadic operators
*/
#define fmult(a, b) ((a * b) >> 8)
#define fdiv(a, b)  ((a << 8) / b)

/*
  convert between floating and fixed point
*/
#define fl_fp(a)      ((long)(a * 256.0))
#define fp_fl(a)      (((float)a) / 256.0)
#define fp_long(a)    (a >> 8)
