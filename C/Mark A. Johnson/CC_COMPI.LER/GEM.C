/* 
 * the GEM library
 * contains both AES and VDI stuff, though not all of it
 */

extern int	ct0, ct1, ct2, ct3, ct4, ct5, ct6;
extern int	ii0, ii1, ii2, ii3, ii4, ii5, ii6, ii7, ii8, ii9,
		ii10, ii11, ii12, ii13, ii14, ii15;
extern int	io0, io1, io2, io3, io4, io5, io6, iox[40];
extern int	pi0, pi1, pi2, pi3, pi4, pi5, pi6, pi7, pix[6];
extern int	po0, po1, po2, po3, pox[12];
extern int 	*ai0, *ai1;
extern int	*ao0;
extern int	*aes0, *aes1, *aes2, *aes3, *aes4, *aes5;
extern int	*vdi0, *vdi1, *vdi2, *vdi3, *vdi4, *vdi5;
extern int	global[16];

/* 
 * the c runtime start up routine for GEM processes
 * no argv argc stuff, no stdio (use TOS routines for file access)
 *
 * assumes a startup prg.s of
 *	. _bstk 2048
 *	. _estk 4
 *	taa 7 6
 *	lll 4 0
 *	sgl _estk
 *	lag _estk 7
 *	jsr _cprg
 * plus definitions for all the above externs
 */

#define SETBLK	0x4A
#define EXIT	0x4C

_cprg(tpa) long tpa; {
	int i;
	long x, *lp;

	/* compute size of program, give memory back to TOS */
	lp = tpa;
	x = lp[3] + lp[5] + lp[7] + 0x100;
	if (trap(1, SETBLK, 0, tpa, x))
		appl_exit(-1);

	/* set up the aespb and vdipb arrays */
	aes0 = &ct0;
	aes1 = global;
	aes2 = &ii0;
	aes3 = &io0;
	aes4 = &ai0;
	aes5 = &ao0;
	vdi0 = &ct0;
	vdi1 = &ii0;
	vdi2 = &pi0;
	vdi3 = &io0;
	vdi4 = &po0;
	
	/* run the program */
	i = main();

	/* close up shop */
	appl_exit(i);
}

/* GEM application init */

appl_init() {
	ct0 = 10;
	ct2 = 1;
	ct1 = ct3 = ct4 = 0;
	aes();
	return io0;
}

appl_exit(i) { trap(1, EXIT, i); }

/* VDI routines for the GEM library */


/* 
 * GEM:VDI open virtual workstation 
 * 	"in" should point to work_in[11]
 * 	"out" should point to work_out[57];
 * 	"handle" is both input and output
 */

v_opnvwk(in, handle, out) int *in, *handle, *out; {
	int i, j, *intin, *intout, *ptsout;
	ct0 = 100;
	ct1 = 0;
	ct3 = 11;
	ct6 = *handle;
	intin = &ii0;
	for (i = 0; i < 11; i++) intin[i] = in[i];
	vdi();
	intout = &io0;
	for (i = 0; i < 45; i++) out[i] = intout[i];
	ptsout = &po0;
	for (j = 0; j < 12; j++) out[i++] = ptsout[j];
	*handle = ct6;
}

vq_extnd(handle, owflag, out) int *out; {
	int i, j, *intout, *ptsout;
	ct0 = 102;
	ct1 = 0;
	ct3 = 1;
	ct6 = handle;
	ii0 = owflag;
	vdi();
	intout = &io0;
	for (i = 0; i < 45; i++) out[i] = intout[i];
	ptsout = &po0;
	for (j = 0; j < 12; j++) out[i++] = ptsout[j];
}

/* GEM:VDI close the workstation */

v_clsvwk(handle) {
	ct0 = 101;
	ct6 = handle;
	ct1 = ct3 = 0;
	vdi();
}

/* GEM:VDI clear the workstation */

