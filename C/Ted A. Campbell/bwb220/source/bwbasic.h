/***************************************************************

        bwbasic.h       Header File
                        for Bywater BASIC Interpreter

                        Copyright (c) 1993, Ted A. Campbell
                        Bywater Software

                        email: tcamp@delphi.com

        Copyright and Permissions Information:

        All U.S. and international rights are claimed by the author,
        Ted A. Campbell.

	This software is released under the terms of the GNU General
	Public License (GPL), which is distributed with this software
	in the file "COPYING".  The GPL specifies the terms under
	which users may copy and use the software in this distribution.

	A separate license is available for commercial distribution,
	for information on which you should contact the author.

***************************************************************/

/*---------------------------------------------------------------*/
/* NOTE: Modifications marked "JBV" were made by Jon B. Volkoff, */
/* 11/1995 (eidetics@cerf.net).                                  */
/*---------------------------------------------------------------*/

#ifndef TRUE
#define TRUE    -1
#define FALSE   0
#endif

/***************************************************************

	bwbasic.h	Part I: Definitions

***************************************************************/

/* Version number */

#define VERSION         "2.25 (mod.)"          /* Current version number */

/***************************************************************

	bwbasic.h:	Part I-A: Define Major Hardware Implementation

			Gone is the simplicity of earlier versions.
			You must specify one and only one of the
			following hardware implementations as TRUE.
			IMP_TTY is the default implementation.
			It is the most minimal, but the most
			universal hardware implementation.

			If you pick IMP_TTY then check the settings
			in bwx_tty.h for your system.

***************************************************************/

#define IMP_TTY         TRUE     /* simple TTY-style interface using stdio */
#define IMP_IQC         FALSE    /* IBM PC, Microsoft QuickC Compiler */
#define IMP_NCU         FALSE    /* Linux, ncurses */
#define ALLOW_RENUM     TRUE     /* Added by JBV */
#define ATARI				TRUE		/* for AtariST/PureC */

#if IMP_TTY
#include "bwx_tty.h"
#endif

#if IMP_IQC
#include "bwx_iqc.h"
#endif

#if IMP_NCU
#include "bwx_ncu.h"
#endif

/***************************************************************

	bwbasic.h:	Part I-B: Define Compiler Implementation

			You also need to give some information about
			your C compiler.  If your compiler is ANSI-
			compatible, don't worry about these.  But
			if your compiler is "stock," you might
			want to indicate which of the following
			sets of features it has or dosn't have.

***************************************************************/

#ifdef MSDOS
#define HAVE_RAISE TRUE
#define HAVE_STRING TRUE
#define HAVE_STDLIB TRUE
#endif

#ifdef ATARI
#define HAVE_STRING TRUE
#define HAVE_STDLIB TRUE
#define HAVE_RAISE TRUE
#endif

#ifdef __STDC__
#define	HAVE_SIGNAL	TRUE
#else
#define	HAVE_SIGNAL	TRUE	/* Compiler supports signal() */
#endif

#ifdef __STDC__
#define	HAVE_LONGJUMP	TRUE
#else
#define	HAVE_LONGJUMP	TRUE	/* Compiler supports setjmp() and longjmp() */
#endif

/* configure sets this */
#ifndef HAVE_RAISE
#define HAVE_RAISE	FALSE	/* Compiler supports raise() */
#endif

/* configure sets this */
#ifndef HAVE_STRING
#define	HAVE_STRING	FALSE	/* Compiler has <string.h> header */
#endif

/* configure sets this */
#ifndef HAVE_STDLIB
#define HAVE_STDLIB	FALSE	/* Compiler has <stdlib.h> header */
#endif

/* configure sets this (section added by JBV) */
#ifndef HAVE_UNISTD
#define HAVE_UNISTD	FALSE	/* Compiler has <unistd.h> header */
#endif

#ifdef __STDC__
#define HAVE_SYSTYPES	TRUE
#else
#define HAVE_SYSTYPES	TRUE	/* Compiler has <sys/types.h> header */
#endif

#ifdef __STDC__
#define HAVE_SYSSTAT	TRUE
#else
#define HAVE_SYSSTAT	TRUE	/* Compiler has <sys/stat.h> header */
#endif

/***************************************************************

	bwbasic.h:	Part I-C: Define Program Configuration

			You must specify one and only one of the
			following progrm configurations as TRUE.
			If you specify CFG_CUSTOM, then you will
			need to fill out the custom section below.

***************************************************************/

#define	CFG_ANSIMINIMAL	FALSE   /* Conforms to ANSI Minimal BASIC standard X3.60-1978 */
#define CFG_COMMON      FALSE   /* Small implementation with commands and functions common to GWBASIC (tm) and ANSI full BASIC */
#define CFG_MSTYPE      FALSE   /* Configuration similar to Microsoft line-oriented BASICs */
#define	CFG_ANSIFULL	FALSE	/* Conforms to ANSI Full BASIC standard X3.113-1987 */
#define CFG_CUSTOM      TRUE    /* Custom Configuration specified below */

/***************************************************************

	bwbasic.h:	Part I-D: Define Custom Program Configuration

			If you specified CFG_CUSTOM above, then
			you will need to fill out this section.

***************************************************************/

#if CFG_CUSTOM
#define COMMAND_SHELL   TRUE		/* allow command shell processing */
#define PROFILE         TRUE            /* interpret profile at beginning */
#define NUMBER_DOUBLE	TRUE		/* define BASIC number as double: default is float*/
#define MULTISEG_LINES  TRUE            /* allow multi-segment lines delimited by ':' */
#define PARACT		FALSE		/* Implement PARallen ACTion (Multi-tasking) interpreter */
#define INTERACTIVE	TRUE		/* interactive programming environment and related commands */
#define COMMON_CMDS	TRUE		/* commands common to ANSI full BASIC and GWBASIC */
#if UNIX_CMDS
#define UNIX_CMDS	TRUE 		/* implement Unix-style directory commands  */
#endif
#define STRUCT_CMDS     TRUE           /* commands for structured programming required by full ANSI BASIC */
#define MS_CMDS         TRUE            /* commands specific to Microsoft GWBASIC (tm) */
#define MS_FUNCS        TRUE            /* Microsoft-specific functions and commands */
#define	COMMON_FUNCS	TRUE		/* functions common to GWBASIC and ANSI full BASIC */
#define ANSI_FUNCS	TRUE		/* functions required by ANSI full BASIC */
#endif					/* end of CFG_CUSTOM */

/***************************************************************

	bwbasic.h:	Part I-E: Define Natural Language for Messages

			One and only one of the following must be
			defined as TRUE.  Note that the language
			definitions themselves are in file bwb_mes.h.
			If none is specified, then ENGLISH will be
			taken as the default.

***************************************************************/

#define STD_ENGLISH     TRUE            /* standard English */
#define POL_ENGLISH     FALSE		/* polite English messages */
#define IMP_ENGLISH	FALSE		/* impolite English messages */
#define LATIN		FALSE		/* Latin language messages */
#define STD_RUSSIAN	FALSE		/* Russian language messages */
#define STD_GERMAN      FALSE           /* German language messages */
#define ESPERANTO       FALSE           /* Esperanto messages */

