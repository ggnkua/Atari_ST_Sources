/*****************************************************************************
 *
 * Module : DISK.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 16.06.96
 *
 *
 * Description: This module implements the disk icon.
 *
 * History:
 * 16.06.96: Using strcmpi for comparing file names
 * 28.07.94: Printer port calculation corrected
 * 26.07.94: Global variables fs_path and fs_sel used in call to get_open_filename
 * 16.11.93: Using new file selector
 * 04.11.93: Using fontdesc
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "dialog.h"
#include "edit.h"
#include "image.h"
#include "meta.h"
#include "mfile.h"
#include "printer.h"

#include "export.h"
#include "disk.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

/*****************************************************************************/
/* Iconbehandlung                                                            */
/*****************************************************************************/

GLOBAL BOOLEAN icons_disk (src_obj, dest_obj)
WORD src_obj, dest_obj;

{
  FULLNAME filename;
  EXT      ext;
  LONG     filter_index;
  BYTE     *p;

  strcpy (filename, fs_path);

  if ((p = strrchr (filename, PATHSEP)) != EOS)
    p [1] = EOS;

  strcat (filename, fs_sel);

  switch (dest_obj)
  {
    case ITRASH   : filter_index = 0;
                    if (get_open_filename (FDELFILE, NULL, 0L, FFILTER_ALL, &filter_index, NULL, FAILURE, filename, NULL))
                      file_remove (filename);
                    return (TRUE);
    case IPRINTER : if (prncfg.port < PPORT1)
                    {
                      hndl_alert (ERR_NOPORT);
                      return (FALSE);
                    } /* if */

                    filter_index = 3;

                    if (get_open_filename (FPRINTFI, NULL, 0L, FFILTER_IMG_GEM_TXT, &filter_index, NULL, FAILURE, filename, NULL))
                    {
                      file_split (filename, NULL, NULL, NULL, ext);

                      if (strcmpi (ext, FREETXT (FIMGSUFF) + 2) == 0)
                        print_image (filename);
                      else
                        if (strcmpi (ext, FREETXT (FGEMSUFF) + 2) == 0)
                          print_meta (filename);
                        else
                          spool_file (filename, prncfg.port - PPORT1, FALSE, FALSE, prncfg.events_ps, prncfg.bytes_pe);
                    } /* if */
                    return (TRUE);
    default       : return (FALSE);
  } /* switch */
} /* icons_disk */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_disk (obj, menu, icon)
OBJECT *obj, *menu;
WORD   icon;

{
  return (NULL);                        /* Fenster zurckgeben */
} /* crt_disk */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_disk (icon)
WORD icon;

{
  BOOLEAN  ok;
  FULLNAME filename;
  EXT      ext;
  LONG     filter_index;
  BYTE     *p;

  ok           = TRUE;
  filter_index = 4;

  strcpy (filename, fs_path);

  if ((p = strrchr (filename, PATHSEP)) != EOS)
    p [1] = EOS;

  strcat (filename, fs_sel);

  if (get_open_filename (FOPENFIL, NULL, 0L, FFILTER_IND_IMG_GEM_TXT, &filter_index, NULL, FAILURE, filename, NULL))
  {
    file_split (filename, NULL, NULL, NULL, ext);

    if ((strcmpi (ext, FREETXT (FINDSUFF) + 2) == 0) || (strcmp (ext, FREETXT (FDATSUFF) + 2) == 0))
      mopendb (filename, TRUE);
    else
      if (strcmpi (ext, FREETXT (FIMGSUFF) + 2) == 0)
        ok = open_image (NIL, filename);
      else
        if (strcmpi (ext, FREETXT (FGEMSUFF) + 2) == 0)
          ok = open_meta (NIL, filename);
        else
          ok = open_edit (NIL, filename, &fontdesc);
  } /* if */

  return (ok);
} /* open_disk */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_disk (window, icon)
WINDOWP window;
WORD    icon;

{
  hndl_alert (ERR_INFODISK);
  return (TRUE);
} /* info_disk */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_disk (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HIDISK));
} /* help_disk */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_disk ()

{
  return (TRUE);
} /* init_disk */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_disk ()

{
  return (TRUE);
} /* term_disk */

