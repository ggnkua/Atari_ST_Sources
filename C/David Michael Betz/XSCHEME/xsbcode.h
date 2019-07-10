/* xsbcode.h - xscheme compiler byte code definitions */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#define OP_BRT		0x01	/* branch on true */
#define OP_BRF		0x02	/* branch on false */
#define OP_BR		0x03	/* branch unconditionally */
#define OP_LIT		0x04	/* load literal */
#define OP_GREF		0x05	/* global symbol value */
#define OP_GSET		0x06	/* set global symbol value */
#define OP_EREF		0x09	/* environment variable value */
#define OP_ESET		0x0A	/* set environment variable value */
#define OP_SAVE		0x0B	/* save a continuation */
#define OP_CALL		0x0C	/* call a function */
#define OP_RETURN	0x0D	/* return from a function */
#define OP_T		0x0E	/* load 'val' with t */
#define OP_NIL		0x0F	/* load 'val' with nil */
#define OP_PUSH		0x10	/* push the 'val' register */
#define OP_CLOSE	0x11	/* create a closure */

#define OP_FRAME	0x12	/* create a new enviroment frame */
#define OP_MVARG	0x13	/* move required argument to frame slot */
#define OP_MVOARG	0x14	/* move optional argument to frame slot */
#define OP_MVRARG	0x15	/* build rest argument and move to frame slot */
#define OP_ADROP	0x19	/* drop the rest of the arguments */
#define OP_ALAST	0x1A	/* make sure there are no more arguments */
#define OP_DELAY	0x1B	/* create a promise */

#define OP_AREF		0x1C	/* access a variable in an environment */
#define OP_ASET		0x1D	/* set a variable in an environment */

#define OP_ATOM		0x1E	/* atom predicate */
#define OP_EQ		0x1F	/* eq? predicate */
#define OP_NULL		0x20	/* null? (or not) predicate */
#define OP_CONS		0x21	/* cons */
#define OP_CAR		0x22	/* car */
#define OP_CDR		0x23	/* cdr */
#define OP_SETCAR	0x24	/* set-car! */
#define OP_SETCDR	0x25	/* set-cdr! */

#define OP_ADD		0x40	/* add two numeric expressions */
#define OP_SUB		0x41	/* subtract two numeric expressions */
#define OP_MUL		0x42	/* multiply two numeric expressions */
#define OP_QUO		0x43	/* divide two integer expressions */
#define OP_LSS		0x44	/* less than */
#define OP_EQL		0x45	/* equal to */
#define OP_GTR		0x46	/* greater than */
