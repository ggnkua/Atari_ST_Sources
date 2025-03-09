/****************************\
* Bitmap mit Farbtabelle als *
* Graphik-Datei speichern    *
* Autor: Gabriel Schmidt     *
* (c)1992 by MAXON-Computer  *
*  -> Programmcode           *
\****************************/

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>

#include "bitmfile.h"

/* --- (X)IMG-Implementation ----------------- */

#define IMG_COMPRESSED

typedef struct
{
   UWORD img_version;
   UWORD img_headlen;
   UWORD img_nplanes;
   UWORD img_patlen;
   UWORD img_pixw;
   UWORD img_pixh;
   UWORD img_w;
   UWORD img_h;
} IMG_HEADER;

typedef enum
   {NONE, SOLID0, SOLID1, BITSTR} IMG_MODE;

typedef UBYTE IMG_SOLID;

typedef struct
{
   UBYTE bs_first;
   UBYTE bs_cnt;
} IMG_BITSTRING;

typedef enum
   {RGB=0, CMY=1, Pantone=2} XIMG_COLMODEL;

typedef struct
{
   ULONG img_ximg;
   XIMG_COLMODEL img_colmodel;
} XIMG_HEADER;

typedef struct RGB XIMG_RGB;

int bitmap_to_img(FILE_TYP typ,
   int ww, int wh,
   unsigned int pixw, unsigned int pixh,
   unsigned int planes, unsigned int colors,
   const char *filename,
   void (*get_color)
      (unsigned int colind, struct RGB *rgb),
   void (*get_pixel)
      (int x, int y, unsigned int *colind))
{
   int file, error, cnt;
   IMG_HEADER header;
   XIMG_HEADER xheader;
   XIMG_RGB xrgb;
   IMG_MODE mode;
   IMG_SOLID solid;
   IMG_BITSTRING bitstring;
   UBYTE *line_buf, *startpnt;
   unsigned int colind, line_len, line, byte, bit;

   /* (X)IMG-Header ausfÅllen */
   header.img_version=1;
   header.img_headlen=(UWORD) sizeof(header)/2;
   if (typ==XIMG)
      header.img_headlen+=(UWORD) (sizeof(xheader)+
         colors*sizeof(xrgb))/2;
   header.img_nplanes=planes;
   header.img_patlen=2;
   header.img_pixw=pixw;
   header.img_pixh=pixh;
   header.img_w=ww;
   header.img_h=wh;
   xheader.img_ximg='XIMG';
   xheader.img_colmodel=RGB;
   /* ZeilenlÑnge best., Puffer allozieren */
   line_len=(ww+7)/8;
   line_buf=malloc((size_t) planes*line_len);
   if (line_buf==NULL)
   {
      return(ENOMEM);
   }
   /* Datei îffnen */
   file=open(filename,O_WRONLY|O_CREAT|O_TRUNC);
   if (file<0)
   {
      error=errno;
      free(line_buf);
      return(error);
   }
   /* Header schreiben */
   if (write(file,&header,sizeof(header))!=
         sizeof(header) || (typ==XIMG &&
         write(file,&xheader,sizeof(xheader))!=
         sizeof(xheader)))
   {
      error=errno;
      close(file);
      free(line_buf);
      return(error);
   }
   /* evtl. Farbtabelle speichern */
   if (typ==XIMG)
      for (cnt=0; cnt<colors; cnt++)
      {
         get_color(cnt,&xrgb);
         if (write(file,&xrgb,sizeof(xrgb))!=
               sizeof(xrgb))
         {
            error=errno;
            close(file);
            free(line_buf);
            return(error);
         }
      }
   bitstring.bs_first=0x80;
   /* Und nun Zeile fÅr Zeile... */
   for (line=0; line<wh; line++)
   {
      /* Pixel abfragen, aufspalten und */
      /* als Planes im Puffer ablegen   */
      for (byte=0; byte<line_len; byte++)
      {
         for (cnt=0; cnt<planes; cnt++)
            line_buf[cnt*line_len+byte]=0x00;
         for (bit=0; bit<8; bit++)
         {
            if (8*byte+bit<ww)
               get_pixel(8*byte+bit,line,&colind);
            for (cnt=0; cnt<planes; cnt++)
            {
               line_buf[cnt*line_len+byte]<<=1;
               line_buf[cnt*line_len+byte]|=
                  colind&0x01;
               colind>>=1;
            }
         }
      }
      /* Bitstrings im Puffer komprimieren */
      /* und in die Datei schreiben        */
      for (cnt=0; cnt<planes; cnt++)
      {
         /* Bitstringzeiger auf Anfang der Plane */
         startpnt=&line_buf[cnt*line_len];
         /* Keine Komprimierung aktiv */
         mode=NONE;
         /* FÅr jedes Byte der Plane... */
         for (byte=0; byte<=line_len; byte++)
         {
            /* öberprÅfen, ob Byte noch in den  */
            /* aktuellen Bitstring passt, sonst */
            /* diesen speichern                 */
            switch (mode)
            {
               case SOLID0:
                  if (line_buf[cnt*line_len+byte]!=
                           0x00 || 
                        &line_buf[cnt*line_len+byte]-
                           startpnt==0x7F ||
                        byte==line_len)
                  {
                     solid=(unsigned int)
                        (&line_buf[cnt*line_len+byte]-
                        startpnt);
                     if (write(file,&solid,1)!=1)
                     {
                        error=errno;
                        close(file);
                        free(line_buf);
                        return(error);
                     }
                     startpnt=
                        &line_buf[cnt*line_len+byte];
                  }
                  break;
               case SOLID1:
                  if (line_buf[cnt*line_len+byte]!=
                           0xFF ||
                        &line_buf[cnt*line_len+byte]-
                           startpnt==0x7F ||
                        byte==line_len)
                  {
                     solid=0x80 | (unsigned int) 
                        (&line_buf[cnt*line_len+byte]-
                        startpnt);
                     if (write(file,&solid,1)!=1)
                     {
                        error=errno;
                        close(file);
                        free(line_buf);
                        return(error);
                     }
                     startpnt=
                        &line_buf[cnt*line_len+byte];
                  }
                  break;
               case BITSTR:
                  if (line_buf[cnt*line_len+byte]==
                           0x00 ||
                        line_buf[cnt*line_len+byte]==
                           0xFF ||
                        &line_buf[cnt*line_len+byte]-
                           startpnt==0xFF ||
                        byte==line_len)
                  {
                     bitstring.bs_cnt=(unsigned int)
                        (&line_buf[cnt*line_len+byte]-
                        startpnt);
                     if (write(file,&bitstring,
                              sizeof(bitstring))!=
                              sizeof(bitstring) ||
                           write(file,startpnt,
                              bitstring.bs_cnt)!=
                              bitstring.bs_cnt)
                     {
                        error=errno;
                        close(file);
                        free(line_buf);
                        return(error);
                     }
                     startpnt=
                        &line_buf[cnt*line_len+byte];
                  }
            }
            /* Welcher Komprimiermodus "passt" */
            /* zum aktuellen Byte?             */
            switch (line_buf[cnt*line_len+byte])
            {
               case 0x00:
                  mode=SOLID0;
                  break;
               case 0xFF:
                  mode=SOLID1;
                  break;
               default:
                  mode=BITSTR;
            }
         }
      }
   }
   /* Datei schlieûen, Puffer freigeben */
   close(file);
   free(line_buf);
   return(0);
}

/* --- Filetyp-Dispatcher -------------------- */

const char *get_file_ext(FILE_TYP typ)
{
   switch (typ)
   {
      case IMG:
      case XIMG:
         return("IMG");
      default:
         return("");
   }
}

int bitmap_to_file(FILE_TYP typ,
   int ww, int wh,
   unsigned int pwx, unsigned int pwy,
   unsigned int planes, unsigned int colors,
   const char *filename,
   void (*get_color)(unsigned int colind,
      struct RGB *rgb),
   void (*get_pixel)(int x, int y,
      unsigned int *colind))
{
   switch (typ)
   {
      case IMG:
      case XIMG:
         return(bitmap_to_img(typ,ww,wh,pwx,pwy,
            planes,colors,filename,
            get_color,get_pixel));
      default:
         return(-1);
   }
}