/***************************************************************

	bwbasic.h:	Part I-F: Define Debugging Options

			You can specify debugging options here.

			Defining DEBUG true provides some useful commands:
			CMDS, VARS, FNCS

***************************************************************/

#define DEBUG           FALSE  	/* current debugging */
#define PROG_ERRORS     TRUE  	/* identify serious programming errors */
					/* and print extensive error messages */
					/* This will override messages defined in */
					/* bwb_mes.h, and almost all messages will be in English */
#define CHECK_RECURSION FALSE		/* check for recursion violation in expression parser */
#define INTENSIVE_DEBUG FALSE           /* old debugging; might be useful later */
#define REDIRECT_STDERR FALSE           /* Redirect stderr to file ERRFILE */
#define TEST_BSTRING    FALSE           /* test bstring integrity */

#ifdef __STDC__
#define ANSI_C          TRUE            /* FALSE to test and debug non-ANSI-C version
					   with ANSI C compiler (watch out) */
#endif

/***************************************************************

	bwbasic.h:	This ends the section of definitions that
			users of bwBASIC will normally need to
			specify. The following are internally defined.

			Note that you may need to set up the default
			FILES command and the default editor below.
			See Part I-G

***************************************************************/

#if CFG_ANSIMINIMAL
#define COMMAND_SHELL   FALSE		/* allow command shell processing */
#define PROFILE		FALSE		/* interpret profile at beginning */
#define NUMBER_DOUBLE	FALSE		/* define BASIC number as double: default is float*/
#define MULTISEG_LINES	FALSE		/* allow multi-segment lines delimited by ':' */
#define PARACT		FALSE		/* Implement PARallen ACTion (Multi-tasking) interpreter */
#define INTERACTIVE	TRUE		/* interactive programming environment and related commands */
#define COMMON_CMDS	FALSE		/* commands common to ANSI full BASIC and GWBASIC */
#if UNIX_CMDS
#define UNIX_CMDS	FALSE 		/* implement Unix-style directory commands  */
#endif
#define STRUCT_CMDS	FALSE		/* commands for structured programming required by full ANSI BASIC */
#define MS_CMDS	FALSE		/* commands specific to Microsoft GWBASIC (tm) */
#define MS_FUNCS	FALSE		/* Microsoft-specific functions and commands */
#define	COMMON_FUNCS	FALSE		/* functions common to GWBASIC and ANSI full BASIC */
#define ANSI_FUNCS	FALSE		/* functions required by ANSI full BASIC */
#endif					/* end of CFG_ANSIMINIMAL */

#if CFG_COMMON
#define COMMAND_SHELL   FALSE		/* allow command shell processing */
#define PROFILE		FALSE		/* interpret profile at beginning */
#define NUMBER_DOUBLE	FALSE		/* define BASIC number as double: default is float*/
#define MULTISEG_LINES	FALSE		/* allow multi-segment lines delimited by ':' */
#define PARACT		FALSE		/* Implement PARallen ACTion (Multi-tasking) interpreter */
#define INTERACTIVE	TRUE		/* interactive programming environment and related commands */
#define COMMON_CMDS	TRUE		/* commands common to ANSI full BASIC and GWBASIC */
#if UNIX_CMDS
#define UNIX_CMDS	FALSE 		/* implement Unix-style directory commands  */
#endif
#define STRUCT_CMDS	FALSE		/* commands for structured programming required by full ANSI BASIC */
#define MS_CMDS	FALSE		/* commands specific to Microsoft GWBASIC (tm) */
#define MS_FUNCS	FALSE		/* Microsoft-specific functions and commands */
#define	COMMON_FUNCS	TRUE		/* functions common to GWBASIC and ANSI full BASIC */
#define ANSI_FUNCS	FALSE		/* functions required by ANSI full BASIC */
#endif					/* end of CFG_COMMON */

#if CFG_ANSIFULL
#define COMMAND_SHELL   TRUE		/* allow command shell processing */
#define PROFILE		TRUE		/* interpret profile at beginning */
#define NUMBER_DOUBLE	FALSE		/* define BASIC number as double: default is float*/
#define MULTISEG_LINES	FALSE		/* allow multi-segment lines delimited by ':' */
#define PARACT		TRUE		/* Implement PARallen ACTion (Multi-tasking) interpreter */
#define INTERACTIVE	TRUE		/* interactive programming environment and related commands */
#define COMMON_CMDS	TRUE		/* commands common to ANSI full BASIC and GWBASIC */
#if UNIX_CMDS
#define UNIX_CMDS	FALSE 		/* implement Unix-style directory commands  */
#endif
#define STRUCT_CMDS	TRUE		/* commands for structured programming required by full ANSI BASIC */
#define MS_CMDS	FALSE		/* commands specific to Microsoft GWBASIC (tm) */
#define MS_FUNCS	FALSE		/* Microsoft-specific functions and commands */
#define	COMMON_FUNCS	TRUE		/* functions common to GWBASIC and ANSI full BASIC */
#define ANSI_FUNCS	TRUE		/* functions required by ANSI full BASIC */
#endif					/* end of CFG_ANSIFULL */

#if CFG_MSTYPE
#define COMMAND_SHELL   FALSE		/* allow command shell processing */
#define PROFILE		FALSE		/* interpret profile at beginning */
#define NUMBER_DOUBLE	FALSE		/* define BASIC number as double: default is float*/
#define MULTISEG_LINES	TRUE		/* allow multi-segment lines delimited by ':' */
#define PARACT		FALSE		/* Implement PARallen ACTion (Multi-tasking) interpreter */
#define INTERACTIVE	TRUE		/* interactive programming environment and related commands */
#define COMMON_CMDS	TRUE		/* commands common to ANSI full BASIC and GWBASIC */
#define STRUCT_CMDS	FALSE		/* commands for structured programming required by full ANSI BASIC */
#define MS_CMDS	TRUE		/* commands specific to Microsoft GWBASIC (tm) */
#define MS_FUNCS	TRUE		/* Microsoft-specific functions and commands */
#define	COMMON_FUNCS	TRUE		/* functions common to GWBASIC and ANSI full BASIC */
#define ANSI_FUNCS	FALSE		/* functions required by ANSI full BASIC */
#endif                                  /* end of CFG_MSTYPE */

/* inclusions and definitions necessary if C compiler is not ANSI compliant */

#if HAVE_STRING
#include <string.h>
#else
#include <strings.h>
#endif

#if HAVE_STDLIB
#include <stdlib.h>
#endif

/* Section added by JBV */
#if HAVE_UNISTD
#include <unistd.h>
#endif

#if HAVE_SYSTYPES
#include <sys/types.h>
#endif

#if HAVE_STDLIB				/* if neither ANSI */
#else
#if HAVE_SYSTYPES			/* nor SYSTYPES */
#else
#define size_t	unsigned int		/* then define these */
#define time_t 	long 
#endif
#endif

