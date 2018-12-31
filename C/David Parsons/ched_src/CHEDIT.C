/*
 * chedit - CHaracter EDITor, inspired by UCSD Pascal.
 *
 * "Abandon all hope, ye who enter here" -Dante
 */
#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include <stdarg.h>
#include <atari\osbind.h>
#undef toupper

#define	YES	1
#define	NO	0

#define	ESC	033

/* 
 * top line for help, edit, and charset windows
 */
#define	TOPY	4
#define	CHARY	0

/*
 * x position of display windows
 */
#define	CHARX	54
#define	EDITX	31

/*
 * pen states
 */
#define	NONE	0
#define	SET	1
#define	CLEAR	2
#define	XOR	3


/*
 * Function key definitions
 */
#define	F1	0x81
#define	F2	0x82
#define	F3	0x83
#define	F4	0x84
#define	F5	0x85
#define	F6	0x86
#define	F7	0x87
#define	F8	0x88
#define	F9	0x89
#define	F10	0x8a

#define	UNDO	0x8b

/*
 * DEGAS font information and editing information
 */
#define	FNTSIZE	0x800
char	*fontname;
int	handle;
char	hasalt=0;
unsigned char undo[16];
unsigned char font[256][16];
unsigned char curch=127;	/* character being edited */
int	curx=0;			/* x-position */
int	cury=0;			/* y-position */
int	touched=0;		/* font modified? */

/*
 * mask array for mapping xpos into the characters...
 */
int	pixelmask[8] = { 0200, 0100, 0040, 0020, 0010, 0004, 0002, 0001 };

char blurb[] = "CHEDIT V5 - Orc/20 June 1990";
char *phys;
int (*pen)();
int pen_state;

int rolll(), rollr(), rollu(), rolld(), invert(), flipr(), flipc();

