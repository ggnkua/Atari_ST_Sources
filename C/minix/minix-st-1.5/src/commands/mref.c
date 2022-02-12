/* mref - MINIX cross referencer	Author: Andy Tanenbaum */

/* Mref is intended for producing listings and cross reference maps of
 * MINIX.  The default is to produce three outputs:
 *
 *	on stdout:	numbered listing of all the files given as args
 *	on symbol.out:	list of all "global" symbols and their definition line
 *	on xref.out:	cross reference map of all references to global symbols
 *
 * For this program, a global symbol is one that is defined as PUBLIC, PRIVATE,
 * EXTERN, #define, or SYMBOL.  The latter is provided to allow users to force
 * symbols x, y, and z to "global" status but simply making up a file with
 *
 *	SYMBOL x
 *	SYMBOL y
 *	SYMBOL z
 *
 * The numbering is consecutive across files, i.e., the second file begins
 * where the first one left off, except that each file begins at the top of
 * a new page, and the line number is rounded upward to the next page.
 * The three types of output can each be suppressed, using the -l, -d, and -x
 * flags, respectively.  Line numbering between procedures may be optionally
 * suppressed with -s, as in the MINIX book.  Page length and numbering can be
 * user controlled with flags.
 *
 * Normally output is designed for a dumb line printer, but the -t flag causes
 * the output to be enhanced with macros and font control so it can be fed to
 * troff (or nroff).  If troff form, the symbol table is printed in three
 * columns, the first page being shorter to allow for the chapter opening.
 *
 * Flags:
 *	-#	Number of lines to print per page, default = 50
 *	-d	Don't produce definition file (symbol table)
 *	-l	Don't produce listing
 *	-m	Multiple reference on one line only are cited once
 *	-p n	Set initial page number to n
 *	-t	Generate troff macro call before each page
 *	-s	Suppress line numbering between procedures
 *	-x	Don't produce the cross reference map
 *
 * Examples:
 *	mref -60 *.c		# print 60 lines per page (default is 50)
 *	mref -t -p 50 *.c	# first page is 50; generate .Ep and .Op macros
 *	mref -l -d *.h *.c	# no listing or symbols, just cross ref map
 */

#include <sys/types.h>
#include <ctype.h>
#include <fcntl.h>
#include <stdio.h>

#define LINE_SIZE     512
#define PHYS_PAGE      66	/* physical page length */
#define DEF_LEN        50	/* default # lines/page */
#define SYM_SIZE       13	/* symbols are truncated to this size */
#define HDR_SIZE        5	/* number of lines in the default header */
#define NSYMS        2000	/* size of the symbol table */
#define NTOKENS       100	/* maximum number of tokens per line */
#define MAX_VALUES    100	/* maximum times a name can be declared */
#define MAX_PER_LINE    9	/* number of cross refs to print per line */
#define NCOLS           3	/* number of columns for troffed symbol.out */

#define SYM_FILE "symbol.out"	/* place to write the symbol table */
#define XREF_FILE "xref.out"	/* place to write cross ref map */
#define TMP_FILE  "xref.tmp"	/* temporary xref file for gathering refs */
#define SORTED_FILE "xref.sort"	/* temporary xref file for sorting */

#define DEF             1	/* this line contains #define */
#define EXT             2	/* this line contains EXTERN  */
#define PRIV            3	/* this line contains PRIVATE */
#define PUB             4	/* this line contains PUBLIC  */
#define SYM             5	/* this line contains SYMBOL  */

int listing = 1;		/* 1 = output listing;		0: don't */
int xref = 1;			/* 1 = output cross ref map;	0: don't */
int definitions = 1;		/* 1 = output definitions;	0: don't */
int sflag = 0;			/* 1 = number all lines;	0: most  */
int tflag = 0;			/* 1 = troff output;		0: flat  */
int mflag = 0;			/* 1 = max one ref/line		0: many  */

