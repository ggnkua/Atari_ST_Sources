/*
	NAME
		srec - convert Motorola DSP load file records to
		       S-record format

	SYNOPSIS
		srec [-blmrsw] [-p <procno>] <input file ... >

	DESCRIPTION
		Srec takes as input a Motorola DSP absolute load file and
		produces byte-wide Motorola S-record files suitable for
		PROM burning.  If no file is specified the standard input
		is read.  The Motorola DSP START and END records are
		mapped into S0 and S7/S9 records respectively.  All other
		DSP record types are mapped into S1 or S3-type records
		depending on the source processor.  SYMBOL and COMMENT records
		are currently ignored.

		Since Motorola DSPs use different word sizes, the words
		must be split into bytes and stored in an appropriate format.
		The program examines the machine type field in the load
		file start record to determine the appropriate S-record
		format to use.  For example, if the machine ID in the START
		record is DSP56000 or DSP5616, srec generates S1/S9 output
		records; if the machine ID is DSP96000, the program generates
		S3/S7 records.

		In the default mode of operation the program writes the
		low, middle, and high bytes of each word
		consecutively to the current S1/S3 record being written.  For
		example, given the DSP56000 DATA record below:

				address field
				|
			_DATA P 0000
			0008F8 300000 340000 094E3E
			|      |      |      |
			|      |      |      fourth word
			|      |      third word
			|      second word
			first word

		srec would create the following S1 record:

			  byte count field
			  | address  field              checksum field
			  | |                           |
			S10D0000F808000000300000343E4E09F9
			        |     |     |     |
			        |     |     |     fourth word
			        |     |     third word
			        |     second word
			        first word

		Output records are written to a file named according to
		the following convention:

			<basename>.M

		where <basename> is the filename of the input load file
		without extension and M is the memory space specifier
		(X, Y, L, or P) for this set of data words.  Note that a
		separate file is created for each memory space encountered
		in the input stream; thus the maximum number of output files
		in the default mode is 4.

		When the -m option is specified, srec splits each DSP source
		word into bytes and stores the bytes in parallel S1/S3
		records.  For example, the following DSP56000 DATA record:

				address field
				|
			_DATA P 0000
			0008F8 300000 340000 094E3E
			|      |      |      |
			|      |      |      fourth word
			|      |      third word
			|      second word
			first word

		would be converted by srec into the three S1 records below:

			  byte count field
			  | address  field
			  | |
			S1070000F800003EC2 -- low  byte
			S10700000800004EA2 -- mid  byte
			S1070000003034098B -- high byte
				| | | | |
				| | | | checksum field
				| | | fourth word
				| | third word
				| second word
				first word

		The three records corresponding to the high, middle, and
		low bytes of each data word are written to separate files.
		The files are named according to the following convention:

			<basename>.<M><#>

		where <basename> is the filename of the input load file
		without extension, <M> is the memory space specifier
		(X, Y, L, or P) for this set of data words, and # is
		one of the digits 0, 1, or 2 corresponding to low, middle,
		and high bytes, respectively.  If input comes from the
		standard input, the module name is used as <basename>.

		Note that a separate set of byte-wide files is created for
		each memory space encountered in the input stream.  Thus the
		number of output files generated is (number of memory spaces
		in input * size of DSP word).

		The -s option writes all information to a single file,
		storing the memory space information in the address field
		of the S0 header record.  The values stored in the address
		field and their correspondence to the DSP56000 memory
		spaces are as follows:

			Value		DSP56000 Memory Space
			-----		---------------------
			  1			X
			  2			Y
			  3			L
			  4			P

		When the memory space changes in the DATA or BLOCKDATA
		record, a new S0 header record is generated.  The resulting
		output file is named <basename>.s, where <basename> is
		the filename of the input load file without extension.
		The -m and -s options are mutually exclusive.

		The -r option causes srec to write bytes high to low rather
		than low to high in the default and -s modes.  It has no
		affect when the -m option is given.

		Address fields in DSP load records are copied as is to
		the appropriate S1 or S3 record.  Subsequent S1 or S3
		record addresses are byte incremented until a new DATA
		record is encountered or end-of-file is reached.  In some
		cases the starting S1/S3 record address must be adjusted for
		byte addressing by multiplying the load record start address
		by the number of bytes in a DSP56000 word.  When the -b
		option is given, any DATA record address fields are adjusted
		to begin on a byte-multiple address.  If the -w option is
		specified (the default) byte-incrementing is not done
		when generating S-record addresses, e.g. the S-record
		addresses are word-oriented rather than byte-oriented.
		The -b and -w options have no effect when used in conjunction
		with the -m mode, since in that case byte and word address
		mappings are 1:1.

		DATA records for L space memory contain words which are loaded
		into adjacent X and Y memory locations.  In these cases
		performing the default strict word addressing may be
		inappropriate.  The -l option can be given to indicate
		that double-word addressing should be used to generate
		subsequent S1/S3 addresses after the initial load address.
		In addition the -l option should be used when doing byte
		addressing since the initial load addresses must be adjusted
		to account for double-word addressing in the load file.
		In general, it is a good idea to use the -l option whenever
		the source load file contains DATA records which refer to
		L memory space.

		In the START record only the module id is passed as header
		data for the S0 record; the version number, revision number,
		and comment are ignored.  As noted earlier, the machine ID
		field is used to determine what type of S-records to generate
		based on the addressing range of the DSP processor.  Some
		load file generators may not produce a START record or the
		START record may not contain the processor type.  The -p
		option can be used to explicitly specify a processor load file
		format.  Note that the -p option overrides the machine ID
		given in the START record.

	OPTIONS
		-b	- use byte addressing when transferring load addresses
			  to S-record addresses.  This means that load file
			  DATA record start addresses are multiplied by
			  the DSP bytes/word and subsequent S1/S3 record
			  addresses are computed based on the data byte count.
		-l	- use double-word addressing when transferring load
			  addresses from L space to S-record addresses.  This
			  means that load file DATA records for L space data
			  are moved unchanged and subsequent S1/S3 record
			  addresses are computed based on the data word count
			  divided by 2.  This option should always be used
			  when the source load file contains DATA records in L
			  memory space.
		-m	- split each DSP word into bytes and store
			  the bytes in parallel S-records.   Replaces
			  the -3 option.  The -m and -s options are
			  mutually exclusive.
		-p	- assume <procno> load file input format.  <procno>
			  is one of the Motorola DSP processor numbers, e.g.
			  56000, 96000, etc.
		-r	- write bytes high to low, rather than low to
			  high.  Has no effect when used with -m option.
		-s	- write data to a single file, putting memory
			  space information into the address field of the
			  S0 header record. Replaces the -1 option.
			  Bytes may be reversed with the -r option.
			  The -m and -s options are mutually exclusive.
		-w	- use word addressing when transferring load addresses
			  to S-record addresses.  This means that load file
			  DATA record start addresses are moved unchanged and
			  subsequent S1/S3 record addresses are computed
			  based on the data word count.

	DIAGNOSTICS
		The program does some checking for invalid input record
		formats, memory spaces, and hex values.  It obviously
		cannot check for bad data values if the load file has
		been tampered with.  Both START and END records should be
		found in the input stream, but the program tries to be
		forgiving about this.  If a START record is not present
		then the -p option should be used.

	IMPLEMENTATION NOTES
		One (and only one) of the operating system DEFINEs below
		must be activated to obtain appropriate conditional
		compilation.  This can be done either directly in the source
		by changing the 0 DEFINE for the desired operating system
		to a 1, or via the compiler command line (ex. -DATT=1).
		Note that the UNIX flag is simply a logical ORing of the
		more specific Unix OS flags (ATT and BSD) and thus should
		not be specified explicitly.

	HISTORY
		1.0	The beginning.
		1.1	Added code to support new default mode and -r
			option (-3 was old default mode).
		1.2	Added support for AT&T Unix System V.
		1.3	Fix for bug in default mode where S-record address
			was not being computed correctly (e.g. not a byte
			multiple of the 56000 word size).
		1.4	Added support for Macintosh II.
		1.5	Added separate include file, getopt () support,
			-1 (single output file) option.
		1.6	Fix for bug in default mode when handling BLOCKDATA
			records; repeated call to reverse bytes was reversing
			bytes in place!
		1.7	Added -b and -w options.
		2.1	Bumped version number for distribution.
		3.0	Added DSP96000 support; replaced -1 and -3 options
			with -s and -m respectively.
		3.1	Modified get_start() to handle old-style START
			records (e.g. without error count, machine type,
			assembler version, etc.).
		3.2	Added -l option.
		4.0	Added DSP5616 support.
		4.1	Fixed bug in S7/S9 generation code (get_end()) where
			with -b option address was not transferred correctly
			to output field, resulting in a bad S7/S9 checksum.
		4.2	Added standard input capability.
		4.3	Fixed so data field lengths can vary.
		4.4	Changed standard input to use "-" command line flag;
			no options causes usage to be printed.  Filled out
			option descriptions in usage message.
		4.5	Fixed bug in handling of S-record count fields to
			deal with long values on 16-bit hosts (IBM PC).
		4.6	Name change from DSP56016 to DSP5616.
		4.7	Fixed bug in rev_bytes logic for 5616, 96000.
		4.8	Added -p option; made START/END record parsing
			more forgiving.
		4.9	Made record type names case-insensitive.
		4.10	Fixed bugs in old-style START record logic.
*/


