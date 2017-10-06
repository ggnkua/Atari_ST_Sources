void spread1 (double f (double), 
	void fc (double *, double *, double *, double *),
	header *hd);
void make_complex (header *hd);

void minmax (double *x, LONG n, double *min, double *max, 
	int *imin, int *imax);

void transpose (header *hd);
void vectorize (header *init, header *step, header *end);
void msin (header *hd); 
void mcos (header *hd);
void mtan (header *hd);
void matan (header *hd);
void mexp (header *hd);
void mlog (header *hd);
void msqrt (header *hd);
void mre (header *hd);
void mim (header *hd);
void mpi (header *hd);

void mdup (header *hd);
void msum (header *hd);
void mprod (header *hd);
void mcomplex (header *hd);

void mpower (header *hd);

int exec_builtin (char *name, int nargs, header *hd);
void print_builtin (void);

void mgreater (header *hd);
void mless (header *hd);
void mgreatereq (header *hd);
void mlesseq (header *hd);
void mequal (header *hd);
void munequal (header *hd);
void maboutequal (header *hd);

void msolve (header *hd);

void mindex (header *hd);
