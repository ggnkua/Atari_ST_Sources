/*****************************************************************************
 *
 * Module : ROOT.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 
 *
 *
 * Description: This module defines the root definitions.
 *
 * History:
 * 18.01.04: Function user_help added
 * 04.01.04: enum FREETEXTS auskommentiert
 * 21.03.03: classes for selected objects for clipboard
 * 21.12.02: minimize_process added
 * 21.03.97: FTXTSUFF added
 * 03.03.97: Function appl_help is global
 * 01.03.97: Variables bUseDesktopWindow, bTopDesktopWindow, and bUseDesktopWindowSliders moved to global.h
 * 28.02.97: ERR_REC_NOT_FOUND added
 * 26.02.97: FSAVEFIL added
 * 25.02.97: ACCOUNT_PROP_ACC_PRINTER and ACCOUNT_PROP_LINK_ORDER added
 * 24.02.97: Variable bUseDesktopWindowSliders added
 * 18.02.97: ERR_ACC_NOT_FOUND added
 * 16.02.97: ACCOUNT_PROP_LINK_CONDITION added
 * 15.02.97: Link master and child swapped
 * 14.02.97: Variables bUseDesktopWindow and bTopDesktopWindow added
 * 03.01.97: ERR_BAT_NOBATCH and ERR_BAT_NOACCOUNT added
 * 01.01.97: FPPAGENR added
 * 27.12.96: ACCOUNT_PROP_ACC_PAGE_FORMAT and ACCOUNT_PROP_ACC_PAGE_ORIENTATION added
 * 14.12.96: FPAGE added
 * 11.10.95: MAX_RECORDS increased
 * 27.11.95: ACCOUNT_PROP_ACC_IS_TABLE definition added
 * 26.11.95: ACCOUNT_PROP_REG_... definitions added
 * 25.11.95: ACCOUNT_PROP_ACC_... definitions added
 * 21.10.95: ACCOUNT_PROP_VAL_... definitions added
 * 15.10.95: FPROPERTIES added
 * 14.10.95: ACCOUNT_PROP_FONT_FACENAME added
 * 08.10.95: ERR_IMPEXPBLOB added
 * 01.10.95: ACCOUNT_SIZE_LINES added
 * 30.09.95: ACCOUNT_PROP_IS_SELECTED added
 * 24.09.95: ACCOUNT_PROP... added
 * 14.09.95: ACCOUNT_GROUPBOX added
 * 18.07.95: Variables show_raster and use_raster added
 * 17.07.95: ACCOUNT_... definitions added
 * 09.07.95: FDEFACCOUNT added
 * 04.07.95; Parameter retval added in v_execute
 * 31.01.95; Variable warn_table added
 * 08.12.94: FGETPARM added
 * 01.12.94: ERR_SM_NO_FIELD added
 * 16.10.94: ERR_SM_* added
 * 09.07.94: Visible table capabilities added
 * 20.03.94: ERR_REPDEVICE removed
 * 19.03.94: FCOPIES added
 * 12.03.94: Variable show_info added
 * 05.03.94: Variable show_pattern added
 * 23.02.94: Variables show_top and show_left added
 * 22.02.94: COLUMNSEP added
 * 12.02.94: Variable use_std_fs moved to global.h
 * 16.11.93: Variable use_std_fs added
 * 04.11.93: String definitions for commdlg strings added
 * 03.11.93: Functions load_fonts and unload_fonts removed
 * 30.10.93: ERR_INFVERSION added
 * 07.10.93: Variables max_datacache and max_treecache added
 * 05.10.93: FDLG_CHECK, FDLG_RADIO, and FDLG_ARROW added
 * 03.10.93: Variable use_3d moved to global.h
 * 02.10.93: Functions text_export and text_import added
 * 01.10.93: Bitmaps for multikeys added
 * 30.09.93: Variables color_desktop and pattern_desktop moved to global.h
 * 27.09.93: Bitmaps for db's tables, cols, and indices added
 * 09.09.93: Listbox components removed from DB
 * 27.08.93: Variable hide_iconbar added
 * 20.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __ROOT__
#define __ROOT__

/****** DEFINES **************************************************************/


