/* ubasic.h - Include file for basic routines, UNIX version. */

#ifndef P_DEFINED
#define P_DEFINED
#ifdef NOPROTOS
#define P(a,b) b
#else
#define P(a,b) a
#endif
#endif

#define FALSE 0
#define TRUE 1

#define BASIC_MAX_PRINTF 1024

typedef enum {
	SWITCHONOPT,SWITCHOFFOPT,STRARGOPT,INTARGOPT,LONGARGOPT
} OPTIONTYPE;

typedef struct {
	char *op_name;
	OPTIONTYPE op_type;
	void *op_pval;
} OPTION;

extern void *(*basic_alloc) P((size_t size),());
extern void (*basic_free) P((void *block),());

#define uhalt(m) (printf m, exit(1))

extern free_fnames P((char **fnames, int count, int freearr),());
extern process_command_line P((int *pargc, char **(*pargv), OPTION *opts),());
extern long divup P((long n, long m),());
extern long multup P((long n, long m),());
