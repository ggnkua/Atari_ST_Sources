/*
 * Uudecode -- decode a uuencoded file back to binary form.
 *
 * modified for Lattice C on the ST - 11.05.86 by MSD
 * modified for Alcyon on the ST -    10-24-86 by RDR
 * modified (a lot) for MWC on the ST 02/07/87 by JPHD 
 * (Some more to be done on the I/O speed...)
 *
 */

#include <stdio.h>
#include <osbind.h>

/*extern FILE *fopen();
  extern char *strcpy();
  char *getnword();
*/


#define MAXCHAR 127
#define LINELEN 80
#define FILELEN 64
#define CODEDLN 61
#define NORMLEN 45

char *mism = "Part suffix mismatch: <%> instead of <%>.\r\n";
#define SUBS1 	23
#define SUBS2	38

FILE  *fin, *fout;
char ifname[FILELEN];
char chtbl[MAXCHAR];
char *pos;
char blank, part = '\0';
int partn = (int)'a';
long lens;

/*
 * Bring back a pointer to the start of the nth word.
 */
char *uud_getnword(str, n) register char *str; register int n;
{
	while((*str == '\t') || (*str == ' ')) str++;
	if (! *str) return NULL;
	while(--n) {
		while ((*str != '\t') && (*str != ' ') && (*str)) str++;
		if (! *str) return NULL;
		while((*str == '\t') || (*str == ' ')) str++;
		if (! *str) return NULL;
	}
	return str;
}

int uudecode( char *path )
{

/*void main(argc, argv) int argc; char *argv[];
{
*/
	register int i, j;
	char dest[FILELEN], buf[LINELEN];

/*	if (argc < 2) {
		Console("Almost foolproof uudecode v1.0 15-Feb-1987 JPHD\r\n");
		Console("Usage: uudecode inputfile\r\n");
		exit(1);
	}
*/
	if ((fin = fopen(path /*argv[1]*/, "r")) == NULL) {
		Console("Cant open input file.\r\n");
	/*	exit(2); */
		return(2);
	}

/*
 * Set up the default translation table. 
 */
	for (i = 0; i < ' '; i++) chtbl[i] = '\0';
	for (i = ' ', j = 0; i < ' ' + 64; i++, j++) chtbl[i] = j;
	for (i = ' ' + 64; i < MAXCHAR; i++) chtbl[i] = '\0';
	chtbl['`'] = chtbl[' '];	/* common mutation */
	chtbl['~'] = chtbl['^'];	/* an other common mutation */
	blank = ' ';
/*
 * search for header or translation table line.
 */
	for (;;) {
		if (fgets(buf, sizeof buf, fin) == NULL) {
			Console("No begin line\r\n");
		/*	exit(3); */
			return(3);
		}
		if (strncmp(buf, "table", 5) == 0) {
			i = uud_gettable();
			if (i!=0) { return(i); }
			continue;
		}
		if (strncmp(buf, "begin", 5) == 0) {
			break;
		}
	}
	lens = strlen(buf);
	if (lens) buf[--lens] = '\0';
	if ((pos = uud_getnword(buf, 3)) == NULL) {
		Console("Missing filename in begin line.\r\n");
	/*	exit(10); */
		return(10);
	} else
		strcpy(dest, pos);

	if((fout = fopen(dest, "wb")) == NULL) {
		Console("Cannot open output file\r\n");
	/*	exit(4); */
		return(4);
	}
	uud_decode();
	fclose(fout);
	fclose(fin);
/*	exit(0); */
	return(0);
}

/*
 * Install the table in memory for later use.
 */
