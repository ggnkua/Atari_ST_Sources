/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "vdi.h"
#include <vdibind.h>
#include <aesbind.h>
#include <osbind.h>
#include <values.h>

#include <stdio.h>


static const int NWI=11;
static const int NWO=57;

// Flags.
//
//  Top 1 bit signals that fonts are loaded.
//  Next 7 bits are total # fonts.
//  Low 8 bits are for device type.
//
#define SCREENVDI (Getrez()+2)
static const int METAVDI=31;
static const int FONTS_LOADED=0x8000;

// SpeedoGDOS does not return correct value for WorkOut(10).
static const int NUM_FONTS=0x7f00;
static const int NUM_FONTS_SHIFT=8;

static const int DEVICE_TYPE=0x00ff;

static int STDWORKIN[]={9999,1,1,1,1,1,1,1,1,1,2};

// NWO * sizeof(int) bytes for each cache cell.
// But only when actually used.
//
static const NUM_WORKOUT_CACHE=16;

class WorkOut_CacheCell {
public:
	WorkOut_CacheCell() :
		owner(0),
		workout(0),
		extend(FALSE)
	{
	}

	const VDI* owner;
	int* workout;
	bool extend;
};

static WorkOut_CacheCell WORKOUT_CACHE[NUM_WORKOUT_CACHE];

int* WORKOUTfor(const VDI* vdi, bool ext, bool fill_if_new_array)
{
	// Check most-recently-used cache first.

	static int index=0;

	for (int i=0; i<NUM_WORKOUT_CACHE; i++) {
		if (WORKOUT_CACHE[index].owner==vdi && WORKOUT_CACHE[index].extend==ext) {
			return WORKOUT_CACHE[index].workout;
		}
		index=(index+1)%NUM_WORKOUT_CACHE;
	}

	// Not found.  Reuse old cell belonging to a DIFFERENT VDI.

	// Terminates since at most 1 has this owner, since we
	// can never get two caches with same (owner,extend).
	//
	while (WORKOUT_CACHE[index].owner==vdi) {
		index=(index+1)%NUM_WORKOUT_CACHE;
	}

	WORKOUT_CACHE[index].owner=vdi;
	if (!WORKOUT_CACHE[index].workout)
		WORKOUT_CACHE[index].workout=new int[NWO];

	if (fill_if_new_array)
		vdi->q_extnd(ext,WORKOUT_CACHE[index].workout);

	WORKOUT_CACHE[index].extend=ext;

	return WORKOUT_CACHE[index].workout;
}

void DeleteWORKOUTfor(const VDI* vdi)
{
	for (int i=0; i<NUM_WORKOUT_CACHE; i++) {
		if (WORKOUT_CACHE[i].owner==vdi) {
			delete WORKOUT_CACHE[i].workout;
			WORKOUT_CACHE[i].workout=0;
			WORKOUT_CACHE[i].owner=0;
		}
	}
}


enum GDOStype { GDOS_UNKNOWN=-1, NoGDOS=0, OutlineGDOS, FontGDOS, EarlyGDOS };

static GDOStype GDOS_available()
{
	static GDOStype gdos_active=GDOS_UNKNOWN;

	if (gdos_active==GDOS_UNKNOWN) {
		switch (vq_vgdos()) {
		 case GDOS_NONE:
			gdos_active = NoGDOS; // Or other dyslexic pets? :)
		break; case GDOS_FSM:
			gdos_active = OutlineGDOS;
		break; case GDOS_FNT:
			gdos_active = FontGDOS;
		break; default:
			gdos_active = EarlyGDOS;
		}
	}

	return gdos_active;
}

static MFDB AESMFDB;



VDI::VDI()
{
	flags=SCREENVDI;

	int j;
	handle=graf_handle(&j,&j,&j,&j);

	STDWORKIN[0]=flags&DEVICE_TYPE;

	int ihandle=handle;
	v_opnvwk(STDWORKIN,&ihandle,WORKOUTfor(this,FALSE,FALSE));
	handle=ihandle;
	AESMFDB.fd_addr=0;
}

