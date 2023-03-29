/*****************************************************************************/
/*                                                                           */
/* Modul: PRINTER.C                                                          */
/* Datum: 01/11/90                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#if MSDOS
#include <bios.h>
#endif

#include "designer.h"

#include "database.h"

#include "root.h"
#include "dialog.h"

#include "export.h"
#include "printer.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

/*****************************************************************************/
/* Drucker-TestRoutinen                                                      */
/*****************************************************************************/

GLOBAL BOOLEAN prn_ready (port)
WORD port;

{
  WORD ready;

  ready = TRUE;

#if GEMDOS
  switch (port)
  {
    case 0 : ready = Cprnos () != 0; break;
    case 1 : ready = Cauxos () != 0; break;
  } /* switch */
#endif /* GEMDOS */

#if MSDOS
#if TURBO_C
  switch (port)
  {
    case 0 :
    case 1 : ready = biosprint (2, 0, port) == 0x90; break;
    case 2 :
    case 3 : break;
  } /* switch */
#endif /* TURBO_C */

#if MS_C
  switch (port)
  {
    case 0 :
    case 1 : ready = _bios_printer (_PRINTER_STATUS, port, 0) == 0x90; break;
    case 2 :
    case 3 : break;
  } /* switch */
#endif /* MS_C */
#endif /* MSDOS */

  return (ready);
} /* prn_ready */

/*****************************************************************************/

GLOBAL BOOLEAN prn_check (port)
WORD port;

{
  while (! prn_ready (port))
    if (hndl_alert (ERR_PRINTER) == 2) return (FALSE);

  return (TRUE);
} /* prn_check */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_printer ()

{
  return (TRUE);
} /* init_printer */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_printer ()

{
  return (TRUE);
} /* term_printer */

