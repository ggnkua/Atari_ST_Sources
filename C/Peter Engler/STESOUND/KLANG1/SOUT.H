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



/* --- Typdeklaration --- */

typedef struct
{
	unsigned long anz_bytes;			/* --- LÑnge des Frames --- */
	unsigned long bytes_pro_sekunde;	/* --- Samplingfrequenz --- */
	int control_reg;			/* --- Wert fÅr Sound-DMA-Control Register --- */	
	int mode_reg;				/* --- Wert fÅr Sound-Mode-Control Register --- */
	int frequenz;				/* --- Was wohl ? --- */
	char *s_ptr; 				/* --- Zeiger auf den Frame --- */

} SOUND;



/* --- Prototypen der Assemblerfunktionen aus sout.s --- */

void snd_stop( void );
void snd_play( SOUND * );

