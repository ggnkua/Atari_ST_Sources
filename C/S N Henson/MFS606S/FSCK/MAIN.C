/* This File is part of 'fsck' copyright S.N. Henson */

#define EXTERN /**/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "fs.h"
#include "global.h"
#include "proto.h"

void main(argc,argv)
int argc;
char **argv;
{
	int rw;
	int c;
	extern void do_fsck1(),do_fsck2();

	extern int optind,opterr;
	extern char *optarg;

	rw=1;
	opterr=0;
	while( (c=getopt(argc,argv,"pyYnNd:D:sSRi:"))!=EOF )
	{
		switch(c)
		{
			case 'y':
			case 'Y':
			ally=1;
			break;
			
			case 'n':
			case 'N':
			rw=0;
			alln=1;
			break;

			case 'd':
			case 'D':
			incr=atoi(optarg);
			if( (incr<1) || (incr>8) || NPOW2(incr))
			{
				fprintf(stderr,"Invalid Increment Value\n");
				exit(1);
			}
			break;

			case 's':
			info=1;
			break;

			case 'S':
			info=2;
			break;

			case 'R':
			badroot=1;
			break;

			case 'i':
			comma_parse(optarg,&inums);
			break;
#if notyet
			case 'u':
			ul=malloc(sizeof(llist));
			if(!ul) fatal("Out of Memory");
			ul->member=(long)strdup(optarg);
			ul->next=unlist;
			unlist=ul;
			break;
#endif

			case 'p':
			preen=1;
			break;

			case '?':
			usage();
			break;		
		}
	}

	if( (argc-optind!=1) || opterr) usage();

	if(preen && (ally || alln))
	{
		fprintf(stderr,"-p option cannot be mixed with -n or -y\n");
		exit(1);
	}

	if(preen) ally=1;

	if(badroot && !incr)
	{
		fprintf(stderr,"'-R' option needs '-d'\n");
		exit(1);
	} 

	drvnam=strdup(argv[optind]);

	if( init_device(argv[optind],rw))
	{
		fprintf(stderr,"Can't Open Device %s\n",argv[optind]);
		exit(1);
	}

	read_tables();

	if(version) do_fsck2();
	else do_fsck1();

	showinfo();
	close_device();
	exit(0);
}
