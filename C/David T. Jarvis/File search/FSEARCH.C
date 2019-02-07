/*-------------------------------------------------------------------*/
/*                    "F I L E   S E A R C H"                        */
/*                                                                   */
/* by David T. Jarvis                                                */
/* Copyright 1989 Antic Publishing                                   */
/*                                                                   */
/* FSEARCH.C                                                         */
/* Version 051189 						     */
/* 								     */
/* File Search is a desk accessory that allows users to search for   */
/* files anywhere on a disk.  Once found, useful information about   */
/* each file is displayed and various operations may be performed on */
/* the file, including browsing it or copying it.  A list of all     */
/* files found in a search may be displayed in a window or printed   */
/* after the search has completed, and information about any of      */
/* the files found may be redisplayed by double-clicking on the file */ 
/* name in the list window.                                          */
/*                                                                   */
/* Developed With Mark Williams C                                    */
/* Compile instructions:                                             */
/*        cc -o fsearch.acc -VGEMACC fsearch.c                       */
/* NOTE:  crtsd.s should be edited to increase the stack size from   */
/* 1024 words to 4096, then reassembled with the command:            */
/*        as -o crtsd.o crtsd.s                                      */
/*-------------------------------------------------------------------*/

/* ---------- Includes and definitions ------------------------------*/

#include <stdio.h>         /* Standard I/O definitions               */
#include <osbind.h>        /* Operating System bindings              */
#include <xbios.h>         /* For Extended BIOS functions            */
#include <gemdefs.h>       /* GEM structures and definitions         */
#include <obdefs.h>        /* Object definitions                     */
#include <vdibind.h>       /* VDI bindings                           */
#include <aesbind.h>       /* AES bindings                           */
#include <ctype.h>         /* character macros                       */
#include "fsearch.h"       /* for resource index definitions         */

#define NO_WINDOW          -1
#define NOT_SELECTED       -1
#define NUMLINES           20
#define LINEWIDTH          76
#define OUTWIDTH           70
#define MAXLINES         2000
#define BUFSIZE          1024
#define MAXSPEC           100
#define ALLOCNUM       0x0064
#define WINX               40
#define WINY               20
#define WTYPE  (NAME|CLOSER|SIZER|MOVER|INFO|UPARROW|DNARROW|VSLIDE|FULLER)
#define BWTYPE (NAME|CLOSER|SIZER|MOVER|INFO|VSLIDE|FULLER)
#define SATTR  (AT_RDO|AT_HID|AT_SYS|AT_DIR)
#define DATTR  (AT_DIR|AT_SYS)

/* bit masks for directory attributes */
#define AT_RDO    0x01     /* read-only                              */
#define AT_HID    0x02     /* hidden file                            */
#define AT_SYS    0x04     /* system file                            */
#define AT_VOL    0x08     /* volume label                           */
#define AT_DIR    0x10     /* directory, Also Known As "folder"      */
#define AT_ARC    0x20     /* archival purposes                      */

/* Some portability definitions */
#define BYTE    char
#define WORD    int
#define LONG	long
#define TRUE    1
#define FALSE   0

/* ------ Data Structures --------------------------------------------- */

typedef struct dta_str     /* Disk Transfer Address (DTA) structure     */
   {
   BYTE res[ 21 ];         /* reserved by TOS                           */
   BYTE attr;              /* attribute byte                            */
   WORD time;              /* time stamped on file                      */
   WORD date;              /* date stamped on file                      */
   LONG size;              /* size in bytes of file                     */
   BYTE name[ 14 ];        /* filename, extension & terminating 0 (+1)  */
   } DTA;
typedef struct fl_str
   {
   struct fl_str *next;    /* In our Found file list will point to next */
   BYTE attr;              /* attribute byte                            */
   WORD time;              /* time stamped on file                      */
   WORD date;              /* date stamped on file                      */
   LONG size;              /* size in bytes of file                     */
   BYTE spec[ MAXSPEC ];   /* complete file extension                   */
   } FL;
typedef struct bl_str
   {
   struct bl_str *next;    /* next allocated block of list members      */
   struct fl_str *first;   /* first of ALLOCNUM entries                 */
   } BL;

/* ---- Function declarations for functions in this program  ---------  */

BYTE *DJMalloc();     
WORD HndlFound();
WORD Browse();
WORD DoCForm();
WORD ValidSpec();           
WORD AddList();
WORD InitWindows();
WORD ReDraw();
WORD RefrText();
WORD LoadFile();
WORD RefrLine();
WORD RefrEntry();
WORD RefrBackground();
WORD RefrList();
WORD PrintList();
WORD PrintLine();           
WORD DoFile();              
WORD copyfile();
WORD movefile();
WORD printfile();
WORD delfile();
WORD renamefile();
WORD GetBack();
WORD GetHeap();
WORD BufToLine();
WORD CalcSlidPos();
WORD FinishFile();
LONG Search();       
void Init();
void InitGEM();
void AdjustResources();
void ToHigh();
void Interact();
void StartForm();
void OpenWork();     
void DoSearch();     
void EndSearch();    
void FreeBlocks();   
void FreeHeap();     
void Select();
void DeSelect();
void SetSlidSize();
void CalcRange();
void CalcStart();
void AsgnText();
void BeginWait();
void EndWait();
void CloseCBox();
void FmtTime();
void FmtDate();
void LineUp();
void LineDown();
void main();

/* ----- More function defs ---- Functions external to this module ---- */
BYTE *strpbrk();

/* --------- Miscellaneous Global Variables --------------------------- */

BYTE filespec[ MAXSPEC ];  /* search filespec (default: *.*)            */
BYTE fullname[ MAXSPEC ];  /* full file specification of found file     */
BYTE alert_box[255];       /* For creation of form_alert strings        */
BYTE title[] = "  File Search";     /* Accessory title                  */
BYTE consearch[] = "Continue Search"; /* button text for f_form[]       */
BYTE drv_let;              /* Letter of selected disk drive for search  */
BYTE wind_name[ MAXSPEC ], wind_desc[ 81 ]; /* browse window stuff      */
BYTE *pagetext[ MAXLINES ];      /* browse window text pointers         */
BYTE *djheap, *heap_ptr;      /* Memory allocation for browse window    */
WORD gl_apid, menu_id;     /* desk accessory ID variables               */
WORD display_on;           /* 1 if matches are to be displayed, else 0  */
WORD waiting;              /* 1 if a "wait" box is onscreen             */
WORD filez;                /* number of files found on each search      */
WORD foldz;                /* Number of folders searched on each search */
WORD cur_drv;              /* number for current drive (A=0,B=1,etc)    */
WORD last_path;            /* 0 or index in filespec of last \          */
WORD num_lines, l_start, l_end, l_range, page_size;   /* browse stuff   */
WORD slidpos, slidsize, newslid; /* browse window sliders               */
WORD left_in_block = 0;    /* number of available file entry slots      */
WORD mfdb[10];             /* I quote:  "fake" raster block             */
WORD bw_handle;            /* Background window handle                  */
WORD x_mx,y_mx,w_mx,h_mx,bx_wk,by_wk,bw_wk,bh_wk; /* window dimensions  */
WORD browsing;             /* TRUE if browse window opened, 0 if not    */
WORD memerror;             /* TRUE if couldn't keep all files in mem.   */
WORD contrl[12],                 /* Global GEM variables                */
     intin[256], intout[256],
     ptsin[256], ptsout[256],
     work_in[20], work_out[100],
     handle;                     /* Screen handle                       */
WORD msgbuf[ 8 ];                /* AES message buffer                  */
WORD gr_x, gr_y, gr_w, gr_h;     /* Workstation dimensions              */
WORD cwidth, cheight;            /* Current character cell height,width */
WORD wret;                 /* Junk variable -- global to save stack     */
WORD back_color = 3;       /* Background window color                   */
LONG bytez;                /* total number of bytes per search          */
LONG heap_avail = 0L;      /* Our program's "heap" bytes available      */
GRECT waitbox, c_box;		 /* GEM rectangles used globally        */
DTA dta;                   /* Our program's Data Transfer Area          */
FL *list_head;             /* will point to first in Found File list    */
FL *next_file;             /* Next list member available in cur. block  */
BL *cur_block=NULL, *block_head=NULL;               /* Allocated blocks */

