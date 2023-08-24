
# line 2 "a56.y"
/*******************************************************
 *
 *  a56 - a DSP56001 assembler
 *
 *  Written by Quinn C. Jensen
 *  July 1990
 *  jensenq@npd.novell.com (or jensenq@qcj.icon.com)
 *
 *******************************************************\

/*
 * Copyright (C) 1990-1992 Quinn C. Jensen
 *
 * Permission to use, copy, modify, distribute, and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.  The author makes no representations
 * about the suitability of this software for any purpose.  It is
 * provided "as is" without express or implied warranty.
 *
 */

/*
 *  a56.y - The YACC grammar for the assembler.
 *
 *  Note:  This module requires a "BIG" version of YACC.  I had to
 *  recompile YACC in the largest mode available.
 *
 *  Other notes:
 *
 *  MOVEC, MOVEM and MOVEP must be used explicitly--MOVE can't yet figure
 *  out which form to use.
 *
 */

#include "a56.h"
unsigned int w0, w1, pc;
extern BOOL list_on;
BOOL uses_w1;
int just_rep = 0;
extern char inline[];
char *spaces(), *luntab();
char segs[] = "PXYL";
int seg;
int substatement = 0;
BOOL long_symbolic_expr = FALSE;

struct n binary_op();
struct n unary_op();
struct n sym_ref();

#define R_R6			0x0001
#define R_R5			0x0002
#define R_R4			0x0004
#define R_DATA_ALU_ACCUM	0x0008
#define R_CTL_REG		0x0010
#define R_FUNKY_CTL_REG		0x0020
#define R_SDX			0x0040
#define R_SDY			0x0080
#define R_LSD			0x0100
#define R_AB			0x0200
#define R_XREG			0x0400
#define R_YREG			0x0800
/* registers to which short immediate move is an unsigned int */
#define R_UINT			0x1000
/* registers to which short immediate move is an signed frac */
#define R_SFRAC			0x2000

# line 72 "a56.y"
typedef union  {
	int ival;	/* integer value */
	struct n n;	/* just like in struct sym */
	double dval;	/* floating point value */
	char *sval;	/* string */
	int cval;	/* character */
	char cond;	/* condition */
	struct regs {
		int r6, r5, r4, data_alu_accum, ctl_reg, funky_ctl_reg;
		int sdx, sdy, lsd, ab, xreg, yreg;
		int flags;
	} regs;
	struct ea {
		int mode;
		int ext;
		int pp;
	} ea;
} YYSTYPE;
# define CHEX 257
# define CDEC 258
# define FRAC 259
# define AREG 260
# define BREG 261
# define MREG 262
# define NREG 263
# define RREG 264
# define XREG 265
# define YREG 266
# define OP 267
# define OPA 268
# define OPP 269
# define OP_JCC 270
# define OP_JSCC 271
# define OP_TCC 272
# define SYM 273
# define STRING 274
# define CHAR 275
# define COMMENT 276
# define XMEM 277
# define YMEM 278
# define LMEM 279
# define PMEM 280
# define AAAA 281
# define A10 282
# define BBBB 283
# define B10 284
# define AABB 285
# define BBAA 286
# define XXXX 287
# define YYYY 288
# define SR 289
# define MR 290
# define CCR 291
# define OMR 292
# define SP 293
# define SSH 294
# define SSL 295
# define LA 296
# define LC 297
# define EOL 298
# define EOS 299
# define OP_ABS 300
# define OP_ADC 301
# define OP_ADD 302
# define OP_ADDL 303
# define OP_ADDR 304
# define OP_ASL 305
# define OP_ASR 306
# define OP_CLR 307
# define OP_CMP 308
# define OP_CMPM 309
# define OP_DIV 310
# define OP_MAC 311
# define OP_MACR 312
# define OP_MPY 313
# define OP_MPYR 314
# define OP_NEG 315
# define OP_NORM 316
# define OP_RND 317
# define OP_SBC 318
# define OP_SUB 319
# define OP_SUBL 320
# define OP_SUBR 321
# define OP_TFR 322
# define OP_TST 323
# define OP_AND 324
# define OP_ANDI 325
# define OP_EOR 326
# define OP_LSL 327
# define OP_LSR 328
# define OP_NOT 329
# define OP_OR 330
# define OP_ORI 331
# define OP_ROL 332
# define OP_ROR 333
# define OP_BCLR 334
# define OP_BSET 335
# define OP_BCHG 336
# define OP_BTST 337
# define OP_DO 338
# define OP_ENDDO 339
# define OP_LUA 340
# define OP_MOVE 341
# define OP_MOVEC 342
# define OP_MOVEM 343
# define OP_MOVEP 344
# define OP_ILLEGAL 345
# define OP_INCLUDE 346
# define OP_JMP 347
# define OP_JCLR 348
# define OP_JSET 349
# define OP_JSR 350
# define OP_JSCLR 351
# define OP_JSSET 352
# define OP_NOP 353
# define OP_REP 354
# define OP_RESET 355
# define OP_RTI 356
# define OP_RTS 357
# define OP_STOP 358
# define OP_SWI 359
# define OP_WAIT 360
# define OP_EQU 361
# define OP_ORG 362
# define OP_DC 363
# define OP_END 364
# define OP_PAGE 365
# define OP_PSECT 366
# define OP_ALIGN 367
# define SHL 368
# define SHR 369
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256

# line 1579 "a56.y"


#include <stdio.h>

int yydebug;

struct n binary_op(a1, op, a2)
struct n a1, a2;
int op;
{
    struct n result;

    if(a1.type == UNDEF || a2.type == UNDEF) {
	result.type = UNDEF;
	return result;
    }

    /* promote to float automatically */

    if(a1.type != a2.type) {
	if(a1.type == INT) {
	    a1.val.f = a1.val.i;	/* truncate */
	    a1.type = FLT;
	} else {
	    a2.val.f = a2.val.i;	/* truncate */
	}
    }
    result.type = a1.type;

    /* do the op */

    if(result.type == INT) {
	switch(op) {
	    case '+':	result.val.i = a1.val.i + a2.val.i; break;
	    case '-':	result.val.i = a1.val.i - a2.val.i; break;
	    case '*':	result.val.i = a1.val.i * a2.val.i; break;
	    case '/':	result.val.i = a1.val.i / a2.val.i; break;
	    case '%':	result.val.i = a1.val.i % a2.val.i; break;
	    case SHL:	result.val.i = a1.val.i << a2.val.i; break;
	    case SHR:	result.val.i = a1.val.i >> a2.val.i; break;
	    case '|':	result.val.i = a1.val.i | a2.val.i; break;
	    case '&':	result.val.i = a1.val.i & a2.val.i; break;
	    case '^':	result.val.i = a1.val.i ^ a2.val.i; break;
	}
    } else {
	switch(op) {
	    case '+':	result.val.f = a1.val.f + a2.val.f; break;
	    case '-':	result.val.f = a1.val.f - a2.val.f; break;
	    case '*':	result.val.f = a1.val.f * a2.val.f; break;
	    case '/':	result.val.f = a1.val.f / a2.val.f; break;
	    case '%':	result.val.f = (int)a1.val.f % (int)a2.val.f; break;
	    case SHL:	result.val.f = (int)a1.val.f << (int)a2.val.f; break;
	    case SHR:	result.val.f = (int)a1.val.f >> (int)a2.val.f; break;
	    case '|':	result.val.f = (int)a1.val.f | (int)a2.val.f; break;
	    case '&':	result.val.f = (int)a1.val.f & (int)a2.val.f; break;
	    case '^':	result.val.f = (int)a1.val.f ^ (int)a2.val.f; break;
	}
    }

    return result;
}

struct n unary_op(op, a1)
int op;
struct n a1;
{
    struct n result;

    if(a1.type == UNDEF) {
	result.type = UNDEF;
	return result;
    }

    result.type = a1.type;

    /* do the op */

    if(result.type == INT) {
	switch(op) {
	    case '-':	result.val.i = -a1.val.i; break;
	    case '~':	result.val.i = ~a1.val.i; break;
	}
    } else {
	switch(op) {
	    case '-':	result.val.f = -a1.val.f; break;
	    case '~':	result.val.f = ~(int)a1.val.f; break;
	}
    }

    return result;
}

n2int(n)
struct n n;
{
    if(n.type == UNDEF)
	return UNDEF;
    else if(n.type == INT)
	return n.val.i;
    else
	return n.val.f;
}

n2frac(n)
struct n n;
{
    double adval = n.val.f >= 0.0 ? n.val.f : -n.val.f;

    if(n.type == UNDEF)
	return UNDEF;
    else if(n.type == INT)
	return n.val.i;

    adval -= (double)(int)adval;
    adval *= (double)0x800000;
    adval += 0.5;

    if(n.val.f >= 0.0)
	return adval;
    else
	return -adval;
}

extern struct {int n; char *name;} tok_tab[];
extern int n_tok;

char *tok_print(tok)
int tok;
{
    int i;
    static char buf[32];

    if(tok < 256) {
	sprintf(buf, "'%c'", tok);
	return(buf);
    } else {
	for(i = 0; i < n_tok; i++) {
	    if(tok == tok_tab[i].n)
		return(tok_tab[i].name);
	}
    }
    return("<unknown>");
}

yyerror(s, a0, a1, a2, a3)
char *s, *a0, *a1, *a2, *a3;
{
    extern int error;
    char buf[1024];

    error++;
    sprintf(buf, s, a0, a1, a2, a3);

    if(pass == 2) {
	fprintf(stderr, "%s: line %d: %s (tok=%s)\n", curfile, curline,
	    buf, tok_print(yychar));
	fprintf(stderr, "%s\n", inline); 
	printf("%s: line %d: %s (tok=%s)\n", curfile, curline,
	    buf, tok_print(yychar));
#if 0
	printf("%s\n", inline); 
#endif
    }
}

char *luntab(s)
char *s;
{
    static char buf[256];

    strcpy(buf, s);

    untab(buf);
    return(buf);
}
short yyexca[] ={
-1, 1,
	0, -1,
	270, 32,
	271, 32,
	272, 32,
	298, 6,
	299, 6,
	300, 32,
	301, 32,
	302, 32,
	303, 32,
	304, 32,
	305, 32,
	306, 32,
	307, 32,
	308, 32,
	309, 32,
	310, 32,
	311, 32,
	312, 32,
	313, 32,
	314, 32,
	315, 32,
	316, 32,
	317, 32,
	318, 32,
	319, 32,
	320, 32,
	321, 32,
	322, 32,
	323, 32,
	324, 32,
	325, 32,
	326, 32,
	327, 32,
	328, 32,
	329, 32,
	330, 32,
	331, 32,
	332, 32,
	333, 32,
	334, 32,
	335, 32,
	336, 32,
	337, 32,
	338, 32,
	339, 32,
	340, 32,
	341, 32,
	342, 32,
	343, 32,
	344, 32,
	345, 32,
	347, 32,
	348, 32,
	349, 32,
	350, 32,
	351, 32,
	352, 32,
	353, 32,
	354, 32,
	355, 32,
	356, 32,
	357, 32,
	358, 32,
	359, 32,
	360, 32,
	363, 32,
	-2, 0,
-1, 9,
	298, 35,
	299, 35,
	-2, 31,
	};
