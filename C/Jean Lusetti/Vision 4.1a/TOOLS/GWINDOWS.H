#ifndef __GWINDOWS
#define __GWINDOWS

#if !defined (__XGEM)
#include "..\tools\xgem.h"
#endif

#ifndef __KEYS
#include "..\tools\keys.h"
#endif

#ifndef __VA_START
#include "..\tools\va_start.h"
#endif

#ifndef __LIST_H
#include "..\tools\list.h"
#endif

/* Structure primaire de boite de dialogue */
/* Int‚gr‚e dans la structure GEM_WINDOW  */
typedef struct
{
  OBJECT *BaseObject ;
  /* Pour la gestion des evenements GEM */
  int  EditObject ;
  int  NextObject ;
  int  Cont ;
  int  Idx ;
  int  MuMesag ;
  char ShowEdit ;
  char DoNotReInitEdit ;
  int  ExitCode ; /* IDOK ou IDCANCEL */
  int  StartOb ;

  void *UserData ; /* Pass‚ par DLGDATA */

  clock_t LastObjNotify ; /* To avoid too fast notifications; typically on +/- buttons */

  /* Caster wnd en GEM_WINDOW* */
  void (*OnInitDialog)(void *wnd) ; 
  int  (*OnObjectNotify)(void *wnd, int obj) ; /* > 0 : sortie de la fenetre, code IDOK ou IDCANCEL */
}
DIALOG ;

typedef struct
{
  DIALOG *DlgData ;

  char RFU[64] ;
}
DIALOG_CMD ;

/* Structure de fenetre GEM */
#define NB_MAX_GEM_WINDOWS 20

/* Flags pour le champ flags */
#define FLG_MUSTCLIP    0x0001UL /* vs_clip a faire avant d'appeler OnDraw() */
#define FLG_ISMODAL     0x0100UL /* Fenetre modale  */
#define FLG_ISVISIBLE   0x0200UL /* Fenetre visible */

/* Les codes suivants sont remontes par les fonctions */
/* De traitement des evenements et agissent en        */
/* Consequence sur le moteur GW                       */
#define GW_EVTCONTINUEROUTING    0x100
#define GW_EVTSTOPROUTING        0x101
#define GW_EVTQUITAPP            0x1FF

