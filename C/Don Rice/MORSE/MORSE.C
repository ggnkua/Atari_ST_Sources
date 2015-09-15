/* The guts of a morse code tutorial/training/transmission system.
   Set length variables to control speed and spacing.
   Written for Lattice C.  Note short is 16 bits, int == long is 32 bits. */
#include <osbind.h>

/* Constants for Giaccess */
#define TRUE		1
#define FALSE		0
#define NO_ADDR		0x0L
#define GI_WRITE	0x80
#define GI_READ		0
#define CHANA_LO	0
#define CHANA_HI	1
#define CHAN_ENABLE	7
#define CHANA_VOLUME	8
#define PORT_MASK	0xC0	/* Don't disturb i/o port bits */
#define GI_STATE	0x3E	/* Tone ch A on; others off */
#define OFF		0

/* Event flags, etc */
short	ev_mwhich = 0,
	ev_mflags = MU_KEYBD | MU_BUTTON | MU_TIMER,
	ev_mbclicks = 2,
	ev_mbmask = 2,
	ev_mbstate = 2,
	ev_mm1flags = 0,
	ev_mm1x = 0,
	ev_mm1y = 0,
	ev_mm1width = 0,
	ev_mm1height = 0,
	ev_mm2flags = 0,
	ev_mm2x = 0,
	ev_mm2y = 0,
	ev_mm2width = 0,
	ev_mm2height = 0,
	ev_mmox,
	ev_mmoy,
	ev_mmobutton,
	ev_mmokstate,
	ev_mkreturn,
	ev_mbreturn;
char	ev_mmgpbuff[16];
/* Sound parameters */
unsigned char	a_volume = 15,
		a_hi_note = 1,
		a_lo_note = 0;

/* Initial values are for 5 WPM */
short	l_dot = 240,	/* 1200/WPM */
	l_dash = 720,	/* 3*l_dot */
	l_el = 240,	/* Interelement spacing == l_dot */
	l_char = 480,	/* Char spacing, normally 2*l_el */
	l_word = 960;	/* Word spacing, 4*l_dot */
/* Note that the routine actually sends l_el after each element,
   l_char after each character, and l_word for a space, so the
   character space is l_el+l_char == 3*l_el, and word space is
   l_el+l_char+l_word == 7*l_el, agreeing with the standards */

/* Coding table: '.' = send dit; '_' = send dah; ' ' = word space;
   anything else (ie, '\0') terminates sequence. */
