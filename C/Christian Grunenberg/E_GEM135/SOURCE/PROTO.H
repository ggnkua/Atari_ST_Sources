#include "e_gem.h"

#ifdef __MINT_LIB__
#define CAST	(TEDINFO *)
#else
#ifdef __PUREC__
#define CAST	(long)
#endif
#endif

#define	_set_clip	restore_clipping

extern 	char *strmfp(char *,char *, char *);
extern  int	_is_hotkey(OBJECT *,int,int);

extern	IMAGES radios,checks,arrows_down,arrows_up,arrows_left,arrows_right,cycles;
extern 	boolean _back_win;
extern 	DIAINFO *_dia_list[];
extern 	int _dia_len,_bevent;

void	_bitblt(OBJECT *,MFDB *,boolean);
void 	_line(int,int,int,int);
void 	_bar(int,int,int,int,int,int);
void 	_rectangle(int,int,int,int);
void 	_vdi_attr(int,int,int);
void 	_text_attr(int,int,int);

int		_get_hotkey(OBJECT *,int);
char	_upper(char);
char	_lower(char);

void 	_beg_ctrl(void);
void 	_end_ctrl(void);

void 	_no_click(void);
void	_mouse_pos(int *,int *);
int		_mouse_but(void);