#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>
#if VMS
#include <descrip.h>
#include <ssdef.h>
#include <stsdef.h>
#include <climsgdef.h>
#endif
#if MPW
#include <files.h>
#include <CursorCtl.h>
#ifdef String
#undef String
#endif
#endif	/* MPW */
#include "srec.h"


extern int main ( /* int argc,char *argv [] */ );
static do_srec ( /* FILE *fp */ );
static get_start ( /* FILE *fp */ );
static get_record ( /* void */ );
static get_data ( /* void */ );
static get_bdata ( /* void */ );
static get_end ( /* void */ );
static sum_addr ( /* unsigned long addr */ );
static get_bytes ( /* int space */ );
static flush_rec ( /* int space,unsigned long addr,unsigned long count */ );
static rev_bytes ( /* void */ );
static open_files ( /* int space */ );
static get_field ( /* void */ );
static get_comment ( /* void */ );
static get_line ( /* void */ );
static char *scan_field ( /* char *bp */ );
static bld_s0 ( /* unsigned space */ );
static setup_mach ( /* char *buf */ );
static get_space ( /* void */ );
static char *fix_fname ( /* char *fname */ );
static char *strup ( /* char *str */ );
static fldhex ( /* void */ );
static char *basename ( /* char *str */ );
static setfile ( /* char *fn,char *type,char *creator */ );
extern int getopt ( /* int argc,char *argv [],char *optstring */ );
#if VMS
static dcl_getval ( /* struct dsc$descriptor_s *opt */ );
#else
static dcl_getval ( /* int *opt */ );
#endif
#if BSD
static int onintr ( /* void */ );
#else
static void onintr ( /* void */ );
#endif
static usage ( /* void */ );
static error ( /* char *str */ );
static error2 ( /* char *fmt,char *str */ );