main(argc, argv)
char **argv;
{
    unsigned c;
    register i;
    char *shell, *getenv(), *strdup();
    char command[128];

    if (Getrez() != 2) {
	fprintf(stderr, "Chedit only operates in 640x400 monochrome mode!\n");
	exit(1);
    }

    if (argc != 2) {
	fprintf(stderr, "usage: chedit <font>\n");
	exit(1);
    }

    if (!isatty(fileno(stdout))) {
	fprintf(stderr, "stdout is not a tty!");
	exit(1);
    }

    if ((fontname = strdup(argv[1])) == 0) {
	fprintf(stderr, "out of memory\n");
	exit(4);
    }

    clearwin();
    if (!openfont(fontname)) {
	gotoxy(0,23);
	exit(2);
    }
    init();
    for (i=0; i<16; i++)
	undo[i] = font[curch][i];

    cursor(curx, cury);
    while (1) {
	c = getany();
	cursor(curx, cury);
	switch ((c < 128) ? toupper(c) : c) {
	case 'Q':
		if (touched && !confirm("Discard changes"))
		    break;
		close(handle);
		gotoxy(0,24);
		exit(0);
	case 'C':
	    if (confirm("Clear character")) {
		for (i=0; i<16;i++)
		    font[curch][i] = 0;
		updchar();
		touched=1;
	    }
	    break;
	
	case '=':
	    if (confirm("Copy into this character")) {
		dmsg("From ");
		c = getedit();
		for (i=0; i<16; i++)
		    font[curch][i] = font[c][i];
		updchar();
		touched=1;
	    }
	    break;

	case UNDO:
	    for (i=0; i<16; i++) {
		c = font[curch][i];
		font[curch][i] = undo[i];
		undo[i] = c;
	    }
	    updchar();
	    break;
 
 	case 'G':
	    dmsg("Get ");
	    curch = getedit();
	    updchar();
	    for (i=0; i<16; i++)
		undo[i] = font[curch][i];
	    break;

	case 'H': mvcur(isupper(c), curx-1, cury  );	break;
	case 'B': mvcur(isupper(c), curx-1, cury+1);	break;
	case 'J': mvcur(isupper(c), curx,   cury+1);	break;
	case 'N': mvcur(isupper(c), curx+1, cury+1);	break;
	case 'L': mvcur(isupper(c), curx+1, cury  );	break;
	case 'U': mvcur(isupper(c), curx+1, cury-1);	break;
	case 'K': mvcur(isupper(c), curx,   cury-1);	break;
	case 'Y': mvcur(isupper(c), curx-1, cury-1);	break;
	case '<': rolll(curch); updchar();		break;
	case '>': rollr(curch); updchar();		break;
	case '{': rollu(curch); updchar();		break;
	case '}': rolld(curch); updchar();		break;
	case '/': invert(curch); updchar();		break;
	case F1: charset(rolll);			break;
	case F2: charset(rollr);			break;
	case F3: charset(rollu);			break;
	case F4: charset(rolld);			break;
	case F5: charset(invert);			break;
	case F6: charset(flipr);			break;
	case F7: charset(flipc);			break;
	case F9: flipr(curch); updchar();		break;
	case F10:flipc(curch); updchar();		break;
	case 'D': penstate(CLEAR); offbit();		break;
	case 'A': penstate(SET); onbit();		break;
	case 'X': penstate(XOR); flipbit();		break;
	case ESC: penstate(NONE);			break;
	case 'S': slicer();				break;
	case 'T': slicec();				break;
	case 'V': visit();				break;
	case 'E':
		if (hasalt)
		    dmsg("Alread 256 chars wide");
		else if (confirm("Expand to 256")) {
		    hasalt=1;
		    touched=1;
		    fontwin();
		}
		break;

	case 'R':
		if (touched && !confirm("Discard changes"))
		    break;
		dmsg("read (c/r = %s) ", fontname);
		if ((c = gettext(command)) != ESC) {
		    close(handle);
		    if (c != 0 && openfont(command)) {
			gotoxy(1,2);
			for (i=0; fontname[i]; i++)
			    fputc(' ',stdout);
			fflush(stdout);
			free(fontname);
			fontname = strdup(command);
			fontwin();
			gotoxy(1,2);
			dstring(fontname);
			touched=0;
		    }
		    else if (openfont(fontname)) {
			fontwin();
			touched=0;
		    }
		    else {
			dmsg("lost old font - bye!");
			fputc('\n', stdout);
			exit(1);
		    }
		}
		else
		    clearmsg();
		break;

	case 'W':
		lseek(handle, 0L, 0);
		write(handle, font, hasalt ? (2*FNTSIZE) : FNTSIZE);
		dmsg("font written");
		touched=0;
		break;

	case '!':
	    dmsg("!");
	    c = gettext(command);
	    if (c != 0 && c != ESC)
		if (system(command) >= 0) {
		    fprintf(stdout, "[more]");
		    fflush(stdout);
		    getany();
		    init();
		}
		else
		    dmsg("Cannot fork off subprocess!");
	    break;
	}
	cursor(curx, cury);
    }
}


charset(function)
int (*function)();
{
    register c;

    for (c = (hasalt?256:128); c>0; --c) {
	if (function)
	    (*function)(c-1);
	graphic(c-1);
    }
    updchar();
}


mvcur(draw, newx, newy)
{
    if (newx >= 0 && newx <= 7 && newy >= 0 && newy <= 15) {
	curx = newx;
	cury = newy;
	if (draw && pen)
	    (*pen)();
    }
    else {
	putchar(7);
	fflush(stdout);
    }
}


clearwin()
{
    dstring("\033E");
}


gettext(s)
register char *s;
{
    register c;
    register char *p = s;

    while ((c=getany()) != '\r') {
	if (c == '' || c == '') {
	    if (p > s) {
		dstring("\b \b");
		--p;
		continue;
	    }
	}
	else if (c == ESC)
	    return c;
	else if (c >= 32 && c <= '~') {
	    *p++ = c;
	    Bconout(5,c);
	    continue;
	}
	Cconout(7);
    }
    *p = 0;
    return *s;
}


