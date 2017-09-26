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

/*=========================================================================
 TYPES.H

 Thing
 Prototypen
 =========================================================================*/

/*-------------------------------------------------------------------------
 APP.C
 -------------------------------------------------------------------------*/
int app_start(APPLINFO *appl, char *parm, char *apath, int *rex);
APPLINFO *app_add(void);
void app_remove(APPLINFO *appl);
APPLINFO *app_find(char *name);
APPLINFO *app_get(char *title);
APPLINFO **app_list(int *n);
void app_opensel(APPLINFO *appl);
char *app_env(APPLINFO *appl);
char *app_argv(char *cmd, char *prog, int unixpaths);
APPLINFO *app_match(int mode, char *name, int *ok);
void app_default(APPLINFO *appl);
APPLINFO *app_isdrag(char *name);
#define app_send appl_send

/*-------------------------------------------------------------------------
 AVSERVER.C
 -------------------------------------------------------------------------*/
int av_init(void);
void av_exit(void);
void avs_protokoll(int *msgbuf);
void avs_getstatus(int *msgbuf);
void avs_status(int *msgbuf);
void avs_sendkey(int *msgbuf);
void avs_askfilefont(int *msgbuf);
void avs_askconfont(int *msgbuf);
void avs_openwind(int *msgbuf);
void avs_startprog(int *msgbuf);
void avs_accwindopen(int *msgbuf);
void avs_accwindclosed(int *msgbuf);
void avs_path_update(int *msgbuf);
void avs_copy_dragged(int *msgbuf);
void avs_what_izit(int *msgbuf);
void avs_drag_on_window(int *msgbuf);
void avs_exit(int *msgbuf);
void avs_xwind(int *msgbuf);
void avs_vastart(int *msgbuf);
void avs_view(int *msgbuf);
void avs_fileinfo(int *msgbuf);
void avs_copyfile(int *msgbuf, int del);
AVINFO *avp_add(char *name, int id, int status);
void avp_remove(AVINFO *avinfo);
AVINFO *avp_get(int id);
void avp_exit(int id);
int avp_check(int id);
ACWIN *acwin_add(int id, int handle);
void acwin_remove(ACWIN *accwin);
ACWIN *acwin_find(int handle);
ACSTATE *astate_add(char *name, char *state);
void astate_remove(ACSTATE *accstate);
ACSTATE *astate_get(char *name);
int avp_can_quote(int ap_id);
int avp_checkbuf(int id, int msg, char *tmsg, char *buf, int write);

/*
 * buildcmd.c
 */
int build_commandline(char *dest, size_t len, char *format, char *params, char *curdir);

/*-------------------------------------------------------------------------
 CLIP.C
 -------------------------------------------------------------------------*/
void clip_init(void);
int clip_file(char *name);
void clip_update(void);

/*-------------------------------------------------------------------------
 CONFIG.C
 -------------------------------------------------------------------------*/
int test_key(void);
int conf_save(int tmp);
int conf_load(void);
int conf_isave(void);
int conf_iload(void);
void read_sendto(void);
void free_hotkeys(void);

/*-------------------------------------------------------------------------
 CONSOLE.C
 -------------------------------------------------------------------------*/
int cwin_init(void);
void cwin_exit(void);
void cwin_attr(void);
int cwin_open(void);
void cwin_update(void);
void cwin_close(void);
void cwin_startio(void);
void cwin_endio(void);

/*-------------------------------------------------------------------------
 DESK.C
 -------------------------------------------------------------------------*/
void desk_init(void);
void desk_pat(void);
void desk_draw(int x, int y, int w, int h);
void rub_icon(int n, int *pxy);
void rub_ticon(int n, int *pxy);
void rub_frame(RECT *sel);
void icon_free(int n);
void icon_redraw(int n);
void icon_update(int n);
void icon_select(int obj, int add, int sel);
void icon_drag(int mx, int my, int mk, int ks);
void icon_xsel(int mx, int my, int mk, int ks);
int icon_find(int mx, int my);
int icon_inrect(int n, RECT *rect);
void icon_checksel(void);
void icn_rsrc(char *name, ICONIMG *img);
void icn_setimg(WICON *wicon, OBJECT *obj, ICONIMG *img, char *txt);
void desk_freepos(int n, int *x, int *y, int start);
int desk_icheck(THINGIMG *timg, char *name, int usepal);
int desk_iload(THINGIMG *dest, char *name, int usepal, int alert);
void desk_ifree(THINGIMG *timg);
int cdecl desk_usr(PARMBLK *parmblock);
int sel2buf(char *buf, char *aname, char *apath, int maxlen);
int drag_scroll(int my, int w, int h, int moved, WININFO *win, int n, int *pxy, void(* rubbox)(int, int *));

