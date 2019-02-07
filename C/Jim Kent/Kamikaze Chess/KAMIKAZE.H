

#define WORD int
#define UWORD unsigned int
#define NULL 0L
typedef int (*Vector)();
typedef unsigned char uchar;
typedef unsigned short ushort;

extern long pt_to_long();

/* screen format defines */
#define	XMAX	320
#define	YMAX	200
#define COLORS	16
#define BITPLANES 4
#define CH_WIDTH 8
#define CH_HEIGHT 9

extern WORD *cscreen, *pscreen;		/* drawing and display screens */
extern WORD sys_cmap[];			/* software echo of color map */
extern WORD handle;

extern char bap_line_buf[];	/* a line buffer for byte-a-pixeling */

/* stuff for dynamic memory management */
extern void *askmem(), *laskmem(), *begmem(), *begzeros(),*lbegmem(),
	*askzeros(), *clone_structure();
#define Alloc_a(type) (type *)askmem(sizeof(type) )
#define Free_a(pt)	freemem(pt)
#define Array_els(arr) (sizeof(arr)/sizeof(arr[0]))

extern long mem_free;		/* how much is left */

struct mblock	/* structure to keep track of free memory */
	{
	struct mblock *next;
	long size;
	};

/*  These are globals that contain the input state */
extern WORD mouse_button, omouse_button;  /* button state and last state */
extern WORD mouse_x, mouse_y;	/* the xy position of mouse */
extern WORD lastx, lasty;	/* last mouse_x, mouse_y */
extern WORD mouse_moved;	/* new mouse input? */
extern WORD key_hit;			/* 1 if keyboard hit, 0 otherwise */
extern long key_in;				/* What the extended character code 
								   for when key_hit = 1 */

/* These are macros on the mouse buttons */
#define PDN (mouse_button & 0x100)
#define RDN (mouse_button & 0x200)
#define EDN (mouse_button & 0x300)
#define PJSTDN ( (mouse_button & 0x100) && !(omouse_button & 0x100) )
#define RJSTDN ( (mouse_button & 0x200) && !(omouse_button & 0x200) )

/* Arrow key definitions */
#define LARROW	0x4b00
#define RARROW	0x4d00
#define UARROW	0x4800
#define DARROW	0x5000

struct square
	{
	WORD x, y;  /* pixels */
	WORD width, height;
	struct piece *piece;
	WORD color;
	};
typedef struct square Square;
extern Square board[8][8];

struct piece_move
	{
	uchar dx, dy;
	};
typedef struct piece_move Piece_move;

struct move
	{
	struct move *next;
	struct move *child;
	char dx, dy;
	struct piece *piece, *took_piece;
	WORD value;
	uchar flags;
	uchar promotion;
	};
typedef struct move Move;
#define MCHECKING	1
#define MCHECKED	2
#define MTAKING		4
#define MTOOK		8
#define MMATING		16
#define MENPASSANT	32
#define MCASTLING	64
#define	MQUEENING	128

#define HSZ 1024
extern Move *history[HSZ];
extern ushort move_count;
extern WORD move_color;
extern Move probable_moves[];
extern WORD probable_count;
extern Move *sorted_moves[];
extern WORD sorted_count;

#define WHITE	0
#define BLACK	1

#define WHITE_COLOR 2
#define BLACK_COLOR 3

#define KING	0
#define QUEEN	1
#define ROOK	2
#define BISHOP	3
#define KNIGHT	4
#define PAWN	5

#define KING_IX 3
#define QUEEN_IX 4
#define PAWN_IX	8
struct piece
	{
	char column, row; /* 0 to 7 */
	WORD flags;	/* dead, alive ??*/
	char type;
	char color;
	char *name;
	unsigned WORD *image;
	Vector legal;	/* boolean, returns true if move legal */
	Piece_move *lmoves;
	WORD lmove_count;
	WORD value;		/* pawn = 1 ... king = 128 I guess... */
	WORD id;	/* value 0-16 to identify */
	WORD move_count;
	};
typedef struct piece Piece;
extern Piece black_pieces[16], white_pieces[16];
extern Piece *pieces[2];
extern int living[2];
#define PDEAD 1
#define PMOVED 2


extern char must_take;
