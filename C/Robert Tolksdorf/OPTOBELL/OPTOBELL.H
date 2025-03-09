/* OPTOBELL.H
 *
 * Definitionen fÅr OPTOBELL.C und OPTOCONF.C
 */
 
/* Der Cookie-ID "RTOB"			*/
#define OPTOID		0x52544F42L

/* Die Cookie-Struktur			*/
typedef struct{
	long	id,	val;
} COOKIE;

/* Die OptoBell-Einstellungen	*/
#define O_BLINK		 1
#define O_BLINKBELL	-1
#define O_BELL		 0

/* Ende von OPTOBELL.H	*/
