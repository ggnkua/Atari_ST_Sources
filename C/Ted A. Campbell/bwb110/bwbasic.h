/***************************************************************

        bwbasic.h       Header File
                        for Bywater BASIC Interpreter

                        Copyright (c) 1992, Ted A. Campbell

                        Bywater Software
                        P. O. Box 4023
                        Duke Station
                        Durham, NC  27706

                        email: tcamp@acpub.duke.edu

        Copyright and Permissions Information:

        All U.S. and international copyrights are claimed by the
        author. The author grants permission to use this code
        and software based on it under the following conditions:
        (a) in general, the code and software based upon it may be
        used by individuals and by non-profit organizations; (b) it
        may also be utilized by governmental agencies in any country,
        with the exception of military agencies; (c) the code and/or
        software based upon it may not be sold for a profit without
        an explicit and specific permission from the author, except
        that a minimal fee may be charged for media on which it is
        copied, and for copying and handling; (d) the code must be
        distributed in the form in which it has been released by the
        author; and (e) the code and software based upon it may not
        be used for illegal activities.

***************************************************************/


#ifndef TRUE
#define TRUE    -1
#define FALSE   0
#endif

/* Version number */

#define VERSION         "1.15"          /* Current version number */

/* Definitions controlling program features */

/*#define DIRECTORY_CMDS	TRUE*/ 		/* implement CHDIR, MKDIR, and RMDIR */
					/* requires chdir() mkdir() rmdir() */
#define COMMAND_SHELL   TRUE		/* allow command shell processing */

/* definitions controlling debugging options */

#define DEBUG           FALSE 		/* current debugging */
#define PROG_ERRORS     FALSE		/* identify serious programming errors */
					/* and print extensive error messages */
					/* This will override messages defined in */
					/* bwb_mes.h, and almost all messages will be in English */
#define CHECK_RECURSION FALSE		/* check for recursion violation in expression parser */
#define INTENSIVE_DEBUG FALSE           /* old debugging; might be useful later */
#define REDIRECT_STDERR FALSE           /* Redirect stderr to file ERRFILE */
#define TEST_BSTRING	FALSE		/* test bstring integrity */
#define ERRFILE         "err.out"       /* Filename for redirected error messages */

/* define number of commands */

#define CMDS_BASE       55              /* number of base commands defined */
#if DIRECTORY_CMDS
#define CMDS_DIR	3
#else
#define CMDS_DIR	0
#endif
#if DEBUG
#define CMDS_DEBUG      3               /* number of debugging cmds */
#else
#define CMDS_DEBUG      0               /* no debugging cmds */
#endif
#define COMMANDS        (CMDS_BASE+CMDS_DEBUG+CMDS_DIR)	/* total number of cmds */

#define FUNCS_BASE      45              /* number of basic functions */
#ifdef DEBUG
#define FUNCS_DEBUG	1		/* number of debugging functions */
#else
#define FUNCS_DEBUG	0		/* number of debugging functions */
#endif
#define FUNCTIONS	(FUNCS_BASE+FUNCS_DEBUG)	/* total number of functions implemented */

#define MAXARGSIZE      128             /* maximum size of argument */
#define MAXREADLINESIZE 256             /* size of read_line buffer */
#define MAXCMDNAMESIZE  64              /* maximum size for command name */
#define MAXLINENO       32767           /* maximum line number */
#define MAXVARNAMESIZE  40              /* maximum size for variable name */
#define MAXFILENAMESIZE 40              /* maximum size for file name */
#define MAXSTRINGSIZE   255             /* maximum string length */
#define GOSUBLEVELS     36              /* GOSUB stack levels */
#define WHILELEVELS     36              /* WHILE stack levels */
#define FORLEVELS       36              /* FOR stack levels */
#define MAX_GOLINES     12              /* Maximum # of lines for ON...GOTO statements */
#define MAX_FARGS       4               /* maximum # arguments to function */
#define MAX_DIMS	64		/* maximum # of dimensions */
#define ESTACKSIZE      64              /* elements in expression stack */
#define UFNCSTACKSIZE   64              /* elements in user-defined function stack */
#define XLSTACKSIZE     16              /* elements in xline stack */
#define XTXTSTACKSIZE   16              /* elements in eXecute TeXT stack */
#define N_OPERATORS     24              /* number of operators defined */
#define N_ERRORS	23		/* number of errors defined */
#define MAX_PRECEDENCE  19              /* highest (last) level of precedence */
#define MININTSIZE      -32767          /* minimum integer size */
#define MAXINTSIZE       32767          /* maximum integer size */
#define DEF_SUBSCRIPT   11              /* default subscript */
#define DEF_DEVICES     16              /* default number of devices available */
#define DEF_WIDTH	128		/* default width for devices */
#define PRN_TAB		0x02		/* send TAB followed by col number to output device */