char *optarg = NULL;			/* command argument pointer */
int optind = 0;				/* command argument index */

char Progdef[] = "srec";		/* program default name */
char *Progname = Progdef;		/* pointer to program name */
char Progtitle[] = "Motorola DSP S-Record Conversion Utility";
char Version[]   = "Version 4.10";	/* srec version number */
char Copyright[] = "(C) Copyright Motorola, Inc. 1987, 1988, 1989, 1990.  All rights reserved.";
static dclflag = NO;			/* VMS DCL flag */
static char *ifname = NULL;		/* pointer to input file name */
static FILE *ifile = NULL;		/* file pointer for input file */
static opts = NO;			/* single file option flag */
static optm = NO;			/* multiple file option flag */
static reverse = NO;			/* reverse byte option flag */
static baddr = NO;			/* byte address flag */
static waddr = NO;			/* word address flag */
static lmem = NO;			/* L memory flag */
static unsigned linecount = 1;		/* input file line count */
static char fldbuf[MAXSTR] = {EOS};	/* Object file field buffer */
static char strbuf[MAXSTR] = {EOS};	/* Global string buffer */
static char s0buf[MAXSTR];		/* S0 record string */
static unsigned s0cnt = S0OVRHD;	/* S0 byte count */
static unsigned s0addr = 0;		/* S0 address */
static unsigned s0sum = 0;		/* S0 checksum */
static mach = NONE;			/* source machine type */
static wsize = 0;			/* bytes per DSP word */
static ovrhd = 0;			/* overhead bytes in S-record */
static char *wrdfmt = NULL;		/* word format string */

/*
	pointers to S-record structure arrays
*/
static struct srec *rec[] = {NULL, NULL, NULL, NULL};

extern char *calloc (), *malloc ();
#if BSD
extern char *index (), *rindex ();
#else
extern char *strchr (), *strrchr ();
#endif
char *strup ();
#if LSC
jmp_buf Env;
#endif
extern char *getenv ();

static char dclbuf[MAXSTR];
#if VMS					/* VMS DCL cmd line opt descriptors */
$DESCRIPTOR(arg_desc, dclbuf);
$DESCRIPTOR(lod_desc, "LOAD");
$DESCRIPTOR(byt_desc, "BYTE");
$DESCRIPTOR(lng_desc, "LONG");
$DESCRIPTOR(mlt_desc, "MULT");
$DESCRIPTOR(prc_desc, "PROC");
$DESCRIPTOR(rev_desc, "REVERSE");
$DESCRIPTOR(sgl_desc, "SINGLE");
$DESCRIPTOR(wrd_desc, "WORD");
#else
int lod_desc;
#endif


#if !LSC
main (argc, argv)
#else
_main (argc, argv)
#endif
int argc;
char *argv[];
{
#if BSD
	int onintr (), onsegv ();
#else
	void onintr (), onsegv ();
#endif
	int c;
	char *p, *q, *fn, *procno = NULL;
	char *basename(), *getenv();
	char *fix_fname ();

/*
	set up for signals; get prog. name, check for command line options
*/

#if AZTEC
	(void)sigset (SIGINT, onintr);	/* set up for signals */
#else
	(void)signal (SIGINT, onintr);	/* set up for signals */
#endif
	p = basename (argv[0]);	/* get command base name */
	if ((q = strrchr (p, '.')) != NULL)
		*q = EOS;
#if VMS
	if ((q = strrchr (p, ';')) != NULL)
		*q = EOS;
	dclflag = getenv (p) == NULL;
#endif
#if MSDOS
	if (_osmajor > 2)
#endif
		Progname = p;

#if MSDOS
        (void)fprintf (stderr, "%s  %s\n%s\n", Progtitle, Version, Copyright);
#endif

	if (!dclflag) {		/* not using VMS DCL */

		optarg = NULL;		/* command argument pointer */
		optind = 0;		/* command argument index */
		while ((c = getopt (argc, argv, "blmp:rsw?")) != EOF) {
			switch (c) {
			case 'b':	baddr = YES;
					break;
			case 'l':	lmem = YES;
					break;
			case 'm':	optm = YES;
					break;
			case 'p':	procno = optarg;
					break;
			case 'r':	reverse = YES;
					break;
			case 's':	opts = YES;
					break;
			case 'w':	waddr = YES;
					break;
			case '?':
			default:	usage ();
					break;
			}
		}
		argc -= optind;		/* adjust argument count */
		argv = &argv[optind];	/* reset argv pointer */
		if (argc <= 0 || (opts && optm) || (baddr && waddr))
			usage (); /* no more args or mutually exclusive args */

	} else {	/* using VMS DCL */
#if VMS
		if (cli$present (&byt_desc) == CLI$_PRESENT)
			baddr = YES;
		if (cli$present (&lng_desc) == CLI$_PRESENT)
			lmem = YES;
		if (cli$present (&mlt_desc) == CLI$_PRESENT)
			optm = YES;
		if (dcl_getval (&prc_desc) != CLI_ABSENT)
			procno = dclbuf;
		if (cli$present (&rev_desc) == CLI$_PRESENT)
			reverse = YES;
		if (cli$present (&sgl_desc) == CLI$_PRESENT)
			opts = YES;
		if (cli$present (&wrd_desc) == CLI$_PRESENT)
			waddr = YES;
#endif
	}

/*
	Set processor type if necessary
*/

	if (procno && (mach = setup_mach (procno)) == NONE)
		error ("invalid machine type");

/*
	Loop to process files
*/

	while (dclflag ? dcl_getval (&lod_desc) != CLI_ABSENT : argc) {
		fn = dclflag ? dclbuf : *argv;
		if (strcmp (fn, "-") == 0) {
			ifile = stdin;		/* use standard input */
			do_srec (ifile);	/* process records */
#if VAX
		} else if (strcmp (strup (fn), "SYS$INPUT") == 0) {
			ifile = stdin;		/* use standard input */
			do_srec (ifile);	/* process records */
#endif
		} else {
			ifname = fix_fname (fn);/* fix file name */
			if (!(ifile = fopen (ifname, "r")))
				error2 ("cannot open input file %s", ifname);
			if ((p = strrchr (ifname, '.')) != NULL)
				*p = EOS;	/* strip extension */
			do_srec (ifile);	/* process records */
			(void)fclose (ifile);	/* close input file */
		}
		free (ifname);	/* free file name */
		if (!dclflag) {
			argv++;	/* bump arg pointer */
			argc--;	/* decrement arg counter (MPW 3.0 kludge) */
		}
	}



#if LSC
	return (OK);
#else
	exit (OK);
#endif
}


