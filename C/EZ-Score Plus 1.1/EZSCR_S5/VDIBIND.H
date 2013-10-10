/*
			VDI BINDING ROUTINES
			--------------------

	The following routines are the actual binding routines found in the 
VDIBIND library. They have been provided to help clear up any discrepancy
within the GEM Programmer's Guide Volume 1: VDI.
*/


#include    "portab.h"

extern    WORD    contrl[];
extern    WORD    intin[];
extern    WORD    ptsin[];
extern    WORD    intout[];
extern    WORD    ptsout[];

extern    WORD	*pioff, *iioff, *pooff, *iooff;

extern    vdi();

#define i_ptsin(ptr) pioff = ptr
#define i_intin(ptr) iioff = ptr
#define i_intout(ptr) iooff = ptr
#define i_ptsout(ptr) pooff = ptr

extern    i_ptr();
extern    i_ptr2();
extern    m_lptr2();
