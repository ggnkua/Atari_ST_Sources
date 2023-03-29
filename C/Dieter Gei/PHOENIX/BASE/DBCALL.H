/*****************************************************************************
 *
 * Module : DBCALL.H
 * Author : Dieter Geiﬂ
 *
 * Creation date    : 01.07.89
 * Last modification: 03.11.96
 *
 *
 * Description: This module defines the database call routines.
 *
 * History:
 * 03.11.96: SYS_PICTURE added
 * 16.06.96: Suffixes are lowercase now
 * 24.04.96: MAX_REPORT increased
 * 05.06.95: SYS_ACCOUNT added
 * 15.12.94: Flags REL_11, REL_1N added
 * 19.03.94: Flag TBL_HIDDEN added
 * 30.12.93: First parameter in REORGFUNC is INT
 * 21.12.93: Callback function in db_reorg and db_reorg_cache added
 * 20.07.93: db_open_cache and db_reorg_cache added
 * 26.05.93: MAX_MASK changed to 16384
 * 10.05.93: Definitions for logfile added
 * 15.02.93: db_getstr and db_setstr added
 * 14.02.93: MAX_BASENAME is now MAX_FULLNAME
 * 18.11.92: Function db_reorg added
 * 15.11.92: Funtions db_acc_... returning USHORT
 * 14.11.92: SHORTFUNC renamed to LOCKFUNC
 * 09.11.92: Optimistic locking added
 * 03.11.92: Modifications for NT added
 * 31.10.92: Far pointer definitions for DLL implementation added
 * 25.10.92: Module header added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef _DBCALL_H
#define _DBCALL_H

#ifdef __cplusplus
extern "C" {
#endif

/****** DEFINES **************************************************************/

#define DATA_SUFF       "dat"   /* suffix of data file */
#define TREE_SUFF       "ind"   /* suffix of index file */
#define LOG_SUFF        "log"   /* suffix of log file */

#define BASE_ENCODE     (DATA_ENCODE | TREE_ENCODE)
#define BASE_USELOG     (DATA_USELOG)
#define BASE_MULUSER    (DATA_MULUSER | TREE_MULUSER)
#define BASE_MULTASK    (DATA_MULTASK | TREE_MULTASK)
#define BASE_RDONLY     (DATA_RDONLY | TREE_RDONLY)
#define BASE_NOLOG      (DATA_NOLOG)
#define BASE_FLUSH      (DATA_FLUSH | TREE_FLUSH)
#define BASE_SUPER      0x8000	/* supervisor flag for modifying SYS_USER */

#define MAX_USERNAME    33      /* max chars in username */
#define MAX_PASSWORD    33      /* max chars in password */

#define MAX_BASENAME    MAX_FULLNAME /* max chars of a database */
#define MAX_BASEPATH    MAX_FULLNAME /* max chars of a database path */

#define MAX_TABLENAME   33      /* max chars of a table name */
#define MAX_FIELDNAME   33      /* max chars of a fieldname */
#define MAX_INDEXNAME   81      /* max chars of an indexname */

#define BITMAPSIZE     196      /* number of bytes in one bitmap */

#if MSDOS | NT
#define ICONSIZE       354      /* number of words in one icon */
#else
#define ICONSIZE       256      /* number of words in one icon */
#endif

#define MAX_INXCOLS     16      /* max cols for multiple indexes in sysindex */
#define MAX_ACCESS     512      /* number of words in access list */
#define MAX_TCALC     8191      /* text definition of calc buffer */
#define MAX_CCALC     8192      /* compiled code of calc text buffer */
#define MAX_MASK     16384      /* buffer size for one mask definition */
#define MAX_QUERY     4095      /* buffer size for one query definition */
#define MAX_REPORT   32765      /* buffer size for one report definition */
#define MAX_BATCH     8191      /* buffer size for one batch definition */

