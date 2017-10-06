/* XIMGTOOL - Tool for XIMG Level-1/2/3 files.
 *	      (c) 1995 by Guido Vollbeding.
 *	      Tested with Pure-C on Atari-TOS,
 *	      GNU-C on a SUN-SPARCstation,
 *	      and GNU-C on a Linux-Pentium-System.
 *
 * For Pure-C on TOS use the following project file:
 *
 * ximgtool.ttp
 * =
 * pcxstart.o
 * ximgtool
 * l3decode
 * encoders
 * pcstdlib.lib
 * pctoslib.lib
 *
 * For GNU-C on UNIX use the following shell command:
 *
 * gcc -O -o ximgtool ximgtool.c l3decode.c encoders.c
 *
 * NOTE: The UNIX version does NOT support the -m
 *       multiple mode option at the moment!
 */

#ifdef __TOS__
/* Change 0 to 1 if using tos.h */
#if 0
#include <tos.h>
#else
#include <osbind.h>
#endif
#else
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#define Fopen open
#define Fclose close
#define Fread(handle, count, buf) read(handle, buf, count)
#define Fwrite(handle, count, buf) write(handle, buf, count)
#define Fdelete unlink
#define Malloc (void *(*)(long))malloc
#define Mfree free
#endif

#include <stdio.h>
#include <string.h>
#include <setjmp.h>

#include "imgcodec.h"

/* Forward declarations of local functions. */

static void ProcHeader(int ident);

static void do_proc(char *src, char *des, short outlev, short outpat, int ident);


static jmp_buf jmp_buffer;


/* The following stuff defines application specific file handling. */

#define BUF_LENGTH 80L*1024

typedef struct
{
  FBUFPUB pub;
  long length;
  int handle, EOF_flag;
  /*
   * Note: We simply use a static buffer of reasonable size here.
   * Another implementation would hold a pointer to dynamically
   * allocated buffer space here (plus size variable). In fact,
   * the buffer size may be arbitrary, at least 1 Byte. This should
   * work well with the given codecs, but would be very slow. It is
   * recommended to use at least a couple of KBytes as reasonable
   * buffer size. In dynamic case, using a buffer for full input
   * file size is most efficient (only one buffer read hook).
   */
  char fbuf[BUF_LENGTH];
}
FBUF;

static void Fbufread(FBUF *fp)
{
  long count;

  if ((count = Fread(fp->handle, BUF_LENGTH, fp->fbuf)) > 0)
  {
    fp->length += count;
    fp->pub.bytes_left += count;
    fp->pub.pbuf = fp->fbuf;
  }
  else
  {
    fp->EOF_flag++;
    /* Return to top level routine on short read. */
    longjmp(jmp_buffer, 1);
} }

static void Fbufwrite(FBUF *fp)
{
  long count;

  if ((count = BUF_LENGTH - fp->pub.bytes_left) != 0)
  {
    fp->length += count;
    fp->pub.bytes_left += count;
    fp->pub.pbuf = fp->fbuf;
    if (fp->EOF_flag == 0)
      if (Fwrite(fp->handle, count, fp->fbuf) != count)
	fp->EOF_flag++;
} }

static FBUF input;
static FBUF output;

static short out_lev;
static short out_pat;

static char inpath[128];
static char outpath[128];

static IMG_HEADER header;

static void Usage(void)
{
  fprintf(stderr, "Usage:  ximgtool [options] input [output]\n");
  fprintf(stderr, "options:\n");
  fprintf(stderr, "\t-lN: Use Level-N encoding, N=1..3.\n");
  fprintf(stderr, "\t     Default is input value cropped to 1..3.\n");
  fprintf(stderr, "\t-pN: Force output pattern run N, N=1..2.\n");
  fprintf(stderr, "\t     Default is input value cropped to 1..2.\n");
  fprintf(stderr, "\t-i:  Identify only.\n");
#ifdef __TOS__
  fprintf(stderr, "\t-m:  Multiple mode.\n");
#endif
  fprintf(stderr, "input:\n");
  fprintf(stderr, "\t(X)IMG source file"
#ifdef __TOS__
		  " (pattern if -m)"
#endif
		  ".\n");
  fprintf(stderr, "output:\n");
  fprintf(stderr, "\t(X)IMG destination file"
#ifdef __TOS__
		  " (folder if -m)"
#endif
		  ".\n");
}