static
do_srec (fp)		/* process load file records */
FILE *fp;
{
	if (!get_start (fp))		/* no START record */
		error ("no START record");

	while (!feof (fp)) {		/* loop while not end-of-file */

		switch (get_record ()) {
		case START:
			error ("duplicate START record");
		case END:
			get_end ();
			return;
		case DATA:
			get_data ();
			break;
		case BDATA:
			get_bdata ();
			break;
		case COMMENT:
			(void)get_comment ();
			break;
		case SYMBOL:
			fldbuf[0] = EOS; /* skip SYMBOL records */
			break;
		default:
			if (!feof (fp))
				error ("invalid record type");
		}
	}
	/* should never get here if END record found */
	if (feof (fp))
	    get_end ();		/* be forgiving */
}


static
get_start (fp)		/* process START record */
FILE *fp;
{
	int type, old = NO;
	char *fbp = fldbuf;
	char *sbp = s0buf;
	char *lbp = strbuf;
	char *p, *scan_field ();

/*
	locate START record
*/

	while ((type = get_record ()) <= 0)
		;	/* look for record identifier */

	if (type == EOF)
		return (NO);

	if (type != START) {	/* be forgiving */
		if (!mach && (mach = setup_mach ("56000")) == NONE)
			error ("cannot initialize machine type");
		bld_s0 ((unsigned)NONE);
		if (opts)	/* single file option */
			open_files (NONE);
		return (YES);
	}

	if (get_line () < 0)		/* buffer entire line */
		error ("invalid START record");

/*
	get program name; loop to put into header string
*/

	if ((lbp = scan_field (lbp)) == NULL)	/* pick up program name */
		error ("invalid START record");	/* got to have a name */

	if (fp == stdin) {		/* use module name for output */
		ifname = fix_fname (fldbuf);
		if ((p = strrchr (ifname, '.')) != NULL)
			*p = EOS;		/* strip extension */
	}

	while (*fbp) {
		(void)sprintf (sbp, "%02x", *fbp);
		s0sum += (unsigned)(*fbp++ & 0xff);
		sbp += 2;
		s0cnt++;
	}

/*
	build S0 record
*/

	bld_s0 ((unsigned)NONE);

	if (((lbp = scan_field (lbp)) == NULL) || /* skip version number */
	    ((lbp = scan_field (lbp)) == NULL) || /* skip revision number */
	    ((lbp = scan_field (lbp)) == NULL))   /* skip error count */
		old = YES;		/* wierd or old-style START record */

	if (old) {		/* look for machine type */
		if (!mach && (mach = setup_mach ("56000")) == NONE)
			error ("cannot initialize machine type");
	} else {
		/* already got error count in last scan_field() call.... */

		if ((lbp = scan_field (lbp)) == NULL)	/* machine ID */
			error ("invalid START record");

		if (strncmp (fldbuf, "DSP", 3) != 0)
			error ("invalid START record");

		if (!mach && (mach = setup_mach (&fldbuf[3])) == NONE)
			error ("invalid machine type");

		if ((lbp = scan_field (lbp)) == NULL)	/* skip asm version */
			error ("invalid START record");
	}

	if (get_comment () < 0)		/* skip comment */
		error ("invalid START record");

	if (opts)			/* single file option */
		open_files (NONE);

	return (YES);
}


static
get_record ()		/* look for next record in load file input */
{
	int field = 0;
	char *fbp = fldbuf + 1;

#if MPW
	SpinCursor (4);
#endif
	while (fldbuf[0] != NEWREC && (field = get_field ()) == 0)
		;

	if (field < 0)
		return (field);

	(void) strup (fbp);
	if (strcmp (fbp, "DATA") == 0)
		return (DATA);
	if (strcmp (fbp, "BLOCKDATA") == 0)
		return (BDATA);
	if (strcmp(fbp, "START") == 0)
		return (START);
	if (strcmp (fbp, "END") == 0)
		return (END);
	if (strcmp (fbp, "SYMBOL") == 0)
		return (SYMBOL);
	if (strcmp (fbp, "COMMENT") == 0)
		return (COMMENT);

	return (NONE);
}