int uud_gettable()
{
	char buf[LINELEN];
	register int c, n = 0;
	register char *cpt;

	for (c = 0; c <= MAXCHAR; c++) chtbl[c] = '\0';

again:	if (fgets(buf, sizeof buf, fin) == NULL) {
		Console("EOF while in translation table.\r\n");
	/*	exit(5); */
		return(5);
	}
	if (strncmp(buf, "begin", 5) == 0) {
		Console("Incomplete translation table.\r\n");
	/*	exit(6); */
		return(6);
	}
	cpt = buf + strlen(buf) - 1;
	*cpt = ' ';
	while (*(cpt) == ' ') {
		*cpt = '\0'; 
		cpt--;
	}
	cpt = buf;
	while (c = *cpt) {
		if (chtbl[c] != '\0') {
			Console("Duplicate char in translation table.\n");
		/*	exit(6); */
			return(6);
		}
		if (n == 0) blank = c;
		chtbl[c] = n++;
		if (n >= 64) return(0);
		cpt++;
	}
	goto again;
}

/*
 * copy from in to out, decoding as you go along.
 */

void uud_decode()
{
	char buf[LINELEN], outl[LINELEN];
	register char *bp, *ut, *trtbl = chtbl;
	register unsigned long n, c, len;

	for (;;) {
		if (fgets(buf, sizeof buf, fin) == NULL) {
			Console("Short file.\r\n");
			return;
		}
		len = strlen(buf);
		if (len) buf[--len] = '\0';
/*
 * Get the binary line length.
 */
		n = trtbl[*buf];
		if (n == NORMLEN) goto decod;
/*
 * end of uuencoded file ?
 */
		if (strncmp(buf, "end", 3) == 0) return;
/*
 * end of current file ? : get next one.
 */
		if (strncmp(buf, "include", 7) == 0) {
			uud_getfile(buf);
			continue;
		}
/*
 * Is it the empty line before the end line ?
 */
		if (n <= 0) continue;
/*
 * Pad with blanks.
 */
decod:		for (bp = &buf[c = len];
			 c < CODEDLN; c++, bp++) *bp = blank;

/*
 * output a group of 3 bytes (4 input characters).
 * the input chars are pointed to by p, they are to
 * be output to file f.  n is used to tell us not to
 * output all of them at the end of the file.
 */
		ut = outl;
		len = n;
		bp = &buf[1];
		while (n > 0) {
			*(ut++) = trtbl[*bp] << 2 | trtbl[bp[1]] >> 4;
			n--;
			if (n) {
				*(ut++) = trtbl[bp[1]] << 4 | trtbl[bp[2]] >> 2;
				n--;
			}
			if (n) {
				*(ut++) = trtbl[bp[2]] << 6 | trtbl[bp[3]];
				n--;
			}
			bp += 4;
		}
		n = fwrite(outl, 1, len, fout);
	}
}

/* you may need to rename the filenames at the ends of each part
* if the encoder encoded them on directories and specified drives.
*/
void uud_getfile( char *buf)
{
	int i;

	if ((pos = uud_getnword(buf, 2)) == NULL) {
		Console("Missing include file name.\r\n");
	/*	exit(11); */
		return;
	} else
		strcpy(ifname, pos);

	if (freopen(ifname, "r", fin) != fin) {
		Console("Cannot reassign input file to included file.\r\n");
	/*	exit(7); */
		return;
	}
	for (;;) {
		if (fgets(buf, LINELEN, fin) == NULL) {
			Console("No begin line in included file: ");
			Console(ifname);
			Console(".\r\n");
		/*	exit(3); */
			return;
		}

		if (strncmp(buf, "table", 5) == 0) {
			i = uud_gettable();
			if (i!=0) { return; }
			continue;
		}
		if (strncmp(buf, "begin", 5) == 0) {
			break;
		}
	}
	lens = strlen(buf);
	if (lens) buf[--lens] = '\0';
	if ((pos = uud_getnword(buf, 3)) == NULL ) {
		Console("Missing part name, in included begin line.\r\n");
		part = '?';
	} else {
		part = *pos;
/*
 * Check the part suffix.
 */
		partn++;
		if (part != partn) {
			mism[SUBS1] = part;
			mism[SUBS2] = partn;
			Console(mism);
		}
	}
}

/*
 * Output to console, immune against redirection of stdout.
 */
void Console(s) register char *s;
{
	while (*s) Bconout(2,*s++);
}
