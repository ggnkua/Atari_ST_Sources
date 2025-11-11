

/* File misc.c */
void PrintMatrix (float **M, int rows, int cols, char *fmt);
void d_PrintMatrix (double **M, int rows, int cols, char *fmt);
void Transpose (float **A, int n);
void d_Transpose (double **A, int n);
void CopyMatrix (double **A, double **B, int rows, int cols);
void CopyVector (double *x, double *y, int K);
void RandomSym (double **A, int K, int *seed);
void RandomMatrix (double **A, int rows, int cols, int *seed);
double trace (double **A, int N);

/* File lustuff.c */
int Inverse (float **A, float **Y, int n);
int d_Inverse (double **A, double **Y, int n);
int d_LinSys (double **A, double *b, double *x, int K);

/* File multiply.c */
void MMult (float **A, float **B, float **C, int M, int N, int K);
void d_MMult (double **A, double **B, double **C, int M, int N, int K);
float dot (float *x, float *y, int N);
double d_dot (double *x, double *y, int N);
double df_dot (double *x, float *y, int N);

/* File jacobi.c */
void d_jacobi (double **a, int n, double *d, double **v, int *nrot);

/* File randompd.c */
void RandomPD (double **A, int K, int *seed);
void LessRandomPD (double **A, int K, int *seed);

/* File cholesky.c */
void cholesky (double **A, double **U, int N, int *nullity);
int pd_LinSys (double **A, double *b, double *x, int K);
int pd_Inverse (double **A, int K);
double pd_Logdet (double **A, int K);

/* File covcor.c */
void trans_crm (double **cormat, int size, double **result);
void untrans_crm (double **cormat, int size, double **result);
void cr2cv (double **cormat, int size, double **covmat);
void cv2cr (double **covmat, int size, double **cormat);

/* File vectors.c */
void scalar_vector_mult (double *x, int K, double k);
void vadd (double *x, double *y, int K, double *z);
double enorm (double *x, int K);

/* File quad.c */
void mquad (int n, int m, double **x, double **A, double **B);
double vquad (int n, double *x, double **A);
double vquad_sym (int n, double *x, double **A);

/* File hql_eig.c */
void hql_eig (double **a, int n, double *d, double **z);

/* File sweep.c */
void sweep (double **A, int N);
