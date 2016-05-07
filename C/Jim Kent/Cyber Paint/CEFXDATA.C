

#include "flicker.h"
#include "flicmenu.h"

#define DOFF	117
#define MMDY	11
#define TSYOFF	130
#define TSDY	10
#define CXSUBY	164


extern show_sel_mode(), wbnumber(), inverse_cursor(), mmsee_slider(), 
	white_slice(), see_trange(), see_colors2(), see_range(),
	wbnumber1(), wbtext(), white_block(), see_number_slider(),
	left_arrow(), right_arrow(), yellow_block(), black_block();

extern toggle_sel_mode(), cxadd_ten(), cxgo_first(), cxfast_forward(),
	cxplay_forwards(), cxappend(), cxnext_frame(), cxfeel_slider(),
	cxlast_frame(), cxinsert(), cxplay_backwards(), cxrewind(), cxgo_last(),
	cx_grab_color(), change_csegment(), change_mode(), feel_number_slider(),
	inc_slider(), dec_slider(), jump_palette(),
	toggle_group(), cxrestore();

extern cxstuff_tv(), cxdecl_in_trange(), cxincl_in_trange(), cxdecr_in_trange(),
	cxincr_in_trange(), change_trange(), change_cxsub(), cxpreview(),
	cxrender();

extern struct cursor cdown, cdrizzle, cflood, cleft,
	cline, cpen, cpolygon, cright, cup, cright2, cleft2,
	cappend, cinsert,
	cseparate, csleft, cspray, csright;

extern WORD tween_mode;

extern struct slidepot frame_sl;
extern struct range trange;
extern struct range csegment;
extern struct grid cb_grid;

extern struct flicmenu cxnormal_sel, cxtint_sel, cxfpc_sel;

