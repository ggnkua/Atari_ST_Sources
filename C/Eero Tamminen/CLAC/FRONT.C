/* -------------------------------------------------------------------- */
/*									*/
/* Clac - calculator (C) 1994 by Eero Tamminen. V. 16/5/1994. Freeware.	*/
/*	Should work with both 16 & 32 bit ints. Use tab size 8.		*/
/*	Compile with: gcc -O -o front front.c conv.c clac.c -lpml     	*/
/*									*/
/* Front-end:	Takes care of the acquiring of the expressions,		*/
/* 		outputting results and managing variables.		*/
/*									*/
/* -------------------------------------------------------------------- */

#include <stdio.h>
#include <ctype.h>				/* toupper()		*/
#include <string.h>				/* strcpy/cmp/len()	*/
#include <unistd.h>                             /* access(), R_OK	*/
#include <math.h>				/* M_PI, M_E		*/
#include <macros.h>				/* max(), min()		*/

#include "clac.h"

/* -------------------------------------------------------------------- */

#define inifile	"front.ini"		/* initialization file name	*/

/* Here are some of the front's commandline option flags.		*/
#define CL_EXP	0x01			/* there *is* an expression	*/
#define USE_FL	0x02			/* input from a file		*/
#define CL_ERR	0x03			/* commanline error		*/
#define MAX_FL	256      		/* max length for a filename	*/

/* -------------------------------------------------------------------- */

/* communication structure						*/
/* error, err_pos, trig_mode, result, expression, var. names & values	*/

struct exp_packet comm = {FALSE, 0, RAD, 0, "", "PI\0E\0", {M_PI, M_E}};

/* -------------------------------------------------------------------- */
/* declare front subfunctions						*/

int	parse();			/* get a commandline		*/
void	file_exps();			/* get exp's from a file	*/
void	evaluate();			/* execute evaluation		*/
void	var_name();			/* get variable name		*/
int	mode_change();			/* change mode			*/
void	errors();			/* error texts			*/
void	put_var();			/* put variable/value to stack	*/
void	help();				/* print a brief help text	*/


/* ==================================================================== */
/*				main					*/
/* ==================================================================== */

int main(argc, argv)			/* get + evaluate an expression	*/
int	argc;
char	*argv[];
{
	int options, mode = DEC;	/* cmd_line opts. & output mode	*/
	char file_in[MAX_FL];

	comm.exp[0] = '\0';				/* global	*/
	file_in[0] = '\0';

	/* execute ini-file if it's R_OK				*/
	if(!access(inifile, R_OK))
		file_exps(inifile, &mode);

	/* parser the commandline					*/
	options = parse(argc, argv, file_in, comm.exp, &mode);

	switch(options) {
	case CL_ERR:			/* command line syntax error	*/
		break;
	case CL_EXP:		/* evaluate a command line expression	*/
		evaluate(&mode);
		break;
	case USE_FL:		/* use input stream to get expressions	*/
		file_exps(file_in, &mode);
		break;
	default:				/* interactive mode	*/
		while(printf("Expression: "), fgets(comm.exp, MAX_LN, stdin) && comm.exp[0] > 31)
			evaluate(&mode);	/* calculate expression	*/
		puts("");
	}
	return(0);
}

/* ====================================================================	*/
/*			parse a commandline				*/
/* ==================================================================== */

int parse(argc, argv, fname, exp, mode)
int	argc;			/* number of args in command-line	*/
char	*argv[];		/* the arguments themselves		*/
char	fname[];		/* name of the input file		*/
char	exp[];			/* expression				*/
int	*mode;			/* output mode				*/
{
	/* Check the validity of the command line and assign the	*/
	/* filename to fname_in,  expression to exp, output mode to	*/
	/* mode and trigonometric mode to comm.trig_mode (global)	*/

	int i = 1;

	if (argc < 2)					/* no options	*/
		return(FALSE);

	while (argc > i && (argv[i][0] == '-')) {	/* set modes	*/
		if(mode_change(mode, argv[i][1]))
			return(CL_ERR);
		i ++;
	}

	if(argc > i) {
		if(argv[i][0] == '@') {			/* from a file	*/
			strcpy(fname, &argv[i][1]);
			if(access(fname, R_OK)) {	/* can be read?	*/
				puts("Input file not available.");
				return(CL_ERR);
			} else
				return(USE_FL);
		}
		strcpy(exp, argv[i]);			/* expression	*/
		while(argc > ++i)
			strcat(exp, argv[i]);
		return(CL_EXP);
	} else
		return(FALSE);
}


/* ==================================================================== */
/*		expression parsering and evaluation			*/
/* ==================================================================== */

void file_exps(file_in, mode)	/* evaluate expressions from a file	*/
char	file_in[];
int	*mode;
{
	FILE *fp;

	fp = fopen(file_in, "r");
	if(fp == NULL)
		puts("File disappeared?");			/* ;-)	*/
	else {
		while (fgets(comm.exp, MAX_LN, fp)) {
			if(comm.exp[0] >= ' ')	/* something to calc	*/
				evaluate(mode);
		}
	}
	fclose(fp);
}

/* -------------------------------------------------------------------- */

