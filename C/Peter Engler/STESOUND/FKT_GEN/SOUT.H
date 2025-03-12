/* --- SOUT.H:  Headerdatei fÅr das Assemblermodul SOUT.S --- */



/* --- Konstanten fÅr das Sound-DMA-Control Register --- */
#define SND_STOP   0
#define SND_EINMAL 1
#define SND_IMMER  3

/* --- Konstanten fÅr das Sound-Mode Register --- */
#define MOD_FR6K 	0x0000	/* --- Samplingfrequenz: 6258 Hz --- */
#define MOD_FR12K	0x0001	/* ---					 12517 Hz --- */
#define MOD_FR25K	0x0002	/* ---					 25033 Hz --- */
#define MOD_FR50K	0x0003	/* --- 					 50066 Hz --- */

#define MOD_STEREO	0x0000	/* --- Stereo - Wiedergabe --- */
#define MOD_MONO	0x0080	/* --- Mono - Wiedergabe --- */


/* --- Konstanten fÅr die Zumischung der Signale des GI-Soundchips --- */
#define GI_MIX		1
#define GI_NOMIX	2
#define VOL_12DB	0



/* --- Typdeklaration --- */

typedef struct
{
	unsigned long anz_bytes;
	unsigned long bytes_pro_sekunde;
	int control_reg;
	int mode_reg;
	int frequenz;
	char *s_ptr; 

} SOUND;



/* --- Prototypen der Assemblerfunktionen aus sout.s --- */
void snd_stop( void );
void snd_play( SOUND * );
void snd_laut( int );
void snd_links( int );
void snd_rechts( int );
void snd_hoehen( int );
void snd_tiefen( int );
void snd_mix( int );
void snd_init( void );