int page_len = DEF_LEN;		/* # lines to print per page */
int phys_page = PHYS_PAGE;	/* total page size: top hdr+text+bottom hdr */
int cur_line;			/* current line number */
int cur_page = 1;		/* current page number */
int ntokens;			/* number of tokens in the token[] array */
int suppressing;		/* don't print numbers between procedures */
int hunting;			/* set when hunting for end of declaration */
int comment;			/* set when scanning a comment */
int xcount;			/* number of references so far to this sym */
int prev_ref;			/* previous reference printed */
int stride;			/* length of first symbol table page */
int stride2;			/* length of second symbol table page */

char *prog_name;		/* argv[0] */
char line_buf[LINE_SIZE];	/* buffer for 1 line */
char b[LINE_SIZE];		/* processed line goes here */
char *token[NTOKENS];		/* array of pointers to tokens */

/* Symbol table.  If a symbol is defined multiple times, it will get as many
 * entries in the symbol table as there are definitions.
 */
struct symtab {
  char sym_name[SYM_SIZE + 1];	/* symbol, followed by at least one '\0' */
  char sym_type;		/* PUB, PRIV, EXT, SYM, or DEF */
  int sym_val;			/* line number on which symbol occurs */
} symtab[NSYMS];

char *ppmap[] = {"", "#define", "EXTERN ", "PRIVATE", "PUBLIC ", "SYMBOL "};
char *ppmap2[] = {"", "#def", "EXTN", "PRIV", "PUBL", "SYMB"};
char spaces[] = "                ";

char *xref_text[] = {
  ".nf\n",
  ".tr _\\(ru\n",
  ".ta 1.25i 2iR 2.45iR 2.9iR 3.35iR 3.8iR 4.25iR 4.7iR 5.15iR 5.6iR 6.05iR\n",
  (char *) 0
};

char *list_text[] = {
  ".po .5i\n",
  ".lg 0\n",
  ".nf\n",
  ".ec `\n",
  ".ps 10\n",
  ".vs 12p\n",
  "`f(lb\n",
  ".nr T `w'0'\n",
  ".ta 8u*`nTu 16u*`nTu 24u*`nTu 32u*`nTu 40u*`nTu 48u*`nTu 56u*`nTu 64u*`nTu 72u*`nTu 80u*`nTu\n",
  ".de Op \n",
  ".bp ``$1\n",
  ".sp 0.5i\n",
  ".tl '``fR``s10MINIX SOURCE CODE``s0'``s11File: ``$2``s0``fP'``fB``s12``n%%``s0``fP'\n",
  ".sp 1\n",
  "``f(lb\n",
  "..\n",
  ".de Ep \n",
  ".bp ``$1\n",
  ".sp 0.5i\n",
  ".tl '``fB``s12``n%%``s0``fP``fR'``s11File: ``$2'``s0``s10MINIX SOURCE CODE``s0``fP'\n",
  ".sp 1\n",
  "``f(lb\n",
  "..\n",
  (char *) 0
};

char *sym_text[] = {
  ".nf\n",
  ".tr _\\(ru\n",
  ".ta 1.6iR 2.0i 3.6iR 4.0i 5.6iR\n",
  (char *) 0
};



FILE *sym;			/* for symbol table file */
FILE *xr;			/* for cross reference file */
FILE *tmp;			/* for collecting cross references */
FILE *sortf;			/* for sorting cross refernces */

main(argc, argv)
int argc;
char *argv[];
{

  int i, j;
  char *p;

  prog_name = argv[0];

  /* Process the command line. */
  if (argc < 2) usage();

  for (i = 1; i < argc; i++) {
	p = argv[i];
	if (*p != '-') break;
	p++;
	i += eat_flag(argv, i);
  }
  stride = page_len / 2;	/* allow for chapter opening */
  stride2 = page_len;


  /* Create the output files. */
  make_files();

  /* Read all the files. Make the listing and extract the symbols. */
  for (j = i; j < argc; j++) process(argv[j]);

  if (xref) {
	/* Read all the files again and generate the cross
	 * refererence data. */
	cur_line = 0;
	for (j = i; j < argc; j++) gen_xref(argv[j]);

	/* Go get the cross reference data and print it. */
	collect_xref();
  }

  /* Print the symbol table. */
  if (definitions) print_sym();

  exit(0);
}


