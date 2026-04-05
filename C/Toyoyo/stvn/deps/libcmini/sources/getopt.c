#include <getopt.h>
#include <string.h>
#include <stdio.h>

char *optarg;
int optind = 1;		/* next element to be processed */
int opterr = 1;
int optopt;

int getopt(int argc, char * const argv[], const char *optstring)
{
	static int sp = 1;
	char *cp;
	int c;
	int print_errors = opterr;

	if (*optstring == ':') {
        /* don't write error messages to stderr */
		print_errors = 0;
	}

	optarg = NULL;

	if (sp == 1) {
		if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0') {
            /* no options at all */
			return -1;
		} else if (!strcmp(argv[optind], "--")) {
            /* end of options reached */
			optind++;
			return -1;
		}
	}

	c = argv[optind][sp];
	cp = strchr(optstring, c);

	if (c == ':' || cp == NULL) {
        /* illegal option */
		if (print_errors) {
			fprintf(stderr, "%s: illegal option -- %c\r\n", argv[0], c);
		}
		sp = 1;
		optopt = c;
		return '?';
	} else if (cp[1] == ':') {
        /* argument required */
		if (argv[optind][sp + 1] == '\0') {
            /* argument in next argv element */
			if (++optind >= argc) {
				if (print_errors) {
					fprintf(stderr, "%s: option requires an argument -- %c\r\n", argv[0], c);
				}
				sp = 1;
				optopt = c;
				return (*optstring == ':') ? ':' : '?';
			}
			optarg = argv[optind++];
			sp = 1;
		} else {
            /* argument in current argv element */
			optarg = &argv[optind++][sp + 1];
			sp = 1;
		}
	} else if (argv[optind][sp + 1] == '\0') {
        /* no more options in current argv element */
        optind++;
        sp = 1;
	} else {
        /* move to next option character */
        sp++;
    }
	optopt = 0;
	return c;
}

