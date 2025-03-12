/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

#include "st.h"
#if	defined(unix) || defined(AMIGA)
#include <sys/types.h>
#include <sys/stat.h>
#endif
#ifdef	__STDC__
#include <stdarg.h>
#else
#include <varargs.h>
#endif
#include <ctype.h>
#include <string.h>
#ifdef VMS
#include <errno.h>
#include <perror.h>
#define LASTCHAR        ']'
#else
#include <errno.h>
#define LASTCHAR        '/'
#endif

/*
 * SOX main program.
 *
 * Rewrite for new nicer option syntax.  July 13, 1991.
 * Rewrite for separate effects library.  Sep. 15, 1991.
 */

#ifdef AMIGA
/* This is the Amiga version string */
char amiversion[AmiVerSize]=AmiVerChars;      
#endif /* AMIGA */


EXPORT float volume = 1.0;	/* expansion coefficient */
int dovolume = 0;
int clipped = 0;	/* Volume change clipping errors */

EXPORT float amplitude = 1.0;	/* Largest sample so far */

EXPORT int writing = 0;	/* are we writing to a file? */

/* export flags */
EXPORT int verbose = 0;	/* be noisy on stderr */
EXPORT int summary = 0;	/* just print summary of information */

long ibuf[BUFSIZ];	/* Intermediate processing buffer */
long obuf[BUFSIZ];	/* Intermediate processing buffer */


long volumechange();

#ifdef	DOS
char writebuf[BUFSIZ];	/* output write buffer */
#endif

void	gettype(), geteffect(), checkeffect();

EXPORT struct soundstream informat, outformat;

char *myname;

ft_t ft;
struct effect eff;
char *ifile, *ofile, *itype, *otype;
IMPORT char *optarg;
IMPORT int optind;

main(n, args)
int n;
char **args;
{
	myname = args[0];
	init();
	
	ifile = ofile = NULL;

	/* Get input format options */
	ft = &informat;
	doopts(n, args);
	/* Get input file */
	if (optind >= n)
#ifndef	VMS
		usage("No input file?");
#else
		/* I think this is the VMS patch, but am not certain */
		fail("Input file required");	
#endif
	ifile = args[optind];
	if (! strcmp(ifile, "-"))
		ft->fp = stdin;
	else if ((ft->fp = fopen(ifile, READBINARY)) == NULL)
		fail("Can't open input file '%s': %s", 
			ifile, strerror(errno));
	ft->filename = ifile;
	optind++;

	/* Let -e allow no output file, just do an effect */
	if (optind < n) {
	    if (strcmp(args[optind], "-e")) {
		/* Get output format options */
		ft = &outformat;
		doopts(n, args);
		/* Get output file */
		if (optind >= n)
			usage("No output file?");
		ofile = args[optind];
		ft->filename = ofile;
		/*
		 * There are two choices here:
		 *	1) stomp the old file - normal shell "> file" behavior
		 *	2) fail if the old file already exists - csh mode
		 */
		if (! strcmp(ofile, "-"))
			ft->fp = stdout;
		else {
#ifdef	unix
		 	/*	
			 * Remove old file if it's a text file, but 
		 	 * preserve Unix /dev/sound files.  I'm not sure
			 * this needs to be here, but it's not hurting
			 * anything.
			 */
			if ((ft->fp = fopen(ofile, WRITEBINARY)) && 
				   (filetype(fileno(ft->fp)) == S_IFREG)) {
				fclose(ft->fp);
				unlink(ofile);
				creat(ofile, 0666);
				ft->fp = fopen(ofile, WRITEBINARY);
			}
#else
			ft->fp = fopen(ofile, WRITEBINARY);
#endif
			if (ft->fp == NULL)
				fail("Can't open output file '%s': %s", 
					ofile, strerror(errno));
#ifdef	DOS
			if (setvbuf (ft->fp,writebuf,_IOFBF,sizeof(writebuf)))
				fail("Can't set write buffer");
#endif
		}
		writing = 1;
	    }
	    optind++;
	}

	/* ??? */
/*
	if ((optind < n) && !writing && !eff.name)
		fail("Can't do an effect without an output file!");
*/

	/* Get effect name */
	if (optind < n) {
		eff.name = args[optind];
		optind++;
		geteffect(&eff);
		(* eff.h->getopts)(&eff, n - optind, &args[optind]);
	}

	/* 
	 * If we haven't specifically set an output file 
	 * don't write a file; we could be doing a summary
	 * or a format check.
	 */
/*
	if (! ofile)
		usage("Must be given an output file name");
*/
	if (! ofile)
		writing = 0;
	/* Check global arguments */
	if (volume <= 0.0)
		fail("Volume must be greater than 0.0");
#if	defined(unix) || defined(AMIGA)
	informat.seekable  = (filetype(fileno(informat.fp)) == S_IFREG);
	outformat.seekable = (filetype(fileno(outformat.fp)) == S_IFREG); 
#else
#if	defined(DOS)
	informat.seekable  = 1;
	outformat.seekable = 1;
#else
	informat.seekable  = 0;
	outformat.seekable = 0;
#endif
#endif

	/* If file types have not been set with -t, set from file names. */
	if (! informat.filetype) {
		if (informat.filetype = strrchr(ifile, LASTCHAR))
			informat.filetype++;
		else
			informat.filetype = ifile;
		if (informat.filetype = strrchr(informat.filetype, '.'))
			informat.filetype++;
		else /* Default to "auto" */
			informat.filetype = "auto";
	}
	if (writing && ! outformat.filetype) {
		if (outformat.filetype = strrchr(ofile, LASTCHAR))
			outformat.filetype++;
		else
			outformat.filetype = ofile;
		if (outformat.filetype = strrchr(outformat.filetype, '.'))
			outformat.filetype++;
	}
	/* Default the input comment to the filename. 
	 * The output comment will be assigned when the informat 
	 * structure is copied to the outformat. 
	 */
	informat.comment = informat.filename;

	process();
	statistics();
	exit(0);
}

