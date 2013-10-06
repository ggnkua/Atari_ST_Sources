

/***************************************************************************

    XRSC30.C

    - code for embedded resource trees

    Code from RSC 2.0

    12/29/88 created

    09/06/89 19:00

***************************************************************************/

#include <gemdefs.h>
#include <obdefs.h>

#define adj(xywh, siz)  (siz * (xywh & 0x00FF) + (xywh >> 8))

#define LONG long
#define WORD int
#define BYTE char

#define NIL (-1L)

#include "xrsc30.rsh"

rsc_fix()
    {
    fix_trindex();
    fix_objects();
    fix_tedinfo();
#ifdef NOT_NEED
    fix_iconblk();
    fix_bitblk();
    fix_frstr();
    fix_frimg();
#endif
    }

fix_trindex()
    {
    int test;
    register int ii;

    for (ii = 0; ii < NUM_TREE; ii++)
        {
        test = (int) rs_trindex[ii];
        rs_trindex[ii] = (long) &rs_object[test];
        }
    }

fix_objects()
    {
    int test, ii;
    int wchar, hchar;

    graf_handle( &wchar, &hchar, &ii, &ii );

    for (ii = 0; ii < NUM_OBS; ii++)
        {
        rs_object[ii].ob_x = adj(rs_object[ii].ob_x, wchar);
        rs_object[ii].ob_y = adj(rs_object[ii].ob_y, hchar);
        rs_object[ii].ob_width = adj(rs_object[ii].ob_width, wchar);
        rs_object[ii].ob_height = adj(rs_object[ii].ob_height, hchar);
        test = (int) rs_object[ii].ob_spec;

        switch (rs_object[ii].ob_type)
            {
        case G_TITLE:
        case G_STRING:
        case G_BUTTON:
            fix_str(&rs_object[ii].ob_spec);
            break;

        case G_TEXT:
        case G_BOXTEXT:
        case G_FTEXT:
        case G_FBOXTEXT:
            if (test != NIL)
               rs_object[ii].ob_spec =
                (char *) &rs_tedinfo[test];
            break;

#ifdef NOT_NEED
        case G_ICON:
            if (test != NIL)
               rs_object[ii].ob_spec =
                (char *) &rs_iconblk[test];
            break;

        case G_IMAGE:
            if (test != NIL)
               rs_object[ii].ob_spec =
                (char *) &rs_bitblk[test];
            break;
#endif
        default:
            break;
            }
        }
    }

fix_tedinfo()
    {
    register int ii;

    for (ii = 0; ii < NUM_TI; ii++)
        {
        fix_str(&rs_tedinfo[ii].te_ptext);
        fix_str(&rs_tedinfo[ii].te_ptmplt);
        fix_str(&rs_tedinfo[ii].te_pvalid);
        }
    }

fix_frstr()
    {
    register int ii;

    for (ii = 0; ii < NUM_FRSTR; ii++)
        fix_str(&rs_frstr[ii]);
    }

fix_str(where)
register long *where;
    {
    if (*where != NIL)
        *where = (long) rs_strings[(int) *where];
    }

#ifdef NOT_NEED
fix_iconblk()
    {
    register int ii;

    for (ii = 0; ii < NUM_IB; ii++)
        {
        fix_img(&rs_iconblk[ii].ib_pmask);
        fix_img(&rs_iconblk[ii].ib_pdata);
        fix_str(&rs_iconblk[ii].ib_ptext);
        }
    }

fix_bitblk()
    {
    register int ii;

    for (ii = 0; ii < NUM_BB; ii++)
        fix_img(&rs_bitblk[ii].bi_pdata);
    }

fix_frimg()
    {
    register int ii;

    for (ii = 0; ii < NUM_FRIMG; ii++)
        fix_bb(&rs_frimg[ii]);
    }

fix_bb(where)
register long  *where;
    {
    if (*where != NIL)
        *where = (long) (char *) &rs_bitblk[(char) *where];
    }

fix_img(where)
register long  *where;
    {
    if (*where != NIL)
        *where = (long) (char *) rs_imdope[(int) *where].image;
    }
#endif


