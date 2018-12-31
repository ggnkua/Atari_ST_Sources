/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* macros for getting at and setting the current argument count */

#define arg_value()		arg_count
#define arg_or_default(x)	(is_an_arg()? arg_count : (x))
#define set_arg_value(n)	{ arg_state = AS_NUMERIC; arg_count = (n); }
#define clr_arg_value()		{ arg_state = AS_NONE; arg_count = 1; }
#define is_an_arg()		(arg_state != AS_NONE)
#define is_non_minus_arg()		(arg_state != AS_NONE && arg_state != AS_NEGSIGN)

#define	save_arg(as,ac)	{ (ac) = arg_count; (as) = arg_state; }
#define	restore_arg(as,ac)	{ arg_count = (ac); arg_state = (as); }

extern void	negate_arg proto((void));

/* Commands: */

extern void
	Digit proto((void)),
	DigitMinus proto((void)),
	Digit0 proto((void)),
	Digit1 proto((void)),
	Digit2 proto((void)),
	Digit3 proto((void)),
	Digit4 proto((void)),
	Digit5 proto((void)),
	Digit6 proto((void)),
	Digit7 proto((void)),
	Digit8 proto((void)),
	Digit9 proto((void)),
	TimesFour proto((void));

/* private to macros */

extern int
	arg_state,	/* NO, YES, or YES_NODIGIT */
	arg_count;

#define	AS_NONE	0	/* no arg */
#define	AS_NUMERIC	1	/* numeric arg supplied */
#define	AS_NEGSIGN	2	/* only minus sign supplied */
#define	AS_TIMES	3	/* multiplicative request */
