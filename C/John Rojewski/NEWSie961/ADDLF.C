/*
 * addlf.c  
 *
 * add a linefeed after every carriage return
 */

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	FILE *in,*out;
	int c=6;

	in = fopen( "A:\\x.TXT", "rb");
	if (in!=NULL) {
		out = fopen( "D:\\temp\\x.OUT", "wb");
		for (;;) {
			c = fgetc( in );
			if (c!=EOF) {
				fputc( c, out );
				if (c=='\r') { fputc( '\n', out ); }
			} else { return(0); }
		}
	}
}

