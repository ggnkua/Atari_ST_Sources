/*
 * sound_p.h
 * (c) 1990 by Atari Corp.
 * 
 * Header file for the Sound CPX. This file contains things 
 * that were previously in sound.c 
 *
 * 90Mar23	towns		created.
 *
 */

/* SND structure: used to keep track of sound settings. */

typedef struct _snd {
	int	volume;
	int	bass;
	int	treble;
	int	balance;
} SND;


/* Function Prototypes */
void	open_vwork( void );
void	close_vwork( void );

void 	do_volume_blit( int value, GRECT *rect );
void	setup_MFDB( void );
BOOLEAN	setup_volume( void );
void 	setup_sliders( void );
void 	do_face_blit( int numvalue );

void	slide_balance( void );
void	slide_volume( void );
void	slide_bass( void );
void	slide_treble( void );

void 	do_redraw( WORD *msg );

BOOLEAN cdecl cpx_call( GRECT *rect );
CPXINFO	*cdecl cpx_init( XCPB *Xcpb );

void	get_saved_settings( SND *snd_struct );
void	set_balance( int balance );
void	Ok( void );
void	Cancel( void );

long	set_bass( void );
long	set_treble( void );
long 	set_volume( void );
long	set_bal( void );
long	configure( SND *snd_struct );

void  Do3D( void );
void  MakeActivator( int xtree, int obj );
void  MakeTed( int xtree, int obj );
void  MakeIndex( int xtree, int obj );

void  XDeselect( OBJECT *tree, int button );
void  XSelect( OBJECT *tree, int button );
void  DrawObject( OBJECT *tree, int button );


/* Sound Volume Max and Min */
#define VOL_MAX		40
#define VOL_MIN		0

/* Balance Max and Min   */
#define BAL_MAX		40		/* really from -14 to 14 */
#define BAL_MIN		0
#define BAL_MID 	20

/* Bass MAX and MIN */
#define BASS_MAX 	12
#define BASS_MIN 	0

/* Treble Max and Min */
#define TREBLE_MAX 	12
#define TREBLE_MIN 	0

#define NO_SOUND_DMA	10
#define MEM_ERR		1
