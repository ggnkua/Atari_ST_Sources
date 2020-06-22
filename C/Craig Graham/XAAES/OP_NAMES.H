/* Standard GEM AES op-codes - sensible names for diags */

#if GENERATE_DIAGS

#define MAX_NAMED_DIAG 130

char *op_code_names[]={"","","","","","","","","","",	/* 0-9 */
						"appl_init",					/* 10 */
						"appl_read",					/* 11 */
						"appl_write",					/* 12 */
						"appl_find",					/* 13 */
						"appl_tplay",					/* 14 */
						"appl_trecord",					/* 15 */
						"","","",						/* 16-18 */
						"appl_exit",					/* 19 */
						"evnt_keybd",					/* 20 */
						"evnt_button",					/* 21 */
						"evnt_mouse",					/* 22 */
						"evnt_mesag",					/* 23 */
						"evnt_timer",					/* 24 */
						"evnt_multi",					/* 25 */
						"","","","",					/* 26-29 */
						"menu_bar",						/* 30 */
						"menu_icheck",					/* 31 */
						"menu_ienable",					/* 32 */
						"menu_tnormal",					/* 33 */
						"menu_text",					/* 34 */
						"menu_register",				/* 35 */
						"?","?","?","?",				/* 36-39 */
						"objc_add",						/* 40 */
						"objc_delete",					/* 41 */
						"objc_draw",					/* 42 */
						"objc_find",					/* 43 */
						"objc_offset",					/* 44 */
						"objc_order",					/* 45 */
						"objc_edit",					/* 46 */
						"objc_change",					/* 47 */
						"","",							/* 48-49 */
						"form_do",						/* 50 */
						"form_dial",					/* 51 */
						"form_alert",					/* 52 */
						"form_error",					/* 53 */
						"form_center",					/* 54 */
						"form_keybd",					/* 55 */
						"form_button",					/* 56 */
						"","","",						/* 57-59 */
						"","","","","","","","","","",	/* 60-69 */
						"graf_rubberbox",				/* 70 */
						"graf_dragbox",					/* 71 */
						"graf_movebox",					/* 72 */
						"graf_growbox",					/* 73 */
						"graf_shrinkbox",				/* 74 */
						"graf_watchbox",				/* 75 */
						"graf_slidebox",				/* 76 */
						"graf_handle",					/* 77 */
						"graf_mouse",					/* 78 */
						"graf_mkstate",					/* 79 */
						"scrap_read",					/* 80 */
						"scrap_write",					/* 81 */
						"","","","","","","","",		/* 82-89 */
						"fsel_input",					/* 90 */
						"fsel_exinput",					/* 91 */
						"","","","","","","","",		/* 92-99 */
						"wind_create",					/* 100 */
						"wind_open",					/* 101 */
						"wind_close",					/* 102 */
						"wind_delete",					/* 103 */
						"wind_get",						/* 104 */
						"wind_set",						/* 105 */
						"wind_find",					/* 106 */
						"wind_update",					/* 107 */
						"wind_calc",					/* 108 */
						"wind_new",						/* 109 */
						"rsrc_load",					/* 110 */
						"rsrc_free",					/* 111 */
						"rsrc_gaddr",					/* 112 */
						"rsrc_saddr",					/* 113 */
						"rsrc_obfix",					/* 114 */
						"","","","","",					/* 115-119 */
						"shel_read",					/* 120 */
						"shel_write",					/* 121 */
						"shel_get",						/* 122 */
						"shel_put",						/* 123 */
						"shel_find",					/* 124 */
						"shel_envrn",					/* 125 */
						"","","","",					/* 126-129 */
						"appl_getinfo"					/* 130 */
				};

#else

char *op_code_names[]={"","","","","","","","","",""};
#define MAX_NAMED_DIAG 0

#endif
