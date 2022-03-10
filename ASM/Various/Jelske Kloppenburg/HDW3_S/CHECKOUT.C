static char *rcsid = "$Id: checkout.c,v 1.2 1991/09/17 15:12:12 mario Exp $";

/* $Log: checkout.c,v $
 * Revision 1.2  1991/09/17  15:12:12  mario
 * Let the header be done by the assembler.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#define	IMAGE		"hdw3.tos"

#define	SIZE		8096L
#define	SECSIZE		512

void main(void)
{
	char *text_p;
	int i, copy_image=1;
	BASPAG *baspag;
	unsigned char *buffer;
#if !defined(WR)
	void (*funct)(void);
#endif
#if defined(R_CHECK)
	int fd;
	size_t rbytes;
	char *ram;
#endif
	
	buffer = malloc(SECSIZE);
#if defined(R_CHECK)
	/* For tests if relocation errors occurr */
	ram = malloc(SIZE);
	
	if ((fd = open(IMAGE, O_RDONLY)) < 0) {
		fputs("Open error", stderr);
		exit(1);
	}
	
	rbytes = read(fd, ram, SIZE);

	fprintf(stdout, "Read %ld Bytes\n", rbytes);
#endif
	/* Tends to fail, if the image has to be relocated
	   Debug/trace this on "ram" (with R_CHECK defined) */
	baspag = (BASPAG *)Pexec(3, IMAGE, NULL, NULL);
	if ((long)baspag < 0) {
		if ((long)baspag == -33) {	/* Not found */
			copy_image = 0;
		} else {
			fprintf(stderr, "Pexec failed\n");
		}
	}
#if !defined(WR)
	funct = baspag->p_tbase;
#endif
	Rwabs(2, buffer, 1, 0, 0);

	if (copy_image) {
		text_p = baspag->p_tbase;
		if (baspag->p_dlen) {
			fprintf(stderr, "Warning! Data segment should not contain data\n");
		}
		if (baspag->p_tlen+2 > SECSIZE) {
			fprintf(stderr, "Program too big for bootsector\n");
			exit(1);
		}
		for (i=0; i<8; i++) buffer[i] = text_p[i];
		for (i=0x1e; i<(baspag->p_tlen); i++) buffer[i] = text_p[i];
	} else {
		fprintf(stderr, "No bootsector image %s!\n", IMAGE);
		fprintf(stderr, "Adjusting checksum to executable\n");
	}
	Protobt(buffer, -1, -1, 1);
#if defined(WR)
	Rwabs(3, buffer, 1, 0, 0);
#else
	/* expect bootsector to be executed in supervisor mode */
	Super(0L);
	(*funct)();	/* Check it out with debugger */
	/* Registers might be lost, just exit now! */
#endif
	exit(0);
}

#pragma warn -use
