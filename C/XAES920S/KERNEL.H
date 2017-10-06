/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
 *	Kernal Message Handler
 */

#ifndef _KERNAL_H_
#define _KERNAL_H_

void XaAES(void);
void setup_k_function_table(void);
XA_CLIENT *find_focus(XA_WINDOW *w, bool *waiting);

Tab *new_task(Tab *new);
Tab *nest_task(Tab *tab);
void free_task(Tab *, short *);

/* Mouse device commands */

#ifdef __GNUC__
#define	MOOSE_INIT_PREFIX		0x4d49		/* 'MI' */
#define	MOOSE_DCLICK_PREFIX		0x4d44		/* 'MD' */
#define MOOSE_BUTTON_PREFIX		0x5842		/* 'XB' */
#define MOOSE_MOVEMENT_PREFIX	0x584d		/* 'XM' */
#define MOOSE_VECS_PREFIX		0x4d56		/* 'MV' */
#else
enum
{
	MOOSE_INIT_PREFIX		= 'MI',
	MOOSE_DCLICK_PREFIX		= 'MD',
	MOOSE_BUTTON_PREFIX		= 'XB',
	MOOSE_MOVEMENT_PREFIX	= 'XM',
	MOOSE_VECS_PREFIX		= 'MV'		/* HR: Get VDI vector addresses. */
};
#endif

typedef struct moose_init_com
{
	unsigned short	init_prefix;
	void *dum;
} MOOSE_INIT_COM;

typedef struct moose_dclick_com
{
	unsigned short dclick_prefix, dclick_time;
} MOOSE_DCLICK_COM;

typedef short vdi_vec(void, ...);

typedef struct moose_vecs_com
{
	unsigned short vecs_prefix;
	vdi_vec *motv, *butv, *timv;
} MOOSE_VECS_COM;

typedef struct moose_data
{
	unsigned
	short l,		/* HR: record length */
	      ty;		/* HR: button & movement */
	short x,
	      y,
	      state,
	      clicks,
	      dbg1,
	      dbg2;
} MOOSE_DATA;				/* HR */

typedef struct mouse_data
{
	char state,
	     dx,
	     dy,
	     dum;
} MOUSE_DATA;				/* HR */

void remove_client_handle(XA_CLIENT *client);
void insert_client_handle(XA_CLIENT *client);
void close_client(LOCK lock, XA_CLIENT *client);
void pending_client_exit(XA_CLIENT *client);

void Block(XA_CLIENT *client, short which);			/* HR 080601 */
void Unblock(XA_CLIENT *client, unsigned long value, short which);

void get_mouse(void);

AES_function
	XA_appl_init,
	XA_appl_exit,
	XA_appl_search,
	XA_appl_write,
	XA_appl_yield,
	XA_new_client,
	XA_client_exit,
	XA_appl_getinfo,
	XA_appl_find,
	XA_evnt_button,
	XA_evnt_keybd,
	XA_evnt_mesag,
	XA_evnt_mouse,
	XA_evnt_multi,
	XA_evnt_timer,
	XA_wind_create,
	XA_wind_open,
	XA_wind_close,
	XA_wind_find,
	XA_wind_set,
	XA_wind_get,
	XA_wind_update,
	XA_wind_delete,
	XA_wind_new,
	XA_wind_calc,
	XA_graf_mouse,
	XA_graf_handle,
	XA_graf_mkstate,
	XA_graf_rubberbox,
	XA_graf_dragbox,
	XA_graf_watchbox,
	XA_graf_growbox,
	XA_graf_shrinkbox,
	XA_graf_movebox,
	XA_graf_slidebox,
	XA_rsrc_load,
	XA_rsrc_free,
	XA_rsrc_gaddr,
	XA_rsrc_obfix,
	XA_rsrc_rcfix,
	XA_objc_draw,
	XA_objc_offset,
	XA_objc_find,
	XA_objc_change,
	XA_objc_add,
	XA_objc_delete,
	XA_objc_order,
	XA_objc_edit,
	XA_objc_sysvar,				/* HR */
	XA_form_center,
	XA_form_dial,
	XA_form_button,
	XA_form_alert,
	XA_form_do,
	XA_form_error,
	XA_form_keybd,
	XA_menu_bar,
	XA_menu_tnormal,
	XA_menu_ienable,
	XA_menu_icheck,
	XA_menu_text,
	XA_menu_register,
	XA_menu_popup,
	XA_menu_attach,
	XA_menu_istart,
	XA_menu_settings,
	XA_shell_write,
	XA_shell_read,
	XA_shell_find,
	XA_shell_envrn,
	XA_appl_pipe,
	XA_scrap_read,
	XA_scrap_write,
	XA_fsel_input,
	XA_fsel_exinput
	;

#endif
