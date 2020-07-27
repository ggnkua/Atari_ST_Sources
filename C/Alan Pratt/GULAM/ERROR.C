/* error.c */

#include	"ue.h"

extern BUFFER *bfind();

errfwd()
  {
  register uchar *lp;
  register uchar *p;
  register BUFFER *errbp;
  int	line;
  uchar buf[80];
       
  if ((errbp = bfind("errorbuf",FALSE,0,REGKB,0)) == NULL)
    mlwrite("no errorbuf"); 
  else
    {
    lp = errbp->b_dotp->l_text;
    p = buf;
    line = llength(errbp->b_dotp);
    for (;line--;)
      { *p++ = *lp++; }
    *p = '\000';
    line = atoi(buf);
    mlwrite("%s",buf);
    errbp->b_doto = 0;
    if ((errbp->b_dotp = lforw(errbp->b_dotp)) == errbp->b_linep)
      errbp->b_dotp = lforw(errbp->b_dotp);
    gotoline(TRUE, line);
    }
  }
