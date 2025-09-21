/************************************************************************/
/*																		*/
/* FalconScreen															*/
/* ============															*/
/*																		*/
/* Copyright 1993 by Markus Gutschke.									*/
/* This program is postcardware. You are encouraged to distribute it	*/
/* freely as long as you do not charge anybody for it, but if you keep	*/
/* a copy, you have to send me a postcard:								*/
/*		Markus Gutschke													*/
/*		Papenbusch 31													*/
/*		4400 M"unster													*/
/*		W-Germany														*/
/* Note! This program may not be distributed with so-called PD-			*/
/* collections or on cover-disks!										*/
/* If you encounter any bugs (there are probably a lot!), have comments	*/
/* or suggestions or just found some useful settings for the video		*/
/* registers, please send e-mail to:									*/
/*		srb242@math.uni-muenster.de										*/
/* or:	Markus.Gutschke@uni-muenster.de									*/
/*																		*/
/* The current version of this program will only affect the 640x480x4bit*/
/* mode on an SVGA monitor. It will replace this mode with a user		*/
/* selectable higher resolution. Currently 928x696 is the highest		*/
/* possible setting.													*/
/*																		*/
/* This program relies on several undocumented features of the			*/
/* Falcon030, thus I am unable to guarantee, that it will work on any	*/
/* computer other than my own. This program will most certainly damage	*/
/* any monitor, that does not support SVGA video modes! Even SVGA		*/
/* monitors might be damaged/destroyed, since this program is pushing	*/
/* the signal timing very hard. If you feel at all uncomfortable with	*/
/* the possibility of damaging your hardware, do not run this program!	*/
/*																		*/
/* Since I am releasing this program free of charge, I am unable to		*/
/* give any support or guarantee for this program!						*/
/*																		*/
/* This program will compile with TurboC and PureC. You will probably	*/
/* have to make changes, if you want to compile it with any other		*/
/* system. If you added conditional preprocessor directives that allow	*/
/* you to compile this program both with TC/PC and with your system		*/
/* please let me know.													*/
/* The assembler interface relies on the TC/PC parameter passing scheme.*/
/* Scalar values will be passed in D0 through D2, addresses will be		*/
/* passed in A0 and A1; all parameters that cannot be passed by			*/
/* registers, will be passed on the stack. Return values will be either	*/
/* in D0 (scalar values) or in A0 (pointers). D3-D7/A2-A7 remain		*/
/* unaffected throughout a function call.								*/
/*																		*/
/************************************************************************/

#define		BETA					/* This is a beta release of FS		*/
#define		PRGNAME		"FS.PRG"	/* Program name for patching params.*/
#define		ID			'\344FSC'	/* XBRA Id							*/
#define		PLANES		4			/* Number of planes					*/

#define		MINN		1			/* minimum legal value for N		*/
#define		MAXN		9			/* maximum legal value for N		*/

/* Several negative LineA variables need patching						*/

#define		VGemX		(((int *)linea)[-0x015A])
#define		VGemY		(((int *)linea)[-0x0159])
#define		VCelHT		(((int *)linea)[-0x0017])
#define		VCelMX		(((int *)linea)[-0x0016])
#define		VCelMY		(((int *)linea)[-0x0015])
#define		VCelWR		(((int *)linea)[-0x0014])
#define		VXMax		(((int *)linea)[-0x0006])
#define		VYMax		(((int *)linea)[-0x0002])
#define		VBytesLin	(((int *)linea)[-0x0001])
#define		VPlanes		(((int *)linea)[ 0x0000])
#define		VWrap		(((int *)linea)[ 0x0001])

/* List of undocumented video registers (c.f. VIDEO.PRG)				*/

