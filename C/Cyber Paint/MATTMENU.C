
#include "flicker.h"
#include "flicmenu.h"

extern white_slice(), wbtext(), matte_load(), matte_save(), matte_merge(),
	matte_mask(), matte_imask();

struct flicmenu mtmerge_sel = 
	{
	NONEXT,
	NOCHILD,
	251+5, 187,	62, 11,
	"Xor",
	wbtext,
	matte_merge,
	NOGROUP, 0,
	'x',
	};
struct flicmenu mtimask_sel = 
	{
	&mtmerge_sel,
	NOCHILD,
	186+5, 187, 63, 11,
	"Imask",
	wbtext,
	matte_imask,
	NOGROUP, 0,
	'i',
	};
struct flicmenu mtsave_sel = 
	{
	&mtimask_sel,
	NOCHILD,
	126+5, 187, 58, 11,
	"Mask",
	wbtext,
	matte_mask,
	NOGROUP, 0,
	'm',
	};
struct flicmenu mtmask_sel = 
	{
	&mtsave_sel,
	NOCHILD,
	61+5, 187, 63, 11,
	"Save",
	wbtext,
	matte_save,
	NOGROUP, 0,
	's',
	};
struct flicmenu mtload_sel = 
	{
	&mtmask_sel,
	NOCHILD,
	1, 187,	63, 11,
	"Load",
	wbtext,
	matte_load,
	NOGROUP, 0,
	'l',
	};
struct flicmenu matte_menu = 
	{
	NONEXT,
	&mtload_sel,
	0, 186,	319, 13,
	NOTEXT,
	white_slice,
	NOFEEL,
	NOGROUP, 0,
	};

mattload(type)
WORD type;
{
WORD nou, deg, sft;

sft = save_file_type;
deg = degas;
nou = normal_over_under;
save_file_type = SEQ;
degas = 0;
normal_over_under = type;
go_ldseq();
save_file_type = sft;
degas = deg;
normal_over_under = nou;
}

matte_save(m)
{
WORD sft, sm, deg;

sft = save_file_type;
sm = select_mode;
deg = degas;
save_file_type = SEQ;
select_mode = 2;	/* to all */
deg = 0;
do_save();
save_file_type = sft;
degas = deg;
select_mode = sm;
}

matte_load(m)
{
WORD nou, deg;

mattload(NOU_NORMAL);
}

matte_merge(m)
{
mattload(NOU_MERGE);
}

matte_mask(m)
{
mattload(NOU_MASK);
}

matte_imask(m)
{
mattload(NOU_IMASK);
}

go_matte()
{
hide_mouse();
draw_a_menu(&matte_menu);
do_menu(&matte_menu);
}

mmatte()
{
go_matte();
erase_top_menu(&matte_menu);
draw_a_menu(cur_menu);
}