doopts(n, args)
int n;
char **args;
{
	int c;
	char *str;

	while ((c = getopt(n, args, "r:v:t:c:suUAbwlfdDxSV")) != -1) {
		switch(c) {
		case 't':
			if (! ft) usage("-t");
			ft->filetype = optarg;
			if (ft->filetype[0] == '.')
				ft->filetype++;
			break;

		case 'r':
			if (! ft) usage("-r");
			str = optarg;
			if ((! sscanf(str, "%lu", &ft->info.rate)) ||
					(ft->info.rate <= 0))
				fail("-r must be given a positive integer");
			break;
		case 'v':
			if (! ft) usage("-v");
			str = optarg;
			if ((! sscanf(str, "%e", &volume)) ||
					(volume <= 0))
				fail("Volume value '%s' is not a number",
					optarg);
			dovolume = 1;
			break;

		case 'c':
			if (! ft) usage("-c");
			str = optarg;
			if (! sscanf(str, "%d", &ft->info.channels))
				fail("-c must be given a number");
			break;
		case 'b':
			if (! ft) usage("-b");
			ft->info.size = BYTE;
			break;
		case 'w':
			if (! ft) usage("-w");
			ft->info.size = WORD;
			break;
		case 'l':
			if (! ft) usage("-l");
			ft->info.size = LONG;
			break;
		case 'f':
			if (! ft) usage("-f");
			ft->info.size = FLOAT;
			break;
		case 'd':
			if (! ft) usage("-d");
			ft->info.size = DOUBLE;
			break;
		case 'D':
			if (! ft) usage("-D");
			ft->info.size = IEEE;
			break;

		case 's':
			if (! ft) usage("-s");
			ft->info.style = SIGN2;
			break;
		case 'u':
			if (! ft) usage("-u");
			ft->info.style = UNSIGNED;
			break;
		case 'U':
			if (! ft) usage("-U");
			ft->info.style = ULAW;
			break;
		case 'A':
			if (! ft) usage("-A");
			ft->info.style = ALAW;
			break;
		
		case 'x':
			if (! ft) usage("-x");
			ft->swap = 1;
			break;
		
/*  stat effect does this ?
		case 'S':
			summary = 1;
			break;
*/
		case 'V':
			verbose = 1;
			break;
		}
	}
}