/* define number of commands */
#define CMDS_CORE       22              /* number of core commands defined */
#if UNIX_CMDS
#define CMDS_DIR	5
#else
#define CMDS_DIR	0
#endif
#if COMMON_CMDS
#define CMDS_COMMON	25 /* Was 24 (JBV) */
#else
#define CMDS_COMMON	0
#endif
#if STRUCT_CMDS
#define CMDS_STC	10
#else
#define CMDS_STC	0
#endif
#if INTERACTIVE
#define CMDS_INT	8
#else
#define CMDS_INT	0
#endif
#if MS_CMDS
#define CMDS_MS         5+IMP_CMDCLS+IMP_CMDLOC+IMP_CMDCOLOR
#else
#define CMDS_MS		0
#endif
#if DEBUG
#define CMDS_DEBUG      3               /* number of debugging cmds */
#else
#define CMDS_DEBUG      0               /* no debugging cmds */
#endif
#define COMMANDS        (CMDS_CORE+CMDS_DEBUG+CMDS_DIR+CMDS_COMMON+CMDS_INT+CMDS_MS+CMDS_STC)

/* define number of functions */
#define FUNCS_BASE      14		/* number of basic functions */
#ifdef INTENSIVE_DEBUG
#define FUNCS_DEBUG	1		/* number of debugging functions */
#else
#define FUNCS_DEBUG	0		/* number of debugging functions */
#endif
#if MS_FUNCS
#define FUNCS_MS        (25+IMP_FNCINKEY)
#else
#define FUNCS_MS	0
#endif
#if COMMON_FUNCS
#define FUNCS_COMMON    7
#else
#define FUNCS_COMMON	0
#endif
#if ANSI_FUNCS
#define FUNCS_ANSI	0
#else
#define FUNCS_ANSI	0
#endif
#define FUNCTIONS	(FUNCS_BASE+FUNCS_DEBUG+FUNCS_MS+FUNCS_COMMON+FUNCS_ANSI)

/* Check for inconsistencies */

#if MULTISEG_LINES & STRUCT_CMDS
/* ERROR:  MULTISEG_LINES and STRUCT_CMDS cannot be defined together! */
#endif

/***************************************************************

	bwbasic.h:	Part I-G: Define User Defaults

			Defining your default editor and files commands
			is a good idea. You must supply the file name
			for the editor to use.  These defaults can be
			changed from inside the program or in your profile
			program by setting the appropriate variables
			shown below.

***************************************************************/

#define DEF_EDITOR      "vi"            /* default editor */
#define DEF_FILES       "ls -Fx"         /* default "files" command */
#define DEF_COLORS      256             /* default # of colors */
#define DEFVNAME_EDITOR "BWB.EDITOR$"   /* default variable name for EDITOR */
#define DEFVNAME_PROMPT "BWB.PROMPT$"   /* default variable name for PROMPT */
#define DEFVNAME_FILES  "BWB.FILES$"    /* default variable name for FILES */
#define DEFVNAME_COLORS "BWB.COLORS"    /* default variable name for COLORS */
#define DEFVNAME_IMPL   "BWB.IMPLEMENTATION$" /* default variable name for IMPLEMENTATION */
#define ERRFILE         "err.out"       /* Filename for redirected error messages */
#define PROFILENAME	"profile.bas"	/* Filename for profile execution */
#define	TASKS		4		/* number of tasks available */
#define MAXARGSIZE      128             /* maximum size of argument */
#define MAXREADLINESIZE 256             /* size of read_line buffer */
#define MAXCMDNAMESIZE  64              /* maximum size for command name */
#define MAXLINENO       32766           /* maximum line number */
#define MAXVARNAMESIZE  40              /* maximum size for variable name */
#define MAXFILENAMESIZE 40              /* maximum size for file name */
#if 0 /* JBV 9/4/97 */
#define MAXSTRINGSIZE   255             /* maximum string length */
#endif
#define MAXSTRINGSIZE   5000            /* maximum string length */
#define EXECLEVELS      64              /* EXEC stack levels */
#define MAX_GOLINES     12              /* Maximum # of lines for ON...GOTO statements */
#define MAX_FARGS       6               /* maximum # arguments to function */
#define MAX_DIMS	64		/* maximum # of dimensions */
#define ESTACKSIZE      64              /* elements in expression stack */
#define XTXTSTACKSIZE   16              /* elements in eXecute TeXT stack */
#define N_OPERATORS     25              /* number of operators defined */
#define N_ERRORS	25		/* number of errors defined */
#define MAX_PRECEDENCE  20              /* highest (last) level of precedence */
#if 0 /* JBV 9/96 */
#define MININTSIZE      -32767          /* minimum integer size */
#define MAXINTSIZE       32767          /* maximum integer size */
#endif
#define MININTSIZE      -2147483647     /* minimum integer size */
#define MAXINTSIZE       2147483647     /* maximum integer size */
#define DEF_SUBSCRIPT   11              /* default subscript */
#define DEF_DEVICES     16              /* default number of devices available */
#define DEF_WIDTH	128		/* default width for devices */
#define PRN_TAB		0x02		/* send TAB followed by col number to output device */
#define COMPRESS_FUNCS  TRUE

/* Derivative definitions */

#if MULTISEG_LINES
#define MARK_LINES	FALSE
#else
#define MARK_LINES	TRUE
#endif

#if PARACT
#define CURTASK		bwb_tasks[ bwb_curtask ]->
#define LOCALTASK	bwb_tasks[ task ]->
#else
#define CURTASK
#define LOCALTASK
#endif

#if DEBUG
#define PERMANENT_DEBUG TRUE
#else
#define PERMANENT_DEBUG FALSE
#endif

#if HAVE_STDLIB
#else
extern char *calloc();

#ifndef NULL
#define NULL	0L
#endif

#endif

/* typedef for BASIC number */

#if NUMBER_DOUBLE
typedef double bnumber;
#else
typedef float bnumber;
#endif

/* define variable types based on last character */

#define STRING          '$'

/* define mathematical operations */

#define MULTIPLY        '*'
#define DIVIDE          '/'
#define ADD             '+'
#define SUBTRACT        '-'
#define ARGUMENT        'A'

/* Operations defined */

#define OP_ERROR        -255		/* operation error (break out) */
#define OP_NULL         0               /* null: operation not defined yet */
#define NUMBER          1               /* number held as internal variable in uvar */
#define CONST_STRING    2               /* string constant */
#define CONST_NUMERICAL 3               /* numerical constant */
#define FUNCTION        4               /* function header */
#define VARIABLE        5               /* external variable pointed to by xvar */
#define PARENTHESIS     6               /* begin parenthetical expression */
#define OP_ADD          7               /* addition sign '+' */
#define OP_SUBTRACT     8               /* subtraction sign '-' */
#define OP_MULTIPLY     9               /* multiplication sign '*' */
#define OP_DIVIDE       10              /* division sign '/' */
#define OP_MODULUS      11              /* modulus "MOD" */
#define OP_EXPONENT     12              /* exponentiation '^' */
#define OP_INTDIVISION  13              /* integer division sign '\' */
#define OP_NEGATION     14              /* negation '-' ??? */
#define OP_STRJOIN      15              /* string join ';' */
#define OP_STRTAB       16              /* string tab ',' */
#define OP_EQUALS       17              /* either logical equal operator */
#define OP_ASSIGN       18              /* assignment operator */
#define OP_NOTEQUAL     20              /* inequality */
#define OP_LESSTHAN     21              /* less than */
#define OP_GREATERTHAN  22              /* greater than */
#define OP_LTEQ         23              /* less than or equal to */
#define OP_GTEQ         24              /* greater than or equal to */
#define OP_NOT          25              /* negation */
#define OP_AND          26              /* conjunction */
#define OP_OR           27              /* disjunction */
#define OP_XOR          28              /* exclusive or */
#define OP_IMPLIES      29              /* implication */
#define OP_EQUIV        30              /* equivalence */
#define OP_TERMINATE    31              /* terminate expression parsing */
#define OP_USERFNC	32		/* user-defined function */

