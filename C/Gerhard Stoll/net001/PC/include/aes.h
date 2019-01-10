/******************************************************************************/
/*																										*/
/*		          Eine handoptimierte Bibliothek fÅr Pure-C               		*/
/*																										*/
/* Die AES-Funktionen - Headerdatei fÅr PureC-kompatible AES-Bindings			*/
/*																										*/
/* Diese Datei ersetzt die bisherige Datei AES.H von PureC. Die bisherige		*/
/* Datei umbenennen in AES_ORI.H, dann diese Datei in AES.H umbenennen...		*/
/*																										*/
/*	(c) 1998-2008 by Martin ElsÑsser @ LL, Gerhard Stoll @ B							*/
/*																										*/
/* 																Tabsize: 1 Tag = 3 Spaces	*/
/******************************************************************************/

#ifndef __AES__
#define __AES__

/* Die neue Header-Datei einbinden */
#include <ACSAES.H>

/******************************************************************************/
/*																										*/
/* Die globalen Variablen																		*/
/*																										*/
/******************************************************************************/

/* Der GEM-Parameterblock (Pure-C-kompatibel ;-( */
extern GEMPARBLK _GemParBlk;

/* Zeiger auf GLOBAL-Struktur des Hauptthreads */
extern GlobalArray *_globl;

/* Flag, ob Anwendung als Application oder Accessory lÑuft */
extern int16 _app;

/******************************************************************************/
/*																										*/
/* Die PureC-Funktionen ggf. per Makro auf die MT-Funktionen umleiten			*/
/*																										*/
/******************************************************************************/

#ifndef __COMPATIBLE_FKT__

/******************************************************************************/

/* Die APPL-Funktionen */
#define appl_init()										mt_appl_init(_globl)
#define appl_read(rwid, length, pbuff)				mt_appl_read(rwid, length, pbuff, _globl) 
#define appl_write(rwid, length, pbuff)			mt_appl_write(rwid, length, pbuff, _globl)
#define appl_find(pname)								mt_appl_find(pname, _globl)
#define appl_search(mode, fname, type, ap_id)	mt_appl_search(mode, fname, type, ap_id, _globl)
#define appl_tplay(buffer, tlength, tscale)		mt_appl_tplay(buffer, tlength, tscale, _globl)
#define appl_trecord(tbuffer, tlength)				mt_appl_trecord(tbuffer, tlength, _globl)
#define appl_bvset(a, b)								mt_appl_bvset(a, b, _globl)
#define appl_yield()										mt_appl_yield(_globl)
#define appl_exit()										mt_appl_exit(_globl)
#define appl_getinfo(type, out1, out2, out3, out4)	\
																mt_appl_getinfo(type, out1, out2, out3, out4, _globl)	
#define appl_getinfo_str(type, str1, str2, str3, str4)	\
																mt_appl_getinfo_str(type, str1, str2, str3, str4, _globl)	
#define appl_control(ap_cid, ap_cwhat, ap_cout)	mt_appl_control(ap_cid, ap_cwhat, ap_cout, _globl)

/* Falls appl_xgetinfo benutzt zur PrÅfung vor appl_getinfo wird, so ist dies */
/* ÅberflÅssig, da das Binding von appl_getinfo die PrÅfung mit erledigt!     */
#define appl_xgetinfo(type, out1, out2, out3, out4)	\
																mt_appl_getinfo(type, out1, out2, out3, out4, _globl)	

/******************************************************************************/

/* Die EVNT-Funktionen */
#define evnt_keybd()							mt_evnt_keybd(_globl)
#define evnt_button(a, b, c, d, e, f, g, h) \
													mt_evnt_button(a, b, c, d, e, f, g, h, _globl)
#define evnt_mouse(a, b, c, d, e, f, g, h, i) \
													mt_evnt_mouse(a, b, c, d, e, f, g, h, i, _globl)
#define evnt_mesag(pbuff)					mt_evnt_mesag(pbuff, _globl)
#define evnt_timer(ev_tlocount, ev_thicount) \
													mt_evnt_timer(((int32)(ev_thicount)<<32) | (int32)(ev_tlocount), _globl)
#define evnt_multi(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w) \
													mt_evnt_multi(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, ((int32)(q)<<16)|(int32)(p), r, s, t, u, v, w, _globl)
#define evnt_xmulti(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x) \
													mt_evnt_xmulti(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, ((int32)(q)<<16)|(int32)(p), r, s, t, u, v, w, x, _globl)
#define EVNT_multi(a, b, c, d, e, f, g, h) \
													mt_EVNT_multi(a, b, c, d, e, f, g, h, _globl)
#define evnt_dclick(rate, setit)			mt_evnt_dclick(rate, setit, _globl)

/* Eigener optimierter Aufruf */
#define evnt_event(input, output)		mt_evnt_event(input, output, _globl)

/* Optimierter, Pure-C kompatibler Aufruf */
#define EvntMulti(evnt_data)				mt_EvntMulti(evnt_data, _globl)

/******************************************************************************/

/* Die OBJC-Funktionen */
#define objc_add(tree, parent, child)				mt_objc_add(tree, parent, child, _globl)
#define objc_delete(tree, objnr)						mt_objc_delete(tree, objnr, _globl)
#define objc_draw(tree, start, depth, xc, yc, wc, hc) \
																mt_objc_draw(tree, start, depth, xc, yc, wc, hc, _globl)
#define objc_draw_grect(tree, start, depth, r) \
																mt_objc_draw_grect(tree, start, depth, r, _globl)
#define objc_find(tree, start, depth, mx, my)	mt_objc_find(tree, start, depth, mx, my, _globl)
#define objc_offset(tree, objnr, x, y)				mt_objc_offset(tree, objnr, x, y, _globl)
#define objc_order(tree, objnr, new_nr)			mt_objc_order(tree, objnr, new_nr, _globl)
#define objc_edit(tree, objnr, inchar, idx, kind) \
																mt_objc_edit(tree, objnr, inchar, idx, kind, _globl)
#define objc_xedit(tree, objnr, inchar, idx, kind, r) \
																mt_objc_xedit(tree, objnr, inchar, idx, kind, r, _globl)
#define objc_change(tree, objnr, rsvd,  xc, yc, wc, hc, newstate, redraw) \
																mt_objc_change(tree, objnr, rsvd,  xc, yc, wc, hc, newstate, redraw, _globl)
#define objc_sysvar(mode, which, in1, in2, out1, out2) \
																mt_objc_sysvar(mode, which, in1, in2, out1, out2, _globl)

/******************************************************************************/

/* OBJC-Erweiterungen von MagiC */
#define objc_wdraw(tree, start, depth, clip, whandle) \
																mt_objc_wdraw(tree, start, depth, clip, whandle, _globl)
#define objc_wedit(tree, objnr, inchar,  idx, kind, whandle) \
																mt_objc_wedit(tree, objnr, inchar,  idx, kind, whandle, _globl)
#define objc_wchange(tree, objnr, newstate, clip, whandle) \
																mt_objc_wchange(tree, objnr, newstate, clip, whandle, _globl)
#define objc_xfind(obj, start, depth, x, y)		mt_objc_xfind(obj, start, depth, x, y, _globl)

/******************************************************************************/

