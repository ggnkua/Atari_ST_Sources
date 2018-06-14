
#ifndef BMAPTYPEDEF
#define BMAPTYPEDEF


typedef  struct __attribute__ ((aligned (2))) _bmaptype
{
   int type;
   int Xsize;
   int Ysize;
   int size;
   int csize;
   unsigned char * data;
} bmaptype;
#endif
