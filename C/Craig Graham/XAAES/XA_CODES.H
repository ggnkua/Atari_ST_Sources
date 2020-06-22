/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
	AES OP-Code definitions
*/

#ifndef _XA_CODES_H_
#define _XA_CODES_H_

/* Standard GEM AES op-codes */

#define XA_APPL_INIT	10
#define XA_APPL_WRITE	12
#define XA_APPL_FIND	13
#define XA_APPL_SEARCH	18
#define XA_APPL_EXIT	19
#define XA_APPL_GETINFO	130

#define XA_EVNT_KEYBD	20
#define XA_EVNT_BUTTON	21
#define XA_EVNT_MESAG	23
#define XA_EVNT_TIMER	24
#define XA_EVNT_MULTI	25

#define XA_MENU_BAR		30
#define XA_MENU_ICHECK	31
#define XA_MENU_IENABLE	32
#define XA_MENU_TNORMAL	33
#define XA_MENU_TEXT	34
#define XA_MENU_REGISTER	35

#define XA_OBJC_DRAW	42
#define XA_OBJC_FIND	43
#define XA_OBJC_OFFSET	44
#define XA_OBJC_EDIT	46
#define XA_OBJC_CHANGE	47

#define XA_FORM_DO		50
#define XA_FORM_DIAL	51
#define XA_FORM_ALERT	52
#define XA_FORM_ERROR	53
#define XA_FORM_CENTER	54
#define XA_FORM_KEYBD	55
#define XA_FORM_BUTTON	56

#define XA_GRAF_RUBBERBOX	70
#define XA_GRAF_DRAGBOX	71
#define XA_GRAF_MOVEBOX	72
#define XA_GRAF_GROWBOX	73
#define XA_GRAF_SHRINKBOX	74
#define XA_GRAF_WATCHBOX	75
#define XA_GRAF_HANDLE	77
#define XA_GRAF_MOUSE	78
#define XA_GRAF_MKSTATE	79

#define XA_SCRAP_READ	80
#define XA_SCRAP_WRITE	81

#define XA_WIND_CREATE	100
#define XA_WIND_OPEN	101
#define XA_WIND_CLOSE	102
#define XA_WIND_GET		104
#define XA_WIND_DELETE	103
#define XA_WIND_SET		105
#define XA_WIND_FIND	106
#define XA_WIND_UPDATE	107
#define XA_WIND_CALC	108
#define XA_WIND_NEW		109

#define XA_RSRC_LOAD	110
#define XA_RSRC_FREE	111
#define XA_RSRC_GADDR	112
#define XA_RSRC_OBFIX	114

#define XA_SHELL_READ	120
#define XA_SHELL_WRITE	121
#define XA_SHELL_FIND	124
#define XA_SHELL_ENVRN	125

/* XaAES specific extended op-codes */
/* (these all start at 250, well out of the way of standard AES calls) */
#define XA_BUTTON_CLICK	250
#define XA_NEW_CLIENT	251
#define XA_CLIENT_EXIT	252
#define XA_SHUTDOWN		253

#define XA_APPL_PIPE	260

#endif