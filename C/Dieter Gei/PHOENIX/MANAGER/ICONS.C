/*****************************************************************************
 *
 * Module : ICONS.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.12.93
 * Last modification: 31.12.94
 *
 *
 * Description: This module implements the the initialization for common dialog icons.
 *
 * History:
 * 31.12.94: Using new function names of controls module
 * 01.12.93: Creation of body
 *****************************************************************************/

#include "import.h"

#include "global.h"

#include "controls.h"
#include "commdlg.h"

#include "export.h"
#include "icons.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

#include "appm.h"
#include "app1.h"
#include "app4.h"
#include "binm.h"
#include "bin1.h"
#include "bin4.h"
#include "gemm.h"
#include "gem1.h"
#include "gem4.h"
#include "imgm.h"
#include "img1.h"
#include "img4.h"
#include "indm.h"
#include "ind1.h"
#include "ind4.h"
#include "infm.h"
#include "inf1.h"
#include "inf4.h"
#include "prtm.h"
#include "prt1.h"
#include "prt4.h"
#include "txtm.h"
#include "txt1.h"
#include "txt4.h"

LOCAL ICONSUFFIX icon_suffix [] =
{
  {"APP;PRG;AC?;TOS;TTP"},
  {"BIN"},
  {"GEM"},
  {"IMG"},
  {"IND;DAT"},
  {"INF"},
  {"PRT;PRN"},
  {"TXT;ASC;C;DBS;DOC;H;ICO;LST;RPT"}
};

/****** FUNCTIONS ************************************************************/

/*****************************************************************************/

GLOBAL BOOLEAN InitIcons (VOID)
{
  BOOLEAN ok;
  WORD    i;

  ok = TRUE;

  if (gl_hbox > 8)
  {
    i = 0;

    ok &= BuildIcon (&icon_suffix [i  ].icon1, appm, app1);
    ok &= BuildIcon (&icon_suffix [i++].icon4, appm, app4);
    ok &= BuildIcon (&icon_suffix [i  ].icon1, binm, bin1);
    ok &= BuildIcon (&icon_suffix [i++].icon4, binm, bin4);
    ok &= BuildIcon (&icon_suffix [i  ].icon1, gemm, gem1);
    ok &= BuildIcon (&icon_suffix [i++].icon4, gemm, gem4);
    ok &= BuildIcon (&icon_suffix [i  ].icon1, imgm, img1);
    ok &= BuildIcon (&icon_suffix [i++].icon4, imgm, img4);
    ok &= BuildIcon (&icon_suffix [i  ].icon1, indm, ind1);
    ok &= BuildIcon (&icon_suffix [i++].icon4, indm, ind4);
    ok &= BuildIcon (&icon_suffix [i  ].icon1, infm, inf1);
    ok &= BuildIcon (&icon_suffix [i++].icon4, infm, inf4);
    ok &= BuildIcon (&icon_suffix [i  ].icon1, prtm, prt1);
    ok &= BuildIcon (&icon_suffix [i++].icon4, prtm, prt4);
    ok &= BuildIcon (&icon_suffix [i  ].icon1, txtm, txt1);
    ok &= BuildIcon (&icon_suffix [i++].icon4, txtm, txt4);
  } /* if */

  return (ok);
} /* InitIcons */

/*****************************************************************************/

GLOBAL BOOLEAN TermIcons (VOID)
{
  WORD i;

  if (gl_hbox > 8)
    for (i = 0; i < sizeof (icon_suffix) / sizeof (ICONSUFFIX); i++)
    {
      FreeIcon (&icon_suffix [i].icon1);
      FreeIcon (&icon_suffix [i].icon4);
    } /* for, if */

  return (TRUE);
} /* TermIcons */

/*****************************************************************************/

GLOBAL ICONSUFFIX *IconsGetIconSuffixes (VOID)
{
  return (icon_suffix);
} /* IconsGetIconSuffixes */

/*****************************************************************************/

GLOBAL WORD IconsGetNumIconSuffixes (VOID)
{
  return ((gl_hbox <= 8) ? 0 : sizeof (icon_suffix) / sizeof (ICONSUFFIX));
} /* IconsGetNumIconSuffixes */

/*****************************************************************************/
