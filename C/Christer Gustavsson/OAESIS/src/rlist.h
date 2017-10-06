#ifndef	__RLIST__
#define	__RLIST__

#include	"types.h"

/****************************************************************************
 * Rlist_insert                                                             *
 *  Combines the rectangle lists dst and src and create a list of the       *
 *  largest possible rectangles in dst. The rectangles in src should be     *
 *  deleted with rlistinsert when not needed anymore.                       *
 ****************************************************************************/
void              /*                                                        */
Rlist_insert(     /*                                                        */
RLIST **dst,      /* Destination rectangle list.                            */
RLIST **src);     /* Source rectangle list.                                 */
/****************************************************************************/

/****************************************************************************
 * Rlist_erase                                                              *
 *  Erase rectangle list.                                                   *
 ****************************************************************************/
void              /*                                                        */
Rlist_erase(      /*                                                        */
RLIST **src);     /* Rectangle list to erase.                               */
/****************************************************************************/

/****************************************************************************
 * Rlist_duplicate                                                          *
 *  Duplicate rectangle list.                                               *
 ****************************************************************************/
RLIST *           /* The new rectangle list.                                */
Rlist_duplicate(  /*                                                        */
RLIST *src);      /* Rectangle list to duplicate.                           */
/****************************************************************************/

/****************************************************************************
 * Rlist_sort                                                               *
 *  Sort rectangle list in a "safe" order before moving (dx,dy).            *
 ****************************************************************************/
void              /*                                                        */
Rlist_sort(       /*                                                        */
RLIST **src,      /* Rectangle list to be sorted.                           */
WORD  dx,         /* Movement in x direction.                               */
WORD  dy);        /* Movement in y direction.                               */
/****************************************************************************/

/****************************************************************************
 * Rlist_rectinter                                                          *
 *  Get rectangle parts from src that intersects with area and insert them  *
 *  in dst. No optimization will be done on dst or src.                     *
 ****************************************************************************/
void              /*                                                        */
Rlist_rectinter(  /*                                                        */
RLIST **dst,      /* Destination rectangle list.                            */
RECT  *area,      /* Area to grab parts of.                                 */
RLIST **src);     /* Source rectangle list.                                 */
/****************************************************************************/

#endif
