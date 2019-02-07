/*
 * EASYC.H	typed in 1/June/86
 *
 * This file contains the constructs used in writing EASY C
 * programs, which are basically C programs with some
 * Pascal-like coding plopped on top of them.
 * From the article EASY C, in May 1986 BYTE.
 *
 */

/* Logical operators	*/

#define	AND	&&	/* logical AND	*/
#define OR	||	/* logical OR	*/
#define NOT	!	/* logical NOT	*/
#define	EQ	==	/* equal value comparison	*/
#define	NE	!=	/* not equal value comparison	*/
#define	LT	<	/* less than value comparison	*/
#define LE	<=	/* less than or equal to value comparison	*/
#define GT	>	/* greater than value comparison		*/
#define GE	>=	/* greater than or equal to value comparison	*/

/* Bitwise operators	*/

#define	BAND	&	/* bitwise AND	*/
#define	BOR	|	/* bitwise OR	*/
#define	BXOR	^	/* bitwise exclusive OR	*/
#define	BNOT	~	/* bitwise NOT	*/
#define	LSHF	<<	/* left shift	*/
#define RSHF	>>	/* right shift	*/

/* Arithmetic operators	*/

#define	INC	++	/* increment	*/
#define DEC	--	/* decrement	*/
#define MOD	%	/* modulo division	*/

/* CONTROL constructs.
 *  Some of these constructs are my own invention, in order
 *  to more easily port ACTION! code to C code.
 */

/* IF_THEN_ELSEIF_ELSE construct	*/

#define IF(e)		{ if (e)		/* if statement		*/
#define THEN		{			/* then statement	*/
#define ELSEIF(e)	} else if (e) {		/* elseif statement	*/
#define ELSE		} else {		/* else statement	*/
#define ENDIF		;} }			/* end of if statement	*/
#define FI		;} }			/* end of if statement	*/

/* CASE construct			*/

#define	CASE(e)		{ switch (e) {		/* head of case		*/
#define	CASEOF(e)	case e: {		/* case block		*/
#define DEFCASE		default: {		/* default case block	*/
#define	ENDCOF		} break;		/* end of case block	*/
#define	ENDCASE		} }			/* end of case		*/

/* WHILE construct			*/

#define	WHILE(e)	{ while (e) {		/* while statement	*/
#define	ENDWHILE	;} }			/* end of while statment*/

/* FOR construct			*/

#define	FOR(e)		{ for (e) {		/* for statement	*/
#define	ENDFOR		;} }			/* end of for statement	*/

/* BEGIN_END construct			*/

#define	BEGIN		{			/* beginning of block	*/
#define	END		}			/* end of block		*/
#define DO		{			/* beginning of block	*/
#define OD		}			/* end of block		*/
