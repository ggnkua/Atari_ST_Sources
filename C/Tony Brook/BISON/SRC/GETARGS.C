/* Parse command line arguments for bison,
   Copyright (C) 1984, 1986 Bob Corbett and Free Software Foundation, Inc.

BISON is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY.  No author or distributor accepts responsibility to anyone
for the consequences of using it or for whether it serves any
particular purpose or works at all, unless he says so in writing.
Refer to the BISON General Public License for full details.

Everyone is granted permission to copy, modify and redistribute BISON,
but only under the conditions described in the BISON General Public
License.  A copy of this license is supposed to have been given to you
along with BISON so you can know your rights and responsibilities.  It
should be in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.

 In other words, you are welcome to use, share and improve this program.
 You are forbidden to forbid anyone else to use, share and improve
 what you give them.   Help stamp out software-hoarding!  */

#include <stdio.h>
#include "files.h"

int verboseflag;
int definesflag;
extern int fixed_outfiles;/* JF */


getargs(argc, argv)
int argc;
char *argv[];
{
  register int c;
  register char *cp;

  extern int optind;

  verboseflag = 0;
  definesflag = 0;
  fixed_outfiles = 0;

  while ((c = getopt (argc, argv, "yYvVdD")) != EOF)
    switch (c)
      {
      case 'y':
      case 'Y':
	fixed_outfiles = 1;
	break;

      case 'v':
      case 'V':
	verboseflag = 1;
	break;

      case 'd':
      case 'D':
	definesflag = 1;
	break;
      }

  if (optind == argc)
    fatal("grammar file not specified");
  else
    infile = argv[optind];

  if (optind < argc - 1)
    fprintf(stderr, "bison: warning: extra arguments ignored\n");
}
