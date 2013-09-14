/*
 * aesbind.h -- give bindings and structures for GEM AES routines.
 *
 * Copyright (c) 1981-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

/*
 * The Rect structure describes a rectangle by its (x,y) coordinates
 * and its width and height.  This structure is called a GRECT in obdefs.h.
 */
typedef struct { int x, y, w, h; } Rect;
/*
 * The Mouse structure passes pointers to the (x,y) coordinates,
 * mouse button state, and keyboard state.
 */
typedef struct { int *x, *y, *b, *k; } Mouse;
/*
 * The Prect structure passes pointers to the x and y coordinates,
 * the width, and the height of a rectangle.
 */
typedef struct { int *x, *y, *w, *h; } Prect;
/*
 * The entries to libaes.a, including sample bindings.
 * unsigned ints have been redeclared as ints.
 */
/* int appl_exit(); */
	int appl_exit();
/* int appl_find(p) long p; */
	int appl_find();
/* int appl_init(); */
	int appl_init();
/* int appl_read(r, l, p) int r, l; long p; */
	int appl_read();
/* int appl_tplay(b, l, s) long b; int l, s; */
	int appl_tplay();
/* int appl_trecord(b, l) long b; int l; */
	int appl_trecord();
/* int appl_write(w, l, p) int w, l; long p; */
	int appl_write();
/* int crys_if(o) int o; */
	int crys_if();
/* int evnt_button(c, m, s, p) int c, m, s; Mouse p; */
	int evnt_button();
/* int evnt_dclick(r, s) int r, s; */
	int evnt_dclick();
/* int evnt_keybd(); */
	int evnt_keybd();
/* int evnt_mesag(p) long p; */
	int evnt_mesag();
/* int evnt_mouse(f, r, m) int f; Rect r; Mouse m; */
	int evnt_mouse();
/* int evnt_multi(f, c, k, b, m1, r1, m2, r2, p, tlc, thc, m, pkr, pbr)
 * int f, c, k, b, m1; Rect r1; int m2; Rect r2;
 * long p; int tlc, thc; Mouse m; int *pkr, *pbr;
 */
	int evnt_multi();
/* int evnt_timer(l, h) int l, h; */
	int evnt_timer();
/* int form_alert(d, a) int d; long a; */
	int form_alert();
/* int form_center(t, c) long t; Prect c; */
	int form_center();
/* int form_dial(d, i, r) int d; Rect i, r; */
	int form_dial();
/* int form_do(f, s) long f; int s; */
	int form_do();
/* int form_error(e) int e; */
	int form_error();
/* int fsel_input(p, s, b) char *p, *s; int *b; */
	int fsel_input();
/* int graf_dragbox(w, h, sx, sy, bound, fx, fy);
 * int w, h, sx, sy; Rect bound; int *fx, *fy
 */
	int graf_dragbox();
/* int graf_growbox(o, r) Rect o, r; */
	int graf_growbox();
/* int graf_handle(wc, hc, wb, hb) int *wc, *hc, *wb, *hb; */
	int graf_handle();
/* int graf_mbox(w, h, sx, sy, dx, dy) int w, h, sx, sy, dx, dy; */
	int graf_mbox();
/* int graf_mkstate(m) Mouse m; */
	int graf_mkstate();
/* int graf_mouse(n, p) int n; long p; */
	int graf_mouse();
/* int graf_rubbox(r, w, h) Rect r; int *w, *h; */
	int graf_rubbox();
/* int graf_shrinkbox(o, r) Rect o, r; */
	int graf_shrinkbox();
/* int graf_slidebox(t, p, o, v) long t; int p, o, v; */
	int graf_slidebox();
/* int graf_watchbox(t, o, in, out) long t; int o, in, out; */
	int graf_watchbox();
/* int menu_text(t, i, p) long t; int i; long p; */
	int menu_text();
/* int menu_bar(t, s) long t; int s; */
	int menu_bar();
/* int menu_icheck(t, i, c) long t; int i, c; */
	int menu_icheck();
/* int menu_ienable(t, i, e) long t; int i, e; */
	int menu_ienable();
/* int menu_register(i, p) int i; long p; */
	int menu_register();
/* int menu_tnormal(t, i, n) long t; int i, n; */
	int menu_tnormal();
/* int objc_add(t, p, c) long t; int p, c; */
	int objc_add();
/* int objc_change(t, o, d, c, n, r) long t; int o, d; Rect c; int n, r; */
	int objc_change();
/* int objc_delete(t, d) long t; int d; */
	int objc_delete();
/* int objc_draw(t, o, d, c) long t; int o, d; Rect c; */
	int objc_draw();
/* int objc_edit(t, o, i, x, k) long t; int o, i, *x, k; */
	int objc_edit();
/* int objc_find(t, s, d, x, y) long t; int s, d, x, y; */
	int objc_find();
/* int objc_order(t, m, n) long t; int m, n; */
	int objc_order();
/* int objc_offset(t, o, x, y) long t; int o, *x, *y; */
	int objc_offset();
/* int rc_copy(s, d) Rect *s, *d; */
	int rc_copy();
/* int rc_equal(s, d) Rect *s, *d; */
	int rc_equal();
/* int rc_intersect(s, d) Rect *s, *d; */
	int rc_intersect();
/* int rc_union(s, d) Rect *s, *d; */
	int rc_union();
/* int rsrc_free(); */
	int rsrc_free();
/* int rsrc_gaddr(t, i, p) int t, i; long *p; */
	int rsrc_gaddr();
/* int rsrc_load(r) long r; */
	int rsrc_load();
/* int rsrc_obfix(t, o) long t; int o; */
	int rsrc_obfix();
/* int rsrc_saddr(t, i, v) int t, i; long v; */
	int rsrc_saddr();
/* int scrp_read(p) long p; */
	int scrp_read();
/* int scrp_write(p) long p; */
	int scrp_write();
/* int shel_envrn(p, s) long p, s; */
	int shel_envrn();
/* int shel_find(p) long p; */
	int shel_find();
/* int shel_read(c, t) long c, t; */
	int shel_read();
/* int shel_write(x, g, c, p, t) int x, g, c; long p, t; */
	int shel_write();
/* int wind_calc(t, k, r, p) int t, k; Rect r; Prect p; */
	int wind_calc();
/* int wind_close(h) int h; */
	int wind_close();
/* int wind_create(k, w) int k; Rect w; */
	int wind_create();
/* int wind_delete(h) int h; */
	int wind_delete();
/* int wind_find(x, y) int x, y; */
	int wind_find();
/* int wind_get(h, f, p1, p2, p3, p4) int h, f, *p1, *p2, *p3, *p4; */
	int wind_get();
/* int wind_open(h, w) int h; Rect w; */
	int wind_open();
/* int wind_set(h, f, w2, w3, w4, w5) int h, f, w2, w3, w4, w5; */
	int wind_set();
/* int wind_update(u) int u; */
	int wind_update();

/* End of aesbind.h */