int eat_flag(argv, i)
char *argv[];			/* argument array */
int i;				/* process argv[i] */
{
  char *p;
  int r = 0;

  p = argv[i];
  p++;
  if (*p >= '0' && *p <= '9') {
	page_len = atoi(p);	/* e.g. numb -60 file */
	return(r);
  }
  while (1) {
	/* Flag may be something like -dls. */
	switch (*p) {
	    case 'd':	definitions = 0;	break;
	    case 'l':	listing = 0;	break;
	    case 'x':	xref = 0;	break;
	    case 'm':	mflag = 1;	break;
	    case 's':	sflag = 1;	break;
	    case 't':	tflag = 1;	break;

	    case 'p':
		cur_page = atoi(argv[i + 1]);
		i++;
		r = 1;
		break;

	    default:	usage();
	}
	p++;
	if (*p == 0) return(r);
  }
}


make_files()
{
/* Create output files. */

  int fd;

  if (tflag && listing) output_macros(stdout, list_text);

  if (definitions) {
	if ((fd = creat(SYM_FILE, 0666)) < 0) {
		fprintf(stderr, "%s: cannot create %s\n", prog_name, SYM_FILE);
		exit(2);
	}
	close(fd);
	sym = fopen(SYM_FILE, "w");
	if (sym == NULL) {
		fprintf(stderr, 
		       "%s: cannot open %s for output\n", prog_name, SYM_FILE);
		exit(2);
	}
	if (tflag) output_macros(sym, sym_text);
  }
  if (xref) {
	if ((fd = creat(XREF_FILE, 0666)) < 0) {
		fprintf(stderr,"%s: cannot create %s\n", prog_name, XREF_FILE);
		exit(2);
	}
	close(fd);
	xr = fopen(XREF_FILE, "w");
	if (xr == NULL) {
		fprintf(stderr,
		      "%s: cannot open %s for output\n", prog_name, XREF_FILE);
		exit(2);
	}
	if (tflag) output_macros(xr, xref_text);

	if ((fd = creat(TMP_FILE, 0666)) < 0) {
		fprintf(stderr, "%s: cannot create %s\n", prog_name, TMP_FILE);
		exit(2);
	}
	close(fd);
	tmp = fopen(TMP_FILE, "w");
	if (xr == NULL) {
		fprintf(stderr,
		       "%s: cannot open %s for output\n", prog_name, TMP_FILE);
		exit(2);
	}
  }
}


process(file)
char *file;
{
/* Process one file. */

  int k;
  FILE *f;

  if ((f = fopen(file, "r")) == NULL) {
	fprintf(stderr, "%s: cannot open %s\n", prog_name, file);
	exit(1);
  }
  while (1) {
	if (fgets(line_buf, LINE_SIZE, f) == NULL) {
		/* End of file hit. */
		fclose(f);
		if (listing && cur_line % page_len != 0) {
			fill_page();	/* fill out the e.g. 50 lines */
			eject();/* space to top of next sheet */
		}
		return;
	}
	if (listing)
		list(file);
	else
		cur_line++;
	if (definitions || xref) get_sym();
  }
}


list(file)
char *file;
{
/* We are printing a listing. */

  if (cur_line % page_len == 0) new_page(file);
  if (suppressing == 1 && strlen(line_buf) == 1)
	printf("\n");
  else
	printf("%5d   %s", cur_line, line_buf);

  cur_line++;
  if (cur_line % page_len == 0) eject();

  if (strlen(line_buf) > 1) suppressing = 0;
  if (strcmp(line_buf, "}\n") == 0 && sflag) suppressing = 1;
}