openfont(name)
register char *name;
{
    register size;

    memset(font, 0, 2*FNTSIZE);
    if ((handle = open(name, O_RDWR)) < 0) {
	if (!confirm("Font %s does not exist; create it", name))
	    return 0;
	hasalt=0;
	if ((handle = open(name, O_RDWR|O_CREAT|O_EXCL, 0666)) < 0) {
	    dmsg("Cannot create %s", name);
	    return 0;
	}
    }
    else {
	size = read(handle, font, 2*FNTSIZE);
	if (size < FNTSIZE) {
	    dmsg("Cannot read font");
	    return 0;
	}
	hasalt = (size == 2*FNTSIZE);
    }
    return 1;
}


init()
{
    register i;

    phys = (char *)Physbase();
    clearwin();
    gotoxy(1,1);
    dstring(blurb);
    gotoxy(1,2);
    dstring(fontname);

    gotoxy(0,TOPY+1);
    dstring("\
 G)et a character to edit\r\n\
 Q)uit chedit\r\n\
 C)lear current char\r\n\
 A)dd a bit\r\n\
 D)elete a bit\r\n\
 X)or a bit\r\n\
\r\n\
	 y k u\r\n\
 Moving: h   l\r\n\
	 b j n\r\n\
\r\n\
	 Y K U\r\n\
 Drawing:H   L\r\n\
	 B J N\r\n\
 Colour set by A/D/X\r\n\
 [ESC] turns off pen\r\n\
");
    pen_state = (-1);
    penstate(NONE);
    
    box(0,    0,       EDITX+16, 2);	/* title bar */
    box(0,    TOPY,    EDITX-2, 16);	/* help window */
    box(EDITX,TOPY,    16,      16);	/* edit window */
    box(CHARX,CHARY+18,16,       2);	/* mode window */
    fontwin();
}


fontwin()
{
    register x, y;
    unsigned place = CHARX + (80*16*(CHARY+10));

    box(CHARX, CHARY, 16, hasalt?16:8);	/* charset display window */
    if (!hasalt) {
	for (y=0; y < (8*16); y++, place += 80)
	    for (x=0; x<18; x++)
		phys[place+x] = 0;
    }
    charset((char *)NULL);
}


penstate(state)
{
    int onbit(), offbit(), flipbit();
    char *msg;

    if (state != pen_state) {
	switch (pen_state=state) {
	default: pen = NULL;	msg = "        ";	break;
	case SET: pen = onbit;	msg = "adding  ";	break;
	case CLEAR: pen=offbit;	msg = "deleting";	break;
	case XOR: pen=flipbit;	msg = "xorring ";	break;
	}
	gotoxy(CHARX+1, CHARY+19);
	dstring(msg);
	clearmsg();
    }
}


box(x0, y0, dx, dy)
{
    static char vbar[] = {  0x18, 0x18, 0x18, 0x18,
			    0x18, 0x18, 0x18, 0x18,
			    0x18, 0x18, 0x18, 0x18,
			    0x18, 0x18, 0x18, 0x18 };
    static char hbar[] = {  0x00, 0x00, 0x00, 0x00,
			    0x00, 0x00, 0x00, 0xff,
			    0xff, 0x00, 0x00, 0x00,
			    0x00, 0x00, 0x00, 0x00 };
    static char uplc[] = {  0x00, 0x00, 0x00, 0x00,
			    0x00, 0x00, 0x00, 0x0f,
			    0x1f, 0x1c, 0x18, 0x18,
			    0x18, 0x18, 0x18, 0x18 };
    static char dnlc[] = {  0x18, 0x18, 0x18, 0x18,
			    0x18, 0x18, 0x1c, 0x1f,
			    0x0f, 0x00, 0x00, 0x00,
			    0x00, 0x00, 0x00, 0x00 };
    static char uprc[] = {  0x00, 0x00, 0x00, 0x00,
			    0x00, 0x00, 0x00, 0xf0,
			    0xf8, 0x38, 0x18, 0x18,
			    0x18, 0x18, 0x18, 0x18 };
    static char dnrc[] = {  0x18, 0x18, 0x18, 0x18,
			    0x18, 0x18, 0x38, 0xf8,
			    0xf0, 0x00, 0x00, 0x00,
			    0x00, 0x00, 0x00, 0x00 };
    register x;
    register y;

    for (x=0; x<=dx; x++) {
	blockat(x0+x, y0,      hbar);
	blockat(x0+x, y0+dy+1, hbar);
    }
    for (y=0; y<=dy; y++) {
	blockat(x0,      y0+y, vbar);
	blockat(x0+dx+1, y0+y, vbar);
    }
    blockat(x0,      y0,      uplc);
    blockat(x0,      y0+dy+1, dnlc);
    blockat(x0+dx+1, y0,      uprc);
    blockat(x0+dx+1, y0+dy+1, dnrc);
}


