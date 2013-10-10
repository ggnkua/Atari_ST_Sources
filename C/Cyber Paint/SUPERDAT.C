
#include "flicker.h"
#include "flicmenu.h"

extern white_slice(), show_sel_mode(), toggle_sel_mode(),
	spplay_forwards(), spplay_backwards(), sprewind(), spfast_forward(),
	spgo_first(), spgo_last(), super_mode(),
	spmnext_frame(), spmlast_frame(), spappend(), spinsert(),
	wbtext(), inverse_cursor(), wbnumber(), mmfeel_slider(), mmsee_slider(),
	spdecl_in_trange(), spstuff_tv(), change_trange(),
	spincr_in_trange(), spincl_in_trange(), spdecr_in_trange(),
	spdecl_in_trange(), see_trange(), toggle_group(), super_mode(),
	inc_slider(), dec_slider(), right_arrow(), left_arrow(),
	up_arrow(), down_arrow(), in_arrow(), out_arrow(),
	see_number_slider(), feel_number_slider(),
	see_n100_slider(), see_n160_slider(),
	black_block(), flash_red(), 
	mouse_movexy(),
	change_bigsmallce_mode(),
	change_axance_mode(), change_spmove_mode(),
	see_sp_scale(),
	ps_slide_scale(), ps_inc_slider(), ps_dec_slider(),
	super_preview(), clear_super(), super_render(),
	set_z_axis(), set_y_axis(), set_x_axis(), mouse_center(),
	show_screen_mode(), make_path_points(), make_prop_path(), make_path(),
	clear_path(), spadd_10(),
	show_spfirst(), toggle_spfirst(), default_center();

extern struct cursor cdown, cleft, cright, csleft,
	cinsert, cappend, cright2, cleft2, csright, cup;

extern struct slidepot frame_sl;
extern struct range trange;
extern short tween_mode;

#define SPTOP 115
#define SPY2  (SPTOP+15)
#define TBH 12
#define TBH2 16
#define TBH3 24
#define SPY3  (SPY2+TBH+2)

#define SPW1	35
#define SPW2	55
#define SPW3	50

#define SPX1	1
#define SPX2	(3+SPW2)
#define SPX4	(3+SPW2+2+SPW1+2+SPW3)

