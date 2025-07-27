/* -------------------------------------------------------------------- */
/*                                                                      */
/* Clac - calculator (C) 1994 by Eero Tamminen. V. 16/5/1994. Freeware. */
/*                                                                      */
/*      Header for Clac, Conv and Front. Use tab size 8.                */
/*                                                                      */
/* -------------------------------------------------------------------- */

/* define some preprosessor symbols                                     */
#define VARS    32                      /* number of variables		*/
#define MAX_VAR 8                       /* max. variable name lenght	*/
#define VAR_NAM	VARS * MAX_VAR		/* stack for variable names	*/
#define MAX_LN  256                     /* max length for an expression */

/* define error codes                                                   */
#define GEN_ERR 1                       /* error in expression          */
#define PAR_ERR 2                       /* mismatched parenthesis       */
#define DEF_ERR 3                       /* undefined result 1/0,lg(-1)  */
#define MOD_ERR 4                       /* unrecogniced mode            */
#define OVR_ERR 5                       /* mode overflow                */
#define VAR_ERR 6                       /* variable not defined         */
#define FNC_ERR 7                       /* unrecogniced function        */
#define STK_ERR 8			/* par/val/op stack full	*/
#define NO_EXP	9			/* no expression given		*/

/* define mode identifiers                                              */
#define DEC     1                               /* output modes         */
#define BIN     2
#define OCT     3
#define HEX     4
#define RAD     1                               /* trig. modes          */
#define DEG     2

/* define which character indicates which type of number on expression  */
#define BIN_SYM '%'                             /* binary decimal       */
#define OCT_SYM '#'                             /* octal decimal        */
#define HEX_SYM '$'                             /* hexadecimal          */

#ifndef TRUE
#define FALSE     0
#define TRUE      !FALSE
#endif

/* communication structure between clac and the main application        */
struct exp_packet {
	int error;                      /* evaluation error             */
	int err_pos;			/* pos. of error in exp. string	*/
	int trig_mode;                  /* trigonometric mode           */
	double result;                  /* result of evaluation         */
	char exp[MAX_LN + 1];           /* expression to calculate      */
	char vname[VAR_NAM + 2];	/* names of the variables       */
	double value[VARS + 1];         /* values of the variables      */
};

/* Exp[] and trig_mode should be filled when calc() is called.          */
/* Optionally also vname[] and value[] arrays can be filled up.         */
/* Variable names have to be terminated with a NULL.                    */
/* Calc() returns answer in exp[] & result + a possible error in error. */

void    calc();                         /* evaluate expression          */
int     conv();                         /* convert double to ascii      */
