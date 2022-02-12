/* btoa - binary to ascii	Authors: P. Rutter, J. Orost, & S. Parmark */

/*************************************************************************
     Btoa is a filter which reads binary  bytes  from  the  input
     file  and generates printable ASCII characters on the output
     file. It attaches a header and a checksum to the archive. It
     can  also  reverse  this,  creating  a  binary file from the
     archive.

     Since last version of btoa/atob, several new  features  have
     been  added.  The  most  obvious  one  is that atob has been
     integrated with btoa. They are now the same program which is
     called  with  different arguments. Another is the ability to
     repair damaged archives.

     The new version is compatible with the old version, that is,
     it can still encode and decode old btoa files.

     Btoa has an option to  decode  the  archive,  restoring  the
     binary  bytes.   It  strips  the input file until it finds a
     valid header, and continues decoding until the end  mark  is
     found.  It  recognices  both old- and new-style headers, and
     can decode both. It is possible to leave out the destination
     name  when  decoding new-style archives, because the name is
     stored in the header. Entering  a  name  will  override  the
     autonaming function.

     It is possible to leave out  the  file  names  and  redirect
     stdin and stdout with '<' and '>' to the desired files. This
     is to maintain compatibility with earlier versions of btoa.

     Btoa now adds a single byte checksum  to  each  row  in  the
     archive.   When  an  error is found, diagnosis automatically
     starts and produces a diagnosis file which can  be  used  to
     extract  the  damaged  part  from  an errorfree archive. The
     extracted part can then  be  used  to  correct  the  damaged
     archive.    Btoa  has  options  to  perform  the  reparation
     automatically. This is especially  useful  when  downloading
     data  converted to text files, and occasionally finding that
     an archive file of considerable size turns is corrupted.

FEATURES
     Btoa encodes 4 binary bytes into 5 characters, expanding the
     file  by  25%. As a special case 4 zeroes will be encoded as
     'z' and 4 spaces as 'y'. This makes it possible to  compress
     the archive a bit.

EXAMPLES
     Below follows a description  of  a  normal  repair  session.
     Lines  beginning with 'Local>' were typed on the computer to
     which the file was downloaded. Accordingly, lines  typed  on
     the  connected computer will begin with 'Remote>'. Sending a
     file to the other computer will be noted as 'transmit file'.

     A normal repairing procedure is as follows: Local>  btoa  -a
     file.btoa  btoa:  Bad checksum on line 2648.  btoa: Starting
     diagnosis.  btoa: Diagnosis output  to  'btoa.dia'.   Local>
     transmit btoa.dia

     Remote> btoa -d file.btoa btoa: Repair output to 'btoa.rep'.
     Remote> transmit btoa.rep

     Local> btoa -a btoa.rep btoa: Repaired  archive  written  to
     'btoa.rdy'.

     You can now erase file.btoa and decode btoa.rdy using  'btoa
     -a btoa.rdy'.

*************************************************************************/

#include <sys/types.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define MAXPERLINE      78
#define BUFSIZE         100
#define TRUE            1
#define FALSE           0
#define USE_MACROS      TRUE

#define BYTE            char
#define WORD            short
#define LONG            long

#define ENCODE(ch)      ( (int) ((ch) + '!') )
#define DECODE(ch)      ( (int) ((ch) - '!') )

struct Diagnosis {
  LONG startpos, endpos;	/* Line before and after erroneous area */
  struct Diagnosis *next, *last;
};