/* ---------- GEM Resources for File Search --------------------------- */
TEDINFO ted2[] = 
{   "--------------------------------------------------",
   "__________________________________________________",
   "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
     3,  6,  0,0x1180,  0, -1, 51, 51
};
TEDINFO ted3[] = 
{   "FILE SEARCH",
   "",   "",
     3,  6,  2,0x2103,  0,  2, 12,  1
};
TEDINFO ted4[] = 
{   "File To Search For:",
   "",   "",
     3,  6,  0,0x1100,  0, -1, 20,  1
};
TEDINFO 
ted5[] = 
{   "Wilcards (? and *) Are Acceptable",
   "",   "",
     5,  6,  0,0x1100,  0, -1, 34,  1
};
TEDINFO ted8[] = 
{   "Attributes:",
   "",   "",
     3,  6,  0,0x1200,  0, -1, 12,  1
};
TEDINFO ted9[] = 
{   "Put Filename Herexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "",   "",
     3,  6,  0,0x1100,  0, -1, 56,  1
};
TEDINFO ted10[] = 
{   "Bytesxxxxx",
   "",   "",
     3,  6,  0,0x1100,  0, -1, 11,  1
};
TEDINFO ted11[] = 
{   "mmddyyyy",
   "",   "",
     3,  6,  0,0x1100,  0, -1,  9,  1
};
TEDINFO ted12[] = 
{   "hh:mm:ss",
   "",   "",
     3,  6,  0,0x1100,  0, -1,  9,  1
};
TEDINFO ted13[] = 
{   "Bytes :",
   "",   "",
     3,  6,  0,0x1200,  0, -1,  8,  1
};
TEDINFO ted14[] = 
{   "Last Updated:",
   "",   "",
     3,  6,  0,0x1200,  0, -1, 14,  1
};
TEDINFO ted16[] = 
{   "XXX",
   "",   "",
     3,  6,  0,0x1280,  0, -1,  4,  1
};
TEDINFO ted18[] = 
{   "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
   "",   "",
     3,  6,  0,0x1280,  0, -1, 53,  1
};
TEDINFO ted19[] = 
{   "FILE FOUND:",
   "",   "",
     3,  6,  0,0x21E3,  0, -1, 12,  1
};
TEDINFO ted20[] = 
{   "File Name",
   "",   "",
     3,  6,  0,0x1200,  0, -1, 10,  1
};
TEDINFO ted24[] = 
{   "Source Filexxxxxxxxxxxxxxxxxxxxxxxx:",
   "",   "",
     3,  6,  0,0x1100,  0, -1, 37,  1
};
TEDINFO ted25[] = 
{   "Destinationxxxxxxxxxxxxxxxxxxxxxxx:",
   "",   "",
     3,  6,  0,0x1100,  0, -1, 36,  1
};
TEDINFO ted26[] = 
{   "----------------------------------------",
   "________________________________________",
   "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",  /* only TOS filenames */
     3,  6,  0,0x1180,  0, -1, 41, 41
};
TEDINFO ted27[] = 
{   "----------------------------------------",
   "________________________________________",
   "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
     3,  6,  0,0x1180,  0, -1, 41, 41
};
TEDINFO ted28[] = 
{   "File Copyxxxxxxxxxx",
   "",   "",
     3,  6,  2,0x2200,  0, -1, 20,  1
};
/* File Search dialog */
OBJECT s_form[] = 
{
   {  -1,  1, 31,     G_BOX,  0, 16,  0xFC2143L, 72,  8,424, 136  },
   {  19,  2, 18,    G_IBOX,  0,  0,    0x1100L,  6, 51,158,  56  },
   {   3, -1, -1,  G_STRING,  0,  0,"Drive To Search:",  0,  3, 128,  8  },
   {   4, -1, -1, G_BOXCHAR, 17,  0,0x41FF1100L, 16, 16, 32,  8  },
   {   5, -1, -1, G_BOXCHAR, 17,  0,0x42FF1100L, 48, 16, 32,  8  },
   {   6, -1, -1, G_BOXCHAR, 17,  0,0x43FF1100L, 80, 16, 32,  8  },
   {   7, -1, -1, G_BOXCHAR, 17,  0,0x44FF1100L,112, 16, 32,  8  },
   {   8, -1, -1, G_BOXCHAR, 17,  0,0x45FF1100L, 16, 25, 32,  8  },
   {   9, -1, -1, G_BOXCHAR, 17,  0,0x46FF1100L, 48, 25, 32,  8  },
   {  10, -1, -1, G_BOXCHAR, 17,  0,0x47FF1100L, 80, 25, 32,  8  },
   {  11, -1, -1, G_BOXCHAR, 17,  0,0x48FF1100L,112, 25, 32,  8  },
   {  12, -1, -1, G_BOXCHAR, 17,  0,0x4AFF1100L, 48, 34, 32,  8  },
   {  13, -1, -1, G_BOXCHAR, 17,  0,0x4BFF1100L, 80, 34, 32,  8  },
   {  14, -1, -1, G_BOXCHAR, 17,  0,0x4CFF1100L,112, 34, 32,  8  },
   {  15, -1, -1, G_BOXCHAR, 17,  0,0x4DFF1100L, 16, 43, 32,  8  },
   {  16, -1, -1, G_BOXCHAR, 17,  0,0x4EFF1100L, 48, 43, 32,  8  },
   {  17, -1, -1, G_BOXCHAR, 17,  0,0x4FFF1100L, 80, 43, 32,  8  },
   {  18, -1, -1, G_BOXCHAR, 17,  0,0x50FF1100L,112, 43, 32,  8  },
   {   1, -1, -1, G_BOXCHAR, 17,  0,0x49FF1100L, 16, 34, 32,  8  },
   {  20, -1, -1,   G_FTEXT,  9,  0,      ted2,  6, 43,400,  8  },
   {  21, -1, -1, G_BOXTEXT,  5, 32,      ted3,  8,  8,400, 16  },
   {  22, -1, -1,  G_STRING,  0,  0,"File To Search For:",  8, 32,152,  8  },
   {  23, -1, -1,    G_TEXT,  0,  0,      ted5,210, 31,198,  8  },
   {  24, -1, -1,  G_BUTTON,  7,  0,  "SEARCH",112,112, 88, 16  },
   {  25, -1, -1,  G_BUTTON,  5,  0,"QUIT",216,112, 88, 16  },
   {  29, 26, 28,    G_IBOX,  0,  0,0x1100L,155, 52,156, 60  },
   {  27, -1, -1,  G_BUTTON, 17,  1,"Each Match", 29, 14, 99,  9  },
   {  28, -1, -1,  G_STRING,  0,  0,   "Report:", 19,  2, 56,  8  },
   {  25, -1, -1,  G_BUTTON, 17,  0,"Totals Only", 28, 28,100,  8  },
   {  30, -1, -1,  G_STRING,  0,  0,"Files Found:",307, 54, 96,  8  },
   {  31, -1, -1,  G_BUTTON,  5,  8,"Browse",      321, 67, 64,  8  },
   {   0, -1, -1,  G_BUTTON, 37,  8,"Print",       322, 80, 64,  8  }
};
/* File Found Dialog */
OBJECT f_form[] = 
{
   {  -1,  1, 25,     G_BOX,  0, 16, 0xFF21C3L, 64,  8,472,160  },
   {  13,  2, 12,    G_IBOX,  0,  0,   0x1100L,  8, 24,448, 48  },
   {   3, -1, -1,    G_TEXT,  0,  0,      ted8,   0, 12, 88,  8  },
   {   4, -1, -1,  G_BUTTON,  0,  0,"Read-Only",  8, 23, 80,  8  },
   {   5, -1, -1,  G_BUTTON,  0,  0,"Hidden",    88, 23, 80,  8  },
   {   6, -1, -1,  G_BUTTON,  0,  0,"System",   168, 23, 80,  8  },
   {   7, -1, -1,  G_BUTTON,  0,  0,"Volume",     8, 32, 80,  8  },
   {   8, -1, -1,  G_BUTTON,  0,  0,"Folder",    88, 32, 80,  8  },
   {   9, -1, -1,  G_BUTTON,  0,  0,"Archive",  168, 32, 80,  8  },
   {  10, -1, -1,    G_TEXT,  0,  0,     ted9,    8,  2,440,  8  },
   {  11, -1, -1,    G_TEXT,  0,  0,    ted10,  329, 33, 80,  8  },
   {  12, -1, -1,    G_TEXT,  0,  0,    ted11,  280, 24, 64,  8  },
   {   1, -1, -1,    G_TEXT,  0,  0,    ted12,  361, 24, 64,  8  },
   {  14, -1, -1,    G_TEXT,  0,  0,    ted13,  269, 57, 56,  8  },
   {  15, -1, -1,    G_TEXT,  0,  0,    ted14,  269, 37,104,  8  },
   {  20, 16, 19,     G_BOX,  0, 32, 0x12113L,    8, 72,448, 32  },
   {  17, -1, -1,  G_STRING,  0,  0,"Found So Far:",7, 21,104,  8  },
   {  18, -1, -1,    G_TEXT,  0,  0,    ted16,  126, 22, 24,  8  },
   {  19, -1, -1,  G_STRING,  0,  0,"File Search Specification Was:",
                                                  5,  2,240,  8  },
   {  15, -1, -1,    G_TEXT,  0,  0,    ted18,   21, 11,416,  8  },
   {  21, -1, -1,  G_BUTTON,  7,  0,consearch,   16,144,136,  8  },
   {  22, -1, -1,  G_BUTTON,  5,  0,"Quit",     384,144, 72,  8  },
   {  23, -1, -1,  G_BUTTON,  5,  0,"Return To Search Menu",168,144,208,  8  },
   {  24, -1, -1, G_BOXTEXT,  0, 32,    ted19,    8,  0, 88,  8  },
   {  25, -1, -1,    G_TEXT,  0,  0,    ted20,    8, 16, 72,  8  },
   {   0, 26, 33,     G_BOX,  0, 32,0xFF2113L,    8,112,448, 24  },
   {  27, -1, -1,  G_STRING,  0,  0,"Function:",    6, 13, 72,  8  },
   {  28, -1, -1,  G_BUTTON,  5,  0,"Browse",   104,  8, 56,  8  },
   {  29, -1, -1,  G_BUTTON,  5,  0,"Rename",   168,  8, 56,  8  },
   {  30, -1, -1,  G_BUTTON,  5,  0,"Copy",     232,  8, 48,  8  },
   {  31, -1, -1,  G_BUTTON,  5,  0,"Delete",   336,  8, 48,  8  },
   {  32, -1, -1,  G_BUTTON,  5,  0,"Move",     288,  8, 40,  8  },
   {  33, -1, -1,  G_BUTTON,  5,  0,"Print",    392,  8, 48,  8  },
   {  25, -1, -1,  G_STRING, 32,  0,   "TOS",    27,  4, 24,  8  }
};
/* "Searching..." form */
OBJECT w_form[] = 
{
   {  -1,  1,  1,     G_BOX,  0, 48,0xFE2263L,120, 16,256, 40  },
   {   0, -1, -1,  G_STRING, 32,  0,"Searching...", 16, 24, 96,  8  }
};
/* c_form[] gets information about two filespecs for copy, move, etc. */
OBJECT c_form[] = 
{
   {  -1,  1,  7,     G_BOX,  0, 48,   0x12203L, 56,  8,352, 88  },
   {   2, -1, -1,    G_TEXT,  0,  0,      ted24, 16, 24,288,  8  },
   {   3, -1, -1,    G_TEXT,  0,  0,      ted25, 16, 48,280,  8  },
   {   4, -1, -1,   G_FTEXT,  8,  0,      ted26, 16, 32,320,  8  },
   {   5, -1, -1,   G_FTEXT,  9,  0,      ted27, 16, 56,320,  8  },
   {   6, -1, -1, G_BOXTEXT,  0, 32,      ted28, 16,  8,320,  8  },
   {   7, -1, -1,  G_BUTTON,  7,  0,       "OK", 72, 72, 64,  8  },
   {   0, -1, -1,  G_BUTTON, 37,  0,   "CANCEL",216, 72, 64,  8  }
};
/* "Loading..." form */
OBJECT l_form[] = 
{
   {  -1,  1,  2,     G_BOX,  0, 48, 0x12143L, 24,  8,248, 40  },
   {   2, -1, -1,  G_STRING,  0,  0,"Loading...", 16,  8, 80,  8  },
   {   0, -1, -1,     G_BOX, 32,  0,0xFF1101L, 16, 24,216,  8  }
};

