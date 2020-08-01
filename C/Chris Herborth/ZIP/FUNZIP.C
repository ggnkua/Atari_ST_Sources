/* funzip.c -- put in the public domain by Mark Adler */

#define VERSION "3.83 of 2 August 1994"


/* You can do whatever you like with this source file, though I would
   prefer that if you modify it and redistribute it that you include
   comments to that effect with your name and the date.  Thank you.

   History:
   vers     date          who           what
   ----   ---------  --------------  ------------------------------------
   1.0    13 Aug 92  M. Adler        really simple unzip filter.
   1.1    13 Aug 92  M. Adler        cleaned up somewhat, give help if
                                     stdin not redirected, warn if more
                                     zip file entries after the first.
   1.2    15 Aug 92  M. Adler        added check of lengths for stored
                                     entries, added more help.
   1.3    16 Aug 92  M. Adler        removed redundant #define's, added
                                     decryption.
   1.4    27 Aug 92  G. Roelofs      added exit(0).
   1.5     1 Sep 92  K. U. Rommel    changed read/write modes for OS/2.
   1.6     6 Sep 92  G. Roelofs      modified to use dummy crypt.c and
                                     crypt.h instead of -DCRYPT.
   1.7    23 Sep 92  G. Roelofs      changed to use DOS_OS2; included
                                     crypt.c under MS-DOS.
   1.8     9 Oct 92  M. Adler        improved inflation error msgs.
   1.9    17 Oct 92  G. Roelofs      changed ULONG/UWORD/byte to ulg/ush/uch;
                                     renamed inflate_entry() to inflate();
                                     adapted to use new, in-place zdecode.
   2.0    22 Oct 92  M. Adler        allow filename argument, prompt for
                                     passwords and don't echo, still allow
                                     command-line password entry, but as an
                                     option.
   2.1    23 Oct 92  J-l. Gailly     fixed crypt/store bug,
                     G. Roelofs      removed crypt.c under MS-DOS, fixed
                                     decryption check to compare single byte.
   2.2    28 Oct 92  G. Roelofs      removed declaration of key.
   2.3    14 Dec 92  M. Adler        replaced fseek (fails on stdin for SCO
                                     Unix V.3.2.4).  added quietflg for
                                     inflate.c.
   3.0    11 May 93  M. Adler        added gzip support
   3.1     9 Jul 93  K. U. Rommel    fixed OS/2 pipe bug (PIPE_ERROR)
   3.2     4 Sep 93  G. Roelofs      moved crc_32_tab[] to tables.h; used FOPx
                                     from unzip.h; nuked OUTB macro and outbuf;
                                     replaced flush(); inlined FlushOutput();
                                     renamed decrypt to encrypted
   3.3    29 Sep 93  G. Roelofs      replaced ReadByte() with NEXTBYTE macro;
                                     revised (restored?) flush(); added FUNZIP
   3.4    21 Oct 93  G. Roelofs      renamed quietflg to qflag; changed outcnt,
                     H. Gessau       second updcrc() arg and flush() arg to ulg;
                                     added inflate_free(); added "g =" to null
                                     getc(in) to avoid compiler warnings
   3.5    31 Oct 93  H. Gessau       changed DOS_OS2 to DOS_NT_OS2
   3.6     6 Dec 93  H. Gessau       added "near" to mask_bits[]
   3.7     9 Dec 93  G. Roelofs      added extent typecasts to fwrite() checks
   3.8    28 Jan 94  GRR/JlG         initialized g variable in main() for gcc
   3.81   22 Feb 94  M. Hanning-Lee  corrected usage message
   3.82   27 Feb 94  G. Roelofs      added some typecasts to avoid warnings
   3.83   22 Jul 94  G. Roelofs      changed fprintf to FPRINTF for DLLs
    -      2 Aug 94  -               public release with UnZip 5.11
 */


