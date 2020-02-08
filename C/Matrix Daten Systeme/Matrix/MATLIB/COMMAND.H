/* command.h / MATRIX / WA	/ 10.10.91	*/
/*					  / HG  / 25.11.91  */

typedef char *FN_COMMAND_TABLE[20] ;

extern FN_COMMAND_TABLE *fn_command_table ;

# define FIRSTuser 50

typedef struct { char *cmd; char *parform; char *help; int num; } CMD ;

/* typical structure of a command table :

typedef enum CMDnum { CMDillegal, CMDkey, CMDquit, CMDaaaa, CMDbbbb	} ;

CMD cmd_table[] =
{
	{ "key",		"wait for key press ...",		CMDkey		},
	{ "quit",		"quit command sequence ...",	CMDquit		},
	
	{ "aaaa",		"help for aaaa ...",			CMDaaaa		},
	{ "bbbb",		"help for bbbb ...",			-CMDbbbb	},

	{ "",			"",								0			}
} ;

	input				cmd_look_up ( cmd_table, cmd )
	--------------------------------------------------------
	+aaaa | -aaaa		+ CMDaaaa			sign meaningless

	+bbbb				+ CMDbbbb			sign significant
	-bbbb				- CMDbbbb
*/


extern int radix ;

typedef	union VALue
{
	unsigned		u ;
	int				i ;

	unsigned long	lu ;
	long			li ;

	float			f ;

	char			c ;
	char			*s ;	/* string expression */
	char			*p ;	/* pure string */
	long			*v ;
} VALUE ;

typedef struct
{
	long	step, end;
	int		label, defined ;
} FORvariable ;


# define NUMcallLevels 16

# define NUMpars	64
extern VALUE p[NUMpars] ;

typedef struct DEFvariable *DEFpntr;

# define MAXDEFNAME 8
# define MAXDEFSTR 80

struct DEFvariable
{
	char			name[ MAXDEFNAME ] ;
	long			def;
	char			str[ MAXDEFSTR ] ;
	DEFpntr			next;
} ;

extern int cmd_look_up ( CMD *cmd_table, char *cmd, CMD **tabentry ) ;
/* on return : cmd in lower cases	*/
				/*12345678901234567890123*/
# define HISTtab "                       "

extern char more ( int *line ) ;
extern int cmd_help_all ( CMD *cmd_table, int start ) ;
extern int cmd_help ( CMD *cmd_table, char *cmd_str ) ;

typedef int CMDloop ( int, char ** ) ;
extern CMDloop command_loop ;	/* syscom.c	! */

typedef void POLL_FCT ( long ) ;

extern void set_poll_fct ( POLL_FCT *pfct ) ;
extern void set_prompt_line ( int plin ) ;
extern bool switch_history ( bool on ) ;

extern void catch_line1 ( char *s, int size ) ;
extern int interpret_list ( char *argfilename, CMDloop *cmd_loop ) ;
extern int interpret_string ( char *line, CMDloop *cmd_loop ) ;
extern void interpret_commands ( char *prompt, CMDloop *cmd_loop ) ;

extern void io_xy ( char *name, XY *val, int npars ) ;
extern void io_u  ( char *name, unsigned *val, int npars ) ;
extern void io_i  ( char *name, int *val, int npars ) ;
extern void io_li ( char *name, long *val, int npars ) ;
extern void io_lu ( char *name, unsigned long *val, int npars ) ;

extern int get_darg ( int *arg_num, int arg_count,
			   char *arg_value[], double *result ) ;

extern int get_farg ( int *arg_num, int arg_count,
			   char *arg_value[], float *f ) ;

extern int get_ularg (	int *arg_num, int arg_count,
						char *arg_value[], unsigned long *result ) ;

extern int get_larg (	int *arg_num, int arg_count,
			   			char *arg_value[], long *ll ) ;

extern int get_iarg (	int *arg_num, int arg_count,
			   			char *arg_value[], int *i ) ;

extern int get_uiarg (	int *arg_num, int arg_count,
			    		char *arg_value[], unsigned *ui ) ;

extern int get_lexpr ( int *arg_num, int arg_count,
						char *arg_value[], long *lres ) ;
extern int get_iexpr ( int *arg_num, int arg_count,
			 			char *arg_value[], int *i ) ;

extern void skip_behind_cmd ( int *arg_num, int arg_count,
					  char *arg_value[] ) ;


extern int scan_parameters ( CMD *tabentry,
							 int *arg_num, int arg_count,
							 char *arg_value[],
							 VALUE *pars, int *npars, int maxpars ) ;

extern unsigned get_cmdin_char ( void ) ;
extern bool get_cmdin_stat ( void ) ;
extern void get_cmdstring ( char *prompt, char *s, int maxl ) ;

extern void clear_variables ( void ) ;
extern int check_variable ( int *arg_num, int arg_count,
					 char *arg_value[], long **varref ) ;
extern FORvariable *get_forvar ( long *varref ) ;


extern int get_strarg ( int *arg_num, int arg_count,
						char *arg_value[], char **str ) ;
extern int set_defvar ( char *arg, long val ) ;
extern int set_defstr ( char *arg, const char *text ) ;
extern int undefvar   ( char *arg ) ;
extern void show_defs ( void ) ;
