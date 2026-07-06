/*   ABC  p21 eg 2.5                          */
/*   return()                                 */
/* tested and working ok 23/11/86             */

main()
     {         int length,width,depth;
               int ticks=200;
      
    

          length = 20; width = 26 ; depth = 4;
          printf("surface area = ");
          printf("%d\n",surface(length,width,depth));
             
         
          delay(ticks);
     }

surface(len,wid,dep)
     int len,wid,dep;
     { return(2*(len*wid + wid*dep + dep*len));}