/* Die MENU-Funktionen */
#define menu_bar(tree, show)						mt_menu_bar(tree, show, _globl)
#define menu_icheck(tree, item, check)			mt_menu_icheck(tree, item, check, _globl)
#define menu_ienable(tree, item, enable)		mt_menu_ienable(tree, item, enable, _globl)
#define menu_tnormal(tree, title, normal)		mt_menu_tnormal(tree, title, normal, _globl)
#define menu_text(tree, item, text)				mt_menu_text(tree, item, text, _globl)
#define menu_register(apid, string)				mt_menu_register(apid, string, _globl)
#define menu_unregister(apid)						mt_menu_unregister(apid, _globl)
#define menu_click(click, setit)					mt_menu_click(click, setit, _globl)
#define menu_attach(flag, tree, item, mdata)	mt_menu_attach(flag, tree, item, mdata, _globl)
#define menu_istart(flag, tree, imenu, item)	mt_menu_istart(flag, tree, imenu, item, _globl)
#define menu_popup(menu, xpos, ypos, mdata)	mt_menu_popup(menu, xpos, ypos, mdata, _globl)
#define menu_settings(flag, set)					mt_menu_settings(flag, set, _globl)

/******************************************************************************/

/* Die FORM-Funktionen */
#define form_do(tree, start)				mt_form_do(tree, start, _globl)
#define form_dial(flag, x1, y1, w1, h1, x2, y2, w2, h2) \
													mt_form_dial(flag, x1, y1, w1, h1, x2, y2, w2, h2, _globl)
#define form_alert(defbutton, string)	mt_form_alert(defbutton, string, _globl)
#define form_error(errnum)					mt_form_error(errnum, _globl)
#define form_center(tree, x, y, w, h)	mt_form_center(tree, x, y, w, h, _globl)
#define form_center_grect(tree, r)	   mt_form_center_grect(tree, r, _globl)
#define form_keybd(tree, obj, next, input_char, next_obj, pchar) \
													mt_form_keybd(tree, obj, next, input_char, next_obj, pchar, _globl)
#define form_button(tree, obj, clicks, next_obj) \
													mt_form_button(tree, obj, clicks, next_obj, _globl)
#define form_popup(tree, x, y)			mt_form_popup(tree, x, y, _globl)

/******************************************************************************/

/* FlyDials-Funktionen von MagiC */
#define form_wbutton(fo_btree, fo_bobject, fo_bclicks, fo_bnxtobj, whandle) \
													mt_form_wbutton(fo_btree, fo_bobject, fo_bclicks, fo_bnxtobj, whandle, _globl)
#define form_xdial(flag, x1, y1,  w1, h1, x2, y2, w2, h2, flydial) \
													mt_form_xdial(flag, x1, y1,  w1, h1, x2, y2, w2, h2, flydial, _globl)
#define form_xdial_grect(flag, fo_dilittl, fo_dibig, flydial) \
													mt_form_xdial_grect(flag, fo_dilittl, fo_dibig, flydial, _globl)
#define form_xdo(tree, startob, lastcrsr, tabs, flydial) \
													mt_form_xdo(tree, startob, lastcrsr, tabs, flydial, _globl)
#define form_xerr(errcode, errfile)		mt_form_xerr(errcode, errfile, _globl)

/******************************************************************************/

/* Die GRAF-Funktionen */
#define graf_rubbox(x, y, w_min, h_min, w_end, h_end) \
													mt_graf_rubbox( x, y, w_min, h_min, w_end, h_end, _globl)
#define graf_rubbbox(x, y, w_min, h_min, w_end, h_end) \
													mt_graf_rubbox(x, y, w_min, h_min, w_end, h_end, _globl)
#define graf_rubberbox(x, y, w_min, h_min, w_end, h_end) \
													mt_graf_rubberbox(x, y, w_min, h_min, w_end, h_end, _globl)
#define graf_dragbox(w, h, sx, sy, xc, yc, wc, hc, x, y) \
													mt_graf_dragbox(w, h, sx, sy, xc, yc, wc, hc, x, y, _globl)
#define graf_mbox(w, h, start_x, start_y, ende_x, ende_y) \
													mt_graf_mbox(w, h, start_x, start_y, ende_x, ende_y, _globl)
#define graf_movebox(w, h, start_x, start_y, ende_x, ende_y) \
													mt_graf_movebox(w, h, start_x, start_y, ende_x, ende_y, _globl)
#define graf_growbox(s_x, s_y, s_w, s_h, e_x, e_y, e_w, e_h) \
													mt_graf_growbox(s_x, s_y, s_w, s_h, e_x, e_y, e_w, e_h, _globl)
#define graf_shrinkbox(s_x, s_y, s_w, s_h, e_x, e_y, e_w, e_h) \
													mt_graf_shrinkbox(s_x, s_y, s_w, s_h, e_x, e_y, e_w, e_h, _globl)
#define graf_watchbox(tree, obj_nr, instate, outstate) \
													mt_graf_watchbox(tree, obj_nr, instate, outstate, _globl)
#define graf_slidebox(tree, parent, obj_nr, isvert) \
													mt_graf_slidebox(tree, parent, obj_nr, isvert, _globl)
#define graf_handle(wchar, hchar, wbox, hbox) \
													mt_graf_handle(wchar, hchar, wbox, hbox, _globl)
#define graf_mouse(mouse_nr, form)		mt_graf_mouse(mouse_nr, form, _globl)
#define graf_mkstate(x, y, mstate, kstate) \
													mt_graf_mkstate(x, y, mstate, kstate, _globl)
#define graf_multirubber(x, y, minw, minh, rec, outw, outh) \
													mt_graf_multirubber(x, y, minw, minh, rec, outw, outh, _globl)

/******************************************************************************/

/* GRAF-Erweiterungen von MagiC */
#define graf_wwatchbox(wptree, wobject, winstate, woutstate, whandle) \
									mt_graf_wwatchbox(wptree, wobject, winstate, woutstate, whandle, _globl)
#define graf_xhandle(wchar, hchar, wbox, hbox, device) \
									mt_graf_xhandle(wchar, hchar, wbox, hbox, device, _globl)

/******************************************************************************/

/* Die SRCP-Funktionen */
#define scrp_read(pathname)			mt_scrp_read(pathname, _globl)
#define scrp_write(pathname)			mt_scrp_write(pathname, _globl)
#define scrp_clear()						mt_scrp_clear(_globl)

/******************************************************************************/

/* Die FSEL-Funktionen */
#define fsel_input(path, name, button)					mt_fsel_input(path, name, button, _globl)
#define fsel_exinput(path, name, button, label)		mt_fsel_exinput(path, name, button, label, _globl)
#define fsel_boxinput(path, name, button, label, callback) \
																	mt_fsel_boxinput(path, name, button, label, callback, _globl)

/******************************************************************************/

/* Die FSLX-Funktionen (MagiC, WDialog) */
#define fslx_open(a, b, c, d, e, f, g, h, i, j, k, l, m) \
														mt_fslx_open(a, b, c, d, e, f, g, h, i, j, k, l, m, _globl)
#define fslx_close(fsd)							mt_fslx_close(fsd, _globl)
#define fslx_getnxtfile(fsd, fname)			mt_fslx_getnxtfile(fsd, fname, _globl)
#define fslx_evnt(a, b, c, d, e, f, g, h)	mt_fslx_evnt(a, b, c, d, e, f, g, h, _globl)
#define fslx_do(a, b, c, d, e, f, g, h, i, j, k, l, m) \
														mt_fslx_do(a, b, c, d, e, f, g, h, i, j, k, l, m, _globl)