#define NO_CODE	"\0"
char *codes[128] =
{
	NO_CODE,	/* 00 */
	NO_CODE,	/* 01 */
	NO_CODE,	/* 02 */
	NO_CODE,	/* 03 */
	NO_CODE,	/* 04 */
	NO_CODE,	/* 05 */
	NO_CODE,	/* 06 */
	NO_CODE,	/* 07 */
	NO_CODE,	/* 08 */
	" ",		/* 09 TAB */
	" ",		/* 0A \N */
	NO_CODE,	/* 0B */
	NO_CODE,	/* 0C */
	NO_CODE,	/* 0D */
	NO_CODE,	/* 0E */
	NO_CODE,	/* 0F */
	NO_CODE,	/* 10 */
	NO_CODE,	/* 11 */
	NO_CODE,	/* 12 */
	NO_CODE,	/* 13 */
	NO_CODE,	/* 14 */
	NO_CODE,	/* 15 */
	NO_CODE,	/* 16 */
	NO_CODE,	/* 17 */
	NO_CODE,	/* 18 */
	NO_CODE,	/* 19 */
	NO_CODE,	/* 1A */
	NO_CODE,	/* 1B */
	NO_CODE,	/* 1C */
	NO_CODE,	/* 1D */
	NO_CODE,	/* 1E */
	NO_CODE,	/* 1F */
	" ",		/* 20 SPACE */
	"..._.",	/* 21 ! Understood */
	"._.._.",	/* 22 " */
	"._._..",	/* 23 # Paragraph */
	"..._.._",	/* 24 $ Dollar sign */
	"_._._",	/* 25 % Start/Attention */
	"._...",	/* 26 & Wait */
	".____.",	/* 27 ' */
	"_.__.",	/* 28 ( */
	"_.__._",	/* 29 ) */
	"..._._",	/* 2A * End of Work */
	"._._.",	/* 2B + End of Message */
	"__..__",	/* 2C , */
	"_..._",	/* 2D - */
	"._._._",	/* 2E . */
	"_.._.",	/* 2F / */
	"_____",	/* 30 0 */
	".____",	/* 31 1 */
	"..___",	/* 32 2 */
	"...__",	/* 33 3 */
	"...._",	/* 34 4 */
	".....",	/* 35 5 */
	"_....",	/* 36 6 */
	"__...",	/* 37 7 */
	"___..",	/* 38 8 */
	"____.",	/* 39 9 */
	"___...",	/* 3A : */
	"_._._.",	/* 3B ; */
	NO_CODE,	/* 3C < */
	"_..._",	/* 3D = Double dash */
	"._._",		/* 3E > Newline */
	"..__..",	/* 3F ? */
	NO_CODE,	/* 40 @ */
	"._",		/* 41 A */
	"_...",		/* 42 B */
	"_._.",		/* 43 C */
	"_..",		/* 44 D */
	".",		/* 45 E */
	".._.",		/* 46 F */
	"__.",		/* 47 G */
	"....",		/* 48 H */
	"..",		/* 49 I */
	".___",		/* 4A J */
	"_._",		/* 4B K */
	"._..",		/* 4C L */
	"__",		/* 4D M */
	"_.",		/* 4E N */
	"___",		/* 4F O */
	".__.",		/* 50 P */
	"__._",		/* 51 Q */
	"._.",		/* 52 R */
	"...",		/* 53 S */
	"_",		/* 54 T */
	".._",		/* 55 U */
	"..._",		/* 56 V */
	".__",		/* 57 W */
	"_.._",		/* 58 X */
	"_.__",		/* 59 Y */
	"__..",		/* 5A Z */
	NO_CODE,	/* 5B [ (start prosign, see below) */
	"........",	/* 5C \\ Error */
	NO_CODE,	/* 5D ] (end prosign, see below) */
	NO_CODE,	/* 5E ^ */
	"..__._",	/* 5F _ */
	NO_CODE,	/* 60 ` */
	"._",		/* 61 a */
	"_...",		/* 62 b */
	"_._.",		/* 63 c */
	"_..",		/* 64 d */
	".",		/* 65 e */
	".._.",		/* 66 f */
	"__.",		/* 67 g */
	"....",		/* 68 h */
	"..",		/* 69 i */
	".___",		/* 6A j */
	"_._",		/* 6B k */
	"._..",		/* 6C l */
	"__",		/* 6D m */
	"_.",		/* 6E n */
	"___",		/* 6F o */
	".__.",		/* 70 p */
	"__._",		/* 71 q */
	"._.",		/* 72 r */
	"...",		/* 73 s */
	"_",		/* 74 t */
	".._",		/* 75 u */
	"..._",		/* 76 v */
	".__",		/* 77 w */
	"_.._",		/* 78 x */
	"_.__",		/* 79 y */
	"__..",		/* 7A z */
	NO_CODE,	/* 7B { */
	NO_CODE,	/* 7C | */
	NO_CODE,	/* 7D } */
	NO_CODE,	/* 7E ~ */
	NO_CODE		/* 7F */
};

/* send_morse: sends each character in the supplied string subject to the
   above translation table.  Exception: '[' sets l_char :== 0 and ']'
   returns l_char to its original value.  Thus prosigns can be composed
   (eg, [SK], [KN]) rather than using the equivalent punctuation given
   above.  It is the sender's responsibility to see that the results are
   meaningful; send_morse will happily cram together anything, including
   [absolute garbage].
   Note that end of string simulates ']' so prosigns cannot be broken into
   separate calls to send_morse.
   Also note that for multiple calls, str should start or end with a space
   character (' ', '\t', '\n') because the first character of a new str
   will be sent immediately, and only inter-character space is given
   following the last character of str */
