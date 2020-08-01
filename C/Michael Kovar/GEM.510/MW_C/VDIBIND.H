/*
 * vdibind.h -- GEM VDI declarations and sample bindings
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

/* int v_arc( h, xc, yc, rad, sang, eang ) int h, xc, yc, rad, sang, eang; */
	int v_arc();
/* int v_bar( h, xy ) int h, xy[]; */
	int v_bar();
/* int v_bit_image( h, filename, aspect, scaling, num_pts, xy )
 * int h, aspect, scaling, num_pts;int xy[];char *filename; */
	int v_bit_image();
/* int v_cellarray( h, xy, row_length, el_per_row, num_rows, wr_mode, colors )
 * int h, xy[4], row_length, el_per_row, num_rows, wr_mode, *colors; */
	int v_cellarray();
/* int v_circle( h, xc, yc, rad ) int h, xc, yc, rad; */
	int v_circle();
/* int v_clear_disp_list( h ) int h; */
	int v_clear_disp_list();
/* int v_clrwk( h ) int h; */
	int v_clrwk();
/* int v_clsvwk( h ) int h; */
	int v_clsvwk();
/* int v_clswk( h ) int h; */
	int v_clswk();
/* int v_contourfill( h, x, y, index ) int h, x, y, index; */
	int v_contourfill();
/* int v_curdown( h ) int h; */
	int v_curdown();
/* int v_curhome( h ) int h; */
	int v_curhome();
/* int v_curleft( h ) int h; */
	int v_curleft();
/* int v_curright( h ) int h; */
	int v_curright();
/* int v_curtext( h, string ) int h; char *string;  */
	int v_curtext();
/* int v_curup( h ) int h; */
	int v_curup();
/* int v_dspcur( h, x, y ) int h, x, y; */
	int v_dspcur();
/* int v_eeol( h ) int h; */
	int v_eeol();
/* int v_eeos( h ) int h; */
	int v_eeos();
/* int v_ellarc( h, xc, yc, xrad, yrad, sang, eang )
 * int h, xc, yc, xrad, yrad, sang, eang; */
	int v_ellarc();
/* int v_ellipse( h, xc, yc, xrad, yrad ) int h, xc, yc, xrad, yrad; */
	int v_ellipse();
/* int v_ellpie( h, xc, yc, xrad, yrad, sang, eang)
 * int h, xc, yc, xrad, yrad, sang, eang; */
	int v_ellpie();
/* int v_enter_cur( h ) int h; */
	int v_enter_cur();
/* int vex_butv( h, usercode, savecode ) int h; long usercode, *savecode; */
	int vex_butv();
/* int vex_curv( h, usercode, savecode ) int h; long usercode, *savecode; */
	int vex_curv();
/* int v_exit_cur( h ) int h; */
	int v_exit_cur();
/* int vex_motv( h, usercode, savecode ) int h; long usercode, *savecode; */
	int vex_motv();
/* int vex_timv( h, tim_addr, old_addr, scale )
 * int h, *scale;long tim_addr, *old_addr; */
	int vex_timv();
/* int v_fillarea( h, count, xy) int h, count, xy[]; */
	int v_fillarea();
/* int v_form_adv( h ) int h; */
	int v_form_adv();
/* int v_get_pixel( h, x, y, pel, index ) int h, x, y, *pel, *index; */
	int v_get_pixel();
/* int v_gtext( h, x, y, string) int h, x, y; char *string; */
	int v_gtext();
/* int v_hardcopy( h ) int h; */
	int v_hardcopy();
/* int v_hide_c( h ) int h; */
	int v_hide_c();
/* int v_justified( h, x, y, string, length, word_space, char_space)
 * int h, x, y, length, word_space, char_space;char string[]; */
	int v_justified();
/* int v_meta_extents( h, min_x, min_y, max_x, max_y )
 * int h, min_x, min_y, max_x, max_y; */
	int v_meta_extents();
/* int vm_filename( h, filename ) int h; char *filename; */
	int vm_filename();
/* int v_opnvwk( work_in, h, work_out ) int work_in[], *h, work_out[]; */
	int v_opnvwk();
/* int v_opnwk( work_in, h, work_out ) int work_in[], *h, work_out[]; */
	int v_opnwk();
