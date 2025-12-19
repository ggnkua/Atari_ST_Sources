#include "e_gem.h"

#define MAX_WINDOWS	64
#define MAX_DIALS	32

#define SCANRET 	28
#define SCANENTER	114
#define SCANUNDO	97
#define SCANHELP	98
#define SCANUP		72
#define SCANDOWN	80
#define SCANLEFT	75
#define CTRLLEFT	115
#define CTRLRIGHT	116
#define SCANRIGHT	77
#define SCANTAB 	15
#define SCANHOME	71
#define SCANDEL 	83
#define SCANBS		14
#define SCANINS 	82
#define SCANESC		1

#ifdef __MINT_LIB__
#define CAST	(TEDINFO *)
#else
#ifdef __PUREC__
#define CAST	(long)
#endif
#endif

#define	_set_clip	restore_clipping

extern	IMAGES _radios,_checks,_arrows_down,_arrows_up,_arrows_left,_arrows_right,_cycles;
extern	boolean _back_win;
extern	int _bevent,_ascii,_ascii_digit,_xacc_msgs;
extern  int _opened,_popup;
extern	WIN _windows[];

extern  char _cycle_hot,_close_hot;
extern  int  _cycle,_close;

extern  DIAINFO	*_dia_list[MAX_DIALS+1];
extern	int	_dia_len;

extern	int cdecl (*_icfs)(int,...);

char	*_strmfp(char *,char *, char *);

void	_init_dialog(XEVENT *);

boolean	_is_hidden(OBJECT *,int);
int		_is_hotkey(OBJECT *,int);
void	_check_hotkeys(OBJECT *);

void	_vdi_attr(int,int,int);

void	_bitblt(OBJECT *,MFDB *,boolean);
void 	_line(int,int,int,int);
void 	_bar(int,int,int,int,int,int);
void 	_rectangle(int,int,int,int);

int		_get_hotkey(OBJECT *,int);
char	_upper(char);
char	_lower(char);

void 	_beg_ctrl(void);
void 	_end_ctrl(void);

void 	_no_click(void);
void	_mouse_pos(int *,int *);
int		_mouse_but(void);

char	*_edit_get_info(OBJECT *,int,int,EDINFO *);
void	_calc_cursor(DIAINFO *,EDINFO *,GRECT *);
void	_set_cursor(DIAINFO *,int,int);
EDINFO	*_cursor_off(DIAINFO *);
void	_insert_history(DIAINFO *);

int		_objc_edit_handler(DIAINFO *,int,int,XEVENT *,int *);
int		_next_edit(DIAINFO *,int);
int		_messag_handler(int,XEVENT *,int *,DIAINFO **);
void	_send_msg(void *,int,int);
void	 _init_xformdo(XEVENT *,DIAINFO *,int);

int 	_call_event_handler(int,XEVENT *,int);

void	_XAccSendStartup(char *,char *,int,int,int);
void	_XAccAvExit(void);
int		_XAccComm(int *);