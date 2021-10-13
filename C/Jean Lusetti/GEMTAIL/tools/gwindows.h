#ifndef __GWINDOWS_H
#define __GWINDOWS_H

#if !defined (__XGEM_H)
#include "..\tools\xgem.h"
#endif

#ifndef __KEYS_H
#include "..\tools\keys.h"
#endif

#ifndef __VA_START_H
#include "..\tools\va_start.h"
#endif

#ifndef __LIST_H
#include "..\tools\list.h"
#endif

/* Dialog form basic structure */
typedef struct
{
  OBJECT *BaseObject ;
  /* For GEM events handling */
  int  EditObject ;
  int  NextObject ;
  int  Cont ;
  int  Idx ;
  int  MuMesag ;
  char ShowEdit ;
  char DoNotReInitEdit ;
  int  ExitCode ; /* IDOK or IDCANCEL */
  int  StartOb ;

  void* UserData ; /* Provided by DLGDATA */

  clock_t LastObjNotify ; /* To avoid too fast notifications; typically on +/- buttons */

  /* Caster wnd en GEM_WINDOW* */
  void (*OnInitDialog)(void* wnd) ; 
  int  (*OnObjectNotify)(void* wnd, int obj) ; /* > 0 : outside window, code IDOK or IDCANCEL */
}
DIALOG ;

/* No more than NB_MAX_GEM_WINDOWS open at the same time (whatever AES version is) */
#define NB_MAX_GEM_WINDOWS 20

/* Flags defines for flags field */
#define FLG_MUSTCLIP    0x0001UL /* vs_clip to do before calling OnDraw() */
#define FLG_ISMODAL     0x0100UL /* Modal window                          */
#define FLG_ISVISIBLE   0x0200UL /* Window is visible                     */

/* Codes returned by event handlers     */
/* They define how GW engine will react */
#define GW_EVTCONTINUEROUTING    0x100
#define GW_EVTSTOPROUTING        0x101
#define GW_EVTQUITAPP            0x1FF

/* Porgress function staus returned */
#define SPROG_CANCEL         1
#define SPROG_GUIUPDATED     0
#define SPROG_GUINOTUPDATED -1
#define PROG_CANCEL_CODE(x)      ( (x) == SPROG_CANCEL )
#define PROG_GUIUPD_CODE(x)      ( (x) == SPROG_GUIUPDATED )
#define PROG_GUINUP_CODE(x)      ( (x) == SPROG_GUINOTUPDATED )

/* Structure for ARGS helper */
typedef struct _DD_ARGS
{
  short  ncmds ;
  char** cmds ;
  long   user[10] ;
}
DD_ARGS, *PDD_ARGS ;

/* For Drag'n'Drop protocol */
typedef struct _DD_IHEADER
{
  short size ;
  long  type ;
  long  data_size ;
  char  name[128] ;
  char  filename[128] ;
}
DD_IHEADER, *PDD_IHEADER ;

typedef struct _DD_DATA
{
  DD_IHEADER header ;
  void*      wnd_or_app ;
  int        mx, my ;
  int        kstate ;
  char*      data ;

  DD_ARGS args ; /* Filled in if type = 'ARGS' */
}
DD_DATA, *PDD_DATA ;

typedef struct _DD_INFO
{
  /* 32 bytes accepted types response to initiator */
  long data_types[8] ; /* List of acceptaed data types 'ARGS', 'PATH', '.IMG', '.GEM', '.TXT', ... (max 8) */

  int  (*OnDD)(DD_DATA* dd_data) ;
}
DD_INFO, *PDD_INFO ;