#define SYS_TABLE        0      /* system tables */
#define SYS_COLUMN       1      /* system columns */
#define SYS_INDEX        2      /* system indexes */
#define SYS_REL          3      /* system relations */
#define SYS_USER         4      /* system users */
#define SYS_DELETED      5      /* system deleted records */
#define SYS_ICON         6      /* system icons for tables */
#define SYS_TATTR        7      /* system table attributes */
#define SYS_FORMAT       8      /* system format definitions */
#define SYS_LOOKUP       9      /* system lookup values */
#define SYS_CALC        10      /* system calculation formulas */
#define SYS_MASK        11      /* system mask definitions */
#define SYS_QUERY       12      /* system query definitions */
#define SYS_REPORT      13      /* system report definitions */
#define SYS_BATCH       14      /* system batch definitions */
#define SYS_BLOB        15      /* system variable BLOB header */
#define SYS_ACCOUNT     16      /* system account */
#define SYS_PICTURE     17      /* system picure */
#define SYS_DUMMY18     18      /* system dummy as placeholder */
#define SYS_DUMMY19     19      /* system dummy as placeholder */

#define NUM_SYSTABLES   20      /* number of system tables */

#define GRANT_NOTHING   0x0000  /* user may do nothing */
#define GRANT_INSERT    0x0001  /* user may insert column */
#define GRANT_DELETE    0x0002  /* user may delete column */
#define GRANT_UPDATE    0x0004  /* user may update column */
#define GRANT_SELECT    0x0008  /* user may select column */
#define GRANT_ALL       0x000F  /* user may do everything */

#define TBL_MTONREL     0x0010  /* used for m to n entity relationship */
#define TBL_FIXRECSIZE  0x0020  /* set if record size is not variable */
#define TBL_VISIBLE     0x0040  /* system table is visible to user (calc etc.) */
#define TBL_LOGGED      0x0080  /* table will be logged in log file */
#define TBL_HIDDEN      0x0100  /* table will not be shown in toolbox (e.g. lookup table) */

#define COL_ISINDEX     0x0010  /* column is (single) key field */
#define COL_MANDATORY   0x0020  /* user must enter a value */
#define COL_OUTPUT      0x0040  /* column is for output only */
#define COL_NMODIFY     0x0080  /* once entered, user can't modify */
#define COL_LOOKUP      0x0100  /* lookup table available (see SYSLOOKUP) */
#define COL_DEFAULT     0x0200  /* set default values if NULL */

#define INX_NONE        0x0000  /* no flags */
#define INX_UNIQUE      0x0001  /* unique key */
#define INX_PRIMARY     0x0002  /* primary key */
#define INX_FOREIGN     0x0004  /* foreign key */
#define INX_DIRTY       0x0008  /* index has changed */
#define INX_REORG       0x0010  /* index has to be reorganized */

#define REL_NONE        0       /* integrity rule: none */
#define REL_RESTRICTED  1       /* integrity rule: restricted */
#define REL_CASCADED    2       /* integrity rule: cascaded */
#define REL_SETNULL     3       /* integrity rule: set to null */

#define REL_11          0x0001  /* relation type in sysrel.flags: 1 to 1 */
#define REL_1N          0x0002  /* relation type in sysrel.flags: 1 to many */

#define USER_READONLY   0x0001  /* user may read database only */

#define BLOB_OLE        0x0001  /* sysblob is OLE object */

#define LOG_VERSION     0x0100  /* log version 1.0 */

#define LOG_INSERT      0       /* log operation insert */
#define LOG_DELETE      1       /* log operation delete */
#define LOG_UNDELETE    2       /* log operation undelete */
#define LOG_UPDATE      3       /* log operation update */

#define LOG_FLAG_NONE   0x0000  /* don't use any further information */
#define LOG_FLAG_NUMBER 0x0001  /* use table number */
#define LOG_FLAG_NAME   0x0002  /* use table name */
#define LOG_FLAG_USER   0x0004  /* use user name */
#define LOG_FLAG_TIME   0x0008  /* use timestamp of modification */
#define LOG_FLAG_ENCODE 0x0010  /* encode information */

#define REORG_MAXRECS   0       /* max number of records to reorg */
#define REORG_ACTREC    1       /* actual record number */

/****** TYPES ****************************************************************/

typedef CHAR USERNAME [MAX_USERNAME + 1];
typedef CHAR PASSWORD [MAX_PASSWORD + 1];

typedef CHAR BASENAME [MAX_BASENAME + 1];
typedef CHAR BASEPATH [MAX_BASEPATH + 1];

typedef CHAR TABLENAME [MAX_TABLENAME + 1];
typedef CHAR FIELDNAME [MAX_FIELDNAME + 1];
typedef CHAR INDEXNAME [MAX_INDEXNAME + 1];

