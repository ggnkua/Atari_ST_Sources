/****************************************************************************

 Module
  docalls.c
  
 Description
  AES routine identification and distribution in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)

 Revision history
 
  960103 cg
   Added standard header.
   Fsel_exinput() added.

  960420 cg
   Changed h_aes_call to use a call table instead of switch.
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include	<stdio.h>

#include "appl.h"
#include "debug.h"
#include "evnt.h"
#include "form.h"
#include "fsel.h"
#include "global.h"
#include "graf.h"
#include "menu.h"
#include "objc.h"
#include "rdwrs.h"
#include "rsrc.h"
#include "scrp.h"
#include "shel.h"
#include "types.h"
#include "wind.h"

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

typedef void   (*AESCALL)(AES_PB *);

typedef struct {
	BYTE    *name;
	AESCALL func;
}AESCB;
 
/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static AESCB aescalls[] = {
	/* 0x0000 */
	NULL, NULL,
	
	/* 0x0001 */
	
	NULL, NULL,
	
	/* 0x0002 */
	NULL, NULL,
	
	/* 0x0003 */
	NULL, NULL,
	
	/* 0x0004 */
	NULL, NULL,
	
	/* 0x0005 */
	NULL, NULL,
	
	/* 0x0006 */
	NULL, NULL,
	
	/* 0x0007 */
	NULL, NULL,
	
	/* 0x0008 */
	NULL, NULL,
	
	/* 0x0009 */
	NULL, NULL,
	
	/* 0x000a */
	"appl_init", Appl_init,

	/* 0x000b */
	"appl_read", Appl_read,

	/* 0x000c */
	"appl_write", Appl_write,

	/* 0x000d*/
	"appl_find",Appl_find,

	/* 0x000e */
	"appl_tplay", NULL,

	/* 0x000f */
	"appl_trecord", NULL,

	/* 0x0010 */
	NULL, NULL,
			
	/* 0x0011 */
	NULL, NULL,

	/* 0x0012*/
	"appl_search", Appl_search,
			
	/* 0x0013*/
	"appl_exit", Appl_exit,
			
	/* 0x0014 */
	"evnt_keybd", Evnt_keybd,
			
	/* 0x0015 */
	"evnt_button", Evnt_button,

	/* 0x0016 */
	"evnt_mouse", Evnt_mouse,
			
	/* 0x0017 */
	"evnt_mesag", Evnt_mesag,
			
	/* 0x0018 */
	"evnt_timer", Evnt_timer,
			
	/* 0x0019 */
	"evnt_multi", Evnt_multi,
			
	/* 0x001a */
	"evnt_dclick", Evnt_dclick,

	/* 0x001b */
	NULL, NULL,
			
	/* 0x001c */
	NULL, NULL,
	
	/* 0x001d */
	NULL, NULL,
	
	/* 0x001e */
	"menu_bar", Menu_bar,
			
	/* 0x001f */
	"menu_icheck", Menu_icheck,
			
	/* 0x0020 */
	"menu_ienable", Menu_ienable,
			
	/* 0x0021 */
	"menu_tnormal", Menu_tnormal,
			
	/* 0x0022 */
	"menu_text", Menu_text,
			
	/* 0x0023 */
	"menu_register", Menu_register,

	/* 0x0024 */
	"menu_popup", NULL,

	/* 0x0025 */
	"menu_attach", NULL,

	/* 0x0026 */
	"menu_istart", NULL,

	/* 0x0027 */
	"menu_settings", NULL,

	/* 0x0028 */
	"objc_add", Objc_add,
			
	/* 0x0029 */
	"objc_delete", Objc_delete,
			
	/* 0x002a */
	"objc_draw", Objc_draw,
			
	/* 0x002b */
	"objc_find", Objc_find,
			
	/* 0x002c */
	"objc_offset", Objc_offset,
			
	/* 0x002d */
	"objc_order", NULL,

	/* 0x002e */
	"objc_edit", Objc_edit,
			
	/* 0x002f */
	"objc_change", Objc_change,
			
	/* 0x0030 */
	"objc_sysvar", Objc_sysvar,
			
	/* 0x0031 */
	NULL, NULL,
	
	/* 0x0032 */
	"form_do", Form_do,
			
	/* 0x0033 */
	"form_dial", Form_dial,
			
	/* 0x0034 */
	"form_alert", Form_alert,
			
	/* 0x0035 */
	"form_error", Form_error,
			
	/* 0x0036 */
	"form_center", Form_center,
			
	/* 0x0037 */
	"form_keybd", Form_keybd,
			
	/* 0x0038 */
	"form_button", Form_button,

	/* 0x0039 */
	NULL, NULL,
	
	/* 0x003a */
	NULL, NULL,
	
	/* 0x003b */
	NULL, NULL,
	
	/* 0x003c */
	NULL, NULL,
	
	/* 0x003d */
	NULL, NULL,
	
	/* 0x003e */
	NULL, NULL,
	
	/* 0x003f */
	NULL, NULL,
	
	/* 0x0040 */
	NULL, NULL,
	
	/* 0x0041 */
	NULL, NULL,
	
	/* 0x0042 */
	NULL, NULL,
	
	/* 0x0043 */
	NULL, NULL,
	
	/* 0x0044 */
	NULL, NULL,
	
	/* 0x0045 */
	NULL, NULL,
	
	/* 0x0046 */
	"graf_rubberbox", Graf_rubberbox,
	
	/* 0x0047 */
	"graf_dragbox", Graf_dragbox,
			
	/* 0x0048 */
	"graf_movebox", Graf_movebox,
	
	/* 0x0049 */
	"graf_growbox", Graf_growbox,
			
	/* 0x004a */
	"graf_shrinkbox", Graf_shrinkbox,
			
	/* 0x004b */
	"graf_watchbox", Graf_watchbox,
			
	/* 0x004c */
	"graf_slidebox", Graf_slidebox,
			
	/* 0x004d */
	"graf_handle", Graf_handle,
			
	/* 0x004e */
	"graf_mouse", Graf_mouse,
			
	/* 0x004f */
	"graf_mkstate", Graf_mkstate,
			
	/* 0x0050 */
	"scrp_read", Scrp_read,
			
	/* 0x0051 */
	"scrp_write", Scrp_write,
			
	/* 0x0052 */
	NULL, NULL,
	
	/* 0x0053 */
	NULL, NULL,
	
	/* 0x0054 */
	NULL, NULL,
	
	/* 0x0055 */
	NULL, NULL,
	
	/* 0x0056 */
	NULL, NULL,
	
	/* 0x0057 */
	NULL, NULL,
	
	/* 0x0058 */
	NULL, NULL,
	
	/* 0x0059 */
	NULL, NULL,
	
	/* 0x005a */
	"fsel_input", Fsel_input,
			
	/* 0x005b */
	"fsel_exinput", Fsel_exinput,

	/* 0x005c */
	NULL, NULL,
	
	/* 0x005d */
	NULL, NULL,
	
	/* 0x005e */
	NULL, NULL,
	
	/* 0x005f */
	NULL, NULL,
	
	/* 0x0060 */
	NULL, NULL,
	
	/* 0x0061 */
	NULL, NULL,
	
	/* 0x0062 */
	NULL, NULL,
	
	/* 0x0063 */
	NULL, NULL,
	
	/* 0x0064 */
	"wind_create", Wind_create,
			
	/* 0x0065 */
	"wind_open", Wind_open,
			
	/* 0x0066 */
	"wind_close", Wind_close,
			
	/* 0x0067 */
	"wind_delete", Wind_delete,
			
	/* 0x0068 */
	"wind_get", Wind_get,
			
	/* 0x0069 */
	"wind_set", Wind_set,
			
	/* 0x006a */
	"wind_find", Wind_find,
			
	/* 0x006b */
	"wind_update", Wind_update,
			
	/* 0x006c */
	"wind_calc", Wind_calc,
			
	/* 0x006d */
	"wind_new", Wind_new,

	/* 0x006e */
	"rsrc_load", Rsrc_load,
			
	/* 0x006f */
	"rsrc_free", Rsrc_free,
			
	/* 0x0070 */
	"rsrc_gaddr", Rsrc_gaddr,
			
	/* 0x0071 */
	"rsrc_saddr", Rsrc_saddr,
			
	/* 0x0072 */
	"rsrc_obfix", Rsrc_obfix,
			
	/* 0x0073 */
	"rsrc_rcfix", Rsrc_rcfix,
			
	/* 0x0074 */
	NULL, NULL,
	
	/* 0x0075 */
	NULL, NULL,
	
	/* 0x0076 */
	NULL, NULL,
	
	/* 0x0077 */
	NULL, NULL,

	/* 0x0078 */
	"shel_read", Shel_read,
			
 	/* 0x0079 */
 	"shel_write", Shel_write,		
 			
	/* 0x007a */
	"shel_get", NULL,
	
	/* 0x007b */
	"shel_put", NULL,
	
	/* 0x007c */
	"shel_find", Shel_find,
			
	/* 0x007d */
	"shel_envrn", Shel_envrn,
	
	/* 0x007e */
	NULL, NULL,
	
	/* 0x007f */
	NULL, NULL,
	
	/* 0x0080 */
	NULL, NULL,
	
	/* 0x0081 */
	NULL, NULL,
	
	/* 0x0082 */
	"appl_getinfo", Appl_getinfo
};

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

void h_aes_call(AES_PB *apb) {
/*
#define DCDEBUG
*/
#ifdef DCDEBUG
	if((apb->global->apid != 0) && (apb->control[0] != 25)) {
		DB_printf("Aes call %d (0x%x) %s\r\n",apb->control[0],apb->control[0],aescalls[apb->control[0]].name);
	};
#endif
	
	if(aescalls[apb->control[0]].func) {
		aescalls[apb->control[0]].func(apb);
	}
	else {
		if(aescalls[apb->control[0]].name) {
			DB_printf("%s: Line %d:\r\n"
						    "Unimplemented AES call %d %s",
						    __FILE__,__LINE__,apb->control[0],
						    aescalls[apb->control[0]].name);
		}
		else {
			DB_printf( "%s: Line %d:\r\n"
						           "Illegal AES call %d",
						           __FILE__,__LINE__,apb->control[0]);
		};
	};

#ifdef DCDEBUG
	if((apb->global->apid != 0) && (apb->control[0] != 25)) {
		DB_printf("/Aes call %d\r\n",apb->control[0]);
	};
#endif
}

