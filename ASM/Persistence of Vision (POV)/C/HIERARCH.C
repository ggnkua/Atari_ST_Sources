#include <math.h>
#include <gl/gl.h>

#define X	0
#define Y	1
#define XY	2

float carbody[4][XY] = {
    {-0.1, -0.05},
    { 0.1, -0.05},
    { 0.1,  0.05},
    {-0.1,  0.05}
};
float wheel[4][XY] = {
    {-0.015, -0.015},
    { 0.015, -0.015},
    { 0.015,  0.015},
    {-0.015,  0.015}
};


void drawwheel()
{
    color(GREEN);
    bgnpolygon();
	v2f(wheel[0]);
	v2f(wheel[1]);
	v2f(wheel[2]);
	v2f(wheel[3]);
    endpolygon();
}

void drawcar()
{
    int i;

    color(RED);
    bgnpolygon();
	v2f(carbody[0]);
	v2f(carbody[1]);
	v2f(carbody[2]);
	v2f(carbody[3]);
    endpolygon();
    for (i = 0; i < 4; i++) {
	pushmatrix();
	    translate(carbody[i][X], carbody[i][Y], 0.0);
	    rotate(200*(i+1), 'z');
	    drawwheel();
	popmatrix();
    }
}

main()
{
    float xoffset, yoffset;
    Angle ang;

    prefsize(400, 400);
    winopen("hierarchy");
    mmode(MVIEWING);
    ortho2(-1.0, 1.0, -1.0, 1.0);
    color(BLACK);
    clear();
    for (xoffset = -0.5; xoffset <= 0.5; xoffset += 0.5) {
	for (yoffset = -0.5; yoffset <= 0.5; yoffset += 0.5) {
	    ang = 3600 * drand48();
	    pushmatrix();
		translate(xoffset, yoffset, 0.0);
		rotate(ang, 'z');
		drawcar();
	    popmatrix();
	}
    }
    sleep(10);
    gexit();
    return 0;
}