VDI::VDI(const char* metafile) :
	flags(METAVDI)
{
	if (vq_vgdos()==GDOS_NONE) {
		handle=0;
	} else {
		int ihandle;
		int WORKIN[NWI]=STDWORKIN;

		WORKIN[0]=flags;
		//WORKIN[10]=0;

		v_opnwk(WORKIN,&ihandle,WORKOUTfor(this,FALSE,FALSE));
		handle=ihandle;

		if (strcmp(metafile,"GEMFILE.GEM")!=0) {
			m_filename(metafile);
			Fdelete("GEMFILE.GEM");
		}
	}
}

VDI::~VDI()
{
	st_unload_fonts();

	if (flags<=10) {
		v_clsvwk(handle);
	} else {
		v_clswk(handle);
	}

	DeleteWORKOUTfor(this);
}

void VDI::clrwk() { v_clrwk(handle); }
void VDI::updwk() { v_updwk(handle); }
int VDI::swr_mode (int mode) { return vswr_mode (handle, mode); }
void VDI::s_color (int index, int rgb[]) { vs_color (handle, index, rgb); }
int VDI::sl_type (int style) { return vsl_type (handle, style); }
void VDI::sl_udsty (int pat) { vsl_udsty (handle, pat); }
int VDI::sl_width (int width) { return vsl_width (handle, width); }
int VDI::sl_color (int index) { return vsl_color (handle, index); }
void VDI::sl_ends (int begstyle, int endstyle) { vsl_ends (handle, begstyle, endstyle); }
int VDI::sm_type (int symbol) { return vsm_type (handle, symbol); }
void VDI::sm_height (int height) { vsm_height (handle, height); }
int VDI::sm_color (int index) { return vsm_color (handle, index); }
int VDI::st_height (int height, int *charw, int *charh, int *cellw, int *cellh) { return vst_height (handle, height, charw, charh, cellw, cellh); }
int VDI::st_point (int point, int *charw, int *charh, int *cellw, int *cellh) { return vst_point (handle, point, charw, charh, cellw, cellh); }
int VDI::st_rotation (int ang) { return vst_rotation (handle, ang); }
int VDI::st_font (int font) { return vst_font (handle, font); }
int VDI::st_color (int index) { return vst_color (handle, index); }
int VDI::st_effects (int effects) { return vst_effects (handle, effects); }
void VDI::st_alignment (int hin, int vin, int *hout, int *vout) { vst_alignment (handle, hin, vin, hout, vout); } 
int VDI::sf_interior (int style) { return vsf_interior (handle, style); }
int VDI::sf_fill (int style) { return vsf_fill (handle, style); }
int VDI::sf_style (int style) { return vsf_style (handle, style); }
int VDI::sf_color (int index) { return vsf_color (handle, index); }
int VDI::sf_perimeter (int vis) { return vsf_perimeter (handle, vis); }
void VDI::sf_udpat (int pat[], int planes) { vsf_udpat (handle, pat, planes); }

int VDI::st_load_fonts (int select)
{
	if (GDOS_available()) {
		if ((flags&FONTS_LOADED) == 0) {
			flags^=FONTS_LOADED;
			int numfonts = WorkOut(15);
			int extrafonts = vst_load_fonts (handle, select);
			numfonts+=extrafonts;
			if (numfonts>(NUM_FONTS>>NUM_FONTS_SHIFT)) {
				flags|=NUM_FONTS;
			} else {
				flags|=(numfonts<<NUM_FONTS_SHIFT);
			}
			return extrafonts;
		}
	}

	return 0;
}

void VDI::st_unload_fonts (int select)
{
	if ((flags&FONTS_LOADED) != 0) {
		flags^=FONTS_LOADED;
		flags&=~NUM_FONTS;
		vst_unload_fonts (handle, select);
	}
}

int VDI::NumberOfTextFaces() const
{
	if ((flags&FONTS_LOADED) == 0) {
		return WorkOut(15);
	} else {
		return (flags&NUM_FONTS)>>NUM_FONTS_SHIFT;
	}
}

void VDI::s_clip (int clip_flag, int pxyarray[]) { vs_clip (handle, clip_flag, pxyarray); }