/*-------------------------------------------------------------------------
 DIALOG.C
 -------------------------------------------------------------------------*/
void dl_ddrag(ICONDESK *icon, int ks);
void dl_wdrag_d(FORMINFO *fi, int obj, char *name, int ks);
void dl_wdrag(WININFO *win, WP_ENTRY *item, WG_ENTRY *gitem, WG_ENTRY *gprev, int mx, int my, int ks);
void dl_awdrag(ACWIN *accwin, int whandle, int mx, int my, int ks);
int dl_ddriveinfo(ICONDESK *icon, int donext);
int dl_dtrashinfo(ICONDESK *icon, int donext);
int dl_dclipinfo(ICONDESK *icon, int donext);
int dl_dappinfo(APPLINFO *appl, int del);
void de_dappinfo(int mode, int ret);
int dl_prtinfo(ICONDESK *icon, int donext);
int dl_devinfo(ICONDESK *icon, int donext);
int dl_fileinfo(char *path, int usepar, FILESYS *filesys, WP_ENTRY *item, ICONDESK *icon, int donext);
void dl_groupinfo(WININFO *win);
int dl_giteminfo(WININFO *win, WG_ENTRY *item, int donext);
int dl_copy(char *path, int ks, char *buf);
int dl_devout(char *file, char *dev);
int dl_waitevent(void);
int dl_drag_on_gitem(W_GRP *wgrp, WG_ENTRY *gitem, int ks, int *rex);
int dl_drag_on_ditem(W_PATH *wpath, WP_ENTRY *item, int ks, int *rex);

/*-------------------------------------------------------------------------
 DLMENU.C
 -------------------------------------------------------------------------*/
void di_about(void);
void de_about(int mode, int ret);
void di_ainfo1(void);
void de_ainfo1(int mode, int ret);
void di_new(void);
void de_new(int mode, int ret);
void de_font(int mode, int ret);
int cdecl dl_font_usr(PARMBLK *parmblock);
void dl_font(int *msg);
void di_config(void);
void de_config(int mode, int ret);
void dl_saveconf(void);
void dl_loadconf(void);
int dl_drives(int draw, int _auto, int showall);
void di_rez(void);
void de_rez(int mode, int ret);
void dl_itext(int text);
void dl_isort(int sort);
void dl_ishow(int show);
void di_mask(void);
void de_mask(int mode, int ret);
int dl_open_p(char *path, char *rname, int rel, char *mask, int ks);
void dl_open(int new);
int dl_show(int mode, char *buf);
void dl_info(void);
void dl_selall(int sel);
int dl_delete(char *buf);
void dl_find(void);
void dl_eject(void);
void job_format(void);
void di_format(void);
void de_format(int mode, int ret);
void de_wait(int mode, int ret);
void dl_nextwin(void);
void dl_closewin(void);
void dl_closeallwin(void);
void dl_copywin(void);
void dl_cutwin(void);
void dl_pastewin(void);
void dl_dupwin(void);
void dl_config(void);
void dl_cfunc(int tool);
void de_cfunc(int mode, int ret);
int dl_appl_list(void);
int dl_appl_update(int cont, APPLINFO *appl);
void di_appl(void);
void de_appl(int mode, int ret);
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
void de_hotkeys(int mode, int ret);
int get_new_hotkey(HOTKEY *hotkey);
void dl_default(void);

/*-------------------------------------------------------------------------
 GEMDOS.C
 -------------------------------------------------------------------------*/
