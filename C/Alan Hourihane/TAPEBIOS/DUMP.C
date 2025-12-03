/* Dump a partition to tape				*/
/* This program is part of the TapeBIOS distribution	*/
/* Written by Alan Hourihane 1992			*/
/* Needs TapeBIOS driver loaded				*/

/* Include the necessary header files */
#include <osbind.h>
#include <stdio.h>
#include "tapebind.h"

/* Declare externals */
extern void strncpy();
extern long get_cookie();
extern char toupper();
extern int strcmp();
extern int strlen();
extern void exit();

#define DMAMAX		64*1024 	/* 64Kbyte buffer */
#define DUMPNAME	20		/* Max. length of Dumpname */
#define NUMLEN		10		/* Max. length of number */
#define RABS		0		/* Read for RWABS */
#define IDPOS		64		/* Position of dumpname in field */

typedef struct {			/* Structure for BPB */
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
	long maxspace;		/* Malloc area */
	char drive;		/* Drive to be dumped */
	char name[DUMPNAME];	/* name of dump */
	bpb *srcbpb;		/* Structure for BPB */
	long numsectors;	/* Number of sectors on drive */
	int sectorsize;		/* Sector Size */
	char buffer[512];	/* Header buffer */
	char *obuf;		/* Buffer area for dump */
	int status;		/* Status of tape command */
	int s,n;		/* Temporary storage */
	int nscts;		/* Calculated number of sectors */
	int drivelist;		/* Drivelist for dump */

	printf("Dump Disk Drives to Tape. Copyright 1992, A. Hourihane.\r\n");
	
	if (argc < 3 || (argc < 4 && !strcmp(argv[1],"-a"))) {
		printf("Usage: %s [-a] [drivelist] [dumpname_a] [dumpname_b] [etc..]\r\n",argv[0]);
		printf("e.g.   %s cde boot apps general\r\n",argv[0]);
		exit(1);
	}

	if (!get_cookie("TAPE")) {
		printf("TapeBIOS is not installed.\r\n");
		exit(1);
	}

	status = Tload(0L);
	status = Trewind();
	if (status == 2) {
		fprintf(stderr, "Failed to initialise tape drive.");
		status = Trewind();
		status = Tunload(0L);
		exit(4);
	}	

	if (!strcmp(argv[1],"-a")) {
		argv++;
		argc--;
		status = Tspace(50331648L);
		if (status == 2) {
			fprintf(stderr, "Error spacing to End-of-Recorded Media.");
			status = Trewind();
			status = Tunload(0L);
			exit(4);
		}
	}

	for (drivelist=0;drivelist<strlen(argv[1]);drivelist++) {
	
	drive = toupper(argv[1][drivelist])-'A';

	if (drive<0 || drive>16) {
		fprintf(stderr, "Invalid drive %s\r\n", argv[1]);
		exit(1);
	}

	if (strlen(argv[2+drivelist])>DUMPNAME) {
		fprintf(stderr, "Maximum dump name length is %d characters\r\n",DUMPNAME);
		exit(1);
	}

	strncpy(name, argv[2+drivelist], DUMPNAME);

	srcbpb = (bpb*)Getbpb(drive);

	if (srcbpb==NULL) {
		fprintf(stderr, "Drive %s does not exist\r\n", argv[1]);
		exit(2);
	}

	numsectors = srcbpb->datrec+srcbpb->clsiz*srcbpb->numcl;
	sectorsize = srcbpb->recsiz;
	printf("Dumping drive %c to tape. Size = %.1fK\r\n",drive+'A',(float)numsectors*(float)sectorsize/1024);

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

	buffer[0]=(char)(drive+'A');
	sprintf(&buffer[1],"%d",sectorsize);
	sprintf(&buffer[1+NUMLEN],"%d",numsectors);
	strncpy(&buffer[1+NUMLEN*2],name,DUMPNAME);
	sprintf(&buffer[IDPOS],"DUMPFORMAT");

	status = Twrite(buffer,1);
	if (status != 0) {
		fprintf(stderr, "Error writing header block to tape\r\n");
		exit(4);
	}

	s = 0;
	do {
		n = (numsectors>nscts ? nscts : numsectors);
		status = Rwabs(RABS, &obuf[0], n, s, (int)drive);
		if (status < 0) {
			fprintf(stderr, "\nError %d reading from drive\r\n",status);
			exit(4);
		}
		status = Twrite(obuf,(long)((n*sectorsize)/512));
		printf("Dumped: %dK\r", (s*sectorsize/1024));
		if (status != 0) {
			fprintf(stderr, "\nError writing to tape.\r\n");
			exit(4);
		}
		s+=n;
		numsectors-=n;
	} while(numsectors>0);
	status = Mfree(obuf); 
	}
	printf("\r\n"); 
	status = Trewind();
	status = Tunload(0L);
	return 0;		/* Keep -Wall happy */
}
