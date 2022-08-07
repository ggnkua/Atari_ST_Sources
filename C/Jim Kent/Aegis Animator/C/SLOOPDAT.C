
extern inverse_text(), crude_help(), just_text(), see_digit_gauge(),
	do_digit_gauge(), text_in_box(), new_mode();

struct digit_gauge sloop_gauge =
	{
	3,   /*digits*/
	0,   /*min */
	1,   /*value */
	999,   /*max */
	};

struct one_of forever_node =
	{
	&sloop_gauge.value,
	0,
	"forever",
	};

struct selection sloop_table[5] =
	{
		{
		102, 2,	148,12,
		FALSE,
		(char *)&forever_node, ONE_OF,
		inverse_text,
		NO_SDATA, GO_SUB_REMENU,
		new_mode,
		NO_DOUBLE, NO_DOUBLE,
		"loop forever", crude_help,
		},

		{
		103, 14+8,	147,33+8,
		FALSE,
		(char *)&sloop_gauge, FIRST_TIME,
		see_digit_gauge,
		(char *)&sloop_gauge, GO_SUB_REMENU,
		do_digit_gauge,
		NO_DOUBLE, NO_DOUBLE,
		"help m15", crude_help,
		},

		{
		53, 41,	94,55,
		FALSE,
		(char *)"ok", FIRST_TIME,
		text_in_box,
		NO_SDATA, RETURN_SOMETHING,
		NO_SFUNCTION,
		NO_DOUBLE, NO_DOUBLE,
		"help m16", crude_help,
		},

		{
		3, 9,	101,20,
		FALSE,
		(char *)"Loop Count", FIRST_TIME,
		just_text,
		NO_SDATA, GO_SUBBER,
		NO_SFUNCTION,
		NO_DOUBLE, NO_DOUBLE,
		NULL, NULL,
		},

	};

struct menu sloopm =
	{
	FALSE,
	TRUE,
	88, 47,
	148, 56,
	sizeof(sloop_table)/sizeof(struct selection),
	sizeof(sloop_table)/sizeof(struct selection),
	sloop_table,
	await_input,
	FALSE, FALSE,
	};



/*this is called as a SUB_MENU */
sloop_menu(menu,sel,vis)
struct menu *menu;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
struct control local_control;
extern struct cursor out_cursor, in_cursor;

local_control.m = &sloopm;
local_control.sel = NULL;
local_control.vis = vis;

clear_menu(menu);
copy_menu_offsets( menu, &sloopm);
draw_menu(&sloopm);
main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(&sloopm);
}

