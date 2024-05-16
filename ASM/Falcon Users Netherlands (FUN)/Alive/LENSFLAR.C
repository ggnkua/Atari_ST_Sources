/*
 * flare.c
 *
 * Lars Hamre, 1995
 * lars@scala.no
 *
 * tab = 4 spaces
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <ext.h>

#define PI 3.1416
#define TRUE 1
#define FALSE 0

/*************************************************************************/

unsigned int rgbtab[1024];

int Width  = 64;
int Height = 64;

struct rgbvect
{
	unsigned int	len;
	double			r,g,b;
};

/*************************************************************************/

/* Return random value between -1 and 1 */

double frand1d(long x)
{
	long s = 71 * x; s = s * 8192 ^ s;
	return 1.0 - ((s*(s*s*15731L+789221L)+1376312589L)& 0x7fffffffL)/1073741824.0;
}

/* Return bandlimited noise. Each integer value has a different 
   random number. Values in-between use linear interpolation. */

double Noise1D(double x)
{
	long i;
	double f,n0,n1;

	i = floor(x);
	f = x - i;
	n0 = frand1d(i);
	n1 = frand1d(i+1);

	return n0 + (n1-n0)*f;
}

/* Output the flare-bitmap to file. */

void write_flarebitmap(double r, int tablen)
{
	int flarefile;

	unsigned int col[640];
	int x, y;
	double dx, dy, d, a, f, v;

	double linear = 0.03;
	double gauss  = 0.006;
	double mix    = 0.50;

	double ring,rmin,rmax,rmid,rwid;

	/* ring position and width */

	rmid = 27;
	rwid = 1.6;
	rmax = rmid + rwid;
	rmin = rmid - rwid;

	f = r;
	r = 0;

	flarefile = open("flare.raw", O_CREAT|O_WRONLY|O_TRUNC);

	for (y=0; y<Height; y++)
	{
		dy = Height/2 - y;
		for (x=0; x<Width; x++)
		{
			dx = x - Width/2;

			/* Get distance from center of flare */

			d = sqrt(dx*dx + dy*dy) * 1.0; /* constant controls diameter */

			/* The center of the flare is modelled as a gaussian 
			  bump, and the glow around is a simple falloff. 
			  Mix and match as you like.
			
			  If calculating in RGB try making the bump white
			  and the glow red-orange. */

			a = exp(-d*d*gauss)*mix + exp(-d*linear)*(1-mix);

			/* Draw the ring around the flare. An orange-red
			   color is appropriate here as well.
			   Try RGB = {80,20,10} (or was it darker?) */

			if (d<rmin || d>rmax)
				ring = 0;
			else
			{
				ring = fabs(d-rmid)/rwid;
				ring = 1 - ring*ring*(3 - 2*ring);
				ring *= 0.10;
			}

			a += ring;

			/* Creates random lines out from the center.
			   v/PI*17 controls the number of lines.
			   v*10 sets the noise frequency
   			   *2 is the noise modulation */

			v = atan2(dx, dy)+PI;
			v = (fmod(v/PI*17 + 1.0 + Noise1D(v*10), 1.0) - 0.5)*2;
			v = fabs(v);
			v = pow(v, 5.0);

			/* Add lines and fade out over distance. */

			a += 0.10*v / (1 + d*0.1);

			/* Clip to maximum value */

			if (a>1)
				a = 1;

			col[x] = rgbtab[(tablen-1) * a];
		}
		write(flarefile, col, Width*2);
	}
	close(flarefile);
}

/*********************************************************/

#define GAMMA 1.0 /* 1.8 */

/* Create a grayscale palette */

unsigned int SetColors(struct rgbvect *colortab, int entries )
{
	unsigned int	k, i, j, r, g, b, c, len, tablen;
	double			r1, g1, b1, r2, g2, b2, mix;

	len = 0;
	i = 0;
	for (j=0; j<entries-1; j++)
	{
		len+=colortab[j].len;
		tablen=colortab[j].len;
		r1=colortab[j].r;
		g1=colortab[j].g;
		b1=colortab[j].b;
		r2=colortab[j+1].r;
		g2=colortab[j+1].g;
		b2=colortab[j+1].b;

		for (k=0; k<tablen; k++)
		{
			mix = (double) k / (tablen-1);
			r = ( (mix * r2) + ((1.0-mix) * r1) ) * 255;
			g = ( (mix * g2) + ((1.0-mix) * g1) ) * 255;
			b = ( (mix * b2) + ((1.0-mix) * b1) ) * 255;
			c = 0;
			c |= (r<<8) & 0xf800;
			c |= (g<<3) & 0x07e0;
			c |= (b>>3) & 0x001f;
			rgbtab[i] |= c;
			i++;
		}
	}
	return len;
}

void main(void)
{
	double r = 1.0;
	struct rgbvect colortab[3];
	int	len;

	srand(time(0));
	colortab[0].len = 128;
	colortab[0].r = 0.0;
	colortab[0].g = 0.0;
	colortab[0].b = 0.0;
	colortab[1].len = 128;
	colortab[1].r = 0.8;
	colortab[1].g = 0.2;
	colortab[1].b = 0.1;
	colortab[2].len = 128;
	colortab[2].r = 1.0;
	colortab[2].g = 1.0;
	colortab[2].b = 1.0;
	printf("Calculating colortable...\n");
	len = SetColors(colortab, 3);

	printf("Calculating bitmap and writing to disk...\n");
	write_flarebitmap(r, len);

	printf("Press a key to exit.\n");
	while ( !kbhit() )
	{
	}

}