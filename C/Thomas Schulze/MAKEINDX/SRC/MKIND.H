
/*
 *
 * Copyright (C) 1987   Pehong Chen     (phc@renoir.berkeley.edu)
 * Computer Science Division
 * University of California, Berkeley
 * This is the Atari ST Version (1989) by T.Schulze
 */

/***********************************************************************

                           INSTALLATION NOTES
                              [14-Jan-88]

   At compile-time (or here, if compile-time definition is not
   available), set non-zero ONE OS_xxxx operating system flag, and if
   more than one compiler is available, ONE compiler flag:

        Operating Systems               Compiler(s)
        =================               ===========
        OS_ATARI                        ATARI_TURBO_C
        OS_PCDOS                        IBM_PC_MICROSOFT
        OS_TOPS20                       KCC_20 or PCC_20
        OS_VAXVMS
        OS_UNIX
        =================               ===========
       
   If no OS_xxxx symbol is defined, OS_UNIX is assumed.

   If draft ANSI C prototypes are supported, define the symbol
   ANSI_PROTOTYPES in the appropriate OS_xxxx section below, and insert
   #include's for the standard system files which define library
   prototypes.  Unfortunately, these are scattered about in several
   files in draft ANSI C; the IBM_PC_MICROSOFT section below is an
   example which should be close for other implementations.

   All function declarations in MakeIndex are contained at the end of
   this file.  If ANSI_PROTOTYPES is not selected, then all the standard
   library functions must be declared explicitly.

   If the host system restricts external names to 6 characters, set
   SHORTNAMES non-zero in the appropriate OS_xxxx section below.
*/

/**********************************************************************/
/* Establish needed operating symbols (defaulting to OS_UNIX if none
   specified at compile time) */

#ifndef OS_ATARI
#define OS_ATARI 1  /*This is the Atari ST Version*/
#endif

#ifndef ATARI_TURBO_C
#define ATARI_TURBO_C 1  /* Compiler is Borland's Turbo C Version 1.1 */
#endif

#ifndef OS_PCDOS
#define OS_PCDOS 0
#endif

#ifndef IBM_PC_MICROSOFT
#define IBM_PC_MICROSOFT 0
#endif

#ifndef OS_TOPS20
#define OS_TOPS20 0
#endif

#ifndef KCC_20
#define KCC_20 0
#endif

#ifndef PCC_20
#define PCC_20 0
#endif

#ifndef OS_UNIX
#define OS_UNIX 0
#endif

#ifndef OS_VAXVMS
#define OS_VAXVMS 0
#endif

#if    OS_TOPS20
#if    (KCC_20 | PCC_20)
#else
#undef PCC_20
#define PCC_20 1                        /* PCC-20 is default for Tops-20 */
#endif
#endif

#if    (OS_PCDOS | OS_TOPS20 | OS_UNIX | OS_VAXVMS)
#else
#undef OS_UNIX
#define OS_UNIX 0                       /* Unix is default operating system */
#endif

#if    OS_TOPS20
#define SHORTNAMES 1
#elif  ATARI_TURBO_C
#define SHORTNAMES 1
#else
#define SHORTNAMES 0
#endif

#define ANSI_PROTOTYPES 1

#ifndef ATARI_TURBO_C
#define qsort qqsort        /* avoid conflict with standard library routine */
#endif

/**********************************************************************/

#include        <stdio.h>
#include        <ctype.h>

#if    IBM_PC_MICROSOFT
#include        <io.h>          /* for function declarations */
#include        <stddef.h>      /* for function declarations */
#include        <stdlib.h>      /* for function declarations */
#include        <string.h>      /* for function declarations */
#undef ANSI_PROTOTYPES
#define ANSI_PROTOTYPES 1       /* so we get full argument type checking */
#endif /* IBM_PC_MICROSOFT */

#if             ATARI_TURBO_C
#include        <stddef.h>      /* for function declarations */
#include        <stdlib.h>      /* for function declarations */
#include        <string.h>      /* for function declarations */
#undef      ANSI_PROTOTYPES
#define     ANSI_PROTOTYPES 1   /* Turbo C knows ANSI !!! */
#endif  /* ATARI_TURBO_C */

#if    (IBM_PC_MICROSOFT | OS_VAXVMS | ATARI_TURBO_C)
#define index           strchr  /* convert old K&R form to ANSI form */
#define rindex          strrchr /* convert old K&R form to ANSI form */
#endif

#if    (PCC_20 | ATARI_TURBO_C)
#define R_OK 0                          /* TURBO C/PCC-20 access(file,mode) */
                                        /* only understands mode=0 */
#endif