/* ------- form_alert() strings --------------------------------------- */

BYTE nomem[]     = "[1][ Error: | Not Enough Memory | For Browse ][ CANCEL ]";
BYTE filerr[]    = "[1][ Error: | The File Could Not| Be Opened ][ CANCEL ]";
BYTE crerror[]   = "[1][ Error: | File Creation Failed ][ CANCEL ]";
BYTE badwrite[]  = "[3][ File Write Error: ][ Retry | CANCEL ]";
BYTE badcopy[]   =
"[1][ Destination Same As Source | Copy/Move Not Allowed ][ CANCEL ]";
BYTE movexist[]  =
"[1][ You May Not | Move A File To | An Existing File ][ CANCEL ]";
BYTE notfound[] =
"[0][ No Files Were Found | Matching That Specification. ][ Thanks | Repeat ]";
BYTE delerror[] =
"[1][ An Error Occurred When | Attempting To Delete The File ][ OK ]";
BYTE suredel[] =
"[2][ Are You SURE | You Want To Delete | The File? ][ YES | CANCEL ]";
BYTE badrename[] = "[1][ The Rename Operation Failed ][ OK ]";
BYTE copywarn[] =
"[1][ WARNING:  Destination File | Will Be Overwritten ][ OK | CANCEL ]";
BYTE no_windows[] = "[1][ No Windows Available ][ CANCEL ]";
BYTE prnerror[] = "[1][ The Printer Is Not Responding ][ Retry | CANCEL ]";
BYTE badspec[] =
"[1][ You Have Entered | An Invalid | File Specification ][ CANCEL ]";
BYTE badname[] =
"[1][ File Specification | Contains An Invalid | File/Folder Name ][ CANCEL ]";
BYTE badext[] =
"[1][ File Specification | Has An Invalid | File/Folder Extension ][ CANCEL ]";
BYTE badwild[] =
"[1][ Wildcards | Are Not Supported | Within Folder Names ][ Re-Enter ]";
BYTE baddrive[] = "[1][ You Have Selected | An Invalid Drive ][ CANCEL ]";
BYTE BadAdd[] =
"[0][ WARNING: | Insufficient Memory | To Keep All | Files In List ][ Go On ]";
BYTE whodunit[] =
"[0][         File Search         |     by David T. Jarvis     |\
Copyright 1989 Antic Publishing, Inc.\
][ Yeah! ]";


/* --------- Main function --------------------------------------------- */

void main()
{
/* Initialize everything */
   Init();
/* handle interaction with GEM and the user */
   Interact();
}

/* -------- Initialization functions ---------------------------------- */

void Init()
{
   InitGEM();
   browsing = FALSE;
   s_form[ SDRIVEA+(WORD)Dgetdrv() ].ob_state |= SELECTED;
   AsgnText( s_form,SFILE,filespec );
   filespec[ 0 ] = '\0';
   mfdb[0] = mfdb[1] = 0;
   AdjustResources();
   /* Install desk accessory */
   menu_id = menu_register( gl_apid,title );
}

void InitGEM()
{
/* Initialize GEM application */
   gl_apid = appl_init();
   handle = graf_handle( &gr_x,&gr_y,&gr_w,&gr_h );
}

/* AdjustResources() checks for high resolution and adjusts the 
   resource offsets accordingly if it is being used */
void AdjustResources()
{
   if (Getrez()==2)            /* high resolution */
      {
      ToHigh( s_form,32 );
      ToHigh( f_form,34 );
      ToHigh( c_form,8 );
      ToHigh( l_form,3 );
      ToHigh( w_form,2 );  
      back_color = 0;         /* white background if in monochrome */
      }
}

void ToHigh( form,num )
OBJECT form[];
WORD num;
{
register WORD i;

   for (i=0; i<num; i++)
      {
      form[ i ].ob_y *= 2;
      form[ i ].ob_height *= 2;
      }
}

WORD InitWindows()
{
/* Set maximum size of all windows to desktop size */
   wind_get(0,4,&x_mx,&y_mx,&w_mx,&h_mx);

/* Calculate working area for background window using size it'll be opened as */
   wind_calc(1,0,x_mx,y_mx,w_mx,h_mx,
             &bx_wk,&by_wk,&bw_wk,&bh_wk);

/* Create the big background window */
   if ((bw_handle = wind_create( 0,x_mx,y_mx,w_mx,h_mx )) < 0)
      {
      form_alert(1,no_windows);
      return(-1);
      }
   return( 0 );
}

void OpenWork()
{
WORD attrib[ 10 ];
register WORD i;

   for (i=0; i < 10; i++)
      work_in[ i ] = 1;
   work_in[ 10 ] = 2;
   v_opnvwk( work_in,&handle,work_out );
   vqt_attributes( handle,attrib );
   cwidth = attrib[ 8 ];      cheight = attrib[ 9 ];
}

/* ----------- Interact() -- drives the desk accessory -------------- */
void Interact()
{
WORD event, clik_x, clik_y, num_cliks, bstate, kstate, keycode;

   /* Infinitely check for messages related to this accessory */
   while (TRUE)
      {
      event = evnt_multi(MU_MESAG,0,0,0,
                         0,0,0,0,0,
                         0,0,0,0,0,
                         msgbuf,0,0,
                         &clik_x,&clik_y,&bstate,
                         &kstate,&keycode,&num_cliks );

      /* If the user clicked on the accessory name, run */
      if (event & MU_MESAG)
         {
         switch( msgbuf[0] )
            {
            case AC_OPEN:
               if (msgbuf[4] == menu_id)
                  {
                  OpenWork();
                  DoSearch();
                  v_clsvwk( handle );
                  }
               break;
            default:
               break;
            }
         }
      }  /* end while loop */
}

/* --------------------------------------------------------------------- */
/*    DoSearch() inputs the search criteria, performs the searches, and  */
/*    reports the results						 */
/* --------------------------------------------------------------------  */
void DoSearch()
{
BYTE startdir[ MAXSPEC ];
WORD clip[4], retry;
register WORD button, i;
register LONG drives, bittest, ret = 0L;
GRECT box;

   /* Put current system values into the search form */
   drives = Drvmap();
   for (bittest = 1L,i = 0; i<16; bittest *= 2L,i++)
      {
      if ((WORD)(bittest & drives))
         s_form[ SDRIVEA+i ].ob_state &= ~DISABLED;
      else
         {
         s_form[ SDRIVEA+i ].ob_state = DISABLED;
         s_form[ SDRIVEA+i ].ob_state &= ~SELECTED;
         }
      }
   s_form[ SBROWSE ].ob_state = DISABLED;
   s_form[ SPRINT ].ob_state = DISABLED;

   /* Open & clear a window enclosing the entire desktop */
   if (InitWindows())
      return;
   wind_open( bw_handle,x_mx,y_mx,w_mx,h_mx );
   graf_mouse( M_OFF,0 );
   clip[0] = bx_wk;        clip[1] = by_wk;
   clip[2] = bw_wk;        clip[3] = bh_wk + cheight + 2;
   vs_clip( handle,1,clip );
   vsf_interior( handle,2 );
   vsf_style( handle,8 );
   vsf_color( handle,3 );
   v_bar( handle,clip );
   graf_mouse( M_ON,0 );

   while (TRUE)
      {
      /* Display the search criteria input form */
      StartForm( s_form,&box,2,1,1 );

      /* Let the user take over */
      button = form_do( s_form,SFILE );

      /* Remove the form and restore altered states */
      s_form[ button ].ob_state &= ~SELECTED;
      form_dial( FMD_SHRINK,0,0,0,0,
                 box.g_x,box.g_y,box.g_w,box.g_h );
      form_dial( FMD_FINISH,0,0,0,0,box.g_x,box.g_y,box.g_w,box.g_h );

      /* Check which button the user pressed */
      switch( button )
         {
         /* If they clicked on the title, time to point fingers */
         case 20:
            form_alert( 1,whodunit );
            break;
         /* If the user is finished, clean up and go */
         case SCANCEL:
            wind_close( bw_handle );
            wind_delete( bw_handle );
            FreeBlocks();
            return;
            break;
         case SBROWSE:
            Browse( filespec,0 );
            break;
         case SPRINT:
            PrintList();
            break;
         default:
            /* Validate the file spec -- if necessary, perform some
               formatting on it & select the disk drive */
            if (ValidSpec( filespec )==FALSE)
               break;
            /* Determine whether to display each file match or not */
            display_on = (s_form[ SALL ].ob_state & SELECTED) ? 1 : 0;

            /* Initialize search variables */
            FreeBlocks();
            startdir[ 0 ] = drv_let;
            startdir[ 1 ] = ':';
            startdir[ 2 ] = '\0';
            if (last_path)
               {
               strncat( startdir,filespec,last_path );
               startdir[ last_path+2 ] = '\0';
               }
            filez = foldz = 0;       	bytez = 0L;
            memerror = FALSE;

            /* Recursively search all directories for matches */
            do
               {
               retry = 0;
               if (last_path)
                  ret = Search( startdir,filespec+last_path );
               else
                  ret = Search( startdir,filespec );
               if (ret == -2L)
                  {
                  wind_close( bw_handle );
                  wind_delete( bw_handle );
                  FreeBlocks();
                  return;
                  }
               if (!filez)
                  retry = form_alert( 1,notfound );
               else
                  if (ret > 1L)
                     EndSearch( filez,drv_let );
               if (memerror)
                  form_alert( 1,BadAdd );
               } while (retry == 2);
            ReDraw( bw_handle,bx_wk,by_wk,bw_wk,bh_wk,0 );
            break;
         }  /* end, switch */
      }  /* while TRUE */
}

