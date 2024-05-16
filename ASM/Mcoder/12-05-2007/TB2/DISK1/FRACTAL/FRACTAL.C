/*----------------------------------------------------------+
|    FR_ITER                                                |
|                                                           |
|    Iterate equation (z' = z^2 + c), where 'c' is the      |
|    current complex plane coordinate.                      | 
+----------------------------------------------------------*/

fr_iter( ca, cb )
     LONG      ca;       /* complex plane, real coordinate */
     LONG      cb;       /* complex plane, imaginary coordinate */
     {
     LONG      n=0;      /* iteration count */
     LONG      za, zb;   /* complex number 'z' */
     ULONG     za2, zb2; /* 'z' squared */
     
     /* initialise 'z' to 'c' eliminating first iteration */

     za = ca;
     zb = cb;

     /* count previous iteration, and terminate if maximum allowed */

     while (++n < iters)
          {
          /* calculate square of 'za' and 'zb' */ 

          za2 = fracmul( za, za );
          zb2 = fracmul( zb, zb );

          /************************************************************* 
               value of 'z' must not exceed 2, thus for complex number:

                    ( (a)^2 + (b)^2 )^(0.5) <= 2 

               or,            (a)^2 + (b)^2 <= 4
          *************************************************************/

          if ( (za2 > FOUR) || (zb2 > FOUR) || (za2+zb2 > FOUR) )
               break;

          /************************************************************
               now calculate new value of 'z':

                         z' = z^2 + c 

                (za + izb)' = (za + izb)^2 + (ca + icb)

               ie.      za' = 2*za*zb +cb
                        zb' = (za)^2 - (zb)^2 + ca                

          ************************************************************/

          zb = 2 * fracmul( za, zb ) + cb;
          za = za2 - zb2 + ca;
          }

     /* return number of iterations calculated */

     return( n );
     }

fracmul( f1, f2 )
     int  f1,
          f2;
     {
#asm
     MOVE.L    8(A6),D1
     MOVE.L    12(A6),D2

     MOVE.L    D1,D3
     MOVE.L    D2,D4
     SWAP      D3
     SWAP      D4

*    Create products
     
     MOVE.W    D1,D7
     MULU      D2,D7
     MOVE.W    D3,D6
     MULU      D4,D6
     MULU      D1,D4
     MULU      D2,D3
 
*    Add cross products

     ADD.L     D3,D4

     MOVE.W    D4,D3
     SWAP      D3
     CLR.W     D3

     CLR.W     D4
     ADDX.W    D3,D4
     SWAP      D4

     ADD.L     D3,D7
     ADDX.L    D4,D6

*    Now fix sign

     TST.L     D1
     BPL.S     LMUL1
     SUB.L     D2,D6
LMUL1

     TST.L     D2
     BPL.S     LMUL2
     SUB.L     D1,D6
LMUL2

*    Now shift result to preserve scale

     ASL.L     #4,D6
     BVC.S     LMUL4          BRANCH IF NO OVERFLOW
     MOVE.L    #$55555555,D6  SET RESULT TO 5.3 IF OVERFLOW
LMUL4

     ROL.L     #4,D7
     AND.L     #$0000000F,D7
     ADD.L     D7,D6

     MOVE.L    D6,A0

     CLR.L     D7
     MOVEQ     #1,D6
#endasm
}
/*----------------------------------------------------------+
|    FR_QCOL                                                |
|                                                           |
|    Estimate, quickly a suitable contour colour for the    |
|    provided altitude.                                     |
+----------------------------------------------------------*/

#define   BANDWIDTH      5    /* change colour every N altitude units */

fr_qcol( altitude )
     UWORD     altitude;      /* find colour for this altitude */      
     {
     if ( altitude==iters )
          /* if maximum altitude set to minimum colour */   
          return( MINCOL );
     else
          /* otherwise group altitudes into bands and roll 
               through all the remaining colours */
          return( (MINCOL+1) + ((altitude/BANDWIDTH)%(NCOLS-1)) );
     }