typedef struct _GEM_WINDOW
{
  LIST_ENTRY ListEntry ;

  /* Donnees generales */
  char ClassName[20] ;
  unsigned long marker ;    /* General purpose usage, GWINDOWS doesn't use it */
  unsigned long flags ;     /* See structure below                            */
  int    window_handle ;    /* GEM Handle                                     */
  int    window_kind ;
  char   window_name[60] ;
  char   window_info[120] ;
  char   is_allocated ;
  char   must_be_fulled ;
  char   KnowMouseIsOut ;   /* INTERNAL : OnMouseMove handling */
  long   TimeOutMs ;        /* Time out for OnTimer            */
  size_t LastTick ;         /* For OnTimer handling            */

  /* Coordinates prior to ShowWindow(..., 0) */
  int vx, vy, vw, vh ;

  int  xywh_bicon[4] ;   /* Coordinates prior to iconify */
  MFDB window_icon ;     /* Iconified Image              */
  char is_icon ;         /* Is window iconified ?        */

  /* Specific extension data */
  void* Extension ;

  /* Dialog form */
  DIALOG* DlgData ;      /* != NULL if window is a dialog form or a command bar */
  int     original_key ; /* Original value before translation required for form edits */

  /* Progress */
  clock_t pr_lastupdate ;
  long    pr_diffval ;
  long    pr_max ;
  long    pr_last_val_shown ;
  clock_t pr_currentT ;
  short   pr_force_cancel_check ;
  short   pr_ncalls_before_clock ;

  /* This function may be called directly but it is better to call    */
  /* GWProgRange to avoid too frequent calls and decrease performance */
  int (*ProgRange)(void* wnd, long current, long max, char* txt) ;

  /* Events */
  int   (*OnKeyPressed)(void* wnd, int key) ;
  int   (*OnMenuSelected)(void* wnd, int t_id, int m_id) ;
  void  (*OnDraw)(void* wnd, int xycoords[4]) ;
  int   (*OnLButtonDown)(void* wnd, int mk_state, int x, int y) ;
  int   (*OnDLButtonDown)(void* wnd, int mk_state, int x, int y) ;
  int   (*OnRButtonDown)(void* wnd, int mk_state, int x, int y) ;
  int   (*OnDRButtonDown)(void* wnd, int mk_state, int x, int y) ;
  int   (*OnMouseMove)(void* wnd, int button, int kstate, int mx, int my ) ;
  int   (*OnTopped)(void* wnd) ;
  int   (*OnUnTopped)(void* wnd) ;
  int   (*OnClose)(void* wnd) ;
  void  (*OnMove)(void* wnd, int xywh[4]) ;
  void  (*OnHSlider)(void* wnd, int pos) ;
  void  (*OnVSlider)(void* wnd, int pos) ;
  void  (*OnSize)(void* wnd, int xywh[4]) ;
  int   (*OnFulled)(void* wnd) ;
  int   (*OnRestoreFulled)(void* wnd) ;
  void  (*OnArrow)(void* wnd, int action) ;
  int   (*OnIconify)(void* wnd, int xywh[4]) ;
  int   (*OnUnIconify)(void* wnd, int xywh[4]) ;
  int   (*OnTimer)(void* wnd, int mx, int my) ;
  int   (*OnTxtBubble)(void* wnd, int mx, int my, char* text) ;
  int   (*OnMsgUser)(void* wnd, int id, int mesg[4]) ;
  int   (*OnDragDrop)(void* wnd, int mx, int my, int kstate, int pipeid) ; /* Raw handling (DD_DATA zeroed) */

  void  (*GetWorkXYWH)(void* wnd, int* x, int* y, int* w, int* h) ;
  char* (*GetWindowID)(void* wnd) ;

  DD_INFO  DragDrop ;
}
GEM_WINDOW ;

typedef struct
{
  unsigned HelpBubbles : 1  ;
           RFU         : 15 ;
}
GEM_FLAGS ;

