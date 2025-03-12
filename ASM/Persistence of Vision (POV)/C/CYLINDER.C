#include <math.h>
#include <gl/gl.h>
#include <gl/device.h>

Matrix Identity = { 1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1 };

float mat[] = {
	AMBIENT, .1, .1, .1,
	DIFFUSE, 0, .369, .165,
	SPECULAR, .5, .5, .5,
	SHININESS, 10,
	LMNULL,
};

static float lm[] = {
	AMBIENT, .1, .1, .1,
	LOCALVIEWER, 1,
	LMNULL
};

static float lt[] = {
	LCOLOR, 1, 1, 1,
	POSITION, 0, 0, 1, 0,
	LMNULL
};

main()
{
long xorigin, yorigin, xsize, ysize;
float rx, ry;
short val;

	winopen("cylinder");
	qdevice(ESCKEY);
	getorigin(&xorigin, &yorigin);
	getsize(&xsize, &ysize);
	RGBmode();
	doublebuffer();
	gconfig();
	lsetdepth(getgdesc(GD_ZMIN), getgdesc(GD_ZMAX));
	zbuffer(1);
	mmode(MVIEWING);
	perspective(600, xsize/(float)ysize, .25, 15.0);
	lmdef(DEFMATERIAL, 1, 0, mat);
	lmdef(DEFLIGHT, 1, 0, lt);
	lmdef(DEFLMODEL, 1, 0, lm);
	lmbind(MATERIAL, 1);
	lmbind(LMODEL, 1);
	lmbind(LIGHT0, 1);
	translate(0, 0, -4);

	while (!(qtest() && qread(&val) == ESCKEY && val == 0)) {
		ry = 300 * (2.0*(getvaluator(MOUSEX)-xorigin)/xsize-1.0);
		rx = -300 * (2.0*(getvaluator(MOUSEY)-yorigin)/ysize-1.0);
		czclear(0x404040, getgdesc(GD_ZMAX));
		pushmatrix();
		rot(ry, 'y');
		rot(rx, 'x');
		drawcyl();
		popmatrix();
		swapbuffers();
	}
}

drawcyl()
{
double dy = .2;
double theta, dtheta = 2*M_PI/20;
double x, y, z;
float n[3], v[3];
int i, j;

	for (i = 0, y = -1;  i < 10;  i++, y += dy)  {
		bgntmesh();
		for (j = 0, theta = 0;  j <= 20;  j++, theta += dtheta)  {
			if (j == 20)  theta = 0;
			x = cos(theta);
			z = sin(theta);
			n[0] = x;  n[1] = 0;  n[2] = z;
			n3f(n);
			v[0] = x;  v[1] = y;  v[2] = z;
			v3f(v);
			v[1] = y + dy;
			v3f(v);
		}
		endtmesh();
	}
}

