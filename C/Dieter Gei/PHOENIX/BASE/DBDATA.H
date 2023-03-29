/*****************************************************************************
 *
 * Module : DBDATA.H
 * Author : Jürgen & Dieter Geiß
 *
 * Creation date    : 01.07.89
 * Last modification: 18.07.93
 *
 *
 * Description: This module defines the database data routines.
 *
 * History:
 * 18.07.93: Cache added
 * 09.06.93: Component multi_locked in page 0 added
 * 09.05.93: DATA_USELOG and DATA_NOLOG added
 * 15.11.92: Macro FIRST_VERSION added
 * 14.11.92: SHORTFUNC renamed to LOCKFUNC
 * 07.11.92: Version number added in read_data
 * 04.11.92: Page zero variabled added for reading locked record
 * 31.10.92: Far pointer definitions for DLL implementation added
 * 29.10.92: FHANDLE changed to HFILE
 * 25.10.92: Module header added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef _DBDATA_H
#define _DBDATA_H

#ifdef __cplusplus
extern "C" {
#endif

/****** DEFINES **************************************************************/

#define DB_VERSION    0x0200    /* version number 2.00 */

#define FIRST_REC     1024L     /* first record is stored at address 1024 */
#define FIRST_VERSION 1L        /* first version number of a new inserted record */

#define DATA_ENCODE   0x0100    /* encode/decode (on create), low byte used by tree */
#define DATA_CLOSED   0x0200    /* set if data file was closed correctly */
#define DATA_USELOG   0x0400    /* use data logging */

#define DATA_MULUSER  0x0100    /* multiuser operation (on opening) */
#define DATA_MULTASK  0x0200    /* multitasking operation (on opening) */
#define DATA_RDONLY   0x0400    /* read only mode */
#define DATA_NOLOG    0x0800    /* don't use logging temporarily */
#define DATA_FLUSH    0x1000    /* flush data on write */

#define DATA_OK       0x0000    /* status for one record, record OK */
#define DATA_INDIRECT 0x0001    /* value of indirect points to moved record */
#define DATA_MOVED    0x0002    /* indicates a moved record */
#define DATA_DELETED  0x0004    /* indicates a deleted record */
#define DATA_CRYPTED  0x0008    /* indicates a crypted (encoded) record */

#ifdef _WINDOWS
#define LOCK_RETRY    IDRETRY   /* retry locking */
#define LOCK_IGNORE   IDIGNORE  /* ignore locking */
#define LOCK_CANCEL   IDCANCEL  /* cancel locking */
#else
#define LOCK_RETRY    1         /* retry locking */
#define LOCK_IGNORE   2         /* ignore locking */
#define LOCK_CANCEL   3         /* cancel locking */
#endif

/****** TYPES ****************************************************************/

typedef INT (CALLBACK *LOCKFUNC) _((BOOL lock));

typedef struct
{
  USHORT    locking;            /* multiuser/multitasking locking word */
  USHORT    flags;              /* flags for operation */
  USHORT    version;            /* db version 0x0100 = 1.00 */
  USHORT    fieldsize;          /* records are stored in multiples of fieldsize */
  LONG      multi_vers;         /* version number for multiuser */
  LONG      file_size;          /* filesize of allocated datafile */
  LONG      next_rec;           /* pointer where next record will be stored */
  LONG      addr_table;         /* address of first record of SYS_TABLE */
  LONG      addr_column;        /* address of first record of SYS_COLUMN */
  LONG      addr_index;         /* address of first record of SYS_INDEX */
  LONG      root_table;         /* root block of primary key of SYS_TABLE */
  LONG      root_column;        /* root block of primary key of SYS_COLUMN */
  LONG      root_index;         /* root block of primary key of SYS_INDEX */
  LONG      size_released;      /* size of released space of FIRST_REC..next_rec */
  TIMESTAMP created;            /* creation date & time */
  TIMESTAMP lastuse;            /* date & time of last use */
  SHORT     reorg;              /* TRUE <=> database must be reorganized */
  USHORT    opened;             /* number of times database has been opened without closing */
  TIME      time;               /* creation time for encoding */
  SHORT     dfn_offset;         /* offset to data_dfn */
  SHORT     dfn_size;           /* size of data_dfn in this version */
  USHORT    multi_locked;       /* number of multiuser locks */
  CHAR      filler [678];       /* filler */
  UCHAR     tbl_ascii [256];    /* convert table for move to ascii letters */
} DPAGE0;

