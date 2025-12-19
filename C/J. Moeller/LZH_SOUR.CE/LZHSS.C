/* #define protect */

/**************************************************************
	LZSS.C -- A Data Compression Program
	(tab = 4 spaces)
***************************************************************
	4/6/1989 Haruhiko Okumura
	Use, distribute, and modify this program freely.
	Please send me your improved versions.
		PC-VAN		SCIENCE
		NIFTY-Serve	PAF01022
		CompuServe	74050,1022
**************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* #define _shell_  */
#define _lzst_  
#ifdef _lzst_
  #define from extern
#else  
  #define from 
#endif

#define N		 4096	/* size of ring buffer */
#define F		   18	/* upper limit for match_length */
#define THRESHOLD	2   /* encode string into position and length
						   if match_length is greater than this */
#define NIL			N	/* index for root of binary search trees */
#define RDERR		13
#define WTERR		14
#define MAXBLK		64

extern FILE *infile, *outfile;
extern char *infname, *outfname;
extern unsigned char flg_n;

#ifdef _shell_
  extern unsigned long textsize,codesize;
#else
unsigned long 	textsize = 0,	/* text size counter */
    	 codesize = 0;			/* code size counter */
#endif

unsigned long int printcount = 0; 				  /* counter for reporting progress every 1K bytes */
extern   unsigned char text_buf[N + F - 1];		  /* ring buffer of size N, with extra F-1 bytes to facilitate string comparison */
int      match_position, match_length;  		  /* of longest match.  These are set by the InsertNode() procedure.  */
from int lson[N + 1], rson[N + 257], dad[N + 1];  /* left & right children & parents -- These constitute binary search trees. */

#ifdef _shell_			      
 extern FILE	*infile, *outfile;  /* input & output files */
#else
  FILE	  *infile, *outfile;  /* input & output files */
#endif

#ifdef _shell_
#define setcrc(ch) (crc = (crc >> 8) ^ crctbl [(crc ^ (ch)) & 0xff])
#define setcrcu(ch) (crc_u = (crc_u >> 8) ^ crctbl [(crc_u ^ (ch)) & 0xff])
extern unsigned crc, crc_u, crctbl [];
int crc_getc (register FILE *stream)
{
	register int ch;

	if ((ch = getc (stream)) != EOF)
		setcrc (ch);
	return ch;
}

int crcu_getc (register FILE *stream)
{
	register int ch;

	if ((ch = getc (stream)) != EOF)
		setcrcu (ch);
	return ch;
}

void crc_putc (unsigned ch, register FILE *stream)
{
	putc(ch,stream);
	setcrc(ch);
}
#else
  int crc_getc(register FILE *stream)
  {
    return getc(stream);
  }
  void crc_putc(unsigned ch, register FILE *stream)
  { 
    putc(ch,stream);
  }
#endif
static void InitOTree(void)  /* initialize trees */
{
	int  i;

	/* For i = 0 to N - 1, rson[i] and lson[i] will be the right and
	   left children of node i.  These nodes need not be initialized.
	   Also, dad[i] is the parent of node i.  These are initialized to
	   NIL (= N), which stands for 'not used.'
	   For i = 0 to 255, rson[N + i + 1] is the root of the tree
	   for strings that begin with character i.  These are initialized
	   to NIL.  Note there are 256 trees. */

#ifndef _lzst_
	for (i = N + 1; i <= N + 256; i++) rson[i] = NIL;
	for (i = 0; i < N; i++) dad[i] = NIL;
#else
	for (i = N + 1; i <= N + 256; i++) rson[i] = 2*NIL;
	for (i = 0; i < N; i++) dad[i] = 2*NIL;
#endif		      
}

#ifndef _lzst_
static void InsertONode(int r)
	/* Inserts string of length F, text_buf[r..r+F-1], into one of the
	   trees (text_buf[r]'th tree) and returns the longest-match position
	   and length via the global variables match_position and match_length.
	   If match_length = F, then removes the old node in favor of the new
	   one, because the old one will be deleted sooner.
	   Note r plays double role, as tree node and position in buffer. */
{
	int  i, p, cmp;
	unsigned char  *key;

	cmp = 1;  key = &text_buf[r];  p = N + 1 + key[0];
	rson[r] = lson[r] = NIL;  match_length = 0;
	for ( ; ; ) {
		if (cmp >= 0) {
			if (rson[p] != NIL) p = rson[p];
			else {	rson[p] = r;  dad[r] = p;  return;  }
		} else {
			if (lson[p] != NIL) p = lson[p];
			else {	lson[p] = r;  dad[r] = p;  return;  }
		}
		for (i = 1; i < F; i++)
			if ((cmp = key[i] - text_buf[p + i]) != 0)  break;
		if (i > match_length) {
			match_position = p;
			if ((match_length = i) >= F)  break;
		}
	}
	dad[r] = dad[p];  lson[r] = lson[p];  rson[r] = rson[p];
	dad[lson[p]] = r;  dad[rson[p]] = r;
	if (rson[dad[p]] == p) rson[dad[p]] = r;
	else		       lson[dad[p]] = r;
	dad[p] = NIL;  /* remove p */
}