void full2comp(char *full, char *path, char *file);
void comp2full(char *full, char *path, char *file);
int valid_path(char *path);
int valid_mask(char *mask, int wild);
int valid_ext(char *ext);
int is_app(char *name, unsigned int mode);
int is_appl(char *path);
int setdir(char *full);
#ifdef DEBUG_NOTUSED
int setdir_debug(char *file, int line, char *full);
#define set_dir(x) setdir_debug(__FILE__, __LINE__, x)
#else
#define set_dir	setdir
#endif
long get_label(int drive, char *buf, int len);

/*-------------------------------------------------------------------------
 HNDLEVNT.C
 -------------------------------------------------------------------------*/
void handle_menu(int title, int item, int ks);
void handle_win(int handle, int msg, int f1, int f2, int f3, int f4, int ks);
void handle_button(int mx, int my, int but, int ks, int br);
void handle_key(int ks, int kr);
void handle_fmsg(EVENT *mevent, FORMINFO *fi);
void handle_fontmsg(int *msg);
void handle_job(EVENT *event);
void do_job(int j_id);
void handle_dd(int *msg);
int handle_fkey_or_tool(char *what);
void handle_context(int mx, int my, WININFO *win);
void desk_popup(int mx, int my);
void parent_popup(WININFO *win, int mx, int my);
HOTKEY *get_hotkey(int key);

/*-------------------------------------------------------------------------
 MAIN.C
 -------------------------------------------------------------------------*/
int main_init(void);
void main_exit(void);
void main_loop(void);
void main_debug(char *txt);
void wind_restore(int desk_redraw);
void free_wopen(WINOPEN **wopen);

/*-------------------------------------------------------------------------
 MCODE.S
 -------------------------------------------------------------------------*/
extern void long2int(long lword, int *iword1, int *iword2);
extern long int2long(int *iword1, int *iword2);
extern int boot_drv(void);

/*-------------------------------------------------------------------------
 MENU.C
 -------------------------------------------------------------------------*/
void mn_disable(void);
void mn_check(void);
void mn_update(void);

/*-------------------------------------------------------------------------
 SYSTEM.C
 -------------------------------------------------------------------------*/
char *get_text(char *str, char *buf, int maxlen);
void put_text(FILE *fh, char *str);
int chk_drive(int drv);
int dir_check(char *path, int *nfiles, int *nfolders, unsigned long *size,
		int *nlinks, int follow, int sub);
int wild_match1(char *mask, char *name);
int wild_match(char *mask, char *name);
int abs2rel(int rel, int abs, int value);
int va_open(char *name);
void err_file(char *alstr, long code, char *name);
void show_help(char *ref);
void key_clr(void);
void msg_clr(void);
void prlong(unsigned long v, char *str);
void prlong11(unsigned long v, char *str);
int sys_open(char *path, char *name);
void file_header(FILE *fh, char *msg, char *name);
void title_update(int drive);
void fs_info(char *name, FILESYS *filesys);
#ifdef DEBUG_NOTUSED
void fsinfo_debug(char *file, int line, char *name, FILESYS *fs);
#define fsinfo(x, y) fsinfo_debug(__FILE__, __LINE__, x, y)
#else
#define fsinfo fs_info
#endif
void clr_drv(void);
void fsconv(char *name, FILESYS *filesys);
void str230(char *dest, char *src);
void str245(char *dest, char *src);
int setfpop(char *name);
long get_dir_entry(char *dirpath, char *buf, int len, XATTR *xattr);
void fill_xattr(char *dirpath, XATTR *xattr, DTA *the_dta);
int get_buf_entry(char *buf, char *name, char **newpos);
int file_exists(char *fname, int follow, XATTR *xattr);
void adjust_text(int _3d, int _3dcol, int tree);
char *get_username(int uid);
char *get_groupname(int gid);
void quote(char *fname);
int has_quotes(char *buf);
#ifdef DEBUG
void debug_log(int init, const char *format, ...);
#define LOG(x) debug_log x
#else
#define LOG(x)
#endif
int count_char(char *str, char which);
int drv_ejectable(int drv);
int full_fselect(char *full, char *deflt, char *ext, int dironly, char *title, int freedret, int freedid, FORMINFO *fi);

/*-------------------------------------------------------------------------
 WINDESK.C
 -------------------------------------------------------------------------*/
