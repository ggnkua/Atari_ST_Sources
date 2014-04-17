/*
 * Internal structures for XCONTROL...
 * This file needs to be included BEFORE slots.h or cpxhandl.h are
 * loaded.
 * An example can be:
 *
 *  #include "xcontrol.h"		;XCONTROL RCS objects 
 *  #include "xstructs.h"		;This file...
 *  #include "cpxdata.h"		;Inter-cpx data structures
 *  #include "cpxhandl.h"		;cpxhandl.c prototypes
 *  #include "slots.h"			;slots.c prototypes
 */
#include <alt\portab.h>
#include "cpxhead.h"				/* CPX HEADER FORMAT */ 

typedef struct _Prghead
{
	int	magic;
	long	tsize,
		dsize,
		bsize,
		ssize;
	int	fill[5];
} Prghead;


/*
 * Internal data structure for storing cpx headers in a linked list.
 * Data structure manipulation is in cpxhandl.c
 * We INCLUDE the header so that it can be sized and changed without
 * too much hassle. Note that there are some additional requirements
 * for the nodes than just the header information.
 */
typedef struct cpxnode
{
   char      fname[ 14 ];	 /* filename...   */
   int	     vacant;		 /* 1 = not vacant*/
   int	     SkipRshFix;	 /* Always 0 if non-resident. For residents
   				  * 0 first time CPXinit is called and then 
   				  * set to 1 so it will skip it thereafter
   				  */
   long      *baseptr;	         /* Basepage ptr
   				  * for resident cpxs
   				  */
   struct    cpxnode   *next;	 /* Next cpxnode      */
   CPXHEAD   cpxhead;		 /* cpx header struct */
				 /* NOTE: THESE TWO FIELDS MUST REMAIN
				  * CONTIGUOUS FOR ALL TIME!!!
				  */
   Prghead   prghead;		 /* program header of CPX */
   
} CPXNODE;

 
 