updchar()
{
    register y;

    for (y=0; y<16; y++)
	updcolumn(y);
    penstate(NONE);
    graphic(curch);
    updsample(curch);
}


updsample()
{
    register y;

    for (y=0; y<16; y++)
	blockat(CHARX+1+y, CHARY+20, font[curch]);
}


updcolumn(y)
{
    register x;

    for (x=0; x<8; x++)
	if (font[curch][y] & pixelmask[x])
	    dot(x,y);
	else
	    clear(x,y);
}


onbit()
{
    font[curch][cury] |= pixelmask[curx];
    updcolumn(cury);
    updsample(curch);
    graphic(curch);
    touched=1;
}


offbit()
{
    font[curch][cury] &= ~pixelmask[curx];
    updcolumn(cury);
    updsample(curch);
    graphic(curch);
    touched=1;
}


flipbit()
{
    font[curch][cury] ^= pixelmask[curx];
    updcolumn(cury);
    updsample(curch);
    graphic(curch);
    touched=1;
}


static struct _sck {
    unsigned scancode;
    unsigned value;
    unsigned shiftval;
} mappings[] = {
    {0x4b, 'h', 'H' },
    {0x50, 'j', 'J' },
    {0x4d, 'l', 'L' },
    {0x48, 'k', 'K' },
    {0x67, 'y', 'Y' },
    {0x68, 'k', 'K' },
    {0x69, 'u', 'U' },
    {0x6a, 'h', 'H' },
    {0x6c, 'l', 'L' },
    {0x6d, 'b', 'B' },
    {0x6e, 'j', 'J' },
    {0x6f, 'n', 'N' },
    {0x3b, F1,  F1  },
    {0x3c, F2,  F2  },
    {0x3d, F3,  F3  },
    {0x3e, F4,  F4  },
    {0x3f, F5,  F5  },
    {0x40, F6,  F6  },
    {0x41, F7,  F7  },
    {0x42, F8,  F8  },
    {0x43, F9,  F9  },
    {0x44, F10, F10 },
    {0x61, UNDO,UNDO},
    {0x00, 0,   0   }
} ;

getany()
{
    register long key;
    register scancode, shifted;
    register struct _sck *map;

    key = Bconin(2);
    scancode = (key>>16) & 0x7f;
    shifted  = (key>>16) & 0x0300;
    for (map=mappings; map->value; ++map)
	if (map->scancode == scancode)
	    return shifted ? (map->shiftval) : (map->value);
    return (int)key;
}


highlight(x)
register x;
{
    register idx;

    for (idx=0; idx<16; idx++)
	font[x][idx] = ~font[x][idx];
    graphic(x);
}


/*
 * get a char to edit.  You can type in anything < 128; alt-digits selects
 * an ascii number; the arrow keys will move a little cursor around to pick
 * a character to edit; c/r selects the character.
 */