/* --------------------------------------------------------------------- */
/* HndlFound() is invoked, if the user has requested that each match     */
/* be reported, after a match is found on the current search.  It uses   */
/* the "found" dialog (f_form) to display information about the file and */
/* offers the user several choices for the next action: continue the     */
/* current search, start a new search, exit from the accessory or        */
/* perform one of the following file operations on the found file:       */
/* copy, move, delete, rename, browse, or print.                         */
/* This function may also be invoked when the user selects, with the     */
/* mouse, a file from the list of files found in the last search.  If    */
/* this is the case, the fromlist argument will equal one.               */
/* --------------------------------------------------------------------- */
WORD HndlFound( dtaptr,fullname,files,fromlist )
DTA *dtaptr;
BYTE *fullname;
WORD files, fromlist;
{
register BYTE bittest;
BYTE dbuff[ 11 ], tbuff[ 11 ], bbuff[ 11 ], fbuff[ 4 ];
register WORD button, i;
GRECT box;

   /* Copy the file information onto the form */
   AsgnText( f_form,FFILE,fullname );
   AsgnText( f_form,FSPEC,filespec );
   FmtTime( dtaptr->time,tbuff );
   FmtDate( dtaptr->date,dbuff );
   sprintf( bbuff,"%8lu",dtaptr->size );
   AsgnText( f_form,FTIME,tbuff );
   AsgnText( f_form,FDATE,dbuff );
   AsgnText( f_form,FBYTES,bbuff );
   for (bittest = 1, i = 0; bittest < 32; bittest *= 2,i++)
      if (dtaptr->attr & bittest)
         f_form[ FREADONL+i ].ob_state = SELECTED;
      else
         f_form[ FREADONL+i ].ob_state = DISABLED;
   sprintf( fbuff,"%d",files );
   AsgnText( f_form,FMATCHES,fbuff );

   /* if necessary, clear the "waiting" box */
   if (waiting)
      EndWait();

   /* For files, enable the file manipulation options;  for folders, disable */
   if (dtaptr->attr & AT_DIR)
      for (i=FBROWSE; i<=FPRINT; i++)
         f_form[ i ].ob_state |= DISABLED;
   else
      for (i=FBROWSE; i<=FPRINT; i++)
         f_form[ i ].ob_state &= ~DISABLED;
   /* Most TOS file ops are not supported for a file selected from the list */
   if (fromlist)
      for (i=FBROWSE; i<FPRINT; i++)
         f_form[ i ].ob_state |= DISABLED;

   /* Get the form started on screen */
   StartForm( f_form,&box,2,0,0 );

   /* Let the user handle the form */
   while (1)
      {
      objc_draw( f_form,0,2,box.g_x,box.g_y,box.g_w,box.g_h );
      button = form_do( f_form,0 );
      f_form[ button ].ob_state &= ~SELECTED;
      objc_change(f_form,button,0,box.g_x,box.g_y,box.g_w,box.g_h,NORMAL,1);
      /* handle TOS functions here */
      switch( button )
         {
         case FBROWSE:     Browse( fullname,1 );
                           break;
         case FRENAME:     renamefile( fullname );
                           break;
         case FCOPY:       copyfile( fullname );
                           break;
         case FMOVE:       movefile( fullname );
                           break;
         case FDELETE:     if (!delfile( fullname ))
                              for (i=FBROWSE; i<=FPRINT; i++)
                                 f_form[ i ].ob_state |= DISABLED;
                           break;
         case FPRINT:      printfile( fullname );
                           break;
         default:
            /* Remove the form and restore altered states */
            form_dial( FMD_FINISH,0,0,0,0,box.g_x,box.g_y,box.g_w,box.g_h );
            /* Let the calling function handle other choices */
            return( button );
         }     /* end, switch */
      }     /* end, while */
}

/* --------------------------------------------------------------------- */
/* DoFile() lets the user examine information and perform operations on  */
/* a file which was found in the last search.  The file has been         */
/* selected from the Browse() window.                                    */
/* --------------------------------------------------------------------- */
WORD DoFile( which )
WORD which;
{
register WORD i;
register FL *next;
DTA dta2;

   /* find the entry */
   next = list_head;
   for (i=0; i<which; i++)
      {
      if (next == NULL)
         return( -1 );
      next = next->next;
      }
   /* set up the "fake" DTA */
   strcpy( dta2.name,"Listed" );
   dta2.size = next->size;
   dta2.time = next->time;
   dta2.date = next->date;
   dta2.attr = next->attr;
   /* Modify the found file dialog slightly */
   f_form[ FNEXT ].ob_spec = (LONG)"Return To List";
   f_form[ FDONE ].ob_state |= DISABLED;
   f_form[ FANOTHER ].ob_state |= DISABLED;
   /* display the file information */
   HndlFound( &dta2,next->spec,filez,1 );
   /* Get the form back to normal */
   f_form[ FNEXT ].ob_spec = (LONG)consearch;
   f_form[ FDONE ].ob_state &= ~DISABLED;
   f_form[ FANOTHER ].ob_state &= ~DISABLED;
   return(0);
}

/* --------- Miscellanous GEM utility functions ------------------- */

WORD DoCForm( workfile,dest,flag )
BYTE workfile[],dest[];
WORD flag;
{
register WORD button;

   switch( flag )
      {
      case 0:
         AsgnText( c_form,CTITLE,"File Rename" );
         AsgnText( c_form,CT1,"Current Name:" );
         AsgnText( c_form,CT2,"New Name:" );
         break;
      case 1:
         AsgnText( c_form,CTITLE,"File Copy" );
         AsgnText( c_form,CT1,"Source File:" );
         AsgnText( c_form,CT2,"Destination File:" );
         break;
      case 2:
         AsgnText( c_form,CTITLE,"File Move" );
         AsgnText( c_form,CT1,"Source File:" );
         AsgnText( c_form,CT2,"Destination File:" );
         break;
      default:
         break;
      }     /* end switch */
   c_form[ CT1 ].ob_flags &= ~EDITABLE;

   /* Set the form to point to the source and destination strings */
   AsgnText( c_form,CSOURCE,workfile );
   AsgnText( c_form,CDEST,dest );
   dest[ 0 ] = '\0';

   /* Put up the form */
   StartForm( c_form,&c_box,2,0,1 );

   /* Let the user take over */
   button = form_do( c_form,CDEST );

   /* Remove the form and restore altered states */
   c_form[ button ].ob_state &= ~SELECTED;
   objc_change( c_form,button,0,c_box.g_x,c_box.g_y,c_box.g_w,c_box.g_h,
                NORMAL,1 );

   /* If the user changed their mind, exit */
   if (button == CCANCEL)
      return(-1);
   /* Otherwise, make sure both file names are complete */
   FinishFile( workfile );
   FinishFile( dest );
   return( 0 );
}

void CloseCBox()
{
   form_dial( FMD_FINISH,0,0,0,0,c_box.g_x,c_box.g_y,c_box.g_w,c_box.g_h );
}

void EndSearch( count,drive )
WORD count;
BYTE drive;
{
BYTE temp[ 81 ];

	sprintf( alert_box,
                 "[0][ Search Completed On Drive %c | With %d Match(es) | ",
                 drive,count );
        sprintf( temp,"Comprising %lu Byte(s). | ",bytez );
        strcat( alert_box,temp );
        sprintf( temp,"%d Folder(s) Searched. ][ Great! ]",foldz );
        strcat( alert_box,temp );
	form_alert( 1,alert_box );
}

/* AsgnText() -- assign a string to a TEDINFO structure */
/* Or, TEDINFO's excellent adventure ?... */
void AsgnText( form,field,string )
OBJECT *form;
WORD field;
BYTE string[];
{
register TEDINFO *ted_ptr; 

   ted_ptr = (TEDINFO *)form[ field ].ob_spec;
   ted_ptr->te_ptext = (unsigned BYTE *)string;
}

void StartForm( form,box,level,flag1,flag2 )
OBJECT *form;
GRECT *box;
WORD level,flag1,flag2;
{
   form_center( form,&(box->g_x),&(box->g_y),
                &(box->g_w),&(box->g_h) );
   form_dial( FMD_START,0,0,0,0,
              box->g_x,box->g_y,box->g_w,box->g_h );
   if (flag1)
      form_dial( FMD_GROW,0,0,0,0,box->g_x,box->g_y,box->g_w,box->g_h );
   if (flag2)
      objc_draw( form,0,level,box->g_x,box->g_y,box->g_w,box->g_h );
}

/* BeginWait() and EndWait() enable and disable, respectively, the
   appearance of the "Searching..." box on the screen while 
   a new directory is being searched
*/
void BeginWait()
{
   StartForm( w_form,&waitbox,2,0,1 );
   waiting = 1;
}

void EndWait()
{
   form_dial( FMD_FINISH,0,0,0,0,waitbox.g_x,waitbox.g_y,
              waitbox.g_w,waitbox.g_h );
   waiting = 0;
}

/* -------- Search() -- the recursive search routine called from DoSearch() */

