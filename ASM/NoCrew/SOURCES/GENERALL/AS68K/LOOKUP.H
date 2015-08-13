struct nlist { /* basic symbol table entry */
	char    *sym_name;
	int     sym_def;
	char    sym_type;       /* type of symbol entry */
	struct nlist *sym_next;     /* next entry in chain */
};

struct nlist *lookup();

/* sym_types */
#define SYM     0       /* a user defined symbol */
#define SREG    1       /* status reg (SR or CCR) */
#define DREG    2       /* Dn */
#define AREG    3       /* An */
#define CREG    4       /* control register */
#define FREG    5       /* floating point register */
#define FCREG   6       /* floating control register */
#define PC      7       /* PC */
#define ZPC     8       /* Supress PC in "new" addressing modes */
#define ZAREG   9       /* Supress An in "new" addressing modes */
#define ZDREG   10      /* Supress Dn in "new" addressing modes */
#define PREG    11      /* PMMU control register */
#define QSTR    12      /* quoted string (used only by eval) */