#if    SHORTNAMES
/* Provide alternate external names which are unique in the first
SIX characters as required for portability (and Oct. 1986 draft ANSI C) */
#define check_all               chk_all
#define check_idx               chk_idx
#define check_mixsym            chk_mix
#define compare_one             cmp_one
#define compare_page            cmp_page
#define compare_string          cmp_string
#define delim_n                 dlm_n
#define delim_p                 dlm_p
#define delim_r                 dlm_r
#define encap_i                 ecp_i
#define encap_p                 ecp_p
#define encap_range             ecp_range
#define encap_s                 ecp_s
#define group_skip              grp_skip
#define group_type              grp_type
#define idx_aclose              idxaclose
#define idx_actual              idxactual
#define idx_keyword             idx_kwd
#define indent_length           ind_length
#define indent_space            ind_space
#define lethead_flag            lth_flag
#define lethead_pre             lth_pre
#define lethead_suf             lth_suf
#define process_idx             prc_idx
#define process_precedence      prc_pre
#define range_lc                rng_lc
#define range_ptr               rng_ptr
#define scan_alpha_lower        scnalw
#define scan_alpha_upper        scnaup
#define scan_arabic             scnarabic
#define scan_arg1               scna1
#define scan_arg2               scna2
#define scan_char               scnchr
#define scan_field              scnfld
#define scan_idx                scnidx
#define scan_key                scnkey
#define scan_no                 scnno
#define scan_roman_lower        scnrlw
#define scan_roman_upper        scnrup
#define scan_spec               scnspc
#define scan_string             scnstr
#define scan_style              scnsty
#define setpagelen              spg_len
#define setpage_close           spg_close
#define setpage_open            spg_open
#endif /* SHORTNAMES */

#if OS_VAXVMS
#define EXIT(code) exit( ((code) == 0) ? 1 : (1 << 28) + 2 )
#else /* NOT OS_VAXVMS */
#define EXIT exit
#endif /* OS_VAXVMS */

#ifndef R_OK
#define R_OK                    4   /* only symbol needed from sys/file.h */
#endif

#undef  TRUE
#define TRUE                    1
#undef  FALSE
#define FALSE                   0
#undef  NULL
#define NULL                    '\0'

#define TAB                     '\t'
#define LFD                     '\n'
#define SPC                     ' '
#define LSQ                     '['
#define RSQ                     ']'
#define BSH                     '\\'

#if    OS_ATARI
#define ENV_SEPAR               ','
#define DIR_DELIM               '\\'
#endif /* OS_ATARI */

#if    OS_PCDOS
#define ENV_SEPAR               ';'
#define DIR_DELIM               '\\'
#endif /* OS_PCDOS */

#if    OS_TOPS20
#define ENV_SEPAR               ','
#define DIR_DELIM               ':'
#endif /* OS_TOPS20 */

#if    OS_UNIX
#define ENV_SEPAR               ':'
#define DIR_DELIM               '/'
#endif /* OS_UNIX */

#if    OS_VAXVMS
#define ENV_SEPAR               ','     /* In fact these aren't used */
#define DIR_DELIM               ':'
#endif /* OS_VAXVMS */

#define SW_PREFIX               '-'
#define EXT_DELIM               '.'
#define ROMAN_SIGN              '*'
#define EVEN                    "even"
#define ODD                     "odd"
#define ANY                     "any"

#define GET_CHAR                getc

#define TOASCII(i)              (char)((i) + 48)
#define TOLOWER(C)              (char)((isupper(C)) ? tolower(C) : (C))
#define TOUPPER(C)              (char)((isupper(C)) ? (C) : toupper(C))

#define STREQ(A, B)             (strcmp(A, B) == 0)
#define STRNEQ(A, B)            (strcmp(A, B) != 0)

#define MESSAGE(F, S) { \
        if (verbose) { \
                fprintf(stderr, F, S); \
                fflush(stderr); \
        } \
        fprintf(ilg_fp, F, S); \
}

#define FATAL(F, S) { \
        fprintf(stderr, F, S); \
        fprintf(stderr, USAGE, pgm_fn); \
        EXIT(1); \
}

#define FATAL2(F, D1, D2) { \
        fprintf(stderr, F, D1, D2); \
        fprintf(stderr, USAGE, pgm_fn); \
        EXIT(1); \
}

#define OPEN_IN(FP)             fopen(FP, "r")
#define OPEN_OUT(FP)    fopen(FP, "w")
#define CLOSE(FP)               fclose(FP)

#define ISDIGIT(C)              ('0' <= C && C <= '9')
#define ISSYMBOL(C)             (('!' <= C && C <= '@') || \
                                 ('[' <= C && C <= '`') || \
                                 ('{' <= C && C <= '~'))

