/*****************************************************************************
 *
 * Module : ROOT.H
 * Author : Jrgen Geiž
 *
 * Creation date    : 17.07.90
 * Last modification:
 *
 *
 * Description: This module defines the dependant functions for all modules.
 *
 * History:
 * 09.01.04: enum FREETEXTS ausgeklammert
 * 19.03.97: Variables cfg_path, cfg_name moved from moptions.c
 * 12.03.97: Functions vm_pagesize & vm_coords removed
 * 06.03.97: FM_ACCOUNT added
 * 19.02.97: Variable olga_activated added to MASK_SPEC
 * 12.06.96: ERR_QUITPROGRAM added
 * 22.08.95: FACCOUNTS added
 * 11.07.95: SM_SHOW_3D added
 * 15.12.94: REL_11, REL_1N moved to dbcall.h
 * 06.10.94: ERR_JOINMASK deleted
 * 29.09.94: REL_11, REL_1N added
 * 21.09.94: FSELJOIN -> FSUBMASK
 * 18.08.94: MASK_VERSION changed to 1 for checking of MIINFO, MIMENU
 * 28.02.94: FASCSUFF, FFILTER_ASC added
 * 21.02.94: Variable use_std_fs moved to global.h
 * 20.11.93: Functions get_open_filename, get_save_filename added
 * 18.11.93: Variable use_std_fs, FFILTER_ added
 * 10.11.93: Macro FONT_FLAG_SHOW_ALL added
 * 04.11.93: Functions load_fonts and unload_fonts removed
 * 03.11.93: String definitions for commdlg strings added
 * 27.10.93: cal_icon added
 * 23.10.93: msk_icon added
 * 14.10.93: datacache/treecache added in open_db, icons tbl_icon etc. added
 * 13.10.93: ERR_INFVERSION, FCOLINFO, datacache, treecache, rdonly added
 * 11.10.93: FCOLOR_HIGHLIGHT, ... FDLG_ARROW added
 * 24.09.93: FCONFMORE, use_3d, color_desktop, pattern_desktop added
 * 06.09.93: show_message, init_message changed
 * 20.08.93: get_str and set_str deleted
 * 17.07.90: Creation of body
 *****************************************************************************/

#ifndef __ROOT__
#define __ROOT__

#include "gemobj.h"     /* only used by modules mask and mclick */
#include "imageobj.h"

/****** DEFINES **************************************************************/