/*

   All funzip does is take a zip file from stdin and decompress the
   first entry to stdout.  The entry has to be either deflated or
   stored.  If the entry is encrypted, then the decryption password
   must be supplied on the command line as the first argument.

   funzip needs to be linked with inflate.o and crypt.o compiled from
   the unzip source.  If decryption is desired, the full version of
   crypt.c (and crypt.h) from zcrypt21.zip or later must be used.

 */

#define FUNZIP
#include "unzip.h"
#include "crypt.h"

#ifdef EBCDIC
#  undef EBCDIC                 /* don't need ebcdic[] */
#endif
#include "tables.h"             /* crc_32_tab[] */

/* PKZIP header definitions */
#define ZIPMAG 0x4b50           /* two-byte zip lead-in */
#define LOCREM 0x0403           /* remaining two bytes in zip signature */
#define LOCSIG 0x04034b50L      /* full signature */
#define LOCFLG 4                /* offset of bit flag */
#define  CRPFLG 1               /*  bit for encrypted entry */
#define  EXTFLG 8               /*  bit for extended local header */
#define LOCHOW 6                /* offset of compression method */
#define LOCTIM 8                /* file mod time (for decryption) */
#define LOCCRC 12               /* offset of crc */
#define LOCSIZ 16               /* offset of compressed size */
#define LOCLEN 20               /* offset of uncompressed length */
#define LOCFIL 24               /* offset of file name field length */
#define LOCEXT 26               /* offset of extra field length */
#define LOCHDR 28               /* size of local header, including LOCREM */
#define EXTHDR 16               /* size of extended local header, inc sig */

/* GZIP header definitions */
#define GZPMAG 0x8b1f           /* two-byte gzip lead-in */
#define GZPHOW 0                /* offset of method number */
#define GZPFLG 1                /* offset of gzip flags */
#define  GZPMUL 2               /* bit for multiple-part gzip file */
#define  GZPISX 4               /* bit for extra field present */
#define  GZPISF 8               /* bit for filename present */
#define  GZPISC 16              /* bit for comment present */
#define  GZPISE 32              /* bit for encryption */
#define GZPTIM 2                /* offset of Unix file modification time */
#define GZPEXF 6                /* offset of extra flags */
#define GZPCOS 7                /* offset of operating system compressed on */
#define GZPHDR 8                /* length of minimal gzip header */

/* Macros for getting two-byte and four-byte header values */
#define SH(p) ((ush)(uch)((p)[0]) | ((ush)(uch)((p)[1]) << 8))
#define LG(p) ((ulg)(SH(p)) | ((ulg)(SH((p)+2)) << 16))

/* Function prototypes */
ulg updcrc OF((uch *, ulg));
int inflate OF((void));
void err OF((int, char *));
void main OF((int, char **));

/* Globals */
FILE *in, *out;                 /* input and output files */
union work area;                /* inflate sliding window */
uch *outptr;                    /* points to next byte in output buffer */
ulg outcnt;                     /* bytes in output buffer */
ulg outsiz;                     /* total bytes written to out */
int encrypted;                  /* flag to turn on decryption */
int qflag = 1;                  /* turn off messages in inflate.c */

/* Masks for inflate.c */
ush near mask_bits[] = {
    0x0000,
    0x0001, 0x0003, 0x0007, 0x000f, 0x001f, 0x003f, 0x007f, 0x00ff,
    0x01ff, 0x03ff, 0x07ff, 0x0fff, 0x1fff, 0x3fff, 0x7fff, 0xffff
};


ulg updcrc(s, n)
uch *s;                 /* pointer to bytes to pump through */
ulg n;                  /* number of bytes in s[] */
/* Run a set of bytes through the crc shift register.  If s is a NULL
   pointer, then initialize the crc shift register contents instead.
   Return the current crc in either case. */
{
  register ulg c;       /* temporary variable */

  static ulg crc = 0xffffffffL; /* shift register contents */

  if (s == (uch *)NULL)
    c = 0xffffffffL;
  else
  {
    c = crc;
    while (n--)
      c = crc_32_tab[((int)c ^ (*s++)) & 0xff] ^ (c >> 8);
  }
  crc = c;
  return c ^ 0xffffffffL;       /* (instead of ~c for 64-bit machines) */
}