/* Following functions have been converted to macros:  calcchecksum() */

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(BYTE btoa, (FILE *infile, BYTE *infilename));
_PROTOTYPE(void printhelp, (void));
_PROTOTYPE(void calcchecksum, (int ch));
_PROTOTYPE(void wordout, (LONG codeword));
_PROTOTYPE(void asciiout, (int ch));
_PROTOTYPE(BYTE *truncname, (BYTE *name));
_PROTOTYPE(BYTE atob, (FILE *infile));
_PROTOTYPE(int nextbyte, (FILE *infile));
_PROTOTYPE(BYTE new_decodefile, (FILE *infile, LONG *lastline, LONG filepos, int maxperline));
_PROTOTYPE(BYTE old_decodefile, (FILE *infile, LONG *lastline));
_PROTOTYPE(BYTE decode_line, (BYTE *buffer, int length));
_PROTOTYPE(void producediag, (struct Diagnosis *diaglist, FILE *infile));
_PROTOTYPE(void intodiaglist, (struct Diagnosis *diaglist, LONG startpos, LONG endpos));
_PROTOTYPE(void outdiaglist, (struct Diagnosis *diaglist, LONG *startpos, LONG *endpos));
_PROTOTYPE(BYTE copyfile, (FILE *infile, FILE *outfile, BYTE *searchstring));
_PROTOTYPE(BYTE readbuffer, (BYTE *buffer, BYTE *errormsg, FILE *infile));
_PROTOTYPE(FILE *fopen_read, (BYTE *filename));
_PROTOTYPE(FILE *fopen_write, (BYTE *filename));
_PROTOTYPE(BYTE pro_repair, (FILE *infile));
_PROTOTYPE(BYTE performrepair, (FILE *infile));

/* Chksum.h */
/* Calcchecksum() was converted to a macro for effectivity reasons. */
/* Don't (!!) give it an argument that has to be evaluated. This    */
/* Is guaranteed to slow it down.                                   */

/* Update file checksums. */

#define calcchecksum(ch)        \
{                               \
  Ceor ^= ch;                   \
  Csum += ch + 1;               \
                                \
  if (Crot & 0x80000000L)       \
  {                             \
    Crot <<= 1;                 \
    Crot ++;                    \
  }                             \
  else                          \
    Crot <<= 1;                 \
                                \
  Crot += ch;                   \
}

/* Btoa.c */

/* Written by Paul Rutter, Joe Orost & Stefan Parmark. */

#ifdef AMIGA
#include <stdlib.h>
#include <string.h>
#endif /* AMIGA */


#define VERSION  "5.2"

LONG Ceor, Csum, Crot;		/* Checksums to verify archive validity. */
BYTE new_version, openoutput, buffer[BUFSIZE];
FILE *outfile;


int main(argc, argv)
int argc;
char **argv;
{
  register BYTE openinput, error, ch, a_to_b, diag, repair;
  register BYTE *infilename, *text;
  register FILE *infile;
#ifdef AMIGA
  extern int _bufsiz;

  /* Change file buffer size. */
  _bufsiz = 10240;
#endif /* AMIGA */

  error = openinput = openoutput = a_to_b = diag = repair = FALSE;
  new_version = TRUE;
  infilename = NULL;

  /* Scan for '-' options. The rest must be file names. */
  while (!error && argc > 1 && *argv[1] == '-') {
	text = &argv[1][1];
	while (!error && (ch = *text++) != 0) {
		switch (ch) {
		    case 'a':	/* Activate atob. */
			a_to_b = TRUE;
			break;
		    case 'd':	/* Extract missing part from
				 * undamaged archive. */
			diag = TRUE;
			break;
		    case 'h':	/* Print help and abort execution. */
			error = TRUE;
			break;
		    case 'o':	/* Use old btoa format. */
			new_version = FALSE;
			break;
		    case 'r':	/* Repair damaged archive. */
			repair = TRUE;
			break;
		    default:	error = TRUE;
		}
	}
	argv++;
	argc--;
  }

  if (argc > 3) error = TRUE;

  if (error)
	printhelp();
  else {
	/* If file name was given, try to open file. Otherwise use stdin. */
	if (argc > 1) {
		infilename = argv[1];
		if ((infile = fopen_read(infilename)) == NULL)
			error = TRUE;
		else
			openinput = TRUE;
	} else
		infile = stdin;
  }

  if (!error) {
	/* If file name was given, try to open file. Otherwise use stdout. */
	if (argc > 2 && !diag && !repair) {
		if ((outfile = fopen_write(argv[2])) == NULL)
			error = TRUE;
		else
			openoutput = TRUE;
	} else
		outfile = stdout;
  }
  if (!error) {
	if (diag)
		error = pro_repair(infile);
	else if (repair)
		error = performrepair(infile);
	else if (a_to_b)
		error = atob(infile);
	else
		error = btoa(infile, infilename);
  }

  /* Close all opened files. */
  if (openinput) fclose(infile);
  if (openoutput) fclose(outfile);

  if (error) exit(1);
  return(0);
}