/* int v_output_window( h, xy ) int h, xy[]; */
	int v_output_window();
/* int v_pieslice( h, xc, yc, rad, sang, eang )
 * int h, xc, yc, rad, sang, eang; */
	int v_pieslice();
/* int v_pline( h, count, xy ) int h, count, xy[]; */
	int v_pline();
/* int v_pmarker( h, count, xy ) int h, count, xy[]; */
	int v_pmarker();
/* int vq_cellarray( h, xy, r_len, num_rs, el_used, rs_used, stat, colors )
 * int h, xy[], r_len, num_rs, *el_used, *rs_used, *stat, colors[]; */
	int vq_cellarray();
/* int vq_chcells( h, rows, columns ) int h, *rows, *columns; */
	int vq_chcells();
/* int vq_color( h, index, set_flag, rgb ) int h, index, set_flag, rgb[]; */
	int vq_color();
/* int vq_curaddress( h, row, column ) int h, *row, *column; */
	int vq_curaddress();
/* int vq_extnd( h, owflag, work_out ) int h, owflag, work_out[]; */
	int vq_extnd();
/* int vqf_attributes( h, attributes ) int h, attributes[]; */
	int vqf_attributes();
/* int vqin_mode( h, dev_type, mode ) int h, dev_type, *mode; */
	int vqin_mode();
/* int vq_key_s( h, status ) int h, *status; */
	int vq_key_s();
/* int vql_attributes( h, attributes ) int h, attributes[]; */
	int vql_attributes();
/* int vqm_attributes( h, attributes ) int h, attributes[]; */
	int vqm_attributes();
/* int vq_mouse( h, status, px, py ) int h, *status, *px, *py; */
	int vq_mouse();
/* int vqp_error( h ) int h; */
	int vqp_error();
/* int vqp_films( h, names ) int h; char names[]; */
	int vqp_films();
/* int vqp_state( h, port, filmnum, lightness, interlace, planes, indexes )
 * int h, *port, *filmnum, *lightness, *interlace, *planes, *indexes; */
	int vqp_state();
/* int vq_tabstatus( h ) int h; */
	int vq_tabstatus();
/* int vqt_attributes( h, attributes ) int h, attributes[]; */
	int vqt_attributes();
/* int vqt_extent( h, string, extent ) int h, extent[]; char string[]; */
	int vqt_extent();
/* int vqt_font_info( h, minADE, maxADE, distances, maxwidth, effects )
 * int h, *minADE, *maxADE, distances[], *maxwidth, effects[]; */
	int vqt_font_info();
/* int vqt_name( h, element_num, name ) int h, element_num; char name[]; */
	int vqt_name();
/* int vqt_width( h, character, cell_width, left_delta, right_delta )
 * int h, *cell_width, *left_delta, *right_delta; char character; */
	int vqt_width();
/* int v_rbox( h, xy ) int h, xy[]; */
	int v_rbox();
/* int v_rfbox( h, xy ) int h, xy[]; */
	int v_rfbox();
/* int v_rmcur( h ) int h; */
	int v_rmcur();
/* int vro_cpyfm( h, wr_mode, xy, srcMFDB, desMFDB )
 * int h, wr_mode, xy[], *srcMFDB, *desMFDB; */
	int vro_cpyfm();
/* int vrq_choice( h, in_choice, out_choice ) int h, in_choice, *out_choice; */
	int vrq_choice();
/* int vrq_locator( h, initx, inity, xout, yout, term )
 * int h, initx, inity, *xout, *yout, *term; */
	int vrq_locator();
/* int vrq_string( h, length, echo_mode, echo_xy, string)
 * int h, length, echo_mode, echo_xy[]; char *string; */
	int vrq_string();
/* int vrq_valuator( h, val_in, val_out, term )
 * int h, val_in, *val_out, *term; */
	int vrq_valuator();
/* int vr_recfl( h, xy ) int h, *xy; */
	int vr_recfl();
/* int vrt_cpyfm( h, wr_mode, xy, srcMFDB, desMFDB, index )
 * int h, wr_mode, *srcMFDB, *desMFDB, xy[], *index; */
	int vrt_cpyfm();
/* int vr_trnfm( h, srcMFDB, desMFDB ) int h, *srcMFDB, *desMFDB; */
	int vr_trnfm();
