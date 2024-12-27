#include <stdio.h>
#include <gl/gl.h>

float octdata[6][3] = {
    { 1.0,  0.0,  0.0},
    { 0.0,  1.0,  0.0},
    { 0.0,  0.0,  1.0},
    {-1.0,  0.0,  0.0},
    { 0.0, -1.0,  0.0},
    { 0.0,  0.0, -1.0}
};
unsigned long octcolor[6] = {
    0xff0000,			/* [0] = blue */
    0x00ff00,			/* [1] = green */
    0x0000ff,			/* [2] = red */
    0xff00ff,	    		/* [3] = magenta */
    0xffff00,			/* [4] = cyan */
    0xffffff,			/* [5] = white */
};

void vertex(i)
int i;
{
    cpack(octcolor[i]);
    v3f(octdata[i]);
}


void drawoctahedron()
{
    bgntmesh();
	vertex(0);
	vertex(1);
    swaptmesh();
	vertex(2);
    swaptmesh();
	vertex(4);
    swaptmesh();
    	vertex(5);
    swaptmesh();
	vertex(1);
	vertex(3);
	vertex(2);
    swaptmesh();
	vertex(4);
    swaptmesh();
	vertex(5);
    swaptmesh();
	vertex(1);
    endtmesh();
}

main()
{
    Angle xang, yang, zang;
    long zval;
    int cnt;

    if (getgdesc(GD_BITS_NORM_DBL_RED) == 0) {
	fprintf(stderr, "Double buffered RGB not available on this machine\n");
	return 1;
    }
    if (getgdesc(GD_BITS_NORM_ZBUFFER) == 0) {
	fprintf(stderr, "Z-buffer not available on this machine\n");
	return 1;
    }
    prefsize(400, 400);
    winopen("octahedron");
    doublebuffer();
    RGBmode();
    gconfig();
    ortho(-2.0, 2.0, -2.0, 2.0, -2.0, 2.0);
    zbuffer(TRUE);		/* hidden surfaces removed with z-buffer */
    zval = getgdesc(GD_ZMAX);

    xang = yang = zang = 0;
    for (cnt = 0; cnt < 1000; cnt++) {
	czclear(0x000000, zval); 
	pushmatrix();		/* save viewing transformation */
	    rotate(xang, 'x');	/* rotate by xang about x axis */
	    rotate(yang, 'y');	/* rotate by yang about y axis */
	    rotate(zang, 'z');	/* rotate by zang about z axis */
	    drawoctahedron();
	popmatrix();		/* restore viewing transformation */
	swapbuffers();		/* show completed drawing */

	xang += 10;
	yang += 13;
	if (xang + yang > 3000)
	    zang += 17;
	if (xang > 3600)
	    xang -= 3600;
	if (yang > 3600)
	    yang -= 3600;
	if (zang > 3600)
	    zang -= 3600;
    }
    gexit();
    return 0;
}