/* [GS] 5.1f alt:
enum ERRORS
{
  ERR_NOOPEN = 90,
  ERR_NOINFO,
  ERR_NOHELP,
  ERR_INFOTABLE,
  ERR_INFOPROCESS,
  ERR_INFOTRASH,
  ERR_INFOPRINTER,
  ERR_INFODISK,
  ERR_INFOEDIT,
  ERR_INFOCLIPBRD,
  ERR_INFOIMAGE,

  ERR_FILEOPEN,
  ERR_FILEREAD,
  ERR_FILEWRITE,
  ERR_FILECREATE,

  ERR_PRINTER,
  ERR_SCRAPDIR,
  ERR_MAXDB,
  ERR_SAMEBASE,
  ERR_NOMEMORY,
  ERR_NOMEMRETRY,
  ERR_NOCURSOR,
  ERR_NOINITCURSOR,
  ERR_NOKEYS,
  ERR_NOICON,
  ERR_NOVTABLE,
  ERR_VTABLEFULL,
  ERR_NOPROCESSES,
  ERR_ABORTPROCESS,
  ERR_FILEUSED,
  ERR_IMPSEP,
  ERR_PRINTERUSED,
  ERR_QUEUEFULL,
  ERR_NOPORT,
  ERR_READDRV,
  ERR_CHANGEDRV,
  ERR_NOPRIMARY,
  ERR_NOTABLE,
  ERR_NOCOLUMN,
  ERR_NOSELECT,
  ERR_NOFROM,
  ERR_NONUMBER,
  ERR_NOSEMICOLON,
  ERR_NOBY,
  ERR_NOAND,
  ERR_NOREL,
  ERR_TOOMANYORS,
  ERR_TOOMANYCONDS,
  ERR_NOEXPRESSION,
  ERR_INFOQBE,
  ERR_NOHELPOPEN,
  ERR_NOHELPMEM,
  ERR_NOHELPBASE,
  ERR_MNOTABLE,
  ERR_MNOFIELD,
  ERR_DBSEARCH,
  ERR_NOCOLUMNS,
  ERR_NOVINDEX,
  ERR_QUITPROGRAM,
  ERR_SAVEMODIFIED,
  ERR_INFORECORDS,
  ERR_MODIFIED,
  ERR_NOMASK,
  ERR_PICUNKNOWN,
  ERR_PIC2BIG,
  ERR_BLOB2BIG,
  ERR_TEXT2BIG,
  ERR_NOUSERMASK,
  ERR_NOTINBOUND,
  ERR_NOLOOKUP,
  ERR_LUNOMATCH,
  ERR_FIELD2LONG,
  ERR_TBLEXP,
  ERR_COLEXP,
  ERR_INXEXP,
  ERR_IDEXP,
  ERR_FORMATEXP,
  ERR_ENDEXP,
  ERR_EQUEXP,
  ERR_VAREXP,
  ERR_NUMBEREXP,
  ERR_LESSZERO,
  ERR_BRANCHNOTALLOWED,
  ERR_RETURNNOTALLOWED,
  ERR_TOOMANYBRANCHES,
  ERR_TOOFEWRETURNS,
  ERR_TYPEMISMATCH,
  ERR_CALCNOTALLOWED,
  ERR_REPMISMATCH,
  ERR_REORG,
  ERR_COLNULL,
  ERR_INXNOTUNIQUE,
  ERR_NOINSERT,
  ERR_NODELETE,
  ERR_NOUPDATE,
  ERR_INXTYPE,
  ERR_DELETE,
  ERR_BRANCHSEP,
  ERR_SRCINX,
  ERR_TBLSEP,
  ERR_DSTTBL,
  ERR_DSTINX,
  ERR_INXCOLS,
  ERR_RECINVALID,
  ERR_NOREPORT,
  ERR_WRONGDB,
  ERR_SUPERUSER,
  ERR_RESETFLAGS,
  ERR_CALCMISMATCH,
  ERR_IMPCOLNULL,
  ERR_IMPINXNOTUNIQUE,
  ERR_IMPNOINSERT,
  ERR_IMPNODELETE,
  ERR_IMPNOUPDATE,
  ERR_2MANYLINES,
  ERR_SHOWLINES,
  ERR_BAT_NOCMD,
  ERR_BAT_NOPARM,
  ERR_BAT_WRONGPARM,
  ERR_BAT_NOCMDSEP,
  ERR_BAT_NOEQU,
  ERR_BAT_NOTABLE,
  ERR_BAT_NOINDEX,
  ERR_BAT_NODIR,
  ERR_BAT_NONUMBER,
  ERR_BAT_NOSTRSEP,
  ERR_BAT_NOSIZESEP,
  ERR_BAT_NOBOOL,
  ERR_BAT_NODEVICE,
  ERR_BAT_NOQUERY,
  ERR_BAT_NOCALC,
  ERR_BAT_NOREPORT,
  ERR_BAT_NOBATCH,
  ERR_BAT_NOACCOUNT,
  ERR_CALCENTRY,
  ERR_CALCEXIT,
  ERR_INFVERSION,
  ERR_SM_2MANY,
  ERR_SM_NOTABLE,
  ERR_SM_LINK_OBJ,
  ERR_SM_NO_FIELD,
  ERR_IMPEXPBLOB,
  ERR_ACC_COLUMN_NOT_FOUND,
  ERR_ACC_NOT_FOUND,
  ERR_REC_NOT_FOUND
}; /* ERRORS */
*/