BYTE btoa(infile, infilename)
register FILE *infile;
register BYTE *infilename;
{
  register LONG codeword, filesize;
  register int ch1, ch2, ch3, ch4, readbytes;

  Ceor = Csum = Crot = 0;

  /* Write archive header. */
  if (new_version) {
	fprintf(outfile, "xbtoa5 %d %s Begin\n", MAXPERLINE,
		(infilename == NULL) ? "-" : truncname(infilename));
  } else
	fprintf(outfile, "xbtoa Begin\n");

  /* Encode entire input file. */
  filesize = 0;
  do {
	readbytes = fread(buffer, (size_t)1, (size_t)4, infile);

	if (readbytes < 4) {
		ch1 = (readbytes > 0) ? ((int) buffer[0] & 0xFF) : 0;
		ch2 = (readbytes > 1) ? ((int) buffer[1] & 0xFF) : 0;
		ch3 = (readbytes > 2) ? ((int) buffer[2] & 0xFF) : 0;
		ch4 = 0;
	} else {
		ch1 = (int) buffer[0] & 0xFF;
		ch2 = (int) buffer[1] & 0xFF;
		ch3 = (int) buffer[2] & 0xFF;
		ch4 = (int) buffer[3] & 0xFF;
	}

	if (readbytes > 0) {
		if (!new_version) {
			calcchecksum(ch1);
			calcchecksum(ch2);
			calcchecksum(ch3);
			calcchecksum(ch4);
		}
		codeword = (ch1 << 8) | ch2;
		codeword = (((codeword << 8) | ch3) << 8) | ch4;
		wordout(codeword);

		filesize += readbytes;
	}
  }
  while (readbytes == 4);

  asciiout(EOF);		/* Flush buffer. */

  /* Filesize is written twice as crude cross check. */
  fprintf(outfile, "xbtoa End N %ld %lx E %lx S %lx R %lx\n",
	filesize, filesize, Ceor, Csum, Crot);

  return(FALSE);		/* No errors discovered. */
}


/* Print help on how to use btoa. */
void printhelp()
{
  fprintf(stderr, "              Btoa version %s\n", VERSION);
  fprintf(stderr, "Written by Paul Rutter, Joe Orost & Stefan Parmark.\n");

  fprintf(stderr, "\nUsage: btoa [-{adhor}] [input file] [output file]\n");

  fprintf(stderr, "\nOptions:\n");
  fprintf(stderr, "-h  Shows this help list.\n");
  fprintf(stderr, "-a  Use atob rather than btoa.\n");
  fprintf(stderr, "-o  Use old version of btoa.\n");
  fprintf(stderr, "-d  Extract repair file from diag file.\n");
  fprintf(stderr, "-r  Repair archive from repair file.\n");

  fprintf(stderr, "\nExamples:\n");
  fprintf(stderr, "  btoa -h\n");
  fprintf(stderr, "  btoa [input binary file] [output archive file]\n");
  fprintf(stderr, "  btoa -o [input binary file] [output archive file]\n");
  fprintf(stderr, "  btoa -a [input archive file] [output binary file]\n");
  fprintf(stderr, "  btoa -d [undamaged archive file]\n");
  fprintf(stderr, "  btoa -r [damaged archive file]\n");
}


#if !USE_MACROS
/* Update file checksums. */
void calcchecksum(ch)
register int ch;
{
  Ceor ^= ch;
  Csum += ch + 1;

  if (Crot & 0x80000000L) ch++;
  Crot <<= 1;
  Crot += ch;
}

#endif /* !USE_MACROS */