init() {

	/* init files */
	informat.info.rate      = outformat.info.rate  = 0;
	informat.info.size      = outformat.info.size  = -1;
	informat.info.style     = outformat.info.style = -1;
	informat.info.channels  = outformat.info.channels = -1;
	informat.comment   = outformat.comment = NULL;
	informat.swap      = 0;
	informat.filetype  = outformat.filetype  = (char *) 0;
	informat.fp        = stdin;
	outformat.fp       = stdout;
	informat.filename  = "input";
	outformat.filename = "output";
}

/* 
 * Process input file -> effect -> output file
 *	one buffer at a time
 */

process() {
	long isamp, osamp, istart;
	long i, idone, odone;

	gettype(&informat);
	if (writing)
		gettype(&outformat);
	/* Read and write starters can change their formats. */
	(* informat.h->startread)(&informat);
	checkformat(&informat);
	report("Input file: using sample rate %u\n\tsize %s, style %s, %d %s",
		informat.info.rate, sizes[informat.info.size], 
		styles[informat.info.style], informat.info.channels, 
		(informat.info.channels > 1) ? "channels" : "channel");
	if (informat.comment)
		report("Input file: comment \"%s\"\n",
			informat.comment);
	if (writing) {
		copyformat(&informat, &outformat);
		(* outformat.h->startwrite)(&outformat);
		checkformat(&outformat);
		cmpformats(&informat, &outformat);
	report("Output file: using sample rate %u\n\tsize %s, style %s, %d %s",
		outformat.info.rate, sizes[outformat.info.size], 
		styles[outformat.info.style], outformat.info.channels, 
		(outformat.info.channels > 1) ? "channels" : "channel");
		if (outformat.comment)
			report("Output file: comment \"%s\"\n",
				outformat.comment);
	}
	/* Very Important: 
	 * Effect fabrication and start is called AFTER files open.
	 * Effect may write out data beforehand, and
	 * some formats don't know their sample rate until now.
	 */
	checkeffect(0);
	/* inform effect about signal information */
	eff.ininfo = informat.info;
	eff.outinfo = outformat.info;
	(* eff.h->start)(&eff);
	istart = 0;
	while((isamp = (*informat.h->read)(&informat,&ibuf[istart],
			(long) BUFSIZ-istart))>0) {
		long *ib = ibuf;

		isamp += istart;
		/* Do volume before effect or after?  idunno */
		if (dovolume) for (i = 0; i < isamp; i++)
			ibuf[i] = volumechange(ibuf[i]);
		osamp = sizeof(obuf) / sizeof(long);
		/* Effect (i.e. rate change) may do different sizes I and O */
		while (isamp) {
			idone = isamp;
			odone = osamp;
			(* eff.h->flow)(&eff, ib, obuf, &idone, &odone);
			/* 
			 * kludge! 	
			 * Effect is stuck.  Start over with new buffer.
			 * This can drop samples at end of file. 
			 * No effects currently do this, but it could happen.
			 */
			if (idone == 0) {
				int i;
				for(i = isamp - 1; i; i--)
					ibuf[i] = ib[i];
				istart = isamp;
				isamp = 0;
				break;
			}
			if (writing && (odone > 0)) 
				(* outformat.h->write)(&outformat, obuf, (long) odone);
			isamp -= idone;
			ib += idone;
		}
	}
	/* Drain effect out */
	if (writing) {
		odone = sizeof(obuf) / sizeof(long);
		(* eff.h->drain)(&eff, obuf, &odone);
		if (odone > 0)
			(* outformat.h->write)(&outformat, obuf, (long) odone);
		/* keep calling it until it returns a partial buffer */
		while (odone == (sizeof(obuf) / sizeof(long))) {
			(* eff.h->drain)(&eff, obuf, &odone);
			if (odone)
			 (* outformat.h->write)(&outformat, obuf, (long) odone);
		}
	}
	/* Very Important: 
	 * Effect stop is called BEFORE files close.
	 * Effect may write out more data after. 
	 */
	(* eff.h->stop)(&eff);
	(* informat.h->stopread)(&informat);
	fclose(informat.fp);
	if (writing)
		(* outformat.h->stopwrite)(&outformat);
	if (writing)
		fclose(outformat.fp);
}

/*
 * Check that we have a known format suffix string.
 */
