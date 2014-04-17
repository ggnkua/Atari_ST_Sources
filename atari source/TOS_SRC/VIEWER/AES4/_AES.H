/* _aes.h - low-level interface to AES
 *=======================================================================
 * 920628 kbad
 */

#ifndef LATTICE
#define __regargs /**/
#endif

int __regargs _aes(short fn, void *pb);
#define aes(fn) _aes(((fn)-10)*4, apb)

enum AESfn {

/* Application Manager */
APPL_INIT=10,	APPL_READ,	APPL_WRITE,	APPL_FIND,	APPL_TPLAY,
APPL_TRECORD,					APPL_SEARCH=18,	APPL_EXIT,

/* Event Manager */
EVNT_KEYBD=20,	EVNT_BUTTON,	EVNT_MOUSE,	EVNT_MESAG,	EVNT_TIMER,
EVNT_MULTI,	EVNT_DCLICK,

/* Menu Manager */
MENU_BAR=30,	MENU_ICHECK,	MENU_IENABLE,	MENU_TNORMAL,	MENU_TEXT,
MENU_REGISTER,	MENU_POPUP,	MENU_ATTACH,	MENU_ISTART,	MENU_SETTINGS,

/* Object Manager */
OBJC_ADD=40,	OBJC_DELETE,	OBJC_DRAW,	OBJC_FIND,	OBJC_OFFSET,
OBJC_ORDER,	OBJC_EDIT,	OBJC_CHANGE,	OBJC_SYSVAR,

/* Form Manager */
FORM_DO=50,	FORM_DIAL,	FORM_ALERT,	FORM_ERROR,	FORM_CENTER,
FORM_KEYBD,	FORM_BUTTON,

/* Graphics Manager */
GRAF_RUBBOX=70,	GRAF_DRAGBOX,	GRAF_MOVEBOX,	GRAF_GROWBOX,	GRAF_SHRINKBOX,
GRAF_WATCHBOX,	GRAF_SLIDEBOX,	GRAF_HANDLE,	GRAF_MOUSE,	GRAF_MKSTATE,

/* Scrap Manager */
SCRP_READ=80,	SCRP_WRITE,

/* File Selector Manager */
FSEL_INPUT=90,	FSEL_EXINPUT,

/* Window Manager */
WIND_CREATE=100, WIND_OPEN,	WIND_CLOSE,	WIND_DELETE,	WIND_GET,
WIND_SET,	WIND_FIND,	WIND_UPDATE,	WIND_CALC,	WIND_NEW,

/* Resource Manager */
RSRC_LOAD=110,	RSRC_FREE,	RSRC_GADDR,	RSRC_SADDR,	RSRC_OBFIX,
RSRC_RCFIX,

/* Shell Manager */
SHEL_READ=120,	SHEL_WRITE,	SHEL_GET,	SHEL_PUT,	SHEL_FIND,
SHEL_ENVRN

};
