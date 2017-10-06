#ifndef	__MESAGDEF__
#define	__MESAGDEF__

#include	"global.h"
#include	"types.h"

typedef struct {
	WORD	type;
	WORD	sid;
	WORD	length;
	WORD	msg0;
	WORD	msg1;
	WORD	msg2;
	WORD	msg3;
	WORD	msg4;
}COMMSG;

#define	MSG_LENGTH	sizeof(COMMSG)

		/* event message values */
#define MN_SELECTED	10

typedef struct {
	WORD		type;
	WORD		sid;
	WORD		length;
	WORD		title;
	WORD		item;
	OBJECT	*tree;
	WORD		parent;
}MENUMSG;


typedef struct
{
	WORD	type;	/*type of message WM_REDRAW*/
	WORD	sid;	/*sender id*/
	WORD	length;
	WORD	wid;	/*window id*/
	RECT	area;	/*area to redraw*/
}REDRAWSTRUCT;

typedef struct
{
	WORD	type;	/*type of message KB_PRESS*/
	WORD	sid;	/*sender id*/
	WORD	length;
	WORD	keycode;	/*keycode*/
	WORD	msg1;
	WORD	msg2;
	WORD	msg3;
	WORD	msg4;
}KEYPRESS;

typedef struct
{
	WORD	type;	/*type of message MB_CLICK*/
	WORD	sid;	/*sender id*/
	WORD	length;
	WORD	buttons;	/*button status*/
	WORD	changed;	/*change status*/
	LONG	when;		/*time of change*/
	WORD	msg4;
}BUTTONCLICK;

typedef struct
{
	WORD	type;	/*type of message MB_CLICK*/
	WORD	sid;	/*sender id*/
	WORD	length;
	WORD	mx;		/*mouse position*/
	WORD	my;		
	WORD	buttons;	/*button status*/
	WORD	kstate;	/*shift key state*/
	WORD	number;	/*number*/
}MOUSERECT;

typedef struct
{
	WORD	mx;		/*mouse position*/
	WORD	my;		
	WORD	buttons;	/*button status*/
	WORD	kstate;	/*shift key state*/	
}EVNTREC_MOUSE;

#define MH_TOP    200
#define	MO_RECT1	202
#define	MO_RECT2	203

#endif
