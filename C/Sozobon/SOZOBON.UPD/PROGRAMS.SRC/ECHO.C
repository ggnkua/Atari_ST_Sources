#include <stdio.h>
#include <errno.h>

int	n_flag = FALSE;		/* suppress '\n' after output */
int	c_flag = FALSE;		/* process words with ctlcnv() */

usage()
	{
	fprintf(stderr, "usage: echo [-nc] [-ofile|-afile] [--] [word...]\n");
	exit(1);
	}

main(argc, argv)
	int argc;
	char *argv[];
	{
	extern int optind;
	extern char *optarg;
	register int c;
	register char *p;

	while((c = getopt(argc, argv, "nco:a:E")) != EOF)
		{
		switch(c)
			{
			case 'n':
				n_flag = TRUE;
				break;
			case 'c':
				c_flag = TRUE;
				break;
			case 'o':
				if(freopen(optarg, "w", stdout) == NULL)
					{
					perrorf(
					"can write to file '%s', errno=%d",
						optarg, errno);
					exit(EXIT_FAILURE);
					}
				break;
			case 'a':
				if(freopen(optarg, "a", stdout) == NULL)
					{
					perrorf(
					"can append to file '%s', errno=%d",
						optarg, errno);
					exit(EXIT_FAILURE);
					}
				break;
			case 'E':
				for(c = 0; is_syserr(c); --c)
					printf("error %-3d '%s'\n",
						c, strerror(c));
				exit(EXIT_SUCCESS);
			case '?':
				usage();
			}
		}
	for(; optind < argc; ++optind)
		{
		p = argv[optind];
		if(c_flag)
			ctlcnv(p);
		fputs(p, stdout);
		fputc(' ', stdout);
		}
	if(!n_flag)
		fputc('\n', stdout);
	}
