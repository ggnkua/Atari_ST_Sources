/*******************************************************************
 *
 *  memtest.c		projekt : xcarpet
 *------------------------------------------------------------------
 *  test des memory-moduls
 *------------------------------------------------------------------
 *
 *******************************************************************/
  
 /*  29. 5.88  stock  */

#include "..\\xcarpet\\memory.c"
#include <stdio.h>
#include <osbind.h>


main()
{
  int i,nx,ny,nochmal,check,gety,res;
  
  puts ("\033E\n\n *********  test des memory-moduls  **********\n");
  
  do
  {
    fputs ("eingabe : x- und y-aufl”sung : ",stdout); fflush (stdout);
    do 
      i=scanf ("%d%d",&nx,&ny);
    while (i != 2);
    
    check = check_resolution (nx,ny);
    gety  = get_yresolution (nx); 
    res   = reserve_xyz (nx,ny);
    
    printf ("\n   check = %d , get_y = %d , reserve_xyz = %d \n\n",
      check, gety, res);
    printf (
    "array2d = %lx, rowvectors = %lx, totalbytes = %ld, bytes/block = %d \n\n", 
      array2d, rowvectors, totalbytes, bytes);
    
    if (res)
    {
      puts ("speicherbl”cke, block[i]");
      for (i = 0; i < BLOCKS; i++)
        printf ("%8lx",block[i]);
      puts ("");
      
      puts("spaltenvektoren, row_vector (i)");
      for (i = 0; i < nx; i++)
        printf ("%8lx",row_vector(i));
      puts("");
    }
    free_xyz ();
    
    puts ("nochmal ? (= <enter>)");
    nochmal = (int) Cconin() == 13;
  }
  while (nochmal);
}

/*******************************************************************/
