#include "e_gem.h"

typedef void (*D_PROC)(DIAINFO *,GRECT *,GRECT *);
typedef void (*R_PROC)(WIN *,GRECT *);

#define MAX_MSG	128

typedef struct
{
	int msg[8];
} MESSAG;

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

#define win_iconified(win)	(win->iconified & (ICONIFIED|ICFS))

#define MAX_WINDOWS	64
#define MAX_DIALS	32

#ifdef __MINT_LIB__
#define CAST	(TEDINFO *)
#else
#ifdef __PUREC__
#define CAST	(long)
#endif
#endif

extern	OBJECT *_menu,_alert_tree[];
extern	IMAGES _radios,_checks,_arrows_down,_arrows_up,_arrows_left,_arrows_right,_cycles;
extern	boolean _back_win,_nonsel_fly,_dial_round;
extern	int _bevent,_bottom,_ascii,_ascii_digit,_xacc_msgs;
extern  int _opened,_popup,_no_button,_ac_close,_alert_color,_min_timer;
extern	WIN _windows[];

extern  char _cycle_hot,_close_hot;
extern  int  _cycle,_close,_no_av_win;

extern	MESSAG _messages[];
extern	int _msg_cnt,_dd_available;

extern  DIAINFO	*_dia_list[MAX_DIALS+1];
extern	int	_dia_len,_last_top;

extern	int cdecl (*_icfs)(int,...);

int cdecl _default_icfs(int,...);
int 	_icfs_iconify(WIN *,int,int);

void	_init_dialog(XEVENT *);

boolean	_is_hidden(OBJECT *,int);
int		_is_hotkey(OBJECT *,int);
void	_check_hotkeys(OBJECT *);

void	_vdi_attr(int,int,int);

int		_rc_sc_savetree(OBJECT *,RC_RECT *);
void 	_line(int,int,int,int);
void 	_bar(int,int,int,int,int,int,int);
void 	_rectangle(int,int,int,int);

int		_get_hotkey(OBJECT *,int);

void 	_beg_ctrl(void);
void 	_end_ctrl(void);

int		_get_top(void);

void	_set_menu(void);

void 	_no_click(void);
void	_mouse_pos(int *,int *);
int		_mouse_but(void);

char	*_edit_get_info(OBJECT *,int,int,EDINFO *);
void	_calc_cursor(DIAINFO *,EDINFO *,GRECT *);
void	_set_cursor(DIAINFO *,int,int);
EDINFO	*_cursor_off(DIAINFO *);
void	_insert_history(DIAINFO *);
int		_insert_buf(DIAINFO *,char *,int);

int		_objc_edit_handler(DIAINFO *,int,int,XEVENT *,int *);
int		_next_edit(DIAINFO *,int);
int		_messag_handler(int,XEVENT *,int *,DIAINFO **);
void	_send_msg(void *,int,int,int,int);
void 	_send_puf(int,int *);
void	_init_xformdo(XEVENT *,DIAINFO *,int);

void	_window_fast_mouse(WIN *,int);
void	_reset_mouse(void);
void	_arrow_window(SCROLL *,int,int);
void	_cycle_close_window(int,int);
int 	_call_event_handler(int,XEVENT *,int);

void	_XAccSendStartup(char *,char *,int,int,int);
void	_XAccAvExit(void);
int		_XAccComm(int *);

void	_rec_ddmsg(int*);
void	_scrp_init(void);

void	_clip_rect(GRECT *);