typedef CHAR KEY [MAX_KEYSIZE];

typedef CHAR CALCTEXT [MAX_TCALC + 1];
typedef CHAR FORMATSTR [MAX_FORMATSTR + 1];
typedef CHAR QUERYDEF [MAX_QUERY + 1];
typedef CHAR REPORTDEF [MAX_REPORT + 1];
typedef CHAR BATCHDEF [MAX_BATCH + 1];
typedef CHAR DEVSIZE [2];

#ifdef WIN32
#pragma pack(2)
#endif

typedef struct
{
  SHORT col;                    /* column of index */
  SHORT len;                    /* significant length of index if char */
} INXCOL;

typedef struct
{
  LONG   size;                  /* actual size of elements in bytes */
  INXCOL cols [MAX_INXCOLS];    /* cols and length of indexes */
} INXCOLS;

typedef struct
{
  LONG  size;
  SHORT list [MAX_ACCESS];      /* list of access rights */
} ACCESSDEF;

typedef struct
{
  LONG  size;
  SHORT icondef [ICONSIZE];     /* icon for systable (data & mask) */
} ICONDEF;

typedef struct
{
  LONG  size;
  UCHAR bitmapdef [BITMAPSIZE]; /* bitmap for systable */
} BITMAPDEF;

typedef struct
{
  LONG size;
  CHAR buffer [MAX_CCALC];      /* buffer for code of calculation */
} CALCCODE;

typedef CALCCODE FAR *LPCALCCODE; /* pointer to calccode */

typedef struct
{
  LONG size;
  CHAR buffer [MAX_MASK];       /* buffer for mask definition */
} MASKDEF;

typedef struct
{
  LONG      address;            /* address of record */
  SHORT     table;              /* number of table */
  TABLENAME name;               /* name of table */
  LONG      recs;               /* number of records */
  SHORT     cols;               /* number of columns */
  SHORT     indexes;            /* number of indexes */
  LONG      size;               /* size of one record */
  SHORT     color;              /* color of table */
  SHORT     icon;               /* icon for table */
  SHORT     children;           /* number of dependent tables */
  SHORT     parents;            /* number of parent tables */
  USHORT    flags;              /* flags of table */
} SYSTABLE;

typedef struct
{
  LONG      address;            /* address of record */
  SHORT     table;              /* number of table */
  SHORT     number;             /* number of column in table */
  FIELDNAME name;               /* name of column */
  SHORT     type;               /* type of column */
  LONG      addr;               /* address in record */
  LONG      size;               /* size of column */
  SHORT     format;             /* format of column */
  USHORT    flags;              /* flags of column */
} SYSCOLUMN;

typedef struct
{
  LONG      address;            /* address of record */
  SHORT     table;              /* number of table */
  SHORT     number;             /* number of index in table */
  FIELDNAME name;               /* name of index */
  SHORT     type;               /* type of index */
  LONG      root;               /* root page number */
  LONG      num_keys;           /* number of actual keys */
  INXCOLS   inxcols;            /* column numbers of (multiple) indexes */
  USHORT    flags;              /* flags of index */
} SYSINDEX;

typedef struct
{
  LONG   address;               /* address of record */
  SHORT  reftable;              /* referenced (parent) table of foreign key */
  SHORT  refindex;              /* referenced index (primary key) */
  SHORT  reltable;              /* dependent table of relation */
  SHORT  relindex;              /* dependent index of relation (foreign key) */
  SHORT  insrule;               /* insert rule */
  SHORT  delrule;               /* delete rule */
  SHORT  updrule;               /* update rule */
  USHORT flags;                 /* flags of relation */
} SYSREL;

typedef struct
{
  LONG      address;            /* address of record */
  USERNAME  name;               /* user name */
  PASSWORD  pass;               /* password of user */
  LONG      count;              /* number of uses */
  TIMESTAMP lastuse;            /* date & time of last use */
  ACCESSDEF access;             /* table & column access list */
  USHORT    flags;              /* flags of user */
} SYSUSER;

typedef struct
{
  LONG  address;                /* address of record */
  LONG  del_addr;               /* address of deleted record */
  SHORT table;                  /* table of deleted record */
} SYSDELETED;