/* [GS] 5.1d alt:
enum FREETEXTS
{
  FDESKNAM,
  FDESKINF,
  FHELPBAS,
  FTRASHNA,
  FTRASHIN,
  FHELPNAM,
  FHELPINF,
  FCALC,
  FQUERY,
  FREPORT,
  FBATCH,
  FACCOUNT,
  FCLIST,
  FQLIST,
  FRLIST,
  FBLIST,
  FALIST,
  FMLIST,
  FMEMORY,
  FTOTMEM,
  FDATABAS,
  FDEFREP,
  FDEFBAT,
  FDEFACCOUNT,
  FPROPERTIES,
  FPROPERTY,
  FNOTITLE,
  FSINGLE,
  FMULTASK,
  FMULUSER,
  FPERCENT,
  FCOLINFO,
  FQUEUEIN,
  FYES,
  FASCII,
  FNO,
  FBINARY,
  FSPOOLER,
  FFILE,
  FSEP,

  FM1,
  FM2,
  FM3,
  FM4,
  FM5,
  FM6,
  FM7,
  FM8,
  FM9,
  FM10,

  FALLSUFF,
  FINDSUFF,
  FDATSUFF,
  FLSTSUFF,
  FLAYSUFF,
  FPRNSUFF,
  FPRTSUFF,
  FBINSUFF,
  FASCSUFF,
  FTXTSUFF,
  FIMPSUFF,
  FTMPSUFF,
  FINFSUFF,
  FGEMSUFF,
  FIMGSUFF,
  FIFFSUFF,
  FTIFSUFF,
  FPRGSUFF,
  FAPPSUFF,
  F286SUFF,
  FRPTSUFF,
  FQBESUFF,
  FREPSUFF,
  FCALSUFF,
  FSAMSUFF,

  FFILTER_286_EXE,
  FFILTER_ALL,
  FFILTER_APP_EXE,
  FFILTER_ASC_BIN,
  FFILTER_DAT,
  FFILTER_GEM,
  FFILTER_IMG,
  FFILTER_IMG_GEM,
  FFILTER_IMG_GEM_TXT,
  FFILTER_IMP,
  FFILTER_IFF,
  FFILTER_IND,
  FFILTER_IND_IMG_GEM_TXT,
  FFILTER_INF,
  FFILTER_LAY,
  FFILTER_LST,
  FFILTER_PRG_ACC_TOS_TTP,
  FFILTER_PRN,
  FFILTER_PRT,
  FFILTER_RPT,
  FFILTER_SAM,
  FFILTER_TIF,
  FFILTER_TMP,
  FFILTER_TXT,

  FPRECSPE,
  FPBYTEPE,
  FPRECORD,
  FPBYTE,
  FPPAGENR,
  FPAGE,

  REPWIDTH,
  REPLENGT,
  REPTOP,
  REPBOT,
  REPHEAD,
  REPFOOT,
  REPHEADL,
  REPHEADM,
  REPHEADR,
  REPFOOTL,
  REPFOOTM,
  REPFOOTR,
  REPTABLE,
  REPASCII,
  REPPOS,
  REPLEFT,
  REPLIST,
  REPVPOS,
  REPSQL,
  REPPROP,
  REPSUPER,
  REPSUB,
  REPITALIC,
  REPBOLD,
  REPUNDER,
  REPPICA,
  REPELITE,
  REPNLQ,
  REPCONDENSED,
  REPEXPANDED,

  ACCOUNT_ACC_HEADER,
  ACCOUNT_ACC_FOOTER,
  ACCOUNT_PAGE_HEADER,
  ACCOUNT_PAGE_FOOTER,
  ACCOUNT_GROUP_HEADER,
  ACCOUNT_GROUP_FOOTER,
  ACCOUNT_DETAILS,
  ACCOUNT_WIDTH,
  ACCOUNT_HEIGHT,
  ACCOUNT_SIZE,
  ACCOUNT_SIZE_LINES,
  ACCOUNT_GROUPBOX,
  ACCOUNT_PROP_CLASS,
  ACCOUNT_PROP_FLAGS,
  ACCOUNT_PROP_TEXT,
  ACCOUNT_PROP_COLUMN,
  ACCOUNT_PROP_TABLE,
  ACCOUNT_PROP_FORMAT,
  ACCOUNT_PROP_VALUE,
  ACCOUNT_PROP_FILENAME,
  ACCOUNT_PROP_ACCOUNTNAME,
  ACCOUNT_PROP_LINK_MASTER_FIELDS,
  ACCOUNT_PROP_LINK_CHILD_FIELDS,
  ACCOUNT_PROP_LINK_CONDITION,
  ACCOUNT_PROP_LINK_ORDER,
  ACCOUNT_PROP_SUM,
  ACCOUNT_PROP_X,
  ACCOUNT_PROP_Y,
  ACCOUNT_PROP_W,
  ACCOUNT_PROP_H,
  ACCOUNT_PROP_BK_MODE,
  ACCOUNT_PROP_BK_COLOR,
  ACCOUNT_PROP_EFFECT,
  ACCOUNT_PROP_BORDER_MODE,
  ACCOUNT_PROP_BORDER_COLOR,
  ACCOUNT_PROP_BORDER_WIDTH,
  ACCOUNT_PROP_BORDER_STYLE,
  ACCOUNT_PROP_FONT_FACENAME,
  ACCOUNT_PROP_FONT_FONT,
  ACCOUNT_PROP_FONT_POINT,
  ACCOUNT_PROP_FONT_COLOR,
  ACCOUNT_PROP_FONT_BOLD,
  ACCOUNT_PROP_FONT_ITALIC,
  ACCOUNT_PROP_FONT_UNDERLINED,
  ACCOUNT_PROP_FONT_OUTLINED,
  ACCOUNT_PROP_FONT_LIGHT,
  ACCOUNT_PROP_HORZ_ALIGNMENT,
  ACCOUNT_PROP_VERT_ALIGNMENT,
  ACCOUNT_PROP_ROTATION,
  ACCOUNT_PROP_IS_VISIBLE,
  ACCOUNT_PROP_IS_SELECTED,
  ACCOUNT_PROP_CAN_GROW,
  ACCOUNT_PROP_CAN_SHRINK,
  ACCOUNT_PROP_HIDE_DUPLICATES,
  ACCOUNT_PROP_ACC_TABLE_OR_QUERY,
  ACCOUNT_PROP_ACC_IS_TABLE,
  ACCOUNT_PROP_ACC_PAGEHEADER,
  ACCOUNT_PROP_ACC_PAGEFOOTER,
  ACCOUNT_PROP_ACC_RASTER_X,
  ACCOUNT_PROP_ACC_RASTER_Y,
  ACCOUNT_PROP_ACC_WIDTH,
  ACCOUNT_PROP_ACC_MARGIN_LEFT,
  ACCOUNT_PROP_ACC_MARGIN_RIGHT,
  ACCOUNT_PROP_ACC_MARGIN_TOP,
  ACCOUNT_PROP_ACC_MARGIN_BOTTOM,
  ACCOUNT_PROP_ACC_NUM_COLUMNS,
  ACCOUNT_PROP_ACC_COLUMN_GAP,
  ACCOUNT_PROP_ACC_PRINTER,
  ACCOUNT_PROP_ACC_PAGE_FORMAT,
  ACCOUNT_PROP_ACC_PAGE_ORIENTATION,
  ACCOUNT_PROP_REG_NEW_PAGE,
  ACCOUNT_PROP_REG_HEIGHT,
  ACCOUNT_PROP_REG_BK_COLOR,
  ACCOUNT_PROP_REG_VISIBLE,
  ACCOUNT_PROP_REG_KEEP_TOGETHER,
  ACCOUNT_PROP_REG_CAN_GROW,
  ACCOUNT_PROP_REG_CAN_SHRINK,
  ACCOUNT_PROP_VAL_SUM,
  ACCOUNT_PROP_VAL_MODE,
  ACCOUNT_PROP_VAL_COLOR,
  ACCOUNT_PROP_VAL_EFFECT,
  ACCOUNT_PROP_VAL_STYLE,
  ACCOUNT_PROP_VAL_BOOL,
  ACCOUNT_PROP_VAL_HORZ_ALIGNMENT,
  ACCOUNT_PROP_VAL_VERT_ALIGNMENT,
  ACCOUNT_PROP_VAL_FROM_TABLE,
  ACCOUNT_PROP_VAL_PAGEHEADER,
  ACCOUNT_PROP_VAL_NEW_PAGE,
  ACCOUNT_PROP_VAL_PAGE_FORMAT,
  ACCOUNT_PROP_VAL_PAGE_ORIENTATION,

  FRDWR,
  FRDONLY,

  FOPENFIL,
  FSAVEFIL,
  FLOADINF,
  FSAVEINF,
  FOPENEXP,
  FOPENIMP,
  FPRNFILE,
  FOPENLST,
  FTMPDIR,
  FPRINTFI,
  FDELFILE,
  FLOADPRT,
  FLOADPRN,
  FSAVEPRN,
  FLOADLAY,
  FSAVELAY,
  FLOADIMP,
  FSAVEIMP,
  FSELPROG,
  FIMPTEXT,
  FEXPTEXT,
  FIMPPIC,
  FEXPPIC,
  FIMPBLOB,
  FEXPBLOB,
  FOPENRPT,
  FGETFILE,

  FPSPOOL,
  FPDISK,
  FPPRINT,
  FPEXPORT,
  FPIMPORT,
  FPSEARCH,
  FPDELETE,
  FPINSERT,
  FPACCOUNT,
  FPREPORT,
  FPCALC,
  FPBATCH,

  FABOUT,
  FOPENDB,
  FCONFIG,
  FIMEXPAR,
  FPRINTER,
  FPAGEFOR,
  FFONT,
  FLOCKSCR,
  FCHNGPSS,
  FDBINFO,
  FTBLINFO,
  FINXINFO,
  FPROCESS,
  FQUEUE,
  FPROGPAR,
  FDELRECS,
  FCSAVEAS,
  FQSAVEAS,
  FRSAVEAS,
  FBSAVEAS,
  FASAVEAS,
  FORDER,
  FNEWWIDT,
  FHABOUT,
  FCLIPNAM,
  FLSTSRCH,
  FMOREINF,
  FMETAINF,
  FMCHANGE,
  FJOIN,
  FMCONFIG,
  FREORGDB,
  FREORGPA,
  FREORGST,
  FREMSEL,
  FNEWPROC,
  FLSTPROC,
  FUSERINTR,
  FCOPIES,
  FGETPARM,

  FLOAD,
  FLOAD_TABLE,
  FLOAD_COLUMN,
  FLOAD_INDEX,
  FLOAD_REL,
  FLOAD_USER,
  FLOAD_DELETED,
  FLOAD_ICON,
  FLOAD_TATTR,
  FLOAD_FORMAT,
  FLOAD_LOOKUP,
  FLOAD_CALC,
  FLOAD_MASK,
  FLOAD_QUERY,
  FLOAD_REPORT,
  FLOAD_BATCH,
  FLOAD_BLOB,
  FLOAD_ACCOUNT,
  FLOAD_DUMMY17,
  FLOAD_DUMMY18,
  FLOAD_DUMMY19,

  FCOLOR_HIGHLIGHT,
  FCOLOR_HIGHLIGHTTEXT,
  FCOLOR_DISABLED,
  FCOLOR_BTNFACE,
  FCOLOR_BTNHIGHLIGHT,
  FCOLOR_BTNSHADOW,
  FCOLOR_BTNTEXT,
  FCOLOR_SCROLLBAR,
  FCOLOR_DIALOG,

  FDLG_CHECK0,
  FDLG_CHECK1,

  FDLG_RADIO0,
  FDLG_RADIO1,

  FDLG_ARROW0,
  FDLG_ARROW1,

  FCOMMDLG_NAME,
  FCOMMDLG_TYPE,
  FCOMMDLG_DATE,
  FCOMMDLG_SIZE,
  FCOMMDLG_NOTHING,

  FCOMMDLG_WHITE,
  FCOMMDLG_BLACK,
  FCOMMDLG_RED,
  FCOMMDLG_GREEN,
  FCOMMDLG_BLUE,
  FCOMMDLG_CYAN,
  FCOMMDLG_YELLOW,
  FCOMMDLG_MAGENTA,
  FCOMMDLG_GRAY,
  FCOMMDLG_DGRAY,
  FCOMMDLG_DRED,
  FCOMMDLG_DGREEN,
  FCOMMDLG_DBLUE,
  FCOMMDLG_DCYAN,
  FCOMMDLG_DYELLOW,
  FCOMMDLG_DMAGENTA
}; /* FREETEXTS */
*/

