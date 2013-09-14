/*  SCROLL.H
/*	2-May-88	ml.	for use in bslscrol.c and defscol.c	*/

#define LWGET(x)	((int) *((int *)(x)))
#define LWSET(x, y)	(*((int *)(x)) = y)
#define LLGET(x)	(*((long *)(x)))
#define LLSET(x, y)	(*((long *)(x)) = y)

#define OB_STATE(tree, x)	((long)tree + (x) * sizeof(OBJECT) + 10)
#define OB_SPEC(tree, x)	((long)tree + (x) * sizeof(OBJECT) + 12)
#define OB_X(tree, x)		((long)tree + (x) * sizeof(OBJECT) + 16)
#define OB_Y(tree, x)		((long)tree + (x) * sizeof(OBJECT) + 18)
#define OB_WIDTH(tree, x)	((long)tree + (x) * sizeof(OBJECT) + 20)
#define OB_HEIGHT(tree, x)	((long)tree + (x) * sizeof(OBJECT) + 22)

#define NM_ITEMS  8	/* number of items to be scrolled */

