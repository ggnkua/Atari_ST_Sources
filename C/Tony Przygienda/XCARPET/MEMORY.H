/* 'DEFINITIONS' fÅr MEMORY.C */

extern char *array2d;

int check_resolution(int, int);
int get_yresolution(int);

void *reserve2d(int, int);
void xfree(void *);
void free_2d(void);
void free_xyz(void);

double *row_vector(int);

int reservexyz(int, int);
 

