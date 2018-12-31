/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "jctype.h"

int	arg_state = AS_NONE,
	arg_count;

void
negate_arg()
{
	if (arg_count < 0) {
		arg_count = -arg_count;
		if (arg_count < 0)
			complain("arg count overflow");
	} else {
		arg_count = -arg_count;
	}
}

private void
gather_argument(ns, nc)
	int
		ns,	/* new state */
		nc;	/* new count */
{
	for (;;) {
		ZXchar	c;
		bool	neg = NO;

		if (arg_count < 0) {
			neg = YES;
			negate_arg();
		}
		if (ns != arg_state) {
			/* First time in this state */
			arg_state = ns;
			arg_count = nc;	/* ignore previous value (but remember sign) */
		} else {
			/* Continuing in this state. */
			int	t = arg_count;

			switch (ns) {
			case AS_NUMERIC:
				t = t*10 + nc;	/* add a digit to previous value */
				break;
			case AS_NEGSIGN:
				neg = !neg;	/* change previous sign */
				break;
			case AS_TIMES:
				t *= nc;	/* multiply by factor */
				break;
			}
			if (t < arg_count)
				complain("arg count overflow");
			arg_count = t;
		}
		if (neg)
			negate_arg();

		/* Treat a following digit as AS_NUMERIC.
		 * If in AS_TIMES, accept a '-'.
		 */
		c = waitchar();
		if (jisdigit(c)) {
			ns = AS_NUMERIC;
			nc = c - '0';
		} else if (arg_state==AS_TIMES && c=='-') {
			ns = AS_NEGSIGN;	/* forget multiplication */
			nc = -1;
		} else {
			Ungetc(c);
			break;
		}
	}
	this_cmd = ARG_CMD;
}

void
TimesFour()
{
	gather_argument(AS_TIMES, 4);
}

void
Digit()
{
	if (LastKeyStruck == '-')
		gather_argument(AS_NEGSIGN, -1);
	else if (jisdigit(LastKeyStruck))
		gather_argument(AS_NUMERIC, LastKeyStruck - '0');
	else
		complain((char *)NULL);
}

void
Digit0()
{
	gather_argument(AS_NUMERIC, 0);
}

void
Digit1()
{
	gather_argument(AS_NUMERIC, 1);
}

void
Digit2()
{
	gather_argument(AS_NUMERIC, 2);
}

void
Digit3()
{
	gather_argument(AS_NUMERIC, 3);
}

void
Digit4()
{
	gather_argument(AS_NUMERIC, 4);
}

void
Digit5()
{
	gather_argument(AS_NUMERIC, 5);
}

void
Digit6()
{
	gather_argument(AS_NUMERIC, 6);
}

void
Digit7()
{
	gather_argument(AS_NUMERIC, 7);
}

void
Digit8()
{
	gather_argument(AS_NUMERIC, 8);
}

void
Digit9()
{
	gather_argument(AS_NUMERIC, 9);
}

void
DigitMinus()
{
	gather_argument(AS_NEGSIGN, -1);
}
