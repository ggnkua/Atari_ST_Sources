/* format.c: format a floppy disk */

/* Author:  Gary Mills <mills@ccu.umanitoba.ca> */
/* adapted for HAVENEWFLOP by Howard Johnson */
/* may 2, 1991: Frans Meulenbroeks: added -s -n -i -h -c options
   -s	 silent
   -n	 noverify
   -i n  interleave factor n (default 1)
   -h n  head skew n (default 0)
   -c n  cylinder skew n (default 2)
*/

#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <minix/config.h>
#include <minix/const.h>

#define TRACK_SIZE	7168
#define NR_SECTORS	9
#define NR_CYLINDERS	80
#define TRACK_CAP	(512*NR_SECTORS)
#define TRK_NDX		3


struct desc {
	int rep;	/* repetition count */
	int val;	/* byte value */
};
typedef struct desc DESC;

DESC leader[] = {
	160,	0x4e,	/* pre-index gap */
	12,	0,	/* sync before index */
	3,	0xf6,	/* C2 */
	1,	0xfc,	/* index mark */
	80,	0xff,	/* gap 1 */
	0,	0
};

DESC brack[] = {
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

DESC trail[] = {
	TRACK_SIZE,	0x4e,	/* gap */
	0,	0
};

_PROTOTYPE(void usage, (void));
_PROTOTYPE(int main, (int argc, char *argv []));
_PROTOTYPE(char *fill, (char *pt, DESC *st));

int interleave_arr[NR_SECTORS];
int verbose = 1;
int verify = 1;

int nr_heads;
int o_trk, b_len;
char *mark;
short disk;
char image[TRACK_SIZE];
char b_dev[128], f_dev[128], c_dev[128];

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

int main(argc, argv)
int argc;
char *argv[];
{
	char *drive;
	char *pt;
	int n,i;
	int head, cyl;
	int interleave, cyl_skew, head_skew;

	interleave = 1;
	cyl_skew = 2;
	head_skew = 0;

	if ( argc < 2 ) {
	    usage();
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
	for (i = 0; i < NR_SECTORS; i++) interleave_arr[i] = -1;
	i = 0;
	n = 0;
	while (n < NR_SECTORS) {
	    if (interleave_arr[i] == -1)
	    {
	        interleave_arr[i] = n;
	        n++;
	        i = (i + interleave) % NR_SECTORS;
	    }
	    else i = ( i + 1) % NR_SECTORS;
	}
	drive = argv[0];
	if ( *drive >= '0' && *drive <= '9' )
		sprintf(b_dev, "/dev/dd%c", *drive);
	else if ( *drive == '/' )
		strcpy(b_dev, drive);
	else
		sprintf(b_dev, "/dev/%s", drive);
	strcpy(f_dev, b_dev);
	strcpy(c_dev, b_dev);
	if ( !( pt = strrchr(b_dev, '/') ) ) {
		fprintf(stderr, "Invalid drive %s\n", drive);
		exit(1);
	}
	++pt;
	sprintf(f_dev + (pt - b_dev), "fmt%s", pt);
	sprintf(c_dev + (pt - b_dev), "r%s", pt);
	if ( *pt == 's' )
		nr_heads = 1;
	else if ( *pt == 'd' )
		nr_heads = 2;
	else {
		fprintf(stderr, "Invalid drive %s\n", drive);
		exit(1);
	}

	b_len = 0;
	for ( n = 0; brack[n].rep; ++n ) {
		if ( n == TRK_NDX )
			o_trk = b_len;
		b_len += brack[n].rep;
	}

	pt = fill(image, &leader[0]);
	mark = pt + o_trk;
	for ( n = 0; n < NR_SECTORS; ++n )
		pt = fill(pt, &brack[0]);
	fill(pt, &trail[0]);

	if ( ( disk = open(f_dev, 1) ) < 0 ) {
		fprintf(stderr, "Cannot open %s\n", f_dev);
		exit(1);
	}
	if ( verbose ) 
		fprintf(stderr, "Formatting\n");
	for ( cyl = 0; cyl < NR_CYLINDERS; ++cyl ) {
		if ( verbose )
			fprintf(stderr, "Cyl: %d\r", cyl);
		for ( head = 0; head < nr_heads; ++head ) {
			pt = mark;
			for ( n = 0; n < NR_SECTORS; ++n ) {
				pt[0] = cyl;
				pt[1] = head;
				pt[2] = ((interleave_arr[n] + head * head_skew +
					  cyl * cyl_skew) % NR_SECTORS) + 1;
				pt += b_len;
			}
			if ( write(disk, image, TRACK_SIZE) != TRACK_SIZE ) {
				extern int errno;
				perror("I/O Error");
				fprintf(stderr,"errno=%d on cyl=%d\n",errno,cyl);
				exit(1);
			}
		}
	}
	close(disk);

	if ( ( disk = open(c_dev, 2) ) < 0 ) {
		fprintf(stderr, "Cannot open %s\n", c_dev);
		exit(1);
	}
  /* Fix the boot block up.... */

 i = NR_SECTORS * NR_CYLINDERS * nr_heads;
 block0.b0_nsects[0] = i ;
 block0.b0_nsects[1] = i >> 8;
 block0.b0_nsides[0] = nr_heads ;
 block0.b0_nsides[1] = nr_heads >> 8;
/*
  bzero(block0.b0_code, sizeof(block0.b0_code) + sizeof(buf));
 */
	for(i=0;i<sizeof(block0.b0_code);i++)
		block0.b0_code[i] = 0;


	if ( write(disk, (char *)&block0, sizeof(block0)) != sizeof(block0) ) {
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

	if (verify)
	{
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

	return(0);
}

char *
fill(pt, st) char *pt; DESC *st; {
	char *lim = &image[TRACK_SIZE];
	register int n;

	while ( (n = st->rep ) && pt < lim ) {
		while ( --n >= 0 && pt < lim ) 
			*pt++ = st->val;
		++st;
	}
	return pt;
}