static
get_data ()		/* process DATA records */
{
	int space, spc, i;
	unsigned long addr, val, count = 0L;
	struct srec *drec;

	if (get_field () < 0)		/* pick up memory space */
		error ("invalid DATA record");

	if ((spc = space = get_space ()) < 0)
		error ("invalid memory space specifier");

	if (opts) {			/* single file option */
		i = space + 1;
		space = NONE;
		if (s0addr != (unsigned)i) {
			bld_s0 ((unsigned)i);
			fputs (s0buf, rec[0]->fp);
			s0addr = (unsigned)i;
		}
	} else
		if (!rec[space])	/* see if files are open */
			open_files (space);

	if (get_field () < 0)		/* read in address field */
		error ("invalid DATA record");
	if (!fldhex ())
		error ("invalid address value");
	(void)sscanf (fldbuf, "%lx", &addr);	/* convert address */
	if (!optm && baddr)
		addr *= wsize;		/* adjust address for serial bytes */
	if (lmem && baddr)
		addr *= 2;		/* adjust address for long memory */

/*
	initialize data record fields
*/

	for (i = 0, drec = rec[space]; i < (optm ? wsize : 1); i++, drec++) {
		drec->checksum = 0;
		drec->p = drec->buf;
	}

/*
	loop to pick up data
*/

	while (get_field () == 0) {	/* get next data field */

		if (!fldhex ())
			error ("invalid data value");
		(void) sscanf (fldbuf, "%lx", &val);
		(void) sprintf (fldbuf, wrdfmt, val);
		(void) strup (fldbuf);
		if (strlen (fldbuf) != wsize * 2)
			error ("improper number of bytes in word");
		if (!reverse && !optm)
			rev_bytes ();
		get_bytes (space);	/* extract bytes from field */

/*
	if max record count reached, print out current record
*/

		count += optm ? 1L : wsize;
		if (!(count & 1L) && count >= MAXBYTE) {
			flush_rec (space, addr, count);
			if (waddr && !optm) {
				if (lmem && spc == LMEM)
					addr += (count / wsize) / 2L;
				else
					addr += count / wsize;
			} else
				addr += count;
			count = 0L;
		}
	}

/*
	new record or EOF encountered; flush out current record
*/

	if (rec[space]->p != rec[space]->buf)
		flush_rec (space, addr, count);
}


static
get_bdata ()		/* process BLOCKDATA records */
{
	int space, spc, i, j;
	unsigned long addr, val, count = 0L;
	unsigned repeat;
	struct srec *drec;

	if (get_field () < 0)		/* pick up memory space */
		error ("invalid BLOCKDATA record");

	if ((spc = space = get_space ()) < 0)
		error ("invalid memory space specifier");

	if (opts) {			/* single file option */
		i = space + 1;
		space = NONE;
		if (s0addr != (unsigned)i) {
			bld_s0 ((unsigned)i);
			fputs (s0buf, rec[0]->fp);
			s0addr = (unsigned)i;
		}
	} else
		if (!rec[space])	/* see if files are open */
			open_files (space);

	if (get_field () < 0)		/* read in address field */
		error ("invalid BLOCKDATA record");
	if (!fldhex ())
		error ("invalid address value");
	(void)sscanf (fldbuf, "%lx", &addr);	/* convert address */
	if (!optm && baddr)
		addr *= wsize;		/* adjust address for serial bytes */
	if (lmem && baddr)
		addr *= 2;		/* adjust address for long memory */

	if (get_field () < 0)		/* read in repeat field */
		error ("invalid BLOCKDATA record");
	if (!fldhex ())
		error ("invalid count value");
	(void)sscanf (fldbuf, "%x", &repeat);	/* save repeat value */

	if (get_field () < 0)		/* read in value field */
		error ("invalid BLOCKDATA record");
	if (!fldhex ())
		error ("invalid data value");
	(void) sscanf (fldbuf, "%lx", &val);
	(void) sprintf (fldbuf, wrdfmt, val);
	(void) strup (fldbuf);
	if (strlen (fldbuf) != wsize * 2)
		error ("improper number of bytes in word");
	if (!fldhex ())
		error ("invalid data value");
	if (!reverse && !optm)
		rev_bytes ();

/*
	initialize data record fields
*/

	for (i = 0, drec = rec[space]; i < (optm ? wsize : 1); i++, drec++) {
		drec->checksum = 0;
		drec->p = drec->buf;
	}

/*
	loop to generate data records
*/

	for (j = 0; j < repeat; j++) {

		get_bytes (space);	/* extract bytes from field */

/*
	if max record count reached, print out current record
*/

		count += optm ? 1L : wsize;
		if (!(count & 1L) && count >= MAXBYTE) {
			flush_rec (space, addr, count);
			if (waddr && !optm) {
				if (lmem && spc == LMEM)
					addr += (count / wsize) / 2L;
				else
					addr += count / wsize;
			} else
				addr += count;
			count = 0L;
		}
	}

/*
	new record or EOF encountered; flush out current record
*/

	if (rec[space]->p != rec[space]->buf)
		flush_rec (space, addr, count);
}