/* [GS] 5.1f alt:
enum ERRORS
{
  ERR_NOOPEN = 90,
  ERR_NOINFO,
  ERR_NOHELP,
  ERR_INFOTRASH,
  ERR_FILEOPEN,
  ERR_FILEREAD,
  ERR_FILEWRITE,
  ERR_FILECREATE,
  ERR_FILEEXISTS,
  ERR_PRINTER,
  ERR_SCRAPDIR,
  ERR_LOADCONFIG,
  ERR_SAVECONFIG,
  ERR_SAMEBASE,
  ERR_NOMEMORY,
  ERR_DBERROR,
  ERR_DBCREATE,
  ERR_DBOPEN,
  ERR_DBUPDATE,
  ERR_DBSAVE,
  ERR_MAXDB,
  ERR_SAMEMASK,
  ERR_NOMEMRETRY,
  ERR_NOTABLES,
  ERR_NOFIELDS,
  ERR_NOKEYS,
  ERR_NORULES,
  ERR_NOUSERS,
  ERR_NOICONS,
  ERR_NOFORMATS,
  ERR_NOLOOKUPS,
  ERR_NOMASKS,
  ERR_NOPICS,
  ERR_NOTUNIQUE,
  ERR_DELADDRESS,
  ERR_DELTABLE,
  ERR_DELFIELD,
  ERR_DELKEY,
  ERR_DELUSER,
  ERR_DELICON,
  ERR_DELFORMAT,
  ERR_NOTSAVED,
  ERR_OVERWRITE,
  ERR_DATAEXPAND,
  ERR_TREEEXPAND,
  ERR_ICONREAD,
  ERR_ICONWRITE,
  ERR_METAOK,
  ERR_TMPDIR,
  ERR_REORG,
  ERR_WDELKEY,
  ERR_NOPRIMARY,
  ERR_RELTYPE,
  ERR_FORMATUSED,
  ERR_MASKFILE,
  ERR_MNOTSAVED,
  ERR_MASKSAVE,
  ERR_MASKNEW,
  ERR_MASKLOAD,
  ERR_NOOBJECTS,
  ERR_NOMATCH,
  ERR_OBJEXISTS,
  ERR_UNKNOWNOBJ,
  ERR_TABLENAME,
  ERR_FIELDNAME,
  ERR_NOTBLNAME,
  ERR_IDTABLE,
  ERR_IDFIELD,
  ERR_IDINDEX,
  ERR_NOHELPOPEN,
  ERR_NOHELPMEM,
  ERR_NOHELPBASE,
  ERR_LOOKUPTYPE,
  ERR_LOOKUPEXIST,
  ERR_OUTDEVICE,
  ERR_STDMASK,
  ERR_FIELDINTBL,
  ERR_KEYINTBL,
  ERR_NODB,
  ERR_DELTRASH,
  ERR_PICUNKNOWN,
  ERR_USERINFO,
  ERR_USEREXISTS,
  ERR_SUPERUSER,
  ERR_FORMATLOST,
  ERR_CLIPINFO,
  ERR_CLIPEMPTY,
  ERR_CLIPMULTIKEY,
  ERR_CHECKTABLE,
  ERR_CHECKFIELD,
  ERR_KEYLEN,
  ERR_FORMAT2LONG,
  ERR_INFVERSION
}; /* ERRORS */
*/

