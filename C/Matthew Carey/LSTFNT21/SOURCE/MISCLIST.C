#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <osbind.h>
#include <aes.h>
#include <linea.h>

#include "listfont.h"

void bswap(char *p, int len);
long wswap(long);

#define __SWAP_D0 "4840"

#pragma inline d0=wswap(d0) {register d0; __SWAP_D0; }


/* speedo stuff */
/***** PUBLIC FONT HEADER OFFSET CONSTANTS  *****/
#define  FH_FMVER    0      /* U   D4.0 CR LF NULL NULL  8 bytes            */
#define  FH_FNTSZ    8      /* U   Font size (bytes) 4 bytes                */
#define  FH_FBFSZ   12      /* U   Min font buffer size (bytes) 4 bytes     */
#define  FH_CBFSZ   16      /* U   Min char buffer size (bytes) 2 bytes     */
#define  FH_HEDSZ   18      /* U   Header size (bytes) 2 bytes              */
#define  FH_FNTID   20      /* U   Source Font ID  2 bytes                  */
#define  FH_SFVNR   22      /* U   Source Font Version Number  2 bytes      */
#define  FH_FNTNM   24      /* U   Source Font Name  70 bytes               */
#define  FH_MDATE   94      /* U   Manufacturing Date  10 bytes             */
#define  FH_LAYNM  104      /* U   Layout Name  70 bytes                    */
#define  FH_CPYRT  174      /* U   Copyright Notice  78 bytes               */
#define  FH_NCHRL  252      /* U   Number of Chars in Layout  2 bytes       */
#define  FH_NCHRF  254      /* U   Total Number of Chars in Font  2 bytes   */


typedef struct {
        char    cal_id[10];
        unsigned short unknown1[8];
        unsigned short add_space;
        
        unsigned short label1;                 /* strings */ 
        unsigned short font_name_len;
        char    font_name[26];  /* end 0 */
        unsigned short creator_len;
} CALHEAD;

typedef struct {
     short id;
     short size;
     char  name[32];
} GEMHEAD;

int postList(char *fontname,char *node,size_t size, FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[90];
     char *buff, *ptr, *end;
     unsigned char head[6];
     int c;

     ffp = fopen (fontname,"rb");

      if (!ffp) return 0;

      if (fread (head,1,6,ffp)<6)
      {
                fclose(ffp);
                return 0;
      }

/* As this is for GhostScript the fonts must be PC specific */          
/* Mac Fonts fail here and PC fonts give length of text part */
/* of the font (see Adobe Techical Note #5020) */
 
     if (head[0] != 128 || head[1] != 1)
     {
          fclose(ffp);           
          return 0;
     }
     size=intel_long((unsigned char *)&head[2]);
     if (size < 10 || size > 500000) 
     {
          fclose(ffp);           
          return 0;
     }
     buff = (unsigned char *)calloc((size_t)size,1);
     if (!buff)
     {
          form_alert(1,"[1][Couldn't allocate |enough memory][Ok]");
          return (1);
     }

     if (fread (buff,1,size,ffp)<size)
     {
          free(buff);
          fclose(ffp);
          return 0;
     }
     fclose (ffp);

     end=&buff[size];

     ptr=memsearch(buff,"%!FontType1",9,end);
     if (!ptr)
     {
          ptr=memsearch(buff,"%!PS-",4,end);
     }
     if (!ptr)
     {
          free(buff);
          return 0;
     }
     ptr=memsearch(buff,"eexec",5,end);
     if (!ptr)
     {
          free(buff);
          return 0;
     }

     ptr=memsearch(buff,"/FontName",9,end);
     if (ptr)
     {
          ptr++;
          while (*ptr != '/')ptr++;
          for (c=0;c<100 && ptr[c]>' ';c++) font_name[c]=ptr[c];
          font_name[c]=0;
     }
     else
     {
          free(buff);
          return 0;
     }

     print_to_list(fpList, fontname, node, &font_name[1],  mode);

     free(buff);
     return 0;
}

