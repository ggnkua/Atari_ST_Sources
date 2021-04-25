/*
 * SSED		substitution stream editor (a very small subset of SED)
 */

#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <ctype.h>
#include <errno.h>

char		lnbuf[512];		/* line buffer */
char		**old = NULL;		/* old string list (search for) */
char		**new = NULL;		/* new string list (replace with) */
int		s_flag = FALSE;		/* modify files "in place" */

typedef	char	**LIST;

int lstlen(list)
	register LIST list;
	{
	register int len = 0;

	if(list == NULL)
		return(0);
	while(*list++)
		++len;
	return(len);
	}

LIST lstcat(list, item)
	register LIST list;
	register char *item;
	{
	register int len;

	len = lstlen(list);
	list = (LIST) realloc(list, (len + 2) * sizeof(char *));
	if(list == NULL)
		return(NULL);
	list[len] = item;
	list[len+1] = NULL;
	return(list);
	}

version()
	{
	printf("ssed v1.2 -- 10/19/88 by Dale Schumacher\n");
	exit(1);
	}

usage()
	{
	fprintf(stderr,
"usage: ssed [-s] [-e command] [-f commandfile] [infile...] >outfile\n");
	fprintf(stderr,
"	-s	files are modified in place (standalone).\n");
	fprintf(stderr,
"	-e	s/oldtext/newtext/ command on the command line.\n");
	fprintf(stderr,
"	-f	s/oldtext/newtext/ commands read from a file.\n");
	exit(EXIT_FAILURE);
	}

main(argc, argv)
	int argc;
	char *argv[];
	{
	FILE *fp, *ftmp;		/* working and temporary files */
	char *fname;			/* working file name */
	char tname[128];		/* temporary file name */
	int c;
	extern int optind;
	extern char *optarg;

	while((c = getopt(argc, argv, "se:f:V")) != EOF)
		{
		switch(c)
			{
			case 's':
				s_flag = TRUE;
				break;
			case 'e':
				parse(optarg);
				break;
			case 'f':
				if((fp = fopen(optarg, "r")) == NULL)
					{
					perrorf("can't open command file '%s'",
						optarg);
					exit(EXIT_FAILURE);
					}
				errno = 0;
				while(fgets(lnbuf, sizeof(lnbuf), fp))
					parse(lnbuf);
				fclose(fp);
				if(errno)
					perror(optarg);
				break;
			case 'V':
				version();
			case '?':
				usage();
			}
		}
	if(old == NULL)			/* no commands specified */
		usage;
	if(optind >= argc)		/* no files specified */
		{
		if(isatty(stdin) || s_flag)
			usage();
		else
			ssed(stdin, stdout);
		}
	else
		{
		for(; optind < argc; ++optind)
			{
			fname = argv[optind];
			if(!strcmp(fname, "-"))
				fp = stdin;
			else if((fp = fopen(fname, "r")) == NULL)
				{
				perrorf("can't open file '%s'", fname);
				exit(EXIT_FAILURE);
				}
			if(s_flag)
				{
				tmpnam(tname);
				if((ftmp = fopen(tname, "w")) == NULL)
					{
					perrorf("can't open temp file '%s'",
						tname);
					exit(EXIT_FAILURE);
					}
				}
			else
				ftmp = stdout;
			errno = 0;
			ssed(fp, ftmp);
			fclose(fp);
			if(s_flag)
				{
				fclose(ftmp);
				unlink(fname);
				if(rename(tname, fname) != 0)
					{
					perrorf("can't rename '%s' to '%s'.\n",
						tname, fname);
					exit(EXIT_FAILURE);
					}
				}
			if(errno)
				perror(NULL);
			}
		}
	exit(EXIT_SUCCESS);
	}

parse(cmd)
	register char *cmd;
	{
	register char *p, *q;
	register char delim;
	char buf[512];

	if(!(cmd && *cmd))
		return;
	cmd = strcpy(buf, cmd);
	if(tolower(*cmd) != 's')
		{
		fprintf(stderr,
		"ssed: only 's/oldtext/newtext/' commands are implemented.\n");
		exit(EXIT_FAILURE);
		}
	if(((delim = cmd[1]) == '\0')
	|| ((q = strchr((cmd + 2), delim)) == NULL)
	|| ((p = strchr((q + 1), delim)) == NULL))
		{
		fprintf(stderr, "ssed: bad command syntax '%s'\n", cmd);
		exit(EXIT_FAILURE);
		}
	*p = '\0';
	*q++ = '\0';
	p = cmd + 2;
	if(((old = lstcat(old, strdup(p))) == NULL)
	|| ((new = lstcat(new, strdup(q))) == NULL))
		{
		fprintf(stderr, "ssed: out of memory.\n");
		exit(EXIT_FAILURE);
		}
	}

ssed(fin, fout)
	FILE *fin, *fout;
	{
	register char **pp, **qq;

	while(fgets(lnbuf, sizeof(lnbuf), fin))
		{
		for(pp = old, qq = new; *pp && *qq; ++pp, ++qq)
			{
			strrpl(lnbuf, *pp, *qq, -1);
			}
		fputs(lnbuf, fout);
		}
	}
