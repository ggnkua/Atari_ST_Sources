extern long sxbios();

int star[] = { 8,   0,-50, 10,-10, 50,0, 10,10, 0,50, -10,10,
                    -50,0, -10,-10 };

int i,res;
long log;

main()
     {
     offmouse();
     res=(int) sxbios(4);
     log=sxbios(2);
     sxbios(5,-1L,-1L,0);
     all_init();
     def_clip(0,0,319,199,1);
     clearscreen(log,0,199);
     for(i=1;i<16;i++)
          {
          setcolor(i);
          object(i*19,5+i*10,22+i*7,star);
          }
     sgemdos(7);
     sxbios(5,-1L,-1L,res);
     onmouse();
     }

