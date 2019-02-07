/************************************************************************/
/* PACKTEXT.C - Play with Text Packing using Huffman Codes		*/
/* Copyright 1986 Daniel Matejka					*/
/* 23 Aug 86 - 10:00							*/
/************************************************************************/

#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>

/* encodable ASCII codes (all 256) and size of unpack tree */
#define CODECOUNT  256
#define PTREESIZE  (CODECOUNT+10)

/* maximum size of text buffers */
#define MAXTEXT    3000

/* menu indices */
#define DESKMENU	 3
#define FILEMENU	 4
#define HUFFMENU	 5
#define WINDMENU	 6
#define PACKFILE	18
#define UNPACKFILE	19
#define SAVECODES	20
#define LOADCODES	21
#define INCLCODES	23
#define QUIT		25
#define GENERATE	27
#define PRINTCODES	28
#define FSTWINDOW	30

/* window indices */
#define WINDCNT		 3
#define TXTWIND		 0
#define INFWIND		 1
#define CDEWIND		 2

int contrl[12],
  intin[128],
  intout[128],
  ptsin[128],
  ptsout[128],		/* GEM silliness */

  schandle,		/* screen (workstation) handle */

  cellheight,
  cellwidth,		/* system character cell size */
  scrxmax,
  scrymax,		/* screen size */

  cwindtop,		/* top line of codewindow */

  menusize,		/* number of bytes in menu bar */

  window[WINDCNT],	/* window handles */
  windattrib[WINDCNT],	/* window attributes */
  windopen[WINDCNT],	/* windows open flag */
  windrect[WINDCNT][4],	/* window work area position and size */

  message[8],		/* GEM event message buffer */
  trash;

char pathname[60],	/* path and filenames from human */
  filename[60],
  *menusave;		/* safe area in which to store menu bar */

struct PSTATS {		/* some interesting packing statistics */
  long psplen,		/* length of packed text (bytes) */
    psulen,		/* length of original unpacked text */
    pspeffic,		/* packing efficiency */
    psteffic;		/* efficiency of packing table */
} packstats;

/* list of relative frequencies; default value included */
long textprobs[CODECOUNT] = {
     0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 169,   0,   0, 169,   0,
     0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
     0,   0,2095,   0,  18,   0,   0,   5,   0,  16,  25,  25,   5,   0,  83,
     2, 100,   0,  19,  22,   4,   2,   2,   4,   0,   1,   1,   0,   2,   3,
     0,   1,   0,   0,   0,  14,   2,  20,   3,  13,   7,   4,  11,  23,   0,
     3,   1,   6,   6,   7,   8,   0,   4,   9,  40,   4,   0,   3,   3,   0,
     0,   4,   0,   4,   0,   2,   0, 530, 135, 277, 276, 926, 205, 117, 323,
   538,   8,  58, 302, 140, 491, 471, 164,  14, 400, 453, 662, 205,  45, 121,
    32,  79,  10
};

/* table of Huffman Codes */
struct PACKTABLE {
  unsigned char	ptsymb,		/* unpacked character */
           	ptlen;		/* # bits used in Huffman Code */
  unsigned int	ptimage;	/* Huffman Code */
} packtable[CODECOUNT];

/* tree for unpacking Huffman Codes */
int packtree[PTREESIZE][2];

/* window text display buffer */
struct TEXTREC {
  char	*trtext,	/* beginning of text */
	**trlines;	/* line starts */
  int	trtopline,	/* line number at top of window */
	trlcount,	/* # of lines in text */
	trwindow;	/* window index */
} otext;		/* unpacked text */

/************************************************************************/
/**************************** The Resources *****************************/
/************************************************************************/

char *wmenustr[] = {
  "  Open Text Window",
  "  Open Pack Data Window",
  "  Open Code Window",
  "  Close Text Window",
  "  Close Pack Data Window",
  "  Close Code Window"
};

/********** (the menu) **********/
OBJECT menudata[] = {
-1,1,7,G_IBOX,NONE,NORMAL,0x0L,			0,0,45,0x309,
  7,2,2,G_BOX,NONE,NORMAL,0x1100L,		0,0,30,0x201,
    1,3,6,G_IBOX,NONE,NORMAL,0x0L,		2,0,28,0x301,
      4,-1,-1,G_TITLE,NONE,NORMAL," Desk ",		 0,0,6,0x301,
      5,-1,-1,G_TITLE,NONE,NORMAL," File ",		 6,0,6,0x301,
      6,-1,-1,G_TITLE,NONE,NORMAL," Codes ",		12,0,7,0x301,
    2,-1,-1,G_TITLE,NONE,NORMAL," Windows ",		19,0,9,0x301,
  0,8,29,G_IBOX,NONE,NORMAL,0x0L,		0,0x301,45,8,
    17,9,16, G_BOX,NONE,NORMAL,0xFF1100L,	2,0,20,8,
      10,-1,-1,G_STRING,NONE,NORMAL,"  About PackText",		0,0,20,1,
      11,-1,-1,G_STRING,NONE,DISABLED,"--------------------",	0,1,20,1,
      12,-1,-1,G_STRING,NONE,NORMAL,"",				0,2,20,1,
      13,-1,-1,G_STRING,NONE,NORMAL,"",				0,3,20,1,
      14,-1,-1,G_STRING,NONE,NORMAL,"",				0,4,20,1,
      15,-1,-1,G_STRING,NONE,NORMAL,"",				0,5,20,1,
      16,-1,-1,G_STRING,NONE,NORMAL,"",				0,6,20,1,
       8,-1,-1,G_STRING,NONE,NORMAL,"",				0,7,20,1,
   26,18,25,G_BOX,NONE,NORMAL,0xFF1100L,	6,0,25,8,
      19,-1,-1,G_STRING,NONE,NORMAL,"  Pack a File",		0,0,25,1,
      20,-1,-1,G_STRING,NONE,NORMAL,"  Unpack a File",		0,1,25,1,
      21,-1,-1,G_STRING,NONE,NORMAL,"  Save Huffman Codes",	0,2,25,1,
      22,-1,-1,G_STRING,NONE,NORMAL,"  Load Huffman Codes",	0,3,25,1,
      23,-1,-1,G_STRING,NONE,DISABLED,"-------------------------",0,4,25,1,
      24,-1,-1,G_STRING,NONE,CHECKED,"  Include Codes in File",	0,5,25,1,
      25,-1,-1,G_STRING,NONE,DISABLED,"-------------------------",0,6,25,1,
      17,-1,-1,G_STRING,NONE,NORMAL,"  Quit",			0,7,25,1,
   29,27,28,G_BOX,NONE,NORMAL,0xFF1100L,	12,0,26,2,
      28,-1,-1,G_STRING,NONE,NORMAL,"  Generate Huffman Codes",	0,0,26,1,
      26,-1,-1,G_STRING,NONE,NORMAL,"  Print Huffman Codes",	0,1,26,1,
   7,30,32,G_BOX,NONE,NORMAL,0xFF1100L,		19,0,26,3,
      31,-1,-1,G_STRING,NONE,NORMAL,"",				0,0,26,1,
      32,-1,-1,G_STRING,NONE,NORMAL,"",				0,1,26,1,
      29,-1,-1,G_STRING,LASTOB,NORMAL,"",			0,2,26,1
};

/* "About" dialog box */
OBJECT glorybox[] = {
-1,1,5,G_BOX,NONE,OUTLINED,0x22100L,0,0,35,10,
  2,-1,-1,G_STRING,NONE,NORMAL,  "PackText uses Huffman Codes",4,2,29,1,
  3,-1,-1,G_STRING,NONE,NORMAL,"to compress and decompress",2,3,31,1,
  4,-1,-1,G_STRING,NONE,NORMAL,"text files.",2,4,31,1,
  5,-1,-1,G_STRING,NONE,NORMAL,"Copyright 1986 Daniel Matejka",2,6,31,1,
  0,-1,-1,G_BUTTON,LASTOB|EXIT|DEFAULT|SELECTABLE,NORMAL,"OK",15,8,6,1,
};