/* Encode 4 binary bytes to 5 ascii bytes. */
void wordout(codeword)
register LONG codeword;
{
  register int tmp, quote;

  if (codeword == 0)		/* Encode 4 zeros as a 'z'. */
	asciiout('z');
  else if (new_version && codeword == 0x20202020)
	/* Encode 4 spaces as a 'y'. */
	asciiout('y');
  else {
	tmp = 0;

	/* Extra calculations because some machines don't support */
	/* Unsigned longwords.                                    */
	if (codeword < 0) {
		tmp = 32;
		codeword -= (LONG) (85L * 85 * 85 * 85 * 32);
	}
	if (codeword < 0) {
		tmp = 64;
		codeword -= (LONG) (85L * 85 * 85 * 85 * 32);
	}

	/* Write 5 ascii bytes representing 4 binary bytes. */

	quote = codeword / (LONG) (85L * 85 * 85 * 85);
	codeword -= quote * (LONG) (85L * 85 * 85 * 85);
	asciiout(ENCODE(quote + tmp));

	quote = codeword / (LONG) (85L * 85 * 85);
	codeword -= quote * (LONG) (85L * 85 * 85);
	asciiout(ENCODE(quote));

	quote = codeword / (LONG) (85L * 85);
	codeword -= quote * (LONG) (85L * 85);
	asciiout(ENCODE(quote));

	quote = (int) codeword / 85;
	codeword -= quote * 85;
	asciiout(ENCODE(quote));

	asciiout(ENCODE((int) codeword));
  }
}


/* Write ch to outfile. Write '\n' for every line. */
void asciiout(ch)
register int ch;
{
  static WORD linepos = 0;

  if (ch == EOF) {		/* Signal to flush buffer. */
	/* Linepos == 0 means '\n' just written in asciiout(). This */
	/* Avoids bug in BITNET, which changes blank line to spaces. */
	if (linepos != 0) {
		if (new_version)
			fputc(ENCODE(Csum % 85), outfile);	/* Checksum for every
								 * line. */
		fputc('\n', outfile);
	}
  } else {
	fputc(ch, outfile);
	linepos++;

	if (new_version) {
		calcchecksum(ch);
		if (linepos >= (MAXPERLINE - 1)) {
			fputc(ENCODE(Csum % 85), outfile);	/* Checksum for every
								 * line. */
			fputc('\n', outfile);
			linepos = 0;
		}
	} else
	 /* Old version */ if (linepos >= MAXPERLINE) {
		fputc('\n', outfile);
		linepos = 0;
	}
  }
}


/* Remove paths from a file name. */
BYTE *truncname(name)
register BYTE *name;
{
  register BYTE ch, *newname;

  newname = name;
  while ((ch = *name++) != 0)
	if (ch == '/' || ch == ':') newname = name;

  return(newname);
}

/* Atob.c */

/* Written by Paul Rutter, Joe Orost & Stefan Parmark. */

#ifdef AMIGA
#include <stdlib.h>
#include <string.h>
#endif /* AMIGA */



BYTE atob(infile)
register FILE *infile;
{
  register BYTE error;
  register LONG filepos;
  int maxperline;
  LONG n1, n2, oeor, osum, orot, lastline;
  static BYTE outfilename[BUFSIZE];

  error = FALSE;

  /* Search for archive header. */
  do {
	filepos = ftell(infile);

	if (readbuffer(buffer, "archive", infile)) error = TRUE;
  }
  while (!(error || strncmp(buffer, "xbtoa", (size_t)5) == 0));

  if (!error)
	if (strcmp(buffer, "xbtoa Begin\n") == 0) {
		new_version = FALSE;
		fprintf(stderr, "btoa: Old btoa format.\n");
	} else if (sscanf(buffer, "xbtoa5 %d %s Begin\n", &maxperline, outfilename) == 2) {
		new_version = TRUE;
		/* Naming a file overrides the read-name-from-file
		 * function. */
		if (!openoutput && strcmp(outfilename, "-") != 0)
			if ((outfile = fopen_write(outfilename)) == NULL)
				error = TRUE;
			else
				openoutput = TRUE;
	} else {
		fprintf(stderr, "btoa: Illegal archive header.\n");
		error = TRUE;
	}

  if (!error) {
	Ceor = Csum = Crot = 0;

	if (new_version)
		error = new_decodefile(infile, &lastline, filepos, maxperline);
	else
		error = old_decodefile(infile, &lastline);
  }
  if (!error) {
	if (sscanf(buffer, "xbtoa End N %ld %lx E %lx S %lx R %lx\n",
		   &n1, &n2, &oeor, &osum, &orot) != 5) {
		fprintf(stderr, "btoa: Bad format on line %ld. Can't repair file.\n",
			lastline);
		error = TRUE;
	} else if ((n1 != n2) || (oeor != Ceor) || (osum != Csum) || (orot != Crot)) {
		fprintf(stderr, "btoa: Bad file checksum. Can't repair file.\n");
		error = TRUE;
	} else
		/* Flush last characters. */
		decode_line((BYTE *) NULL, (int) ((n1 - 1) & 0x03));
  }
  return(error);
}


