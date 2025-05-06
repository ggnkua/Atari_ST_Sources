#include <stdio.h>

#define MAXLIN 80
#define YES 1
#define NO  0
#define TABSP 8
#define TABPOS(col)	(((col) < MAXLIN) ? tabs[(col)] : YES)

int             tabs[MAXLIN];

main ()
{
    int            *ptab, col, c;

    ptab = tabs;
    settab (ptab);
    col = 0;
    while (EOF != (c = getchar ())) {
	switch (c) {
	case '\t':
	    while (YES != tabpos (col)) {
		putchar (' ');
		col++;
	    }
	    putchar (' ');
	    col++;
	    break;
	case '\n':
	    putchar ('\n');
	    col = 0;
	    break;
	default:
	    putchar (c);
	    col++;
	    break;
	}
    }
    exit (0);
}


tabpos (col)
    int             col;
{
    return (TABPOS (col));
}

settab (tabp, up)
    short          *tabp;
    long           *up;
{
    int             i;

    for (i = 1; i <= MAXLIN; i++) {
	*tabp++ = (0 == (i % TABSP));
    }
}