/* object list for coordinate fix */
OBJECT *oblist[] = { menudata,glorybox,0 };

/************************************************************************/
/****************************** Miscellany ******************************/
/************************************************************************/

/********** copy one string into another **********/
strcpy(dest,source)
  register char *dest,*source; {

  while (*dest++ = *source++);
} /* end strcpy */

/********** concatenate two strings **********/
strconc(dest,appendage)
  register char *dest,*appendage; {

  while (*dest++);
  dest--;
  while (*dest++ = *appendage++);
} /* end strconc */

/********** move memory around **********/
movmem(s,d,c)
  register char *s,*d;
  register int c; {

  if (s > d)
    while (c-- > 0)
      *d++ = *s++;
  else {
    d += c;
    s += c;
    while (c-- > 0)
      *--d = *--s;
  }
} /* end movmem */

/********** initialize memory **********/
setmem(d,c,v)
  register char *d;
  register int c,v; {

  while (c-- > 0)
    *d++ = v;
} /* end setmem */

/********** concatenate a string and a longint **********/
longconc(s,it,decimal,digits,zeroes)
  char	*s;		/* string on which to append the longint */
  long	it;		/* the longint */
  int	decimal,	/* # of digits to right of decimal pt for display */
	digits,		/* # of spaces in which to display the longint */
	zeroes; {	/* pack on left with zeroes? */
  /* Note if (digits == 0), use as many digits as necessary (left justify) */

  int	sign;
  char	sbuf[14],
	*slider;

  if (sign = it < 0)			/* make it positive */
    it *= -1;
  zeroes = zeroes ? '0' : ' ';		/* left padding character */
  if (decimal > 0 && digits > 0)
    digits++;
  if (digits)
    slider = sbuf+digits;
  else
    slider = sbuf+12;			/* largest possible, fix later */
  *slider = 0;

  /* turn longint into a string */
  do {
    *--slider = (it - 10*(it/10)) + '0'; /* long mod doesn't work */
    if (--decimal == 0)
      *--slider = '.';
    it /= 10;
  } while (it > 0 && slider > sbuf);

  /* add sign */
  if (sign && slider > sbuf)
    *--slider = '-';

  /* add decimal point */
  if (decimal > 0) {
    while (--decimal >= 0 && slider > sbuf)
      *--slider = '0';
    if (slider > sbuf)
      *--slider = '.';
  }

  /* justify, right or left as requested */
  if (digits)
    while (slider > sbuf)
      *--slider = zeroes;
  else {
    digits = 12 - (slider-sbuf);
    movmem(slider,sbuf,1 + digits);
  }

  strconc(s,sbuf);
} /* end longconc */


/************************************************************************/
/********************* Text Buffer Display Routines *********************/
/************************************************************************/

/********** initialize text buffer **********/
int tenew(text,windx)
  struct TEXTREC *text;
  int windx; {

  int ctr;

  text->trtext = Malloc((long) MAXTEXT);
  text->trtopline = 0;
  text->trlcount = 0;
  text->trwindow = windx;
  text->trlines = Malloc( (long) (MAXTEXT/2 * sizeof(char *)) );

  /* if any allocations failed, reverse whatever was done and return 0 */
  if (text->trtext == 0 || text->trlines == 0) {
    if (text->trtext != 0)
      Mfree(text->trtext);
    if (text->trlines != 0)
      Mfree(text->trlines);
    return 0;
  }
  for (ctr = 0; ctr < MAXTEXT/2; ctr++)
    text->trlines[ctr] = text->trtext;

  return 1;
} /* end tenew */

/********** find width of character cell (proportional font?) **********/
static int charwidth(it)
  int it; {

  int width;

  vqt_width(schandle,it,&width,&trash,&trash);
  return width;
} /* end charwidth */

/********** find a real line end **********/
static char *lineadjust(linebeg,teptr)
  char *linebeg,*teptr; {

  char  *pushpos;

  pushpos = teptr;

  /* find last blank on line currently ending at teptr */
  while (*teptr != ' ' && teptr > linebeg)
    teptr--;

  if (teptr == linebeg) /* none such */
    return pushpos;

  /* find last non-blank character on line */
  pushpos = teptr+1; /* first character after last blank */
  while (*teptr == ' ' && teptr > linebeg)
    teptr--;

  /* return 1st char after last blank, or last non-blank + spacer */
  teptr += (*teptr == '.') ? 3 : 2;
  return (teptr > pushpos) ? pushpos : teptr;
} /* end lineadjust */

/********** calculate line starts **********/
tecalc(text)
  struct TEXTREC *text; {

  register char
    *teptr,		/* text array pointer */
    *teend;		/* end of text */
  char *tlinestart = text->trlines[text->trtopline];
  register int
    line,		/* line counter */
    linewidth;		/* width as it is built */
  int width,		/* character width variable (proportional font?) */
    windwidth = windrect[text->trwindow][2];

  /* start scanning at text beginning, with 0 lines */
  line = 0;
  text->trlines[0] = text->trtext;
  teptr = text->trtext;
  teend = text->trlines[text->trlcount];

  while (teptr < teend) {  /* while scanner is within text buffer */

    /* count character widths until end of window is reached */
    for (linewidth = 0;
      linewidth <= windwidth && *teptr != '\n' && teptr < teend;
      linewidth += charwidth(*teptr++));

    /* if end of window or '\n', a new line begins somewhere close */
    if (linewidth > windwidth || (*teptr == '\n' && teptr < teend)) {
      if (*teptr == '\n')
        teptr++;
      else
        teptr = lineadjust(text->trlines[line],teptr-1);
      text->trlines[++line] = teptr;
    }
  } /* end while */

  /* adjust other variables that need adjusting */
  text->trlcount = ++line;
  text->trlines[line] = teend;

  /* reset trtopline */
  for (line = text->trlcount; text->trlines[line] > tlinestart; line--);
  text->trtopline = line;

  setsliders(text->trwindow,1,1);
} /* end tecalc */

/********** display text buffer **********/
teupdate(text)
  struct TEXTREC *text; {

  int	line,		/* line index */
	lastline,	/* last displayable text line */
	linelen,	/* length of each line */
	x,y;		/* beginning position of each line */
  char	dspline[80],
	*seek;

  clrwindow(text->trwindow);
  v_hide_c(schandle);

  x = windrect[text->trwindow][0];
  y = windrect[text->trwindow][1];
  lastline = text->trtopline + windrect[text->trwindow][3]/cellheight;
  lastline = lastline > text->trlcount ? text->trlcount : lastline;

  for (line = text->trtopline; line < lastline; line++) {  /* for each line */

    /* copy line into display buffer */
    linelen = text->trlines[line+1] - text->trlines[line];
    movmem(text->trlines[line],dspline,linelen);

    /* search for first printable character at end, omitting spaces */
    seek = dspline + linelen;
    while (--seek > dspline && *seek <= ' ');
    if (*seek > ' ')
      seek++;
    *seek = 0;

    /* and print it */
    y += cellheight;
    v_gtext(schandle,x,y,dspline);
  }

  v_show_c(schandle,1);
} /* end teupdate */


/************************************************************************/
/************************ Huffman Code Analyzers ************************/
/************************************************************************/

/********** Assign initial code lengths from frequency distribution **********/
static makeclens() {

  long divider;
  int ctr,curlen;

  divider = 5000;				/* == 0.5, or length 1 */
  curlen = 1;					/* length 1 */
  for (ctr = 0; ctr < CODECOUNT; ctr++) {	/* for each ASCII symbol */
    while (textprobs[ctr] < divider) {		/* calculate a good... */
      divider /= 2;
      curlen++;					/* code length */
    }
    packtable[ctr].ptlen = curlen;		/* and assign it */
  }
} /* end makeclens */