v_clrwk(handle) {
	ct0 = 3;
	ct1 = 0;
	ct3 = 0;
	ct6 = handle;
	vdi();
}

/* GEM:VDI poly line output */

v_pline(handle, count, pxy) int *pxy; {
	ct0 = 6;
	ct1 = count;
	ct3 = 0;
	ct6 = handle;
	vdi2 = pxy;
	vdi();
	vdi2 = &po0;
}

/* GEM:VDI put text on the screen */

v_gtext(handle, x, y, string) char *string; {
	int n, *intin;
	ct0 = 8;
	ct1 = 1;
	intin = &ii0;
	for (n = 0; string[n]; n++)
		intin[n] = string[n];
	ct3 = n;
	ct6 = handle;
	pi0 = x;
	pi0 = y;
	vdi();
}

/* 
 * GEM:VDI set clipping rectangle 
 *	flag = 0 	no clipping
 *	flag = 1	clipping on
 * 	pxy[] should contain the upper left and bottom right coords
 */

vs_clip(handle, flag, pxy) int *pxy; {
	ct0 = 129;
	ct1 = 2;
	ct3 = 1;
	ct6 = handle;
	ii0 = flag;
	vdi2 = pxy;
	vdi();
	vdi2 = &pi0;
}

/* GEM:VDI polymarker output */

v_pmarker(handle, count, pxy) int *pxy; {
	ct0 = 7;
	ct1 = count;
	ct3 = 0;
	ct6 = handle;
	vdi2 = pxy;
	vdi();
	vdi2 = &pi0;
}

/* GEM:VDI fill area */

v_fillarea(handle, count, pxy) int *pxy; {
	ct0 = 9;
	ct1 = count;
	ct3 = 0;
	ct6 = handle;
	vdi2 = pxy;
	vdi();
	vdi2 = &pi0;
}

/* GEM:VDI contour fill */

v_contourfill(handle, x, y, index) {
	ct0 = 103;
	ct1 = 1;
	ct3 = 1;
	ct6 = handle;
	ii0 = index;
	pi0 = x;
	pi1 = y;
	vdi();
}

/* GEM:VDI rectangle fill */

vr_recfl(handle, pxy) int *pxy; {
	ct0 = 114;
	ct1 = 2;
	ct3 = 0;
	ct6 = handle;
	vdi2 = pxy;
	vdi();
	vdi2 = &pi0;
}

/* GEM:VDI bar graph */

v_bar(handle, pxy) int *pxy; {
	ct0 = 11;
	ct1 = 2;
	ct3 = 0;
	ct5 = 1;
	ct6 = handle;
	vdi2 = pxy;
	vdi();
	vdi2 = &pi0;
}

/* GEM:VDI arc */

v_arc(handle, x, y, rad, b_angle, e_angle) {
	int i, *ptsin;
	ct0 = 11;
	ct1 = 4;
	ct3 = 2;
	ct5 = 2;
	ct6 = handle;
	ii0 = b_angle;
	ii1 = e_angle;
	pi0 = x;
	pi1 = y;
	pi6 = rad;
	pi2 = pi3 = pi4 = pi5 = pi7 = 0;
	vdi();
}

/* GEM:VDI pie */

v_pieslice(handle, x, y, rad, b_angle, e_angle) {
	int i;
	ct0 = 11;
	ct1 = 4;
	ct3 = 2;
	ct5 = 3;
	ct6 = handle;
	ii0 = b_angle;
	ii1 = e_angle;
	pi0 = x;
	pi1 = y;
	pi6 = rad;
	pi2 = pi3 = pi4 = pi5 = pi7 = 0;
	vdi();
}

/* GEM:VDI circle */

v_circle(handle, x, y, rad) {
	int i;
	ct0 = 11;
	ct1 = 3;
	ct3 = 0;
	ct5 = 4;
	ct6 = handle;
	pi0 = x;
	pi1 = y;
	pi4 = rad;
	pi2 = pi3 = pi5 = 0;
	vdi();
}