get_sym()
{
/* Look for lines starting with PRIVATE, PUBLIC, EXTERN, SYMBOL or #define and
 * make a symbol table entry for them.  Life is slightly complicated by
 * constructions like:
 *
 * 1000 PRIVATE struct foobar {
 * 1001   int i;
 * 1002   char c;
 * 1003 } name[MAX];
 *
 * in which the symbol 'name' is triggered on line 1000, but its value is 1003.
 */

  int n, type;
  register char c;
  char *p, *q, *backup();

  /* If we are hunting for the end of a declaration, the rules are
   * different. */
  if (hunting) {
	q = line_buf;
	while (*q == ' ' || *q == '\t') q++;
	if (*q != '}') return;
	q++;
	while (*q == ' ' || *q == '\t') q++;
	p = q;
	while (isalnum(*p) || *p == '_') p++;
	*p = 0;
	enter_sym(q, cur_line - 1, hunting);
	hunting = 0;
	return;
  }

  /* For efficiency, make a quick check to see if this line is interesting. */
  c = line_buf[0];
  if (c != 'P' && c != 'E' && c != 'S' && c != '#') return;

  squash();			/* squeeze out white space */

  /* Real check to see if this line is interesting. */
  type = 0;
  if (strncmp(b, "#define", 7) == 0) type = DEF;
  if (strncmp(b, "PRIVATE", 7) == 0) type = PRIV;
  if (strncmp(b, "PUBLIC", 6) == 0) type = PUB;
  if (strncmp(b, "EXTERN", 6) == 0) type = EXT;
  if (strncmp(b, "SYMBOL", 6) == 0) type = SYM;
  if (type == 0) return;

  /* Process #define */
  if (type == DEF) {
	q = &b[8];
	while (*q != ' ') q++;
	*q = 0;
	enter_sym(&b[8], cur_line - 1, type);
	return;
  }
  q = b + strlen(b) - 1;	/* q points to last character */
  if (*q == '!' || *q == '+') {
	*q = ' ';
	while (*q == ' ') q--;
  }

  /* If last char is paren, }, or comma, this is a function call. */
  if (*q == ')' || *q == ',' || *q == '}') {
	/* It is a paren. */
	q = b;
	while (*q != '(') q++;
	if (*(q + 1) == '*')
		*q = ' ';	/* worry about: int (*foo[N])() */
	strip(b, "(", 1);
	strip(b, "[", 1);
	q = b + strlen(b) - 1;
	q = backup(q);
	enter_sym(q, cur_line - 1, type);
	return;
  }

  /* If last char is semicolon, '[', or letter, this is a declaration. */
  if (*q == ';' || *q == ']' || *q == '_' || isalnum(*q)) {
	/* It is a declaration. */
	if (*q == ';') q--;
	if (*q == ' ') q--;
	*(q + 1) = 0;
	if (*q == ']') strip(b, "[", 1);	/* e.g. PRIVATE int foo[N]; */
	q = b + strlen(b) - 1;
	q = backup(q);
	enter_sym(q, cur_line - 1, type);
	return;
  }

  /* If last char is curly bracket, this is the start of a struct array. */
  if (*q == '{') {
	hunting = type;		/* Start hunting for the '}' */
	return;
  }
  panic("getsym got unknown line type");
}



fill_page()
{
/* Fill out current page with line feeds. This routine is only called when
 * an end of file is encountered.  It fills out the current page to 50
 * lines (or whatever).  For -t it does nothing.
 */
  int k;

  k = cur_line % page_len;
  if (k > 0) k = page_len - k;
  cur_line += k;
  if (tflag == 0) while (k--)
		printf("\n");
}


eject()
{
/* Finish off the last 11 or so blank lines on a page (not for -t. */

  int i;

  if (tflag) return;

  i = phys_page - page_len - HDR_SIZE;
  while (i--) printf("\n");
}


new_page(file)
char *file;
{
/* Top of page processing. */

  int i;

  if (tflag) {
	/* Generate a troff macro that does the heading (odd/even). */
	if (cur_page & 1)
		printf(".Op %d %s\n", cur_page, file);	/* odd page */
	else
		printf(".Ep %d %s\n", cur_page, file);	/* even page */
  } else {
	/* Standard header */
	printf("\n\n\nPage: %d                         ", cur_page);
	printf("File: %s\n\n", file);
  }
  cur_page++;
}


