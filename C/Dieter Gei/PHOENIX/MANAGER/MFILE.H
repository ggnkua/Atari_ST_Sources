/*****************************************************************************
 *
 * Module : MFILE.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.11.93
 *
 *
 * Description: This module defines the file menu.
 *
 * History:
 * 04.11.93: Using fontdesc
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MFILE__
#define __MFILE__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  USERNAME username;            /* username for database */
  PASSWORD password;            /* password for database */
  LONG     treecache;           /* number of kb's for tree chache */
  LONG     datacache;           /* number of kb's for data chache */
  BOOLEAN  treeflush;           /* TRUE, if tree autoflush is on */
  BOOLEAN  dataflush;           /* TRUE, if data autoflush is on */
  WORD     cursors;             /* number of cursors */
  BOOLEAN  rdonly;              /* TRUE, if rdonly is on */
  WORD     mode;                /* singleuser/multitasking/multiuser mode */
} OPENCFG;

/****** VARIABLES ************************************************************/

GLOBAL OPENCFG  opencfg;        /* set of open vars */
GLOBAL FULLNAME open_path;      /* path of database to open */
GLOBAL FILENAME open_name;      /* name of database to open */

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_mfile  _((VOID));
GLOBAL BOOLEAN term_mfile  _((VOID));

GLOBAL VOID    get_opencfg _((VOID));
GLOBAL VOID    set_opencfg _((VOID));

GLOBAL VOID    mopendb     _((BYTE *dbname, BOOLEAN auto_cache));
GLOBAL VOID    mclosedb    _((VOID));

GLOBAL VOID    mopentbl    _((DB *db, WORD table, WORD index, WORD dir, WORD device, FONTDESC *fontdesc, RECT *size, BYTE *filename, BOOLEAN minimize, BOOLEAN use_query));

#endif /* __MFILE__ */