/********** assign Huffman Codes from code length array **********/
static int assigncodes(start)
  int start; {

  int	ctr,
	dlength,	/* change in code length between consecutive codes */
	traitor;	/* index of first code which doesn't work */

  /* following algorithms assume start > 0, so take care of start == 0 */
  if (start <= 0) {
    packtable[0].ptimage = 0;
    start = 1;
  }

  /* each code is preceding code + 1, with zeroes tacked on as necessary */
  for (ctr = start; ctr < CODECOUNT; ctr++) {
    packtable[ctr].ptimage = packtable[ctr-1].ptimage + 1;
    dlength = packtable[ctr].ptlen - packtable[ctr-1].ptlen;
    packtable[ctr].ptimage <<= dlength;
  }

  /* find index to first code which doesn't work */
  for (traitor = -1, ctr = start; ctr < CODECOUNT; ctr++)
    if (packtable[ctr].ptimage >= (1 << packtable[ctr].ptlen)) {
      traitor = ctr;
      break;
    }

  return traitor;
} /* end assigncodes */

/********** calculate unpacktree from Huffman Code table **********/
maketree() {

  int	ctr,
	bumppt,		/* index of lengths currently being tweaked */
	nextpt,		/* next point while traversing packtree */
	branch,		/* branch to take while traversing packtree */
	mask;		/* for traversing Huffman code */

  /* initialize tree */
  for (ctr = 0; ctr < PTREESIZE; ctr++) {
    packtree[ctr][0] = -CODECOUNT;
    packtree[ctr][1] = -CODECOUNT;
  }

  for (bumppt = 0, ctr = 0; ctr < CODECOUNT && bumppt < PTREESIZE-1;
    ctr++) {  /* for each code */

    /* for each bit in code (save the last one), traverse the tree */
    for (nextpt = 0, mask = 1 << (packtable[ctr].ptlen - 1);
        mask > 1; mask >>= 1) {

      /* if branch is illegal value, insert new value */
      branch = (packtable[ctr].ptimage & mask) != 0;
      if (packtree[nextpt][branch] <= -CODECOUNT)
        packtree[nextpt][branch] = ++bumppt;
      nextpt = packtree[nextpt][branch];
    }

    /* for last bit, enter the unpacked symbol */
    branch = (packtable[ctr].ptimage & 1) != 0;
    packtree[nextpt][branch] = packtable[ctr].ptsymb;
    packtree[nextpt][branch] *= -1;
  }
  if (bumppt >= PTREESIZE)
    form_alert(1,
  "[3][Unpacktree overflowed.|Don't attempt to unpack|anything.][Not OK]");
} /* end maketree */

/********** assign Huffman codes from frequency distribution **********/
huffmans() {

  int	ctr,
	bumppt;		/* index of lengths currently being tweaked */

  /* find a set of Huffman Codes which do indeed work */
  makeclens();		/* initial approximation at code lengths */
  bumppt = 0;
  while ((bumppt = assigncodes(bumppt)) >= 0) {	/* if doesn't work, */
    packtable[bumppt].ptlen++;			/* increment length */
    for (ctr = bumppt+1; ctr < CODECOUNT; ctr++)
      if (packtable[ctr].ptlen < packtable[ctr-1].ptlen)
        packtable[ctr].ptlen = packtable[ctr-1].ptlen;
  }

  /* fine tune it */
  bumppt = 0;
  do { /* attempt to drop length of every code, from the beginning */
    do { /* drop value of lengths[bumppt] until it no longer works */
      packtable[bumppt].ptlen--;
    } while (packtable[bumppt].ptlen > 0 &&
        (bumppt == 0 ||
          packtable[bumppt].ptlen >= packtable[bumppt-1].ptlen) &&
        assigncodes(bumppt) < 0);

    /* restore last length (which did work), then try next one */
    packtable[bumppt].ptlen++;
    assigncodes(bumppt);
  } while (++bumppt < CODECOUNT);

  /* codelengths now OK; assign final codes */
  assigncodes(0);

  /* make the unpack tree */
  maketree();

  /* calculate table efficiency parameter */
  for (packstats.psteffic = 0, ctr = 0; ctr < CODECOUNT; ctr++)
    packstats.psteffic += packtable[ctr].ptlen * textprobs[ctr];
  packstats.psteffic /= 8;
} /* end huffmans */

/********** sort a FREQSTRUCT and PACKTABLE by frequency **********/
sortptable() {

  int	ctr,
	seek;
  long	tfreq;			/* temporary frequency variable for swapping */
  struct PACKTABLE tptable;	/* same for PACKTABLE entry */

  for (ctr = 1; ctr < CODECOUNT; ctr++) {  /* for each code past first, */

    /* find where it goes in the previous sorted part of the array */
    for (seek = 0; seek < ctr && textprobs[seek] >= textprobs[ctr];
      seek++);

    /* and put it there */
    if (seek < ctr) {
      tfreq = textprobs[ctr];
      movmem(&textprobs[seek],&textprobs[seek+1],
        sizeof(long) * (ctr-seek));
      textprobs[seek] = tfreq;
      movmem(&packtable[ctr],&tptable,sizeof(struct PACKTABLE));
      movmem(&packtable[seek],&packtable[seek+1],
        sizeof(struct PACKTABLE) * (ctr-seek));
      movmem(&tptable,&packtable[seek],sizeof(struct PACKTABLE));
    }
  }
} /* end sortptable */

/********** do the real work of loadfreqs() **********/
int maketables(fhandle,flength,fbuffer)
  int fhandle;			/* file handle */
  long flength;			/* length of file */
  unsigned char *fbuffer; {	/* read buffer, length is assumed MAXTEXT */

  register unsigned char
  	*fbufend,		/* working end of fbuffer */
	*fbufscan;		/* scanner down length of fbuffer */
  int	ctr,
  	done;			/* successful table creation? */
  long	iolength,		/* length of each read operation */
  	charcount;		/* count of packable characters */

  /* initialize frequency table */
  for (ctr = 0; ctr < CODECOUNT; ctr++) {
    packtable[ctr].ptsymb = ctr;
    textprobs[ctr] = 0L;
  }
  charcount = 0;
  done = 1;

  /* read file, count occurrences of each ASCII symbol */
  Fseek(0L,fhandle,0);
  while (flength > 0) {
    iolength = flength > MAXTEXT ? MAXTEXT : flength;
    flength -= iolength;
    if (iolength != Fread(fhandle,iolength,fbuffer)) {
      done = 0;
      form_alert(1,"[3][Read error][Abort]");
      break;
    }
    fbufend = fbuffer + iolength;
    for (fbufscan = fbuffer; fbufscan < fbufend; fbufscan++) {
      if (*fbufscan < CODECOUNT) {
        textprobs[*fbufscan] += 10000L;
        charcount++;
      } else {
        done = 0;
	form_alert(1,"[3][File contains characters|not allowed in tables][Abort]");	
	break;
      }
    }
  } /* end while (flength) */
  Fseek(0L,fhandle,0);

  /* normalize */
  for (ctr = 0; ctr < CODECOUNT; ctr++)
    textprobs[ctr] /= charcount;

  if (done) { /* if successfully loaded frequency table, finish the job */
    sortptable();
    huffmans();
  }

  return done;
} /* end maketables */

/********** construct a frequency distribution table **********/
int loadfreqs() {

  int	fhandle,	/* file handle */
	done;
  char	*fbuffer;	/* file input buffer */
  long	flength;	/* total file length */

  if (!getfname(pathname,filename,"Select File to be Analyzed"))
    return 0;
  if ((fhandle = Fopen(filename,0)) < 0) {
    form_alert(1,"[3][Can't find that file.][ OK ]");
    return 0;
  }
  fbuffer = Malloc((long) MAXTEXT);
  if (fbuffer == 0) {
    form_alert(1,"[3][No memory free!][ Ack ]");
    Fclose(fhandle);
    return 0;
  }

  flength = Fseek(0L,fhandle,2);
  done = maketables(fhandle,flength,fbuffer);

  Mfree(fbuffer);
  Fclose(fhandle);

  return done;
} /* end loadfreqs */