short send_morse( str )
char *str;
{
	short ll_char, i, len, j, els, m_send(), m_pause();
	char ch, elem, *seq;
	unsigned char port_state=GI_STATE, new_state;

	/* Set sound chip */
	port_state = (unsigned char) Giaccess( port_state, 
	  CHAN_ENABLE|GI_READ );
	new_state = (port_state & PORT_MASK) | GI_STATE;
	Giaccess( new_state, CHAN_ENABLE|GI_WRITE );

	Giaccess( OFF, CHANA_VOLUME|GI_WRITE );
	Giaccess( a_hi_note, CHANA_HI|GI_WRITE );
	Giaccess( a_lo_note, CHANA_LO|GI_WRITE );

	ev_mkreturn = 0;
	ll_char = l_char;	/* Actual inter-character space */
	len = strlen( str );
	for( i=0; i<len; i++ )
		if( ev_mkreturn != 0 ) break;
		else if( (ch = str[i]) == '[' )
			l_char = 0;
		else if( ch == ']' )
		{
			l_char = ll_char;
			m_pause( l_char );
		}
		else
		{
			els = strlen( seq = codes[ch] );
			for( j=0; j<els; j++ )
				if( (elem = seq[j]) == ' ' )
					if( j == 0 ) m_pause( l_el+l_char+l_word );
					else m_pause( l_word );
				else if( elem == '.' )
				{
					m_send( l_dot );
					m_pause( l_el );
				}
				else if( elem == '_' )
				{
					m_send( l_dash );
					m_pause( l_el );
				}
			if( elem != ' ' ) m_pause( l_char );
		}
	l_char = ll_char;
	Giaccess( OFF, CHANA_VOLUME|GI_WRITE );
	Giaccess( port_state, CHAN_ENABLE|GI_WRITE );
	return( i );
}	/* send_morse */

short m_pause( len )	/* pause len milliseconds */
short len;
{
	short m_wait();

	Giaccess( OFF, CHANA_VOLUME|GI_WRITE );

	return( m_wait( len ) );
}	/* m_pause */

short m_send( len )	/* send tone for len milliseconds */
short len;
{
	short m_wait();

	Giaccess( a_volume, CHANA_VOLUME|GI_WRITE );
	Giaccess( a_hi_note, CHANA_HI|GI_WRITE );
	Giaccess( a_lo_note, CHANA_LO|GI_WRITE );

	return( m_wait( len ) );
}	/* m_send */

short m_wait( len )	/* wait around for len milliseconds */
short len;
{
	short item, done = FALSE, i, mmox, mmoy, mmobutton, mmokstate,
	  mkreturn, mbreturn;
	char mmgpbuff[16];

	if( len == 0 ) return( 0 );
	while( !done )
	{
		item = evnt_multi( ev_mflags, ev_mbclicks, ev_mbmask,
		  ev_mbstate, ev_mm1flags, ev_mm1x, ev_mm1y, ev_mm1width,
		  ev_mm1height, ev_mm2flags, ev_mm2x, ev_mm2y, ev_mm2width,
		  ev_mm2height, mmgpbuff, len, 0, &mmox, &mmoy, &mmobutton,
		  &mmokstate, &mkreturn, &mbreturn );
		if( item & MU_TIMER ) done = TRUE;
		if( item != MU_TIMER )
		{
			ev_mwhich = item;
			for( i=0; i<16; i++ )
				ev_mmgpbuff[i] = mmgpbuff[i];
			ev_mmox = mmox;
			ev_mmoy = mmoy;
			ev_mmobutton = mmobutton;
			ev_mmokstate = mmokstate;
			ev_mkreturn = mkreturn;
			ev_mbreturn = mbreturn;
		}
	}
	return( ev_mwhich );
}	/* m_wait */