/* [GS] 5.1d alt:
enum FREETEXTS
{
  FDESKNAM,
  FDESKINF,
  FTRASHNA,
  FTRASHIN,
  FNOTITLE,
  FNOFONT,
  FPOINT,
  FYES,
  FFIX,
  FPERCENT,
  FMEMORY,
  FTOTMEM,
  FHELPNAM,
  FHELPINF,
  FHELPBAS,
  FSEQUENT,
  FNULL,
  FSCREEN,
  FPRINTER,
  FSCRMASK,
  FPRNMASK,
  FDATABAS,
  FHABOUT,
  FTXTDEMO,
  FNO,
  FSEP,
  FSTDDATE,
  FCOLINFO,
  FSINGLE,
  FMULTASK,
  FMULUSER,
  FRDWR,
  FRDONLY,

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
  FICNSUFF,
  FDATSUFF,
  FINDSUFF,
  FINFSUFF,
  FDBSSUFF,
  FHSUFF,
  FTXTSUFF,
  FASCSUFF,

  FFILTER_ALL,
  FFILTER_DAT,
  FFILTER_DBS,
  FFILTER_GEM,
  FFILTER_H,
  FFILTER_ICO,
  FFILTER_IMG,
  FFILTER_IMG_GEM,
  FFILTER_IMG_GEM_TXT,
  FFILTER_IND,
  FFILTER_INF,
  FFILTER_TXT,
  FFILTER_ASC,

  FTABLES,
  FCOLUMNS,
  FINDEXES,
  FRELS,
  FUSERS,
  FDELETED,
  FICONS,
  FTATTRIB,
  FFORMATS,
  FLOOKUPS,
  FCALCS,
  FMASKS,
  FQUERIES,
  FREPORTS,
  FBATCHES,
  FBLOBS,
  FACCOUNTS,
  FDUMMY17,
  FDUMMY18,
  FDUMMY19,

  FTABLE,
  FFIELD,
  FKEY,
  FMOBJECT,

  FBYTE,
  FWORD,
  FLONG,

  FMNEUTRAL,
  FMOUTLINED,
  FMUNDERLINED,
  FMCHECKBOXL,
  FMCHECKBOXR,
  FMRADIOBUTTON,
  FMCOMBOBOX,

  FABOUT,
  FMOREINF,
  FCONFIG,
  FPARAMS,
  FUSERINTR,
  FFONT,
  FDBINFO,
  FMASKINF,

  FOPENDB,
  FNEWTBL,
  FCHGTBL,
  FNEWFIEL,
  FCHGFIEL,
  FNEWKEY,
  FCHGKEY,
  FTBLINFO,
  FDELRULE,
  FDBPARAM,

  FSELPATH,
  FLOADCFG,
  FSAVECFG,
  FSAVEAS,
  FLOADICN,
  FUPDICN,
  FEXPICN,
  FLOADGRF,
  FEXPSTR,
  FIMPSTR,
  FCIF,
  FTXT,
  FASCEXP,

  FSELMASK,
  FDOICONS,
  FFORMAT,
  FFIELDAT,
  FSELFILL,
  FSELLINE,
  FSELGRID,
  FSELSIZE,
  FTEXT,
  FBUTTON,
  FOBJSIZE,
  FPICSIZE,
  FLINESIZ,
  FRVALUES,
  FCVALUES,
  FSUBMASK,
  FACCESS,
  FUSERINF,

  FWRITE,
  FREAD,
  FDELOBJ,
  FOPEN,
  FCREATE,
  FSAVE,
  FEXPAND,

  FMASKINFO,    /* mask button commands */
  FMSAVE,
  FMINSERT,
  FMUPDATE,
  FMSEARCH,
  FMDELETE,
  FMCALC,
  FMCLEAR,
  FMPREV,
  FMNEXT,
  FMFIRST,
  FMLAST,
  FMIMPORT,
  FMEXPORT,
  FMOPEN,
  FMFILENAME,
  FMCHANGE,
  FMJOIN_MASK,
  FMJOIN_NEW,
  FMJOIN_TABLE,
  FMPOPUP,
  FMPRINT,
  FMREPORT,
  FMUSERHELP,
  FMWINFULL,
  FMWINCLOSE,
  FMQUERY_MASK,
  FMQUERY_TABLE,
  FMBATCH,
  FMMULTIBUTTON,
  FMACCOUNT,
  FMUSERHELPST,

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

#define ADD_TABLES       16L            /* max number of objects to add at one session */
#define ADD_COLUMNS     128L
#define ADD_INDEXES      32L
#define ADD_RELS         32L
#define ADD_USERS         8L
#define ADD_ICONS         8L
#define ADD_TATTRS       ADD_TABLES
#define ADD_FORMATS      32L
#define ADD_LOOKUPS      32L
#define ADD_MASKS        16L
#define ADD_SYSPTRS      ADD_TABLES

#define SM_SHOW_ICONS    0x0001         /* flag in SYSMASK, show icon bar in mask window */
#define SM_SHOW_INFO     0x0002         /* flag in SYSMASK, show info line in mask window */
#define SM_SHOW_MENU     0x0004         /* flag in SYSMASK, show menu line in mask window */
#define SM_SHOW_3D       0x0008         /* flag in SYSMASK, show controls with 3d effect */

#define INS_FLAG         0x8000         /* new and must be inserted at save time */
#define UPD_FLAG         0x4000         /* must be updated at save time */
#define DEL_FLAG         0x2000         /* must be deleted at save time */
#define MOD_FLAG         0x1000         /* object can be modified freely */

#define DESIGNER_FLAGS     (INS_FLAG | UPD_FLAG | DEL_FLAG | MOD_FLAG)
#define FONT_FLAG_SHOW_ALL (FONT_FLAG_SHOW_SYSTEM | FONT_FLAG_SHOW_MONO | FONT_FLAG_SHOW_PROP | FONT_FLAG_SHOW_VECTOR)