typedef struct _GEM_WINDOW
{
  LIST_ENTRY ListEntry ;

  /* Donnees generales */
  char ClassName[20] ;
  unsigned long marker ;   /* Pour ce qu'on veut, GWINDOWS n'y touche pas */
  unsigned long flags ;    /* Voir ci dessus */
  int    window_handle ;   /* Handle GEM */
  int    window_kind ;     /* Style de la fenetre */
  char   window_name[60] ; /* Titre de la fenetre */
  char   window_info[120] ;/* Texte de la barre d'infos */
  char   is_allocated ;    /* Fenetre utilisee ? */
  char   must_be_fulled ;  /* Doit etre maximisee ? */
  char   KnowMouseIsOut ;  /* INTERNE : Gestion du OnMouseMove */
  long   TimeOutMs ;       /* Time out pour OnTimer */
  size_t LastTick ;        /* Pour gestion OnTimer */

  /* Coordonnees avant ShowWindow(..., 0) */
  int vx, vy, vw, vh ;

  int  xywh_bicon[4] ;   /* Coordonnees avant iconification */
  MFDB window_icon ;     /* Image iconifiee */
  char is_icon ;         /* Fenetre iconisee ? */

  /* Donnees d'extension */
  void *Extension ;

  /* Boite de dialogue */
  DIALOG *DlgData ; /* != NULL Si la fenetre est une boite de dialogue ou barre de commandes) */

  /* Progression */
  int (*ProgPc)(void *wnd, int pc, char *txt) ;
  int (*ProgRange)(void *wnd, long current, long max, char *txt) ;

  /* Evenements */
  int  (*OnKeyPressed)(void *wnd, int key) ;
  int  (*OnMenuSelected)(void *wnd, int t_id, int m_id) ;
  void (*OnDraw)(void *wnd, int xycoords[4]) ;
  int  (*OnLButtonDown)(void *wnd, int mk_state, int x, int y) ;
  int  (*OnDLButtonDown)(void *wnd, int mk_state, int x, int y) ;
  int  (*OnRButtonDown)(void *wnd, int mk_state, int x, int y) ;
  int  (*OnDRButtonDown)(void *wnd, int mk_state, int x, int y) ;
  int  (*OnMouseMove)(void *wnd, int button, int kstate, int mx, int my ) ;
  int  (*OnTopped)(void *wnd) ;
  int  (*OnUnTopped)(void *wnd) ;
  int  (*OnClose)(void *wnd) ;
  void (*OnMove)(void *wnd, int xywh[4]) ;
  void (*OnHSlider)(void *wnd, int pos) ;
  void (*OnVSlider)(void *wnd, int pos) ;
  void (*OnSize)(void *wnd, int xywh[4]) ;
  int  (*OnFulled)(void *wnd) ;
  int  (*OnRestoreFulled)(void *wnd) ;
  void (*OnArrow)(void *wnd, int action) ;
  int  (*OnIconify)(void *wnd, int xywh[4]) ;
  int  (*OnUnIconify)(void *wnd, int xywh[4]) ;
  int  (*OnTimer)(void *wnd, int mx, int my) ;
  int  (*OnTxtBubble)(void *wnd, int mx, int my, char *text) ;

  void (*GetWorkXYWH)(void *wnd, int *x, int *y, int *w, int *h ) ;
  int  (*OnMsgUser)(void *wnd, int id, int mesg[4]) ;
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
  EVENT      Event ;
  OBJECT     *Menu ;
  GEM_WINDOW *CurrentGemWindow ;
  long       TimeOutMs ;       /* Time out pour OnTimer */
  size_t     LastTick ;        /* Pour gestion OnTimer  */

  GEM_FLAGS  Flags ;

  int        (*OnTimer)(int mx, int my) ;
  int        (*OnKeyPressed)(int key) ;
  int        (*OnMenuSelected)(int t_id, int m_id) ;
  void       (*OnUpdateGUI)(void) ;

  /* S'il n'y a pas de fenetre active */
  int (*OnLButtonDown)(int mk_state, int x, int y) ;
  int (*OnDLButtonDown)(int mk_state, int x, int y) ;
  int (*OnRButtonDown)(int mk_state, int x, int y) ;
  int (*OnDRButtonDown)(int mk_state, int x, int y) ;
  int (*OnMouseMove)(int button, int mk_state, int mx, int my) ;

  int  (*OnInit)(void *app) ;
  void (*OnParseCmdLine)(void *app, int argc, char **argv) ;
  void (*OnOpenFile)(char *name) ; /* Appele par VA_START */
  void (*OnTerminate)(void *app) ;
  int  (*OnUnknownMsg)(void *app, int *mesg) ;
  int  (*OnMsgUser)(void *app, int id, int mesg[4]) ;

  int    Argc ;
  char** Argv ;

  LIST_ENTRY GemWindowListHead ;
  int        NbGemWindows ;
}
GEM_APP ;

extern GEM_APP GemApp ;

void GWSetTimer(GEM_WINDOW *wnd, long ms) ;
void GWKillTimer(GEM_WINDOW *wnd) ;

void GWRedraws(void) ;
void GWInvalidate(GEM_WINDOW *wnd) ;

int  GWSetMenu(int id, char *title) ;
void GWSetMenuStatus(int valid) ;
int  GWOnMenuSelected(int t_id, int m_id) ;

GEM_WINDOW *GWCreateWindow(int kind, long extension_size, char *class_name) ;
int        GWOpenWindow(GEM_WINDOW *wnd, int wx, int wy, int ww, int wh) ;
int        GWIsWindow(void) ;

void       GWShowWindow(GEM_WINDOW *wnd, int show) ;
void       GWSetWindowCaption(GEM_WINDOW *wnd, char *caption) ;
void       GWSetWindowInfo(GEM_WINDOW *wnd, char *info) ;

void       GWSetHSlider(GEM_WINDOW *wnd, int pos) ;
void       GWSetVSlider(GEM_WINDOW *wnd, int pos) ;
void       GWSetHSliderSize(GEM_WINDOW *wnd, int size) ;
void       GWSetVSliderSize(GEM_WINDOW *wnd, int size) ;