void evaluate(mode)
int	*mode;
{
	int i = 0;
	char name[MAX_VAR + 1];			/* variable name	*/
	char result[max(25, sizeof(long)*8+1)];	/* result in ascii	*/

	name[0] = '\0';
	comm.error = 0;

	while((comm.exp[i] != '=') && (comm.exp[i] != '?') && (comm.exp[i] != ':') && (comm.exp[i] >= ' '))
		i ++;

	switch(comm.exp[i]) {
	case '=':				/* variable assignment?	*/
		var_name(i, name);
		break;
	case '?':				/* help			*/
		comm.error = NO_EXP;
		help();
		break;
	case ':':				/* mode change		*/
		mode_change(mode, comm.exp[i + 1]);
		comm.error = NO_EXP;
		break;
	}

	if(!comm.error)
		calc(&comm);			/* CALCULATE		*/

	if(!comm.error)
		/* result into a string according to output mode	*/
		comm.error = conv(comm.result, result, *mode);

	if(comm.error)				/* get error text	*/
		errors(comm.error, result);
	else {
		if(name[0])			/* variable assignment	*/
			put_var(name, result);
	}

	if(comm.error != NO_EXP)		/* show result or error	*/
		puts(result);
}

void var_name(i, name)				/* get variable name	*/
int	i;
char	name[];
{
	int a = 0, b;
	char mark;

	/* search for variable name (same criteria as in clac)		*/
	while(comm.exp[a] <= ' ') a ++;

	mark = comm.exp[a];
	if(i > a && ((mark >= 'A' && mark <= 'Z') ||
	  (mark >= 'a' && mark <= 'z'))) {

		b = 0;
		mark = toupper(comm.exp[b]);
		/* store variable name (ignore erranous end)		*/
		do {
			name[b] = mark;
			b ++;
			mark = toupper(comm.exp[b + a]);
		} while(((mark >= 'A' && mark <= 'Z') || (mark >= '0' && mark <= '9')) && b < MAX_VAR);

		name[b] = '\0';
		strcpy(comm.exp, &comm.exp[++ i]);
	} else
		comm.error = GEN_ERR;		/* syntax error		*/
}

int mode_change(mode, mark)			/* change mode		*/
int	*mode;
char	mark;
{
	switch(toupper(mark)) {
		case 'B':
			*mode = BIN;
			break;
		case 'O':
			*mode = OCT;
			break;
		case 'D':
			*mode = DEC;
			break;
		case 'H':
			*mode = HEX;
			break;
		case 'R':
			comm.trig_mode = RAD;
			break;
		case 'G':
			comm.trig_mode = DEG;
			break;
		default:
			puts("Output modes: binary (b), octal (o), decimal (d), hexadecimal (h).");
			puts("Trigonometric modes: radian (r), degrees (g).");
			return(CL_ERR);
	}
	return(0);
}

void errors(error, str)				/* error -> error text	*/
int	error;
char	str[];					/* only 25 chars long!	*/
{
	switch(error) {
	case GEN_ERR:
		strcpy(str, "Syntax error.");
		break;
	case PAR_ERR:
		strcpy(str, "Mismatched parenthesis.");
		break;
	case DEF_ERR:
		strcpy(str, "Undefined.");
		break;
	case MOD_ERR:
		strcpy(str, "Mode error.");
		break;
	case OVR_ERR:
		strcpy(str, "Mode overflow.");
		break;
	case VAR_ERR:
		strcpy(str, "Variable undefined.");
		break;
	case FNC_ERR:
		strcpy(str, "Unrecognized function.");
		break;
	case STK_ERR:
		strcpy(str, "Calculation stack full.");
	case NO_EXP:				/* no expression	*/
		break;
	default:
		strcpy(str, "Unrecognized error.");		/* :-)	*/
	}
}

void put_var(name, str)			/* put variable into stack	*/
char	name[];
char	str[];
{
	int i = 0, lenny, idx = 0;

	/* find the index for the given variable			*/
	lenny = strlen(&comm.vname[i]);
	while((lenny > 0) && (strcmp(&comm.vname[i], name))) {
		idx ++;
		i += ++lenny;
		lenny = strlen(&comm.vname[i]);
	}

	if((lenny + i < VAR_NAM) && (idx < VARS)) {
		strcpy(&comm.vname[i], name);
		comm.value[idx] = comm.result;
	} else
		strcpy(str, "Variable stack full.");
}

/* -------------------------------------------------------------------- */
/* show a short summary of the current features of calc + front		*/

void help()					/* brief help text	*/
{
	int i, a = 0;

puts("Calc (C) 1994 Eero Tamminen. Freeware.");
puts("- Understands the order of precedence.");
puts("- Number bases: Decimal, $=Hexadecimal, #=Octal and %=Binary.");
puts("- Output modes: Decimal (default), binary, octal and hexadecimal.");
puts("- Trigonometric modes: Radians (default) and degrees.");
puts("  Select mode with command line options (-) or mode operator (:)");
puts("  d, b, o, h, r and g. Eg. in interactive mode use ':b' for binary.");
puts("- Variables: Variables are case-insensitive and assigned with '='.");
puts("  There are two predefined variables: E and PI.");
puts("- Operators: (, ), ^, /, *, -, +, & and | (in the order of precedence).");
puts("- Functions: lg(), ln(), rad(), deg(), sin(), cos(), tan(),");
puts("             asin(), acos(), atan(), sinh(), cosh(), tanh(), sqrt(),");
puts("             avg(), std().");
puts("- Eg. calc -r 'foo = sin(DEG($FF.8)) + (2 + 3)^2 / pi + (-1)'.");

	/* print variable names and values				*/
	for(i = 0; comm.vname[i] != '\0'; i += strlen(&comm.vname[i]) + 1)
		printf("%s = %g\n", &comm.vname[i], comm.value[a ++]);

}
