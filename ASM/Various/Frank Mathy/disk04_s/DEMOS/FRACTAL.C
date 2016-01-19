/* Fractal-Programm von Frank Mathy */
/*  FÅr das Grafik- und Soundbuch   */

extern long sxbios(),sgemdos();

#define Random() sxbios(17)
#define Logbase() sxbios(3)
#define Color(a,b) sxbios(7,a,b)
#define Setpalette(a) sxbios(6,a)
#define Getrez() (int)sxbios(4)
#define Setscreen(a,b,c) sxbios(5,a,b,c)

int  h[65][65],colors[16];
int  sw,aw,l,yg,xz,yz,res;
long log;

int pot[] = { 63,31,15,7,3,1,0 };

int  p0,p1,p2,p3,p4,p5;

zufall(stufe)
int  stufe;
{
     return((Random()&pot[stufe-1])-(pot[stufe]));
}

mache_fractal()
{
     register int yg,yz,sw,xz,aw;
     h[0][0]=0;
     h[0][64]=0;
     h[64][0]=0;

     sw=32; aw=64;
     for (l=1;l<=6;l++)
     {
     yz=0; yg=0;
     do   {
               if (yg++%2==0)
               {    xz=sw;
                    do   {
                         h[xz][yz]=(h[xz-sw][yz]+h[xz+sw][yz])/2+zufall(l);
                         xz+=aw;
                         }
                    while (xz<64-yz);
               }
               else
               {    xz=0;
                    do   {
                         h[xz][yz]=(h[xz][yz-sw]+h[xz][yz+sw])/2+zufall(l);
                         xz+=sw;
                         h[xz][yz]=(h[xz-sw][yz+sw]+h[xz+sw][yz-sw])/2+zufall(l);
                         xz+=sw;
                         }
                    while (xz<=64-yz);
               }
          yz+=sw;
          }
          while (yz<64);
     aw>>=1;
     sw>>=1;
     }
}

zeichne_fractal(stufe,pegel)
int stufe,pegel;
{
     register int x,y,farbe;
     sw=(pot[stufe+1])+1;
     clearscreen(log,0,199);
     for(y=0;y<=63;y+=sw)for(x=0;x<=63-y;x+=sw)
     {
          farbe=2;
          p0=(x*10)+(y*5);
          p1=(y<<1)+70;
          if((h[x][y])>pegel) {
                         p1-=(h[x][y]);
                         farbe=3;
                         }
          else p1-=pegel;
          p2=p0+(10*sw);
          p3=(y<<1)+70;
          if((h[x+sw][y])>pegel){
                         p3-=(h[x+sw][y]);
                         farbe=3;
                         }
          else p3-=pegel;
          p4=p0+(5*sw);
          p5=((y+sw)<<1)+70;
          if((h[x][y+sw])>pegel){
                         p5-=(h[x][y+sw]);
                         farbe=3;
                         }
          else p5-=pegel;
          setcolor(farbe);
          drawline(p0,p1,p2,p3);
          drawline(p2,p3,p4,p5);
          drawline(p4,p5,p0,p1);
     }
}

main()
     {
     int zl,wp;
     long key;
     wp=0; zl=5;
     palget(colors);
     res=Getrez();
     Setscreen(-1L,-1L,1);
     Color(0,0);
     Color(2,7);
     Color(3,0x70);
     log=Logbase();
     all_init();
     offmouse();
     mache_fractal();
     zeichne_fractal(zl,wp);
     do   {
          key=sgemdos(7);
          key>>=16;
          switch((int) key)
               {
               case 0x48:     if(wp<50) 
                                   {
                                   wp+=3;
                                   zeichne_fractal(zl,wp);
                                   }
                              break;
               case 0x50:     if(wp>-50)
                                   {
                                   wp-=3;
                                   zeichne_fractal(zl,wp);
                                   }
                              break;
               case 0x4d:     if(zl<5)
                                   {
                                   zl++;
                                   zeichne_fractal(zl,wp);
                                   }
                              break;
               case 0x4b:     if(zl)
                                   {
                                   zl--;
                                   zeichne_fractal(zl,wp);
                                   }
                              break;
               case 0x62:     mache_fractal();
                              zeichne_fractal(zl,wp);
                              break;
               }
          } while(key!=0x61);
     Setscreen(-1L,-1L,res);
     Setpalette(colors);
     onmouse();
}

