#include <stdio.h>
#include <gl/gl.h>
#include <gl/device.h>

#define X	    0
#define Y	    1
#define XY	    2

#define BUFSIZE	    10
#define PLANET	    109
#define SHIPWIDTH   20
#define SHIPHEIGHT  10

void drawplanet()
{
    color(GREEN);
    circfi(200, 200, 20);
}

main()
{
    float ship[XY];
    long org[XY];
    long size[XY];
    Device dev;
    short val;
    Device mdev[XY];
    short mval[XY];
    long nhits;
    short buffer[BUFSIZE];
    Boolean run;

    prefsize(400, 400);
    winopen("select1");
    getorigin(&org[X], &org[Y]);
    getsize(&size[X], &size[Y]);
    mmode(MVIEWING);
    ortho2(-0.5, size[X] - 0.5, -0.5, size[Y] - 0.5);
    qdevice(LEFTMOUSE);
    qdevice(ESCKEY);
    color(BLACK);
    clear();
    mdev[X] = MOUSEX;
    mdev[Y] = MOUSEY;

    drawplanet();
    run = TRUE;
    while (run) {
	dev = qread(&val);
	if (val == 0) {				/* on upstroke */
	    switch (dev) {
	    case LEFTMOUSE:
		getdev(XY, mdev, mval);
		ship[X] = mval[X] - org[X];
		ship[Y] = mval[Y] - org[Y];
		color(BLUE);
		sbox(ship[X], ship[Y], 
		     ship[X] + SHIPWIDTH, ship[Y] + SHIPHEIGHT);

		/*
		 * specify the selecting region to be a box surrounding the
		 * rocket ship 
		 */
		ortho2(ship[X], ship[X] + SHIPWIDTH, 
		       ship[Y], ship[Y] + SHIPHEIGHT);

		initnames();
		gselect(buffer, BUFSIZE);
		    loadname(PLANET);
		    /* no actual drawing takes place */
		    drawplanet();
		nhits = endselect(buffer);

		/*
		 * restore the Projection matrix; NB. can't use push/popmatrix 
		 * since they only work for the ModelView matrix stack 
		 * when in MVIEWING mode
		 */
		ortho2(-0.5, size[X] - 0.5, -0.5, size[Y] - 0.5);

		/* 
		 * check to see if PLANET was selected; NB. nhits is NOT the
		 * number of buffer elements written
		 */
		if (nhits < 0) {
		    fprintf(stderr, "gselect buffer overflow\n");
		    run = FALSE;
		} 
		else if (nhits >= 1 && buffer[0] == 1 && buffer[1] == PLANET)
		    ringbell();
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
