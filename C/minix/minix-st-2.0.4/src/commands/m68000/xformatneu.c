/* format.c: format a floppy disk */

/* Author:  Gary Mills <mills@ccu.umanitoba.ca> */
/* adapted for HAVENEWFLOP by Howard Johnson */
/* adapted for 10/11/12/13/14 sector formats by Volker Seebode */

#include <stdio.h>
#include <minix/config.h>
#include <minix/const.h>

#include <sgtty.h>
#include <errno.h>

#define TRACK_SIZE	7168
#define	HD_TRACK_SIZE	(2*TRACK_SIZE)
#define NR_SECTORS	9
#define NR_CYLINDERS	80
#define TRACK_CAP	(512*nr_sectors)
#define TRK_NDX		3


struct desc {
	int rep;	/* repetition count */
	int val;	/* byte value */
};
typedef struct desc DESC;

DESC normleader[] = {
	160,	0x4e,	/* pre-index gap */
	12,	0,	/* sync before index */
	3,	0xf6,	/* C2 */
	1,	0xfc,	/* index mark */
	80,	0xff,	/* gap 1 */
	0,	0
};

DESC leader10[] = {
	80,	0x4e,	/* pre-index gap, frueher 0x4e */
	0,	0
};

DESC leader11[] = {
	3,	0x4e,
	0,	0
};

DESC leader13[] = {
	30,	0x4e,
	0,	0
};

DESC leader14[] = {
	8,	0x4e,
	0,	0
};

DESC leader21[] = {
	10,	0x4e,
	0,	0
};

DESC normbrack[] = {
	12,	0,	/* sync before id */
	3,	0xf5,	/* A1 */
	1,	0xfe,	/* id address mark */
	1,	0,	/* track */
	1,	0,	/* side */
	1,	0,	/* sector */
	1,	2,	/* sector length (512) */
	1,	0xf7,	/* crc */
	22,	0x4e,	/* gap 2 */
	12,	0,	/* sync before data */
	3,	0xf5,	/* A1 */
	1,	0xfb,	/* data address mark */
	512,	0,	/* data */
	1,	0xf7,	/* crc */
	64,	0x4e,	/* gap 3 */
	0,	0
};

DESC brack10[] = {
	12,	0,	/* pre-address mark */
	3,	0xf5,	/* 3 synchbytes, werden zu A1 */
	1,	0xfe,	/* Adressmarke */
	1,	0,	/* Tracknummer */
	1,	0,	/* Seite */
	1,	0,	/* Sektornummer */
	1,	2,	/* Sektorgroesse */
	1,	0xf7,	/* Checksumme schreiben lassen */
	22,	0x4e,	/* Post Adress Mark 1 */
	12,	0,	/* Post Adress Mark 2 */
	3,	0xf5,	/* 3 Synchbytes (werden zu A1) */
	1,	0xfb,	/* Datenblockmarke */
	512,	0,	/* Daten */
	1,	0xf7,	/* Checksumme schreiben lassen */
	38,	0,	/* Post Data Mark */
	0,	0
};

DESC brack11[] = {
	3,	0,	/* pre-address mark */
	3,	0xf5,	/* 3 synchbytes, werden zu A1 */
	1,	0xfe,	/* Adressmarke */
	1,	0,	/* Tracknummer */
	1,	0,	/* Seite */
	1,	0,	/* Sektornummer */
	1,	2,	/* Sektorgroesse */
	1,	0xf7,	/* Checksumme schreiben lassen */
	22,	0x4e,	/* Post Adress Mark 1 */
	12,	0,	/* Post Adress Mark 2 */
	3,	0xf5,	/* 3 Synchbytes (werden zu A1) */
	1,	0xfb,	/* Datenblockmarke */
	512,	0,	/* Daten */
	1,	0xf7,	/* Checksumme schreiben lassen */
	2,	0,	/* Post Data Mark */
	0,	0
};