void
gettype(formp)
ft_t formp;
{
	char **list;
	int i;

	if (! formp->filetype)
fail("Must give file type for %s file, either as suffix or with -t option",
formp->filename);
	for(i = 0; formats[i].names; i++) {
		for(list = formats[i].names; *list; list++) {
			char *s1 = *list, *s2 = formp->filetype;
			if (! strcmpcase(s1, s2))
				break;	/* not a match */
		}
		if (! *list)
			continue;
		/* Found it! */
		formp->h = &formats[i];
		return;
	}
	if (! strcmpcase(formp->filetype, "snd")) {
		verbose = 1;
		report("File type '%s' is used to name several different formats.", formp->filetype);
		report("If the file came from a Macintosh, it is probably");
		report("a .ub file with a sample rate of 11025 (or possibly 5012 or 22050).");
		report("Use the sequence '-t .ub -r 11025 file.snd'");
		report("If it came from a PC, it's probably a Soundtool file.");
		report("Use the sequence '-t .sndt file.snd'");
		report("If it came from a NeXT, it's probably a .au file.");
		fail("Use the sequence '-t .au file.snd'\n");
	}
	fail("File type '%s' of %s file is not known!",
		formp->filetype, formp->filename);
}

copyformat(ft, ft2)
ft_t ft, ft2;
{
	int noise = 0;
	if (ft2->info.rate == 0) {
		ft2->info.rate = ft->info.rate;
		noise = 1;
	}
	if (outformat.info.size == -1) {
		ft2->info.size = ft->info.size;
		noise = 1;
	}
	if (outformat.info.style == -1) {
		ft2->info.style = ft->info.style;
		noise = 1;
	}
	if (outformat.info.channels == -1) {
		ft2->info.channels = ft->info.channels;
		noise = 1;
	}
	if (outformat.comment == NULL) {
		ft2->comment = ft->comment;
		noise = 1;
	}
	return noise;
}

cmpformats(ft, ft2)
ft_t ft, ft2;
{
	int noise = 0;
	float abs;

}

/* check that all settings have been given */
checkformat(ft) 
ft_t ft;
{
	if (ft->info.rate == 0)
		fail("Sampling rate for %s file was not given\n", ft->filename);
	if ((ft->info.rate < 100) || (ft->info.rate > 50000))
		fail("Sampling rate %u for %s file is bogus\n", 
			ft->info.rate, ft->filename);
	if (ft->info.size == -1)
		fail("Data size was not given for %s file\nUse one of -b/-w/-l/-f/-d/-D", ft->filename);
	if (ft->info.style == -1)
		fail("Data style was not given for %s file\nUse one of -s/-u/-U/-A", ft->filename);
	/* it's so common, might as well default */
	if (ft->info.channels == -1)
		ft->info.channels = 1;
	/*	fail("Number of output channels was not given for %s file",
			ft->filename); */
}

/*
 * If no effect given, decide what it should be.
 */
void
checkeffect(effp)
eff_t effp;
{
	int already = (eff.name != (char *) 0);
	char *rate = 0, *chan = 0;
	int i;

	for (i = 0; effects[i].name; i++) {
		if (!chan && (effects[i].flags & EFF_CHAN))
			chan = effects[i].name;
		if (! rate && (effects[i].flags & EFF_RATE))
			rate = effects[i].name;
	}

	if (eff.name && ! writing)
		return;

	/* 
	 * Require mixdown for channel mismatch.
	 * XXX Doesn't handle channel expansion.  Need an effect for this.
	 * Require one of the rate-changers on a rate change.
	 * Override a rate change by explicitly giving 'copy' command.
	 */
	if (informat.info.channels != outformat.info.channels) {
		if (eff.name && !(eff.h->flags & EFF_CHAN))
			fail("Need to do change number of channels first.  Try the '%s' effect.", chan);
		if (! eff.name) {
			eff.name = chan;
			report(
"Changing %d input channels to %d output channels with '%s' effect\n",
			informat.info.channels, outformat.info.channels, chan);
			geteffect(&eff);
		}
	} 
	/* 
	 * Be liberal on rate difference errors.
	 * Note that the SPARC 8000-8192 problem
	 * comes in just under the wire.  XXX
	 *
 	 * Bogus.  Should just do a percentage.
	 */
	if (abs(informat.info.rate - outformat.info.rate) > 200) {
		if (eff.name && !(eff.h->flags & EFF_RATE))
		    fail("Need to do rate change first.  Try the '%s' effect.", 
			rate);
		if (! eff.name) {
			eff.name = rate;
			report(
"Changing sample rate %u to rate %u via noisy 'rate' effect\n",
			informat.info.rate, outformat.info.rate);
			geteffect(&eff);
		}
	}
	/* don't need to change anything */
	if (! eff.name)
		eff.name = "copy";
	if (! already) {
		geteffect(&eff);
		/* give default opts for manufactured effect */
		(* eff.h->getopts)(&eff, 0, (char *) 0);
	}
}

