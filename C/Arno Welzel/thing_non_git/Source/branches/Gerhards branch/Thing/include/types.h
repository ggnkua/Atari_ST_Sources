/**
 * Thing
 * Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Arno Welzel, Thomas Binder 1994-2012
 * @author     Arno Welzel, Thomas Binder
 * @license    LGPL
 */

/*-------------------------------------------------------------------------
 * Function prototypes for Thing
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------
 * 'debug.c'
 *-------------------------------------------------------------------------*/
#if 0
#ifdef DEBUG
void debugLog(short init, const char *format, ...);
#define DEBUGLOG(x) debugLog x
#else
#define DEBUGLOG(x)
#endif
#endif
#ifdef _DEBUG
void debugMain(char *debugMsg);
#endif

/*-------------------------------------------------------------------------
 APP.C
 -------------------------------------------------------------------------*/
short app_start(APPLINFO *appl, char *parm, char *apath, short *rex);
APPLINFO *app_add(void);
void app_remove(APPLINFO *appl);
APPLINFO *app_find(char *name);
APPLINFO *app_get(char *title);
APPLINFO **app_list(short *n);
void app_opensel(APPLINFO *appl);
char *app_env(APPLINFO *appl);
char *app_argv(char *cmd, char *prog, short unixpaths);
APPLINFO *app_match(short mode, char *name, short *ok);
void app_default(APPLINFO *appl);
APPLINFO *app_isdrag(char *name);

/*-------------------------------------------------------------------------
 AVSERVER.C
 -------------------------------------------------------------------------*/
short av_init(void);
void av_exit(void);
void avs_protokoll(short *msgbuf);
void avs_getstatus(short *msgbuf);
void avs_status(short *msgbuf);
void avs_sendkey(short *msgbuf);
void avs_askfilefont(short *msgbuf);
void avs_askconfont(short *msgbuf);
void avs_openwind(short *msgbuf);
void avs_startprog(short *msgbuf);
void avs_accwindopen(short *msgbuf);
void avs_accwindclosed(short *msgbuf);
void avs_path_update(short *msgbuf);
void avs_copy_dragged(short *msgbuf);
void avs_what_izit(short *msgbuf);
void avs_drag_on_window(short *msgbuf);
void avs_exit(short *msgbuf);
void avs_xwind(short *msgbuf);
void avs_vastart(short *msgbuf);
void avs_view(short *msgbuf);
void avs_fileinfo(short *msgbuf);
void avs_copyfile(short *msgbuf, short del);
AVINFO *avp_add(char *name, short id, short status);
void avp_remove(AVINFO *avinfo);
AVINFO *avp_get(short id);
void avp_exit(short id);
short avp_check(short id);
ACWIN *acwin_add(short id, short handle);
void acwin_remove(ACWIN *accwin);
ACWIN *acwin_find(short handle);
ACSTATE *astate_add(char *name, char *state);
void astate_remove(ACSTATE *accstate);
ACSTATE *astate_get(char *name);
short avp_can_quote(short ap_id);
short avp_checkbuf(short id, short msg, char *tmsg, char *buf, short write);

/*
 * buildcmd.c
 */
short build_commandline(char *dest, size_t len, char *format, char *params, char *curdir);

/*-------------------------------------------------------------------------
 CLIP.C
 -------------------------------------------------------------------------*/
void clip_init(void);
short clip_file(char *name);
void clip_update(void);

/*-------------------------------------------------------------------------
 CONFIG.C
 -------------------------------------------------------------------------*/
short test_key(void);
short conf_save(short tmp);
short conf_load(void);
short conf_isave(void);
short conf_iload(void);
void read_sendto(void);
void free_hotkeys(void);

/*-------------------------------------------------------------------------
 CONSOLE.C
 -------------------------------------------------------------------------*/
short cwin_init(void);
void cwin_exit(void);
void cwin_attr(void);
short cwin_open(void);
void cwin_update(void);
void cwin_close(void);
void cwin_startio(void);
void cwin_endio(void);

/*-------------------------------------------------------------------------
 DESK.C
 -------------------------------------------------------------------------*/