static
get_end ()		/* process END record, clean up, and exit */
{
	int i, field, space;
	unsigned long count = 1;	/* always a checksum byte */
	unsigned long addr, checksum = 0;
	struct srec *drec;

	if ((field = get_field ()) > 0)	/* try to get address field */
		error ("invalid END record");

	if (field == 0) {
		if (!fldhex ())
			error ("invalid address value");
		(void)sscanf (fldbuf, "%lx", &addr);	/* convert address */
		if (!optm && baddr)
			addr *= wsize;	/* adjust address for serial bytes */
		if (mach == DSP56000 || mach == DSP5616)
			(void)sprintf (fldbuf, "%04lx", addr);
		else
			(void)sprintf (fldbuf, "%08lx", addr);
		checksum = (unsigned)sum_addr (addr);
		count = ovrhd;
	}

	for (space = 0; space < (opts ? 1 : MSPACES); space++) {
		if (rec[space]) {
			for (i = 0, drec = opts ? rec[0] : rec[space];
			     i < (optm ? wsize : 1); i++, drec++) {
				if (mach == DSP56000 || mach == DSP5616)
					(void)sprintf (strbuf,
						"S9%02lx%s%02x\n",
						count,
						field == 0 ? fldbuf : "",
						~(checksum + count) & 0xff);
				else
					(void)sprintf (strbuf,
						"S7%02lx%s%02x\n",
						count,
						field == 0 ? fldbuf : "",
						~(checksum + count) & 0xff);
				fputs (strup (strbuf), drec->fp);
				(void)fclose (drec->fp);
			}
			free ((char *)rec[space]);
			rec[space] = NULL;
		}
	}
}


static
sum_addr (addr)		/* sum bytes of address */
unsigned long addr;
{
	int i, sum;

	for (i = 0, sum = 0; i < sizeof (unsigned long); i++) {
		sum += addr & 0xff;
		addr >>= 8;
	}
	return (sum);
}


static
get_bytes (space)	/* move bytes from field buffer into record buffer */
int space;
{
	int i, j;
	register char *fbp, *p;
	struct srec *drec;

	fbp = fldbuf;
	/* loop to move bytes, sum for checksum */
	for (i = 0, drec = rec[space]; i < wsize; i++, drec += optm ? 1 : 0) {
		p = drec->p;
		*p++ = *fbp++;
		*p++ = *fbp++;
		*p = EOS;
		(void)sscanf (drec->p, "%x", &j);
		drec->checksum += (unsigned)j;
		drec->p = p;
	}
}


static
flush_rec (space, addr, count)	/* flush S1/S3 record to appropriate file */
int space;
unsigned long addr, count;
{
	int i;
	struct srec *drec;

	count += ovrhd;
	for (i = 0, drec = rec[space]; i < (optm ? wsize : 1); i++, drec++) {
		drec->checksum += (unsigned)sum_addr (addr);
		if (mach == DSP56000 || mach == DSP5616)
			(void)sprintf (strbuf, "S1%02lx%04lx%s%02x\n",
				 count, addr, drec->buf,
				 ~(drec->checksum + count) & 0xff);
		else
			(void)sprintf (strbuf, "S3%02lx%08lx%s%02x\n",
				 count, addr, drec->buf,
				 ~(drec->checksum + count) & 0xff);
		fputs (strup (strbuf), drec->fp);
		drec->checksum = 0;
		drec->p = drec->buf;
	}
}


static
rev_bytes ()		/* reverse the bytes in fldbuf */
{
	char c;

	switch (mach) {
	case DSP96000:
		c = fldbuf[0];
		fldbuf[0] = fldbuf[6];
		fldbuf[6] = c;
		c = fldbuf[1];
		fldbuf[1] = fldbuf[7];
		fldbuf[7] = c;
		c = fldbuf[2];
		fldbuf[2] = fldbuf[4];
		fldbuf[4] = c;
		c = fldbuf[3];
		fldbuf[3] = fldbuf[5];
		fldbuf[5] = c;
		break;
	case DSP5616:
		c = fldbuf[0];
		fldbuf[0] = fldbuf[2];
		fldbuf[2] = c;
		c = fldbuf[1];
		fldbuf[1] = fldbuf[3];
		fldbuf[3] = c;
		break;
	case DSP56000:
	default:
		c = fldbuf[0];
		fldbuf[0] = fldbuf[4];
		fldbuf[4] = c;
		c = fldbuf[1];
		fldbuf[1] = fldbuf[5];
		fldbuf[5] = c;
		break;
	}
}


static
open_files (space)	/* open S-record ouput files */
int space;
{
	struct srec *drec;
	char fn[MAXSTR], *p;
	register i;
	char c;

/*
	allocate S-record structure array; construct output file name
*/

	if ((drec = (struct srec *)calloc (optm ? (unsigned)wsize :
					   (unsigned)1,
					   sizeof (struct srec))) == NULL)
		error ("cannot allocate S-record structure");
	rec[space] = drec;		/* squirrel pointer away */
	if (ifname) {	/* if explicit input file */
		c = opts ? 's' : fldbuf[0];
		(void)sprintf (fn, "%s.%c",
			       ifname, isupper (c) ? tolower (c) : c);
		p = fn + strlen (fn);
	}

/*
	loop to open all files, write out S0 record
*/

	if (!optm) {		/* don't need multiple files */
		if (!ifname)
			drec->fp = stdout;	/* if all else fails... */
		else {
			if ((drec->fp = fopen (fn, "w")) == NULL)
				error2 ("cannot open output file %s", fn);
			(void) setfile (fn, "TEXT", "MPS ");
		}
		if (!opts)
			fputs (s0buf, drec->fp);
	} else
		for (i = wsize - 1, rec[space] = drec; i >= 0; i--, drec++) {
			if (!ifname)
				drec->fp = stdout;
			else {
				*p = (char)(i + '0');
				*(p + 1) = EOS;
				if ((drec->fp = fopen (fn, "w")) == NULL)
					error2 ("cannot open output file %s",
						fn);
				(void) setfile (fn, "TEXT", "MPS ");
			}
			fputs (s0buf, drec->fp);
		}
}


