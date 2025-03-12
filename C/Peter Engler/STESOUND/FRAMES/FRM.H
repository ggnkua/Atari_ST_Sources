/* --- FRM.H:  Headerdatei fÅr das Assemblermodul FRM.S --- */



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



/* --- Typdeklarationen --- */

/* --- Struktur zur Speicherung eines Frames --- */
typedef struct
{
	unsigned long anz_bytes;
	unsigned long bytes_pro_sekunde;
	int control_reg;
	int mode_reg;
	int frequenz;
	int wiederholungen;
	char *s_ptr; 

} FSOUND;


/* --- Die FRAME-Struktur faût alle auszugebenden Frames zusammen --- */
typedef struct
{
	int anz_frames;
	FSOUND **frame_tab;
} FRAME;



/* --- Prototypen der Assemblerfunktionen aus FRAMES.S --- */
void frm_stop( void );
void frm_start( FRAME * );