void desk_init(void);
void desk_pat(void);
void desk_draw(short x, short y, short w, short h);
void rub_icon(short n, short *pxy);
void rub_ticon(short n, short *pxy);
void rub_frame(GRECT *sel);
void icon_free(short n);
void icon_redraw(short n);
void icon_update(short n);
void icon_select(short obj, short add, short sel);
void icon_drag(short mx, short my, short mk, short ks);
void icon_xsel(short mx, short my, short mk, short ks);
short icon_find(short mx, short my);
short icon_inrect(short n, GRECT *rect);
void icon_checksel(void);
void icn_rsrc(char *name, ICONIMG *img);
void icn_setimg(WICON *wicon, OBJECT *obj, ICONIMG *img, char *txt);
void desk_freepos(short n, short *x, short *y, short start);
short desk_icheck(THINGIMG *timg, char *name, short usepal);
short desk_iload(THINGIMG *dest, char *name, short usepal, short alert);
void desk_ifree(THINGIMG *timg);
short cdecl desk_usr(PARMBLK *parmblock);
short sel2buf(char *buf, char *aname, char *apath, short maxlen);
short drag_scroll(short my, short w, short h, short moved, WININFO *win, short n, short *pxy, void(* rubbox)(short, short *));

/*-------------------------------------------------------------------------
 DIALOG.C
 -------------------------------------------------------------------------*/
void dl_ddrag(ICONDESK *icon, short ks);
void dl_wdrag_d(FORMINFO *fi, short obj, char *name, short ks);
void dl_wdrag(WININFO *win, WP_ENTRY *item, WG_ENTRY *gitem, WG_ENTRY *gprev, short mx, short my, short ks);
void dl_awdrag(ACWIN *accwin, short whandle, short mx, short my, short ks);
short dl_ddriveinfo(ICONDESK *icon, short donext);
short dl_dtrashinfo(ICONDESK *icon, short donext);
short dl_dclipinfo(ICONDESK *icon, short donext);
short dl_dappinfo(APPLINFO *appl, short del);
void de_dappinfo(short mode, short ret);
short dl_prtinfo(ICONDESK *icon, short donext);
short dl_devinfo(ICONDESK *icon, short donext);
short dl_fileinfo(char *path, short usepar, FILESYS *filesys, WP_ENTRY *item, ICONDESK *icon, short donext);
void dl_groupinfo(WININFO *win);
short dl_giteminfo(WININFO *win, WG_ENTRY *item, short donext);
short dl_copy(char *path, short ks, char *buf);
short dl_devout(char *file, char *dev);
short dl_waitevent(void);
short dl_drag_on_gitem(W_GRP *wgrp, WG_ENTRY *gitem, short ks, short *rex);
short dl_drag_on_ditem(W_PATH *wpath, WP_ENTRY *item, short ks, short *rex);

/*-------------------------------------------------------------------------
 DLMENU.C
 -------------------------------------------------------------------------*/
void di_about(void);
void de_about(short mode, short ret);
void di_ainfo1(void);
void de_ainfo1(short mode, short ret);
void di_new(void);
void de_new(short mode, short ret);
void de_font(short mode, short ret);
short cdecl dl_font_usr(PARMBLK *parmblock);
void dl_font(short *msg);
void di_config(void);
void de_config(short mode, short ret);
void dl_saveconf(void);
void dl_loadconf(void);
short dl_drives(short draw, short _auto, short showall);
void di_rez(void);
void de_rez(short mode, short ret);
void dl_itext(short text);
void dl_isort(short sort);
void dl_ishow(short show);
void di_mask(void);
void de_mask(short mode, short ret);
short dl_open_p(char *path, char *rname, short rel, char *mask, short ks);
void dl_open(short new);
short dl_show(short mode, char *buf);
void dl_info(void);
void dl_selall(short sel);
short dl_delete(char *buf);
void dl_find(void);
void dl_eject(void);
void job_format(void);
void di_format(void);
void de_format(short mode, short ret);
void de_wait(short mode, short ret);
void dl_nextwin(void);
void dl_closewin(void);
void dl_closeallwin(void);
void dl_copywin(void);
void dl_cutwin(void);
void dl_pastewin(void);
void dl_dupwin(void);
void dl_config(void);
void dl_cfunc(short tool);
void de_cfunc(short mode, short ret);
short dl_appl_list(void);
short dl_appl_update(short cont, APPLINFO *appl);
void di_appl(void);
void de_appl(short mode, short ret);
void dl_appl(void);
void dl_iconedit(void);
void dl_iconload(void);
void dl_conwin(void);
void dl_savegrp(void);
void dl_changeres(void);
void dl_changeres_nomagic(void);
void dl_shutdown(void);
void dl_quit(void);
void dl_saveindex(void);
void di_hotkeys(void);
void de_hotkeys(short mode, short ret);
short get_new_hotkey(HOTKEY *hotkey);
void dl_default(void);

