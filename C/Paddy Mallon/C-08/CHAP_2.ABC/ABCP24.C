/* ABC p24 eg2.7                          */
/*  pointers and addresses                */
/* tested 22/11/86 this version runs ok   */

 

main()
     {         int length,width,depth,area;
               int ticks=200;
      
    

          length = 20; width = 26 ; depth = 4;
          surface(length,width,depth,&area);
          printf("surface area = %d\n",area);
             
         
          delay(ticks);
     }

surface(len,wid,dep,addr)
     int len,wid,dep,*addr;
     { *addr = (2*(len*wid + wid*dep + dep*len));}

