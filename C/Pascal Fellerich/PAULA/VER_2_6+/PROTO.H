/************************************************************************/
/*
 *	PROTO.H
 *	-------
 *
 *	Global Setup Defines
 *	C Prototypes of assembler primitives
 *
 *
 *	last modified: 26-Oct-1992
 */
/************************************************************************/

#include <tos.h>
#include <aes.h>
#include <portab.h>


/* -------------------------------------------------------------------- */
/* Fix-Texte:															*/
/* -------------------------------------------------------------------- */
#define ACCNAME 			"  Paula ][ "			/* ACC title		*/

#define WINDOW_TITLE		"PAULA 2.6 (Noise Shaping)"
#define VERSION				0x0206

#define FILEMAGIC			"PAULA2.5"
#define INFOFILE			"PAULA.INF"
#define MOD_MASK			"*.MOD"
#define AUTOMOD_PATH		"MODFILES\\"

#define BOOL		int

/* -------------------------------------------------------------------- */
/*	SETUP DEFINES:														*/
/* -------------------------------------------------------------------- */
#define INDICATORDELAY		150 		/* Indicator redraw time in ms	*/
#define REPEATDELAY 		80	 		/* button repeat				*/
#define ACCLOOPDELAY		1000		/* accessory timer event in ms	*/

#define FS_LOW				1			/* samplefreq chip index		*/
#define FS_MED				2			/* Medium						*/
#define FS_HI				3			/* High 						*/


/* -------------------------------------------------------------------- */
/* player states														*/
/* -------------------------------------------------------------------- */
#define P_IDLE			0	/* Player is inactive, no memory allocated	*/
#define P_STOPPED		1	/* File loaded, no play, memory allocated	*/
#define P_PLAYING		2	/* currently playing a module				*/
#define P_PAUSED		3	/* currently suspended						*/
#define P_INTERRUPTED	4


/* -------------------------------------------------------------------- */
/* miscellaneous														*/
/* -------------------------------------------------------------------- */
#define E_OK			0
#define E_ERROR			-1
#define E_MODFILE		-2		  /* corrupted/no modfile */
#define E_FILENOTFOUND	-3
#define E_MEMORY		-4
#define E_FRAMEBUFFER	-5
#define E_DMASOUND		-6
#define E_INFOFILE		-7
#define E_PHYSDRIVE		-8
#define E_WINDOW		-9
#define E_REGISTER		-10

#define MAX_ERROR		10		/* Limit fÅr error_alert */


#define FALSE 0
#define TRUE !FALSE

#define PRIVATE static

#define FSEL 0x4653454CL				/* FSEL cookie					*/
#define SLCT 0x534C4354L				/* Selectric Cookie 			*/



/* -------------------------------------------------------------------- */
/* Selectric: Excerpts from FSEL_xxx.H									*/
/* -------------------------------------------------------------------- */

#define CMD_FILES_OUT	0x01		/* return filelist */
#define CFG_ONESTRING	0x02		/* return list in one string */



/* -------------------------------------------------------------------- */
/* Gemini Messages, Excerpts from VAPROTO.H 							*/
/* -------------------------------------------------------------------- */
/* AV_SENDKEY: Ein Acc sendet VENUS/GEMINI einen Tastaturevent, den
 * es selber vielleicht nicht versteht.
 * Word 3 = Tastaturstatus				   ev_mmokstate
 * Word 4 = Scancode der gedrÅckten Taste  ev_mkreturn
 */
#define AV_SENDKEY			0x4710

/* VA_START: Accessory wird aktiviert. Word 3 + 4 enthalten einen
 * Pointer auf eine Kommandozeile, der auch NULL sein kann.
 * In der Kommandozeile stehen Pfade oder Dateinamen.
 */
#define VA_START			0x4711

/* MP_START: identisch mit VA_START, aber:
 * 1. andere Nummer
 * 2. nachdem Paula die Kommandozeile eingelesen hat, kommt eine
 *    Antwort-Message zurÅck (MP_ACK)
 */
#define MP_ACK			0x4800		/* return message: SUCCESSFUL! */
#define MP_NAK			0x4801		/* return message: no success */
#define MP_START		0x4802		/* start the given files */
#define MP_STOP			0x4803		/* stop player & release files */

/* MP_SHUTDOWN:	stop player & close win & release MOD */
#define MP_SHUTDOWN		0x4804		/* total shut down */