#define MAX_SELOBJ       ADD_COLUMNS
#define MAX_DEL          256            /* buffer for deleted objects */
#define MAX_PICS          16            /* background pictures in a mask */

#define LEN_TYPE           6            /* width of data type + 1 blank in chars */
#define LEN_SIZE           5            /* width of size type + 1 blank in chars */

#define MASK_SCREEN       'S'           /* used for mask specification */
#define MASK_PRINTER      'P'
#define MASK_VERSION       1            /* version number of a mask created with this phoenix version */

#define FREETXT(index)   (freetxt [index])

/****** TYPES ****************************************************************/

typedef struct
{
  LONG      address;            /* address of record */
  DEVSIZE   device;             /* device: S = screen, P = printer etc. */
  FIELDNAME name;               /* name of mask */
  TABLENAME tablename;          /* table of mask */
  WORD      findex;             /* index in temporary mask file */
  UWORD     flags;              /* flags of mask definition */
  SHORT     version;            /* version of mask */
  FIELDNAME calcentry;          /* name of calculation at entry time of record */
  FIELDNAME calcexit;           /* name of calculation at exit time of record */
  SHORT     x;			/* x starting position */
  SHORT     y;			/* y starting position */
  SHORT     w;			/* w starting position */
  SHORT     h;			/* h starting position */
  LONG      bkcolor;		/* background color */
} HLPMASK;

typedef struct
{
  WORD table;                   /* table of deleted objects */
  LONG address;                 /* address of record of deleted object */
} DELSPEC;

typedef struct
{
  WORD table;                   /* table of deleted key */
  WORD key;                     /* key to delete */
} DELKEY;

typedef union
{
  IMGOBJ img;                   /* for handling of bit images */
  GEMOBJ gem;                   /* for handling of gem metafiles */
} PICS;

typedef struct
{
  WORD    type;                 /* picture type (see conv.h) */
  LONGSTR filename;             /* filename of picture */
  PICS    pic;                  /* picture descriptor */
} PICOBJ;