/* GEM:VDI elliptical arc */

v_ellarc(handle, x, y, xrad, yrad, b_angle, e_angle) {
	int i;
	ct0 = 11;
	ct1 = 2;
	ct3 = 2;
	ct5 = 6;
	ct6 = handle;
	ii0 = b_angle;
	ii1 = e_angle;
	pi0 = x;
	pi1 = y;
	pi2 = xrad;
	pi3 = yrad;
	vdi();
}

/* GEM:VDI elliptical pie */

v_ellpie(handle, x, y, xrad, yrad, b_angle, e_angle) {
	int i;
	ct0 = 11;
	ct1 = 2;
	ct3 = 2;
	ct5 = 7;
	ct6 = handle;
	ii0 = b_angle;
	ii1 = e_angle;
	pi0 = x;
	pi1 = y;
	pi2 = xrad;
	pi3 = yrad;
	vdi();
}

/* GEM:VDI ellipse */

v_ellipse(handle, x, y, xrad, yrad) {
	ct0 = 11;
	ct1 = 2;
	ct3 = 0;
	ct5 = 5;
	ct6 = handle;
	pi0 = x;
	pi1 = y;
	pi2 = xrad;
	pi3 = yrad;
	vdi();
}

/* GEM:VDI rounded box */

v_rbox(handle, pxy) int *pxy; {
	ct0 = 11;
	ct1 = 2;
	ct3 = 0;
	ct5 = 8;
	ct6 = handle;
	vdi2 = pxy;
	vdi();
	vdi2 = &pi0;
}

/* GEM:VDI rounded filled box */

v_rfbox(handle, pxy) int *pxy; {
	ct0 = 11;
	ct1 = 2;
	ct3 = 0;
	ct5 = 9;
	ct6 = handle;
	vdi2 = pxy;
	vdi();
	vdi2 = &pi0;
}

/* GEM:VDI put justified text on the screen */

v_justified(handle, x, y, string, len, wspace, cspace) char *string; {
	int *ip;
	ct0 = 11;
	ct1 = 2;
	ct6 = handle;
	ii0 = wspace;
	ii1 = cspace;
	ip = &ii2;
	for (ct3 = 2; *ip++ = *string++; ct3++)
		;
	pi0 = x;
	pi1 = y;
	pi2 = len;
	vdi();
}

/* GEM:VDI set drawing mode */

vswr_mode(handle, mode) { return vset(handle, 32, mode); }

/* GEM:VDI set color */

vs_color(handle, index, rgb) int *rgb; {
	ct0 = 14;
	ct1 = 0;
	ct3 = 4;
	ct6 = handle;
	ii0 = index;
	ii1 = rgb[0];
	ii2 = rgb[1];
	ii3 = rgb[2];
	vdi();
}

/* GEM:VDI set line color */

vsl_color(handle, color) { return vset(handle, 17, color); }

/* GEM:VDI set line type */

vsl_type(handle, type) { return vset(handle, 15, type); }

/* GEM:VDI set marker type */

vsm_type(handle, type) { return vset(handle, 18, type); }

/* GEM:VDI set marker height */

vsm_height(handle, height) {
	ct0 = 19;
	ct1 = 1;
	ct3 = 0;
	ct6 = handle;
	pi0 = 0;
	pi1 = height;
	vdi();
	return po1;
}

/* GEM:VDI set user defined line type */

vsl_udsty(handle, pattern) { return vset(handle, 113, pattern); }

/* GEM:VDI set the width of a line */

vsl_width(handle, width) { 
	ct0 = 16;
	ct1 = 1;
	ct3 = 0;
	ct6 = handle;
	pi0 = width;
	pi1 = 0;
	vdi();
	return po0;
}

/* GEM:VDI line end style  */

