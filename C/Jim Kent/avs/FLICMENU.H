
/* This is the tree structure that is the core of the pull-down system */
struct pull
	{
	struct pull *next;
	WORD xoff, yoff, width, height;
	struct pull *children;
	char *data;  /* actually just some old pointer, must agree with see function
				 */
	Vector see;
	};
typedef struct pull Pull;

/* some defines to make it easier to edit skeletal pull data files... */
#define NONEXT NULL
#define NOCHILD NULL
#define NODATA NULL

extern WORD menu_ix, sel_ix, pull_hit;	/* returned by pull() */

/*some functions to put into pull->see */
extern pull_block(), pull_color(), pull_oblock(), 
	spull_text(), pull_text(), pull_brush();

struct slidepot
	{
	WORD min, max, value;
	};

struct range
	{
	WORD min, max, v1, v2;
	};

struct grid
	{
	WORD divx, divy;
	};

/* struct flicmenu is the core structure for the "flat panel" menu's. */

struct flicmenu
	{
	struct flicmenu *next;
	struct flicmenu *children;
	WORD x, y;
	WORD width, height;
	char *text;
	int (*seeme)();
	int (*feelme)();
	int *group;
	int identity;
	WORD key_equiv;
	};
typedef struct flicmenu Flicmenu;

#define NOTEXT NULL
#define NOSEE  NULL
#define NOFEEL NULL
#define NOGROUP NULL
#define NOKEY	0

extern Flicmenu *cur_menu;
extern char break_menu;
