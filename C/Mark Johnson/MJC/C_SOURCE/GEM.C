/* 
 * the GEM library
 * contains both AES and VDI stuff, though not all of it
 */

#include "gem.h"

extern short	ct0, ct1, ct2, ct3, ct4, ct5, ct6, ct7;
extern short	ii0, ii1, ii2, ii3, ii4, ii5, ii6, ii7, ii8, ii9,
		ii10, ii11, ii12, ii13, ii14, ii15;
extern short	io0, io1, io2, io3, io4, io5, io6, iox[40];
extern short	pi0, pi1, pi2, pi3, pi4, pi5, pi6, pi7, pix[6];
extern short	po0, po1, po2, po3, pox[12];
extern short	*ai0, *ai1;
extern short	*ao0;
extern	short	*vdi0, *vdi1, *vdi2, *vdi3, *vdi4, *vdi5;
extern short	*aes0, *aes1, *aes2, *aes3, *aes4, *aes5;
extern short	global[16];

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
#define TERM	0x4C

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

	/* init standard i/o */
	_ioinit();
	
	/* run the program */
	i = main();

	/* close up shop */
	appl_exit(i);
}

#define vdc(op,pi,ii,xx,yy) ct0=op;ct1=pi;ct2=ct4=0;ct3=ii;ct5=xx;ct6=yy;vdi()


/* open virtual workstation */

v_opnvwk(in, h, out) 
struct vdi_openin *in; 
short *h; 
struct vdi_openout *out; {
	vdi0	= &ct0;
	vdi1	= in;
	vdi2	= &pi0;
	vdi3	= out;
	vdi4	= &(out->devicetyp);
	vdc(100, 0, 11, 0, 1);
	*h 	= ct6;
	vdi0	= &ct0;
	vdi1	= &ii0;
	vdi2	= &pi0;
	vdi3	= &io0;
	vdi4	= &po0;
}

/* close virtual workstation */
		
v_clsvwk(h) short h; {
	vdc(101, 0, 0, 0, h);
}

v_clrwk(h) short h; {
	vdc(3, 0, 0, 0, h);
}

/* cursor control */

v_enter_cur(h) short h; {	/* enter cursor mode - shows cursor */
	vdc(5, 0, 0, 3, h);
}

v_exit_cur(h) short h; {	/* exit cursor mode - removes cursor */
	vdc(5, 0, 0, 2, h);
}

v_rvon(h) {	 		/* reverse video on - cursor text */
	vdc(5, 0, 0, 13, h);
}

v_rvoff(h) {			/* reverse video off - cursor text */
	vdc(5, 0, 0, 14, h);
}

v_curhome(h) {			/* home cursor */
	vdc(5, 0, 0, 8, h);
}

vs_curaddress(h, r, c) {     /* put cursor on row r (0-24) and col. c (0-79) */
	ii0 = c;
	ii1 = r;
	vdc(5, 0, 2, 11, h);
}

/* screen operations */

v_eeos(h) {			/* erase from cursor to end of screen */
	vdc(5, 0, 0, 9, h);
}

/* polymarkers */
	
v_pmarker(h, count, xy)	short xy[]; { /* plot markers at xy coords. passed */
	vdi2 = xy;
	vdc(7, count, 0, 0, h);
	vdi2 = &pi0;
}

vsm_color(h, color) {	/* sets the color that marker is plotted with */
	return vdi_attr(h, 20, color); /* color: 0 - numcolors */
}

vsm_height(h, height) {	/* set the height of plotted markers (not of type 1) */
	pi0 = 0;
	pi1 = height; /* height: in pels, 1 - maxy */
	vdc(19, 1, 0, 0, h);
	return po1;
}

vsm_type(h, type) {	/* set marker type - returns type selected */
	return vdi_attr(h, 18, type); /* type: 1 - nummarktyp */
}

vqm_attributes(h, at) struct vdi_mattr *at; { /* query marker attributes */
	vdi3 = at;
	vdi4 = &(at->markwid);
	vdc(36, 0, 0, 0, h);
	vdi3 = &io0;
	vdi4 = &po0;
}

/* polylines */

v_pline(h, count, xy) short xy[]; { /* draw multi-segment line */
	vdi2 = xy;
	vdc(6, count, 0, 0, h); 	/* count >= 2 */
	vdi2 = &pi0;
}

vsl_color(h, color) {	/* set line color - returns color selected */
	return vdi_attr(h, 17, color);
}

vsl_ends(h, begin, end)	{ /* set line end styles */
	ii0 = begin;
	ii1 = end;
	vdc(108, 0, 2, 0, h);
}

vsl_type(h, type) {	/* set line type - returns type selected */
	return vdi_attr(h, 15, type);
}

vsl_udsty(h, pat) {	/* set user defined line type pattern */
	vdi_attr(h, 113, pat); /* e.g. dash line type is: 0xFF00 */
}

vsl_width(h, w) {	/* set line width - returns actual width */
	pi0 = w;
	vdc(16, 1, 0, 0, h);
	return po0;
}

