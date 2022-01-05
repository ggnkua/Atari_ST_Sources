#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

typedef unsigned char			UBYTE;
typedef signed char				SBYTE;
typedef unsigned int            UWORD;
typedef signed int              SWORD;
typedef unsigned long           ULONG;
typedef signed long             SLONG;

typedef unsigned char			U8;
typedef signed char				S8;
typedef unsigned int 			U16;
typedef signed int          	S16;
typedef unsigned long           U32;
typedef signed long            	S32;
typedef float                   FP32;

typedef union { U8 b3, b2, b1, b0; U16 w1, w0; U32 ln; } UL;