/* Peek at the next byte without moving the file pointer. */
int nextbyte(infile)
register FILE *infile;
{
  register int ch;
  register LONG filepos;

  filepos = ftell(infile);
  ch = fgetc(infile);
  fseek(infile, filepos, 0);

  return(ch);
}


BYTE new_decodefile(infile, lastline, filepos, maxperline)
register FILE *infile;
LONG *lastline, filepos;
int maxperline;
{
  register int length;
  int ch;
  register BYTE stop, error, newerror, errorstart;
  register LONG line, prevfilepos, startpos;
  struct Diagnosis diaglist;

  error = FALSE;

  line = 1;			/* Current line number. */

  /* A sequence of errors is indicated by errorstart. When it */
  /* Changes from TRUE to FALSE a diag record will be    */
  /* Generated.                                               */
  stop = errorstart = FALSE;

  /* File position of the line before the error sequence.     */
  /* That is the last correct line.                           */
  startpos = 0;

  while (!stop) {
	prevfilepos = filepos;
	filepos = ftell(infile);

	/* Newerror indicates an error on the current line. */
	newerror = FALSE;

	line++;
	if (readbuffer(buffer, "archive", infile))
		newerror = stop = TRUE;
	else if (buffer[0] == 'x')	/* End of archive found. */
		stop = TRUE;
	else if ((length = strlen(buffer) - 1) != maxperline ||
		 buffer[length] != '\n') {
		/* If last character wasn't end-of-line, then we */
		/* Have to read until it is found.               */
		if (buffer[length] != '\n') {
			newerror = TRUE;
			while ((ch = fgetc(infile)) != EOF && (BYTE) ch != '\n');
			if (ch == EOF) stop = TRUE;
		} else if (length > maxperline || nextbyte(infile) != 'x') {
			newerror = TRUE;
			Csum = DECODE(buffer[length - 1]);	/* Make Csum correct
								 * (modulo 85). */
		}
		if (newerror)
			fprintf(stderr, "btoa: Bad line length on line %ld.\n", line);
		if (!(newerror || stop)) {
			if (decode_line(buffer, length - 1)) {
				if (!error)
					fprintf(stderr, "btoa: Bad character on line %ld.\n", line);
				newerror = TRUE;
			}
	
			/* Examine checksum. */
			if ((ch = buffer[length - 1]) == ENCODE(Csum % 85)) {
				if (errorstart) {
					intodiaglist(&diaglist, startpos, filepos);
					errorstart = FALSE;
				}
			} else {
				newerror = TRUE;
				fprintf(stderr, "btoa: Bad checksum on line %ld.\n", line);
				Csum = DECODE(ch);	/* Make Csum correct
							 * (modulo 85). */
			}
		}
	}
	if (newerror) {
		if (!error) {
			fprintf(stderr, "btoa: Starting diag.\n");
			diaglist.next = diaglist.last = NULL;
		}
		error = TRUE;
		if (!errorstart) {
			errorstart = TRUE;
			startpos = prevfilepos;
		}
	}
  }

  if (error) {
	if (errorstart) intodiaglist(&diaglist, startpos, filepos);
	producediag(&diaglist, infile);
  }
  *lastline = line;

  return(error);
}



