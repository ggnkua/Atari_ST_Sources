/*
 * superglue: like newglue, but allows for compression, etc.
 * the basic idea is to take some files, stick them together, and
 * prepend a header. The resulting big chunk of data goes in ROM,
 * and at run-time the AES extracts the pieces as necessary, possibly
 * after decompressing them.
 *
 * Here's what the glue file format looks like:
 *
 * bytes 0-1: 	WORD magic: tells whether this is compressed or not
 *		0: not compressed
 *		0xab08: compressed with the scheme described below
 * bytes 2-5: 	LONG totsize: total size of uncompressed data, including
 *		the glue header but *not* including "magic" and "totsize".
 * bytes 6-9:	LONG cursize: current size of the compressed data
 *
 * If the data is compressed, the next bytes give the decompression
 * information, as follows:
 * byte 10:	BYTE used to represent 0000
 * byte 11:	BYTE used to represent FFFF
 * byte 12:	BYTE used to mark a run of 0s 
 * byte 13:	BYTE used to mark a run of FFs
 * byte 14:	BYTE used to mark a run of arbitrary characters
 * byte 15:	BYTE used to represent 0000 0000
 * byte 16:	BYTE used to represent FFFF FFFF
 * byte 17:	BYTE used to mark tokens
 * byte 18:	BYTE number of tokens in this file
 * bytes 19-n:	the actual tokens. Each token is stored as a 1 byte length,
 *		followed by that many bytes of data.
 *		In the compressed data, a token is given by a token marker
 *		followed by an index. Index 0 represents the token marker
 *		itself, other indices point into the (1 based) array
 *		of tokens, i.e. index 1 means "put the data in the first
 *		token here.
 * As mentioned above, the token marker is escaped by using a token index
 * of 0. All the other special bytes are escaped by representing them
 * as a run of length 1, i.e. by storing <run marker> <character> <1>.
 *
 * If the data is not compressed, it starts at byte 10 of the file.
 *
 * The decompressed data has the following format:
 *
 * bytes 0-3: LONG size1: size of the GEM.RSC part of the file
 * bytes 4-7: LONG size2: size of the DESK.RSC part of the file
 * bytes 8-11: LONG size3: size of the DESKTOP.INF part of the file
 * bytes 12-n: the data bytes of GEM.RSC, followed by those of DESK.RSC,
 *		followed by those of DESKTOP.INF
 * The length of strings which will be eligible for tokenization can
 * be given on the command line with a -c argument.
 *
 * Written 5/12/93 by Eric Smith
 * Compile this with an ANSI compiler (I used gcc).
 */

#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>

/* macro to round a long to the next largest even number */
#define ROUND(x) (((x)+1) & ~1L)

#define NUMFILES 3
char *fname[NUMFILES] = { "gem%s.rsc", "desk%s.rsc", "desk%s.inf" };


#define HEADERSIZE (NUMFILES*sizeof(long))
#define DEFAULT_MATCHSIZE 8

int gl_matchsize = DEFAULT_MATCHSIZE;

/* Structure used by Fgetdta(), Fsetdta(), Fsfirst(), Fsnext() */
typedef struct mydta {
    char 	    dta_buf[21];	/* reserved */
    char            dta_attribute;	/* file attribute */
    unsigned short  dta_time;		/* file time stamp */
    unsigned short  dta_date;		/* file date stamp */
    long            dta_size;		/* file size */
    char            dta_name[14];	/* file name */
} DTA;

typedef unsigned char byte;

static char magic[2] = "\0";

extern long crunch( byte *, long, byte * );

int
main(int argc, char **argv)
{
	long size[NUMFILES];
	long totsize;
	char buf[20], name[40];
	byte *inbuf, *ptr;
	byte *outbuf;
	long outsize;
	int i, fd;
	DTA *dt;
	int compress, noheader;
	int interactive = 1;

	dt = (DTA *)Fgetdta();

	compress = 0;
	noheader = 0;

	printf("\nSuperglue v1.0\n");
	while (argc > 1) {
		ptr = (byte *)argv[1];
		argv++; --argc;
		if (*ptr == '-') {
			ptr++;
			switch (*ptr) {
			case 'c':
				compress = 1;
				i = atoi(ptr+1);
				if (i) gl_matchsize = i;
				break;
			case 'n':
				noheader = 1;
				break;
			default:
				printf("usage: superglu [-n][-c#] [extension]\n");
				break;
			}
		} else {
			interactive = 0;
			break;
		}
	}

	puts(compress ? "COMPRESSING resources" : "storing resources" );
	if (interactive) {
		printf("\nPlease enter the 3 letter country abbreviation, or\n");
		printf("type 'exit' to quit\n");
	}

	do {
		totsize = HEADERSIZE;
		if (interactive) {
			printf("> "); fflush(stdout);
			gets(buf);
			if (strlen(buf) > 3) break;
		} else {
			strcpy(buf, *argv);
		}

	/* first, find the sizes of the pieces */
		for (i = 0; i < NUMFILES; i++) {
			sprintf(name, fname[i], buf);
			if (Fsfirst(name, 0) != 0) {
				printf("%s: not found\n", name);
				goto top;
			}
			size[i] = dt->dta_size;
	/* we round all file sizes up to the next even number when we
	 * read them into memory, so everything will be on a word boundary
	 */
			totsize += ROUND(size[i]);
		}


		ptr = inbuf = (byte *)Malloc( totsize );
		if (!inbuf) {
			printf("not enough memory: couldn't allocate %ld bytes\n",
			  totsize);
			goto top;
		}

		ptr += HEADERSIZE;

	/* now, go read the files */
		for (i = 0; i < NUMFILES; i++) {
			sprintf(name, fname[i], buf);
			fd = Fopen(name, 0);
			if (fd < 0) {
				printf("couldn't open %s\n", name);
				Mfree(inbuf);
				goto top;
			}
			puts(name);
			if (Fread(fd, size[i], ptr) != size[i]) {
				printf("Error during read\n");
				Mfree(inbuf);
				Fclose(fd);
				goto top;
			}
			Fclose(fd);
			ptr += ROUND(size[i]);
			/* fill in the size in the header */
			((long *)inbuf)[i] = ROUND(size[i]);
		}

	/* OK, now write the result */
		sprintf(name, "glue.%s", buf);
		fd = Fcreate(name, 0);
		if (fd < 0) {
			printf("couldn't create %s\n", name);
			Mfree(inbuf);
			goto top;
		}

		if (compress) {
			outbuf = (byte *)Malloc( totsize * 2 );
			if (!outbuf) {
				printf("NO MEMORY FOR COMPRESSION!!\n");
				printf("storing resource instead\n");
				compress = 0;
			}
		}
		if (compress) {
			magic[0] = 0xab;
			magic[1] = 0x08;
			outsize = crunch(inbuf, totsize, outbuf);
		} else {
			outbuf = inbuf;
			outsize = totsize;
			magic[0] = magic[1] = 0;
		}
		printf("Writing %s...\n", name);

	/* first, the file header */
		if (!noheader) {
			Fwrite(fd, 2L, magic);
			Fwrite(fd, 4L, &totsize);
			Fwrite(fd, 4L, &outsize);
		}

	/* now write the data */
		if (Fwrite(fd, outsize, outbuf) != outsize) {
			printf("write error!\n");
		}

		Fclose(fd);
		Mfree(inbuf);
		if (compress) Mfree(outbuf);
top: ;
	} while (interactive);

	return 0;
}
