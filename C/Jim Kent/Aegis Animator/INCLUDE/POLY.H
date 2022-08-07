

struct point
	{
	WORD x, y, z;
	WORD level;
	};
typedef struct point Point;
extern struct point grc_point;

struct llpoint
	{
	WORD x, y;
	WORD level;
	struct llpoint *next;
	};
typedef struct llpoint LLpoint;

struct color_def
	{
	WORD red, green, blue;
	};
extern struct color_def *usr_cmap, init_cmap[];


/*******
********	note: it is essential now for struct 
********	poly, text_window, stencil, and full_color
********	to be the same size!
********/

struct poly
	{
	WORD type;	/* == JUST_LINE, OUT_LINE, FILLED	*/
	WORD color;
	WORD fill_color;
	struct point center;
	WORD pt_count;
	WORD pt_alloc;
	struct point *pt_list;
	LLpoint *clipped_list;
	};
typedef struct poly Poly;
extern struct poly grc_poly;
extern Poly *clone_poly();

#define HIDE_BIT 	0x8000		/*means you don't draw it*/
#define IS_RASTER	0x4000
#define FILLED		0
#define OUT_LINE	1
#define JUST_LINE	2
#define FONT_VECTOR	3
#define COLOR_RECT	4
#define AMIGA_BITMAP		(0 | IS_RASTER)
#define TEXT_WINDOW			(1 | IS_RASTER)
#define BYPLANE_RASTER	(2 | IS_RASTER)
#define BITPLANE_RASTER		(3 | IS_RASTER)
#define BACKGROUND			(4 | IS_RASTER)
#define BYPLANE_STENCIL	(5 | IS_RASTER)
#define COLOR_BLOCK			(6 | IS_RASTER)
#define ATARI_CEL			(7 | IS_RASTER)
#define ANI_STRIP		(8 | IS_RASTER)

struct just_line
	{
	WORD type;		/*	== JUST_LINE	*/
	WORD color;
	WORD fill_color;
	struct point center;
	WORD pt_count;
	WORD pt_alloc;
	struct point *pt_list;
	LLpoint *clipped_list;
	};

struct outline_poly
	{
	WORD type;	/* == OUT_LINE	*/
	WORD color;
	WORD fill_color;
	struct point center;
	WORD pt_count;
	WORD pt_alloc;
	struct point *pt_list;
	LLpoint *clipped_list;
	};

struct filled_poly
	{
	WORD type;	/* == FILLED	*/
	WORD color;
	WORD fill_color;
	struct point center;
	WORD pt_count;
	WORD pt_alloc;
	struct point *pt_list;
	LLpoint *clipped_list;
	};

#define TURTLE_MOVE	109
#define TURTLE_DRAW	110
struct color_rect
	{
	WORD type;	/* == COL_RECT	*/
	WORD color;
	WORD pad;
	struct point center;
	WORD pt_count;	/*	==	2	*/
	WORD pt_alloc;	/*	==	2	*/
	struct point *pt_list;
	int	*pad_pt;
	};

struct ani_strip
	{
	WORD type;	/*	== ANI_STRIP	*/
	WORD xhot, yhot;	/* offset from "center" */
	struct point origin;
	WORD pad1;	/*	== 	0	*/
	WORD pad2;	/*	==	0	*/
	char *padpt;
	WORD zhot;
	WORD script_ix;
	};

struct amiga_BitMap
	{
	WORD type;	/*	== ATARI_BITMAP	*/
	WORD color0;
	WORD color1;
	struct point origin;
	WORD pad1;	/*	== 	0	*/
	WORD pad2;	/*	==	0	*/
	char *padpt;
	struct raster_list	*raster;
	};

struct bitplane_raster
	{
	WORD type;	/*	== BITPLANE_RASTER	*/
	WORD color0;
	WORD color1;
	struct point origin;
	WORD pad1;	/*	==	0	*/
	WORD pad2;	/*	==	0	*/
	char *padpt;
	struct raster_list *raster;
	};

struct atari_form
	{
	WORD type;	/*	== ATARI_FORM	*/
	WORD color0;
	WORD color1;
	struct point origin;
	WORD pad1;	/*	==	0	*/
	WORD pad2;	/*	==	0	*/
	char *padpt;
	struct raster_list *raster;
	};

struct text_window
	{
	WORD type;	/* == TEXT_WINDOW */
	WORD color0;
	WORD color1;
	struct point origin;
	WORD pad1;
	WORD pad2;
	char *padpt;
	struct raster_list *raster;
	};

#ifdef SUN
struct byteplane_raster
	{
	WORD type;	/*	==	BYPLANE_RASTER	*/
	WORD color0;
	WORD color1;
	struct point origin;
	WORD pad1;	/*	==	0	*/
	WORD pad2;	/*	==	0	*/
	char *padpt;
	struct raster_list *raster;
	};

struct byteplane_stencil
	{
	WORD type;	/*	==	BYPLANE_RASTER	*/
	WORD color0;
	WORD color1;
	struct point origin;
	WORD pad1;	/*	==	0	*/
	WORD pad2;	/*	==	0	*/
	char *padpt;
	struct raster_list *raster;
	};
#endif SUN

struct color_block
	{
	WORD type;	/*	== COLOR_BLOCK		*/
	WORD color0;
	WORD color1;
	struct point origin;
	char *padpt1;	/* == NULL*/
	WORD width;
	WORD height;
	char *padpt2;
	};

struct poly_list
	{
	WORD count;
	WORD alloc;
	struct poly **list;
	struct poly **zlist;
	struct color_def *cmap;
	char *bg_name;
	};
typedef struct poly_list Poly_list;
extern struct poly_list grc_poly_list;
extern Poly_list	*clone_plist();
extern Poly_list	*empty_poly_list();

typedef int OBJ;


