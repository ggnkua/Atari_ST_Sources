/**************************************************************************
 * FRMDSDIA.C - frm_dsdialog(): dynamic string dialog routine.
 *************************************************************************/

#include "gemfast.h"
#include "frmtypes.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

static char *default_buttons[] = {" Continue ",     NULL};
static char *default_strings[] = {"<no message>",   NULL};

/*-------------------------------------------------------------------------
 * Object tree for dynamic dialog box...
 *-----------------------------------------------------------------------*/

#define OUTLINED_BOX_SPEC 0x00021100L
#define SHADOWED_BOX_SPEC 0x00FF1100L

static OBJECT dialtree[] = {
  -1,  1, 21, G_BOX,    NONE,   OUTLINED, 0x00021100L,0x0000, 0x0000, 0x0021, 0x0017,
   2, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0001, 0x0001, 0x0001,
   3, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0002, 0x0001, 0x0001,
   4, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0003, 0x0001, 0x0001,
   5, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0004, 0x0001, 0x0001,
   6, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0005, 0x0001, 0x0001,
   7, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0006, 0x0001, 0x0001,
   8, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0007, 0x0001, 0x0001,
   9, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0008, 0x0001, 0x0001,
  10, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0009, 0x0001, 0x0001,
  11, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x000A, 0x0001, 0x0001,
  12, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x000B, 0x0001, 0x0001,
  13, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x000C, 0x0001, 0x0001,
  14, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x000D, 0x0001, 0x0001,
  15, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x000E, 0x0001, 0x0001,
  16, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x000F, 0x0001, 0x0001,
  17, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0010, 0x0001, 0x0001,
  18, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0011, 0x0001, 0x0001,
  19, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0012, 0x0001, 0x0001,
  20, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0013, 0x0001, 0x0001,
  21, -1, -1, G_STRING, NONE,   NORMAL,   0L,         0x0001, 0x0014, 0x0001, 0x0001,
   0, 22, 26, G_IBOX,   NONE,   NORMAL,   0x00001100L,0x0001, 0x0015, 0x0001, 0x0001,
  23, -1, -1, G_BUTTON, 0x0005, NORMAL,   0L,         0x0000, 0x0000, 0x0001, 0x0001,
  24, -1, -1, G_BUTTON, 0x0005, NORMAL,   0L,         0x0000, 0x0000, 0x0001, 0x0001,
  25, -1, -1, G_BUTTON, 0x0005, NORMAL,   0L,         0x0000, 0x0000, 0x0001, 0x0001,
  26, -1, -1, G_BUTTON, 0x0005, NORMAL,   0L,         0x0000, 0x0000, 0x0001, 0x0001,
  21, -1, -1, G_BUTTON, 0x0025, NORMAL,   0L,         0x0000, 0x0000, 0x0001, 0x0001
  };

#define DIALSTL1 1      /* String Line 1                */
#define DIALPBXB 21     /* Parent Box for exit buttons  */
#define DIALBX01 22     /* First exit button            */

/*----------------------------------------------------------------------------
 * count_strings - Count strings and keep track of the longest one.
 *--------------------------------------------------------------------------*/

static int count_strings(pstrings, maxstrings, pmaxlen)
    register char   **pstrings;
    register int    maxstrings;
    int             *pmaxlen;
{
    register int    numstrings;
    register int    wrklen;
    register int    maxlen;

    for (numstrings = 0, maxlen = 0;
         numstrings < maxstrings && *pstrings && **pstrings != 0x00;
         ++numstrings,
         ++pstrings) {

            if (maxlen < (wrklen = strlen(*pstrings))) {
                maxlen = wrklen;
            }
    }

    *pmaxlen = maxlen;
    return numstrings;
}

/**************************************************************************
 * frm_dsdial - Form dynamic string dialog.
 *************************************************************************/

