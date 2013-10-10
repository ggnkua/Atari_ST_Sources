#ifndef	_MAIN_H
#define	_MAIN_H

	#define	TRUE -1
	#define	FALSE 0

	#define	WINTYPE		(NAME | MOVE | CLOSE | SMALLER | INFO | FULLER)

	#define MAX_WID		work_out[0]+1
	#define MAX_HGT		work_out[1]+1

	typedef struct {
		short	handle;
		GRECT	w_rect;
		GRECT	b_rect;
		} WINDOW;

#endif