#define SEL_NONE          0             /* classes for selected objects */
#define SEL_TABLE         1             /* object in base window */
#define SEL_FIELD         2             /* object in base window */
#define SEL_KEY           3             /* object in base window */
#define SEL_MOBJ          4             /* object in mask window */

#define MAX_DB            8             /* max number of open databases */
#define MAX_DATACACHE  1000             /* max data cache */
#define MAX_TREECACHE  1000             /* max tree cache */
#define MAX_RECORDS    5000             /* max records for virtual table */

#define MAX_TBLICONS      (IPROCESS - ITABLE) /* max number of tables on desktop */
#define MAX_PROCESS       6             /* max number of simultaneous processes */

#define MAX_VTABLE        (MAX_TBLICONS + MAX_PROCESS + MAX_GEMWIND + 2) /* max virtual tables (0 & -1 not used) */
#define VTBL(vtable)      (vtable < FAILURE)
#define VTABLEP(vtable)   (&vtables [-vtable])

#define MAX_VINDEX        (MAX_TBLICONS + MAX_PROCESS + MAX_GEMWIND + 2) /* max virtual tables (0 & -1 not used) */
#define VINX(vindex)      (vindex < FAILURE)
#define VINDEXP(vindex)   (&vindexes [-vindex])

#define EVENTS_PS       100             /* default number of events per second */
#define RECS_PE           1             /* default number of records per event */