/*-------------------------------------------------------------------------
 GEMDOS.C
 -------------------------------------------------------------------------*/
short is_app(char *name, unsigned short mode);
short is_appl(char *path);
short setdir(char *full);
#ifdef DEBUG_NOTUSED
short setdir_debug(char *file, short line, char *full);
#define set_dir(x) setdir_debug(__FILE__, __LINE__, x)
#else
#define set_dir	setdir
#endif
long get_label(short drive, char *buf, short len);

/*-------------------------------------------------------------------------
 HNDLEVNT.C
 -------------------------------------------------------------------------*/
void handle_menu(short title, short item, short ks);
void handle_win(short handle, short msg, short f1, short f2, short f3, short f4, short ks);
void handle_button(short mx, short my, short but, short ks, short br);
void handle_key(short ks, short kr);
void handle_fmsg(EVENT *mevent, FORMINFO *fi);
void handle_fontmsg(short *msg);
void handle_job(EVENT *event);
void do_job(short j_id);
void handle_dd(short *msg);
short handle_fkey_or_tool(char *what);
void handle_context(short mx, short my, WININFO *win);
void desk_popup(short mx, short my);
void parent_popup(WININFO *win, short mx, short my);
HOTKEY *get_hotkey(short key);

/*-------------------------------------------------------------------------
 MAIN.C
 -------------------------------------------------------------------------*/
short main_init(void);
void main_exit(void);
void main_loop(void);
void wind_restore(short desk_redraw);
void free_wopen(WINOPEN **wopen);

/*-------------------------------------------------------------------------
 MCODE.S
 -------------------------------------------------------------------------*/
extern short boot_drv(void);

/*-------------------------------------------------------------------------
 MENU.C
 -------------------------------------------------------------------------*/
void mn_disable(void);
void mn_check(void);
void mn_update(void);

/*-------------------------------------------------------------------------
 SYSTEM.C
 -------------------------------------------------------------------------*/
#if 0
char *get_text(char *str, char *buf, short maxlen);
#endif
void put_text(FILE *fh, char *str);
short chk_drive(short drv);
short dir_check(char *path, short *nfiles, short *nfolders, unsigned long *size,
		short *nlinks, short follow, short sub);
short wild_match1(char *mask, char *name);
short wild_match(char *mask, char *name);
short va_open(char *name);
void err_file(char *alstr, long code, char *name);
void show_help(char *ref);
void key_clr(void);
void msg_clr(void);
void prlong(unsigned long v, char *str);
void prlong11(unsigned long v, char *str);
short sys_open(char *path, char *name);
void file_header(FILE *fh, char *msg, char *name);
void title_update(short drive);
void fs_info(char *name, FILESYS *filesys);
#ifdef DEBUG_NOTUSED
void fsinfo_debug(char *file, short line, char *name, FILESYS *fs);
#define fsinfo(x, y) fsinfo_debug(__FILE__, __LINE__, x, y)
#else
#define fsinfo fs_info
#endif
void clr_drv(void);
void fsconv(char *name, FILESYS *filesys);
short setfpop(char *name);
long get_dir_entry(char *dirpath, char *buf, short len, XATTR *xattr);
void fill_xattr(char *dirpath, XATTR *xattr, _DTA *the_dta);
short get_buf_entry(char *buf, char *name, char **newpos);
short file_exists(char *fname, short follow, XATTR *xattr);
void adjust_text(short _3d, short _3dcol, short tree);
char *get_username(short uid);
char *get_groupname(short gid);
void quote(char *fname);
short has_quotes(char *buf);
short count_char(char *str, char which);
short drv_ejectable(short drv);
#if 0
short full_fselect(char *full, char *deflt, char *ext, short dironly, char *title, short freedret, short freedid, FORMINFO *fi);
#endif

/*-------------------------------------------------------------------------
 WINDESK.C
 -------------------------------------------------------------------------*/