#define fslx_set_flags(flags, oldval)		mt_fslx_set_flags(flags, oldval, _globl)

/******************************************************************************/

/* Die WIND-Funktionen */
#define wind_create(kind, x, y, w, h)			mt_wind_create(kind, x, y, w, h, _globl)
#define wind_create_grect(kind, r)				mt_wind_create_grect(kind, r, _globl)
#define wind_open(handle, x, y, w, h)			mt_wind_open(handle, x, y, w, h, _globl)
#define wind_open_grect(handle, g)				mt_wind_open_grect(handle, g, _globl)
#define wind_close(handle)							mt_wind_close(handle, _globl)
#define wind_delete(handle)						mt_wind_delete(handle, _globl)
#define wind_getQSB(handle, buffer, length)	mt_wind_getQSB(handle, buffer, length, _globl)
#define wind_get_int(handle, what, g1) 		mt_wind_get_int(handle, what, g1, _globl )
#define wind_setGRECT(handle, what, xywh)		mt_wind_setGRECT(handle, what, xywh, _globl)
#define wind_set_grect(handle, what, xywh)	mt_wind_setGRECT(handle, what, xywh, _globl)
#define wind_set_int(handle, what, d1)			mt_wind_set_int(handle, what, g1, _globl)
#define wind_find(x, y)								mt_wind_find(x, y, _globl)
#define wind_update(what)							mt_wind_update(what, _globl)
#define wind_calc(wtype, kind, x, y, w, h, px, py, pw, ph) \
															mt_wind_calc(wtype, kind, x, y, w, h, px, py, pw, ph, _globl)
#define wind_calcGRECT(wtype, kind, input, output) \
															mt_wind_calcGRECT(wtype, kind, input, output, _globl)
#define wind_new()									mt_wind_new(_globl)
#define wind_draw(handle, startob)				mt_wind_draw(handle, startob, _globl)

/* Wegen variabler Parameter immer als Funktionen implementiert */
int16 wind_get( const int16 handle, const int16 what, ... );		/* up to 4 Pointers to int16 */
int16 wind_get_opt( const int16 handle, const int16 what, ... );	/* optimized for Pointers    */
int16 wind_set( const int16 handle, const int16 what, ... );

/******************************************************************************/

/* Die RSRC-Funktionen */
#define rsrc_load(name)						mt_rsrc_load(name, _globl)
#define rsrc_free()							mt_rsrc_free(_globl)
#define rsrc_gaddr(type, id, addr)		mt_rsrc_gaddr(type, id, addr, _globl)
#define rsrc_saddr(type, id, addr)		mt_rsrc_saddr(type, id, addr, _globl)
#define rsrc_obfix(tree, obj)				mt_rsrc_obfix(tree, obj, _globl)
#define rsrc_rcfix(rc_header)				mt_rsrc_rcfix(rc_header, _globl)

/******************************************************************************/

/* Die SHEL-Funktionen */
#define shel_read(cmd, tail)				mt_shel_read(cmd, tail, _globl)
#define shel_write(do_execute, is_graph, is_overlay, cmd, tail) \
													mt_shel_write(do_execute, is_graph, is_overlay, cmd, tail, _globl)
#define shel_get(addr, len)				mt_shel_get(addr, len, _globl)
#define shel_put(addr, len)				mt_shel_put(addr, len, _globl)
#define shel_find(path)						mt_shel_find(path, _globl)
#define shel_envrn(value, name)			mt_shel_envrn(value, name, _globl)
#define shel_rdef(cmd, dir)				mt_shel_rdef(cmd, dir, _globl)
#define shel_wdef(cmd, dir)				mt_shel_wdef(cmd, dir, _globl)
#define shel_help(mode, file, key)		mt_shel_help(mode, file, key, _globl)

/* Andere Schreibweise */
#define shel_environ(value, name)		mt_shel_envrn(value, name, _globl)

/******************************************************************************/

/* Die FNTS-Funktionen */
#define fnts_add(fnt_dialog, user_fonts)		mt_fnts_add(fnt_dialog, user_fonts, _globl)
#define fnts_close(fnt_dialog, x, y)			mt_fnts_close(fnt_dialog, x, y, _globl)
#define fnts_create(a, b, c, d, e, f)			mt_fnts_create(a, b, c, d, e, f, _globl)
#define fnts_delete(fnt_dialog, vdi_handle)	mt_fnts_delete(fnt_dialog, vdi_handle, _globl)
#define fnts_do(a, b, c, d, e, f, g, h, i)	mt_fnts_do(a, b, c, d, e, f, g, h, i, _globl)
#define fnts_evnt(a, b, c, d, e, f, g)			mt_fnts_evnt(a, b, c, d, e, f, g, _globl)
#define fnts_get_info(fnt_dialog, id, mono, outline) \
															mt_fnts_get_info(fnt_dialog, id, mono, outline, _globl)
#define fnts_get_name(fnt_dialog, id, full_name, family_name, style_name) \
															mt_fnts_get_name(fnt_dialog, id, full_name, \
																	family_name, style_name, _globl)
#define fnts_get_no_styles(fnt_dialog, id)	mt_fnts_get_no_styles(fnt_dialog, id, _globl)
#define fnts_get_style(fnt_dialog, id, index)mt_fnts_get_style(fnt_dialog, id, index, _globl)
#define fnts_open(fnt_dialog, button_flags, x, y, id, pt, ratio) \
															mt_fnts_open(fnt_dialog, button_flags, x, y, id, pt, ratio, _globl)
#define fnts_remove(fnt_dialog)					mt_fnts_remove(fnt_dialog, _globl)
#define fnts_update(fnt_dialog, button_flags, id, pt, ratio) \
															mt_fnts_update(fnt_dialog, button_flags, id, pt, ratio, _globl)

/******************************************************************************/

/* Die LBOX-Funktionen */
#define lbox_ascroll_to(box, first, box_rect, slider_rect) \
												mt_lbox_ascroll_to(box, first, box_rect, slider_rect, _globl)
#define lbox_scroll_to(box, first, box_rect, slider_rect) \
												mt_lbox_scroll_to(box, first, box_rect, slider_rect, _globl)
#define lbox_bscroll_to(box, first, box_rect, slider_rect) \
												mt_lbox_bscroll_to(box, first, box_rect, slider_rect, _globl)
#define lbox_cnt_items(box)			mt_lbox_cnt_items(box, _globl)
#define lbox_create(tr, slct, set, items, v_a, f_a, c_objs, objs, flags, p_a, user, dia, v_b, f_b, e_b, p_b) \
												mt_lbox_create(tr, slct, set, items, v_a, f_a, c_objs, objs, flags, p_a, user, dia, v_b, f_b, e_b, p_b, _globl)