#define CLIPBRD           "CLIPBRD "    /* name of clipboard */

#define SCRP_OK        1000             /* message from scrap: ok */
#define SCRP_NOTOK     1001             /* message from scrap: not ok */
#define SCRP_UPDT      1002             /* message to scrap: update window */
#define SCRP_OPEN      1003             /* message to scrap: open window */

#define DEV_SCREEN        0             /* output on screen */
#define DEV_DISK          1             /* output to disk */
#define DEV_PRINTER       2             /* output to printer */

#define SIGN(x)           ((x < 0) ? (-1) : (x == 0) ? 0 : 1)
#define LEN(ucsd)         (WORD)(UBYTE)(ucsd [0]) /* length of UCSD string */

#define DESC_ORDER        0x8000        /* sort order for column is descending */

#define FREETXT(index)    (freetxt [index])

#define COLUMNSEP         FS            /* separator of columns in a line */

/****** TYPES ****************************************************************/

typedef struct
{
  BYTE *indexname;                      /* pointer to index name */
  WORD indexnum;                        /* real index number */
} I_INFO;                               /* index info for given index */

typedef struct
{
  BYTE      *tablename;                 /* pointer to table name */
  WORD      tablenum;                   /* table number */
  WORD      indexes;                    /* number of indexes in table */
  WORD      index;                      /* actual index number */
  WORD      i_inx;                      /* actual index index */
  WORD      first;                      /* first index in listbox */
  FIELDNAME calcname;                   /* name of calculation */
  CALCCODE  calccode;                   /* code of calculation for table */
  I_INFO    *i_info;                    /* pointer to index information */
} T_INFO;                               /* table info for given table */

typedef struct
{
  BASE      *base;                      /* database */
  PASSWORD  password;                   /* password for checking with lockscreen */
  UWORD     flags;                      /* open flags for database */
  WORD      pos;                        /* position in combobox */
  WORD      tables;                     /* number of tables in base */
  WORD      table;                      /* actual table number */
  WORD      t_inx;                      /* actual table index */
  WORD      num_vis_tables;             /* number of visible tables */
  WORD      *vis_tables;                /* indexes into t_info of visible tables */
  BOOLEAN   sort_by_name;               /* TRUE, if tables are sorted by name */
  BYTE      *mem;                       /* pointer to dynamic memory */
  T_INFO    *t_info;                    /* pointer to table information */
  VOID      *buffer;                    /* data base buffer */
  SYSICON   *sysicon;                   /* data and mask of all icons */
  SYSLOOKUP *syslookup;                 /* lookup info */
  FORMATSTR *formatstr;                 /* the plain text of the formats */
  FORMAT    *format;                    /* the coded formats */
} DB;                                   /* database definition */