typedef struct
{
  LONG      address;            /* address of record */
  SHORT     number;             /* number of icon */
  SHORT     width;              /* width of icon in pixels */
  SHORT     height;             /* height of icon in pixels */
  ICONDEF   icon;               /* icon for table */
  BITMAPDEF bitmap;		/* bitmap for table */
  USHORT    flags;              /* flags of icon */
} SYSICON;

typedef struct
{
  LONG   address;               /* address of record */
  SHORT  table;                 /* number of table */
  SHORT  x;                     /* x-coordinate */
  SHORT  y;                     /* y-coordinate */
  SHORT  width;                 /* width of box */
  SHORT  height;                /* height of box */
  USHORT flags;                 /* flags of table attributes */
} SYSTATTR;

typedef struct
{
  LONG      address;            /* address of record */
  SHORT     number;             /* number of format */
  SHORT     type;               /* type of field of format */
  FORMATSTR format;             /* format string */
  USHORT    flags;              /* flags of format */
} SYSFORMAT;

typedef struct
{
  LONG   address;               /* address of record */
  SHORT  table;                 /* destination table */
  SHORT  column;                /* destination column */
  SHORT  reftable;              /* referenced table */
  SHORT  refcolumn;             /* referenced column */
  USHORT flags;                 /* flags of lookup */
} SYSLOOKUP;

typedef struct
{
  LONG      address;            /* address of record */
  TABLENAME tablename;          /* table name of calculation */
  FIELDNAME name;               /* name of calculation */
  CALCTEXT  text;               /* text of calculation */
  CALCCODE  code;               /* code of calculation */
  USHORT    flags;              /* flags of calculation */
} SYSCALC;

typedef SYSCALC FAR *LPSYSCALC; /* pointer to syscalc */

typedef struct
{
  LONG      address;            /* address of record */
  DEVSIZE   device;             /* device: S = screen, P = printer etc. */
  FIELDNAME name;               /* name of mask */
  TABLENAME tablename;          /* table name of mask */
  USERNAME  username;           /* user name of mask */
  USHORT    flags;              /* flags of mask definition */
  MASKDEF   mask;               /* mask definition */
  SHORT     version;            /* version of mask */
  FIELDNAME calcentry;          /* name of calculation at entry time of record */
  FIELDNAME calcexit;           /* name of calculation at exit time of record */
  SHORT     x;			/* x starting position */
  SHORT     y;			/* y starting position */
  SHORT     w;			/* w starting position */
  SHORT     h;			/* h starting position */
  LONG      bkcolor;		/* background color */
} SYSMASK;

typedef struct
{
  LONG      address;            /* address of record */
  FIELDNAME name;               /* name of query */
  QUERYDEF  query;              /* query definition */
} SYSQUERY;

typedef struct
{
  LONG      address;            /* address of record */
  FIELDNAME name;               /* name of report */
  REPORTDEF report;             /* report definition */
} SYSREPORT;

typedef struct
{
  LONG      address;            /* address of record */
  FIELDNAME name;               /* name of report */
  BATCHDEF  batch;              /* batch definition */
} SYSBATCH;

typedef struct
{
  LONG     address;             /* address of record */
  LONG     size;                /* actual size of blob */
  BLOBEXT  ext;                 /* file extension of blob */
  BLOBNAME name;                /* name of blob */
  USHORT   flags;               /* flags of blob */
  UCHAR    blob [2];            /* 2 bytes minimum, please use dynamically allocated memory */
} SYSBLOB;

typedef SYSBLOB FAR *LPSYSBLOB; /* pointer to sysblob */

typedef struct
{
  LONG      address;            /* address of record */
  FIELDNAME name;               /* name of report */
  BLOB      account;            /* account definition */
} SYSACCOUNT;

typedef struct
{
  LONG      address;            /* address of record */
  FIELDNAME name;               /* name of picture */
  BLOB      picture;            /* picture itself */
  USHORT    flags;              /* flags of picture */
} SYSPICTURE;

typedef struct
{
  SHORT column;                 /* "pointer" to first record in syscolumn of given table */
  SHORT index;                  /* "pointer" to first record in sysindex of given table */
} SYSPTR;

typedef struct
{
  SHORT size;                   /* size of header */
  SHORT version;                /* version of next log record */
  SHORT operation;              /* log operation */
  SHORT flags;                  /* log flags */
} LOGHEADER;