/* Device input/output modes */

#define DEVMODE_AVAILABLE  -1
#define DEVMODE_CLOSED     0
#define DEVMODE_OUTPUT     1
#define DEVMODE_INPUT      2
#define DEVMODE_APPEND     3
#define DEVMODE_RANDOM     4

/* codes for EXEC stack and for function-sub-label lookup table */

#define EXEC_NORM	0
#define	EXEC_GOSUB	1
#define	EXEC_WHILE	2
#define EXEC_FOR        3
#define EXEC_FUNCTION	4
#define EXEC_CALLSUB	5
#define EXEC_IFTRUE	6
#define EXEC_IFFALSE	7
#define EXEC_MAIN	8
#define EXEC_SELTRUE	9
#define EXEC_SELFALSE	10
#define EXEC_LABEL      11
#define EXEC_DO         12
#define EXEC_ON         13

/***************************************************************

	bwbasic.h	Part II: Structures

***************************************************************/

/* Typdef structure for strings under Bywater BASIC */

typedef struct bstr
   {
   /* unsigned int was unsigned char (JBV 9/4/97) */
   unsigned int length;			/* length of string */
   char *sbuffer;			/* pointer to string buffer */
   int rab;				/* is it a random-access buffer? */
#if TEST_BSTRING
   char name[ MAXVARNAMESIZE + 1 ];	/* name for test purposes */
#endif
   } bstring;

/* Structure used for all variables under Bywater BASIC */

struct bwb_variable
   {
   char name[ MAXVARNAMESIZE + 1 ];	/* name */
   int type;                            /* type, i.e., STRING or NUMBER */
#if OLDWAY
   void *array;				/* pointer to array memory */
#endif
   bnumber *memnum;			/* memory for number */
   bstring *memstr;			/* memory for string */
   size_t array_units;			/* total number of units of memory */
   int  *array_sizes;			/* pointer to array of <dimensions>
                                           integers, with sizes of each
                                           dimension */
   int *array_pos;                      /* current position in array */
   int dimensions;                      /* number of dimensions,
                                           0 = not an array */
   struct bwb_variable *next;           /* next variable in chain */
   int common;				/* should this variable be common to chained programs? */
   int preset;				/* preset variable: CLEAR should not alter */
   };

/* Structure to represent program lines under Bywater BASIC */

struct bwb_line
   {
   struct bwb_line *next;               /* pointer to next line in chain */
   int number;                          /* line number */
   char xnum;				/* is there actually a line number? */
   char *buffer;			/* buffer to hold the line */
   int position;                        /* current position in line */
   int lnpos;                           /* line number position in buffer */
   int lnum;                            /* line number read from buffer */
   int cmdpos;                          /* command position in buffer */
   int cmdnum;                          /* number of command in command table
                                           read from buffer */
   int startpos;                        /* start of rest of line read from buffer */
   int marked;                          /* has line been checked yet? */
   };

/* Structure used for all predefined functions under Bywater BASIC */

struct bwb_function
   {
   char name[ MAXVARNAMESIZE + 1 ];     /* name */
   int type;                            /* type, i.e., STRING or NUMBER */
   int arguments;                       /* number of args passed */
#if ANSI_C
   struct bwb_variable * (*vector) ( int argc, struct bwb_variable *argv, int unique_id );  /* vector to function to call */
#else
   struct bwb_variable * (*vector) ();  /* vector to function to call */
#endif
   struct bwb_function *next;           /* next function in chain */
   int id;                              /* id to identify multiple functions */
   };

/* Structure to represent all command statements under Bywater BASIC */

struct bwb_command
   {
   char name[ MAXCMDNAMESIZE + 1 ];
#if ANSI_C
   struct bwb_line * (*vector) (struct bwb_line *);
#else
   struct bwb_line * (*vector) ();
#endif
   };

/* Structure to define device stack for Bywater BASIC */

struct dev_element
   {
   int mode;                            /* DEVMODE_ item */
   int width;				/* width for output control */
   int col;				/* current column */
   int reclen;                          /* record length for random access */
   int next_record;			/* next record to read/write */
   int loc;				/* location in file */
   int lof;				/* length of file in bytes (JBV) */
   char filename[ MAXFILENAMESIZE + 1 ];/* filename */
   FILE *cfp;                           /* C file pointer for this device */
   char *buffer;			/* pointer to character buffer for random access */
   };

/* Structure to define expression stack elements under Bywater BASIC */

struct exp_ese
   {
   int operation;                       /* operation at this level */
   char type;				/* type of operation at this level:
   					   STRING or NUMBER */
   bstring sval;			/* string */
   bnumber nval;			/* number */
   char string[ MAXSTRINGSIZE + 1 ]; 	/* string for writing */
   struct bwb_variable *xvar;           /* pointer to external variable */
   struct bwb_function *function;       /* pointer to function structure */
   int array_pos[ MAX_DIMS ];		/* array for variable positions */
   int pos_adv;                         /* position advanced in string */
   int rec_pos;                         /* position marker for recursive calls */
   };

/* structure for FUNCTION-SUB loopup table element */

struct fslte
   {
   char *name;
   struct bwb_line *line;
   int code;
   int startpos;			/* starting position in line */
   struct fslte *next;
   struct bwb_variable *local_variable;
   };

/* Structure to define EXEC stack elements */

struct exse
   {
   struct bwb_line *line;		/* line for execution */
   int code;				/* code to note special operations */
   int position;			/* position in line for restore */
   struct bwb_variable *local_variable;	/* local variable chain and current FOR counter */
   struct bwb_variable *calling_variable[ MAX_FARGS ];
   int n_cvs;				/* number of calling variables */
   int for_step;			/* STEP value for FOR */
   int for_target;			/* target value for FOR */
   struct bwb_line *while_line;		/* return line for current WHILE */
   struct bwb_line *wend_line;          /* breakout line for current WHILE (or FOR-NEXT) */
   struct exp_ese expression;		/* expression for evaluation by SELECT CASE */
#if MULTISEG_LINES
   struct bwb_line *for_line;           /* top line for FOR-NEXT loop, multisegmented */
   int for_position;                    /* position in top line for FOR-NEXT loop, multisegmented */
#endif
   };

struct xtxtsl
   {
   int  position;
   struct bwb_line l;
   };

/* Structure to define bwBASIC task: UNDER CONSTRUCTION */