vsl_ends(handle, begin, end) {
	ct0 = 108;
	ct1 = 0;
	ct2 = 2;
	ct6 = handle;
	ii0 = begin;
	ii1 = end;
	vdi();
}

/* GEM:VDI set marker color */

vsm_color(handle, color) { return vset(handle, 20, color); }

/* GEM:VDI set text height, returns char size and cell(box) size  */

vst_height(handle, h, cw, ch, bw, bh) int *cw, *ch, *bw, *bh; {
	ct0 = 12;
	ct1 = 1;
	ct3 = 0;
	ct6 = handle;
	pi0 = 0;
	pi1 = h;
	vdi();
	*cw = po0;
	*ch = po1;
	*bw = po2;
	*bh = po3;
}

/* GEM:VDI set text height, returns char size and cell(box) size  */

vst_point(handle, point, cw, ch, bw, bh) int *cw, *ch, *bw, *bh; {
	ct0 = 107;
	ct1 = 0;
	ct3 = 1;
	ct6 = handle;
	ii0 = point;
	vdi();
	*cw = po0;
	*ch = po1;
	*bw = po2;
	*bh = po3;
}

/* GEM:VDI set text baseline rotation */

vst_rotation(handle, angle) { return vset(handle, 13, angle); }

/* GEM:VDI set color of the text */

vst_color(handle, color) { return vset(handle, 22, color); }

/* 
 * GEM:VDI set effects of the text 
 *	bit 0	bold
 *	bit 1	light
 *	bit 2	italic
 *	bit 3	underline
 *	bit 4	outline
 *	bit 5	shadowed
 */
 

vst_effects(handle, effect) { return vset(handle, 106, effect); }

/* GEM:VDI set text alignment  */

vst_alignment(handle, hor, ver, nhor, nver) int *nhor, *nver; {
	ct0 = 39;
	ct1 = 0;
	ct3 = 2;
	ct6 = handle;
	ii0 = hor;
	ii0 = ver;
	vdi();
	*nhor = io0;
	*nver = io1;
}

/* GEM:VDI set fill interior */

vsf_interior(handle, style) { return vset(handle, 23, style); }

/* GEM:VDI set fill style index  */

vsf_style(handle, style) { return vset(handle, 24, style); }

/* GEM:VDI set fill color index */

vsf_color(handle, color) { return vset(handle, 25, color); }

/* GEM:VDI set perimeter visibility */

vsf_perimeter(handle, visible) { return vset(handle, 105, visible); }

/* GEM:VDI set user defined fill pattern */

vsf_updat(handle, pat, count) int *pat; {
	ct0 = 112;
	ct1 = 0;
	ct3 = count * 16;
	ct6 = handle;
	vdi1 = pat;
	vdi();
	vdi1 = &ii0;
}

/* GEM:VDI set an attribute */

vset(handle, op, arg) {
	ct0 = op;
	ct1 = 0;
	ct3 = 1;
	ct6 = handle;
	ii0 = arg;
	vdi();
	return io0;
}

/* AES: resource handling */

rsrc_gaddr(type, index, addr) long **addr; {
	ct0 = 112;
	ct1 = 2;
	ct2 = ct4 = 1;
	ct3 = 0;
	ii0 = type;
	ii1 = index;
	aes();
	*addr = ao0;
	return io0;
}

rsrc_saddr(type, index, addr) long *addr; {
	ct0 = 113;
	ct1 = 2;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = type;
	ii1 = index;
	ai0 = addr;
	aes();
	return io0;
}

/* graphics handling */

graf_handle(wchar, hchar, wbox, hbox) int *wchar, *hchar, *wbox, *hbox; {
	ct0 = 77;
	ct2 = 5;
	ct1 = ct3 = ct4 = 0;
	aes();
	*wchar = io1;
	*hchar = io2;
	*wbox = io3;
	*hbox = io4;
	return io0;
}