/********** save Huffman Code table **********/
savecodes() {

  int	fhandle;	/* file handle */

  if (!getfname(pathname,filename,"Select File In Which to Save Codes"))
    return;
  if ((fhandle = Fopen(filename,0)) >= 0) {
    Fclose(fhandle);
    if (2 == form_alert(1,
      "[2][That file already exists][Overwrite|Stop]"))
      return;
  }
  if ((fhandle = Fcreate(filename,0)) < 0) {
    form_alert(1,"[3][Can't create that file][ Abort ]");
    return;
  }

  if (Fwrite(fhandle,(long) sizeof(packtable),packtable)
    != sizeof(packtable))

    form_alert(1,"[3][Write error][Abort]");
  else
    form_alert(1,"[1][Code table written][ OK ]");

  Fclose(fhandle);
} /* end savecodes */

/********** read Huffman Code table **********/
int loadcodes() {

  int	ctr,
	fhandle;	/* file handle */

  if (!getfname(pathname,filename,"Select File From Which to Load Codes"))
    return;
  if ((fhandle = Fopen(filename,0)) < 0) {
    form_alert(1,"[3][Can't open that file][ Abort ]");
    return;
  }

  if (Fread(fhandle,(long) sizeof(packtable),packtable)
    != sizeof(packtable)) {

    form_alert(1,"[3][Read error:|Code tables are damaged.][Abort]");
    return;
  }

  Fclose(fhandle);

  /* finish making Huffman Codes, adjust textprobs[] array and statistics */
  maketree();
  for (ctr = 0; ctr < CODECOUNT; ctr++)
    textprobs[ctr] = 10000L/CODECOUNT;
  for (packstats.psteffic = 0, ctr = 0; ctr < CODECOUNT; ctr++)
    packstats.psteffic += packtable[ctr].ptlen;
  packstats.psteffic *= 1250;  /* (effic*10000/8) */
} /* end loadcodes */

/********** make a string for printing an entry of the code table **********/
makecstring(str,indx,toscreen)
  char *str;
  int indx,toscreen; {

  int	bit,
	symbol = packtable[indx].ptsymb,
	whitespace = toscreen ? 4 : 9;
  char	blanks[20];

  blanks[whitespace] = 0;
  setmem(blanks,whitespace,' ');
  strcpy(str,blanks);

  if (toscreen)
    if (symbol == 0)
      strconc(str,"Null");
    else {
      strconc(str,"    ");
      str[whitespace+2] = symbol;
    }
  else
    if (symbol >= ' ' && symbol <= '~') {
      strconc(str,"        ");
      str[whitespace+5] = symbol;
    } else {
      strconc(str,"chr(");
      longconc(str,(long) symbol,0,3,0);
      strconc(str,")");
    }

  /* print frequency of occurrence, code length */
  strconc(str,blanks);
  longconc(str,textprobs[indx],4,5,0);
  strconc(str,blanks);
  longconc(str,(long) packtable[indx].ptlen,0,2,0);

  /* print code */
  strconc(str,"/");
  for (bit = 15; bit >= 0; bit--)
    if (packtable[indx].ptimage & (1 << bit))
      strconc(str,"1");
    else if (bit < packtable[indx].ptlen)
      strconc(str,"0");
    else
      strconc(str," ");
} /* end makecstring */

/********** put a string on the printer **********/
printstr(str)
  char *str; {

  char	*scan;

  for (scan = str; *scan; scan++)
    Cprnout(*scan);
  Cprnout('\r');
  Cprnout('\n');
} /* end printstr */

/********** print Huffman Code table **********/
printcodes() {

  int	ctr,
	line;
  char	msg[80];

  /* get the printer turned on */
  do {
    evnt_timer(50,0);
    if (!(ctr = Cprnos()) && 2 == form_alert(1,
      "[1][Please turn on|the printer][ OK | Abort ]"))
    return;
  } while (!ctr);

  /* print each line of the code table */
  for (ctr = 0, line = 54; ctr < CODECOUNT; ctr++, line++) {
    if (line >= 54) {  /* paginate at line 54 */
      printstr("          Char          Frequency        Length/Code\n");
      line = 2;
    }
    makecstring(msg,ctr,0);
    printstr(msg);
    if (line == 53)
      Cprnout('\f');
  }

  strcpy(msg,"\nEfficiency rating ");
  longconc(msg,packstats.psteffic,4,0,0);
  printstr(msg);
} /* end printcodes */


/************************************************************************/
/********************* Packing and Unpacking Routines *******************/
/************************************************************************/

/********** prepare to read and write some files **********/
int openfiles(ihandle,ohandle,ibuffer,obuffer)
  int *ihandle,*ohandle;
  char **ibuffer,**obuffer; {

  /* open an input file */
  if (!getfname(pathname,filename,"Select Input File"))
    return 0;
  if ((*ihandle = Fopen(filename,0)) < 0) {
    form_alert(1,"[3][Can't find that file][ Abort ]");
    return 0;
  }

  /* open an output file */
  if (!getfname(pathname,filename,"Select Output File"))
    return 0;
  if ((*ohandle = Fopen(filename,0)) >= 0) {
    Fclose(*ohandle);
    if (2 == form_alert(1,
      "[2][That file already exists][Overwrite|Stop]")) {
      Fclose(*ihandle);
      return 0;
    }
  }
  if ((*ohandle = Fcreate(filename,0)) < 0) {
    form_alert(1,"[3][Can't create that file][ Abort ]");
    Fclose(*ihandle);
    return 0;
  }

  /* allocate input and output buffers, length MAXTEXT */
  *ibuffer = Malloc((long) MAXTEXT);
  *obuffer = Malloc((long) MAXTEXT);
  if (*ibuffer == 0 || *obuffer == 0) {
    if (*obuffer != 0)
      Mfree(*obuffer);
    if (*ibuffer != 0)
      Mfree(*ibuffer);
    form_alert(1,"[3][No memory for packing!][ Abort ]");
    Fclose(*ohandle);
    Fclose(*ihandle);
    return 0;
  }

  return 1;
} /* end openfiles */

/********** reverse openfiles **********/
closefiles(ihandle,ohandle,ibuffer,obuffer)
  int ihandle,ohandle;
  char *ibuffer,*obuffer; {

  Mfree(obuffer);
  Mfree(ibuffer);
  Fclose(ohandle);
  Fclose(ihandle);
} /* end closefiles */

