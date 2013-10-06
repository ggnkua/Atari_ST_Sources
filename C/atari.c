                #include<math.h>
                int   main   (){
                int   x,y,   u;
               char   c='*'  , * 
               s =    "%*c"  ;for 
              (x=0    ;x <   11 ;    
              x++)    { y=   (int)
             (0.01    *pow    (x,3)
             +1 );    u =(    int ) 
           (0.005     *pow     (x,3.1)
         );printf     (s,14      -y, c);
       printf(s,      y-u,c       );printf
     ("%*c**",        2+ u,        c); printf(
  s, u+2, c);         printf          ("%*c\n",y
 -u , c); }           return                0; }