#define ARGUMENT_MAX            1024
#define LONG_MAX                144
#define LINE_MAX                72
#define STRING_MAX              64
#define ARABIC_MAX              4
#define ROMAN_MAX               16
#define PAGETYPE_MAX            5
#define PAGEFIELD_MAX           10
#define FIELD_MAX               3
#define NUMBER_MAX              16

#define VERSION "portable version 2.5 [4-14-88]"
#define PUT_VERSION { \
        MESSAGE("This is %s, ", pgm_fn); \
        MESSAGE("%s.\n", VERSION); \
        need_version = FALSE; \
}

#define USAGE \
   "Usage: %s [-ilqrc] [-s sty] [-o ind] [-t log] [-p no] [idx0 idx1 ...]\n"

#define STYLE_PATH              "INDEXSTYLE"
#define INDEX_IDX               ".idx"
#define INDEX_ILG               ".ilg"
#define INDEX_IND               ".ind"
#if    OS_VAXVMS
#define INDEX_LOG               ".lis"
#else
#define INDEX_LOG               ".log"
#endif

#define EMPTY                   -9999
#define ROML                    0
#define ROMU                    1
#define ARAB                    2
#define ALPL                    3
#define ALPU                    4
#define DUPLICATE               9999

#define SYMBOL                  -1
#define ALPHA                   -2

typedef struct KFIELD {
        char            sf[FIELD_MAX][STRING_MAX];      /* sort key */
        char            af[FIELD_MAX][STRING_MAX];      /* actual key */
        int             group;                          /* key group */
        char            lpg[NUMBER_MAX];                /* literal page */
        short           npg[PAGEFIELD_MAX];             /* page field array */
        short           count;                          /* page field count */
        short           type;                           /* page number type */
        char            encap[STRING_MAX];              /* encapsulator */
        char            *fn;                            /* input filename */
        int             lc;                             /* line number */
} FIELD, *FIELD_PTR;

typedef struct KNODE {
        FIELD           data;
        struct KNODE    *next;
} NODE, *NODE_PTR;

extern  int     letter_ordering;
extern  int     compress_blanks;
extern  int     init_page;
extern  int     merge_page;
extern  int     even_odd;
extern  int     verbose;

extern  char    idx_keyword[LONG_MAX];
extern  char    idx_aopen;
extern  char    idx_aclose;
extern  char    idx_level;
extern  char    idx_ropen;
extern  char    idx_rclose;
extern  char    idx_quote;
extern  char    idx_actual;
extern  char    idx_encap;
extern  char    idx_escape;

extern  char    page_comp[LONG_MAX];
extern  int     page_offset[PAGETYPE_MAX];

extern  char    preamble[LONG_MAX];
extern  char    postamble[LONG_MAX];
extern  char    setpage_open[LONG_MAX];
extern  char    setpage_close[LONG_MAX];
extern  char    group_skip[LONG_MAX];
extern  char    lethead_pre[LONG_MAX];
extern  char    lethead_suf[LONG_MAX];
extern  int     lethead_flag;
extern  int     prelen;
extern  int     postlen;
extern  int     skiplen;
extern  int     headprelen;
extern  int     headsuflen;
extern  int     setpagelen;

extern  char    item_r[FIELD_MAX][LONG_MAX];
extern  char    item_u[FIELD_MAX][LONG_MAX];
extern  char    item_x[FIELD_MAX][LONG_MAX];
extern  int     ilen_r[FIELD_MAX];
extern  int     ilen_u[FIELD_MAX];
extern  int     ilen_x[FIELD_MAX];

extern  char    delim_p[FIELD_MAX][LONG_MAX];
extern  char    delim_n[LONG_MAX];
extern  char    delim_r[LONG_MAX];

extern  char    encap_p[LONG_MAX];
extern  char    encap_i[LONG_MAX];
extern  char    encap_s[LONG_MAX];

extern  int     linemax;
extern  char    indent_space[LONG_MAX];
extern  int     indent_length;

extern  FILE    *idx_fp;
extern  FILE    *sty_fp;
extern  FILE    *ind_fp;
extern  FILE    *ilg_fp;
extern  char    *idx_fn;
extern  char    sty_fn[];
extern  char    *pgm_fn;
extern  char    *ind_fn;
extern  char    *ilg_fn;
extern  char    ind[];
extern  char    ilg[];
extern  char    pageno[];

extern  FIELD_PTR       *idx_key;
extern  NODE_PTR        head;
extern  NODE_PTR        tail;

extern  int     idx_dot;
extern  int     idx_tt;
extern  int     idx_gt;
extern  int     idx_et;
extern  int     idx_dc;

#define DOT                     "."
#define DOT_MAX                 1000
#define CMP_MAX                 1500

