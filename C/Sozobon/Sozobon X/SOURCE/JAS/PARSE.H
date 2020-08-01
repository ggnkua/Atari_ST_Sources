
/*
 * Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Joseph M Treat
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

typedef union {
	long val;
	char *str;
	LIST *list;
	STMT *stmt;
	SYM  *sym;
	EXPR  expr;
	OPERAND *op;
} YYSTYPE;

extern YYSTYPE yylval;

#define _TEXT 257
#define _DATA 258
#define _GLOBL 259
#define _BSS 260
#define _DC 261
#define _COMM 262
#define LP 263
#define RP 264
#define NL 265
#define SEMI 266
#define COMMA 267
#define ERR 268
#define COLON 269
#define COMMENT 270
#define NUMBER 271
#define NAME 272
#define STRING 273
#define OR 274
#define XOR 275
#define AND 276
#define LSH 277
#define RSH 278
#define PLUS 279
#define MINUS 280
#define STAR 281
#define DIV 282
#define MOD 283
#define NOT 284
#define REG 285
#define POUND 286
#define INSTR 287
#define PC 288
#define _EVEN 289
#define _ORG 290
#define _DS 291
#define END 292
#define _EQU 293
#define SREG 294

#ifdef MINIX
#	define _ASCII 295
#	define _SECT  296
#	define _ALIGN 297
#endif