BYTE old_decodefile(infile, lastline)
register FILE *infile;
LONG *lastline;
{
  register int length;
  register BYTE stop, error;
  register LONG line;

  error = FALSE;

  line = 1;
  stop = FALSE;
  while (!stop) {
	line++;

	if (readbuffer(buffer, "archive", infile))
		error = stop = TRUE;
	else if (buffer[0] == 'x')	/* End of archive found. */
		stop = TRUE;
	else {
		length = strlen(buffer) - 1;
		if (buffer[length] != '\n')
			error = stop = TRUE;	/* The line was longer
						 * than the buffer. */
		else {
			if (decode_line(buffer, length)) {
				fprintf(stderr, "btoa: Bad character on line %ld.\n", line);
				error = stop = TRUE;
			}
		}
	}

  }

  *lastline = line;

  return(error);
}


BYTE decode_line(buf, length)
register BYTE *buf;
register int length;
{
  register int ch;
  register BYTE error;
  register LONG tmp_codeword;
  static LONG codeword;
  static int ch1, ch2, ch3, ch4;
  static BYTE bytecount = 0;

  error = FALSE;

  if (buf == NULL) {		/* Flush last characters. */
	if (bytecount > 0) {
		fputc(ch1, outfile);
		if (length > 0) fputc(ch2, outfile);
		if (length > 1) fputc(ch3, outfile);
		if (length > 2) fputc(ch4, outfile);
	}
  } else {
	while (length > 0) {
		length--;
		ch = *buf++;

		/* Delayed output. This is to make sure that files
		 * with lengths */
		/* That are not multiples of 4 won't become too long.           */
		if (bytecount == 5) {
			fputc(ch1, outfile);
			fputc(ch2, outfile);
			fputc(ch3, outfile);
			fputc(ch4, outfile);

			bytecount = 0;
		}
		if (new_version) calcchecksum(ch);

		if (((BYTE) ch >= '!') && ((BYTE) ch < ('!' + 85))) {	/* Valid characters. */
			/* See if we can take all 5 bytes and decode
			 * them right away. */
			/* That is, if all remaining bytes are on the
			 * current line.   */
			if (length >= 4 - bytecount) {
				length -= 4 - bytecount;

				if (bytecount == 0)
					codeword = DECODE(ch);
				else
					codeword = codeword * 85 + DECODE(ch);

				for (bytecount++; bytecount < 5; bytecount++) {
					ch = *buf++;
					if (new_version) calcchecksum(ch);
					codeword = codeword * 85 + DECODE(ch);
				}
			} else {
				/* Shift codeword and insert character. */

				if (bytecount == 0) {
					codeword = DECODE(ch);
					bytecount = 1;
				} else {	/* bytecount < 5 */
					codeword = codeword * 85 + DECODE(ch);
					bytecount++;
				}
			}

			if (bytecount == 5) {
				tmp_codeword = codeword;

				ch4 = (int) tmp_codeword & 0xFF;
				ch3 = (int) (tmp_codeword >>= 8) & 0xFF;
				ch2 = (int) (tmp_codeword >>= 8) & 0xFF;
				ch1 = (int) (tmp_codeword >> 8) & 0xFF;

				if (!new_version) {
					calcchecksum(ch1);
					calcchecksum(ch2);
					calcchecksum(ch3);
					calcchecksum(ch4);
				}
			}
		} else if ((BYTE) ch == 'z' || (new_version && (BYTE) ch == 'y')) {
			if (bytecount != 0)
				error = TRUE;
			else {
				ch1 = ch2 = ch3 = ch4 = (ch == 'z') ? 0 : ' ';
				if (!new_version) {
					calcchecksum(ch1);
					calcchecksum(ch1);
					calcchecksum(ch1);
					calcchecksum(ch1);
				}
				bytecount = 5;
			}
		} else
			error = TRUE;
	}
  }

  return(error);
}

/* Repair.c */

/* Written by Stefan Parmark. */

#ifdef AMIGA
#include <stdlib.h>
#include <string.h>
#endif /* AMIGA */


