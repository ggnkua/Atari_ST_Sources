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
| ztype.h -- extended ctype macros					|
\*---------------------------------------------------------------------*/

#define Z_ct1 (unsigned char)0x01
#define Z_ct2 (unsigned char)0x02
#define Z_isx (unsigned char)0x03
#define Z_fsx (unsigned char)0x08
#define Z_oct (unsigned char)0x10

extern unsigned char Z_type[];
extern void Z_type_init();

/* a character that can appear at the start of a C token */
#define is_ctoks(c)	(Z_type[(unsigned char)c]&Z_ct1)
/* a character that can appear within a C token */
#define is_ctok(c)	(Z_type[(unsigned char)c]&Z_ct2)
/* a character that can be a floating-point suffix */
#define is_isuff(c)	(Z_type[(unsigned char)c]&Z_isx)
/* a character that can be an integer suffix */
#define is_fsuff(c)	(Z_type[(unsigned char)c]&Z_fsx)
/* an octal digit */
#define is_octal(c)	(Z_type[(unsigned char)c]&Z_oct)
