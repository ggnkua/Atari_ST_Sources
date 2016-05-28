#include <stdio.h>
#include <dos.h>

typedef unsigned char			UBYTE;
typedef signed char				SBYTE;
typedef unsigned short          UWORD;
typedef signed short            SWORD;
typedef unsigned int            ULONG;
typedef signed int              SLONG;

typedef unsigned char			U8;
typedef signed char				S8;
typedef unsigned short 			U16;
typedef signed short        	S16;
typedef unsigned int            U32;
typedef signed int             	S32;
typedef float                   FP32;

typedef union { S8 b3, b2, b1, b0; S16 w1, w0; S32 ln; } SL;
typedef union { U8 b3, b2, b1, b0; U16 w1, w0; U32 ln; } UL;
