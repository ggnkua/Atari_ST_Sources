/* -------------------------------------------------------------------- */
/*									*/
/* Clac - calculator (C) 1994 by Eero Tamminen. V. 16/5/1994. Freeware.	*/
/*	Use tab size 8. Compile with: gcc -O clac.c -lpml		*/
/*									*/
/* Clac:	Calculates the expression and returns the result	*/
/*		or error code in the exp_packet structure.		*/
/*									*/
/* -------------------------------------------------------------------- */

#include <stdio.h>
#include <ctype.h>				/* toupper()		*/
#include <stdlib.h>				/* atof()		*/
#include <string.h>				/* strcpy(), strcmp()	*/
#include <math.h>				/* pow(), sin() etc.	*/

#include "clac.h"

/* -------------------------------------------------------------------- */
/* define some preprosessor symbols					*/

/* define internal allocation sizes (should be enough)			*/
#define	DEPTH	64			/* max. parenth. nesting depth	*/
#define STACK	128			/* size of the operator stack	*/
#define V_STACK	256			/* size of the value stack	*/

/* -------------------------------------------------------------------- */
/* all structures are global						*/

/* globals + function identifier stack(s)				*/
struct {
	int error;			/* global error code		*/
	int valid;			/* value validation		*/
	char fname[120];		/* function names		*/
	int mfunc;			/* 1st multiparameter function	*/
} id = {0, 0,
	"LN\0LG\0RAD\0DEG\0SIN\0COS\0TAN\0SINH\0COSH\0TANH\0ASIN\0ACOS\0ATAN\0SQRT\0AVG\0STD\0\0",
	14};

/* Make SURE that the order of functions is same in here and in the	*/
/* eval_func() and eval_mfunc() functions!!!				*/


/* parenthesis and function stacks					*/
struct {
	int idx;			/* parenthesis level		*/
	int max;			/* maximum idx			*/
	char func;			/* current function opcode	*/
	int opx[DEPTH + 1];		/* current op index for par	*/
	int vax[DEPTH + 1];		/* current val index for par	*/
	char buf[DEPTH + 1];		/* function opcode buffer	*/
} par = {0, DEPTH, '\0', {0}, {0}, ""};

struct {					/* operator stack	*/
	int idx;
	int max;
	char buf[STACK + 1];
} op = {0, STACK, ""};

struct {					/* value stack		*/
	int idx;
	int max;
	double buf[V_STACK + 1];
} val = {0, V_STACK, {0}};


/* -------------------------------------------------------------------- */
/* macros								*/

/* increment stack index and put value on stack (ie. PUSH)		*/
#define PUSH(stk,val)	if((stk).idx < (stk).max) {			\
				(stk).idx += 1;				\
				(stk).buf[(stk).idx] = (val);		\
			} else						\
				id.error = STK_ERR;
/* degrees <-> radians							*/
#define TO_RAD(val)	val = M_PI / 180 * val
#define TO_DEG(val)	val = 180 / M_PI * val


/* -------------------------------------------------------------------- */
/* declare subfunctions							*/

double	get_predef();			/* parser variable/function/mem	*/
double	get_var();			/* get variables value		*/
void	get_func();			/* identify a function		*/
int	str_cmp();			/* special string comparator	*/
double	get_dec();			/* parse a decimal from exp.	*/
double	get_value();			/* parse one value from exp.	*/
int	chr_pos();			/* 'value' of a char		*/

void	operation();			/* parse operations		*/
void	eval_stack();			/* juggle stacks, if possible	*/
int	get_level();			/* operator -> operator level	*/
double	apply();			/* evaluate one operation	*/
double	eval_func();			/* evaluate one function	*/
double	eval_mfunc();			/* multiple parameter functions	*/

void	open_bracket();			/* increase parenthesis level	*/
double	close_bracket();		/* decrease	-"-		*/


void calc(pkt)			/* evaluate one whole expression	*/
struct	exp_packet *pkt;
{
	/* exp	 : expression to evaluate				*/
	/* value : current parsed value					*/
	/* mark	 : current character in expression			*/
	/* valid : expression validation flag, set when number parsed	*/
	/* exit	 : 'expression end' flag				*/
	/* offset: character offset in expression			*/

	int exit = FALSE, offset = 0;
	double value = 0;
	char mark;

	/* Uses global variables:	*/