typedef struct
{
  FULLNAME filename;                    /* full name of database */
  UWORD    flags;                       /* open flags for database */
  LONG     treecache;                   /* size of tree cache */
  LONG     datacache;                   /* size of data cache */
  WORD     num_cursors;                 /* number of cursors */
  USERNAME username;                    /* name of user */
  PASSWORD password;                    /* password of user */
  BOOLEAN  sort_by_name;                /* TRUE, if tables are sorted by name */
} DB_SPEC;                              /* database specification for opening */

typedef struct
{
  DB   *db;                             /* database of table */
  WORD table;                           /* physical table */
  LONG recs;                            /* number of actual records */
  WORD cols;                            /* number of actual columns */
  WORD used;                            /* used counter */
  LONG maxrecs;                         /* maximum number of records */
  LONG *recaddr;                        /* addresses of records */
} VTABLE;                               /* virtual table structure */

typedef struct
{
  DB      *db;                          /* database of table */
  WORD    vtable;                       /* virtual table */
  WORD    used;                         /* used counter */
  INXCOLS inxcols;                      /* column numbers of (multiple) indexes */
} VINDEX;                               /* virtual table structure */

typedef struct
{
  DB      *db;                          /* database of icon */
  WORD    table;                        /* table of icon */
  WINDOWP window;                       /* window of icon */
} ICON_INFO;                            /* icon information */

typedef struct
{
  WORD x;                               /* x-position */
  WORD y;                               /* y-position */
} ICON_POS;                             /* icon position */

typedef struct
{
  STRING  recsep;                       /* record separator */
  STRING  colsep;                       /* column separator */
  STRING  txtsep;                       /* text separator */
  BYTE    decimal [2];                  /* decimal period */
  WORD    asciiformat;                  /* ascii or binary format */
  BOOLEAN colname;                      /* print column names before first record */
  WORD    dateformat;                   /* date format */
  WORD    mode;                         /* insert or update mode */
  WORD    primary;                      /* primary index */
  FORMAT  format;                       /* format for date */
} IMPEXPCFG;

typedef struct
{
  LONGSTR lheader;                      /* left header */
  LONGSTR cheader;                      /* center header */
  LONGSTR rheader;                      /* right header */
  LONGSTR lfooter;                      /* left footer */
  LONGSTR cfooter;                      /* center footer */
  LONGSTR rfooter;                      /* right footer */
  WORD    width;                        /* width of paper */
  WORD    length;                       /* length of paper */
  WORD    mtop;                         /* top margin */
  WORD    mbottom;                      /* bottom margin */
  WORD    mheader;                      /* header margin */
  WORD    mfooter;                      /* footer margin */
  WORD    mleft;                        /* left margin */
  BOOLEAN formadvance;                  /* advance form after every page */
  BOOLEAN colheader;                    /* add column header */
  BOOLEAN sum;                          /* add groups */
  WORD    group;                        /* number of cols for different of group */
  WORD    result;                       /* resulting number of records per page */
} PAGE_FORMAT;

typedef struct
{
  STRING  name;                         /* name of printer */
  STRING  control;                      /* control code sequences */
  STRING  filename;                     /* filename */
  WORD    face;                         /* face */
  BOOLEAN condensed;                    /* condensed letters */
  BOOLEAN micro;                        /* micro letters */
  BOOLEAN expanded;                     /* expanded letters */
  BOOLEAN italic;                       /* italic letters */
  BOOLEAN emphasized;                   /* empahsized letters */
  BOOLEAN nlq;                          /* near letter quality */
  BOOLEAN spool;                        /* spool file */
  WORD    port;                         /* port number */
  BYTE    *port_name [5];               /* port name */
  WORD    lspace;                       /* line spacing */
  LONG    events_ps;                    /* events per second for spooler */
  LONG    bytes_pe;                     /* bytes per event for spooler */
} PRNCFG;

typedef union
{
  WORD   c_word;                        /* one word */
  LONG   c_long;                        /* one long */
  DOUBLE c_float;                       /* one double */
  STRING c_cfloat;                      /* one character float */
} CALC_TYPE;

/****** VARIABLES ************************************************************/

GLOBAL DB        db [MAX_DB];           /* all databases */
GLOBAL DB        *actdb;                /* actual database */
GLOBAL WORD      num_opendb;            /* number of open db's */
GLOBAL VTABLE    vtables [MAX_VTABLE];  /* virtual tables */
GLOBAL VINDEX    vindexes [MAX_VINDEX]; /* virtual indexes */
GLOBAL ICON_INFO icon_info [MAX_TBLICONS];  /* icon information */
GLOBAL ICON_POS  icon_pos [FKEYS + 1 - DTABLES]; /* icon positions */
GLOBAL WORD      sort_order;            /* ascending, descending */
GLOBAL BOOLEAN   sort_by_name;          /* tables and indexes sorted by name */
GLOBAL BOOLEAN   show_raster;           /* show raster in account */
GLOBAL BOOLEAN   use_raster;            /* use raster in account */
GLOBAL BOOLEAN   lockable;              /* screen is lockable */