#define lbox_delete(box)				mt_lbox_delete(box, _globl)
#define lbox_do(box, obj)				mt_lbox_do(box, obj, _globl)
#define lbox_free_items(box)			mt_lbox_free_items(box, _globl)
#define lbox_free_list(items)			mt_lbox_free_list(items, _globl)
#define lbox_get_afirst(box)			mt_lbox_get_afirst(box, _globl)
#define lbox_get_first(box)			mt_lbox_get_first(box, _globl)
#define lbox_get_avis(box)				mt_lbox_get_avis(box, _globl)
#define lbox_get_visible(box)			mt_lbox_get_visible(box, _globl)
#define lbox_get_bentries(box)		mt_lbox_get_bentries(box, _globl)
#define lbox_get_bfirst(box)			mt_lbox_get_bfirst(box, _globl)
#define lbox_get_idx(items, search)	mt_lbox_get_idx(items, search, _globl)
#define lbox_get_item(box, n)			mt_lbox_get_item(box, n, _globl)
#define lbox_get_items(box)			mt_lbox_get_items(box, _globl)
#define lbox_get_bvis(box)				mt_lbox_get_bvis(box, _globl)
#define lbox_get_slct_idx(box)		mt_lbox_get_slct_idx(box, _globl)
#define lbox_get_slct_item(box)		mt_lbox_get_slct_item(box, _globl)
#define lbox_get_tree(box)				mt_lbox_get_tree(box, _globl)
#define lbox_get_udata(box)			mt_lbox_get_udata(box, _globl)
#define lbox_set_asldr(box, first, rect) \
												mt_lbox_set_asldr(box, first, rect, _globl)
#define lbox_set_slider(box, first, rect) \
												mt_lbox_set_slider(box, first, rect, _globl)
#define lbox_set_bentries(box, entries) \
												mt_lbox_set_bentries(box, entries, _globl)
#define lbox_set_bsldr(box, first, rect) \
												mt_lbox_set_bsldr(box, first, rect, _globl)
#define lbox_set_items(box, items)	mt_lbox_set_items(box, items, _globl)
#define lbox_update(box, rect)		mt_lbox_update(box, rect, _globl)

/******************************************************************************/

/* Die PDLG-Funktionen */
#define pdlg_add_printers(prn_dialog, drv_info) \
													mt_pdlg_add_printers(prn_dialog, drv_info, _globl)
#define pdlg_add_sub_dialogs(prn_dialog, sub_dialog) \
													mt_pdlg_add_sub_dialogs(prn_dialog, sub_dialog, _globl)
#define pdlg_close(prn_dialog, x, y)	mt_pdlg_close(prn_dialog, x, y, _globl)
#define pdlg_create(dialog_flags)		mt_pdlg_create(dialog_flags, _globl)
#define pdlg_delete(prn_dialog)			mt_pdlg_delete(prn_dialog, _globl)
#define pdlg_dflt_settings(prn_dialog, settings) \
													mt_pdlg_dflt_settings(prn_dialog, settings, _globl)
#define pdlg_do(prn_dialog, settings, document_name, option_flags) \
													mt_pdlg_do(prn_dialog, settings, document_name, option_flags, _globl)
#define pdlg_evnt(prn_dialog, settings, events, button) \
													mt_pdlg_evnt(prn_dialog, settings, events, button, _globl)
#define pdlg_free_settings(settings)	mt_pdlg_free_settings(settings, _globl)
#define pdlg_get_setsize()					mt_pdlg_get_setsize(_globl)
#define pdlg_new_settings(prn_dialog)	mt_pdlg_new_settings(prn_dialog, _globl)
#define pdlg_open(prn_dialog, settings, document_name, option_flags, x, y) \
													mt_pdlg_open(prn_dialog, settings, document_name, option_flags, x, y, _globl)
#define pdlg_remove_printers(prn_dialog) \
													mt_pdlg_remove_printers(prn_dialog, _globl)
#define pdlg_remove_sub_dialogs(prn_dialog) \
													mt_pdlg_remove_sub_dialogs(prn_dialog, _globl)
#define pdlg_update(prn_dialog, document_name) \
													mt_pdlg_update(prn_dialog, document_name, _globl)
#define pdlg_use_settings(prn_dialog, settings) \
													mt_pdlg_use_settings(prn_dialog, settings, _globl)
#define pdlg_validate_settings(prn_dialog, settings) \
													mt_pdlg_validate_settings(prn_dialog, settings, _globl)

/******************************************************************************/

/* Die WDLG-Funktionen */
#define wdlg_create(handle_exit, tree, user_data, code, data, flags) \
														mt_wdlg_create(handle_exit, tree, user_data, code, data, flags, _globl)
#define wdlg_open(dialog, title, kind, x, y, code, data) \
														mt_wdlg_open(dialog, title, kind, x, y, code, data, _globl)
#define wdlg_close(dialog, x, y)				mt_wdlg_close(dialog, x, y, _globl)
#define wdlg_delete(dialog)					mt_wdlg_delete(dialog, _globl)
#define wdlg_get_tree(dialog, tree, r)		mt_wdlg_get_tree(dialog, tree, r, _globl)
#define wdlg_get_edit(dialog, cursor)		mt_wdlg_get_edit(dialog, cursor, _globl)
#define wdlg_get_udata(dialog)				mt_wdlg_get_udata(dialog, _globl)
#define wdlg_get_handle(dialog)				mt_wdlg_get_handle(dialog, _globl)
#define wdlg_set_edit(dialog, obj)			mt_wdlg_set_edit(dialog, obj, _globl)
#define wdlg_set_tree(dialog, new_tree)	mt_wdlg_set_tree(dialog, new_tree, _globl)
#define wdlg_set_size(dialog, new_size)	mt_wdlg_set_size(dialog, new_size, _globl)
#define wdlg_set_iconify(dialog, g, title, tree, obj) \
														mt_wdlg_set_iconify(dialog, g, title, tree, obj, _globl)
#define wdlg_set_uniconify(dialog, g, title, tree) \
														mt_wdlg_set_uniconify(dialog, g, title, tree, _globl)
#define wdlg_evnt(dialog, events)			mt_wdlg_evnt(dialog, events, _globl)
#define wdlg_redraw(dialog, rect, obj, depth) \
														mt_wdlg_redraw(dialog, rect, obj, depth, _globl)

/******************************************************************************/

/* Die EDIT-Funktionen */
#define edit_create()								mt_edit_create(_globl)
#define edit_set_buf(tree, obj, buffer, buflen) \
															mt_edit_set_buf(tree, obj, buffer, buflen, _globl)
#define edit_open(tree, obj)						mt_edit_open(tree, obj, _globl)
#define edit_close(tree, obj)						mt_edit_close(tree, obj, _globl)
#define edit_delete(editinfo)						mt_edit_delete(editinfo, _globl)
#define edit_cursor(tree, obj, whdl, show)	mt_edit_cursor(tree, obj, whdl, show, _globl)
#define edit_evnt(tree, obj, whdl, events, errcode) \
															mt_edit_evnt(tree, obj, whdl, events, errcode, _globl)
#define edit_get_buf(tree, obj, buffer, buflen, txtlen) \
															mt_edit_get_buf(tree, obj, buffer, buflen, txtlen, _globl)
#define edit_get_format(tree, obj, tabwidth, autowrap) \
															mt_edit_get_format(tree, obj, tabwidth, autowrap, _globl)
#define edit_get_colour(tree, obj, tcolour, bcolour) \
															mt_edit_get_colour(tree, obj, tcolour, bcolour, _globl)
#define edit_get_font(tree, obj, fontID, fontH, fontPix, mono) \
															mt_edit_get_font(tree, obj, fontID, fontH, fontPix, mono, _globl)
#define edit_get_cursor(tree, obj, cursorpos) \
															mt_edit_get_cursor(tree, obj, cursorpos, _globl)