squash()
{
/* Copy line_buf to b, squeezing out white space, comments, and initializers. */

  register char *p, *q;
  char c;

  p = line_buf;
  q = b;
  c = *p;
  *q++ = *p++;			/* copy first character */
  if (c == '#') {
	while (*p == ' ' || *p == '\t') p++;	/* skip spaces after '#' */
  }
  while (*p != '\0') {
	if (*p == '\n' || *p == '=') break;
	if (*p == '/' && *(p + 1) == '*') break;
	if (*p == ' ' || *p == '\t') {
		while (*p == ' ' || *p == '\t') p++;
		*q++ = ' ';	/* copy one space */
	} else {
		*q++ = *p++;
	}
  }
  if (*(q - 1) == ' ') q--;
  *q = 0;
}



strip(string, s, n)
char *string;
char *s;
int n;
{
/* Scan b for the string s and truncate it there if found. */

  char *p;

  p = string;

  while (*p != '\0') {
	if (strncmp(p, s, n) == 0) {
		*p = 0;
		if (*(p - 1) == ' ') *(p - 1) = 0;
		return;
	} else {
		p++;
	}
  }

}


char *backup(q)
char *q;
{
/* Back the pointer q up to the start of the word it points to. */

  while (*q != ' ' && *q != '*') q--;
  return(q + 1);
}

enter_sym(p, value, type)
char *p;			/* pointer to name of symbol */
int value;			/* line number on which symbol occurs */
int type;			/* PUB, PRIV, EXT, DEF, SYM */
{
/* Enter a symbol in the hash table.  A symbol may be define in FS and again
 * in MM, etc.  Up to 3 definitions are stored.
 */

  int h, len;
  struct symtab *hp;

  /* Watch out for the #define PUBLIC line, etc. */
  if (strlen(p) == 0) return;
  if (strcmp(p, "PUBLIC") == 0) return;
  if (strcmp(p, "PRIVATE") == 0) return;
  if (strcmp(p, "EXTERN") == 0) return;
  if (strcmp(p, "int") == 0) return;
  if (strcmp(p, "char") == 0) return;
  if (strcmp(p, "void") == 0) return;

  strip(p, "(", 1);
  h = find_slot(p);
  hp = &symtab[h];
  len = strlen(p);
  if (len > SYM_SIZE) len = SYM_SIZE;

  /* Enter the symbol.  Multiple definitions are allowed. */
  strncpy(hp->sym_name, p, len);/* entry is SYM_SIZE+1 for \'0' */
  hp->sym_type = type;
  hp->sym_val = value;
}


int find_slot(p)
char *p;
{
/* Hash the string and return an index into the hash table.  If a collision
 * occurs, the first consecutive free slot is used.
 */

  unsigned int h, hash();

  /* Search all entries starting at h for a free slot. */
  h = hash(p);
  while (1) {
	if (symtab[h].sym_type == 0) return((int) h);	/* empty slot */
	h = (h + 1) % NSYMS;	/* try next entry */
  }
}

int lookup(p)
char *p;
{
/* Is p is in the symbol table?  Return slot if it is present, -1 if absent. */

  unsigned int h, hash();
  int n;

  n = strlen(p);
  if (n > SYM_SIZE) n = SYM_SIZE;
  h = hash(p);
  while (1) {
	if (symtab[h].sym_type == 0) return(-1);	/* not present */
	if (strncmp(p, symtab[h].sym_name, n) == 0) return ((int) h);
	h = (h + 1) % NSYMS;
  }
}


unsigned int hash(p)
char *p;
{
/* Compute and return the hash code of p. */

  int i, n;
  unsigned h;

  n = strlen(p);
  if (n > SYM_SIZE) n = SYM_SIZE;
  h = 0;
  for (i = 0; i < n; i++) {
	h += 23 * i * (int) *p;
	p++;
  }
  h = h % NSYMS;
  return(h);
}