int ghostList(char *fontname,char *node,size_t size,FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[90];
     char *buff, *ptr, *end;
     int c;

     ffp = fopen (fontname,"rb");

     if (!ffp) return 0;

     buff = (unsigned char *)calloc((size_t)size,1);
     if (!buff)
     {
          form_alert(1,"[1][Couldn't allocate |enough memory][Ok]");
          return (1);
     }

     if (fread (buff,1,size,ffp)<size)
     {
          free(buff);
          fclose(ffp);
          return 0;
     }
     fclose (ffp);

     for (c=0;c<60;c++) 
          font_name[c]=0;


     end=&buff[size];

/*
     ptr=memsearch(buff,"%!FontType1",9,end);
     if (!ptr)
     {
          free(buff);
          return 0;
     }
*/

     ptr=memsearch(buff," MakeHersheyFont",13,end);
     if (ptr)
     {
          while (ptr > buff && *ptr != '/')ptr--;
          if (*ptr=='/')
          {

               for (c=0;c<90 && ptr[c]>' ';c++) 
                    font_name[c]=ptr[c];
               font_name[c]=0;
               if (c)
                    print_to_list(fpList, fontname, node, &font_name[1],  mode);

               free(buff);
               return 0;
          }
     }
     ptr=memsearch(buff,"/FontName",9,end);
     if (ptr)
     {
          ptr += 9;
          while (*ptr != '(' && *ptr != '/' && *ptr != 'e')ptr++;
          if (ptr[0]=='e' && ptr[1]=='x' && ptr[2]=='c' && ptr[3]=='h')
          {
                ptr=memsearch(ptr,"/FontName",9,end);
                if (ptr)
                {
                     ptr += 9;
                     while (*ptr != '(' && *ptr != '/')ptr++;
                }
                else
                {
                     free(buff);
                     return 0;
                }
          }
          for (c=0;c<100 && ptr[c]!=')' && ptr[c]!=' ';c++) 
               font_name[c]=ptr[c];
          font_name[c]=0;
     }
     else
     {
          free(buff);
          return 0;
     }

     print_to_list(fpList, fontname, node, &font_name[1],  mode);

     free(buff);
     return 0;

}

int post3List(char *fontname,char *node,size_t size, FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[90];
     char *buff, *ptr, *end, test[500];
     int c;

     ffp = fopen (fontname,"rb");

     if (!ffp) return 0;

     fread (test,1,500,ffp);

     ptr=memsearch(test,"/FontType 3 def",14, &test[500]);

     if (!ptr)
     {
          return 0;
     }


     rewind(ffp);



     buff = (unsigned char *)calloc((size_t)size,1);
     if (!buff)
     {
          form_alert(1,"[1][Couldn't allocate |enough memory][Ok]");
          return (1);
     }

     if (fread (buff,1,size,ffp)<size)
     {
          free(buff);
          fclose(ffp);
          return 0;
     }
     fclose (ffp);

     for (c=0;c<60;c++) 
          font_name[c]=0;


     end=&buff[size];

     ptr=&buff[ptr-test];


     ptr=memsearch(ptr,"exch definefont pop",13,end);
     if (ptr)
     {
          while (ptr > buff && *ptr != '/')ptr--;
          if (*ptr=='/')
          {

               for (c=0;c<90 && ptr[c]>' ';c++) 
                    font_name[c]=ptr[c];
               font_name[c]=0;
               if (c)
                    print_to_list(fpList, fontname, node, &font_name[1],  mode);
          }
     }
     free(buff);
     return 0;

}


int calamusList(char *fontname,char *node,size_t size,FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[90];
     CALHEAD calh;


     ffp = fopen (fontname,"rb");

     if (!ffp) return 0;

     if (fread (&calh,1,sizeof(calh),ffp)<sizeof(calh))
     {
          fclose(ffp);
          return 0;
     }
     fclose(ffp);
     if (strncmp(calh.cal_id,"CALAMUSCFN",9))
          return 0;
     strncpy(font_name, calh.font_name, min(25,calh.font_name_len));
     font_name[25]=0;
     font_name[calh.font_name_len]=0;

     print_to_list(fpList, fontname, node, font_name,  mode);
     return 0;
}

int caligList(char *fontname,char *node,size_t size,FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[0x30];
     char buff[0x30];

     ffp = fopen (fontname,"rb");

     if (!ffp) return 0;

     if (fread (buff,1,0x30,ffp)<0x30)
     {
          fclose(ffp);
          return 0;
     }
     fclose(ffp);

     strncpy(font_name,&buff[4],0x30-5);

     print_to_list(fpList, fontname, node, font_name,  mode);

     return 0;
}

int dmfList(char *fontname,char *node,size_t size,FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[0x70];
     char buff[0x70];
     char *ptr;
     
     for (ptr=fontname;*ptr;ptr++);
     ptr -= 3;
     strcpy(ptr,"fm");
     
     ffp = fopen (fontname,"rb");

     if (!ffp) return 0;

     if (fread (buff,1,0x70,ffp)<0x70)
     {
          fclose(ffp);
          return 0;
     }
     fclose(ffp);

     strncpy(font_name,&buff[0x10],0x50);
   
     print_to_list(fpList, fontname, node, font_name,  mode);
     return 0;
}


int speedoList(char *fontname,char *node,size_t size,FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[90];
     char spheader[106];

     ffp = fopen (fontname,"rb");

     if (!ffp) return 0;

     fread (spheader,FH_LAYNM,1,ffp);

     fclose(ffp);

     if (spheader[0] != 'D' || spheader[4] != '\r' ||  
          spheader[5] != '\n' || spheader[6] || spheader[7]) 
          return 0;

     strncpy (font_name,&spheader[FH_FNTNM],FH_MDATE-FH_FNTNM);

     font_name[FH_MDATE-FH_FNTNM]=0;

     print_to_list(fpList, fontname, node, font_name,  mode);

     return 0;
}

