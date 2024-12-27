#include <stdio.h>
#include <gl/gl.h>
#include <gl/device.h>

#define BUFSIZE 50

void drawit()
{
    loadname(1);
    color(BLUE);
    writemask(BLUE);
    sboxfi(20, 20, 100, 100);

    loadname(2);
    pushname(21);
	color(GREEN);
	writemask(GREEN);
	circfi(200, 200, 50);
    popname();
    pushname(22);
	color(RED);
	writemask(RED);
	circi(200, 230, 60);
    popname();
    writemask(0xfff);
}

void printhits(buffer, hits)
short buffer[];
long hits;    
{
    int indx, items, h, i;
    char str[20];

    sprintf(str, "%ld hit", hits);
    charstr(str);
    if (hits != 1)
	charstr("s");
    if (hits > 0)
	charstr(": ");
    indx = 0;
    for (h = 0; h < hits; h++) {
	items = buffer[indx++];
	charstr("(");
	for (i = 0; i < items; i++) {
	    if (i != 0)
		charstr(" ");
	    sprintf(str, "%d", buffer[indx++]);
	    charstr(str);
	}
	charstr(") ");
    }
}

main()
{
    Device dev;
    short val;
    long hits;
    long xsize, ysize;
    short buffer[BUFSIZE];
    Boolean run;

    prefsize(400, 400);
    winopen("pick");
    getsize(&xsize, &ysize);
    mmode(MVIEWING);
    ortho2(-0.5, xsize - 0.5, -0.5, ysize - 0.5);
    color(BLACK);
    clear();
    qdevice(LEFTMOUSE);
    qdevice(ESCKEY);
		
    drawit();
    run = TRUE;
    while (run) {
	dev = qread(&val);
	if (val == 0) {				/* on upstroke */
	    switch (dev) {
	    case LEFTMOUSE:
		pick(buffer, BUFSIZE);
		    ortho2(-0.5, xsize - 0.5, -0.5, ysize - 0.5);
		    drawit();	/* no actual drawing takes place */
		hits = endpick(buffer);

		ortho2(-0.5, xsize - 0.5, -0.5, ysize - 0.5);
		color(BLACK);
		sboxfi(150, 20 - getdescender(), xsize - 1, 20 + getheight());
		color(WHITE);
		cmov2i(150, 20);
		printhits(buffer, hits);
		break;

	    case ESCKEY:
		run = FALSE;
		break;
	    }
	}
    }
    gexit();
    return 0;
}