/*
 * Check that we have a known effect name.
 */
void
geteffect(effp)
eff_t effp;
{
	int i;

	for(i = 0; effects[i].name; i++) {
		char *s1 = effects[i].name, *s2 = effp->name;
		while(*s1 && *s2 && (tolower(*s1) == tolower(*s2)))
			s1++, s2++;
		if (*s1 || *s2)
			continue;	/* not a match */
		/* Found it! */
		effp->h = &effects[i];
		return;
	}
	/* Guido Van Rossum fix */
	fprintf(stderr, "Known effects:");
	for (i = 0; effects[i].name; i++)
		fprintf(stderr, "\t%s\n", effects[i].name);
	fail("\nEffect '%s' is not known!", effp->name);
}

/* Guido Van Rossum fix */
statistics() {
	if (dovolume && clipped > 0)
		report("Volume change clipped %d samples", clipped);
}

long volumechange(y)
long y;
{
	double y1;

	y1 = y * volume;
	if (y1 < -2147483647.0) {
		y1 = -2147483647.0;
		clipped++;
	}
	else if (y1 > 2147483647.0) {
		y1 = 2147483647.0;
		clipped++;
	}

	return y1;
}

#if	defined(unix) || defined(AMIGA)
filetype(fd)
int fd;
{
	struct stat st;

	fstat(fd, &st);

	return st.st_mode & S_IFMT;
}
#endif

char *usagestr = 
"[ -V -S ] [ fopts ] ifile [ fopts ] ofile [ effect [ effopts ] ]\nfopts: -r rate -v volume -c channels -s/-u/-U/-A -b/-w/-l/-f/-d/-D -x\neffects and effopts: various";

usage(opt)
char *opt;
{
#ifndef	DOS
	/* single-threaded machines don't really need this */
	fprintf(stderr, "%s: ", myname);
#endif
	fprintf(stderr, "Usage: %s", usagestr);
	if (opt)
		fprintf(stderr, "\nFailed at: %s\n", opt);
	exit(1);
}

void
#ifdef	__STDC__
report(char *fmt, ...)
#else
report(va_alist) 
va_dcl
#endif
{
	va_list args;
#ifndef	__STDC__
	char *fmt;
#endif

	if (! verbose)
		return;
#ifndef	DOS
	/* single-threaded machines don't really need this */
	fprintf(stderr, "%s: ", myname);
#endif
#ifdef	__STDC__
	va_start(args, fmt);
#else
	va_start(args);
	fmt = va_arg(args, char *);
#endif
	vfprintf(stderr, fmt, args);
	va_end(args);
	fprintf(stderr, "\n");
}

void
#ifdef	__STDC__
fail(char *fmt, ...)
#else
fail(va_alist) 
va_dcl
#endif
{
	va_list args;
#ifndef	__STDC__
	char *fmt;
#endif

#ifndef	DOS
	/* single-threaded machines don't really need this */
	fprintf(stderr, "%s: ", myname);
#endif
#ifdef	__STDC__
	va_start(args, fmt);
#else
	va_start(args);
	fmt = va_arg(args, char *);
#endif
	vfprintf(stderr, fmt, args);
	va_end(args);
	fprintf(stderr, "\n");
	exit(2);
}


strcmpcase(s1, s2)
char *s1, *s2;
{
	while(*s1 && *s2 && (tolower(*s1) == tolower(*s2)))
		s1++, s2++;
	return *s1 - *s2;
}