vql_attributes(h, at) struct vdi_lattr *at; { /* query line attributes */
	vdi3 = at;
	vdi4 = &(at->linewid);
	vdc(35, 0, 0, 0, h);
	vdi3 = &io0;
	vdi4 = &po0;
}

/* text */

vst_alignment(h, hin, vin, hout, vout) 
short *hout, *vout; { 	/* set text alignment */
	ii0 = hin;
	ii1 = vin;
	vdc(39, 0, 2, 0, h);
	*hout = io0;
	*vout = io1;
}

vst_color(h, color) {	/* set text color - color selected returned */
	return vdi_attr(h, 22, color);
}

vst_effects(h, effects) { /* set text effects - effects selected returned */
	return vdi_attr(h, 106, effects);
}

/* set text height - absolute mode */
vst_height(h, height, wch, hch, wcl, hcl) int *wch, *hch, *wcl, *hcl; {
	pi0 = 0;
	pi1 = height; /* height: distance from baseline to top of char. cell */
	vdc(12, 1, 0, 0, h);
	*wch = po0;
	*hch = po1;
	*wcl = po2;
	*hcl = po3;
}

vst_point(h, height) { /* set text height - points mode, height returned */
	/* distance between baselines of two consecutive lines */
	return vdi_attr(h, 107, height);
}

vst_rotation(h, angle) { /* set baseline vector - angle selected returned */
	return vdi_attr(h, 13, angle); /* angle expressed in .1s of a degree */
}

vst_font(h, font) {	/* set font - returns font selected */
	return vdi_attr(h, 21, font);
}

vswr_mode(h, mode) {	/* set writing mode - mode selected returned */
	return vdi_attr(h, 32, mode);
}

v_curtext(h, s) char *s; {
	_vdi_tcpy(5, 0, 12, h, s);
}

v_gtext(h, x, y, s) char *s; {
	pi0 = x;
	pi1 = y;
	_vdi_tcpy(8, 2, 0, h, s);
}

_vdi_tcpy(op, pin, p5, h, s) char *s; {
	short	*ip, tbuf[140];
	int	i;

	vdi1 = tbuf;
	for (ip = tbuf, i = 0; (i < 140) && (*s != '\0'); ++i) {
		*ip++ = *s++;
	}
	vdc(op, pin, i, p5, h);
	vdi1 = &ii0;
}

vqt_attributes(h, at) struct vdi_tattr *at; { /* query text attributes */
	vdi3 = at;
	vdi4 = &(at->charwid);
	vdc(38, 0, 0, 0, h);
	vdi3 = &io0;
	vdi4 = &po0;
}

/* graphic primitives */

v_arc(h, x, y, r, sa, ea) { /* draw arc - portion of a circle */
	ii0 = sa;	/* start angle - .1s of degree */
	ii1 = ea;	/* end angle */
	pi0 = x;	/* center - x coord. */
	pi1 = y;	/* center - y coord. */
	pi6 = r;	/* radius */
	vdc(11, 4, 2, 2, h);
}

v_bar(h, xy) int *xy; {	/* draw a bar (box) */
	pi0 = *xy;
	pi1 = *++xy;
	pi2 = *++xy;
	pi3 = *++xy;
	vdc(11, 2, 0, 1, h);
}

v_circle(h, x, y, r) {	/* draw a circle */
	pi0 = x;
	pi1 = y;
	pi4 = r;
	vdc(11, 3, 0, 4, h);
}

v_contourfill(h, x, y, color) {	/* fill area enclosing x,y */
	pi0 = x;
	pi1 = y;
	ii0 = color; /* color < 0: boundry of any color other than xy's */
	vdc(103, 1, 1, 0, h);
}

v_ellarc(h, x, y, xr, yr, sa, ea) { /* draw an elliptical arc */
	ii0 = sa;	/* start angle */
	ii1 = ea; /* end angle */
	pi0 = x;	/* center point x */
	pi1 = y;	/* center point y */
	pi2 = xr; /* x radius */
	pi3 = yr; /* y radius */
	vdc(11, 2, 2, 6, h);
}

v_ellpie(h, x, y, xr, yr, sa, ea) { /* draw an elliptical pie slice */
	ii0 = sa;
	ii1 = ea;
	pi0 = x;
	pi1 = y;
	pi2 = xr;
	pi3 = yr;
	vdc(11, 2, 2, 7, h);
}

v_ellipse(h, x, y, xr, yr) {	/* draw an ellipse */
	pi0 = x;
	pi1 = y;
	pi2 = xr;
	pi3 = yr;
	vdc(11, 2, 0, 5, h);
}

v_rbox(h, xy) short *xy; { /* draw a rounded box */
	pi0 = *xy; /* xy coordinates of lower left and upper right corners */
	pi1 = *++xy;
	pi2 = *++xy;
	pi3 = *++xy;
	vdc(11, 2, 0, 8, h);
}

v_rfbox(h, xy) short *xy; { /* draw a rounded filled box */
	pi0 = *xy; /* xy coordinates of lower left and upper right corners */
	pi1 = *++xy;
	pi2 = *++xy;
	pi3 = *++xy;
	vdc(11, 2, 0, 9, h);
}