/* -------------------------------------------------------------------- */
/* Soft DMA Interface													*/
/* -------------------------------------------------------------------- */
typedef struct {
	long		magic;

	/* von Paula aufgerufene Funktionen: */
	void    (*SetAudioFrame)(int *data, int length, int range);
	void    (*Init_SDMA)(int *data, int size, int range, int sfreq);
	void    (*Exit_SDMA)(void);
	int     (*GetCPULoad)(void);    /* return cpu load */
	
	/* Paula RO vars: Welche Samplefrequenzen benutzt werden */
	unsigned int    samplefreq0,    /* unused... */
	                samplefreq1,    /* sfreq for index 1 */
	                samplefreq2,    /* etc */
	                samplefreq3;
	
	/* Paula R/W vars: */
	void    (*PaulaHook)(void);     /* call this after every bufferplay */

	int		boost;

	/* SoftDMA Samplefreq Texte fÅr Paula Radio-Buttons */
	char	*splftxt0,
			*splftxt1,
			*splftxt2,
			*splftxt3;

} SoftDMA;


typedef struct					/* reasonable string */
{
	int			flag;
	int			siz;			/* total size of the struct */
	char		str[];
} string_t;


typedef struct filename_block
{
	size_t		len,			/* how many bytes can data[] hold... */
				pos;			/* next free position in block */
	long		entries,		/* total records */
				play;			/* doing this number */

	char		data[];			/* complete path + name */
} filename_block_t;



/* -------------------------------------------------------------------- */
/* FROM HANDLER.C														*/
/* -------------------------------------------------------------------- */
int 	make_modlist( char *arg );
void 	clear_modfile_list( void );
BOOL 	add_modfile_to_list( const char *name );
long	get_num_listentries( void );
BOOL 	get_first_mod( void );
BOOL	get_next_mod( void );
void	expand_wildcards( char *path, char *wild );

void	autoload( void );
int 	mp_load( void );
int 	mp_stop( void );
int 	mp_play( void );
void	mp_free( void );
#define mp_pause p_pause
#define mp_fastforward p_fastforward
#define mp_rewind p_rewind
int 	mod_sequencer( void );
int 	read_parameters( void );
int 	save_parameters( void );


/* -------------------------------------------------------------------- */
/* FROM PAULA.C															*/
/* -------------------------------------------------------------------- */
void	draw_indicators( int mask );
int 	fileselect(char *path, char *file, char *title);
int		error_alert( int errorcode );
int 	trim_path( char *path, char *file );
void	draw_dialogbox( OBJECT *tree, GRECT *dbox );
void	undraw_dialogbox( GRECT *dbox );
void	set_amigafreq( int index, int detune );


/* -------------------------------------------------------------------- */
/* FROM REGISTER.C														*/
/* -------------------------------------------------------------------- */
void	reset_registrationdata( void );
void	handle_register_dialog( void );
/* WORD	cdecl check_userkey(PARMBLK *pb); */


/* -------------------------------------------------------------------- */
/* FROM SYSTEM.S														*/
/* -------------------------------------------------------------------- */
/* functions: */
int 	p_global_init( BASPAG *bp );	/* Player Initialization!!! 	*/
void	*acc_malloc( size_t amount );
void	check_sound_running( void );
int 	free_memory( void *base );
int 	read_cookie(long ID, long *ret);


/* -------------------------------------------------------------------- */
/* FROM PLAYER.S														*/
/* -------------------------------------------------------------------- */
/* functions: */
void	p_set_amigaclock( long clockfrequency );
int 	p_set_samplefreq( int chipindex );
int 	p_set_framefreq( int freq );
int 	p_get_state( void );
int 	p_get_position( void );
int 	p_get_cpuload( void );
void	p_get_name( char *dest );
int 	p_load( char *name );
int 	p_free( void );
int 	p_play( void );
int 	p_pause( void );
int 	p_stop( void );
int 	p_fastforward( void );
int 	p_rewind( void );

/* variables (flags, either 0 or 1): */
extern int		p_compatibility,		/* 1 = protracker mode			*/
				p_interpolate,			/* 1 = interpolation			*/
				p_repeat,				/* 1 = repeat modfile			*/
				p_boost,				/* 1 = 6 dB Output Boost		*/
				p_overload, 			/* READ-ONLY: !0 means overload */
				p_swapchannel;			/* 1 = use RLLR not LRRL		*/

/* -------------------------------------------------------------------- */
/* FROM PTREPLAY.S AND SYNTH.S											*/
/* -------------------------------------------------------------------- */
/*				   N O T H I N G ! ! !									*/

/* -------------------------------------------------------------------- */
/* end of file. 														*/
/* -------------------------------------------------------------------- */
