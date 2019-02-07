/* Copyright 1990 by Antic Publishing, Inc. */
#include <obdefs.h>

objc_box(tree, branch, x, y, w, h)

OBJECT *tree;  /* Pointer to object tree */
int    branch; /* Subobject of interest */
short *x, *y, *w, *h;  /* Position of size of specified object */

/*
** This routine determines the positions (x & y coordinates) and size (width
** and height) of the object BRANCH, which is within the structure TREE.
*/
{
   objc_offset(tree, branch, x, y);
   *w = tree[branch].ob_width;
   *h = tree[branch].ob_height;
}