	par.idx = 0;			/* parenthesis stack pointer	*/
	par.func = 0;			/* current function opcode	*/
	par.opx[0] = par.vax[0] = 0;	/* additional stack pointers	*/
	op.idx = val.idx = -1;

	id.error = FALSE;
	id.valid = FALSE;		/* value validation		*/

	/* parsering loop, repeated until expression ends		*/
	do {
		mark = pkt->exp[offset];
		switch(mark) {
		case ' ':
		case '\t':
			offset ++;		/* jump over spaces	*/
			break;
		case ';':				/* comment	*/
		case '\0':				/* end of line	*/
		case '\n':				/* newline     	*/
			exit = TRUE;
			break;
		case '|':				/* operators	*/
		case '&':
		case '+':
		case '-':
		case '*':
		case '/':
		case '^':
			operation(value, mark);
			offset ++;
			id.valid = FALSE;
			break;
		case '(':
			open_bracket();
			offset ++;
			break;
		case ')':
			value = close_bracket(value, TRUE, pkt->trig_mode);
			offset ++;
			break;
		case ',':			/* more parameters	*/
			if(par.buf[par.idx - 1] > id.mfunc) {
				/* evaluate previous parameter		*/
				value = close_bracket(value, FALSE, pkt->trig_mode);
				id.valid = FALSE;
				PUSH(val, value);
				open_bracket();		/* next param.	*/
			} else
				pkt->error = FNC_ERR;
			offset ++;
			break;
		case '.':				/* decimal	*/
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			value = get_dec(pkt->exp, &offset);
			id.valid = TRUE;
			break;
		case BIN_SYM:			/* binary decimal	*/
			offset ++;
			value = get_value(pkt->exp, &offset, 1);
			id.valid = TRUE;
			break;
		case OCT_SYM:			/* octal decimal	*/
			offset ++;
			value = get_value(pkt->exp, &offset, 3);
			id.valid = TRUE;
			break;
		case HEX_SYM:			/* hexa decimal		*/
			offset ++;
			value = get_value(pkt->exp, &offset, 4);
			id.valid = TRUE;
			break;
		default:
			/* if recogniced, push function id to stack	*/

			value = get_predef(pkt->exp, &offset, pkt);
		}

	/* until exit or error message					*/
	} while((exit == FALSE) && (id.error == FALSE));

	/* something to return?						*/
	if(!id.error) {
		if(id.valid) {

			/* evaluate rest of the pkt->expression		*/
			operation( value, '|');
			if(par.idx)			/* mismatched	*/
				id.error = PAR_ERR;
			else				/* result out	*/
				pkt->result = val.buf[0];

		} else {
			if((val.idx < 0) && (op.idx < 0)) {
				id.error = NO_EXP;	/* no expr.	*/
				pkt->result = 0;
			} else			/* trailing operators	*/
				id.error = GEN_ERR;
		}
	}

	if(id.error) {
		pkt->error = id.error;
		pkt->err_pos = offset;
	} else
		pkt->error = pkt->err_pos = 0;
}


/* ==================================================================== */
/*		parser variables & functions				*/
/* ==================================================================== */

double get_predef(exp, offset, pkt)
char	exp[];				/* pointer to expression	*/
int	*offset;			/* variable offset in exp.	*/
struct	exp_packet *pkt;
{
	/* return value of the parsed variable / make new variable	*/
	/* / assign new value to a variable / parser a function		*/

	int more = 0;
	char mark;
	double value = 0;
	char str[MAX_VAR + 1];			/* variable name	*/
	str[2] = '\0';				/* for get_mem()	*/

	if(id.valid == FALSE) {		/* preceded by operator?	*/

		/* parse one identification from expression		*/
		mark = toupper(exp[*offset]);
		while((((mark >= '0') && (mark <= '9'))
		   || ((mark >= 'A') && (mark <= 'Z'))) && (more <= MAX_VAR)) {
			str[more ++] = mark;
			mark = toupper(exp[*offset + more]);
		}

		if(more == FALSE)			/* not valid	*/
			id.error = GEN_ERR;
		else {
			if(more > MAX_VAR)		/* too long	*/
				id.error = VAR_ERR;

	       		else {
				str[more] = '\0';	/* end name	*/

				if(mark == '(')		/* a function	*/
					get_func(str);
				else {			/* a variable	*/
					value = get_var(str, pkt);
					id.valid = TRUE;
				}
			}
		}
	} else
		id.error = GEN_ERR;

	*offset += more;			/* overtake identifier	*/
	return(value);
}

