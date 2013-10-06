extern long sxbios();

#define XRND (int) (sxbios(17)&511)-72
#define YRND (int) (sxbios(17)&255)-28
#define RRND (int) (sxbios(17)&127)

int res;
long physbase;
int clip[] = { 0,0,319,199 };

main()
{
     register int i;
     offmouse();
     physbase=sxbios(2);
     res = (int) sxbios(4);
     sxbios(5,-1L,-1L,0);

     for(i=0;i<500;i++) fhline(XRND,YRND,XRND,i&15,physbase,clip);

     for(i=0;i<500;i++) fvline(XRND,YRND,YRND,i&15,physbase,clip);

     for(i=0;i<500;i++) fcircle(XRND,YRND,RRND,i&15,physbase,clip);

     for(i=0;i<500;i++) fframe(XRND,YRND,XRND,YRND,i&15,physbase,clip);

     for(i=0;i<500;i++) fline(XRND,YRND,XRND,YRND,i&15,physbase,clip);

     for(i=0;i<500;i++) fbox(XRND,YRND,XRND,YRND,i&15,physbase,clip);

     for(i=0;i<500;i++) fpcircle(XRND,YRND,RRND,i&15,physbase,clip);

     for(i=0;i<7500;i++) fplot(XRND,YRND,i&15,physbase,clip);

     sxbios(5,-1L,-1L,res);
     onmouse();
}