typedef struct
{
  LONG      memsize;            /* size of allocated memory */
  BOOLEAN   new;                /* indicates a new database */
  BOOLEAN   untitled;           /* indicates an untitled database */
  BOOLEAN   abort;              /* user wants to abort database */
  BOOLEAN   modified;           /* database was modified */
  BOOLEAN   show_star;          /* show star, if modified */
  BOOLEAN   reorg;              /* database must be reorganized */
  BOOLEAN   in_memory;          /* TRUE if SYSTABLES are in memory */
  BOOLEAN   del_trash;          /* TRUE if old table was deleted */
  BASE      *base;              /* database descriptor */
  BASENAME  basename;           /* name of database */
  BASEPATH  basepath;           /* path of database */
  UWORD     oflags;             /* flags for opening db */
  UWORD     cflags;             /* flags for creating db */
  LONG      datasize;           /* size of data file */
  LONG      treesize;           /* size of index file */
  LONG      datacache;          /* cache for data */
  LONG      treecache;          /* cache for tree */
  BOOLEAN   rdonly;             /* open read only */
  WORD      cursors;            /* number of cursors */
  USERNAME  username;           /* name of user */
  PASSWORD  password;           /* password of user */
  BASE_INFO base_info;          /* database info, if not new */

  SYSTABLE  *systable;          /* pointer to tables */
  SYSCOLUMN *syscolumn;         /* pointer to columns */
  SYSINDEX  *sysindex;          /* pointer to indexes */
  SYSREL    *sysrel;            /* pointer to relations */
  SYSUSER   *sysuser;           /* pointer to users */
  SYSICON   *sysicon;           /* pointer to icons for tables */
  SYSTATTR  *systattr;          /* pointer to table attributes */
  SYSFORMAT *sysformat;         /* pointer to formats */
  SYSLOOKUP *syslookup;         /* pointer to lookups */
  SYSPTR    *sysptr;            /* pointer to sysptrs */
  HLPMASK   *sysmask;           /* pointer to help mask definitions */

  WORD      num_tables;         /* number of existing tables */
  WORD      num_columns;        /* number of existing columns */
  WORD      num_indexes;        /* number of existing indexes */
  WORD      num_rels;           /* number of existing relations */
  WORD      num_users;          /* number of existing users */
  WORD      num_icons;          /* number of existing icons */
  WORD      num_tattrs;         /* number of existing table attributes */
  WORD      num_formats;        /* number of existing formats */
  WORD      num_lookups;        /* number of existing lookup rules */
  WORD      num_masks;          /* number of existing masks */

  WORD      max_tables;         /* max number of tables */
  WORD      max_columns;        /* max number of columns */
  WORD      max_indexes;        /* max number of indexes */
  WORD      max_rels;           /* max number of relations */
  WORD      max_users;          /* max number of users */
  WORD      max_icons;          /* max number of icons */
  WORD      max_tattrs;         /* max number of attributes */
  WORD      max_formats;        /* max number of formats */
  WORD      max_lookups;        /* max number of lookup rules */
  WORD      max_masks;          /* max number of masks */

  WORD      first_table;        /* indicates first table to draw */
  WORD      x_factor;           /* x sizing factor: 100 = 100% */
  WORD      y_factor;           /* y sizing factor: 100 = 100% */
  LRECT     doc;                /* for saving old doc position */
  DELSPEC   delobjs [MAX_DEL];  /* holds objects which must be deleted at save time */
  WORD      delptr;             /* actual pointer to delobjs */
  DELKEY    delkeys [MAX_DEL];  /* holds keys which must be killed (db_killtree) at save time */
  WORD      delkeyptr;          /* actual pointer to delkeys */
  BOOLEAN   show_full;          /* show window full_scale/best_fit */
  BOOLEAN   show_tools;         /* TRUE <=> dbicons are shown */
  BOOLEAN   show_rels;          /* show table relations (TRUE)/lookup relations (FALSE) */
  BOOLEAN   show_short;         /* show tables with or without size of columns */
  WORD      tool;               /* selected tool */
  WORD      font;               /* actual font used */
  WORD      point;              /* actual point used */
  WORD      wbox;               /* character width */
  WORD      hbox;               /* character height */
  FULLNAME  fmask_name;         /* name of mask file */
  FHANDLE   fmask;              /* file handle of mask buffer */
  WORD      imask;              /* first free index in mask file */
} BASE_SPEC;

typedef struct
{
  LONG      memsize;            /* size of allocated memory */
  WINDOWP   window;             /* related window of this mask */
  BOOLEAN   new;                /* indicates a new mask */
  BOOLEAN   abort;              /* user wants to abort mask */
  BOOLEAN   modified;           /* mask was modified */
  BOOLEAN   show_star;          /* show star, if modified */
  BOOLEAN   show_full;          /* show window full_scale/best_fit */
  BOOLEAN   show_tools;         /* TRUE <=> maskicons are shown */
  BOOLEAN   printer_mask;       /* TRUE <=> mask designed for printer */
  BOOLEAN   olga_activated;     /* TRUE <=> olga server has been activated, window can be used again when olga server has been finished */
  SYSMASK   mask;               /* mask record */
  BASE_SPEC *base_spec;         /* database descriptor */
  WORD      mindex;             /* index of base_spec->sysmask */
  WORD      findex;             /* index in temporary mask file */
  WORD      str;                /* index into string table */
  WORD      objs;               /* number of objects */
  WORD      max_objs;           /* max number of objects */
  WORD      factor;             /* sizing factor */
  WORD      grid_x;             /* for snapping of objects in x dir */
  WORD      grid_y;             /* for snapping of objects in y dir */

  WORD      tool;               /* selected tool */
  WORD      font;               /* actual font used */
  WORD      point;              /* actual point used */
  WORD      color;              /* fill color */
  WORD      line_type;          /* fill type */
  WORD      line_width;         /* line width */
  WORD      line_bstyle;        /* line begin style */
  WORD      line_estyle;        /* line end style */
  WORD      fill_style;         /* hollow, solid, pattern... */
  WORD      fill_index;         /* fill style index */
  WORD      picptr;             /* actual pointer to pictures */
  WORD      max_pics;           /* max number of pictures in mask */
  PICOBJ    *picobj;            /* background pictures in mask */
} MASK_SPEC;