/********** pack a file **********/
packtext() {

  unsigned register int
	row,		/* row of codes corresponding to char being packed */
	pmask,		/* mask for selecting individual bits of pack stream */
	imagemask;	/* mask for selecting the image bit in question */
  register unsigned char
	*pscan,		/* grosser, 8-bit version of pmask */
	*pend,		/* end of pack buffer */
	*uscan,		/* unpacked characters */
	*uend;		/* end of unpack buffer */
  unsigned char
	*ubuffer,	/* memory buffer from unpacked file */
	*pbuffer;	/* memory buffer into which packed file is built */
  int	ihandle,	/* input file handle */
	ohandle,	/* output file handle */
	ioerror,	/* did an i/o error occur? */
	firstread,	/* first read operation */
	writetable = (menudata[INCLCODES].ob_state & CHECKED) != 0;
  long	ilength,	/* input file length */
	iolength,	/* i/o operation length */
	olenpos,	/* position in output file of character count */
	packlen;	/* output file character count */

  /* get file handles and allocate i/o buffers */
  if (!openfiles(&ihandle,&ohandle,&ubuffer,&pbuffer))
    return;

  /*  initialize error flag, first i/o operation flag, statistics
    and file length variables (packstats.psulen set later) */
  packstats.psplen = 0;
  ioerror = 0;
  firstread = windopen[TXTWIND];  /* don't update window if not open */
  ilength = Fseek(0L,ihandle,2);
  Fseek(0L,ihandle,0);

  if (writetable && !maketables(ihandle,ilength,ubuffer)) {
    closefiles(ihandle,ohandle,ubuffer,pbuffer);
    return;
  }

  /* write packtable if requested */
  if (Fwrite(ohandle,(long) sizeof(int),&writetable) == sizeof(int)) {
    if (writetable && Fwrite(ohandle,(long) sizeof(packtable),packtable) !=
      sizeof(packtable))

      ioerror = 2;
  } else
    ioerror = 2;

  /* remember where file length field goes and make space for it */
  olenpos = Fseek(0L,ohandle,1);
  if (!ioerror &&
    Fwrite(ohandle,(long) sizeof(long),&packlen) != sizeof(long))

    ioerror = 2;

  /* read entire input file */
  for (packlen = 0, *(pscan=pbuffer) = 0, pend = pbuffer + MAXTEXT,
      pmask = 0x80, uscan = uend = ubuffer, packstats.psulen = 0;
    !ioerror && (ilength > 0 || uscan < uend);
    packstats.psulen++, uscan++) {

    /* if input buffer entirely processed, refill it */
    if (uscan >= uend) {
      iolength = ilength > MAXTEXT ? MAXTEXT : ilength;
      ilength -= iolength;
      if (Fread(ihandle,iolength,ubuffer) != iolength)
        ioerror = 1;
      uscan = ubuffer;
      uend = ubuffer + iolength;

      if (firstread) {  /* save file beginning for display */
        firstread = 0;
        movmem(ubuffer,otext.trtext,(int) iolength);
        otext.trlcount = 1;
        otext.trlines[1] = otext.trtext + iolength;
        otext.trtopline = 0;
        tecalc(&otext);
      }
    }

    /* find out which row of Huffman Code Table applies */
    for (row = 0; row < CODECOUNT && *uscan != packtable[row].ptsymb;
      row++);

    if (row < CODECOUNT) {  /* if packable character */
      packlen++;

      /* accessing each bit of packimage in order... */
      for (imagemask = 1 << (packtable[row].ptlen - 1);
        imagemask > 0;
        imagemask >>= 1) {

        /* add that bit of packimage to end of packstream */
        if (packtable[row].ptimage & imagemask)
          *pscan |= pmask;

        /* go to next bit of packstream */
        pmask >>= 1;
        if (pmask == 0) {  /* then go to next byte */
          packstats.psplen++;
          pmask = 0x80;
          if (++pscan >= pend) {  /* then flush buffer */
            if (Fwrite(ohandle,pscan-pbuffer,pbuffer) !=
              pscan-pbuffer)
              ioerror = 2;

            pscan = pbuffer;
          }
          *pscan = 0;
        }
      } /* end for (imagemask...) */
    } /* end if (row) */
  } /* end for (packlen...) */

  /* some buffer remains unflushed... */
  iolength = pscan - pbuffer;
  if (pmask != 0x80)
    iolength++;
  if (!ioerror && iolength > 0)
    if (Fwrite(ohandle,iolength,pbuffer) != iolength)
      ioerror = 2;

  /* write number of characters stored in file at beginning */
  Fseek(olenpos,ohandle,0);
  if (!ioerror &&
    Fwrite(ohandle,(long) sizeof(long),&packlen) != sizeof(long))
    ioerror = 2;

  if (ioerror == 1)
    form_alert(1,"[3][Read error][Abort]");
  else if (ioerror == 2)
    form_alert(1,"[3][Write error][Abort]");

  /* close files, deallocate i/o buffers */
  closefiles(ihandle,ohandle,ubuffer,pbuffer);

  /* keep interesting statistics */
  packstats.pspeffic = (10000*packstats.psplen)/packstats.psulen;
} /* end packtext */

/********** unpack a file **********/
unpacktext() {

  register unsigned int
	pmask;		/* mask for selecting individual bits of packstream */
  register int
	utindex;	/* traverses unpack tree */
  unsigned register char
	*pscan,		/* grosser, 8-bit version of pmask */
	*pend,		/* end of pack buffer */
	*uscan,		/* unpacked character pointer */
	*uend;		/* end of unpack buffer */
  unsigned char
	*pbuffer,	/* memory buffer from packed file */
	*ubuffer;	/* buffer for unpack file */
  int	ihandle,	/* input file handle */
	ohandle,	/* output file handle */
	firstwrite,	/* first write operation */
	ioerror,	/* did an i/o error occur? */
	readtable,	/* read code table from file? */
	temp;
  long	ilength,	/* input file length */
	iolength,	/* i/o operation length */
	packlen;	/* input file character count */

  /* get file handles and allocate i/o buffers */
  if (!openfiles(&ihandle,&ohandle,&pbuffer,&ubuffer))
    return;

  /*	initialize error flag, first i/o operation flag, statistics
	and file length variables (packstats.psulen set later) */
  packstats.psplen = 0;
  ioerror = 0;
  firstwrite = windopen[TXTWIND];
  ilength = Fseek(0L,ihandle,2);
  Fseek(0L,ihandle,0);

  /* read packtable if requested */
  readtable = (menudata[INCLCODES].ob_state & CHECKED) != 0;
  if (Fread(ihandle,(long) sizeof(int),&temp) == sizeof(int)) {
    if (temp != readtable) {
      readtable = temp;
      menu_icheck(menudata,INCLCODES,readtable);
      form_alert(1,"[1][Include tables flag|value changed.][ OK ]");
    }
  } else
    ioerror = 1;
  if (readtable && !ioerror)
    if (Fread(ihandle,(long) sizeof(packtable),packtable) == 
      sizeof(packtable)) {

      maketree();
      for (temp = 0; temp < CODECOUNT; temp++)
        textprobs[temp] = 10000L/CODECOUNT;
      for (packstats.psteffic = 0, temp = 0; temp < CODECOUNT; temp++)
        packstats.psteffic += packtable[temp].ptlen;
      packstats.psteffic *= 1250;  /* (effic*10000/8) */
    } else
      ioerror = 1;

  /* read number of characters stored in file */
  if (Fread(ihandle,(long) sizeof(long),&packlen) != sizeof(long))
    ioerror = 1;

  /* adjust ilength from total file size to remaining file size */
  ilength -= Fseek(0L,ihandle,1);

  /* read entire input file */
  for (pscan = pend = pbuffer, pmask = 0x0, packstats.psulen = 0,
      uscan = ubuffer, uend = ubuffer + MAXTEXT;
    !ioerror && packlen > 0;
    packlen--, packstats.psulen++) {

    /* decode character */
    utindex = 0;
    do { /* bounce around in packtree[][] until terminal node found */
      if (pmask == 0) {  /* go to next byte of packed buffer */
        pmask = 0x80;
        packstats.psplen++;
        if (++pscan >= pend) { /* buffer end found: read more */
          iolength = ilength > MAXTEXT ? MAXTEXT : ilength;
          ilength -= iolength;
          if (Fread(ihandle,iolength,pbuffer) != iolength)
            ioerror = 1;
          pscan = pbuffer;
          pend = pbuffer + iolength;
        }
      }
      utindex = packtree[utindex][(*pscan & pmask) != 0];
      pmask >>= 1;  /* go to next bit of packstream */
    } while (utindex > 0);	/* nonpositive utindex flags terminal node */

    *uscan++ = -1 * utindex;	/* save unpacked character in buffer */
    if (uscan >= uend) {	/* output buffer filled: flush it */
      iolength = uscan-ubuffer;
      if (firstwrite) {		/* save first one for public display */
        firstwrite = 0;
        movmem(ubuffer,otext.trtext,(int) iolength);
        otext.trlcount = 1;
        otext.trlines[1] = otext.trtext + iolength;
        otext.trtopline = 0;
        tecalc(&otext);
      }
      if (Fwrite(ohandle,iolength,ubuffer) != iolength)
        ioerror = 2;
      uscan = ubuffer;
    }
  } /* end for (packlen...) */

  /* input file processed, data remaining in output buffer */
  iolength = uscan - ubuffer;
  if (!ioerror && iolength > 0) {
    if (firstwrite) {  /* if first write, save for public display */
      firstwrite = 0;
      movmem(ubuffer,otext.trtext,(int) iolength);
      otext.trlcount = 1;
      otext.trlines[1] = otext.trtext + iolength;
      otext.trtopline = 0;
      tecalc(&otext);
    }
    if (Fwrite(ohandle,iolength,ubuffer) != iolength)
      ioerror = 2;
  }

  if (ioerror == 1)
    form_alert(1,"[3][Read error][Abort]");
  else if (ioerror == 2)
    form_alert(1,"[3][Write error][Abort]");

  /* close files, deallocate i/o buffers */
  closefiles(ihandle,ohandle,pbuffer,ubuffer);

  /* keep interesting statistics */
  packstats.pspeffic = (10000*packstats.psplen)/packstats.psulen;
} /* end unpacktext */


