/*
 * drawcicn.h as of 10/19/95
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
 * 10/19/95: Prepared for usage of Memdebug to see how much memory is
 *           used and if there are any leaks.
 */

#ifndef _DRAWCICN_H_INCLUDED
#define _DRAWCICN_H_INCLUDED

#include <aes.h> /* Replace aes.h and vdi.h with the corresponding */
#include <vdi.h> /* files of your favourite compiler */
#include <stdlib.h>
#include <string.h>
#include <portab.h>
#ifdef MEMDEBUG
#include <memdebug.h>
#endif

#define _G_CICON	33

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

/*
 * init_routines
 *
 * This function initialises important global variables used by the
 * other routines in that file. Call this function at the beginning
 * of your program and *never* forget to do so, because otherwise a
 * call to init_tree will crash.
 *
 * Input:
 * vdi_handle: Handle of the virtual vdi-workstation the routines
 *             should use
 */
void init_routines(WORD vdi_handle);

/*
 * deinit_routines
 *
 * This functions frees all memory allocated by calls to init_tree.
 * Call this function at the end of your program. If you don't do it,
 * it's possible that you get a lack of memory.
 */
void deinit_routines(void);

/*
 * init_tree
 *
 * This routine initialises an AES-object-tree that may contain
 * color-icons so that it can simply be drawn with objc_draw. To
 * achive that, all color-icons are converted into G_USERDEF-objects,
 * where ub_parm points to the following structure:
 *
 * typedef struct draw_cicon
 * {
 *     struct draw_cicon *next;      pointer to next structure
 *     WORD              *icon_data; pointer to icon-data, this
 *                                    data is in the device-
 *                                    dependent format of the
 *                                    current resolution
 *     WORD              *sel_idata; pointer to data of the
 *                                    selected icon, same format as
 *                                    icon_data. Note that this
 *                                    data is always present, even
 *                                    if the corresponding icon
 *                                    didn't have explicit data for
 *                                    the state 'selected'
 *     WORD              *mask_data; pointer to mask, 1 plane in
 *                                    device-dependent-format
 *     WORD              *sel_mdata; pointer to mask of selected
 *                                    icon, format as mask_data
 *     WORD              planes;     number of planes used in icon-
 *                                    data (this is either 1 or the
 *                                    value of the active resolution)
 *     _CICONBLK         *original;  original CICONBLK, use this to
 *                                    get the ICONBLK of the icon,
 *                                    e.g. to change the text
 *     WORD              free_icon;  for internal use only
 *     WORD              free_sel;   dito
 *     USERBLK           attached;   dito
 * } DRAW_CICON;
 *
 * init_tree looks if the color-icon contains data that fits the
 * current resolution. If so, it is converted into device-dependent
 * format. If not, and the color-icon contains 4-plane-data, and the
 * current resolution has more than 4 planes, or 1-plane-data is
 * available, that data is converted and used. In all other cases, or
 * due to lack of memory, the icon will be converted into a simple
 * mono-icon (i.e., ob_type will be set to G_ICON and ob_spec will
 * point to the ICONBLK supplied with the color-icon).
 *
 * BUGS: Up to now, init_tree only re-uses color-icons with 1 or 4
 * planes in resolutions with more planes. Maybe that will change in
 * future, but I can't promise.
 *
 * Input:
 * tree: Pointer to the tree that should be initialised
 *
 * Output:
 * 0: One or more color-icons were only converted into mono-icons.
 * otherwise: All color-icons in tree have been converted into
 *            user-defined objects.
 */
WORD init_tree(OBJECT *tree);

#endif

/* EOF */