print_sym()
{
/* Print all the definitions. */

  int n, k, count, s, i, limit;
  struct symtab *ap, *bp, *cp;

  n = compact();		/* compact the symbol table */
  if (n < 0 || n > NSYMS) panic("compact returned invalid value");
  sort(n);			/* sort the symbol table */

  /* Print the symbol table. */
  if (tflag) {
	/* Produce the symbol.out file for troff. */
	i = 0;
	limit = stride;
	while (1) {
		while (i < limit) {
			ap = &symtab[i];
			bp = &symtab[i + stride];
			cp = &symtab[i + 2 * stride];
			if (ap < &symtab[n])
				fprintf(sym, "%s\t%d", ap->sym_name, ap->sym_val);
			if (bp < &symtab[n])
				fprintf(sym, "\t%s\t%d", bp->sym_name, bp->sym_val);
			if (cp < &symtab[n])
				fprintf(sym, "\t%s\t%d", cp->sym_name, cp->sym_val);
			fprintf(sym, "\n");
			i++;
		}
		fprintf(sym, ".bp\n");
		if (cp >= &symtab[n - 1]) return;
		i += 2 * stride;
		stride = stride2;	/* 1st page may be different */
		limit = i + stride;
	}
  } else {
	/* Produce the flat version of symbol.out. */
	for (ap = &symtab[0]; ap < &symtab[n]; ap++) {
		k = strlen(ap->sym_name);
		fprintf(sym, "%s%s %5d  %s\n", ap->sym_name, &spaces[k],
			ap->sym_val, ppmap[ap->sym_type]);
	}
  }
}


compact()
{
/* Compact the symbol table to make sorting more efficient. */

  unsigned int d;
  struct symtab *ap, *bp;

  bp = &symtab[NSYMS - 1];	/* bp points to last entry */
  for (ap = &symtab[0]; ap < bp; ap++) {
	if (ap->sym_type != 0) continue;	/* skip used slots. */

	/* Ap points to an empty slot.  Find a full one and swap them. */
	while (bp->sym_type == 0 && bp > symtab)
		bp--;		/* skip empty slots */

	if (bp <= ap) {
		d = ap - symtab;
		return(d);
	}
	swap(ap, bp);
  }
  return(ap - symtab);
}


swap(ap, bp)
struct symtab *ap, *bp;
{
/* Swap two symbol table entries. */

  struct symtab xp;

  xp = *ap;
  *ap = *bp;
  *bp = xp;
}

sort(n)
int n;				/* number of nonnull entries in symtab */
{
/* Sort the symbol table.  Use bubble sort. */

  int s;
  struct symtab *ap, *bp;

  for (ap = &symtab[0]; ap < &symtab[n - 1]; ap++) {
	for (bp = ap + 1; bp < &symtab[n]; bp++) {
		s = strcmp(ap->sym_name, bp->sym_name);
		if (s < 0) continue;
		if (s == 0 && ap->sym_type < bp->sym_type) continue;
		swap(ap, bp);
	}
  }
}