#define edit_get_pos(tree, obj, xscroll, yscroll, cyscroll, cursorpos, cx, cy) \
															mt_edit_get_pos(tree, obj, xscroll, yscroll, cyscroll, cursorpos, cx, cy, _globl)
#define edit_get_dirty(tree, obj)				mt_edit_get_dirty(tree, obj, _globl)
#define edit_get_sel(tree, obj, bsel, esel)	mt_edit_get_sel(tree, obj, bsel, esel, _globl)
#define edit_get_scrollinfo(tree, obj, nlines, yscroll, yvis, yval, ncols, xscroll, xvis) \
															mt_edit_get_scrollinfo(tree, obj, nlines, yscroll, yvis, yval, ncols, xscroll, xvis, _globl)
#define edit_set_format(tree, obj, tabwidth, autowrap) \
															mt_edit_set_format(tree, obj, tabwidth, autowrap, _globl)
#define edit_set_colour(tree, obj, tcolour, bcolour) \
															mt_edit_set_colour(tree, obj, tcolour, bcolour, _globl)
#define edit_set_font(tree, obj, fontID, fontH, fontPix, mono) \
															mt_edit_set_font(tree, obj, fontID, fontH, fontPix, mono, _globl)
#define edit_set_cursor(tree, obj, cursorpos) \
															mt_edit_set_cursor(tree, obj, cursorpos, _globl)
#define edit_set_pos(tree, obj, xscroll, yscroll, cyscroll, cursorpos, cx, cy) \
															mt_edit_set_pos(tree, obj, xscroll, yscroll, cyscroll, cursorpos, cx, cy, _globl)
#define edit_resized(tree, obj, oldrh, newrh) \
															mt_edit_resized(tree, obj, oldrh, newrh, _globl)
#define edit_set_dirty(tree, obj, dirty)		mt_edit_set_dirty(tree, obj, dirty, _globl)
#define edit_scroll(tree, obj, whdl, yscroll, xscroll) \
															mt_edit_scroll(tree, obj, whdl, yscroll, xscroll, _globl)

/* edit_get_colour = edit_get_color? Ein Schreibfeher in der MagiC-Dokumentation? */
#define edit_get_color(tree, obj, tcolor, bcolor) \
															mt_edit_get_colour(tree, obj, tcolor, bcolor, _globl)

/* edit_set_colour = edit_set_color? Ein Schreibfeher in der MagiC-Dokumentation? */
#define edit_set_color(tree, obj, tcolor, bcolor) \
															mt_edit_set_colour(tree, obj, tcolor, bcolor, _globl)

/******************************************************************************/
/*																										*/
/* NÅtzliche Erweiterungen																		*/
/*																										*/
/******************************************************************************/

#define wind_calc_grect(type, parts, in, out) \
															mt_wind_calc_grect(type, parts, in, out, _globl)#define wind_create_grect(parts, r)				mt_wind_create_grect(parts, r, _globl)#define wind_get_grect(handle, what, r)		mt_wind_get_grect(handle, what, r, _globl)#define wind_xget_grect(handle, what, clip, r) \
															mt_wind_xget_grect(handle, what, clip, r, _globl)
#define wind_open_grect(handle, r)				mt_wind_open_grect(handle, r, _globl)#define wind_xset_grect(handle, what, s, r)	mt_wind_xset_grect(handle, what, s, r, _globl)#define wind_set_str(handle, what, str)		mt_wind_set_str(handle, what, str, _globl)
/******************************************************************************/

#endif

/******************************************************************************/
/*																										*/
/* Die PureC-Funktionen ggf. als Funktionen, die die MT-Funktionen aufrufen	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE_FKT__

/******************************************************************************/

/* Die APPL-Funktionen */
int16 appl_init( void );
int16 appl_read( const int16 rwid, const int16 length, void *pbuff );
int16 appl_write( const int16 rwid, const int16 length, void *pbuff );
int16 appl_find( char *pname );
int16 appl_search( const int16 mode, char *fname, int16 *type, int16 *ap_id );
int16 appl_tplay( APPLRECORD *tbuffer, const int16 tlength, const int16 tscale );
int16 appl_trecord( APPLRECORD *tbuffer, const int16 tlength );
int16 appl_bvset( const uint16 bvdisk, const uint16 bvhard );
int16 appl_yield( void );
int16 appl_exit( void );
int16 appl_getinfo( const int16 type, int16 *out1, int16 *out2, int16 *out3, int16 *out4 );
int16 appl_getinfo_str( const int16 type, char *str1, char *str2, char *str3, char *str4 );
int16 appl_control( const int16 ap_cid, const int16 ap_cwhat, void *ap_cout );

/******************************************************************************/

/* Die EVNT-Funktionen */
int16 evnt_keybd( void );
int16 evnt_button( const int16 ev_bclicks, const uint16 ev_bmask,
				const uint16 ev_bstate, int16 *ev_bmx, int16 *ev_bmy, int16 *ev_bbutton,
				int16 *ev_bkstate );
int16 evnt_xbutton( const int16 ev_bclicks, const uint16 ev_bmask,
				const uint16 ev_bstate, int16 *ev_bmx, int16 *ev_bmy, int16 *ev_bbutton,
				int16 *ev_bkstate, int16 *ev_bwhlpbuff );
int16 evnt_mouse( const int16 ev_moflags, const int16 ev_mox, const int16 ev_moy,
				const int16 ev_mowidth, const int16 ev_moheight, int16 *ev_momx, int16 *ev_momy,
				int16 *ev_mobutton, int16 *ev_mokstate );
int16 evnt_mesag( int16 *pbuff );
int16 evnt_timer( int16 ev_tlocount, int16 ev_thicount );
int16 evnt_multi( const int16 ev_mflags, const int16 ev_mbclicks, const int16 ev_mbmask,
				const int16 ev_mbstate, const int16 ev_mm1flags, const int16 ev_mm1x,
				const int16 ev_mm1y, const int16 ev_mm1width, const int16 ev_mm1height,
				const int16 ev_mm2flags, const int16 ev_mm2x, const int16 ev_mm2y,
				const int16 ev_mm2width, const int16 ev_mm2height, int16 *ev_mmgpbuff,
				const int16 ev_mtlocount, const int16 ev_mthicount, int16 *ev_mmox,
				int16 *ev_mmoy, int16 *ev_mmbutton, int16 *ev_mmokstate, int16 *ev_mkreturn,
				int16 *ev_mbreturn );
int16 evnt_xmulti( const int16 ev_mflags, const int16 ev_mbclicks, const int16 ev_mbmask,
				const int16 ev_mbstate, const int16 ev_mm1flags, const int16 ev_mm1x,
				const int16 ev_mm1y, const int16 ev_mm1width, const int16 ev_mm1height,
				const int16 ev_mm2flags, const int16 ev_mm2x, const int16 ev_mm2y,
				const int16 ev_mm2width, const int16 ev_mm2height, int16 *ev_mmgpbuff,
				const int16 ev_mtlocount, const int16 ev_mthicount, int16 *ev_mmox,
				int16 *ev_mmoy, int16 *ev_mmbutton, int16 *ev_mmokstate, int16 *ev_mkreturn,
				int16 *ev_mbreturn, int16 *ev_mwhlpbuff );
void EVNT_multi( const int16 ev_mflags, const int16 ev_mbclicks, const int16 ev_mbmask,
				const int16 ev_mbstate, MOBLK *m1, MOBLK *m2, const int32 ev_mtimer,
				EVNT *event );