/************************************************************************/
/************************** Windowing Routines **************************/
/************************************************************************/

/********** turn a GEM window handle into its PACKTEXT index **********/
int getwindx(whandle)
  int whandle; {

  int ctr;

  for (ctr = 0; ctr < WINDCNT && window[ctr] != whandle; ctr++);
  return ctr;
} /* end getwindx */

/********** take a requested total window size, make it real **********/
/*  Value is nonzero iff window size is smaller or same in both directions,
  which means GEM won't take care of the redraw message */
int  sizewindow(windx,wbx,wby,wbw,wbh)
  int windx,*wbx,*wby,*wbw,*wbh; {

  int	oldw = windrect[windx][2],
	oldh = windrect[windx][3];

  /* what does that work out to for a work area for our window? */
  wind_calc(WC_WORK,windattrib[windx],*wbx,*wby,*wbw,*wbh,
    &windrect[windx][0],&windrect[windx][1],
    &windrect[windx][2],&windrect[windx][3]);

  if (windrect[windx][2] < 10*cellwidth) {  /* too narrow */
    windrect[windx][2] = 10*cellwidth;
    wind_calc(WC_BORDER,windattrib[windx],
      windrect[windx][0],windrect[windx][1],
      windrect[windx][2],windrect[windx][3],
      wbx,wby,wbw,wbh);
  }
  if (windrect[windx][3] < 6*cellheight) {  /* too short */
    windrect[windx][3] = 6*cellheight;
    wind_calc(WC_BORDER,windattrib[windx],
      windrect[windx][0],windrect[windx][1],
      windrect[windx][2],windrect[windx][3],
      wbx,wby,wbw,wbh);
  }

  return oldw >= windrect[windx][2] && oldh >= windrect[windx][3];
} /* end sizewindow */

/********** set window sliders **********/
setsliders(windx,vsize,vpos)
  int windx,vsize,vpos; {

  long newsize;

  if (windx == INFWIND || !windopen[windx])
    return;

  if (vsize) { /* set vertical thumb size */

    /* newsize is # of lines in window / total lines in displayed data */
    newsize = (1000L * windrect[windx][3])/cellheight;
    if (windx == TXTWIND)
      if (otext.trlcount > 0)
        newsize /= otext.trlcount;
      else
        newsize = 1000L;
    else /* windx == CDEWIND */
      newsize /= CODECOUNT;
    newsize = newsize > 1000L ? 1000L : newsize;
    wind_set(window[windx],WF_VSLSIZE,(int) newsize);
  }

  if (vpos) { /* set vertical thumb position */

    /* newsize is index of top line / total lines in displayed data */
    if (windx == TXTWIND)
      if (otext.trlcount > 0)
        newsize = (1000L * otext.trtopline)/otext.trlcount;
      else
        newsize = 0L;
    else
      newsize = (1000L * cwindtop)/CODECOUNT;
    wind_set(window[windx],WF_VSLIDE,(int) newsize);
  }
} /* end setsliders */

/********** open a new window **********/
int openwindow(windx,firstime,wbx,wby,wbw,wbh)
  int windx,firstime,wbx,wby,wbw,wbh; {

  int dbx,dby,dbw,dbh;

  /* calculate windrect[][], then create as large as possible */
  if (firstime) {
    sizewindow(windx,&wbx,&wby,&wbw,&wbh);
    wind_get(0,WF_WORKXYWH,&dbx,&dby,&dbw,&dbh);  /* desktop window */
    window[windx] = wind_create(windattrib[windx],dbx,dby,dbw,dbh);
    if (window[windx] < 0)
      return 0;
    windopen[windx] = 1;
  } else {
    wind_calc(WC_BORDER,windattrib[windx],
      windrect[windx][0],windrect[windx][1],
      windrect[windx][2],windrect[windx][3],
      &wbx,&wby,&wbw,&wbh);
  }

  switch (windx) {
    case TXTWIND :
      wind_set(window[TXTWIND],WF_NAME," Unpacked Text ");
      break;
    case INFWIND :
      wind_set(window[INFWIND],WF_NAME," Pack Data ");
      break;
    case CDEWIND :
      wind_set(window[CDEWIND],WF_NAME," Huffman Codes ");
  } /* end switch (windx) */

  setsliders(windx,1,1);
  wind_open(window[windx],wbx,wby,wbw,wbh);

  return 1;
} /* end openwindow */

/********** erase a window's contents **********/
clrwindow(windx)
  int windx; {

  /*	make a rectangle equal to window contents, clipped to screen,
	then fill it.  fill type is assumed background */
  v_hide_c(schandle);
  ptsin[0] = (windrect[windx][0] > 0) ? windrect[windx][0] : 0;
  ptsin[1] = (windrect[windx][1] > 0) ? windrect[windx][1] : 0;
  ptsin[2] = windrect[windx][0] + windrect[windx][2] - 1;
  ptsin[2] = (ptsin[2] <= scrxmax) ? ptsin[2] : scrxmax;
  ptsin[3] = windrect[windx][1] + windrect[windx][3] - 1;
  ptsin[3] = (ptsin[3] <= scrymax) ? ptsin[3] : scrymax;
  vr_recfl(schandle,ptsin);
  v_show_c(schandle,1);
} /* end clrwindow */

/********** show huffman codes generated in code window **********/
cwupdate() {

  int	ctr,line,
	windbottom = windrect[CDEWIND][1] + windrect[CDEWIND][3];
  char	msg[80];

  clrwindow(CDEWIND);
  v_hide_c(schandle);

  v_gtext(schandle,
    windrect[CDEWIND][0],windrect[CDEWIND][1]+cellheight,
    "    Char  Frequency  Length/Code");

  /* display each line of code table that fits in window */
  for (ctr = cwindtop, line = windrect[CDEWIND][1] + 3*cellheight;
    line < windbottom && ctr < CODECOUNT;
    ctr++, line += cellheight) {

    makecstring(msg,ctr,1);
    v_gtext(schandle,windrect[CDEWIND][0],line,msg);
  } /* end for (ctr) */

  /* add a line at the bottom to show theoretical packing efficiency */
  line += cellheight;
  if (line <= windbottom) {
    strcpy(msg,"Efficiency rating ");
    longconc(msg,packstats.psteffic,4,0,0);
    v_gtext(schandle,windrect[CDEWIND][0],line,msg);
  }

  v_show_c(schandle,1);
} /* end cwupdate */

/********** display info window (some stats) **********/
pwupdate() {

  char msg[40];
  int x,y;

  clrwindow(INFWIND);

  v_hide_c(schandle);
  x = windrect[INFWIND][0] + cellwidth;
  y = windrect[INFWIND][1] + cellheight;

  strcpy(msg,"Unpacked length ");
  longconc(msg,packstats.psulen,0,0,0);
  v_gtext(schandle,x,y,msg);
  y += cellheight;

  strcpy(msg,"Packed length ");
  longconc(msg,packstats.psplen,0,0,0);
  v_gtext(schandle,x,y,msg);
  y += cellheight;

  strcpy(msg,"Packing efficiency ");
  longconc(msg,packstats.pspeffic,4,0,0);
  v_gtext(schandle,x,y,msg);
  y += cellheight;

  strcpy(msg,"Pack table efficiency ");
  longconc(msg,packstats.psteffic,4,0,0);
  v_gtext(schandle,x,y,msg);

  v_show_c(schandle,1);
} /* end pwupdate */

/********** display any window **********/
/*	windx is window index, drawmsg is a rectangle defining a subset of the
	window to be updated */