typedef struct
{
  WORD class;                   /* class of selected object */
  WORD table;                   /* selected table */
  WORD field;                   /* selected field */
  WORD key;                     /* selected multi key */
} SEL_SPEC;

typedef struct
{
  WORD tables;
  WORD columns;
  WORD indexes;
  WORD rels;
  WORD users;
  WORD icons;
  WORD formats;
  WORD lookups;
  WORD masks;
  WORD pics;
} WORK_SPEC;

/****** VARIABLES ************************************************************/

GLOBAL BOOLEAN   use_fonts;     /* use external fonts */
GLOBAL WORD      num_fonts;     /* fonts available */
GLOBAL WORD      g_font;        /* global font */
GLOBAL WORD      g_point;       /* global point */
GLOBAL BOOLEAN   autosave;      /* save config on exit */
GLOBAL BOOLEAN   print2meta;    /* printer output to metafile */
GLOBAL BOOLEAN   autoexp;       /* autoexport on saving db */
GLOBAL BOOLEAN   hidefunc;      /* hide function keys on desktop */
GLOBAL BOOLEAN   unixdb;        /* create unix compatible database */
GLOBAL FULLNAME  cfg_path;      /* path of configuration */
GLOBAL FILENAME  cfg_name;      /* name of configuration */
GLOBAL FULLNAME  db_path;       /* path of databases */
GLOBAL FILENAME  db_name;       /* last database used in mopen, msaveas */
GLOBAL FULLNAME  icn_path;      /* path of icon files */
GLOBAL FILENAME  icn_name;      /* name of icon files */
GLOBAL FULLNAME  pic_path;      /* path of picture files */
GLOBAL FILENAME  pic_name;      /* name of picture files */
GLOBAL FULLNAME  exp_path;      /* path of imp/exp files */
GLOBAL FILENAME  exp_name;      /* name of imp/exp files */
GLOBAL FULLNAME  tmpdir;        /* temporary directory */
GLOBAL SEL_SPEC  sel;           /* selected objects */
GLOBAL WORD      doc_width;     /* initial doc width of windows in gl_wbox units */
GLOBAL WORD      doc_height;    /* initial doc height of windows in gl_hbox units */
GLOBAL WORD      win_width;     /* initial window width of windows in gl_wbox units */
GLOBAL WORD      win_height;    /* initial window height of windows in gl_hbox units */
GLOBAL WORD      g_xgrid;       /* global initial x-grid for mask windows */
GLOBAL WORD      g_ygrid;       /* global initial y-grid for mask windows */
GLOBAL WORK_SPEC work_spec;     /* working parameters (add values) */
GLOBAL WORD      *std_width;    /* pointer to array of standard field width */
GLOBAL BYTE      **freetxt;     /* array of all free text elements */

GLOBAL ICON      tbl_icon;	/* table icon for listboxes */
GLOBAL ICON      col_icon;	/* column icon */
GLOBAL ICON      inx_icon;	/* index icon */
GLOBAL ICON      mul_icon;	/* multi index icon */
GLOBAL ICON      usr_icon;	/* user operator icon */
GLOBAL ICON      msk_icon;	/* mask icon */
GLOBAL ICON      cal_icon;	/* calc icon */

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_root         _((VOID));
GLOBAL BOOLEAN term_root         _((VOID));