int16 evnt_dclick( const int16 rate, const int16 setit );

/* Eigener optimierter Aufruf */
int16 evnt_event( MultiEventIn *input, MultiEventOut *output );

/* Optimierter, Pure-C kompatibler Aufruf */
int16 EvntMulti( EVENT *evnt_data );

/******************************************************************************/

/* Die OBJC-Funktionen */
int16 objc_add( OBJECT *tree, const int16 parent, const int16 child );
int16 objc_delete( OBJECT *tree, const int16 objnr );
int16 objc_draw( OBJECT *tree, const int16 start, const int16 depth,
				const int16 xclip, const int16 yclip, const int16 wclip, const int16 hclip );
int16 objc_draw_grect( OBJECT *tree, const int16 start, const int16 depth,	const GRECT *r );
int16 objc_find( OBJECT *tree, const int16 start, const int16 depth,
				const int16 mx, const int16 my );
int16 objc_offset( OBJECT *tree, const int16 objnr, int16 *x, int16 *y );
int16 objc_order( OBJECT *tree, const int16 objnr, const int16 new_nr );
int16 objc_edit( OBJECT *tree, const int16 objnr, const int16 inchar,
				int16 *idx, const int16 kind );
int16 objc_xedit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				int16 kind, GRECT *r );
int16 objc_change( OBJECT *tree, const int16 objnr, const int16 reserved, 
				const int16 xclip, const int16 yclip, const int16 wclip, const int16 hclip,
				const int16 newstate, const int16 redraw );
int16 objc_sysvar( const int16 mode, const int16 which, const int16 in1, const int16 in2,
				int16 *out1, int16 *out2 );

/******************************************************************************/

/* OBJC-Erweiterungen von MagiC */
void objc_wdraw( OBJECT *tree, const int16 start, const int16 depth, GRECT *clip,
				const int16 whandle );
int16 objc_wedit( OBJECT *ob_edtree, const int16 ob_edobject, const int16 ob_edchar, 
				int16 *ob_edidx, const int16 ob_edkind, const int16 whandle );
void objc_wchange( OBJECT *tree, const int16 objnr, const int16 newstate,
				GRECT *clip, const int16 whandle );
int16 objc_xfind( OBJECT *obj, const int16 start, const int16 depth,
				const int16 x, const int16 y );

/******************************************************************************/

/* Die MENU-Funktionen */
int16 menu_bar( OBJECT *tree, const int16 show );
int16 menu_icheck( OBJECT *tree, const int16 item, const int16 check );
int16 menu_ienable( OBJECT *tree, const int16 item, const int16 enable );
int16 menu_tnormal( OBJECT *tree, const int16 title, const int16 normal );
int16 menu_text( OBJECT *tree, const int16 item, char *text );
int16 menu_register( const int16 apid, char *string );
int16 menu_unregister( const int16 apid );
int16 menu_click( const int16 click, const int16 setit );
int16 menu_attach( const int16 flag, OBJECT *tree, const int16 item, MENU *mdata );
int16 menu_istart( const int16 flag, OBJECT *tree, const int16 imenu, const int16 item );
int16 menu_popup( MENU *menu, const int16 xpos, const int16 ypos, MENU *mdata );
int16 menu_settings( const int16 flag, MN_SET *set );

/******************************************************************************/

/* Die FORM-Funktionen */
int16 form_do( OBJECT *tree, const int16 start );
int16 form_dial( const int16 flag, const int16 xlittle, const int16 ylittle,
				const int16 wlittle, const int16 hlittle, const int16 xbig, const int16 ybig,
				const int16 wbig, const int16 hbig );
int16 form_alert( const int16 defbutton, char *string );
int16 form_error( const int16 errnum );
int16 form_center( OBJECT *tree, int16 *x, int16 *y, int16 *w, int16 *h );
int16 form_center_grect( OBJECT *tree, GRECT *r );
int16 form_keybd( OBJECT *tree, const int16 obj, const int16 next,
				const int16 input_char, int16 *next_obj, int16 *pchar );
int16 form_button( OBJECT *tree, const int16 obj, const int16 clicks, int16 *next_obj );
int16 form_popup( OBJECT *tree, const int16 x, const int16 y);

/******************************************************************************/

/* FlyDials-Funktionen von MagiC */
int16 form_wbutton( const OBJECT *fo_btree, const int16 fo_bobject,
				const int16 fo_bclicks, int16 *fo_bnxtobj, const int16 whandle );
int16 form_xdial( const int16 fo_diflag, const int16 fo_dilittlx, const int16 fo_dilittly, 
				const int16 fo_dilittlw, const int16 fo_dilittlh, const int16 fo_dibigx,
				const int16 fo_dibigy, const int16 fo_dibigw, const int16 fo_dibigh, 
				void **flydial );
int16 form_xdial_grect( const int16 fo_diflag, const GRECT *fo_dilittl,
				const GRECT *fo_dibig, void **flydial );
int16 form_xdo( const OBJECT *tree, const int16 startob,
				int16 *lastcrsr, const XDO_INF *tabs, void *flydial );
int16 form_xerr( const int32 errcode, int8 *errfile );

/******************************************************************************/

/* Die GRAF-Funktionen */
int16 graf_rubbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end );
int16 graf_rubbbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end );
int16 graf_rubberbox( const int16 x, const int16 y, const int16 w_min,
				int16 const h_min, int16 *w_end, int16 *h_end );
int16 graf_dragbox( const int16 w, const int16 h, const int16 sx,
				const int16 sy, const int16 xc, const int16 yc, const int16 wc, const int16 hc,
				int16 *x, int16 *y );
int16 graf_mbox( const int16 w, const int16 h, int16 const start_x,	const int16 start_y,
				const int16 ende_x, const int16 ende_y );
int16 graf_movebox( const int16 w, const int16 h, const int16 start_x, const int16 start_y,
				int16 const ende_x, int16 const ende_y );
int16 graf_growbox( const int16 start_x, const int16 start_y,	const int16 start_w,
				const int16 start_h, const int16 ende_x, const int16 ende_y, const int16 ende_w,
				const int16 ende_h );
int16 graf_shrinkbox( const int16 start_x, const int16 start_y, const int16 start_w,
				const int16 start_h, const int16 ende_x, const int16 ende_y, const int16 ende_w,
				const int16 ende_h );
int16 graf_watchbox( OBJECT *tree, const int16 obj_nr, const int16 instate,
				const int16 outstate );
int16 graf_slidebox( OBJECT *tree, const int16 parent, const int16 obj_nr,
				const int16 isvert );
int16 graf_handle( int16 *wchar, int16 *hchar, int16 *wbox, int16 *hbox );
int16 graf_mouse( const int16 mouse_nr, MFORM *form );
int16 graf_mkstate( int16 *x, int16 *y, int16 *mstate, int16 *kstate );
int16 graf_multirubber( const int16 x, const int16 y, const int16 minw, const int16 minh,
				GRECT *rec, int16 *outw, int16 *outh );

/******************************************************************************/

/* GRAF-Erweiterungen von MagiC */
int16 graf_wwatchbox( const OBJECT *gr_wptree, const int16 gr_wobject,
				const int16 gr_winstate, const int16 gr_woutstate, const int16 whandle );
