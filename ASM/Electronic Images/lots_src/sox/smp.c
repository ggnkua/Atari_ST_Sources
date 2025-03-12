/*
 * June 30, 1992
 * Copyright 1992 Leigh Smith And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Leigh Smith And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools SampleVision file format driver.
 * Output is always in little-endian (80x86/VAX) order.
 * 
 * Derived from: Sound Tools skeleton handler file.
 */

#include "st.h"
#include <string.h>

#define NAMELEN    30		/* Size of Samplevision name */
#define COMMENTLEN 60		/* Size of Samplevision comment, not shared */
#define MIDI_UNITY 60		/* MIDI note number to play sample at unity */

/* The header preceeding the sample data */
struct smpheader {
	char Id[18];		/* File identifier */
	char version[4];	/* File version */
	char comments[COMMENTLEN];	/* User comments */
	char name[NAMELEN + 1];	/* Sample Name, left justified */
};
#define HEADERSIZE (sizeof(struct smpheader) - 1)	/* -1 for name's \0 */

/* Samplevision loop definition structure */
struct loop {
	unsigned long start; /* Sample count into sample data, not byte count */
	unsigned long end;   /* end point */
	char type;	     /* 0 = loop off, 1 = forward, 2 = forw/back */
	short count;	     /* No of times to loop */
};

/* Samplevision marker definition structure */
struct marker {
	char name[10];		/* Ascii Marker name */
	unsigned long position;	/* Sample Number, not byte number */
};

/* The trailer following the sample data */
struct smptrailer {
	struct loop loops[8];		/* loops */
	struct marker markers[8];	/* markers */
	char MIDInote;			/* for unity pitch playback */
	unsigned long rate;		/* in hertz */
	unsigned long SMPTEoffset;	/* in subframes */
	unsigned long CycleSize;	/* sample count in one cycle of the */
					/* sampled sound -1 if unknown */
};

/* Private data for SMP file */
typedef struct smpstuff {
	unsigned long NoOfSamps;	/* Sample data count in words */
	char comment[NAMELEN + 1];	/* comment memory resides in private */
} *smp_t;				/* data because it's small */

char *SVmagic = "SOUND SAMPLE DATA ", *SVvers = "2.1 ";

IMPORT float volume, amplitude;
IMPORT int summary, verbose;

/*
 * Read the SampleVision trailer structure.
 * Returns 1 if everything was read ok, 0 if there was an error.
 */
static int readtrailer(ft, trailer)
ft_t ft;
struct smptrailer *trailer;
{
	int i;

	rlshort(ft);			/* read reserved word */
	for(i = 0; i < 8; i++) {	/* read the 8 loops */
		trailer->loops[i].start = rllong(ft);
		trailer->loops[i].end = rllong(ft);
		trailer->loops[i].type = getc(ft->fp);
		trailer->loops[i].count = rlshort(ft);
	}
	for(i = 0; i < 8; i++) {	/* read the 8 markers */
		if (fread(trailer->markers[i].name, 1, 10, ft->fp) != 10)
			return(0);
		trailer->markers[i].position = rllong(ft);
	}
	trailer->MIDInote = getc(ft->fp);
	trailer->rate = rllong(ft);
	trailer->SMPTEoffset = rllong(ft);
	trailer->CycleSize = rllong(ft);
	return(1);
}

/*
 * set the trailer data - loops and markers, to reasonably benign values
 */
static settrailer(trailer, rate)
struct smptrailer *trailer;
unsigned int rate;
{
	int i;

	trailer->loops[0].start = ~0;	/* set first loop start as FFFFFFFF */
	trailer->loops[0].end = 0;	/* to mark it as not set */
	trailer->loops[0].type = 0;
	trailer->loops[0].count = 0;
	for(i = 1; i < 8; i++) {	/* assign the 7 other loops */
		trailer->loops[i].start = 0;
		trailer->loops[i].end = 0;
		trailer->loops[i].type = 0;
		trailer->loops[i].count = 0;
	}
	for(i = 0; i < 8; i++) {	/* write the 8 markers */
		strcpy(trailer->markers[i].name, "          ");
		trailer->markers[i].position = ~0;
	}
	trailer->MIDInote = MIDI_UNITY;		/* Unity play back */
	trailer->rate = rate;
	trailer->SMPTEoffset = 0;
	trailer->CycleSize = -1;
}

/*
 * Write the SampleVision trailer structure.
 * Returns 1 if everything was written ok, 0 if there was an error.
 */
static int writetrailer(ft, trailer)
ft_t ft;
struct smptrailer *trailer;
{
	int i;

	wlshort(ft, 0);			/* write the reserved word */
	for(i = 0; i < 8; i++) {	/* write the 8 loops */
		wllong(ft, trailer->loops[i].start);
		wllong(ft, trailer->loops[i].end);
		putc(trailer->loops[i].type, ft->fp);
		wlshort(ft, trailer->loops[i].count);
	}
	for(i = 0; i < 8; i++) {	/* write the 8 markers */
		if (fwrite(trailer->markers[i].name, 1, 10, ft->fp) != 10)
			return(0);
		wllong(ft, trailer->markers[i].position);
	}
	putc(trailer->MIDInote, ft->fp);
	wllong(ft, trailer->rate);
	wllong(ft, trailer->SMPTEoffset);
	wllong(ft, trailer->CycleSize);
	return(1);
}