void VDI::bar (int pxyarray[]) { v_bar (handle, pxyarray); }
void VDI::arc (int x, int y, int radius, int begang, int endang) { v_arc (handle, x, y, radius, begang, endang); } 
void VDI::pieslice (int x, int y, int radius, int begang, int endang) { v_pieslice (handle, x, y, radius, begang, endang); }
void VDI::circle (int x, int y, int radius) { v_circle (handle, x, y, radius); }
void VDI::ellarc (int x, int y, int xrad, int yrad, int begang, int endang) { v_ellarc (handle, x, y, xrad, yrad, begang, endang); }
void VDI::ellpie (int x, int y, int xrad, int yrad, int begang, int endang) { v_ellpie (handle, x, y, xrad, yrad, begang, endang); }
void VDI::ellipse (int x, int y, int xrad, int yrad) { v_ellipse (handle, x, y, xrad, yrad); }
void VDI::rbox (int pxyarray[]) { v_rbox (handle, pxyarray); }
void VDI::rfbox (int pxyarray[]) { v_rfbox (handle, pxyarray); }
void VDI::justified (int x, int y, char *str, int len, int word_space, int char_space) { v_justified (handle, x, y, str, len, word_space, char_space); }

int VDI::sin_mode  (int dev, int mode) { return vsin_mode  (handle, dev, mode); }
void VDI::rq_locator (int x, int y, int *xout, int *yout, int *term) { vrq_locator (handle, x, y, xout, yout, term); }  
int VDI::sm_locator (int x, int y, int *xout, int *yout, int *term) { return vsm_locator (handle, x, y, xout, yout, term); }

void VDI::rq_valuator (int in, int *out, int *term) { vrq_valuator (handle, in, out, term); }
void VDI::sm_valuator (int in, int *out, int *term, int *status) { vsm_valuator (handle, in, out, term, status); }
void VDI::rq_choice (int cin, int *cout) { vrq_choice (handle, cin, cout); }
int VDI::sm_choice (int *choice) { return vsm_choice (handle, choice); }
void VDI::rq_string (int len, int echo, int echoxy[], char *str) { vrq_string (handle, len, echo, echoxy, str); }
int VDI::sm_string (int len, int echo, int echoxy[], char *str) { return vsm_string (handle, len, echo, echoxy, str); }
void VDI::sc_form (int form[]) { vsc_form (handle, form); }
void VDI::ex_timv (void *time_addr, void **otime_addr, int *time_conv) { vex_timv (handle, time_addr, otime_addr, time_conv); } 
void VDI::show_c (int reset) { v_show_c (handle, reset); }
void VDI::hide_c () { v_hide_c (handle); }
void VDI::q_mouse (int *pstatus, int *x, int *y) { vq_mouse (handle, pstatus, x, y); }
void VDI::ex_butv (void *new_p, void **old) { vex_butv (handle, new_p, old); }
void VDI::ex_motv (void *new_p, void **old) { vex_motv (handle, new_p, old); }
void VDI::ex_curv (void *new_p, void **old) { vex_curv (handle, new_p, old); }
void VDI::q_key_s (int *state) { vq_key_s (handle, state); }

void VDI::q_extnd (int flag, int work_out[]) const { vq_extnd (handle, flag, work_out); }
int VDI::q_color (int index, int flag, int rgb[]) const { return vq_color (handle, index, flag, rgb); }
void VDI::ql_attribute (int atrib[]) const { vql_attribute (handle, atrib); }
void VDI::qm_attributes (int atrib[]) const { vqm_attributes (handle, atrib); }
void VDI::qf_attributes (int atrib[]) const { vqf_attributes (handle, atrib); }
void VDI::qt_attributes (int atrib[]) const { vqt_attributes (handle, atrib); }
void VDI::qt_extent (char *str, int extent[]) const { vqt_extent (handle, str, extent); }
int VDI::qt_width (int chr, int *cw, int *ldelta, int *rdelta) const { return vqt_width (handle, chr, cw, ldelta, rdelta); }
int VDI::qt_name (int element, char *name) const { return vqt_name (handle, element, name); }
void VDI::q_cellarray (int pxyarray[], int row_len, int nrows, int *el_used, int *rows_used, int *status, int color[]) { vq_cellarray (handle, pxyarray, row_len, nrows, el_used, rows_used, status, color); }  
void VDI::qin_mode (int dev, int *mode) { vqin_mode (handle, dev, mode); }
void VDI::qt_fontinfo (int *minade, int *maxade, int distances[], int *maxwidth, int effects[]) { vqt_fontinfo (handle, minade, maxade, distances, maxwidth, effects); }  
void VDI::qt_font_info (int *minade, int *maxade, int distances[], int *maxwidth, int effects[]) { vqt_font_info (handle, minade, maxade, distances, maxwidth, effects); }  

