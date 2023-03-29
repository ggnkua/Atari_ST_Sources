/*****************************************************************************
 *
 * Module : MFILE.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 24.07.91
 * Last modification: 28.02.94
 *
 *
 * Description: This module defines the file menu handling.
 *
 * History:
 * 28.02.94: mascexp added
 * 14.10.93: Struct OPENCFG changed
 * 24.07.91: Creation of body
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

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_mfile  _((VOID));
GLOBAL BOOLEAN term_mfile  _((VOID));

GLOBAL VOID    get_opencfg _((VOID));
GLOBAL VOID    set_opencfg _((VOID));

GLOBAL VOID    mnewdb      _((VOID));
GLOBAL VOID    mopendb     _((BYTE *dbname, BOOLEAN auto_cache));
GLOBAL BOOLEAN msave_as    _((WINDOWP window));

GLOBAL VOID    mexport     _((BASE_SPEC *base_spec, BYTE *expname));
GLOBAL VOID    mimport     _((VOID));
GLOBAL VOID    mascexp     _((BASE_SPEC *base_spec, BYTE *expname));
#endif /* __MFILE__ */