#define IDX_DOT(MAX) { \
        idx_dot = TRUE; \
        if (idx_dc++ == 0) { \
                if (verbose) { \
                        fprintf(stderr, DOT); \
                        fflush(stderr); \
                } \
                fprintf(ilg_fp, DOT); \
        } \
        if (idx_dc == MAX) \
                idx_dc = 0; \
}

#define ALL_DONE { \
        if (fn_no > 0) { \
                if (verbose) \
                        fprintf(stderr, "Overall %d files read (%d entries accepted, %d rejected).\n", \
                                   fn_no+1, idx_gt, idx_et); \
                fprintf(ilg_fp, "Overall %d files read (%d entries accepted, %d rejected).\n", \
                           fn_no+1, idx_gt, idx_et); \
        } \
}

#define DONE(A, B, C, D) { \
        if (verbose) \
                fprintf(stderr, "done (%d %s, %d %s).\n", (A), B, C, D); \
        fprintf(ilg_fp, "done (%d %s, %d %s).\n", (A), B, C, D); \
}

#if    ANSI_PROTOTYPES
static  void    check_all(char *fn,int ind_given,int ilg_given,int log_given);
static  void    check_idx(char *fn,int open_fn);
static  int     check_mixsym(char *x,char *y);
static  int     compare(struct KFIELD * *a,struct KFIELD * *b);
static  int     compare_one(char *x,char *y);
static  int     compare_page(struct KFIELD * *a,struct KFIELD * *b);
static  int     compare_string(char *a,char *b);
static  int     count_lfd(char *str);
static  void    find_pageno(void);
static  void    flush_line(int print);
extern  void    gen_ind(void);
extern  int     group_type(char *str);
static  void    insert_page(void);
extern  int     main(int argc,char * *argv);
static  int     make_entry(int n);
static  void    make_item(void);
static  int     make_key(void);
static  void    new_entry(void);
static  int     next_nonblank(void);
static  void    old_entry(void);
static  void    open_sty(char *fn);
static  int     page_diff(struct KFIELD *a,struct KFIELD *b);
static  void    prepare_idx(void);
static  void    process_idx(char * *fn,int use_stdin,int sty_given,int ind_given,int ilg_given,int log_given);
static  int     process_precedence(void);
#ifndef ATARI_TURBO_C  /* Turbo C uses built-in qsort */
extern       void    qsort(char *base,int n,int size,int (*)(char*,char*));
#endif
static  void    qst(char *base, char *max);
static  int     scan_alpha_lower(char *no,short *npg,short *count);
static  int     scan_alpha_upper(char *no,short *npg,short *count);
static  int     scan_arabic(char *no,short *npg,short *count);
static  int     scan_arg1(void);
static  int     scan_arg2(void);
static  int     scan_char(char *c);
static  int     scan_field(int *n,char *field,int ck_level,int ck_encap,int ck_actual);
extern  void    scan_idx(void);
static  int     scan_key(struct KFIELD *data);
static  int     scan_no(char *no,short *npg,short *count,short *type);
static  int     scan_roman_lower(char *no,short *npg,short *count);
static  int     scan_roman_upper(char *no,short *npg,short *count);
static  int     scan_spec(char *spec);
static  int     scan_string(char *str);
extern  void    scan_sty(void);
extern  void    sort_idx(void);
extern  int     strtoint(char *str);
static  void    wrap_line(int print);
#else
static  void    check_all();
static  void    check_idx();
static  int     check_mixsym();
static  int     compare();
static  int     compare_one();
static  int     compare_page();
static  int     compare_string();
static  int     count_lfd();
static  void    find_pageno();
static  void    flush_line();
extern  void    gen_ind();
extern  int     group_type();
static  void    insert_page();
extern  int     main();
static  int     make_entry();
static  void    make_item();
static  int     make_key();
static  void    new_entry();
static  int     next_nonblank();
static  void    old_entry();
static  void    open_sty();
static  int     page_diff();
static  void    prepare_idx();
static  void    process_idx();
static  int     process_precedence();
extern  void    qsort();
static  void    qst();
static  int     scan_alpha_lower();
static  int     scan_alpha_upper();
static  int     scan_arabic();
static  int     scan_arg1();
static  int     scan_arg2();
static  int     scan_char();
static  int     scan_field();
extern  void    scan_idx();
static  int     scan_key();
static  int     scan_no();
static  int     scan_roman_lower();
static  int     scan_roman_upper();
static  int     scan_spec();
static  int     scan_string();
extern  void    scan_sty();
extern  void    sort_idx();
extern  int     strtoint();
static  void    wrap_line();

/* Miscellaneous standard library routines */
char            *calloc();
char            *getenv();
char            *index();
char            *malloc();
char            *rindex();
#endif

