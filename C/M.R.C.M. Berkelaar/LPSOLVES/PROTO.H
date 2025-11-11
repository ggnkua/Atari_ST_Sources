#ifdef __STDC__
# define	P(s) s
#else
# define P(s) ()
#endif


/* dual.c */
void rowdual P((int *rownr ));
short coldual P((int *numeta , int *rownr , int *colnr , short *minit , double *prow , double *drow ));

/* lp.c */
int yyparse P((void ));

/* read.c */
void yyerror P((char *string ));
void check_decl P((char *str ));
void add_int_var P((char *name ));
void init_read P((void ));
int hashvalue P((nstring string ));
hashelem *gethash P((nstring variable ));
column *getrow P((column *p , int row ));
bound *create_bound_rec P((void ));
void null_tmp_store P((void ));
void store P((nstring variable , int row , double value ));
void store_re_op P((void ));
void rhs_store P((double value ));
void var_store P((char *var , int row , double value ));
int store_bounds P((void ));
void resize_eta P((void ));
void readinput P((int *cend , double *rh , short *relat , double *lowbo , double *upbo , matrec *mat , nstring *names ));

/* tran.c */
void ftran P((int start , int end , double *pcol ));
void btran P((int numc , double *row ));

/* main.c */
short is_int P((double value ));
void allocate_globals P((void ));
void signal_handler P((int sig ));

/* solve.c */
void condensecol P((int rownr , int numc , double *pcol ));
void addetacol P((int *numc ));
void presolve P((void ));
void setpivcol P((short *lower , int varin , int numeta , double *pcol ));
short colprim P((int *colnr , int *numeta , short *minit , double *drow ));
void minoriteration P((int colnr , int rownr , int *numeta ));
void rhsmincol P((double *theta , int rownr , int varin , int numeta ));
void invert P((int n , int *numeta , int *numinv ));
short rowprim P((int *rownr , double *theta , double *pcol ));
void iteration P((int *numc , int *rownr , int *varin , double *theta , double *up , short *minit , short *low , short *primair , short *smotes , int *iter , int *numinv ));
int solvelp P((void ));
void construct_solution P((double *sol ));
int solve P((double *upbo , double *lowbo ));

/* write.c */
void print_solution P((FILE *stream , double *sol ));
void print_indent P((void ));
void debug_print_solution P((double *sol ));
void debug_print_bounds P((double *upbo , double *lowbo ));
void debug_print P((char *format , ...));

#undef P