LONG Search( s,m )
BYTE s[], m[];
{
BYTE news[ MAXSPEC ];            /* new search string */
BYTE dsearch[ MAXSPEC ];         /* directory search string */
BYTE save[ MAXSPEC ];            /* where we were before */
register LONG ret;               /* return code, call to self */
register LONG f_count = 0L;      /* count of matches */
register LONG flags = 0L;        /* return value of BIOS functions */
register DTA *olddta;            /* save this and restore at end */

   /* Every call to Search() searches another folder (or the root) */
   foldz++;

   /* build search string */
   strcpy( news,s );
   if (m[0] != '\\')
      strcat( news,"\\" );
   strcat( news,m );

   /* Set Disk Transfer Address, saving old one */
   olddta = (struct dta_str *)Fgetdta();
   Fsetdta( &dta );

   /* Find first matching file */
   flags = Fsfirst( news,SATTR );

   /* As long as matches exist, find NEXT matching file */
   while (!flags)
      {
      /* Is this a directory? */
      if (dta.name[0] == '.')
         {
         flags = Fsnext();
         continue;
         }
      /* Build the full name of the file */
      strcpy( fullname,s );
      strcat( fullname,"\\" );
      strcat( fullname,dta.name );
      /* Increase file counts, byte counts */
      f_count++;
      filez++;
      bytez += dta.size;
      /* If all matches are to be reported, report & handle */ 
      if (display_on)
         wret = HndlFound( &dta,fullname,filez,0 );
      /* Add this file's info to the list in memory */
      if (AddList( &dta,fullname ))
         memerror = TRUE;
      else
         {
         /* Files found -- enable browse & print list options */
         s_form[ SBROWSE ].ob_state &= ~DISABLED;
         s_form[ SPRINT ].ob_state  &= ~DISABLED;
         }
      /* Take next action depending on what user selected */
      if (display_on)
         switch( wret )
            {
            case FANOTHER: Fsetdta( olddta ); return( -1L );
            case FDONE:    Fsetdta( olddta ); return( -2L );
            default:       break;
            }        /* end, switch */
      flags = Fsnext();
      }

   /* Now, search for subdirectories -- find FIRST */
   strcpy( dsearch,s );
   strcat( dsearch,"\\*.*" );
   flags = Fsfirst( dsearch,(WORD)DATTR );

   /* Search each directory found for matching files */
   while (!flags)
      {
      if ((dta.attr & AT_DIR)&&(dta.name[ 0 ] != '.'))
         {
         if (!waiting)
            BeginWait();
         strcpy( news,s );
         strcat( news,"\\" );
         strcat( news,dta.name );
         strcpy( save,dta.name );
         ret = Search( news,m );
         if (ret < 0L)
            {
            Fsetdta( olddta );
            return( ret );
            }
         else
            f_count += ret;
         GetBack( dsearch,save );
         }
      flags = Fsnext();
      }
   /* Restore old DTA */
   Fsetdta( olddta );

   /* Return number of matches, this directory */
   return( f_count );
}

/* GetBack() returns to us to the previous directory position */
WORD GetBack( s,m )
BYTE s[], m[];
{
register LONG flags;

   flags = Fsfirst( s,(WORD)DATTR );
   while ((!flags)&&(strcmp( dta.name,m )))
      flags = Fsnext();
   return(0);
}

/* ------------- File manipulation functions ------------------------ */

WORD copyfile( workfile )
BYTE workfile[];
{
BYTE destfile[ MAXSPEC ], buffer[ BUFSIZE ];
register WORD fh1, fh2;
register LONG lret;

   if ((DoCForm( workfile,destfile,1 ))||!strlen( destfile ))
      {
      CloseCBox();
      return(0);
      }
   if (strcmp( workfile,destfile )==0)
      {
      form_alert( 1,badcopy );
      CloseCBox();
      return( -1 );
      }
   if ((fh1 = Fopen( workfile,0 )) < 0)
      {
      form_alert( 1,filerr );
      CloseCBox();
      return( -1 );
      }
   if ((fh2 = Fopen( destfile,0 )) > 0)
      {
      if (form_alert( 2,copywarn )==2)
         {
         Fclose( fh1 );
         Fclose( fh2 );
         CloseCBox();
         return( 0 );
         }
      else
         {
         Fclose( fh2 );
         fh2 = Fopen( destfile,1 );
         }
      }
   else
      fh2 = Fcreate( destfile,0 );

   graf_mouse( BUSY_BEE,0L );
   while ((lret = Fread( fh1,(LONG)BUFSIZE,buffer )) > 0L)
      Fwrite( fh2,lret,buffer );
   graf_mouse( ARROW,0L );
   Fclose( fh1 );
   Fclose( fh2 );
   CloseCBox();
   return( 0 );
}

WORD movefile( workfile )
BYTE workfile[];
{
BYTE destfile[ MAXSPEC ], buffer[ BUFSIZE ];
register WORD fh1, fh2;
register LONG lret;

   if ((DoCForm( workfile,destfile,2 ))||!strlen( destfile ))
      {
      CloseCBox();
      return(0);
      }
   if (strcmp( workfile,destfile )==0)
      {
      form_alert( 1,badcopy );
      CloseCBox();
      return( -1 );
      }
   if ((fh1 = Fopen( workfile,0 )) < 0)
      {
      form_alert( 1,filerr );
      CloseCBox();
      return( -1 );
      }
   if ((fh2 = Fopen( destfile,0 )) > 0)
      {
      form_alert( 1,movexist );
      Fclose( fh1 );
      Fclose( fh2 );
      CloseCBox();
      return(-1);
      }
   else
      if ((fh2 = Fcreate( destfile,0 )) < 0)
         {
         form_alert( 1,crerror );
         Fclose( fh1 );
         CloseCBox();
         return( -1 );
         }

   graf_mouse( BUSY_BEE,0L );
   while ((lret = Fread( fh1,(LONG)BUFSIZE,buffer )) > 0)
      while (Fwrite( fh2,lret,buffer ) < 0)
         if (form_alert( 1,badwrite ) == 2)
            {
            Fclose( fh1 );
            Fclose( fh2 );
            CloseCBox();
            graf_mouse( ARROW,0L );
            return( -1 );
            }
   Fclose( fh1 );
   Fclose( fh2 );
   Fdelete( workfile );
   CloseCBox();
   graf_mouse( ARROW,0L );
   strcpy( workfile,destfile );
   return( 0 );
}
WORD printfile( workfile )
BYTE workfile[];
{
BYTE buffer[ BUFSIZE ];
register WORD fh1, i;
register LONG lret;

   while (Cprnos()==0L)
      if (form_alert( 2,prnerror )==2)
         return(-1);
   if ((fh1 = Fopen( workfile,0 )) < 0)
      {
      form_alert( 1,filerr );
      return( -1 );
      }
   graf_mouse( BUSY_BEE,0L );
   while ((lret = Fread( fh1,(LONG)BUFSIZE,buffer )) > 0)
      for (i=0; i<(WORD)lret; i++)
         if (Cprnout( buffer[ i ] )==0)
            if (form_alert( 1,prnerror )==2)
               {
               Fclose( fh1 );
               graf_mouse( ARROW,0L );
               return( -1 );
               }
   Fclose( fh1 );
   graf_mouse( ARROW,0L );
   return( 0 );
}

WORD delfile( workfile )
BYTE workfile[];
{
   if (form_alert( 2,suredel )==1)
      {
      if ((WORD)Fdelete( workfile ))
         {
         form_alert( 1,delerror );
         return( -1 );
         }
      }
   else
      return(-1);
   return( 0 );
}

WORD renamefile( workfile )
BYTE workfile[];
{
BYTE destfile[ MAXSPEC ];

   if ((DoCForm( workfile,destfile,0 ))||!strlen( destfile ))
      {
      CloseCBox();
      return(0);
      }
   if (Frename( 0,workfile,destfile ) < 0)
      {
      form_alert( 1,badrename );
      CloseCBox();
      return( -1 );
      }
   else
      {
      strcpy( workfile,destfile );
      CloseCBox();
      return( 0 );
      }
}

/* ---------- ValidSpec() -- validate an input file specification ---- */

WORD ValidSpec( filespec )
BYTE *filespec;
{
register WORD len = strlen( filespec ), i, partlen = 0, error = 0;
register WORD wild = FALSE;
WORD inname = TRUE, inext = FALSE;

   /* empty filespecs are not valid for our purposes */
   if (!len)
      return( FALSE );
   /* Determine the search string and drive */
   cur_drv = -1;
   for (i=SDRIVEA; i<SDRIVEA+15; i++)
      if (s_form[ i ].ob_state & SELECTED)
         {
         cur_drv = i-SDRIVEA;
         drv_let = cur_drv + 'A';
         break;
         }
   if (filespec[1] == ':')       /* drive specified in filespec */
      {
      if (cur_drv != -1)
         s_form[ SDRIVEA+cur_drv ].ob_state &= ~SELECTED;
      drv_let = toupper(filespec[0]);
      cur_drv = drv_let - 'A';
      if (s_form[ SDRIVEA+cur_drv ].ob_state & DISABLED)
         {
         form_alert( 1,baddrive );
         return(FALSE);
         }
      else
         s_form[ SDRIVEA+cur_drv ].ob_state |= SELECTED;
      if (strlen(filespec)==2)   /* cases like "B:" */
         strcat( filespec,"\*.*" );
      len = strlen( filespec )-1;
      memmove( filespec,&(filespec[2]),len );
      len = strlen( filespec );
      }
   /* Check for invalid charcters in the filespec */
   if (strpbrk( filespec,"!@#$%^&()-=+~`;:\"'<>{}[] " ) != NULL)
      {
      form_alert( 1,badspec );
      return( FALSE );
      }
   /* Check the filespec character by character */
   for (i=0; i<len && !error; i++)
      switch( filespec[i] )
         {
         case '\\':
            inname = TRUE;
            inext = FALSE;
            if (wild)
               {
               form_alert( 1,badwild );
               return( FALSE );
               }
            wild = FALSE;
            partlen = 0;
            break;
         case '.':
            inname = FALSE;
            inext = TRUE;
            wild = FALSE;
            partlen = 0;
            break;
         case '*':
            wild = TRUE;
            break;
         case '?':
            wild = TRUE;         /* and go on to next case */
         default:
            if (filespec[i] < 32 || filespec[i] > 127)
               error = 1;
            partlen++;
            if (partlen > 8 && inname)
               error = 2;
            if (partlen > 3 && inext)
               error = 3;
            break;
         }
   /* was an error found? */
   switch( error )
      {
      case 1:  form_alert( 1,badspec );
               return( FALSE );
      case 2:  form_alert( 1,badname );
               return( FALSE );
      case 3:  form_alert( 1,badext );
               return( FALSE );
      case 0:
      default: break;
      }

   /* See if a path is part of the filespec */
   for (i=len-1; i; i--)
      if (filespec[ i ] == '\\')
         break;
   last_path = i;
   if (last_path && filespec[0] != '\\')
      {
      memmove( filespec+1,filespec,++len );
      filespec[0] = '\\';
      }
   return( TRUE );
}

