
struct slidepot
	{
	WORD min, max, value;
	};

struct range
	{
	WORD min, max, v1, v2;
	};

extern struct range trange;


struct grid
	{
	WORD divx, divy;
	};

struct text_attr
	{
	char *text;
	WORD attr;
	};

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