DESC brack13[] = {
	11,	0,	/* pre-address mark */
	3,	0xf5,	/* 3 synchbytes, werden zu A1 */
	1,	0xfe,	/* Adressmarke */
	1,	0,	/* Tracknummer */
	1,	0,	/* Seite */
	1,	0,	/* Sektornummer */
	1,	2,	/* Sektorgroesse */
	1,	0xf7,	/* Checksumme schreiben lassen */
	22,	0x4e,	/* Post Adress Mark 1 */
	12,	0,	/* Post Adress Mark 2 */
	3,	0xf5,	/* 3 Synchbytes (werden zu A1) */
	1,	0xfb,	/* Datenblockmarke */
	512,	0,	/* Daten */
	1,	0xf7,	/* Checksumme schreiben lassen */
	39,	0,	/* Post Data Mark */
	0,	0
};


DESC brack14[] = {
	2,	0,	/* pre-address mark */
	3,	0xf5,	/* 3 synchbytes, werden zu A1 */
	1,	0xfe,	/* Adressmarke */
	1,	0,	/* Tracknummer */
	1,	0,	/* Seite */
	1,	0,	/* Sektornummer */
	1,	2,	/* Sektorgroesse */
	1,	0xf7,	/* Checksumme schreiben lassen */
	22,	0x4e,	/* Post Adress Mark 1 */
	12,	0,	/* Post Adress Mark 2 */
	3,	0xf5,	/* 3 Synchbytes (werden zu A1) */
	1,	0xfb,	/* Datenblockmarke */
	512,	0,	/* Daten */
	1,	0xf7,	/* Checksumme schreiben lassen */
	5,	0,	/* Post Data Mark */
	0,	0
};

DESC brack21[] = {
	8,	0,	/* pre-address mark */
	3,	0xf5,	/* 3 synchbytes, werden zu A1 */
	1,	0xfe,	/* Adressmarke */
	1,	0,	/* Tracknummer */
	1,	0,	/* Seite */
	1,	0,	/* Sektornummer */
	1,	2,	/* Sektorgroesse */
	1,	0xf7,	/* Checksumme schreiben lassen */
	22,	0x4e,	/* Post Adress Mark 1 */
	12,	0,	/* Post Adress Mark 2 */
	3,	0xf5,	/* 3 Synchbytes (werden zu A1) */
	1,	0xfb,	/* Datenblockmarke */
	512,	0,	/* Daten */
	1,	0xf7,	/* Checksumme schreiben lassen */
	24,	0,	/* Post Data Mark */
	0,	0
};

DESC trail[] = {
	HD_TRACK_SIZE,	0x4e,	/* gap */
	0,	0
};

DESC *leader,*brack;

int interleaves[9][21] = {
  { 1,6,2,7,3,8,4,9,5 },				/* 9 Sektoren */
  { 1,6,2,7,3,8,4,9,5,10 },				/* 10 Sektoren */
  { 1,5,9,2,6,10,3,7,11,4,8 },				/* 11 Sektoren */
  { 1,6,11,4,9,2,7,12,5,10,3,8 },			/* 12 Sektoren */
  { 1,8,2,9,3,10,4,11,5,12,6,13,7 },			/* 13 Sektoren */
  { 1,4,7,10,13,2,5,8,11,14,3,6,9,12 },			/* 14 Sektoren */
  { 1,10,2,11,3,12,4,13,5,14,6,15,7,16,8,17,9,18 },	/* 18 Sektoren */
  { 1,11,2,12,3,13,4,14,5,15,6,16,7,17,8,18,9,19,10,20 },/* 20 Sektoren */
  { 1,12,2,13,3,14,4,15,5,16,6,17,7,18,8,19,9,20,10,21,11 }/* 21 Sektoren */
};

int verbose = 1;

int nr_heads, nr_sectors, track_size;
int o_trk, b_len;
char *mark;
short disk;
char image[HD_TRACK_SIZE];
char b_dev[128], f_dev[128], c_dev[128];

struct fparam oldparams, newparams;

char *strrchr();
char *fill();

/*
 * Block 0 of a TOS media	-- from tos.c
 *	(media : floppy diskette or hard disk partion)
 * Contains media description and boot code
 */