typedef struct
{
  EVENT       Event ;
  OBJECT*     Menu ;
  GEM_WINDOW* CurrentGemWindow ;
  long        TimeOutMs ;       /* Time out for OnTimer */
  size_t      LastTick ;        /* For OnTimer handling */

  GEM_FLAGS   Flags ;

  int  (*OnTimer)(int mx, int my, void* context) ;
  int  (*OnKeyPressed)(int key) ;
  int  (*OnMenuSelected)(int t_id, int m_id) ;
  void (*OnUpdateGUI)(void) ;

  /* If there is no active window */
  int (*OnLButtonDown)(int mk_state, int x, int y) ;
  int (*OnDLButtonDown)(int mk_state, int x, int y) ;
  int (*OnRButtonDown)(int mk_state, int x, int y) ;
  int (*OnDRButtonDown)(int mk_state, int x, int y) ;
  int (*OnMouseMove)(int button, int mk_state, int mx, int my) ;

  int  (*OnInit)(void* app) ;
  void (*OnParseCmdLine)(void* app, int argc, char** argv) ;
  void (*OnOpenFile)(char* name) ; /* Called from VA_START */
  void (*OnTerminate)(void* app) ;
  int  (*OnUnknownMsg)(void* app, int *mesg) ;
  int  (*OnMsgUser)(void* app, int id, int mesg[4]) ;
  int  (*OnDragDrop)(void* app, int mx, int my, int kstate, int pipeid) ; /* Raw handling (DD_INFO zeroed) */

  void (*OnPreModal)(void) ;
  void (*OnPostModal)(void) ;

  int    Argc ;
  char** Argv ;

  LIST_ENTRY GemWindowListHead ;
  int        NbGemWindows ;

  void*      TimerContext ;
  DD_INFO    DragDrop ;
}
GEM_APP ;

extern GEM_APP GemApp ;

void GWSetTimer(GEM_WINDOW* wnd, long ms, void* context) ; /* context only if wnd=NULL (for application) */
void GWKillTimer(GEM_WINDOW* wnd) ;

void GWRedraws(void) ;
void GWInvalidate(GEM_WINDOW* wnd) ;

int  GWSetMenu(int id, char* title) ;
void GWSetMenuStatus(int valid) ;
int  GWOnMenuSelected(int t_id, int m_id) ;

GEM_WINDOW* GWCreateWindow(int kind, long extension_size, char* class_name) ;
int         GWOpenWindow(GEM_WINDOW* wnd, int wx, int wy, int ww, int wh) ;
int         GWIsWindow(void) ;

void        GWShowWindow(GEM_WINDOW* wnd, int show) ;
void        GWSetWindowCaption(GEM_WINDOW* wnd, char* caption) ;
void        GWSetWindowInfo(GEM_WINDOW* wnd, char* info) ;

void        GWSetHSlider(GEM_WINDOW* wnd, int pos) ;
void        GWSetVSlider(GEM_WINDOW* wnd, int pos) ;
void        GWSetHSliderSize(GEM_WINDOW* wnd, int size) ;
void        GWSetVSliderSize(GEM_WINDOW* wnd, int size) ;

void        GWGetHSlider(GEM_WINDOW* wnd, int* pos) ;
void        GWGetVSlider(GEM_WINDOW* wnd, int* pos) ;
void        GWGetHSliderSize(GEM_WINDOW* wnd, int* size) ;
void        GWGetVSliderSize(GEM_WINDOW* wnd, int* size) ;

void        GWGetWorkXYWH(GEM_WINDOW* wnd, int* x, int* y, int* w, int* h) ;
void        GWGetCurrXYWH(GEM_WINDOW* wnd, int* x, int* y, int* w, int* h) ;
void        GWSetCurrXYWH(GEM_WINDOW* wnd, int x, int y, int w, int h) ;

GEM_WINDOW* GWGetWindow(int x, int y) ;
GEM_WINDOW* GWGetWindowByClass(char* class_name) ;

void       GWDestroyWindow(GEM_WINDOW* wnd) ;

void       GWRePaint(GEM_WINDOW* wnd) ;