void       GWGetHSlider(GEM_WINDOW *wnd, int *pos) ;
void       GWGetVSlider(GEM_WINDOW *wnd, int *pos) ;
void       GWGetHSliderSize(GEM_WINDOW *wnd, int *size) ;
void       GWGetVSliderSize(GEM_WINDOW *wnd, int *size) ;

void       GWGetWorkXYWH(GEM_WINDOW *wnd, int *x, int *y, int *w, int *h ) ;
void       GWGetCurrXYWH(GEM_WINDOW *wnd, int *x, int *y, int *w, int *h ) ;
void       GWSetCurrXYWH(GEM_WINDOW *wnd, int x, int y, int w, int h ) ;

GEM_WINDOW *GWGetWindow(int x, int y) ;
GEM_WINDOW *GWGetWindowByClass(char *class_name) ;

void       GWDestroyWindow(GEM_WINDOW *wnd) ;

void       GWRePaint(GEM_WINDOW *wnd) ;

/* Handlers par defaut */
void GWOnDraw(GEM_WINDOW *wnd, int xycoords[4]) ;
int  GWOnTopped(GEM_WINDOW *wnd) ;
int  GWOnClose(GEM_WINDOW *wnd) ;
void GWOnMove(GEM_WINDOW *wnd, int xywh[4]) ;
void GWOnHSlider(GEM_WINDOW *wnd, int pos) ;
void GWOnVSlider(GEM_WINDOW *wnd, int pos) ;
void GWOnSize(GEM_WINDOW *wnd, int xywh[4]) ;
int  GWOnFulled(GEM_WINDOW *wnd, int xywh[4]) ;
int  GWOnRestoreFulled(GEM_WINDOW *wnd, int xywh[4]) ;
int  GWOnIconify(GEM_WINDOW *wnd, int xywh[4]) ;
int  GWOnUnIconify(GEM_WINDOW *wnd, int xywh[4]) ;

#define IDOK      1
#define IDCANCEL  2

typedef struct
{
  int    RsrcId ; /* Si -1, Object sert de reference */
  OBJECT *Object ; /* Inutilise si RsrcId != -1 */
  int    WKind ;   /* En plus de MOVER, CLOSER et NAME */
  int    NWKind ;  /* Si on ne veut pas CLOSER par ex. */
  char   Title[100] ;
  char   ClassName[20] ;
  int    XPos, YPos ;    /* Si (0,0), Parent sera utilise pour le positionnement */ 
  GEM_WINDOW *Parent ; /* Bureau si NULL */
  void   *UserData ;   /* Stockage des valeurs utiles pour le retour */
  long   ExtensionSize ;

  void (*OnInitDialog)(void *wnd) ; 
  int  (*OnObjectNotify)(void *wnd, int obj) ; /* >=0 : sortie de la fenetre, code IDOK ou IDCANCEL */
  int  (*OnCloseDialog)(void *wnd) ; 
}
DLGDATA ;

int         GWSetWndRscIcon(GEM_WINDOW *wnd, int form, int id) ;
int         GWIsWindowValid(GEM_WINDOW *wnd) ;
GEM_WINDOW* GWCreateDialog(DLGDATA *data) ;
GEM_WINDOW* GWCreateWindowCmdBar(DLGDATA *data) ;
int         GWDoModal(GEM_WINDOW *wnd, int start_ob) ; /* IDOK ou IDCANCEL */
int         GWOnKeyPressedDlg(void *w, int key) ;
int         GWCloseDlg(void *w) ;
void        GWOnMoveDlg(void *gw, int xywh[4]) ;
int         OnLButtonDownDlg(void *w, int mk_state, int mx, int my) ;
void        OnDrawDlg(void *w, int xywh[4]) ;
int         OnToppedDlg(void *w) ;
int         GWBasicModalHandler(void) ;

#define    GWM_STARTMSG    500
#define    GWM_DESTROY     (GWM_STARTMSG + 0)
#define    WM_USER_FIRST   (GWM_STARTMSG + 50)
#define    WM_USER_LAST    (GWM_STARTMSG + 99)

int  PostMessage(GEM_WINDOW *wnd, int id, int mesg[4]) ;
void GWDestroyWindow(GEM_WINDOW *wnd) ;


GEM_APP* GWGetApp(int argc, char **argv) ;
void     GWDeclareAndRunApp(GEM_APP *app) ;
int      GeneralMesagHandler(EVENT *event) ;

#endif