gen_xref(file)
char *file;
{
/* Build the cross reference listing.  Reread file, looking up all
 * symbols in the hash table.  On every hit, an entry written to the temporary
 * file.  Later they will be sorted and printed.
 */

  int i, k;
  register char *p;
  char c, *skip_comment();
  FILE *f;

  if ((f = fopen(file, "r")) == NULL) {
	fprintf(stderr, "%s: cannot open %s\n", prog_name, file);
	exit(1);
  }
  while (1) {
	/* Each iteration of this outer loop reads one line of the file. */
	if (fgets(line_buf, LINE_SIZE, f) == NULL) {
		/* End of file hit. */
		fclose(f);
		if (cur_line % page_len != 0) {
			k = cur_line % page_len;
			if (k > 0) k = page_len - k;
			cur_line += k;
		}
		return;
	}
	ntokens = 0;
	p = line_buf;

	if (comment) {
		p = skip_comment(p);
		if (*p == '\n') {
			cur_line++;
			continue;	/* we haven't seen end yet */
		}
	}
	c = *p;

	while (c != '\n') {
		/* This loop scans the line looking for tokens. */
		if (isalpha(c) || c == '_') {
			/* This is the start of a token. */
			token[ntokens++] = p;	/* store start of token */
			while (isalnum(*p) || *p == '_') p++;
			c = *p;	/* save character after token */
			*p = 0;	/* terminate the token */
			continue;
		}

		/* Check to see if it is a comment. */
		if (c == '/' && *(p + 1) == '*') {
			p = skip_comment(p + 2);	/* it's a comment */
			c = *p;
			continue;
		}

		/* Check to see if it is a string. */
		if (c == '"') {
			p++;
			while (*p != '"') p++;
			p++;
			c = *p;
			continue;
		}

		/* It is not a token or a comment, just ignore it. */
		p++;
		c = *p;
	}

	/* Process the token array just constructed. This is where
	 * the cross references are written to TMP_FILE.  Put out
	 * leading zeros so that sort will get them right. */
	for (i = 0; i < ntokens; i++) {
		p = token[i];
		if (strlen(p) > SYM_SIZE) *(p + SYM_SIZE) = 0;
		k = lookup(p);
		if (k > 0) {
			fprintf(tmp, "%s ", p);
			if (cur_line < 10)
				fprintf(tmp, "0000%d\n", cur_line);
			else if (cur_line < 100)
				fprintf(tmp, "000%d\n", cur_line);
			else if (cur_line < 1000)
				fprintf(tmp, "00%d\n", cur_line);
			else if (cur_line < 10000)
				fprintf(tmp, "0%d\n", cur_line);
			else
				fprintf(tmp, "%d\n", cur_line);
		}
	}

	cur_line++;
  }
}

char *skip_comment(p)
char *p;
{
/* Skip a comment. */

  while (1) {
	if (*p == '*' && *(p + 1) == '/') {
		comment = 0;
		return(p + 2);
	}
	if (*p == '\n') {
		comment = 1;	/* next line is still comment. */
		return(p);
	}
	p++;
  }
}

collect_xref()
{
/* Sort the cross references and format them. */

  int i, n, values[MAX_VALUES], used, nval, s, flag;
  register char *p;
  char *pname, *pnum;
  char cur[SYM_SIZE + 1];	/* name currently being processed. */


  /* Use the sort program to sort the file where the cross references
   * have been accumulating. */

  fclose(tmp);			/* close temporary file to flush the buffer */
  sort_xref();			/* sort the cross references */
  unlink(TMP_FILE);		/* temporary file is not needed any more */

  /* Open the sorted file to read it back. */
  sortf = fopen(SORTED_FILE, "r");
  if (sortf == NULL) {
	fprintf(stderr, "%s: cannot read back %s \n", prog_name, SORTED_FILE);
	exit(2);
  }

  /* Read back each line in turn. */
  used = 0;
  while (1) {
	if (fgets(line_buf, LINE_SIZE, sortf) == NULL) {
		/* EOF seen.  Flush current line and return. */
		fprintf(xr, "\n");
		fclose(xr);
		unlink(SORTED_FILE);
		return;
	}

	/* Terminate both of the tokens contained on each line with 0s. */
	p = line_buf;
	pname = p;
	while (*p != ' ') p++;
	*p = 0;
	p++;
	pnum = p;
	while (*p != '\n') p++;
	*p = 0;

	/* Is this name the one we are currently working on? */
	if (used == 0 || strcmp(pname, cur) != 0) {
		nval = new_name(cur, used, pname, values);
		xcount = nval;	/* # refs on this line so far */
	}
	used = 1;

	/* For every reference, see if it is a definition.  If so, do
	 * not print it, since the definitions are printed when the
	 * symbol is encountered for the first time. */
	s = atoi(pnum);
	flag = 0;
	for (i = 0; i < nval; i++)
		if (s == values[i]) flag = 1;
	if (flag) continue;
	if (mflag && s == prev_ref) continue;	/* max 1 citation/line */
	if (xcount > 0 && xcount % MAX_PER_LINE == 0) {
		if (tflag)
			fprintf(xr, "\t");
		else
			fprintf(xr, "                       ");
	}

	/* The next line prints a reference on the cross reference listing. */
	if (tflag)
		fprintf(xr, "\t%d", s);
	else
		fprintf(xr, " %5d", s);
	prev_ref = s;		/* remember it for subsequent use */
	xcount++;		/* number of symbols printed on this line */
	if (xcount % MAX_PER_LINE == 0) fprintf(xr, "\n");
  }
}