/* int v_rvoff( h ) int h; */
	int v_rvoff();
/* int v_rvon( h ) int h; */
	int v_rvon();
/* int vsc_form( h, cur_form ) int h, *cur_form; */
	int vsc_form();
/* int vs_clip( h, clip_flag, xy ) int h, clip_flag, xy[]; */
	int vs_clip();
/* int vs_color( h, index, rgb ) int h, index, *rgb; */
	int vs_color();
/* int vs_curaddress( h, row, column ) int h, row, column; */
	int vs_curaddress();
/* int vsf_color( h, index ) int h, index; */
	int vsf_color();
/* int vsf_interior( h, style ) int h, style; */
	int vsf_interior();
/* int vsf_perimeter( h, per_vis ) int h, per_vis; */
	int vsf_perimeter();
/* int vsf_style( h, index ) int h, index; */
	int vsf_style();
/* int vsf_udpat( h, fill_pat, planes ) int h, fill_pat[], planes; */
	int vsf_udpat();
/* int v_show_c( h, reset ) int h, reset; */
	int v_show_c();
/* int vsin_mode( h, dev_type, mode ) int h, dev_type, mode; */
	int vsin_mode();
/* int vsl_color( h, index ) int h, index; */
	int vsl_color();
/* int vsl_ends( h, beg_style, end_style) int h, beg_style, end_style; */
	int vsl_ends();
/* int vsl_type( h, style ) int h, style; */
	int vsl_type();
/* int vsl_udsty( h, pattern ) int h, pattern; */
	int vsl_udsty();
/* int vsl_width( h, width ) int h, width; */
	int vsl_width();
/* int vsm_choice( h, choice ) int h, *choice; */
	int vsm_choice();
/* int vsm_color( h, index ) int h, index; */
	int vsm_color();
/* int vsm_height( h, height ) int h, height; */
	int vsm_height();
/* int vsm_locator( h, initx, inity, xout, yout, term )
 * int h, initx, inity, *xout, *yout, *term; */
	int vsm_locator();
/* int vsm_string( h, length, echo_mode, echo_xy, string )
 * int h, length, echo_mode, echo_xy[];char *string; */
	int vsm_string();
/* int vsm_type( h, symbol ) int h, symbol; */
	int vsm_type();
/* int vsm_valuator( h, val_in, val_out, term, status )
 * int h, val_in, *val_out, *term, *status; */
	int vsm_valuator();
/* int vs_palette( h, palette ) int h, palette; */
	int vs_palette();
/* int vsp_message( h ) int h; */
	int vsp_message();
/* int vsp_save( h ) int h; */
	int vsp_save();
/* int vsp_state( h, port, filmnum, lightness, interlace, planes, indexes )
 * int h, port, filmnum, lightness, interlace, planes, *indexes; */
	int vsp_state();
/* int vst_alignment( h, hor_in, vert_in, hor_out, vert_out )
 * int h, hor_in, vert_in, *hor_out, *vert_out; */
	int vst_alignment();
/* int vst_color( h, index ) int h, index; */
	int vst_color();
/* int vst_effects( h, effect ) int h, effect; */
	int vst_effects();
/* int vst_font( h, font ) int h, font; */
	int vst_font();
/* int vst_ht( h, ht, char_wd, char_ht, cell_wd, cell_ht )
 * int h, ht, *char_wd, *char_ht, *cell_wd, *cell_ht; */
	int vst_height();
/* int vst_load_fonts( h, select ) int h, select; */
	int vst_load_fonts();
/* int vst_point( h, point, char_wd, char_ht, cell_wd, cell_ht )
 * int h, point, *char_wd, *char_ht, *cell_wd, *cell_ht; */
	int vst_point();
/* int vst_rotation( h, angle ) int h, angle; */
	int vst_rotation();
/* int vst_unload_fonts( h, select ) int h, select; */
	int vst_unload_fonts();
/* int vswr_mode( h, mode ) int h, mode; */
	int vswr_mode();
/* int v_updwk( h ) int h; */
	int v_updwk();
/* int v_write_meta( h, num_ints, ints, num_pts, pts )
 * int h, num_ints, ints[], num_pts, pts[]; */
	int v_write_meta();

/* End of vdibind.h */