int main(int argc, char **argv)
{
  int ident, mult;
  short outlev, outpat;
  char *inname, *outname;

  fprintf(stdout,
    "\nXIMGTOOL " __DATE__ " -- Tool for XIMG Level-1/2/3 files.\n\n");

  if (--argc <= 0) {
    Usage(); return 0;
  }
  ++argv;

  ident = mult = 0; outlev = outpat = 0;
  while (argv[0][0] == '-') {
    if (argv[0][1] == 'l' || argv[0][1] == 'L') {
      if (argv[0][2] == '1') outlev = 1;
      else if (argv[0][2] == '2') outlev = 2;
      else if (argv[0][2] == '3') outlev = 3;
      else fprintf(stderr, "Ignoring invalid option %s\n", argv[0]);
    }
    else if (argv[0][1] == 'p' || argv[0][1] == 'P') {
      if (argv[0][2] == '1') outpat = 1;
      else if (argv[0][2] == '2') outpat = 2;
      else fprintf(stderr, "Ignoring invalid option %s\n", argv[0]);
    }
    else if (argv[0][1] == 'i' || argv[0][1] == 'I') ident = 1;
#ifdef __TOS__
    else if (argv[0][1] == 'm' || argv[0][1] == 'M') mult = 1;
#endif
    else fprintf(stderr, "Ignoring invalid option %s\n", argv[0]);

    if (--argc <= 0) {
      Usage(); return 0;
    }
    ++argv;
  }
#ifdef __TOS__
  if (mult) {
    static DTA mydta;
    Fsetdta(&mydta);
    if (Fsfirst(argv[0], 0x27)) {
      fprintf(stderr, "Can't find matching file %s\n", argv[0]);
      return 0;
    }
    strcpy(inpath, argv[0]);
    inname = strrchr(inpath, '\\');
    if (inname) inname++;
    else {
      inname = inpath;
      if (inname[0] && inname[1] == ':')
	inname += 2;
    }
    outname = 0;
    if (argv[1]) {
      outname = strcpy(outpath, argv[1]);
      while (*outname++);
      outname--;
    }
    do {
      strcpy(inname, mydta.d_fname);
      if (outname) {
	strcpy(outname, mydta.d_fname);
	do_proc(inpath, outpath, outlev, outpat, ident);
      }
      else do_proc(inpath, 0, outlev, outpat, ident);
    }
    while (Fsnext() == 0);
  }
  else
#endif
    do_proc(argv[0], argv[1], outlev, outpat, ident);
  return 0;
}

static void encode_exit(void)
{
  /* Return to top level routine if image end is reached. */
  longjmp(jmp_buffer, 2);
}

