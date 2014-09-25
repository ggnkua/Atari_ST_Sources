/*	perform.h			By Jeff Koftinoff
**	v2.0		 		started: Apr 17/88
**
*/

#include <jk_sys.h>



#define NUM_SONGS (1024)

typedef struct _SONG {
	long	type,
		length,
		offset;			// 	offset to song data
	char	*location,
		thru,
		master_local,
		full_name[32];
	short	division;		// for Midi files	
	char	_later[76];			
} SONG;



typedef struct s_cfg {
	long	cfg_type;
	char	master_ch,
		master_local,
		light_ch,
		disp_type,
		disp_chan,
		thru,
		ctrl_type,
		ctrl_chan,
		auto_play,
		int_chan,
		wait_after_excl,
		use_joy,
		load_single,
		pause_after_load,
		_later[238];	

} CFG;

struct midi_header 
{
	long type;
	long header_len;
	short format;
	short ntracks;
	short division;
	long trk_type;
	long trk_len;
};



typedef enum {			/* disk filing errors	*/
	NoError,
	OpenError,
	CreateError,
	ReadError,
	WriteError,
	TypeError
} DiskErr;

extern	long	jk_get_200( void );

typedef struct _SET {	
	int	num_songs;
	char	list[1024][96];
} SET;

#define TSNG1	OSTYPE('S','N','G','1')
#define TTNG1	OSTYPE('T','N','G','1')

#define TMTrk	OSTYPE('M','T','r','k')
#define TMThd	OSTYPE('M','T','h','d')
#define TNThd	OSTYPE('N','T','h','d')

#define TEXCL	OSTYPE('E','X','C','L')

#define TSET0	OSTYPE('S','E','T','0')
#define TSET1	OSTYPE('S','E','T','1')
#define TSET2	OSTYPE('S','E','T','2')

#define TCFG0	OSTYPE('C','F','G','0')
#define TCFG1	OSTYPE('C','F','G','1')

#define TBAD	OSTYPE('B','A','D',' ')

