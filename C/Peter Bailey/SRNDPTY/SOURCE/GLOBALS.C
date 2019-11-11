/* ==================================================================== */
/*	Serendipity: Global definitions					*/
/* ==================================================================== */

/*	Base screen coordinates						*/

#define	BX	20
#define	BY	46
#define	PX	158
#define	PY	83
#define	TX	192
#define	TY	46
#define	IX	198
#define	IY	46


/* -------------------------------------------------------------------- */
/*	Flags, counters, etc						*/
/* -------------------------------------------------------------------- */

char	board[12][12];			/* The playing board		*/

long	timer	   = 30000;		/* Timer for event multi	*/
int	quit_flag  = 0;			/* Set true by quit button	*/
int	help_flag  = 0;			/* Set true during help screens	*/
int	goes       = 0;			/* Number of pieces played	*/
int	game_on	   = 0;			/* Set true during each game	*/
int	ply        = 0;			/* Ply depth			*/
int	depth      = 1;			/* Depth of insight		*/
int	span	   = 2;			/* Area to examine in evaluate	*/
int	game_type  = 2;			/* Lightning or attrition	*/
int	game_mode  = 1;			/* Optimistic or nihilistic	*/
int	colours    = 3;			/* Number of pieces		*/
int	level      = 2;			/* Expertise level		*/
int	me         = 0;			/* Computer's pieces		*/
int	you        = 0;			/* Player's pieces		*/
int	won        = 0;			/* Games won			*/
int	lost       = 0;			/* Games lost			*/
int	drawn      = 0;			/* Games drawn			*/
int	panic	   = 0;			/* Panic mode flag		*/
int	i_last     = 0;			/* The last row played		*/
int	j_last     = 0;			/* The last column played	*/
int	old_palette[16];		/* Save load-time palette	*/
long	*buf;				/* Buffer for screen elements	*/
char	*buffer;			/* Buffer for saving screen	*/


/* -------------------------------------------------------------------- */
/*	Run-time palette						*/
/* -------------------------------------------------------------------- */

int	palette[]  = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };


/* -------------------------------------------------------------------- */
/*	Mfdb definitions for screen handling				*/
/* -------------------------------------------------------------------- */

typedef	struct	{
	long	address;		/* Buffer address		*/
	int	width;			/* Screen width in pixels	*/
	int	height;			/* Height in pixels		*/
	int	points;			/* Width in words		*/
	int	format;			/* Area format			*/
	int	planes;			/* Number of screen planes	*/
	int	reserved[3];		/* Unused			*/
	}	Mfdb;

Mfdb	s_mfdb,d_mfdb;			/* Source & destination mfdbs	*/


/* -------------------------------------------------------------------- */
/*	Gem workspace							*/
/* -------------------------------------------------------------------- */

int	handle;				/* Gem Vdi handle		*/
int	work_in[12],work_out[57];	/* Vdi workspace		*/


/* -------------------------------------------------------------------- */
/*	Frame table							*/
/* -------------------------------------------------------------------- */

#define	Frames	10

/*	Coordinates of rectangular areas of screen; four entries per	*/
/*	rectangle; format: top left x, top left y, width, height	*/

int	frame[] = {

	BX,	BY,	127,	119,	/* Main playing board		*/
	PX,	PY,	16,	45,	/* Playing pieces		*/
	192,	112,	68,	15,	/* Don't click button		*/
	268,	112,	32,	15,	/* Info button			*/
	192,	132,	32,	15,	/* Play button			*/
	230,	132,	32,	15,	/* Game button			*/
	268,	132,	32,	15,	/* Help button			*/
	192,	152,	32,	15,	/* Pass button			*/
	230,	152,	32,	15,	/* Hint button			*/
	268,	152,	32,	15	/* Quit button			*/

	};


/* -------------------------------------------------------------------- */
/*	Text for buttons						*/
/* -------------------------------------------------------------------- */

char	*b_text[] = {

	"DON'T CLICK", "INFO", "PLAY", "GAME", "HELP", "PASS", "HINT", "QUIT"

	};


/* -------------------------------------------------------------------- */
/*	Position evaluation tables					*/
/* -------------------------------------------------------------------- */

/*	Values for lose, win, indeterminate, and safe respectively	*/

#define	L	-8
#define	W	16
#define	P	1
#define S	0

/*	Game mode 1 - Triples win					*/

int	value_1[] = {

	S, L, S, L, W, L, S, S, P, L, L, L, W, W, W, L,
	L, L, S, L, S, L, W, S, P, P, P, L, L, L, L, W,
	L, L, L, L, W, W, W, W, W, W, W, W, W, S, L, S,
	L, W, S, P, P, P, S, L, S, L, W, L, S, S, P, L,
	L, L, W, W, W, S, S, S, P, P, P, L, W, P, P, P, P

	};


/*	Game mode 2 - Triples lose					*/

