#include "FALC_SPL.H"

typedef long	ID;

typedef union
{
	unsigned long	Frequence;
	char			FreqReplay;
}AVR_FREQ_TYPE;

typedef struct
{
	ID				avrID;
	char			Name[8];
	int				numVoices;
	int				numBits;
	int				Signe;
	int				Loop;
	int				Midi;
	AVR_FREQ_TYPE	FreqType;	
	unsigned long	Length;
	unsigned long	begLoop;
	unsigned long	endLoop;
	char			reserved[26];
	char			user[64];
}AVR_HEADER;

long double AVR_Freq_list[]={5485.0,8084.0,10971.0,16168.0,21942.0,32336.0,43885.0,47261.0};