graf_rubberbox(x, y, minw, minh, lastw, lasth) int *lastw, *lasth; { 
	ct0 = 70;
	ct1 = 4;
	ct2 = 3;
	ct3 = ct4 = 0;
	ii0 = x;
	ii1 = y;
	ii2 = minw;
	ii3 = minh;
	aes();
	*lastw = io1;
	*lasth = io2;
	return io0;
}

graf_dragbox(dw, dh, sx, sy, bx, by, bw, bh, endx, endy) int *endx, *endy; {
	ct0 = 71;
	ct1 = 8;
	ct2 = 3;
	ct3 = ct4 = 0;
	ii0 = dw;
	ii1 = dh;
	ii2 = sx;
	ii3 = sy;
	ii4 = bx;
	ii5 = by;
	ii6 = bw;
	ii7 = bh;
	aes();
	*endx = io1;
	*endy = io2;
	return io0;
}

graf_movebox(w, h, sx, sy, dx, dy) {
	ct0 = 72;
	ct1 = 6;
	ct2 = 1;
	ct3 = ct4 = 0;
	ii0 = w;
	ii1 = h;
	ii2 = sx;
	ii3 = sy;
	ii4 = dx;
	ii5 = dy;
	aes();
	return io0;
}

graf_growbox(bx, by, bw, bh, ex, ey, ew, eh) {
	ct0 = 73;
	ct1 = 8;
	ct2 = 1;
	ct3 = ct4 = 0;
	aes2 = &bx;
	aes();
	aes2 = &ii0;
	return io0;
}
	
graf_shrinkbox(ex, ey, ew, eh, bx, by, bw, bh) {
	ct0 = 73;
	ct1 = 8;
	ct2 = 1;
	ct3 = ct4 = 0;
	aes2 = &ex;
	aes();
	aes2 = &ii0;
	return io0;
}

graf_watchbox(tree, obj, instate, outstate) int *tree; { 
	ct0 = 75;
	ct1 = 4;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii1 = obj;
	ii2 = instate;
	ii3 = outstate;
	ai0 = tree;
	aes();
	return io0;
}

graf_slidebox(tree, parent, obj, vh) int *tree; { 
	ct0 = 76;
	ct1 = 3;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = parent;
	ii1 = obj;
	ii2 = vh;
	ai0 = tree;
	aes();
	return io0;
}

graf_mouse(type, shape) int *shape; { 
	ct0 = 78;
	ct1 = ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = type;
	ai0 = shape;
	aes();
	return io0;
}

graf_mkstate(x, y, mstate, kstate) int *x, *y, *mstate, *kstate; { 
	ct0 = 79;
	ct1 = ct3 = ct4 = 0;
	ct2 = 5;
	aes();
	*x = io1;
	*y = io2;
	*mstate = io3;
	*kstate = io4;
	return io0;
}

/* window handling */

wind_get(handle, gfld, gw1, gw2, gw3, gw4) int *gw1, *gw2, *gw3, *gw4; {
	ct0 = 104;
	ct1 = 2;
	ct2 = 5;
	ct3 = ct4 = 0;
	ii0 = handle;
	ii1 = gfld;
	aes();
	*gw1 = io1;
	*gw2 = io2;
	*gw3 = io3;
	*gw4 = io4;
	return io0;
}

wind_create(kind, x, y, w, h) {
	ct0 = 100;
	ct1 = 5;
	ct2 = 1;
	ct3 = ct4 = 0;
	ii0 = kind;
	ii1 = x;
	ii2 = y;
	ii3 = w;
	ii4 = h;
	aes();
	return io0;
}

wind_set(handle, field, s1, s2, s3, s4) {
	ct0 = 105;
	ct1 = 6;
	ct2 = 1;
	ct3 = ct4 = 0;
	ii0 = handle;
	ii1 = field;
	ii2 = s1;
	ii3 = s2;
	ii4 = s3;
	ii5 = s4;
	aes();
	return io0;
}

