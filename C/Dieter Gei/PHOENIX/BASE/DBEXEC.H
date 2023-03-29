/*****************************************************************************
 *
 * Module : DBEXEC.H
 * Author : Purex & Jürgen Geiß
 *
 * Creation date    : 01.04.91
 * Last modification: 04.07.95
 *
 *
 * Description: This module defines the database execute routines.
 *
 * History:
 * 04.07.95: O_RETURN added
 * 02.11.94: O_KBVGET added
 * 18.10.94: O_KBVREAD added
 * 07.06.94: O_IMPORT, O_EXPORT added
 * 07.05.93: Macro setjmp undefined in windows version
 * 06.05.93: O_ERRNO added
 * 28.04.93: O_RAND, O_POW, O_ROUND, O_TRUNCATE, O_SIGN, O_KEYCOUNT, O_STRLOWER, O_STRUPPER, O_CHAR, O_WORD, O_LONG, O_FLOAT added
 * 27.04.93: O_SIN, O_COS, O_TAN, O_ASIN, O_ACOS, O_ATAN, O_ABS, O_EXP, O_LN, O_LOG, O_SQRT added
 * 26.04.93: O_LENGTH, O_POSITION added
 * 18.01.93: O_USER added
 * 18.11.92: Packing pragma added
 * 04.11.92: Modifications for WIN32 added
 * 26.10.92: CalcError has INT parameter
 * 25.10.92: Module header added
 * 01.04.89: Creation of body
 *****************************************************************************/

#ifndef _DBEXEC_H
#define _DBEXEC_H