drawindow(windx,drawmsg)
  int windx,drawmsg[]; {

  int wx,wy,ww,wh;

  if (!windopen[windx])
    return;

  wind_update(BEG_UPDATE);
  v_hide_c(schandle);

  /* update separately each rectangle in the list that defines the window */
  wind_get(window[windx],WF_FIRSTXYWH,&wx,&wy,&ww,&wh);
  while (ww > 0 && wh > 0) {  /* while valid rectangle */

    /* calculate intersection of window rectangle and draw rectangle */
    ptsin[0] = drawmsg[0] > wx ? drawmsg[0] : wx;
    ptsin[1] = drawmsg[1] > wy ? drawmsg[1] : wy;
    ptsin[2] = (drawmsg[0] + drawmsg[2] > wx + ww ?
      wx + ww : drawmsg[0] + drawmsg[2])-1;
    ptsin[3] = (drawmsg[1] + drawmsg[3] > wy + wh ?
      wy + wh : drawmsg[1] + drawmsg[3])-1;
    ptsin[2] = ptsin[2] > scrxmax ? scrxmax : ptsin[2];
    ptsin[3] = ptsin[3] > scrymax ? scrymax : ptsin[3];

    /* if intersection is not empty, clip and draw */
    if (ptsin[2] > ptsin[0] && ptsin[3] > ptsin[1]) {
      vs_clip(schandle,1,ptsin);
      switch (windx) {
        case TXTWIND :
          teupdate(&otext);
          break;
        case INFWIND :
          pwupdate();
          break;
        case CDEWIND :
          cwupdate();
      } /* end switch (windx) */
    }
    wind_get(window[windx],WF_NEXTXYWH,&wx,&wy,&ww,&wh);
  }

  /* clipping is normally off in this program */
  vs_clip(schandle,0,ptsin);
  v_show_c(schandle,1);
  wind_update(END_UPDATE);
} /* end drawindow */


/************************************************************************/
/************************ GEM Interface Handlers ************************/
/************************************************************************/

/********** wake up **********/
initialize() {

  int	ctr,obctr,
	obval,
	wbx,wby,wbw,wbh;

  /* open the GEM workstation */
  appl_init();
  schandle = graf_handle(&cellwidth,&cellheight,&trash,&trash);
  for (ctr = 0; ctr < 10; ctr++)
    intin[ctr] = 1;
  intin[10] = 2;
  v_opnvwk(intin,&schandle,intout);
  scrxmax = intout[0];
  scrymax = intout[1];
  v_hide_c(schandle);
  graf_mouse(0,0);

  /* set up the screen: */
  vsf_interior(schandle,0);			/* fill mode is erase */
  vst_alignment(schandle,0,3,&trash,&trash);	/* text aligned @ bottom */
  vswr_mode(schandle,1);			/* writing mode is replace */

  wind_get(0,WF_WORKXYWH,&wbx,&wby,&wbw,&wbh);	/* desktop window */

  /* object coordinate tweaking */
  for (obctr = 0; oblist[obctr] != 0; obctr++) {
    ctr = 0;
    /* multiply each coordinate low byte by cell size, add high byte */
    do {
      obval = oblist[obctr][ctr].ob_x;
      oblist[obctr][ctr].ob_x =
        cellwidth*(obval & 0xFF) + (obval >> 8);
      obval = oblist[obctr][ctr].ob_y;
      oblist[obctr][ctr].ob_y =
        cellheight*(obval & 0xFF) + (obval >> 8);
      obval = oblist[obctr][ctr].ob_width;
      oblist[obctr][ctr].ob_width =
        cellwidth*(obval & 0xFF) + (obval >> 8);
      obval = oblist[obctr][ctr].ob_height;
      oblist[obctr][ctr].ob_height =
        cellheight*(obval & 0xFF) + (obval >> 8);
    } while (!(oblist[obctr][ctr++].ob_flags & LASTOB));
  }

  /* additional tweak for menu */
  menudata[0].ob_width = scrxmax;
  menudata[menudata[0].ob_head].ob_width = scrxmax;

  /* set "windows" menu item strings */
  for (ctr = 0; ctr < WINDCNT; ctr++)
    menudata[ctr+FSTWINDOW].ob_spec = (long) wmenustr[ctr+3];

  menu_bar(menudata,1);

  /* calculate size of menubar */
  vq_extnd(schandle,1,intout);
  menusize = ((scrxmax+1)/8)*intout[4]*wby;
  menusave = Malloc((long) menusize);
  if (menusave == 0) {
    form_alert(1,"[3][No memory!][Bad]");
    return 0;
  }

  wby += 2;  /* just some space between menu and windows */
  wbh -= 2;

  /* define and open the three windows */
  windattrib[TXTWIND] =	NAME | CLOSER | MOVER | SIZER |
			UPARROW | DNARROW | VSLIDE;
  windattrib[CDEWIND] =	windattrib[TXTWIND];
  windattrib[INFWIND] =	NAME | CLOSER | MOVER | SIZER;

  openwindow(TXTWIND,1,wbx,wby,wbw/2,wbh/2);
  openwindow(INFWIND,1,wbx+wbw/6,wby+wbh/6,wbw/2,wbh/2);
  openwindow(CDEWIND,1,wbx+wbw/3,wby+wbh/3,wbw/2,wbh/2);

  /* initialize appropriate variables */
  setmem(packstats,sizeof(packstats),0);
  cwindtop = 0;

  /* set current path and file names */
  filename[0] = 0;
  Dgetpath(pathname + 2,0);
  movmem("A:",pathname,2);
  pathname[0] += Dgetdrv();
  strconc(pathname,"\\*.*");

  /* finish constructing the default huffman code */
  for (ctr = 0; ctr < CODECOUNT; ctr++)
    packtable[ctr].ptsymb = ctr;
  sortptable();
  huffmans();

  /* initialize text display area */
  if (!tenew(&otext,TXTWIND)) {
    form_alert(1,"[3][Insufficient memory|for text buffer.][Abort]");
    return 0;
  }

  v_show_c(schandle,0);

  return 1;
} /* end initialize */

/********** run a dialog; return which object was chosen **********/
int dodialog(thedialog)
  OBJECT *thedialog; {

  int	dbox[4],		/* dialog position and size */
	window,			/* handle for window in which dialog appears */
	wbx,wby,wbw,wbh,	/* window size and position */
	ctr,
	obj;			/* object causing exit from dialog */

  /* draw the dialog inside a window, if possible */
  form_center(thedialog,&dbox[0],&dbox[1],&dbox[2],&dbox[3]);
  wind_calc(WC_BORDER,0,dbox[0],dbox[1],dbox[2],dbox[3],
    &wbx,&wby,&wbw,&wbh);
  window = wind_create(0,wbx,wby,wbw,wbh);
  if (window >= 0)
    wind_open(window,wbx,wby,wbw,wbh);
  form_dial(FMD_START,dbox[0],dbox[1],dbox[2],dbox[3]);
  form_dial(FMD_GROW,0,0,2,2,dbox[0],dbox[1],dbox[2],dbox[3]);
  objc_draw(thedialog,0,2,dbox[0],dbox[1],dbox[2],dbox[3]);

  /* find first edit object if any, open it, run the dialog */
  for (obj = 0; !(thedialog[obj].ob_flags & (LASTOB | EDITABLE)); obj++);
  if (!(thedialog[obj].ob_flags & EDITABLE))
    obj = 0;
  obj = form_do(thedialog,obj);
  thedialog[obj].ob_state &= ~SELECTED;

  /* "erase" it:  does this do anything? */
  form_dial(FMD_SHRINK,0,0,2,2,dbox[0],dbox[1],dbox[2],dbox[3]);
  form_dial(FMD_FINISH,dbox[0],dbox[1],dbox[2],dbox[3]);

  /* now really erase it, as well as possible */
  if (window >= 0) {
    wind_close(window);
    wind_delete(window);
  } else
    for (ctr = 0; ctr < WINDCNT; ctr++)
      drawindow(ctr,dbox);
  return obj;
} /* end dodialog */