#if PARACT
struct bwb_task
   {
   char progfile[ MAXARGSIZE ];		/* program file */
   int rescan;				/* program needs to be rescanned */
   int number;				/* current line number */
   struct bwb_line *bwb_l;		/* current line pointer */
   struct bwb_line bwb_start;		/* starting line marker */
   struct bwb_line bwb_end;		/* ending line marker */
   struct bwb_line *data_line;      	/* current line to read data */
   int data_pos;			/* position in data_line */
   struct bwb_variable var_start;	/* variable list start marker */
   struct bwb_variable var_end;		/* variable list end marker */
   struct bwb_function fnc_start;	/* function list start marker */
   struct bwb_function fnc_end;		/* function list end marker */
   struct fslte fslt_start;		/* function-sub-label lookup table start marker */
   struct fslte fslt_end;		/* function-sub-label lookup table end marker */
   int exsc;				/* EXEC stack counter */
   int expsc;				/* expression stack counter */
   int xtxtsc;				/* eXecute TeXT stack counter */
   struct exse excs[ EXECLEVELS ];	/* EXEC stack */
   struct exp_ese exps[ ESTACKSIZE ];	/* Expression stack */
   struct xtxtsl xtxts[ XTXTSTACKSIZE ];/* Execute Text stack */
   };

extern struct bwb_task *bwb_tasks[ TASKS ];	/* table of task pointers */

#else					/* not multi-tasking */

extern char progfile[ MAXARGSIZE ];	/* program file */
extern int rescan;			/* program needs to be rescanned */
extern int number;			/* current line number */
extern struct bwb_line *bwb_l;		/* current line pointer */
extern struct bwb_line bwb_start;	/* starting line marker */
extern struct bwb_line bwb_end;		/* ending line marker */
extern struct bwb_line *data_line;      /* current line to read data */
extern int data_pos;			/* position in data_line */
extern struct bwb_variable var_start;	/* variable list start marker */
extern struct bwb_variable var_end;	/* variable list end marker */
extern struct bwb_function fnc_start;	/* function list start marker */
extern struct bwb_function fnc_end;	/* function list end marker */
extern struct fslte fslt_start;		/* function-sub-label lookup table start marker */
extern struct fslte fslt_end;		/* function-sub-label lookup table end marker */
extern int exsc;			/* EXEC stack counter */
extern int expsc;			/* expression stack counter */
extern int xtxtsc;			/* eXecute TeXT stack counter */
extern struct exse *excs;		/* EXEC stack */
extern struct exp_ese *exps;		/* Expression stack */
extern struct xtxtsl *xtxts;		/* Execute Text stack */
#endif

extern int bwb_curtask;			/* current task */
extern struct bwb_variable *ed;         /* EDITOR$ variable */
extern struct bwb_variable *fi;         /* FILES$ variable */
extern struct bwb_variable *pr;         /* PROMPT$ variable */
extern struct bwb_variable *im;         /* IMPLEMENTATION$ variable */
extern struct bwb_variable *co;         /* COLORS variable */

/***************************************************************

	bwbasic.h	Part III: Global Data

***************************************************************/

extern char *bwb_ebuf;
extern int bwb_trace;
extern int dim_base;			/* set by OPTION BASE */
extern struct bwb_command bwb_cmdtable[ COMMANDS ];
extern FILE *errfdevice;                /* output device for error messages */
extern int err_line;			/* line in which error occurred */
extern int err_number;			/* number of last error */
extern char err_gosubl[ MAXVARNAMESIZE + 1 ]; /* line for error GOSUB */
extern char *err_table[ N_ERRORS ];	/* table of error messages */
extern int prn_col;
extern struct bwb_function bwb_prefuncs[ FUNCTIONS ];	/* table of predefined functions */

#if COMMON_CMDS
extern struct dev_element *dev_table;   /* table of devices */
#endif

/* Operator Structure and Table */

struct bwb_op
   {
   char symbol[ 8 ];                    /* BASIC symbol for the operator */
   int operation;                       /* internal code for the operator */
   int precedence;                      /* level of precedence, 0 = highest */
   };

extern struct bwb_op exp_ops[ N_OPERATORS ]; /* the table itself, filled in in bwb_tbl.c */

/***************************************************************

	bwbasic.h	Part IV: Function Prototypes

***************************************************************/

#if ANSI_C
extern void *CALLOC(size_t nelem, size_t elsize, char *str); /* JBV */
extern void FREE(void *ptr, char *str); /* JBV */
extern void bwb_init( int argc, char **argv );
extern int bwb_fload( FILE *file );
extern int bwb_ladd( char *buffer, int replace );
extern int bwb_findcmd( int argc, int a, struct bwb_line *l );
extern struct bwb_line *bwb_xtxtline( char *buffer );
extern void bwb_mainloop( void );
extern void bwb_execline( void );
extern int bwb_gets( char *buffer );
extern int bwb_error( char *message );
extern void break_handler( void );
extern void break_mes( int x );
extern struct bwb_line *bwb_null( struct bwb_line *l );
extern struct bwb_line *bwb_rem( struct bwb_line *l );
extern struct bwb_line *bwb_lerror( struct bwb_line *l );
extern struct bwb_line *bwb_run( struct bwb_line *l );
extern struct bwb_line *bwb_let( struct bwb_line *l );
extern struct bwb_line *bwb_load( struct bwb_line *l );
extern struct bwb_line *bwb_merge( struct bwb_line *l );
extern struct bwb_line *bwb_chain( struct bwb_line *l );
extern struct bwb_line *bwb_common( struct bwb_line *l );
extern struct bwb_line *bwb_xload( struct bwb_line *l );
extern struct bwb_line *bwb_new( struct bwb_line *l );
extern struct bwb_line *bwb_save( struct bwb_line *l );
extern struct bwb_line *bwb_list( struct bwb_line *l );
extern struct bwb_line *bwb_xlist( struct bwb_line *l, FILE *file );
extern struct bwb_line *bwb_go( struct bwb_line *l );
extern struct bwb_line *bwb_goto( struct bwb_line *l );
extern struct bwb_line *bwb_gosub( struct bwb_line *l );
extern struct bwb_line *bwb_return( struct bwb_line *l );
extern struct bwb_line *bwb_xend( struct bwb_line *l );
extern struct bwb_line *bwb_system( struct bwb_line *l );
extern struct bwb_line *bwb_tron( struct bwb_line *l );
extern struct bwb_line *bwb_troff( struct bwb_line *l );
extern struct bwb_line *bwb_randomize( struct bwb_line *l );
extern struct bwb_line *bwb_stop( struct bwb_line *l );
extern struct bwb_line *bwb_data( struct bwb_line *l );
extern struct bwb_line *bwb_read( struct bwb_line *l );
extern struct bwb_line *bwb_restore( struct bwb_line *l );
extern struct bwb_line *bwb_delete( struct bwb_line *l );
extern struct bwb_line *bwb_if( struct bwb_line *l );
extern struct bwb_line *bwb_else( struct bwb_line *l );
extern struct bwb_line *bwb_elseif( struct bwb_line *l );
extern struct bwb_line *bwb_select( struct bwb_line *l );
extern struct bwb_line *bwb_case( struct bwb_line *l );
extern struct bwb_line *bwb_endselect( struct bwb_line *l );
extern struct bwb_line *bwb_endif( struct bwb_line *l );
extern struct bwb_line *bwb_while( struct bwb_line *l );
extern struct bwb_line *bwb_wend( struct bwb_line *l );
extern struct bwb_line *bwb_for( struct bwb_line *l );
extern struct bwb_line *bwb_next( struct bwb_line *l );
extern struct bwb_line *bwb_dim( struct bwb_line *l );
extern struct bwb_line *bwb_option( struct bwb_line *l );
extern struct bwb_line *bwb_open( struct bwb_line *l );
extern struct bwb_line *bwb_close( struct bwb_line *l );
extern struct bwb_line *bwb_get( struct bwb_line *l );
extern struct bwb_line *bwb_put( struct bwb_line *l );
extern struct bwb_line *bwb_rmdir( struct bwb_line *l );
extern struct bwb_line *bwb_chdir( struct bwb_line *l );
extern struct bwb_line *bwb_mkdir( struct bwb_line *l );
extern struct bwb_line *bwb_kill( struct bwb_line *l );
extern struct bwb_line *bwb_name( struct bwb_line *l );
extern struct bwb_line *bwb_rset( struct bwb_line *l );
extern struct bwb_line *bwb_lset( struct bwb_line *l );
extern struct bwb_line *bwb_field( struct bwb_line *l );
extern struct bwb_line *bwb_on( struct bwb_line *l );
extern struct bwb_line *bwb_line( struct bwb_line *l );
extern struct bwb_line *bwb_ddbl( struct bwb_line *l );
extern struct bwb_line *bwb_dint( struct bwb_line *l );
extern struct bwb_line *bwb_dsng( struct bwb_line *l );
extern struct bwb_line *bwb_dstr( struct bwb_line *l );
extern struct bwb_line *bwb_mid( struct bwb_line *l );
extern struct bwb_line *bwb_clear( struct bwb_line *l );
extern struct bwb_line *bwb_erase( struct bwb_line *l );
extern struct bwb_line *bwb_swap( struct bwb_line *l );
extern struct bwb_line *bwb_environ( struct bwb_line *l );
extern struct bwb_line *bwb_width( struct bwb_line *l );
extern struct bwb_line *bwb_write( struct bwb_line *l );
extern struct bwb_line *bwb_edit( struct bwb_line *l );
extern struct bwb_line *bwb_files( struct bwb_line *l );
extern struct bwb_line *bwb_do( struct bwb_line *l );
extern struct bwb_line *bwb_doloop( struct bwb_line *l );
extern struct bwb_line *bwb_cls( struct bwb_line *l );
extern struct bwb_line *bwb_locate( struct bwb_line *l );
extern struct bwb_line *bwb_color( struct bwb_line *l );
extern struct bwb_line *bwb_do( struct bwb_line *l );
extern struct bwb_line *bwb_loop( struct bwb_line *l );
extern struct bwb_line *bwb_exit( struct bwb_line *l );
extern struct bwb_line *bwb_exitfor( struct bwb_line *l );
extern struct bwb_line *bwb_exitdo( struct bwb_line *l );

