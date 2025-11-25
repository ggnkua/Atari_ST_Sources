#include "defs.h"

transitive_closure(R, n)
unsigned *R;
int n;
{
  register int rowsize;
  register unsigned mask;
  register unsigned *rowj;
  register unsigned *rp;
  register unsigned *rend;
  register unsigned *ccol;

  unsigned *relend;
  unsigned *cword;
  unsigned *rowi;

  rowsize = ROWSIZE(n);
  relend = (unsigned *) ((unsigned) R + n*rowsize);

  cword = R;
  mask = 1;
  rowi = R;
  while (rowi < relend)
    {
      ccol = cword;
      rowj = R;

      while (rowj < relend)
	{
	  if (*ccol & mask)
	    {
	      rp = rowi;
	      rend = (unsigned *) ((unsigned) rowj + rowsize);

	      while (rowj < rend)
		*rowj++ |= *rp++;
	    }
	  else
	    {
	      rowj = (unsigned *) ((unsigned) rowj + rowsize);
	    }

	  ccol = (unsigned *) ((unsigned) ccol + rowsize);
	}

      mask <<= 1;
      if (mask == 0)
	{
	  mask = 1;
	  cword++;
	}

      rowi = (unsigned *) ((unsigned) rowi + rowsize);
    }
}

reflexive_transitive_closure(R, n)
unsigned *R;
int n;
{
  register int rowsize;
  register unsigned mask;
  register unsigned *rp;
  register unsigned *relend;

  transitive_closure(R, n);

  rowsize = ROWSIZE(n);
  relend = (unsigned *) ((unsigned) R + n*rowsize);

  mask = 1;
  rp = R;
  while (rp < relend)
    {
      *rp |= mask;

      mask <<= 1;
      if (mask == 0)
	{
	  mask = 1;
	  rp++;
	}

      rp = (unsigned *) ((unsigned) rp + rowsize);
    }
}
