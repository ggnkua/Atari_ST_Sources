/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/taddr.h,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:31:12 $	$Locker: kbad $
* =======================================================================
*  $Log:	taddr.h,v $
* Revision 2.2  89/04/26  18:31:12  mui
* TT
* 
* Revision 2.1  89/02/22  05:32:33  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:36:30  lozben
* Initial revision
* 
*************************************************************************
*/
/*	TADDR.H		04/11/84 - 09/11/84	Gregg Morris		*/

#define NIL -1
#define ROOT 0
#define OB_NEXT(x) (tree + (x) * sizeof(OBJECT) + 0)
#define OB_HEAD(x) (tree + (x) * sizeof(OBJECT) + 2)
#define OB_TAIL(x) (tree + (x) * sizeof(OBJECT) + 4)
#define OB_TYPE(x) (tree + (x) * sizeof(OBJECT) + 6)
#define OB_FLAGS(x) (tree + (x) * sizeof(OBJECT) + 8)
#define OB_STATE(x) (tree + (x) * sizeof(OBJECT) + 10)
#define OB_SPEC(x) (tree + (x) * sizeof(OBJECT) + 12)
#define OB_X(x) (tree + (x) * sizeof(OBJECT) + 16)
#define OB_Y(x) (tree + (x) * sizeof(OBJECT) + 18)
#define OB_WIDTH(x) (tree + (x) * sizeof(OBJECT) + 20)
#define OB_HEIGHT(x) (tree + (x) * sizeof(OBJECT) + 22)