# define YYNPROD 286
# define YYLAST 1345
short yyact[]={

 134, 479, 221, 222, 336, 219, 345, 282, 277, 434,
 119, 338, 284, 281, 106, 280,  20, 283,  17,  18,
 110, 399, 133, 215, 216,  97, 234, 396, 439, 115,
 220, 435, 436, 437, 390, 182, 183, 400, 282, 277,
 176, 177, 395, 284, 281, 371, 280, 389, 283, 282,
 277, 181, 131, 180, 284, 281, 173, 280, 172, 283,
 422, 516, 174, 175, 276, 204,  20, 205, 104, 521,
 241, 245, 187, 102, 188, 112, 113, 114, 111, 203,
 274, 522, 139, 140, 116, 256, 258, 262, 300, 267,
 301, 270, 242, 246, 275, 276, 240, 244,  98,  99,
 100,  96, 109, 460, 459, 511, 276, 253, 490, 261,
 353, 254, 302, 263, 481, 268, 282, 277, 271, 272,
 369, 284, 281, 503, 280, 275, 283, 227, 502, 225,
 288, 218, 228, 457, 458, 210, 210, 210, 210, 293,
 304, 305, 297, 282, 277, 198, 199, 223, 284, 281,
 461, 280, 226, 283, 103,  98,  99, 100, 232, 214,
 233, 202, 528, 193, 294, 209, 282, 298, 197, 247,
 455, 284, 454, 276, 282, 277, 283, 523, 132, 284,
 281, 282, 280, 166, 283, 167, 284, 281, 504, 280,
 517, 283, 514, 512, 229, 230, 231, 510, 505, 499,
 276, 498, 494, 275, 468, 441, 430, 425, 424, 224,
 195, 196, 423, 103, 206, 207, 208, 420, 200, 201,
 217, 101, 211, 212, 213, 236, 237, 238, 282, 277,
 275, 417, 121, 284, 281, 462, 280, 194, 283, 414,
 264, 248, 248, 248, 248, 328, 327, 413, 412, 334,
 332, 249, 250, 251, 388, 387, 337, 339, 405, 386,
 406, 342, 382, 381, 376, 346, 375, 348, 358, 357,
 356, 355, 354, 329, 352, 351, 350, 333, 186, 189,
 190, 191, 192, 344, 343,  98,  99, 100, 341, 335,
 347, 331, 349, 374, 330, 326, 377, 380, 321, 320,
 319, 107, 373, 108, 235, 372, 273, 318, 317, 316,
 315, 314, 285, 286, 287, 313, 312, 311, 378, 227,
 289, 225, 310, 138, 228, 309, 308, 409, 307, 306,
 296, 295, 292, 410, 411, 291, 416, 290, 279, 278,
 385, 130, 129, 171,  98,  99, 100, 299, 128, 408,
 127, 427, 428, 429, 126, 431, 125, 433, 415, 124,
 107, 123, 108, 265, 419, 260, 421, 179, 438, 279,
 278, 257, 252, 426, 243, 442, 443, 444, 447, 178,
 279, 278, 452, 453, 448, 450,  19, 239, 391, 392,
 393, 394, 440,  92, 397, 398,  95,  91, 401, 402,
 403, 404,  29,  10, 446, 103, 184, 185, 117, 449,
 451, 464, 467,  28,  27, 469, 470, 471, 478,  26,
 466, 475, 122, 483, 485, 486, 487, 473, 346, 484,
  25,  24, 488, 322, 480, 432, 480, 287, 285, 465,
 476,  23, 118, 482, 495, 299, 474, 279, 278, 500,
  21, 497,   8, 347,   7, 340, 493, 489, 137,   5,
   3,   2, 227, 138, 225,   1, 456, 228, 266, 269,
 165, 506, 303, 150, 279, 278, 472, 463, 135, 337,
 339, 507, 223, 508, 509, 359, 360, 361, 362, 363,
 364, 365, 366, 367, 368, 105, 235, 480, 370, 515,
   0, 121, 513,   0,   0, 279, 278, 518, 519, 164,
 383, 384,   0,   0,   0, 524,   0,   0, 526,   0,
   0,   0, 525,   0, 530, 520,   0,   0, 529, 532,
  62,  61,  88, 531,   0, 287,  98,  99, 100,   0,
   0, 168, 169, 170,   0,   0,   0,   0, 103,   0,
 418,   0, 107,   0, 108,   0,   0,   0,   0,   0,
  53,  59,  35,  41,  45,  55,  51,  42,  38,  39,
  90,  32,  33,  30,  31,  57,  89,  40,  60,  34,
  43,  47,  37,  46,  48,  94,  50,  56,  52,  44,
  49,  93,  58,  54,  83,  82,  81,  80,  70,  71,
  87,  36,  86,  85,  84,  77, 235,  64,  68,  67,
  63,  66,  65,  79,  69,  74,  78,  75,  72,  76,
  73,   0,   0,  22,   4,   0,   0,   0,   0,   0,
   0,   0,   0,   0, 143, 144, 149, 148, 147, 141,
 142,   9,   0,   0,   6, 235,   0, 340,   0, 491,
 492, 139, 140,   0, 477, 145, 151, 146, 152, 155,
 156, 153, 154, 157,   0,   0, 158, 159, 160, 161,
 162, 163,   0,   0,   0,   0,   0,   0,   0,  98,
  99, 100,   0, 143, 144, 149, 148, 147, 141, 142,
   0,   0,   0,   0,   0, 107,   0, 108,   0,   0,
 139, 140, 136,   0, 145, 151, 146, 152, 155, 156,
 153, 154, 157,   0,  15, 158, 159, 160, 161, 162,
 163, 143, 144, 149, 148, 147, 141, 142,   0,   0,
  13,   0,  16,  14,  12,  11,   0,   0, 139, 140,
   0, 255, 145, 151, 146, 152, 155, 156, 153, 154,
 157,   0,   0, 158, 159, 160, 161, 162, 163, 143,
 144, 149, 148, 147, 141, 142,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 139, 140, 379,   0,
 145, 151, 146, 152, 155, 156, 153, 154, 157,   0,
   0, 158, 159, 160, 161, 162, 163,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0, 143, 144, 149, 148, 147, 141, 142,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0, 139, 140,
   0,   0, 145, 151, 146, 152, 155, 156, 153, 154,
 157,   0,   0, 158, 159, 160, 161, 162, 163,   0,
 143, 144, 149, 148, 147, 141, 142,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0, 445,   0,
   0, 145, 151, 146, 152, 155, 156, 153, 154, 157,
   0,   0, 158, 159, 160, 161, 162, 163, 143, 144,
 149, 148, 147, 141, 142,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0, 139, 140,   0,   0, 145,
 151, 146, 152, 155, 156, 153, 154, 157,   0,   0,
 158, 159, 160, 161, 162, 163, 143, 144, 149, 148,
 147, 141, 142, 227,   0, 225, 104,   0, 228,   0,
   0, 102,   0,   0, 527,   0,   0, 145, 151, 146,
 152, 155, 156, 153, 154, 157,   0,   0, 158, 159,
 160, 161, 162, 163, 143, 144, 149, 148, 147, 141,
 142, 104,   0, 225,   0,   0, 102,   0,   0,   0,
   0,   0, 501,   0,   0, 145, 151, 146, 152, 155,
 156, 153, 154, 157,   0,   0, 158, 159, 160, 161,
 162, 163, 143, 144, 149, 148, 147, 141, 142, 104,
   0,   0, 104,   0, 102,   0,   0, 102,   0, 103,
 496,   0, 103, 145, 151, 146, 152, 155, 156, 153,
 154, 157, 300,   0, 158, 159, 160, 161, 162, 163,
 143, 144, 149, 148, 147, 141, 142, 104,   0,   0,
   0, 104, 102, 323,   0,   0, 102, 103,   0,   0,
 259, 145, 151, 146, 152, 155, 156, 153, 154, 157,
   0,   0, 158, 159, 160, 161, 162, 163, 143, 144,
 149, 148, 147, 141, 142,   0, 104,   0,   0, 325,
   0, 102,   0,   0, 102, 103,   0,   0, 103, 145,
 151, 146, 152, 155, 156, 153, 154, 157,   0,   0,
 158, 159, 160, 161, 162, 163,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0, 103,   0,   0,   0, 103,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  98,  99, 100,  98,  99, 100,   0,   0,   0,   0,
 407,   0,   0,   0,   0,   0, 107,   0, 108, 107,
   0, 108, 103,   0,   0, 103,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  98,  99,
 100,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0, 107,   0, 108,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,  98,  99, 100,  98,
  99, 100,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0, 107, 120, 108, 107,   0, 108,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,  98,  99, 100,   0,  98,  99,
 100, 324,   0,   0,   0,   0,   0,   0,   0,   0,
 107,   0, 108,   0, 107,   0, 108,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,  98,  99, 100,  98,  99, 100,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0, 107,
   0, 108, 107,   0, 108 };
short yypact[]={

-1000, 368,-1000,-280,-1000,-1000,-1000,-210, 260,-260,
-102,1066,-171,-202,-102,-190,-1000,-1000,-1000,-1000,
-1000,-210, 989,-1000,-1000, 423,-1000,-1000,-1000,-1000,
 140, 140, 140, 140,-225,-225,-1000,-230,-230,-230,
-209,-209,-209,-209,-209,-209,-209,-209,-120,-120,
-120,-216,-216,-216,-216,-216,-216,-216,-216,-264,
-264, 422, 422, 422, 422, 269, 269, 269, 269, 571,
 571,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
 269, 269, 269, 269, 461, 800, 571, 283, 838,-149,
 838, 269, 269,-1000,-1000,-1000,1066,-194,-1000,-1000,
-1000, 106,1066,1066,1066,-1000,-1000,-1000,-1000,-202,
1066,-1000,-1000,-1000,-1000, 293,-1000,-1000, 291,-1000,
-1000, 106,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000, 288,-1000, 422, 287, 286, 422,  28,-152,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-125,-1000,-1000,-1000,-1000,
-1000,-1000, 285, 284, 282, 281, 278, 273,-1000,-1000,
 272, 271, 267, 266,-1000,-1000,-1000, 265, 264,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000, 263, 256,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,-1000, 255, 254,-1000,-1000,-1000,
-1000,-1000,-1000,1031, 106,-1000,-1000,1027,1069,-1000,
-1000,-1000,-1000, 251,-1000, 992,-1000,-1000,-1000,-1000,
-1000,-1000, 422,-1000, 250, 247, 422,-1000, 245,-1000,
-1000,-1000,-1000, 279, 244, 913, 240,-1000, 239, 422,
-1000, 422, 232, 231, 230,-1000,-154, 228, 227,-1000,
 226, 225, 224, 106,-1000,1066,1066,1066,1066,1066,
1066,1066,1066,1066,1066,-1000,-1000,  79,1066,   1,
-102, 989, 838, 222, 220, 499, 838, 219, 218, 106,
1066,1066, 299, 215, 211, 210,-234,-249,-216,-216,
-216,-216,-239,-256,-216,-216,-262,-244,-216,-216,
-216,-216, 106,-1000, 217, 916, 648,-1000,-1000,-1000,
 951, 951, 204, 203, 195, 648, 187,-1000,-1000,-1000,
1066,-195, 173,-195,-220, 168,-1000,-1000, 164, 163,
 648, 838, 838, 162, 838,-216, 838,-259,-259,  12,
 137, 144, 191, 191, 129, 129,-1000,-1000,-1000,-1000,
 -30,-202, 161,-1000, 838, 838, 838, 610, 422, 422,
-1000, 838, 838, 106, 106, 127,-216,-132,-162,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,-1000, 127,-113, 194,  87, 160,
-1000,-1000, 951, 951, 951,  87,-1000, 374, 106,-159,
-195,-159, 422, 838, 838, 838, 422,-1000,-1000,-1000,
-156,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,1066,
1066,-102, 158, 762,-1000, 913, 157, 155, 724,-1000,
-1000,-1000,-1000,-1000,-135,-140,-1000,-1000,-1000,-1000,
-1000, 147,-1000, 154,-1000,-1000,-1000,-1000, 951,-1000,
-1000,-1000,-1000,-1000,-1000,-1000, 279, 913,-1000,-1000,
-1000,-1000,-159,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000, 106, 106, 153,-161, 149, 913, 148, 838,-217,
 146, 913,-1000,-1000,-1000, 951,-1000,-1000,-1000,-1000,
-102,-1000,-197, 133, 838,-1000, 913, 686, 118,-1000,
-1000,-1000, 913, 838,-1000,-1000,-1000, 913, 838,-1000,
-1000,-1000,-1000 };
short yypgo[]={

   0,  14,   1, 495, 209,  26, 478,   2,  30,  11,
  79,  22,   5, 160, 477,   3, 476,   6, 131, 152,
 473, 343, 367, 237, 163, 168, 161, 165, 159, 509,
 472, 470, 469,   9, 468,  20,   0,   4, 465, 461,
 460, 459, 454, 386, 452, 450, 442,  10, 441, 431,
 430, 422, 419, 414, 413, 402, 397, 393, 158, 387,
 374, 169, 372, 371, 365, 363, 361, 359, 356, 354,
 350, 348, 342, 341 };