/*
 * Do anything required before you start reading samples.
 * Read file header. 
 *	Find out sampling rate, 
 *	size and style of samples, 
 *	mono/stereo/quad.
 */
smpstartread(ft) 
ft_t ft;
{
	smp_t smp = (smp_t) ft->priv;
	int littlendian = 0, i;
	long samplestart;
	char *endptr;
	struct smpheader header;
	struct smptrailer trailer;

	/* If you need to seek around the input file. */
	if (! ft->seekable)
		fail("SMP input file must be a file, not a pipe");

	/* Read SampleVision header */
	if (fread((char *) &header, 1, HEADERSIZE, ft->fp) != HEADERSIZE)
		fail("unexpected EOF in SMP header");
	if (strncmp(header.Id, SVmagic, 17) != 0)
		fail("SMP header does not begin with magic word %s\n", SVmagic);
	if (strncmp(header.version, SVvers, 4) != 0)
		fail("SMP header is not version %s\n", SVvers);

	strncpy(smp->comment, header.name, NAMELEN);
        for (i = NAMELEN; i >= 0 && smp->comment[i] == ' '; i--)
		smp->comment[i] = '\0';
	ft->comment = smp->comment;
	report("SampleVision File name: %s", ft->comment);
	report("File comments: %.*s", COMMENTLEN, header.comments);
	/* Extract out the sample size (always intel format) */
	smp->NoOfSamps = rllong(ft);
	/* mark the start of the sample data */
	samplestart = ftell(ft->fp);

	/* seek from the current position (the start of sample data) by */
	/* NoOfSamps * 2 */
	if (fseek(ft->fp, smp->NoOfSamps * 2L, 1) == -1)
		fail("SMP unable to seek to trailer");
	if (!readtrailer(ft, &trailer))
		fail("unexpected EOF in SMP trailer");

	/* seek back to the beginning of the data */
	if (fseek(ft->fp, samplestart, 0) == -1) 
		fail("SMP unable to seek back to start of sample data");

	ft->info.rate = (int) trailer.rate;
	ft->info.size = WORD;
	ft->info.style = SIGN2;
	ft->info.channels = 1;

	endptr = (char *) &littlendian;
	*endptr = 1;
	if (littlendian != 1)
		ft->swap = 1;
}

/*
 * Read up to len samples from file.
 * Convert to signed longs.
 * Place in buf[].
 * Return number of samples read.
 */
smpread(ft, buf, len) 
ft_t ft;
long *buf, len;
{
	smp_t smp = (smp_t) ft->priv;
	register long datum;
	int done = 0;
	
	for(; done < len && smp->NoOfSamps; done++, smp->NoOfSamps--) {
		datum = rshort(ft);
		/* scale signed up to long's range */
		*buf++ = LEFT(datum, 16);
	}
	return done;
}

/*
 * Do anything required when you stop reading samples.  
 * Don't close input file! 
 */
smpstopread(ft) 
ft_t ft;
{
}

smpstartwrite(ft) 
ft_t ft;
{
	smp_t smp = (smp_t) ft->priv;
	struct smpheader header;

	/* If you have to seek around the output file */
	if (! ft->seekable)
		fail("Output .smp file must be a file, not a pipe");

	/* If your format specifies any of the following info. */
	ft->info.size = WORD;
	ft->info.style = SIGN2;
	ft->info.channels = 1;

	strcpy(header.Id, SVmagic);
	strcpy(header.version, SVvers);
	sprintf(header.comments, "%-*s", COMMENTLEN, "Converted using Sox.");
	sprintf(header.name, "%-*.*s", NAMELEN, NAMELEN, ft->comment);

	/* Write file header */
	if(fwrite(&header, 1, HEADERSIZE, ft->fp) != HEADERSIZE)
		fail("SMP: Can't write header completely");
	wllong(ft, 0);	/* write as zero length for now, update later */
	smp->NoOfSamps = 0;
}

smpwrite(ft, buf, len) 
ft_t ft;
long *buf, len;
{
	smp_t smp = (smp_t) ft->priv;
	register int datum;

	while(len--) {
		datum = RIGHT(*buf++, 16);
		wlshort(ft, datum);
		smp->NoOfSamps++;
	}
	/* If you cannot write out all of the supplied samples, */
	/*	fail("SMP: Can't write all samples to %s", ft->filename); */
}

smpstopwrite(ft) 
ft_t ft;
{
	smp_t smp = (smp_t) ft->priv;
	struct smptrailer trailer;

	/* Assign the trailer data */
	settrailer(&trailer, ft->info.rate);
	writetrailer(ft, &trailer);
	if (fseek(ft->fp, 112, 0) == -1)
		fail("SMP unable to seek back to save size");
	wllong(ft, smp->NoOfSamps);
}
