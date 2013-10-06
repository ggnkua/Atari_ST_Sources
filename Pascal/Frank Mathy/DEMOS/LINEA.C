extern long sxbios();

struct MFDB
{    long start;
     int width;
     int height;
     int wwidth;
     int format;
     int planes;
     int fut1;
     int fut2;
     int fut3;
} r;

int muster[] = { 0xF0F0,0xF0F0,0xFFFF,0xFFFF,
                 0x0F0F,0x0F0F,0x0000,0x0000,
                 0x0F0F,0x0F0F,0x3C3C,0x3C3C,
                 0xFFFF,0xFFFF,0x3C3C,0x3C3C,
                 
                 0xF0F0,0xF0F0,0x0000,0x0000,
                 0xFFFF,0xFFFF,0xC3C3,0xC3C3,
                 0xF0F0,0xF0F0,0x3C3C,0x3C3C,
                 0x0000,0x0000,0xFFFF,0xFFFF,
                 
                 0xF0F0,0xF0F0,0x3C3C,0x3C3C,
                 0x0000,0x0000,0xFFFF,0xFFFF,
                 0x0000,0x0000,0x3C3C,0x3C3C,
                 0x0F0F,0x0F0F,0x0000,0x0000,
                 
                 0xFFFF,0xFFFF,0x0000,0x0000,
                 0x0000,0x0000,0xC3C3,0xC3C3,
                 0xFFFF,0xFFFF,0xC3C3,0xC3C3,
                 0x0000,0x0000,0xFFFF,0xFFFF };

int sprite[] = { 8,8,1,1,2,
                 0x0000,0x0000,
                 0x0000,0x0000,
                 0x0000,0x0180,
                 0x0000,0x07E0,
                 0x0420,0x03C0,
                 0x0420,0x03C0,
                 0x0000,0x0180,
                 0x0000,0x0180,
                 0x0000,0x03C0,
                 0x0000,0x03C0,
                 0x1818,0x07E0,
                 0x1998,0x0660,
                 0x1998,0x0660,
                 0x0180,0x0000,
                 0x0000,0x0000,
                 0x0000,0x0000 };

int save[133];

int i,res;
int punkte[] = { 10,10,130,190,310,50 };
int copy[] = { 10,10,70,70,200,100,260,160 };
int maus[36];

main()
     {
     res=(int) sxbios(4);
     offmouse();
     sxbios(5,-1L,-1L,0);
     all_init();
     maus[0]=maus[1]=8; maus[2]=0; maus[3]=15;
     for(i=4;i<=35;i++) maus[i]=0xffff;
     transform(maus);
     fpoly(punkte,3);
     for(i=0;i<320;i++) set_pixel(i,190,i&15);
     for(i=199;i>=0;i--)
          {
          setsprite(160,i,sprite,save);
          sxbios(37);
          clrsprite(save);
          }
     for(i=0;i<100;i++) 
          {
          setcolor(i&15);
          drawline(10,i*2+1,310,199-i*2);
          }
     def_fill(muster,15,1);
     frect(0,0,280,40);
     settext(1,15,0,4,0);
     for(i=0;i<26;i++) setchar(20+i*8,20,65+i,1);

     r.start=sxbios(2);
     r.width=320;
     r.height=200;
     r.wwidth=20;
     r.format=0;
     r.planes=4;
     r.fut1=r.fut2=r.fut3=0;

     copy_raster(copy,&r,&r,3,0,0,0);

     onmouse();
     sgemdos(7);
     sxbios(5,-1L,-1L,res);
     }

