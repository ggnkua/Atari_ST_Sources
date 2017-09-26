#include "manitor.h"
#include "..\toslib\aes\aes.h"
#include <stdlib.h>
#include <string.h>
#include "gscript.h"
#include "..\toslib\aes\av_msg.h"
#include "..\toslib\aes\olga.h"
#include "..\toslib\aes\bubblgem.h"

int aes_is_traced = DEFAULT_AES_TRACE;
int show_snd_messages = DEFAULT_SHOW_SND_MSG;
int show_rcv_messages = DEFAULT_SHOW_RCV_MSG;
int rcv_only_screnmgr = DEFAULT_RCV_SCRENMGR;
int show_msg_prgname = DEFAULT_SHOW_MSG_PRGNAME;

AESFUNCS aes_funcs;

/* ACHTUNG: Funktionen mÅssen nach Opcode sortiert sein!!!! */

AESFUNC aes_func[] = {
	{ 0, 1, 0, NO_SUBCODE, NO_SUBCODE, "recalc_cicon_colours", 1, {{ADDRIN, 0, T_ADR, "palette"}}, 0, {0}, FALSE },
	{10, 0, 0, NO_SUBCODE, NO_SUBCODE, "appl_init", 0, {0}, 1, {{INTOUT, 0, T_INT, "apid"}}, FALSE},
	{11, 2, 1, NO_SUBCODE, NO_SUBCODE, "appl_read", 3, {{INTIN, 0, T_AESID, "apid"}, {INTIN, 1, T_INT, "len"}, {ADDRIN, 0, T_ADR, "buf"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{12, 2, 1, NO_SUBCODE, NO_SUBCODE, "appl_write", 3, {{INTIN, 0, T_AESID, "apid"}, {INTIN, 1, T_INT, "len"}, {ADDRIN, 0, T_ADR, "buf"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{13, 0, 1, NO_SUBCODE, NO_SUBCODE, "appl_find", 1, {{ADDRIN, 0, T_APPFINDSTR, "name"}}, 1, {{INTOUT, 0, T_INT, "apid"}}, FALSE},
	{14, 2, 1, NO_SUBCODE, NO_SUBCODE, "appl_tplay", 3, {{ADDRIN, 0, T_ADR, "buf"}, {INTIN, 0, T_INT, "len"}, {INTIN, 1, T_INT, "scale"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{15, 1, 1, NO_SUBCODE, NO_SUBCODE, "appl_trecord", 2, {{ADDRIN, 0, T_ADR, "buf"}, {INTIN, 0, T_INT, "len"}}, 1, {{INTOUT, 0, T_INT, "count"}}, FALSE},
	{16, 2, 0, NO_SUBCODE, NO_SUBCODE, "appl_bvset", 2, {{INTIN, 0, T_INT, "disk"}, {INTIN, 1, T_INT, "hard"}}, 0, {0}, FALSE},
	{17, 0, 0, NO_SUBCODE, NO_SUBCODE, "appl_yield", 0, {0}, 0, {0}, FALSE},
	{18, 1, 1, NO_SUBCODE, NO_SUBCODE, "appl_search", 2, {{INTIN, 0, T_INT, "mode"}, {ADDRIN, 0, T_ADR, "buf"}}, 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "type"}, {INTOUT, 2, T_INT, "id"}}, FALSE},
	{19, 0, 0, NO_SUBCODE, NO_SUBCODE, "appl_exit", 0, {0}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{20, 0, 0, NO_SUBCODE, NO_SUBCODE, "evnt_keybd", 0, {0}, 1, {{INTOUT, 0, T_KEY, "key"}}, FALSE},
	{21, 3, 0, NO_SUBCODE, NO_SUBCODE, "evnt_button", 3, {{INTIN, 1, T_INT, "nclicks"}, {INTIN, 2, T_INT, "mask"}, {INTIN, 3, T_INT, "state"}}, 5, {{INTOUT, 0, T_INT, "clicks"}, {INTOUT, 1, T_INT, "x"}, {INTOUT, 2, T_INT, "y"},
																			{INTOUT, 3, T_INT, "but"}, {INTOUT, 4, T_SHIFT, "shift"}}, FALSE},
	{22, 5, 0, NO_SUBCODE, NO_SUBCODE, "evnt_mouse", 5, {{INTIN, 0, T_INT, "flg_leave"}, {INTIN, 1, T_INT, "x"}, {INTIN, 2, T_INT, "y"}, {INTIN, 3, T_INT, "w"}, {INTIN, 4, T_INT, "h"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{23, 0, 1, NO_SUBCODE, NO_SUBCODE, "evnt_mesag", 1, {{ADDRIN, 0, T_ADR, "msgbuf"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{24, 2, 0, NO_SUBCODE, NO_SUBCODE, "evnt_timer", 2, {{INTIN, 0, T_INT, "locount"}, {INTIN, 1, T_INT, "hicount"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{25, 16, 1, NO_SUBCODE, NO_SUBCODE, "evnt_multi", 17, {{INTIN, 0, T_MULTITYPES, 0L}, {INTIN, 1, T_INT, "nclicks"}, {INTIN, 2, T_INT, "bmask"}, {INTIN, 3, T_INT, "bstate"}, {INTIN, 4, T_INT, "flg1_leave"},
			{INTIN, 5, T_INT, "x1"}, {INTIN, 6, T_INT, "y1"}, {INTIN, 7, T_INT, "w1"}, {INTIN, 8, T_INT, "h1"}, {INTIN, 9, T_INT, "flg2_leave"}, {INTIN, 10, T_INT, "x2"}, {INTIN, 11, T_INT, "y2"}, {INTIN, 12, T_INT, "w2"}, {INTIN, 13, T_INT, "h2"},
			{ADDRIN, 0, T_ADR, "msgbuf"}, {INTIN, 14, T_INT, "locount"}, {INTIN, 15, T_INT, "hicount"}},
			1, {{INTOUT, 0, T_EVNTMULTI}}, FALSE},
	{26, 2, 0, NO_SUBCODE, NO_SUBCODE, "evnt_dclick", 2, {{INTIN, 0, T_INT, "val"}, {INTIN, 1, T_INT, "setflg"}}, 1, {{INTOUT, 0, T_INT, "speed"}}, FALSE},
	{30, 1, 1, NO_SUBCODE, NO_SUBCODE, "menu_bar", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "show"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{31, 2, 1, NO_SUBCODE, NO_SUBCODE, "menu_icheck", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "chkflag"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{32, 2, 1, NO_SUBCODE, NO_SUBCODE, "menu_ienable", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "chkflag"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{33, 2, 1, NO_SUBCODE, NO_SUBCODE, "menu_tnormal", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "chkflag"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{34, 1, 2, NO_SUBCODE, NO_SUBCODE, "menu_text", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {ADDRIN, 1, T_STR, "txt"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{35, 1, 1, NO_SUBCODE, NO_SUBCODE, "menu_register", 2, {{INTIN, 0, T_AESID, "apid"}, {ADDRIN, 0, T_STR, "name"}}, 1, {{INTOUT, 0, T_INT, "menuid"}}, FALSE},
	{36, 1, 0, NO_SUBCODE, NO_SUBCODE, "menu_unregister", 1, {{INTIN, 0, T_INT, "menuid"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{36, 2, 2, NO_SUBCODE, NO_SUBCODE, "menu_popup", 4, {{ADDRIN, 0, T_ADR, "menu"}, {INTIN, 0, T_INT, "x"}, {INTIN, 1, T_INT, "y"}, {ADDRIN, 1, T_ADR, "data"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{37, 2, 0, NO_SUBCODE, NO_SUBCODE, "menu_click", 2, {{INTIN, 0, T_INT, "click"}, {INTIN, 1, T_INT, "setflag"}}, 1, {{INTOUT, 0, T_INT, "click"}}, FALSE},
	{37, 2, 2, NO_SUBCODE, NO_SUBCODE, "menu_attach", 4, {{INTIN, 0, T_INT, "flag"}, {ADDRIN, 0, T_ADR, "tree"}, {INTIN, 1, T_INT, "obj"}, {ADDRIN, 1, T_ADR, "data"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{38, 3, 1, NO_SUBCODE, NO_SUBCODE, "menu_istart", 4, {{INTIN, 0, T_INT, "flag"}, {ADDRIN, 0, T_ADR, "tree"}, {INTIN, 1, T_INT, "menu"}, {INTIN, 1, T_ADR, "item"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{39, 1, 1, NO_SUBCODE, NO_SUBCODE, "menu_settings", 2, {{INTIN, 0, T_INT, "flag"}, {ADDRIN, 0, T_ADR, "values"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{40, 2, 1, NO_SUBCODE, NO_SUBCODE, "objc_add", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "parent"}, {INTIN, 1, T_INT, "child"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{41, 1, 1, NO_SUBCODE, NO_SUBCODE, "objc_delete", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{42, 6, 1, NO_SUBCODE, NO_SUBCODE, "objc_draw", 7, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "start"}, {INTIN, 1, T_INT, "depth"}, {INTIN, 2, T_INT, "x"}, {INTIN, 3, T_INT, "y"}, {INTIN, 4, T_INT, "w"}, {INTIN, 5, T_INT, "h"}},
														1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{43, 4, 1, NO_SUBCODE, NO_SUBCODE, "objc_find", 5, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "start"}, {INTIN, 1, T_INT, "depth"}, {INTIN, 2, T_INT, "x"}, {INTIN, 3, T_INT, "y"}}, 1, {{INTOUT, 0, T_INT, "obj"}}, FALSE},
	{44, 1, 1, NO_SUBCODE, NO_SUBCODE, "objc_offset", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "x"}, {INTOUT, 2, T_INT, "y"}}, FALSE},
	{45, 2, 1, NO_SUBCODE, NO_SUBCODE, "objc_order", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "newpos"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{46, 4, 1, NO_SUBCODE, NO_SUBCODE, "objc_edit", 5, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_KEY, "key"}, {INTIN, 2, T_INT, "xpos"}, {INTIN, 3, T_INT, "subfn"}},
																	2, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "xpos"}}, FALSE},
	{46, 4, 2, NO_SUBCODE, NO_SUBCODE, "objc_xedit", 6, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_KEY, "key"}, {INTIN, 2, T_INT, "xpos"}, {INTIN, 3, T_INT, "subfn"}, {ADDRIN, 1, T_GRECT, "rect"}},
																	2, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "xpos"}}, FALSE},
	{47, 8, 1, NO_SUBCODE, NO_SUBCODE, "objc_change", 9, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "resvd"}, {INTIN, 2, T_INT, "x"}, {INTIN, 3, T_INT, "y"}, {INTIN, 4, T_INT, "w"}, {INTIN, 5, T_INT, "h"},
																			{INTIN, 6, T_INT, "newstate"}, {INTIN, 7, T_INT, "redraw"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{48, 4, 0, NO_SUBCODE, NO_SUBCODE, "objc_sysvar", 4, {{INTIN, 0, T_INT, "mode"}, {INTIN, 1, T_INT, "which"}, {INTIN, 2, T_INT, "ival1"}, {INTIN, 3, T_INT, "ival2"}},
																		3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "oval1"}, {INTOUT, 2, T_INT, "oval2"}}, FALSE},
	{50, 1, 1, NO_SUBCODE, NO_SUBCODE, "form_do", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 1, {{INTOUT, 0, T_INT, "obj"}}, FALSE},
	{50, 1, 3, NO_SUBCODE, NO_SUBCODE, "form_xdo", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {ADDRIN, 1, T_ADR, "scantab"}, {ADDRIN, 2, T_ADR, "flyinf"}}, 2, {{INTOUT, 0, T_INT, "obj"}, {INTOUT,1, T_INT, "cursor"}}, FALSE},
	{51, 9, 0, NO_SUBCODE, NO_SUBCODE, "form_dial", 9, {{INTIN, 0, T_FMD, "subfn"}, {INTIN, 1, T_INT, "lx"}, {INTIN, 2, T_INT, "ly"}, {INTIN, 3, T_INT, "lw"}, {INTIN, 4, T_INT, "lh"},
																		{INTIN, 5, T_INT, "bx"}, {INTIN, 6, T_INT, "by"}, {INTIN, 7, T_INT, "bw"}, {INTIN, 8, T_INT, "bh"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{51, 9, 2, NO_SUBCODE, NO_SUBCODE, "form_xdial", 11, {{INTIN, 0, T_FMD, "subfn"}, {INTIN, 1, T_INT, "lx"}, {INTIN, 2, T_INT, "ly"}, {INTIN, 3, T_INT, "lw"}, {INTIN, 4, T_INT, "lh"},
																		{INTIN, 5, T_INT, "bx"}, {INTIN, 6, T_INT, "by"}, {INTIN, 7, T_INT, "bw"}, {INTIN, 8, T_INT, "bh"}, {ADDRIN, 0, T_ADR, "flyinf"}, {ADDRIN, 1, T_LONG, "resvd"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{52, 1, 1, NO_SUBCODE, NO_SUBCODE, "form_alert", 2, {{INTIN, 0, T_INT, "defbutton"}, {ADDRIN, 0, T_STR, "string"}}, 1, {{INTOUT, 0, T_INT, "button"}}, FALSE},
	{53, 1, 0, NO_SUBCODE, NO_SUBCODE, "form_error", 1, {{INTIN, 0, T_INT, "dosenkot"}}, 1, {{INTOUT, 0, T_INT, "button"}}, FALSE},
	{54, 0, 1, NO_SUBCODE, NO_SUBCODE, "form_center", 1, {{ADDRIN, 0, T_ADR, "tree"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{55, 3, 1, NO_SUBCODE, NO_SUBCODE, "form_keybd", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "next"}, {INTIN, 1, T_KEY, "key"}},
																	3, {{INTOUT, 0, T_INT, "continue"}, {INTOUT, 1, T_INT, "nxtobj"}, {INTOUT, 2, T_INT, "nxtchar"}}, FALSE},
	{56, 2, 1, NO_SUBCODE, NO_SUBCODE, "form_button", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "nclicks"}},
																	2, {{INTOUT, 0, T_INT, "continue"}, {INTOUT, 1, T_INT, "nxtobj"}}, FALSE},
	{60, 3, 2, NO_SUBCODE, NO_SUBCODE, "objc_wdraw", 5, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "depth"}, {ADDRIN, 1, T_GRECT, "clip"}, {INTIN, 2, T_INT, "whnd"}}, 0, {0}, FALSE},
	{61, 3, 2, NO_SUBCODE, NO_SUBCODE, "objc_wchange", 5, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "newstate"}, {ADDRIN, 1, T_GRECT, "clip"}, {INTIN, 2, T_INT, "whnd"}}, 0, {0}, FALSE},
	{62, 4, 1, NO_SUBCODE, NO_SUBCODE, "graf_wwatchbox", 5, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "instate"}, {INTIN, 2, T_INT, "outstate"}, {INTIN, 3, T_INT, "whnd"}}, 1, {{INTOUT, 0, T_INT, "mouse_in"}}, FALSE},
	{63, 3, 1, NO_SUBCODE, NO_SUBCODE, "form_wbutton", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "nclicks"}, {INTIN, 2, T_INT, "whnd"}},
																	2, {{INTOUT, 0, T_INT, "continue"}, {INTOUT, 1, T_INT, "nxtobj"}}, FALSE},
	{64, 3, 1, NO_SUBCODE, NO_SUBCODE, "form_wkeybd", 5, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "next"}, {INTIN, 1, T_KEY, "key"}, {INTIN, 3, T_INT, "whnd"}},
																	3, {{INTOUT, 0, T_INT, "continue"}, {INTOUT, 1, T_INT, "nxtobj"}, {INTOUT, 2, T_INT, "nxtchar"}}, FALSE},
	{65, 5, 1, NO_SUBCODE, NO_SUBCODE, "objc_wedit", 6, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_KEY, "key"}, {INTIN, 2, T_INT, "xpos"}, {INTIN, 3, T_INT, "subfn"}, {INTIN, 4, T_INT, "whnd"}},
																	2, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "xpos"}}, FALSE},
	{69, 4, 1, NO_SUBCODE, NO_SUBCODE, "graf_mutlirubber", 5, {{INTIN, 0, T_INT, "x"}, {INTIN, 1, T_INT, "y"}, {INTIN, 2, T_INT, "minw"}, {INTIN, 3, T_INT, "minh"}, {ADDRIN, 0, T_GRECT, "rec"}},
																			 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "outw"}, {INTOUT, 2, T_INT, "outh"}}, FALSE},
	{70, 4, 0, NO_SUBCODE, NO_SUBCODE, "graf_rubbox", 4, {{INTIN, 0, T_INT, "x"}, {INTIN, 1, T_INT, "y"}, {INTIN, 2, T_INT, "min_w"}, {INTIN, 3, T_INT, "min_h"}},
																		3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "last_w"}, {INTOUT, 2, T_INT, "last_h"}}, FALSE},
	{71, 8, 0, NO_SUBCODE, NO_SUBCODE, "graf_dragbox", 8, {{INTIN, 0, T_INT, "w"}, {INTIN, 1, T_INT, "h"}, {INTIN, 2, T_INT, "x"}, {INTIN, 3, T_INT, "y"}, {INTIN, 4, T_INT, "boundx"}, {INTIN, 5, T_INT, "boundy"},
																			{INTIN, 6, T_INT, "boundw"}, {INTIN, 7, T_INT, "boundh"}},
																		3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "x"}, {INTOUT, 2, T_INT, "y"}}, FALSE},
	{72, 6, 0, NO_SUBCODE, NO_SUBCODE, "graf_mbox", 6, {{INTIN, 0, T_INT, "w"}, {INTIN, 1, T_INT, "h"}, {INTIN, 2, T_INT, "x1"}, {INTIN, 3, T_INT, "y1"}, {INTIN, 4, T_INT, "x2"}, {INTIN, 5, T_INT, "y2"}},
																		1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{73, 8, 0, NO_SUBCODE, NO_SUBCODE, "graf_growbox", 8, {{INTIN, 0, T_INT, "x1"}, {INTIN, 1, T_INT, "y1"}, {INTIN, 2, T_INT, "w1"}, {INTIN, 3, T_INT, "h1"}, {INTIN, 4, T_INT, "x2"}, {INTIN, 5, T_INT, "y2"},
																			{INTIN, 6, T_INT, "w2"}, {INTIN, 7, T_INT, "h2"}},
																		1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{74, 8, 0, NO_SUBCODE, NO_SUBCODE, "graf_shrinkbox", 8, {{INTIN, 0, T_INT, "x1"}, {INTIN, 1, T_INT, "y1"}, {INTIN, 2, T_INT, "w1"}, {INTIN, 3, T_INT, "h1"}, {INTIN, 4, T_INT, "x2"}, {INTIN, 5, T_INT, "y2"},
																			{INTIN, 6, T_INT, "w2"}, {INTIN, 7, T_INT, "h2"}},
																		1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{75, 4, 1, NO_SUBCODE, NO_SUBCODE, "graf_watchbox", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "instate"}, {INTIN, 2, T_INT, "outstate"}}, 1, {{INTOUT, 0, T_INT, "mouse_in"}}, FALSE},
	{76, 3, 1, NO_SUBCODE, NO_SUBCODE, "graf_slidebox", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "parent"}, {INTIN, 1, T_INT, "slider"}, {INTIN, 2, T_INT, "vertical"}}, 1, {{INTOUT, 0, T_INT, "pos"}}, FALSE},
	{77, 0, 0, NO_SUBCODE, NO_SUBCODE, "graf_handle", 0, {0}, 5, {{INTOUT, 0, T_INT, "hnd"}, {INTOUT, 1, T_INT, "wchar"}, {INTOUT, 2, T_INT, "hchar"}, {INTOUT, 3, T_INT, "wbox"}, {INTOUT, 4, T_INT, "hbox"}, {INTOUT, 5, T_INT, "device"}}, FALSE},
	{78, 1, 1, NO_SUBCODE, NO_SUBCODE, "graf_mouse", 2, {{INTIN, 0, T_GRAFMOUSE, 0L}, {ADDRIN, 0, T_ADR, "mform"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{79, 0, 0, NO_SUBCODE, NO_SUBCODE, "graf_mkstate", 0, {0}, 5, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "x"}, {INTOUT, 2, T_INT, "y"}, {INTOUT, 3, T_INT, "mbut"}, {INTOUT, 4, T_SHIFT, "shift"}}, FALSE},
	{80, 0, 1, NO_SUBCODE, NO_SUBCODE, "scrp_read", 1, {{ADDRIN, 0, T_ADR, "buf"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{81, 0, 1, NO_SUBCODE, NO_SUBCODE, "scrp_write", 1, {{ADDRIN, 0, T_STR, "path"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{82, 0, 0, NO_SUBCODE, NO_SUBCODE, "scrp_clear", 0, {0}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{90, 0, 2, NO_SUBCODE, NO_SUBCODE, "fsel_input", 2, {{ADDRIN, 0, T_STR, "path"}, {ADDRIN, 1, T_STR, "mask"}}, 2, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "button"}}, FALSE},
	{91, 0, 3, NO_SUBCODE, NO_SUBCODE, "fsel_exinput", 3, {{ADDRIN, 0, T_STR, "path"}, {ADDRIN, 1, T_STR, "mask"}, {ADDRIN, 2, T_STR, "label"}}, 2, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "button"}}, FALSE},
	{99, 2, 1, NO_SUBCODE, NO_SUBCODE, "wind_draw", 2, {{INTIN, 0, T_INT, "whnd"}, {INTIN, 1, T_INT, "wi_dstartob"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{100, 5, 0, NO_SUBCODE, NO_SUBCODE, "wind_create", 5, {{INTIN, 0, T_WKIND, "kind"}, {INTIN, 1, T_INT, "max_x"}, {INTIN, 2, T_INT, "max_y"}, {INTIN, 3, T_INT, "max_w"}, {INTIN, 4, T_INT, "max_h"}}, 1, {{INTOUT, 0, T_INT, "whnd"}}, FALSE},
	{101, 5, 0, NO_SUBCODE, NO_SUBCODE, "wind_open", 5, {{INTIN, 0, T_INT, "whnd"}, {INTIN, 1, T_INT, "x"}, {INTIN, 2, T_INT, "y"}, {INTIN, 3, T_INT, "w"}, {INTIN, 4, T_INT, "h"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{102, 1, 0, NO_SUBCODE, NO_SUBCODE, "wind_close", 1, {{INTIN, 0, T_INT, "whnd"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{103, 1, 0, NO_SUBCODE, NO_SUBCODE, "wind_delete", 1, {{INTIN, 0, T_INT, "whnd"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{104, 2, 0, NO_SUBCODE, NO_SUBCODE, "wind_get", 2, {{INTIN, 0, T_INT, "whnd"}, {INTIN, 1, T_WGETSET, 0L}}, 5, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, 0L}, {INTOUT, 2, T_INT, 0L}, {INTOUT, 3, T_INT, 0L}, {INTOUT, 4, T_INT, 0L}}, FALSE},
	{104, 3, 0, NO_SUBCODE, NO_SUBCODE, "wind_get", 3, {{INTIN, 0, T_INT, "whnd"}, {INTIN, 1, T_WGETSET, 0L}, {INTIN, 2, T_INT, "welem"}},
																	5, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, 0L}, {INTOUT, 2, T_INT, 0L}, {INTOUT, 3, T_INT, 0L}, {INTOUT, 4, T_INT, 0L}}, FALSE},	/* fÅr WF_DCOLOR */
	{105, 6, 0, NO_SUBCODE, NO_SUBCODE, "wind_set", 6, {{INTIN, 0, T_INT, "whnd"}, {INTIN, 1, T_WGETSET, 0L}, {INTIN, 2, T_INT, 0L}, {INTIN, 3, T_INT, 0L}, {INTIN, 4, T_INT, 0L}, {INTIN, 5, T_INT, 0L}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{105, 4, 0, NO_SUBCODE, NO_SUBCODE, "wind_set", 4, {{INTIN, 0, T_INT, "whnd"}, {INTIN, 1, T_WGETSET, 0L}, {INTIN, 2, T_INT, 0L}, {INTIN, 3, T_INT, 0L}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{106, 2, 0, NO_SUBCODE, NO_SUBCODE, "wind_find", 2, {{INTIN, 0, T_INT, "x"}, {INTIN, 1, T_INT, "y"}}, 1, {{INTOUT, 0, T_INT, "whnd"}}, FALSE},
	{107, 1, 0, NO_SUBCODE, NO_SUBCODE, "wind_update", 1, {{INTIN, 0, T_WUPD, 0L}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{108, 6, 0, NO_SUBCODE, NO_SUBCODE, "wind_calc", 6, {{INTIN, 0, T_WCALC, 0L}, {INTIN, 1, T_WKIND, "kind"}, {INTIN, 2, T_INT, "x"}, {INTIN, 3, T_INT, "y"}, {INTIN, 4, T_INT, "w"}, {INTIN, 5, T_INT, "h"}},
																	5, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "x"}, {INTOUT, 2, T_INT, "y"}, {INTOUT, 3, T_INT, "w"}, {INTOUT, 4, T_INT, "h"}}, FALSE},
	{109, 0, 0, NO_SUBCODE, NO_SUBCODE, "wind_new", 0, {0}, 0, {0}, FALSE},
	{110, 0, 1, NO_SUBCODE, NO_SUBCODE, "rsrc_load", 1, {{ADDRIN, 0, T_STR, "file"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{111, 0, 0, NO_SUBCODE, NO_SUBCODE, "rsrc_free", 0, {0}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{112, 2, 0, NO_SUBCODE, NO_SUBCODE, "rsrc_gaddr", 2, {{INTIN, 0, T_INT, "type"}, {INTIN, 1, T_INT, "index"}}, 2, {{INTOUT, 0, T_INT, "ok"}, {ADDROUT, 0, T_ADR, "adr"}}, FALSE},
	{113, 2, 1, NO_SUBCODE, NO_SUBCODE, "rsrc_saddr", 3, {{INTIN, 0, T_INT, "type"}, {INTIN, 1, T_INT, "index"}, {ADDRIN, 0, T_ADR, "adr"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{114, 1, 1, NO_SUBCODE, NO_SUBCODE, "rsrc_obfix", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{115, 0, 1, NO_SUBCODE, NO_SUBCODE, "rsrc_rcfix", 1, {{ADDRIN, 0, T_ADR, "rsh"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{120, 0, 2, NO_SUBCODE, NO_SUBCODE, "shel_read", 2, {{ADDRIN, 0, T_ADR, "cmd"}, {ADDRIN, 1, T_ADR, "tail"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{121, 3, 2, NO_SUBCODE, NO_SUBCODE, "shel_write", 1, {{AESPBIN, 0, T_SHELWRITE, 0L}}, 1, {{INTOUT, 0, T_INT, "apid"}}, FALSE},
	{122, 1, 1, NO_SUBCODE, NO_SUBCODE, "shel_get", 2, {{ADDRIN, 0, T_ADR, "buf"}, {INTIN, 0, T_INT, "len"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{123, 1, 1, NO_SUBCODE, NO_SUBCODE, "shel_put", 2, {{ADDRIN, 0, T_ADR, "buf"}, {INTIN, 0, T_INT, "len"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{124, 0, 1, NO_SUBCODE, NO_SUBCODE, "shel_find", 1, {{ADDRIN, 0, T_STR, "path"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{125, 0, 2, NO_SUBCODE, NO_SUBCODE, "shel_envrn", 2, {{ADDRIN, 0, T_ADR, "&val"}, {ADDRIN, 1, T_STR, "name"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{126, 0, 2, NO_SUBCODE, NO_SUBCODE, "shel_rdef", 2, {{ADDRIN, 0, T_ADR, "name"}, {ADDRIN, 1, T_ADR, "dir"}}, 0, {0}, FALSE},
	{127, 0, 2, NO_SUBCODE, NO_SUBCODE, "shel_wdef", 2, {{ADDRIN, 0, T_STR, "name"}, {ADDRIN, 1, T_STR, "dir"}}, 0, {0}, FALSE},
	{129, 2, 1, NO_SUBCODE, NO_SUBCODE, "appl_control", 3, {{INTIN, 0, T_INT, "ap_cid"}, {INTIN, 1, T_INT, "ap_cwhat"}, {ADDRIN, 0, T_ADR, "ap_count"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{130, 1, 0, NO_SUBCODE, NO_SUBCODE, "appl_getinfo", 1, {{INTIN, 0, T_INT, "type"}}, 5, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "o1"}, {INTOUT, 2, T_INT, "o2"}, {INTOUT, 3, T_INT, "o3"}, {INTOUT, 4, T_INT, "o4"}}, FALSE},
	{130, 6, 0, NO_SUBCODE, NO_SUBCODE, "xgrf_stepcalc", 6, {{INTIN, 0, T_INT, "orgw"}, {INTIN, 1, T_INT, "orgh"}, {INTIN, 2, T_INT, "xc"}, {INTIN, 3, T_INT, "yc"}, {INTIN, 4, T_INT, "w"}, {INTIN, 5, T_INT, "h"}},
																		6, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "cx"}, {INTOUT, 2, T_INT, "cy"}, {INTOUT, 3, T_INT, "cnt"}, {INTOUT, 4, T_INT, "xstep"}, {INTOUT, 5, T_INT, "ystep"}}, FALSE},
	{131, 9, 0, NO_SUBCODE, NO_SUBCODE, "xgrf_2box", 9, {{INTIN, 5, T_INT, "cx"}, {INTIN, 6, T_INT, "cy"}, {INTIN, 7, T_INT, "w"}, {INTIN, 8, T_INT, "h"}, {INTIN, 4, T_INT, "corners"}, {INTIN, 0, T_INT, "cnt"}, {INTIN, 1, T_INT, "xstep"},
																		{INTIN, 2, T_INT, "ystep"}, {INTIN, 3, T_INT, "doubled"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{135, 2, 1, NO_SUBCODE, NO_SUBCODE, "form_popup", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "x"}, {INTIN, 1, T_INT, "y"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{135, 6, 3, NO_SUBCODE, NO_SUBCODE, "xfrm_popup", 10, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "x"}, {INTIN, 1, T_INT, "y"}, {INTIN, 2, T_INT, "firstscrlob"}, {INTIN, 3, T_INT, "lastscrlob"}, {INTIN, 4, T_INT, "nlines"},
																	{ADDRIN, 1, T_ADR, "init"}, {ADDRIN, 2, T_ADR, "param"}, {INTIN, 5, T_INT, "lastscrlpos"}}, 2, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "lastscrlpos"}}, FALSE},
	{136, 2, 1, NO_SUBCODE, NO_SUBCODE, "form_xerr", 2, {{INTIN, 0, T_LONG, "errcode"}, {ADDRIN, 0, T_STR, "errfile"}}, 1, {{INTOUT, 0, T_INT, "button"}}, FALSE},
	{160, 2, 4, NO_SUBCODE, NO_SUBCODE, "wdlg_create", 6, {{ADDRIN, 0, T_ADR, "handler"}, {ADDRIN, 1, T_ADR, "tree"}, {ADDRIN, 2, T_ADR, "user_data"}, {INTIN, 0, T_INT, "code"}, {ADDRIN, 3, T_ADR, "data"}, {INTIN, 1, T_INT, "flags"}},
																	1, {{ADDROUT, 0, T_ADR, "dialog"}}, FALSE},
	{161, 4, 3, NO_SUBCODE, NO_SUBCODE, "wdlg_open", 7, {{ADDRIN, 0, T_ADR, "dialog"}, {ADDRIN, 1, T_STR, "title"}, {INTIN, 0, T_WKIND, "kind"}, {INTIN, 1, T_INT, "x"}, {INTIN, 2, T_INT, "y"}, {INTIN, 3, T_INT, "code"}, {ADDRIN, 2, T_ADR, "data"}},
																	1, {{INTOUT, 0, T_INT, "whnd"}}, FALSE},
	{162, 0, 1, NO_SUBCODE, NO_SUBCODE, "wdlg_close", 1, {{ADDRIN, 0, T_ADR, "dialog"}}, 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "x"}, {INTOUT, 2, T_INT, "y"}}, FALSE},
	{163, 0, 1, NO_SUBCODE, NO_SUBCODE, "wdlg_delete", 1, {{ADDRIN, 0, T_ADR, "dialog"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{164, 1, 3, 0, NO_SUBCODE, "wdlg_get_tree", 3, {{ADDRIN, 0, T_ADR, "dialog"}, {ADDRIN, 1, T_ADR, "&tree"}, {ADDRIN, 2, T_ADR, "rect"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{164, 1, 1, 1, NO_SUBCODE, "wdlg_get_edit", 1, {{ADDRIN, 0, T_ADR, "dialog"}}, 2, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "cursor"}}, FALSE},
	{164, 1, 1, 2, NO_SUBCODE, "wdlg_get_udata", 1, {{ADDRIN, 0, T_ADR, "dialog"}}, 1, {{ADDROUT, 0, T_ADR, "udata"}}, FALSE},
	{164, 1, 1, 3, NO_SUBCODE, "wdlg_get_handle", 1, {{ADDRIN, 0, T_ADR, "dialog"}}, 1, {{INTOUT, 0, T_INT, "whnd"}}, FALSE},
	{165, 2, 1, 0, NO_SUBCODE, "wdlg_set_edit", 2, {{ADDRIN, 0, T_ADR, "dialog"}, {INTIN, 1, T_INT, "obj"}}, 1, {{INTOUT, 0, T_INT, "obj"}}, FALSE},
	{165, 1, 2, 1, NO_SUBCODE, "wdlg_set_tree", 2, {{ADDRIN, 0, T_ADR, "dialog"}, {ADDRIN, 1, T_ADR, "new_tree"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{165, 1, 2, 2, NO_SUBCODE, "wdlg_set_size", 2, {{ADDRIN, 0, T_ADR, "dialog"}, {ADDRIN, 1, T_GRECT, "newsize"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{165, 2, 4, 3, NO_SUBCODE, "wdlg_set_iconify", 5, {{ADDRIN, 0, T_ADR, "dialog"}, {ADDRIN, 1, T_GRECT, "pos"}, {ADDRIN, 2, T_STR, "title"}, {ADDRIN, 3, T_ADR, "tree"}, {INTIN, 1, T_INT, "obj"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{165, 1, 4, 4, NO_SUBCODE, "wdlg_set_uniconify", 4, {{ADDRIN, 0, T_ADR, "dialog"}, {ADDRIN, 1, T_GRECT, "pos"}, {ADDRIN, 2, T_STR, "title"}, {ADDRIN, 3, T_ADR, "tree"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{166, 0, 2, NO_SUBCODE, NO_SUBCODE, "wdlg_evnt", 2, {{ADDRIN, 0, T_ADR, "dialog"}, {ADDRIN, 1, T_EVNT, 0L}}, 1, {{INTOUT, 0, T_INT, "continue"}}, FALSE},
	{167, 2, 2, NO_SUBCODE, NO_SUBCODE, "wdlg_redraw", 4, {{ADDRIN, 0, T_ADR, "dialog"}, {ADDRIN, 1, T_GRECT, "clip"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "depth"}}, 0, {0}, FALSE},
	{170, 8, 8, NO_SUBCODE, NO_SUBCODE, "lbox_create", 16, {{ADDRIN, 0, T_ADR, "tree"}, {ADDRIN, 1, T_ADR, "slct"}, {ADDRIN, 2, T_ADR, "set"}, {ADDRIN, 3, T_ADR, "items"}, {INTIN, 0, T_INT, "visible_a"}, {INTIN, 1, T_INT, "first_a"},
																		{ADDRIN, 4, T_ADR, "ctrl_objs"}, {ADDRIN, 5, T_ADR, "objs"}, {INTIN, 2, T_INT_HEX, "flags"}, {INTIN, 3, T_INT, "pause_a"}, {ADDRIN, 6, T_ADR, "user_data"}, {ADDRIN, 7, T_ADR, "dialog"},
																		{INTIN, 4, T_INT, "visible_b"}, {INTIN, 5, T_INT, "first_b"}, {INTIN, 6, T_INT, "entries_b"}, {INTIN, 7, T_INT, "pause_b"}},
																		1, {{ADDROUT, 0, T_ADR, "box"}}, FALSE},
	{171, 0, 2, NO_SUBCODE, NO_SUBCODE, "lbox_update", 2, {{ADDRIN, 0, T_ADR, "box"}, {ADDRIN, 1, T_GRECT, "rect"}}, 0, {0}, FALSE},
	{172, 1, 1, NO_SUBCODE, NO_SUBCODE, "lbox_do", 2, {{ADDRIN, 0, T_ADR, "box"}, {INTIN, 0, T_INT, "obj"}}, 1, {{INTOUT, 0, T_INT, "obj"}}, FALSE},
	{173, 0, 1, NO_SUBCODE, NO_SUBCODE, "lbox_delete", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{174, 1, 1, 0, NO_SUBCODE, "lbox_cnt_items", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{INTOUT, 0, T_INT, "items"}}, FALSE},
	{174, 1, 1, 1, NO_SUBCODE, "lbox_get_tree", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{ADDROUT, 0, T_ADR, "tree"}}, FALSE},
	{174, 1, 1, 2, NO_SUBCODE, "lbox_get_visible", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{INTOUT, 0, T_INT, "visible"}}, FALSE},
	{174, 1, 1, 3, NO_SUBCODE, "lbox_get_udata", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{ADDROUT, 0, T_ADR, "udata"}}, FALSE},
	{174, 1, 1, 4, NO_SUBCODE, "lbox_get_afirst", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{INTOUT, 0, T_INT, "afirst"}}, FALSE},
	{174, 1, 1, 5, NO_SUBCODE, "lbox_get_slct_idx", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{INTOUT, 0, T_INT, "slct_idx"}}, FALSE},
	{174, 1, 1, 6, NO_SUBCODE, "lbox_get_items", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{ADDROUT, 0, T_ADR, "items"}}, FALSE},
	{174, 2, 1, 7, NO_SUBCODE, "lbox_get_item", 2, {{ADDRIN, 0, T_ADR, "box"}, {INTIN, 1, T_INT, "n"}}, 1, {{ADDROUT, 0, T_ADR, "item"}}, FALSE},
	{174, 1, 1, 8, NO_SUBCODE, "lbox_get_slct_item", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{ADDROUT, 0, T_ADR, "slct_item"}}, FALSE},
	{174, 1, 2, 9, NO_SUBCODE, "lbox_get_idx", 2, {{ADDRIN, 0, T_ADR, "items"}, {ADDRIN, 0, T_ADR, "search"}}, 1, {{INTOUT, 0, T_INT, "idx"}}, FALSE},
	{174, 1, 1, 10, NO_SUBCODE, "lbox_get_bvis", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{INTOUT, 0, T_INT, "bvis"}}, FALSE},
	{174, 1, 1, 11, NO_SUBCODE, "lbox_get_bentries", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{INTOUT, 0, T_INT, "bentries"}}, FALSE},
	{174, 1, 1, 12, NO_SUBCODE, "lbox_get_bfirst", 1, {{ADDRIN, 0, T_ADR, "box"}}, 1, {{INTOUT, 0, T_INT, "bfirst"}}, FALSE},
	{175, 2, 2, 0, NO_SUBCODE, "lbox_set_slider", 3, {{ADDRIN, 0, T_ADR, "box"}, {INTIN, 1, T_INT, "first"}, {ADDRIN, 1, T_GRECT, "rect"}}, 0, {0}, FALSE},
	{175, 1, 2, 1, NO_SUBCODE, "lbox_set_items", 2, {{ADDRIN, 0, T_ADR, "box"}, {ADDRIN, 1, T_ADR, "items"}}, 0, {0}, FALSE},
	{175, 1, 1, 2, NO_SUBCODE, "lbox_free_items", 1, {{ADDRIN, 0, T_ADR, "box"}}, 0, {0}, FALSE},
	{175, 1, 1, 3, NO_SUBCODE, "lbox_free_list", 1, {{ADDRIN, 0, T_ADR, "box"}}, 0, {0}, FALSE},
	{175, 2, 3, 4, NO_SUBCODE, "lbox_scroll_to", 4, {{ADDRIN, 0, T_ADR, "box"}, {INTIN, 1, T_INT, "first"}, {ADDRIN, 1, T_GRECT, "box_rect"}, {ADDRIN, 2, T_GRECT, "slider_rect"}}, 0, {0}, FALSE},
	{175, 2, 2, 5, NO_SUBCODE, "lbox_set_bsldr", 3, {{ADDRIN, 0, T_ADR, "box"}, {INTIN, 1, T_INT, "first"}, {ADDRIN, 1, T_GRECT, "rect"}}, 0, {0}, FALSE},
	{175, 2, 1, 6, NO_SUBCODE, "lbox_set_bentries", 2, {{ADDRIN, 0, T_ADR, "box"}, {INTIN, 1, T_INT, "entries"}}, 0, {0}, FALSE},
	{175, 2, 3, 7, NO_SUBCODE, "lbox_bscroll_to", 4, {{ADDRIN, 0, T_ADR, "box"}, {INTIN, 1, T_INT, "first"}, {ADDRIN, 1, T_GRECT, "box_rect"}, {ADDRIN, 2, T_GRECT, "slider_rect"}}, 0, {0}, FALSE},
	{180, 4, 4, NO_SUBCODE, NO_SUBCODE, "fnts_create", 6, {{INTIN, 0, T_INT, "vdi_hnd"}, {INTIN, 1, T_INT, "nr_fonts"}, {INTIN, 2, T_INT_HEX, "font_flags"}, {INTIN, 3, T_INT_HEX, "dialog_flags"}, {ADDRIN, 0, T_STR, "sample"},
																		{ADDRIN, 1, T_STR, "opt_button"}}, 1, {{ADDROUT, 0, T_ADR, "fntdial"}}, FALSE},
	{181, 1, 1, NO_SUBCODE, NO_SUBCODE, "fnts_delete", 2, {{ADDRIN, 0, T_ADR, "fntdial"}, {INTIN, 0, T_INT, "vdi_hnd"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{182, 9, 1, NO_SUBCODE, NO_SUBCODE, "fnts_open", 7, {{ADDRIN, 0, T_ADR, "fntdial"}, {INTIN, 0, T_INT_HEX, "button_flags"}, {INTIN, 1, T_INT, "x"}, {INTIN, 2, T_INT, "y"}, {INTIN, 3, T_LONG, "id"}, {INTIN, 5, T_FIX31, "pt"},
																		{INTIN, 7, T_LONG, "ratio"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{183, 0, 1, NO_SUBCODE, NO_SUBCODE, "fnts_close", 1, {{ADDRIN, 0, T_ADR, "fntdial"}}, 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "x"}, {INTOUT, 2, T_INT, "y"}}, FALSE},
	{184, 3, 1, 0, NO_SUBCODE, "fnts_get_no_styles", 2, {{ADDRIN, 0, T_ADR, "fntdial"}, {INTIN, 1, T_LONG, "id"}}, 1, {{INTOUT, 0, T_INT, "no_styles"}}, FALSE},
	{184, 4, 1, 1, NO_SUBCODE, "fnts_get_style", 3, {{ADDRIN, 0, T_ADR, "fntdial"}, {INTIN, 1, T_LONG, "id"}, {INTIN, 3, T_INT, "idx"}}, 1, {{INTOUT, 0, T_LONG, "style"}}, FALSE},
	{184, 3, 4, 2, NO_SUBCODE, "fnts_get_name", 5, {{ADDRIN, 0, T_ADR, "fntdial"}, {INTIN, 1, T_LONG, "id"}, {ADDRIN, 1, T_ADR, "full_name"}, {ADDRIN, 2, T_ADR, "family_name"}, {ADDRIN, 3, T_ADR, "style_name"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{184, 3, 1, 3, NO_SUBCODE, "fnts_get_info", 2, {{ADDRIN, 0, T_ADR, "fntdial"}, {INTIN, 1, T_LONG, "id"}}, 3, {{INTOUT, 0, T_INT, "idx"}, {INTOUT, 1, T_INT, "mono"}, {INTOUT, 2, T_INT, "outline"}}, FALSE},
	{185, 1, 2, 0, NO_SUBCODE, "fnts_add", 2, {{ADDRIN, 0, T_ADR, "fntdial"}, {ADDRIN, 1, T_ADR, "user_fonts"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{185, 1, 1, 1, NO_SUBCODE, "fnts_remove", 1, {{ADDRIN, 0, T_ADR, "fntdial"}}, 0, {0}, FALSE},
	{185, 8, 1, 2, NO_SUBCODE, "fnts_update", 5, {{ADDRIN, 0, T_ADR, "fntdial"}, {INTIN, 1, T_INT_HEX, "button_flags"}, {INTIN, 2, T_LONG, "id"}, {INTIN, 4, T_FIX31, "pt"}, {INTIN, 6, T_LONG, "ratio"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{186, 0, 2, NO_SUBCODE, NO_SUBCODE, "fnts_evnt", 2, {{ADDRIN, 0, T_ADR, "fntdial"}, {ADDRIN, 1, T_EVNT, 0L}}, 6, {{INTOUT, 0, T_INT, "continue"}, {INTOUT, 1, T_INT, "button"}, {INTOUT, 2, T_INT_HEX, "check_boxes"}, {INTOUT, 3, T_LONG, "id"},
																		{INTOUT, 5, T_FIX31, "pt"}, {INTOUT, 7, T_LONG, "ratio"}}, FALSE},
	{187, 7, 1, NO_SUBCODE, NO_SUBCODE, "fnts_do", 5, {{ADDRIN, 0, T_ADR, "fntdial"}, {INTIN, 0, T_INT_HEX, "button_flags"}, {INTIN, 1, T_LONG, "id"}, {INTIN, 3, T_FIX31, "pt"}, {INTIN, 5, T_LONG, "ratio"}},
																	5, {{INTOUT, 0, T_INT, "button"}, {INTOUT, 1, T_INT_HEX, "check_boxes"}, {INTOUT, 2, T_LONG, "id"}, {INTOUT, 4, T_FIX31, "pt"}, {INTOUT, 6, T_LONG, "ratio"}}, FALSE},
	{190, 6, 6, NO_SUBCODE, NO_SUBCODE, "fslx_open", 12, {{ADDRIN, 0, T_STR, "title"}, {INTIN, 0, T_INT, "x"}, {INTIN, 1, T_INT, "y"}, {ADDRIN, 1, T_STR, "path"}, {INTIN, 2, T_INT, "pathlen"}, {ADDRIN, 2, T_STR, "fname"}, {INTIN, 3, T_INT, "fnamelen"},
																		{ADDRIN, 3, T_STR00, "patterns"}, {ADDRIN, 4, T_ADR, "filter"}, {ADDRIN, 5, T_STR00, "paths"}}, 2, {{ADDROUT, 0, T_ADR, "fsldial"}, {INTOUT, 0, T_INT, "hnd"}}, FALSE},
	{191, 0, 1, NO_SUBCODE, NO_SUBCODE, "fslx_close", 1, {{ADDRIN, 0, T_ADR, "fsldial"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{192, 0, 2, NO_SUBCODE, NO_SUBCODE, "fslx_getnxtfile", 2, {{ADDRIN, 0, T_ADR, "fsldial"}, {ADDRIN, 1, T_ADR, "name"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{193, 0, 4, NO_SUBCODE, NO_SUBCODE, "fslx_evnt", 4, {{ADDRIN, 0, T_ADR, "fsldial"}, {ADDRIN, 1, T_EVNT, 0L}, {ADDRIN, 2, T_ADR, "path"}, {ADDRIN, 3, T_ADR, "file"}},
																	5, {{INTOUT, 0, T_INT, "continue"}, {INTOUT, 1, T_INT, "button"}, {INTOUT, 2, T_INT, "nfiles"}, {INTOUT, 3, T_INT, "sort"}, {ADDROUT, 0, T_STR, "pattern"}}, FALSE},
	{194, 4, 6, NO_SUBCODE, NO_SUBCODE, "fslx_do", 10, {{ADDRIN, 0, T_STR, "title"}, {ADDRIN, 1, T_STR, "path"}, {INTIN, 0, T_INT, "pathlen"}, {ADDRIN, 2, T_STR, "fname"}, {INTIN, 1, T_INT, "fnamelen"}, {ADDRIN, 3, T_STR00, "patterns"},
																		{ADDRIN, 4, T_ADR, "filter"}, {ADDRIN, 5, T_STR00, "paths"}, {INTIN, 2, T_INT, "sort"}, {INTIN, 3, T_INT_HEX, "flags"}},
																	5, {{ADDROUT, 0, T_ADR, "fsldial"}, {INTOUT, 1, T_INT, "button"}, {INTOUT, 2, T_INT, "nfiles"}, {INTOUT, 3, T_INT, "sort"}, {ADDROUT, 1, T_STR, "pattern"}}, FALSE},
	{195, 2, 0, 0, NO_SUBCODE, "fslx_set_flags", 1, {{INTIN, 1, T_INT_HEX, "flags"}}, 2, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT_HEX, "oldflags"}}, FALSE},
	{200, 1, 0, NO_SUBCODE, NO_SUBCODE, "pdlg_create", 1, {{INTIN, 0, T_INT_HEX, "flags"}}, 1, {{ADDROUT, 0, T_ADR, "pdial"}}, FALSE},
	{201, 0, 1, NO_SUBCODE, NO_SUBCODE, "pdlg_delete", 1, {{ADDRIN, 0, T_ADR, "pdial"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{202, 3, 3, NO_SUBCODE, NO_SUBCODE, "pdlg_open", 6, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 1, T_ADR, "settings"}, {ADDRIN, 2, T_STR, "docname"}, {INTIN, 0, T_INT_HEX, "flags"}, {INTIN, 1, T_INT, "x"}, {INTIN, 2, T_INT, "y"}},
																	1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{203, 0, 1, NO_SUBCODE, NO_SUBCODE, "pdlg_close", 1, {{ADDRIN, 0, T_ADR, "pdial"}}, 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "x"}, {INTOUT, 2, T_INT, "y"}}, FALSE},
	{204, 1, 0, NO_SUBCODE, NO_SUBCODE, "pdlg_get_setsize", 0, {0}, 1, {{INTOUT, 0, T_LONG, "size"}}, FALSE},
	{205, 1, 2, 0, NO_SUBCODE, "pdlg_add_printers", 2, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 1, T_ADR, "drv_info"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{205, 1, 1, 1, NO_SUBCODE, "pdlg_remove_printers", 1, {{ADDRIN, 0, T_ADR, "pdial"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{205, 1, 3, 2, NO_SUBCODE, "pdlg_update", 2, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 2, T_STR, "docname"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{205, 1, 2, 3, NO_SUBCODE, "pdlg_add_sub_dialogs", 2, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 1, T_ADR, "sub_dialogs"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{205, 1, 1, 4, NO_SUBCODE, "pdlg_remove_sub_dialogs", 1, {{ADDRIN, 0, T_ADR, "pdial"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{205, 1, 1, 5, NO_SUBCODE, "pdlg_new_settings", 1, {{ADDRIN, 0, T_ADR, "pdial"}}, 1, {{ADDROUT, 0, T_ADR, "settings"}}, FALSE},
	{205, 1, 1, 6, NO_SUBCODE, "pdlg_free_settings", 1, {{ADDRIN, 0, T_ADR, "settings"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{205, 1, 2, 7, NO_SUBCODE, "pdlg_dflt_settings", 2, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 1, T_ADR, "settings"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{205, 1, 2, 8, NO_SUBCODE, "pdlg_validate_settings", 2, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 1, T_ADR, "settings"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{205, 1, 2, 9, NO_SUBCODE, "pdlg_use_settings", 2, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 1, T_ADR, "settings"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{206, 0, 3, NO_SUBCODE, NO_SUBCODE, "pdlg_evnt", 3, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 1, T_ADR, "settings"}, {ADDRIN, 2, T_EVNT, 0L}}, 1, {{INTOUT, 0, T_INT, "continue"}}, FALSE},
	{207, 1, 3, NO_SUBCODE, NO_SUBCODE, "pdlg_do", 4, {{ADDRIN, 0, T_ADR, "pdial"}, {ADDRIN, 1, T_ADR, "settings"}, {ADDRIN, 2, T_STR, "docname"}, {INTIN, 0, T_INT_HEX, "flags"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{210, 0, 0, NO_SUBCODE, NO_SUBCODE, "edit_create", 0, {0}, 1, {{ADDROUT, 0, T_ADR, "xi"}}, FALSE},
	{211, 1, 1, NO_SUBCODE, NO_SUBCODE, "edit_open", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{212, 1, 1, NO_SUBCODE, NO_SUBCODE, "edit_close", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 0, {0}, FALSE},
	{213, 0, 1, NO_SUBCODE, NO_SUBCODE, "edit_delete", 1, {{ADDRIN, 0, T_ADR, "xi"}}, 0, {0}, FALSE},
	{214, 3, 1, NO_SUBCODE, NO_SUBCODE, "edit_cursor", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "whnd"}, {INTIN, 2, T_INT, "show"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{215, 2, 2, NO_SUBCODE, NO_SUBCODE, "edit_evnt", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 1, T_INT, "whnd"}, {ADDRIN, 1, T_EVNT, 0L}}, 2, {{INTOUT, 0, T_INT, "continue"}, {INTOUT, 1, T_LONG, "errcode"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 0, "edit_get_buf", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 4, {{INTOUT, 0, T_INT, "ok"}, {ADDROUT, 0, T_ADR, "buf"}, {INTOUT, 1, T_LONG, "buflen"}, {INTOUT, 3, T_LONG, "txtlen"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 1, "edit_get_format", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "tabwidth"}, {INTOUT, 2, T_INT, "autowrap"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 2, "edit_get_colour", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "tcolour"}, {INTOUT, 2, T_INT, "bcolour"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 3, "edit_get_font", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 5, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "id"}, {INTOUT, 2, T_INT, "h"}, {INTOUT, 3, T_INT, "mono"}, {INTOUT, 4, T_INT, "pix"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 4, "edit_get_cursor", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 2, {{INTOUT, 0, T_INT, "ok"}, {ADDROUT, 0, T_ADR, "cursorpos"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 5, "edit_get_pos", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 6, {{INTOUT, 1, T_INT, "xscroll"}, {INTOUT, 2, T_LONG, "yscroll"}, {ADDROUT, 0, T_ADR, "cyscroll"}, {INTOUT, 4, T_INT, "cx"},
																	{INTOUT, 5, T_INT, "cy"}, {ADDROUT, 1, T_INT, "cursorpos"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 7, "edit_get_dirty", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 1, {{INTOUT, 0, T_INT, "dirty"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 8, "edit_get_sel", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 2, {{ADDROUT, 0, T_ADR, "bsel"}, {ADDROUT, 1, T_ADR, "esel"}}, FALSE},
	{216, 2, 1, NO_SUBCODE, 9, "edit_get_scrollinfo", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 7, {{INTOUT, 1, T_LONG, "nlines"}, {INTOUT, 3, T_LONG, "yscroll"}, {INTOUT, 5, T_INT, "yvis"}, {INTOUT, 6, T_INT, "yval"},
																	{INTOUT, 7, T_INT, "ncols"}, {INTOUT, 8, T_INT, "xscroll"}, {INTOUT, 9, T_INT, "xvis"}}, FALSE},
	{217, 4, 2, NO_SUBCODE, 0, "edit_set_buf", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {ADDRIN, 1, T_ADR, "buf"}, {INTIN, 2, T_LONG, "buflen"}}, 0, {0}, FALSE},
	{217, 4, 1, NO_SUBCODE, 1, "edit_set_format", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "tabwidth"}, {INTIN, 3, T_INT, "autowrap"}}, 0, {0}, FALSE},
	{217, 4, 1, NO_SUBCODE, 2, "edit_set_colour", 4, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "tcolour"}, {INTIN, 3, T_INT, "bcolour"}}, 0, {0}, FALSE},
	{217, 5, 1, NO_SUBCODE, 3, "edit_set_font", 5, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "id"}, {INTIN, 3, T_INT, "h"}, {INTIN, 4, T_INT, "mono"}}, 0, {0}, FALSE},
	{217, 6, 1, NO_SUBCODE, 3, "edit_set_font", 6, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "id"}, {INTIN, 3, T_INT, "h"}, {INTIN, 4, T_INT, "mono"}, {INTIN, 5, T_INT, "pix"}}, 0, {0}, FALSE},
	{217, 2, 2, NO_SUBCODE, 4, "edit_set_cursor", 3, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {ADDRIN, 1, T_ADR, "cursorpos"}}, 0, {0}, FALSE},
	{217, 7, 3, NO_SUBCODE, 5, "edit_set_pos", 8, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "xscroll"}, {INTIN, 3, T_LONG, "yscroll"}, {ADDRIN, 1, T_ADR, "cyscroll"}, {ADDRIN, 2, T_ADR, "cursorpos"},
																{INTIN, 5, T_INT, "cx"}, {INTIN, 6, T_INT, "cy"}}, 0, {0}, FALSE},
	{217, 2, 1, NO_SUBCODE, 6, "edit_resized", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}}, 3, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "oldrh"}, {INTOUT, 2, T_INT, "newrh"}}, FALSE},
	{217, 2, 2, NO_SUBCODE, 7, "edit_set_dirty", 2, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "dirty"}}, 0, {0}, FALSE},
	{217, 6, 1, NO_SUBCODE, 9, "edit_scroll", 5, {{ADDRIN, 0, T_ADR, "tree"}, {INTIN, 0, T_INT, "obj"}, {INTIN, 2, T_INT, "whnd"}, {INTIN, 3, T_LONG, "yscroll"}, {INTIN, 5, T_INT, "xscroll"}}, 1, {{INTOUT, 0, T_INT, "ok"}}, FALSE},
	{0, 0, 0, 0, 0, 0L, 0, {0}, 0, {0}, FALSE}
};

GEM_MSGS gem_msgs;

GEM_MSG gem_msg[] = {
	{MN_SELECTED, "MN_SELECTED", 2, {{3, T_INT, "title"}, {4, T_INT, "index"}}, FALSE},
	{WM_REDRAW, "WM_REDRAW", 5, {{3, T_INT, "whnd"}, {4, T_INT, "x"}, {5, T_INT, "y"}, {6, T_INT, "w"}, {7, T_INT, "h"}}, FALSE},
	{WM_TOPPED, "WM_TOPPED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_CLOSED, "WM_CLOSED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_FULLED, "WM_FULLED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_ARROWED, "WM_ARROWED", 2, {{3, T_INT, "whnd"}, {4, T_ARROWED, "action"}}, FALSE},
	{WM_HSLID, "WM_HSLID", 2, {{3, T_INT, "whnd"}, {4, T_INT, "pos"}}, FALSE},
	{WM_VSLID, "WM_VSLID", 2, {{3, T_INT, "whnd"}, {4, T_INT, "pos"}}, FALSE},
	{WM_SIZED, "WM_SIZED", 5, {{3, T_INT, "whnd"}, {4, T_INT, "x"}, {5, T_INT, "y"}, {6, T_INT, "w"}, {7, T_INT, "h"}}, FALSE},
	{WM_MOVED, "WM_MOVED", 5, {{3, T_INT, "whnd"}, {4, T_INT, "x"}, {5, T_INT, "y"}, {6, T_INT, "w"}, {7, T_INT, "h"}}, FALSE},
	{WM_NEWTOP, "WM_NEWTOP", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_UNTOPPED, "WM_UNTOPPED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_ONTOP, "WM_ONTOP", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_BOTTOMED, "WM_BOTTOMED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_ICONIFY, "WM_ICONIFY", 5, {{3, T_INT, "whnd"}, {4, T_INT, "x"}, {5, T_INT, "y"}, {6, T_INT, "w"}, {7, T_INT, "h"}}, FALSE},
	{WM_UNICONIFY, "WM_UNICONIFY", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_ALLICONIFY, "WM_ALLICONIFY", 5, {{3, T_INT, "whnd"}, {4, T_INT, "x"}, {5, T_INT, "y"}, {6, T_INT, "w"}, {7, T_INT, "h"}}, FALSE},
	{37, "WM_TOOLBAR", 4, {{3, T_INT, "whnd"}, {4, T_INT, "obj"}, {5, T_INT, "clicks"}, {6, T_SHIFT, "shift"}}, FALSE},
	{AC_OPEN, "AC_OPEN", 1, {{4, T_INT, "id"}}, FALSE},
	{AC_CLOSE, "AC_CLOSE", 1, {{4, T_INT, "id"}}, FALSE},
/* ???
	{CT_UPDATE, "CT_UPDATE", 0, {0}, FALSE},
	{CT_MOVE, "CT_MOVE", 0, {0}, FALSE},
*/
	{CT_NEWTOP, "CT_NEWTOP", 0, {0}, FALSE},				/* ??? */
	{CT_KEY, "CT_KEY", 1, {{3, T_KEY, "key"}}, FALSE},
	{AP_TERM, "AP_TERM", 1, {{5, T_INT, "cause"}}, FALSE},
	{AP_TFAIL, "AP_TFAIL", 1, {{3, T_INT, "cause"}}, FALSE},
	{AP_RESCHG, "AP_RESCHG", 0, {0}, FALSE},
	{SHUT_COMPLETED, "SHUT_COMPLETED", 0, {0}, FALSE},
	{RESCH_COMPLETED, "RESCH_COMPLETED", 1, {{3, T_INT, "ok"}}, FALSE},
	{AP_DRAGDROP, "AP_DRAGDROP", 5, {{3, T_INT, "whnd"}, {4, T_INT, "x"}, {5, T_INT, "y"}, {6, T_SHIFT, "shift"}, {7, T_XACC, "ext"}}, FALSE},
	{SH_WDRAW, "SH_WDRAW", 1, {{3, T_DRV0, "drv"}}, FALSE},
	{SC_CHANGED, "SC_CHANGED", 2, {{3, T_INT_HEX, "format"}, {4, T_EXT, "ext"}}, FALSE},
	{PRN_CHANGED, "PRN_CHANGED", 2, {{3, T_INT, "dev"}, {4, T_INT, "val"}}, FALSE},
	{FNT_CHANGED, "FNT_CHANGED", 2, {{3, T_INT, "removed"}, {4, T_INT, "added"}}, FALSE},
	{THR_EXIT, "THR_EXIT", 2, {{3, T_INT, "AES-ID"}, {4, T_LONG, "errcode"}}, FALSE},		/* MagiC Thread */
	{PA_EXIT, "PA_EXIT", 0, {0}, FALSE},		/* ????????? */
	{CH_EXIT, "CH_EXIT", 2, {{3, T_AESID, "apid"}, {4, T_INT, "ret"}}, FALSE},
	{WM_M_BDROPPED, "WM_M_BDROPPED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{SM_M_SPECIAL, "SM_M_SPECIAL", 3, {{4, T_EXT, "magx"}, {6, T_INT, "todo"}, {7, T_AESID, "apid"}}, FALSE},
	{SM_M_RES2, "SM_M_RES2", 0, {0}, FALSE},		/* ??? */
	{SM_M_RES3, "SM_M_RES3", 0, {0}, FALSE},		/* ??? */
	{SM_M_RES4, "SM_M_RES4", 0, {0}, FALSE},		/* ??? */
	{SM_M_RES5, "SM_M_RES5", 0, {0}, FALSE},		/* ??? */
	{SM_M_RES6, "SM_M_RES6", 0, {0}, FALSE},		/* ??? */
	{SM_M_RES7, "SM_M_RES7", 0, {0}, FALSE},		/* ??? */
	{SM_M_RES8, "SM_M_RES8", 0, {0}, FALSE},		/* ??? */
	{SM_M_RES9, "SM_M_RES9", 0, {0}, FALSE},		/* ??? */
	{WM_SHADED, "WM_SHADED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{WM_UNSHADED, "WM_UNSHADED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{AV_PROTOKOLL, "AV_PROTOKOLL", 2, {{3, T_AVPROTOKOLL, "bits"}, {6, T_STR, "name"}}, FALSE},
	{VA_PROTOSTATUS, "VA_PROTOSTATUS", 2, {{3, T_VAPROTOSTATUS, "bits"}, {6, T_STR, "name"}}, FALSE},
	{AV_GETSTATUS, "AV_GETSTATUS", 0, {0}, FALSE},
	{AV_STATUS, "AV_STATUS", 1, {{3, T_STR, "status"}}, FALSE},
	{VA_SETSTATUS, "VA_SETSTATUS", 1, {{3, T_STR, "status"}}, FALSE},
	{AV_SENDCLICK, "AV_SENDCLICK", 5, {{3, T_INT, "x"}, {4, T_INT, "y"}, {5, T_INT, "but"}, {6, T_SHIFT, "shift"}, {7, T_INT, "clicks"}}, FALSE},
	{AV_SENDKEY, "AV_SENDKEY", 3, {{3, T_SHIFT, "shift"}, {4, T_KEY, "key"}, {5, T_INT, "msg5"}}, FALSE},
	{VA_START, "VA_START", 1, {{3, T_STR, 0L}}, FALSE},
	{AV_STARTED, "AV_STARTED", 1, {{3, T_STR, 0L}}, FALSE},
	{AV_ASKFILEFONT, "AV_ASKFILEFONT", 0, {0}, FALSE},
	{VA_FILEFONT, "VA_FILEFONT", 2, {{3, T_INT, "id"}, {4, T_INT, "pt"}}, FALSE},
	{AV_ASKCONFONT, "AV_ASKCONFONT", 0, {0}, FALSE},
	{VA_CONFONT, "VA_CONFONT", 2, {{3, T_INT, "id"}, {4, T_INT, "pt"}}, FALSE},
	{AV_ASKOBJECT, "AV_ASKOBJECT", 0, {0}, FALSE},
	{VA_OBJECT, "VA_OBJECT", 1, {{3, T_STR, "objs"}}, FALSE},
	{AV_OPENCONSOLE, "AV_OPENCONSOLE", 0, {0}, FALSE},
	{VA_CONSOLEOPEN, "VA_CONSOLEOPEN", 1, {{3, T_INT, "ok"}}, FALSE},
	{AV_OPENWIND, "AV_OPENWIND", 2, {{3, T_STR, "path"}, {5, T_STR, "match"}}, FALSE},
	{VA_WINDOPEN, "VA_WINDOPEN", 1, {{3, T_INT, "ok"}}, FALSE},
	{AV_STARTPROG, "AV_STARTPROG", 3, {{3, T_STR, "file"}, {5, T_STR, "cmd"}, {7, T_INT, "id"}}, FALSE},
	{VA_PROGSTART, "VA_PROGSTART", 3, {{3, T_INT, "ok"}, {4, T_INT, "ret"}, {7, T_INT, "id"}}, FALSE},
	{AV_ACCWINDOPEN, "AV_ACCWINDOPEN", 1, {{3, T_INT, "whnd"}}, FALSE},
	{VA_DRAGACCWIND, "VA_DRAGACCWIND", 4, {{3, T_INT, "whnd"}, {4, T_INT, "x"}, {5, T_INT, "y"}, {6, T_STR, "objs"}}, FALSE},
	{AV_ACCWINDCLOSED, "AV_ACCWINDCLOSED", 1, {{3, T_INT, "whnd"}}, FALSE},
	{AV_COPY_DRAGGED, "AV_COPY_DRAGGED", 2, {{3, T_SHIFT, "shift"}, {4, T_STR, "path"}}, FALSE},
	{VA_COPY_COMPLETE, "VA_COPY_COMPLETE", 1, {{3, T_INT, "ok"}}, FALSE},
	{AV_PATH_UPDATE, "AV_PATH_UPDATE", 1, {{3, T_STR, "path"}}, FALSE},
	{AV_WHAT_IZIT, "AV_WHAT_IZIT", 2, {{3, T_INT, "x"}, {4, T_INT, "y"}}, FALSE},
	{VA_THAT_IZIT, "VA_THAT_IZIT", 3, {{3, T_AESID, "apid"}, {4, T_THAT_IZIT, "what"}, {5, T_STR, "obj"}}, FALSE},
	{AV_DRAG_ON_WINDOW, "AV_DRAG_ON_WINDOW", 4, {{3, T_INT, "x"}, {4, T_INT, "y"}, {5, T_SHIFT, "shift"}, {6, T_STR, "objs"}}, FALSE},
	{VA_DRAG_COMPLETE, "VA_DRAG_COMPLETE", 1, {{3, T_INT, "ok"}}, FALSE},
	{AV_EXIT, "AV_EXIT", 1, {{3, T_AESID, "apid"}}, FALSE},
	{VA_FONTCHANGED, "VA_FONTCHANGED", 4, {{3, T_INT, "id"}, {4, T_INT, "pt"}, {5, T_INT, "cons_id"}, {6, T_INT, "cons_pt"}}, FALSE},
	{AV_XWIND, "AV_XWIND", 3, {{3, T_STR, "path"}, {5, T_STR, "match"}, {7, T_INT_HEX, "bits"}}, FALSE},
	{VA_XOPEN, "VA_XOPEN", 1, {{3, T_INT, "ok"}}, FALSE},
	{AV_VIEW, "AV_VIEW", 1, {{3, T_STR, "file"}}, FALSE},
	{VA_VIEWED, "VA_VIEWED", 1, {{3, T_INT, "ok"}}, FALSE},
	{AV_FILEINFO, "AV_FILEINFO", 1, {{3, T_STR, "objs"}}, FALSE},
	{VA_FILECHANGED, "VA_FILECHANGED", 1, {{3, T_STR, "objs"}}, FALSE},
	{AV_COPYFILE, "AV_COPYFILE", 3, {{3, T_STR, "objs"}, {5, T_STR, "path"}, {7, T_INT_HEX, "bits"}}, FALSE},
	{VA_FILECOPIED, "VA_FILECOPIED", 1, {{3, T_INT, "ok"}}, FALSE},
	{AV_DELFILE, "AV_DELFILE", 1, {{3, T_STR, "objs"}}, FALSE},
	{VA_FILEDELETED, "VA_FILEDELETED", 1, {{3, T_INT, "ok"}}, FALSE},
	{GS_REQUEST, "GS_REQUEST", 2, {{7, T_INT, "ID"}, {3, T_GS_INFO, 0L}}, FALSE},
	{GS_REPLY, "GS_REPLY", 3, {{7, T_INT, "ID"}, {6, T_INT, "not_yet"}, {3, T_GS_INFO, 0L}}, FALSE},
	{GS_COMMAND, "GS_COMMAND", 2, {{7, T_INT, "ID"}, {3, T_STR00, "cmd"}}, FALSE},
	{GS_ACK, "GS_ACK", 1, {{0, T_GS_ACK, 0L}}, FALSE},
	{GS_QUIT, "GS_QUIT", 1, {{7, T_INT, "ID"}}, FALSE},
	{GS_OPENMACRO, "GS_OPENMACRO", 1, {{3, T_STR, "file"}}, FALSE},
	{GS_MACRO, "GS_MACRO", 3, {{5, T_INT, "ID"}, {6, T_INT, "error"}, {3, T_STR, "file"}}, FALSE},
	{GS_WRITE, "GS_WRITE", 2, {{5, T_INT, "ID"}, {3, T_STR00, "cmd"}}, FALSE},
	{GS_CLOSEMACRO, "GS_CLOSEMACRO", 1, {{5, T_INT, "ID"}}, FALSE},
	{OLE_INIT, "OLE_INIT", 3, {{3, T_OLE_BITS, "bits"}, {4, T_INT, "level"}, {7, T_XACC, "XAcc"}}, FALSE},
	{OLE_EXIT, "OLE_EXIT", 0, {0}, FALSE},
	{OLE_NEW, "OLE_NEW", 3, {{3, T_OLE_BITS, "bits"}, {4, T_INT, "level"}, {7, T_INT_HEX, "version"}}, FALSE},
	{OLGA_INIT, "OLGA_INIT", 3, {{3, T_OLE_BITS, "bits"}, {4, T_INT, "level"}, {7, T_INT, "ok"}}, FALSE},
	{OLGA_UPDATE, "OLGA_UPDATE", 2, {{3, T_STR, "file"}, {5, T_INT, "idx"}}, FALSE},
	{OLGA_ACK, "OLGA_ACK", 1, {{0, T_OLGA_ACK, 0L}}, FALSE},
	{OLGA_RENAME, "OLGA_RENAME", 2, {{3, T_STR, "old"}, {5, T_STR, "new"}}, FALSE},
	{OLGA_OPENDOC, "OLGA_OPENDOC", 1, {{5, T_INT, "grp_id"}}, FALSE},
	{OLGA_CLOSEDOC, "OLGA_CLOSEDOC", 1, {{5, T_INT, "grp_id"}}, FALSE},
	{OLGA_LINK, "OLGA_LINK", 2, {{3, T_STR, "file"}, {5, T_INT, "grp_id"}}, FALSE},
	{OLGA_UNLINK, "OLGA_UNLINK", 2, {{3, T_STR, "file"}, {5, T_INT, "grp_id"}}, FALSE},
	{OLGA_UPDATED, "OLGA_UPDATED", 4, {{3, T_STR, "file"}, {5, T_INT, "idx"}, {6, T_AESID, "apid"}, {7, T_INT, "grp_id"}}, FALSE},
	{OLGA_RENAMELINK, "OLGA_RENAMELINK", 3, {{3, T_STR, "old"}, {5, T_STR, "new"}, {7, T_INT, "grp_id"}}, FALSE},
	{OLGA_LINKRENAMED, "OLGA_LINKRENAMED", 3, {{3, T_STR, "old"}, {5, T_STR, "new"}, {7, T_INT, "grp_id"}}, FALSE},
	{OLGA_GETOBJECTS, "OLGA_GETOBJECTS", 1, {{3, T_INT, "next"}}, FALSE},
	{OLGA_OBJECTS, "OLGA_OBJECTS", 3, {{3, T_INT, "rest"}, {4, T_EXT, "ext"}, {6, T_STR, "txt"}}, FALSE},
	{OLGA_BREAKLINK, "OLGA_BREAKLINK", 1, {{3, T_STR, "file"}}, FALSE},
	{OLGA_LINKBROKEN, "OLGA_LINKBROKEN", 2, {{3, T_STR, "file"}, {5, T_INT, "grp_id"}}, FALSE},
	{OLGA_START, "OLGA_START", 1, {{0, T_OLGA_START, 0L}}, FALSE},
	{OLGA_GETINFO, "OLGA_GETINFO", 1, {{5, T_INT, "idx"}}, FALSE},
	{OLGA_INFO, "OLGA_INFO", 2, {{3, T_STR, "file"}, {5, T_INT, "idx"}}, FALSE},
	{OLGA_IDLE, "OLGA_IDLE", 1, {{3, T_INT, "idle"}}, FALSE},
	{OLGA_ACTIVATE, "OLGA_ACTIVATE", 1, {{0, T_OLGA_ACTIVATE, 0L}}, FALSE},
	{OLGA_EMBED, "OLGA_EMBED", 3, {{3, T_INT, "flag"}, {4, T_ADR, "buf"}, {6, T_EXT0ID, 0L}}, FALSE},
	{OLGA_EMBEDDED, "OLGA_EMBEDDED", 3, {{3, T_INT, "flag"}, {4, T_ADR, "buf"}, {6, T_INT, "w"}, {7, T_INT, "h"}}, FALSE},
	{OLGA_UNEMBED, "OLGA_UNEMBED", 1, {{4, T_ADR, "buf"}}, FALSE},
	{OLGA_GETSETTINGS, "OLGA_GETSETTINGS", 0, {0}, FALSE},
	{OLGA_SETTINGS, "OLGA_SETTINGS", 1, {{3, T_INT, "ok"}}, FALSE},
	{OLGA_REQUESTNOTIFICATION, "OLGA_REQUESTNOTIFICATION", 1, {{3, T_EXT, "ext"}}, FALSE},
	{OLGA_RELEASENOTIFICATION, "OLGA_RELEASENOTIFICATION", 1, {{3, T_EXT, "ext"}}, FALSE},
	{OLGA_NOTIFY, "OLGA_NOTIFY", 1, {{3, T_STR, "file"}}, FALSE},
	{OLGA_NOTIFIED, "OLGA_NOTIFIED", 0, {0}, FALSE},
	{OLGA_SERVERTERMINATED, "OLGA_SERVERTERMINATED", 2, {{3, T_AESID, "apid"}, {4, T_EXTXACC, 0L}}, FALSE},
	{OLGA_CLIENTTERMINATED, "OLGA_CLIENTTERMINATED", 3, {{3, T_AESID, "apid"}, {4, T_INT, "clients"}, {7, T_INT, "was_started"}}, FALSE},
	{OLGA_INPLACEUPDATE, "OLGA_INPLACEUPDATE", 1, {{4, T_ADR, "buf"}}, FALSE},
	{OLGA_ID4UPDATE, "OLGA_ID4UPDATE", 0, {0}, FALSE},
	{OLGA_GETEXTENSION, "OLGA_GETEXTENSION", 1, {{3, T_STR, "file"}}, FALSE},
	{OLGA_EXTENSION, "OLGA_EXTENSION", 3, {{3, T_STR, "file"}, {5, T_EXT, "ext"}, {7, T_INT, "error"}}, FALSE},
	{OLGA_GETSERVERPATH, "OLGA_GETSERVERPATH", 1, {{3, T_EXT, "ext"}}, FALSE},
	{OLGA_SERVERPATH, "OLGA_SERVERPATH", 3, {{3, T_EXT, "ext"}, {5, T_STR, "path"}, {7, T_INT_HEX, "bits"}}, FALSE},
	{BUBBLEGEM_REQUEST, "BUBBLEGEM_REQUEST", 0, {0}, FALSE},
	{BUBBLEGEM_SHOW, "BUBBLEGEM_SHOW", 4, {{3, T_INT, "x"}, {4, T_INT, "y"}, {7, T_INT_HEX, "bits"}, {5, T_STR, "txt"}}, FALSE},
	{BUBBLEGEM_ACK, "BUBBLEGEM_ACK", 0, {0}, FALSE},
	{BUBBLEGEM_ASKFONT, "BUBBLEGEM_ASKFONT", 0, {0}, FALSE},
	{BUBBLEGEM_FONT, "BUBBLEGEM_FONT", 2, {{3, T_INT, "id"}, {4, T_INT, "pt"}}, FALSE},
	{0x1150, "JINNEE_MSG", 1, {{3, T_INT, "subcode"}}, FALSE},
	{0x2f10, "KOBOLD_JOB", 1, {{3, T_ADR, "buf"}}, FALSE},
	{0x2f11, "KOBOLD_JOB_NO_WINDOW", 1, {{3, T_ADR, "buf"}}, FALSE},
	{0x2f12, "KOBOLD_ANSWER", 2, {{3, T_INT, "status"}, {4, T_INT, "line"}}, FALSE},
	{0x2f13, "KOBOLD_CONFIG", 1, {{3, T_ADR, "buf"}}, FALSE},
	{0x2f14, "KOBOLD_FIRST_SLCT", 1, {{3, T_ADR, "buf"}}, FALSE},
	{0x2f15, "KOBOLD_NEXT_SLCT", 1, {{3, T_ADR, "buf"}}, FALSE},
	{0x2f16, "KOBOLD_CLOSE", 0, {0L}, FALSE},
	{0x2f17, "KOBOLD_FREE_DRIVES", 0, {0L}, FALSE},
	{0x4200, "SE_INIT", 3, {{3, T_INT_HEX, "send"}, {4, T_LONG_HEX, "know"}, {6, T_INT_HEX, "version"}}, FALSE},
	{0x4201, "SE_OK", 4, {{3, T_INT_HEX, "send"}, {4, T_LONG_HEX, "know"}, {6, T_INT_HEX, "version"}, {7, T_AESID, "apid"}}, FALSE},
	{0x4202, "SE_ACK", 1, {{3, T_INT, "ok"}}, FALSE},
	{0x4203, "SE_OPEN", 1, {{3, T_STR, "file"}}, FALSE},
	{0x4204, "SE_ERROR", 1, {{4, T_ADR, "buf"}}, FALSE},
	{0x4205, "SE_ERRFILE", 2, {{3, T_STR, "file"}, {5, T_STR, "name"}}, FALSE},
	{0x4206, "SE_PROJECT", 1, {{3, T_STR, "name"}}, FALSE},
	{0x4207, "SE_QUIT", 0, {0L}, FALSE},
	{0x4208, "SE_TERMINATE", 0, {0L}, FALSE},
	{0x4209, "SE_CLOSE", 0, {0L}, FALSE},
	{0x4240, "ES_INIT", 3, {{3, T_INT_HEX, "know"}, {4, T_LONG_HEX, "send"}, {6, T_INT_HEX, "version"}}, FALSE},
	{0x4241, "ES_OK", 4, {{3, T_INT_HEX, "know"}, {4, T_LONG_HEX, "send"}, {6, T_INT_HEX, "version"}, {7, T_AESID, "apid"}}, FALSE},
	{0x4242, "ES_ACK", 1, {{3, T_INT, "ok"}}, FALSE},
	{0x4243, "ES_COMPILE", 1, {{3, T_STR, "file"}}, FALSE},
	{0x4244, "ES_MAKE", 1, {{3, T_STR, "file"}}, FALSE},
	{0x4245, "ES_MAKEALL", 1, {{3, T_STR, "file"}}, FALSE},
	{0x4246, "ES_LINK", 1, {{3, T_STR, "file"}}, FALSE},
	{0x4247, "ES_EXEC", 1, {{3, T_STR, "file"}}, FALSE},
	{0x4248, "ES_MAKEEXEC", 1, {{3, T_STR, "file"}}, FALSE},
	{0x4249, "ES_PROJECT", 1, {{3, T_STR, "file"}}, FALSE},
	{0x424a, "ES_QUIT", 0, {0L}, FALSE},
	{0x7a18, "FONT_CHANGED", 5, {{3, T_INT, "whnd"}, {4, T_INT, "id"}, {5, T_INT, "pt"}, {6, T_INT, "col"}, {7, T_INT_HEX, "effects"}}, FALSE},
	{0x7a19, "FONT_SELECT", 5, {{3, T_INT, "whnd"}, {4, T_INT, "id"}, {5, T_INT, "pt"}, {6, T_INT, "col"}, {7, T_INT_HEX, "effects"}}, FALSE},
	{0x7a1a, "FONT_ACK", 1, {{3, T_INT, "ok"}}, FALSE},
	{0x7a1b, "XFONT_CHANGED", 4, {{3, T_LONG, "fix31"}, {5, T_INT, "rot"}, {6, T_INT, "italic"}, {7, T_INT_HEX, "kern/width"}}, FALSE},
	{0x8000, "CatMsg", 1, {{3, T_INT, "sub-code"}}, FALSE},			/* CAT-Protokoll */
	{0x8001, "ExtCatMsg", 0, {0}, FALSE},									/* CAT-Protokoll */
	{0x8002, "Cat2FiltMsg", 0, {0}, FALSE},								/* CAT-Protokoll */
	{0x8003, "CatProtoMsg", 1, {{3, T_INT, "sub-code"}}, FALSE},	/* CAT-Protokoll */
	{0xcab0, "CAB_CHANGED", 0, {0}, FALSE},													/* CAB-Protokoll */
	{0xcab1, "CAB_EXIT", 0, {0}, FALSE},														/* CAB-Protokoll */
	{0xcab2, "CAB_PATH", 0, {0}, FALSE},														/* CAB-Protokoll */
	{0xcab3, "CAB_VIEW", 2, {{3, T_ADR, "buf"}, {5, T_INT, "Fenster"}}, FALSE},	/* CAB-Protokoll */
	{0xcab4, "CAB_TERM", 0, {0}, FALSE},														/* CAB-Protokoll */
	{0xcab5, "CAB_REQUESTSTATUS", 0, {0}, FALSE},											/* CAB-Protokoll */
	{0xcab6, "CAB_STATUS", 1, {{3, T_INT, "Online"}}, FALSE},							/* CAB-Protokoll */
	{0xcab7, "CAB_RELEASESTATUS", 0, {0}, FALSE},											/* CAB-Protokoll */
	{0xcab8, "CAB_HELLO", 3, {{3, T_INT_HEX, "Version"}, {4, T_INT, "Protokolle"}, {5, T_INT, "Nachrichten"}}, FALSE},			/* CAB-Protokoll */
	{0xcab9, "CAB_MAIL", 3, {{3, T_ADR, "URL"}, {5, T_ADR, "Mail"}, {4, T_INT, "Optionen"}}, FALSE},			/* CAB-Protokoll */
	{0xcaba, "CAB_MAILSENT", 2, {{3, T_INT, "Fehler"}, {4, T_INT, "Fehlernummer"}}, FALSE},			/* CAB-Protokoll */
	{0xcabb, "CAB_SUPPORT", 0, {0}, FALSE},													/* CAB-Protokoll */
	{0xcabd, "CAB_D", 0, {0L}, FALSE},			/* ??? */
	{0xcabe, "CAB_E", 0, {0L}, FALSE},			/* ??? */
	{0xcabf, "CAB_F", 0, {0L}, FALSE},			/* ??? */
	{0x0935, "WIND_DATA", 0, {0L}, FALSE},		/* ??? */
	{0x0936, "DO_WPOPUP", 0, {0L}, FALSE},		/* ??? */
	{0x0997, "WISEL_MSG", 0, {0L}, FALSE},		/* ??? */
	{0x0998, "MSG_NOEVENT", 0, {0L}, FALSE},
	{0x0999, "WINCOM_MSG", 3, {{3, T_INT, "Kommando"}, {4, T_INT, "ID/Option"}, {5, T_INT, "ID"}}, FALSE},		/* WinCom */
	{0x1235, "GO_PRIVATE", 1, {{3, T_INT, "subcode"}}, FALSE},
	{0x4560, "FILE_SELECTED", 0, {0L}, FALSE},		/* ??? */
	{0x46ff, "THING_MSG", 0, {0L}, FALSE},				/* ??? */
	{0x475a, "GZ_PRIVATE", 0, {0L}, FALSE},			/* ??? */
	{0x4b48, "DA_KNOWHOW", 0, {0L}, FALSE},			/* ??? */
	{0x6368, "CHTW_MSG", 0, {0L}, FALSE},				/* ??? */
	{0x7996, "AES-Load", 0, {0L}, FALSE},				/* ??? */
	{0x0400, "ACC_ID", 4, {{3, T_INT_HEX, "version/group"}, {4, T_STR, "name"}, {6, T_INT, "menu-ID"}, {7, T_INT, "msg7"}}, FALSE},
	{0x0401, "ACC_OPEN", 0, {0L}, FALSE},
	{0x0402, "ACC_CLOSE", 0, {0L}, FALSE},
	{0x0403, "ACC_ACC", 4, {{3, T_INT_HEX, "version/group"}, {4, T_STR, "name"}, {6, T_INT, "menu-ID"}, {7, T_AESID, "apid"}}, FALSE},
	{0x0404, "ACC_EXIT", 0, {0L}, FALSE},
	{0x0480, "ACC_REQUEST", 0, {0L}, FALSE},		/* ??? */
	{0x0481, "ACC_REPLY", 0, {0L}, FALSE},			/* ??? */
	{0x0500, "ACC_ACK", 1, {{3, T_INT, "ok"}}, FALSE},
	{0x0501, "ACC_TEXT", 1, {{4, T_ADR, "buf"}}, FALSE},
	{0x0502, "ACC_KEY", 2, {{3, T_KEY, "key"}, {4, T_SHIFT, "shift"}}, FALSE},
	{0x0503, "ACC_META", 3, {{3, T_INT, "last"}, {4, T_ADR, "buf"}, {6, T_LONG, "size"}}, FALSE},
	{0x0504, "ACC_IMG", 3, {{3, T_INT, "last"}, {4, T_ADR, "buf"}, {6, T_LONG, "size"}}, FALSE},
	{0x0510, "ACC_GETDSI", 0, {0L}, FALSE},		/* ??? */
	{0x0511, "ACC_DSINFO", 0, {0L}, FALSE},		/* ??? */
	{0x0512, "ACC_FILEINFO", 0, {0L}, FALSE},		/* ??? */
	{0x0513, "ACC_GETFIELDS", 0, {0L}, FALSE},	/* ??? */
	{0x0514, "ACC_FIELDINFO", 0, {0L}, FALSE},	/* ??? */
	{0x0520, "ACC_FORCESDF", 0, {0L}, FALSE},		/* ??? */
	{0x0521, "ACC_GETSDF", 0, {0L}, FALSE},		/* ??? */
	{0x1000, "WM_SAVE", 0, {0L}, FALSE},
	{0x1001, "WM_SAVEAS", 0, {0L}, FALSE},
	{0x1002, "WM_PRINT", 0, {0L}, FALSE},
	{0x1003, "WM_UNDO", 0, {0L}, FALSE},
	{0x1004, "WM_CUT", 0, {0L}, FALSE},
	{0x1005, "WM_COPY", 0, {0L}, FALSE},
	{0x1006, "WM_PASTE", 0, {0L}, FALSE},
	{0x1007, "WM_SELECTALL", 0, {0L}, FALSE},
	{0x1008, "WM_FIND", 0, {0L}, FALSE},
	{0x1009, "WM_REPLACE", 0, {0L}, FALSE},
	{0x100a, "WM_FINDNEXT", 0, {0L}, FALSE},
	{0x100b, "WM_HELP", 0, {0L}, FALSE},
	{0x100c, "WM_DELETE", 0, {0L}, FALSE},
	{30961, "WinChangeFont", 5, {{3, T_INT, "whnd"}, {4, T_INT, "id"}, {5, T_INT, "pt"}, {6, T_INT, "col"}, {7, T_INT_HEX, "effects"}}, FALSE},
	{0, 0L, 0, {0}}
};

GEM_APP gem_app[MAX_GEM_APPS];
int gem_app_anz;			/* Benutzte EintrÑge (mit ungÅltigen) */
int gem_app_filled;		/* gÅltige EintrÑge */

int init_aesfuncs(void)
{
	long size;
	AESFUNC *func = aes_func;
	aes_funcs.min_hash = func->opcode;
	aes_funcs.max_hash = func->opcode;
	while (func->name) {
		if ((unsigned int)func->opcode < aes_funcs.min_hash)
			aes_funcs.min_hash = func->opcode;
		if ((unsigned int)func->opcode > aes_funcs.max_hash)
			aes_funcs.max_hash = func->opcode;
		func++;
	}
	size = (aes_funcs.max_hash - aes_funcs.min_hash + 1) * sizeof(AESFUNC*);
	aes_funcs.hash = Malloc(size);
	if (!aes_funcs.hash)
		return FALSE;
	memset(aes_funcs.hash, 0, size);
	func = aes_func;
	while (func->name) {
		if (!aes_funcs.hash[(unsigned int)func->opcode - aes_funcs.min_hash])		/* Nur den ersten merken! */
			aes_funcs.hash[(unsigned int)func->opcode - aes_funcs.min_hash] = func;
		func++;
	}
	return TRUE;
}

int init_gem_msgs(void)
{
	long size;
	GEM_MSG *msg = gem_msg;
	gem_msgs.min_hash = msg->nr;
	gem_msgs.max_hash = msg->nr;
	while (msg->name) {
		if ((unsigned int)msg->nr < gem_msgs.min_hash)
			gem_msgs.min_hash = msg->nr;
		if ((unsigned int)msg->nr > gem_msgs.max_hash)
			gem_msgs.max_hash = msg->nr;
		msg++;
	}
	size = (gem_msgs.max_hash - gem_msgs.min_hash + 1) * sizeof(GEM_MSG*);
	gem_msgs.hash = Malloc(size);
	if (!gem_msgs.hash)
		return FALSE;
	memset(gem_msgs.hash, 0, size);
	msg = gem_msg;
	while (msg->name) {
		gem_msgs.hash[(unsigned int)msg->nr - gem_msgs.min_hash] = msg;
		msg++;
	}
	return TRUE;
}

void deinit_aesfuncs(void)
{
	if (aes_funcs.hash)
		Mfree(aes_funcs.hash);
}

void deinit_gem_msgs(void)
{
	if (gem_msgs.hash)
		Mfree(gem_msgs.hash);
}

#define AES_MAX_REENTRANCE 64
#define AES_INFO_SIZE 24
extern long aes_info[];
extern void *nach_aestrap;
int deinit_aespending(void)
{
/* "Pending" traps zurÅckbiegen, damit sie nicht irgendwann in Manitor zurÅckkehren, wenn Manitor schon weg ist! */
	long *tab = aes_info;
	int ok = TRUE;
	int i = AES_MAX_REENTRANCE - 1;
	do {
		if (tab[0]) {	/* Basepage ausgefÅllt (Eintrag gÅltig) */
			if (*(long *)(tab[2]) == (long)nach_aestrap) {	/* Wurde von Manitor verbogen? */
				*(long *)(tab[2]) = tab[1];	/* verbogene Returnadresse zurÅckbiegen! */
			} else {
				ok = FALSE;	/* Kann nicht zurÅckverbogen werden! */
			}
		}
		(char *)tab += AES_INFO_SIZE;
	} while (--i >= 0);
	return ok;
}

/* Broadcast an alle Apps, damit diese mal kurz
aus ihrem "Winterschlaf" aufwachen, und somit aus
evtl. getracten evnt-Routinen zurÅckgekehrt wird! */

#define MSG_NOEVENT     0x0998

void deinit_broadcast(void)
{
	if (aesinfo.applsearch) {
		static int16 msg[8] = {MSG_NOEVENT, 0, 0, 0, 0, 0, 0, 0};
		char name[9];
		int16 type;
		int16 id;
		int16 mode = 0;	/* erste */

		while (appl_search(mode, name, &type, &id, global) == 1) {
			my_appl_write(id, msg);
			mode = 1;	/* nÑchste */
		}
	}
}

int init_aes(void)
{
	return (init_aesfuncs() && init_gem_msgs());
}

void deinit_aes(void)
{
	deinit_gem_msgs();
	deinit_aesfuncs();
}

AESFUNC *find_aesfunc(int opcode, int contrl1, int contrl3, int intin0, int intin1)
{
	AESFUNC *func;

	if (opcode < aes_funcs.min_hash || opcode > aes_funcs.max_hash)
		return 0L;

	func = aes_funcs.hash[opcode - aes_funcs.min_hash];

	if (func) {
		while (func->name && func->opcode == opcode) {
			if (	(func->anz_intin == EGAL || func->anz_intin == contrl1) &&
					(func->anz_addrin == EGAL || func->anz_addrin == contrl3) &&
					(func->subcode == NO_SUBCODE || func->subcode == intin0) &&
					(func->subcode2 == NO_SUBCODE || func->subcode2 == intin1)	)
				return func;
			func++;
		}

/* Nicht gefunden -> evtl. falsche Werte in control[1/3] (Anzahl intin/addrin) : */

/*
		func = aes_funcs.hash[opcode - aes_funcs.min_hash];
		if ((func + 1)->opcode != opcode)	/* Einzige Funktion mit diesem Opcode? */
			return func;							/* Dann einfach nehmen */
*/

		return (aes_funcs.hash[opcode - aes_funcs.min_hash]);


	}

	return 0L;
}

void show_aesfunc(AESFUNC *func, AESPB *pb)
{
	AESPARA *para = func->para;
	void *ptr;
	int komma = FALSE;
	int i;
	fillbuf(" ", 1);
	fillbuf_string(func->name);
	fillbuf("(", 1);
	for(i = func->para_anz; --i >= 0; ) {
		if (komma)
			fillbuf(", ", 2);
		switch (para->intype) {
		case INTIN:
			ptr = &pb->intin[para->idx];
			break;
		case ADDRIN:
			ptr = &pb->addrin[para->idx];
			break;
		default:
			ptr = pb;
		}
		show_funcpara(para->typ, para->name, &ptr);
		para++;
		komma = TRUE;
	}
	fillbuf(")\r\n", 3);
}

GEM_APP *find_gem_app(int id)
{
	GEM_APP *app = gem_app;
	int i;

	for(i = 0; i < gem_app_anz; i++, app++) {
		if (app->gueltig && app->id == id)
			return app;
	}
	return 0L;
}

GEM_APP *find_gem_app_by_basepage(BASPAG *bas)
{
	GEM_APP *app = gem_app;
	int i;
	for(i = 0; i < gem_app_anz; i++, app++) {
		if (app->gueltig && app->bas == bas)
			return app;
	}
	return 0L;
}

static char *unknown_prg = "<???>";

void get_prg(BASPAG *bas, int aesid, char **prc_name, char **app_name)
{
	char *env = bas->p_env;
	*prc_name = unknown_prg;
	*app_name = 0L;
	if ((long)env > 0L) {
		while (*env) {
			if (strncmp(env, "_PNAM=", 6) == 0) {
				*prc_name = (env + 6);						/* _PNAM gefunden, Prozeûname ermittelt */
				break;
			}
			env += strlen(env) + 1;
		}
	}
	if (aesid >= 0) {											/* AES-ID bekannt? (AES-Trap) */
		GEM_APP *app = find_gem_app(aesid);
		if (app) {
			*app_name = app->name;							/* Applikationsname ermittelt */
			app->bas = bas;									/* Basepage merken */
		}
	} else if (!*prc_name) {								/* Keine AES-ID bekannt und kein Prozeûname gefunden? */
		GEM_APP *app = find_gem_app_by_basepage(bas);	/* Dann Anhand der Basepage die GEM-App ermitteln... */
		if (app) {
			*prc_name = app->name;							/* ...und das als Prozeûname nehmen */
		}
	}
}

GEM_APP *find_free_app(void)
{
	GEM_APP *app = gem_app;
	int i;
	if (gem_app_anz == gem_app_filled) {
		if (gem_app_anz == MAX_GEM_APPS)
			return 0L;
		return &gem_app[gem_app_anz];
	}
	for(i = 0; i < MAX_GEM_APPS; i++, app++) {
		if (!app->gueltig)
			return app;
	}
	return 0L;	/* darf nie auftreten */
}

GEM_MSG *find_gem_msg(int nr)
{
	if (nr < gem_msgs.min_hash || nr > gem_msgs.max_hash)
		return 0L;
	return gem_msgs.hash[nr - gem_msgs.min_hash];
}

void show_message(int *msgbuf, int ziel_pid, char *prc_name, char *title)
{
	GEM_MSG *msg = find_gem_msg(msgbuf[0]);
	if (!msg || !msg->filtered) {
		char nr[12];

		if (show_timer) {
			ultoa((*(long *)0x4BAL) - begin_timer, nr, 10);
			fillbuf_string(nr);
			fillbuf(": ", 2);
		}

		if (show_msg_prgname) {
			fillbuf_prg(-1, prc_name, 0L, SIZE_MSG);
			fillbuf(" ", 1);
		}
		fillbuf_string(title);
		fillbuf(": ", 2);

		{
			int quell_pid = msgbuf[1];
			GEM_APP *app = find_gem_app(quell_pid);
			fillbuf_aes(quell_pid, app ? app->name : 0L);
		}
		fillbuf(" -> ", 4);
		{
			GEM_APP *app = find_gem_app(ziel_pid);
			fillbuf_aes(ziel_pid, app ? app->name : 0L);
		}
		fillbuf(": ", 2);
		if (msg) {
			int trenner = FALSE;
			int i = msg->para_anz;
			MSGPARA *para = msg->para;
			void *ptr;
			fillbuf_string(msg->name);
			if (i) {
				fillbuf("( ", 2);
				while (--i >= 0) {
					if (trenner)
						fillbuf(", ", 2);
					ptr = &msgbuf[para->idx];
					show_funcpara(para->typ, para->name, &ptr);
					para++;
					trenner = TRUE;
				}
				fillbuf(" )", 2);
			}
		} else {
			itoa(msgbuf[0], nr, 10);
			fillbuf_string(nr);
			fillbuf(" (0x", 4);
			itoa(msgbuf[0], nr, 16);
			fillbuf_string(nr);
			fillbuf(")", 1);
		}
		fillbuf("\r\n", 2);
	}
}

void aes_trace(AESPB *pb)
{
	int opcode = pb->contrl[0];
	int pid;
	char *prc_name;
	char *app_name;

/*
	if (!pb->global) {
		fillbuf(" *** global == 0 !!! *** ", 25);
		fillbuf_crlf();
		pid = -1;
	} else {
*/
		pid = opcode == 10 ? -1 : pb->global[2];	/* Bei appl_init stimmt pid noch nicht!!! */
/*
	}
*/

	get_prg(*p_run, pid, &prc_name, &app_name);	/* Vorher machen, damit Basepage evtl. zu App gemerkt wird. */

	show_returncodes();

	if (aes_is_traced && !prg_is_filtered(prc_name, app_name)) {
		char nr[12];
		AESFUNC *func = find_aesfunc(opcode, pb->contrl[1], pb->contrl[3], pb->intin[0], pb->intin[1]);
		if (!func || !func->filtered) {

			if (show_timer) {
				ultoa((*(long *)0x4BAL) - begin_timer, nr, 10);
				fillbuf_string(nr);
				fillbuf(": ", 2);
			}

			fillbuf_prg(pid, prc_name, app_name, SIZE_PRG);

			if (show_trap || !func) {
				if (!show_short_trap || !func) {
					fillbuf(" {AES #", 7);
					itoa(opcode, nr, 10);
					fillbuf_string(nr);
					fillbuf("}", 1);
				} else {
					fillbuf(" A:", 3);
				}
			}
			if (func) {
				show_aesfunc(func, pb);
			} else {
				fillbuf(" ??? (control[1]=", 17);
				itoa(pb->contrl[1], nr, 10);
				fillbuf_string(nr);
				fillbuf(", control[3]=", 13);
				itoa(pb->contrl[3], nr, 10);
				fillbuf_string(nr);
				fillbuf(", intin[0]=", 11);
				itoa(pb->intin[0], nr, 10);
				fillbuf_string(nr);
				fillbuf(")\r\n", 3);
			}
		}

		if (show_snd_messages && opcode == 12) {		/* appl_write */
			int *msgbuf = pb->addrin[0];

			show_message(msgbuf, pb->intin[0], prc_name, "Message send    ");

		}
	}
}

void show_aesreturn(AESFUNC *func, RETURN *ret)
{
	AESPARA *para = func->retpara;
	void *ptr;
	int komma = FALSE;
	int i = func->ret_anz;

	while (--i >= 0) {
		switch (para->intype) {
		case INTOUT:
			ptr = &ret->intout[para->idx];
			break;
		case ADDROUT:
			ptr = &ret->addrout[para->idx];
			break;
		}

		if (komma)
			fillbuf(", ", 2);
		show_funcpara(para->typ, para->name, &ptr);

		komma = TRUE;
		para++;
	}
}

void aes_return(RETURN *ret)
{
	if (!prg_is_filtered(ret->prc_name, ret->app_name)) {
		AESFUNC *func = find_aesfunc(ret->opcode, ret->contrl1, ret->contrl3, ret->intin0, ret->intin1);
		if (!func || !func->filtered) {
			char nr[12];
			if (show_timer) {
				ultoa(ret->hz200 - begin_timer, nr, 10);
				fillbuf_string(nr);
				fillbuf(":>", 2);
			}
	
			fillbuf_prg(ret->pid, ret->prc_name, ret->app_name, SIZE_PRG);
	
			if (func) {
				fillbuf(">", 1);
				fillbuf_string(func->name);
				fillbuf("=> ", 3);
				show_aesreturn(func, ret);
			} else {
				fillbuf(">{AES #", 7);
				itoa(ret->opcode, nr, 10);
				fillbuf_string(nr);
				fillbuf("}=> intout[0] = ", 16);
				itoa(ret->intout[0], nr, 10);
				fillbuf_string(nr);
			}
			fillbuf_crlf();
		}

		if (show_rcv_messages && (ret->opcode == 23 || (ret->opcode == 25 && (ret->intin0 & MU_MESAG) && (ret->intout[0] & MU_MESAG)))) {	/* evnt_mesag oder evnt_multi(MU_MESAG) */
			if (!rcv_only_screnmgr || ret->msgbuf[1] == 1) {
				show_message(ret->msgbuf, ret->pid, ret->prc_name, "Message received");
			}
		}
	}
}

void update_gem_apps(void)
{
	if (aesinfo.applsearch) {
		char *c;
		static int check = 0;
		int neu = FALSE;
		GEM_APP *app;
		char name[9];
		int16 type;
		int16 id;
		int16 mode = 0;	/* erste */

		while (appl_search(mode, name, &type, &id, global) == 1) {
			app = find_gem_app(id);
			if (!app) {
				app = find_free_app();
				neu = TRUE;
			}
			if (app) {
				c = name + strlen(name) - 1;
				while (c >= name && *c == ' ')
					*c-- = 0;		/* Leerzeichen am Ende entfernen */
				app->id = id;
				strcpy(app->name, name);
				app->gueltig = TRUE;
				app->check = check;
				if (neu) {
					if (++gem_app_filled > gem_app_anz)
						gem_app_anz = gem_app_filled;
				}
			}
			mode = 1;	/* nÑchste */
		}
		/* nicht mehr vorhandene Apps entfernen: */
		app = gem_app;
		for(id = 0; id < gem_app_anz; id++, app++) {
			if (app->check != check)
				app->gueltig = FALSE;
		}
		check++;
	}
}