/* -------------------------------------------------------------------- */
/* find out value of a variable						*/

double get_var(name, pkt)
char	name[];
struct	exp_packet *pkt;		/* get variables from here	*/
{
	int i = 0, lenny, idx = 0;
	double value = 0;

	/* find the index for the given variable			*/
	lenny = strlen(&pkt->vname[i]);
	while((lenny > 0) && (strcmp(&pkt->vname[i], name))) {
		idx ++;
		i += ++lenny;
		lenny = strlen(&pkt->vname[i]);
	}

	if(lenny > 0)				/* variable found	*/
		value = pkt->value[idx];
	else
		id.error = VAR_ERR;

	return(value);
}

/* ==================================================================== */
/*			parser a function				*/
/* ==================================================================== */

void get_func(name)		/* identify a function -> id to stack	*/
char	name[];
{
	/* returns the character identifier of the parsed function	*/

	int i = 0, idx = 1, lenny;

	/* find the index for the given variable			*/
	lenny = strlen(&id.fname[i]);
	while((lenny > 0) && (strcmp(&id.fname[i], name))) {
		idx ++;
		i += ++lenny;
		lenny = strlen(&id.fname[i]);
	}

	if(lenny > 0) {				/* function found	*/
		par.func = idx;			/* function opcode	*/
	} else
		id.error = FNC_ERR;
}

/* ==================================================================== */
/*			parse a value					*/
/* ==================================================================== */

double get_dec(exp, offset)		/* parse a decimal number	*/
char	exp[];
int	*offset;
{
	char mark;
	double value = 0;

	if(id.valid == FALSE) {
		value = atof(&exp[*offset]);
		/* jump over number */
		do {
			mark = exp[++(*offset)];
		} while((mark >= '.') && (mark <= '9') && (mark != '/'));
	} else
		id.error = GEN_ERR;

	return(value);
}

/* -------------------------------------------------------------------- */
/* parsering for 2^bits number base (up to hex, at the moment)		*/

double get_value(exp, offset, bits)		/* parse one value	*/
char	exp[];					/* expression		*/
int	*offset;				/* expression offset	*/
int	bits;					/* bits in number base	*/
{
	/* returns parsed value, changes expression offset		*/

	double value = 0;
	int i, lenny, pos, index, len_long = sizeof(long) * 8;
	unsigned long num1 = 0, num2 = 0;	/* int/decimal	parts	*/
	char digit;
	char base[17];
	strcpy(base, "0123456789ABCDEF");	/* largest base = 16   	*/
	base[1 << bits] = '\0';			/* cut to current base	*/
	if(bits == 1) len_long --;		/* eliminate negate	*/
	lenny = len_long / bits;		/* max. number lenght	*/

	/* if start of expression or preceded by an operator		*/
	if(id.valid == FALSE) {

		i = 0;
		digit = exp[*offset];		/* digit		*/
		index = chr_pos(digit, base);	/* value of digit	*/

		/* increment i until the integer part of value ends	*/
		while((i < lenny) && (index >= 0)) {
			num1 = (num1 << bits) | index;
			digit = exp[++(*offset)];
			index = chr_pos(digit, base);	/* -1 if not in	*/
			i ++;
		}
		/* too long number or expands into the sign bit?	*/
		if(((i == lenny) && (index >= 0)) || (num1 & (1L << (len_long - 1))))
			id.error = OVR_ERR;
		else {
			if(digit == '.') {	/* decimal part?	*/
				pos = len_long - bits;
				digit = exp[++ (*offset)];
				index = chr_pos(digit, base);

				/* calculate x / 0xFFFFFFFF		*/
				while((pos >= bits) && (index >= 0)) {
					pos -= bits;
					num2 |= (long)index << pos;
					digit = exp[++ (*offset)];
					index = chr_pos(digit, base);
				}
				/* jump over any remaining decimals	*/
				if((pos < bits) && (index >= 0))
					for(; chr_pos(exp[*offset], base) >= 0; (*offset) ++);
				}
			/* compose value of integral and decimal parts	*/
			value = num2 / (double) (1L << (len_long - bits)) + num1;
		}

	} else
		id.error = GEN_ERR;

	return(value);
}

/* -------------------------------------------------------------------- */
/* return the value of a given character in the current number base	*/