GLOBAL FULLNAME  tmpdir;                /* temporary directory */
GLOBAL BOOLEAN   proc_beep;             /* beep at finishing of processes */
GLOBAL BOOLEAN   autosave;              /* save config on exit */
GLOBAL BOOLEAN   use_fonts;             /* use external fonts */
GLOBAL BOOLEAN   hide_func;             /* hide function keys */
GLOBAL BOOLEAN   hide_iconbar;          /* hide iconbar keys */
GLOBAL BOOLEAN   show_queried;          /* show number of queried recs */
GLOBAL BOOLEAN   show_grid;             /* show grid in list windows */
GLOBAL BOOLEAN   show_info;             /* show info line in list windows */
GLOBAL BOOLEAN   show_top;              /* show topmost line */
GLOBAL BOOLEAN   show_left;             /* show leftmost column */
GLOBAL BOOLEAN   show_pattern;          /* show pattern in topmost line and leftmost column (only in b/w) */
GLOBAL BOOLEAN   use_calc;              /* use calculation in every window */

GLOBAL BOOLEAN   minimize_process; 			/* minimize processes */
GLOBAL BOOLEAN   minimize;	            /* minimize rest */

GLOBAL BOOLEAN   warn_table;            /* warning of using empty tables */
GLOBAL LONG      max_datacache;         /* max. cache for data file */
GLOBAL LONG      max_treecache;         /* max. cache for tree file */
GLOBAL LONG      max_records;           /* max. records for query tables */
GLOBAL LONG      events_ps;             /* number of events per second */
GLOBAL LONG      recs_pe;               /* number of records per event */

GLOBAL FULLNAME  cfg_path;              /* path of configuration */
GLOBAL FILENAME  cfg_name;              /* name of configuration */
GLOBAL FULLNAME  drv_path;              /* path of printer driver */
GLOBAL FILENAME  drv_name;              /* name of printer driver */

GLOBAL FONTDESC  fontdesc;              /* font for next window */

GLOBAL UWORD     wi_modeless;           /* WI_MODELESS or WI_MODAL */

GLOBAL BYTE      **freetxt;             /* array of all free text elements */

GLOBAL ICON      tooldb_icon;		/* toolbar db icon */
GLOBAL ICON      tooltbl_icon;		/* toolbar table icon */
GLOBAL ICON      toolcol_icon;		/* toolbar column icon */
GLOBAL ICON      toolinx_icon;		/* toolbar index icon */
GLOBAL ICON      toolmul_icon;		/* toolbar multi index icon */
GLOBAL ICON      toolcal_icon;		/* toolbar calc operator icon */
GLOBAL ICON      toolbat_icon;		/* toolbar batch command icon */

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_root         _((VOID));
GLOBAL BOOLEAN term_root         _((VOID));

GLOBAL WORD    open_db           _((FULLNAME filename, UWORD flags, LONG datacache, LONG treecache, WORD num_cursors, USERNAME username, PASSWORD password, BOOLEAN sort_by_name));
GLOBAL WORD    close_db          _((VOID));

GLOBAL VOID    switch_base       _((WORD pos));
GLOBAL VOID    switch_table      _((DB *db, WORD table));
GLOBAL WORD    tablenum          _((DB *db, WORD t_inx));
GLOBAL WORD    indexnum          _((DB *db, WORD t_inx, WORD i_inx));
GLOBAL WORD    tableinx          _((DB *db, WORD table));
GLOBAL WORD    indexinx          _((DB *db, WORD table, WORD index));
GLOBAL WORD    sel_from_inx      _((DB *db, WORD t_inx));

GLOBAL WORD    rtable            _((WORD vtable));
GLOBAL WORD    new_vtable        _((DB *db, WORD table, LONG maxrecs, WORD cols));
GLOBAL VOID    free_vtable       _((WORD vtable));
GLOBAL VOID    del_vtable        _((WORD vtable, LONG index));
GLOBAL LONG    in_vtable         _((VTABLE *vtablep, LONG addr));
GLOBAL VOID    check_vtable      _((WORD vtable, LONG addr));
GLOBAL WORD    new_vindex        _((DB *db, WORD vtable, INXCOLS *inxcols));
GLOBAL VOID    free_vindex       _((WORD vindex));
GLOBAL WORD    v_tableinfo       _((DB *db, WORD vtable, TABLE_INFO *table_info));
GLOBAL WORD    v_indexinfo       _((DB *db, WORD vtable, WORD vindex, INDEX_INFO *index_info));
GLOBAL BOOLEAN v_initcursor      _((DB *db, WORD vtable, WORD inx, WORD dir, CURSOR *cursor));
GLOBAL BOOLEAN v_movecursor      _((DB *db, CURSOR *cursor, LONG steps));
GLOBAL LONG    v_readcursor      _((DB *db, CURSOR *cursor, VOID *keyval));
GLOBAL BOOLEAN v_isfirst         _((DB *db, CURSOR *cursor));
GLOBAL BOOLEAN v_islast          _((DB *db, CURSOR *cursor));
GLOBAL BOOLEAN v_read            _((DB *db, WORD vtable, VOID *buffer, CURSOR *cursor, LONG address, BOOLEAN modify));
GLOBAL WORD    v_execute         _((DB *db, WORD vtable, CALCCODE *calccode, VOID *buffer, LONG count, LPVALUEDESC retval));
GLOBAL LONG    num_keys          _((DB *db, WORD vtable, WORD inx));

