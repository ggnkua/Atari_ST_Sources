
/*
	_Before_ including this file, be sure to include
	stdio.h
*/

/* Booleans: */
#define TRUE 1
#define FALSE 0

/* File fatal.c */
void FatalError (char *error_text);

/* File macheps.c */
double macheps ();

/* File loadfile.c */
float **LoadFile (char *dfname,
		  int *NumColumns, int *ObsNum,
		  int pickfields, char *cstring, char *ustring,
		  char ***labels, int **table, int *tablesize);

/* File ran1.c */
double ran1 (int *idum);

/* File split.c */
int split (char *string, char **fields, int size_fields, char *separators);

/* File loadvector.c */
float *loadvector (FILE * inf, int *N);

/* File maxmem.c */
long int maxmem ();

/* File miscstring.c */
#ifndef _STRING_H
char *strdup (char *s);
#endif

/* File arcpoints.c */
int mk_arcpoints (double x0, double y0, double r,
		  double theta1, double theta2, double deltat,
		  float **x, float **y, int *N);

/* File ../MEMORY/matalloc.c */
/* File ../MEMORY/matfree.c */
/* File ../MEMORY/valloc.c */
/* File ../MEMORY/vfree.c */
/* File ../MEMORY/matalloc.inc */
/* File ../MEMORY/matfree.inc */
/* File ../MEMORY/valloc.inc */

float **matrix (int rl, int rh, int cl, int ch);
double **dmatrix (int rl, int rh, int cl, int ch);
int **imatrix (int rl, int rh, int cl, int ch);

void free_matrix (float **M, int rl, int rh, int cl, int ch);
void free_dmatrix (double **M, int rl, int rh, int cl, int ch);
void free_imatrix (int **M, int rl, int rh, int cl, int ch);

float *vector (int l, int h);
double *dvector (int l, int h);
int *ivector (int l, int h);

void free_vector (float *V, int l, int h);
void free_dvector (double *V, int l, int h);
void free_ivector (int *V, int l, int h);

/* File ../MEMORY/fillm.inc */
/* File ../MEMORY/fillv.inc */
/* File ../MEMORY/inits.c */

void fill_ivector (int *v, int N, int V);
void fill_vector (float *v, int N, float V);
void fill_dvector (double *v, int N, double V);

void fill_imatrix (int **M, int rows, int cols, int V);
void fill_matrix (float **M, int rows, int cols, float V);
void fill_dmatrix (double **M, int rows, int cols, double V);

void I_matrix (float **M, int N);
void I_imatrix (int **M, int N);
void I_dmatrix (double **M, int N);
