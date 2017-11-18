/************************************************************************/
/*	VDIBIND.H	VDI External Declarations.			*/
/*		Copyright 1985 Atari Corp.				*/
/************************************************************************/

extern	int	v_opnwk();
extern	int	v_clswk();
extern	int	v_clrwk();
extern	int	v_clswk();
extern	int	vq_chcells();
extern	int	v_exit_cur();
extern	int	v_enter_cur();
extern	int	v_curup();
extern	int	v_curdown();
extern	int	v_curright();
extern	int	v_curleft();
extern	int	v_curhome();
extern	int	v_eeos();
extern	int	v_eeol();
extern	int	vs_curaddress();
extern	int	v_curtext();
extern	int	v_rvon();
extern	int	v_rvoff();
extern	int	vq_curaddress();
extern	int	vq_tabstatus();
extern	int	v_hardcopy ();
extern	int	v_dspcur();
extern	int	v_rmcur ();
extern	int	v_pline();
extern	int	v_pmarker();
extern	int	v_gtext();
extern	int	v_fillarea();

extern	int	v_bar();
extern	int	v_circle();
extern	int	v_arc();
extern	int	v_pieslice();
extern	int	v_ellipse();
extern	int	v_ellarc();
extern	int	v_ellpie();

extern	int	vst_height();
extern	int	vst_rotation();
extern	int	vs_color();
extern	int	vsl_type();
extern	int	vsl_width();
extern	int	vsl_color();
extern	int	vsm_type();
extern	int	vsm_height();
extern	int	vsm_color();
extern	int	vst_font();
extern	int	vst_color();
extern	int	vsf_interior();
extern	int	vsf_style();
extern	int	vsf_color();
extern	int	vq_color();

extern	int	vrq_locator();
extern	int	vsm_locator();
extern	int	vrq_valuator();
extern	int	vsm_valuator();
extern	int	vrq_choice();
extern	int	vsm_choice();
extern	int	vrq_string();
extern	int	vsm_string();
extern	int	vswr_mode();
extern	int	vsin_mode();

extern	int	vsf_perimeter();

extern	int	vr_cpyfm();
extern	int	vr_trnfm();
extern	int	vsc_form();
extern	int	vsf_udpat();
extern	int	vsl_udsty();
extern	int	vr_recfl();
extern	int	v_show_c();
extern	int	v_hide_c();
extern	int	vq_mouse();
extern	int	vex_butv();
extern	int	vex_motv();
extern	int	vex_curv();
extern	int	vq_key_s();			