extern struct bwb_line *bwb_zline( struct bwb_line *l );

extern void bwb_incexec( void );
extern void bwb_decexec( void );
extern int bwb_setexec( struct bwb_line *l, int position, int code );
extern int bwb_getcnd( char *lb, char *lhs, char *rhs, char *op, int *n );
extern int bwb_getlhs( char *lb, char *lhs, int *n );
extern int bwb_getop( char *lb, char *op, int *n );
extern int bwb_getrhs( char *lb, char *rhs, int *n );
extern int bwb_evalcnd( char *lhs, char *rhs, char *op );
extern int bwb_isstr( char *b );
extern int eval_int( int l, int r, char *op );
extern int eval_sng( float l, float r, char *op );
extern int eval_dbl( double l, double r, char *op );
extern struct exp_ese *bwb_exp( char *expression, int assignment, int *position );
extern int exp_getvfname( char *source, char *destination );
extern int exp_operation( int entry_level );
extern int inc_esc( void );
extern int dec_esc( void );
extern int fnc_init( int task );
extern struct bwb_function *fnc_find( char *buffer );
extern struct bwb_line *bwb_def( struct bwb_line *l );
extern int bwb_getargs( char *buffer );
extern int bwb_stripcr( char *s );
extern int bwb_numseq( char *buffer, int *start, int *end );
extern int bwb_freeline( struct bwb_line *l );
extern struct bwb_line *bwb_print( struct bwb_line *l );
extern int bwb_xprint( struct bwb_line *l, FILE *f );
extern int bwb_eltype( char *l_buffer, int p );
extern int var_init( int task );
extern int fslt_init( int task );
extern int var_delcvars( void );
extern struct bwb_variable *var_new( char *name );
extern struct bwb_variable *var_islocal( char *buffer );
extern int bwb_strel( char *lb, char *sb, int *n );
extern struct bwb_variable *bwb_numel( char *lb, int *n );
extern int bwb_const( char *lb, char *sb, int *n );
extern int bwb_getvarname( char *lb, char *sb, int *n );
extern struct bwb_variable *var_find( char *buffer );
extern int bwb_isvar( char *buffer );
extern struct bwb_line *bwb_input( struct bwb_line *l );
extern int inp_adv( char *b, int *c );
extern int var_make( struct bwb_variable *v, int type );
extern bstring *var_getsval( struct bwb_variable *nvar );
extern bstring *var_findsval( struct bwb_variable *v, int *pp );
extern bstring *exp_getsval( struct exp_ese *e );
extern int dim_getparams( char *buffer, int *pos, int *n_params, int **pp );
extern int adv_element( char *buffer, int *pos, char *element );
extern int adv_ws( char *buffer, int *pos );
#if MULTISEG_LINES
extern int adv_eos( char *buffer, int *pos );
#endif
extern int line_start( char *buffer, int *pos, int *lnpos, int *lnum,
   int *cmdpos, int *cmdnum, int *startpos );
extern int is_cmd( char *buffer, int *cmdnum );
extern int is_let( char *buffer, int *cmdnum );
extern int is_eol( char *buffer, int *position );
extern int is_numconst( char *buffer );
extern int is_label( char *buffer );
extern struct bwb_line * find_label( char *buffer );
extern struct bwb_line *find_loop( struct bwb_line *l );
extern int int_qmdstr( char *buffer_a, char *buffer_b );
extern struct bwb_line * cnd_xpline( struct bwb_line *l, char *buffer );
extern int scan_element( char *buffer, int *pos, char *element );

extern int prn_precision( struct bwb_variable *v );
extern int * prn_getcol( FILE *f );
extern int prn_getwidth( FILE *f );
extern int prn_xprintf( FILE *f, char *buffer );
extern int prn_xxprintf( FILE *f, char *buffer ); /* JBV */
extern int bwb_strtoupper( char *buffer );
extern int getcmdnum( char *cmdstr );

extern int str_btoc( char *buffer, bstring *s );
extern int str_btob( bstring *d, bstring *s );
extern int str_ctob( bstring *s, char *buffer );
extern int str_cmp( bstring *s, bstring *t );
extern char * str_cat( bstring *s, bstring *t );
extern int exp_findop( char *expression );
extern int exp_isop( char *expression );
extern int exp_isfn( char *expression );
extern int exp_isufn( char *expression );
extern int exp_isnc( char *expression );
extern int exp_isvn( char *expression );
extern int exp_iscmd( char *expression );
extern int exp_paren( char *expression );
extern int exp_strconst( char *expression );
extern int exp_numconst( char *expression );
extern int exp_function( char *expression );
extern int exp_ufnc( char *expression );
extern int exp_variable( char *expression );
extern int exp_validarg( char *expression );
extern int ln_asbuf( struct bwb_line *l, char *s );
extern int xputc( FILE *f, char c );
extern int bwx_signon( void );
extern int bwx_message( char *m );
extern int bwx_putc( char c );
extern int bwx_errmes( char *m );
extern int bwx_input( char *prompt, char *buffer );
extern void bwx_terminate( void );

