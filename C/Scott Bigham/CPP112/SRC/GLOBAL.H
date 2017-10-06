/*---------------------------------------------------------------------*\
|									|
| CPP -- a stand-alone C preprocessor					|
| Copyright (c) 1993 Hacker Ltd.		Author: Scott Bigham	|
|									|
| Permission is granted to anyone to use this software for any purpose	|
| on any computer system, and to redistribute it freely, with the	|
| following restrictions:						|
| - No charge may be made other than reasonable charges for repro-	|
|     duction.								|
| - Modified versions must be clearly marked as such.			|
| - The author is not responsible for any harmful consequences of	|
|     using this software, even if they result from defects therein.	|
|									|
| global.h -- global definitions					|
\*---------------------------------------------------------------------*/

#include <string.h>
#include <stdio.h>

#ifndef __MINT__
# ifdef __STDC__
# define __PROTO(x) x
# else
# define __PROTO(x) ()
# endif
#endif

typedef struct macro {
  struct macro *next;		/* for free-list chaining */
  int nargs;
  unsigned int flags;
#define MAGIC	0x0001		/* system special #define */
#define MAGIC2	0x0002		/* as above, but not always visible */
#define HASARGS	0x0004		/* check for arguments */
#define MARKED	0x0008		/* used for recursive #definitions */
#define UNDEF	0x0010		/* -U argument */
  struct token *argnames;
  struct token *m_text;
} Macro;

typedef struct token {
  struct token *next;
  union {
    char *out_of_line;
    char inline[8];
  } _txt;
  union {
    char *out_of_line;
    char inline[4];
  } _ws;
  long val;
  unsigned int hashval;
  char type;
  char subtype;
  unsigned int flags;
#define BLUEPAINT	0x0001	/* not available for expansion */
#define UNS_VAL		0x0002	/* value is unsigned */
#define STRINGIZE_ME	0x0004	/* stringized macro arg */
#define CONCAT_NEXT	0x0008	/* concatenate this token with next token */
#define TRAIL_SPC	0x0010	/* add spc to prevent accidental token merge */
#define UNPAINT_ME	0x0020	/* see expand() and expand_tlist() */
#define INLINE_TXT	0x0040	/* text of token is inline */
#define INLINE_WS	0x0080	/* whitespace is inline */
} Token, *TokenP;

/* accessor macros to get at the inlined strings */
#define token_txt(Tp)	\
    (((Tp)->flags & INLINE_TXT) ? (Tp)->_txt.inline : (Tp)->_txt.out_of_line)
#define token_ws(Tp)	\
    (((Tp)->flags & INLINE_WS) ? (Tp)->_ws.inline : (Tp)->_ws.out_of_line)

typedef struct hash {
  struct hash *next;
  union {
    char inline[8];
    char *out_of_line;
  } _id;
  Macro *data;
  unsigned int flags;
#define INLINE_KEY	0x0001	/* text of key is inline */
} Hash;

/* token types */
#define UNKNOWN		1
#define DONT_CARE	2
#define EOL		3
#define NUMBER		4
#define FP_NUM		5
#define ID		6
#define STR_CON		7
#define CHAR_CON	8
#define UNARY_OP	9
#define MUL_OP		10
#define ADD_OP		11
#define SHIFT_OP	12
#define REL_OP		13
#define EQ_OP		14
#define B_AND_OP	15
#define B_XOR_OP	16
#define B_OR_OP		17
#define L_AND_OP	18
#define L_OR_OP		19
#define LPAREN		20
#define RPAREN		21
#define COMMA		22
#define INC_NAM		23
#define POUND		24
#define TOK_CAT		25
#define MACRO_ARG	26
#define EOF_		27
#define STOP		28
#define UNMARK		29

/* tokenizer modes */
#define NORMAL		0	/* default behavior */
#define INCLUDE_LINE	1	/* return <filename.h> as a single token */
#define IF_EXPR		2	/* interpret defined(IDENTIFIER) */
#define SLURP		4	/* ignore preprocessor directives */

/* types of synchronization lines */
#define SL_NONE   0		/* no sync line */
#define SL_NORMAL 1		/* default style:  # 15 "fred.c" */
#define SL_LINE   2		/* preproc style:  #line 15 "fred.c" */

#if defined(__MINT__) || defined(__GNUC__)
#define PATH_SEP '/'
#else
#define PATH_SEP '\\'
#endif

#define STDIN_NAME "standard input"

#define streq(s,t) (strcmp((s),(t))==0)
#define nelems(arr) (sizeof(arr)/sizeof((arr)[0]))

/* Global variables and functions from each file */

