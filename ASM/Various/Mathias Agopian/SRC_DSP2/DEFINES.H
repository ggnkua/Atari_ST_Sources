typedef unsigned char uchar ;
typedef unsigned int uint ;

typedef struct
{
	unsigned synchro	: 12;
	unsigned ID			: 1;
	unsigned couche		: 2;
	unsigned crc_check	: 1;
	unsigned debit		: 4;
	unsigned frequence	: 2;
	unsigned padding	: 1;
	unsigned user		: 1;
	unsigned type		: 2;
	unsigned stereo		: 2;
	unsigned copyright	: 1;
	unsigned original	: 1;
	unsigned acc		: 1;
	unsigned reserved	: 1;
}MPEG_AUDIO_HEADER;