short yyr1[]={

   0,  38,  38,  39,  39,  39,  40,  40,  40,  40,
  40,  40,  41,  42,  42,  42,  42,  42,  42,  42,
  42,  42,  42,  46,  46,  47,  47,  35,  35,  35,
  35,  44,  44,  45,  43,  43,  48,  48,  48,  50,
  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,
  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,
  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,
  29,  31,  31,  31,  30,  30,  30,  30,  21,  21,
  21,  21,  21,  21,  22,  22,  22,  22,  23,  23,
  23,  23,  24,  25,  25,  26,  27,  28,  28,  10,
  10,  49,  49,  49,  49,  55,  55,  55,  55,  56,
  56,  57,  57,  52,  52,  52,  52,  52,  52,  52,
  52,  52,  52,  52,  52,  52,  52,  52,  52,  52,
  52,  52,  60,  60,  60,  60,  60,  59,  59,  59,
  59,  59,  58,  58,  14,  14,  14,  14,  53,  53,
  53,  53,  61,  61,  16,  16,  16,  54,  54,  54,
  54,  54,  65,  65,  34,  32,  64,  64,  64,  64,
  64,  64,  62,  62,  62,  62,  62,  62,  37,  37,
  37,  63,  63,  13,  11,  11,  17,  17,  18,  18,
  12,  12,  15,  15,  15,  15,  19,  19,  19,  19,
  36,  36,  36,  36,  36,  36,  36,  36,  36,  36,
  36,  36,  36,  36,  36,  36,  20,  20,  20,  20,
  20,  20,  20,  33,  33,  33,  51,  51,  51,  51,
  51,  51,  51,  51,  66,  71,  67,  68,  68,  68,
  68,  68,  69,  69,  69,  70,  70,  70,  73,  73,
  73,  73,  72,  72,  72,  72,   1,   1,   1,   5,
   5,   6,   7,   7,   8,   8,   9,   2,   2,   3,
   3,   3,   4,   4,   4,   4,   4,   4,   4,   4,
   4,   4,   4,   4,   4,   4 };
short yyr2[]={

   0,   0,   2,   2,   2,   1,   0,   1,   1,   2,
   3,   2,   3,   3,   2,   2,   6,   3,   6,   3,
   8,   2,   1,   3,   1,   1,   1,   1,   1,   1,
   1,   1,   0,   1,   1,   0,   1,   1,   2,   2,
   2,   2,   2,   2,   2,   1,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
   4,   1,   1,   0,   3,   3,   3,   3,   3,   3,
   3,   3,   3,   3,   3,   3,   3,   3,   1,   1,
   3,   3,   1,   3,   3,   1,   1,   3,   3,   1,
   1,   1,   1,   1,   1,   4,   2,   4,   4,   1,
   1,   1,   1,   2,   2,   2,   2,   2,   2,   2,
   2,   2,   2,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   3,   3,   4,   4,   4,   1,   1,   2,
   2,   2,   6,   5,   1,   1,   1,   1,   2,   2,
   2,   2,   4,   3,   1,   1,   1,   2,   2,   2,
   4,   2,   1,   4,   3,   3,   4,   4,   3,   4,
   4,   3,   5,   4,   5,   5,   4,   4,   1,   1,
   1,   4,   4,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   3,   5,   4,   5,   5,   4,   4,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   3,   3,   1,   4,   4,   4,
   4,   3,   7,   6,   7,   7,   6,   7,   4,   4,
   4,   4,   8,   8,   8,   8,   1,   1,   1,   2,
   3,   3,   1,   1,   2,   2,   2,   1,   1,   1,
   1,   1,   3,   3,   3,   3,   3,   3,   3,   3,
   3,   3,   2,   2,   3,   1 };
short yychk[]={

-1000, -38, -39, -40, 256, -41, 276, -42, -44, 273,
  35, 367, 366, 362, 365, 346, 364, 298, 299, -43,
 276, -45, 363, -48, -49, -50, -52, -53, -54, -55,
 313, 314, 311, 312, 319, 302, 341, 322, 308, 309,
 317, 303, 307, 320, 329, 304, 323, 321, 324, 330,
 326, 306, 328, 300, 333, 305, 327, 315, 332, 301,
 318, 271, 270, 350, 347, 352, 351, 349, 348, 354,
 338, 339, 358, 360, 355, 357, 359, 345, 356, 353,
 337, 336, 335, 334, 344, 343, 342, 340, 272, 316,
 310, -56, -57, 331, 325, -43, 361,  -1, 257, 258,
 259,  -4,  45, 126,  40,  -3,  -1, 273, 275, 273,
 -35, 280, 277, 278, 279,  -1, 274, -43, -46, -47,
 274,  -4, -51, -66, -67, -68, -69, -70, -71, -72,
 -73,  -5, -19, -11, -36,  -6, 279,  35,  40, 277,
 278, 265, 266, 260, 261, 281, 283, 264, 263, 262,
 -20, 282, 284, 287, 288, 285, 286, 289, 292, 293,
 294, 295, 296, 297, -29, -31,  43,  45, -29, -29,
 -29, -21, 283, 281, 287, 288, 265, 266, -21, -22,
 283, 281, 265, 266, -22, -22, -23, 281, 283, -23,
 -23, -23, -23, -24, -23, -24, -24, -25, 265, 266,
 -25, -25, -26, -10, 281, 283, -26, -26, -26, -27,
 -10, -27, -27, -27, -28, 287, 288, -28, -18, -12,
  -8,  -7, -15,  60,  -4,  42, -19,  40,  45, -18,
 -18, -18, -58, -13,  -5,  35, -58, -58, -58, -59,
  -5, -36, -11, -60,  -5, -36, -11, -61, -13, -61,
 -61, -61, -62, -11,  -5, 280, -36, -63, -36, 280,
 -64, -11, -36,  -5, -19, -65, -34, -36, 264, -32,
 -36,  -5,  -5,  -4, 274, 124,  94,  38, 369, 368,
  45,  43,  37,  47,  42,  -4,  -4,  -4, -35,  -4,
  44,  44,  44, -12,  -8,  44,  44, -12,  -8,  -4,
  60,  62, 264, -30, 265, 266,  44,  44,  44,  44,
  44,  44,  44,  44,  44,  44,  44,  44,  44,  44,
  44,  44,  -4,  42, 264,  40,  44, -15,  -7,  -8,
  44,  44, -15,  -8,  -7,  44, -37,  -7,  -9, -15,
 368,  44, -12,  44,  44, -17, -12,  -8, -12,  -8,
  44,  44,  44, 264,  44,  44,  44,  44,  44,  -4,
  -4,  -4,  -4,  -4,  -4,  -4,  -4,  -4,  -4,  41,
  -4,  44,  -1, -47, -36,  44,  44, -36, -11, 279,
 -36,  44,  44,  -4,  -4,  41,  44,  44,  44, 281,
 283, -10, -10, -10, -10, 281, 283, -10, -10, 283,
 281, -10, -10, -10, -10,  41,  43, 264, -11, -36,
  -7,  -7,  44,  44,  44, -11, -36,  44,  -4, -11,
  44, -11, 280,  44,  44,  44, -11, -36, -36, -36,
  44, -36, -10, -36, -33, 290, 291, 292, -33,  58,
 -35,  44, -36, -36, -36, 278,  -5, -36, -12,  -8,
 -12,  -8, -36, -36,  45,  43, -10, 265, 266, 266,
 265, 263,  41, -14,  -7,  -8,  -9, -15,  44,  -7,
  -7,  -7, -16,  -9,  -8, -12, -11, 280, -36,  -2,
  -1, 273, -11,  -2, -17, -36, -36, -36, -12,  -8,
 264,  -4,  -4,  -1,  44, -36, 278, -12,  44,  44,
 -36, 278, 263, 263,  41,  44,  -7, -37, -12,  -2,
  44, 266,  44, -12,  44, -36, 278,  44, -12,  -7,
  -1, 266, 278,  44, -36, -12, -36, 278,  44, -12,
 -36, -12, -36 };
short yydef[]={

   1,  -2,   2,   0,   5,   7,   8,  35,   0,  -2,
   0,   0,   0,   0,   0,   0,  22,   3,   4,   9,
  34,  35,   0,  33,  36,  37, 101, 102, 103, 104,
  73,  73,  73,  73,   0,   0,  45,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0, 111, 109,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0, 123, 124, 125, 126, 127, 128, 129, 130, 131,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0, 110, 112,  11,   0,   0, 256, 257,
 258,  14,   0,   0,   0, 285, 269, 270, 271,  15,
   0,  27,  28,  29,  30,   0,  21,  10,  19,  24,
  25,  26,  38, 226, 227, 228, 229, 230, 231, 232,
 233,   0, 236,   0,   0,   0,   0,   0,   0, 184,
 185, 200, 201, 202, 203, 204, 205, 206, 207, 208,
 209, 210, 211, 212, 213, 214, 215, 216, 217, 218,
 219, 220, 221, 222,  39,   0,  71,  72,  40,  41,
  42,  43,   0,   0,   0,   0,   0,   0,  44,  46,
   0,   0,   0,   0,  47,  48,  49,  88,  89,  50,
  51,  52,  53,  54,  92,  55,  56,  57,   0,   0,
  58,  59,  60,  95,  99, 100,  61,  62,  63,  64,
  96,  65,  66,  67,  68,   0,   0,  69, 113, 188,
 189, 190, 191,   0, 262, 263, 192,   0,   0, 114,
 115, 116, 117,   0, 183,   0, 118, 119, 120, 121,
 137, 138,   0, 122,   0,   0,   0, 148,   0, 149,
 150, 151, 157,   0,   0,   0,   0, 158,   0,   0,
 159,   0,   0,   0,   0, 161, 162,   0,   0, 106,
   0,   0,   0,  13,  12,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0, 282, 283,   0,   0,  17,
   0,   0,   0,   0,   0,   0,   0,   0,   0, 259,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0, 264, 265,   0,   0,   0, 139, 140, 141,
   0,   0,   0,   0,   0,   0,   0, 178, 179, 180,
   0,   0,   0,   0,   0,   0, 186, 187,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0, 272,
 273, 274, 275, 276, 277, 278, 279, 280, 281, 284,
   0,   0,   0,  23, 234,   0,   0, 235,   0,   0,
 241,   0,   0, 260, 261,   0,   0,   0,   0,  78,
  79,  80,  81,  82,  83,  84,  85,  86,  87,  91,
  90,  93,  94,  97,  98, 193,   0,   0,   0,   0,
 132, 133,   0,   0,   0,   0, 153,   0, 266,   0,
   0,   0,   0,   0,   0,   0,   0, 171, 168, 160,
   0, 164, 105, 165, 107, 223, 224, 225, 108,   0,
   0,   0,   0, 237, 238,   0,   0,   0, 239, 240,
 249, 251, 248, 250, 198, 199,  70,  74,  76,  75,
  77,   0, 195,   0, 144, 145, 146, 147,   0, 134,
 135, 136, 152, 154, 155, 156,   0,   0, 177, 173,
 267, 268,   0, 176, 181, 182, 166, 169, 167, 170,
 163,  16,  18,   0,   0,   0,   0,   0,   0,   0,
   0,   0, 196, 197, 194,   0, 143, 172, 175, 174,
   0, 243,   0,   0,   0, 246,   0,   0,   0, 142,
  20, 242,   0,   0, 245, 247, 244,   0,   0, 253,
 252, 255, 254 };
