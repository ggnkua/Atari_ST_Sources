/*
	vector.c
	
	T.AL 95
*/

#include <stdio.h>
#include <tos.h>
#include <ext.h>

#include "vector.h"
#include "ptlist.h"

int main(int argc, char *argv[])
{
	IMGF30 *i;
	GREY *g, *sx, *sy, *sg;
	GREY     *dx, *dy, *dg;
	GREY     *lx, *ly, *lg;
	GREY *fun;
	EDLIST *chain= NULL;
	long hist[256];

	if(argc==1)
	{
		puts("usage: vdspq4 image.f30 alpha\n\n.f30 image file must be true color\nalpha is the filter factor\n");
		return -1;
	}
	
	i= load_f30(argv[1]);
	if(!i) return 1;
	
	g= convf30_grey(i);
	if(!g) return 1;
	free_f30(i);

	disp_grey(g);
	histo(g, hist);
	recadre_histo(g, hist);
	disp_grey(g);
	
	/* init_dsp, chargement .LOD */
	init_dsp("dspcalc3.lod");

	if(argc==2)
		alpha= DEFAULT_FILTER_FACTOR;
	else
		sscanf(argv[2], "%f", &alpha);

	printf("\nDeriche filter factor %6.3f\n", alpha);
	factor(alpha);
	
	/* Deriche filter */
	sx= calc_sx(g);
	/* disp_grey(sx);
	getch(); */
	sy= calc_sy(g);
	/* disp_grey(sy);
	getch(); */
	sg= filter(sx,sy);
	disp_grey(sg);
	/* histo(sg, hist);
	getch(); */

	/* Deriche gradient */
	dx= calc_dx(sg);
	/* disp_grey(dx);
	histo(dx, hist);
	getch(); */
	dy= calc_dy(sg);
	/* disp_grey(dy);
	histo(dy, hist);
	getch(); */
	dg= gradient(dx,dy);
	disp_grey(dg);
	/* histo(dg, hist);
	getch(); */
	
	/* Deriche laplacian */
	lx= calc_dx(dx);
	/* disp_grey(lx);
	histo(dx, hist);
	getch(); */
	ly= calc_dy(dy);
	/* disp_grey(dy);
	histo(dy, hist);
	getch(); */
	lg= laplacian(lx,ly);
	disp_pol(lg);
	/* histo(dg, hist);
	getch(); */

	check_zgr(lg, dx, dy);
	disp_grey(lg);
	/* getch(); */

	/*
	fun= copy_grey(dg);
	grlocalsort(dg, dx,dy);
	disp_grey(dg);
	getch();
	grlocalsort_8c(fun, dx, dy);
	disp_grey(fun);
	getch();
	free_grey(fun);
	*/
		
	/* just fun
	fun= filter(sg, dg);
	disp_grey(fun);
	getch();
	free_grey(fun);
	fun= filter(sg,lg);
	disp_grey(fun);	
	getch();
	free_grey(fun);
	
	disp_mask(sg, lg);
	getch();
	*/

	chain= chain_edge(lg);
	disp_chain(chain);
	getch();
	/* free_ed(chain); */
			
	free_grey(g);
	free_grey(sx);
	free_grey(sy);
	free_grey(sg);
	
	free_grey(dx);
	free_grey(dy);
	free_grey(dg);
	
	free_grey(lx);
	free_grey(ly);
	free_grey(lg);

	free_dsp();

	return 0;
}
