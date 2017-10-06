extern char *ramstart,*ramend,*startlocal,*endlocal,
	*newram,*udfend,*varstart;

#if defined __MSDOS__
#define SPLIT_MEM
#define FLOAT_TEST
#endif

#define LONG size_t
#define TAB 9

#ifndef M_PI
#define M_PI            3.14159265358979323846
#endif

#define EXTENSION ".e"

extern char fktext[10][64];

extern int error,surpressed,udf,udfon,linelength,stringon;
extern long loopindex;
extern char *next,*udfline;
extern int actargn;

extern int linew,fieldw,hchar,wchar;
extern double maxexpo,minexpo;
extern char expoformat[],fixedformat[];

extern FILE *infile,*outfile;
void output(char *s);
void output1(char *form, ...);
#define output2(form,s,t) output1(form,s,t)

typedef enum { s_real,s_complex,s_matrix,s_cmatrix,
	s_reference,s_command,s_submatrix,s_csubmatrix,s_string,s_udf } 
	stacktyp;
typedef struct
{	LONG size; char name[16]; int xor; stacktyp type; int flags;
#ifdef SPECIAL_ALIGNMENT
	double dummy;
#endif
	}
	header;
typedef struct { int c,r; 
#ifdef SPECIAL_ALIGNMENT
	double dummy;
#endif
	} dims;
typedef struct { header hd; double val; } realtyp;

extern double epsilon;

typedef enum { c_none, c_allv, c_quit, c_hold, 
		c_shg, c_load, c_udf, c_return, c_for, c_end, c_break,
		c_loop, c_if, c_repeat, c_endif, c_else,
		c_clear, c_clg, c_cls, c_exec, c_forget, c_global } 
	comtyp;

typedef struct { char *name; comtyp nr; void (*f)(void); } commandtyp;

typedef struct { char *name; int nargs;  void (*f) (header *); }
	builtintyp;
extern builtintyp builtin_list[];

/* edit.c */

void edit (char *s);
void prompt (void);

/* mainloop.c */

extern char *argname[];
extern int xors[];

void print_error (char *p);

void main_loop (int argc, char *argv[]);
header *new_matrix (int c, int r, char *name);
header *new_cmatrix (int c, int r, char *name);
header *new_real (double x, char *name);
header *new_complex (double x, double y, char *name);
header *new_reference (header *hd, char *name);
header *new_submatrix (header *hd, header *cols, header *rows,
	char *name);
header *new_csubmatrix (header *hd, header *cols, header *rows,
	char *name);
header *new_command (int no);
header *new_string (char *s, size_t size, char *name);
header *new_udf (char *name);
header *new_subm (header *var, LONG l, char *name);
header *new_csubm (header *var, LONG l, char *name);

int xor (char *n);

void scan_space (void);
void scan_name (char *name);
void next_line (void);
void trace_udfline(char *);
void getmatrix (header *hd, int *r, int *c, double **x);
header *searchvar (char *name);
header *searchudf (char *name);

#define realof(hd) ((double *)((hd)+1))
#define matrixof(hd) ((double *)((char *)((hd)+1)+sizeof(dims)))
#define dimsof(hd) ((dims *)((hd)+1))
#define commandof(hd) ((int *)((hd)+1))
#define referenceof(hd) (*((header **)((hd)+1)))
#define imagof(hd) ((double *)((hd)+1)+1)
#define rowsof(hd) ((int *)((dims *)((header **)((hd)+1)+1)+1))
#define colsof(hd) ((int *)((dims *)((header **)((hd)+1)+1)+1)+submdimsof((hd))->r)
#define submrefof(hd) (*((header **)((hd)+1)))
#define submdimsof(hd) ((dims *)((header **)((hd)+1)+1))
#define stringof(hd) ((char *)((hd)+1))
#define udfof(hd) ((char *)(hd)+(*((size_t *)((hd)+1))))
#define udfstartof(hd) ((size_t *)((hd)+1))
#define helpof(hd) ((char *)(hd)+sizeof(header)+sizeof(size_t))
#define nextof(hd) ((header *)((char *)(hd)+(hd)->size))

#define mat(m,c,i,j) (m+(((LONG)(c))*(i)+(j)))
#define cmat(m,c,i,j) (m+(2*(((LONG)(c))*(i)+(j))))

#define matrixsize(c,r) (sizeof(header)+sizeof(dims)+(c)*(LONG)(r)*sizeof(double))
#define cmatrixsize(c,r) (sizeof(header)+sizeof(dims)+2l*(c)*(LONG)(r)*sizeof(double))

header *next_param (header *hd);

void give_out (header *hd);

int command (void);

/* express.c */

header *map2 (void f(double *,double *,double *),
	void fc(double *, double *, double *, double *, double *, double *),
	header *hd, header *hd1);
header *map1 (void f(double *, double *), 
	void fc(double *, double *, double *, double *),
	header *hd);
header *map1r (void f(double *, double *), 
	void fc(double *, double *, double *),
	header *hd);
header *getvalue (header *);
header *getvariable (header *);
header *scan(void);
header *scan_value(void);
void moveresult (header *stack, header *result);
void moveresult1 (header *stack, header *result);
void copy_complex (double *, double *);
void complex_divide (double *, double *, double *, double *, double *,
	double *);
void complex_multiply (double *, double *, double *, double *, double *,
	double *);

void interpret_udf (header *var, header *args, int nargs);

int scan_arguments (void);

/* several */

void mnot (header *hd);
void mand (header *hd);
void mor (header *hd);
void mvconcat (header *hd);
void mhconcat (header *hd);

void sort_builtin (void);
void sort_commands (void);

void make_xors (void);

extern FILE *metafile;