void VDI::pline (int count, int pxyarray[]) { v_pline (handle, count, pxyarray); }
void VDI::pmarker (int count, int pxyarray[]) { v_pmarker (handle, count, pxyarray); }
int VDI::gtext (int x, int y, char *str) { return v_gtext (handle, x, y, str); }
void VDI::fillarea (int count, int pxyarray[]) { v_fillarea (handle, count, pxyarray); }
void VDI::cellarray (int pxyarray[], int row_length, int elements, int nrows, int write_mode, int colarray[]) { v_cellarray (handle, pxyarray, row_length, elements, nrows, write_mode, colarray); }
void VDI::contourfill (int x, int y, int index) { v_contourfill (handle, x, y, index); }
void VDI::r_recfl (int pxyarray[]) { vr_recfl (handle, pxyarray); }

void VDI::ro_cpyfm (int mode, int pxyarray[], const MFDB& src, const MFDB& dst) { vro_cpyfm (handle, mode, pxyarray, (MFDB*)&src, (MFDB*)&dst); }
void VDI::rt_cpyfm (int mode, int pxyarray[], const MFDB& src, const MFDB& dst, int color[]) { vrt_cpyfm (handle, mode, pxyarray, (MFDB*)&src, (MFDB*)&dst, color); }  
void VDI::r_trnfm (const MFDB& src, const MFDB& dst) { vr_trnfm (handle, (MFDB*)&src, (MFDB*)&dst); }
void VDI::get_pixel (int x, int y, int *pel, int *indx) { v_get_pixel (handle, x, y, pel, indx); } 

