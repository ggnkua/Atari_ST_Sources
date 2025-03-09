/* C-Routine: enlarge() (w) 1991 by M. Kraus
                        (c) 1991 MAXON Computer 
   Zweck    : Vergrîssert eine beliebige Bitmap 
   Parameter: x1,y1,x2,y2: siehe #define-Zeilen    
              src,dst: Adresse von Quell- und 
              Ziel-Bitmap, mÅssen existieren   */

#include <stdio.h> 
#include <string.h>
#include <tos.h>

#define  X1  20  /* Quellbitmapbreite in Bytes */
#define  Y1  40      /* ... und Hîhe in Zeilen */
#define  X2  60   /* Zielbitmapbreite in Bytes */
#define  Y2  120     /* ... und Hîhe in Zeilen */

void enlarge(int x1,int y1,int x2,int y2,
             char *src,char *dst);

int main()  /* Demo fÅr normale 640*400 Pixel: */
{  /* Eine Bitmap wird vergrîssert und gezeigt */
  int i,j;
  char src[X1*Y1],dst[X2*Y2];   /* Die Bitmaps */
  char *c;            /* Zeiger auf Bildschirm */
  
  c=(char*)Logbase();     /* Bildschirmadresse */
  for(i=0;i<X1*Y1;src[i++]=i&255);   /* Quell- */
                   /* Bitmap mit Muster fÅllen */
  enlarge(X1,Y1,X2,Y2,src,dst); /* Vergrîssern */

  for(i=0;i<Y1;i++)      /* Quellbitmap zeigen */
    for(j=0;j<X1;c[i*80+j+2000]=src[i*X1+j],j++);
  for(i=0;i<Y2;i++)       /* Zielbitmap zeigen */
    for(j=0;j<X2;c[i*80+j+8000]=dst[i*X2+j],j++);

  getchar();
  return 0;
}

void enlarge(int x1,int y1,int x2,int y2, 
             char *src,char *dst)
{
  int h,i,j,k,a,i2,j2;

  memset(dst,0,x2*y2);   /* Zielbitmap lîschen */
                           /* X-Vergrîsserung: */  
  for(i=x2-1;i>=0;i--)       /* Bytes und Bits */
    for(k=i<<3,j=7;j>=0;j--)     /* durchgehen */
    { 
      a=(int)((long)(k+j)*x1/x2); /* Umrechnen */
      for(i2=a>>3,j2=a&7,h=0;h<y1;h++)
        if((src[i2+h*x1]>>(7-j2))&1) /* Bits.. */
          dst[i+h*x2]|=1<<(7-j);  /* schreiben */
    }
                           /* Y-Vergrîsserung: */
  for(i=y2-1;i>=0;i--)      /* Zeilen kopieren */
    memcpy(dst+i*x2,dst+i*y1/y2*x2,x2);
}