int new_name(cur, used, pname, values)
char *cur[SYM_SIZE + 1];	/* storage for current name */
int used;			/* 0 only on first call. */
char *pname;			/* pointer to the new name */
int values[MAX_VALUES];		/* all the definitions of the new name */
{
/* A new name has been read.  Finish off the old one and prepare new one. */

  int slot, nval, i, j, type, temp;

  /* If a name is currently in use (all except first time), finish it. */
  if (used && xcount % MAX_PER_LINE > 0) fprintf(xr, "\n");
  xcount = 0;

  /* Copy the new name in place and fetch its definitions. Multiple
   * definitions are allowed, e.g., do_fork may appear in FS and also
   * in MM, but if they are different types (e.g., one PUBLIC and one
   * PRIVATE) only one of them will be included in the listing, to
   * avoid messing up the layout. */
  strcpy(cur, pname);
  cur[SYM_SIZE] = 0;
  slot = lookup(pname);
  nval = 0;

  while (symtab[slot].sym_type > 0) {
	if (strcmp(pname, symtab[slot].sym_name) == 0) {
		values[nval++] = symtab[slot].sym_val;
		type = symtab[slot].sym_type;
		if (nval == MAX_VALUES) break;
	}
	slot = (slot + 1) % NSYMS;
  }

  /* Sort the values. */
  for (i = 0; i < nval - 1; i++) {
	for (j = i + 1; j < nval; j++) {
		if (values[i] > values[j]) {
			temp = values[i];
			values[i] = values[j];
			values[j] = temp;
		}
	}
  }

  /* Print the line in the cross reference map that contains the symbol. */
  fprintf(xr, "%s", pname);
  if (tflag) {
	fprintf(xr, "\t%s\\fB", ppmap2[type]);
	for (i = 0; i < nval; i++) fprintf(xr, "\t%d", values[i]);
	fprintf(xr, "\\fR");
  } else {
	i = strlen(pname);
	fprintf(xr, "%s %s ", &spaces[i], ppmap2[type]);
	for (i = 0; i < nval; i++) fprintf(xr, "%5d ", values[i]);
  }

  return(nval);
}



sort_xref()
{
/* Sort the cross reference file by forking off a copy of 'sort'. */

  int status, pid;

  pid = fork();
  if (pid > 0) {
	/* Parent just waits. */
	wait(&status);
	if (status != 0) panic("couldn't sort cross references");
  } else {
	/* Child execs sort. */
	close(0);
	close(1);
	if (open(TMP_FILE, O_RDONLY) < 0) exit(1);
	if (creat(SORTED_FILE, 0644) < 0) exit(2);
	execl("/bin/sort", "sort", (char *) 0);
	execl("/usr/bin/sort", "sort", (char *) 0);
	exit(3);
  }
}


output_macros(f, text)
FILE *f;
char *text[];
{
/* Output troff commands. */

  int i;

  i = 0;
  while (text[i] != (char *) 0) {
	fprintf(f, text[i]);
	i++;
  }
}


sym_macros()
{
}


xref_macros()
{
}




panic(s)
char *s;
{
  fprintf(stderr, "%s: %s\n", prog_name, s);
  exit(2);
}


usage()
{
  fprintf(stderr, "Usage: %s [-<n>] [-dlmtsx] [-p pagenr] file ... \n",
	prog_name);
}
