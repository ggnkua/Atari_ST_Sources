/* -------------------------------------------------------------------- */
/*									*/
/* 	Conv - Converts a double to ascii in binary, octal,		*/
/*		decimal or hexadecimal format.				*/
/*									*/
/* -------------------------------------------------------------------- */

#include <stdio.h>			/* sprintf()			*/
#include <math.h>			/* fabs()			*/
#include "clac.h"			/* symbols, errors and modes	*/

char base[]  = "0123456789ABCDEF";	/* max. numberbase		*/

int conv();
int make_out();


/* -------------------------------------------------------------------- */
/*		output according to the mode				*/

int conv(value, exp, mode)		/* return error or 0		*/
double	value;				/* a value to be converted	*/
char	exp[];				/* string for ascii string	*/
int	mode;				/* output format		*/
{
	int error = 0;

	switch(mode) {
		case DEC:
			sprintf(exp, "%g", value);
			break;
		case BIN:
			error = make_out(exp, BIN_SYM, 1, value);
			break;
		case OCT:
			error = make_out(exp, OCT_SYM, 3, value);
			break;
		case HEX:
			error = make_out(exp, HEX_SYM, 4, value);
			break;
		default:
			error = MOD_ERR;
	}
	return(error);
}

/* -------------------------------------------------------------------- */
/* BIN, OCT and HEX outputs						*/

int make_out(exp, mode, bits, value)	/* output in 2^bits modes	*/
char	exp[];
char	mode;
int	bits;
double	value;
{
	int i, index, mask, num, exp_idx = 0;
	unsigned long num1, num2;		/* int/decimal	parts	*/
	int len_long = sizeof(long) * 8;	/* bits in 'long'	*/
	if(bits == 1) len_long --;		/* eliminate negate	*/
	mask = (1 << bits) - 1;			/* mask for basedigit	*/
	if(len_long % bits)			/* for uneven bitamount	*/
		len_long -= len_long % bits;

	if(value > ((1L << (len_long - 1)) - 1))
		return(OVR_ERR);
	else {
		if(value < 0) {			/* sign			*/
			exp[exp_idx ++] = '-';
			value = fabs(value);
		}
		exp[exp_idx ++] = mode;
		num1 = value;
		num2 = (value - num1) * (1L << (len_long - bits));

		if(num1) {			/* integer part		*/
			num = 0;
			i = len_long - bits;
			while(i >= 0) {
				index = (num1 >> i) & mask;
				num |= index;
				if(num)
					exp[exp_idx ++] = base[index];
				i -=bits;
			}
		} else
			exp[exp_idx ++] = '0';	/* zero before point	*/

		if(num2) {			/* decimal part		*/
			num = 0;
			exp[exp_idx ++] = '.';
			i = len_long - bits;
			while(i >= 0) {
				i -=bits;
				index = (num2 >> i) & mask;
				exp[exp_idx ++] = base[index];
			}
		}
	}
	exp[exp_idx] = '\0';			/* end output string	*/

	return(0);
}