static
get_field ()		/* get next field from ifile; put in fldbuf */
{
	register c;
	register char *p;

	while ((c = fgetc (ifile)) != EOF && isspace (c))
		if (c == '\n')
			linecount++;

	if (c == EOF)			/* end of object file */
		return (EOF);

	for (p = fldbuf, *p++ = c;	/* loop to pick up field value */
	     (c = fgetc (ifile)) != EOF && !isspace (c);
	     *p++ = c)
		;

	*p = EOS;			/* null at end of value */
	if (c != EOF)
		(void)ungetc (c, ifile); /* put back last char. if not EOF */

	return (*fldbuf == NEWREC ? 1 : 0);/* let caller know if new record */
}


static
get_comment ()		/* get comment from load file; put in fldbuf */
{
	register c;
	register char *p;

	while ((c = fgetc (ifile)) != EOF && c != '\n' && isspace (c))
		;			/* skip white space (except newline) */

	if (c == EOF || c != '\n')	/* end of file or synch error */
		return (EOF);

	linecount++;
	for (p = fldbuf; (c = fgetc (ifile)) != EOF && c != '\n'; *p++ = c)
		;			/* loop to pick up comment */
	if (c == '\n')
		linecount++;

	*p = EOS;			/* null at end of comment */

	return (0);			/* good return */
}


static
get_line ()		/* buffer line in strbuf */
{
	register char *p;
	register c;

	for (p = strbuf; (c = fgetc (ifile)) != EOF && c != '\n'; p++)
		*p = c;
	if (c == EOF || c != '\n')	/* end of file or synch error */
		return (EOF);
	*p = EOS;
	(void)ungetc (c, ifile);	/* put back new line */
	return (0);
}


static char *
scan_field (bp)		/* scan next field in strbuf; put in fldbuf */
register char *bp;
{
	register char *p;

	while (*bp && isspace (*bp))
		bp++;

	if (!*bp)			/* end of line */
		return (NULL);

	for (p = fldbuf; *bp && !isspace (*bp); *p++ = *bp++)
		;			/* loop to pick up field value */
	*p = EOS;			/* null at end of value */

	return (bp);			/* return current line pointer */
}


static
bld_s0 (space)
unsigned space;
{
	static char s0name[MAXSTR];

	if (space == NONE)
		(void)strcpy (s0name, s0buf);
	(void)sprintf (s0buf, "S0%02x%04x%s%02x\n",
		s0cnt, space, s0name, ~(s0sum + s0cnt + space) & 0xff);
	(void)strup (s0buf);
}


static
setup_mach (buf)
char *buf;
{
	int mach = NONE;

	if (strcmp (buf, "56000") == 0) {
		mach = DSP56000;
		wsize = WSIZE5;
		ovrhd = OVRHD5;
		wrdfmt = WRDFMT5;
	} else if (strcmp (buf, "96000") == 0) {
		mach = DSP96000;
		wsize = WSIZE9;
		ovrhd = OVRHD9;
		wrdfmt = WRDFMT9;
	} else if (strcmp (buf, "5616") == 0) {
		mach = DSP5616;
		wsize = WSIZE6;
		ovrhd = OVRHD6;
		wrdfmt = WRDFMT6;
	}
	return (mach);
}


static
get_space ()			/* return memory space attribute */
{
	switch (fldbuf[0]) {
	case 'X':
	case 'x':
		return (XMEM);
	case 'Y':
	case 'y':
		return (YMEM);
	case 'P':
	case 'p':
		return (PMEM);
	case 'L':
	case 'l':
		return (LMEM);
	default:
		return (-1);
	}
}


static char *
fix_fname (fname)		/* add extension to file name if reqd */
char *fname;
{
	int len = strlen (fname);
	char *fn;
	register char *p, *np, *ep = NULL;
	static char *defext = ".lod";

	if ((fn = malloc ((unsigned)(len + MAXEXTLEN + 1))) == NULL)
		error ("cannot allocate file name");
	(void)strcpy (fn, fname);

	np = p = fn + len; 	/* save end */

	while (p != fn) {
		if (*--p == '.')
			ep = p;
#if MSDOS
		if (*p == '\\' || *p == ':')
#endif
#if VMS
		if (*p == ']' || *p == ':')
#endif
#if UNIX
		if (*p == '/')
#endif
#if MAC
		if (*p == ':')
#endif
			break;
		else
			continue;
		}
	if (p != fn)
		p++;

	if (!ep) {	/* no extension supplied */
		(void)strcpy (np, defext);
		ep = np;
		np += strlen (defext);
	}

	if (np - p > BASENAMLEN) {	/* filename too long -- truncate */
		np = p + (BASENAMLEN - MAXEXTLEN);
		p = np;
		while (*ep && np < p + MAXEXTLEN)
			*np++ = *ep++;
		*np = EOS;
	}
	return (fn);
}


static char *
strup (str)			/* convert all alpha chars in str to upper */
char *str;
{
	register char *p = str;

	while (*p) {
		if (isalpha (*p) && islower (*p))
			*p = toupper (*p);
		p++;
	}
	return (str);
}


static
fldhex ()			/* insure fldbuf contains hex value */
{
	register char *p = fldbuf;

	while (*p) {
		if (!isxdigit (*p))
			break;
		p++;
	}
	if (!*p)
		return (YES);
	else
		return (NO);
}


static char *
basename (str)			/* return base part of file name in str */
char *str;
{
	register char *p;

	if (!str)		/* empty input */
		return (NULL);

	for (p = str + strlen (str); p >= str; --p)
#if MSDOS
		if( *p == '\\' || *p == ':')
#endif
#if VMS
		if( *p == ']' || *p == ':')
#endif
#if UNIX
		if( *p == '/' )
#endif
#if MAC
		if( *p == ':' )
#endif
			break;

	return (p < str ? str : ++p);
}


