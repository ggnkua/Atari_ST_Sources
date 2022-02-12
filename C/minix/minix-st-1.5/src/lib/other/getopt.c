/* getopt - get option letter from argv
 *
 *    Getopt(3) is used to ease the process of scanning the
 *    options on a command line. The <argc> and <argv> given
 *    to main() are passed to getopt(3), as well as a string
 *    naming all of the single character option names. If
 *    an option allows an argument, then a ':' is put after
 *    the name in <optstring>.
 *
 *    For example, the <optstring> "af:x" means that the
 *    command accepts the options "-a", "-f" and "-x". The
 *    "-f" option has an argument. When a command line is
 *    entered the options without a following argument may
 *    be grouped together, and there may be space between
 *    the "-f" and its argument in the command line. For
 *    example,
 *
 *	cmd -a -xf arg rest of line
 *
 *    After each call, main() must check the returned option
 *    name and, if appropriate, the argument referenced by
 *    <optarg>. Main() should continue to call getopt(3) until
 *    it returns EOF, at which time main() can use <optind> to
 *    determine how many items still remain on the command line.
 *
 *    The cases for getopt(3) returning EOF are: no more items
 *    in the command line, an item does not start with a "-",
 *    an item is simply "-" or an item is "--". In the latter
 *    case, <optind> is incremented past this item.
 *
 *    Normally getopt(3) will print an error message on stderr
 *    if either an unknown option is encountered or an option
 *    is missing an argument. This output may be suppressed by
 *    setting <opterr> to 0. Errors cause '?' to be returned and
 *    <optopt> to be set to the offending option letter.
 *
 * Output:
 *    o/w : Option character, <optarg> points to possible argument.
 *    EOF : Finished scanning options, <optind> is next <argv>.
 *    '?' : Encountered an illegal option, <optopt> is letter.
 *
 * Copyright (c) Henry Spencer.
 * Written by Henry Spencer.
 *
 * This software is not subject to any license of the American Telephone
 * and Telegraph Company or of the Regents of the University of California.
 *
 * Permission is granted to anyone to use this software for any purpose on
 * any computer system, and to alter it and redistribute it freely, subject
 * to the following restrictions:
 *
 * 1. The author is not responsible for the consequences of use of this
 *    software, no matter how awful, even if they arise from flaws in it.
 *
 * 2. The origin of this software must not be misrepresented, either by
 *    explicit claim or by omission.  Since few users ever read sources,
 *    credits must appear in the documentation.
 *
 * 3. Altered versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.  Since few users
 *    ever read sources, credits must appear in the documentation.
 *
 * 4. This notice may not be removed or altered.
 */

/* changed index() calls to strchr() - darwin, oct 87.
 *
 * added opterr & optopt     - Terrence W. Holm, Aug. 1988
 */

#include <lib.h>
#include <string.h>
#include <stdio.h>

char *optarg;			/* Global argument pointer. */
int optind = 0;			/* Global argv index. */
int opterr = 1;			/* Print error flag, default = on */
int optopt;

PRIVATE char *scan = (char *)NULL;	/* Private scan pointer. */

int getopt(argc, argv, optstring)
int argc;
char *argv[];
char *optstring;
{
  register char c;
  register char *place;

  optarg = (char *)NULL;

  if (scan == (char *)NULL || *scan == '\0') {
	if (optind == 0) optind++;

	if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0')
		return(EOF);
	if (strcmp(argv[optind], "--") == 0) {
		optind++;
		return(EOF);
	}
	scan = argv[optind] + 1;
	optind++;
  }
  optopt = c = *scan++;
  place = strchr(optstring, c);

  if (place == (char *)NULL || c == ':') {
	if (opterr) fprintf(stderr, "%s: unknown option -%c\n", argv[0], c);
	return('?');
  }
  place++;
  if (*place == ':') {
	if (*scan != '\0') {
		optarg = scan;
		scan = (char *)NULL;
	} else if (optind < argc) {
		optarg = argv[optind];
		optind++;
	} else {
		if (opterr)
			fprintf(stderr, "%s: -%c argument missing\n", argv[0], c);
		return('?');
	}
  }
  return(c);
}