int frm_dsdialog(options, pbuttons, pstrings)
    long             options;
    char             *pbuttons[];
    char             *pstrings[];
{
    int              dmy;
    int              xbwidth;
    int              slen;
    register int     sizechar;
    register int     counter;
    register int     numobs;
    register int     pixlen;
    register OBJECT  *ptree;
    register char    **pwrk;
    static   int     initdone = 0;
    static   int     l1_title_y;
    static   int     l1_notitle_y;

/*-------------------------------------------------------------------------
 * validate the parameters.
 *-----------------------------------------------------------------------*/

    if (pstrings == NULL) {
        pstrings = default_strings;
    }

    if (pbuttons == NULL) {
        pbuttons = default_buttons;
    }

    if (!(options & FRM_NODEFAULTS)) {
        options |= (_FrmDefaults & FRM_DOPTIONBITS) | FRM_DEFAULT_DYNOPT;
    }
    options |= FRM_MANDATORY_DYNOPT;

/*-------------------------------------------------------------------------
 * Init the xywh values in the object tree, get the system character sizes
 * for later usage, precalc possible top-line Y placements for later.
 *-----------------------------------------------------------------------*/

    if (!initdone) {
        initdone = TRUE;
        rsc_treefix(dialtree);
        l1_notitle_y = dialtree[DIALSTL1].ob_y;
        l1_title_y   = l1_notitle_y - (gl_hchar >> 1);
    }

/*-------------------------------------------------------------------------
 * Count the button strings, find the longest one, distribute the buttons
 * evenly within their parent box, make the rightmost the default button.
 * (We place a gutter of 2 character widths on each side of each button.)
 *-----------------------------------------------------------------------*/

    {
        register int obx;

        numobs = count_strings(pbuttons, FRM_DSMAXBUTTONS, &slen);

        sizechar  = gl_wchar;
        pixlen    = (slen + 2) * sizechar;
        sizechar *= 2;
        xbwidth   = (numobs * pixlen) + ((numobs + 1) * sizechar);

        for (counter = 0, obx = sizechar, pwrk = pbuttons, ptree = &dialtree[DIALBX01];
             counter < FRM_DSMAXBUTTONS;
             ++counter, obx += pixlen + sizechar, ++ptree) {

            ptree->ob_flags &= ~DEFAULT;

            if (counter < numobs) {
                ptree->ob_flags &= ~HIDETREE;
                ptree->ob_x     = obx;
                ptree->ob_spec  = (long)*pwrk++;
                ptree->ob_width = pixlen;
            } else {
                ptree->ob_flags |= HIDETREE;
            }
        }

        if (!(options & FRM_DMUSTSELECT)) {
            dialtree[DIALPBXB+numobs].ob_flags |= DEFAULT;
        }
    }

/*-------------------------------------------------------------------------
 * Count the dialog strings, find the largest, calc the size of the
 * dialog box and the placement of the buttons at the bottom.  If space
 * permits, we leave a 1-line gutter between the last dialog string and
 * the buttons, but if all 20 dialog strings are used, then the buttons
 * are jammed right up against the bottom string.
 *-----------------------------------------------------------------------*/

    {
        register int btnadjust;

        numobs    = count_strings(pstrings, FRM_DSMAXSTRINGS, &slen);

        btnadjust = (numobs < FRM_DSMAXSTRINGS); /* button padding, if space allows */

        pixlen    = (slen + 2) * gl_wchar;
        pixlen    = (pixlen > xbwidth) ? pixlen : xbwidth;

        sizechar  = gl_hchar;

        ptree            = dialtree;
        ptree->ob_width  = pixlen;
        ptree->ob_height = ((numobs + 3 + btnadjust) * sizechar);

        ptree            = &dialtree[DIALPBXB];
        ptree->ob_x      = (pixlen - xbwidth) >> 1;
        ptree->ob_y      = ((numobs + 1 + btnadjust) * sizechar) + (sizechar >> 2);
        ptree->ob_width  = xbwidth;
    }

/*-------------------------------------------------------------------------
 * Set the ob_width and ob_spec for all the active strings in the dialog
 * box, set all the inactive strings to HIDETREE.  Center strings that
 * start with 0x7F (and fix it so the 0x7F char isn't displayed).
 *-----------------------------------------------------------------------*/

    {
    register char *line;
    register int  at_x;
    register int  len;

        sizechar = gl_wchar;
        for (counter = 0, pwrk  = pstrings, ptree = &dialtree[DIALSTL1];
             counter < FRM_DSMAXSTRINGS;
             ++counter, ++ptree) {

            if (counter < numobs) {
                ptree->ob_flags &= ~HIDETREE;
                line = *pwrk++;
                if (*line == 0x7F) {
                    len  = sizechar * strlen(++line);
                    at_x = (pixlen - len) / 2;
                } else {
                    len  = pixlen;
                    at_x = sizechar;
                }
                ptree->ob_spec   = (long)line;
                ptree->ob_x      = at_x;
                ptree->ob_width  = len;

            } else {
                ptree->ob_flags |= HIDETREE;
            }
        }
    }

/*-------------------------------------------------------------------------
 * Handle the FRM_DSHADOWED and FRM_DSL1TITLE options.
 *-----------------------------------------------------------------------*/

    ptree  = dialtree;

    if (options & FRM_DSHADOWED) {
        ptree->ob_state = SHADOWED;
        ptree->ob_spec  = SHADOWED_BOX_SPEC;
    } else {
        ptree->ob_state = OUTLINED;
        ptree->ob_spec  = OUTLINED_BOX_SPEC;
    }

    ptree[DIALSTL1].ob_y =
        (options & FRM_DSL1TITLE) ? l1_title_y : l1_notitle_y;


/*-------------------------------------------------------------------------
 * Do dialog, return button number adjusted to range of 0-4.
 *-----------------------------------------------------------------------*/

    {
        int selection;

        selection = frm_dialog(options, ptree, ROOT);
        return (selection - DIALBX01);

    }
}