WININFO *wpath_find(char *path);
short wpath_obfind(char *full);
void wpath_name(WININFO *win);
short wpath_parent(WININFO *win, short new, short rel);
void wpath_lfree(WININFO *win);
void wpath_tfree(WININFO *win);
void wpath_pat(void);
void wpath_tree(WININFO *win);
short wpath_update(WININFO *win);
void wpath_iupdate(WININFO *win, short dosort);
short wpath_open(char *path, char *wildcard, short rel, char *relname, short text, short num, short sortby);
void wpath_info(WININFO *win);
WP_ENTRY *wpath_efind(WININFO *win, short x, short y);
void wpath_esel1(WININFO *win, WP_ENTRY *entry, short sel, GRECT *wrect, short *rd);
void wpath_esel(WININFO *win, WP_ENTRY *entry, short add, short sel, short doinfo);
void wpath_exsel(WININFO *win, short mx, short my, short mk, short ks);
void wpath_eupdate(WP_ENTRY *item);
void wpath_edrag(short mx, short my, short mk, short ks);
void wpath_showsel(WININFO *win, short doscroll);

/*-------------------------------------------------------------------------
 WINGROUP.C
 -------------------------------------------------------------------------*/
short wgrp_open(char *name, WININFO *uwin, unsigned long wait);
WG_ENTRY *wgrp_add(W_GRP *wgrp, WG_ENTRY *gprev, short class, char *title, char *name, char *parm);
void wgrp_remove(W_GRP *wgrp, WG_ENTRY *item);
void wgrp_eupdate(W_GRP *grp, WG_ENTRY *item);
void wgrp_update(WININFO *win);
void wgrp_title(WININFO *win);
void wgrp_tfree(WININFO *win);
void wgrp_tree(WININFO *win);
void wgrp_esel1(WININFO *win, WG_ENTRY *entry, short sel, GRECT *wrect, short *rd);
void wgrp_esel(WININFO *win, WG_ENTRY *entry, short add, short sel);
void wgrp_showsel(WININFO *win, short doscroll);
WG_ENTRY *wgrp_efind(WININFO *win, short x, short y, WG_ENTRY **prev);
void wgrp_change(WININFO *win);
void wgrp_eabs(W_GRP *wgrp, WG_ENTRY *entry, char *buf);
void wgrp_edrag(short mx, short my, short mk, short ks);
void wgrp_exsel(WININFO *win, short mx, short my, short mk, short ks);

/*-------------------------------------------------------------------------
 WINDOW.C
 -------------------------------------------------------------------------*/
void w_draw(WININFO *win);
void pwin_update(struct wininfo *win);
void pwin_prepare(struct wininfo *win);
void pwin_redraw(struct wininfo *win, GRECT *area);
void pwin_slide(struct wininfo *win, short mode, short h, short v);
void gwin_update(struct wininfo *win);
void gwin_prepare(struct wininfo *win);
void gwin_redraw(struct wininfo *win, GRECT *area);
void gwin_slide(struct wininfo *win, short mode, short h, short v);
void wf_set(WININFO *win);
void wf_clear(void);
void wf_draw(void);
void wf_sel(short sel, short add);
void wf_move(short dir, short add);
void w_full(WININFO *win);
void wc_icon(short *pxy, short *x, short *y, short *w, short *h, short ix, short iw, short tx, short ty, short th);
void wc_text(short *pxy, short *x, short *y, short *w, short *h);

/*-------------------------------------------------------------------------
 KOBOLD.C
 -------------------------------------------------------------------------*/
short kbd_newjob(void);
short kbd_addcmd(char *cmd);
void kbd_startjob(void);

/*-------------------------------------------------------------------------
 TPROTO.C
 -------------------------------------------------------------------------*/
void tp_handle(EVENT *event);
ALICE_WIN *alw_add(char *name, short handle);
void alw_remove(ALICE_WIN *awin);
ALICE_WIN *alw_get(short handle);
void alw_draw(ALICE_WIN *awin, short x, short y, short w, short h);

/*-------------------------------------------------------------------------
 COPY.C
 -------------------------------------------------------------------------*/
DSTK *cp_add(DSTK *stk, short class, char *src, char *dst);
void cp_remove(DSTK *dstk);
short cp_getdir(DSTK *dstk);
void job_copy(void);