#if DEBUG
#define PERMANENT_DEBUG TRUE
#else
#define PERMANENT_DEBUG FALSE
#endif

/* define variable types based on first character */

#define INTEGER         '%'
#define DOUBLE          '#'
#define SINGLE          '!'
#define STRING          '$'

/* define mathematical operations */

#define MULTIPLY        '*'
#define DIVIDE          '/'
#define ADD             '+'
#define SUBTRACT        '-'
#define ARGUMENT        'A'

/* absence of one of these marks denotes a single-precision
   (i.e., float) variable */

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

/* Device input/output modes */

#define DEVMODE_AVAILABLE  -1
#define DEVMODE_CLOSED     0
#define DEVMODE_OUTPUT     1
#define DEVMODE_INPUT      2
#define DEVMODE_APPEND     3
#define DEVMODE_RANDOM     4

extern char bwb_progfile[ MAXARGSIZE ];
extern char *bwb_ebuf;
extern int bwb_trace;
extern int bwb_number;			/* current line number */
extern struct bwb_line *bwb_l;		/* current line pointer */
extern int exp_esc;			/* expression stack counter */
extern int dim_base;			/* set by OPTION BASE */

/* Typdef structure for strings under Bywater BASIC */

struct bstr
   {
   unsigned char length;		/* length of string */
   char *buffer;			/* pointer to string buffer */
   int rab;				/* is it a random-access buffer? */
   #if TEST_BSTRING
   char name[ MAXVARNAMESIZE + 1 ];	/* name for test purposes */
   #endif
   };

typedef struct bstr bstring;

/* Structure used for all variables under Bywater BASIC */

struct bwb_variable
   {
   char name[ MAXVARNAMESIZE + 1 ];	/* name */
   int type;                            /* type, i.e., STRING, DOUBLE,
                                           SINGLE, or INTEGER */
   char *array;				/* pointer to array memory */
   size_t array_units;			/* total number of units of memory */
   int  *array_sizes;			/* pointer to array of <dimensions>
                                           integers, with sizes of each
                                           dimension */
   int *array_pos;                      /* current position in array */
   int dimensions;                      /* number of dimensions,
                                           0 = not an array */
   struct bwb_variable *next;           /* next variable in chain */
   int common;				/* should this variable be common to chained programs? */
   };

extern struct bwb_variable var_start, var_end;

/* Structure to represent program lines under Bywater BASIC */