int	value_2[] = {

	S, S, S, S, L, S, S, S, S, S, S, S, L, L, L, S,
	S, S, S, S, S, S, L, S, S, S, S, S, S, S, S, L,
	S, S, S, S, L, L, L, L, L, L, L, L, L, S, S, S,
	S, L, S, S, S, S, S, S, S, S, L, S, S, S, S, S,
	S, S, L, L, L, S, S, S, S, S, S, S, L, S, S, S, S

	};


/*	Pointer to whichever table is applicable to the current game	*/

int	*value = value_1;


/* -------------------------------------------------------------------- */
/*	Sound data							*/
/* -------------------------------------------------------------------- */

typedef	struct	{
	long	id;		/* Id field - Not sure what its for	*/
	long	entries;	/* Number of sound entries		*/
	long	filesize;	/* Number of bytes in file		*/
	struct	{
		long	offset;	/* Offset from start of file		*/
		int	s_size;	/* Entry size				*/
		char	nm[10];	/* Sound name				*/
		} entry[7];	/* Entry name				*/
	char	data[594];	/* Sound data buffer			*/
	}	Sound;

Sound	sound;


/* -------------------------------------------------------------------- */
/*	Help text							*/
/* -------------------------------------------------------------------- */

char	*info_1[] = {
"This is probably one of the simplest", "games ever invented, not to mention ",
"one of the silliest. The game can be", "played in either of two versions,   ",
"each of which consists of attempting", "to place coloured counters onto the ",
"board in lines of three, vertically,", "horizontally, or diagonally. This is",
"not as straightforward as it sounds,", "because either player may use pieces",
"of either colour - players don't own", "any particular colour as they do in ",
"most games. Furthermore, the game is", "played with pieces of up to three   ",
"different colours simultaneously!   ", ""
	};

char	*info_2[] = {
"The game can be played in either the", "normal form, or a reverse form where",
"the object is to avoid making lines ", "of three. When a player successfully",
"makes a line, the central piece is  ", "effectively captured and will change",
"colour - gold for your captures, and", "black for the computers.   Normally,",
"whoever makes the most captures wins", "(or loses in the reverse form),  but",
"you may elect to play the game in a ", "lightning form, where the first to  ",
"make a capture wins (or loses).  In ", "essence, therefore, there are four  ",
"methods of play.                    ", ""
	};

char	*info_3[] = {
"A piece is considered to be captured", "when it has two pieces of the same  ",
"colour (as itself) on either side of", "of it; because of this, it is quite ",
"possible to make a multiple capture ", "with a single piece.                ",
"                                    ", "You can elect to play with all three",
"colours (red, blue, and green), with", "only two (red and blue), or even (if",
"you're that way inclined) with just ", "the red pieces.  When the program is",
"loaded, it is initially set to play ", "the normal game (most captures win) ",
"in protracted (non-lightning) form, ", "with all three colours.  Clear ?    ",
""
	};

char	*info_4[] = {
"Make your move by clicking first on ", "one of the pieces to the right of   ",
"the main board, then on the square  ", "on which you want to play.          ",
"                                    ", "Click on the HELP button at any time",
"before or during a game for a brief ", "explanation of the options available",
"at that time.                       ", "                                    ",
"You can abandon a game at any time  ", "by clicking on the quit button, but ",
"there is absolutely no way to turn  ", "off those irritating noises. Tough. ",
" ",">> READY WHEN YOU ARE, OLD CHAP <<",
""
	};


char	*help_1[] = {
"Use the buttons!", " ",
"INFO Gives a full description of the", "     various types of game available",
" ",
"PLAY Starts the game                ",
" ",
"GAME Selects the game type,  number ", "     of pieces, and the skill level ",
" ",
"HELP I think you can probably guess,", "     can't you? You can also use the",
"     help button during a game      ",
" ",
"QUIT Return to the infamous Desktop ", "     or to wherever else you might  ",
"     have come from                 ",
""
	};


char	*help_2[] = {
"More buttons than a plastic mac!",
" ",
"PASS If you want the computer to    ", "     make the first move of the game",
"     click this one.  Any attempt to", "     pass on any move other than the",
"     first will result in abuse.    ",
" ",
"HINT Click here for a suggestion as ", "     to where you might play.  The  ",
"     computer is entirely at liberty", "     to lie, deceive and attempt to ",
"     mislead you whenever it feels  ", "     inclined.  (What a shame)      ",
""
	};


char	*panic_mess[] = {
"So... Now we know, don't we ?",
" ",
"You're the type who can't walk", "past a 'Wet Paint' sign without",
"getting Dulux on your fingers", " ", "Well, as a punishment for clicking",
"a button which is clearly marked:", " ",
"DON'T CLICK", " ",
"you will be given just 3 seconds", "to make each move during the next",
"game. If you fail to respond in", "that time, you forfeit your turn",
" ", "TOUGH CHEESE",
""
	};