#define		RShift		(*(int *)0xFFFF8260l)
#define		RSpShift	(*(int *)0xFFFF8266l)
#define		RWrap		(*(int *)0xFFFF8210l)
#define		RCO			(*(int *)0xFFFF82C0l)
#define		RMode		(*(int *)0xFFFF82C2l)
#define		RHHT		(*(int *)0xFFFF8282l)
#define		RHBB		(*(int *)0xFFFF8284l)
#define		RHBE		(*(int *)0xFFFF8286l)
#define		RHDB		(*(int *)0xFFFF8288l)
#define		RHDE		(*(int *)0xFFFF828Al)
#define		RHSS		(*(int *)0xFFFF828Cl)
#define		RHFS		(*(int *)0xFFFF828El)
#define		RHEE		(*(int *)0xFFFF8290l)
#define		RVFT		(*(int *)0xFFFF82A2l)
#define		RVBB		(*(int *)0xFFFF82A4l)
#define		RVBE		(*(int *)0xFFFF82A6l)
#define		RVDB		(*(int *)0xFFFF82A8l)
#define		RVDE		(*(int *)0xFFFF82AAl)
#define		RVSS		(*(int *)0xFFFF82ACl)

/* Bindings for system calls are provided by the assembler modul		*/

void	*LineA0(void);
int		Kbshift(int);
void	*Physbase(void);
void	Setscreen(void *,void *,int,int);
int		Vsetmode(int);
int		Montype(void);
void	VsetRGB(int,int,long *);
void	VgetRGB(int,int,long *);
void	Pterm0(void);
int		Cnecin(void);
void	Cconws(char *);
int		Cconis(void);
void	*Srealloc(unsigned long);
long	Super(void *);
int		Fopen(char *,int);
void	Fclose(int);
long	Fread(int,long,void *);
long	Fwrite(int,long,void *);
long	Fseek(long,int,int);
void	*Malloc(long amount);
void	Mfree(void *addr);

/* Copyright message													*/

void showlogo(int x,int y,unsigned short *scr,
              int width,int height,int planes);
void hidelogo(void);
static char copyright[] =
	"\x1BpFalconScreen (c) 1993 by M. Gutschke\x1Bq\r\n"
	"This program is postcardware!\r\n"
	"If you like it, send a postcard to:\r\n"
	"   Markus Gutschke\r\n"
	"   Papenbusch 31\r\n"
	"   4400 M\x81nster\r\n"
	"   W-Germany\r\n"
#ifdef	BETA
	"Warning! This is a beta-Release!\r\n"
#endif
	"This program might damage your F030\r\n"
	"and/or your monitor!\r\n";

/* Preset values														*/

struct settings {					/* This preinitialized structure	*/
	long	magic;					/* can be patched by the program!	*/
	int		size;
	int		mask;					/* It contains the user's prefered	*/
	int		value;					/* resolution.						*/
	int		planes;
	int		n;
	int		width,height;
} settings = {ID,(int)sizeof(struct settings),
              0x18F,0x00A,PLANES,MINN-1,640,400};

/* Precomputed parameter sets:											*/