int chr_pos(chr, string)	/* find 'value' of a char in numberbase	*/
char chr;			/* character representation of a number	*/
char string[];	/* string containing all numbers in the selected base	*/
{
	/* returns a character position (0 - ) in a string or -1	*/

	int pos = 0;				/* character position	*/

	chr = toupper(chr);			/* uppercase a letter	*/

	while((string[pos] != '\0') && (string[pos] != chr))
		pos ++;		/* till string end or character found	*/

	if(string[pos] == '\0')		/* if string end -> not found	*/
		pos = -1;

	return(pos);
}

/* ==================================================================== */
/*			expression evaluation				*/
/* ==================================================================== */

void operation(value, oper)			/* parse operations	*/
double	value;					/* last parsed value	*/
char	oper;					/*    -"-   operator	*/
{
	/* uses globals par[], id.error[], op[], val[]		*/
	/* operation executed if the next one is on same or lower level	*/

	if(id.valid) {				/* something to calc?	*/

		/* add new items to stack and increase pointer		*/
		PUSH(op, oper);
		PUSH(val, value);

		if(op.idx > par.opx[par.idx]) {		/* > 1 operator	*/

			if(val.idx == par.vax[par.idx]) {	/* sign	*/
				val.buf[val.idx] = -value;
				op.idx --;
				op.buf[op.idx] = op.buf[op.idx + 1];
			} else
				eval_stack();
				/* evaluate all possible operations	*/
		}
	} else {
		/* No value, might be a sign. If minus, put to stack.	*/

		if(op.idx < par.opx[par.idx] && (oper == '-' || oper == '+')){
			if(oper == '-')
				PUSH(op, oper);
		} else
			id.error = GEN_ERR;
	}
}

/* -------------------------------------------------------------------- */
/* evaluate operators if precedence allows it				*/

/* evaluate all possible (according to order of precedence) operators	*/
void eval_stack()
{
	/* uses globals par[], op[], val[]	*/

	/* # of operators >= 2 and prev. op-level >= current op-level ?	*/
	while((op.idx > par.opx[par.idx]) && get_level(-1) >= get_level(0)) {

		/* shorten value stacks by one	*/
		/* + calculate resulting value	*/
		op.idx -= 1;
		val.idx -= 1;
		val.buf[val.idx] = apply(op.buf[op.idx],
			val.buf[val.idx], val.buf[val.idx + 1]);

		/* pull the just used operator out of the stack		*/
		op.buf[op.idx] = op.buf[op.idx + 1];
	}
}

/* -------------------------------------------------------------------- */
/* return the precedence level of a given operator			*/

int get_level(offset)		/* operator -> operator level		*/
int	offset;			/* offset to operator stack index	*/
{
	/* used globals par[], op[]					*/
	/* returns operator level of: operator[stack index + offset]	*/

	int level = 0;

	switch(op.buf[op.idx + offset]) {
		case '|':				/* level = 0	*/
		case '&':
			break;
		case '+':
		case '-':
			level = 1;
			break;
		case '*':
		case '/':
			level = 2;
			break;
		case '^':
			level = 3;
			break;
	}
	return(level);
}

/* -------------------------------------------------------------------- */
/* apply operator to given values, return the result			*/

double apply(opcode, value1, value2)	/* calculate one operation	*/
char	opcode;				/* operator			*/
double	value1, value2;			/* values to be operated on	*/
{
	/* uses global id.error[]			*/
	/* returns the result of operation	*/

	switch(opcode) {
		case '|':
			value1 = (long)value1 | (long)value2;
			break;
		case '&':
			value1 = (long)value1 & (long)value2;
			break;
		case '+':
			value1 = value1 + value2;
			break;
		case '-':
			value1 = value1 - value2;
			break;
		case '*':
			value1 = value1 * value2;
			break;
		case '/':
			/* not 'divide by zero'	*/
			if(value2 != 0.0)
				value1 = value1 / value2;
			else
				id.error = DEF_ERR;
			break;
		case '^':
			value1 = pow(value1, value2);
			break;
	}
	return(value1);				/* return result	*/
}

/* -------------------------------------------------------------------- */
/* evaluate function on the given parameter				*/

