/* SCHDEFS.H */

#define TRUE  1
#define FALSE 0

/* window definitions */

#define WF_WXYWH 4
#define WF_CXYWH 5
#define WF_PXYWH 6
#define WF_FXYWH 7

#define WA_UPPAGE 0
#define WA_DNPAGE 1
#define WA_UPLINE 2
#define WA_DNLINE 3
#define WA_LFPAGE 4
#define WA_RTPAGE 5
#define WA_LFLINE 6
#define WA_RTLINE 7

/* rename function error numbers */

#define EACCDN -36  /* destination file already exists */
#define EPTHNF -33  /* 'oldname' not found             */
#define ENSAME -48  /* 'newname' not on save drive     */

#define NUM_WINDS                7
#define NUM_REPORTS             21 /* 20 reports + calendar report        */
#define NUM_AUTO_TICKLERS       10
#define NUM_XFIELDS              5 /* number of additonal fields (custom) */
#define NUM_SELECTIONS          25 /* maximum number of lines in a window */

#define MAX_CLMS                 255 /* max columns in reports */
#define MAX_LINES_IN_DESCRIPTION   4
#define MAX_XFIELD_LENGTH         40 /* max chrs of additional fields */
#define MAX_EDIT_FIELDS           20 /* must be equal to or greater than the
                                        number of editable text fields in a
                                        form that uses last/copy/paste */

#define CAL_LINES 11 /* number of lines in calendar dialog report */

/* magic numbers to identify files */

#define REC_MAGIC 0xACED
#define RPT_MAGIC 0xDEAD
#define WDW_MAGIC 0xFEED
#define MAC_MAGIC 0xDEAF
#define COD_MAGIC 0xFADE
#define TIK_MAGIC 0xBEEF

/* field alignment in reports */

#define LEFT   0
#define CENTER 1
#define RIGHT  2

#define OFF 0
#define ON  1

#define ERROR (-1)

#define FIRST_SYS_YEAR 80

#define FMD_FORWARD  0
#define FMD_BACKWARD 1
#define FMD_DEFLT    2

#define HIDE_MOUSE graf_mouse(256,&dummy)
#define SHOW_MOUSE graf_mouse(257,&dummy)

/* field comparison values */

#define IN               0
#define EQUAL            1
#define NOT_EQUAL        2
#define LESS_THAN        3
#define GREATER_THAN     4
#define LT_OR_EQUAL      5
#define GT_OR_EQUAL      6

#define CAL_WFEATURES  (NAME+CLOSER+MOVER+UPARROW+DNARROW+VSLIDE)
#define FORM_WFEATURES (NAME+CLOSER+MOVER)

#define CONTINUOUS 0 /* printer sheet types */
#define SINGLE     1

/* print styles */

#define NLQ       0
#define PICA      1
#define ELITE     2
#define CONDENSED 3

/* print modes */

#define DRAFT       0
#define BOLD        1 /* must be one (also used with vdi text style) */
#define DOUBLE      2
#define EXPANDED    3
#define DOUBLE_BOLD 4

#define DEV_PRINTER      0
#define DEV_WINDOW       1
#define DEV_DISK         2
#define DEV_COUNT_LINES  3
#define DEV_CINFO_WINDOW 4
#define DEV_SHOWN        5
#define DEV_SELECTIONS   6

#define MAX(x,y) (((x) > (y)) ? (x) : (y))
#define MIN(x,y) (((x) < (y)) ? (x) : (y))

#define WC_CALENDAR 0
#define WC_REPORT   1 /* first of NUM_REPORTS */

#define COLUMN 0
#define DAILY  1

#define PLUS  0
#define MINUS 1

#define DAY  0
#define WEEK 1

#define CR_BLANK            0 /* must be these values */
#define CR_DATE             1
#define CR_DAY_OF_WEEK      2
#define CR_TIME             3
#define CR_DESCRIPTION      4
#define CR_SHORT_TO_EVENT   5
#define CR_SUBJECT          6
#define CR_XFIELD1          7

#define CR_MED_TO_EVENT  100
#define CR_LONG_TO_EVENT 101

#define AT_DESCRIPTION  0
#define AT_SUBJECT      1

#define BACKWARD 0
#define FORWARD  1

typedef struct recstr
{
   int  rdeleted;
   char rdate[9];
   char *rstime;
   char *retime;
   char *rsubj;
   char *rxfield[NUM_XFIELDS];
   char *rdescr[4];
} RECORD;

typedef struct windstr
{
   int   wfeatures;
   int   wopen;
   int   whandle;
   int   whidden;
   int   wtopped;
   char  wtitle[81];
   char  w1header[MAX_CLMS+1];
   char  w2header[MAX_CLMS+1];
   int   wx;
   int   wy;
   int   wwidth;
   int   wheight;
   GRECT work_area;
   int   wcontents;
   int   wxindex;
   int   wyindex;
   int   wlines;
   int   wcolumns;
   int   wshown;
   int   wxdescr;
   char  wsdate[9];
   char  wedate[9];
   char  wstime[6];
   char  wetime[6];
   char  wsubj[16];
   char  wxfield[NUM_XFIELDS][41];
   char  wdescr[41];
   int   wdecision[9];
   int   wbeg_flag;
   int   wend_flag;
   int   wsys_sdate;
   int   wsys_edate;
} WIND;

typedef struct tickstr
{
   char akeyword[16];
   int  adir;
   int  adays[5];
} TICKLERS;

typedef struct custstr
{
   int  dcentury;
   int  dyear;
   int  dtickler;
   int  dstime;
   int  detime;
   int  dsubj;
   int  dlen_subj;
   int  ddescr_lines;
   int  dlen_descr[4];
   int  dxfields;
   char dxflabel[NUM_XFIELDS][14];
   int  dxfchrs[NUM_XFIELDS];
} CUSTOM;

typedef struct rptstr
{
   int  cavailable;
   int  cstyle;
   char cname[21];
   int  cinfo[2][9];
   int  clength[2][9];
   int  calign_fld[2][9];
   int  cspacing[2];
   int  cmin_spacing_per_day;
   int  ctot_clms[2];
} RPT;

typedef struct laststr
{
   char lsdate[9];
   char ledate[9];
   char lstime[6];
   char letime[6];
   char lsubj[41];
   char lxfield[NUM_XFIELDS][41];
   char ldescr[4][41];
   char ldays[5];
} LAST_USED;

typedef struct pcstr
{
   char pnotes[48];
   int  ponnlq[4];
   int  poffnlq[4];
   int  ponbold[4];
   int  poffbold[4];
   int  ponexpanded[4];
   int  poffexpanded[4];
   int  pondouble[4];
   int  poffdouble[4];
   int  ppica[4];
   int  pelite[4];
   int  pcondensed[4];
} PCODES;

typedef struct pagestr
{
   int  pfirst_page;
   int  plast_page;
   int  pcopies;
   int  plmarg;
   int  prmarg;
   int  ptmarg;
   int  pbmarg;
   int  ppage_size;
   int  pnumber_page;
   int  pheader;
   int  pdate_stamp;
   int  ptime_stamp;
   int  pfile_stamp;
   int  peject_page;
   int  ptotal_events;
   int  pstyle;
   int  pmode;
   int  ptype_sheet;
   int  pnew_report;
} PAGE;

typedef struct selstr
{
   int  sselected;
   int  srec_no;
   int  scommon;
} SELECTION;

typedef struct oprfstr
{
   int  opbackup;
   int  opdate_display;
   int  optime_display;
   char opdisk_extension[4];
} OTHER_PREFS;