WININFO *wpath_find(char *path);
int wpath_obfind(char *full);
void wpath_name(WININFO *win);
int wpath_parent(WININFO *win, int new, int rel);
void wpath_lfree(WININFO *win);
void wpath_tfree(WININFO *win);
void wpath_pat(void);
void wpath_tree(WININFO *win);
int wpath_update(WININFO *win);
void wpath_iupdate(WININFO *win, int dosort);
int wpath_open(char *path, char *wildcard, int rel, char *relname, int text, int num, int sortby);
void wpath_info(WININFO *win);
WP_ENTRY *wpath_efind(WININFO *win, int x, int y);
void wpath_esel1(WININFO *win, WP_ENTRY *entry, int sel, RECT *wrect, int *rd);
void wpath_esel(WININFO *win, WP_ENTRY *entry, int add, int sel, int doinfo);
void wpath_exsel(WININFO *win, int mx, int my, int mk, int ks);
void wpath_eupdate(WP_ENTRY *item);
void wpath_edrag(int mx, int my, int mk, int ks);
void wpath_showsel(WININFO *win, int doscroll);

/*-------------------------------------------------------------------------
 WINGROUP.C
 -------------------------------------------------------------------------*/
int wgrp_open(char *name, WININFO *uwin, unsigned long wait);
WG_ENTRY *wgrp_add(W_GRP *wgrp, WG_ENTRY *gprev, int class, char *title, char *name, char *parm);
void wgrp_remove(W_GRP *wgrp, WG_ENTRY *item);
void wgrp_eupdate(W_GRP *grp, WG_ENTRY *item);
void wgrp_update(WININFO *win);
void wgrp_title(WININFO *win);
void wgrp_tfree(WININFO *win);
void wgrp_tree(WININFO *win);
void wgrp_esel1(WININFO *win, WG_ENTRY *entry, int sel, RECT *wrect, int *rd);
void wgrp_esel(WININFO *win, WG_ENTRY *entry, int add, int sel);
void wgrp_showsel(WININFO *win, int doscroll);
WG_ENTRY *wgrp_efind(WININFO *win, int x, int y, WG_ENTRY **prev);
void wgrp_change(WININFO *win);
void wgrp_eabs(W_GRP *wgrp, WG_ENTRY *entry, char *buf);
void wgrp_edrag(int mx, int my, int mk, int ks);
void wgrp_exsel(WININFO *win, int mx, int my, int mk, int ks);

/*-------------------------------------------------------------------------
 WINDOW.C
 -------------------------------------------------------------------------*/
void w_draw(WININFO *win);
void pwin_update(struct wininfo *win);
void pwin_prepare(struct wininfo *win);
void pwin_redraw(struct wininfo *win, RECT *area);
void pwin_slide(struct wininfo *win, int mode, int h, int v);
void gwin_update(struct wininfo *win);
void gwin_prepare(struct wininfo *win);
void gwin_redraw(struct wininfo *win, RECT *area);
void gwin_slide(struct wininfo *win, int mode, int h, int v);
void wf_set(WININFO *win);
void wf_clear(void);
void wf_draw(void);
void wf_sel(int sel, int add);
void wf_move(int dir, int add);
void w_full(WININFO *win);
void wc_icon(int *pxy, int *x, int *y, int *w, int *h, int ix, int iw, int tx, int ty, int th);
void wc_text(int *pxy, int *x, int *y, int *w, int *h);

/*-------------------------------------------------------------------------
 KOBOLD.C
 -------------------------------------------------------------------------*/
int kbd_newjob(void);
int kbd_addcmd(char *cmd);
void kbd_startjob(void);

/*-------------------------------------------------------------------------
 TPROTO.C
 -------------------------------------------------------------------------*/
void tp_handle(EVENT *event);
ALICE_WIN *alw_add(char *name, int handle);
void alw_remove(ALICE_WIN *awin);
ALICE_WIN *alw_get(int handle);
void alw_draw(ALICE_WIN *awin, int x, int y, int w, int h);

/*-------------------------------------------------------------------------
 COPY.C
 -------------------------------------------------------------------------*/
DSTK *cp_add(DSTK *stk, int class, char *src, char *dst);
void cp_remove(DSTK *dstk);
int cp_getdir(DSTK *dstk);
void job_copy(void);
