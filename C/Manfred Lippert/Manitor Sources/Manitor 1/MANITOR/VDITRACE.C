#include "manitor.h"
#include "..\toslib\vdi\vdi.h"
#include <stdlib.h>
#include <string.h>

int vdi_is_traced = DEFAULT_VDI_TRACE;

VDIFUNCS vdi_funcs;

/* ACHTUNG: Funktionen m《sen nach Opcode sortiert sein!!!! */
/* Subcode sollte beim ersten jeweils 0 sein */

/* OUT_... wird selbst gesetzt! */

VDIFUNC vdi_func[] = {
	{1, NO_SUBCODE, EGAL, EGAL, "v_opnwk", 2, {{INTIN, 0, T_INT, "work_in[0]"}, {INTIN, 10, T_INT, "work_in[10]"}}, 1, {{CONTRL, 6, T_INT, "hnd"}}, OUT_NONE, FALSE},
	{2, NO_SUBCODE, EGAL, EGAL, "v_clswk", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{3, NO_SUBCODE, EGAL, EGAL, "v_clrwk", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{4, NO_SUBCODE, EGAL, EGAL, "v_updwk", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 1, EGAL, EGAL, "vq_chcells", 1, {{CONTRL, 6, T_INT, "hnd"}}, 2, {{INTOUT, 0, T_INT, "rows"}, {INTOUT, 1, T_INT, "columns"}}, OUT_NONE, FALSE},
	{5, 2, EGAL, EGAL, "v_exit_cur", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 3, EGAL, EGAL, "v_enter_cur", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 4, EGAL, EGAL, "v_curup", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 5, EGAL, EGAL, "v_curdown", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 6, EGAL, EGAL, "v_curright", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 7, EGAL, EGAL, "v_curleft", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 8, EGAL, EGAL, "v_curhome", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 9, EGAL, EGAL, "v_eeos", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 10, EGAL, EGAL, "v_eeol", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 11, EGAL, EGAL, "v_curaddress", 3, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "row"}, {INTIN, 1, T_INT, "column"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 12, EGAL, EGAL, "v_curtext", 2, {{CONTRL, 6, T_INT, "hnd"}, {VDIPBIN, 0, T_VDISTR, "\0""txt"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 13, EGAL, EGAL, "v_rvon", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 14, EGAL, EGAL, "v_rvoff", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 15, EGAL, EGAL, "vq_curaddress", 1, {{CONTRL, 6, T_INT, "hnd"}}, 2, {{INTOUT, 0, T_INT, "row"}, {INTOUT, 1, T_INT, "column"}}, OUT_NONE, FALSE},
	{5, 16, EGAL, EGAL, "vq_tabstatus",1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 17, EGAL, EGAL, "v_hardcopy",1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 18, EGAL, EGAL, "v_dspcur", 3, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 19, EGAL, EGAL, "v_rmcur",1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 20, EGAL, EGAL, "v_form_adv", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 21, EGAL, EGAL, "v_output_window",1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 22, EGAL, EGAL, "v_clear_disp_list", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 23, EGAL, EGAL, "v_bit_image", 11, {{CONTRL, 6, T_INT, "hnd"}, {VDIPBIN, 0, T_VDISTR, "\5""file"}, {INTIN, 0, T_INT, "aspect"}, {INTIN, 1, T_INT, "x_scale"}, {INTIN, 2, T_INT, "y_scale"},
														{INTIN, 3, T_INT, "h_align"}, {INTIN, 4, T_INT, "v_align"}, {PTSIN, 0, T_INT, "x1"}, {PTSIN, 1, T_INT, "y1"}, {PTSIN, 2, T_INT, "x2"}, {PTSIN, 3, T_INT, "y2"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 24, EGAL, EGAL, "vq_scan", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 25, EGAL, EGAL, "v_alpha_text", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 27, EGAL, EGAL, "v_orient", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "orient"}}, 1, {{INTOUT, 0, T_INT, "orient"}}, OUT_NONE, FALSE},
	{5, 28, EGAL, EGAL, "v_copies", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "copies"}}, 1, {{INTOUT, 0, T_INT, "copies"}}, OUT_NONE, FALSE},
	{5, 29, EGAL, EGAL, "v_trays", 3, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "input"}, {INTIN, 1, T_INT, "output"}}, 2, {{INTOUT, 0, T_INT, "input"}, {INTOUT, 1, T_INT, "output"}}, OUT_NONE, FALSE},
	{5, 36, EGAL, EGAL, "vq_tray_names", 3, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_ADR, "input"}, {INTIN, 2, T_ADR, "output"}}, 2, {{INTOUT, 0, T_INT, "input"}, {INTOUT, 1, T_INT, "output"}}, OUT_NONE, FALSE},
	{5, 37, EGAL, EGAL, "v_page_size", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "page_id"}}, 1, {{INTOUT, 0, T_INT, "set_page"}}, OUT_NONE, FALSE},
	{5, 38, EGAL, EGAL, "vq_page_name", 3, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "page_id"}, {INTIN, 1, T_ADR, "name"}}, 3, {{INTOUT, 0, T_INT, "set_page"}, {INTOUT, 1, T_LONG, "width"}, {INTOUT, 3, T_LONG, "height"}}, OUT_NONE, FALSE},
	{5, 39, EGAL, EGAL, "vq_prn_scaling", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 60, EGAL, EGAL, "vs_palette", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 61, EGAL, EGAL, "v_sound", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 62, EGAL, EGAL, "vs_mute", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 76, EGAL, EGAL, "vs_calibrate", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 77, EGAL, EGAL, "vq_calibrate", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 81, EGAL, EGAL, "vt_resolution", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 82, EGAL, EGAL, "vt_axis", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 83, EGAL, EGAL, "vt_origin", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 84, EGAL, EGAL, "vq_tdimensions", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 85, EGAL, EGAL, "vt_alignment", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 91, EGAL, EGAL, "vsp_film", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 92, EGAL, EGAL, "vqp_filmname", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 93, EGAL, EGAL, "vsc_expose", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 98, EGAL, EGAL, "v_meta_extents", 5, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x_min"}, {PTSIN, 1, T_INT, "y_min"}, {PTSIN, 2, T_INT, "x_max"}, {PTSIN, 3, T_INT, "y_max"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 99, EGAL, EGAL, "v_bez_qual/v_write_meta", 4, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "intin[0]"}, {INTIN, 1, T_INT, "intin[1]"}, {INTIN, 2, T_INT, "intin[2]"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 100, EGAL, EGAL, "vm_filename", 2, {{CONTRL, 6, T_INT, "hnd"}, {VDIPBIN, 0, T_VDISTR, "\0""file"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 101, EGAL, EGAL, "v_offset", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 102, EGAL, EGAL, "v_fontinit", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{5, 2000, EGAL, EGAL, "v_escape2000", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "times"}}, 0, {0}, OUT_NONE, FALSE},
	{5, 2103, EGAL, EGAL, "vs_document_info", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{6, 0, EGAL, EGAL, "v_pline", 3, {{CONTRL, 6, T_INT, "hnd"}, {CONTRL, 1, T_INT, "count"}, {VDIPBIN, 0, T_V_PLINE, 0L}}, 0, {0}, OUT_NONE, FALSE},
	{6, 13, EGAL, EGAL, "v_bez", 3, {{CONTRL, 6, T_INT, "hnd"}, {CONTRL, 1, T_INT, "count"}, {VDIPBIN, 0, T_V_BEZ, 0L}}, 6, {{INTOUT, 0, T_INT, "jumps"}, {INTOUT, 1, T_INT, "pts"},
												{PTSOUT, 0, T_INT, "x1"}, {PTSOUT, 1, T_INT, "y1"}, {PTSOUT, 2, T_INT, "x2"}, {PTSOUT, 3, T_INT, "y2"}}, OUT_NONE, FALSE},
	{7, NO_SUBCODE, EGAL, EGAL, "v_pmarker", 3, {{CONTRL, 6, T_INT, "hnd"}, {CONTRL, 1, T_INT, "count"}, {VDIPBIN, 0, T_V_PLINE, 0L}}, 0, {0}, OUT_NONE, FALSE},
	{8, NO_SUBCODE, EGAL, EGAL, "v_gtext", 4, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}, {VDIPBIN, 0, T_VDISTR, "\0""txt"}}, 0, {0}, OUT_NONE, FALSE},
	{9, 0, EGAL, EGAL, "v_fillarea", 2, {{CONTRL, 6, T_INT, "hnd"}, {CONTRL, 1, T_INT, "count"}, {VDIPBIN, 0, T_V_PLINE, 0L}}, 0, {0}, OUT_NONE, FALSE},
	{9, 13, EGAL, EGAL, "v_bez_fill", 3, {{CONTRL, 6, T_INT, "hnd"}, {CONTRL, 1, T_INT, "count"}, {VDIPBIN, 0, T_V_BEZ, 0L}}, 6, {{INTOUT, 0, T_INT, "jumps"}, {INTOUT, 1, T_INT, "pts"},
												{PTSOUT, 0, T_INT, "x1"}, {PTSOUT, 1, T_INT, "y1"}, {PTSOUT, 2, T_INT, "x2"}, {PTSOUT, 3, T_INT, "y2"}}, OUT_NONE, FALSE},
	{10, NO_SUBCODE, EGAL, EGAL, "v_cellarray", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{11, 1, EGAL, EGAL, "v_bar", 5, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x1"}, {PTSIN, 1, T_INT, "y1"}, {PTSIN, 2, T_INT, "x2"}, {PTSIN, 3, T_INT, "y2"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 2, EGAL, EGAL, "v_arc", 6, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}, {PTSIN, 6, T_INT, "radius"}, {INTIN, 0, T_INT, "beg"}, {INTIN, 1, T_INT, "end"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 3, EGAL, EGAL, "v_piesclice", 6, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}, {PTSIN, 6, T_INT, "radius"}, {INTIN, 0, T_INT, "beg"}, {INTIN, 1, T_INT, "end"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 4, EGAL, EGAL, "v_circle", 4, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}, {PTSIN, 4, T_INT, "radius"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 5, EGAL, EGAL, "v_ellipse", 5, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}, {PTSIN, 2, T_INT, "x_radius"}, {PTSIN, 3, T_INT, "y_radius"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 6, EGAL, EGAL, "v_ellarc", 7, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}, {PTSIN, 2, T_INT, "x_radius"}, {PTSIN, 3, T_INT, "y_radius"}, {INTIN, 0, T_INT, "beg"}, {INTIN, 1, T_INT, "end"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 7, EGAL, EGAL, "v_ellpie", 7, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}, {PTSIN, 2, T_INT, "x_radius"}, {PTSIN, 3, T_INT, "y_radius"}, {INTIN, 0, T_INT, "beg"}, {INTIN, 1, T_INT, "end"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 8, EGAL, EGAL, "v_rbox", 5, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x1"}, {PTSIN, 1, T_INT, "y1"}, {PTSIN, 2, T_INT, "x2"}, {PTSIN, 3, T_INT, "y2"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 9, EGAL, EGAL, "v_rfbox", 5, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x1"}, {PTSIN, 1, T_INT, "y1"}, {PTSIN, 2, T_INT, "x2"}, {PTSIN, 3, T_INT, "y2"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 10, EGAL, EGAL, "v_justified", 7, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}, {PTSIN, 2, T_INT, "width"}, {INTIN, 0, T_INT, "word_space"}, {INTIN, 1, T_INT, "char_space"},
														{VDIPBIN, 0, T_VDISTR, "\0""txt"}}, 0, {0}, OUT_NONE, FALSE},
	{11, 13, EGAL, EGAL, "v_bez_on", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_INT, "qual"}}, OUT_NONE, FALSE},
	{11, 13, EGAL, EGAL, "v_bez_off", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{12, NO_SUBCODE, EGAL, EGAL, "vst_height", 2, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 1, T_INT, "height"}}, 4, {{PTSOUT, 0, T_INT, "char_w"}, {PTSOUT, 1, T_INT, "char_h"}, {PTSOUT, 2, T_INT, "cell_w"}, {PTSOUT, 3, T_INT, "cell_h"}}, OUT_NONE, FALSE},
	{13, NO_SUBCODE, EGAL, EGAL, "vst_rotation", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "angle"}}, 1, {{INTOUT, 0, T_INT, "angle"}}, OUT_NONE, FALSE},
	{14, NO_SUBCODE, EGAL, EGAL, "vs_color", 5, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "idx"}, {INTIN, 1, T_INT, "red"}, {INTIN, 2, T_INT, "green"}, {INTIN, 3, T_INT, "blue"}}, 0, {0}, OUT_NONE, FALSE},
	{15, NO_SUBCODE, EGAL, EGAL, "vsl_type", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "type"}}, 1, {{INTOUT, 0, T_INT, "type"}}, OUT_NONE, FALSE},
	{16, NO_SUBCODE, EGAL, EGAL, "vsl_width", 2, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "width"}}, 1, {{PTSOUT, 0, T_INT, "width"}}, OUT_NONE, FALSE},
	{17, NO_SUBCODE, EGAL, EGAL, "vsl_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "idx"}}, 1, {{INTOUT, 0, T_INT, "idx"}}, OUT_NONE, FALSE},
	{18, NO_SUBCODE, EGAL, EGAL, "vsm_type", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "type"}}, 1, {{INTOUT, 0, T_INT, "type"}}, OUT_NONE, FALSE},
	{19, NO_SUBCODE, EGAL, EGAL, "vsm_height", 2, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "height"}}, 1, {{PTSOUT, 0, T_INT, "width"}, {PTSOUT, 1, T_INT, "height"}}, OUT_NONE, FALSE},
	{20, NO_SUBCODE, EGAL, EGAL, "vsm_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "idx"}}, 1, {{INTOUT, 0, T_INT, "idx"}}, OUT_NONE, FALSE},
	{21, NO_SUBCODE, EGAL, EGAL, "vst_font", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "font"}}, 1, {{INTOUT, 0, T_INT, "font"}}, OUT_NONE, FALSE},
	{22, NO_SUBCODE, EGAL, EGAL, "vst_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "col"}}, 1, {{INTOUT, 0, T_INT, "col"}}, OUT_NONE, FALSE},
	{23, NO_SUBCODE, EGAL, EGAL, "vsf_interior", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "interior"}}, 1, {{INTOUT, 0, T_INT, "interior"}}, OUT_NONE, FALSE},
	{24, NO_SUBCODE, EGAL, EGAL, "vsf_style", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "style"}}, 1, {{INTOUT, 0, T_INT, "style"}}, OUT_NONE, FALSE},
	{25, NO_SUBCODE, EGAL, EGAL, "vsf_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "col"}}, 1, {{INTOUT, 0, T_INT, "col"}}, OUT_NONE, FALSE},
	{26, NO_SUBCODE, EGAL, EGAL, "vq_color", 3, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "idx"}, {INTIN, 1, T_INT, "real"}},
											4, {{INTOUT, 0, T_INT, "ok"}, {INTOUT, 1, T_INT, "red"}, {INTOUT, 2, T_INT, "green"}, {INTOUT, 3, T_INT, "blue"}}, OUT_NONE, FALSE},
	{27, NO_SUBCODE, EGAL, EGAL, "vq_cellarray", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{28, NO_SUBCODE, EGAL, EGAL, "vrq/vsm_locator", 3, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x"}, {PTSIN, 1, T_INT, "y"}}, 3, {{INTOUT, 0, T_INT, "term"}, {PTSOUT, 0, T_INT, "x"}, {PTSOUT, 1, T_INT, "y"}}, OUT_NONE, FALSE},
	{29, NO_SUBCODE, EGAL, EGAL, "vrq/vsm_valuator", 0, {0}, 0, {0}, OUT_NONE, FALSE}, /* ??? */
	{30, NO_SUBCODE, EGAL, EGAL, "vrq/vsm_choice", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_INT, "choice"}}, OUT_NONE, FALSE},
	{31, NO_SUBCODE, EGAL, EGAL, "vrq/vsm_string", 0, {0}, 0, {0}, OUT_NONE, FALSE},		/* ??? */
	{32, NO_SUBCODE, EGAL, EGAL, "vswr_mode", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "mode"}}, 1, {{INTOUT, 0, T_INT, "mode"}}, OUT_NONE, FALSE},
	{33, NO_SUBCODE, EGAL, EGAL, "vsin_mode", 3, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "dev_type"}, {INTIN, 1, T_INT, "mode"}}, 1, {{INTOUT, 0, T_INT, "mode"}}, OUT_NONE, FALSE},
	{35, NO_SUBCODE, EGAL, EGAL, "vql_attributes", 1, {{CONTRL, 6, T_INT, "hnd"}}, 6, {{INTOUT, 0, T_INT, "type"}, {INTOUT, 1, T_INT, "color"}, {INTOUT, 2, T_INT, "mode"}, {PTSOUT, 0, T_INT, "width"},
																		{INTOUT, 3, T_INT, "beg"}, {INTOUT, 4, T_INT, "end"}}, OUT_NONE, FALSE},
	{36, NO_SUBCODE, EGAL, EGAL, "vqm_attributes", 1, {{CONTRL, 6, T_INT, "hnd"}}, 5, {{INTOUT, 0, T_INT, "type"}, {INTOUT, 1, T_INT, "color"}, {INTOUT, 2, T_INT, "mode"}, {PTSOUT, 1, T_INT, "height"},
																		{PTSOUT, 0, T_INT, "width"}}, OUT_NONE, FALSE},
	{37, NO_SUBCODE, EGAL, EGAL, "vqf_attributes", 1, {{CONTRL, 6, T_INT, "hnd"}}, 5, {{INTOUT, 0, T_INT, "type"}, {INTOUT, 1, T_INT, "color"}, {INTOUT, 2, T_INT, "idx"}, {INTOUT, 3, T_INT, "mode"}, {INTOUT, 4, T_INT, "boundary"}}, OUT_NONE, FALSE},
	{38, NO_SUBCODE, EGAL, EGAL, "vqt_attributes", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{39, NO_SUBCODE, EGAL, EGAL, "vst_alignment", 3, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "hor"}, {INTIN, 1, T_INT, "ver"}}, 2, {{INTOUT, 0, T_INT, "hor"}, {INTOUT, 1, T_INT, "ver"}}, OUT_NONE, FALSE},
	{100, 0, EGAL, EGAL, "v_opnvwk", 3, {{CONTRL, 6, T_INT, "phys_hnd"}, {INTIN, 0, T_INT, "work_in[0]"}, {INTIN, 10, T_INT, "work_in[10]"}}, 1, {{CONTRL, 6, T_INT, "hnd"}}, OUT_NONE, FALSE},
	{100, 1, EGAL, EGAL, "v_opnbm", 2, {{CONTRL, 6, T_INT, "phys_hnd"}, {CONTRL, 7, T_MFDB, "mfdb"}}, 1, {{CONTRL, 6, T_INT, "hnd"}}, OUT_NONE, FALSE},
	{100, 2, EGAL, EGAL, "v_resize_bm", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{100, 3, EGAL, EGAL, "v_opn_bm", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{101, 0, EGAL, EGAL, "v_clsvwk", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{101, 1, EGAL, EGAL, "v_clsbm", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{102, 0, EGAL, EGAL, "vq_extnd", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{102, 1, EGAL, EGAL, "vq_scrninfo", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{103, NO_SUBCODE, EGAL, EGAL, "v_contourfill", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{104, NO_SUBCODE, EGAL, EGAL, "vsf_perimeter", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "on"}}, 1, {{INTOUT, 0, T_INT, "on"}}, OUT_NONE, FALSE},
	{105, NO_SUBCODE, EGAL, EGAL, "v_get_pixel", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{106, NO_SUBCODE, EGAL, EGAL, "vst_effects", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_VSTEFFECTS, "effect"}}, 1, {{INTOUT, 0, T_VSTEFFECTS, "effect"}}, OUT_NONE, FALSE},
	{107, NO_SUBCODE, EGAL, EGAL, "vst_point", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "pt"}}, 5, {{INTOUT, 0, T_INT, "pt"}, {PTSOUT, 0, T_INT, "char_w"}, {PTSOUT, 1, T_INT, "char_h"},
																		{PTSOUT, 2, T_INT, "cell_w"}, {PTSOUT, 3, T_INT, "cell_h"}}, OUT_NONE, FALSE},
	{108, NO_SUBCODE, EGAL, EGAL, "vsl_ends", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{109, NO_SUBCODE, EGAL, EGAL, "vro_cpyfm", 5, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "mode"}, {CONTRL, 7, T_MFDB, "src"}, {CONTRL, 9, T_MFDB, "dst"}, {VDIPBIN, 0, T_V_PLINE, "xy"}}, 0, {0}, OUT_NONE, FALSE},
	{110, NO_SUBCODE, EGAL, EGAL, "vr_trnfm", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{111, NO_SUBCODE, EGAL, EGAL, "vsc_form", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{112, NO_SUBCODE, EGAL, EGAL, "vsf_udpat", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{113, NO_SUBCODE, EGAL, EGAL, "vsl_udsty", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "pattern"}}, 0, {0}, OUT_NONE, FALSE},
	{114, NO_SUBCODE, EGAL, EGAL, "vr_recfl", 5, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "x1"}, {PTSIN, 1, T_INT, "y1"}, {PTSIN, 2, T_INT, "x2"}, {PTSIN, 3, T_INT, "y2"}}, 0, {0}, OUT_NONE, FALSE},
	{115, NO_SUBCODE, EGAL, EGAL, "vqin_mode", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{116, NO_SUBCODE, EGAL, EGAL, "vqt_extent", 2, {{CONTRL, 6, T_INT, "hnd"}, {VDIPBIN, 0, T_VDISTR, "\0""txt"}}, 8, {{PTSOUT, 0, T_INT, "x1"}, {PTSOUT, 1, T_INT, "y1"}, {PTSOUT, 2, T_INT, "x2"}, {PTSOUT, 3, T_INT, "y2"}, {PTSOUT, 4, T_INT, "x3"}, {PTSOUT, 5, T_INT, "y3"},
																{PTSOUT, 6, T_INT, "x4"}, {PTSOUT, 7, T_INT, "y4"}}, OUT_NONE, FALSE},
	{117, NO_SUBCODE, EGAL, EGAL, "vqt_width", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{118, NO_SUBCODE, EGAL, EGAL, "vex_timv", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{119, NO_SUBCODE, EGAL, EGAL, "vst_load_fonts", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "select"}}, 1, {{INTOUT, 0, T_INT, "additional"}}, OUT_NONE, FALSE},
	{120, NO_SUBCODE, EGAL, EGAL, "vst_unload_fonts", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "select"}}, 0, {0}, OUT_NONE, FALSE},
	{121, NO_SUBCODE, EGAL, EGAL, "vrt_cpyfm", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{122, NO_SUBCODE, EGAL, EGAL, "v_show_c", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "count_hide"}}, 0, {0}, OUT_NONE, FALSE},
	{123, NO_SUBCODE, EGAL, EGAL, "v_hide_c", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{124, NO_SUBCODE, EGAL, EGAL, "vq_mouse", 1, {{CONTRL, 6, T_INT, "hnd"}}, 3, {{INTOUT, 0, T_INT, "status"}, {PTSOUT, 0, T_INT, "x"}, {PTSOUT, 1, T_INT, "y"}}, OUT_NONE, FALSE},
	{125, NO_SUBCODE, EGAL, EGAL, "vex_butv", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{126, NO_SUBCODE, EGAL, EGAL, "vex_motv", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{127, NO_SUBCODE, EGAL, EGAL, "vex_curv", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{128, NO_SUBCODE, EGAL, EGAL, "vq_key_s", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{129, NO_SUBCODE, EGAL, EGAL, "vs_clip", 6, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_INT, "on"}, {PTSIN, 0, T_INT, "x1"}, {PTSIN, 1, T_INT, "y1"}, {PTSIN, 2, T_INT, "x2"}, {PTSIN, 3, T_INT, "y2"}}, 0, {0}, OUT_NONE, FALSE},
	{130, NO_SUBCODE, EGAL, EGAL, "vqt_name", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{131, NO_SUBCODE, EGAL, EGAL, "vqt_fontinfo", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{132, NO_SUBCODE, EGAL, EGAL, "vqt_justified", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{170, NO_SUBCODE, EGAL, EGAL, "vr_transfer_bits", 5, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_TRANSFER_MODE, "mode"}, {VDIPBIN, 0, T_V_PLINE, "xy"}, {CONTRL, 7, T_GCBITMAP, "src"}, {CONTRL, 9, T_GCBITMAP, "dst"}}, 0, {0}, OUT_NONE, FALSE},
	{171, 0, EGAL, EGAL, "vr_clip_rects_by_dst", 13, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "dst_clip_rect.x"}, {PTSIN, 1, T_INT, "dst_clip_rect.y"}, {PTSIN, 2, T_INT, "dst_clip_rect.h"}, {PTSIN, 3, T_INT, "dst_clip_rect.w"}, 
											 {PTSIN, 4, T_INT, "src_rect.x"}, {PTSIN, 5, T_INT, "src_rect.y"}, {PTSIN, 6, T_INT, "src_rect.h"}, {PTSIN, 7, T_INT, "src_rect.w"},
											 {PTSIN, 8, T_INT, "dst_rect.x"}, {PTSIN, 9, T_INT, "dst_rect.y"}, {PTSIN,10, T_INT, "dst_rect.h"}, {PTSIN,11, T_INT, "dst_rect.w"}},
											 9, {{PTSOUT, 0, T_INT, "clip_src_rect.x"}, {PTSOUT, 1, T_INT, "clip_src_rect.y"}, {PTSOUT, 2, T_INT, "clip_src_rect.h"}, {PTSOUT, 3, T_INT, "clip_src_rect.w"}, 
											    {PTSOUT, 4, T_INT, "clip_dst_rect.x"}, {PTSOUT, 5, T_INT, "clip_dst_rect.y"}, {PTSOUT, 6, T_INT, "clip_dst_rect.h"}, {PTSOUT, 7, T_INT, "clip_dst_rect.w"}, 
											    {INTOUT, 9, T_INT, "ret"}}, OUT_NONE, FALSE},
	{190, NO_SUBCODE, EGAL, EGAL, "vqt_char_index", 0, {0}, 0, {0}, OUT_NONE, FALSE},

	{200, 0, EGAL, EGAL, "vst_fg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},
	{200, 1, EGAL, EGAL, "vsf_fg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},
	{200, 2, EGAL, EGAL, "vsl_fg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},
	{200, 3, EGAL, EGAL, "vsm_fg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},
	{200, 4, EGAL, EGAL, "vsr_fg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},

	{201, 0, EGAL, EGAL, "vst_bg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},
	{201, 1, EGAL, EGAL, "vsf_bg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},
	{201, 2, EGAL, EGAL, "vsl_bg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},
	{201, 3, EGAL, EGAL, "vsm_bg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},
	{201, 4, EGAL, EGAL, "vsr_bg_color", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "color_space"}}, 1, {{INTOUT, 0, T_INT, "ret"}}, OUT_NONE, FALSE},

	{202, 0, EGAL, EGAL, "vqt_fg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},
	{202, 1, EGAL, EGAL, "vqf_fg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},
	{202, 2, EGAL, EGAL, "vql_fg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},
	{202, 3, EGAL, EGAL, "vqm_fg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},
	{202, 4, EGAL, EGAL, "vqr_fg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},

	{203, 0, EGAL, EGAL, "vqt_bg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},
	{203, 1, EGAL, EGAL, "vqf_bg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},
	{203, 2, EGAL, EGAL, "vql_bg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},
	{203, 3, EGAL, EGAL, "vqm_bg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},
	{203, 4, EGAL, EGAL, "vqr_bg_color", 1, {{CONTRL, 6, T_INT, "hnd"}}, 1, {{INTOUT, 0, T_LONG, "color_space"}}, OUT_NONE, FALSE},

	{204, 0, EGAL, EGAL, "v_color2value", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{204, 1, EGAL, EGAL, "v_value2color", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{204, 2, EGAL, EGAL, "v_color2nearest", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{204, 3, EGAL, EGAL, "vq_px_format", 1, {{CONTRL, 6, T_INT, "hnd"}}, 2, {{INTOUT, 0, T_LONG_HEX, "color_space"}, {INTOUT, 2, T_LONG_HEX, "px_format"}}, OUT_NONE, FALSE},
	{205, 0, EGAL, EGAL, "vs_ctab", 1, {{CONTRL, 6, T_INT, "hnd"}}, 0, {0}, OUT_NONE, FALSE},
	{205, 1, EGAL, EGAL, "vs_ctab_entry", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{205, 2, EGAL, EGAL, "vs_dflt_ctab", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{206, 0, EGAL, EGAL, "vq_ctab", 2, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG, "ctab_length"}}, 0, {0}, OUT_NONE, FALSE},
	{206, 1, EGAL, EGAL, "vq_ctab_entry", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{206, 2, EGAL, EGAL, "vq_ctab_id", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{206, 3, EGAL, EGAL, "v_ctab_idx2vdi", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{206, 4, EGAL, EGAL, "v_ctab_vdi2idx", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{206, 5, EGAL, EGAL, "v_ctab_idx2value", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{206, 6, EGAL, EGAL, "v_get_ctab_id", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{206, 7, EGAL, EGAL, "vq_dflt_ctab", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{207, 0, EGAL, EGAL, "vs_hilite_color", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{207, 1, EGAL, EGAL, "vs_min_color", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{207, 2, EGAL, EGAL, "vs_max_color", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{207, 3, EGAL, EGAL, "vs_weight_color", 3, {{CONTRL, 6, T_INT, "hnd"}, {INTIN, 0, T_LONG_HEX, "color_space"}, {INTIN, 2, T_COLOR_ENTRY, 0L}}, 1, {{INTOUT, 0, T_INT, "ok"}}, OUT_NONE, FALSE},
	{208, 0, EGAL, EGAL, "v_create_itab", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{208, 1, EGAL, EGAL, "v_delete_itab", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{209, 0, EGAL, EGAL, "vq_hilite_color", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{209, 1, EGAL, EGAL, "vq_min_color", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{209, 2, EGAL, EGAL, "vq_max_color", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{209, 3, EGAL, EGAL, "vq_weight_color", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{229, NO_SUBCODE, EGAL, EGAL, "vqt_xfntinfo", 0, {0}, 0, {0}, OUT_NONE, FALSE},

	{230, 0, EGAL, EGAL, "vst_name", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{230, 100, EGAL, EGAL, "vqt_name_and_id", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{231, NO_SUBCODE, EGAL, EGAL, "vst_width", 2, {{CONTRL, 6, T_INT, "hnd"}, {PTSIN, 0, T_INT, "width"}}, 4, {{PTSOUT, 0, T_INT, "char_width"},
																{PTSOUT, 1, T_INT, "char_height"}, {PTSOUT, 2, T_INT, "cell_width"}, {PTSOUT, 3, T_INT, "cell_height"}}, OUT_NONE, FALSE},
	{232, NO_SUBCODE, EGAL, EGAL, "vqt_fontheader", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{234, NO_SUBCODE, EGAL, EGAL, "vqt_trackkern", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{235, NO_SUBCODE, EGAL, EGAL, "vqt_pairkern", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{236, NO_SUBCODE, 1, EGAL, "vst_charmap", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{236, NO_SUBCODE, 2, EGAL, "vst_map_mode", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{237, NO_SUBCODE, 3, EGAL, "vst_kern", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{237, NO_SUBCODE, 4, EGAL, "vst_track_offset", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{239, NO_SUBCODE, EGAL, EGAL, "v_getbitmap_info", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{240, 0, EGAL, EGAL, "vqt_f_extent", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{240, 4200, EGAL, EGAL, "vqt_real_extent", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{241, NO_SUBCODE, EGAL, 1, "v_ftext", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{241, NO_SUBCODE, EGAL, EGAL, "v_ftext_offset", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{243, 0, EGAL, EGAL, "v_getoutline", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{243, 1, EGAL, EGAL, "v_get_outline", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{246, NO_SUBCODE, EGAL, EGAL, "vst_arbpt32", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{247, NO_SUBCODE, EGAL, EGAL, "vqt_advance32", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{248, 0, EGAL, EGAL, "vq_devinfo", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{248, 4242, EGAL, EGAL, "vq_ext_devinfo", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{252, NO_SUBCODE, EGAL, EGAL, "vst_setsize32", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{253, NO_SUBCODE, EGAL, EGAL, "vst_skew", 0, {0}, 0, {0}, OUT_NONE, FALSE},
	{0, 0, 0, 0, 0L, 0, {0}, 0, {0}, OUT_NONE, FALSE}
};

int init_vdifuncs(void)
{
	int i;
	long size;
	VDIFUNC *func = vdi_func;
	vdi_funcs.min_hash = func->opcode;
	vdi_funcs.max_hash = func->opcode;
	while (func->name) {

		for(i = 0; i < func->ret_anz; i++) {
			switch (func->retpara[i].intype) {
			case INTOUT:
				func->outbits |= OUT_INT;
				break;
			case PTSOUT:
				func->outbits |= OUT_PTS;
				break;
			}
		}

		if ((unsigned int)func->opcode < vdi_funcs.min_hash)
			vdi_funcs.min_hash = func->opcode;
		if ((unsigned int)func->opcode > vdi_funcs.max_hash)
			vdi_funcs.max_hash = func->opcode;
		func++;
	}
	size = (vdi_funcs.max_hash - vdi_funcs.min_hash + 1) * sizeof(VDIFUNC*);
	vdi_funcs.hash = Malloc(size);
	if (!vdi_funcs.hash)
		return FALSE;
	memset(vdi_funcs.hash, 0, size);
	func = vdi_func;
	while (func->name) {
		if (!vdi_funcs.hash[(unsigned int)func->opcode - vdi_funcs.min_hash])		/* Nur den ersten merken! */
			vdi_funcs.hash[(unsigned int)func->opcode - vdi_funcs.min_hash] = func;
		func++;
	}
	return TRUE;
}

void deinit_vdifuncs(void)
{
	if (vdi_funcs.hash)
		Mfree(vdi_funcs.hash);
}

int init_vdi(void)
{
	return init_vdifuncs();
}

void deinit_vdi(void)
{
	deinit_vdifuncs();
}

#define VDI_MAX_REENTRANCE 32
#define VDI_INFO_SIZE 26
extern long vdi_info[];
extern void *nach_vditrap;
int deinit_vdipending(void)
{
/* "Pending" traps zur…kbiegen, damit sie nicht irgendwann in Manitor zur…kkehren, wenn Manitor schon weg ist! */
	long *tab = vdi_info;
	int ok = TRUE;
	int i = VDI_MAX_REENTRANCE - 1;
	do {
		if (tab[0]) {	/* Basepage ausgef〕lt (Eintrag g〕tig) */
			if (*(long *)(tab[2]) == (long)nach_vditrap) {	/* Wurde von Manitor verbogen? */
				*(long *)(tab[2]) = tab[1];	/* verbogene Returnadresse zur…kbiegen! */
			} else {
				ok = FALSE;	/* Kann nicht zur…kverbogen werden! */
			}
		}
		(char *)tab += VDI_INFO_SIZE;
	} while (--i >= 0);
	return ok;
}

VDIFUNC *find_vdifunc(int opcode, int subcode, int contrl3, int contrl1)
{
	VDIFUNC *func;

	if (opcode < vdi_funcs.min_hash || opcode > vdi_funcs.max_hash)
		return 0L;

	func = vdi_funcs.hash[opcode - vdi_funcs.min_hash];

	if (func) {
		while (func->name && func->opcode == opcode) {
			if (	(func->subcode == NO_SUBCODE || func->subcode == subcode) &&
					(func->anz_intin == EGAL || func->anz_intin == contrl3) &&
					(func->anz_ptsin == EGAL || func->anz_ptsin == contrl1) )
				return func;
			func++;
		}

/* Nicht gefunden - evtl. contrl[5] (subcode) falsch gesetzt: */

		return vdi_funcs.hash[opcode - vdi_funcs.min_hash];	/* Einfach den ersten nehmen */
	}

	return 0L;
}

void show_vdifunc(VDIFUNC *func, VDIPB *pb)
{
	VDIPARA *para = func->para;
	void *ptr;
	int komma = FALSE;
	int i = func->para_anz;

	fillbuf(" ", 1);
	fillbuf_string(func->name);
	fillbuf("(", 1);

	while (--i >= 0) {
		if (komma)
			fillbuf(", ", 2);
		switch (para->intype) {
		case INTIN:
			ptr = &pb->intin[para->idx];
			break;
		case PTSIN:
			ptr = &pb->ptsin[para->idx];
			break;
		case CONTRL:
			ptr = &pb->contrl[para->idx];
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

/* Liefert zur…k, in welchen "OUT"-Arrays was geliefert wird:
	Bit 0: intout
	Bit 1: ptsout
*/
int vdi_trace(VDIPB *pb)
{
	int back = 0;

	show_returncodes();

	if (vdi_is_traced) {
		int opcode = pb->contrl[0];
		int subcode = pb->contrl[5];
		int contrl3 = pb->contrl[3];
		int contrl1 = pb->contrl[1];
		VDIFUNC *func = find_vdifunc(opcode, subcode, contrl3, contrl1);
		if (func)
			back = func->outbits;

		if (!func || !func->filtered) {
			char nr[12];
			char *prc_name;
			char *app_name;

			get_prg(*p_run, -1, &prc_name, &app_name);
			if (!prg_is_filtered(prc_name, app_name)) {
				if (show_timer) {
					ultoa((*(long *)0x4BAL) - begin_timer, nr, 10);
					fillbuf_string(nr);
					fillbuf(": ", 2);
				}
	
				fillbuf_prg(-1, prc_name, app_name, SIZE_PRG);
	
				if (show_trap || !func) {
					if (!show_short_trap || !func) {
						fillbuf(" {VDI #", 7);
						itoa(opcode, nr, 10);
						fillbuf_string(nr);
						if (func && func->subcode != NO_SUBCODE) {
							fillbuf(",", 1);
							itoa(subcode, nr, 10);
							fillbuf_string(nr);
						}
						fillbuf("}", 1);
					} else {
						fillbuf(" V:", 3);
					}
				}
				if (func)
					show_vdifunc(func, pb);
				else {
					fillbuf(" ??? (control[5]=", 17);
					itoa(pb->contrl[5], nr, 10);
					fillbuf_string(nr);
					fillbuf(", control[3]=", 13);
					itoa(pb->contrl[3], nr, 10);
					fillbuf_string(nr);
					fillbuf(", control[1]=", 13);
					itoa(pb->contrl[1], nr, 10);
					fillbuf_string(nr);
					fillbuf(")\r\n", 3);
				}
			}
		}
	}
	return back;
}

void show_vdireturn(VDIFUNC *func, RETURN *ret)
{
	VDIPARA *para = func->retpara;
	void *ptr;
	int komma = FALSE;
	int i = func->ret_anz;

	while (--i >= 0) {
		switch (para->intype) {
		case INTOUT:
			ptr = &ret->intout[para->idx];
			break;
		case PTSOUT:
			ptr = &((int *)ret->addrout)[para->idx];
			break;
		case CONTRL:
			switch (para->idx) {
			case 1:
				ptr = &ret->contrl1;
				break;
			case 3:
				ptr = &ret->contrl3;
				break;
			case 5:
				ptr = &ret->contrl5;
				break;
			case 6:
				ptr = &ret->contrl6;
				break;
			}
			break;
		}

		if (komma)
			fillbuf(", ", 2);
		show_funcpara(para->typ, para->name, &ptr);

		komma = TRUE;
		para++;
	}
}

void vdi_return(RETURN *ret)
{
	VDIFUNC *func = find_vdifunc(ret->opcode, ret->contrl5, ret->contrl3, ret->contrl1);
	if ((!func || !func->filtered) && !prg_is_filtered(ret->prc_name, ret->app_name)) {
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
			show_vdireturn(func, ret);
		} else {
			fillbuf(">{VDI #", 7);
			itoa(ret->opcode, nr, 10);
			fillbuf_string(nr);
			fillbuf("}=>", 3);
		}

		fillbuf_crlf();
	}
}
