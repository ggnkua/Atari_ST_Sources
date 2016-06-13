typedef struct
{
#define AVR_MAGIC	0x32424954
	long avr_magic;					// '2BIT'
	char avr_name[8];				// sample name
#define AVR_MONO	0
#define AVR_STEREO	-1
	short avr_mode;					// mono/stereo
#define AVR_UNSIGNED	0
#define AVR_SIGNED	-1
	short avr_resolution;			// sample resolution
	short avr_signed;				// signed/unsigned sample
#define AVR_NON_LOOPING	0
#define AVR_LOOPING	-1
	short avr_looping;				// looping sample control
#define AVR_NOTE_NONE	-1
	short avr_midinote;				// assigned midi note
	unsigned long avr_frequency;	// sample frequency
	unsigned long avr_length;		// sample length
	unsigned long avr_loop_first;	// offset of first loop
	unsigned long avr_loop_end;		// offset of end loop
	char avr_reserved[6];			// reserved
	char avr_xname[20];				// sample name extension area
	char avr_user[64];				// user commitable area
} avr_t;