struct block0 {
	char	b0_res0[8];
	char	b0_serial[3];
	char	b0_bps[2];
	char	b0_spc;
	char	b0_res[2];
	char	b0_nfats;
	char	b0_ndirs[2];
	char	b0_nsects[2];
	char	b0_media;
	char	b0_spf[2];
	char	b0_spt[2];
	char	b0_nsides[2];
	char	b0_nhid[2];
	char	b0_code[0x1e2];
};
struct	block0	block0 = {
	0,0,'T','O','S',' ',' ',' ',
	'M','I','X', 0,2,  2,  1,0,	/* serial,bps,spc,res */
	2,  0x70,0,  0xa0,5, 0xf9, 5,0, /* nfats,ndirs,nsects,media,spf */
	NR_SECTORS,0, 2,0, 0,0	/* spt, nsides,nhid */
};

/* convert an 88-format short into a 68-format short */
#define	sh88tosh68(ch)	((short)(((ch)[1]<<8)|(ch)[0]))

void usage()
{
     fprintf(stderr, "Usage: format [-s] [-v] [-i interleave] [-c cyl_skew] [-h head_skew] drive\n");
     exit(1);
}

void printparms(fparms)
struct fparam *fparms;
{
	fprintf(stderr, "sector_size = %d\n", fparms->sector_size);
	fprintf(stderr, "sector_0 = %d\n", fparms->sector_0);
	fprintf(stderr, "cylinder_0 = %d\n", fparms->cylinder_0);
	fprintf(stderr, "nr_cylinders = %d\n", fparms->nr_cylinders);
	fprintf(stderr, "nr_sides = %d\n", fparms->nr_sides);
	fprintf(stderr, "density = %d\n", fparms->density);
	fprintf(stderr, "stepping = %d\n", fparms->stepping);
	fprintf(stderr, "autocf = %d\n", fparms->autocf);
}

