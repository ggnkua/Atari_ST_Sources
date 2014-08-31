/***********************************************/
/* Modulname      : FALCON.H                   */
/* Autor          : Thomas Binder              */
/* Zweck          : Headerdatei zur FALCON-    */
/*                  XBIOS-Library (ohne DSP-   */
/*                  Routinen!)                 */
/* Compiler       : Pure C 1.0                 */
/* Erstellt am    : 20.05.1993                 */
/* Letzte énderung: 26.08.1993                 */
/***********************************************/


#ifndef __FALCON
#define __FALCON


/* Konstanten fÅr den Videomodus */

#define VERTFLAG	0x100
#define STMODES		0x80
#define OVERSCAN	0x40
#define PAL			0x20
#define VGA			0x10
#define TV			0x0
#define COL80		0x08
#define COL40		0x0
#define BPS16		0x04
#define BPS8		0x03
#define BPS4		0x02
#define BPS2		0x01
#define BPS1		0x0
#define NUMCOLS		0x07


/* RÅckgabewerte von Locksnd() und Unlocksnd() */

#define SNDLOCKED	-129
#define SNDNOTLOCK	-128


/* Soundcmd()-Konstanten */

#define LTATTEN		0
#define RTATTEN		1
#define LTGAIN		2
#define RTGAIN		3
#define ADDRIN		4
#define ADCINPUT	5
#define SETPRESCALE	6


/* Aufnahme-/Wiedergabemodi */

#define STEREO8		0
#define STEREO16	1
#define MONO8		2


/* Devconnect()-Konstanten */

#define CLK25M		0
#define CLKEXT		1
#define CLK32M		2
#define DMAPLAY		0
#define DSPXMIT		1
#define EXTINP		2
#define ADC			3
#define DMAREC		0
#define DSPREC		2
#define EXTOUT		4
#define DAC			8
#define CLKOLD		0
#define CLK50K		1
#define CLK33K		2
#define CLK25K		3
#define CLK20K		4
#define CLK16K		5
#define CLK12K		7
#define CLK10K		9
#define CLK8K		11


/* Die von Buffptr() benutzte Struktur */

typedef struct
{
	void	*playbufptr;
	void	*recbufptr;
	long	reserved1,
			reserved2;
} BUFFPTR;


/* Die einzelnen Prototypen... */

/* ... fÅr die Videohardware */
int		VSetscreen(void *log, void *phys,
			int rez, int mode);
/* Achtung! VSetscreen statt Setscreen, um
   nicht mit altem Aufruf zu kollidieren */
int		Vsetmode(int modecode);
int		mon_type(void);
void	VsetSync(int external);
long	VgetSize(int mode);
void	VsetRGB(int index, int count,
			long *array);
void	VgetRGB(int index, int count,
			long *array);
void	VsetMask(int andmask, int ormask);

/* ... und fÅr das Soundsubsystem */
long	locksnd(void);
long	unlocksnd();
long	soundcmd(int mode, int data);
long	setbuffer(int reg, void *begaddr,
			void *endaddr);
long	setsndmode(int mode);
long	settrack(int playtracks, int rectracks);
long	setmontrack(int montrack);
long	setinterrupt(int src_inter, int cause);
long	buffoper(int mode);
long	dsptristate(int dspxmit, int dsprec);
long	gpio(int mode, int data);
long	devconnect(int src, int dst, int srcclk,
			int prescale, int protocol);
long	sndstatus(int reset);
long	buffptr(BUFFPTR *pointer);


#endif /* __FALCON */