getedit()
{
    long key;
    register scancode;
    register digit;
    register unsigned c;
    int toback;
    register thisch=curch;
    register limit = hasalt?256:128;

    while (1) {
	highlight(thisch);
	key = Bconin(2);
	scancode = key >> 16;
	c = key & 0xff;
	highlight(thisch);

	if (scancode >= 0x0878 && scancode <= 0x0881) {
	    toback = c = 0;
	    Bconout(5,'#');
	    do {
		digit = (scancode & 0xff) - 0x77;
		if (digit == 10)
		    digit = 0;
		c = (c*10) + digit;
		Bconout(5, digit+'0');
		toback++;
		key = Bconin(2);
		scancode = key >> 16;
	    } while (scancode >= 0x0878 && scancode <= 0x0881);
	    while (toback-->=0)
		dstring("\b \b");
	    if ((key&0x7f) != '\r')
		continue;
	}
	else { /* arrow keys, perhaps? */
	    switch (scancode & 0xff) {
	    case 0x6a:				/* keypad 4 */
	    case 0x4b:	if (thisch>0)		/* leftarrow */
			    --thisch;
			continue;
	    case 0x68:				/* keypad 8 */
	    case 0x48:	if (thisch>=16)		/* uparrow */
			    thisch -= 16;
			continue;
	    case 0x6c:				/* keypad 6 */
	    case 0x4d:	if (thisch < limit-1)	/* rightarrow */
			    ++thisch;
			continue;
	    case 0x6e:				/* keypad 2 */
	    case 0x50:	if (thisch < limit-16)	/* downarrow */
			    thisch += 16;
			continue;
	    case 0x67:	if (thisch>16)		/* keypad 7 */
			    thisch -= 17;
			continue;
	    case 0x69:	if (thisch>=16)		/* keypad 9 */
			    thisch -= 15;
			continue;
	    case 0x6d:	if (thisch < limit-16)	/* keypad 1 */
			    thisch += 15;
			continue;
	    case 0x6f:	if (thisch < limit-17)	/* keypad 3 */
			    thisch += 17;
			continue;
	    case 0x72:				/* enter */
	    case 0x1c:	c = thisch;		/* return */
			break;
	    }
	    if (c == 0)			/* don't allow funny characters */
		continue;
	}
	Bconout(5,c);
	return c;
    }
} /* getedit */


getupper()
{
    return toupper(getany());
}


clearmsg()
{
    gotoxy(0,22);
    dstring("\033K");
}


dmsg(fmt)
char *fmt;
{
    va_list ptr;

    gotoxy(0, 22);
    va_start(ptr, fmt);
    vfprintf(stdout, fmt, ptr);
    va_end(ptr);
    fflush(stdout);
    dstring("\033K");
}


confirm(fmt)
char *fmt;
{
    va_list ptr;
    register c;

    gotoxy(0, 22);
    va_start(ptr, fmt);
    vfprintf(stdout, fmt, ptr);
    va_end(ptr);
    fflush(stdout);
    dstring("?\033K");
    c = getupper();
    clearmsg();
    return (c == 'Y');
}


dstring(s)
char *s;
{
    write(fileno(stdout), s, strlen(s));
}


graphic(c)
register c;
{
    int x = c%16,
	y = c/16;

    blockat(CHARX+1+x, CHARY+1+y, font[c]);
}


dot(x,y)
{
    static char dotl[] = { 0x00, 0x00, 0x00, 0x07, 0x0f, 0x1f, 0x1f, 0x1f };
    static char dotr[] = { 0x00, 0x0 , 0x00, 0xe0, 0xf0, 0xf8, 0xf8, 0xf8 };

    unsigned place = (EDITX+1)+(x*2) + (80*16*((TOPY+1)+y));
    register i;

    for (i=0; i<8; i++, place += 80) {
	phys[place  ] = dotl[i];
	phys[place+1] = dotr[i];
    }
    for (i=7; i>=0; --i, place += 80) {
	phys[place  ] = dotl[i];
	phys[place+1] = dotr[i];
    }
}


