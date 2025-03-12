/*
 * drawcicn.h as of 08/26/95
 *
 * Contains the prototypes for the functions init_routines,
 * deinit_routines, and init_tree in drawcicn.c, and some
 * definitions.
 *
 * For copying and use of this routine see drawcicn.c!
 *
 * History:
 * 02/04/95: Creation
 * 08/13/95: Added planes to the DRAW_CICON-structure
 * 08/15/95: Added original to the DRAW_CICON-structure
 * 08/20/95: Removed icon from the DRAW_CICON-structure because the
 *           ICONBLK can also be accessed via the pointer original,
 *           which is now a documented part of DRAW_CICON
 * 08/23/95: Now really removed icon from the DRAW_CICON-structure...
 *           It seems I had only done that in all comments, but not in
 *           the declaration itself...
 * 08/26/95: "Fixed" comment for init_tree: The pointer original was
 *           described twice
 */

#ifndef _DRAWCICN_H_INCLUDED
#define _DRAWCICN_H_INCLUDED

#include <mt_gemx.h>

#include <stdlib.h>
#include <string.h>
#include <portab.h>

typedef struct _cicon_data
{
    WORD				num_planes;
    WORD				*col_data;
    WORD				*col_mask;
    WORD				*sel_data;
    WORD				*sel_mask;
    struct _cicon_data	*next_res;
} _CICON;

typedef struct
{
    ICONBLK	monoblk;
    _CICON	*mainlist;
} _CICONBLK;

typedef struct draw_cicon
{
    struct draw_cicon	*next;
    WORD				*icon_data;
    WORD				*sel_idata;
    WORD				*mask_data;
    WORD				*sel_mdata;
    WORD				planes;
    _CICONBLK			*original;
    WORD				free_icon;
    WORD				free_sel;
    USERBLK				attached;
} DRAW_CICON;

typedef struct
{
 DRAW_CICON	*first;
} DCINFO;

short init_cicon(void);
short init_cicon_with_palette(WORD *pal);
void exit_cicon(void);
void init_routines(DCINFO *dinfo);
void deinit_routines(DCINFO *dinfo);
WORD init_tree(OBJECT *tree,DCINFO *dinfo);

#endif

/* EOF */
