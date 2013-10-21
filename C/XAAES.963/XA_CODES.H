/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
	AES OP-Code definitions
*/

#ifndef _XA_CODES_H_
#define _XA_CODES_H_

/* Standard GEM AES op-codes */
typedef enum xa_opcodes
{
	XA_APPL_INIT	= 10,
	XA_APPL_READ,
	XA_APPL_WRITE,
	XA_APPL_FIND,
	XA_APPL_TPLAY,
	XA_APPL_TRECORD,
	XA_APPL_YIELD   = 17,
	XA_APPL_SEARCH,
	XA_APPL_EXIT,
	XA_APPL_CONTROL = 129,
	XA_APPL_GETINFO,

	XA_EVNT_KEYBD	= 20,
	XA_EVNT_BUTTON,
	XA_EVNT_MOUSE,
	XA_EVNT_MESAG,
	XA_EVNT_TIMER,
	XA_EVNT_MULTI,
	XA_EVNT_DCLICK,

	XA_MENU_BAR		= 30,
	XA_MENU_ICHECK,
	XA_MENU_IENABLE,
	XA_MENU_TNORMAL,
	XA_MENU_TEXT,
	XA_MENU_REGISTER,
	XA_MENU_POPUP,
	XA_MENU_ATTACH,
	XA_MENU_ISTART,
	XA_MENU_SETTINGS,

	XA_OBJC_ADD		= 40,
	XA_OBJC_DELETE,
	XA_OBJC_DRAW,
	XA_OBJC_FIND,
	XA_OBJC_OFFSET,
	XA_OBJC_ORDER,
	XA_OBJC_EDIT,
	XA_OBJC_CHANGE,
	XA_OBJC_SYSVAR,

	XA_FORM_DO		= 50,
	XA_FORM_DIAL,
	XA_FORM_ALERT,
	XA_FORM_ERROR,
	XA_FORM_CENTER,
	XA_FORM_KEYBD,
	XA_FORM_BUTTON,

	XA_GRAF_RUBBERBOX	= 70,
	XA_GRAF_DRAGBOX,
	XA_GRAF_MOVEBOX,
	XA_GRAF_GROWBOX,
	XA_GRAF_SHRINKBOX,
	XA_GRAF_WATCHBOX,
	XA_GRAF_SLIDEBOX,
	XA_GRAF_HANDLE,
	XA_GRAF_MOUSE,
	XA_GRAF_MKSTATE,

	XA_SCRAP_READ	= 80,
	XA_SCRAP_WRITE,

	XA_FSEL_INPUT	= 90,
	XA_FSEL_EXINPUT,

	XA_WIND_CREATE	= 100,
	XA_WIND_OPEN,
	XA_WIND_CLOSE,
	XA_WIND_DELETE,
	XA_WIND_GET,
	XA_WIND_SET,
	XA_WIND_FIND,
	XA_WIND_UPDATE,
	XA_WIND_CALC,
	XA_WIND_NEW,

	XA_RSRC_LOAD	= 110,
	XA_RSRC_FREE,
	XA_RSRC_GADDR,
	XA_RSRC_SADDR,
	XA_RSRC_OBFIX,
	XA_RSRC_RCFIX,

	XA_SHELL_READ	= 120,
	XA_SHELL_WRITE,
	XA_SHELL_GET,
	XA_SHELL_PUT,
	XA_SHELL_FIND,
	XA_SHELL_ENVRN,

	XA_FORM_POPUP	= 135,			/* HR 051101 */

#if WDIAL
	XA_WDIAL_CREATE	= 160,			/* HR 261101 */
	XA_WDIAL_OPEN,
	XA_WDIAL_CLOSE,
	XA_WDIAL_DELETE,
	XA_WDIAL_GET,
	XA_WDIAL_SET,
	XA_WDIAL_EVENT,
	XA_WDIAL_REDRAW,

	XA_LBOX_CREATE	= 170,
	XA_LBOX_UPDATE,
	XA_LBOX_DO,
	XA_LBOX_DELETE,
	XA_LBOX_GET,
	XA_LBOX_SET,
#endif

/* XaAES specific extended op-codes */
/* (these all start at 250, well out of the way of standard AES calls) */
	XA_BUTTON_CLICK	= 250,
	XA_NEW_CLIENT,
	XA_CLIENT_EXIT,
	XA_SHUTDOWN,

	XA_OBJC_SETSCROLL,

	XA_APPL_PIPE	= 260,
	KtableSize					/* HR: This, of course, is how it should be defined. :-) */
} XA_opcode;

#endif
