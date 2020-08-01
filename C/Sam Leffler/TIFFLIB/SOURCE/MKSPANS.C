#pragma warn -use
static char 	*sccsid = "@(#)TIFF/mkspans.c 1.04, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Hack program to construct tables used to find runs of zeros and ones in Group 3 Fax encoding.
 */
#include <stdlib.h>
#include "tiffio.h"

/****************************************************************************
 *
 */
static void
dumparray(
       	char 	*name,
        u_char	runs[256]
        )
{
        register int 	i;
        register char 	*sep;

        printf("static u_char\t%s[256] = {\n", name);
        sep = "\t";
        for (i = 0; i < 256; i++) {
                printf("%s%d", sep, runs[i]);
                if (((i + 1) % 16) == 0) {
                        printf(",\t/* 0x%02x - 0x%02x */\n", i - 15, i);
                        sep = "\t";
                } 
                else
                        sep = ", ";
        }
        printf("\n};\n");
}

/****************************************************************************
 *
 */
void
main(
	void
	)
{
        register int 	run, runlen, i;
        u_char		runs[2][256];

        bzero(runs[0], sizeof(char) * 256);
        bzero(runs[1], sizeof(char) * 256);
        runlen = 1;
        for (run = 0x80; run != 0xff; run = (run >> 1) | 0x80) {
              	for (i = run - 1; i >= 0; i--) {
                       	runs[1][run|i] = runlen;
                       	runs[0][(~(run | i)) & 0xff] = runlen;
                }
                runlen++;
        }
        runs[1][0xff] = runs[0][0] = 8;
        dumparray("bruns", runs[0]);
        dumparray("wruns", runs[1]);
        exit(0);
}
