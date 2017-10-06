
/*
 * Each window have the following structure. These data are
 * linked to a window using the DataAttach() function and the
 * magic number 'WINF'. Currently these data are used to save
 * the windows characteristics.
 */

typedef
struct infos {
	int menu;			/* index menu */
	int toolbar;		/* index toolbar */
	int form;			/* index form */
} WINFO;

#define INFOS_MENU	1
#define INFOS_TOOL 	2
#define INFOS_FORM	3

#define WD_WINF	0x57494E46L	/* 'WINF' */
#define WD_DRAW 0x44524157L	/* 'DRAW' */

#define SETUP_INSTALL_DESKTOP	0x1
#define SETUP_SAVE_WINDOWS		0x2
#define SETUP_AUTOSAVE			0x4
#define SETUP_XTYPE				0x8

struct _param {
	OBJECT *desk;
	WINDOW *winuser;
	int setup, FrameWidth, FrameColor;
};

extern struct _param param;

