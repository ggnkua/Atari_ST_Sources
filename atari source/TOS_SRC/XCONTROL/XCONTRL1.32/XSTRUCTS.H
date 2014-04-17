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
#include <sys\portab.h>
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

#define CPX_CHICKEN 0x100L  /* cpx load memory safety margin */

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

 
 
/*
 * Data structure for SLOTS. Slots are the objects that hold
 * the icon, filename, and text string of a loaded cpx.
 * There are currently MAX_SLOTS defined and are stored in
 * an array of SLOT
 * The array is defined in SLOTS.C
 */ 
typedef struct slot
{
   int     obj;					/* Object to click on */
   int     text;				/* Large text object  */
   int     icon;				/* Icon Object...     */
   int     base;				/* base of objects... */
   CPXNODE *sptr;				/* Ptr to structure   */
} SLOT;   



/* Structure for the filename nodes, which is used by the MOVER/RENAME
 * routines to display the active and inactive CPXs.
 * FILE: XOPTIONS.C
 */
typedef struct _fnode
{
   BOOLEAN aflag;		/* 0 - Deselect/ 1 = Selected      
   				 * This is the actual state visible on 
   				 * the screen of the filename node.
   				 */
   BOOLEAN sflag;		/* The Shadow flag, this is what the Action
   				 * Flag 'WAS' before it was toggled.
   				 * It is used for the scrolling toggle
   				 * routines.
   				 */
   BOOLEAN mflag;		/* The original state of the file.
   				 * 1 = Active, 0 - Inactive
   				 */
   char fname[10];		/* The filename. 8 Characters for fnamely */
   struct _fnode *next;   				 
}FNODE;