/* File names. */
BYTE *diagname = "btoa.dia";
BYTE *repairname = "btoa.rep";
BYTE *repairedname = "btoa.rdy";

/* File headers. */
BYTE *diagheader = "xdiag\n";
BYTE *repairheader = "xrepair\n";


/* Produce diag file from diagnoses records created by atob(). */
/* It contains the lines immediately before and after the error     */
/* Sequence.                                                        */
void producediag(diaglist, infile)
register struct Diagnosis *diaglist;
register FILE *infile;
{
  register FILE *diagfile;
  LONG startpos, endpos;
  register LONG currentpos;

  currentpos = ftell(infile);

  if ((diagfile = fopen_write(diagname)) != NULL) {
	fprintf(stderr, "btoa: Diagnosis output to '%s'.\n", diagname);

	fputs(diagheader, diagfile);
	do {
		/* Extract startpos & endpos from diaglist. */
		outdiaglist(diaglist, &startpos, &endpos);

		if (startpos != -1) {
			/* Print line before error. */
			fseek(infile, startpos, 0);
			fgets(buffer, BUFSIZE, infile);
			fputs(buffer, diagfile);

			/* Print line after error. */
			fseek(infile, endpos, 0);
			fgets(buffer, BUFSIZE, infile);
			fputs(buffer, diagfile);
		}
	}
	while (startpos != -1);
	fputs(diagheader, diagfile);

	fclose(diagfile);
  }

  /* Move file pointer to where it was when we entered. */
  fseek(infile, currentpos, 0);
}


/* Insert two file positions into diaglist. */
void intodiaglist(diaglist, startpos, endpos)
register struct Diagnosis *diaglist;
register LONG startpos, endpos;
{
  register struct Diagnosis *diagitem, *lastitem;

  diagitem = (struct Diagnosis *) malloc(sizeof(struct Diagnosis));
  diagitem->startpos = startpos;
  diagitem->endpos = endpos;
  diagitem->next = NULL;

  if ((lastitem = diaglist->last) == NULL)	/* List is empty */
	diaglist->next = diaglist->last = diagitem;
  else {
	if (lastitem->endpos >= startpos) {
		lastitem->endpos = endpos;
		free((BYTE *) diagitem);
	} else {
		lastitem->next = diagitem;
		diaglist->last = diagitem;
	}
  }
}


/* Extract two file positions from diaglist. */
void outdiaglist(diaglist, startpos, endpos)
register struct Diagnosis *diaglist;
LONG *startpos, *endpos;
{
  register struct Diagnosis *diagitem;

  if ((diagitem = diaglist->next) == NULL)	/* List is empty */
	*startpos = *endpos = -1;
  else {
	*startpos = diagitem->startpos;
	*endpos = diagitem->endpos;

	diaglist->next = diagitem->next;
	free((BYTE *) diagitem);
	if (diaglist->next == NULL)
	    diaglist->last = NULL;
  }
}


/* Copy infile to outfile until searchstring is found. If outfile */
/* Is NULL nothing will be written.                               */
BYTE copyfile(infile, outfil, searchstring)
register FILE *infile, *outfil;
register BYTE *searchstring;
{
  register BYTE stop, error;
  static BYTE copybuffer[BUFSIZE];

  stop = error = FALSE;
  while (!(stop || error))
	if (readbuffer(copybuffer, "archive", infile))
		error = TRUE;
	else {
		if (outfil != NULL) fputs(copybuffer, outfil);
		if (strcmp(copybuffer, searchstring) == 0) stop = TRUE;
	}

  return(error);
}


/* Read a line from infile into buffer. Returns TRUE if */
/* End-of-file has been reached.                        */
BYTE readbuffer(buf, errormsg, infile)
register BYTE *buf, *errormsg;
register FILE *infile;
{
  register BYTE error;

  error = FALSE;
  if (fgets(buf, BUFSIZE, infile) == NULL) {
	fprintf(stderr, "btoa: Unexpected end of %s file.\n", errormsg);
	error = TRUE;
  }
  return(error);
}


