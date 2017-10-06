#ifndef PRELUDE_H
#define PRELUDE_H

/* (c) 1991-1998 by H. Robbers te Amsterdam */

/* HR: the word global should really be kept reserved for (future?)
       use as the opposite of auto, local or static. */

/* (c) 1991-1998 by H. Robbers te Amsterdam */
	#undef TRUE
	#undef FALSE
	#undef true
	#undef false
	#undef NULL
	#undef null
	#undef NIL
	#undef nil

	#define   and &&
	#define   or  ||
	#define   eq  ==
	#define   ne  !=
	#define   ge  >=
	#define   le  <=
	#define global
	#define elif else if
	#define od while(1);		/* ; no mistake */
	#define othw  }else{
	typedef enum boolean
	{
		false = 0,
		true
	} bool;

	#define NULL 0L
	#define null 0L
	#define nil 0L
	#define NIL 0L
	#define FALSE false
	#define TRUE true

#endif
