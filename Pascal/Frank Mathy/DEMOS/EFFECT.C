extern long sxbios(),getpage(),cload(),csave;

long phys,pic1,pic2,st1,st2;
int colors[16],oldcol[16],res;
int i,j;
int window[] = { 3,50,16,150 };

main()
     {
     offmouse();
     res= (int) sxbios(4);
     phys=sxbios(2);
     pic1=getpage();
     pic2=getpage();
     if ((pic1>0) && (pic2>0))
          {
          st1=cload("glas.cmp",pic1,32000L,colors);
          st2=cload("station.cmp",pic2,32000L,colors);

          if ((st1>=0) && (st2>=0))
               {
               palget(oldcol);
               sxbios(5,-1L,-1L,0);
               sxbios(6,colors);

               effect();

               fadeout();
               sxbios(5,-1L,-1L,res);
               fadein(oldcol);
               }
          freepage(pic1);
          freepage(pic2);
          }
     onmouse();
     }

effect()
     {
     for(i=4;i<=200;i+=4) yshrink(pic2,phys,i,(200-i)/2);
     for(i=4;i<=200;i+=4) yshrink(pic1,phys,i,200-i);
     for(i=4;i<=200;i+=4) yshrink(pic2,phys,i,0);
     fadeout();
     opscreen(pic1,phys,0,199,1);
     fadein(colors);
     for(i=95;i>=0;i--) copyscreen(pic2,phys,i,199-i);
     for(i=1;i<=230;i++) lp_scroll(phys,window);
     yin(pic1,phys,0);
     yin(pic2,phys,1);
     xyin(pic1,phys);
     fallin(pic2,phys);
     splitin(pic1,phys);
     rndbcopy(pic2,phys,1500);
     rndpcopy(pic1,phys);
     overlap(pic2,phys);
     overlap(pic1,phys);
     }

