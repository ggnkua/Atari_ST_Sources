extern long sxbios();

int r,g,b,var,res,i,colors[16];
long phys;
int clip[] = { 0,0,319,199 };

int col[2000];

main()
{
     i=0; var=0;
     for(r=7;r>=0;r--)
          for(g=0;g<8;g++)
               {
               for(b=0;b<8;b++)
                    {
                    col[var++]=(8-b)*2;
                    col[var++]=(r*0x100)+(g*0x10)+b;
                    }
               col[var++]=(-1);
               }
     for(i=0;i<100;i++) col[var++]=(-1);

     offmouse();
     palget(colors);
     phys=sxbios(2);
     res = (int) sxbios(4);
     sxbios(5,-1L,-1L,0);

     ondlist(col,3);

     for(i=0;i<8;i++) fbox(40*i,0,40*i+39,191,i+1,phys,clip);

     sgemdos(7);

     offdlist();
     sxbios(5,-1L,-1L,res);
     sxbios(6,colors);
     onmouse();
}