int cgList(char *fontname,char *node,size_t size,FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[90];
     char *cgfont,*buff;
     char test[8];
     short c;

     test[0]=0;
     test[1]=0x6B;
     test[2]=0;
     test[3]=0;
     test[4]=0;
     test[5]=0x6E;
     test[6]=0;
     test[7]=0x01;

     cgfont = (unsigned char *)calloc((size_t)size,1);
     if (!cgfont)
     {
          form_alert(1,"[1][Couldn't allocate |enough memory][Ok]");
          return (1);
     }


     ffp = fopen (fontname,"rb");

     if (!ffp) return 0;

     fread (cgfont,size,1,ffp);

     fclose(ffp);

     buff=memsearch(cgfont,"COMPUGRAPHIC",12,&cgfont[size]);

     if (buff)
          buff=memsearch(buff,test,8,&cgfont[size]);

     if (buff) 
     {
          buff+=8;

          for(c=0;buff[c]>31 && !(buff[c]==' ' && buff[c+1]==' ') && c<90 ;c++)
               font_name[c]=buff[c];

          font_name[c]=0;

          print_to_list(fpList, fontname, node, font_name,  mode);
     }
     free(cgfont);
     return 0;
}

void bswap(char *p, int len)
{
        register unsigned short *wp;

/* make word pointer wp point to an even byte */
        wp=(unsigned short *)((unsigned long)p & ~0x01);

/* halve the value of len */
        len >>=1;

/* swap the bytes */
        while (len--)
        {
                *wp = (*wp >> 8) | (*wp << 8);
                *wp++;
        }
}

int GEMList(char *fontname,char *node,size_t size,FILE *fpList, short mode)
{
     FILE *ffp;
     char font_name[35];
     LA_FONT *gh;
/*
     long bits;
     char str[50];
*/
     short nchars,hotlen,cotlen;

     
     if (size < sizeof(LA_FONT)) return 0;
     ffp = fopen (fontname,"rb");

     if (!ffp) return 0;

     
     gh=(LA_FONT *)malloc(size);;

     if (!gh) 
     {
          form_alert(1,"[1][Memory allocation error][OK]");
          fclose(ffp);
          return 1;
     }
     fread (gh,size,1,ffp);

     fclose(ffp);

     if (!(gh->font_flags & 4))
     {
          gh->font_horiz_off = (short *) wswap((long)gh->font_horiz_off);

          gh->font_char_off = (short *) wswap((long)gh->font_char_off);

          gh->font_data = (char *) wswap((long)gh->font_data);

          bswap((char *)gh,4);

          bswap((char *) (&gh->font_low_ade),52);

          if (gh->font_hi_ade > 255 || gh->font_hi_ade < 0 ||
               gh->font_low_ade < 0 || gh->font_low_ade > 255 ||
               gh->font_low_ade > gh->font_hi_ade) 
          {
               free(gh); 
               return 0;
          }

               
               
          nchars=gh->font_hi_ade - gh->font_low_ade + 1;


          hotlen=(gh->font_flags & 2) ? nchars * 2 : 0;
          if (hotlen > size-sizeof(LA_FONT) || hotlen < 0)
          {
               free(gh); 
               return 0;
          }
          cotlen=(nchars + 1) * 2;
          if (cotlen > size-(sizeof(LA_FONT)+hotlen || cotlen < 0))
          {
               free(gh); 
               return 0;
          }

          if (hotlen)
          {
               bswap((char *)gh + (long)gh->font_horiz_off,hotlen);

          }

          bswap((char *)gh + ((unsigned long)gh->font_char_off),cotlen);

     }
     if (gh->font_hi_ade < gh->font_low_ade) 
     {
          free(gh); 
          return 0;
     }
     if ((unsigned long)gh->font_horiz_off & 1) 
     {
          free(gh); 
          return 0;
     }
     if ((unsigned long)gh->font_horiz_off+hotlen > size) 
     {
          free(gh);
          return 0;
     }
     if ((unsigned long)gh->font_char_off & 1) 
     {
          free(gh); 
          return 0;
     }
     if ((unsigned long)gh->font_char_off+cotlen > size) 
     {
          free(gh);
          return 0;
     }
     if ((unsigned long)gh->font_data & 1) {free(gh); return 0;}
     
     gh->font_horiz_off = (short *)(
                    (unsigned long)gh->font_horiz_off + (unsigned long)gh);
     gh->font_char_off = (short *)(
                    (unsigned long)gh->font_char_off + (unsigned long)gh);
     gh->font_data = (void *)(
                    (unsigned long)gh->font_data + (unsigned long) gh);


     strncpy (font_name,gh->font_name,32);

     font_name[32]=0;

     print_to_list(fpList, fontname, node, font_name,  mode);

     free(gh); 
     return 0;
}