int16 graf_xhandle( int16 *wchar, int16 *hchar, int16 *wbox, int16 *hbox, int16 *device );

/******************************************************************************/

/* Die SRCP-Funktionen */
int16 scrp_read( char *pathname );
int16 scrp_write( char *pathname );
int16 scrp_clear( void );

/******************************************************************************/

/* Die FSEL-Funktionen */
int16 fsel_input( char *path, char *name, int16 *button );
int16 fsel_exinput( char *path, char *name, int16 *button, const char *label );
int16 fsel_boxinput( char *path, char *name, int *button,
			const char *label, FSEL_CALLBACK callback );

/******************************************************************************/

/* Die FSLX-Funktionen (MagiC, WDialog) */
void *fslx_open( char *title, const int16 x, const int16 y, int16 *handle, char *path,
				const int16 pathlen, char *fname, const int16 fnamelen, char *patterns,
				XFSL_FILTER *filter, char *paths, const int16 sort_mode, const int16 flags);
int16 fslx_close( void *fsd );
int16 fslx_getnxtfile( void *fsd, char *fname );
int16 fslx_evnt( void *fsd, EVNT *events, char *path, char *fname, int16 *button,
			int16 *nfiles, int16 *sort_mode, char **pattern );
void *fslx_do( char *title, char *path, const int16 pathlen, char *fname,
				const int16 fnamelen, char *patterns, XFSL_FILTER *filter, char *paths,
				int16 *sort_mode, const int16 flags, int16 *button, int16 *nfiles, char **pattern );
int16 fslx_set_flags( const int16 flags, int16 *oldval );

/******************************************************************************/

/* Die WIND-Funktionen */
int16 wind_create( const int16 kind, const int16 max_x, const int16 max_y,
				const int16 max_w, const int16 max_h );
int16 wind_create_grect( const int16 kind,  const GRECT *r );
int16 wind_open( const int16 handle, const int16 x, const int16 y,
				const int16 w, const int16 h );
int16 wind_open_grect( const int16 handle, GRECT *g );
int16 wind_close( const int16 handle );
int16 wind_delete( const int16 handle );
int16 wind_getQSB( const int16 handle, void **buffer, int32 *length );
int16 wind_get_int( const int16 handle, int16 what, int16 *g1 );
int16 wind_setGRECT( const int16 handle, const int16 what, const GRECT *xywh );
#define  wind_set_grect( handle, what, xywh )	wind_setGRECT( handle, what, xywh )
int16 wind_set_int( const int16 handle, const int16 what, const int g1 );
int16 wind_find( const int16 x, const int16 y );
int16 wind_update( const int16 what );
int16 wind_calc( const int16 wtype, const int16 kind, const int16 x, const int16 y,
				const int16 w, const int16 h, int16 *px, int16 *py, int16 *pw, int16 *ph );
int16 wind_calcGRECT( const int16 wtype, const int16 kind, const GRECT *input,
				GRECT *output);
int16 wind_calc_grect( const int16 wtype, const int16 kind, const GRECT *input,
				GRECT *output);
int16 wind_new( void );
int16 wind_draw( const int16 handle, const int16 startob );

/* Wegen variabler Parameter immer als Funktionen implementiert */
int16 wind_get( const int16 handle, const int16 what, ... );		/* up to 4 Pointers to int16 */
int16 wind_get_opt( const int16 handle, const int16 what, ... );	/* optimized for Pointers    */
int16 wind_set( const int16 handle, const int16 what, ... );

/******************************************************************************/

/* Die RSRC-Funktionen */
int16 rsrc_load( char *name );
int16 rsrc_free( void );
int16 rsrc_gaddr( const int16 type, const int16 id, void *addr );
int16 rsrc_saddr( const int16 type, const int16 id, void *addr );
int16 rsrc_obfix( OBJECT *tree, const int16 obj );
int16 rsrc_rcfix( void *rc_header );

/******************************************************************************/

/* Die SHEL-Funktionen */
int16 shel_read( char *cmd, char *tail );
int16 shel_write( const int16 do_execute, const int16 is_graph, const int16 is_overlay,
				char *cmd, char *tail );
int16 shel_get( char *addr, const int16 len );
int16 shel_put( char *addr, const int16 len );
int16 shel_find( char *path );
int16 shel_envrn( char **value, char *name );
int16 shel_rdef( char *cmd, char *dir );
int16 shel_wdef( char *cmd, char *dir );
int16 shel_help( const int16 sh_hmode, char *sh_hfile, char *sh_hkey );

/* Andere Schreibweise */
#define shel_environ(value, name)	shel_envrn(value, name)

/******************************************************************************/

/* Die FNTS-Funktionen */
int16 fnts_add( const FNT_DIALOG *fnt_dialog, const FNTS_ITEM *user_fonts );
int16 fnts_close( const FNT_DIALOG *fnt_dialog, int16 *x, int16 *y );
FNT_DIALOG *fnts_create( const int16 vdi_handle, const int16 no_fonts,
					const int16 font_flags, const int16 dialog_flags,
					const int8 *sample, const int8 *opt_button );
int16 fnts_delete( const FNT_DIALOG *fnt_dialog, const int16 vdi_handle );
int16 fnts_do( FNT_DIALOG *fnt_dialog, const int16 button_flags, const int32 id_in,
					const fix31 pt_in, const int32 ratio_in, int16 *check_boxes, 
					int32 *id, fix31 *pt, fix31 *ratio );
int16 fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, int16 *button,
					int16 *check_boxes, int32 *id, fix31 *pt, fix31 *ratio );
int16 fnts_get_info( FNT_DIALOG *fnt_dialog, const int32 id, int16 *mono,
					int16  *outline );
int16 fnts_get_name( FNT_DIALOG *fnt_dialog, const int32 id, char *full_name,
					char *family_name, char *style_name );
int16 fnts_get_no_styles( FNT_DIALOG *fnt_dialog, const int32 id );
int32 fnts_get_style( FNT_DIALOG *fnt_dialog, const int32 id, const int16 index );
int16 fnts_open( FNT_DIALOG *fnt_dialog, const int16 button_flags, const int16 x,
					const int16 y, const int32 id, const fix31 pt, const fix31 ratio );
void fnts_remove( FNT_DIALOG *fnt_dialog );
int16 fnts_update( FNT_DIALOG *fnt_dialog, const int16 button_flags,
					const int32 id, const fix31 pt, const int32 ratio );

/******************************************************************************/

/* Die LBOX-Funktionen */
void lbox_ascroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect );
void lbox_scroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect );
void lbox_bscroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect );
int16 lbox_cnt_items( LIST_BOX *box );
LIST_BOX *lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set,
					LBOX_ITEM *items, const int16 visible_a, const int16 first_a,
					const int16 *ctrl_objs, const int16 *objs, const int16 flags, 
					const int16 pause_a, void *user_data, DIALOG *dialog,
					const int16 visible_b, const int16 first_b, const int16 entries_b, 
					const int16 pause_b );
