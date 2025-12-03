/* Directory of a dump tape 				*/
/* This program is part of the TapeBIOS distribution	*/
/* Written by Alan Hourihane 1992			*/
/* Needs TapeBIOS driver loaded				*/

#include <osbind.h>
#include <stdio.h>
#include "tapebind.h"

extern void bzero();
extern long get_cookie();
extern void exit();
extern int Request_Sense();
extern int atoi();
extern int strcmp();

#define NUMLEN	10
#define IDPOS	64

typedef struct {			/* BIOS Parameter Block Structure */
	short	  recsiz;
	short	  clsiz;
	short	  clsizb;
	short	  rdlen;
	short	  fsiz;
	short	  fatrec;
	short	  datrec;
	short	  numcl;
	short	  bflags;
} bpb;

int
main(argc,argv)
int	argc;
char	*argv[];
{
	int	spacing;
	char	buffer[512];	      /* Buffer for header block */
	char	*sname; 		/* Pointer to the name */
	char	drvnam; 		/* Original source drive name */
	int	sctsiz; 		/* sector size */
	long	 numsct;		 /* Number of sectors on drive */
	int	r;		      /* Used for results */
	int	status;

	printf("Read Dumped Drives from Tape. Copyright 1992, A. Hourihane.\r\n");

	if (argc!=1) {
		fprintf(stderr,"Usage: %s <no parameters>\r\n",argv[0]);
		exit(1);
	}

	if (!get_cookie("TAPE")) {
		printf("TapeBIOS is not installed.\r\n");
		exit(1);
	}

	status = Tload(0L);
	status = Trewind();

	for (;;) { 
		bzero(buffer,512);
		r=Tread(buffer,1L);	 /* Read the header */
		if(r == 2) {
			status = Request_Sense();
			fprintf(stderr,"Error reading header block or End of Archive.\r\n");
			status = Trewind();
			status = Tunload(0L);
			exit(0);
		}
		drvnam=buffer[0];
		sctsiz=atoi(&buffer[1]);
		numsct=atoi(&buffer[1+NUMLEN]);
		sname=&buffer[1+NUMLEN*2];
		if (strcmp("DUMPFORMAT",&buffer[IDPOS])) {
			fprintf(stderr, "Tape not in DUMP format.\r\n");
			status = Trewind();
			status = Tunload(0L);
			exit(1);
		}
		printf("Original source drive: %c, Sector size: %d bytes, Drive size = %.1fK\r\n",drvnam,sctsiz,(float)numsct*(float)sctsiz/1024);
		printf("Dump name: %s\r\n",sname);
		for (spacing=1;spacing<=(sctsiz/512);spacing++) 
			r = Tspace(numsct);
	} 
	exit(0);
}
