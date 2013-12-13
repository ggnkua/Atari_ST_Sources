/*
 * myscat - a MaxYMiser song file concatenator
 * by Zerkman / Sector One
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

/*
 * v1.0 - 2011-08-03 - Initial version.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#ifdef __M68K__
#include <osbind.h>
#endif

#define HEAD_SIZE (sizeof(struct mys_file) - sizeof(struct pattern_entry))

struct pattern_entry {
	char note_num;
	char inst_num;
	char volume;
	char eff1_type;
	char eff1_num;
	char eff2_type;
	char eff2_num;
	char rle;		/* 7 RLE byte - number of empty lines to next used line */
};

struct mys_file {
	char TAGtracker[8];		/* MYM?TRAK */

	char currentsongpos;
	char currentpattpos;
	char currpattposedit;
	char oldpattposedit;

	char currentpattern1;
	char currentpattern2;
	char currentpattern3;
	char currentpattern4;

	char add;
	char pastemode;			/* 0 = overwrite, 1 = overlay, 2 = underlay */
	char lowlevelmask;
	char scrollpattern;
	char octave;

	char songspeed;
	char timercfreq;		/* 50->200 = timercfreq */

	char currentinstedit;
	char destinstedit;
	char instrumentbank;

	char editorcolourr1;	/* highlight */
	char editorcolourg1;
	char editorcolourb1;
	char editorcolourr2;	/* maus */
	char editorcolourg2;
	char editorcolourb2;
	char mauspointertype;

	char playing;
	char recording;
	char patternplay;

	char currentseqedit;
	char destseqedit;
	char seqeditpositon;

	char midienables;		/* bit 0 = internal=0 / external=1
							   bit 1 = midi=0     / sync24=1
							   bit 2 = midicontrollers */

	char midiinst[4];

	char timerenables;		/* bit2=A bit1=B bit0=D */
	char channelmutes;		/* bit4=5 bit3=4 bit2=3 bit1=2 bit0=1 */

	char nextsongpos;
	char livemode;

	char midichan[4];

	char trackpattpos[4];

	char songspeedcount;
	char stedmasound;		/* 0, 1, 2, native channels */

	char midiinst5;
	char midichan5;

	char nextpattern[4];

	char stedmavolume;

	char _pad[7];

	char songdata[256*4];
	char songlength;
	char songrepeat;

	struct pattern_entry patterndata[1];
};

static void error(const char *format, ...) {
	va_list ap;
	va_start(ap, format);
	vfprintf(stderr, format, ap);
	va_end(ap);
#ifdef __M68K__
	printf("Press any key\n");
	Crawcin();
#endif
	exit(1);
}

static void usage() {
	error(
"usage: myscat [FILE1 [FILE2 [OUTFILE]]]\n\n"
"default values: FILE1=1.mys, FILE2=2.mys, OUTFILE=out.mys\n"
	);
}

static void *bload(const char *filename, size_t *size) {
	char *p;
	FILE *fd;
	size_t s;
	fd = fopen(filename, "rb");
	if (!fd || fseek(fd, 0, SEEK_END))
		error("File `%s' could not be opened\n", filename);
	s=ftell(fd);
	fseek(fd, 0, SEEK_SET);
	p = malloc(s);
	if (!p)
		error("Memory allocation error\n");
	fread(p, 1, s, fd);
	fclose(fd);
	if (size)
		*size = s;
	return p;
}

static void bsave(const char *filename, const void *ptr, size_t size) {
	FILE *fd;
	fd = fopen(filename, "wb");
	if (!fd)
		error("File `%s' could not be opened\n", filename);
	if (fwrite(ptr, 1, size, fd) < size)
		error("Write error on file `%s'\n", filename);
	fclose(fd);
}

static int count_patterns(const struct mys_file *file, size_t size) {
	int num_entries = (size-HEAD_SIZE) / sizeof(struct pattern_entry);
	int i = 0;
	int num_patterns = 0;
	while (num_entries > 0) {
		int n = 64;
		++num_patterns;
		while (n > 0) {
			n -= file->patterndata[i++].rle + 1;
			--num_entries;
		}
		if (n < 0)
			error("error: pattern doesn't have 64 entries!\n");
	}
	if (num_entries < 0)
		error("error: patterns structure does not fit in file size!\n");
	return num_patterns;
}

int main(int argc, char **argv) {
	const char *filename1 = "1.mys";
	const char *filename2 = "2.mys";
	const char *filename3 = "out.mys";
	int fn1_set = 0;
	int fn2_set = 0;
	int fn3_set = 0;
	struct mys_file *file1, *file2;
	size_t size1, size2, size3;
	int num_pat1;
	int i;
	int length;

	i = 1;
	while (i < argc) {
		if (argv[i][0] == '-')
			usage();
		if (!fn1_set)
			fn1_set = 1, filename1 = argv[i];
		else if (!fn2_set)
			fn2_set = 1, filename2 = argv[i];
		else if (!fn3_set)
			fn3_set = 1, filename3 = argv[i];
		else
			usage();
		++i;
	}
	file1 = bload(filename1, &size1);
	file2 = bload(filename2, &size2);
	num_pat1 = count_patterns(file1, size1);
	size3 = size1 + size2 - HEAD_SIZE;
	file1 = realloc(file1, size3);
	if (!file1)
		error("Memory allocation error\n");
	/* copy pattern entries from file 2 to file 1 */
	memcpy(((char*)file1) + size1, file2->patterndata, size2 - HEAD_SIZE);
	/* copy song data entries */
	memcpy(file1->songdata + file1->songlength*4,
		file2->songdata, file2->songlength*4);
	/* renumber pattern numbers in song data entries from file 2 */
	length = file1->songlength + file2->songlength;
	for (i = file1->songlength; i < length; ++i) {
		unsigned char *entry = (unsigned char *)file1->songdata + i*4;
		int j;
		for (j=0; j<4; ++j) {
			if (entry[j] < 253) {
				entry[j] += num_pat1;
			}
		}
	}
	file1->songlength = length;
	/* save the new file */
	bsave(filename3, file1, size3);

	free(file2);
	free(file1);
	return 0;
}