wind_open(handle, x, y, w, h) {
	ct0 = 101;
	ct1 = ct2 = 5;
	ct3 = ct4 = 0;
	ii0 = handle;
	ii1 = x;
	ii2 = y;
	ii3 = w;
	ii4 = h;
	aes();
	return io0;
}

wind_close(handle) { 
	ct0 = 102;
	ct1 = ct2 = 1;
	ct3 = ct4 = 0;
	ii0 = handle;
	aes();
	return io0;
}

wind_delete(handle) {
	ct0 = 103;
	ct1 = ct2 = 1;
	ct3 = ct4 = 0;
	ii0 = handle;
	aes();
	return io0;
}

wind_find(x, y) {
	ct0 = 106;
	ct1 = 2;
	ct2 = 1;
	ct3 = ct4 = 0;
	ii0 = x;
	ii1 = y;
	aes();
	return io0;
}

wind_update(n) {
	ct0 = 107;
	ct1 = ct2 = 1;
	ct3 = ct4 = 0;
	ii0 = n;
	aes();
	return io0;
}

wind_calc(
    type, kind, xi, yi, wi, hi, 
    xo, yo, wo, ho) int *xo, *yo, *wo, *ho; {
	ct0 = 108;
	ct1 = 6;
	ct2 = 5;
	ct3 = ct4 = 0;
	ii0 = type;
	ii1 = kind;
	ii2 = xi;
	ii3 = yi;
	ii4 = wi;
	ii5 = hi;
	aes();
	*xo = io1;
	*yo = io2;
	*wo = io3;
	*ho = io4;
	return io0;
}

/* event handling */

event_multi(
  flags, clicks, mask, state, 
  af, ax, ay, aw, ah,
  bf, bx, by, bw, bh,
  buff, lo, hi,
  ox, oy, obut, ostate, okret, obret) 
	int *ox, *oy, *obut, *ostate, *okret, *obret;
{
	ct0 = 25;
	ct1 = 16;
	ct2 = 7;
	ct3 = 1;
	ct4 = 0;
	ii0 = flags;
	ii1 = clicks;
	ii2 = mask;
	ii3 = state;
	ii4 = af;
	ii5 = ax;
	ii6 = ay;
	ii7 = aw;
	ii8 = ah;
	ii9 = bf;
	ii10 = bx;
	ii11 = by;
	ii12 = bw;
	ii13 = bh;
	ii14 = lo;
	ii15 = hi;
	ai0 = buff;
	aes();
	*ox = io1;
	*oy = io2;
	*obut = io3;
	*ostate = io4;
	*okret = io5;
	*obret = io6;
	return io0;
}

/* object handling */

objc_draw(tree, start, depth, xclip, yclip, wclip, hclip) int *tree; { 
	ct0 = 42;
	ct1 = 6;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = start;
	ii1 = depth;
	ii2 = xclip;
	ii3 = yclip;
	ii4 = wclip;
	ii5 = hclip;
	ai0 = tree;
	aes();
	return io0;
}

objc_find(tree, start, depth, x, y) int *tree; { 
	ct0 = 43;
	ct1 = 4;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = start;
	ii1 = depth;
	ii2 = x;
	ii3 = y;
	ai0 = tree;
	aes();
	return io0;
}

objc_offset(tree, object, xoff, yoff) int *tree, *xoff, *yoff; {
	ct0 = 43;
	ct1 = 1;
	ct2 = 3;
	ct3 = 1;
	ct4 = 0;
	ii0 = object;
	ai0 = tree;
	aes();
	*xoff = io1;
	*yoff = io2;
	return io0;
}

objc_edit(tree, object, ch, idx, kind, newidx) int *tree, *newidx; {
	ct0 = 46;
	ct1 = 4;
	ct2 = 2;
	ct3 = 1;
	ct4 = 0;
	ii0 = object;
	ii1 = ch;
	ii2 = idx;
	ii3 = kind;
	ai0 = tree;
	aes();
	*newidx = io1;
	return io0;
}