GLOBAL WORD    file_error        _((WORD errornum, BYTE *filename));
GLOBAL WORD    dberror           _((WORD errornum, BYTE *basename));
GLOBAL WORD    dbtest            _((BASE *base));
GLOBAL BASE    *open_db          _((FULLNAME filename, UWORD flags, LONG datacache, LONG treecache, WORD num_cursors, USERNAME username, PASSWORD password, WORD *result));
GLOBAL VOID    close_db          _((BASE_SPEC *base_spec));
GLOBAL BOOLEAN make_maskfile     _((BASE_SPEC *base_spec));
GLOBAL VOID    del_maskfile      _((BASE_SPEC *base_spec));
GLOBAL BOOLEAN hndl_help         _((WORD helpindex));

GLOBAL WORD    v_tableinfo       _((BASE_SPEC *base_spec, WORD table, TABLE_INFO *table_info));
GLOBAL WORD    v_fieldinfo       _((BASE_SPEC *base_spec, WORD table, WORD field, FIELD_INFO *field_info));
GLOBAL WORD    v_indexinfo       _((BASE_SPEC *base_spec, WORD table, WORD inx, INDEX_INFO *index_info));
GLOBAL VOID    fill_sysptr       _((BASE_SPEC *base_spec));
GLOBAL WORD    get_ktype         _((BASE_SPEC *base_spec, WORD table, SYSINDEX *inxp));
GLOBAL VOID    get_tblwh         _((BASE_SPEC *base_spec, WORD table, WORD *width, WORD *height));
GLOBAL VOID    size2str          _((FIELD_INFO *field_info, BYTE *s));

GLOBAL WORD    abscol            _((BASE_SPEC *base_spec, WORD table, WORD col));
GLOBAL WORD    absinx            _((BASE_SPEC *base_spec, WORD table, WORD inx));
GLOBAL WORD    find_index        _((BASE_SPEC *base_spec, WORD table, WORD col));
GLOBAL WORD    find_multikey     _((BASE_SPEC *base_spec, WORD table, WORD inx));
GLOBAL WORD    inx2obj           _((BASE_SPEC *base_spec, WORD table, WORD inx, WORD *obj));
GLOBAL WORD    find_primary      _((BASE_SPEC *base_spec, WORD table));

GLOBAL VOID    set_idata         _((OBJECT *tree, WORD object, WORD *mask, WORD *data, WORD width, WORD height));
GLOBAL WORD    get_word          _((OBJECT *tree, WORD object));
GLOBAL LONG    get_long          _((OBJECT *tree, WORD object));
GLOBAL VOID    set_word          _((OBJECT *tree, WORD object, WORD value));
GLOBAL VOID    set_long          _((OBJECT *tree, WORD object, LONG value));

GLOBAL VOID    init_message      _((WORD menuobj, RECT *r, MFDB *screen, MFDB *buffer, BYTE *title));
GLOBAL VOID    exit_message      _((RECT *r, MFDB *screen, MFDB *buffer));
GLOBAL VOID    show_message      _((WORD num, WORD rwindex, WORD index));
GLOBAL BYTE    *temp_name        _((BYTE *s));
GLOBAL BOOLEAN sel_file          _((BYTE *name, BYTE *path, WORD suffix, WORD label, BYTE *filename));
GLOBAL BOOLEAN get_open_filename _((WORD wTitle, BYTE *pszHelpID, ULONG ulFlags, WORD wFilter, LONG *plFilterIndex, BYTE *pszInitialDir, WORD wDefExt, BYTE *pszFullName, BYTE *pszFileName));
GLOBAL BOOLEAN get_save_filename _((WORD wTitle, BYTE *pszHelpID, ULONG ulFlags, WORD wFilter, LONG *plFilterIndex, BYTE *pszInitialDir, WORD wDefExt, BYTE *pszFullName, BYTE *pszFileName));
GLOBAL VOID    make_id           _((BYTE *name));
GLOBAL VOID    device_info       _((WORD vdi_handle, DEVINFO *devinfo));

#endif /* __ROOT__ */