halfdot(x,y)
{
    static char hdotl[] = { 0x00, 0x00, 0x00, 0x00, 0x03, 0x04, 0x08, 0x08 };
    static char hdotr[] = { 0x00, 0x0 , 0x00, 0x00, 0xc0, 0x20, 0x10, 0x10 };

    doublesq(x,y, hdotl, hdotr);
}


doublesq(x,y, lhs, rhs)
char *lhs, *rhs;
{
    unsigned place = (EDITX+1)+(x*2) + (80*16*((TOPY+1)+y));
    register i;

    for (i=0; i<8; i++, place += 80) {
	phys[place  ] ^= lhs[i];
	phys[place+1] ^= rhs[i];
    }
    for (i=7; i>=0; --i, place += 80) {
	phys[place  ] ^= lhs[i];
	phys[place+1] ^= rhs[i];
    }
}


shadow(c)
{
    register x, y;

    for (y=0; y<16; y++)
	for (x=0; x<8; x++)
	    if (font[c][y] & pixelmask[x])
		halfdot(x,y);
}


cursor(x,y)
{
#ifdef CROSS
    static char curl[] = { 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff };
    static char curr[] = { 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0xff };
#else
    static char curl[] = { 0xff, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 };
    static char curr[] = { 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01 };
#endif

    doublesq(x,y,curl,curr);
}


clear(x,y)
{
    unsigned place = (EDITX+1)+(x*2) + (80*16*((TOPY+1)+y));
    register i;

    for (i=0; i<16; i++, place += 80)
	phys[place] = phys[place+1] = 0;
}


blockat(x, y, mask)
char *mask;
{
    unsigned place = x + (80*16*y);
    register i;

    for (i=0; i<16; i++, place += 80)
	phys[place] = mask[i];
}


flipr(c)
unsigned c;
{
    register carry, i;

    for (i=0; i<8; i++) {
	carry = font[c][i];
	font[c][i] = font[c][15-i];
	font[c][15-i] = carry;
    }
    touched=1;
}


flipc(c)
unsigned c;
{
    register carry, i, j;

    for (i=0; i<16; i++) {
	carry = 0;
	for (j=0; j<8; j++)
	    if (font[c][i] & pixelmask[j])
		carry |= pixelmask[7-j];
	font[c][i] = carry;
    }
    touched=1;
}


invert(c)
unsigned c;
{
    register i;

    for (i=0; i<16;i++)
	font[c][i] = ~font[c][i];
    touched=1;
}


rolll(c)
{
    register carry, i;

    for (i=0; i<16;i++) {
	carry = font[c][i] & 0x80;
	font[c][i] <<= 1;
	if (carry)
	    font[c][i] |= 0x01;
    }
    touched=1;
}


rollr(c)
{
    register carry, i;

    for (i=0; i<16;i++) {
	carry = font[c][i] & 0x01;
	font[c][i] >>= 1;
	if (carry)
	    font[c][i] |= 0x80;
    }
    touched=1;
}


rollu(c)
{
    register carry, i;

    carry = font[c][0];
    for (i=1; i<16;i++)
	font[c][i-1] = font[c][i];
    font[c][15] = carry;
    touched=1;
}


rolld(c)
{
    register carry, i;

    carry = font[c][15];
    for (i=14; i>=0; --i)
	font[c][i+1] = font[c][i];
    font[c][0] = carry;
    touched=1;
}


hline(y)
{
    register place = (EDITX+1) + (80*(8+(16*(TOPY+1+y))));
    register i;

    phys[place-240]   ^= 0x80;
    phys[place-160]   ^= 0xc0;
    phys[place-80]    ^= 0xe0;
    phys[place+80]    ^= 0xe0;
    phys[place+160]   ^= 0xc0;
    phys[place+240]   ^= 0x80;
    for (i=0; i<16; i++)
	phys[place+i] ^= 0xff;
    phys[place+15-240]^= 0x01;
    phys[place+15-160]^= 0x03;
    phys[place+15-80] ^= 0x07;
    phys[place+15+80] ^= 0x07;
    phys[place+15+160]^= 0x03;
    phys[place+15+240]^= 0x01;
}