main(argc, argv) int argc; char *argv[]; {
	char *drive;
	char *pt;
	int n,i;
	int head, cyl;
	struct sgttyb sg; int retcode;
	int interleave, cyl_skew, head_skew, verify;
	
	interleave = 1;
	cyl_skew = 2;
	head_skew = 0;
	verify = 1;

	if ( argc < 2 ) {
		fprintf(stderr, "Usage: format [-v] drive\n");
		exit(1);
	}
	argc--;
	argv++;
	while ((argc > 1) && (argv[0][0] == '-'))
	{
	    switch (argv[0][1]) {
	        case 'i':
	        	  if (argv[0][2] == '\0')
	        	  {
	        	      argv++;
			      argc--;
	        	      interleave = atoi(argv[0]);
	        	  }
	        	  else
	        	  {
	        	      interleave = atoi(&argv[0][2]);
	        	  }
	          	  break;
	        case 'c':
	        	  if (argv[0][2] == '\0')
	        	  {
	        	      argv++;
			      argc--;
	        	      cyl_skew = atoi(argv[0]);
	        	  }
	        	  else
	        	  {
	        	      cyl_skew = atoi(&argv[0][2]);
	        	  }
	        	  cyl_skew = NR_SECTORS - (cyl_skew % NR_SECTORS);
	          	  break;
	        case 'h':
	        	  if (argv[0][2] == '\0')
	        	  {
	        	      argv++;
			      argc--;
	        	      head_skew = atoi(argv[0]);
	        	  }
	        	  else
	        	  {
	        	      head_skew = atoi(&argv[0][2]);
	        	  }
	        	  head_skew = NR_SECTORS - (head_skew % NR_SECTORS);
	          	  break;
	        case 's':
			  verbose = 0;
	          	  break;
	        case 'n':
			  verify = 0;
	          	  break;
		default:
			  usage();
	    }
	    argv++;
	    argc--;
	}
	if (argc != 1 ) {
	    usage();
	}

	drive = argv[0];
	if ( *drive >= '0' && *drive <= '9' )
		sprintf(b_dev, "/dev/fd%c", *drive);
	else if ( *drive == '/' )
		strcpy(b_dev, drive);
	else
		sprintf(b_dev, "/dev/%s", drive);
	strcpy(f_dev, b_dev);
	strcpy(c_dev, b_dev);
	if ( !( pt = strrchr(b_dev, '/') ) ) {
		fprintf(stderr, "Invalid drive %s\n", drive);
		usage();
	}
	++pt;
	sprintf(f_dev + (pt - b_dev), "fmt%s", pt);
	sprintf(c_dev + (pt - b_dev), "r%s", pt);
	if ( *pt == 'f' )
		nr_heads = 1;
	else if ( *pt == 'd' )
		nr_heads = 2;
	else {
		fprintf(stderr, "Invalid drive %s\n", drive);
		usage();
	}

	if (pt = strrchr(pt,'s')) {
		nr_sectors = atoi(&pt[1]);
		if (nr_sectors < 9 ||
		   (nr_sectors > 14 && nr_sectors < 18) ||
		    nr_sectors > 21) {
			fprintf(stderr,"Invalid drive %s\n",drive);
			usage();
		}

		switch (nr_sectors) {
			case 10:
			case 20:
				leader = &leader10[0];
				brack = &brack10[0];
				break;
			case 13:
				leader = &leader13[0];
				brack = &brack13[0];
				break;
			case 11:

				leader = &leader11[0];
				brack = &brack11[0];
				break;
			case 14:
				leader = &leader14[0];
				brack = &brack14[0];
				break;
			case 21:
				leader = &leader21[0];
				brack = &brack21[0];
				break;
			case 18:
			default:
				leader = &normleader[0];
				brack = &normbrack[0];
				break;
		} /* switch */
	} else {
		nr_sectors = 9;
		leader = &normleader[0];
		brack = &normbrack[0];
	}
	track_size = (nr_sectors > 11) ? HD_TRACK_SIZE : TRACK_SIZE;

	b_len = 0;
	for ( n = 0; brack[n].rep; ++n ) {
		if ( n == TRK_NDX )
			o_trk = b_len;
		b_len += brack[n].rep;
	}

	pt = fill(image, &leader[0]);
	mark = pt + o_trk;
	for ( n = 0; n < nr_sectors; ++n )
		pt = fill(pt, &brack[0]);
	fill(pt, &trail[0]);

	if ( ( disk = open(f_dev, 1) ) < 0 ) {
		fprintf(stderr, "Cannot open %s, error %d/%d\n", f_dev, retcode, errno);
		exit(1);
	}
	if ( (retcode=ioctl(disk, DIOGETP, &oldparams)) < 0 ) {
		fprintf(stderr, "Cannot get old parameters of %s, error %d/%d\n",
			f_dev, retcode, errno);
		ioctl(disk, DIOFMTFREE, &sg);
		close(disk);
		exit(1);
	}
	fprintf(stderr, "Alte Parameter:\n");
	printparms(&oldparams);
#if 0
	newparams.sector_size = 512;
	newparams.sector_0 = 1;
	newparams.nr_sectors = nr_sectors;
	newparams.cylinder_0 = 0;
	newparams.nr_cylinders = 80;
	newparams.nr_sides = nr_heads == 2 ? SIDES2 : SIDES1;
	newparams.density = (nr_sectors > 11) ? DD : HD;
	newparams.stepping = 0;
	newparams.autocf = HARD;
	if ( (retcode=ioctl(disk, DIOSETP, &newparams)) < 0 ) {
		fprintf(stderr, "Cannot set new parameters of %s, error %d/%d\n",
			f_dev, retcode, errno);
		ioctl(disk, DIOFMTFREE, &sg);
		close(disk);
		exit(1);
	}
	fprintf(stderr, "Neue Parameter:\n");
	printparms(&newparams);
#endif
	if ( (retcode=ioctl(disk, DIOFMTLOCK, &sg)) < 0 ) {
		fprintf(stderr, "Cannot lock %s, error%d/%d\n", f_dev, retcode, errno);
		close(disk);
		exit(1);
	}

	if ( verbose ) 
		fprintf(stderr, "Formatting\n");

	if (nr_sectors > 18)
		i = nr_sectors-9-4;
	else if (nr_sectors == 18)
		i = nr_sectors-9-3;
	else
		i = nr_sectors-9;
	for ( cyl = 0; cyl < NR_CYLINDERS; ++cyl ) {
		if ( verbose )
			fprintf(stderr, "Cyl: %d\r", cyl);
		for ( head = 0; head < nr_heads; ++head ) {
			pt = mark;
			for ( n = 0; n < nr_sectors; ++n ) {
				pt[0] = cyl;
				pt[1] = head;
				pt[2] = interleaves[i][n];
/*				fprintf(stderr,"interleaves[%d][%d]= %d\n",
							nr_sectors-9,n,interleaves[nr_sectors-9][n]);
 */				pt += b_len;
			}
			if ( write(disk, image, track_size) != track_size ) {
				extern int errno;
				perror("I/O Error");
				fprintf(stderr,"errno=%d on cyl=%d\n",errno,cyl);
				exit(1);
			}
		}
	}
	if ( ioctl(disk, DIOFMTFREE, &sg) < 0 )
		fprintf(stderr, "Cannot unlock %s\n", f_dev);
	close(disk);

	if ( ( disk = open(c_dev, 2) ) < 0 ) {
		fprintf(stderr, "Cannot open %s\n", c_dev);
		exit(1);
	}
  /* Fix the boot block up.... */

 i = nr_sectors * NR_CYLINDERS * nr_heads;
 block0.b0_nsects[0] = i ;
 block0.b0_nsects[1] = i >> 8;
 block0.b0_nsides[0] = nr_heads ;
 block0.b0_nsides[1] = nr_heads >> 8;
/*
  bzero(block0.b0_code, sizeof(block0.b0_code) + sizeof(buf));
 */
	for(i=0;i<sizeof(block0.b0_code);i++)
		block0.b0_code[i] = 0;


	if ( write(disk, &block0, sizeof(block0)) != sizeof(block0) ) {
		fprintf(stderr, "Error writing sector 0 \n");
		exit(1);
	}
	lseek(disk,0L,0);
	if ( read(disk, image, sizeof(block0)) != sizeof(block0) ) {
		fprintf(stderr, "Error reading sector 0 \n");
		exit(1);
	}
	for(i=0;i<sizeof(block0);i++) {
		if( ((char*)&block0)[i] !=  ((char*)image)[i]) {
			fprintf(stderr, "Block 0 differs a byte %d %x != %x\n",
				i,((char*)&block0)[i],((char*)image)[i]);
			exit(1);
		}
	}
	close(disk);

	if (verify != 0) {

		if ( ( disk = open(c_dev, 0) ) < 0 ) {
		    fprintf(stderr, "Cannot open %s\n", c_dev);
		    exit(1);
		}
		if ( verbose )
		    fprintf(stderr, "Verifying \n");
		for ( cyl = 0; cyl < NR_CYLINDERS; ++cyl ) {
		    if ( verbose )
			fprintf(stderr, "Cyl: %d\r", cyl);
		    for ( head = 0; head < nr_heads; ++head ) {
			if ( read(disk, image, TRACK_CAP) != TRACK_CAP ) {
				fprintf(stderr, "Error reading cylinder %d\n", cyl);
				exit(1);
			}
		    }
		}
		close(disk);
	}

	if ( verbose )
		fprintf(stderr, "Complete   \n");

	exit(0);
}

char *
fill(pt, st) char *pt; DESC *st; {
	char *lim = &image[track_size];
	register int n;

	while ( (n = st->rep ) && pt < lim ) {
		while ( --n >= 0 && pt < lim ) 
			*pt++ = st->val;
		++st;
	}
	return pt;
}

char *
strrchr(s, c) char *s, c; {
	register char *pt = NULL;
	while ( *s ) {
		if ( c == *s )
			pt = s;
		++s;
	}
	return pt;
}

/**/

