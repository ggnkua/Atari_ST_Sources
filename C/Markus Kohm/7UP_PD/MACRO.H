#define MAX_MACROS 256L /* Increment der Macroerweiterungen */

#define ALTF7 0x84100
#define ALTF8 0x84200
#define ALTF9 0x84300

typedef struct
{
	int kstate, key;
}TMACROBUFF;

typedef struct
{
	char versionstr[31/*VERSIONSTRLEN*/];
	unsigned int version;
	int headerlen;
	long size,
		  macroindex,
	     lastmacro,
	     rec,
	     play,
	     repindex,
	     lastrep;
	TMACROBUFF *mp;
}TMACRO;

int record_macro(int command, int kstate, int key);
int play_macro(int *kstate, int *key);