double eval_func(opcode, value, tmode)	/* calculate function on value	*/
char	opcode;				/* function opcode		*/
double	value;				/* value for function		*/
int	tmode;				/* triggonometric mode		*/
{
	/* uses global id.error[]					*/
	/* returns the result of a function				*/

	/* check for things that can't be evaluated			*/
	if((opcode < 3 && value <= 0.0) ||		/* logarithms	*/
	   (opcode > 10 && opcode < 14 &&		/* arcus ...	*/
	    (value < -1.0 || value > 1.0)) ||
	   (opcode == 14 && value < 0.0)) {		/* square root	*/
		id.error = DEF_ERR;
		return(value);
	}

	/* In case function is trigonometric and angle mode is degrees.	*/
	if(opcode > 4 && opcode < 11 && tmode == DEG)
			value = TO_RAD(value);

	/* Opcode refers to the fuction name position in id.fname!	*/
	/* Make sure that these are in same order than they are in it!!	*/
	switch(opcode) {
	case 1:
		value = log(value);
		break;
	case 2:
		value = log10(value);
		break;
	case 3:					/* degrees <-> radians	*/
		value = TO_RAD(value);
		break;
	case 4:
		value = TO_DEG(value);
		break;
	case 5:				/* trigonometric functions	*/
		value = sin(value);
		break;
	case 6:
		value = cos(value);
		break;
	case 7:
		value = tan(value);
		break;
	case 8:						/* hyperbolic -	*/
		value = sinh(value);
		break;
	case 9:
		value = cosh(value);
		break;
	case 10:
		value = tanh(value);
		break;
	case 11:					/* arcus -	*/
		value = asin(value);
		break;
	case 12:
		value = acos(value);
		break;
	case 13:
		value = atan(value);
		break;
	case 14:					/* others	*/
		value = sqrt(value);
		break;
	}

	/* In case trigonometric function is arcus...+ mode is degrees.	*/
	if(opcode > 10 && opcode < 14 && tmode == DEG)
			value = TO_DEG(value);

	return(value);
}

/* -------------------------------------------------------------------- */
/* evaluate function on multiple parameters				*/

double eval_mfunc(opcode, a, b)
char	opcode;					/* function opcode	*/
int	a,b;					/* start/end of params.	*/
{
	int i, params;
	double value = 0, temp = 0;
	opcode -= id.mfunc;
	params = b - a + 1;

	switch(opcode) {
	case 1:					/* average		*/
	case 2:					/* standard deviation	*/
		for(i = a; i <= b; i ++)
			value += val.buf[i];
		value = value / params;

		if(opcode == 2) {
			for(i = a; i <= b; i ++)
				temp += pow(val.buf[i] - value, 2);
			value = sqrt(temp / params);
		}
		break;
	}

	return(value);
}

/* ==================================================================== */
/*			parenthesis and help				*/
/* ==================================================================== */

void open_bracket()
{
	if(id.valid == FALSE) {		/* preceded by operator		*/
		if(par.idx < DEPTH) {	/* not nested too deep		*/
			PUSH(par, (char)par.func);	/* inc. level	*/
			par.opx[par.idx] = op.idx + 1;
			par.vax[par.idx] = val.idx + 1;

			if(par.func > id.mfunc) {
				par.func = 0;	/* zero current opcode	*/
				open_bracket();	/* average((1),(1+1))	*/
			} else
				par.func = 0;
		} else
			id.error = STK_ERR;
	} else
		id.error = GEN_ERR;
}

/* -------------------------------------------------------------------- */
/* close prenthesis, and evaluate if it was a function			*/

double close_bracket(value, straight, tmode)
double	value;					/* last parsed value	*/
int	straight;				/* last param. flag	*/
int	tmode;					/* trigonometric	*/
{
	/* returns the value of the parenthesised expression	*/

	int func;

	if(id.valid) {			/* preceded by an operator	*/
		if(par.idx > 0) {	/* prenthesis has a pair	*/
			/* calculate the value of parenthesised exp.	*/
			operation(value, '|');
			value = val.buf[val.idx];

			/* if function, evaluate it now			*/
			/* and change value accordingly			*/
			func = par.buf[par.idx];
			if(func > 0)		/* one parameter	*/
				value = eval_func(func, value, tmode);
			else {			/* multiple parameters?	*/
				func = par.buf[par.idx - 1];
				if(straight && (func > id.mfunc)) {
					par.idx --;
					value = eval_mfunc(func, par.vax[par.idx], val.idx);
				}
			}
			op.idx = par.opx[par.idx] - 1;	/* restore prev	*/
			val.idx = par.vax[par.idx] - 1;
			par.idx --;
		} else
			id.error = PAR_ERR;
	} else
			id.error = GEN_ERR;

	return(value);
}
