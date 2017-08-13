
#include "test_effect.h"

void qsort_polyoutput_list(int links, int rechts)
{
	int xvergl;
	int i,j;

	int z_temp;
	PolyOut *poly_temp;

	i = links;
	j = rechts;

	xvergl = polyoutput_Zsort_list[(i+j)/2].z_average;

	do
	{
		//while(polyoutput_Zsort_list[i].z_average < xvergl)
		while(polyoutput_Zsort_list[i].z_average > xvergl)
		{
			i++;
		}

		//while(xvergl < polyoutput_Zsort_list[j].z_average)
		while(xvergl > polyoutput_Zsort_list[j].z_average)
		{
			j--;
		}

		if(i<=j)
		{
			z_temp = polyoutput_Zsort_list[i].z_average;
			polyoutput_Zsort_list[i].z_average = polyoutput_Zsort_list[j].z_average;
			polyoutput_Zsort_list[j].z_average = z_temp;

			poly_temp = polyoutput_Zsort_list[i].polygon;
			polyoutput_Zsort_list[i].polygon = polyoutput_Zsort_list[j].polygon;
			polyoutput_Zsort_list[j].polygon = poly_temp;

			i++;
			j--;
		}

	}while( i<=j );

	if( links<j)
	{
		qsort_polyoutput_list( links,j);
	}

	if( i<rechts)
	{
		qsort_polyoutput_list( i,rechts);
	}
}