FILE *fopen_read(filename)
register BYTE *filename;
{
  register FILE *infile;

  if ((infile = fopen(filename, "r")) == NULL)
	fprintf(stderr, "btoa: Can't open '%s' for input.\n", filename);

  return(infile);
}


FILE *fopen_write(filename)
register BYTE *filename;
{
  register FILE *outfil;

  if ((outfil = fopen(filename, "w")) == NULL)
	fprintf(stderr, "btoa: Can't open '%s' for output.\n", filename);

  return(outfil);
}


/* Extract lines from original archive to fix the damaged one. */
BYTE pro_repair(infile)
register FILE *infile;
{
  register FILE *repairfile, *diagfile;
  register BYTE error, stop;
  static BYTE *errormsg = "diag";

  error = FALSE;
  diagfile = repairfile = NULL;

  fprintf(stderr, "btoa: Repair output to '%s'.\n", repairname);
  if ((diagfile = fopen_read(diagname)) == NULL)
	error = TRUE;
  else if ((repairfile = fopen_write(repairname)) == NULL) {
	fclose(diagfile);
	diagfile = NULL;
	error = TRUE;
  } else {
	/* Read until header is found. This makes it possible to   */
	/* Have junk before the header, such as an article header. */
	do {
		if (readbuffer(buffer, errormsg, diagfile)) error = TRUE;
	}
	while (!error && strcmp(buffer, diagheader) != 0);
	fputs(repairheader, repairfile);
  }

  stop = FALSE;
  while (!(error || stop)) {
	/* Loop until header is found again. */

	if (readbuffer(buffer, errormsg, diagfile))
		error = TRUE;
	else if (strcmp(buffer, diagheader) == 0)
		stop = TRUE;
	else {
		/* Read until line before error is found. */
		error = copyfile(infile, (FILE *) NULL, buffer);
		if (!error) {
			/* Print line before error. */
			fputs(buffer, repairfile);

			if (readbuffer(buffer, errormsg, diagfile))
				error = TRUE;
			else {
				/* Print line after error */
				fputs(buffer, repairfile);
				/* Copy infile to repairfile until
				 * line after error */
				error = copyfile(infile, repairfile, buffer);
			}
		}
	}
  }

  if (!error) fputs(repairheader, repairfile);

  if (repairfile != NULL) fclose(repairfile);
  if (diagfile != NULL) fclose(diagfile);

  return(error);
}


/* Repair damaged archive from repair file. */
BYTE performrepair(infile)
register FILE *infile;
{
  register FILE *repairfile, *outfile;
  register BYTE error, stop;
  static BYTE *errormsg = "repair";

  error = FALSE;
  repairfile = outfile = NULL;

  if ((repairfile = fopen_read(repairname)) == NULL)
	error = TRUE;
  else if ((outfile = fopen_write(repairedname)) == NULL) {
	fclose(repairfile);
	repairfile = NULL;
	error = TRUE;
  } else {
	fprintf(stderr, "btoa: Repaired archive written to '%s'.\n", repairedname);

	/* Read until header is found. */
	do {
		if (readbuffer(buffer, errormsg, repairfile)) error = TRUE;
	}
	while (!error && strcmp(buffer, repairheader) != 0);
  }

  stop = FALSE;
  while (!(error || stop)) {
	/* Loop until header is found. */

	if (readbuffer(buffer, errormsg, repairfile))
		error = TRUE;
	else if (strcmp(buffer, repairheader) == 0)
		stop = TRUE;
	else {
		/* Read and write until line before error. */
		error = copyfile(infile, outfile, buffer);
		if (!error)
			if (readbuffer(buffer, errormsg, repairfile))
				error = TRUE;
			else {
				/* Read and write until line after error. */
				error = copyfile(repairfile, outfile, buffer);
				/* Skip until line after error */
				copyfile(infile, (FILE *) NULL, buffer);
			}
	}
  }

  if (!error)			/* Write rest of archive. */
	while (fgets(buffer, BUFSIZE, infile) != (char *)NULL)
		fputs(buffer, outfile);

  if (outfile != (FILE *)NULL) fclose(outfile);
  if (repairfile != (FILE *)NULL) fclose(repairfile);

  return(error);
}
