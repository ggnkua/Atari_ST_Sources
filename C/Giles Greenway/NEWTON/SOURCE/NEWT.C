#include<stdlib.h>
#include<math.h>
#include<linea.h>
#include<osbind.h>
#include<vdi.h>

#define max_its 100

int main(argc,argv)
int argc; char *argv[];
{

	short old_col[16];

	short col_dat[7][16] = {{1792,1536,1280,1024,768,56,40,32,
							 24,16,7,6,5,3,2,0},
							{1792,1280,1024,768,1848,1832,1824,1816,
							 56,40,32,24,7,5,4,3},
							{1792,1280,768,1848,1832,1816,56,40,
							 24,7,5,3,1543,1030,774,0},
							{1792,1024,1816,1296,1848,1320,56,32,
							 7,4,1031,519,0,0,0,0},
							{1792,1024,1816,1296,1848,1832,1060,530,
							 56,32,7,4,1031,519,0,0},
							{1040,776,1792,1024,1816,1296,1848,1832,
							 1060,530,56,32,7,4,1031,519},
							{1792,1808,1824,1848,1336,824,312,56,
							 32,25,19,13,7,263,519,775}};


	int res,x_pix,y_pix,ncols,loop,n,nn,nnn,x_loop,y_loop,
	root,pen,its,mode,pal,offset,colmod;

	float x_root[16],y_root[16],theta,x_min,x_max,y_min,y_max,
	x_len,y_len,dx,dy,x,y,x_old,y_old,x_new,y_new,h,k,h_temp,k_temp,
	denom,n_recip,vsmall;

	res = Getrez();

	linea0();

	switch (res)
	{
		case 0: x_pix = 319; y_pix = 199; ncols = 16; break;
		case 1: x_pix = 639; y_pix = 199; ncols = 4; break;
		case 2: x_pix = 639; y_pix = 399; ncols = 2; break;
	}

	for (loop = 0;loop <= 15;loop++)
	{
		old_col[loop] = Setcolor(loop,-1);
	}
	
	colmod = atoi(argv[1]);

	n = atoi(argv[2]);
	nn = n - 1;
	nnn = n - 2;
	n_recip = 1.0 / n;

	theta = 6.283185307 / n;

	x_root[0] = 1.0; y_root[0] = 0.0;	
	
	for (loop = 1;loop <= nn;loop++)
	{
		x_root[loop] = cos(loop * theta);
		y_root[loop] = sin(loop * theta);
	}

	if (ncols == 16)
	{

		mode = 1;

		offset = 16 / n;

		if (n < 8 && n > 2)
		pal = n - 3; else {pal = 6; mode = 0;}

		for (loop = 0;loop <= 15;loop++)
		Setcolor(loop,col_dat[pal][loop]);

	}
	
	

	x_min = atof(argv[3]);
	x_max = atof(argv[4]);
	y_min = atof(argv[5]);
	y_max = atof(argv[6]);

	

	x_len = x_max - x_min;
	y_len = y_max - y_min;

	dx = (x_len / x_pix) / 2;
	dy = (y_len / y_pix) / 2;

	vsmall = pow(dx,(float)n);
	vsmall = vsmall * vsmall;

	Cursconf(0,0);

	for (x_loop = 0;x_loop <= x_pix;x_loop++)
	{
		x = x_min + (x_len * x_loop) / x_pix;

 		for (y_loop = 0;y_loop <= y_pix;y_loop++)
		{
			y = y_min + (y_len * y_loop) / y_pix;

			

			x_old = x; y_old = y;

			
		
			root = - 1;

			its = 0;

			while (root < 0)
			{			

				its++; 

				if (its > max_its) root = 0;

				h = x_old; k = y_old;

				for (loop = 1;loop <= nnn;loop++)
				{	
					h_temp = h; k_temp = k;
					h = h_temp * x_old - k_temp * y_old;
					k = h_temp * y_old + k_temp * x_old;

					

				}

				denom = h * h + k * k;
	
				

				if (denom < vsmall) denom = vsmall;

				x_new = x_old - n_recip * (x_old - h / denom);
				y_new = y_old - n_recip * (y_old + k / denom);
			
				

				x_old = x_new; y_old = y_new;

				for (loop = 0;loop <= nn;loop++)
				{
					if (fabs(x_old - x_root[loop]) < dx &&
                	fabs(y_old - y_root[loop]) < dy) 
					{root = loop; break;}		
				}



			}

	
			if (colmod == 0)
			{
				if (mode == 1)
				pen = (root * offset) + (its % offset);
				else pen = root % ncols;
			}
			else pen = its % ncols;


			putpixel (x_loop,y_loop,pen);
			
		}

	}

	while (Bconin(2) == 0) {}

	for (loop = 0;loop <= 15;loop++)
	Setcolor(loop,old_col[loop]);

	return 0;

}