void err(n, m)
int n;
char *m;
/* Exit on error with a message and a code */
{
  FPRINTF(stderr, "funzip error: %s\n", m);
  exit(n);
}


int flush(w)    /* used by inflate.c (FLUSH macro) */
ulg w;          /* number of bytes to flush */
{
  updcrc(slide, w);
  if (fwrite((char *)slide,1,(extent)w,out) != (extent)w && !PIPE_ERROR)
    err(9, "out of space on stdout");
  outsiz += w;
  return 0;
}


void main(argc, argv)
int argc;
char **argv;
/* Given a zip file on stdin, decompress the first entry to stdout. */
{
  ush n;
  uch h[LOCHDR];                /* first local header (GZPHDR < LOCHDR) */
  int g = 0;                    /* true if gzip format */
#ifdef CRYPT
  char *s = " [-password]";
  char *p;                      /* password */
#else /* !CRYPT */
  char *s = "";
#endif /* ?CRYPT */

  /* skip executable name */
  argc--;
  argv++;

#ifdef CRYPT
  /* get the command line password, if any */
  p = (char *)NULL;
  if (argc && **argv == '-')
  {
    argc--;
    p = 1 + *argv++;
  }
#endif /* CRYPT */

  /* if no file argument and stdin not redirected, give the user help */
  if (argc == 0 && isatty(0))
  {
    FPRINTF(stderr, "fUnZip (filter UnZip), version %s\n", VERSION);
    FPRINTF(stderr, "usage: ... | funzip%s | ...\n", s);
    FPRINTF(stderr, "       ... | funzip%s > outfile\n", s);
    FPRINTF(stderr, "       funzip%s infile.zip > outfile\n", s);
    FPRINTF(stderr, "       funzip%s infile.gz > outfile\n", s);
    FPRINTF(stderr, "Extracts to stdout the gzip file or first zip entry of\
 stdin or the given file.\n");
    exit(3);
  }

  /* prepare to be a binary filter */
  if (argc)
  {
    if ((in = fopen(*argv, FOPR)) == (FILE *)NULL)
      err(2, "cannot find input file");
  }
  else
  {
#ifdef DOS_NT_OS2
    setmode(0, O_BINARY);  /* some buggy C libraries require BOTH setmode() */
#endif                     /*  call AND the fdopen() in binary mode :-( */
    if ((in = fdopen(0, FOPR)) == (FILE *)NULL)
      err(2, "cannot find stdin");
  }
#ifdef DOS_NT_OS2
  setmode(1, O_BINARY);
#endif
  if ((out = fdopen(1, FOPW)) == (FILE *)NULL)
    err(2, "cannot write to stdout");

  /* read local header, check validity, and skip name and extra fields */
  n = getc(in);  n |= getc(in) << 8;
  if (n == ZIPMAG)
  {
    if (fread((char *)h, 1, LOCHDR, in) != LOCHDR || SH(h) != LOCREM)
      err(3, "invalid zip file");
    if (SH(h + LOCHOW) != STORED && SH(h + LOCHOW) != DEFLATED)
      err(3, "first entry not deflated or stored--can't funzip");
    for (n = SH(h + LOCFIL); n--; ) g = getc(in);
    for (n = SH(h + LOCEXT); n--; ) g = getc(in);
    g = 0;
    encrypted = h[LOCFLG] & CRPFLG;
  }
  else if (n == GZPMAG)
  {
    if (fread((char *)h, 1, GZPHDR, in) != GZPHDR)
      err(3, "invalid gzip file");
    if (h[GZPHOW] != DEFLATED)
      err(3, "gzip file not deflated");
    if (h[GZPFLG] & GZPMUL)
      err(3, "cannot handle multi-part gzip files");
    if (h[GZPFLG] & GZPISX)
    {
      n = getc(in);  n |= getc(in) << 8;
      while (n--) g = getc(in);
    }
    if (h[GZPFLG] & GZPISF)
      while ((g = getc(in)) != 0 && g != EOF) ;
    if (h[GZPFLG] & GZPISC)
      while ((g = getc(in)) != 0 && g != EOF) ;
    g = 1;
    encrypted = h[GZPFLG] & GZPISE;
  }
  else
    err(3, "input not a zip or gzip file");

  /* if entry encrypted, decrypt and validate encryption header */
  if (encrypted)
#ifdef CRYPT
    {
      ush i, e;

      if (p == (char *)NULL)
        if ((p = (char *)malloc(PWLEN+1)) == (char *)NULL)
          err(1, "out of memory");
        else if ((p = getp("Enter password: ", p, PWLEN+1)) == (char *)NULL)
          err(1, "no tty to prompt for password");
      init_keys(p);
      for (i = 0; i < RAND_HEAD_LEN; i++)
        e = NEXTBYTE;
      if (e != (ush)(h[LOCFLG] & EXTFLG ? h[LOCTIM + 1] : h[LOCCRC + 3]))
        err(3, "incorrect password for first entry");
    }
#else /* !CRYPT */
    err(3, "cannot decrypt entry (need to recompile with full crypt.c)");
#endif /* ?CRYPT */

  /* prepare output buffer and crc */
  outptr = slide;
  outcnt = 0L;
  outsiz = 0L;
  updcrc(NULL, 0L);

  /* decompress */
  if (g || h[LOCHOW])
  {                             /* deflated entry */
    int r;
 
    if ((r = inflate()) != 0)
      if (r == 3)
        err(1, "out of memory");
      else
        err(4, "invalid compressed data--format violated");
    inflate_free();
  }
  else
  {                             /* stored entry */
    register ulg n;

    n = LG(h + LOCLEN);
    if (n != LG(h + LOCSIZ) - (encrypted ? RAND_HEAD_LEN : 0)) {
      FPRINTF(stderr, "len %ld, siz %ld\n", n, LG(h + LOCSIZ));
      err(4, "invalid compressed data--length mismatch");
    }
    while (n--) {
      ush c = getc(in);
#ifdef CRYPT
      if (encrypted)
        zdecode(c);
#endif
      *outptr++ = (uch)c;
      if (++outcnt == WSIZE)    /* do FlushOutput() */
      {
        updcrc(slide, outcnt);
        if (fwrite((char *)slide, 1,(extent)outcnt,out) != (extent)outcnt
            && !PIPE_ERROR)
          err(9, "out of space on stdout");
        outsiz += outcnt;
        outptr = slide;
        outcnt = 0L;
      }
    }
  }
  if (outcnt)   /* flush one last time; no need to reset outptr/outcnt */
  {
    updcrc(slide, outcnt);
    if (fwrite((char *)slide, 1,(extent)outcnt,out) != (extent)outcnt
        && !PIPE_ERROR)
      err(9, "out of space on stdout");
    outsiz += outcnt;
  }
  fflush(out);

  /* if extended header, get it */
  if (g)
  {
    if (fread((char *)h + LOCCRC, 1, 8, in) != 8)
      err(3, "gzip file ended prematurely");
  }
  else
    if ((h[LOCFLG] & EXTFLG) &&
        fread((char *)h + LOCCRC - 4, 1, EXTHDR, in) != EXTHDR)
      err(3, "zip file ended prematurely");

  /* validate decompression */
  if (LG(h + LOCCRC) != updcrc(slide, 0L))
    err(4, "invalid compressed data--crc error");
  if (LG(h + (g ? LOCSIZ : LOCLEN)) != outsiz)
    err(4, "invalid compressed data--length error");

  /* check if there are more entries */
  if (!g && fread((char *)h, 1, 4, in) == 4 && LG(h) == LOCSIG)
    FPRINTF(stderr,
      "funzip warning: zip file has more than one entry--rest ignored\n");

  exit(0);
}
