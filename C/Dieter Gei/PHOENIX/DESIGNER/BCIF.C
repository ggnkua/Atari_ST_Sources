/*****************************************************************************
 *
 * Module : BCIF.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 24.11.93
 *
 *
 * Description: This module implements the creating of a C-Interface
 *
 * History:
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
#include "bcif.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID type2str _((WORD type, FIELDNAME name, LONG size, BYTE *str));

/*****************************************************************************/

GLOBAL VOID mcinterface (base_spec)
BASE_SPEC *base_spec;

{
  WORD       table, col;
  LONGSTR    s;
  EXT        ext;
  FILENAME   name;
  FULLNAME   path, filename;
  FILE       *file;
  TABLE_INFO table_info;
  FIELD_INFO field_info;

  strcpy (name, base_spec->basename);
  strcat (name, FREETXT (FHSUFF) + 1);
  strcpy (path, base_spec->basepath);

  strcpy (filename, path);
  strcat (filename, name);

  if (! get_save_filename (FCIF, NULL, 0L, FFILTER_H, NULL, path, FHSUFF, filename, name)) return;

  busy_mouse ();

  file_split (filename, NULL, path, name, ext);
  strcpy (filename, path);
  strcat (filename, name);
  strcat (filename, FREETXT (FHSUFF) + 1);

  file = fopen (filename, "w");

  if (file != NULL)
  {
    fprintf (file, "/* PHOENIX System C-Interface */\n");
    fprintf (file, "/* Database: %s */\n", base_spec->basename);
    fprintf (file, "\n");

    for (table = base_spec->first_table; table < base_spec->num_tables; table++)
    {
      v_tableinfo (base_spec, table, &table_info);
      fprintf (file, "#define TBL_%-16s %2d\n", table_info.name, table);
    } /* for */

    fprintf (file, "\n");

    for (table = base_spec->first_table; table < base_spec->num_tables; table++)
    {
      v_tableinfo (base_spec, table, &table_info);
      str_ascii (table_info.name);

      fprintf (file, "typedef struct\n");
      fprintf (file, "{\n");

      for (col = 0; col < table_info.cols; col++)
      {
        v_fieldinfo (base_spec, table, col, &field_info);
        str_ascii (field_info.name);
        type2str (field_info.type, field_info.name, field_info.size, s);
        fprintf (file, "  %-32s /* %5ld */\n", s, field_info.addr);
      } /* for */

      fprintf (file, "} %s;\n\n", table_info.name);
    } /* for */

    fclose (file);
  } /* if */
  else
    file_error (ERR_FILECREATE, filename);

  arrow_mouse ();
} /* mcinterface */

/*****************************************************************************/

LOCAL VOID type2str (type, name, size, str)
WORD      type;
FIELDNAME name;
LONG      size;
BYTE      *str;

{
  size = (size + 1) & 0xFFFFFFFEL;

  switch (type)
  {
    case TYPE_CHAR      :
    case TYPE_CFLOAT    :
    case TYPE_EXTERN    : sprintf (str, "BYTE      %s [%ld];", name, size); break;
    case TYPE_WORD      : sprintf (str, "WORD      %s;", name);             break;
    case TYPE_LONG      :
    case TYPE_DBADDRESS : sprintf (str, "LONG      %s;", name);             break;
    case TYPE_FLOAT     : sprintf (str, "DOUBLE    %s;", name);             break;
    case TYPE_DATE      : sprintf (str, "DATE      %s;", name);             break;
    case TYPE_TIME      : sprintf (str, "TIME      %s;", name);             break;
    case TYPE_TIMESTAMP : sprintf (str, "TIMESTAMP %s;", name);             break;
    case TYPE_VARBYTE   :
    case TYPE_VARWORD   :
    case TYPE_VARLONG   :
    case TYPE_PICTURE   : sprintf (str, "UBYTE     %s [%ld];", name, size); break;
    case TYPE_BLOB      : sprintf (str, "BLOB      %s;", name, size);       break;
    default             : sprintf (str, "BYTE      %s [%ld];", name, size); break;
  } /* switch */
} /* type2str */

