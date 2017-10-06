/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "vdi++.h"
#include <vdibind.h>

// Flags.
//
//  Top 1 bit signals that fonts are loaded.
//  Next 7 bits are total # fonts.
//  Low 8 bits are for device type.
//

// SpeedoGDOS does not return correct value for WorkOut(10).
static const int NUM_FONTS=0x7f00;
static const int NUM_FONTS_SHIFT=8;

static const int METAVDI=31;
static const int FONTS_LOADED=0x8000;

static const int DEVICE_TYPE=0x00ff;

#ifdef L_gclass

#include <aesbind.h>
#include <osbind.h>

static const int NWI=11;
static const int NWO=57;

#define SCREENVDI (Getrez()+2)

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
		extend(false)
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



static MFDB AESMFDB;



VDI::VDI()
{
	flags=SCREENVDI;

	int j;
	handle=graf_handle(&j,&j,&j,&j);

	STDWORKIN[0]=flags&DEVICE_TYPE;

	int ihandle=handle;
	v_opnvwk(STDWORKIN,&ihandle,WORKOUTfor(this,false,false));
	handle=ihandle;
	AESMFDB.fd_addr=0;
}

VDI::VDI(const char* metafile) :
	flags(METAVDI)
{
	if ((long int) vq_vgdos()==GDOS_NONE) {
		handle=0;
	} else {
		int ihandle;
		int WORKIN[NWI]=STDWORKIN;

		WORKIN[0]=flags;
		//WORKIN[10]=0;

		v_opnwk(WORKIN,&ihandle,WORKOUTfor(this,false,false));
		handle=ihandle;

		if (strcmp(metafile,"GEMFILE.GEM")!=0) {
			m_filename(metafile);
			(void) Fdelete("GEMFILE.GEM");
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

const MFDB& VDI::MF()
{
	return AESMFDB;
}

int VDI::WorkOut(int index) const
{
	return WORKOUTfor(this,false,true)[index];
}

int VDI::ExtWorkOut(int index) const
{
	return WORKOUTfor(this,true,true)[index];
}

int VDI::NumberOfTextFaces() const
{
	if ((flags&FONTS_LOADED) == 0) {
		return WorkOut(15);
	} else {
		return (flags&NUM_FONTS)>>NUM_FONTS_SHIFT;
	}
}

#endif



#ifdef L_gclrwk
void VDI::clrwk() { v_clrwk(handle); }
#endif

#ifdef L_gupdwk
void VDI::updwk() { v_updwk(handle); }
#endif

#ifdef L_gswr_mo
int VDI::swr_mode (int mode) { return vswr_mode (handle, mode); }
#endif

#ifdef L_gs_colo
void VDI::s_color (int index, int rgb[]) { vs_color (handle, index, rgb); }
#endif

#ifdef L_gsl_typ
int VDI::sl_type (int style) { return vsl_type (handle, style); }
#endif

#ifdef L_gsl_uds
void VDI::sl_udsty (int pat) { vsl_udsty (handle, pat); }
#endif

#ifdef L_gsl_wid
int VDI::sl_width (int width) { return vsl_width (handle, width); }
#endif

#ifdef L_gsl_col
int VDI::sl_color (int index) { return vsl_color (handle, index); }
#endif

#ifdef L_gsl_end
void VDI::sl_ends (int begstyle, int endstyle) { vsl_ends (handle, begstyle, endstyle); }
#endif

#ifdef L_gsm_typ
int VDI::sm_type (int symbol) { return vsm_type (handle, symbol); }
#endif

#ifdef L_gsm_hei
void VDI::sm_height (int height) { vsm_height (handle, height); }
#endif

#ifdef L_gsm_col
int VDI::sm_color (int index) { return vsm_color (handle, index); }
#endif

#ifdef L_gst_hei
int VDI::st_height (int height, int *charw, int *charh, int *cellw, int *cellh) { return vst_height (handle, height, charw, charh, cellw, cellh); }
int  VDI::st_height(int height)
{
	int j;
	return st_height(height,&j,&j,&j,&j);
}
#endif

#ifdef L_gst_poi
int VDI::st_point (int point, int *charw, int *charh, int *cellw, int *cellh) { return vst_point (handle, point, charw, charh, cellw, cellh); }
int	 VDI::st_point(int point)
{
	int j;
	return st_point(point,&j,&j,&j,&j);
}
#endif

#ifdef L_gst_rot
int VDI::st_rotation (int ang) { return vst_rotation (handle, ang); }
#endif

#ifdef L_gst_fon
int VDI::st_font (int font) { return vst_font (handle, font); }
#endif

#ifdef L_gst_col
int VDI::st_color (int index) { return vst_color (handle, index); }
#endif

#ifdef L_gst_eff
int VDI::st_effects (int effects) { return vst_effects (handle, effects); }
#endif

#ifdef L_gst_ali
void VDI::st_alignment (int hin, int vin, int *hout, int *vout) { vst_alignment (handle, hin, vin, hout, vout); } 
void VDI::st_alignment(int hin, int vin)
{
	st_alignment(hin,vin,&hin,&vin);
}
#endif

#ifdef L_gsf_int
int VDI::sf_interior (int style) { return vsf_interior (handle, style); }
#endif

#ifdef L_gsf_fil
int VDI::sf_fill (int style) { return vsf_fill (handle, style); }
#endif

#ifdef L_gsf_sty
int VDI::sf_style (int style) { return vsf_style (handle, style); }
#endif

#ifdef L_gsf_col
int VDI::sf_color (int index) { return vsf_color (handle, index); }
#endif

#ifdef L_gsf_per
int VDI::sf_perimeter (int vis) { return vsf_perimeter (handle, vis); }
#endif

#ifdef L_gsf_udp
void VDI::sf_udpat (int pat[], int planes) { vsf_udpat (handle, pat, planes); }

#endif

#ifdef L_gst_loa
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

#endif

#ifdef L_gst_unl
void VDI::st_unload_fonts (int select)
{
	if ((flags&FONTS_LOADED) != 0) {
		flags^=FONTS_LOADED;
		flags&=~NUM_FONTS;
		vst_unload_fonts (handle, select);
	}
}

#endif

#ifdef L_gs_clip
void VDI::s_clip (int clip_flag, int pxyarray[]) { vs_clip (handle, clip_flag, pxyarray); }
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
void VDI::clip()
{
	int j[]={0,0,MaxX(),MaxY()};
	s_clip(1,j);
}
#endif

#ifdef L_gbar
void VDI::bar (int pxyarray[]) { v_bar (handle, pxyarray); }
void VDI::bar(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	bar(pxy);
}
#endif

#ifdef L_garc
void VDI::arc (int x, int y, int radius, int begang, int endang) { v_arc (handle, x, y, radius, begang, endang); } 
#endif

#ifdef L_gpiesli
void VDI::pieslice (int x, int y, int radius, int begang, int endang) { v_pieslice (handle, x, y, radius, begang, endang); }
#endif

#ifdef L_gcircle
void VDI::circle (int x, int y, int radius) { v_circle (handle, x, y, radius); }
#endif

#ifdef L_gellarc
void VDI::ellarc (int x, int y, int xrad, int yrad, int begang, int endang) { v_ellarc (handle, x, y, xrad, yrad, begang, endang); }
#endif

#ifdef L_gellpie
void VDI::ellpie (int x, int y, int xrad, int yrad, int begang, int endang) { v_ellpie (handle, x, y, xrad, yrad, begang, endang); }
#endif

#ifdef L_gellips
void VDI::ellipse (int x, int y, int xrad, int yrad) { v_ellipse (handle, x, y, xrad, yrad); }
#endif

#ifdef L_grbox
void VDI::rbox (int pxyarray[]) { v_rbox (handle, pxyarray); }
void VDI::rbox(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	rbox(pxy);
}
#endif

#ifdef L_grfbox
void VDI::rfbox (int pxyarray[]) { v_rfbox (handle, pxyarray); }
void VDI::rfbox(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	rfbox(pxy);
}
#endif

#ifdef L_gjustif
void VDI::justified (int x, int y, char *str, int len, int word_space, int char_space) { v_justified (handle, x, y, str, len, word_space, char_space); }

#endif

#ifdef L_gsin_mo
int VDI::sin_mode  (int dev, int mode) { return vsin_mode  (handle, dev, mode); }
#endif

#ifdef L_grq_loc
void VDI::rq_locator (int x, int y, int *xout, int *yout, int *term) { vrq_locator (handle, x, y, xout, yout, term); }  
#endif

#ifdef L_gsm_loc
int VDI::sm_locator (int x, int y, int *xout, int *yout, int *term) { return vsm_locator (handle, x, y, xout, yout, term); }

#endif

#ifdef L_grq_val
void VDI::rq_valuator (int in, int *out, int *term) { vrq_valuator (handle, in, out, term); }
#endif

#ifdef L_gsm_val
void VDI::sm_valuator (int in, int *out, int *term, int *status) { vsm_valuator (handle, in, out, term, status); }
#endif

#ifdef L_grq_cho
void VDI::rq_choice (int cin, int *cout) { vrq_choice (handle, cin, cout); }
#endif

#ifdef L_gsm_cho
int VDI::sm_choice (int *choice) { return vsm_choice (handle, choice); }
#endif

#ifdef L_grq_str
void VDI::rq_string (int len, int echo, int echoxy[], char *str) { vrq_string (handle, len, echo, echoxy, str); }
#endif

#ifdef L_gsm_str
int VDI::sm_string (int len, int echo, int echoxy[], char *str) { return vsm_string (handle, len, echo, echoxy, str); }
#endif

#ifdef L_gsc_for
void VDI::sc_form (int form[]) { vsc_form (handle, form); }
#endif

#ifdef L_gex_tim
void VDI::ex_timv (void *time_addr, void **otime_addr, int *time_conv) { vex_timv (handle, time_addr, otime_addr, time_conv); } 
#endif

#ifdef L_gshow_c
void VDI::show_c (int reset) { v_show_c (handle, reset); }
#endif

#ifdef L_ghide_c
void VDI::hide_c () { v_hide_c (handle); }
#endif

#ifdef L_gq_mous
void VDI::q_mouse (int *pstatus, int *x, int *y) { vq_mouse (handle, pstatus, x, y); }
#endif

#ifdef L_gex_but
void VDI::ex_butv (void *new_p, void **old) { vex_butv (handle, new_p, old); }
#endif

#ifdef L_gex_mot
void VDI::ex_motv (void *new_p, void **old) { vex_motv (handle, new_p, old); }
#endif

#ifdef L_gex_cur
void VDI::ex_curv (void *new_p, void **old) { vex_curv (handle, new_p, old); }
#endif

#ifdef L_gq_key_
void VDI::q_key_s (int *state) { vq_key_s (handle, state); }

#endif

#ifdef L_gq_extn
void VDI::q_extnd (int flag, int work_out[]) const { vq_extnd (handle, flag, work_out); }
#endif

#ifdef L_gq_colo
int VDI::q_color (int index, int flag, int rgb[]) const { return vq_color (handle, index, flag, rgb); }
#endif

#ifdef L_gql_att
void VDI::ql_attribute (int atrib[]) const { vql_attribute (handle, atrib); }
#endif

#ifdef L_gqm_att
void VDI::qm_attributes (int atrib[]) const { vqm_attributes (handle, atrib); }
#endif

#ifdef L_gqf_att
void VDI::qf_attributes (int atrib[]) const { vqf_attributes (handle, atrib); }
#endif

#ifdef L_gqt_att
void VDI::qt_attributes (int atrib[]) const { vqt_attributes (handle, atrib); }
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
#endif

#ifdef L_gqt_ext
void VDI::qt_extent (char *str, int extent[]) const { vqt_extent (handle, str, extent); }
#endif

#ifdef L_gqt_wid
int VDI::qt_width (int chr, int *cw, int *ldelta, int *rdelta) const { return vqt_width (handle, chr, cw, ldelta, rdelta); }
#endif

#ifdef L_gqt_nam
int VDI::qt_name (int element, char *name) const { return vqt_name (handle, element, name); }
#endif

#ifdef L_gq_cell
void VDI::q_cellarray (int pxyarray[], int row_len, int nrows, int *el_used, int *rows_used, int *status, int color[]) { vq_cellarray (handle, pxyarray, row_len, nrows, el_used, rows_used, status, color); }  
#endif

#ifdef L_gqin_mo
void VDI::qin_mode (int dev, int *mode) { vqin_mode (handle, dev, mode); }
#endif

#ifdef L_gqt_fon
void VDI::qt_fontinfo (int *minade, int *maxade, int distances[], int *maxwidth, int effects[]) { vqt_fontinfo (handle, minade, maxade, distances, maxwidth, effects); }  
#endif

#ifdef L_gqt_fon
void VDI::qt_font_info (int *minade, int *maxade, int distances[], int *maxwidth, int effects[]) { vqt_font_info (handle, minade, maxade, distances, maxwidth, effects); }  

#endif

#ifdef L_gpline
void VDI::pline (int count, int pxyarray[]) { v_pline (handle, count, pxyarray); }
void VDI::line(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	pline(2,pxy);
}
#endif

#ifdef L_gpmarke
void VDI::pmarker (int count, int pxyarray[]) { v_pmarker (handle, count, pxyarray); }
void VDI::marker(int x, int y)
{
	int pxy[]={x,y};
	pmarker(1,pxy);
}
#endif

#ifdef L_ggtext
int VDI::gtext (int x, int y, char *str) { return v_gtext (handle, x, y, str); }
#endif

#ifdef L_gfillar
void VDI::fillarea (int count, int pxyarray[]) { v_fillarea (handle, count, pxyarray); }
#endif

#ifdef L_gcellar
void VDI::cellarray (int pxyarray[], int row_length, int elements, int nrows, int write_mode, int colarray[]) { v_cellarray (handle, pxyarray, row_length, elements, nrows, write_mode, colarray); }
#endif

#ifdef L_gcontou
void VDI::contourfill (int x, int y, int index) { v_contourfill (handle, x, y, index); }
#endif

#ifdef L_gr_recf
void VDI::r_recfl (int pxyarray[]) { vr_recfl (handle, pxyarray); }
void VDI::r_recfl(int x1, int y1, int x2, int y2)
{
	int pxy[]={x1,y1,x2,y2};
	r_recfl(pxy);
}
#endif

#ifdef L_gro_cpy
void VDI::ro_cpyfm (int mode, int pxyarray[], const MFDB& src, const MFDB& dst) { vro_cpyfm (handle, mode, pxyarray, (MFDB*)&src, (MFDB*)&dst); }
void VDI::ro_cpyfm(int mode, int pxyarray[])
{
	ro_cpyfm(mode,pxyarray,MF(),MF());
}
void VDI::ro_cpyfm (int mode, int pxyarray[], VDI& from)
{
	ro_cpyfm(mode,pxyarray,from.MF(),MF());
}
#endif

#ifdef L_grt_cpy
void VDI::rt_cpyfm (int mode, int pxyarray[], const MFDB& src, const MFDB& dst, int color[]) { vrt_cpyfm (handle, mode, pxyarray, (MFDB*)&src, (MFDB*)&dst, color); }  
void VDI::rt_cpyfm (int mode, int pxyarray[], VDI& from, int color[])
{
	rt_cpyfm(mode,pxyarray,from.MF(),MF(),color);
}
void VDI::rt_cpyfm(int mode, int pxyarray[], int color[])
{
	rt_cpyfm(mode,pxyarray,MF(),MF(),color);
}
#endif

#ifdef L_gr_trnf
void VDI::r_trnfm (const MFDB& src, const MFDB& dst) { vr_trnfm (handle, (MFDB*)&src, (MFDB*)&dst); }
void VDI::r_trnfm()
{
	r_trnfm(MF(),MF());
}
void VDI::r_trnfm (VDI& from)
{
	r_trnfm(from.MF(),MF());
}
#endif

#ifdef L_gget_pi
void VDI::get_pixel (int x, int y, int *pel, int *indx) { v_get_pixel (handle, x, y, pel, indx); } 

#endif

#ifdef L_gq_chce
void VDI::q_chcells (int *n_rows, int *n_cols) { vq_chcells (handle, n_rows, n_cols); }
#endif

#ifdef L_gexit_c
void VDI::exit_cur () { v_exit_cur (handle); }
#endif

#ifdef L_genter_
void VDI::enter_cur () { v_enter_cur (handle); }
#endif

#ifdef L_gcurup
void VDI::curup () { v_curup (handle); }
#endif

#ifdef L_gcurdow
void VDI::curdown () { v_curdown (handle); }
#endif

#ifdef L_gcurrig
void VDI::curright () { v_curright (handle); }
#endif

#ifdef L_gcurlef
void VDI::curleft () { v_curleft (handle); }
#endif

#ifdef L_gcurhom
void VDI::curhome () { v_curhome (handle); }
#endif

#ifdef L_geeos
void VDI::eeos () { v_eeos (handle); }
#endif

#ifdef L_geeol
void VDI::eeol () { v_eeol (handle); }
#endif

#ifdef L_gs_cura
void VDI::s_curaddress (int row, int col) { vs_curaddress (handle, row, col); }
#endif

#ifdef L_gcurtex
void VDI::curtext (char *s) { v_curtext (handle, s); }
#endif

#ifdef L_grvon
void VDI::rvon () { v_rvon (handle); }
#endif

#ifdef L_grvoff
void VDI::rvoff () { v_rvoff (handle); }
#endif

#ifdef L_gq_cura
void VDI::q_curaddress (int *cur_row, int *cur_col) { vq_curaddress (handle, cur_row, cur_col); }
#endif

#ifdef L_gq_tabs
int VDI::q_tabstatus () { return vq_tabstatus (handle); }
#endif

#ifdef L_ghardco
void VDI::hardcopy () { v_hardcopy (handle); }
#endif

#ifdef L_gdspcur
void VDI::dspcur  (int x, int y) { v_dspcur  (handle, x, y); }
#endif

#ifdef L_grmcur
void VDI::rmcur () { v_rmcur (handle); }
#endif

#ifdef L_gform_a
void VDI::form_adv () { v_form_adv (handle); }
#endif

#ifdef L_goutput
void VDI::output_window (int *pxyarray) { v_output_window (handle, pxyarray); }
#endif

#ifdef L_gclear_
void VDI::clear_disp_list () { v_clear_disp_list (handle); }
#endif

#ifdef L_gbit_im
void VDI::bit_image (const char *filename, int aspect, int x_scale, int y_scale, int h_align, int v_align, int *pxyarray) { v_bit_image (handle, filename, aspect, x_scale, y_scale, h_align, v_align, pxyarray); }
#endif

#ifdef L_gq_scan
void VDI::q_scan (int *g_slice, int *g_page, int *a_slice, int *a_page, int *div_fac) { vq_scan (handle, g_slice, g_page, a_slice, a_page, div_fac); }
#endif

#ifdef L_galpha_
void VDI::alpha_text (const char *string) { v_alpha_text (handle, string); }
#endif

#ifdef L_gs_pale
int VDI::s_palette (int palette) { return vs_palette (handle, palette); }
#endif

#ifdef L_gsound
void VDI::sound (int frequency, int duration) { v_sound (handle, frequency, duration); }
#endif

#ifdef L_gs_mute
int VDI::s_mute (int action) { return vs_mute (handle, action); }
#endif

#ifdef L_gt_reso
void VDI::t_resolution (int xres, int yres, int *xset, int *yset) { vt_resolution (handle, xres, yres, xset, yset); }
#endif

#ifdef L_gt_axis
void VDI::t_axis (int xres, int yres, int *xset, int *yset) { vt_axis (handle, xres, yres, xset, yset); }
#endif

#ifdef L_gt_orig
void VDI::t_origin (int xorigin, int yorigin) { vt_origin (handle, xorigin, yorigin); }
#endif

#ifdef L_gq_dime
void VDI::q_dimensions (int *xdimension, int *ydimension) { vq_dimensions (handle, xdimension, ydimension); }
#endif

#ifdef L_gt_alig
void VDI::t_alignment (int dx, int dy) { vt_alignment (handle, dx, dy); }
#endif

#ifdef L_gsp_fil
void VDI::sp_film (int index, int lightness) { vsp_film (handle, index, lightness); }
#endif

#ifdef L_gqp_fil
int VDI::qp_filmname (int index, char *name) { return vqp_filmname (handle, index, name); }
#endif

#ifdef L_gsc_exp
void VDI::sc_expose (int state) { vsc_expose (handle, state); }
#endif

#ifdef L_gmeta_e
void VDI::meta_extents (int min_x, int min_y, int max_x, int max_y) { v_meta_extents (handle, min_x, min_y, max_x, max_y); }
#endif

#ifdef L_gwrite_
void VDI::write_meta (int num_intin, int *a_intin, int num_ptsin, int *a_ptsin) { v_write_meta (handle, num_intin, a_intin, num_ptsin, a_ptsin); }
#endif

#ifdef L_gm_page
void VDI::m_pagesize (int pgwidth, int pgheight) { vm_pagesize (handle, pgwidth, pgheight); }
#endif

#ifdef L_gm_coor
void VDI::m_coords (int llx, int lly, int urx, int ury) { vm_coords (handle, llx, lly, urx, ury); }
#endif

#ifdef L_gm_file
void VDI::m_filename (const char *filename) { vm_filename (handle, filename); }
#endif

#ifdef L_gescape
void VDI::escape2000 (int times) { v_escape2000 (handle, times); }
#endif

#ifdef L_gq_vgdo
unsigned long VDI::q_vgdos () { return vq_vgdos (); }
#endif

#ifdef L_ggetbit
void VDI::getbitmap_info (int ch, long *advancex, long *advancey, long *xoffset, long *yoffset, int *width, int *height, short **bitmap) { v_getbitmap_info (handle, ch,  advancex, advancey, xoffset, yoffset, width, height, bitmap); }
#endif

#ifdef L_gqt_f_e
void VDI::qt_f_extent (const char *str, int extent[]) { vqt_f_extent (handle, str, extent); }
#endif

#ifdef L_gftext
void VDI::ftext (int x, int y, const char *str) { v_ftext (handle, x, y, str); }
#endif

#ifdef L_gkillou
//void VDI::killoutline (void *component) { v_killoutline (handle, component); }
#endif

#ifdef L_ggetout
void VDI::getoutline (int ch, int *xyarray, char *bezarray, int maxverts, int *numverts) { v_getoutline (handle, ch, xyarray, bezarray, maxverts, numverts); }
#endif

#ifdef L_gst_scr
void VDI::st_scratch (int mode) { vst_scratch (handle, mode); }
#endif

#ifdef L_gst_err
void VDI::st_error (int mode, short *errorvar) { vst_error (handle, mode, errorvar); }
#endif

#ifdef L_gst_arb
int VDI::st_arbpt (int point, int *wchar, int *hchar, int *wcell, int *hcell ) { return vst_arbpt (handle, point, wchar, hchar, wcell, hcell ); }
#endif

#ifdef L_gqt_adv
void VDI::qt_advance (int ch, int *xadv, int *yadv, int *xrem, int *yrem) { vqt_advance (handle, ch, xadv, yadv, xrem, yrem); } 
#endif

#ifdef L_gqt_dev
void VDI::qt_devinfo (int device, int *isdev, char *drivername ) { vqt_devinfo (handle, device, isdev, drivername ); }
#endif

#ifdef L_gsaveca
int VDI::savecache (char *filename ) { return v_savecache (handle, filename ); }
#endif

#ifdef L_gloadca
int VDI::loadcache (char *filename, int mode ) { return v_loadcache (handle, filename, mode ); }
#endif

#ifdef L_gflushc
int VDI::flushcache () { return v_flushcache (handle); }
#endif

#ifdef L_gst_set
int VDI::st_setsize (int point, int *wchar, int *hchar, int *wcell, int *hcell ) { return vst_setsize (handle, point, wchar, hchar, wcell, hcell ); }
#endif

#ifdef L_gst_ske
int VDI::st_skew (int skew ) { return vst_skew (handle, skew ); }
#endif

#ifdef L_gqt_get
// void VDI::qt_get_tables (void **gascii, void **style ) { vqt_get_tables (handle, gascii, style ); }
#endif

#ifdef L_gqt_get
void VDI::qt_get_table (short **map) { vqt_get_table (handle, map ); }
#endif

#ifdef L_gqt_cac
void VDI::qt_cachesize (int which_cache, size_t *size ) { vqt_cachesize (handle, which_cache, size ); }
#endif

#ifdef L_gbez
int VDI::bez (int count, int *xyarr, char *bezarr, int extent[4], int *npts, int *nmvs) { return v_bez (handle, count, xyarr, bezarr, extent, npts, nmvs); }
#endif

#ifdef L_gbez_fi
int VDI::bez_fill (int count, int *xyarr, char *bezarr, int extent[4], int *npts, int *nmvs) { return v_bez_fill (handle, count, xyarr, bezarr, extent, npts, nmvs); }
#endif

#ifdef L_gbez_qu
int VDI::bez_qual (int percent, int *actual) { return v_bez_qual (handle, percent, actual); }
#endif

#ifdef L_gbez_on
int VDI::bez_on () { return v_bez_on (handle); }
#endif

#ifdef L_gbez_of
void VDI::bez_off () { v_bez_off (handle); }
#endif

#ifdef L_gshtext
void VDI::shtext (int wsid, int x, int y, const char *text, int color, int xshadow, int yshadow ) { v_shtext (wsid, x, y, text, color, xshadow, yshadow ); }
#endif

#ifdef L_gset_ap
void VDI::set_app_buff (void **buf_p, int size) { v_set_app_buff (buf_p, size); }
#endif



