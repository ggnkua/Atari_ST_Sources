 /*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or question
s
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

/*      compiler header file    */

enum e_sym {
        id, cconst, iconst, lconst, sconst, rconst, plus, minus,
        star, divide, lshift, rshift, modop, eq, neq, lt, leq, gt,
        geq, assign, asplus, asminus, astimes, asdivide, asmodop,
        aslshift, asrshift, asand, asor, autoinc, autodec, hook, compl,
        comma, colon, semicolon, uparrow, openbr, closebr, begin, end,
        openpa, closepa, pointsto, dot, lor, land, not, or, and, kw_int,
        kw_void, kw_char, kw_float, kw_double, kw_struct, kw_union,
        kw_long, kw_short, kw_unsigned, kw_auto, kw_extern,
        kw_register, kw_typedef, kw_static, kw_goto, kw_return,
        kw_sizeof, kw_break, kw_continue, kw_if, kw_else, kw_for,
        kw_do, kw_while, kw_switch, kw_case, kw_default, kw_enum,
        eof };

enum e_sc {
        sc_static, sc_auto, sc_global, sc_external, sc_type, sc_const,
        sc_member, sc_label, sc_ulabel };

enum e_bt {
        bt_char, bt_short, bt_long, bt_float, bt_double, bt_pointer,
        bt_unsigned, bt_struct, bt_union, bt_enum, bt_func, bt_ifunc};

struct slit {
        struct slit     *next;
        int             label;
        char            *str;
        };

struct sym {
        struct sym      *next;
        char            *name;
        int		       storage_class;
        union   {
                long            i;
                unsigned        u;
                double          f;
                char            *s;
                }
                        value;

        struct typ {
                int		       type;
                char            val_flag;       /* is it a value type */
                long            size;
                struct stab {
                        struct sym      *head, *tail;
                        }       lst;
                struct typ      *btp;
                char            *sname;
                }
                        *tp;
        };

#define SYM     struct sym
#define TYP     struct typ
#define TABLE   struct stab

#define MAX_STRLEN      120
#define MAX_STLP1       121
#define ERR_SYNTAX      0
#define ERR_ILLCHAR     1
#define ERR_FPCON       2
#define ERR_ILLTYPE     3
#define ERR_UNDEFINED   4
#define ERR_DUPSYM      5
#define ERR_PUNCT       6
#define ERR_IDEXPECT    7
#define ERR_NOINIT      8
#define ERR_INCOMPLETE  9
#define ERR_ILLINIT     10
#define ERR_INITSIZE    11
#define ERR_ILLCLASS    12
#define ERR_BLOCK       13
#define ERR_NOPOINTER   14
#define ERR_NOFUNC      15
#define ERR_NOMEMBER    16
#define ERR_LVALUE      17
#define ERR_DEREF       18
#define ERR_MISMATCH    19
#define ERR_EXPREXPECT  20
#define ERR_WHILEXPECT  21
#define ERR_NOCASE      22
#define ERR_DUPCASE     23
#define ERR_LABEL       24
#define ERR_PREPROC     25
#define ERR_INCLFILE    26
#define ERR_CANTOPEN    27
#define ERR_DEFINE      28

/*      alignment sizes         */

#define AL_CHAR         1
#define AL_SHORT        2
#define AL_LONG         2
#define AL_POINTER      2
#define AL_FLOAT        2
#define AL_DOUBLE       2
#define AL_STRUCT       2

