extern long sxbios();

int res,i,colors[16];
long phys;
int clip[] = { 0,0,319,199 };
int liste[] = { 0,0x000,-1,0,0x111,-1,0,0x222,-1,0,0x333,-1,0,0x444,-1,
                0,0x555,-1,0,0x666,-1,0,0x777,-1 };

main()
{
     offmouse();
     palget(colors);
     phys=sxbios(2);
     res = (int) sxbios(4);
     sxbios(5,-1L,-1L,0);

     ondlist(liste,26);

     for(i=1;i<15;i++) fbox(20*i,95,19+20*i,105,i,phys,clip);

     oncycle(1,14,0,7);

     sgemdos(7);

     offcycle();

     offdlist();

     sxbios(5,-1L,-1L,res);
     sxbios(6,colors);
     onmouse();
}