static struct {
	int		width,height,frq,planes;
	int		Shift,SpShift,Wrap,CO,Mode,HHT,HBB,HBE,HDB;
	int		HDE,HSS,HFS,HEE,VFT,VBB,VBE,VDB,VDE,VSS;
} table[MAXN-MINN+2] = {
	640,480,62, 4,0,0,160,0x186,8,0x0c6,0x8d,0x15,0x2a3,0x7c,0x96,0,0,
									0x3e7,0x3e3,0x23,0x23,0x3eb,0x3e4,
	672,512,72, 4,0,0,168,0x182,8,0x0ce,0x8d,0x0d,0x2a3,0x7c,0x96,0,0,
									0x427,0x423,0x23,0x23,0x42b,0x424,
	704,528,67, 4,0,0,176,0x182,8,0x0d6,0x8d,0x05,0x2a3,0x7c,0x96,0,0,
									0x447,0x443,0x23,0x23,0x44b,0x444,
#ifdef	OLDVALUES
	736,560,58, 4,0,0,184,0x182,8,0x0ea,0xa2,0x1e,0x2d0,0x91,0xb8,0,0,
									0x487,0x483,0x23,0x23,0x48b,0x484,
	768,576,55, 4,0,0,192,0x182,8,0x0f2,0xa2,0x16,0x2d0,0x91,0xb8,0,0,
									0x4a7,0x4a3,0x23,0x23,0x4ab,0x4a4,
	800,608,50, 4,0,0,200,0x182,8,0x0fa,0xa2,0x0e,0x2d0,0x91,0xb8,0,0,
									0x4e7,0x4e3,0x23,0x23,0x4eb,0x4e4,
	832,624,48, 4,0,0,208,0x182,8,0x102,0xa2,0x06,0x2d0,0x91,0xb8,0,0,
									0x507,0x503,0x23,0x23,0x50b,0x504
#else
	/* Harald, thank you for finding these improved values!				*/
	736,560,61, 4,0,0,184,0x182,8,0x0df,0xb8,0x29,0x2d0,0xa8,0xb7,0,0,
									0x487,0x483,0x23,0x23,0x48b,0x484,
	768,576,57, 4,0,0,192,0x182,8,0x0e7,0xb8,0x21,0x2d0,0xa8,0xb7,0,0,
									0x4a7,0x4a3,0x23,0x23,0x4ab,0x4a4,
	800,608,52, 4,0,0,200,0x182,8,0x0ef,0xb8,0x19,0x2d0,0xa8,0xb7,0,0,
									0x4e7,0x4e3,0x23,0x23,0x4eb,0x4e4,
	832,624,50, 4,0,0,208,0x182,8,0x0f7,0xb8,0x11,0x2d0,0xa8,0xb7,0,0,
									0x507,0x503,0x23,0x23,0x50b,0x504,
	864,656,46, 4,0,0,216,0x182,8,0x0ff,0xb8,0x09,0x2d0,0xa8,0xb7,0,0,
									0x547,0x543,0x23,0x23,0x54b,0x544,
	896,672,45, 4,0,0,224,0x182,8,0x0ff,0xb8,0x01,0x2d0,0xa8,0xb7,0,0,
									0x567,0x563,0x23,0x23,0x56b,0x564,
	928,696,41, 4,0,0,232,0x182,8,0x10f,0xb8,0x01,0x2e0,0xa8,0xb7,0,0,
									0x597,0x593,0x23,0x23,0x59b,0x594
#endif
};

/* Convert a number to a string without exceeding the string size		*/

static char *tonum(int i,char *s,int *n)
{
	/* recursion is needed to output digits in the right order!			*/
	if (i > 10) s = tonum(i/10,s,n);
	if (*n > 1) {
		(*n)--;
		*s++ = i%10+'0'; }
	*s = '\000';
	return(s);
}

/* Create a string that describes a screen resolution					*/

static void makeresstr(int w,int h,int p,int f,char *s,int n)
{
	char	*ptr1 = "bit (";
	char	*ptr2 = "Hz)           ";

	/* -> "NNNxNNNxNbit (NNHz)      "									*/
	s = tonum(w,s,&n);
	if (n <= 1) goto eos; else { n--; *s++ = 'x'; }
	s = tonum(h,s,&n);
	if (n <= 1) goto eos; else { n--; *s++ = 'x'; }
	s = tonum(p,s,&n);
	while (*ptr1 && n-- > 1)
		*s++ = *ptr1++;
	if (n <= 1) goto eos;
	s = tonum(f,s,&n);
	while (*ptr2 && n-- > 1)
		*s++ = *ptr2++;
eos:
	*s ='\000';
	return;
}

/* Initialize video registers											*/

static void setvideo(void)
{
	RShift		= table[settings.n].Shift;
	RSpShift	= table[settings.n].SpShift;
	RWrap		= table[settings.n].Wrap;
	RCO			= table[settings.n].CO;
	RMode		= table[settings.n].Mode;
	RHHT		= table[settings.n].HHT;
	RHBB		= table[settings.n].HBB;
	RHBE		= table[settings.n].HBE;
	RHDB		= table[settings.n].HDB;
	RHDE		= table[settings.n].HDE;
	RHSS		= table[settings.n].HSS;
	RHFS		= table[settings.n].HFS;
	RHEE		= table[settings.n].HEE;
	RVFT		= table[settings.n].VFT;
	RVBB		= table[settings.n].VBB;
	RVBE		= table[settings.n].VBE;
	RVDB		= table[settings.n].VDB;
	RVDE		= table[settings.n].VDE;
	RVSS		= table[settings.n].VSS;
	return;
}

/* Patch (negative) line-A variables									*/