struct bwb_line
   {
   struct bwb_line *next;               /* pointer to next line in chain */
   int number;                          /* line number */
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

extern struct bwb_line bwb_start, bwb_end;
extern struct bwb_line *data_line;      /* current line to read data */

/* Structure defining user-defined function in Bywater BASIC:
   note that this structure is appended to an existing bwb_function
   structure (see below) and cannot be used apart from its host
   bwb_function structure. */

struct user_fnc
   {
   char user_vns[ MAX_FARGS ][ MAXVARNAMESIZE + 1 ]; /* array of variable names: user_vns[ 0 ] is argv[ 0 ], etc. */
   struct bwb_line *line;		/* line on which the function definition occurs */
   char int_line[ MAXSTRINGSIZE + 1 ];	/* line to be interpreted */
   };

/* Structure used for all functions under Bywater BASIC.  Note that
   user-defined functions should have an attached user_fnc structure
   pointed to by the ufnc field; if ufnc is set to NULL, then the
   function is predefined. */

struct bwb_function
   {
   char name[ MAXVARNAMESIZE + 1 ];     /* name */
   int type;                            /* type, i.e., STRING, DOUBLE,
                                           SINGLE, or INTEGER */
   int arguments;                       /* number of args passed */
   struct user_fnc *ufnc;               /* pointer to structure for a user-defined function (or NULL) */
   struct bwb_variable * (*vector) ( int argc, struct bwb_variable *argv );  /* vector to function to call */
   struct bwb_function *next;           /* next function in chain */
   };

extern struct bwb_function fnc_start, fnc_end;
extern struct bwb_function * fnc_find();

extern int data_pos;                    /* position in data_line */

/* Structure to represent all command statements under Bywater BASIC */

struct bwb_command
   {
   char name[ MAXCMDNAMESIZE + 1 ];
   struct bwb_line * (*vector) (struct bwb_line *);
   int arg_offset;
   };

extern struct bwb_command bwb_cmdtable[ COMMANDS ];

/* Structure to define device stack for Bywater BASIC */

struct dev_element
   {
   int mode;                            /* DEVMODE_ item */
   int width;				/* width for output control */
   int col;				/* current column */
   int reclen;                          /* record length for random access */
   int next_record;			/* next record to read/write */
   int loc;				/* location in file */
   char filename[ MAXFILENAMESIZE + 1 ];/* filename */
   FILE *cfp;                           /* C file pointer for this device */
   char *buffer;			/* pointer to character buffer for random access */
   };

extern struct dev_element *dev_table;          /* table of devices */

/* Structure to define expression stack elements under Bywater BASIC */

struct exp_ese
   {
   int operation;                       /* operation at this level */
   char type;				/* type of operation at this level:
   					   STRING, INTEGER, SINGLE, or DOUBLE */
   bstring sval;			/* string */
   int ival;				/* integer value */
   float fval;				/* float value */
   double dval;				/* double value */
   char string[ MAXSTRINGSIZE + 1 ]; 	/* string for writing */
   struct bwb_variable *xvar;           /* pointer to external variable */
   struct bwb_function *function;       /* pointer to function structure */
   int array_pos[ MAX_DIMS ];		/* array for variable positions */
   int pos_adv;                         /* position advanced in string */
   int rec_pos;                         /* position marker for recursive calls */
   };

/* Structure to define user-defined function stack elements */

struct ufsel                            /* user function stack element */
   {
   char args[ MAX_FARGS ][ MAXARGSIZE + 1 ];
   char l_buffer[ MAXSTRINGSIZE + 1 ];
   int position;
   };

/* Structure to define FOR-NEXT stack elements */

struct fse                                       	/* FOR stack element */
   {
   struct bwb_line     *nextline;                       /* next line after FOR */
   struct bwb_variable *variable;                       /* variable to be incremented */
   int                 target;                          /* target value */
   int                 step;                            /* step increment */
   int                 position;                        /* position for reset */
   };

/* Structure to define GOSUB-RETURN stack elements */

struct gsse                                       	/* GOSUB stack element */
   {
   int                 position;                        /* position marker */
   };

extern FILE *errfdevice;                /* output device for error messages */

extern struct exp_ese *exp_es;  	/* expression stack */
extern struct ufsel *ufs;              	/* user function stack */
extern struct fse *fs;                  /* FOR stack */
extern struct gsse *bwb_gss;            /* GOSUB stack */

extern int bwb_gssc;                    /* GOSUB stack counter */
extern int ufsc;                        /* user function stack counter */
extern int ws_counter;                  /* WHILE stack counter */
extern int fs_counter;                  /* FOR stack counter */
extern int err_line;			/* line in which error occurred */
extern int err_number;			/* number of last error */
extern int err_gosubn;			/* number for error GOSUB */
extern char *err_table[ N_ERRORS ];	/* table of error messages */

/* Operator Table */

static struct
   {
   char symbol[ 8 ];                    /* BASIC symbol for the operator */
   int operation;                       /* internal code for the operator */
   int precedence;                      /* level of precedence, 0 = highest */
   } exp_ops[ N_OPERATORS ] =
   {
   { "NOT",     OP_NOT,         12 },   /* multiple-character operators */
   { "AND",     OP_AND,         13 },   /* should be tested first because */
   { "OR",      OP_OR,          14 },   /* e.g. a ">=" would be matched */
   { "XOR",     OP_XOR,         15 },   /* as "=" if the single-character */
   { "IMP",     OP_IMPLIES,     16 },   /* operator came first */
   { "EQV",     OP_EQUIV,       17 },
   { "MOD",     OP_MODULUS,     4  },
   { "<>",      OP_NOTEQUAL,    7  },
   { "<=",      OP_LTEQ,        10 },
   { "=<",      OP_LTEQ,        10 },   /* allow either form */
   { ">=",      OP_GTEQ,        11 },
   { "=>",      OP_GTEQ,        11 },   /* allow either form */
   { "<",       OP_LESSTHAN,    8  },
   { ">",       OP_GREATERTHAN, 9  },
   { "^",       OP_EXPONENT,    0  },
   { "*",       OP_MULTIPLY,    2  },
   { "/",       OP_DIVIDE,      2  },
   { "\\",      OP_INTDIVISION, 3  },
   { "+",       OP_ADD,         5  },
   { "-",       OP_SUBTRACT,    5  },
   { "=",       OP_EQUALS,      6  },
   { "=",       OP_ASSIGN,      6  },   /* don't worry: OP_EQUALS will be converted to OP_ASSIGN if necessary */
   { ";",       OP_STRJOIN,     18 },
   { ",",       OP_STRTAB,      19 }
   };

/* Prototypes for publicly available functions and data */

extern int bwb_fload( FILE *file );
extern int bwb_ladd( char *buffer, int replace );
extern int bwb_findcmd( int argc, int a, struct bwb_line *l );
extern struct bwb_line *bwb_xtxtline( char *buffer );
extern struct bwb_line *bwb_xline( struct bwb_line *l );
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
extern struct bwb_line *bwb_clear( struct bwb_line *l );
extern struct bwb_line *bwb_erase( struct bwb_line *l );
extern struct bwb_line *bwb_swap( struct bwb_line *l );
extern struct bwb_line *bwb_environ( struct bwb_line *l );
extern struct bwb_line *bwb_width( struct bwb_line *l );
extern struct bwb_line *bwb_write( struct bwb_line *l );
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
extern int fnc_init( void );
extern struct bwb_function *fnc_find( char *buffer );
extern struct bwb_variable *fnc_intufnc( int argc, struct bwb_variable *argv,
   struct bwb_function *f );
extern struct bwb_line *bwb_deffn( struct bwb_line *l );
extern int bwb_getargs( char *buffer );
extern int bwb_stripcr( char *s );
extern int bwb_numseq( char *buffer, int *start, int *end );
extern int bwb_freeline( struct bwb_line *l );
extern struct bwb_line *bwb_print( struct bwb_line *l );
extern int bwb_xprint( struct bwb_line *l, FILE *f );
extern int bwb_eltype( char *l_buffer, int p );
extern int var_init( void );
extern int var_delcvars( void );
extern int bwb_strel( char *lb, char *sb, int *n );
extern struct bwb_variable *bwb_numel( char *lb, int *n );
extern int bwb_const( char *lb, char *sb, int *n );
extern int bwb_getvarname( char *lb, char *sb, int *n );
extern struct bwb_variable *var_find( char *buffer );
extern int bwb_isvar( char *buffer );
extern struct bwb_line *bwb_input( struct bwb_line *l );
extern int inp_adv( char *b, int *c );
extern double var_getdval( struct bwb_variable *nvar );
extern float var_getfval( struct bwb_variable *nvar );
extern int var_getival( struct bwb_variable *nvar );
extern bstring *var_getsval( struct bwb_variable *nvar );
extern bstring *var_findsval( struct bwb_variable *v, int *pp );
extern int *var_findival( struct bwb_variable *v, int *pp );
extern float *var_findfval( struct bwb_variable *v, int *pp );
extern double *var_finddval( struct bwb_variable *v, int *pp );
extern int var_make( struct bwb_variable *v, int type );
extern int dim_getparams( char *buffer, int *pos, int *n_params, int **pp );
extern double exp_getdval( struct exp_ese *e );
extern float exp_getfval( struct exp_ese *e );
extern int exp_getival( struct exp_ese *e );
extern bstring * exp_getsval( struct exp_ese *e );
extern double * exp_finddval( struct exp_ese *e );
extern float * exp_findfval( struct exp_ese *e );
extern int * exp_findival( struct exp_ese *e );
extern int is_numconst( char *buffer );
extern int adv_element( char *buffer, int *pos, char *element );
extern int adv_ws( char *buffer, int *pos );
extern int line_start( char *buffer, int *pos, int *lnpos, int *lnum,
   int *cmdpos, int *cmdnum, int *startpos );
extern int is_cmd( char *buffer, int *cmdnum );
extern int is_let( char *buffer, int *cmdnum );
extern int int_qmdstr( char *buffer_a, char *buffer_b );
extern struct bwb_line * cnd_xpline( struct bwb_line *l, char *buffer );

extern int prn_precision( struct bwb_variable *v );
extern int * prn_getcol( FILE *f );
extern int prn_getwidth( FILE *f );
extern int xprintf( FILE *f, char *buffer );
extern int bwb_strtoupper( char *buffer );
extern int getcmdnum( char *cmdstr );

extern struct bwb_variable * fnc_tab( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_spc( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_space( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_environ( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_pos( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_err( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_erl( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_loc( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_lof( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_eof( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_csng( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_exp( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_instr( int argc, struct bwb_variable *argv );
extern struct bwb_variable * fnc_str( int argc, struct bwb_variable *argv );
extern int str_btoc( char *buffer, bstring *s );
extern int str_btob( bstring *d, bstring *s );
extern int str_ctob( bstring *s, char *buffer );
extern int str_cmp( bstring *s, bstring *t );
extern char * str_cat( bstring *s, bstring *t );
extern int exp_findop( char *expression );
extern int exp_isop( char *expression );
extern int exp_isfn( char *expression );
extern int exp_isnc( char *expression );
extern int exp_isvn( char *expression );
extern int exp_iscmd( char *expression );
extern int exp_paren( char *expression );
extern int exp_strconst( char *expression );
extern int exp_numconst( char *expression );
extern int exp_function( char *expression );
extern int exp_variable( char *expression );
extern int exp_validarg( char *expression );
extern int ln_asbuf( struct bwb_line *l, char *s );
extern int xputc( FILE *f, char c );

#if DEBUG
extern int bwb_debug( char *message );
extern struct bwb_line *bwb_cmds( struct bwb_line *l );
extern struct bwb_line *bwb_vars( struct bwb_line *l );
extern struct bwb_line *bwb_fncs( struct bwb_line *l );
#endif

#ifdef ALLOW_RENUM
extern struct bwb_line *bwb_renum( struct bwb_line *l );
#endif

#if DIRECTORY_CMDS
extern int rmdir( char *path );
extern int chdir( char *path );
extern int mkdir( char *path );
#endif

/* declarations of function commands */

extern struct bwb_variable *fnc_null( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_abs( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_date( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_time( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_atn( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_acos( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_cos( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_log( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_sin( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_sqr( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_tan( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_sgn( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_int( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_rnd( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_chr( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_mid( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_left( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_right( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_timer( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_val( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_len( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_hex( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_oct( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_cint( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_asc( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_mkd( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_mki( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_mks( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_cvi( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_cvd( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_cvs( int argc, struct bwb_variable *argv );
extern struct bwb_variable *fnc_string( int argc, struct bwb_variable *argv );
extern double trnc_int( double x );
extern int fnc_checkargs( int argc, struct bwb_variable *argv,
   int min, int max );
extern int ufsc;			/* user function stack counter */

#if DEBUG
extern struct bwb_variable *fnc_test( int argc, struct bwb_variable *argv );
#endif



