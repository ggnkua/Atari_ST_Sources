/**************************************************************************
 * FRMNLDSU.C - Some service routines used by frm_nl and frm_ds functions.
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

#define JUSTIFY_LEFT   0
#define JUSTIFY_CENTER 2

/*-------------------------------------------------------------------------
 * 
 *-----------------------------------------------------------------------*/

static TEDINFO local_tedinfos[] = {
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1}
};                                                                    

typedef struct ___size_sanity_check___ {
    char x[FRM_DSMAXSTRINGS == (sizeof(local_tedinfos)/sizeof(TEDINFO))];
} ___size_sanity_check___;

/*-------------------------------------------------------------------------
 * set width of an object and all its children.
 *-----------------------------------------------------------------------*/

void _FrmTrWidths(ptree, parent, width)
    register OBJECT *ptree;
    register int    parent;
    register int    width;
{
    register int    curobj;
    
    ptree[parent].ob_width = width;
    curobj = ptree[parent].ob_head;
    
    while (curobj != parent && curobj >= ROOT) {
        ptree[curobj].ob_width = width;
        curobj = ptree[curobj].ob_next;
    }
}

/*-------------------------------------------------------------------------
 * attach string pointers from array to tedinfo pointers, 
 * attach tedinfos to tree objects.
 * if the objects pointed to by pobj are not G_xTEXT objects, it 
 * attaches the strings directly to the objects and doesn't touch
 * the tedinfo array at all.
 *-----------------------------------------------------------------------*/

int _FrmDS2Obj(ppstr, pobj, pted, pwidth, maxobj)
    register char    **ppstr;
    register OBJECT  *pobj;
    register TEDINFO *pted;
    int              *pwidth;
    int              maxobj;
{
    char             *pstr;
    register int     len;
    register int     counter;
    register int     linecount = 0;
    register int     width     = *pwidth;
    int              sumwidth  = FALSE;
    int              center_it;
    
    if (width == -1) {
        sumwidth = TRUE;
        width    = 0;
    }
    
    if (pted == NULL) {
        pted = local_tedinfos;
    }

    for (counter = 0; counter < maxobj; ++counter) {
        pstr = *ppstr;
        if (pstr == NULL) {
            pobj->ob_flags |= HIDETREE;
        } else {
            pobj->ob_flags &= ~HIDETREE;
            if (*pstr == 0x7F) {
                center_it = TRUE;
                ++pstr;
            } else {
                center_it = FALSE;
            }
            len  = strlen(pstr);
            if (sumwidth) {
                width += len;
            } else if (width < len) {
                width = len;
            }
            switch (pobj->ob_type & 0x00FF) {
              case G_TEXT:
              case G_BOXTEXT:
              case G_FTEXT:
              case G_FBOXTEXT:
                pobj->ob_spec   = (long)pted;
                pted->te_ptext  = pstr;
                pted->te_txtlen = len;
                pted->te_just   = (center_it) ? JUSTIFY_CENTER : JUSTIFY_LEFT;
                break;
              default:
                pobj->ob_spec   = (long)pstr;
                break;
            }
            ++ppstr;
            ++linecount;
        }
        ++pobj;
        ++pted;
    }
    
    *pwidth = width;
    return linecount;
}

/*-------------------------------------------------------------------------
 * Go put \n chars back in all the places where we changed them to \0.
 *-----------------------------------------------------------------------*/

void _FrmNLPatch(patch_array)
    register char  **patch_array;
{
    register char   *thepatch;
    
    while (NULL != (thepatch = *patch_array)) {
        *thepatch = '\n';
        ++patch_array;
    }
}

/*-------------------------------------------------------------------------
 * Divide \n-delimited string into set of \0-terminated strings.
 *-----------------------------------------------------------------------*/

void _FrmNL2DS(strings, pointer_array, patch_array, maxstrings)
    register char    *strings;
    register char   **pointer_array;
    register char   **patch_array;
    register int      maxstrings;
{
    register int      counter;
    register char     c;

    for (counter = 0; *strings && counter < maxstrings; ++counter) {
        *pointer_array = strings;
        for (;;) {
            c = *strings;
            if (c == '\0' || c == '\n') {
                break;
            }
            ++strings;
        }
        if (c == '\n') {
            if (patch_array) {
                *patch_array++ = strings;
            }
            *strings++ = '\0';
        }
        if (**pointer_array == '\0') {
            *pointer_array = " ";
        }
        ++pointer_array;
    }
    *pointer_array = NULL;
    if (patch_array) {
        *patch_array   = NULL;
    }
}

