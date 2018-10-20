#include <grape_h.h>

int roff;

typedef struct {
  void     *baseAddr;/*pointer to pixels*/
  short    rowBytes;/*offset to next line*/
  /* Rest egal */
}PixMap;

typedef struct  { 
  short   vers;     /* Version number of Cookie */ 
  short   size; 
  long    flags1;     /* Bits: see above */ 
  PixMap    *scrnPMPtr; 
  /* Rest interessiert nicht */ 
}MgMcCookie; 

void mgmc_extend_base(void)
{
	MgMcCookie	*mmc;

	/* find magicmac cookie */
	if(find_cookie('MgMc', (long*)(&mmc))==0)
		roff=sw;
	else	
		roff=(int) ((long) ( 32768l+(long)(mmc->scrnPMPtr->rowBytes)) );
}