/**
* name		setfile --- set the file type and creator if necessary
*
* synopsis	yn = setfile (fn, type, creator)
*		int yn;		YES on success, NO on failure
*		char *fn;	pointer to file name
*		char *type;	pointer to file type
*		char *creator;	pointer to file creator
*
* description	Sets the file type and creator for newly-created Macintosh
*		output files.  Simply returns YES on other hosts.
*
**/
static
setfile (fn, type, creator)
char *fn, *type, *creator;
{
#if MPW
	int i;
	short status;
	struct FInfo finfo;
	OSType val;
	Str255 buf;

	(void) strcpy (&buf[1], fn);
	buf[0] = strlen (fn);
	if ((status = GetFInfo (buf, (short)0, &finfo)) != 0)
		return (NO);
	i = 0;
	val = (OSType) 0;
	while (i < sizeof (OSType)) {
		val <<= (OSType) 8;
		val += (OSType) type[i++];
	}
	finfo.fdType = val;
	i = 0;
	val = (OSType) 0;
	while (i < sizeof (OSType)) {
		val <<= (OSType) 8;
		val += (OSType) creator[i++];
	}
	finfo.fdCreator = val;
	if ((status = SetFInfo (buf, (short)0, &finfo)) != 0)
		return (NO);
#endif
#if LINT
	fn = fn;
	type = type;
	creator = creator;
#endif
	return (YES);
}


getopt (argc, argv, optstring)	/* get option letter from argv */
int argc;
char *argv[];
char *optstring;
{
	register char c;
	register char *place;
	static char *scan = NULL;
	extern char *index();

	optarg = NULL;

	if (scan == NULL || *scan == '\0') {
		if (optind == 0)
			optind++;
	
		if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0')
			return(EOF);
		if (strcmp(argv[optind], "--")==0) {
			optind++;
			return(EOF);
		}
	
		scan = argv[optind]+1;
		optind++;
	}

	c = *scan++;
	place = index(optstring, c);

	if (place == NULL || c == ':') {
		(void)fprintf(stderr, "%s: unknown option -%c\n", argv[0], c);
		return('?');
	}

	place++;
	if (*place == ':') {
		if (*scan != '\0') {
			optarg = scan;
			scan = NULL;
		} else if (optind < argc) {
			optarg = argv[optind];
			optind++;
		} else {
			(void)fprintf( stderr, "%s: -%c argument missing\n", 
					argv[0], c);
			return( '?' );
		}
	}

	return(c);
}


/**
*
* name		dcl_getval - get DCL command line value
*
* synopsis	status = dcl_getval (opt)
*		int status;	return status from cli$get_value
*		struct dsc$descriptor_s *opt;	pointer to command line option
*
* description	Calls the VMS DCL routine cli$get_value to return values
*		for the command line option referenced by opt.  The values
*		are returned in the global dclbuf array.  The length returned
*		from cli$get_value is used to terminate the string.
*
**/
static
dcl_getval (opt)
#if VMS
struct dsc$descriptor_s *opt;
#else
int *opt;
#endif
{
#if VMS
	unsigned status, len = 0;
	
	status = cli$get_value (opt, &arg_desc, &len);
	if (status != CLI$_ABSENT)
		dclbuf[len] = EOS;
	return (status);
#else
	return (*opt);
#endif
}


#if VMS
/**
*
* name		dcl_reset - reset DCL command line
*
* synopsis	yn = dcl_reset ()
*		int yn;		YES/NO for errors
*
* description	Resets the DCL command line so that it may be reparsed.
*		Returns YES if command line is reset, NO on error.
*
**/
static
dcl_reset ()
{
	return (cli$dcl_parse(NULL, NULL) == CLI$_NORMAL);
}
#endif


#if BSD
static
#else
static void
#endif
onintr ()			/* clean up from signal */
{
	error ("Interrupted");
}


static
usage ()			/* display usage on stderr, exit nonzero */
{
#if !MSDOS
        (void)fprintf (stderr, "%s  %s\n%s\n", Progtitle, Version, Copyright);
#endif
	(void)fprintf (stderr, "Usage: %s [-blmrsw] [-p <procno>] <input file ... >\n",	Progname);
	(void) fprintf (stderr, "        b - byte addressing\n");
	(void) fprintf (stderr, "        l - long (double-word) addressing\n");
	(void) fprintf (stderr, "        m - multiple output files\n");
	(void) fprintf (stderr, "        p - <procno> load file format\n");
	(void) fprintf (stderr, "        r - reverse bytes in word\n");
	(void) fprintf (stderr, "        s - single output file\n");
	(void) fprintf (stderr, "        w - word addressing\n");
#if LSC
	longjmp (Env, 1);
#else
	exit (ERR);
#endif
}


static
error (str)
char *str;
{
	(void)fprintf (stderr, "%s: at line %d: ", Progname, linecount);
	(void)fprintf (stderr, "%s\n", str);
#if LSC
	longjmp (Env, 1);
#else
	exit (ERR);
#endif
}


static
error2 (fmt, str)
char *fmt, *str;
{
	(void)fprintf (stderr, "%s: at line %d: ", Progname, linecount);
	(void)fprintf (stderr, fmt, str);
	(void)fprintf (stderr, "\n");
#if LSC
	longjmp (Env, 1);
#else
	exit (ERR);
#endif
}
