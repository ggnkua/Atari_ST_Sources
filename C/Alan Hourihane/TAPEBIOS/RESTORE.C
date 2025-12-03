/* Restore a partition from tape 			*/
/* This program is part of the TapeBIOS distribution	*/
/* Written by Alan Hourihane 1992			*/
/* Needs TapeBIOS driver loaded				*/

#include <osbind.h>
#include <stdio.h>
#include "tapebind.h"

extern long get_cookie();
extern int atoi();
extern int strcmp();
extern void strncpy();
extern void exit();
extern int strlen();
extern char toupper();

#define DMAMAX		(long)(64*1024)		/* 64Kbyte buffer */
#define DUMPNAME	20
#define NUMLEN		10
#define WABS		1
#define IDPOS		64

typedef struct {
	short	recsiz;
	short	clsiz;
	short	clsizb;
	short	rdlen;
	short	fsiz;
	short	fatrec;
	short	datrec;
	short	numcl;
	short	bflags;
} bpb;

int
main(argc, argv)
int argc;
char *argv[];
{
	int spacing;
	long maxspace;
	char drive;
	char sname[DUMPNAME];
	char *name;
	long numsectors;
	int sectorsize;
	char buffer[512];
	char *obuf;
	int status;
	int s,n;
	int nscts;
	int drivelist;

	printf("Restore Disk Drives from Tape. Copyright 1992, A. Hourihane.\r\n");
	
	if (argc == 1) {
		printf("Usage: %s [destination drives] [dumpname_a] [dumpname_b] [etc..]\r\n",argv[0]);
		printf("e.g.   %s fg boot apps\r\n",argv[0]);
		exit(1);
	}

	if (!get_cookie("TAPE")) {
		printf("TapeBIOS is not installed.\r\n");
		exit(1);
	}
	
	status = Tload(0L);
	status = Trewind();

	for (drivelist=0;drivelist<strlen(argv[1]);drivelist++) {
	strncpy(sname,argv[2+drivelist],DUMPNAME);
	for (;;) {
		status = Tread(buffer,1);
		if (status != 0) {
			fprintf(stderr, "Error reading header block from tape\r\n");
			status = Trewind();
			status = Tunload(0L);
			exit(4);
		}
		if (strcmp("DUMPFORMAT",&buffer[IDPOS])) {
			printf("Tape not in DUMP format");
			status = Trewind();
			status = Tunload(0L);
			exit(1);
		}
		
		drive = toupper(argv[1][drivelist])-'A';
		sectorsize = atoi(&buffer[1]);
		numsectors = atoi(&buffer[1+NUMLEN]);
		name = &buffer[1+NUMLEN*2];
		if (strcmp(name,sname)==0) break;
		for (spacing=1;spacing<=(sectorsize/512);spacing++)
			status = Tspace(numsectors);
	}

	maxspace = Malloc(-1L);
	if (maxspace < DMAMAX) {
		fprintf(stderr, "Not enough memory for buffer allocation.");
		exit(3);
	}
 	maxspace = DMAMAX;
	obuf=(char*)Malloc(maxspace);
	if (!obuf) {
		fprintf(stderr, "Cannot malloc buffer\r\n");
		exit(3);
	}
	if ((long)obuf&1) obuf++;	/* Word align it */
	nscts = maxspace/sectorsize;

	printf("Restoring: Source drive: %c, Sector size: %d bytes, Drive size = %.1fK\r\n",buffer[0],sectorsize,(float)numsectors*(float)sectorsize/1024);
	printf("	   Destination drive: %c, Dump name: %s\r\n",drive+'A',name);


	s = 0;
	do {
		n = (numsectors>nscts ? nscts : numsectors);
		status = Tread(obuf,n*(sectorsize/512));
		printf("Restoring: %dK\r", (s*sectorsize/1024));
		if (status != 0) {
			fprintf(stderr, "\nError reading from tape.\r\n\r\n");
			status = Trewind();
			status = Tunload(0L);
			exit(4);
		}
		status = Rwabs(WABS, &obuf[0], n, s, (int)drive);
		if (status < 0) {
			fprintf(stderr, "\nError %d writing to drive\r\n\r\n",status);
			status = Trewind();
			status = Tunload(0L);
			exit(4);
		}
		s+=n;
		numsectors-=n;
	} while(numsectors>0);

	}
	printf("\r\n");
	status = Trewind();
	status = Tunload(0L);
	return 0;
}