static void patchos(void)
{
	void	*linea = LineA0();

	VPlanes     = settings.planes;	/* Patch a couple of LineA variables*/
	VWrap		= (settings.width>>3)*settings.planes;
	VGemX		= settings.width-1;	/* VGemX and VGemY are undocumented!*/
	VGemY		= settings.height-1;
	VCelMX		= (settings.width>>3)-1;
	VCelMY		= settings.height/VCelHT-1;
	VCelWR		= (settings.width>>3)*settings.planes*VCelHT;
	VXMax		= settings.width;
	VYMax		= settings.height;
	VBytesLin	= (settings.width>>3)*settings.planes;
	return;
}

/* Reallocate new screen memory											*/

static void realloc(void)
{
	long	scrsize,hz200;
	void	*scraddr;

	scrsize = ((long)settings.width*(long)settings.height*
	          (long)settings.planes)>>3;
	scraddr = Srealloc(scrsize);	/* Reallocate screen memory			*/
	Setscreen(scraddr,scraddr,-1,-1);/* Set new screen address			*/
	showlogo(48,48,scraddr,settings.width,settings.height,4);
	for (hz200 = *(long *)0x4BA+130;/* wait 0.65 seconds				*/
	     *(long *)0x4BA < hz200;);
	hidelogo();
	return;
}

/* Initialize a new video mode											*/

void init(int dorealloc)
{
	Cconws("\x1B""H");
	patchos();
	setvideo();
	if (dorealloc)
		realloc();
	Cconws("\x1B""E");
	return;
}

/* Handle extended setscreen modes										*/

long	setscreen(long rc,void *log,void *phys,int rez,int mode)
{
	if (rez == 3 && (mode & settings.mask) == settings.value)
		init(!log && !phys);
	return(rc);
}

/* Replace 640x480x4bit with new video mode								*/

long	vsetmode(long rc,int mode)
{
	if ((mode & settings.mask) == settings.value)
		init(0);
	return(rc);
}

/* Return new screen size												*/

long	vgetsize(long rc,int mode)
{
	if ((mode & settings.mask) == settings.value)
		return(((long)settings.width*(long)settings.height*
		        (long)settings.planes)>>3);
	return(rc);
}

/* Get/set an entry from the system cookie jar							*/

static long	docookie(long cookie,long value)
{
	long	stack;
	long	*cookiejar;

	stack = Super(0l);
	cookiejar = *(long **)0x5a0;
	if (cookiejar) {
		while (*cookiejar && *cookiejar != cookie) cookiejar += 2;
		if (*cookiejar == 0 && value != 0 &&
		    cookiejar - *(long **)0x5a0 < 2*cookiejar[1]) {
			cookiejar[3] = cookiejar[1];
			cookiejar[2] = 0;
			cookiejar[1] = value;
			cookiejar[0] = cookie; } }
	Super((void *)stack);
	return (cookiejar && *cookiejar == cookie ? cookiejar[1] : 0);
}

/* Change preferences													*/

