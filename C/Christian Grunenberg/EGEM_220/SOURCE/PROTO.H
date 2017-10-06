
#include "e_gem.h"

typedef void (*WIN_REDRAW)(int,WIN*,GRECT*);
typedef void (*WIN_DRAW)(int,WIN*,GRECT*,GRECT*,void*);

#ifdef __MINT_LIB__
#define CAST	(TEDINFO *)
#else
#define CAST	(long)
#endif

typedef struct
{
	int msg[8];
} MESSAG;

typedef struct
{
	int msg_max,msg_tail,msg_head;
	MESSAG *msg;
} XMSG;

typedef unsigned int uint;

typedef struct
{
	uint mode;
	long index;
	uint dev,reserved1,nlink,uid,gid;
	long size,blksize,nblocks;
	int mtime,mdate;
	int atime,adate;
	int ctime,cdate;
	int attr,reserved2;
	long reserved3[2];
} X_ATTR;

#ifndef SMALL_NO_ICONIFY
#define win_iconified(win)	(win->iconified & (ICONIFIED|ICFS))
#endif

#define	FONT_WAIT	0
#define	XACC_WAIT	1
#define AV_WAIT		2
#define PAULA_WAIT	3

#ifndef SMALL_NO_MENU
extern	OBJECT *_menu;
#endif

extern	char *_win_id;
extern	IMAGES _radios,_checks,_arrows_down,_arrows_up,_arrows_left,_arrows_right,_cycles;
extern	boolean _back_win,_nonsel_fly,_dial_round,_app_mouse;
extern	int _up_test,_rc_handle,_untop,_mouse_off;
extern  int _opened,_ac_close,_alert_color,_min_timer,_no_output,_ibm_hot,_small_hot;
#ifndef SMALL_NO_ICONIFY
extern	int _iconified;
#endif
extern	WIN *_window_list[];

#define output	(_dia_len==0 && !_no_output)
#define protect	(mint || magx>=0x0300)

extern	int _theight;

extern  MITEM _menu_items[];
extern  int _mitems_cnt;

extern	MITEM *_xmenu_items;
extern	int _xitems_cnt;

#ifndef SMALL_NO_SCROLL
extern	int _scroll,_scroll_all;
#endif

#ifndef SMALL_NO_HZ
extern DIAINFO *_last_cursor;
extern int _crs_hz,_no_edit;
#endif
#ifndef SMALL_EDIT
extern int _ascii,_ascii_digit;
#ifndef SMALL_NO_CLIPBRD
extern int _edit_clip;
#endif
#endif

#ifndef SMALL_NO_XACC_AV
extern int _xacc_msgs;
#endif

#ifndef SMALL_NO_DD
extern  int _dd_available;
#endif

#define TOP_TIMER	500

extern long _top_timer;
extern long _Topper(long,long,MKSTATE *);

extern  DIAINFO	*_dia_list[MAX_DIALS+1];
extern	int	_dia_len,_win_len;

#ifndef SMALL_NO_ICONIFY
extern	int cdecl (*_icfs)(int,...);
int cdecl _default_icfs(int,...);
#endif

void	_init_dialog(XEVENT *);

boolean	_is_hidden(OBJECT *,int);
int		_is_hotkey(OBJECT *,int);
void	_check_hotkeys(OBJECT *);
int		_get_hotkey(OBJECT *,int);
int		_set_hotkey(OBJECT *,OBJECT *,char);

void	_vdi_attr(int,int,int,int);
int		_rc_sc_savetree(OBJECT *,RC_RECT *);
void 	_bar(int,int,int,int,int,int,int,int);

void	_new_top(int,int);
void	_get_font_size(OBJECT *,int *,int *,int *);

#ifndef SMALL_NO_EDIT
char	*_edit_get_info(OBJECT *,int,int,EDINFO *);
void	_calc_cursor(DIAINFO *,EDINFO *,GRECT *);
void	_cursor_off(DIAINFO *);
#ifndef SMALL_EDIT
void	_insert_history(DIAINFO *);
#endif
int		_insert_buf(DIAINFO *,char *,int);
void	_objc_edit_handler(DIAINFO *,int,int,XEVENT *,int *);
int		_next_edit(DIAINFO *,int);
#endif

int		_messag_handler(int,XEVENT *,int *,DIAINFO **);
int		_send_msg(void *,int,int,int,int);
void	_inform(int);
void	_inform_buffered(int);
void 	_send_puf(int,int,int *);

#ifndef SMALL_NO_SCROLL
void	_window_scroll_pos(WIN *,int);
void	_arrow_window(SCROLL *,int,int);
#endif
int 	_call_event_handler(int,XEVENT *,int);

#ifndef SMALL_NO_FSEL
int		_FselEvent(int,int *,XEVENT *);
#endif

#ifndef SMALL_NO_FONT
int			_InitFont(void);
#endif

#ifndef SMALL_NO_XACC_AV
void	_XAccSendStartup(char *,char *,int,int,int);
void	_XAccAvExit(void);
int		_XAccComm(int *);
void	_AvAllWins(void);
void	_MultiAv(void);
int		_Wait(int,int,int,char*);
#endif

#ifndef SMALL_NO_DD
void	_rec_ddmsg(int*);
#endif

#ifndef SMALL_NO_CLIPBRD
void	_scrp_init(void);
#endif

void	_clip_rect(GRECT *);
void	_ob_xdraw(OBJECT *,int,GRECT *);