slicer()
{
    register i, c;
    register y;

    dmsg("Slice row: J,K move slice, ESC aborts, D)elete, I)insert");
    hline(y=cury);
    while ((c=getupper()) != ESC && c != 'D' && c != 'I') {
	hline(y);
	if (c == 'J' && y < 15)
	    ++y;
	else if (c == 'K' && y > 0)
	    --y;
	hline(y);
    }
    hline(y);
    switch (c) {
    case 'D':
	while (y < 15) {
	    font[curch][y] = font[curch][y+1];
	    ++y;
	}
	font[curch][15] = 0;
	updchar();
	touched=1;
	break;
    case 'I':
	for (i=14;i>=y;--i)
	    font[curch][i+1] = font[curch][i];
	updchar();
	touched=1;
	break;
    }
    clearmsg();
}


vline(x)
{
    register place = (EDITX+1+x+x) + (80*(8+(16*(TOPY+1))));
    register i;

    phys[place]       ^= 0x0f;
    phys[place+1]     ^= 0xe0;
    place += 80;
    phys[place]       ^= 0x07;
    phys[place+1]     ^= 0xc0;
    place += 80;
    phys[place]       ^= 0x03;
    phys[place+1]     ^= 0x80;
    place += 80;
    for (i=0; i<((13*16)+(2*13)); i++, place += 80)
	phys[place]   ^= 0x01;
    phys[place]       ^= 0x03;
    phys[place+1]     ^= 0x80;
    place += 80;
    phys[place]       ^= 0x07;
    phys[place+1]     ^= 0xc0;
    place += 80;
    phys[place]       ^= 0x0f;
    phys[place+1]     ^= 0xe0;
}


slicec()
{
    static unsigned char bitmask[] = { 0xff, 0x7f, 0x3f, 0x1f,
				       0x0f, 0x07, 0x03, 0x01,
				       0x00  };
    register i, c;
    register x;
    register unsigned rhs;

    dmsg("Slice column: H,L move slice, ESC aborts, D)elete, I)insert");
    vline(x=curx);
    while ((c=getupper()) != ESC && c != 'D' && c != 'I') {
	vline(x);
	if (c == 'L' && x < 7)
	    ++x;
	else if (c == 'H' && x > 0)
	    --x;
	vline(x);
    }
    vline(x);
    clearmsg();
    if (c == ESC)
	return;
    for (i=0; i<16; i++) {
	if (c == 'D') {
	    rhs = font[curch][i] & bitmask[x+1];
	    font[curch][i] &= ~bitmask[x];
	    rhs <<= 1;
	}
	else {
	    rhs = font[curch][i] & bitmask[x];
	    font[curch][i] &= ~bitmask[x+1];
	    rhs >>= 1;
	}
	font[curch][i] |= rhs;
    }
    touched=1;
    updchar();
}


visit()
{
    register i;
    register unsigned c;
    char ask;

    dmsg("Visit ");
    c = getedit();
    shadow(c);
    dmsg("O)r, X)or, N)and, A)nd, Q)uit, ESC");
    while ((ask = getupper()) != ESC && strchr("OXNAQ", ask) == 0)
	;
    clearmsg();
    if (ask != ESC)
	shadow(c);
    if (ask != ESC && ask != 'Q') {
	for (i=0; i<16; i++)
	    switch (ask) {
	    case 'O': font[curch][i] |= font[c][i];	break;
	    case 'A': font[curch][i] &= font[c][i];	break;
	    case 'X': font[curch][i] ^= font[c][i];	break;
	    case 'N': font[curch][i] &= ~font[c][i];	break;
	    }
	updchar();
	touched=1;
    }
}
