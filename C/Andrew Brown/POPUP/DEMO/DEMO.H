MITEM MENU_DESK[]=
{
	-1,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	" About the demo... ",
	"Display author and copyright"
};

#define ITM_ABOUT 0

MITEM MENU_FILE[]=
{
	1,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	"  Check me ",
	"Display/remove menu tick",

	2,0,-1,-1,0,0,0,0,
	MSELECTABLE|MDISABLED,0L,
	"#l",
	0L,

	5,0,3,-1,0,0,0,0,
	MSELECTABLE,0L,
	"  Files   ",
	0L,

	4,3,-1,0,0,0,0,0,
	MSELECTABLE,0L,
	" Load ",
	"Load a file (dummy option!)",

	-1,3,-1,0,0,0,0,0,
	MSELECTABLE,0L,
	" Save",
	"Save a file (dummy option !)",

	-1,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	"  Quit",
	"Quit the demonstration"
};

#define ITM_CHECKME 0
#define ITM_QUIT 5

MITEM MENU_OPTIONS[]=
{
	-1,0,1,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Display menu ",
	"A few popup menu demos",

	2,1,-1,0,0,0,0,0,
	MSELECTABLE,0L,
	" Drop down ",
	"Show menu, exit when clicked",

	-1,1,-1,0,0,0,0,0,
	MSELECTABLE,0L,
	" Hold down",
	"Show while button is down"
};

#define ITM_DROPDOWN 1
#define ITM_HOLDDOWN 2

MITEM MENU_DROPDOWN[]=
{
	1,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Save file ",
	"Save file to disk drive",

	2,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Load file",
	"Load file from disk",

	3,0,-1,-1,0,0,0,0,
	MSELECTABLE|MDISABLED,0L,
	"#l",
	0L,

	4,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Quit",
	0L,

	-1,0,5,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Info     ",
	"Information about this menu",

	6,5,-1,0,0,0,0,0,
	0L,0L,
	" The items in this menu do  ",
	0L,

	7,5,-1,0,0,0,0,0,
	0L,0L,
	" not actually do anything.",
	0L,

	8,5,-1,0,0,0,0,0,
	0L,0L,
	" This is just an example of",
	0L,

	-1,5,-1,0,0,0,0,0,
	0L,0L,
	" a possible drop down menu.",
	0L
};


MITEM MENU_HOLDDOWN[]=
{
	1,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Bold      ",
	"Bold text",

	2,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Underline",
	"Underlined text",

	3,0,-1,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Italic",
	"Italicised text",

	4,0,-1,-1,0,0,0,0,
	MSELECTABLE|MDISABLED,0L,
	"#l",
	0L,

	-1,0,5,-1,0,0,0,0,
	MSELECTABLE,0L,
	" Info     ",
	"About this popup menu",

	6,5,-1,0,0,0,0,0,
	0L,0L,
	" This menu does not actually ",
	0L,

	7,5,-1,0,0,0,0,0,
	0L,0L,
	" do anything, it just serves",
	0L,

	8,5,-1,0,0,0,0,0,
	0L,0L,
	" as an example of a menu",
	0L,

	-1,5,-1,0,0,0,0,0,
	0L,0L,
	" that you might create.",
	0L
};


