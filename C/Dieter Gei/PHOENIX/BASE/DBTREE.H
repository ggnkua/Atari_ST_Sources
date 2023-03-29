/*****************************************************************************
 *
 * Module : DBTREE.H
 * Author : Dieter Geiﬂ
 *
 * Creation date    : 01.07.89
 * Last modification: 04.11.92
 *
 *
 * Description: This module defines the database tree routines.
 *
 * History:
 * 04.11.92: Modifications for NT added
 * 31.10.92: Far pointer definitions for DLL implementation added
 * 29.10.92: FHANDLE changed to HFILE
 * 25.10.92: Module header added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef _DBTREE_H
#define _DBTREE_H

#ifdef __cplusplus
extern "C" {
#endif

/****** DEFINES **************************************************************/

#define PAGESIZE      512       /* size of a page */
#define MAX_KEYSIZE    82       /* max size of a key */

#define TREE_ENCODE   0x0001    /* encode/decode (on create) */

#define TREE_MULUSER  0x0001    /* multiuser operation */
#define TREE_FLUSH    0x0002    /* flush virtual pages on write */
#define TREE_MULTASK  0x0004    /* multitasking operation */
#define TREE_RDONLY   0x0008    /* read only mode */

#define CURS_USED     0x0001    /* key of cursor is in use */
#define CURS_DELETED  0x0002    /* key of cursor has just been deleted */

#define ASCENDING     1         /* ascending order */
#define DESCENDING    (-1)      /* descending order */

/****** TYPES ****************************************************************/

typedef UCHAR PAGE [PAGESIZE];
typedef PAGE HUGE *PAGEP;

#ifdef WIN32
#pragma pack(2)
#endif

typedef struct
{
  USHORT flags;                 /* flags for operation */
  LONG   num_pages;             /* number of pages */
  LONG   used_pages;            /* number of used pages */
  LONG   free_page;             /* number of first free page */
  LONG   rlsd_page;             /* number of first released page */
} PAGE0;

#ifdef WIN32
#pragma pack()
#endif

typedef struct
{
  SHORT type;                   /* type of key */
  LONG  root;                   /* number of root page */
  LONG  num_keys;               /* number of actual entries */
} KEY_DFN;

typedef KEY_DFN HUGE *HPKEY_DFN;

typedef struct
{
  LONG  time;                   /* last time used (LRU) */
  BOOL  dirty;                  /* modified since last write */
  LONG  pagenum;                /* real page number */
  UCHAR *vpage;                 /* pointer to virtual page */
} VPAGEINF;

typedef VPAGEINF HUGE *VPAGEINFP;

typedef struct cursor *CURSORP; /* pointer to cursor for recurse */

typedef struct
{
  HFILE     handle;             /* file handle for trees */
  USHORT    flags;              /* flags for operating trees */
  PAGE0     page0;              /* page 0 information */
  LONG      vtime;              /* virtual time for LRU strategy */
  LONG      num_vpages;         /* number of virtual pages */
  VPAGEINFP vpageinf;           /* pointer to virtual page info */
  PAGEP     vpages;             /* pointer to virtual pages */
  SHORT     num_cursors;        /* number of cursors */
  CURSORP   cursors;            /* pointer to cursors */
  LONG      num_calls;          /* number of calls to virtual page test */
  LONG      num_hits;           /* number of hits (virtual page found) */
} TREEINF;

typedef TREEINF FAR *LPTREEINF; /* pointer to tree information */

typedef struct cursor
{
  LPTREEINF tree;               /* tree of cursor */
  SHORT     type;               /* key type */
  LONG      pagenum;            /* actual page number */
  SHORT     inx;                /* actual index */
  USHORT    flags;              /* flags of cursor */
  LONG      pos;                /* record position for virtual tables */
  CURSORP   next;               /* pointer to next cursor for join */
} CURSOR;

typedef CURSOR FAR *LPCURSOR;   /* pointer to cursor */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL LPTREEINF WINAPI create_tree   _((LPSTR filename, USHORT flags, LONG size));
GLOBAL LPTREEINF WINAPI open_tree     _((LPSTR filename, USHORT flags, LONG cache_size, SHORT num_cursors));
GLOBAL BOOL      WINAPI close_tree    _((LPTREEINF tree));

GLOBAL BOOL      WINAPI insert_key    _((LPTREEINF tree, HPVOID keyval, LONG data, HPKEY_DFN kd));
GLOBAL BOOL      WINAPI delete_key    _((LPTREEINF tree, HPVOID keyval, LONG data, HPKEY_DFN kd));
GLOBAL BOOL      WINAPI search_key    _((LPTREEINF tree, SHORT dir, LPCURSOR cursor, HPVOID keyval, LONG data, HPKEY_DFN kd, BOOL use_wildcards));
GLOBAL BOOL      WINAPI update_key    _((LPTREEINF tree, HPVOID keyval, LONG data, LONG newdata, HPKEY_DFN kd));

GLOBAL LPCURSOR  WINAPI new_cursor    _((LPTREEINF tree));
GLOBAL VOID      WINAPI free_cursor   _((LPCURSOR cursor));
GLOBAL BOOL      WINAPI init_cursor   _((LPTREEINF tree, SHORT dir, HPKEY_DFN kd, LPCURSOR cursor));
GLOBAL BOOL      WINAPI move_cursor   _((LPCURSOR cursor, LONG steps));
GLOBAL LONG      WINAPI read_cursor   _((LPCURSOR cursor, HPVOID keyval));
GLOBAL BOOL      WINAPI test_cursor   _((LPCURSOR cursor, SHORT dir, HPVOID keyval));
GLOBAL LONG      WINAPI locate_addr   _((LPCURSOR cursor, SHORT dir, LONG addr));
GLOBAL BOOL      WINAPI is_firstlast  _((LPCURSOR cursor, BOOL first));

GLOBAL BOOL      WINAPI kill_virtual  _((LPTREEINF tree));
GLOBAL BOOL      WINAPI flush_virtual _((LPTREEINF tree));

GLOBAL BOOL      WINAPI kill_tree     _((LPTREEINF tree, LONG root));
GLOBAL BOOL      WINAPI expand_tree   _((LPTREEINF tree, LONG size));

#ifdef __cplusplus
}
#endif

#endif /* _DBTREE_H */