/* START OF CYCLE SUBSELECTIONS */
	struct slidepot cxcyc_sl =
		{
		0,
		499,
		16,
		};
	extern struct flicmenu cxcyc_sel;
	struct flicmenu cxrcyc_sel = 
		{
		NONEXT,
		NOCHILD,
		303, 182,	15, 16,
		(char *)&cxcyc_sel,
		right_arrow,
		inc_slider,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu cxcyc_sel = 
		{
		&cxrcyc_sel,
		NOCHILD,
		177, 182,	124, 16,
		(char *)&cxcyc_sl,
		see_number_slider,
		feel_number_slider,
		NOGROUP, 0,
		};
	struct flicmenu cxlcyc_sel = 
		{
		&cxcyc_sel,
		NOCHILD,
		160, 182,	15, 16,
		(char *)&cxcyc_sel,
		left_arrow,
		dec_slider,
		NOGROUP, 0,
		NOKEY,
		};
	WORD cxcyc_mode;
	struct flicmenu cxcycle_sel =
		{
		&cxlcyc_sel,
		NOCHILD,
		119, 182, 39, 16,
		"ShOT",
		wbtext,
		change_mode,
		&cxcyc_mode, 1,
		};
	struct slidepot cxfra_sl =
		{
		0,
		49,
		0,
		};
	extern struct flicmenu cxfra_sel;
	struct flicmenu cxrfra_sel = 
		{
		&cxcycle_sel,
		NOCHILD,
		303, 164,	15, 16,
		(char *)&cxfra_sel,
		right_arrow,
		inc_slider,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu cxfra_sel = 
		{
		&cxrfra_sel,
		NOCHILD,
		177, 164,	124, 16,
		(char *)&cxfra_sl,
		see_number_slider,
		feel_number_slider,
		NOGROUP, 0,
		};
	struct flicmenu cxlfra_sel = 
		{
		&cxfra_sel,
		NOCHILD,
		160, 164,	15, 16,
		(char *)&cxfra_sel,
		left_arrow,
		dec_slider,
		NOGROUP, 0,
		NOKEY,
		};
	struct flicmenu cxfpc_sel =
		{
		&cxlfra_sel,
		NOCHILD,
		119, 164, 39, 16,
		"FPSh",
		wbtext,
		change_mode,
		&cxcyc_mode, 0,
		};
/* END OF CYCLE SUBSELECTIONS */

/* START OF FADE SUBSELECTIONS */
struct slidepot cxtinting_sl =
	{
	-1,
	99,
	79,
	};
extern struct flicmenu cxtinting_sel;
struct flicmenu cxrtinting_sel = 
	{
	NONEXT,
	NOCHILD,
	303, 182,	15, 16,
	(char *)&cxtinting_sel,
	right_arrow,
	inc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu cxtinting_sel = 
	{
	&cxrtinting_sel,
	NOCHILD,
	185, 182,	116, 16,
	(char *)&cxtinting_sl,
	see_number_slider,
	feel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu cxltinting_sel = 
	{
	&cxtinting_sel,
	NOCHILD,
	168, 182,	15, 16,
	(char *)&cxtinting_sel,
	left_arrow,
	dec_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu cxpercent_sel =
	{
	&cxltinting_sel,
	NOCHILD,
	168, 164, 150, 16,
	"Max Tinting %:",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};
struct flicmenu cxfade_sub_sel =
	{
	NONEXT,
	&cxpercent_sel,
	168, 164, 150, 34,
	NOTEXT,
	white_block,
	NOFEEL,
	NOGROUP, 0,
	};
WORD cxfade_mode;
struct flicmenu cxblend_sel =
	{
	&cxfade_sub_sel,
	NOCHILD,
	119, 182, 47, 16,
	"Blend",
	wbtext,
	change_mode,
	&cxfade_mode, 1,
	};
struct flicmenu cxtint_sel =
	{
	&cxblend_sel,
	NOCHILD,
	119, 164, 47, 16,
	"Tint",
	wbtext,
	change_mode,
	&cxfade_mode, 0,
	};
/* END OF FADE SUBSELECTIONS */

/* START OF F/X SUBSELECTIONS */
WORD cfx_group;

struct flicmenu cxblue_sel =
	{
	NONEXT,
	NOCHILD,
	260, CXSUBY+24, 58, 10,
	"Blue",
	wbtext,
	change_mode,
	&cfx_group,8,
	};
struct flicmenu cxgreen_sel =
	{
	&cxblue_sel,
	NOCHILD,
	260, CXSUBY+12, 58, 10,
	"Green",
	wbtext,
	change_mode,
	&cfx_group,7,
	};
struct flicmenu cxred_sel =
	{
	&cxgreen_sel,
	NOCHILD,
	260, CXSUBY, 58, 10,
	"Red",
	wbtext,
	change_mode,
	&cfx_group,6,
	};
struct flicmenu cxmetal_sel =
	{
	&cxred_sel,
	NOCHILD,
	191, CXSUBY+12, 67, 10,
	"Metal",
	wbtext,
	change_mode,
	&cfx_group,5,
	};
struct flicmenu cxchrome_sel =
	{
	&cxmetal_sel,
	NOCHILD,
	191, CXSUBY+24, 67, 10,
	"Chrome",
	wbtext,
	change_mode,
	&cfx_group,4,
	};
struct flicmenu cxxerox_sel =
	{
	&cxchrome_sel,
	NOCHILD,
	191, CXSUBY, 67, 10,
	"Xerox",
	wbtext,
	change_mode,
	&cfx_group,3,
	};
struct flicmenu cxmono_sel =
	{
	&cxxerox_sel,
	NOCHILD,
	119, CXSUBY+24, 70, 10,
	"Mono",
	wbtext,
	change_mode,
	&cfx_group,2,
	};
struct flicmenu cxinverse_sel =
	{
	&cxmono_sel,
	NOCHILD,
	119, CXSUBY+12, 70, 10,
	"Inverse",
	wbtext,
	change_mode,
	&cfx_group,1,
	};
struct flicmenu cxnormal_sel =
	{
	&cxinverse_sel,
	NOCHILD,
	119, CXSUBY, 70, 10,
	"Normal",
	wbtext,
	change_mode,
	&cfx_group,0,
	};
/* END OF F/X SUBSELECTIONS */

struct flicmenu cxsubmenu_sel =
	{
	NONEXT,
	&cxnormal_sel,
	119, 164, 199, 34,
	NOTEXT,
	white_block,
	NOFEEL,
	NOGROUP, 0,
	};

WORD cx_sub_group = 2;
struct flicmenu cxfx_sel =
	{
	&cxsubmenu_sel,
	NOCHILD,
	68, CXSUBY, 49, 10,
	"f/x",
	wbtext,
	change_cxsub,
	&cx_sub_group,2,
	};
struct flicmenu cxfade_sel =
	{
	&cxfx_sel,
	NOCHILD,
	68, CXSUBY+24, 49, 10,
	"Fade",
	wbtext,
	change_cxsub,
	&cx_sub_group,1,
	};
struct flicmenu cxshift_sel =
	{
	&cxfade_sel,
	NOCHILD,
	68, CXSUBY+12, 49, 10,
	"Shift",
	wbtext,
	change_cxsub,
	&cx_sub_group,0,
	};
struct flicmenu cxrestore_sel =
	{
	&cxshift_sel,
	NOCHILD,
	1, CXSUBY+24,	65, 10,
	"Restore",
	wbtext,
	cxrestore,
	NOGROUP, 0,
	};
struct flicmenu cxrender_sel =
	{
	&cxrestore_sel,
	NOCHILD,
	1, CXSUBY+12,	65, 10,
	"Render",
	wbtext,
	cxrender,
	NOGROUP, 0,
	};
struct flicmenu cxpreview_sel =
	{
	&cxrender_sel,
	NOCHILD,
	1, CXSUBY,	65, 10,
	"Preview",
	wbtext,
	cxpreview,
	NOGROUP, 0,
	};
struct flicmenu cxcsegment_sel = 
	{
	&cxpreview_sel,
	NOCHILD,
	1, TSDY+TSYOFF+2+10+2,	317, 8,
	(char *)&csegment,
	see_range,
	change_csegment,
	NOGROUP, 0,
	};
struct flicmenu cxcbars_sel = 
	{
	&cxcsegment_sel,
	NOCHILD,
	0, TSDY+TSYOFF+2,	319, 10,
	(char *)&cb_grid,
	see_colors2,
	cx_grab_color,
	NOGROUP, 0,
	};

/* START TIME RANGE SELECTOR */
struct flicmenu cxpalette_sel =
	{
	&cxcbars_sel,
	NOCHILD,
	217+51+1-4+49-9+2-1-24+14+12, TSYOFF,	10, TSDY,
	"@",
	wbtext,
	jump_palette,
	NOGROUP, 0,
	'@',
	};
struct flicmenu cxtween_sel =
	{
	&cxpalette_sel,
	NOCHILD,
	217+51+1-4+49-9+2-1-24+14, TSYOFF,	10, TSDY,
	"t",
	wbtext,
	toggle_group,
	&tween_mode, 1,
	't',
	};
struct flicmenu cxinc_tright_sel =
	{
	&cxtween_sel,
	NOCHILD,
	217+51+1-4+49-9+2-1-24, TSYOFF,	12, TSDY,
	(char *)&cright,
	inverse_cursor,
	cxincr_in_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu cxtright_time_sel =
	{
	&cxinc_tright_sel,
	NOCHILD,
	217+51+1-4+10+1+2+1-24, TSYOFF,	25, TSDY,
	(char *)&trange.v2,
	wbnumber1,
	cxstuff_tv,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu cxdec_tright_sel =
	{
	&cxtright_time_sel,
	NOCHILD,
	217+51+1-4-24, TSYOFF,	12, TSDY,
	(char *)&cleft,
	inverse_cursor,
	cxdecr_in_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu cxtsegment_sel = 
	{
	&cxdec_tright_sel,
	NOCHILD,
	56, TSYOFF,	207-24, TSDY,
	(char *)&trange,
	see_trange,
	change_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu cxinc_tleft_sel =
	{
	&cxtsegment_sel,
	NOCHILD,
	1+49-9+2-1, TSYOFF,	12, TSDY,
	(char *)&cright,
	inverse_cursor,
	cxincl_in_trange,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu cxtleft_time_sel =
	{
	&cxinc_tleft_sel,
	NOCHILD,
	1+10+1+2+1, TSYOFF,	25, TSDY,
	(char *)&trange.v1,
	wbnumber1,
	cxstuff_tv,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu cxdec_tleft_sel =
	{
	&cxtleft_time_sel,
	NOCHILD,
	1, TSYOFF,	12, TSDY,
	(char *)&cleft,
	inverse_cursor,
	cxdecl_in_trange,
	NOGROUP, 0,
	NOKEY,
	};
/* END TIME RANGE SELECTOR */

/* SHUTTLE BAR */
struct flicmenu cxselmode_sel = 
	{
	&cxdec_tleft_sel,
	NOCHILD,
	281+37-8-3, DOFF,	8+3, MMDY,
	NOTEXT,
	show_sel_mode,
	toggle_sel_mode,
	&select_mode, 1,
	'.',
	};
struct flicmenu cxframes_sel = 
	{
	&cxselmode_sel,
	NOCHILD,
	281-3, DOFF,	37-10, MMDY,
	(char *)&screen_ct,
	wbnumber,
	cxadd_ten,
	NOGROUP, 0,
	'\r',
	};
struct flicmenu cmx_fa = 
	{
	&cxframes_sel,
	NOCHILD,
	266-2, DOFF,	13-1, MMDY,
	(char *)&cdown,
	inverse_cursor,
	cxgo_last,
	NOGROUP, 0,
	0x4400,	/* F10 */
	};
struct flicmenu cmx_f9 = 
	{
	&cmx_fa,
	NOCHILD,
	248-2, DOFF,	16, MMDY,
	(char *)&cright2,
	inverse_cursor,
	cxfast_forward,
	NOGROUP, 0,
	0x4300,	/* F9 */
	};
struct flicmenu cmx_f8 = 
	{
	&cmx_f9,
	NOCHILD,
	232-2, DOFF,	14, MMDY,
	(char *)&cright,
	inverse_cursor,
	cxplay_forwards,
	NOGROUP, 0,
	0x4200,	/* F8 */
	};
struct flicmenu xc6f8a = 
	{
	&cmx_f8,
	NOCHILD,
	232-2, DOFF,	14, MMDY,
	NOTEXT,
	NOSEE,
	cxplay_forwards,
	NOGROUP, 0,
	0x5000,	/* down arrow */
	};
struct flicmenu cmx_f7 = 
	{
	&xc6f8a,
	NOCHILD,
	214-2, DOFF,	16, MMDY,
	(char *)&cappend,
	inverse_cursor,
	cxappend,
	NOGROUP, 0,
	0x4100,	/* F7 */
	};
struct flicmenu cmx_f4 = 
	{
	&cmx_f7,
	NOCHILD,
	196-2, DOFF,	16, MMDY,
	(char *)&csright,
	inverse_cursor,
	cxnext_frame,
	NOGROUP, 0,
	0x4000,	/* F6 */
	};
struct flicmenu xc6f4a = 
	{
	&cmx_f4,
	NOCHILD,
	196-2, DOFF,	16, MMDY,
	NOTEXT,
	NOSEE,
	cxnext_frame,
	NOGROUP, 0,
	0x4d00,	/* right arrow */
	};
struct flicmenu cxframe_sel = 
	{
	&xc6f4a,
	NOCHILD,
	86-1, DOFF,	108-1, MMDY,
	(char *)&frame_sl,
	mmsee_slider,
	cxfeel_slider,
	NOGROUP, 0,
	};
struct flicmenu cmx_f2 = 
	{
	&cxframe_sel,
	NOCHILD,
	68-1, DOFF,	16, MMDY,
	(char *)&csleft,
	inverse_cursor,
	cxlast_frame,
	NOGROUP, 0,
	0x3f00,	/* F5 */
	};
struct flicmenu xc6f2a = 
	{
	&cmx_f2,
	NOCHILD,
	68-1, DOFF,	16, MMDY,
	NOTEXT,
	NOSEE,
	cxlast_frame,
	NOGROUP, 0,
	0x4b00,	/* left arrow */
	};
struct flicmenu cmx_f1 = 
	{
	&xc6f2a,
	NOCHILD,
	50-1, DOFF,	16, MMDY,
	(char *)&cinsert,
	inverse_cursor,
	cxinsert,
	NOGROUP, 0,
	0x3e00,	/* F4 */
	};
struct flicmenu cmx_f0 = 
	{
	&cmx_f1,
	NOCHILD,
	34-1, DOFF,	14, MMDY,
	(char *)&cleft,
	inverse_cursor,
	cxplay_backwards,
	NOGROUP, 0,
	0x3d00,	/* F3 */
	};
struct flicmenu xc6f0a = 
	{
	&cmx_f0,
	NOCHILD,
	34-1, DOFF,	14, MMDY,
	NOTEXT,
	NOSEE,
	cxplay_backwards,
	NOGROUP, 0,
	0x4800,	/* up arrow */
	};
struct flicmenu cmx_ef = 
	{
	&xc6f0a,
	NOCHILD,
	16-1, DOFF,	16, MMDY,
	(char *)&cleft2,
	inverse_cursor,
	cxrewind,
	NOGROUP, 0,
	0x3c00,	/* F2 */
	};
struct flicmenu cmx_ee = 
	{
	&cmx_ef,
	NOCHILD,
	1, DOFF,	12, MMDY,
	(char *)&cup,
	inverse_cursor,
	cxgo_first,
	NOGROUP, 0,
	0x3b00,	/* F1 */
	};
/* END SHUTTLE BAR */
struct flicmenu rcefx_menu = 
	{
	NONEXT,
	&cmx_ee,
	0, 116,	319, 83,
	NOTEXT,
	white_slice,
	NOFEEL,
	NOGROUP, 0,
	};

struct flicmenu cefx_menu =
	{
	NONEXT,
	&rcefx_menu,
	0, 0, 319, 199,
	NOTEXT,
	NOSEE,
	cx_grab_color,
	NOGROUP, 0,
	};