typedef DPAGE0 FAR *LPDPAGE0;   /* pointer to page zero information */

typedef struct
{
  LONG  indirect;               /* if data has been moved, points to data */
  LONG  recsize;                /* size of this record */
  LONG  free;                   /* free size in this field */
  SHORT table;                  /* tablenumber of this record */
  SHORT status;                 /* status for this record */
  LONG  version;                /* version of record (for optimistic locking) */
  CHAR  data [2];               /* data itself (2 is dummy) */
} DATA_DFN;

typedef DATA_DFN FAR *LPDATA_DFN; /* pointer to data information */

typedef struct
{
  HFILE   handle;               /* file handle for data */
  USHORT  flags;                /* flags for operating datafile */
  SHORT   locked;               /* number of times databse has been locked (beginning transaction) */
  LONG    cache_size;           /* cache size */
  LONG    cache_seekpos;        /* cache seek position */
  LONG    cache_low;            /* low writing pos */
  LONG    cache_high;           /* high writing pos */
  HPUCHAR cache_memory;         /* cache memory */
  LONG    num_calls;            /* number of calls to read from cache */
  LONG    num_hits;             /* number of hits in cache */
  DPAGE0  page0;                /* page 0 information */
} DATAINF;

typedef DATAINF FAR *LPDATAINF; /* pointer to data information */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID      WINAPI init_data     _((LOCKFUNC lock));

GLOBAL LPDATAINF WINAPI create_data   _((LPSTR filename, USHORT flags, LONG size));
GLOBAL LPDATAINF WINAPI open_data     _((LPSTR filename, USHORT flags, LONG cache_size));
GLOBAL BOOL      WINAPI close_data    _((LPDATAINF data));
GLOBAL BOOL      WINAPI flush_data    _((LPDATAINF data));

GLOBAL LONG      WINAPI insert_data   _((LPDATAINF data, SHORT table, LONG size, HPVOID buffer, BOOL encode));
GLOBAL BOOL      WINAPI delete_data   _((LPDATAINF data, LONG address));
GLOBAL BOOL      WINAPI undelete_data _((LPDATAINF data, LONG address));
GLOBAL BOOL      WINAPI update_data   _((LPDATAINF data, SHORT table, LONG size, HPVOID buffer, BOOL encode, LONG address));
GLOBAL LONG      WINAPI read_data     _((LPDATAINF data, LONG address, HPVOID buffer, LPSHORT table, LPLONG size, LPLONG version, LPBOOL deleted, LPBOOL moved));

GLOBAL BOOL      WINAPI test_multi    _((LPDATAINF data, BOOL do_write));
GLOBAL BOOL      WINAPI read_dpg0     _((LPDATAINF data));
GLOBAL BOOL      WINAPI write_dpg0    _((LPDATAINF data));
GLOBAL BOOL      WINAPI db_lock       _((LPDATAINF data));
GLOBAL BOOL      WINAPI db_unlock     _((LPDATAINF data));
GLOBAL BOOL      WINAPI read_dfn      _((LPDATAINF data, LONG address, LPDATA_DFN data_dfn, LPDATA_DFN data_idfn));
GLOBAL BOOL      WINAPI write_dfn     _((LPDATAINF data, LONG address, LPDATA_DFN data_dfn));

GLOBAL BOOL      WINAPI expand_data   _((LPDATAINF data, LONG size));
GLOBAL BOOL      WINAPI inc_released  _((LPDATAINF data, LONG address));

#ifdef __cplusplus
}
#endif

#endif /* _DBDATA_H */