static void do_proc(char *src, char *des, short outlev, short outpat, int ident)
{
  IBUFPUB *image;
  int error;

  out_lev = outlev; out_pat = outpat;

  if ((input.handle = Fopen(src, 0)) < 0) {
    fprintf(stderr, "Can't open input file %s\n", src);
    return;
  }
  input.EOF_flag = 0; input.length = 0;
  input.pub.bytes_left = 0;
  /* Note: pub.pbuf entry does not need to be set here. */
  input.pub.data_func = (void (*)(FBUFPUB *))Fbufread;

  if (ident == 0) {
    if (des == 0) {
      output.handle = -1; output.EOF_flag = 1;
    }
    else {
#ifdef __TOS__
      if ((output.handle = Fcreate(des, 0)) < 0) {
#else
      static struct stat sbuf;
      stat(src, &sbuf);
      if ((output.handle = creat(des, sbuf.st_mode)) < 0) {
#endif
	fprintf(stderr, "Can't create output file %s\n", des);
	Fclose(input.handle);
	return;
      }
      output.EOF_flag = 0;
    }
    output.length = 0;
    output.pub.bytes_left = sizeof(output.fbuf);
    output.pub.pbuf = output.fbuf;
    output.pub.data_func = (void (*)(FBUFPUB *))Fbufwrite;
  }

  fprintf(stdout, "%s\n", src);
  if (setjmp(jmp_buffer)) {
    fprintf(stdout, "  is not a valid IMG file at all!\n");
    if (ident == 0) {
      if (output.handle >= 0) {
	Fclose(output.handle); Fdelete(des);
      }
      ident = 1;
    }
  }
  else {
    ProcHeader(ident);
    fprintf(stdout, "  is a %dx%d (X)IMG file with %ld colors (l=%d,p=%d).\n",
	    header.sl_width, header.sl_height, 1L << header.planes,
	    header.version, header.pat_run);
    if (ident == 0) {
      image = encode_init(&header, &output.pub,
			  Malloc, encode_exit,
			  out_lev, out_pat);
      if (image == 0) {
	fprintf(stderr, "  Insufficient memory!\n");
	if (output.handle >= 0) {
	  Fclose(output.handle); Fdelete(des);
	}
	ident = 1;
      }
      else {
	if (setjmp(jmp_buffer) == 0)

	  /* OK, here's the real work... */
	  level_3_decode(&input.pub, image);

	/* Flush out last line(s) in case of short read break. */
	(*image->put_line)(image);

	Mfree(image);
	/* My, that was easy, wasn't it? */
      }
    }
  }

  /* Done. Check for errors, print statistics... */
  error = 0;
  if (input.EOF_flag) {
    error = 1;
    fprintf(stderr,
      "  Warning: Read Error or Premature EOF encountered in input stream!\n");
  }
  if (ident == 0) {
    Fbufwrite(&output); /* Flush out last bytes from buffer. */
    if (output.handle >= 0) {
      if (output.EOF_flag) {
	error = 1;
	fprintf(stderr, "  Warning: Write Error occured in output file!\n");
      }
      if (Fclose(output.handle)) {
	error = 1;
	fprintf(stderr, "  Warning: Error in closing output file!\n");
      }
    }
    if (error == 0) fprintf(stderr, "  Successful end of processing.\n");
    fprintf(stdout, "  %ld input bytes, %ld output bytes, %ld saved bytes\n",
	    input.length, output.length, input.length - output.length);
  }
  Fclose(input.handle);
}

static void ProcHeader(int ident)
{
  short save_l, save_p, temp, *p;
  long count;

  p = (short *)&header; count = sizeof(header);
  do { FGETW(&input.pub, temp); *p++ = temp; } while (count -= 2);
  /*
   * Sanity check. Po'bly to restrictive, but ensures
   * reliability of actual code.
   */
  if (header.sl_width <= 0 ||
      header.sl_height <= 0 ||
      header.planes <= 0 ||
      header.version < 0 ||
      header.pat_run < 0) longjmp(jmp_buffer, 3);
  if (ident == 0) {
    save_l = header.version;
    save_p = header.pat_run;
    if (out_lev == 0) out_lev = save_l > 3 ? 3 : save_l < 1 ? 1 : save_l;
    if (out_pat == 0) out_pat = save_p > 2 ? 2 : save_p < 1 ? 1 : save_p;
    header.version = out_lev;
    header.pat_run = out_pat;
    p = (short *)&header; count = sizeof(header);
    do { temp = *p++; FPUTW(&output.pub, temp); } while (count -= 2);
    header.version = save_l;
    header.pat_run = save_p;
    count = ((long)header.headlen << 1) - sizeof(header);
    while (--count >= 0) FCOPYC(&input.pub, &output.pub);
  }
}