static void DeleteONode(int p)	/* deletes node p from tree */
{
	int  q;
	
	if (dad[p] == NIL) return;  /* not in tree */
	if (rson[p] == NIL) q = lson[p];
	else if (lson[p] == NIL) q = rson[p];
	else {
		q = lson[p];
		if (rson[q] != NIL) {
			do {  q = rson[q];  } while (rson[q] != NIL);
			rson[dad[q]] = lson[q];  dad[lson[q]] = dad[q];
			lson[q] = lson[p];  dad[lson[p]] = q;
		}
		rson[q] = rson[p];  dad[rson[p]] = q;
	}
	dad[q] = dad[p];
	if (rson[dad[p]] == p) rson[dad[p]] = q;  else lson[dad[p]] = q;
	dad[p] = NIL;
}
#else
  void InsertONode(int r);
  void DeleteONode(int p);  /* deletes node p from tree */
#endif

void EncodeOld(void)
{
	register int  i, c, len, r, s, last_match_length, code_buf_ptr;
	unsigned char  code_buf[17], mask;
/*	  unsigned long done=N; */
	printcount=textsize=0;
	InitOTree();  /* initialize trees */
	code_buf[0] = 0;  /* code_buf[1..16] saves eight units of code, and
		code_buf[0] works as eight flags, "1" representing that the unit
		is an unencoded letter (1 byte), "0" a position-and-length pair
		(2 bytes).  Thus, eight units require at most 16 bytes of code. */
	code_buf_ptr = mask = 1;
	s = 0;	r = N - F;
	for (i = s; i < r; i++) text_buf[i] = ' ';  /* Clear the buffer with
		any character that will appear often. */
	for (len = 0; len < F && (c = crc_getc(infile)) != EOF; len++)
		text_buf[r + len] = c;	/* Read F bytes into the last F bytes of
			the buffer */
	if ((textsize = len) == 0) return;  /* text of size zero */
	for (i = 1; i <= F; i++) InsertONode(r - i);  /* Insert the F strings,
		each of which begins with one or more 'space' characters.  Note
		the order in which these strings are inserted.	This way,
		degenerate trees will be less likely to occur. */
	InsertONode(r);	/* Finally, insert the whole string just read.	The
		global variables match_length and match_position are set. */
	do {
		if (match_length > len) match_length = len;  /* match_length
			may be spuriously long near the end of text. */
		if (match_length <= THRESHOLD) {
			match_length = 1;  /* Not long enough match.  Send one byte. */
#ifndef protect 		       
			code_buf[0] |= mask;  /* 'send one byte' flag */
#endif			      
			code_buf[code_buf_ptr++] = text_buf[r];  /* Send uncoded. */
		} else {
#ifdef protect
			code_buf[0] |= mask;
#endif						
			code_buf[code_buf_ptr++] = (unsigned char) match_position;
			code_buf[code_buf_ptr++] = (unsigned char)
				(((match_position >> 4) & 0xf0)
			  | (match_length - (THRESHOLD + 1)));	/* Send position and
					length pair. Note match_length > THRESHOLD. */
		}
		if ((mask <<= 1) == 0) {  /* Shift mask left one bit. */
			for (i = 0; i < code_buf_ptr; i++)  /* Send at most 8 units of */
				putc(code_buf[i], outfile);	/* code together */
			codesize += code_buf_ptr;
			code_buf[0] = 0;  code_buf_ptr = mask = 1;
		}
		last_match_length = match_length;
		for (i = 0; i < last_match_length &&
				(c = crc_getc(infile)) != EOF; i++) {
			DeleteONode(s);		/* Delete old strings and */
			text_buf[s] = c;	/* read new bytes */
			if (s < F - 1) text_buf[s + N] = c;  /* If the position is
				near the end of buffer, extend the buffer to make
				string comparison easier. */
			s = (s + 1) & (N - 1);	r = (r + 1) & (N - 1);
				/* Since this is a ring buffer, increment the position
				   modulo N. */
			InsertONode(r);	/* Register the string in text_buf[r..r+F-1] */
		}
		if ((textsize += i) > printcount) {
			if (!flg_n) putchar('*');  printcount += N;
				/* Reports progress each time the textsize exceeds
				   multiples of 1024. */
		}
		while (i++ < last_match_length) {	/* After the end of text, */
			DeleteONode(s);					/* no need to read, but */
			s = (s + 1) & (N - 1);	r = (r + 1) & (N - 1);
			if (--len) InsertONode(r);		/* buffer may not be empty. */
		}
	  if (ferror(outfile)) error(WTERR,outfname);
	} while (len > 0);	/* until length of string to be processed is zero */
	if (code_buf_ptr > 1) { 	/* Send remaining code. */
		for (i = 0; i < code_buf_ptr; i++) putc(code_buf[i], outfile);
		codesize += code_buf_ptr;
	}
	
}


#ifndef _shell_
int main(int argc, char *argv[])
{
	char  *s;
	
	if (argc != 4) {
		printf("'lzss e file1 file2' encodes file1 into file2.\n"
			   "'lzss d file2 file1' decodes file2 into file1.\n");
		return EXIT_FAILURE;
	}
	if ((s = argv[1], s[1] || strpbrk(s, "DEde") == NULL)
	 || (s = argv[2], (infile  = fopen(s, "rb")) == NULL)
	 || (s = argv[3], (outfile = fopen(s, "wb")) == NULL)) {
		printf("??? %s\n", s);	return EXIT_FAILURE;
	}
	if (toupper(*argv[1]) == 'E') Encode();  else Decode();
	fclose(infile);  fclose(outfile);
	return EXIT_SUCCESS;
}
#else

void DecodeOld(void)
{
  puts("Nicht m”glich: DecodeOld");
}
#endif	