#ifndef lint
static char yaccpar_sccsid[] = "@(#)yaccpar	4.1	(Berkeley)	2/11/83";
#endif not lint

#
# define YYFLAG -1000
# define YYERROR goto yyerrlab
# define YYACCEPT return(0)
# define YYABORT return(1)

/*	parser for yacc output	*/

#ifdef YYDEBUG
int yydebug = 0; /* 1 for debugging */
#endif
YYSTYPE yyv[YYMAXDEPTH]; /* where the values are stored */
int yychar = -1; /* current input token number */
int yynerrs = 0;  /* number of errors */
short yyerrflag = 0;  /* error recovery flag */

yyparse() {

	short yys[YYMAXDEPTH];
	short yyj, yym;
	register YYSTYPE *yypvt;
	register short yystate, *yyps, yyn;
	register YYSTYPE *yypv;
	register short *yyxi;

	yystate = 0;
	yychar = -1;
	yynerrs = 0;
	yyerrflag = 0;
	yyps= &yys[-1];
	yypv= &yyv[-1];

 yystack:    /* put a state and value onto the stack */

#ifdef YYDEBUG
	if( yydebug  ) printf( "state %d, char 0%o\n", yystate, yychar );
#endif
		if( ++yyps> &yys[YYMAXDEPTH] ) { yyerror( "yacc stack overflow" ); return(1); }
		*yyps = yystate;
		++yypv;
		*yypv = yyval;

 yynewstate:

	yyn = yypact[yystate];

	if( yyn<= YYFLAG ) goto yydefault; /* simple state */

	if( yychar<0 ) if( (yychar=yylex())<0 ) yychar=0;
	if( (yyn += yychar)<0 || yyn >= YYLAST ) goto yydefault;

	if( yychk[ yyn=yyact[ yyn ] ] == yychar ){ /* valid shift */
		yychar = -1;
		yyval = yylval;
		yystate = yyn;
		if( yyerrflag > 0 ) --yyerrflag;
		goto yystack;
		}

 yydefault:
	/* default state action */

	if( (yyn=yydef[yystate]) == -2 ) {
		if( yychar<0 ) if( (yychar=yylex())<0 ) yychar = 0;
		/* look through exception table */

		for( yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=yystate) ; yyxi += 2 ) ; /* VOID */

		while( *(yyxi+=2) >= 0 ){
			if( *yyxi == yychar ) break;
			}
		if( (yyn = yyxi[1]) < 0 ) return(0);   /* accept */
		}

	if( yyn == 0 ){ /* error */
		/* error ... attempt to resume parsing */

		switch( yyerrflag ){

		case 0:   /* brand new error */

			yyerror( "syntax error" );
		yyerrlab:
			++yynerrs;

		case 1:
		case 2: /* incompletely recovered error ... try again */

			yyerrflag = 3;

			/* find a state where "error" is a legal shift action */

			while ( yyps >= yys ) {
			   yyn = yypact[*yyps] + YYERRCODE;
			   if( yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE ){
			      yystate = yyact[yyn];  /* simulate a shift of "error" */
			      goto yystack;
			      }
			   yyn = yypact[*yyps];

			   /* the current yyps has no shift onn "error", pop stack */

#ifdef YYDEBUG
			   if( yydebug ) printf( "error recovery pops state %d, uncovers %d\n", *yyps, yyps[-1] );
#endif
			   --yyps;
			   --yypv;
			   }

			/* there is no state on the stack with an error shift ... abort */

	yyabort:
			return(1);


		case 3:  /* no shift yet; clobber input char */

#ifdef YYDEBUG
			if( yydebug ) printf( "error recovery discards char %d\n", yychar );
#endif

			if( yychar == 0 ) goto yyabort; /* don't discard EOF, quit */
			yychar = -1;
			goto yynewstate;   /* try again in the same state */

			}

		}

	/* reduction by production yyn */

#ifdef YYDEBUG
		if( yydebug ) printf("reduce %d\n",yyn);