/* FinishFile() insures that a file name includes the drive and path.
   This routine assumes that filename[] is long enough to hold a 
   complete filespec */
WORD FinishFile( filename )
BYTE filename[];
{
BYTE newfile[ MAXSPEC+1 ], temp[ MAXSPEC+1 ];
WORD drive;

   newfile[0]='\0';
   drive = Dgetdrv();
   if (filename[1] != ':')
      {
      newfile[0]=drive+'A';
      newfile[1]=':';   
      newfile[2]='\0';
      }
   strcat( newfile,filename );
   if (newfile[2] != '\\')
      {
      Dgetpath( temp,drive+1 );   
      strcat( temp,"\\" );
      sprintf( filename,"%.2s%s%s",newfile,temp,newfile+2 );
      }
   else
      strcpy( filename,newfile );
}

/* FmtTime() -- formats time into string in hh:mm:ss format */
void FmtTime( f_time,l_buf )
WORD f_time;
BYTE l_buf[];
{
register unsigned WORD h,m;
BYTE m_buf[ 3 ];

   h = (f_time >> 11) & 0x001f;
   m = (f_time & 0x07e0) >> 5;
   if (h > 12)
      {
      h -= 12;
      strcpy( m_buf,"pm" );
      }
   else
      strcpy( m_buf,"am" );
   if (h == 0)
      h = 12;
   sprintf( l_buf,"%2u:%2u",h,m );
   if (m<10)
      l_buf[3] = '0';
   strcat( l_buf,m_buf );
}

/* FmtDate() -- formats a date into a string in mm/dd/yy format */
void FmtDate( f_date,l_buf )
WORD f_date;
BYTE l_buf[];
{
register unsigned WORD y,m,d;

   y = ((f_date >> 9) & 0x007f) + 80;
   if (y>100)
      y -= 100;
   m = (f_date & 0x01e0) >> 5;
   d = (f_date & 0x001f);

   sprintf( l_buf,"%2u-%2u-%2u",m,d,y );
   if (d<10)
      l_buf[3] = '0';
   if (y<10)
      l_buf[6] = '0';
}

/* ---------------------------------------------------------------------- */
/* Browse() has two purposes -- to browse a file and to browse the list   */ 
/* of files found in the last search.                                     */
/* When the argument type = 1, the filespec is of the file to be browsed. */
/* Otherwise, we are to browse the list of found files and filespec is    */
/* the search specification.                                              */
/* ---------------------------------------------------------------------- */
WORD Browse( filespec,type )
BYTE filespec[];
WORD type;
{
WORD dmy, xt, x, y, w, h, wind_type, top_window, ret;
WORD event, clik_x, clik_y, num_cliks, bstate, kstate, keycode;
WORD x_wk,y_wk,w_wk,h_wk,bmsgbuf[ 8 ];
register WORD sel = NOT_SELECTED, oldsel = NOT_SELECTED, w_hand;
GRECT box;

/* Set up text alignment */
   vst_alignment( handle,0,3,&dmy,&dmy );

/* Calculate working area for window based on size it'll be opened as */
   if (type)
      wind_type = WTYPE;
   else
      wind_type = BWTYPE;
   wind_calc(1,wind_type,WINX,WINY,(OUTWIDTH*cwidth),(NUMLINES*cheight),
                &x_wk,&y_wk,&w_wk,&h_wk);

/* Create window */
   w_hand = wind_create( wind_type,x_mx,y_mx,w_mx,h_mx );
   if (w_hand < 0)
      {
      form_alert(1,no_windows);
      return( -1 );
      }

/* If this is a browse on a file, get that file */
   if (type)
      {
      /* Put up the "loading..." form */
      StartForm( l_form,&box,2,0,1 );

      /* load the file into the window */
      num_lines = LoadFile( filespec,&box );
      form_dial( FMD_FINISH,0,0,0,0,box.g_x,box.g_y,box.g_w,box.g_h );
      if (num_lines == -1)
         {
         /* clean up stuff allocated for browse function */
         wind_delete( w_hand );
         ReDraw( bw_handle,bx_wk,by_wk,bw_wk,bh_wk,type );
         return( -1 );
         }
      strcpy( wind_name,filespec );
      wind_set( w_hand,2,wind_name,0,0 );
      sprintf( wind_desc,"Total Lines In Window: %d", num_lines );
      wind_set( w_hand,3,wind_desc,0,0 );	
      }
   else
      {
      num_lines = filez;
      sprintf( wind_name,"Search string: %s",filespec );
      wind_set( w_hand,2,wind_name,0,0 );
      sprintf( wind_desc,"Files Found: %d",num_lines );
      wind_set( w_hand,3,wind_desc,0,0 );	
      }

   /* Open window and initialize window variables */
   l_start = 0;
   CalcRange( h_wk );
   slidpos = 1;
   SetSlidSize( w_hand );
   graf_growbox( x_mx,y_mx,cwidth,cheight,
                 WINX,WINY,(OUTWIDTH*cwidth),(NUMLINES*cheight) );
   wind_open( w_hand,WINX,WINY,(OUTWIDTH*cwidth),(NUMLINES*cheight) );
   browsing = TRUE;

   /* Handle events for this window until it is closed */
   do
      {
      event = evnt_multi(MU_MESAG|MU_BUTTON,2,3,1,
                         0,0,0,0,0,
                         0,0,0,0,0,
                         bmsgbuf,0,0,
                         &clik_x,&clik_y,&bstate,
                         &kstate,&keycode,&num_cliks );   

      /* Did the user select a file from the list? */
      if ((event & MU_BUTTON)&&!type)
         {
         wind_get( w_hand,WF_TOP,&top_window,&ret,&ret,&ret,&ret );
         if ((w_hand == top_window)&&(clik_x >= x_wk)&&
             (clik_y >= y_wk)&&(clik_x <= w_wk+x_wk)
             &&(clik_y <= h_wk+y_wk))
            {
            sel = (clik_y - y_wk + l_start*cheight)/cheight;
            if (sel != oldsel)
               {
               DeSelect( x_wk,y_wk,w_wk,h_wk,oldsel );
               oldsel = sel;
               Select( x_wk,y_wk,w_wk,h_wk,sel );
               }
            if (num_cliks == 2)
               if (sel >= 0 && sel < num_lines)
                  DoFile( sel );
            }
         else
            {
            DeSelect( x_wk,y_wk,w_wk,h_wk,oldsel );
            sel = oldsel = NOT_SELECTED;
            }
         }           

      /* Message event */
      if (event & MU_MESAG)  
         {
         /* If a window event was received for one of ours, handle it */
         if (bmsgbuf[3]==bw_handle)
            if (bmsgbuf[0]==WM_REDRAW)
               {
               ReDraw( bmsgbuf[3],bx_wk,by_wk,bw_wk,bh_wk,type );
               }
         if (bmsgbuf[3]==w_hand)
            {
            /* Handle all window messages */
            switch (bmsgbuf[0])
               {
               case WM_TOPPED:
               case WM_NEWTOP:
                  wind_set(bmsgbuf[3],WF_TOP,0,0,0,0 );
                  break;
               case WM_ARROWED:
                  switch (bmsgbuf[4])
                     {
                     case 0:   /* page up */
                        l_start -= page_size;;
                        l_end -= page_size;
                        break;
                     case 1:   /* page down */
                        l_start += page_size;;
                        l_end += page_size;
                        break;
                     case 2:   /* up arrow */
                        l_start--;
                        l_end--;
                        break;
                     case 3:   /* down arrow */
                        l_start++;
                        l_end++;
                        break;
                     }  /* end switch */
                  if (l_start < 0)
                     l_start = 0;
                  if (l_start > num_lines)
                     l_start = num_lines;
                  if (l_end < 0)
                     l_end = 0;
                  if (l_end > num_lines)
                     l_end = num_lines;
                  if (l_end == num_lines)
                     l_start = l_end - l_range;
                  l_end = l_start + l_range;
                  newslid = CalcSlidPos();
                  if (newslid != slidpos)
                     {
                     slidpos = newslid;
                     wind_set( bmsgbuf[3],WF_VSLIDE,slidpos,0,0,0 );
                     switch( bmsgbuf[ 4 ] )
                        {
                        case 0:
                        case 1:
                           ReDraw( bmsgbuf[3],x_wk,y_wk,w_wk,h_wk,type );
                           break;
                        case 2:
                           LineDown(x_wk,y_wk,w_wk,h_wk);
                           break;
                        case 3:
                           LineUp(x_wk,y_wk,w_wk,h_wk);
                           break;
                        default:
                           break;
                        }     /* end switch */
                     }
                  break;
               case WM_VSLID:
                  if (bmsgbuf[4] != slidpos)
                     {
                     slidpos = bmsgbuf[4];
                     wind_set( bmsgbuf[3],WF_VSLIDE,slidpos,0,0,0 );
                     CalcStart();
                     ReDraw( bmsgbuf[3],x_wk,y_wk,w_wk,h_wk,type );
                     }
                  break;
               case WM_SIZED:
               case WM_MOVED:
                  if ((xt=w_wk) < gr_w)
                     {
                     w_wk = gr_w;
                     bmsgbuf[6] += gr_w - xt;
                     } 
                  if((xt=h_wk) < gr_h)
                     {
                     h_wk = gr_h;
                     bmsgbuf[7] += gr_h - xt;
                     }
                  wind_set(w_hand,WF_CURRXYWH,bmsgbuf[4],bmsgbuf[5],
                           bmsgbuf[6],bmsgbuf[7]);
                  wind_calc(1,wind_type,bmsgbuf[4],bmsgbuf[5],bmsgbuf[6],
                            bmsgbuf[7],&x_wk,&y_wk,&w_wk,&h_wk);
                  wind_set(w_hand,WF_WORKXYWH,x_wk,
                           y_wk,w_wk,h_wk);
                  CalcRange( h_wk );
                  SetSlidSize( w_hand );
                  break;
               case WM_REDRAW:
                  ReDraw( bmsgbuf[3],x_wk,y_wk,w_wk,h_wk,type );
                  break;
               case WM_FULLED:
                  wind_get( w_hand,WF_CURRXYWH,&x,&y,&w,&h );
                  if (w==w_mx && h==h_mx)
                     {
                     wind_get( w_hand,WF_PREVXYWH,&x,&y,&w,&h );
                     wind_set( w_hand,WF_CURRXYWH,x,y,w,h );
                     wind_calc(1,wind_type,x,y,w,h,
                               &x_wk,&y_wk,&w_wk,&h_wk);
                     wind_set( w_hand,WF_WORKXYWH,x_wk,
                               y_wk,w_wk,h_wk );
                     }
                  else
                     {
                     wind_set( w_hand,WF_CURRXYWH,x_mx,
                               y_mx,w_mx,h_mx );
                     wind_calc(1,wind_type,x_mx,y_mx,
                               w_mx,h_mx,&x_wk,&y_wk,&w_wk,&h_wk);
                     wind_set( w_hand,WF_WORKXYWH,x_wk,
                               y_wk,w_wk,h_wk );
                     }
                  CalcRange( h_wk );
                  SetSlidSize( w_hand );
                  break;
               case WM_CLOSED:
                  wind_close( bmsgbuf[3] );
                  graf_shrinkbox( x_wk+w_wk/2,y_wk+h_wk/2,cwidth,cheight,
                                  x_wk,y_wk,w_wk,h_wk );
                  /* clean up stuff allocated for browse function */
                  FreeHeap();
                  wind_delete( w_hand );
                  browsing = FALSE;
                  ReDraw( bw_handle,bx_wk,by_wk,bw_wk,bh_wk,type );
                  break;
               default:
                  break;
               }  /* end switch */
            }  /* end, if a message received */
         }  /* end, if it was for our browse window */
      } while (browsing);
   return( 0 );
}