typedef LOGHEADER FAR *LPLOGHEADER;     /* pointer to log header */

#ifdef WIN32
#pragma pack()
#endif

typedef struct
{
  DATAINF   *datainf;           /* pointer to data information */
  TREEINF   *treeinf;           /* pointer to tree information */
  USERNAME  username;           /* name of user which opened database */
  BASENAME  basename;           /* name of database */
  BASEPATH  basepath;           /* path of database */
  SHORT     status;             /* last error status */
  SHORT     systbls;            /* number of systables in memory */
  SHORT     syscols;            /* number of syscolums in memory */
  SHORT     sysinxs;            /* number of sysinxs in memory */
  SYSTABLE  *systable;          /* pointer to systable records */
  SYSCOLUMN *syscolumn;         /* pointer to syscolumn records */
  SYSINDEX  *sysindex;          /* pointer to sysindex records */
  SYSREL    *sysrel;            /* pointer to sysrel records */
  SYSPTR    *sysptr;            /* pointer to sysptr records */
  HFILE     hFileLog;           /* log file handle */
} BASE;

typedef BASE FAR *LPBASE;       /* pointer to data base */

typedef struct
{
  USHORT    version;            /* db version 0x0100 = 1.00 */
  USHORT    fieldsize;          /* records are stored in multiples of fieldsize */
  LONG      file_size;          /* filesize of allocated datafile */
  LONG      next_rec;           /* pointer where next record will be stored */
  LONG      size_released;      /* size of released space of FIRST_REC..next_rec */
  TIMESTAMP created;            /* creation date & time */
  TIMESTAMP lastuse;            /* date & time of last use */
  BOOL      reorg;              /* TRUE <=> database must be reorganized */
  LONG      cache_size;         /* cache size */
  LONG      num_calls;          /* number of calls to read from cache */
  LONG      num_hits;           /* number of hits in cache */
  UCHAR     tbl_ascii [256];    /* convert table for move to ascii letters */
} DATA_INFO;

typedef DATA_INFO FAR *LPDATA_INFO; /* pointer to data information */

typedef struct
{
  LONG  num_pages;              /* number of pages */
  LONG  used_pages;             /* number of used pages */
  LONG  free_page;              /* number of first free page */
  LONG  num_vpages;             /* number of virtual pages */
  SHORT num_cursors;            /* number of cursors */
  LONG  num_calls;              /* number of calls to virtual page test */
  LONG  num_hits;               /* number of hits (virtual page found) */
} TREE_INFO;

typedef TREE_INFO FAR *LPTREE_INFO; /* pointer to tree information */

typedef struct
{
  USERNAME  username;           /* name of user which opened database */
  BASENAME  basename;           /* name of database */
  BASEPATH  basepath;           /* path of database */
  DATA_INFO data_info;          /* data information */
  TREE_INFO tree_info;          /* tree information */
} BASE_INFO;

typedef BASE_INFO FAR *LPBASE_INFO; /* pointer to data base information */

typedef struct
{
  TABLENAME name;               /* name of table */
  LONG      recs;               /* number of records */
  SHORT     cols;               /* number of columns */
  SHORT     indexes;            /* number of indexes */
  LONG      size;               /* size of one record */
  SHORT     color;              /* color of table */
  SHORT     icon;               /* icon for table */
  SHORT     children;           /* number of dependent tables */
  SHORT     parents;            /* number of parent tables */
  USHORT    flags;              /* flags of table */
} TABLE_INFO;

typedef TABLE_INFO FAR *LPTABLE_INFO; /* pointer to table information */

typedef struct
{
  FIELDNAME name;               /* name of column */
  SHORT     type;               /* type of column */
  LONG      addr;               /* address in record */
  LONG      size;               /* size of column */
  SHORT     format;             /* format of column */
  USHORT    flags;              /* flags of column */
} FIELD_INFO;

typedef FIELD_INFO FAR *LPFIELD_INFO; /* pointer to field information */

typedef struct
{
  FIELDNAME name;               /* name of index */
  INDEXNAME indexname;          /* sort name of index */
  SHORT     type;               /* type of index */
  LONG      root;               /* root page number */
  LONG      num_keys;           /* number of actual keys */
  INXCOLS   inxcols;            /* column numbers of (multiple) indexes */
  USHORT    flags;              /* flags of index */
} INDEX_INFO;

