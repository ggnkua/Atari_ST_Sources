/* Copyright 1990 by Antic Publishing, Inc. */
#include "easy.h"

plotline(data, ndata, mode, eolflag) /*********** PLOTLINE *****************/

unsigned char data[];
short  ndata, mode, eolflag;
/*
**   This function sends the 'ndata' values in 'data' to the printer to 
     be plotted. 'mode' is the density mode:

     mode      density (dpi)       description

      0             60             single density
      1             120            double density
      2             120            high speed double density
      3             240            quadruple density
      4             80             CRT screen
      5             72             one-to-one
      6             90             hi-res CRT
      7             144            two-to-one


     If 'eolflag' = 1, a <CR><LF> is sent to the printer after the data.*/

{
     unsigned char esccode[6];

/*   The escape code to set the printer properly is "<ESC>*'m''n1''n2'",
     where 'm' is the mode and 'n1' and 'n2' colectively specify the 
     number of columns to plot ('ndata'). 'n1' is 'ndata' MOD 256, and
     'n2' is 'ndata'/256 */

     sprintf(esccode, "%c*%c%c%c", ESC, (char) mode, (char)(ndata MOD 256),
               (char)(ndata/256));
     printcha(esccode, 5, 0);

/*   The data is assumed to be correctly coded for the printer to plot
     properly - each byte specifies one column of eight dots with the
     high bit specifying the top dot. */

     printcha(data, ndata, eolflag);
}