int16 lbox_delete( LIST_BOX *box );
int16 lbox_do( LIST_BOX *box, const int16 obj );
void lbox_free_items( LIST_BOX *box );
void lbox_free_list( LBOX_ITEM *items );
int16 lbox_get_afirst( LIST_BOX *box );
int16 lbox_get_first( LIST_BOX *box );
int16 lbox_get_avis( LIST_BOX *box );
int16 lbox_get_visible( LIST_BOX *box );
int16 lbox_get_bentries( LIST_BOX *box );
int16 lbox_get_bfirst( LIST_BOX *box );
int16 lbox_get_bvis( LIST_BOX *box );
int16 lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search );
LBOX_ITEM *lbox_get_item( LIST_BOX *box, const int16 n );
LBOX_ITEM *lbox_get_items( LIST_BOX *box );
int16 lbox_get_slct_idx( LIST_BOX *box );
LBOX_ITEM *lbox_get_slct_item( LIST_BOX *box );
OBJECT *lbox_get_tree( LIST_BOX *box );
void *lbox_get_udata( LIST_BOX *box );
void lbox_set_asldr( LIST_BOX *box, const int16 first, GRECT *rect );
void lbox_set_slider( LIST_BOX *box, const int16 first, GRECT *rect );
void lbox_set_bentries( LIST_BOX *box, const int16 entries );
void lbox_set_bsldr( LIST_BOX *box, const int16 first, GRECT *rect );
void lbox_set_items( LIST_BOX *box, LBOX_ITEM *items );
void lbox_update( LIST_BOX *box, GRECT *rect );

/******************************************************************************/

/* Die PDLG-Funktionen */
int16 pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info );
int16 pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialog );
int16 pdlg_close( PRN_DIALOG *prn_dialog, int16 *x, int16 *y );
PRN_DIALOG *pdlg_create( const int16 dialog_flags );
int16 pdlg_delete( PRN_DIALOG *prn_dialog );
int16 pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings );
int16 pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name,
				const int16 option_flags );
int16 pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events,
				int16 *button );
int16 pdlg_free_settings( PRN_SETTINGS *settings );
int32 pdlg_get_setsize( void );
PRN_SETTINGS *pdlg_new_settings( PRN_DIALOG *prn_dialog );
int16 pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name,
				const int16 option_flags, const int16 x, const int16 y );
int16 pdlg_remove_printers( PRN_DIALOG *prn_dialog );
int16 pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog );
int16 pdlg_update( PRN_DIALOG *prn_dialog, CHAR *document_name );
int16 pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings );
int16 pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings );

/******************************************************************************/

/* Die WDLG-Funktionen */
DIALOG *wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, const int16 code,
				void *data, const int16 flags );
int16	wdlg_open( DIALOG *dialog, char *title, const int16 kind, const int16 x, const int16 y,
				const int16 code, void *data );
int16 wdlg_close( DIALOG *dialog, int16 *x, int16 *y );
int16 wdlg_delete( DIALOG *dialog );
int16 wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r );
int16 wdlg_get_edit( DIALOG *dialog, int16 *cursor );
void *wdlg_get_udata( DIALOG *dialog );
int16 wdlg_get_handle( DIALOG *dialog );
int16 wdlg_set_edit( DIALOG *dialog, const int16 obj );
int16 wdlg_set_tree( DIALOG *dialog, OBJECT *new_tree );
int16 wdlg_set_size( DIALOG *dialog, GRECT *new_size );
int16 wdlg_set_iconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree,
				const int16 obj );
int16 wdlg_set_uniconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree );
int16 wdlg_evnt( DIALOG *dialog, EVNT *events );
void wdlg_redraw( DIALOG *dialog, GRECT *rect, const int16 obj, const int16 depth );

/******************************************************************************/

/* Die EDIT-Funktionen */
XEDITINFO *edit_create( void );
void edit_set_buf( OBJECT *tree, const int16 obj, char *buffer, const int32 buflen );
int16 edit_open( OBJECT *tree, const int16 obj );
void edit_close( OBJECT *tree, const int16 obj );
void edit_delete( XEDITINFO *editinfo );
int16 edit_cursor( OBJECT *tree, const int16 obj, const int16 whdl, const int16 show );
int16 edit_evnt( OBJECT *tree, const int16 obj, const int16 whdl, EVNT *events,
				int32 *errcode );
int16 edit_get_buf( OBJECT *tree, const int16 obj, char **buffer, int32 *buflen,
				int32 *txtlen );
int16 edit_get_format( OBJECT *tree, const int16 obj, int16 *tabwidth, int16 *autowrap );
int16 edit_get_colour( OBJECT *tree, const int16 obj, int16 *tcolour, int16 *bcolour );
int16 edit_get_font( OBJECT *tree, const int16 obj, int16 *fontID, int16 *fontH,
				boolean *fontPix, boolean *mono );
int16 edit_get_cursor( OBJECT *tree, const int16 obj, char **cursorpos );
void edit_get_pos( OBJECT *tree, const int16 obj, int16 *xscroll, int32 *yscroll,
				char **cyscroll, char **cursorpos, int16 *cx, int16 *cy );
boolean edit_get_dirty( OBJECT *tree, const int16 obj );
void edit_get_sel( OBJECT *tree, const int16 obj, char **bsel, char **esel );
void edit_get_scrollinfo( OBJECT *tree, const int16 obj, int32 *nlines, int32 *yscroll,
				int16 *yvis, int16 *yval, int16 *ncols, int16 *xscroll, int16 *xvis );
void edit_set_format( OBJECT *tree, const int16 obj, const int16 tabwidth,
				const int16 autowrap );
void edit_set_colour( OBJECT *tree, const int16 obj, const int16 tcolour,
				const int16 bcolour );
void edit_set_font( OBJECT *tree, const int16 obj, const int16 fontID, const int16 fontH,
				const boolean fontPix, const boolean mono );
void edit_set_cursor( OBJECT *tree, const int16 obj, char *cursorpos );
void edit_set_pos( OBJECT *tree, const int16 obj, const int16 xscroll,
				const int32 yscroll, char *cyscroll, char *cursorpos, const int16 cx,
				const int16 cy );
int16 edit_resized( OBJECT *tree, const int16 obj, int16 *oldrh, int16 *newrh );
void edit_set_dirty( OBJECT *tree, const int16 obj, const boolean dirty );
int16 edit_scroll( OBJECT *tree, const int16 obj, const int16 whdl, const int32 yscroll,
				const int16 xscroll );

/* edit_get_colour = edit_get_color? Ein Schreibfeher in der MagiC-Dokumentation? */
int16 edit_get_color( OBJECT *tree, const int16 obj, int16 *tcolor, int16 *bcolor );

/* edit_set_colour = edit_set_color? Ein Schreibfeher in der MagiC-Dokumentation? */
void edit_set_color( OBJECT *tree, const int16 obj, const int16 tcolor, const int16 bcolor );

/******************************************************************************/
/*																										*/
/* NÅtzliche Erweiterungen																		*/
/*																										*/
/******************************************************************************/

int16 wind_calc_grect( const int16 type, int16 parts, const GRECT *in, GRECT *out );int16 wind_create_grect( const int16 parts, const GRECT *r );int16 wind_get_grect( const int16 handle, short what, GRECT *r );int16 wind_xget_grect( const int16 handle, int16 what, const GRECT *clip, GRECT *r );
int16 wind_open_grect( const int16 handle, const GRECT *r );int16 wind_set_grect( const int16 handle, const int16 what, const GRECT *r );int16 wind_xset_grect( const int16 handle, const int16 what, const GRECT *s, GRECT *r );int16 wind_set_str( const int16 handle, const int16 what, const char *str );
/******************************************************************************/

#endif

/******************************************************************************/

#endif
