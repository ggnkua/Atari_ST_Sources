/*------------------------------------------------------------------------
    MAKEMAP.C:
    Sample programm for generating NeoN-Map Files,
    for new procedural textures and structures.

    (c) 1994 Ole Dittmann & Jens Stutte
------------------------------------------------------------------------*/

#include<stdio.h>
#include<stdlib.h>
#include<math.h>

int main(void)
    {
    char maphead[16]="Rip-Mapfile:";
    FILE *dat;
    short n,x,y,z;
    long i,j;
    double f;
    const short nm=1,xm=128,ym=128,zm=1; /* Place dimensions here */
                                         /* Numbers must be 2^x */
                                         /* 0 is not allowed */
                                         /* nm should be 1 */

    dat=fopen("drop_xy.map","wb");       /* Place filename here */

    if (dat==NULL) {printf("Could not open file !"); return -1;}
    fwrite(maphead,16,1,dat);
    fputc(nm % 256,dat); fputc(nm / 256,dat);
    fputc(xm % 256,dat); fputc(xm / 256,dat);
    fputc(ym % 256,dat); fputc(ym / 256,dat);
    fputc(zm % 256,dat); fputc(zm / 256,dat);
    srand(0);
    for (n=0; n<nm; n++)
        for (x=0; x<xm; x++)
            for (y=0; y<ym; y++)
                for (z=0; z<zm; z++)
                    {
                    /* rect,quad */
/*                  if (x==0 || y==0 || z==0)
                        fputc(255,dat);
                    else
                        fputc(0,dat); */

                    /* chess */
/*                  fputc((((x>>3)&1)^((y>>3)&1)^
                          ((z>>3)&1))*255,dat); */

                    /* fade */
/*                  if (y==0)
                        fputc(255,dat);
                    else
                        fputc(((y-1)*8.5),dat); */

                    /* cshad */
/*                  i=(x-64); j=(y-64);
                    f=sqrt(i*i+j*j);
                    f=(f-16)/16;
                    if (f<0) f=0; if (f>1) f=1;
                    fputc(f*255,dat); */

                    /* drop */
                    i=(x-64); j=(y-64);
                    f=(sin(sqrt(i*i+j*j)/2)+1)/2;
                    fputc(f*255,dat);

                    /* rand */
/*                  fputc(rand() % 256,dat); */
                    }
    fclose(dat);
    return 0;
    }

