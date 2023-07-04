
/* we use a good old binary tree to store symbols, of this struct: */

struct s_sym {
	struct s_sym *left,*right;
	byte type;
	byte size;				/* determines below */
	union {
		long l;
		word w;
		byte b;
		void *ptr;
		struct { word offset; byte reg; } oreg;
			} v;
	word (*func)(void *);	/* ptr to change fn */
	struct s_sym *next;		/* singly-linked list of all syms */
	ubyte len;				/* of name */
	char name[1];			/* null termed */
	};

typedef struct s_sym sym;

long foreachsym( sym *s,long (*each)(sym *));
long clear_debug(sym *s);

struct remstruct {
	sym **toadd;			/* points to left or right */
	sym *last;				/* points to last one added */
	};

sym *find_sym(sym **global,char *symname, ubyte symlen, struct remstruct *remember,bool casesig);
word add_sym(char *symname, ubyte symlen, struct remstruct *remember);

extern sym *asm_syms;


/* a hash table global pointer points to this: */
struct h_hsh {
	uword hsize;
	long *hstart,*hend;
	/* hash value, useful ptr */
	};

typedef struct h_hsh hash;

extern hash *static_hash;
void add_hash(hash *h, sym *s, void*(*geth)(sym *), bool all);
void build_hash(hash **glo,uword hsize);
void clear_hash(hash **glo);
long match_scoped_syms( long (*match_fn)(sym *) );