/* Default handlers */
void GWOnDraw(GEM_WINDOW* wnd, int xycoords[4]) ;
int  GWOnTopped(GEM_WINDOW* wnd) ;
int  GWOnClose(GEM_WINDOW* wnd) ;
void GWOnMove(GEM_WINDOW* wnd, int xywh[4]) ;
void GWOnHSlider(GEM_WINDOW* wnd, int pos) ;
void GWOnVSlider(GEM_WINDOW* wnd, int pos) ;
void GWOnSize(GEM_WINDOW* wnd, int xywh[4]) ;
int  GWOnFulled(GEM_WINDOW* wnd, int xywh[4]) ;
int  GWOnRestoreFulled(GEM_WINDOW* wnd, int xywh[4]) ;
int  GWOnIconify(GEM_WINDOW* wnd, int xywh[4]) ;
int  GWOnUnIconify(GEM_WINDOW* wnd, int xywh[4]) ;

#define IDOK      1
#define IDCANCEL  2

typedef struct
{
  GEM_WINDOW* Parent ;        /* Desktop if NULL                            */
  OBJECT*     Object ;        /* Unused if RsrcId != -1                     */
  int         RsrcId ;        /* If -1, Object is the reference             */
  int         WKind ;         /* In addition to MOVER, CLOSER et NAME       */
  int         NWKind ;        /* In case we don't wante CLOSER for instance */
  char        Title[100] ;
  char        ClassName[20] ;
  int         XPos, YPos ;    /* If (0,0), Parent will be used as position  */ 
  void*       UserData ;      /* To hold return values                      */
  long        ExtensionSize ;

  void (*OnInitDialog)(void* wnd) ; 
  int  (*OnObjectNotify)(void* wnd, int obj) ; /* >=0 : outside window, code IDOK or IDCANCEL */
  int  (*OnCloseDialog)(void* wnd) ; 
}
DLGDATA ;

int         GWSetWndRscIcon(GEM_WINDOW* wnd, int form, int id) ;
int         GWIsWindowValid(GEM_WINDOW* wnd) ;
void        GWZeroDlgData(DLGDATA* data) ;
GEM_WINDOW* GWCreateDialog(DLGDATA* data) ;
GEM_WINDOW* GWCreateWindowCmdBar(DLGDATA* data) ;
int         GWDoModal(GEM_WINDOW* wnd, int start_ob) ; /* IDOK or IDCANCEL */
int         GWOnKeyPressedDlg(void* w, int key) ;
int         GWCloseDlg(void* w) ;
void        GWOnMoveDlg(void* gw, int xywh[4]) ;
int         OnLButtonDownDlg(void* w, int mk_state, int mx, int my) ;
void        OnDrawDlg(void* w, int xywh[4]) ;
int         OnToppedDlg(void* w) ;
int         GWBasicModalHandler(void) ;
GEM_WINDOW* GWGetWindowByID(char* name) ;
GEM_WINDOW* GWGetNextWindow(GEM_WINDOW* wnd) ;

#define    GWM_STARTMSG    500
#define    GWM_DESTROY     (GWM_STARTMSG + 0)
#define    WM_USER_FIRST   (GWM_STARTMSG + 50)
#define    WM_USER_LAST    (GWM_STARTMSG + 99)

int  PostMessage(GEM_WINDOW* wnd, int id, int mesg[4]) ;
void GWDestroyWindow(GEM_WINDOW* wnd) ;


GEM_APP* GWGetApp(int argc, char** argv) ;
void     GWDeclareAndRunApp(GEM_APP* app) ;
int      GeneralMesagHandler(EVENT* event) ;
int      CursorKeyToArrowAction(int key) ;

int GWProgRange(GEM_WINDOW* wnd, long val, long max, char* txt) ;
int GWGetKey(void) ;

void GWDDAddType(GEM_WINDOW* wnd, long type) ;


#endif