void VDI::q_chcells (int *n_rows, int *n_cols) { vq_chcells (handle, n_rows, n_cols); }
void VDI::exit_cur () { v_exit_cur (handle); }
void VDI::enter_cur () { v_enter_cur (handle); }
void VDI::curup () { v_curup (handle); }
void VDI::curdown () { v_curdown (handle); }
void VDI::curright () { v_curright (handle); }
void VDI::curleft () { v_curleft (handle); }
void VDI::curhome () { v_curhome (handle); }
void VDI::eeos () { v_eeos (handle); }
void VDI::eeol () { v_eeol (handle); }
void VDI::s_curaddress (int row, int col) { vs_curaddress (handle, row, col); }
void VDI::curtext (char *s) { v_curtext (handle, s); }
void VDI::rvon () { v_rvon (handle); }
void VDI::rvoff () { v_rvoff (handle); }
void VDI::q_curaddress (int *cur_row, int *cur_col) { vq_curaddress (handle, cur_row, cur_col); }
int VDI::q_tabstatus () { return vq_tabstatus (handle); }
void VDI::hardcopy () { v_hardcopy (handle); }
void VDI::dspcur  (int x, int y) { v_dspcur  (handle, x, y); }
void VDI::rmcur () { v_rmcur (handle); }
void VDI::form_adv () { v_form_adv (handle); }
void VDI::output_window (int *pxyarray) { v_output_window (handle, pxyarray); }
void VDI::clear_disp_list () { v_clear_disp_list (handle); }
void VDI::bit_image (const char *filename, int aspect, int x_scale, int y_scale, int h_align, int v_align, int *pxyarray) { v_bit_image (handle, filename, aspect, x_scale, y_scale, h_align, v_align, pxyarray); }
void VDI::q_scan (int *g_slice, int *g_page, int *a_slice, int *a_page, int *div_fac) { vq_scan (handle, g_slice, g_page, a_slice, a_page, div_fac); }
void VDI::alpha_text (const char *string) { v_alpha_text (handle, string); }
int VDI::s_palette (int palette) { return vs_palette (handle, palette); }
void VDI::sound (int frequency, int duration) { v_sound (handle, frequency, duration); }
int VDI::s_mute (int action) { return vs_mute (handle, action); }
void VDI::t_resolution (int xres, int yres, int *xset, int *yset) { vt_resolution (handle, xres, yres, xset, yset); }
void VDI::t_axis (int xres, int yres, int *xset, int *yset) { vt_axis (handle, xres, yres, xset, yset); }
void VDI::t_origin (int xorigin, int yorigin) { vt_origin (handle, xorigin, yorigin); }
void VDI::q_dimensions (int *xdimension, int *ydimension) { vq_dimensions (handle, xdimension, ydimension); }
void VDI::t_alignment (int dx, int dy) { vt_alignment (handle, dx, dy); }
void VDI::sp_film (int index, int lightness) { vsp_film (handle, index, lightness); }
int VDI::qp_filmname (int index, char *name) { return vqp_filmname (handle, index, name); }
void VDI::sc_expose (int state) { vsc_expose (handle, state); }
void VDI::meta_extents (int min_x, int min_y, int max_x, int max_y) { v_meta_extents (handle, min_x, min_y, max_x, max_y); }
void VDI::write_meta (int num_intin, int *a_intin, int num_ptsin, int *a_ptsin) { v_write_meta (handle, num_intin, a_intin, num_ptsin, a_ptsin); }
void VDI::m_pagesize (int pgwidth, int pgheight) { vm_pagesize (handle, pgwidth, pgheight); }
void VDI::m_coords (int llx, int lly, int urx, int ury) { vm_coords (handle, llx, lly, urx, ury); }
void VDI::m_filename (const char *filename) { vm_filename (handle, filename); }
void VDI::escape2000 (int times) { v_escape2000 (handle, times); }
unsigned long VDI::q_vgdos () { return vq_vgdos (); }
void VDI::getbitmap_info (int ch, long *advancex, long *advancey, long *xoffset, long *yoffset, int *width, int *height, short **bitmap) { v_getbitmap_info (handle, ch,  advancex, advancey, xoffset, yoffset, width, height, bitmap); }
void VDI::qt_f_extent (const char *str, int extent[]) { vqt_f_extent (handle, str, extent); }
void VDI::ftext (int x, int y, const char *str) { v_ftext (handle, x, y, str); }
//void VDI::killoutline (void *component) { v_killoutline (handle, component); }
void VDI::getoutline (int ch, int *xyarray, char *bezarray, int maxverts, int *numverts) { v_getoutline (handle, ch, xyarray, bezarray, maxverts, numverts); }
void VDI::st_scratch (int mode) { vst_scratch (handle, mode); }
void VDI::st_error (int mode, short *errorvar) { vst_error (handle, mode, errorvar); }
int VDI::st_arbpt (int point, int *wchar, int *hchar, int *wcell, int *hcell ) { return vst_arbpt (handle, point, wchar, hchar, wcell, hcell ); }
void VDI::qt_advance (int ch, int *xadv, int *yadv, int *xrem, int *yrem) { vqt_advance (handle, ch, xadv, yadv, xrem, yrem); } 
void VDI::qt_devinfo (int device, int *isdev, char *drivername ) { vqt_devinfo (handle, device, isdev, drivername ); }
int VDI::savecache (char *filename ) { return v_savecache (handle, filename ); }
int VDI::loadcache (char *filename, int mode ) { return v_loadcache (handle, filename, mode ); }
int VDI::flushcache () { return v_flushcache (handle); }
int VDI::st_setsize (int point, int *wchar, int *hchar, int *wcell, int *hcell ) { return vst_setsize (handle, point, wchar, hchar, wcell, hcell ); }
int VDI::st_skew (int skew ) { return vst_skew (handle, skew ); }
// void VDI::qt_get_tables (void **gascii, void **style ) { vqt_get_tables (handle, gascii, style ); }
void VDI::qt_get_table (short **map) { vqt_get_table (handle, map ); }
void VDI::qt_cachesize (int which_cache, size_t *size ) { vqt_cachesize (handle, which_cache, size ); }
int VDI::bez (int count, int *xyarr, char *bezarr, int extent[4], int *npts, int *nmvs) { return v_bez (handle, count, xyarr, bezarr, extent, npts, nmvs); }
int VDI::bez_fill (int count, int *xyarr, char *bezarr, int extent[4], int *npts, int *nmvs) { return v_bez_fill (handle, count, xyarr, bezarr, extent, npts, nmvs); }
int VDI::bez_qual (int percent, int *actual) { return v_bez_qual (handle, percent, actual); }
int VDI::bez_on () { return v_bez_on (handle); }
void VDI::bez_off () { v_bez_off (handle); }

