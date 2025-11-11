#include "defines.h"
#include "globals.h"

#ifdef alliant
#pragma global safe (Eta_rownr, Eta_value)
#pragma global assoc
#endif

void  ftran(int start,
	    int end,
	    double *pcol)
{
  int    i, j;
  int    k, r;
  double theta;
  
#ifdef alliant
#pragma safe (pcol, Endetacol)
#pragma routine permutation (Eta_rownr)
#endif

  if (Verbose)
    printf("ftran\n");
  for (i = start; i <= end; i++)
    {
      k = Endetacol[i] - 1;
      r = Eta_rownr[k];
      theta = pcol[r];
      if (theta != 0)
	for (j = Endetacol[i - 1]; j < k; j++)
	  pcol[Eta_rownr[j]] += theta * Eta_value[j]; /* cpu expensive line */
      pcol[r] *= Eta_value[k];
    }

#ifdef alliant
#pragma loop novector
#endif

  for (i = 0; i <= Rows; i++)
    if (abs(pcol[i]) < EPSEL)
      pcol[i] = 0;
} /* ftran */

void  btran(int numc,
	    double *row)
{
  int    i, j, k;
  double f;
  
#ifdef alliant
#pragma safe (row, Endetacol)
#endif

  if (Verbose)
    printf("btran\n");
  for (i = numc; i >= 1; i--)
    {
      f = 0;
      k = Endetacol[i];
      for (j = Endetacol[i - 1]; j < k; j++)
	f += row[Eta_rownr[j]] * Eta_value[j];
      if (abs(f) < EPSEL)
	row[Eta_rownr[k - 1]] = 0;
      else
	row[Eta_rownr[k - 1]] = f;
    }
} /* btran */