#ifdef __cplusplus
extern "C" {
#endif

typedef	enum
{
	O_END,				/* end of calculation program	*/
	O_NEG,				/* negate values				*/
	O_ADD,				/* add values					*/
	O_SUB,				/* subtract values				*/
	O_MUL,				/* multiply values				*/
	O_DIV,				/* divide values				*/
	O_EQ,				/* compare for equal			*/
	O_NE,				/* compare for not equal		*/
	O_GT,				/* compare for greater than		*/
	O_LT,				/* compare for less than		*/
	O_GE,				/* compare for greater equal	*/
	O_LE,				/* compare for less equal		*/
	O_AND,				/* bitwise and					*/
	O_OR,				/* bitwise or					*/
	O_NOT,				/* bitwise not					*/
	O_COLON,			/* format operator				*/
	O_REPLACE,			/* replace string2 in string1 by string3	*/
	O_SUM,				/* sum of fields				*/
	O_MIN,				/* minimum of fields			*/
	O_MAX,				/* maximum of fields			*/
	O_AVG,				/* average of fields			*/
	O_GET,				/* get field from other table	*/
	O_PUT,				/* put field into other table	*/
	O_ALERT,			/* gem form_alert				*/
	O_SUBSTR,			/* substring					*/
	O_CHR,				/* chr function					*/
	O_LFIELD,			/* load field					*/
	O_SFIELD,			/* store field					*/
	O_LCONST,			/* load constant				*/
	O_LCOUNT,			/* load count					*/
	O_LSYDATE,			/* load system date				*/
	O_LSYTIME,			/* load system time				*/
	O_LSYTIMST,			/* load system timestamp		*/
	O_LDAY,				/* load day of date				*/
	O_LMONTH,			/* load month of date			*/
	O_LYEAR,			/* load year of date			*/
	O_LHOUR,			/* load hour of time			*/
	O_LMINUTE,			/* load minute of time			*/
	O_LSECOND,			/* load second of time			*/
	O_LMICSEC,			/* load microsecond of time		*/
	O_LNAMEDFLD,		/* load field (name computed)	*/
	O_SDAY,				/* store day of date			*/
	O_SMONTH,			/* store month of date			*/
	O_SYEAR,			/* store year of date			*/
	O_SHOUR,			/* store hour of time			*/
	O_SMINUTE,			/* store minute of time			*/
	O_SSECOND,			/* store second of time			*/
	O_SMICSEC,			/* store microsecond of time	*/
	O_SNAMEDFLD,		/* store field (name computed)	*/
	O_FIRST,			/* first (field)				*/
	O_LAST,				/* last (field)					*/
	O_USER,				/* get user id 					*/
	O_JMP,				/* Jump unconditional			*/
	O_FJMP,				/* Jump conditional				*/
	O_INITVARS,			/* Reserve space for variables	*/
	O_LOADVAR,			/* Load variable				*/
	O_STOREVAR,			/* Store variable				*/
	O_LNUL,				/* use NULL value				*/
	O_LENGTH,			/* length of a string			*/
	O_POSITION,			/* position of string in string	*/
	O_STRLOWER,			/* convert string to lower case	*/
	O_STRUPPER,			/* convert string to upper case	*/
	O_SIN,				/* sine 						*/
	O_COS,				/* cosine 						*/
	O_TAN,				/* tangent 						*/
	O_ASIN,				/* arcsine 						*/
	O_ACOS,				/* arccosine 					*/
	O_ATAN,				/* arctangent 					*/
	O_ABS,				/* absolut value 				*/
	O_EXP,				/* exponential function 		*/
	O_LN,				/* logarithm natural 			*/
	O_LOG,				/* logarithm base-10 			*/
	O_SQRT,				/* square root 					*/
	O_RAND,				/* random function 				*/
	O_POW,				/* pow (x, y) 					*/
	O_ROUND,			/* round number 				*/
	O_TRUNCATE,			/* truncate number 				*/
	O_SIGN,				/* sign of number 				*/
	O_KEYCOUNT,			/* count keys from index		*/
	O_CHAR,				/* cast to char 				*/
	O_WORD,				/* cast to word 				*/
	O_LONG,				/* cast to long 				*/
	O_FLOAT,			/* cast to float 				*/
	O_ERRNO,			/* get errno on float errors	*/
	O_IMPORT,			/* import field from filename	*/
	O_EXPORT,			/* export field into filename	*/
	O_KBVREAD,			/* read smart card of "Kassenärztliche Bundesvereinigung" */
	O_KBVGET,			/* get certain field of smart card of card of "Kassenärztliche Bundesvereinigung" */
	O_RETURN			/* return value of db_execute	*/
}	OPCODE;


#if MSDOS | NT
#pragma pack(1)
#endif

typedef	struct
{
	SHORT	field;		/* field index					*/
	SHORT	type;		/* type of column				*/
	LONG	addr;		/* address in record			*/
	USHORT	flags;		/* flags of column				*/
}	FIELDDESC;


typedef	union
{
	CHAR		*stringVal;
	SHORT		wordVal;
	LONG		longVal;
	DOUBLE		floatVal;
	DATE		dateVal;
	TIME		timeVal;
	TIMESTAMP	timeStampVal;
}	VALUE;


typedef	struct
{
	SHORT	type;
	VALUE	val;
}	VALUEDESC;

typedef VALUEDESC FAR *LPVALUEDESC;	/* pointer to value descriptor */

typedef	VOID	*CODELOC;

#ifdef _WINDOWS
#ifndef WIN32
#ifdef setjmp
#undef setjmp			/* setjmp is a macro in ANSI C */
#endif
#define jmp_buf	CATCHBUF
#define setjmp	Catch
#define longjmp Throw
#endif
#endif

#if MSDOS | NT
#pragma pack()
#endif

GLOBAL	jmp_buf	errJmp;		/* to abort execution/compilation */

GLOBAL	VOID	CalcError		_((INT error));

GLOBAL	VOID	StartGen		_((CHAR *codeBuf, LONG len));
GLOBAL	VOID	GenInst			_((OPCODE op, SHORT varNum));
GLOBAL	VOID	LookupField		_((BASE *base, SHORT table,
								   CHAR *name, FIELDDESC *fieldDesc));
GLOBAL	VOID	GenFieldInst	_((OPCODE op, FIELDDESC *fieldDesc));
GLOBAL	VOID	GenConstLoad	_((VALUEDESC *val));
GLOBAL	CODELOC	GetCurLoc		_((VOID));
GLOBAL	VOID	GenJmp			_((CODELOC targetLoc));
GLOBAL	VOID	GenFalseJmp		_((CODELOC targetLoc));
GLOBAL	VOID	PatchJmp		_((CODELOC jmpLoc));
GLOBAL	LONG	CodeSize		_((VOID));

#ifdef __cplusplus
}
#endif

#endif /* _DBEXEC_H */