GLOBAL BYTE    *dbtbl_name       _((DB *db, WORD vtable, BYTE *name));
GLOBAL BYTE    *table_name       _((DB *db, WORD vtable, BYTE *name));
GLOBAL BYTE    *column_name      _((DB *db, WORD vtable, WORD col, BYTE *name));
GLOBAL BYTE    *index_name       _((DB *db, WORD vtable, WORD inx, BYTE *name));
GLOBAL BYTE    *sort_name        _((DB *db, WORD vtable, WORD inx, WORD dir, BYTE *name));
GLOBAL BYTE    *temp_name        _((BYTE *s));

GLOBAL WORD    init_columns      _((DB *db, WORD table, WORD tblcols, WORD *columns, WORD *colwidth));
GLOBAL WORD    def_width         _((DB *db, WORD table, WORD col));
GLOBAL LONG    get_width         _((WORD cols, WORD *colwidth));
GLOBAL VOID    build_colheader   _((DB *db, WORD vtable, WORD cols, WORD *columns, WORD *colwidth, LONG max_cols, BYTE *header));
GLOBAL VOID    rec_to_line       _((DB *db, WORD vtable, VOID *buffer, WORD cols, WORD *columns, WORD *colwidth, LONG max_cols, BYTE *line));
GLOBAL VOID    col_to_str        _((DB *db, WORD table, VOID *buffer, WORD col, WORD colwidth, BYTE *s));
GLOBAL VOID    get_colheader     _((DB *db, WORD vtable, WORD cols, WORD *columns, WORD *colwidth, LONG max_cols, BYTE *header));
GLOBAL VOID    rec2line          _((DB *db, WORD vtable, VOID *buffer, WORD cols, WORD *columns, WORD *colwidth, LONG max_cols, BYTE *line));
GLOBAL VOID    col2str           _((DB *db, WORD table, VOID *buffer, WORD col, WORD colwidth, BYTE *s));
GLOBAL BOOLEAN str2col           _((DB *db, WORD table, VOID *buffer, WORD col, BYTE *s));
GLOBAL VOID    build_keystr      _((DB *db, WORD table, WORD inx, VOID *buffer, BYTE *keystr));
GLOBAL BOOLEAN printable         _((WORD type));
GLOBAL BOOLEAN str2ucsd          _((BYTE *s, BYTE *u));
GLOBAL BOOLEAN same_ucsd         _((BYTE *u1, BYTE *u2));
GLOBAL LONG    date2days         _((DATE *date));
GLOBAL VOID    days2date         _((LONG days, DATE *date));
GLOBAL LONG    time2secs         _((TIME *time));
GLOBAL VOID    secs2time         _((LONG seconds, TIME *time));

GLOBAL WORD    get_word          _((OBJECT *tree, WORD object));
GLOBAL LONG    get_long          _((OBJECT *tree, WORD object));
GLOBAL VOID    set_word          _((OBJECT *tree, WORD object, WORD value));
GLOBAL VOID    set_long          _((OBJECT *tree, WORD object, LONG value));

GLOBAL BOOLEAN hndl_help         _((WORD helpindex));
GLOBAL BOOLEAN appl_help         _((BYTE *helpmsg));
/* [GS] 5.1d Start: */
GLOBAL BOOLEAN user_help         _((BYTE *helpmsg));
/* Ende */ 
GLOBAL WORD    dbtest            _((DB *db));
GLOBAL WORD    dberror           _((BYTE *basename, WORD errornum));
GLOBAL BOOLEAN integrity         _((BASE *base, WORD table, WORD status));
GLOBAL WORD    file_error        _((WORD errornum, BYTE *filename));
GLOBAL VOID    sort_tables       _((DB *db, BOOLEAN alphanum));
GLOBAL WORD    find_rel          _((DB *db, WORD src_table, WORD src_index, WORD dst_table));
GLOBAL BOOLEAN sel_file          _((BYTE *name, BYTE *path, WORD suffix, WORD label, BYTE *filename));
GLOBAL BOOLEAN get_open_filename _((WORD wTitle, BYTE *pszHelpID, ULONG ulFlags, WORD wFilter, LONG *plFilterIndex, BYTE *pszInitialDir, WORD wDefExt, BYTE *pszFullName, BYTE *pszFileName));
GLOBAL BOOLEAN get_save_filename _((WORD wTitle, BYTE *pszHelpID, ULONG ulFlags, WORD wFilter, LONG *plFilterIndex, BYTE *pszInitialDir, WORD wDefExt, BYTE *pszFullName, BYTE *pszFileName));
GLOBAL VOID    set_idata         _((OBJECT *tree, WORD object, WORD *mask, WORD *data, WORD width, WORD height));
GLOBAL VOID    set_greyline      _((VOID));
GLOBAL BOOLEAN esc_pressed       _((VOID));
GLOBAL BOOLEAN check_close       _((VOID));
GLOBAL VOID    set_period        _((MKINFO *mk));
GLOBAL VOID    scan_header       _((DB *db, WORD vtable, WORD inx, WORD dir, WORD pagenr, BYTE *src, BYTE *dst));

GLOBAL BOOLEAN text_export       _((BYTE *text, LONG size));
GLOBAL BOOLEAN text_import       _((BYTE *text, LONG size));

#endif /* __ROOT__ */