/* ---------- Window update functions -------------------------------- */

void SetSlidSize( w_hand )
WORD w_hand;
{
   slidsize = (WORD)((l_range*999L)/num_lines + 1);
   wind_set( w_hand,WF_VSLSIZE,slidsize,0,0,0 );
}

void CalcRange( rh )
WORD rh;
{
   l_range = (WORD)(rh/cheight);
   if (l_range > num_lines)
      {
      l_start = 0;
      l_range = num_lines;
      }
   l_end = l_start + l_range;
   if (l_end > num_lines)
      {
      l_end = num_lines;
      l_start = l_end - l_range;
      }
   page_size = l_range;
}

void CalcStart()
{
   l_start = (WORD)(slidpos*(LONG)(num_lines-l_range)/1000L);
   l_end = l_start + l_range;
   if (l_end > num_lines)
      l_end = num_lines;
}

WORD CalcSlidPos()
{
   return( (WORD)((l_start*999L)/(num_lines+l_start-l_end)) + 1);
}

WORD ReDraw( w_handle,rl,rt,rw,rh,type )
WORD w_handle;             /* window to redraw */
WORD rl,rt,rw,rh;          /* rectangle extent */
WORD type;                 /* 1 if file text, 0 if file list */
{
WORD wl, wt, ww, wh;    /* window extent */
WORD clip[4];

   wind_update( TRUE );
   graf_mouse( M_OFF,0 );
   wind_get( w_handle,WF_FIRSTXYWH,&wl,&wt,&ww,&wh );
   while (ww && wh)
      {      /* do the rectangles intersect? */
      if (rl < wl+ww && wl < rl+rw && rt < wt+wh && wt < rt+rh)
         {
         /* Set clipping area for rectangle to be redrawn */
         clip[0] = wl;
         clip[2] = wl + ww - 1;
         clip[1] = wt;
         clip[3] = wt + wh - 1;
         vs_clip( handle,1,clip );
         /* Clear the area, first, with a solid filled rectangle */
         vsf_interior(handle,2);
         vsf_style(handle,8);
         vsf_color(handle,0);
         v_bar(handle,clip);
         /* Update the area appropriately */
         if (w_handle == bw_handle)
            RefrBackground( rl,rt,rw,rh );
         else
            {
            if (type)
               RefrText( rl,rt );
            else
               RefrList( rl,rt );
            }
         }  /* end if */
      wind_get( w_handle,WF_NEXTXYWH,&wl,&wt,&ww,&wh);
      }  /* end while */
   graf_mouse( M_ON,0 );
   wind_update( FALSE );
   vs_clip( handle,0,clip );
} /* end redraw */

WORD RefrText( rl,rt )
WORD rl,rt;
{
register WORD i, x, y;

   for (i=l_start; i<l_end; i++)
      {
      x = (WORD)(rl+cwidth/2);
      y = (WORD)(rt+cheight*(i-l_start)+cheight);
      vswr_mode(handle,1);          /* replace mode */
      v_gtext( handle,x,y,pagetext[i] );
      }
}

WORD RefrEntry( rl,rt,rw,rh,lin,selflag )
WORD rl,rt,rw,rh,lin,selflag;
{
WORD clip[4];
register WORD i, x, y;
register FL *next;

   /* find the entry */
   next = list_head;
   for (i=0; i<lin; i++)
      {
      if (next == NULL)
         return( -1 );
      next = next->next;
      }
   /* Set clipping area */
   clip[0] = rl;
   clip[2] = rl + rw - 1;
   clip[1] = rt;
   clip[3] = rt + rh - 1;
   vs_clip( handle,1,clip );
   /* Refresh the entry */
   x = (WORD)(rl+cwidth/2);
   y = (WORD)(rt+cheight*(i-l_start)+cheight);
   /* Display the file name in the appropriate display mode */
   if (selflag)
      {
      vswr_mode(handle,3);          /* XOR mode, to blank out */
      v_gtext( handle,x,y,next->spec );
      vswr_mode(handle,4);          /* reverse transparent mode */
      v_gtext( handle,x,y,next->spec );
      vswr_mode(handle,1);          /* replace mode */
      }
   else
      {
      vswr_mode(handle,1);          /* replace mode */
      v_gtext( handle,x,y,next->spec );
      }
   vs_clip( handle,1,clip );
   return(0);
}

WORD RefrList( rl,rt )
WORD rl,rt;
{
register WORD i, x, y;
register FL *next;

   next = list_head;
   for (i=0; i<l_start; i++)
      {
      if (next == NULL)
         return( -1 );
      next = next->next;
      }
   for (i=l_start; i<l_end; i++)
      {
      if (next == NULL)
         return( -1 );
      x = (WORD)(rl+cwidth/2);
      y = (WORD)(rt+cheight*(i-l_start)+cheight);
      vswr_mode(handle,1);          /* replace mode */
      v_gtext( handle,x,y,next->spec );
      next = next->next;
      }
   return(0);
}

WORD RefrBackground( rl,rt,rw,rh )
WORD rl,rt,rw,rh;
{
WORD clip[ 4 ];

   clip[0] = rl;     clip[1] = rt;
   clip[2] = rl + rw - 1;
   clip[3] = rt + rh - 1;
   vsf_interior( handle,2 );
   vsf_style( handle,8 );
   vsf_color( handle,back_color );
   v_bar( handle,clip );
}

WORD RefrLine( rl,rt,rw,rh,lin )
WORD rl,rt,rw,rh,lin;
{
register WORD x, y, plin;
WORD clip[4];

   wind_update( TRUE );
   graf_mouse( M_OFF,0 );
   /* Set clipping area */
   clip[0] = rl;
   clip[2] = rl + rw - 1;
   clip[1] = rt;
   clip[3] = rt + rh - 1;
   vs_clip( handle,1,clip );
   /* If line is on screen, rewrite it */
   if ((lin >= l_start)&&(lin < l_end))
      {
      x = (WORD)(rl+cwidth/2);
      y = (WORD)(rt+cheight*(lin-l_start)+cheight);
      /* Clear the area, first, with a solid filled rectangle */
      clip[0] = rl;
      clip[1] = (WORD)(rt+cheight*(lin-l_start));
      clip[2] = rl + rw - 1;
      clip[3] = clip[1] + cheight - 1;
      vsf_interior( handle,2 );
      vsf_style( handle,8 );
      vsf_color( handle,0 );
      v_bar( handle,clip );
      vswr_mode( handle,1 );           /* replace mode */
      plin = lin-1;
      if ((plin >= l_start)&&(plin < l_end))
         v_gtext( handle,x,y-cheight,pagetext[ lin-1 ] );
      v_gtext( handle,x,y,pagetext[ lin ] );
      }
   /* clean up */
   graf_mouse( M_ON,0 );
   wind_update( FALSE );
   vs_clip( handle,0,clip );
}

/* LineUp() and LineDown() move screen memory to accomplish
   smooth scrolling within the BROWSE window */
void LineUp( rl,rt,rw,rh )
WORD rl,rt,rw,rh;
{
WORD array[ 8 ];

   array[0] = array[4] = rl;
   array[1] = rt + cheight;
   array[2] = array[6] = rl + rw - 1;
   array[3] = rt + rh - 1;
   array[5] = rt;
   array[7] = rt + rh - cheight - 1;
   vro_cpyfm( handle,S_ONLY,array,mfdb,mfdb );
   RefrLine( rl,rt,rw,rh,l_end-1 );
}

void LineDown( rl,rt,rw,rh )
WORD rl,rt,rw,rh;
{
WORD array[ 8 ];

   array[0] = array[4] = rl;
   array[1] = rt;
   array[2] = array[6] = rl + rw - 1;
   array[3] = rt + rh - cheight - 1;
   array[5] = rl + cheight;
   array[7] = rt + rh - 1;
   vro_cpyfm( handle,S_ONLY,array,mfdb,mfdb );
   RefrLine( rl,rt,rw,rh,l_start );
}

