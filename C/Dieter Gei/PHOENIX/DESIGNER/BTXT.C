/*****************************************************************************
 *
 * Module : BTXT.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 12.06.02
 *
 *
 * Description: This module implements the creating of a text description
 *
 * History:
 * 12.06.02: mdescription: Bei der Auswahl des Dateinamen wird nun FTXTSUFF
 *           statt FHSUFF bergeben.
 * 24.11.93: New file selector box used
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "dialog.h"
#include "export.h"
#include "btxt.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL LONG get_fsize  _((FIELD_INFO *field_info));
LOCAL VOID fflags2str _((UWORD flags, UWORD kflags, STRING s));
LOCAL VOID kflags2str _((UWORD flags, STRING s));

/*****************************************************************************/

GLOBAL VOID mdescription (base_spec)
BASE_SPEC *base_spec;

{
  BOOLEAN    has_multi;
  WORD       table, col, inx, multi;
  WORD       index, abs_inx;
  UWORD      kflags;
  LONG       size;
  STRING     sizestr, flagstr;
  LONGSTR    s;
  EXT        ext;
  FILENAME   name;
  FULLNAME   path, filename;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  INDEX_INFO index_info;
  SYSINDEX   *sysindex;
  FILE       *file;

  strcpy (name, base_spec->basename);
  strcat (name, FREETXT (FTXTSUFF) + 1);
  strcpy (path, base_spec->basepath);

  strcpy (filename, path);
  strcat (filename, name);

  if (! get_save_filename (FTXT, NULL, 0L, FFILTER_TXT, NULL, path, FTXTSUFF, filename, name)) return;

  busy_mouse ();

  file_split (filename, NULL, path, name, ext);
  strcpy (filename, path);
  strcat (filename, name);
  strcat (filename, FREETXT (FTXTSUFF) + 1);

  file = fopen (filename, "w");

  if (file != NULL)
  {
    fprintf (file, "Database: %s\n", base_spec->basename);
    fprintf (file, "\n");

    for (table = base_spec->first_table; table < base_spec->num_tables; table++)
    {
      v_tableinfo (base_spec, table, &table_info);

      fprintf (file, "%s\n", table_info.name);

      for (col = 1; col < table_info.cols; col++)
      {
        v_fieldinfo (base_spec, table, col, &field_info);
        str_type (field_info.type, s);

        kflags = 0;
        index  = find_index (base_spec, table, col);

        if (index != FAILURE)
        {
          abs_inx  = absinx (base_spec, table, index);
          sysindex = &base_spec->sysindex [abs_inx];
          kflags   = sysindex->flags;
        } /* if */

        fflags2str (field_info.flags, kflags, flagstr);

        size = get_fsize (&field_info);
        if (size > 0)
          sprintf (sizestr, "(%ld)", size);
        else
          strcpy (sizestr, "");

        fprintf (file, "  %-20s %-5s %-8s%s\n", field_info.name, s, sizestr, flagstr);
      } /* for */

      has_multi = FALSE;

      for (inx = 1; inx < table_info.indexes; inx++)
      {
        v_indexinfo (base_spec, table, inx, &index_info);
        multi = index_info.inxcols.size / sizeof (INXCOL);
        if (multi > 1) has_multi = TRUE;
      } /* for */

      if (has_multi)
      {
        fprintf (file, "\n  MULTI-INDEXES:\n");

        for (inx = 1; inx < table_info.indexes; inx++)
        {
          v_indexinfo (base_spec, table, inx, &index_info);
          str_type (index_info.type, s);
          kflags2str (index_info.flags, flagstr);
          multi = index_info.inxcols.size / sizeof (INXCOL);

          if (multi > 1)
            if (*flagstr == EOS)
              fprintf (file, "  %-20s %-5s = (%s)\n", index_info.name, s, index_info.indexname);
            else
              fprintf (file, "  %-20s %-5s = (%s), %s\n", index_info.name, s, index_info.indexname, flagstr);
        } /* for */
      } /* if */

      fprintf (file, "----------------------------------------------------------------------\n");
    } /* for */

    fclose (file);
  } /* if */
  else
    file_error (ERR_FILECREATE, filename);

  arrow_mouse ();
} /* mdescription */

/*****************************************************************************/

LOCAL LONG get_fsize (field_info)
FIELD_INFO *field_info;

{
  LONG size;

  switch (field_info->type)
  {
    case TYPE_WORD      :
    case TYPE_LONG      :
    case TYPE_FLOAT     :
    case TYPE_CFLOAT    :
    case TYPE_DATE      :
    case TYPE_TIME      :
    case TYPE_TIMESTAMP :
    case TYPE_DBADDRESS :
    case TYPE_BLOB      : size = 0;                                break;
    case TYPE_EXTERN    :
    case TYPE_CHAR      : size = field_info->size - 1;             break;
    case TYPE_VARBYTE   :
    case TYPE_VARWORD   :
    case TYPE_VARLONG   :
    case TYPE_PICTURE   : size = field_info->size - sizeof (LONG); break;
  } /* switch */

  return (size);
} /* get_fsize */

/*****************************************************************************/

LOCAL VOID fflags2str (flags, kflags, s)
UWORD  flags, kflags;
STRING s;

{
  WORD   len;
  STRING ks;

  strcpy (s, "");

  if (flags & COL_MANDATORY) strcat (s, "MANDATORY, ");
  if (flags & COL_OUTPUT)    strcat (s, "OUTPUT, ");
  if (flags & COL_NMODIFY)   strcat (s, "NOT MODIFY, ");
  if (flags & COL_LOOKUP)    strcat (s, "LOOKUP, ");
  if (flags & COL_DEFAULT)   strcat (s, "DEFAULT, ");
  if (flags & COL_ISINDEX)   strcat (s, "INDEX, ");

  kflags2str (kflags, ks);
  strcat (s, ks);

  len = strlen (s) - 2;                                 /* comma + ' ' */
  if ((len >= 0) && (s [len] == ',')) s [len] = EOS;    /* delete "," */
} /* fflags2str */

/*****************************************************************************/

LOCAL VOID kflags2str (flags, s)
UWORD  flags;
STRING s;

{
  WORD len;

  strcpy (s, "");

  if (flags & INX_UNIQUE)  strcat (s, "UNIQUE, ");
  if (flags & INX_PRIMARY) strcat (s, "PRIMARY, ");
  if (flags & INX_FOREIGN) strcat (s, "FOREIGN, ");
  if (flags & INX_DIRTY)   strcat (s, "DIRTY, ");
  if (flags & INX_REORG)   strcat (s, "REORG, ");

  len = strlen (s) - 2;         /* comma + ' ' */
  if (len >= 0) s [len] = EOS;  /* delete "," */
} /* kflags2str */