typedef INDEX_INFO FAR *LPINDEX_INFO; /* pointer to index information */

typedef struct
{
  LONG all_recs;                /* number of records reorganized */
  LONG lost_recs;               /* number of lost records */
  LONG del_recs;                /* number of records deleted from SYS_DELETED */
  LONG size_before;             /* size of data file before reorganizing */
  LONG size_after;              /* size of data file after reorganizing */
  SHORT status;                 /* last reorg error */
} REORG_RESULT;

typedef REORG_RESULT FAR *LPREORG_RESULT; /* pointer to reorg result */

typedef BOOL (CALLBACK *REORGFUNC) _((INT msg, LONG rec));

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID      WINAPI db_init        _((LOCKFUNC lock));
GLOBAL LPBASE    WINAPI db_create      _((LPSTR basename, LPSTR basepath, USHORT flags, LONG datasize, LONG treesize));
GLOBAL LPBASE    WINAPI db_open        _((LPSTR basename, LPSTR basepath, USHORT flags, LONG cachesize, SHORT num_cursors, LPSTR username, LPSTR password));
GLOBAL LPBASE    WINAPI db_open_cache  _((LPSTR basename, LPSTR basepath, USHORT flags, LONG datacache, LONG treecache, SHORT num_cursors, LPSTR username, LPSTR password));
GLOBAL BOOL      WINAPI db_close       _((LPBASE base));
GLOBAL BOOL      WINAPI db_reorg       _((LPSTR basename, LPSTR basepath, LONG cachesize, BOOL crypt, REORGFUNC reorgfunc, LPREORG_RESULT reorg_result));
GLOBAL BOOL      WINAPI db_reorg_cache _((LPSTR basename, LPSTR basepath, LONG datacache, LONG treecache, BOOL crypt, REORGFUNC reorgfunc, LPREORG_RESULT reorg_result));
GLOBAL BOOL      WINAPI db_flush       _((LPBASE base, BOOL flushdata, BOOL flushtree));
GLOBAL BOOL      WINAPI db_beg_trans   _((LPBASE base, BOOL write));
GLOBAL BOOL      WINAPI db_end_trans   _((LPBASE base));
GLOBAL USHORT    WINAPI db_version     _((LPBASE base));
GLOBAL USHORT    WINAPI db_lib_version _((VOID));

GLOBAL SHORT     WINAPI db_status      _((LPBASE base));
GLOBAL BOOL      WINAPI db_baseinfo    _((LPBASE base, LPBASE_INFO base_info));
GLOBAL SHORT     WINAPI db_tableinfo   _((LPBASE base, SHORT table, LPTABLE_INFO table_info));
GLOBAL SHORT     WINAPI db_fieldinfo   _((LPBASE base, SHORT table, SHORT field, LPFIELD_INFO field_info));
GLOBAL SHORT     WINAPI db_indexinfo   _((LPBASE base, SHORT table, SHORT inx, LPINDEX_INFO index_info));
GLOBAL USHORT    WINAPI db_acc_table   _((LPBASE base, SHORT table));
GLOBAL USHORT    WINAPI db_acc_column  _((LPBASE base, SHORT table, SHORT col));
GLOBAL USHORT    WINAPI db_acc_index   _((LPBASE base, SHORT table, SHORT inx));
GLOBAL LPSTR     WINAPI db_tablename   _((LPBASE base, SHORT table));
GLOBAL LPSTR     WINAPI db_fieldname   _((LPBASE base, SHORT table, SHORT field));
GLOBAL LPSTR     WINAPI db_indexname   _((LPBASE base, SHORT table, SHORT inx));

