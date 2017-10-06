typedef double complex[2];

extern int error;
extern char *newram,*ramend;

void solvesim (double *a, int n, double *b, int m, double *c);
void c_solvesim (double *a, int n, double *b, int m, double *c);

void c_add (complex x, complex y, complex z);
void c_sub (complex x, complex y, complex z);
void c_div (complex x, complex y, complex z);
void c_mult (complex x, complex y, complex z);
void c_copy (complex x, complex y);

void make_lu (double *a, int n, int m,int **rows, int **cols, int *rankp,
	double *det);
void cmake_lu (double *a, int n, int m, int **rows, int **cols, int *rankp,
	double *det, double *deti);
void lu_solve (double *a, int n, double *b, int m, double *c);
void clu_solve (double *a, int n, double *b, int m, double *c);

void fft (double *a, int n, int signum);

void bauhuber (double *m, int deg, double *res, int all,
	double startr, double starti);

void tridiag (double *m, int n, int **r);
void ctridiag (double *m, int n, int **r);

void charpoly (double *m, int n, double *p);
void ccharpoly (double *m, int n, double *p);