v_recfl(h, xy) short *xy; { /* draw a filled rectangle */
	pi0 = *xy; /* xy coordinates of diagonally opposite corners */
	pi1 = *++xy;
	pi2 = *++xy;
	pi3 = *++xy;
	vdc(114, 2, 0, 0, h);
}

/* area fill and attributes */

v_fillarea(h, count, xy) short xy[]; { 
	vdi2 = xy; /* fill area defined by a multi-segment line */
	vdc(9, count, 0, 0, h); /* count >= 2 */
	vdi2 = &pi0;
}

vsf_color(h, color) {	/* set fill color */
	return vdi_attr(h, 25, color);
}

vsf_perimeter(h, v_flag) { /* set fill perimeter visibility */
	return vdi_attr(h, 104, v_flag); /* 0 = invisible, 1 = visible */
}

vsf_interior(h, style) { /* set fill interior style */
	return vdi_attr(h, 23, style);
}

vsf_style(h, style) {	/* set fill style */
	/* interior pattern: 0-23, interior hatch: 0-11 */
	return vdi_attr(h, 24, style); 
}

vsf_updat(h, fill, planes) int *fill; { /* set user defined fill pattern */
	int n;
	n = planes << 4; /* 16 words per plane */
	vdi1 = fill;
	vdc(112, 0, n, 0, h);
	vdi1 = &ii0;
}

vqf_attributes (h, at)	struct vdi_fattr *at; {
	/* inquire current fill area attributes */
	vdi4 = at;
	vdc(37, 0, 0, 0, h);
	vdi4 = &po0;
}

/* pixel operation */

v_get_pixel(h, x, y, pel, color) short *pel, *color; { /* get pixel value */
	pi0 = x;
	pi1 = y;
	vdc(105, 1, 0, 0, h);
	*pel = io0;
	*color = io1;
}

vro_cpyfm(h, mode, xy, src, des) short xy[]; struct mfdb *src, *des; {
	struct	mfdb	**p;

	p = (struct mfdb **) &ct7;
	*p = src;
	*++p = des;
	ii0 = mode;
	vdi2 = xy;
	vdc(109, 4, 1, 0, h);
	vdi2 = &pi0;
}

vrt_cpyfm(h, mode, pxy, src, dst, color) int *pxy; struct mfdb *src, *dst; {
	struct mfdb **p;
	p = &ct7;
	*p++ = src;
	*p = dst;
	ii0 = mode;
	ii1 = color;
	ii2 = 0;
	vdi2 = pxy;
	vdc(121, 4, 3, 0, h);	
	vdi2 = &pi0;
}

vr_trnfm(h, src, dst) struct mfdb *src, *dst; {
	struct mfdb **p;
	p = &ct7;
	*p++ = src;
	*p = dst;
	vdc(110, 0, 0, 0, h);
}

vq_color(h, index, set_flag, rgb) short rgb[]; {
	/* inquire color representation */
	ii0 = index;	/* color to enquire about */
	ii1 = set_flag;	/* 0 = values set; 1 = values realized */
	vdc(26, 0, 2, 0, h);
	rgb[0] = io1;	/* red intensity - .1% */
	rgb[1] = io2;	/* green intensity  */
	rgb[2] = io3;	/* blue intensity */
}

vs_color(h, index, rgb) short rgb[]; {	/* set color representation */
	ii0 = index;
	ii1 = rgb[0];	/* red */
	ii2 = rgb[1];	/* green */
	ii3 = rgb[2];	/* blue */
	vdc(14, 0, 4, 0, h);
}

vq_key_s(h, status) int h, *status; {
	ct0 = 128;
	ct1 = ct2 = ct3 = 0;
	ct6 = h;
	vdi();
	*status = io0;
}

/* mouse functions */

v_show_c(h, mstyle) {	/* show mouse */
	ii0 = mstyle;
	vdc(122, 0, 1, 0, h);
}

v_hide_c(h) {	/* hide mouse */
	vdc(123, 0, 0, 0, h);
}

vsc_form(h, form) struct vdi_form *form; { /* define mouse shape */
	vdi1 = form;
	vdc(111, 0, 37, 0, h);
	vdi1 = &ii0;
}

vq_mouse(h, pstatus, px, py) short *pstatus, *px, *py; {
	/* get mouse's status */
	vdc(124, 0, 0, 0, h);
	*pstatus = io0;
	*px = po0;
	*py = po1;
}

vdi_attr(h, op, attr) { /* implements many common routines */
	ii0 = attr;
	vdc(op, 0, 1, 0, h);
	return io0;
}

/* GEM application init and exit */

appl_init() {
	ct0 = 10;
	ct2 = 1;
	ct1 = ct3 = ct4 = 0;
	aes();
	return io0;
}

appl_exit(i) { trap(1, TERM, i); }

/* VDI routines for the GEM library */

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

/* AES file selector */

fsel_input(dir, file, button) char *dir, *file; int *button; {
	ct0 = 90;
	ct1 = ct4 = 0;
	ct2 = ct3 = 2;
	ai0 = dir;
	ai1 = file;
	aes();
	*button = io1;
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
