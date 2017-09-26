/*----------------------------------------------------------------------------------------
	vdi.c, part of TOS Linker for CodeWarrior

	VDI system calls for TOS
	
	21.10.1998 by Manfred Lippert
	based on VDI documentations from Sven & Wilfried Behne

	last change: 27.6.2001

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#include <vdi.h>

#define MAX_VDI_STRLEN 		128
#define MAX_VDI_FONTNAMELEN	32

/* device drivers and offscreen bitmaps: */

/* OPEN WORKSTATION (1,0) */

void v_opnwk(int16 *work_in, int16 *handle, int16 *work_out) {
	static VDICONIN conin = {	/*opcode*/	1,
								/*p_in*/	0,
								/*i_in*/	11,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = work_in;						/* 0 - 10 */
	pb.intout = work_out;					/* 0 - 44 */
	pb.ptsout = (POINT16 *)&work_out[45];	/* 45 - 56 */

	contrl.handle = 0;

	mt_vdi(&pb, &conin);

	*handle = contrl.handle;
}

/* OPEN PRINTER (1,0) */

int16	v_opnprn(int16 base_handle, PRN_SETTINGS *settings, int16 *work_out) {
	static VDICONIN conin = {	/*opcode*/	1,
								/*p_in*/	0,
								/*i_in*/	16,	/* v_opnprn */
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 work_in[16];

	work_in[0] = settings->driver_id;	/* Treibernummer */
	{
		int16 *ptr = work_in + 1;
		int16 i = 8;
		do {
			*ptr++ = 1;
		} while (--i >= 0);
	}
	work_in[10] = 2;
	work_in[11] = (int16) settings->size_id;		/* Seitenformat aus settings benutzen */
	*(int8 **) &work_in[12] = settings->device;		/* Ausgabekanal aus settings benutzen */
	*(PRN_SETTINGS **) &work_in[14] = settings;		/* Druckereinstellung */

	pb.contrl = &contrl;
	pb.intin = work_in;						/* 0 - 15 */
	pb.intout = work_out;					/* 0 - 44 */
	pb.ptsout = (POINT16 *)&work_out[45];	/* 45 - 56 */

	contrl.handle = base_handle;

	mt_vdi(&pb, &conin);

	return contrl.handle;
}

/* CLOSE WORKSTATION (2,0) */

void v_clswk(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	2,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* OPEN VIRTUAL SCREEN WORKSTATION (100,0) */

void v_opnvwk(int16 *work_in, int16 *handle, int16 *work_out) {
	static VDICONIN conin = {	/*opcode*/	100,
								/*p_in*/	0,
								/*i_in*/	11,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = work_in;						/* 0 - 10 */
	pb.intout = work_out;					/* 0 - 44 */
	pb.ptsout = (POINT16 *)&work_out[45];	/* 45 - 56 */

	contrl.handle = *handle;

	mt_vdi(&pb, &conin);

	*handle = contrl.handle;
}

/* CLOSE VIRTUAL SCREEN WORKSTATION (101,0) */

void v_clsvwk(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	101,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* CLEAR WORKSTATION (3,0) */

void v_clrwk(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	3,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* CLEAR DISPLAY LIST (5,22) */

void v_clear_disp_list(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	22};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* UPDATE WORKSTATION (4) */

void v_updwk(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	4,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* OPEN BITMAP (100,1) */

void v_opnbm(int16 *work_in, MFDB *bitmap, int16 *handle, int16 *work_out) {
	static VDICONIN conin = {	/*opcode*/	100,
								/*p_in*/	0,
								/*i_in*/	20,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;

	*(MFDB **)&contrl.idx7 = bitmap;
	pb.contrl = &contrl;
	pb.intin = work_in;			/* 0 - 19 */
	pb.intout = work_out;		/* 0 - 44 */
	pb.ptsout = (POINT16 *)&work_out[45];	/* 45 - 56 */

	contrl.handle = *handle;

	mt_vdi(&pb, &conin);

	*handle = contrl.handle;
}

/* CLOSE BITMAP (101,1) */

void v_clsbm(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	101,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* OPEN BITMAP (NVDI 5) (100,3) */

int16 v_open_bm(int16 base_handle, GCBITMAP *bitmap, int16 zero, int16 flags,
								int16 pixel_width, int16 pixel_height) {
	static VDICONIN conin = {	/*opcode*/	100,
								/*p_in*/	0,
								/*i_in*/	4,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[4];
	int16 intout;

	*(GCBITMAP **)&contrl.idx7 = bitmap;

	intin[0] = zero;
	intin[1] = flags;
	intin[2] = pixel_width;
	intin[3] = pixel_height;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = base_handle;

	mt_vdi(&pb, &conin);

	return contrl.handle;
}

/* RESIZE BITMAP (NVDI 5) (100,2) */

int16 v_resize_bm(int16 handle, int16 width, int16 height, int32 byte_width, uint8 *addr) {
	static VDICONIN conin = {	/*opcode*/	100,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	intin[0] = width;
	intin[1] = height;
	*(int32 *)&intin[2] = byte_width;
	*(uint8 **)&intin[4] = addr;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* EXTENDED INQUIRE FUNCTION (102,0) */

void vq_extnd(int16 handle, int16 flag, int16 *wout) {
	static VDICONIN conin = {	/*opcode*/	102,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = &flag;
	pb.intout = wout;			/* 0 - 44 */
	pb.ptsout = (POINT16 *)&wout[45];	/* 45 - 56 */

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INQUIRE SCREEN INFORMATION (102,1) */

void vq_scrninfo(int16 handle, int16 *wout) {
	static VDICONIN conin = {	/*opcode*/	102,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 zwei = 2;

	pb.contrl = &contrl;
	pb.intin = &zwei;
	pb.intout = wout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INQUIRE DEVICE STATUS INFORMATION (248,0) */

void vq_devinfo(int16 handle, int16 device, int16 *dev_open, char *file_name, char *device_name) {
	static VDICONIN conin = {	/*opcode*/	248,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	int16 i;
	int16 *ptr;
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[128];
	int16 ptsout[128];

	pb.contrl = &contrl;
	pb.intin = &device;
	pb.intout = intout;
	pb.ptsout = (POINT16 *)ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	ptr = ptsout;
	*dev_open = *ptr++;
	i = contrl.ptsout_count;
	while (--i > 0) {
		*device_name++ = (char)(*ptr++);
	}
	*device_name = 0;
	ptr = intout;
	i = contrl.intout_count;
	while (--i >= 0) {
		*file_name++ = (char)(*ptr++);
	}
	*file_name = 0;
}

/* INQUIRE EXTENDED DEVICE STATUS INFORMATION (248,4242) */

int16 vq_ext_devinfo(int16 handle, int16 device, int16 *dev_exists, char *file_path, char *file_name, char *name) {
	static VDICONIN conin = {	/*opcode*/	248,
								/*p_in*/	0,
								/*i_in*/	7,
								/*subcode*/	4242};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[7];
	int16 intout[2];

	intin[0] = device;
	*(char **)&intin[1] = file_path;
	*(char **)&intin[3] = file_name;
	*(char **)&intin[5] = name;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*dev_exists = intout[0];
	return intout[1];
}


/* colors: */

/* SET COLOR REPRESENTATION (14,0) */

void vs_color(int16 handle, int16 index, RGB1000 *rgb) {
	static VDICONIN conin = {	/*opcode*/	14,
								/*p_in*/	0,
								/*i_in*/	4,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[4];

	intin[0] = index;
	*(RGB1000 *)&intin[1] = *rgb;

	pb.contrl = &contrl;
	pb.intin = intin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INQUIRE COLOR REPRESENTATION (26,0) */

int16 vq_color(int16 handle, int16 index, int16 flag, RGB1000 *rgb) {
	static VDICONIN conin = {	/*opcode*/	26,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	int16 intout[4];

	intin[0] = index;
	intin[1] = flag;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*rgb = *(RGB1000 *)&intout[1];

	return intout[0];
}

/* SET CALIBRATION (5,76) */

int16 vs_calibrate(int16 handle, int16 flag, RGB1000 *table) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	3,
								/*subcode*/	76};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[3];
	int16 cal_flag;

	*(RGB1000 **)&intin[0] = table;
	intin[2] = flag;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &cal_flag;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return cal_flag;
}

/* INQUIRE CALIBRATION (5,77) */

int16 vq_calibrate(int16 handle, int16 *flag) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	77};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intout = flag;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return contrl.intout_count;
}


/* writing mode and clipping area: */

/* SET WRITING MODE (32,0) */

int16 vswr_mode(int16 handle, int16 mode) {
	static VDICONIN conin = {	/*opcode*/	32,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 setmode;

	pb.contrl = &contrl;
	pb.intin = &mode;
	pb.intout = &setmode;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return setmode;
}

/* SET CLIPPING RECTANGLE (129,0) */

void vs_clip(int16 handle, int16 flag, POINT16 *area) {
	static VDICONIN conin = {	/*opcode*/	129,
								/*p_in*/	2,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = &flag;
	pb.ptsin = area;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}


/* lines and unfilled graphic primitives: */

/* POLYLINE (6,0) */

void v_pline(int16 handle, int16 count, POINT16 *xy) {
	VDICONIN conin = {	/*opcode*/	6,		/* Nicht static!!! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	conin.ptsin_count = count;	/* ! */

	pb.contrl = &contrl;
	pb.ptsin = xy;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* OUTPUT BEZIER (6,13) */

void v_bez(int16 handle, int16 count, POINT16 *xyarr, uint8 *bezarr, POINT16 *extent, int16 *totpts, int16 *totmoves) {
	VDICONIN conin = {	/*opcode*/	6,		/* Nicht static!!! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	13};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];			/* 2 - 5 reserviert */

	conin.ptsin_count = count;				/* ! */
	conin.intin_count = ((count + 1) >> 1);	/* ! */

	pb.contrl = &contrl;
	pb.ptsin = xyarr;
	pb.ptsout = extent;
	pb.intin = (int16 *)bezarr;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*totpts = intout[0];
	*totmoves = intout[1];
}

/* ARC (11,2) */

void v_arc(int16 handle, int16 x, int16 y, int16 radius, int16 begang, int16 endang) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	4,
								/*i_in*/	2,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	POINT16 ptsin[4];

	intin[0] = begang;
	intin[1] = endang;
	ptsin[0].x = x;
	ptsin[0].y = y;
	*(int32 *)&ptsin[1] = 0;
	*(int32 *)&ptsin[2] = 0;
	ptsin[3].x = radius;
	ptsin[3].y = 0;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ELLIPTICAL ARC (11,6) */

void v_ellarc(int16 handle, int16 x, int16 y, int16 xradius, int16 yradius, int16 begang, int16 endang) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	2,
								/*i_in*/	2,
								/*subcode*/	6};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	POINT16 ptsin[2];

	intin[0] = begang;
	intin[1] = endang;
	ptsin[0].x = x;
	ptsin[0].y = y;
	ptsin[1].x = xradius;
	ptsin[1].y = yradius;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ROUNDED RECTANGLE (11,8) */

void v_rbox(int16 handle, POINT16 *rect) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	2,
								/*i_in*/	0,
								/*subcode*/	8};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.ptsin = rect;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ENABLE BEZIER CAPABILITIES (11,13) */

int16 v_bez_on(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	1,		/* bez_on */
								/*i_in*/	0,
								/*subcode*/	13};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 retval;

	pb.contrl = &contrl;
	pb.intout = &retval;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return retval;
}

/* DISABLE BEZIER CAPABILITIES (11,13) */

void v_bez_off(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	0,		/* bez_off */
								/*i_in*/	0,
								/*subcode*/	13};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET BEZIER QUALITY (5,99) */

void v_bez_qual(int16 handle, int16 qual, int16 *set_qual) {	/* int16 return value? */
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	3,
								/*subcode*/	99};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[3];

	intin[0] = 32;		/* v_bez_qual */
	intin[1] = 1;		/* v_bez_qual */
	intin[2] = qual;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = set_qual;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

/*	return *set_qual; ?? */
}

/* SET POLYLINE LINE TYPE (15,0) */

int16 vsl_type(int16 handle, int16 type) {
	static VDICONIN conin = {	/*opcode*/	15,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_type;

	pb.contrl = &contrl;
	pb.intin = &type;
	pb.intout = &set_type;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_type;
}

/* SET POLYLINE LINE WIDTH (16,0) */

int16 vsl_width(int16 handle, int16 width) {
	static VDICONIN conin = {	/*opcode*/	16,
								/*p_in*/	1,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_width;

	pb.contrl = &contrl;
	pb.ptsin = (POINT16 *)&width;
	pb.ptsout = (POINT16 *)&set_width;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_width;
}

/* SET POLYLINE COLOR INDEX (17,0) */

int16 vsl_color(int16 handle, int16 color_index) {
	static VDICONIN conin = {	/*opcode*/	17,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_color;

	pb.contrl = &contrl;
	pb.intin = &color_index;
	pb.intout = &set_color;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_color;
}

/* INQUIRE CURRENT POLYLINE ATTRIBUTES (35,0) */

void vql_attributes(int16 handle, int16 *attrib) {
	static VDICONIN conin = {	/*opcode*/	35,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intout = attrib;
	pb.ptsout = (POINT16 *)&attrib[5];

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	{
		int16 help = attrib[5];
		attrib[5] = attrib[4];
		attrib[4] = attrib[3];
		attrib[3] = help;
	}
}

/* SET POLYLINE END STYLES (108,0) */

void vsl_ends(int16 handle, int16 beg_style, int16 end_style) {
	static VDICONIN conin = {	/*opcode*/	108,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];

	intin[0] = beg_style;
	intin[1] = end_style;

	pb.contrl = &contrl;
	pb.intin = intin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET USER DEFINED LINE STYLE PATTERN (113,0) */

void vsl_udsty(int16 handle, int16 pattern) {
	static VDICONIN conin = {	/*opcode*/	113,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = &pattern;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}


/* filled graphic primitives: */

/* FILLED AREA (9,0) */

void v_fillarea(int16 handle, int16 count, POINT16 *xy) {
	VDICONIN conin = {	/*opcode*/	9,		/* Nicht static!!! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	conin.ptsin_count = count;	/* ! */

	pb.contrl = &contrl;
	pb.ptsin = xy;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* OUTPUT FILLED BEZIER (9,13) */

void v_bez_fill(int16 handle, int16 count, POINT16 *xyarr, uint8 *bezarr, POINT16 *extent, int16 *totpts, int16 *totmoves) {
	VDICONIN conin = {	/*opcode*/	9,		/* Nicht static!!! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	13};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];			/* 2 - 5 reserviert */

	conin.ptsin_count = count;				/* ! */
	conin.intin_count = ((count + 1) >> 1);	/* ! */

	pb.contrl = &contrl;
	pb.ptsin = xyarr;
	pb.ptsout = extent;
	pb.intin = (int16 *)bezarr;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*totpts = intout[0];
	*totmoves = intout[1];
}

/* BAR (11,1) */

void v_bar(int16 handle, POINT16 *rect) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	2,
								/*i_in*/	0,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.ptsin = rect;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* PIE (11,3) */

void v_pieslice(int16 handle, int16 x, int16 y, int16 radius, int16 begang, int16 endang) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	4,
								/*i_in*/	2,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	POINT16 ptsin[4];

	intin[0] = begang;
	intin[1] = endang;
	ptsin[0].x = x;
	ptsin[0].y = y;
	*(int32 *)&ptsin[1] = 0;
	*(int32 *)&ptsin[2] = 0;
	ptsin[3].x = radius;
	ptsin[3].y = 0;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* CIRCLE (11,4) */

void v_circle(int16 handle, int16 x, int16 y, int16 radius) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	3,
								/*i_in*/	0,
								/*subcode*/	4};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[3];

	ptsin[0].x = x;
	ptsin[0].y = y;
	*(int32 *)&ptsin[1] = 0;
	ptsin[2].x = radius;
	ptsin[2].y = 0;

	pb.contrl = &contrl;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ELLIPSE (11,5) */

void v_ellipse(int16 handle, int16 x, int16 y, int16 xradius, int16 yradius) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	2,
								/*i_in*/	0,
								/*subcode*/	5};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[2];

	ptsin[0].x = x;
	ptsin[0].y = y;
	ptsin[1].x = xradius;
	ptsin[1].y = yradius;

	pb.contrl = &contrl;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ELLIPTICAL PIE (11,7) */

void v_ellpie(int16 handle, int16 x, int16 y, int16 xradius, int16 yradius, int16 begang, int16 endang) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	2,
								/*i_in*/	2,
								/*subcode*/	7};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	POINT16 ptsin[2];

	intin[0] = begang;
	intin[1] = endang;
	ptsin[0].x = x;
	ptsin[0].y = y;
	ptsin[1].x = xradius;
	ptsin[1].y = yradius;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* FILLED ROUNDED RECTANGLE (11,9) */

void v_rfbox(int16 handle, POINT16 *rect) {
	static VDICONIN conin = {	/*opcode*/	11,
								/*p_in*/	2,
								/*i_in*/	0,
								/*subcode*/	9};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.ptsin = rect;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET FILL INTERIOR INDEX (23,0) */

int16 vsf_interior(int16 handle, int16 interior) {
	static VDICONIN conin = {	/*opcode*/	23,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_interior;

	pb.contrl = &contrl;
	pb.intin = &interior;
	pb.intout = &set_interior;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_interior;
}

/* SET FILL STYLE INDEX (24,0) */

int16 vsf_style(int16 handle, int16 style_index) {
	static VDICONIN conin = {	/*opcode*/	24,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_style;

	pb.contrl = &contrl;
	pb.intin = &style_index;
	pb.intout = &set_style;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_style;
}

/* SET FILL COLOR INDEX (25,0) */

int16 vsf_color(int16 handle, int16 color_index) {
	static VDICONIN conin = {	/*opcode*/	25,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_color;

	pb.contrl = &contrl;
	pb.intin = &color_index;
	pb.intout = &set_color;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_color;
}

/* INQUIRE CURRENT FILL AREA ATTRIBUTES (37,0) */

void vqf_attributes(int16 handle, int16 *attrib) {
	static VDICONIN conin = {	/*opcode*/	37,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intout = attrib;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* CONTOUR FILL (103,0) */

void v_contourfill(int16 handle, int16 x, int16 y, int16 color_index) {
	static VDICONIN conin = {	/*opcode*/	103,
								/*p_in*/	1,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[1];

	ptsin[0].x = x;
	ptsin[0].y = y;

	pb.contrl = &contrl;
	pb.intin = &color_index;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET FILL PERIMETER VISIBILITY (104,0) */

int16 vsf_perimeter(int16 handle, int16 flag) {
	static VDICONIN conin = {	/*opcode*/	104,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_flag;

	pb.contrl = &contrl;
	pb.intin = &flag;
	pb.intout = &set_flag;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_flag;
}

/* SET USER_DEFINED FILL PATTERN (112,0) */

void vsf_udpat(int16 handle, int16 *pattern, int16 planes) {
	VDICONIN conin = {	/*opcode*/	112,		/* Nicht static! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	conin.intin_count = (planes << 4);	/* ! 16*planes */

	pb.contrl = &contrl;
	pb.intin = pattern;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* FILLED RECTANGLE (114,0) */

void v_recfl(int16 handle, POINT16 *rect) {
	static VDICONIN conin = {	/*opcode*/	114,
								/*p_in*/	2,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.ptsin = rect;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}


/* marker: */

/* POLYMARKER (7,0) */

void v_pmarker(int16 handle, int16 count, POINT16 *xy) {
	VDICONIN conin = {	/*opcode*/	7,		/* Nicht static!!! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	conin.ptsin_count = count;	/* ! */

	pb.contrl = &contrl;
	pb.ptsin = xy;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET POLYMARKER TYPE (18,0) */

int16 vsm_type(int16 handle, int16 type) {
	static VDICONIN conin = {	/*opcode*/	18,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_type;

	pb.contrl = &contrl;
	pb.intin = &type;
	pb.intout = &set_type;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_type;
}

/* SET POLYMARKER HEIGHT (19,0) */

int16 vsm_height(int16 handle, int16 height) {
	static VDICONIN conin = {	/*opcode*/	19,
								/*p_in*/	1,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[1];
	POINT16 ptsout[1];

	ptsin[0].x = 0;
	ptsin[0].y = height;

	pb.contrl = &contrl;
	pb.ptsin = ptsin;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return ptsout[0].y;	/* nur height wird zurckgeliefert */
}

/* SET POLYMARKER COLOR INDEX (20,0) */

int16 vsm_color(int16 handle, int16 color_index) {
	static VDICONIN conin = {	/*opcode*/	20,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 set_color;

	pb.contrl = &contrl;
	pb.intin = &color_index;
	pb.intout = &set_color;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return set_color;
}

/* INQUIRE CURRENT POLYMARKER ATTRIBUTES (36,0) */

void vqm_attributes(int16 handle, int16 *attrib) {
	static VDICONIN conin = {	/*opcode*/	36,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intout = attrib;					/* 0,1,2 */
	pb.ptsout = (POINT16 *)&attrib[4];	/* 4,3 */

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	{
		int16 help = attrib[3];
		attrib[3] = attrib[4];
		attrib[4] = help;
	}
}


/* text output with bitmap and vector fonts: */

/* TEXT (8,0) */

void v_gtext(int16 handle, int16 x, int16 y, char *string) {
	VDICONIN conin = {	/*opcode*/	8,			/* Nicht static! */
						/*p_in*/	1,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[1];
	int16 intin[MAX_VDI_STRLEN + 1];
	{
		int16 *ptr = intin;
		int16 len = 0;
		while (len < MAX_VDI_STRLEN) {
			if ((*ptr++ = (int16)(uint8)(*string++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}
	ptsin[0].x = x;
	ptsin[0].y = y;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

void v_gtext_unicode(int16 handle, int16 x, int16 y, const uint16 *uni_string, uint32 length) {
	VDICONIN conin = {	/*opcode*/	8,			/* Nicht static! */
						/*p_in*/	1,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[1];
	if (length > 32767) {
		length = 32767;
	}
	conin.intin_count = (int16)length;		/* ! */

	ptsin[0].x = x;
	ptsin[0].y = y;

	pb.contrl = &contrl;
	pb.intin = (int16 *)uni_string;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}


/* JUSTIFIED GRAPHICS TEXT (11, 10) */

void v_justified(int16 handle,int16 x, int16 y, char *string, int16 length,
					int16 word_space, int16 char_space) {
	VDICONIN conin = {	/*opcode*/	11,			/* Nicht static! */
						/*p_in*/	2,
						/*i_in*/	0,
						/*subcode*/	10};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[2];
	int16 intin[MAX_VDI_STRLEN + 2 + 1];
	{
		int16 *ptr = intin;
		int16 len = 2;
		*ptr++ = word_space;
		*ptr++ = char_space;
		while (len < MAX_VDI_STRLEN + 2) {
			if ((*ptr++ = (int16)(uint8)(*string++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}
	ptsin[0].x = x;
	ptsin[0].y = y;
	ptsin[1].x = length;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET CHARACTER HEIGHT, ABSOLUTE MODE (12) */

void vst_height(int16 handle, int16 height,
					int16 *char_width, int16 *char_height,
					int16 *cell_width, int16 *cell_height) {
	static VDICONIN conin = {	/*opcode*/	12,
								/*p_in*/	1,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[1];
	POINT16 ptsout[4];

	ptsin[0].x = 0;
	ptsin[0].y = height;

	pb.contrl = &contrl;
	pb.ptsin = ptsin;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*char_width = ptsout[0].x;
	*char_height = ptsout[0].y;
	*cell_width = ptsout[1].x;
	*cell_height = ptsout[1].y;
}

/* SET CHARACTER BASELINE VECTOR (13) */

int16 vst_rotation(int16 handle, int16 angle) {
	static VDICONIN conin = {	/*opcode*/	13,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = &angle;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* SET TEXT FACE (21) */

int16 vst_font(int16 handle, int16 font) {
	static VDICONIN conin = {	/*opcode*/	21,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = &font;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* SET GRAPHIC TEXT COLOR INDEX (22) */

int16 vst_color(int16 handle, int16 color_index) {
	static VDICONIN conin = {	/*opcode*/	22,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = &color_index;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* INQUIRE CURRENT GRAPHIC TEXT ATTRIBUTES (38) */

void vqt_attributes(int16 handle, int16 *attrib) {
	static VDICONIN conin = {	/*opcode*/	38,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intout = attrib;
	pb.ptsout = (POINT16 *)(attrib + 6);

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET GRAPHIC TEXT ALIGNMENT (39) */

void vst_alignment(int16 handle, int16 hor_in, int16 vert_in,
					int16 *hor_out, int16 *vert_out) {
	static VDICONIN conin = {	/*opcode*/	39,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	int16 intout[2];

	intin[0] = hor_in;
	intin[1] = vert_in;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*hor_out = intout[0];
	*vert_out = intout[1];
}

/* SET GRAPHIC TEXT SPECIAL EFFECTS (106) */

int16 vst_effects(int16 handle, int16 effect) {
	static VDICONIN conin = {	/*opcode*/	106,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = &effect;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* SET CHARACTER HEIGHT, POINTS MODE (107) */

int16 vst_point(int16 handle, int16 point,
				int16 *char_width, int16 *char_height,
				int16 *cell_width, int16 *cell_height) {
	static VDICONIN conin = {	/*opcode*/	107,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;
	POINT16 ptsout[2];

	pb.contrl = &contrl;
	pb.intin = &point;
	pb.intout = &intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*char_width = ptsout[0].x;
	*char_height = ptsout[0].y;
	*cell_width = ptsout[1].x;
	*cell_height = ptsout[1].y;

	return intout;
}

/* INQUIRE TEXT EXTENT (116) */

void vqt_extent(int16 handle, char *string, POINT16 *extent) {
	VDICONIN conin = {	/*opcode*/	116,		/* Nicht static! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_STRLEN + 1];
	{
		int16 *ptr = intin;
		int16 len = 0;
		while (len < MAX_VDI_STRLEN) {
			if ((*ptr++ = (int16)(uint8)(*string++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsout = extent;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INQUIRE CHARACTER CELL WIDTH (117) */

int16 vqt_width(int16 handle, int16 index, int16 *cell_width,
				int16 *left_delta, int16 *right_delta) {
	static VDICONIN conin = {	/*opcode*/	117,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;
	POINT16 ptsout[3];

	pb.contrl = &contrl;
	pb.intin = &index;
	pb.intout = &intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*cell_width = ptsout[0].x;
	*left_delta = ptsout[1].x;
	*right_delta = ptsout[2].x;

	return intout;
}

/* LOAD FONTS (119) */

int16 vst_load_fonts(int16 handle, int16 select) {
	static VDICONIN conin = {	/*opcode*/	119,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = &select;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* UNLOAD FONTS (120) */

void vst_unload_fonts(int16 handle, int16 select) {
	static VDICONIN conin = {	/*opcode*/	120,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = &select;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INQUIRE FACE NAME AND INDEX (130) */

/* flags is only valid, if format is not FONTFORMAT_UNKNOWN */
int16 vqt_ext_name(int16 handle, int16 index, char *name,
					int16 *vector, uint16 *font_format, uint16 *flags) {
	static VDICONIN conin = {	/*opcode*/	130,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	int16 intout[35];

	intin[0] = index;
	intin[1] = 0;

	intout[33] = 0;		/* compatibility to old VDI */
	intout[34] = 0;		/* compatibility to old VDI */

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	{
		int16 *ptr = intout + 1;
		int i = 31;
		do {
			*name++ = (char)(*ptr++);	/* 32 characters */
		} while (--i >= 0);
		*name = 0;
	}
	*vector = intout[33];
	*font_format = ((uint16)(intout[34]) & 0xFF);
	*flags = (((uint16)(intout[34]) >> 8) & 0xFF);

	return intout[0];
}

/* INQUIRE CURRENT FACE INFORMATION (131) */

void vqt_fontinfo(int16 handle, int16 *minADE, int16 *maxADE,
					int16 *distances, int16 *maxwidth, int16 *effects) {
	static VDICONIN conin = {	/*opcode*/	131,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[2];
	POINT16 ptsout[5];

	pb.contrl = &contrl;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*minADE = intout[0];
	*maxADE = intout[1];
	*maxwidth = ptsout[0].x;
	distances[0] = ptsout[0].y;
	distances[1] = ptsout[1].y;
	distances[2] = ptsout[2].y;
	distances[3] = ptsout[3].y;
	distances[4] = ptsout[4].y;
	effects[0] = ptsout[1].x;
	effects[1] = ptsout[2].x;
	effects[2] = ptsout[3].x;
}

/* INQUIRE CHARACTER INDEX (190, 0) */

uint16 vqt_char_index(int16 handle, uint16 src_index,
						int16 src_mode, int16 dst_mode) {
	static VDICONIN conin = {	/*opcode*/	190,
								/*p_in*/	0,
								/*i_in*/	3,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[3];
	int16 intout;

	intin[0] = (int16)src_index;
	intin[1] = src_mode;
	intin[2] = dst_mode;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return (uint16)intout;
}

/* INQUIRE EXTENDED FONT INFORMATION (229) */

int16 vqt_xfntinfo(int16 handle, int16 flags, int16 id, int16 index,
					XFNT_INFO *info) {
	static VDICONIN conin = {	/*opcode*/	229,
								/*p_in*/	0,
								/*i_in*/	5,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[5];
	int16 intout[3];

	intin[0] = flags;
	intin[1] = id;
	intin[2] = index;
	*(XFNT_INFO **)&intin[3] = info;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout[1];
}

/* SET TEXT FACE BY NAME (230, 0) */

int16 vst_name(int16 handle, int16 font_format,
				char *font_name, char *ret_name) {
	VDICONIN conin = {	/*opcode*/	230,		/* Nicht static! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_FONTNAMELEN + 1 + 1];
	int16 intout[MAX_VDI_FONTNAMELEN + 1];

	{
		int16 *ptr = intin;
		int16 len = 1;
		*ptr++ = font_format;
		while (len < MAX_VDI_FONTNAMELEN + 1) {
			if ((*ptr++ = (int16)(uint8)(*font_name++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	{
		int16 *ptr = intout + 1;
		int16 len = contrl.intout_count - 1;
		if (len > MAX_VDI_FONTNAMELEN) {
			len = MAX_VDI_FONTNAMELEN;
		}
		while (len-- > 0) {
			*ret_name++ = (char)(*ptr++);
		}
		*ret_name = 0;
	}

	return intout[0];
}

/* INQUIRE FACE NAME AND ID BY NAME (230, 100) */

int16 vqt_name_and_id(int16 handle, int16 font_format,
						char *font_name, char *ret_name) {
	VDICONIN conin = {	/*opcode*/	230,		/* Nicht static! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	100};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_FONTNAMELEN + 1 + 1];
	int16 intout[MAX_VDI_FONTNAMELEN + 1];

	{
		int16 *ptr = intin;
		int16 len = 1;
		*ptr++ = font_format;
		while (len < MAX_VDI_FONTNAMELEN + 1) {
			if ((*ptr++ = (int16)(uint8)(*font_name++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	{
		int16 *ptr = intout + 1;
		int16 len = contrl.intout_count - 1;
		if (len > MAX_VDI_FONTNAMELEN) {
			len = MAX_VDI_FONTNAMELEN;
		}
		while (len-- > 0) {
			*ret_name++ = (char)(*ptr++);
		}
		*ret_name = 0;
	}

	return intout[0];
}

/* SET CHARACTER WIDTH, ABSOLUTE MODE (231) */

void vst_width(int16 handle, int16 width,
				int16 *char_width, int16 *char_height,
				int16 *cell_width, int16 *cell_height) {
	static VDICONIN conin = {	/*opcode*/	231,
								/*p_in*/	1,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsout[2];

	pb.contrl = &contrl;
	pb.ptsin = (POINT16 *)&width;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*char_width = ptsout[0].x;
	*char_height = ptsout[0].y;
	*cell_width = ptsout[1].x;
	*cell_height = ptsout[1].y;
}

/* INQUIRE SPEEDO HEADER INFORMATION (232) */

void vqt_fontheader(int16 handle, void *buffer, char *tdf_name) {
	static VDICONIN conin = {	/*opcode*/	232,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[256];

	pb.contrl = &contrl;
	pb.intin = (int16 *)&buffer;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	{
		int16 *ptr = intout;
		int16 len = contrl.intout_count;
		if (len > 256) {
			len = 256;
		}
		while (len-- > 0) {
			*tdf_name++ = (char)(*ptr++);
		}
		*tdf_name = 0;
	}
}

/* INQUIRE TRACK KERNING INFORMATION (234) */

void vqt_trackkern(int16 handle, fixed32 *x_offset, fixed32 *y_offset) {
	static VDICONIN conin = {	/*opcode*/	234,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[4];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*x_offset = *(fixed32 *)&intout[0];
	*y_offset = *(fixed32 *)&intout[2];
}

/* INQUIRE PAIR KERNING INFORMATION (235) */

void vqt_pairkern(int16 handle, int16 index1, int16 index2,
					fixed32 *x_offset, fixed32 *y_offset) {
	static VDICONIN conin = {	/*opcode*/	235,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	int16 intout[4];

	intin[0] = index1;
	intin[1] = index2;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*x_offset = *(fixed32 *)&intout[0];
	*y_offset = *(fixed32 *)&intout[2];
}

/* SET CHARACTER MAPPING MODE (236) */

void vst_charmap(int16 handle, int16 mode) {
	static VDICONIN conin = {	/*opcode*/	236,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = &mode;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

int16 vst_mapmode(int16 handle, int16 mode) {
	static VDICONIN conin = {	/*opcode*/	236,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	int16 intout;

	intin[0] = mode;
	intin[1] = 1;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* SET KERNING MODE (237) */

void vst_kern(int16 handle, int16 track_mode, int16 pair_mode,
				int16 *tracks, int16 *pairs) {
	static VDICONIN conin = {	/*opcode*/	237,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	int16 intout[2];

	intin[0] = track_mode;
	intin[1] = pair_mode;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*tracks = intout[0];
	*pairs = intout[1];
}

void vst_track_offset(int16 handle, fixed32 offset, int16 pair_mode,
						int16 *tracks, int16 *pairs)
{
	static VDICONIN conin = {	/*opcode*/	237,
								/*p_in*/	0,
								/*i_in*/	4,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[4];
	int16 intout[2];

	intin[0] = 255;			/* user defined */
	intin[1] = pair_mode;
	*(fixed32 *)&intin[2] = offset;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*tracks = intout[0];
	*pairs = intout[1];
}

/* GET CHARACTER BITMAP INFORMATION (239) */

void v_getbitmap_info(int16 handle, int16 index,
						fixed32 *x_advance, fixed32 *y_advance,
						fixed32 *x_offset, fixed32 *y_offset,
						int16 *width, int16 *height, void **bitmap) {
	static VDICONIN conin = {	/*opcode*/	239,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[12];

	pb.contrl = &contrl;
	pb.intin = &index;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*width = intout[0];
	*height = intout[1];
	*x_advance = *(fixed32 *)&intout[2];
	*y_advance = *(fixed32 *)&intout[4];
	*x_offset = *(fixed32 *)&intout[6];
	*y_offset = *(fixed32 *)&intout[8];
	*bitmap = *(void **)&intout[10];
}

/* INQUIRE OUTLINE FONT TEXT EXTENT (240) */

void vqt_f_extent(int16 handle, char *string, int16 *extent) {
	VDICONIN conin = {	/*opcode*/	240,		/* Nicht static! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_STRLEN + 1];
	{
		int16 *ptr = intin;
		int16 len = 0;
		while (len < MAX_VDI_STRLEN) {
			if ((*ptr++ = (int16)(uint8)(*string++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsout = (POINT16 *)extent;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INQUIRE REAL OUTLINE FONT TEXT EXTENT (240, 4200) */

void vqt_real_extent(int16 handle, int16 x, int16 y,
					char *string, int16 *extent) {
	VDICONIN conin = {	/*opcode*/	240,		/* Nicht static! */
						/*p_in*/	1,
						/*i_in*/	0,
						/*subcode*/	4200};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_STRLEN + 1];
	POINT16 ptsin;
	{
		int16 *ptr = intin;
		int16 len = 0;
		while (len < MAX_VDI_STRLEN) {
			if ((*ptr++ = (int16)(uint8)(*string++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}
	ptsin.x = x;
	ptsin.y = y;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = &ptsin;
	pb.ptsout = (POINT16 *)extent;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

void vqt_real_extent_unicode(	int16 handle,
										int16 x, int16 y,
										const uint16 *uni_string, uint32 length,
										POINT16 *extent) {
	VDICONIN conin = {/*opcode*/	240,		/* Nicht static! */
							/*p_in*/	1,
							/*i_in*/	0,
							/*subcode*/	4200};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin;
	if (length > 32767) {
		length = 32767;
	}
	conin.intin_count = (int16)length;		/* ! */
	ptsin.x = x;
	ptsin.y = y;

	pb.contrl = &contrl;
	pb.intin = (int16 *)uni_string;
	pb.ptsin = &ptsin;
	pb.ptsout = extent;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* OUTLINE FONT TEXT (241) */

void v_ftext(int16 handle, int16 x, int16 y, char *string) {
	VDICONIN conin = {	/*opcode*/	241,		/* Nicht static! */
						/*p_in*/	1,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_STRLEN + 1];
	POINT16 ptsin;
	{
		int16 *ptr = intin;
		int16 len = 0;
		while (len < MAX_VDI_STRLEN) {
			if ((*ptr++ = (int16)(uint8)(*string++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}
	ptsin.x = x;
	ptsin.y = y;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = &ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

void v_ftext_offset(int16 handle, int16 x, int16 y, char *string, int16 *offset) {
	VDICONIN conin = {	/*opcode*/	241,		/* Nicht static! */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_STRLEN + 1];
	POINT16 ptsin[MAX_VDI_STRLEN + 1];
	{
		int16 *ptr = intin;
		POINT16 *p_ptr = ptsin;
		int16 len = 0;
		p_ptr->x = x;
		(p_ptr++)->y = y;
		while (len < MAX_VDI_STRLEN) {
			if ((*ptr++ = (int16)(uint8)(*string++)) == 0) {
				break;
			}
			p_ptr->x = *offset++;
			(p_ptr++)->y = *offset++;
			len++;
		}
		conin.intin_count = len;		/* ! */
		conin.ptsin_count = len + 1;	/* ! */
	}

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* GET CHARACTER OUTLINE (243) */

void v_getoutline(int16 handle, int16 index, int16 *xyarr,
					uint8 *bezarr, int16 max_pts, int16 *count) {
	static VDICONIN conin = {	/*opcode*/	243,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];

	intin[0] = index;
	intin[1] = max_pts;
	*(int16 **)&intin[2] = xyarr;
	*(uint8 **)&intin[4] = bezarr;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = count;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* GET CHARACTER OUTLINE (NVDI 5) (243,1) */

int16 v_get_outline(int16 handle, uint16 index, int16 x_offset, int16 y_offset,
					int16 *xyarr, uint8 *bezarr, int16 max_pts) {
	static VDICONIN conin = {	/*opcode*/	243,
								/*p_in*/	0,
								/*i_in*/	8,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[8];
	int16 intout;

	intin[0] = (int16)index;
	intin[1] = max_pts;
	*(int16 **)&intin[2] = xyarr;
	*(uint8 **)&intin[4] = bezarr;
	intin[6] = x_offset;
	intin[7] = y_offset;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* SET CHARACTER HEIGHT BY ARBITRARY POINTS (246) */

fixed32 vst_arbpt32(int16 handle, fixed32 height,
					int16 *char_width, int16 *char_height,
					int16 *cell_width, int16 *cell_height) {
	static VDICONIN conin = {	/*opcode*/	246,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	fixed32 intout;
	POINT16 ptsout[2];

	pb.contrl = &contrl;
	pb.intin = (int16 *)&height;
	pb.intout = (int16 *)&intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*char_width = ptsout[0].x;
	*char_height = ptsout[0].y;
	*cell_width = ptsout[1].x;
	*cell_height = ptsout[1].y;

	return intout;
}

/* INQUIRE OUTLINE FONT TEXT ADVANCE PLACEMENT VECTOR (247) */

void vqt_advance32(int16 handle, int16 index,
					fixed32 *x_advance, fixed32 *y_advance) {
	static VDICONIN conin = {	/*opcode*/	247,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsout[4];

	pb.contrl = &contrl;
	pb.intin = &index;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*x_advance = *(fixed32 *)&ptsout[2];
	*y_advance = *(fixed32 *)&ptsout[3];
}

/* FLUSH OUTLINE FONT CACHE (251) */

int16 v_flushcache(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	251,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* SET CHARACTER CELL WIDTH BY ARBITRARY POINTS (252) */

fixed32 vst_setsize32(int16 handle, fixed32 width,
						int16 *char_width, int16 *char_height,
						int16 *cell_width, int16 *cell_height) {
	static VDICONIN conin = {	/*opcode*/	252,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	fixed32 intout;
	POINT16 ptsout[2];

	pb.contrl = &contrl;
	pb.intin = (int16 *)&width;
	pb.intout = (int16 *)&intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*char_width = ptsout[0].x;
	*char_height = ptsout[0].y;
	*cell_width = ptsout[1].x;
	*cell_height = ptsout[1].y;

	return intout;
}

/* SET OUTLINE FONT SKEW (253) */

int16 vst_skew(int16 handle, int16 skew) {
	static VDICONIN conin = {	/*opcode*/	253,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = &skew;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}


/* raster operations: */

/* COPY RASTER, OPAQUE (109) */

void vro_cpyfm(int16 handle, int16 wr_mode, POINT16 *xyarr,
				MFDB *src_MFDB, MFDB *des_MFDB) {
	static VDICONIN conin = {	/*opcode*/	109,
								/*p_in*/	4,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	*(MFDB **)&contrl.idx7 = src_MFDB;
	*(MFDB **)&contrl.idx9 = des_MFDB;

	pb.contrl = &contrl;
	pb.intin = &wr_mode;
	pb.ptsin = xyarr;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* COPY RASTER, TRANSPARENT (121) */

void vrt_cpyfm(int16 handle, int16 wr_mode, POINT16 *xyarr,
				MFDB *src_MFDB, MFDB *des_MFDB,
				int16 *color_index) {
	static VDICONIN conin = {	/*opcode*/	121,
								/*p_in*/	4,
								/*i_in*/	3,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[3];

	*(MFDB **)&contrl.idx7 = src_MFDB;
	*(MFDB **)&contrl.idx9 = des_MFDB;

	intin[0] = wr_mode;
	*(int32 *)&intin[1] = *(int32 *)color_index;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = xyarr;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* TRANSFORM FORM (110) */

void vr_trnfm(int16 handle, MFDB *src_MFDB, MFDB *des_MFDB) {
	static VDICONIN conin = {	/*opcode*/	110,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	*(MFDB **)&contrl.idx7 = src_MFDB;
	*(MFDB **)&contrl.idx9 = des_MFDB;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* GET PIXEL (105) */

void v_get_pixel(int16 handle, int16 x, int16 y, int16 *pel, int16 *index) {
	static VDICONIN conin = {	/*opcode*/	105,
								/*p_in*/	1,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[2];
	POINT16 ptsin;

	ptsin.x = x;
	ptsin.y = y;

	pb.contrl = &contrl;
	pb.ptsin = &ptsin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*pel = intout[0];
	*index = intout[1];
}

#if 0

/* input functions: */

/* SET INPUT MODE (33) */

void vsin_mode(int16 handle, int16 dev_type, int16 mode) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INPUT LOCATOR, REQUEST MODE (28) */

void vrq_locator(int16 handle, int16 x, int16 y, int16 *xout,
					int16 *yout, int16 *term) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INPUT LOCATOR, SAMPLE MODE (28) */

int16 vsm_locator(int16 handle,  int16 x,  int16 y,  int16 *xout,
					int16 *yout, int16 *term) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INPUT CHOICE, REQUEST MODE (30) */

void vrq_choice(int16 handle, int16 ch_in, int16 *ch_out) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INPUT CHOICE, SAMPLE MODE (30) */

int16 vsm_choice(int16 handle, int16 *choice) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INPUT STRING,REQUEST MODE (31) */

void vrq_string(int16 handle, int16 max_length, int16 echo_mode,
				int16 *echo_xy, char *string) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INPUT STRING,SAMPLE MODE (31) */

int32 vsm_string(int16 handle, int16 max_length, int16 echo_mode,
				int16 *echo_xy, char *string) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET MOUSE FORM (111) */

void vsc_form(int16 handle, int16 *cursor) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INQUIRE INPUT MODE (115) */

void vqin_mode(int16 handle, int16 dev_type, int16 *input_mode) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* EXCHANGE TIMER INTERRUPT VECTOR (118) */

void vex_timv(int16 handle, void *tim_addr, void **otim_addr, int16 *tim_conv) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

#endif

/* SHOW CURSOR (122) */

void v_show_c(int16 handle, int16 reset) {
	static VDICONIN conin = {	/*opcode*/	122,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = &reset;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* HIDE CURSOR (123) */

void v_hide_c(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	123,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}


#if 0

/* SAMPLE MOUSE BUTTON STATE (124) */

void vq_mouse(int16 handle, int16 *status, int16 *x, int16 *y) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* EXCHANGE BUTTON CHANGE VECTOR (125) */

void vex_butv(int16 handle, void *pusrcode, void **psavcode) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* EXCHANGE MOUSE MOVEMENT VECTOR (126) */

void vex_motv(int16 handle, void *pusrcode, void **psavcode) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* EXCHANGE CURSOR CHANGE VECTOR (127) */

void vex_curv(int16 handle, void *pusrcode, void **psavcode) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SAMPLE KEYBOARD STATE INFORMATION (128) */

void vq_key_s(int16 handle, int16 *status) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}


/* text mode and VT52: */

/* INQUIRE ADDRESSABLE ALPHA CHARACTER CELLS (5, 1) */

void vq_chcells(int16 handle, int16 *rows, int16 *columns) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* EXIT ALPHA MODE (5, 2) */

void v_exit_cur(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ENTER ALPHA MODE (5, 3) */

void v_enter_cur(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ALPHA CURSOR UP (5, 4) */

void v_curup(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ALPHA CURSOR DOWN (5, 5) */

void v_curdown(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ALPHA CURSOR RIGHT (5, 6) */

void v_curright(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ALPHA CURSOR LEFT (5, 7) */

void v_curleft(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* HOME ALPHA CURSOR (5, 8) */

void v_curhome(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ERASE TO END OF ALPHA SRCEEN (5, 9) */

void v_eeos(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* ERASE TO END OF ALPHA TEXT LINE (5, 10) */

void v_eeol(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* DIRECT ALPHA CURSOR ADDRESS (5, 11) */

void v_curaddress(int16 handle, int16 row, int16 column) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* OUTPUT CURSOR ADDRESSABLE ALPHA TEXT (5, 12) */

void v_curtext(int16 handle, char *string) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* REVERSE VIDEO ON (5, 13) */

void v_rvon(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* REVERSE VIDEO OFF (5, 14) */

void v_rvoff(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* INQUIRE CURRENT ALPHA CURCOR ADDRESS (5, 15) */

void vq_curaddress(int16 handle, int16 *row, int16 *column) {
	static VDICONIN conin = {	/*opcode*/	,
								/*p_in*/	,
								/*i_in*/	,
								/*subcode*/	};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[];
	int16 intout[];
	POINT16 ptsin[];
	POINT16 ptsout[];

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

#endif


/* printer specific functions: */

/* OUTPUT BIT IMAGE FILE (5, 23) */

void v_bit_image(int16 handle, char *name, int16 aspect,
					int16 x_scale, int16 y_scale, int16 h_align,
					int16 v_align, POINT16 *xyarray) {
	VDICONIN conin = {	/*opcode*/	5,		/* not static */
						/*p_in*/	2,
						/*i_in*/	0,
						/*subcode*/	23};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_STRLEN + 5 + 1];

	intin[0] = aspect;
	intin[1] = x_scale;
	intin[2] = y_scale;
	intin[3] = h_align;
	intin[4] = v_align;
	{
		int16 *ptr = intin + 5;
		int16 len = 5;
		while (len < MAX_VDI_STRLEN + 5) {
			if ((*ptr++ = (int16)(uint8)(*name++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = xyarray;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* SET INPUT AND OUTPUT TRAY (5, 29) */

void v_trays(int16 handle, int16 input, int16 output,
				int16 *set_input, int16 *set_output) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	29};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[2];
	int16 intout[2];

	intin[0] = input;
	intin[1] = output;

	*(long *)&intout[0] = 0;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*set_input = intout[0];
	*set_output = intout[1];
}

/* INQUIRE TRAY NAMES (5, 36) */

void vq_tray_names(int16 handle, char *input_name,
					char *output_name, int16 *input, int16 *output) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	4,
								/*subcode*/	36};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[4];
	int16 intout[2];

	*(char **)&intin[0] = input_name;
	*(char **)&intin[2] = output_name;

	*(long *)&intout[0] = 0;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*input = intout[0];
	*output = intout[1];
}

/* SET PAGE SIZE (5, 37) */

int16 v_page_size(int16 handle, int16 page_id) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	37};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout = 0;

	pb.contrl = &contrl;
	pb.intin = &page_id;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* INQUIRE PAGE NAME (5, 38) */

int16 vq_page_name(int16 handle, int16 page_id, char *page_name,
					int32 *page_width, int32 *page_height) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	3,
								/*subcode*/	38};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[3];
	int16 intout[5];

	intin[0] = page_id;
	*(char **)&intin[1] = page_name;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*page_width = *(int32 *)&intout[1];
	*page_height = *(int32 *)&intout[3];

	return intout[0];
}

/* ESCAPE 2000 (5, 2000) */

void v_escape2000(int16 handle, int16 times) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	2000};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = &times;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}


/* metafile specific functions: */

/* UPDATE METAFILE EXTENTS (5, 98) */

void v_meta_extents(int16 handle, int16 x_min, int16 y_min,
					int16 x_max, int16 y_max) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	2,
								/*i_in*/	0,
								/*subcode*/	98};
	XVDIPB pb;
	VDICONTRL contrl;
	POINT16 ptsin[2];

	ptsin[0].x = x_min;
	ptsin[0].y = y_min;
	ptsin[1].x = x_max;
	ptsin[1].y = y_max;

	pb.contrl = &contrl;
	pb.ptsin = ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* WRITE METAFILE ITEM (5, 99) */

void v_write_meta(int16 handle, int16 num_intin, int16 *a_intin,
					int16 num_ptsin, POINT16 *a_ptsin) {
	VDICONIN conin = {	/*opcode*/	5,		/* not static */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	99};
	XVDIPB pb;
	VDICONTRL contrl;

	conin.ptsin_count = num_ptsin;
	conin.intin_count = num_intin;

	pb.contrl = &contrl;
	pb.intin = a_intin;
	pb.ptsin = a_ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* PHYSICAL PAGE SIZE (5, 99, 0) */

void vm_pagesize(int16 handle, int16 pgwidth, int16 pgheight) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	3,
								/*subcode*/	99};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[3];

	intin[0] = 0;
	intin[1] = pgwidth;
	intin[2] = pgheight;

	pb.contrl = &contrl;
	pb.intin = intin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* COORDINATE WINDOW (5, 99, 1) */

void vm_coords(int16 handle, int16 llx, int16 lly, int16 urx, int16 ury) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	5,
								/*subcode*/	99};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[5];

	intin[0] = 1;
	intin[1] = llx;
	intin[2] = lly;
	intin[3] = urx;
	intin[4] = ury;

	pb.contrl = &contrl;
	pb.intin = intin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* CHANGE GEM VDI FILE NAME (5, 100) */

void vm_filename(int16 handle, char *filename) {
	VDICONIN conin = {	/*opcode*/	5,		/* not static */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	100};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_STRLEN + 1];
	{
		int16 *ptr = intin;
		int16 len = 0;
		while (len < MAX_VDI_STRLEN) {
			if ((*ptr++ = (int16)(uint8)(*filename++)) == 0) {
				break;
			}
			len++;
		}
		conin.intin_count = len;	/* ! */
	}

	pb.contrl = &contrl;
	pb.intin = intin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}


/* NVDI 5: */


/* set foreground color compatible to GEM/3-Metafiles */
extern C_CALL void v_setrgb(int16 handle, int16 type, int16 r, int16 g, int16 b) {
	VDICONIN conin = {	/*opcode*/	138,	/* not static */
						/*p_in*/	0,
						/*i_in*/	3,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[3];

	intin[0] = r;
	intin[1] = g;
	intin[2] = b;

	conin.subcode = type;	/* ! */

	pb.contrl = &contrl;
	pb.intin = intin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* set foreground color */
extern C_CALL int16 vst_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	200,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *fg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vsf_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	200,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *fg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vsl_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	200,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *fg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vsm_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	200,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *fg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vsr_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	200,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	4};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *fg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* set background color */
extern C_CALL int16 vst_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	201,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *bg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vsf_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	201,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *bg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vsl_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	201,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *bg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vsm_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	201,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *bg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vsr_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	201,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	4};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *bg_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* inquire foreground color */
extern C_CALL int32 vqt_fg_color(int16 handle, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	202,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*fg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vqf_fg_color(int16 handle, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	202,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*fg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vql_fg_color(int16 handle, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	202,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*fg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vqm_fg_color(int16 handle, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	202,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*fg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vqr_fg_color(int16 handle, COLOR_ENTRY *fg_color) {
	static VDICONIN conin = {	/*opcode*/	202,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	4};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*fg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}

/* inquire background color */
extern C_CALL int32 vqt_bg_color(int16 handle, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	203,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*bg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vqf_bg_color(int16 handle, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	203,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*bg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vql_bg_color(int16 handle, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	203,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*bg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vqm_bg_color(int16 handle, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	203,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*bg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vqr_bg_color(int16 handle, COLOR_ENTRY *bg_color) {
	static VDICONIN conin = {	/*opcode*/	203,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	4};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*bg_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}

/* diverse Modi parametrisieren */
extern C_CALL int16 vs_hilite_color(int16 handle, int32 color_space, COLOR_ENTRY *hilite_color) {
	static VDICONIN conin = {	/*opcode*/	207,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *hilite_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vs_min_color(int16 handle, int32 color_space, COLOR_ENTRY *min_color) {
	static VDICONIN conin = {	/*opcode*/	207,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *min_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vs_max_color(int16 handle, int32 color_space, COLOR_ENTRY *max_color) {
	static VDICONIN conin = {	/*opcode*/	207,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *max_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vs_weight_color(int16 handle, int32 color_space, COLOR_ENTRY *weight_color) {
	static VDICONIN conin = {	/*opcode*/	207,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *weight_color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

extern C_CALL int32 vq_hilite_color(int16 handle, COLOR_ENTRY *hilite_color) {
	static VDICONIN conin = {	/*opcode*/	209,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*hilite_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vq_min_color(int16 handle, COLOR_ENTRY *min_color) {
	static VDICONIN conin = {	/*opcode*/	209,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*min_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vq_max_color(int16 handle, COLOR_ENTRY *max_color) {
	static VDICONIN conin = {	/*opcode*/	209,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*max_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vq_weight_color(int16 handle, COLOR_ENTRY *weight_color) {
	static VDICONIN conin = {	/*opcode*/	209,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*weight_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}

/* colors, pixel format */
extern C_CALL uint32 v_color2value(int16 handle, int32 color_space, COLOR_ENTRY *color) {
	static VDICONIN conin = {	/*opcode*/	204,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	uint32 intout;

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = (int16 *)&intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int32 v_value2color(int16 handle, uint32 value, COLOR_ENTRY *color) {
	static VDICONIN conin = {	/*opcode*/	204,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intin = (int16 *)&value;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*color = *(COLOR_ENTRY *)&intout[2];
	return *(int32 *)&intout[0];
}
extern C_CALL int32 v_color2nearest(int16 handle, int32 color_space, COLOR_ENTRY *color, COLOR_ENTRY *nearest_color) {
	static VDICONIN conin = {	/*opcode*/	204,
								/*p_in*/	0,
								/*i_in*/	6,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[6];
	int16 intout[6];

	*(int32 *)&intin[0] = color_space;
	*(COLOR_ENTRY *)&intin[2] = *color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*nearest_color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vq_px_format(int16 handle, uint32 *px_format) {
	static VDICONIN conin = {	/*opcode*/	204,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int32 intout[2];

	pb.contrl = &contrl;
	pb.intout = (int16 *)intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*px_format = (uint32)intout[1];

	return intout[0];
}

/* color tables */
extern C_CALL int16 vs_ctab(int16 handle, COLOR_TAB *ctab) {
	VDICONIN conin = {	/*opcode*/	205,		/* not static */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	conin.intin_count = (int16)(ctab->length / 2);	/* ! */

	pb.contrl = &contrl;
	pb.intin = (int16 *)ctab;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vs_ctab_entry(int16 handle, int16 index, int32 color_space, COLOR_ENTRY *color) {
	static VDICONIN conin = {	/*opcode*/	205,
								/*p_in*/	0,
								/*i_in*/	7,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[7];
	int16 intout;

	intin[0] = index;
	*(int32 *)&intin[1] = color_space;
	*(COLOR_ENTRY *)&intin[3] = *color;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vs_dflt_ctab(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	205,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

extern C_CALL int16 vq_ctab(int16 handle, int32 ctab_length, COLOR_TAB *ctab) {
	static VDICONIN conin = {	/*opcode*/	206,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = (int16 *)&ctab_length;
	pb.intout = (int16 *)ctab;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return (contrl.intout_count != 0);
}
extern C_CALL int32 vq_ctab_entry(int16 handle, int16 index, COLOR_ENTRY *color) {
	static VDICONIN conin = {	/*opcode*/	206,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[6];

	pb.contrl = &contrl;
	pb.intin = &index;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*color = *(COLOR_ENTRY *)&intout[2];

	return *(int32 *)&intout[0];
}
extern C_CALL int32 vq_ctab_id(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	206,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	2};
	XVDIPB pb;
	VDICONTRL contrl;
	int32 intout;

	pb.contrl = &contrl;
	pb.intout = (int16 *)&intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 v_ctab_idx2vdi(int16 handle, int16 index) {
	static VDICONIN conin = {	/*opcode*/	206,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	3};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = &index;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 v_ctab_vdi2idx(int16 handle, int16 vdi_index) {
	static VDICONIN conin = {	/*opcode*/	206,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	4};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = &vdi_index;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL uint32 v_ctab_idx2value(int16 handle, int16 index) {
	static VDICONIN conin = {	/*opcode*/	206,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	5};
	XVDIPB pb;
	VDICONTRL contrl;
	uint32 intout;

	pb.contrl = &contrl;
	pb.intin = &index;
	pb.intout = (int16 *)&intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int32 v_get_ctab_id(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	206,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	6};
	XVDIPB pb;
	VDICONTRL contrl;
	int32 intout;

	pb.contrl = &contrl;
	pb.intout = (int16 *)&intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 vq_dflt_ctab(int16 handle, int32 ctab_length, COLOR_TAB *ctab) {
	static VDICONIN conin = {	/*opcode*/	206,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	7};
	XVDIPB pb;
	VDICONTRL contrl;

	pb.contrl = &contrl;
	pb.intin = (int16 *)&ctab_length;
	pb.intout = (int16 *)ctab;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return (contrl.intout_count != 0);
}

/* inverse color tables */
extern C_CALL ITAB_REF v_create_itab(int16 handle, COLOR_TAB *ctab, int16 bits) {
	static VDICONIN conin = {	/*opcode*/	208,
								/*p_in*/	0,
								/*i_in*/	5,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[5];
	ITAB_REF intout;

	*(COLOR_TAB **)&intin[0] = ctab;
	intin[2] = bits;
	*(int32 *)&intin[3] = 0;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = (int16 *)&intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 v_delete_itab(int16 handle, ITAB_REF itab) {
	static VDICONIN conin = {	/*opcode*/	208,
								/*p_in*/	0,
								/*i_in*/	2,
								/*subcode*/	1};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout;

	pb.contrl = &contrl;
	pb.intin = (int16 *)&itab;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}

/* bitmap output */
extern C_CALL void vr_transfer_bits(int16 handle, GCBITMAP *src_bm, GCBITMAP *dst_bm,
									POINT16 *src_rect, POINT16 *dst_rect,
									int16 mode) {
	static VDICONIN conin = {	/*opcode*/	170,
								/*p_in*/	4,
								/*i_in*/	4,
								/*subcode*/	0};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[4];
	RECT16 ptsin[2];

	intin[0] = mode;
	intin[1] = 0;
	*(int32 *)&intin[2] = 0;

	ptsin[0] = *(RECT16 *)src_rect;
	ptsin[1] = *(RECT16 *)dst_rect;

	*(GCBITMAP **)&contrl.idx7 = src_bm;
	*(GCBITMAP **)&contrl.idx9 = dst_bm;
	*(int32 *)&contrl.idx11 = 0;

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.ptsin = (POINT16 *)ptsin;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);
}

/* printer */
extern C_CALL int16 v_orient(int16 handle, int16 orient) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	27};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout = 0;

	pb.contrl = &contrl;
	pb.intin = &orient;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL int16 v_copies(int16 handle, int16 copies) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	1,
								/*subcode*/	28};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout = 0;

	pb.contrl = &contrl;
	pb.intin = &copies;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
extern C_CALL fixed32 vq_prn_scaling(int16 handle) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	3,
								/*subcode*/	39};
	XVDIPB pb;
	VDICONTRL contrl;
	int32 intin = -1L;
	int32 intout = -1L;

	pb.contrl = &contrl;
	pb.intin = (int16 *)&intin;
	pb.intout = (int16 *)&intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return (fixed32)intout;
}
extern C_CALL int16 vq_margins(int16 handle, int16 *top_margin, int16 *bottom_margin,
								int16 *left_margin, int16 *right_margin, int16 *hdpi, int16 *vdpi) {
	static VDICONIN conin = {	/*opcode*/	5,
								/*p_in*/	0,
								/*i_in*/	0,
								/*subcode*/	2100};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intout[7];

	pb.contrl = &contrl;
	pb.intout = intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	*top_margin = intout[1];
	*bottom_margin = intout[2];
	*left_margin = intout[3];
	*right_margin = intout[4];
	*hdpi = intout[5];
	*vdpi = intout[6];

	return intout[0];
}
extern C_CALL int16 vs_document_info(int16 handle, int16 type, void *s, int16 wchar) {
	VDICONIN conin = {	/*opcode*/	5,			/* not static */
						/*p_in*/	0,
						/*i_in*/	0,
						/*subcode*/	2103};
	XVDIPB pb;
	VDICONTRL contrl;
	int16 intin[MAX_VDI_STRLEN + 1 + 1];
	int16 intout;
	{
		int16 *ptr = intin;
		int16 len = 1;
		*ptr++ = type;
		if (wchar) {
			int16 *s_ptr = (int16 *)s;
			while (len < MAX_VDI_STRLEN) {
				if ((*ptr++ = *s_ptr++) == 0) {
					break;
				}
				len++;
			}
		} else {
			char *s_ptr = (char *)s;
			while (len < MAX_VDI_STRLEN) {
				if ((*ptr++ = (int16)(uint8)(*s_ptr++)) == 0) {
					break;
				}
				len++;
			}
		}
		conin.intin_count = len;	/* ! */
	}

	pb.contrl = &contrl;
	pb.intin = intin;
	pb.intout = &intout;

	contrl.handle = handle;

	mt_vdi(&pb, &conin);

	return intout;
}