/* Select and DeSelect work on a line of text within the BROWSE window */
void Select( rx,ry,rw,rh,lin )
WORD rx,ry,rw,rh,lin;
{
   if (lin != NOT_SELECTED && lin >= l_start && lin < l_end)
      {
      graf_mouse( M_OFF,0L );
      RefrEntry( rx,ry,rw,rh,lin,1 );
      graf_mouse( M_ON,0L );
      }
}

void DeSelect( rx,ry,rw,rh,lin )
WORD rx,ry,rw,rh,lin;
{
   if (lin != NOT_SELECTED && lin >= l_start && lin < l_end)
      {
      graf_mouse( M_OFF,0L );
      RefrEntry( rx,ry,rw,rh,lin,0 );
      graf_mouse( M_ON,0L );
      }
}

/* PrintList() prints the list of found files.  It invokes PrintLine()
   for each line of text.  The lines are sent to the parallel port.
*/
WORD PrintList()
{
BYTE line[ LINEWIDTH+1 ], dbuff[ 11 ], tbuff[ 11 ];
register FL *next;

   /* Check the printer status */
   while (Cprnos()==0L)
      if (form_alert( 2,prnerror )==2)
         return(-1);
   next = list_head;
   /* Print some header information */
   sprintf( line,"Search string: %s\n",filespec );
   if (PrintLine( line )==-1)
      return( -1 );
   /* Print each file in the list */
   while (next != NULL)
      {
      FmtDate( next->date,dbuff );
      FmtTime( next->time,tbuff );
      sprintf( line,"%s\n",next->spec );
      if (PrintLine( line )==-1)
         return( -1 );
      sprintf( line,"   %lu %s %s\n",next->size,dbuff,tbuff );
      if (PrintLine( line )==-1)
         return( -1 );
      next = next->next;
      }
   return( 0 );
}

WORD PrintLine( line )
BYTE line[];
{
register WORD i, len;

   len = strlen( line );
   for (i=0; i<len; i++)
      if (Cprnout( line[i] )==0)
         if (form_alert( 1,prnerror )==2)
            return( -1 );
   return( 0 );
}

/* --------------------------------------------------------------- */
/* LoadFile() loads a file into the Browse window.                 */
/* --------------------------------------------------------------- */
WORD LoadFile( filespec,dims )
BYTE filespec[];
GRECT *dims;
{
BYTE filebuff[ BUFSIZE+1 ], linebuff[ LINEWIDTH+1 ];
WORD index = 0, box[ 4 ], linelen = 0, fhandle;
WORD bpx, lstart = 0;
register WORD bread,inline,fstart,togo = 0,last_read = 0;

   /* Get all available memory for our "heap" */
   if (GetHeap())
      {
      form_alert( 1,nomem );
      return( -1 );
      }

   /* Set up 'loading' box variables */
   bpx = (WORD)(dta.size/l_form[ LBOX ].ob_width) + 1;
   box[ 0 ] = box[ 2 ] = dims->g_x+l_form[ LBOX ].ob_x;
   box[ 1 ] = dims->g_y+l_form[ LBOX ].ob_y + 2;
   box[ 3 ] = box[ 1 ] + l_form[ LBOX ].ob_height + 1;
   box[ 2 ]++;
   vsf_style( handle,0 );
   vsf_color( handle,1 );

   /* Open the file for reading */
   graf_mouse( BUSY_BEE,0L );
   if ((fhandle = Fopen( filespec,0 )) < 0)
      {
      graf_mouse( ARROW,0L );
      form_alert( 1,filerr );
      FreeHeap();
      return(-1);
      }

   /* read the file into the up-to MAXLINES LINEWIDTH char lines */
   while ((bread = (WORD)Fread( fhandle,(LONG)BUFSIZE,filebuff )) > 0)
      {
      fstart = 0;
      togo = bread;
      /* if necessary, add to the "loading" box */
      last_read += bread;
      while (last_read > bpx)
         {
         last_read -= bpx;
         box[ 0 ] = box[ 2 ];
         box[ 2 ]++;
         v_bar( handle,box );
         }
      while (togo > 0)
         {
         inline = BufToLine( filebuff,linebuff,bread,LINEWIDTH,
                             fstart,&lstart );
         fstart += inline;
         togo -= inline;
         linelen += inline;
         /* If lstart=0, a line has been completed.  Add it to the buffer */
         if (!lstart)
            {
            if ((pagetext[ index ] = (BYTE *)DJMalloc( (LONG)linelen+1L ))
                 == NULL)
               {
               graf_mouse( ARROW,0L );
               sprintf( alert_box,
                        "[0][ ERROR:  Out Of Memory At | %d Lines.  ][ OK ]",
                        index );
               form_alert( 1,alert_box );
               FreeHeap();
               return(-1);
               }

            /* Copy the input buffer to the new line */
            strncpy( pagetext[ index ],linebuff,linelen );
            pagetext[ index ][ linelen ] = '\0';
            linelen = 0;

            /* If the maximum number of lines has been read, exit */
            if (++index >= MAXLINES-1)
               break;
            }
         }
      }

   /* Fill up the rest of the box */
   box[ 0 ] = dims->g_x+l_form[ LBOX ].ob_x;
   box[ 1 ] = dims->g_y+l_form[ LBOX ].ob_y + 2;
   box[ 2 ] = box[ 0 ] + l_form[ LBOX ].ob_width + 2;
   box[ 3 ] = box[ 1 ] + l_form[ LBOX ].ob_height + 1;
   vsf_style( handle,8 );
   vsf_color( handle,1 );
   v_bar( handle,box );

   /* Clean up and return number of lines read */
   Fclose( fhandle );
   graf_mouse( ARROW,0L );
   return( index );
}

/* --------------------------------------------------------------- */
/* BufToLine() moves the appropriate number of characters from     */
/* the file input buffer to a line buffer and updates all          */
/* counters as necessary                                           */
/* --------------------------------------------------------------- */
WORD BufToLine( filebuff,linebuff,fblen,maxline,fstart,lstart )
BYTE filebuff[],linebuff[];
WORD fblen, maxline, fstart, *lstart;
{
register WORD fidx, lidx, ret;

   for (fidx=fstart,lidx=*lstart; fidx<fblen && lidx<maxline; fidx++,lidx++)
      {
      if (filebuff[ fidx ] == '\n')
         {
         linebuff[ lidx ? lidx-1 : lidx ] = '\0';
         ret = lidx-*lstart;
         *lstart = 0;
         return( ret+1 );
         }
      linebuff[ lidx ] = filebuff[ fidx ];
      if ((linebuff[ lidx ] < 32)||(linebuff[ lidx ] > 127))
         linebuff[ lidx ] = ' ';
      }
   /* Determine how many characters were moved */
   ret = lidx - *lstart;
   /* Determine which limit was reached and handle accordingly */
   if (lidx == maxline)
      {
      linebuff[ lidx ] = '\0';
      *lstart = 0;
      return( ret );
      }
   if (fidx == fblen)
      *lstart = lidx;
   else
      *lstart = 0;
   return( ret+1 );
}

/* -------- Memory management for the list of files we've found ------ */

WORD AddList( dtaptr,filespec )
DTA *dtaptr;
BYTE *filespec;
{
register FL *new = NULL, *next = NULL, *prev = NULL;
BL *new_block = NULL;

   /* space for list members is allocated in blocks --
      see if some space is already available.  If not, allocate a block */
   if (!left_in_block)
      {
      if ((new_block = (BL *)Malloc( (LONG)sizeof( BL ) ))==NULL)
         return( -1 );
      new_block->next = NULL;
      if (cur_block != NULL)
         cur_block->next = new_block;
      cur_block = new_block;
      if ((next_file = (FL *)Malloc( (LONG)(ALLOCNUM*sizeof( FL )) ))==NULL)
         return( -1 );
      cur_block->first = next_file;
      left_in_block = ALLOCNUM;
      if (block_head == NULL)
         block_head = cur_block;
      }

   /* Get our next list member from the current block */
   if ((new = next_file) == NULL)
      return(-1);
   left_in_block--;
   next_file = (FL *)&(cur_block->first[ (ALLOCNUM-left_in_block) ]);

   /* Copy the data into the new member */
   strcpy( new->spec,filespec );
   new->size = dtaptr->size;
   new->date = dtaptr->date;
   new->time = dtaptr->time;
   new->attr = dtaptr->attr;
   new->next = NULL;

   /* Insert the new member into the list */
   if (list_head == NULL)
      {
      list_head = new;
      return( 0 );
      }
   next = list_head;
   while (next != NULL)
      {
      if (strcmp( next->spec,new->spec ) > 0)
         {
         new->next = next;
         if (prev == NULL)
            list_head = new;
         else
            prev->next = new;
         return( 0 );
         }
      prev = next;
      next = next->next;
      }
   prev->next = new;
   return( 0 );
}

void FreeBlocks()
{
register BL *next, *prev;

   next = block_head;
   while (next != NULL)
      {
      prev = next;
      Mfree( next );
      Mfree( next->first );
      next = prev->next;
      }
   block_head = NULL;
   cur_block = NULL;
   list_head = NULL;
   left_in_block = 0;
}

/* ---- Poor man's memory management functions --------------- */
/* ---- Used to set up and use memory for file Browse() ------ */
WORD GetHeap()
{
   heap_avail = Malloc( -1L );
   djheap = (BYTE *)Malloc( heap_avail );
   if (djheap == (BYTE *)NULL)
      return( -1 );
   else
      {
      heap_ptr = djheap;
      return( 0 );
      }
}

BYTE *DJMalloc( bytes )
LONG bytes;
{
register BYTE *curheap;

   if (bytes > heap_avail)
      return( NULL );
   curheap = heap_ptr;
   heap_ptr += bytes;
   heap_avail -= bytes;
   return( curheap );
}

void FreeHeap()
{
   Mfree( djheap );
   heap_avail = 0L;
   heap_ptr = NULL;
}
