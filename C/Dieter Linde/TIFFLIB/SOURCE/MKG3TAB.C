#pragma warn -use
static char 	*sccsid = "@(#)TIFF/mkg3tab.c 1.03, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Copyright (c) 1988, 1990 by Sam Leffler, Oct 8 1990
 * All rights reserved.
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <lin.h>
#include "tiffio.h"
#include "t4.h"

#define TABSIZE	8192

static char	*progname;

/****************************************************************************
 *
 */
static void
dumparray(
	char	*name,
       	u_char	tab[TABSIZE]
       	)
{
       	register int	i;
        register char 	*sep;

        printf("u_char\t%s[%d] = {\n", name, TABSIZE);
        sep = "\t";
        for (i = 0; i < TABSIZE; i++) {
                printf("%s%3u", sep, tab[i]);
                if (((i + 1) % 10) == 0) {
                        printf(",\t/* %4d - %4d */\n", i - 9, i);
                        sep = "\t";
                } 
                else
                        sep = ", ";
        }
        if ((i - 1) % TABSIZE)
                putchar('\n');
        printf("};\n");
}

#define SIZEOF(a)	(sizeof(a) / sizeof(a[0]))

/****************************************************************************
 *
 */
static void
addcodes(
       	u_char		tab[TABSIZE],
        int 		n,
        tableentry 	*ttab
        )
{
        int 	i;

        for (i = 0; i < n; i++) {
                tableentry	*te = &ttab[i];
                int 		code = te->code << (13 - te->length);

                if (code >= TABSIZE) {
                       	fprintf(stderr, "%s: unexpected code %d (>=%d) %s(0x%x, %d, %d)\n", progname, code, TABSIZE, 
                       		te->tabid == TWTABLE ? "twtable" : 
                       		te->tabid == TBTABLE ? "tbtable" :
				te->tabid == MWTABLE ? "mwtable" : 
				te->tabid == MBTABLE ? "mbtable" : 
				te->tabid == EXTABLE ? "extable" : 
						     "??? table", te->code, te->length, te->count);
                        exit(-1);
                }
                if (tab[code] != 0xff) {
                        printf("%s: code table collision %d %s(0x%x, %d, %d)\n", progname, code,
                                te->tabid == TWTABLE ? "twtable" :
                                te->tabid == TBTABLE ? "tbtable" :
                                te->tabid == MWTABLE ? "mwtable" :
                                te->tabid == MBTABLE ? "mbtable" :
                                te->tabid == EXTABLE ? "extable" :
                                                     "??? table", te->code, te->length, te->count);
                } 
                else
                        tab[code] = i;
        }
}

/****************************************************************************
 *
 */
static void
dumppointers(
       	tableentry	*tab,
        int 		n,
        char 		*which
        )
{
        int 	i;

        for (i = 0; i < n; i++)
                if (tab[i].tabid > 0)
                        break;
        printf("static  tableentry *g3m%stab = &TIFFFax3%scodes[%d];\n", which, which, i);
        for (; i < n; i++)
                if (tab[i].tabid < 0)
                        break;
        printf("static  tableentry *g3t%stab = &TIFFFax3%scodes[%d];\n", which, which, i);
}

/****************************************************************************
 *
 */
static void
bfill(
       	register u_char	*cp,
        register int 	n,
        register int 	v
        )
{
        while (n-- > 0)
                *cp++ = v;
}

#pragma warn -par
/****************************************************************************
 *
 */
void
main(
	int	argc,
	char	*argv[]
	)
{
        u_char	tab[TABSIZE];

        progname = ((int)strlen(argv[0]) == 0) ? "mkg3tab" : argv[0];

        bfill(tab, (int)sizeof(tab), 0xff);
        addcodes(tab, (int)SIZEOF(TIFFFax3bcodes), TIFFFax3bcodes);
        dumparray("TIFFFax3btab", tab);
        dumppointers(TIFFFax3bcodes, (int)SIZEOF(TIFFFax3bcodes), "b");
        bfill(tab, (int)sizeof(tab), 0xff);
        addcodes(tab, (int)SIZEOF(TIFFFax3wcodes), TIFFFax3wcodes);
        dumparray("TIFFFax3wtab", tab);
        dumppointers(TIFFFax3wcodes, (int)SIZEOF(TIFFFax3wcodes), "w");
        exit(0);
}
#pragma warn .par