#if COMMAND_SHELL
extern int bwx_shell( struct bwb_line *l );
#endif

int bwb_scan( void );
struct bwb_line *bwb_call( struct bwb_line *l );
struct bwb_line *bwb_sub( struct bwb_line *l );
struct bwb_line *bwb_endsub( struct bwb_line *l );
struct bwb_line *bwb_endfnc( struct bwb_line *l );
struct bwb_line *bwb_function( struct bwb_line *l );

extern bnumber var_getnval( struct bwb_variable *nvar );
extern bnumber *var_findnval( struct bwb_variable *v, int *pp );
extern bnumber exp_getnval( struct exp_ese *e );
extern bnumber *exp_findnval( struct exp_ese *e );

#if PARACT
extern int bwb_newtask( int task_requested );
#endif

#if INTERACTIVE
extern int bwb_interact( void );
#endif

#if DEBUG
extern int bwb_debug( char *message );
extern struct bwb_line *bwb_cmds( struct bwb_line *l );
extern struct bwb_line *bwb_vars( struct bwb_line *l );
extern struct bwb_line *bwb_fncs( struct bwb_line *l );
#endif

#ifdef ALLOW_RENUM
extern struct bwb_line *bwb_renum( struct bwb_line *l );
#endif

#if UNIX_CMDS
#if !HAVE_UNISTD /* Not needed if one has <unistd.h> (JBV) */
extern int rmdir( char *path );
extern int chdir( char *path );
#endif
#if !HAVE_SYSSTAT /* Not needed if one has <sys/stat.h> (JBV) */
#if MKDIR_ONE_ARG
extern int mkdir( char *path );
#else
extern int mkdir( char *path, unsigned short permissions );
#endif /* JBV */
#endif
#endif

/* declarations of function commands */

