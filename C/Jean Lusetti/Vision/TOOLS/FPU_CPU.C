/*****************************/
/* Quelques routines CPU-FPU */
/*****************************/
#include <string.h>


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


void cpu2fpudouble(double *x, FPU_DOUBLE *fpu)
{
  CPU_DOUBLE cpu ;

  memcpy(&cpu, x, sizeof(CPU_DOUBLE)) ;
  memcpy(fpu->mantissa, &cpu.mantissa, 2*sizeof(long)) ;
  fpu->zero     = 0 ;
  fpu->exponent = cpu.exponent ;
}
