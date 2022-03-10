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
 *	as this notice stays intact. Please forward any enhancements or questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

/*      expression tree descriptions    */

enum e_node {
        en_void,        /* used for parameter lists */
        en_cbw, en_cbl, en_cwl, en_cld, en_cfd,
        en_icon, en_fcon, en_labcon, en_nacon, en_autocon,
        en_b_ref, en_w_ref, en_l_ref, en_ub_ref, en_uw_ref,
        en_ul_ref, en_fcall, en_tempref, en_add, en_sub, en_mul, en_mod,
        en_div, en_lsh, en_rsh, en_cond, en_assign, en_eq, en_ne,
        en_asadd, en_assub, en_asmul, en_asdiv, en_asmod, en_asrsh,
        en_aslsh, en_asand, en_asor, en_uminus, en_not, en_compl,
        en_lt, en_le, en_gt, en_ge, en_and, en_or, en_land, en_lor,
        en_xor, en_ainc, en_adec, en_umul, en_udiv, en_umod, en_ugt,
        en_uge, en_ule, en_ult };

/*      statement node descriptions     */

enum e_stmt {
        st_expr, st_while, st_for, st_do, st_if, st_switch,
        st_case, st_goto, st_break, st_continue, st_label,
        st_return };

struct enode {
        int		     nodetype;
        short           constflag;
        union {
                int             i;
                double          f;
                char            *sp;
                struct enode    *p[2];
                } v;
        };

struct snode {
        int			     stype;
        struct snode    *next;          /* next statement */
        struct enode    *exp;           /* condition or expression */
        struct snode    *s1, *s2;       /* internal statements */
        int             *label;         /* label number for goto */
        };

struct cse {
        struct cse      *next;
        struct enode    *exp;           /* optimizable expression */
        int             uses;           /* number of uses */
        int             duses;          /* number of dereferenced uses */
        int             voidf;          /* cannot optimize flag */
        int             reg;            /* allocated register */
        };

