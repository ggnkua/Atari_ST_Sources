/***********************/
/* Header de FPU_CPU.C */
/***********************/

typedef struct
{
  int  exponent ;
  int  zero ;
  long mantissa[2] ;
}
FPU_DOUBLE ;

typedef struct
{
  int  exponent ;
  long mantissa[2] ;
}
CPU_DOUBLE ;


void cpu2fpudouble(double *x, FPU_DOUBLE *fpu) ;
