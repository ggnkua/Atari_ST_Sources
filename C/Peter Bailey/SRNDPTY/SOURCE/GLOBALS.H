/* ==================================================================== */
/*	Serendipity: Global declarations				*/
/* ==================================================================== */

/*	Screen coordinates of various crucial objects			*/

#define	BX	20
#define	BY	46
#define	PX	158
#define	PY	83
#define	TX	192
#define	TY	46
#define	IX	198
#define	IY	52

#define	loop	while(1)


extern char	board[12][12];		/* The playing board		*/

extern long	timer;			/* Timer for event multi	*/
extern int	quit_flag;		/* Set true by quit button	*/
extern int	help_flag;		/* Set true during help screens	*/
extern int	goes;			/* Number of pieces played	*/
extern int	game_on;		/* Set true during each game	*/
extern int	ply;			/* Ply depth			*/
extern int	depth;			/* Depth of insight		*/
extern int	span;			/* Area to examine in evaluate	*/
extern int	game_type;		/* Lightning or attrition	*/
extern int	game_mode;		/* Optimistic or nihilistic	*/
extern int	colours;		/* Number of pieces		*/
extern int	level;			/* Expertise level		*/
extern int	me;			/* Computer's pieces		*/
extern int	you;			/* Player's pieces		*/
extern int	won;			/* Games won			*/
extern int	lost;			/* Games lost			*/
extern int	drawn;			/* Games drawn			*/
extern int	panic;			/* Panic mode flag		*/
extern int	i_last;			/* The last row played		*/
extern int	j_last;			/* The last collumn played	*/
extern int	old_palette[16];	/* Save load-time palette	*/
extern int	palette[16];		/* Run-time palette		*/
extern long	*buf;			/* Buffer for screen elements	*/
extern char	*buffer;		/* Buffer for saving screen	*/

typedef	struct	{
	long	address;
	int	width;
	int	height;
	int	points;
	int	format;
	int	planes;
	int	reserved[3];
	}	Mfdb;

extern Mfdb	s_mfdb,d_mfdb;		/* Source & destination mfdbs	*/


extern int	handle;				/* Gem Vdi handle	*/
extern int	work_in[12],work_out[57];	/* Vdi workspace	*/

/*	Frame table							*/

#define	Frames	10

extern int	frame[40];
extern char	*b_text[8];

/*	Position evaluation tables					*/

extern int	value_1[81];		/* Table for games 1 & 3	*/
extern int	value_2[81];		/* Table for game 2		*/
extern int	*value;			/* Pointer to table in use	*/

/*	Sound buffer							*/

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

extern Sound	sound;

/*	Help text							*/

extern char	*info_1[];
extern char	*info_2[];
extern char	*info_3[];
extern char	*info_4[];
extern char	*help_1[];
extern char	*help_2[];
extern char	*panic_mess[];