void VDI::shtext (int wsid, int x, int y, const char *text, int color, int xshadow, int yshadow ) { v_shtext (wsid, x, y, text, color, xshadow, yshadow ); }
void VDI::set_app_buff (void **buf_p, int size) { v_set_app_buff (buf_p, size); }

// Shorthands...
int  VDI::st_height(int height)
{
	int j;
	return st_height(height,&j,&j,&j,&j);
}

int	 VDI::st_point(int point)
{
	int j;
	return st_point(point,&j,&j,&j,&j);
}

void VDI::st_alignment(int hin, int vin)
{
	st_alignment(hin,vin,&hin,&vin);
}


void VDI::clip()
{
	int j[]={0,0,MaxX(),MaxY()};
	s_clip(1,j);
}

void VDI::clip(int x1, int y1, int x2, int y2)
{
	int j[]={x1,y1,x2,y2};
	s_clip(1,j);
}

void VDI::clip_off()
{
	static int j[]={0,0,0,0};
	s_clip(0,j);
}


void VDI::bar(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	bar(pxy);
}

void VDI::rbox(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	rbox(pxy);
}

void VDI::rfbox(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	rfbox(pxy);
}

void VDI::line(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	pline(2,pxy);
}

void VDI::marker(int x, int y)
{
	int pxy[]={x,y};
	pmarker(1,pxy);
}

void VDI::r_recfl(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	r_recfl(pxy);
}


void VDI::ro_cpyfm (int mode, int pxyarray[], VDI& from)
{
	ro_cpyfm(mode,pxyarray,from.MF(),MF());
}

void VDI::rt_cpyfm (int mode, int pxyarray[], VDI& from, int color[])
{
	rt_cpyfm(mode,pxyarray,from.MF(),MF(),color);
}
  
void VDI::r_trnfm (VDI& from)
{
	r_trnfm(from.MF(),MF());
}

void VDI::ro_cpyfm(int mode, int pxyarray[])
{
	ro_cpyfm(mode,pxyarray,MF(),MF());
}

void VDI::rt_cpyfm(int mode, int pxyarray[], int color[])
{
	rt_cpyfm(mode,pxyarray,MF(),MF(),color);
}

void VDI::r_trnfm()
{
	r_trnfm(MF(),MF());
}


int VDI::CharWidth() const
{
	int settings[10];

	qt_attributes(settings);
	
	return settings[6];
}

int VDI::CharHeight() const
{
	int settings[10];
	
	qt_attributes(settings);

	return settings[7];
}

int VDI::CharCellWidth() const
{
	int settings[10];

	qt_attributes(settings);
	
	return settings[8];
}

int VDI::CharCellHeight() const
{
	int settings[10];
	
	qt_attributes(settings);
	
	return settings[9];
}

const MFDB& VDI::MF()
{
	return AESMFDB;
}

int VDI::WorkOut(int index) const
{
	return WORKOUTfor(this,FALSE,TRUE)[index];
}

int VDI::ExtWorkOut(int index) const
{
	return WORKOUTfor(this,TRUE,TRUE)[index];
}
