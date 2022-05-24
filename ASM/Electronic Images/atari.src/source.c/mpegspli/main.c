
/*
 * Copyright (c) 1994 Michael Simmons.
 * All rights reserved.
 * 
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
 * 
 * IN NO EVENT SHALL MICHAEL SIMMONS BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF MICHAEL SIMMONS
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE MICHAEL SIMMONS SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND MICHAEL SIMMONS HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * I can be contacted via 
 * Email: michael@ecel.uwa.edu.au
 * Post: P.O. Box 506, NEDLANDS WA 6009, AUSTRALIA
 */

#include "main.h"

void usage()
{
	printf("Usage splitmpeg [-vq] filename\n");
}

main(int argc, char *argv[])
{
	int i;
	int arg_err;
	int filename_found;

	quiet_flag = FALSE;
	verbose_flag = FALSE;
	arg_err = FALSE;
	filename_found = FALSE;

	for( i=1;(i < argc && !arg_err); i++)
		if(argv[i][0] == '-' ){
			switch (argv[i][1]) {
				case 'q': 	quiet_flag = TRUE  ;break;
				case 'v':	verbose_flag = TRUE;break;
				default: 	arg_err = TRUE;
			}
		}else{
			if( i != (argc-1) )		/* possiable filename - check its last */
				arg_err = TRUE;
			else
				filename_found = TRUE;
		}

	if( arg_err || !filename_found){
		usage();
		exit(1);
	}

	split_stream(argv[argc-1]); 
}