#endif
		yyps -= yyr2[yyn];
		yypvt = yypv;
		yypv -= yyr2[yyn];
		yyval = yypv[1];
		yym=yyn;
			/* consult goto table to find next state */
		yyn = yyr1[yyn];
		yyj = yypgo[yyn] + *yyps + 1;
		if( yyj>=YYLAST || yychk[ yystate = yyact[yyj] ] != -yyn ) yystate = yyact[yypgo[yyn]];
		switch(yym){
			
case 3:
# line 234 "a56.y"
{substatement = 0;
			if(NOT check_psect(seg, pc) && pass == 2)
				yyerror("%04X: psect violation", pc);
			} break;
case 4:
# line 239 "a56.y"
{substatement++;
			if(NOT check_psect(seg, pc) && pass == 2)
				yyerror("%04X: psect violation", pc);
			} break;
case 6:
# line 248 "a56.y"
{if(pass == 2 && list_on) {
				printf("\n");
			}} break;
case 8:
# line 253 "a56.y"
{if(pass == 2 && NOT substatement && list_on) {
				printf("%s%s\n", spaces(0), luntab(inline));
			}} break;
case 9:
# line 257 "a56.y"
{long_symbolic_expr = FALSE;} break;
case 10:
# line 259 "a56.y"
{char *printcode();
			if(pass == 2) {
				gencode(seg, pc, w0);
				if(list_on) printf("%c:%04X %s %s\n", segs[seg], pc, 
					printcode(w0), substatement ? "" :
						luntab(inline));
				pc++;
				if(uses_w1) {
					gencode(seg, pc, w1);
					if(list_on) printf("%c:%04X %s\n", segs[seg], pc,
	       					printcode(w1 & 0xFFFFFF));
					pc++;
				}
			} else {
				pc++;
				if(uses_w1)
					pc++;
			}
			w0 = w1 = 0; uses_w1 = FALSE; 
			long_symbolic_expr = FALSE;} break;
case 11:
# line 280 "a56.y"
{sym_def(yypvt[-1].sval, INT, pc);
			free(yypvt[-1].sval);
			if(pass == 2) {
				if(list_on) printf("%c:%04X%s%s\n", segs[seg], pc, 
					spaces(14-8), substatement ? "" :
						luntab(inline));
			long_symbolic_expr = FALSE;
			}} break;
case 12:
# line 292 "a56.y"
{if(strlen(yypvt[-0].sval) > 0)
				curfile = yypvt[-0].sval;
			curline = yypvt[-1].n.val.i - 2;} break;
case 13:
# line 299 "a56.y"
{sym_def(yypvt[-2].sval, yypvt[-0].n.type, yypvt[-0].n.val.i, yypvt[-0].n.val.f);
			free(yypvt[-2].sval);
			if(pass == 2 && list_on) {
				if(yypvt[-0].n.type == INT)
					printf("%06X%s",
						yypvt[-0].n.val.i & 0xFFFFFF,
						spaces(14-6-2));
				else
					printf("%10g%s", yypvt[-0].n.val.f,
						spaces(14-10-2));
				printf("%s\n", 
					substatement ? "" : luntab(inline));
			}} break;
case 14:
# line 313 "a56.y"
{int ival = n2int(yypvt[-0].n);
			if(yypvt[-0].n.type == UNDEF) {
				yyerror("illegal forward reference");
			} else if (ival <= 1) {
				yyerror("%d: illegal alignment", ival);
			} else {
				if(pc % ival != 0)
					pc += ival - pc % ival;
			}
			if(pass == 2 && list_on)
				printf("%c:%04X%s%s\n", segs[seg], pc, 
					spaces(14-8), substatement ? "" : luntab(inline));
			} break;
case 15:
# line 327 "a56.y"
{struct psect *pp = find_psect(yypvt[-0].sval);
			if(NOT pp) {
				if(pass == 2)
					yyerror("%s: undefined psect", yypvt[-0].sval);
			} else {
				seg = pp->seg;
				pc = pp->pc;
				set_psect(pp);
				if(pass == 2 && list_on) 
					printf("%c:%04X%s%s\n", segs[seg], pc, 
						spaces(14-8), substatement ? "" : luntab(inline));
			}
			free(yypvt[-0].sval);} break;
case 16:
# line 341 "a56.y"
{new_psect(yypvt[-4].sval, yypvt[-3].ival, n2int(yypvt[-2].n), n2int(yypvt[-0].n));
			if(pass == 2 && list_on) 
				printf("%c:%04X %04X%s%s\n", 
					segs[yypvt[-3].ival], n2int(yypvt[-2].n), n2int(yypvt[-0].n), spaces(14-8+4+1), 
					substatement ? "" : luntab(inline));
			} break;
case 17:
# line 348 "a56.y"
{pc = n2int(yypvt[-0].n);
			seg = yypvt[-1].ival;
			if(pass == 2 && list_on) 
				printf("%c:%04X%s%s\n", segs[seg], pc, 
					spaces(14-8), substatement ? "" : luntab(inline));
			} break;
case 18:
# line 355 "a56.y"
{pc = n2int(yypvt[-3].n);
			seg = yypvt[-4].ival;
			if(pass == 2 && list_on)
				printf("%c:%04X%s%s\n", segs[seg], pc, 
					spaces(14-8), substatement ? "" : luntab(inline));
			} break;
case 20:
# line 363 "a56.y"
{if(pass == 2 && NOT substatement && list_on) {
				printf("%s%s\n", spaces(0), luntab(inline));
			}} break;
case 21:
# line 367 "a56.y"
{if(pass == 2 && NOT substatement && list_on) {
				printf("%s%s\n", spaces(0), luntab(inline));
			}
			include(yypvt[-0].sval); /* free($2); */
			} break;
case 22:
# line 373 "a56.y"
{if(pass == 2 && NOT substatement && list_on) {
				printf("%s%s\n", spaces(0), luntab(inline));
			}} break;
case 25:
# line 385 "a56.y"
{int len = strlen(yypvt[-0].sval), i; char *cp; w0 = 0;
			if(len % 3 == 2)
				len++;	/* force empty word */
			for(i = 0, cp = yypvt[-0].sval; i < len; i++, cp++) {
				w0 |= (*cp & 0xFF) << (2 - (i % 3)) * 8;
				if(i % 3 == 2 || i == len - 1) {
					if(pass == 2) {
						if(list_on) printf("%c:%04X %06X%s%s\n",
							segs[seg], pc, w0, 
							spaces(14-6+5), 
							substatement ? "" : luntab(inline));
						gencode(seg, pc, w0);
						substatement++;
					}
					pc++; w0 = 0;
				}
			}
			free(yypvt[-0].sval);} break;
case 26:
# line 404 "a56.y"
{int frac = n2frac(yypvt[-0].n);
			if(pass == 2) {
				if(list_on) {
					printf("%c:%04X ", segs[seg], pc);
					printf("%06X%s", 
						frac & 0xFFFFFF,
							spaces(14-6+5));
					printf("%s\n",
						substatement ? "" : luntab(inline));
				}
				gencode(seg, pc, frac);
				substatement++;
			}
			pc++;} break;
case 27:
# line 420 "a56.y"
{yyval.ival = PROG;} break;
case 28:
# line 422 "a56.y"
{yyval.ival = XDATA;} break;
case 29:
# line 424 "a56.y"
{yyval.ival = YDATA;} break;
case 30:
# line 426 "a56.y"
{yyval.ival = LDATA;} break;
case 31:
# line 431 "a56.y"
{sym_def(yypvt[-0].sval, INT, pc);
			free(yypvt[-0].sval);} break;
case 33:
# line 438 "a56.y"
{if(just_rep) 
				just_rep--;} break;
case 37:
# line 450 "a56.y"
{w0 |= 0x200000;} break;
case 39:
# line 459 "a56.y"
{w0 |= 0x80 | yypvt[-0].ival << 2;} break;
case 40:
# line 461 "a56.y"
{w0 |= 0x81 | yypvt[-0].ival << 2;} break;
case 41:
# line 463 "a56.y"
{w0 |= 0x82 | yypvt[-0].ival << 2;} break;
case 42:
# line 465 "a56.y"
{w0 |= 0x83 | yypvt[-0].ival << 2;} break;
case 43:
# line 468 "a56.y"
{w0 |= 0x04 | yypvt[-0].ival << 3;} break;
case 44:
# line 470 "a56.y"
{w0 |= 0x00 | yypvt[-0].ival << 3;} break;
case 45:
# line 472 "a56.y"
{w0 |= 0x00;} break;
case 46:
# line 475 "a56.y"
{w0 |= 0x01 | yypvt[-0].ival << 3;} break;
case 47:
# line 477 "a56.y"
{w0 |= 0x05 | yypvt[-0].ival << 3;} break;
case 48:
# line 479 "a56.y"
{w0 |= 0x07 | yypvt[-0].ival << 3;} break;
case 49:
# line 482 "a56.y"
{w0 |= 0x11 | yypvt[-0].ival << 3;} break;
case 50:
# line 484 "a56.y"
{w0 |= 0x12 | yypvt[-0].ival << 3;} break;
case 51:
# line 486 "a56.y"
{w0 |= 0x13 | yypvt[-0].ival << 3;} break;
case 52:
# line 488 "a56.y"
{w0 |= 0x16 | yypvt[-0].ival << 3;} break;
case 53:
# line 490 "a56.y"
{w0 |= 0x17 | yypvt[-0].ival << 3;} break;
case 54:
# line 493 "a56.y"
{w0 |= 0x02 | yypvt[-0].ival << 3;} break;
case 55:
# line 495 "a56.y"
{w0 |= 0x03 | yypvt[-0].ival << 3;} break;
case 56:
# line 497 "a56.y"
{w0 |= 0x06 | yypvt[-0].ival << 3;} break;
case 57:
# line 500 "a56.y"
{w0 |= 0x46 | yypvt[-0].ival << 3;} break;
case 58:
# line 502 "a56.y"
{w0 |= 0x42 | yypvt[-0].ival << 3;} break;
case 59:
# line 504 "a56.y"
{w0 |= 0x43 | yypvt[-0].ival << 3;} break;
case 60:
# line 507 "a56.y"
{w0 |= 0x22 | yypvt[-0].ival << 3;} break;
case 61:
# line 509 "a56.y"
{w0 |= 0x23 | yypvt[-0].ival << 3;} break;
case 62:
# line 511 "a56.y"
{w0 |= 0x26 | yypvt[-0].ival << 3;} break;
case 63:
# line 513 "a56.y"
{w0 |= 0x27 | yypvt[-0].ival << 3;} break;
case 64:
# line 516 "a56.y"
{w0 |= 0x32 | yypvt[-0].ival << 3;} break;
case 65:
# line 518 "a56.y"
{w0 |= 0x33 | yypvt[-0].ival << 3;} break;
case 66:
# line 520 "a56.y"
{w0 |= 0x36 | yypvt[-0].ival << 3;} break;
case 67:
# line 522 "a56.y"
{w0 |= 0x37 | yypvt[-0].ival << 3;} break;
case 68:
# line 525 "a56.y"
{w0 |= 0x21 | yypvt[-0].ival << 3;} break;
case 69:
# line 527 "a56.y"
{w0 |= 0x25 | yypvt[-0].ival << 3;} break;
case 70:
# line 531 "a56.y"
{yyval.ival = yypvt[-3].ival | yypvt[-0].ival << 1 | yypvt[-2].ival << 2;} break;
case 71:
# line 536 "a56.y"
{yyval.ival = 0;} break;
case 72:
# line 538 "a56.y"
{yyval.ival = 1;} break;
case 73:
# line 540 "a56.y"
{yyval.ival = 0;} break;
case 74:
# line 545 "a56.y"
{switch (yypvt[-2].ival << 4 | yypvt[-0].ival) {
				case 0x00: yyval.ival = 0x0; break;
				case 0x01: 
				case 0x10: yyval.ival = 0x2; break;
				case 0x11: 
					yyerror("illegal source operands"); 
					break;
			}} break;
case 75:
# line 554 "a56.y"
{switch (yypvt[-2].ival << 4 | yypvt[-0].ival) {
				case 0x00: yyval.ival = 0x1; break;
				case 0x01: 
				case 0x10: yyval.ival = 0x3; break;
				case 0x11: 
					yyerror("illegal source operands"); 
					break;
			}} break;
case 76:
# line 563 "a56.y"
{switch (yypvt[-2].ival << 4 | yypvt[-0].ival) {
				case 0x00: yyval.ival = 0x5; break;
				case 0x01: yyval.ival = 0x4; break;
				case 0x10: yyval.ival = 0x6; break;
				case 0x11: yyval.ival = 0x7; break;
			}} break;
case 77:
# line 570 "a56.y"
{switch (yypvt[-2].ival << 4 | yypvt[-0].ival) {
				case 0x00: yyval.ival = 0x5; break;
				case 0x01: yyval.ival = 0x6; break;
				case 0x10: yyval.ival = 0x4; break;
				case 0x11: yyval.ival = 0x7; break;
			}} break;
case 78:
# line 579 "a56.y"
{yyval.ival = 0x2;} break;
case 79:
# line 581 "a56.y"
{yyval.ival = 0x3;} break;
case 80:
# line 583 "a56.y"
{yyval.ival = 0x4 | yypvt[-0].ival;} break;
case 81:
# line 585 "a56.y"
{yyval.ival = 0x6 | yypvt[-0].ival;} break;
case 82:
# line 587 "a56.y"
{yyval.ival = 0x8 | yypvt[-2].ival << 2 | yypvt[-0].ival;} break;
case 83:
# line 589 "a56.y"
{yyval.ival = 0xA | yypvt[-2].ival << 2 | yypvt[-0].ival;} break;
case 84:
# line 593 "a56.y"
{yyval.ival = 0x0;} break;
case 85:
# line 595 "a56.y"
{yyval.ival = 0x1;} break;
case 86:
# line 597 "a56.y"
{yyval.ival = 0x8 | yypvt[-2].ival << 2 | yypvt[-0].ival;} break;
case 87:
# line 599 "a56.y"
{yyval.ival = 0xA | yypvt[-2].ival << 2 | yypvt[-0].ival;} break;
case 88:
# line 603 "a56.y"
{yyval.ival = 0x0;} break;
case 89:
# line 605 "a56.y"
{yyval.ival = 0x1;} break;
case 90:
# line 607 "a56.y"
{yyval.ival = 0x0;} break;
case 91:
# line 609 "a56.y"
{yyval.ival = 0x1;} break;
case 92:
# line 613 "a56.y"
{yyval.ival = yypvt[-0].ival;} break;
case 93:
# line 617 "a56.y"
{yyval.ival = 0x0 | yypvt[-2].ival << 2 | yypvt[-0].ival;} break;
case 94:
# line 619 "a56.y"
{yyval.ival = 0x2 | yypvt[-2].ival << 2 | yypvt[-0].ival;} break;
case 95:
# line 623 "a56.y"
{yyval.ival = yypvt[-0].ival;} break;
case 96:
# line 627 "a56.y"
{yyval.ival = yypvt[-0].ival;} break;
case 97:
# line 631 "a56.y"
{yyval.ival = 0x0 | yypvt[-0].ival;} break;
case 98:
# line 633 "a56.y"
{yyval.ival = 0x2 | yypvt[-0].ival;} break;
case 99:
# line 637 "a56.y"
{yyval.ival = 0;} break;
case 100:
# line 639 "a56.y"
{yyval.ival = 1;} break;
case 101:
# line 644 "a56.y"
{if(just_rep == 1)
				yyerror("instruction not allowed after REP");} break;
case 105:
# line 655 "a56.y"
{w0 |= 0x01D815 | yypvt[-2].ival << 8 | yypvt[-0].ival << 3;} break;
case 106:
# line 657 "a56.y"
{w0 |= 0x018040 | yypvt[-0].ival << 3;} break;
case 107:
# line 659 "a56.y"
{w0 |= 0x0000F8 | (n2int(yypvt[-2].n) & 0xFF) << 8 | yypvt[-0].ival;} break;
case 108:
# line 661 "a56.y"
{w0 |= 0x0000B8 | (n2int(yypvt[-2].n) & 0xFF) << 8 | yypvt[-0].ival;} break;
case 113:
# line 676 "a56.y"
{if(yypvt[-0].ival) {
				w0 |= 0x0BC0A0 | yypvt[-1].cond << 0;
			} else {
				w0 |= 0x0F0000 | yypvt[-1].cond << 12;
			}} break;
case 114:
# line 682 "a56.y"
{if(yypvt[-0].ival) {
				w0 |= 0x0AC0A0 | yypvt[-1].cond << 0;
			} else {
				w0 |= 0x0E0000 | yypvt[-1].cond << 12;
			}} break;
case 115:
# line 688 "a56.y"
{if(yypvt[-0].ival) {
				w0 |= 0x0BC080;
			} else {
				w0 |= 0x0D0000;
			}} break;
case 116:
# line 694 "a56.y"
{if(yypvt[-0].ival) {
				w0 |= 0x0AC080;
			} else {
				w0 |= 0x0C0000;
			}} break;
case 117:
# line 701 "a56.y"
{w0 |= 0x0B0020;} break;
case 118:
# line 703 "a56.y"
{w0 |= 0x0B0000;} break;
case 119:
# line 705 "a56.y"
{w0 |= 0x0A0020;} break;
case 120:
# line 707 "a56.y"
{w0 |= 0x0A0000;} break;
case 121:
# line 710 "a56.y"
{just_rep = 2;} break;
case 122:
# line 712 "a56.y"
{uses_w1++;} break;
case 123:
# line 714 "a56.y"
{w0 |= 0x00008C;} break;
case 124:
# line 716 "a56.y"
{w0 |= 0x000087;} break;
case 125:
# line 718 "a56.y"
{w0 |= 0x000086;} break;
case 126:
# line 720 "a56.y"
{w0 |= 0x000084;} break;
case 127:
# line 722 "a56.y"
{w0 |= 0x00000C;} break;
case 128:
# line 724 "a56.y"
{w0 |= 0x000006;} break;
case 129:
# line 726 "a56.y"
{w0 |= 0x000005;} break;
case 130:
# line 728 "a56.y"
{w0 |= 0x000004;} break;
case 131:
# line 730 "a56.y"
{w0 |= 0x000000;
			just_rep = 0;} break;
case 132:
# line 735 "a56.y"
{int ival = n2int(yypvt[-2].n);
			w0 |= 0x060080 | (ival & 0xFF) << 8 | (ival & 0xF00)>> 8;
			if(ival > 0xFFF && pass == 2) {
				yyerror("warning: immediate operand truncated");
			}
			w1 |= yypvt[-0].ival-1;} break;
case 133:
# line 742 "a56.y"
{w0 |= 0x06C000 | yypvt[-2].regs.r6 << 8;
			w1 |= yypvt[-0].ival-1;} break;
case 134:
# line 745 "a56.y"
{w0 |= 0x064000 | yypvt[-2].ival << 8 | yypvt[-3].ival << 6;
			w1 |= yypvt[-0].ival-1;} break;
case 135:
# line 748 "a56.y"
{w0 |= 0x060000 | (yypvt[-2].ival & 0x3F) << 8 | yypvt[-3].ival << 6;
			if(yypvt[-2].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			w1 |= yypvt[-0].ival-1;} break;
case 136:
# line 753 "a56.y"
{w0 |= 0x060000 | (yypvt[-2].ival & 0x3F) << 8 | yypvt[-3].ival << 6;
			if(yypvt[-2].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			w1 |= yypvt[-0].ival-1;} break;
case 137:
# line 761 "a56.y"
{int ival = n2int(yypvt[-0].n);
			w0 |= 0x0600A0 | (ival & 0xFF) << 8 | (ival & 0xF00)>> 8;
			if(ival > 0xFFF && pass == 2) {
				yyerror("warning: immediate operand truncated");
			}} break;
case 138:
# line 767 "a56.y"
{w0 |= 0x06C020 | yypvt[-0].regs.r6 << 8;} break;
case 139:
# line 769 "a56.y"
{w0 |= 0x064020 | yypvt[-1].ival << 6 | yypvt[-0].ival << 8;} break;
case 140:
# line 771 "a56.y"
{w0 |= 0x060020 | yypvt[-1].ival << 6 | (yypvt[-0].ival & 0x3F) << 8;
			if(yypvt[-0].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			} break;
case 141:
# line 776 "a56.y"
{w0 |= 0x060020 | yypvt[-1].ival << 6 | (yypvt[-0].ival & 0x3F) << 8;
			if(yypvt[-0].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			} break;
case 142:
# line 784 "a56.y"
{w0 |= yypvt[-5].ival << 0 | yypvt[-3].ival << 6;
			uses_w1++;
			w1 = yypvt[-0].ival;} break;
case 143:
# line 788 "a56.y"
{w0 |= 0x00C000 | yypvt[-4].ival << 0 | yypvt[-2].regs.r6 << 8;
			uses_w1++;
			w1 = yypvt[-0].ival;} break;
case 144:
# line 799 "a56.y"
{if(yypvt[-0].ival != -1) {	/* symbol defined */
				w0 |= (yypvt[-0].ival & 0x3F) << 8;
				if(yypvt[-0].ival >= 0xFFC0) {
					w0 |= 0x008080;
				} else {
					w0 |= 0x000080;
					if(yypvt[-0].ival > 0x003F && pass == 2)
						yyerror("warning: address operand truncated");
				}
			}} break;
case 145:
# line 810 "a56.y"
{if(yypvt[-0].ival != -1) {
				if(yypvt[-0].ival > 0x3F && pass == 2)
					yyerror("warning: address operand truncated");
				w0 |= 0x000080 | (yypvt[-0].ival & 0x3F) << 8;
			}} break;
case 146:
# line 816 "a56.y"
{if(yypvt[-0].ival != -1) {
				if(yypvt[-0].ival < 0xFFC0 && pass == 2)
					yyerror("warning: address operand truncated");
				w0 |= 0x008080 | (yypvt[-0].ival & 0x3F) << 8;
			}} break;
case 147:
# line 822 "a56.y"
{w0 |= 0x004080 | yypvt[-0].ival << 8;} break;
case 148:
# line 829 "a56.y"
{w0 |= 0x0B0020;} break;
case 149:
# line 831 "a56.y"
{w0 |= 0x0B0000;} break;
case 150:
# line 833 "a56.y"
{w0 |= 0x0A0020;} break;
case 151:
# line 835 "a56.y"
{w0 |= 0x0A0000;} break;
case 152:
# line 840 "a56.y"
{w0 |= yypvt[-3].ival << 0 | yypvt[-1].ival << 6;} break;
case 153:
# line 842 "a56.y"
{w0 |= 0x00C040 | yypvt[-2].ival << 0 | yypvt[-0].regs.r6 << 8;} break;
case 154:
# line 847 "a56.y"
{if(yypvt[-0].ival != -1) {
				w0 |= (yypvt[-0].ival & 0x3F) << 8 | 0x008000;
				if(yypvt[-0].ival < 0xFFC0 && pass == 2)
					yyerror("warning: address operand truncated");
			}} break;
case 155:
# line 853 "a56.y"
{if(yypvt[-0].ival != -1) {
				w0 |= (yypvt[-0].ival & 0x3F) << 8 | 0x000000;
				if(yypvt[-0].ival > 0x003F && pass == 2)
					yyerror("warning: address operand truncated");
			}} break;
case 156:
# line 859 "a56.y"
{w0 |= 0x004000;} break;
case 160:
# line 869 "a56.y"
{w0 |= 0x044010 | yypvt[-2].ival << 8 | yypvt[-0].regs.r4;} break;
case 161:
# line 871 "a56.y"
{w0 |= yypvt[-1].cond << 12;} break;
case 162:
# line 876 "a56.y"
{w0 |= 0x020000 | yypvt[-0].ival << 3;} break;
case 163:
# line 878 "a56.y"
{w0 |= 0x030000 | yypvt[-3].ival << 3 | yypvt[-2].ival << 8 | yypvt[-0].ival;} break;
case 164:
# line 882 "a56.y"
{if(yypvt[-2].regs.flags & R_AB && yypvt[-0].regs.flags & R_AB) {
				if(yypvt[-2].regs.ab == yypvt[-0].regs.ab) 
					yyerror("source and dest must be different");
				yyval.ival = yypvt[-0].regs.ab;
			} else if(yypvt[-2].regs.flags & R_XREG && yypvt[-0].regs.flags & R_AB) {
				yyval.ival = 0x8 | yypvt[-2].regs.xreg << 2 | yypvt[-0].regs.ab;
			} else if(yypvt[-2].regs.flags & R_YREG && yypvt[-0].regs.flags & R_AB) {
				yyval.ival = 0xA | yypvt[-2].regs.yreg << 2 | yypvt[-0].regs.ab;
			} else 
				yyerror("illegal TCC operands");
			} break;
case 165:
# line 896 "a56.y"
{if(yypvt[-2].regs.flags & R_XREG && yypvt[-0].regs.flags & R_AB) {
				yyval.ival = yypvt[-2].regs.xreg << 2 | yypvt[-0].regs.ab;
			} else if(yypvt[-2].regs.flags & R_YREG && yypvt[-0].regs.flags & R_AB) {
				yyval.ival = yypvt[-2].regs.yreg << 2 | 2 | yypvt[-0].regs.ab;
			}} break;
case 166:
# line 905 "a56.y"
{if(yypvt[-3].ival == 0) {
				w0 |= 0x05C020 | yypvt[-0].regs.ctl_reg;
			} else {
				w0 |= 0x05C060 | yypvt[-0].regs.ctl_reg;
			}} break;
case 167:
# line 911 "a56.y"
{if(yypvt[-1].ival == 0) {
				w0 |= 0x054020 | yypvt[-3].regs.ctl_reg;
			} else {
				w0 |= 0x054060 | yypvt[-3].regs.ctl_reg;
			}} break;
case 168:
# line 917 "a56.y"
{int ival = n2int(yypvt[-2].n);
			if(ival < 256 && NOT long_symbolic_expr) {
				w0 |= 0x0500A0 | (ival & 0xFF) << 8 | yypvt[-0].regs.ctl_reg; 
			} else {
				w0 |= 0x05C020 | 0x003400 | yypvt[-0].regs.ctl_reg;
				uses_w1++; w1 = ival & 0xFFFF;
			}} break;
case 169:
# line 925 "a56.y"
{if(yypvt[-3].ival == 0) {
				w0 |= 0x058020 | (yypvt[-2].ival & 0x3F) << 8 | yypvt[-0].regs.ctl_reg;
			} else {
				w0 |= 0x058060 | (yypvt[-2].ival & 0x3F) << 8 | yypvt[-0].regs.ctl_reg;
			}
			if(yypvt[-2].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			} break;
case 170:
# line 934 "a56.y"
{if(yypvt[-1].ival == 0) {
				w0 |= 0x050020 | (yypvt[-0].ival & 0x3F) << 8 | yypvt[-3].regs.ctl_reg;
			} else {
				w0 |= 0x050060 | (yypvt[-0].ival & 0x3F) << 8 | yypvt[-3].regs.ctl_reg;
			}
			if(yypvt[-0].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			} break;
case 171:
# line 943 "a56.y"
{if(yypvt[-2].regs.flags & R_CTL_REG) {
				w0 |= 0x0440A0 | yypvt[-0].regs.r6 << 8 | yypvt[-2].regs.ctl_reg;
			} else if(yypvt[-0].regs.flags & R_CTL_REG) {
				w0 |= 0x04C0A0 | yypvt[-2].regs.r6 << 8 | yypvt[-0].regs.ctl_reg;
			} else if(yypvt[-2].regs.flags & yypvt[-0].regs.flags & R_CTL_REG) {
				/* bogus? $$$ */
	       			w0 |= 0x04C0A0 | (yypvt[-2].regs.ctl_reg | 0x20) << 8 | 
				yypvt[-0].regs.ctl_reg;
			} else {
				yyerror("MOVEC must reference a control reg");
			}} break;
case 172:
# line 958 "a56.y"
{w0 |= 0x084080;
			switch(yypvt[-3].ea.pp << 1 | yypvt[-0].ea.pp) {
				case 0:	case 3:
					yyerror("illegal MOVEP; can't move EA to EA or IO to IO");
					break;
				case 1:	/* ea, pp */
					w0 |= yypvt[-1].ival << 16 | 1 << 15 | yypvt[-4].ival << 6 |
						(yypvt[-0].ea.ext & 0x3F);
					if(yypvt[-3].ea.mode == 0x003000) {
						w0 |= 0x003000;
						uses_w1++;
						w1 = yypvt[-3].ea.ext;
					} else {
						w0 |= yypvt[-3].ea.mode;
					}
					break;
				case 2:	/* pp, ea */
					w0 |= yypvt[-4].ival << 16 | 0 << 15 | yypvt[-1].ival << 6 |
						(yypvt[-3].ea.ext & 0x3F);
					if(yypvt[-0].ea.mode == 0x003000) {
						w0 |= 0x003000;
						uses_w1++;
						w1 = yypvt[-0].ea.ext;
					} else {
						w0 |= yypvt[-0].ea.mode;
					}
					break;
			}} break;
case 173:
# line 987 "a56.y"
{w0 |= 0x084080;
			w0 |= yypvt[-1].ival << 16 | 1 << 15 | 0x34 << 8 | 
				(n2int(yypvt[-0].n) & 0x3F);
			uses_w1++;
			w1 = n2int(yypvt[-3].n);} break;
case 174:
# line 993 "a56.y"
{w0 |= 0x084040;
			w0 |= yypvt[-1].ival << 16 | 1 << 15 | (n2int(yypvt[-0].n) & 0x3F);} break;
case 175:
# line 996 "a56.y"
{w0 |= 0x084040;
			if(yypvt[-3].ea.mode != 0x003000 && yypvt[-3].ea.mode != 0)
				yyerror("illegal MOVEP");
			w0 |= yypvt[-4].ival << 16 | 0 << 15 | (yypvt[-3].ea.ext & 0x3F);} break;
case 176:
# line 1001 "a56.y"
{w0 |= 0x084000;
			w0 |= yypvt[-1].ival << 16 | 1 << 15 | yypvt[-3].regs.r6 << 8 | 
				(n2int(yypvt[-0].n) & 0x3F);} break;
case 177:
# line 1005 "a56.y"
{w0 |= 0x084000;
			if(!yypvt[-2].ea.pp)
				yyerror("illegal MOVEP");
			w0 |= yypvt[-3].ival << 16 | 0 << 15 | yypvt[-0].regs.r6 << 8 | (yypvt[-2].ea.ext & 0x3F);} break;
case 178:
# line 1013 "a56.y"
{if(yypvt[-0].ival != UNDEF && yypvt[-0].ival >= 0xFFC0) {
				/* defined symbol or constant, in i/o range */
				yyval.ea.pp = 1;
				yyval.ea.mode = 0;
			} else {
				/* either out of i/o range or symbol not */
				/* yet defined:  assume ea extension */
				yyval.ea.pp = 0;
				yyval.ea.mode = 0x003000;
			}
			yyval.ea.ext = yypvt[-0].ival;} break;
case 179:
# line 1025 "a56.y"
{yyval.ea.pp = 1;
			yyval.ea.mode = 0;
			if(yypvt[-0].ival < 0xFFC0 && pass == 2)
				yyerror("warning: address operand truncated");
			yyval.ea.ext = yypvt[-0].ival;} break;
case 180:
# line 1031 "a56.y"
{yyval.ea.pp = 0;
			yyval.ea.mode = yypvt[-0].ival << 8;
			yyval.ea.ext = yypvt[-0].ival;} break;
case 181:
# line 1038 "a56.y"
{w0 |= 0x070000 | 0 << 15 | yypvt[-3].regs.r6;} break;
case 182:
# line 1040 "a56.y"
{w0 |= 0x070000 | 1 << 15 | yypvt[-0].regs.r6;} break;
case 183:
# line 1047 "a56.y"
{int ival = n2int(yypvt[-0].n);
			yyval.ival = ival; if(ival > 0x17) 
				yyerror("%d: illegal bit number", ival);} break;
case 184:
# line 1053 "a56.y"
{yyval.ival = 0;} break;
case 185:
# line 1055 "a56.y"
{yyval.ival = 1;} break;
case 186:
# line 1061 "a56.y"
{w0 |= 0x004080;} break;
case 187:
# line 1063 "a56.y"
{w0 |= (yypvt[-0].ival & 0x3F) << 8;
			if(yypvt[-0].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			} break;
case 188:
# line 1070 "a56.y"
{yyval.ival = 1;} break;
case 189:
# line 1072 "a56.y"
{w0 |= yypvt[-0].ival & 0xFFF; yyval.ival = 0;
			if(yypvt[-0].ival > 0x0FFF && pass == 2)
				yyerror("warning: address operand truncated");
			} break;
case 190:
# line 1079 "a56.y"
{w0 |= 0x003000;
			uses_w1++;
			w1 |= yypvt[-0].ival;
			yyval.ival = 0x003000;} break;
case 191:
# line 1084 "a56.y"
{w0 |= yypvt[-0].ival << 8;
			yyval.ival = yypvt[-0].ival << 8;} break;
case 192:
# line 1090 "a56.y"
{yyval.ival = yypvt[-0].ival;} break;
case 193:
# line 1092 "a56.y"
{yyval.ival = 4 << 3 | yypvt[-1].ival;} break;
case 194:
# line 1094 "a56.y"
{yyval.ival = 5 << 3 | yypvt[-3].ival;
			if(yypvt[-3].ival != yypvt[-1].ival) yyerror("Rn and Nn must be same number");} break;
case 195:
# line 1097 "a56.y"
{yyval.ival = 7 << 3 | yypvt[-1].ival;} break;
case 196:
# line 1102 "a56.y"
{yyval.ival = 0 << 3 | yypvt[-3].ival;
			if(yypvt[-3].ival != yypvt[-0].ival) yyerror("Rn and Nn must be same number");} break;
case 197:
# line 1105 "a56.y"
{yyval.ival = 1 << 3 | yypvt[-3].ival;
			if(yypvt[-3].ival != yypvt[-0].ival) yyerror("Rn and Nn must be same number");} break;
case 198:
# line 1108 "a56.y"
{yyval.ival = 2 << 3 | yypvt[-2].ival;} break;
case 199:
# line 1110 "a56.y"
{yyval.ival = 3 << 3 | yypvt[-2].ival;} break;
case 200:
# line 1116 "a56.y"
{yyval.regs.r6 = yyval.regs.r5 = 0x04 | yypvt[-0].ival;
			yyval.regs.sdx = yypvt[-0].ival;
			yyval.regs.xreg = yypvt[-0].ival;
			yyval.regs.flags = R_R6|R_R5|R_XREG|R_SDX|R_SFRAC;} break;
case 201:
# line 1121 "a56.y"
{yyval.regs.r6 = yyval.regs.r5 = 0x06 | yypvt[-0].ival;
			yyval.regs.sdy = yypvt[-0].ival;
			yyval.regs.yreg = yypvt[-0].ival;
			yyval.regs.flags = R_R6|R_R5|R_SDY|R_YREG|R_SFRAC;} break;
case 202:
# line 1126 "a56.y"
{switch(yypvt[-0].ival) {
				case 0: 
					yyval.regs.r6 = yyval.regs.r5 = 0x08 | 0; 
					break;
				case 1: 
					yyval.regs.r6 = yyval.regs.r5 = 0x08 | 4; 
					break;
				case 2: 
					yyval.regs.r6 = yyval.regs.r5 = 0x08 | 2; 
					break;
			}
			yyval.regs.flags = R_R6|R_R5|R_UINT;} break;
case 203:
# line 1139 "a56.y"
{switch(yypvt[-0].ival) {
				case 0: 
					yyval.regs.r6 = yyval.regs.r5 = 0x08 | 1; break;
				case 1: 
					yyval.regs.r6 = yyval.regs.r5 = 0x08 | 5; break;
				case 2: 
					yyval.regs.r6 = yyval.regs.r5 = 0x08 | 3; break;
			}
			yyval.regs.flags = R_R6|R_R5|R_UINT;} break;
case 204:
# line 1149 "a56.y"
{yyval.regs.r6 = yyval.regs.r5 = 0x0E;
			yyval.regs.sdx = yyval.regs.sdy = 0x2;
			yyval.regs.ab = 0;
			yyval.regs.lsd = 4;
			yyval.regs.flags = R_R6|R_R5|R_SDX|R_SDY|R_AB|R_LSD|R_SFRAC;} break;
case 205:
# line 1155 "a56.y"
{yyval.regs.r6 = yyval.regs.r5 = 0x0F;
			yyval.regs.sdx = yyval.regs.sdy = 0x3;
			yyval.regs.ab = 1;
			yyval.regs.lsd = 5;
			yyval.regs.flags = R_R6|R_R5|R_SDX|R_SDY|R_AB|R_LSD|R_SFRAC;} break;
case 206:
# line 1161 "a56.y"
{yyval.regs.r6 = yyval.regs.r5 = 0x10 | yypvt[-0].ival;
			yyval.regs.r4 = 0x00 | yypvt[-0].ival;
			yyval.regs.flags = R_R6|R_R5|R_R4|R_UINT;} break;
case 207:
# line 1165 "a56.y"
{yyval.regs.r6 = yyval.regs.r5 = 0x18 | yypvt[-0].ival;
			yyval.regs.r4 = 0x08 | yypvt[-0].ival;
			yyval.regs.flags = R_R6|R_R5|R_R4|R_UINT;} break;
case 208:
# line 1169 "a56.y"
{yyval.regs.r6 = 0x20 | yypvt[-0].ival;
			yyval.regs.r5 = -1;
			yyval.regs.ctl_reg = yypvt[-0].ival;
			yyval.regs.flags = R_R6|R_R5|R_CTL_REG|R_UINT;} break;
case 209:
# line 1174 "a56.y"
{yyval.regs.r6 = 0x38 | yypvt[-0].ival;
			yyval.regs.r5 = -1;
			yyval.regs.ctl_reg = 0x18 | yypvt[-0].ival;
			yyval.regs.flags = R_R6|R_R5|R_CTL_REG|R_UINT;} break;
case 210:
# line 1179 "a56.y"
{yyval.regs.lsd  = 0;
			yyval.regs.flags = R_LSD;} break;
case 211:
# line 1182 "a56.y"
{yyval.regs.lsd = 1;
			yyval.regs.flags = R_LSD;} break;
case 212:
# line 1185 "a56.y"
{yyval.regs.lsd = 2;
			yyval.regs.flags = R_LSD;} break;
case 213:
# line 1188 "a56.y"
{yyval.regs.lsd = 3;
			yyval.regs.flags = R_LSD;} break;
case 214:
# line 1191 "a56.y"
{yyval.regs.lsd = 6;
			yyval.regs.flags = R_LSD;} break;
case 215:
# line 1194 "a56.y"
{yyval.regs.lsd = 7;
			yyval.regs.flags = R_LSD;} break;
case 216:
# line 1200 "a56.y"
{yyval.ival = 1;} break;
case 217:
# line 1202 "a56.y"
{yyval.ival = 2;} break;
case 218:
# line 1204 "a56.y"
{yyval.ival = 3;} break;
case 219:
# line 1206 "a56.y"
{yyval.ival = 4;} break;
case 220:
# line 1208 "a56.y"
{yyval.ival = 5;} break;
case 221:
# line 1210 "a56.y"
{yyval.ival = 6;} break;
case 222:
# line 1212 "a56.y"
{yyval.ival = 7;} break;
case 223:
# line 1217 "a56.y"
{yyval.ival = 0;} break;
case 224:
# line 1219 "a56.y"
{yyval.ival = 1;} break;
case 225:
# line 1221 "a56.y"
{yyval.ival = 2;} break;
case 234:
# line 1238 "a56.y"
{int ival = n2int(yypvt[-2].n);
			int frac = n2frac(yypvt[-2].n);
			int value;
			BOOL shortform = FALSE;
			if(yypvt[-0].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			if(yypvt[-0].regs.flags & R_SFRAC && yypvt[-2].n.type == FLT) {
				if((frac & 0xFFFF) == 0 && 
					NOT long_symbolic_expr) {
					value = frac >> 16;
					shortform++;
				} else {
					value = frac;
				}
			} else {
				if(ival <= 0xFF && NOT long_symbolic_expr) {
					value = ival;
					shortform++;
				} else {
					value = ival;
				}
			}

			if(shortform) {
				w0 |= 0x200000 | (value & 0xFF) << 8 |
					yypvt[-0].regs.r5 << 16;
			} else {
				w0 |= 0x400000 | 0x00F400 |
					(yypvt[-0].regs.r5 >> 3 & 3) << 20 | 
					(yypvt[-0].regs.r5 & 7) << 16;
				uses_w1++; w1 = value;
			}} break;
case 235:
# line 1275 "a56.y"
{
				if(yypvt[-0].regs.flags & R_CTL_REG) {
					yyerror("please use MOVEC for control register moves");
					break;
				}
				if(yypvt[-2].regs.flags & R_R5 & yypvt[-0].regs.flags) 
					w0 |= 0x200000 | yypvt[-0].regs.r5 << 8 | yypvt[-2].regs.r5 << 13;
				else
					yyerror("illegal R move");
			} break;
case 236:
# line 1288 "a56.y"
{w0 |= 0x204000 | yypvt[-0].ival << 8;} break;
case 237:
# line 1293 "a56.y"
{w0 |= 0x40C000 | yypvt[-3].ival << 19;
			if(yypvt[-0].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			w0 |= (yypvt[-0].regs.r5 >> 3 & 3) << 20 | (yypvt[-0].regs.r5 & 7) << 16;} break;
case 238:
# line 1300 "a56.y"
{w0 |= 0x408000 | yypvt[-3].ival << 19 | (yypvt[-2].ival & 0x3F) << 8;
			if(yypvt[-0].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			if(yypvt[-2].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			w0 |= (yypvt[-0].regs.r5>> 3 & 3) << 20 | (yypvt[-0].regs.r5 & 7) << 16;} break;
case 239:
# line 1309 "a56.y"
{w0 |= 0x404000 | yypvt[-1].ival << 19;
			if(yypvt[-3].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			w0 |= (yypvt[-3].regs.r5 >> 3 & 3) << 20 | (yypvt[-3].regs.r5 & 7) << 16;} break;
case 240:
# line 1316 "a56.y"
{w0 |= 0x400000 | yypvt[-1].ival << 19 | (yypvt[-0].ival & 0x3F) << 8;
			if(yypvt[-3].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			if(yypvt[-0].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			w0 |= (yypvt[-3].regs.r5 >> 3 & 3) << 20 | (yypvt[-3].regs.r5 & 7) << 16;} break;
case 241:
# line 1325 "a56.y"
{w0 |= 0x400000 | 0x00F400 | (yypvt[-0].regs.r5 >> 3 & 3) << 20 |
			    (yypvt[-0].regs.r5 & 7) << 16;
			if(yypvt[-0].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			uses_w1++; w1 = n2frac(yypvt[-2].n);
			} break;
case 242:
# line 1336 "a56.y"
{if(yypvt[-6].ival == 0 && yypvt[-2].regs.flags & R_AB) {
				w0 |= 0x108000 | yypvt[-3].regs.sdx << 18 | yypvt[-2].regs.ab << 17 |
					yypvt[-0].ival << 16;
			} else {
				yyerror("illegal X:R move");
			}} break;
case 243:
# line 1343 "a56.y"
{if(yypvt[-2].regs.flags & R_AB) {
				w0 |= 0x10B400 | yypvt[-3].regs.sdx << 18 | yypvt[-2].regs.ab << 17 |
					yypvt[-0].ival << 16;
				uses_w1++;
				w1 |= n2frac(yypvt[-5].n) & 0xFFFFFF;
			} else {
				yyerror("illegal X:R move");
			}} break;
case 244:
# line 1352 "a56.y"
{if(yypvt[-6].regs.flags & R_SDX && yypvt[-4].ival == 0 && yypvt[-2].regs.flags & R_AB &&
				yypvt[-0].regs.flags & R_YREG) {
				w0 |= 0x100000 | yypvt[-6].regs.sdx << 18 | yypvt[-2].regs.ab << 17 |
					yypvt[-0].regs.yreg << 16;
			} else if(yypvt[-6].regs.flags & R_AB && yypvt[-4].ival == 0 && 
				yypvt[-2].regs.flags & R_XREG && yypvt[-0].regs.flags & R_AB) {
				if(yypvt[-2].regs.xreg != 0) yyerror("must use X0");
				if(yypvt[-6].regs.ab == 0 && yypvt[-0].regs.ab == 0)
					w0 |= 0x080000;
				else if(yypvt[-6].regs.ab == 1 && yypvt[-0].regs.ab == 1)
					w0 |= 0x090000;
				else
					yyerror("illegal X:R move");
			} else {
				yyerror("illegal X:R move");
			}} break;
case 245:
# line 1371 "a56.y"
{if(yypvt[-4].regs.flags & R_XREG && yypvt[-0].regs.flags & (R_YREG|R_AB)) {
				w0 |= 0x10C000 | yypvt[-6].regs.ab << 19 | yypvt[-4].regs.xreg << 18 |
					yypvt[-0].regs.sdy << 16;
			} else {
				yyerror("illegal R:Y move");
			}} break;
case 246:
# line 1378 "a56.y"
{if(yypvt[-3].regs.flags & R_XREG && yypvt[-0].regs.flags & (R_YREG|R_AB)) {
				w0 |= 0x10F400 | yypvt[-5].regs.ab << 19 | yypvt[-3].regs.xreg << 18 |
					yypvt[-0].regs.sdy << 16;
				uses_w1++;
				w1 |= n2frac(yypvt[-2].n) & 0xFFFFFF;
			} else {
				yyerror("illegal R:Y move");
			}} break;
case 247:
# line 1387 "a56.y"
{if(yypvt[-6].regs.flags & R_AB && yypvt[-4].regs.flags & R_XREG) {
				w0 |= 0x104000 | yypvt[-6].regs.ab << 19 | yypvt[-4].regs.xreg << 18 |
				yypvt[-3].regs.sdy << 16;
			} else if (yypvt[-6].regs.flags & R_YREG && yypvt[-4].regs.flags & R_AB &&
				yypvt[-3].regs.flags & R_AB) {
				if(yypvt[-6].regs.yreg != 0) yyerror("must use Y0");
				if(yypvt[-4].regs.ab == 0 && yypvt[-3].regs.ab == 0)
					w0 |= 0x088000;
				else if(yypvt[-4].regs.ab == 1 && yypvt[-3].regs.ab == 1)
					w0 |= 0x098000;
				else
					yyerror("illegal R:Y move");
			} else {
				yyerror("illegal R:Y move");
			}} break;
case 248:
# line 1405 "a56.y"
{if(yypvt[-0].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			w0 |= 0x40C000 | (yypvt[-0].regs.lsd & 3) << 16 | (yypvt[-0].regs.lsd >> 2) << 19;} break;
case 249:
# line 1411 "a56.y"
{if(yypvt[-3].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			w0 |= 0x404000 | (yypvt[-3].regs.lsd & 3) << 16 | (yypvt[-3].regs.lsd >> 2) << 19;} break;
case 250:
# line 1417 "a56.y"
{w0 |= 0x408000 | (yypvt[-0].regs.lsd & 3) << 16 | (yypvt[-0].regs.lsd >> 2) << 19;
			if(yypvt[-0].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			if(yypvt[-2].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			w0 |= (yypvt[-2].ival & 0x3F) << 8;} break;
case 251:
# line 1426 "a56.y"
{w0 |= 0x400000 | (yypvt[-3].regs.lsd & 3) << 16 | (yypvt[-3].regs.lsd >> 2) << 19;
			if(yypvt[-3].regs.flags & R_CTL_REG) {
				yyerror("please use MOVEC for control register moves");
				break;
			}
			if(yypvt[-0].ival > 0x003F && pass == 2)
				yyerror("warning: address operand truncated");
			w0 |= (yypvt[-0].ival & 0x3F) << 8;} break;
case 252:
# line 1437 "a56.y"
{int eax = yypvt[-6].ival, eay = yypvt[-2].ival,
			     regx = (yypvt[-4].regs.flags & R_AB) ? yypvt[-4].regs.ab | 2 : yypvt[-4].regs.xreg,
			     regy = (yypvt[-0].regs.flags & R_AB) ? yypvt[-0].regs.ab | 2 : yypvt[-0].regs.yreg;
			if((eax & 0x400) == (eay & 0x400))
				yyerror("registers must be in opposite halves");
			if(!(yypvt[-4].regs.flags & (R_AB | R_XREG)))
				yyerror("invalid X move register");
			if(!(yypvt[-0].regs.flags & (R_AB | R_YREG)))
				yyerror("invalid Y move register");
			if(yypvt[-4].regs.flags & R_AB &&
			   yypvt[-0].regs.flags & R_AB &&
			   yypvt[-4].regs.ab == yypvt[-0].regs.ab)
				yyerror("duplicate destination register");
			w0 = w0 & 0xFF | 0xC08000;	/* both write */
			w0 |= eax & 0x1f00 | (eay & 0x300) << 5 | (eay & 0x1800) << 9 | regx << 18 | regy << 16;} break;
case 253:
# line 1453 "a56.y"
{int eax = yypvt[-6].ival, eay = yypvt[-0].ival,
			     regx = (yypvt[-4].regs.flags & R_AB) ? yypvt[-4].regs.ab | 2 : yypvt[-4].regs.xreg,
			     regy = (yypvt[-3].regs.flags & R_AB) ? yypvt[-3].regs.ab | 2 : yypvt[-3].regs.yreg;
			if((eax & 0x400) == (eay & 0x400))
				yyerror("registers must be in opposite halves");
			if(!(yypvt[-4].regs.flags & (R_AB | R_XREG)))
				yyerror("invalid X move register");
			if(!(yypvt[-3].regs.flags & (R_AB | R_YREG)))
				yyerror("invalid Y move register");
			w0 = w0 & 0xFF | 0x808000;	/* X:write, Y:read */
			w0 |= eax & 0x1f00 | (eay & 0x300) << 5 | (eay & 0x1800) << 9 | regx << 18 | regy << 16;} break;
case 254:
# line 1465 "a56.y"
{int eax = yypvt[-4].ival, eay = yypvt[-2].ival,
			     regx = (yypvt[-7].regs.flags & R_AB) ? yypvt[-7].regs.ab | 2 : yypvt[-7].regs.xreg,
			     regy = (yypvt[-0].regs.flags & R_AB) ? yypvt[-0].regs.ab | 2 : yypvt[-0].regs.yreg;
			if((eax & 0x400) == (eay & 0x400))
				yyerror("registers must be in opposite halves");
			if(!(yypvt[-7].regs.flags & (R_AB | R_XREG)))
				yyerror("invalid X move register");
			if(!(yypvt[-0].regs.flags & (R_AB | R_YREG)))
				yyerror("invalid Y move register");
	      		w0 = w0 & 0xFF | 0xC00000;	/* X:read, Y:write */
			w0 |= eax & 0x1f00 | (eay & 0x300) << 5 | (eay & 0x1800) << 9 | regx << 18 | regy << 16;} break;
case 255:
# line 1477 "a56.y"
{int eax = yypvt[-4].ival, eay = yypvt[-0].ival,
			     regx = (yypvt[-7].regs.flags & R_AB) ? yypvt[-7].regs.ab | 2 : yypvt[-7].regs.xreg,
			     regy = (yypvt[-3].regs.flags & R_AB) ? yypvt[-3].regs.ab | 2 : yypvt[-3].regs.yreg;
			if((eax & 0x400) == (eay & 0x400))
				yyerror("registers must be in opposite halves");
			if(!(yypvt[-7].regs.flags & (R_AB | R_XREG)))
				yyerror("invalid X move register");
			if(!(yypvt[-3].regs.flags & (R_AB | R_YREG)))
				yyerror("invalid Y move register");
	      		w0 = w0 & 0xFF | 0x800000;	/* both read */
			w0 |= eax & 0x1f00 | (eay & 0x300) << 5 | (eay & 0x1800) << 9 | regx << 18 | regy << 16;} break;
case 256:
# line 1493 "a56.y"
{yyval.n = yypvt[-0].n;} break;
case 257:
# line 1495 "a56.y"
{yyval.n = yypvt[-0].n;} break;
case 258:
# line 1497 "a56.y"
{yyval.n = yypvt[-0].n;} break;
case 259:
# line 1501 "a56.y"
{yyval.n = yypvt[-0].n;} break;
case 260:
# line 1503 "a56.y"
{yyval.n.val.i = n2int(yypvt[-0].n) & 0xFF;
			yyval.n.type = INT;
			long_symbolic_expr = FALSE;} break;
case 261:
# line 1509 "a56.y"
{yyval.n = yypvt[-0].n;} break;
case 262:
# line 1514 "a56.y"
{yyval.ival = n2int(yypvt[-0].n);} break;
case 263:
# line 1516 "a56.y"
{yyval.ival = pc;} break;
case 264:
# line 1521 "a56.y"
{yyval.ival = n2int(yypvt[-0].n);} break;
case 265:
# line 1523 "a56.y"
{yyval.ival = pc;} break;
case 266:
# line 1528 "a56.y"
{yyval.ival = n2int(yypvt[-0].n);} break;
case 267:
# line 1533 "a56.y"
{yyval.n = yypvt[-0].n;} break;
case 268:
# line 1535 "a56.y"
{yyval.n = sym_ref(yypvt[-0].sval); free(yypvt[-0].sval);} break;
case 269:
# line 1540 "a56.y"
{yyval.n = yypvt[-0].n;} break;
case 270:
# line 1542 "a56.y"
{yyval.n = sym_ref(yypvt[-0].sval); free(yypvt[-0].sval); long_symbolic_expr++;} break;
case 271:
# line 1544 "a56.y"
{yyval.n.type = INT; yyval.n.val.i = yypvt[-0].cval & 0xFFFFFF;} break;
case 272:
# line 1548 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, '|', yypvt[-0].n);} break;
case 273:
# line 1550 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, '^', yypvt[-0].n);} break;
case 274:
# line 1552 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, '&', yypvt[-0].n);} break;
case 275:
# line 1554 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, SHR, yypvt[-0].n);} break;
case 276:
# line 1556 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, SHL, yypvt[-0].n);} break;
case 277:
# line 1558 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, '-', yypvt[-0].n);} break;
case 278:
# line 1560 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, '+', yypvt[-0].n);} break;
case 279:
# line 1562 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, '%', yypvt[-0].n);} break;
case 280:
# line 1564 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, '/', yypvt[-0].n);} break;
case 281:
# line 1566 "a56.y"
{yyval.n = binary_op(yypvt[-2].n, '*', yypvt[-0].n);} break;
case 282:
# line 1568 "a56.y"
{yyval.n = unary_op('-', yypvt[-0].n);} break;
case 283:
# line 1570 "a56.y"
{yyval.n = unary_op('~', yypvt[-0].n);} break;
case 284:
# line 1572 "a56.y"
{yyval.n = yypvt[-1].n;} break;
case 285:
# line 1574 "a56.y"
{yyval.n = yypvt[-0].n;} break;
		}
		goto yystack;  /* stack new state and value */

	}