GLOBAL LPCURSOR  WINAPI db_newcursor   _((LPBASE base));
GLOBAL VOID      WINAPI db_freecursor  _((LPBASE base, LPCURSOR cursor));
GLOBAL BOOL      WINAPI db_initcursor  _((LPBASE base, SHORT table, SHORT inx, SHORT dir, LPCURSOR cursor));
GLOBAL BOOL      WINAPI db_movecursor  _((LPBASE base, LPCURSOR cursor, LONG steps));
GLOBAL LONG      WINAPI db_readcursor  _((LPBASE base, LPCURSOR cursor, HPVOID keyval));
GLOBAL BOOL      WINAPI db_testcursor  _((LPBASE base, LPCURSOR cursor, SHORT dir, HPVOID keyval));
GLOBAL LONG      WINAPI db_locateaddr  _((LPBASE base, LPCURSOR cursor, SHORT dir, LONG addr));
GLOBAL BOOL      WINAPI db_isfirst     _((LPBASE base, LPCURSOR cursor));
GLOBAL BOOL      WINAPI db_islast      _((LPBASE base, LPCURSOR cursor));

GLOBAL BOOL      WINAPI db_insert      _((LPBASE base, SHORT table, HPVOID buffer, LPSHORT status));
GLOBAL BOOL      WINAPI db_delete      _((LPBASE base, SHORT table, LONG address, LPSHORT status));
GLOBAL BOOL      WINAPI db_undelete    _((LPBASE base, LONG address, LPSHORT status));
GLOBAL BOOL      WINAPI db_update      _((LPBASE base, SHORT table, HPVOID buffer, LPSHORT status));
GLOBAL BOOL      WINAPI db_update_opt  _((LPBASE base, SHORT table, HPVOID buffer, LONG old_version, LPLONG new_version, LPSHORT status));
GLOBAL BOOL      WINAPI db_read        _((LPBASE base, SHORT table, HPVOID buffer, LPCURSOR cursor, LONG address, BOOL modify));
GLOBAL BOOL      WINAPI db_read_opt    _((LPBASE base, SHORT table, HPVOID buffer, LPCURSOR cursor, LONG address, LPLONG version));
GLOBAL LPSYSBLOB WINAPI db_readblob    _((LPBASE base, LPSYSBLOB buffer, LPCURSOR cursor, LONG address, BOOL modify));
GLOBAL BOOL      WINAPI db_search      _((LPBASE base, SHORT table, SHORT inx, SHORT dir, LPCURSOR cursor, HPVOID buffer, LONG address));
GLOBAL BOOL      WINAPI db_keysearch   _((LPBASE base, SHORT table, SHORT inx, SHORT dir, LPCURSOR cursor, HPVOID keyval, LONG address));
GLOBAL BOOL      WINAPI db_reclock     _((LPBASE base, LONG address));
GLOBAL BOOL      WINAPI db_recunlock   _((LPBASE base, LONG address));

GLOBAL LONG      WINAPI db_pack        _((LPBASE base, SHORT table, HPVOID buffer, HPVOID packbuf));
GLOBAL LONG      WINAPI db_unpack      _((LPBASE base, SHORT table, HPVOID buffer, HPVOID packbuf, LONG packsize));
GLOBAL BOOL      WINAPI db_killtree    _((LPBASE base, SHORT table, SHORT inx));
GLOBAL BOOL      WINAPI db_reorgtree   _((LPBASE base, SHORT table, HPVOID buffer));
GLOBAL BOOL      WINAPI db_buildkey    _((LPBASE base, SHORT table, SHORT inx, HPVOID buffer, HPVOID keyval));
GLOBAL BOOL      WINAPI db_fillnull    _((LPBASE base, SHORT table, HPVOID buffer));
GLOBAL BOOL      WINAPI db_getfield    _((LPBASE base, SHORT table, SHORT field, HPVOID buffer, HPVOID value));
GLOBAL BOOL      WINAPI db_setfield    _((LPBASE base, SHORT table, SHORT field, HPVOID buffer, HPVOID value));
GLOBAL SHORT     WINAPI db_cmpfield    _((LPBASE base, SHORT table, SHORT field, HPVOID buffer1, HPVOID buffer2));
GLOBAL SHORT     WINAPI db_expand      _((LPBASE base, LONG datasize, LONG treesize));
GLOBAL VOID      WINAPI db_convstr     _((LPBASE base, HPCHAR s));
GLOBAL BOOL      WINAPI db_getstr      _((LPBASE base, SHORT table, SHORT field, HPVOID buffer, HPCHAR s));
GLOBAL BOOL      WINAPI db_setstr      _((LPBASE base, SHORT table, SHORT field, HPVOID buffer, HPCHAR s));

#ifdef __cplusplus
}
#endif

#endif /* _DBCALL_H */