WORD spmove_mode = 0;
WORD screen_mode = 0;
WORD axance_mode = 2;
WORD bigsmallce_mode = 1;
WORD spfirst_mode;

	struct flicmenu spp_ppsample_sel = 
		{
		NULL,
		NOCHILD,
		SPX4-(SPW3+1)-1, SPY3+(TBH+2)*3,	223, TBH,
		"Sampled Path",
		wbtext,
		make_prop_path,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu spp_psample_sel = 
		{
		&spp_ppsample_sel,
		NOCHILD,
		SPX4-(SPW3+1)-1, SPY3+(TBH+2)*2,	223, TBH,
		"Clocked Sampled Path",
		wbtext,
		make_path,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu spp_popoints_sel = 
		{
		&spp_psample_sel,
		NOCHILD,
		SPX4-(SPW3+1)-1, SPY3+(TBH+2)*1,	223, TBH,
		"Path of Points",
		wbtext,
		make_path_points,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu spp_nothing = 
		{
		&spp_popoints_sel,
		NOCHILD,
		SPX4-(SPW3+1)-1, SPY3+(TBH+2)*0,	223, TBH,
		"Clear Path",
		wbtext,
		clear_path,
		NOGROUP, 0,
		NOKEY,
		};

	struct flicmenu spm_mousexy_sel = 
		{
		NONEXT,
		NOCHILD,
		SPX4-(SPW3+1)-1, SPY3+(TBH+2)*3,	223, TBH,
		"Mouse XY",
		wbtext,
		mouse_movexy,
		NOGROUP, 0,
		NOKEY,
		};
	struct slidepot spm_z_sl =
		{
		-501,
		499,
		-1,
		};
	extern struct flicmenu spm_z_sel;
	struct flicmenu spm_zf4 = 
		{
		&spm_mousexy_sel,
		NOCHILD,
		SPX4+159, SPY3+(TBH+2)*2,	12, TBH,
		(char *)&spm_z_sel,
		in_arrow,
		inc_slider,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu spm_z_sel = 
		{
		&spm_zf4,
		NOCHILD,
		SPX4-(SPW3+1)+14-1, SPY3+(TBH+2)*2,	143+(SPW3+1)+1, TBH,
		(char *)&spm_z_sl,
		see_number_slider,
		feel_number_slider,
		NOGROUP, 0,
		};
	struct flicmenu spm_zf2 = 
		{
		&spm_z_sel,
		NOCHILD,
		SPX4-(SPW3+1)-1, SPY3+(TBH+2)*2,	12, TBH,
		(char *)&spm_z_sel,
		out_arrow,
		dec_slider,
		NOGROUP, 0,
		NOKEY,
		};
	struct slidepot spm_y_sl =
		{
		-501,
		499,
		-1,
		};
	extern struct flicmenu spm_y_sel;
	struct flicmenu spm_yf4 = 
		{
		&spm_zf2,
		NOCHILD,
		SPX4+159, SPY3+(TBH+2)*1,	12, TBH,
		(char *)&spm_y_sel,
		down_arrow,
		inc_slider,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu spm_y_sel = 
		{
		&spm_yf4,
		NOCHILD,
		SPX4-(SPW3+1)+14-1, SPY3+(TBH+2)*1,	143+(SPW3+1)+1, TBH,
		(char *)&spm_y_sl,
		see_number_slider,
		feel_number_slider,
		NOGROUP, 0,
		};
	struct flicmenu spm_yf2 = 
		{
		&spm_y_sel,
		NOCHILD,
		SPX4-(SPW3+1)-1, SPY3+(TBH+2)*1,	12, TBH,
		(char *)&spm_y_sel,
		up_arrow,
		dec_slider,
		NOGROUP, 0,
		NOKEY,
		};
	struct slidepot spm_x_sl =
		{
		-501,
		499,
		-1,
		};
	extern struct flicmenu spm_x_sel;
	struct flicmenu spm_xf4 = 
		{
		&spm_yf2,
		NOCHILD,
		SPX4+159, SPY3,	12, TBH,
		(char *)&spm_x_sel,
		right_arrow,
		inc_slider,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu spm_x_sel = 
		{
		&spm_xf4,
		NOCHILD,
		SPX4-(SPW3+1)+14-1, SPY3,	143+(SPW3+1)+1, TBH,
		(char *)&spm_x_sl,
		see_number_slider,
		feel_number_slider,
		NOGROUP, 0,
		};
	struct flicmenu spm_xf2 = 
		{
		&spm_x_sel,
		NOCHILD,
		SPX4-(SPW3+1)-1, SPY3,	12, TBH,
		(char *)&spm_x_sel,
		left_arrow,
		dec_slider,
		NOGROUP, 0,
		NOKEY,
		};


		struct slidepot divisor_sl =
			{
			0,
			99,
			99,
			};
		extern struct flicmenu spsbs_units_sel;
		struct flicmenu spsbs_unitsf4 = 
			{
			NONEXT,
			NOCHILD,
			SPX4+159, SPY3+(TBH+2)*3,	12, TBH,
			(char *)&spsbs_units_sel,
			right_arrow,
			ps_inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spsbs_units_sel = 
			{
			&spsbs_unitsf4,
			NOCHILD,
			SPX4+14, SPY3+(TBH+2)*3,	143, TBH,
			(char *)&divisor_sl,
			see_number_slider,
			ps_slide_scale,
			NOGROUP, 0,
			};
		struct flicmenu spsbs_unitsf2 = 
			{
			&spsbs_units_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*3,	12, TBH,
			(char *)&spsbs_units_sel,
			left_arrow,
			ps_dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spsbs_units =
			{
			&spsbs_unitsf2,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*2, 171, TBH,
			"Enlarge",
			wbtext,
			NOGROUP, 0,
			NOKEY,
			};

		struct slidepot multiplier_sl =
			{
			0,
			99,
			99,
			};
		extern struct flicmenu spsbs_hundreds_sel;
		struct flicmenu spsbs_hundredsf4 = 
			{
			&spsbs_units,
			NOCHILD,
			SPX4+159, SPY3+(TBH+2)*1,	12, TBH,
			(char *)&spsbs_hundreds_sel,
			right_arrow,
			ps_inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spsbs_hundreds_sel = 
			{
			&spsbs_hundredsf4,
			NOCHILD,
			SPX4+14, SPY3+(TBH+2)*1,	143, TBH,
			(char *)&multiplier_sl,
			see_number_slider,
			ps_slide_scale,
			NOGROUP, 0,
			};
		struct flicmenu spsbs_hundredsf2 = 
			{
			&spsbs_hundreds_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*1,	12, TBH,
			(char *)&spsbs_hundreds_sel,
			left_arrow,
			ps_dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spsbs_hundreds =
			{
			&spsbs_hundredsf2,
			NOCHILD,
			SPX4, SPY3, 171, TBH,
			"Reduce",
			wbtext,
			NOGROUP, 0,
			NOKEY,
			};



extern struct flicmenu sprc_xf2;

	struct flicmenu sps_center_sub_sel =
		{
		NONEXT,
		&spsbs_hundreds,
		SPW1+3+SPW2+2+SPW3+2, SPY3,	223-SPW3-2, 54,
		NOTEXT,
		NOSEE,
		NOFEEL,
		NOGROUP, 0,
		NOKEY,
		};

	struct flicmenu sps_scale_sel =
		{
		&sps_center_sub_sel,
		NOCHILD,
		SPW1+3+SPW2+2, SPY3+(TBH2+2)*2+1,	SPW3, TBH2+1,
		NOTEXT,
		see_sp_scale,
		NOFEEL,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu sps_big_sel =
		{
		&sps_scale_sel,
		NOCHILD,
		SPW1+3+SPW2+2, SPY3+(TBH2+2)*1+1,	SPW3, TBH2,
		"Scale",
		wbtext,
		change_bigsmallce_mode,
		&bigsmallce_mode, 1,
		NOKEY,
		};
	struct flicmenu sps_center_sel =
		{
		&sps_big_sel,
		NOCHILD,
		SPW1+3+SPW2+2, SPY3,	SPW3, TBH2+1,
		"Center",
		wbtext,
		change_bigsmallce_mode,
		&bigsmallce_mode, 0,
		NOKEY,
		};




		struct slidepot turns_sl =
			{
			-17,
			15,
			-1,
			};
		extern struct flicmenu sprt_turns_sel;
		struct flicmenu sprt_turnsf4 = 
			{
			NONEXT,
			NOCHILD,
			SPX4+159, SPY3+(TBH+2)*3,	12, TBH,
			(char *)&sprt_turns_sel,
			right_arrow,
			inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu sprt_turns_sel = 
			{
			&sprt_turnsf4,
			NOCHILD,
			SPX4+14, SPY3+(TBH+2)*3,	143, TBH,
			(char *)&turns_sl,
			see_number_slider,
			feel_number_slider,
			NOGROUP, 0,
			};
		struct flicmenu sprt_turnsf2 = 
			{
			&sprt_turns_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*3,	12, TBH,
			(char *)&sprt_turns_sel,
			left_arrow,
			dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu sprt_turns =
			{
			&sprt_turnsf2,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*2, 171, TBH,
			"Full Turns:",
			wbtext,
			NOGROUP, 0,
			NOKEY,
			};

		struct slidepot angle_sl =
			{
			-361,
			359,
			-1,
			};
		extern struct flicmenu sprt_angle_sel;
		struct flicmenu sprt_anglef4 = 
			{
			&sprt_turns,
			NOCHILD,
			SPX4+159, SPY3+(TBH+2)*1,	12, TBH,
			(char *)&sprt_angle_sel,
			right_arrow,
			inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu sprt_angle_sel = 
			{
			&sprt_anglef4,
			NOCHILD,
			SPX4+14, SPY3+(TBH+2)*1,	143, TBH,
			(char *)&angle_sl,
			see_number_slider,
			feel_number_slider,
			NOGROUP, 0,
			};
		struct flicmenu sprt_anglef2 = 
			{
			&sprt_angle_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*1,	12, TBH,
			(char *)&sprt_angle_sel,
			left_arrow,
			dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu sprt_degrees =
			{
			&sprt_anglef2,
			NOCHILD,
			SPX4, SPY3, 171, TBH,
			"Part Turns (Degrees):",
			wbtext,
			NOGROUP, 0,
			NOKEY,
			};



		struct flicmenu spra_zax_sel =
			{
			NONEXT,
			NOCHILD,
			SPX4+2*(55+2)+2, SPY3+(TBH+2)*3,	55, TBH,
			"Z",
			wbtext,
			set_z_axis,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spra_yax_sel =
			{
			&spra_zax_sel,
			NOCHILD,
			SPX4+1*(55+2)+1, SPY3+(TBH+2)*3,	56, TBH,
			"Y",
			wbtext,
			set_y_axis,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spra_xax_sel =
			{
			&spra_yax_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*3,	56, TBH,
			"X",
			wbtext,
			set_x_axis,
			NOGROUP, 0,
			NOKEY,
			};
		struct slidepot spra_z_sl =
			{
			-101,
			99,
			99,
			};
		extern struct flicmenu spra_z_sel;
		struct flicmenu spra_zf4 = 
			{
			&spra_xax_sel,
			NOCHILD,
			SPX4+159, SPY3+(TBH+2)*2,	12, TBH,
			(char *)&spra_z_sel,
			in_arrow,
			inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spra_z_sel = 
			{
			&spra_zf4,
			NOCHILD,
			SPX4+14, SPY3+(TBH+2)*2,	143, TBH,
			(char *)&spra_z_sl,
			see_number_slider,
			feel_number_slider,
			NOGROUP, 0,
			};
		struct flicmenu spra_zf2 = 
			{
			&spra_z_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*2,	12, TBH,
			(char *)&spra_z_sel,
			out_arrow,
			dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct slidepot spra_y_sl =
			{
			-101,
			99,
			-1,
			};
		extern struct flicmenu spra_y_sel;
		struct flicmenu spra_yf4 = 
			{
			&spra_zf2,
			NOCHILD,
			SPX4+159, SPY3+(TBH+2)*1,	12, TBH,
			(char *)&spra_y_sel,
			down_arrow,
			inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spra_y_sel = 
			{
			&spra_yf4,
			NOCHILD,
			SPX4+14, SPY3+(TBH+2)*1,	143, TBH,
			(char *)&spra_y_sl,
			see_number_slider,
			feel_number_slider,
			NOGROUP, 0,
			};
		struct flicmenu spra_yf2 = 
			{
			&spra_y_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*1,	12, TBH,
			(char *)&spra_y_sel,
			up_arrow,
			dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct slidepot spra_x_sl =
			{
			-101,
			99,
			-1,
			};
		extern struct flicmenu spra_x_sel;
		struct flicmenu spra_xf4 = 
			{
			&spra_yf2,
			NOCHILD,
			SPX4+159, SPY3,	12, TBH,
			(char *)&spra_x_sel,
			right_arrow,
			inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu spra_x_sel = 
			{
			&spra_xf4,
			NOCHILD,
			SPX4+14, SPY3,	143, TBH,
			(char *)&spra_x_sl,
			see_number_slider,
			feel_number_slider,
			NOGROUP, 0,
			};
		struct flicmenu spra_xf2 = 
			{
			&spra_x_sel,
			NOCHILD,
			SPX4, SPY3,	12, TBH,
			(char *)&spra_x_sel,
			left_arrow,
			dec_slider,
			NOGROUP, 0,
			NOKEY,
			};


		struct flicmenu sprc_default_sel =
			{
			NONEXT,
			NOCHILD,
			SPX4+66+21, SPY3+(TBH+2)*3,	64+20, TBH,
			"Default",
			wbtext,
			default_center,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu sprc_mousexy_sel =
			{
			&sprc_default_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*3,	64+21, TBH,
			"Mouse XY",
			wbtext,
			mouse_center,
			NOGROUP, 0,
			NOKEY,
			};
		struct slidepot sprc_z_sl =
			{
			-321,
			319,
			-1,
			};
		extern struct flicmenu sprc_z_sel;
		struct flicmenu sprc_zf4 = 
			{
			&sprc_mousexy_sel,
			NOCHILD,
			SPX4+159, SPY3+(TBH+2)*2,	12, TBH,
			(char *)&sprc_z_sel,
			in_arrow,
			inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu sprc_z_sel = 
			{
			&sprc_zf4,
			NOCHILD,
			SPX4+14, SPY3+(TBH+2)*2,	143, TBH,
			(char *)&sprc_z_sl,
			see_number_slider,
			feel_number_slider,
			NOGROUP, 0,
			};
		struct flicmenu sprc_zf2 = 
			{
			&sprc_z_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*2,	12, TBH,
			(char *)&sprc_z_sel,
			out_arrow,
			dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct slidepot sprc_y_sl =
			{
			-321,
			319,
			-1,
			};
		extern struct flicmenu sprc_y_sel;
		struct flicmenu sprc_yf4 = 
			{
			&sprc_zf2,
			NOCHILD,
			SPX4+159, SPY3+(TBH+2)*1,	12, TBH,
			(char *)&sprc_y_sel,
			down_arrow,
			inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu sprc_y_sel = 
			{
			&sprc_yf4,
			NOCHILD,
			SPX4+14, SPY3+(TBH+2)*1,	143, TBH,
			(char *)&sprc_y_sl,
			see_n100_slider,
			feel_number_slider,
			NOGROUP, 0,
			};
		struct flicmenu sprc_yf2 = 
			{
			&sprc_y_sel,
			NOCHILD,
			SPX4, SPY3+(TBH+2)*1,	12, TBH,
			(char *)&sprc_y_sel,
			up_arrow,
			dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct slidepot sprc_x_sl =
			{
			-321,
			319,
			-1,
			};
		extern struct flicmenu sprc_x_sel;
		struct flicmenu sprc_xf4 = 
			{
			&sprc_yf2,
			NOCHILD,
			SPX4+159, SPY3,	12, TBH,
			(char *)&sprc_x_sel,
			right_arrow,
			inc_slider,
			NOGROUP, 0,
			NOKEY,
			};
		struct flicmenu sprc_x_sel = 
			{
			&sprc_xf4,
			NOCHILD,
			SPX4+14, SPY3,	143, TBH,
			(char *)&sprc_x_sl,
			see_n160_slider,
			feel_number_slider,
			NOGROUP, 0,
			};
		struct flicmenu sprc_xf2 = 
			{
			&sprc_x_sel,
			NOCHILD,
			SPX4, SPY3,	12, TBH,
			(char *)&sprc_x_sel,
			left_arrow,
			dec_slider,
			NOGROUP, 0,
			NOKEY,
			};
	struct flicmenu spr_center_sub_sel =
		{
		NONEXT,
		&sprt_degrees,
		SPW1+3+SPW2+2+SPW3+2, SPY3,	223-SPW3-2, 54,
		NOTEXT,
		NOSEE,
		NOFEEL,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu spangle_sel =
		{
		&spr_center_sub_sel,
		NOCHILD,
		SPW1+3+SPW2+2, SPY3+(TBH2+2)*2+1,	SPW3, TBH2+1,
		"Turns",
		wbtext,
		change_axance_mode,
		&axance_mode, 2,
		NOKEY,
		};
	struct flicmenu spaxis_sel =
		{
		&spangle_sel,
		NOCHILD,
		SPW1+3+SPW2+2, SPY3+(TBH2+2)*1+1,	SPW3, TBH2,
		"Axis",
		wbtext,
		change_axance_mode,
		&axance_mode, 1,
		NOKEY,
		};
	struct flicmenu spr_center_sel =
		{
		&spaxis_sel,
		NOCHILD,
		SPW1+3+SPW2+2, SPY3,	SPW3, TBH2+1,
		"Center",
		wbtext,
		change_axance_mode,
		&axance_mode, 0,
		NOKEY,
		};
struct flicmenu sprot_sub_sel =
	{
	NONEXT,
	&spr_center_sel,
	SPW1+3+SPW2+2, SPY3,	223, 54,
	NOTEXT,
	NOSEE,
	NOFEEL,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu sppath_sel =
	{
	&sprot_sub_sel,
	NOCHILD,
	SPX2, SPY3+(TBH+2)*3,	SPW1, TBH,
	"Path",
	wbtext,
	change_spmove_mode,
	&spmove_mode, 3,
	NOKEY,
	};
struct flicmenu spmove_sel =
	{
	&sppath_sel,
	NOCHILD,
	SPX2, SPY3+(TBH+2)*2,	SPW1, TBH,
	"Move",
	wbtext,
	change_spmove_mode,
	&spmove_mode, 2,
	NOKEY,
	};
struct flicmenu spsize_sel =
	{
	&spmove_sel,
	NOCHILD,
	SPX2, SPY3+(TBH+2)*1,	SPW1, TBH,
	"Size",
	wbtext,
	change_spmove_mode,
	&spmove_mode, 1,
	NOKEY,
	};
struct flicmenu sprotate_sel =
	{
	&spsize_sel,
	NOCHILD,
	SPX2, SPY3,	SPW1, TBH,
	"Turn",
	wbtext,
	change_spmove_mode,
	&spmove_mode, 0,
	NOKEY,
	};
struct flicmenu spscreen_sel =
	{
	&sprotate_sel,
	NOCHILD,
	SPX1, SPY3+(TBH+2)*3,	SPW2, TBH,
	NOTEXT,
	show_screen_mode,
	toggle_group,
	&screen_mode, -5, /* just bogus so never hilit */
	NOKEY,
	};
struct flicmenu spfirst_sel =
	{
	&spscreen_sel,
	NOCHILD,
	SPX1, SPY3+(TBH+2)*2,	SPW2, TBH,
	"First",
	show_spfirst,
	toggle_spfirst,
	&spfirst_mode, -5,
	NOKEY,
	};
struct flicmenu spuse_sel =
	{
	&spfirst_sel,
	NOCHILD,
	SPX1, SPY3+(TBH+2)*1,	SPW2, TBH,
	"Render",
	wbtext,
	super_render,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spclear_sel =
	{
	&spuse_sel,
	NOCHILD,
	SPX1, SPY3+(TBH+2)*0,	SPW2, TBH,
	"Clear",
	wbtext,
	clear_super,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu sppreview_sel =
	{
	&spclear_sel,
	NOCHILD,
	SPX1, SPY2,	SPW2, TBH,
	"Preview",
	wbtext,
	super_preview,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu sptween_sel =
	{
	&sppreview_sel,
	NOCHILD,
	281+37-8-2, SPY2,	8+2, TBH,
	"t",
	wbtext,
	toggle_group,
	&tween_mode, 1,
	't',
	};
struct flicmenu spinc_tright_sel =
	{
	&sptween_sel,
	NOCHILD,
	217+51+1-4+49-9+2-1-12, SPY2,	12, TBH,
	(char *)&cright,
	inverse_cursor,
	spincr_in_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spright_time_sel =
	{
	&spinc_tright_sel,
	NOCHILD,
	217+51+1-4+10+1+2+1-12, SPY2,	25, TBH,
	(char *)&trange.v2,
	wbnumber,
	spstuff_tv,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spdec_tright_sel =
	{
	&spright_time_sel,
	NOCHILD,
	217+51+1-4-12, SPY2,	12, TBH,
	(char *)&cleft,
	inverse_cursor,
	spdecr_in_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spsegment_sel = 
	{
	&spdec_tright_sel,
	NOCHILD,
	SPX2+55, SPY2,	207-12-SPX2+1, TBH,
	(char *)&trange,
	see_trange,
	change_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spinc_tleft_sel =
	{
	&spsegment_sel,
	NOCHILD,
	SPX2+49-9+2-1, SPY2,	12, TBH,
	(char *)&cright,
	inverse_cursor,
	spincl_in_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spleft_time_sel =
	{
	&spinc_tleft_sel,
	NOCHILD,
	SPX2+10+1+2+1, SPY2,	25, TBH,
	(char *)&trange.v1,
	wbnumber,
	spstuff_tv,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spdec_tleft_sel =
	{
	&spleft_time_sel,
	NOCHILD,
	SPX2, SPY2,	12, TBH,
	(char *)&cleft,
	inverse_cursor,
	spdecl_in_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu spselmode_sel = 
	{
	&spdec_tleft_sel,
	NOCHILD,
	281+37-8-3, SPTOP+1,	8+3, TBH,
	NOTEXT,
	show_sel_mode,
	toggle_sel_mode,
	&select_mode, 1,
	'.',
	};
struct flicmenu spframes_sel = 
	{
	&spselmode_sel,
	NOCHILD,
	278, SPTOP+1,	27, TBH,
	(char *)&screen_ct,
	wbnumber,
	spadd_10,
	NOGROUP, 0,
	'\r',
	};
struct flicmenu apc6fa = 
	{
	&spframes_sel,
	NOCHILD,
	265-1, SPTOP+1,	12, TBH,
	(char *)&cdown,
	inverse_cursor,
	spgo_last,
	NOGROUP, 0,
	0x4400,	/* F10 */
	};
struct flicmenu apc6f9 = 
	{
	&apc6fa,
	NOCHILD,
	247-1, SPTOP+1,	16, TBH,
	(char *)&cright2,
	inverse_cursor,
	spfast_forward,
	NOGROUP, 0,
	0x4300,	/* F9 */
	};
struct flicmenu apc6f8 = 
	{
	&apc6f9,
	NOCHILD,
	231-1, SPTOP+1,	14, TBH,
	(char *)&cright,
	inverse_cursor,
	spplay_forwards,
	NOGROUP, 0,
	0x4200,	/* F8 */
	};
struct flicmenu apc6f8a = 
	{
	&apc6f8,
	NOCHILD,
	231-1, SPTOP+1,	14, TBH,
	NOTEXT,
	NOSEE,
	spplay_forwards,
	NOGROUP, 0,
	0x5000,	/* down arrow */
	};
struct flicmenu apc6f7 = 
	{
	&apc6f8a,
	NOCHILD,
	213-1, SPTOP+1,	16, TBH,
	(char *)&cappend,
	inverse_cursor,
	spappend,
	NOGROUP, 0,
	0x4100,	/* F7 */
	};
struct flicmenu apc6f4 = 
	{
	&apc6f7,
	NOCHILD,
	195-1, SPTOP+1,	16, TBH,
	(char *)&csright,
	inverse_cursor,
	spmnext_frame,
	NOGROUP, 0,
	0x4000,	/* F6 */
	};
struct flicmenu apc6f4a = 
	{
	&apc6f4,
	NOCHILD,
	195-1, SPTOP+1,	16, TBH,
	NOTEXT,
	NOSEE,
	spmnext_frame,
	NOGROUP, 0,
	0x4d00,	/* right arrow */
	};
struct flicmenu spframe_sel = 
	{
	&apc6f4a,
	NOCHILD,
	85-1, SPTOP+1,	108, TBH,
	(char *)&frame_sl,
	mmsee_slider,
	mmfeel_slider,
	NOGROUP, 0,
	};
struct flicmenu apc6f2 = 
	{
	&spframe_sel,
	NOCHILD,
	67-1, SPTOP+1,	16, TBH,
	(char *)&csleft,
	inverse_cursor,
	spmlast_frame,
	NOGROUP, 0,
	0x3f00,	/* F5 */
	};
struct flicmenu apc6f2a = 
	{
	&apc6f2,
	NOCHILD,
	67-1, SPTOP+1,	16, TBH,
	NOTEXT,
	NOSEE,
	spmlast_frame,
	NOGROUP, 0,
	0x4b00,	/* left arrow */
	};
struct flicmenu apc6f1 = 
	{
	&apc6f2a,
	NOCHILD,
	49-1, SPTOP+1,	16, TBH,
	(char *)&cinsert,
	inverse_cursor,
	spinsert,
	NOGROUP, 0,
	0x3e00,	/* F4 */
	};
struct flicmenu apc6f0 = 
	{
	&apc6f1,
	NOCHILD,
	33-1, SPTOP+1,	14, TBH,
	(char *)&cleft,
	inverse_cursor,
	spplay_backwards,
	NOGROUP, 0,
	0x3d00,	/* F3 */
	};
struct flicmenu apc6f0a = 
	{
	&apc6f0,
	NOCHILD,
	33-1, SPTOP+1,	14, TBH,
	NOTEXT,
	NOSEE,
	spplay_backwards,
	NOGROUP, 0,
	0x4800,	/* up arrow */
	};
struct flicmenu apc6ef = 
	{
	&apc6f0a,
	NOCHILD,
	15, SPTOP+1,	15, TBH,
	(char *)&cleft2,
	inverse_cursor,
	sprewind,
	NOGROUP, 0,
	0x3c00,	/* F2 */
	};
struct flicmenu apc6ee = 
	{
	&apc6ef,
	NOCHILD,
	1, SPTOP+1,	12, TBH,
	(char *)&cup,
	inverse_cursor,
	spgo_first,
	NOGROUP, 0,
	0x3b00,	/* F1 */
	};
struct flicmenu supermove_menu = 
	{
	NONEXT,
	&apc6ee,
	0, SPTOP,	319, 84,
	NOTEXT,
	white_slice,
	NOFEEL,
	NOGROUP, 0,
	};
