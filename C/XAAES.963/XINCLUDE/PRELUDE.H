#ifndef PRELUDE_H
#define PRELUDE_H

/* (c) 1991-1998 by H. Robbers te Amsterdam */

/* HR: the word global should really be kept reserved for (future?)
       use as the opposite of auto, local or static. */

#undef TRUE
#undef FALSE
#undef true
#undef false
#undef NULL
#undef null
#undef NIL
#undef nil

#if ! __AC__					/* FOR_A 0; Not for 'A' compiler. */
	#define   and &&
	#define   or  ||
	#define   not !
	#define   eq  ==
	#define   ne  !=
	#define   ge  >=
	#define   le  <=
	#define   mod %
	#define begin {
	#define end   }
	#define global
	#define esac break;
	#define elif else if
	#define othw }else{
	#define od while(1);		/* ; no mistake */
	typedef double extended;
	typedef float single;

	#if ! __AHCC__				/* FOR_A 0, but normal ANSI C compilers dont have these names */
	/* these are otherwise built in */
		#define nil 0L
		typedef double real;
		typedef enum boolean
		{
			false = 0,
			true
		} bool;

		typedef struct { real re, im; } complex;
		typedef complex compl;
	#endif
#endif

#if __AC__ || __AHCC__
	
	#define operator __OP__		/* internally defined non C tokens */
	#define cast     __UC__

	#if ! __68020__
		#define __HAVE_SW_LONG_MUL_DIV__ 1
		/* The operands are casted before the existence of these operator
		   overloads are examined, so the below will suffice. */
		unsigned long operator / (unsigned long, unsigned long) _uldiv;
		unsigned long operator * (unsigned long, unsigned long) _ulmul;
		unsigned long operator % (unsigned long, unsigned long) _ulmod;
		long operator / (long, long) _ldiv;
		long operator * (long, long) _lmul;
		long operator % (long, long) _lmod;
	#endif
#endif

#define NULL 0L
#define null 0L
#define nil 0L
#define NIL 0L
#define FALSE false
#define TRUE true

typedef char *string;
typedef unsigned char *ustring;
typedef unsigned char uchar;

#define K *1024
#define fall_thru

#endif