extern struct bwb_variable *fnc_null( int argc, struct bwb_variable *argv, int unique_id );
#if COMPRESS_FUNCS
extern struct bwb_variable *fnc_core( int argc, struct bwb_variable *argv, int unique_id );
#else
extern struct bwb_variable *fnc_abs( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_atn( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_cos( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_log( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_sin( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_asin( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_acos( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_sqr( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_sgn( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_int( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_rnd( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_exp( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_tan( int argc, struct bwb_variable *argv, int unique_id );
#endif
extern struct bwb_variable *fnc_tab( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_date( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_time( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_chr( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_mid( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_left( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_right( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_timer( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_val( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_len( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_hex( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_oct( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_cint( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_asc( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_mkd( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_mki( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_mks( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_cvi( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_cvd( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_cvs( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable *fnc_string( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_spc( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_space( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_environ( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_pos( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_err( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_erl( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_loc( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_lof( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_eof( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_csng( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_instr( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_str( int argc, struct bwb_variable *argv, int unique_id );
extern struct bwb_variable * fnc_inkey( int argc, struct bwb_variable *argv, int unique_id );

extern bnumber trnc_int( bnumber x );
extern int fnc_checkargs( int argc, struct bwb_variable *argv,
   int min, int max );
extern int ufsc;			/* user function stack counter */

#if DEBUG
extern struct bwb_variable *fnc_test( int argc, struct bwb_variable *argv, int unique_id );
#endif

#else                                   /* ANSI_C */

extern void *CALLOC(); /* JBV */
extern void FREE(); /* JBV */
extern void bwb_init();
extern int bwb_fload();
extern int bwb_ladd();
extern int bwb_findcmd();
extern struct bwb_line *bwb_xtxtline();
extern void bwb_mainloop();
extern void bwb_execline();
extern int bwb_gets();
extern int bwb_error();
extern void break_handler();
extern void break_mes();
extern struct bwb_line *bwb_null();
extern struct bwb_line *bwb_rem();
extern struct bwb_line *bwb_lerror();
extern struct bwb_line *bwb_run();
extern struct bwb_line *bwb_let();
extern struct bwb_line *bwb_load();
extern struct bwb_line *bwb_merge();
extern struct bwb_line *bwb_chain();
extern struct bwb_line *bwb_common();
extern struct bwb_line *bwb_xload();
extern struct bwb_line *bwb_new();
extern struct bwb_line *bwb_save();
extern struct bwb_line *bwb_list();
extern struct bwb_line *bwb_xlist();
extern struct bwb_line *bwb_go();
extern struct bwb_line *bwb_goto();
extern struct bwb_line *bwb_gosub();
extern struct bwb_line *bwb_return();
extern struct bwb_line *bwb_xend();
extern struct bwb_line *bwb_system();
extern struct bwb_line *bwb_tron();
extern struct bwb_line *bwb_troff();
extern struct bwb_line *bwb_randomize();
extern struct bwb_line *bwb_stop();
extern struct bwb_line *bwb_data();
extern struct bwb_line *bwb_read();
extern struct bwb_line *bwb_restore();
extern struct bwb_line *bwb_delete();
extern struct bwb_line *bwb_if();
extern struct bwb_line *bwb_else();
extern struct bwb_line *bwb_elseif();
extern struct bwb_line *bwb_select();
extern struct bwb_line *bwb_case();
extern struct bwb_line *bwb_endselect();
extern struct bwb_line *bwb_endif();
extern struct bwb_line *bwb_while();
extern struct bwb_line *bwb_wend();
extern struct bwb_line *bwb_for();
extern struct bwb_line *bwb_next();
extern struct bwb_line *bwb_dim();
extern struct bwb_line *bwb_option();
extern struct bwb_line *bwb_open();
extern struct bwb_line *bwb_close();
extern struct bwb_line *bwb_get();
extern struct bwb_line *bwb_put();
extern struct bwb_line *bwb_rmdir();
extern struct bwb_line *bwb_chdir();
extern struct bwb_line *bwb_mkdir();
extern struct bwb_line *bwb_kill();
extern struct bwb_line *bwb_name();
extern struct bwb_line *bwb_rset();
extern struct bwb_line *bwb_lset();
extern struct bwb_line *bwb_field();
extern struct bwb_line *bwb_on();
extern struct bwb_line *bwb_line();
extern struct bwb_line *bwb_ddbl();
extern struct bwb_line *bwb_dint();
extern struct bwb_line *bwb_dsng();
extern struct bwb_line *bwb_dstr();
extern struct bwb_line *bwb_mid();
extern struct bwb_line *bwb_clear();
extern struct bwb_line *bwb_erase();
extern struct bwb_line *bwb_swap();
extern struct bwb_line *bwb_environ();
extern struct bwb_line *bwb_width();
extern struct bwb_line *bwb_write();
extern struct bwb_line *bwb_edit();
extern struct bwb_line *bwb_files();
extern struct bwb_line *bwb_do();
extern struct bwb_line *bwb_doloop();
extern struct bwb_line *bwb_cls();
extern struct bwb_line *bwb_locate();
extern struct bwb_line *bwb_color();
extern struct bwb_line *bwb_do();
extern struct bwb_line *bwb_loop();
extern struct bwb_line *bwb_exit();
extern struct bwb_line *bwb_exitfor();
extern struct bwb_line *bwb_exitdo();

extern struct bwb_line *bwb_zline();

extern void bwb_incexec();
extern void bwb_decexec();
extern int bwb_setexec();
extern int bwb_getcnd();
extern int bwb_getlhs();
extern int bwb_getop();
extern int bwb_getrhs();
extern int bwb_evalcnd();
extern int bwb_isstr();
extern int eval_int();
extern int eval_sng();
extern int eval_dbl();
extern struct exp_ese *bwb_exp();
extern int exp_getvfname();
extern int exp_operation();
extern int inc_esc();
extern int dec_esc();
extern int fnc_init();
extern struct bwb_function *fnc_find();
extern struct bwb_line *bwb_def();
extern int bwb_getargs();
extern int bwb_stripcr();
extern int bwb_numseq();
extern int bwb_freeline();
extern struct bwb_line *bwb_print();
extern int bwb_xprint();
extern int bwb_eltype();
extern int var_init();
extern int fslt_init();
extern int var_delcvars();
extern struct bwb_variable *var_new();
extern struct bwb_variable *var_islocal();
extern int bwb_strel();
extern struct bwb_variable *bwb_numel();
extern int bwb_const();
extern int bwb_getvarname();
extern struct bwb_variable *var_find();
extern int bwb_isvar();
extern struct bwb_line *bwb_input();
extern int inp_adv();
extern int var_make();
extern bstring *var_getsval();
extern bstring *var_findsval();
extern bstring *exp_getsval();
extern int dim_getparams();
extern int adv_element();
extern int adv_ws();
#if MULTISEG_LINES
extern int adv_eos();
#endif
extern int line_start();
extern int is_cmd();
extern int is_let();
extern int is_eol();
extern int is_numconst();
extern int is_label();
extern struct bwb_line * find_label();
extern struct bwb_line *find_loop();
extern int int_qmdstr();
extern struct bwb_line * cnd_xpline();
extern int scan_element();

extern int prn_precision();
extern int * prn_getcol();
extern int prn_getwidth();
extern int prn_xprintf();
extern int prn_xxprintf(); /* JBV */
extern int bwb_strtoupper();
extern int getcmdnum();

extern int str_btoc();
extern int str_btob();
extern int str_ctob();
extern int str_cmp();
extern char * str_cat();
extern int exp_findop();
extern int exp_isop();
extern int exp_isfn();
extern int exp_isufn();
extern int exp_isnc();
extern int exp_isvn();
extern int exp_iscmd();
extern int exp_paren();
extern int exp_strconst();
extern int exp_numconst();
extern int exp_function();
extern int exp_ufnc();
extern int exp_variable();
extern int exp_validarg();
extern int ln_asbuf();
extern int xputc();
extern int bwx_signon();
extern int bwx_message();
extern int bwx_putc();
extern int bwx_errmes();
extern int bwx_input();
extern void bwx_terminate();

#if COMMAND_SHELL
extern int bwx_shell();
#endif

int bwb_scan();
struct bwb_line *bwb_call();
struct bwb_line *bwb_sub();
struct bwb_line *bwb_endsub();
struct bwb_line *bwb_endfnc();
struct bwb_line *bwb_function();

extern bnumber var_getnval();
extern bnumber *var_findnval();
extern bnumber exp_getnval();
extern bnumber *exp_findnval();

#if PARACT
extern int bwb_newtask();
#endif

#if INTERACTIVE
extern int bwb_interact();
#endif

#if DEBUG
extern int bwb_debug();
extern struct bwb_line *bwb_cmds();
extern struct bwb_line *bwb_vars();
extern struct bwb_line *bwb_fncs();
#endif

#ifdef ALLOW_RENUM
extern struct bwb_line *bwb_renum();
#endif

#if UNIX_CMDS
extern int rmdir();
extern int chdir();
#if MKDIR_ONE_ARG
extern int mkdir();
#else
extern int mkdir();
#endif
#endif

/* declarations of function commands */

extern struct bwb_variable *fnc_null();
#if COMPRESS_FUNCS
extern struct bwb_variable *fnc_core();
#else
extern struct bwb_variable *fnc_abs();
extern struct bwb_variable *fnc_atn();
extern struct bwb_variable *fnc_cos();
extern struct bwb_variable *fnc_log();
extern struct bwb_variable *fnc_sin();
extern struct bwb_variable *fnc_sqr();
extern struct bwb_variable *fnc_sgn();
extern struct bwb_variable *fnc_int();
extern struct bwb_variable *fnc_rnd();
extern struct bwb_variable *fnc_exp();
extern struct bwb_variable *fnc_tan();
#endif
extern struct bwb_variable *fnc_tab();
extern struct bwb_variable *fnc_date();
extern struct bwb_variable *fnc_time();
extern struct bwb_variable *fnc_chr();
extern struct bwb_variable *fnc_mid();
extern struct bwb_variable *fnc_left();
extern struct bwb_variable *fnc_right();
extern struct bwb_variable *fnc_timer();
extern struct bwb_variable *fnc_val();
extern struct bwb_variable *fnc_len();
extern struct bwb_variable *fnc_hex();
extern struct bwb_variable *fnc_oct();
extern struct bwb_variable *fnc_cint();
extern struct bwb_variable *fnc_asc();
extern struct bwb_variable *fnc_mkd();
extern struct bwb_variable *fnc_mki();
extern struct bwb_variable *fnc_mks();
extern struct bwb_variable *fnc_cvi();
extern struct bwb_variable *fnc_cvd();
extern struct bwb_variable *fnc_cvs();
extern struct bwb_variable *fnc_string();
extern struct bwb_variable * fnc_spc();
extern struct bwb_variable * fnc_space();
extern struct bwb_variable * fnc_environ();
extern struct bwb_variable * fnc_pos();
extern struct bwb_variable * fnc_err();
extern struct bwb_variable * fnc_erl();
extern struct bwb_variable * fnc_loc();
extern struct bwb_variable * fnc_lof();
extern struct bwb_variable * fnc_eof();
extern struct bwb_variable * fnc_csng();
extern struct bwb_variable * fnc_instr();
extern struct bwb_variable * fnc_str();
extern struct bwb_variable * fnc_inkey();

extern bnumber trnc_int();
extern int fnc_checkargs();
extern int ufsc;			/* user function stack counter */

#if DEBUG
extern struct bwb_variable *fnc_test();
#endif

#endif                                  /* ANSI_C */

#if COMPRESS_FUNCS
#define         F_ABS           1
#define         F_ATN           2
#define         F_COS           3
#define         F_EXP           4
#define         F_INT           5
#define         F_LOG           6
#define         F_RND           7
#define         F_SGN           8
#define         F_SIN           9
#define         F_SQR           10
#define         F_TAN           11
#define         F_ASIN           12
#define         F_ACOS           13
#endif