/********** run the blasted file selector box **********/
getfname(path,file,prompt)
  char *path,*file,*prompt; {

  int	ok;
  char	*slider,	/* slide up and down path and file name */
	*marker,	/* marks points of interest found by slider */
	*screen,	/* location of screen in memory */
	realname[60];	/* temporary to build filename */

  /* replace menu bar with prompt */
  screen = Physbase();
  v_hide_c(schandle);
  movmem(screen,menusave,menusize);	/* copy menu bar to safekeeping */
  setmem(screen,menusize,0);		/* erase it */
  vst_effects(schandle,1);		/* bold text */
  vqt_extent(schandle,prompt,ptsout);	/* get length of prompt */
  v_gtext(schandle,(scrxmax-(ptsout[2]-ptsout[0]))/2,cellheight,prompt);
  vst_effects(schandle,0);		/* back to normal text */
  v_show_c(schandle,1);

  /* if file includes a pathname, remove it ("path" assumed to have copy) */
  slider = file;
  while (*slider++);
  marker = slider;
  while (*--slider != '\\' && slider >= file);
  if (slider >= file)
    movmem(slider+1,file,(int) (marker-slider));

  /* get path and filename from human */
  fsel_input(path,file,&ok);

  /* glom path and filename together in filename */
  strcpy(realname,path);
  slider = realname;
  while (*slider++);
  while (*--slider != '\\' && slider >= realname);
  strcpy(slider+1,file);
  strcpy(file,realname);

  /* return menu bar */
  v_hide_c(schandle);
  movmem(menusave,screen,menusize);
  v_show_c(schandle,1);

  return ok;
} /* end getfname */

/************ menu item was chosen ************/
int domenus(menu,item)
  int menu,	/* which menu was chosen */
      item; {	/* the actual item within the menu */

  int	tuesday;

  tuesday = 1;

  switch (menu) {
      case DESKMENU :
      dodialog(glorybox);
      break;
      case FILEMENU :
      switch(item) {
        case PACKFILE :
          graf_mouse(2,0);	/* busy symbol */
          packtext();
	  if (menudata[INCLCODES].ob_state & CHECKED) { /* new code tables */
            setsliders(CDEWIND,1,1);
            drawindow(CDEWIND,windrect[CDEWIND]);
	  }
          drawindow(TXTWIND,windrect[TXTWIND]);
          drawindow(INFWIND,windrect[INFWIND]);
          graf_mouse(0,0);
          break;
        case UNPACKFILE :
          graf_mouse(2,0);
          unpacktext();
	  if (menudata[INCLCODES].ob_state & CHECKED) { /* new code tables */
            setsliders(CDEWIND,1,1);
            drawindow(CDEWIND,windrect[CDEWIND]);
	  }
          drawindow(TXTWIND,windrect[TXTWIND]);
          drawindow(INFWIND,windrect[INFWIND]);
          graf_mouse(0,0);
          break;
        case SAVECODES :
          savecodes();
          break;
        case LOADCODES :
          loadcodes();
          drawindow(CDEWIND,windrect[CDEWIND]);
          drawindow(INFWIND,windrect[INFWIND]);
          break;
        case INCLCODES :
          menudata[INCLCODES].ob_state ^= CHECKED;
          break;
        case QUIT :
          tuesday = 0;
      } /* end PROGMENU switch (item) */
      break;
    case HUFFMENU :
      switch (item) {
        case GENERATE :
          if (loadfreqs()) {
            setsliders(CDEWIND,1,1);
            drawindow(CDEWIND,windrect[CDEWIND]);
            drawindow(INFWIND,windrect[INFWIND]);
          }
          break;
        case PRINTCODES :
          printcodes();
      } /* end HUFFMENU switch (item) */
      break;
    case WINDMENU :
      item -= FSTWINDOW;
      windopen[item] = !windopen[item];
      if (windopen[item]) {
        openwindow(item,0,0,0,0,0);
        setsliders(item,1,1);
        drawindow(item,windrect[item]);
      } else
        wind_close(window[item]);
      menudata[item+FSTWINDOW].ob_spec =  
        (long) wmenustr[item + (windopen[item] ? 3 : 0)];
  } /*  end switch (menu) */

  menu_tnormal(menudata,menu,1);
  return tuesday;
} /* end domenus */

/********* handle the window events ***********/
int dowindows() {

  int	wx,wy,ww,wh,	/* window position and size */
	windx,		/* window index */
	misc,
	tuesday;

  tuesday = 1;
  windx = getwindx(message[3]);
  switch (message[0]) {
    case MN_SELECTED :
      tuesday = domenus(message[3],message[4]);
      break;

    case WM_REDRAW: /* redraw some part of the window */
      if (windx < WINDCNT)
        drawindow(windx,message+4);
      break;

    case WM_TOPPED : /* put this window on top */
      wind_set(message[3],WF_TOP,message[3]);
      break;

    case WM_CLOSED : /* close some window */
      wind_close(message[3]);
      windopen[windx] = 0;
      menudata[windx+FSTWINDOW].ob_spec = (long) wmenustr[windx];
      break;

    case WM_ARROWED :
      switch (message[4]) {
        case 0 : /* page up */
          if (windx == TXTWIND)
            otext.trtopline -= windrect[TXTWIND][3]/cellheight;
          else  /* CDEWIND */
            cwindtop -= windrect[CDEWIND][3]/cellheight - 2;
          break;
        case 1 : /* page down */
          if (windx == TXTWIND)
            otext.trtopline += windrect[TXTWIND][3]/cellheight;
          else
            cwindtop += windrect[CDEWIND][3]/cellheight - 2;
          break;
        case 2 : /* scroll up */
          if (windx == TXTWIND)
            otext.trtopline--;
          else
            cwindtop--;
          break;
        case 3 : /* scroll down */
          if (windx == TXTWIND)
            otext.trtopline++;
          else
            cwindtop++;
      } /* end switch (which arrow) */
      if (windx == TXTWIND) {
        if (otext.trtopline >= otext.trlcount)
          otext.trtopline = otext.trlcount - 1;
        if (otext.trtopline < 0)
          otext.trtopline = 0;
      } else {
        if (cwindtop > CODECOUNT)
          cwindtop = CODECOUNT;
        if (cwindtop < 0)
          cwindtop = 0;
      }
      drawindow(windx,windrect[windx]);
      setsliders(windx,0,1);
      break;
    case WM_VSLID :
      if (windx == TXTWIND) {
        wh = otext.trlcount > 0 ? otext.trlcount - 1 : 0;
        wy = (wh * (long) message[4])/1000;
        otext.trtopline = wy > wh ? wh : wy;
      } else {
        wy = (CODECOUNT * (long) message[4])/1000;
        cwindtop = wy > CODECOUNT ? CODECOUNT : wy;
      }
      drawindow(windx,windrect[windx]);
      setsliders(windx,0,1);
      break;
    case WM_SIZED :
      wx = message[4];
      wy = message[5];
      ww = message[6];
      wh = message[7];
      misc = sizewindow(windx,&wx,&wy,&ww,&wh);
      wind_set(window[windx],WF_CURRXYWH,wx,wy,ww,wh);
      if (windx == TXTWIND)
        tecalc(&otext);
      setsliders(windx,1,1);
      if (misc && windx == TXTWIND)
        drawindow(windx,windrect[windx]);
      break;

    case WM_MOVED :
      sizewindow(windx,
        &message[4],&message[5],&message[6],&message[7]);
      wind_set(message[3],WF_CURRXYWH,
        message[4],message[5],message[6],message[7]);
  } /* end of switch */
  return tuesday;
} /* end dowindows */


/************************************************************************/
/******************************** Program *******************************/
/************************************************************************/

/********** **********/
main() {

  int	tuesday;	/* continue until... */

  tuesday = initialize();

  while (tuesday) {
    evnt_mesag(message);
    tuesday = dowindows();
  } /* end main loop */

  for (tuesday = 0; tuesday < WINDCNT; tuesday++) {
    if (windopen[tuesday])
      wind_close(window[tuesday]);
    wind_delete(window[tuesday]);
  }
  v_clsvwk(schandle);
  appl_exit();
} /* end main */