/* comment.c */
char *suck_ws __PROTO((char *, TokenP));

/* define.c */
void do_define __PROTO((void));
void do_undefine __PROTO((void));
int macro_eq __PROTO((Macro *, Macro *));

/* hash.c */
Macro *lookup __PROTO((char *, unsigned int));
unsigned int hash_id __PROTO((char *, char **));
void hash_add __PROTO((char *, unsigned int, Macro *));
void hash_clean_undef __PROTO((void));
void hash_free __PROTO((void));
void hash_remove __PROTO((char *, unsigned int));
void hash_setup __PROTO((void));

/* if_expr.c */
int if_expr __PROTO((void));

/* include.c */
void do_include __PROTO((void));
extern unsigned long include_level;

/* input.c */
/* HSC #defines the following if and only if it is in a mode that gives
   external identifiers more than 7 characters of significance.  If your
   compiler can handle long identifiers, feel free to delete this
   #defin'ition. */
#ifndef __HSC_LONGNAMES__
#define expand_rest_of_line	E_rol
#endif
TokenP tokenize_string __PROTO((char *));
char *getline __PROTO((void));
char *rest_of_line __PROTO((void));
void expand_rest_of_line __PROTO((void));
void flush_line __PROTO((void));
extern char *cur_file;
extern unsigned long last_line, this_line, next_line;

/* macro.c */
Macro *mk_Macro __PROTO((void));
void free_Macro __PROTO((Macro *));
TokenP expand_tlist __PROTO((TokenP));
void expand __PROTO((TokenP, Macro *));
extern char *magic_words[];
extern int N_MWORDS;

/* main.c */
extern FILE *inf;
extern FILE *outf;
extern char *argv0;
extern char **I_list;
extern char date_string[], time_string[];
extern int nerrs;
extern int sl_style, keep_comments, do_trigraphs, ansi, w_bad_chars,
	   w_nest_cmts, f_cpp_cmts, w_bad_concat;
extern int in_config_file, Argc_end;
extern int fluff_mode;
void do_cmdline_arg __PROTO((char *));
void do_all_cmdline_args __PROTO((void));

/* pound.c */
void cond_setup __PROTO((void));
void cond_shutdown __PROTO((void));
void directive __PROTO((void));
void endif_check __PROTO((void));
extern int *if_sp;
#define COND_TRUE	1
#define COND_NESTED	2
#define cond_true() ((if_sp[-1]&(COND_TRUE|COND_NESTED))==COND_TRUE)

/* process.c */
void process_file __PROTO((char *));
void sync_line __PROTO((int));
void synchronize __PROTO((void));

/* token.c */
TokenP mk_Token __PROTO((void));
void clear_txt __PROTO((TokenP));
void clear_ws __PROTO((TokenP));
void set_txt __PROTO((TokenP, const char *));
void set_ws __PROTO((TokenP, const char *));
void set_txt_n __PROTO((TokenP, const char *, int));
TokenP copy_tlist __PROTO((TokenP));
TokenP copy_token __PROTO((TokenP));
TokenP merge_tokens __PROTO((TokenP, TokenP));
TokenP mk_eol __PROTO((void));
TokenP mk_stopper __PROTO((void));
TokenP mk_unmarker __PROTO((TokenP));
TokenP mk_printable __PROTO((const char *));
TokenP token __PROTO((void));
int get_mode __PROTO((void));
void change_mode __PROTO((int, int));
void flush_tokenizer __PROTO((void));
void free_tlist __PROTO((TokenP));
void free_token __PROTO((TokenP));
void print_token __PROTO((TokenP));
void push_tlist __PROTO((TokenP));
void set_mode __PROTO((int));
void tok_shutdown __PROTO((void));
TokenP exp_token __PROTO((void));
TokenP _one_token __PROTO((void));
void _tokenize_line __PROTO((void));
#ifdef DEBUG
void dump_token __PROTO((TokenP));
void dump_tlist __PROTO((TokenP));
void dump_pushback __PROTO((void));
#endif

/* utils.c */
void fatal __PROTO((const char *, ...));
void bugchk __PROTO((const char *, ...));
void warning __PROTO((const char *, ...));
void error __PROTO((const char *, ...));
char *copy_filename __PROTO((char *, int));
#ifndef __GNUC__
char *strdup __PROTO((const char *));
#endif
FILE *xfopen __PROTO((const char *, const char *));
#define NEWBUFSIZ ((size_t)4096)
void *mallok __PROTO((size_t));
void *reallok __PROTO((void *, size_t));
char *grow __PROTO((char **, size_t *, char *, int));

/* ztype.c */
void Z_type_init __PROTO((void));