objc_change(tree, object, resvd, x, y, w, h, state, redraw) int *tree; {
	ct0 = 47;
	ct1 = 8;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = object;
	ii1 = resvd;
	ii2 = x;
	ii3 = y;
	ii4 = w;
	ii5 = h;
	ii6 = state;
	ii7 = redraw;
	ai0 = tree;
	aes();
	return io0;
}

/* menu handling */

menu_bar(tree, show) int *tree; { 
	ct0 = 30;
	ct1 = ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = show;
	ai0= tree;
	aes();
	return io0;
}

menu_icheck(tree, item, check) int *tree; {
	ct0 = 31;
	ct1 = 2;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = item;
	ii1 = check;
	ai0 = tree;
	aes();
	return io0;
}

menu_enable(tree, item, enable) int *tree; {
	ct0 = 32;
	ct1 = 2;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = item;
	ii1 = enable;
	ai0 = tree;
	aes();
	return io0;
}

menu_tnormal(tree, title, normal) int *tree; {
	ct0 = 33;
	ct1 = 2;
	ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = title;
	ii1 = normal;
	ai0 = tree;
	aes();
	return io0;
}

menu_text(tree, item, text) int *tree; char *text; {
	ct0 = 34;
	ct1 = ct2 = 1;
 	ct3 = 2;
	ct4 = 0;
	ii0 = item;
	ai0 = tree;
	ai1 = text;
	aes();
	return io0;
}

menu_register(id, string) char *string; {
	ct0 = 35;
	ct1 = ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = id;
	ai0 = string;
	aes();
	return io0;
}

/* form handling */

form_pf(fmt, args) char *fmt; int args; {
	extern char _pfb[1];
	_dopf(_pfb, fmt, &args);
	form_alert(0, _pfb);
}

form_do(tree, start) int *tree; {
	ct0 = 50;
	ct1 = ct3 = 1;
	ct2 = 2;
	ct4 = 0;
	ii0 = start;
	ai0 = tree;
	aes();
	return io0;
}

form_dial(flag, sx, sy, sw, sh, bx, by, bw, bh) {
	ct0 = 51;
	ct1 = 9;
	ct3 = ct2 = 1;
	ct4 = 0;
	ii0 = flag;
	ii1 = sx;
	ii2 = sy;
	ii3 = sw;
	ii4 = sh;
	ii5 = bx;
	ii6 = by;
	ii7 = bw;
	ii8 = bh;
	aes();
	return io0;
}

form_center(tree, x, y, w, h) int *tree, *x, *y, *w, *h; {
	ct0 = 54;
	ct1 = 0;
	ct3 = 5;
	ct2 = 1;
	ct4 = 0;
	ai0 = tree;
	aes();
	*x = io1;
	*y = io2;
	*w = io3;
	*h = io4;
	return io0;
}

form_error(num) {
	ct0 = 53;
	ct1 = ct2 = 1;
	ct3 = ct4 = 0;
	ii0 = num;
	aes();
	return io0;
}

form_alert(button, string) char *string; {
	ct0 = 52;
	ct1 = ct2 = ct3 = 1;
	ct4 = 0;
	ii0 = button;
	ai0 = string;
	aes();
	return io0;
}


/* AES and VDI support routines */

aes() {
	/* 
         * load address of aes parameter block into a0
         * transfer a0 to d1
         * load 200 into d0
         * trap #2
         */
	asm( lag aes0 0   tad 0 1   ldw 200 0   trp 2 );
}

vdi() {
	/* 
         * load address of vdi parameter block into a0
         * transfer a0 to d1
         * load 115 into d0
         * trap #2
         */
	asm( lag vdi0 0   tad 0 1   ldw 115 0   trp 2 );
}