static void setup(void)
{
	char	s[22];
	int		handle,oldn,mode,oldmode,frq;
	long	scrsize,offset,stack;
	unsigned long hz200,vbl;
	void	*oldscr,*newscr;
	struct {long magic;int size;} header;

	while (Cconis()) Cnecin();
	if (settings.n < MINN || settings.n > MAXN)
		settings.n = MINN-1;		/* FS is inactive					*/
	Cconws("Press <SHIFT> for testing!\r\n");
	oldn = settings.n;
	for (;;) {
		Cconws("\x1BY\x2C Current resolution: ");
		settings.width = table[settings.n].width;
		settings.height= table[settings.n].height;
		makeresstr(settings.width,settings.height,
		           settings.planes,table[settings.n].frq,s,21);
		Cconws(s);
		Cconws("(+/-)");
		scrsize = ((long)settings.width*(long)settings.height*
		           (long)settings.planes)>>3;
		newscr = Malloc(scrsize);
		oldscr = Physbase();
		for (mode = oldmode = Vsetmode(-1);!Cconis() || !mode;)
			if ((Kbshift(-1) & 3) && !Cconis()) {
				if (mode && newscr) {
					mode = 0;
					Setscreen(newscr,newscr,3,0x001A);
					stack = Super(0L);
					setvideo();
					showlogo(48,48,newscr,settings.width,
					         settings.height,4);
					         		/* measure refresh rate, while user */
					         		/* views the screen					*/
					vbl = *(unsigned long *)0x462;
					hz200 = *(unsigned long *)0x4ba;
					Super((void *)stack); } }
			else
				if (!mode) {
					stack = Super(0L);
					hz200 = *(unsigned long *)0x4ba - hz200;
					vbl = *(unsigned long *)0x462 - vbl;
					Super((void *)stack);
									/* calculate "real" refresh rate	*/
					frq = (int)((vbl*2000L+5)/hz200)/10;
					mode = oldmode;
					hidelogo();
					Setscreen(newscr,newscr,3,oldmode);
					Setscreen(oldscr,oldscr,-1,-1);
									/* check for plausibility			*/
					if ((frq - table[settings.n].frq) > -20 &&
					    (frq - table[settings.n].frq) <  20 &&
					    vbl > 20) {
						table[settings.n].frq = frq;
						makeresstr(settings.width,settings.height,
						           settings.planes,frq,s,21);
						Cconws("\x1BY\x2C Current resolution: ");
						Cconws(s);
						Cconws("(+/-)"); } }
		Mfree(newscr);
		switch ((char)Cnecin()) {	/* In/decrease resolution			*/
			case '+':
				if (settings.n < MAXN) settings.n++;
				break;
			case '-':
				if (settings.n >= MINN) settings.n--;
				break;
			default:
				goto eol; } }
eol:								/* Patch the executeable file		*/
	Cconws("\x1BY\x2C \x1BK");
	if (oldn != settings.n) {
		Cconws("S(ave settings, C(ontinue...\r\n");
		if (((char)Cnecin() & 0xDF) == 'S') {
			if ((handle = (int)Fopen(PRGNAME,2)) < 0 &&
			    (handle = (int)Fopen("AUTO\\"PRGNAME,2)) < 0) {
				Cconws("Cannot open FS.PRG!\r\n");
				Cnecin();
				goto ferr; }
			Fseek(0x1E,handle,0);	/* Find patch area and check for	*/
			Fread(handle,4,&offset);/* magic first!						*/
			Fseek(0x1C+offset,handle,0);
			Fread(handle,6,&header);
			if (header.magic != ID || header.size != sizeof(settings)) {
				Cconws("Illegal file format!\r\n");
				Cnecin(); }
			else if (Fwrite(handle,sizeof(settings)-6,
			         ((char *)&settings)+6) != sizeof(settings)-6) {
				Cconws("Could not write to FS.PRG!\r\n");
				Cnecin(); }
			Fclose(handle); } }
ferr:
	return;
}

/* Main program: check video hardware and allow change of preferences	*/

int main(void)
{
	int				rc = 0;
	struct settings *ptr;

	if ((ptr = (struct settings *)docookie(ID,0)) != 0) {
		Cconws("\x1B""E");
		Cconws(copyright);
		Cconws("FalconScreen is already installed...\r\n");
		if (ptr->size == settings.size) {
			settings = *ptr;
			setup();
			*ptr = settings; }
		Pterm0(); }
	if (docookie('_VDO',0) != 0x00030000L || Montype() != 2) {
		Cconws(copyright);
		Cconws("\x1BpYou need a Falcon030 & SVGA-monitor \x1Bq\x07"
		       "\r\n\r\n");
		Pterm0(); }
	settings.width = table[settings.n].width;
	settings.height= table[settings.n].height;
	if ((Cconis() && (Cnecin() & 0xDF) == 'S') ||
	    settings.n < MINN || settings.n > MAXN) {
		Cconws("\x1B""E");
		Cconws(copyright);
		Cconws("Press 'S' for setup...\r\n");
		setup(); }
	else {
		Cconws(copyright);
		Cconws("Press 'S' for setup...\r\n"); }
	Cconws("\r\n");
	if (settings.n < MINN || settings.n > MAXN)
		Pterm0();
	if ((Vsetmode(-1) & settings.mask) == settings.value) {
		if (docookie('MiNT',0)) {
			Cconws("Your boot configuration has to be\r\n"
			       "different from 640x480x4bit!\r\n");
			Pterm0(); }
		rc = 1; }
	docookie(ID,(long)&settings);
	return(rc);
}
