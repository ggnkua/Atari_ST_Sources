/****************************************************************
*
* $Id: ifonts.c 1.4 1999/10/22 21:26:58 tbb Exp $
*  
*  ifonts   -- extract font info from all GEM fonts in the current directory
*  check for valid font tables
*  usage: ifonts [arg]
*  where arg is a list of files, default is *.fnt
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unixlib.h>
#include <osbind.h>

#define FALSE (0!=0)
#define TRUE (0==0)
#define HOR_FLAG 0x0002
#define MOT_FLAG 0x0004

/*
 * Internal representation of GDOS font. Author unknown.
 */

typedef struct GFont {
        short   font_id;        /* Font face identifier, 1 -> system font */
        short   size;           /* Font size in points */
        char    name[32];       /* Font name */
        short   first_ade;      /* Lowest ADE value in the face */
        short   last_ade;       /* Highest ADE value in the face */
        short   top;            /* Distance of top line relative to baseline */
        short   ascent;         /* Distance of ascent line relative to baseline */
        short   half;           /* Distance of half line relative to baseline */
        short   descent;        /* Distance of decent line relative to baseline */
        short   bottom;         /* Distance of bottom line relative to baseline */
                                /* All distances are measured in absolute values */
                                /* rather than as offsets. They are always +ve */
        short   max_char_width; /* Width of the widest character in font */
        short   max_cell_width; /* Width of the widest cell character cell in face */
        short   loffset;        /* Left Offset see Vdi appendix G */
        short   roffset;        /* Right offset   "      "     " */
        short   thicken;        /* Number of pixels by which to thicken characters */
        short   ul_size;        /* Width in pixels of the underline */
        short   lighten;        /* The mask used to lighten characters */
        short   skew;           /* The mask used to determine when to perform */
                        /* additional rotation on the character to perform skewing */
        short   flags;          /* Flags */
                                /*  $01 default system font */
                                /*   02 horiz offset table should be used */
                                /*   04 byte-swap flag */
                                /*   08 mono spaced font */
        long    hoff_base;      /* Offset to horizontal offset table */
        long    coff_base;      /* Offset to character offset table */
                /* font bitmap is byte[width][height], width must be even */
        long    form_base;      /* Offset to font data */
        short   form_width;     /* Form width (#of bytes/scanline in font data) */
        short   form_height;    /* Form height (#of scanlines in font data) */
        struct GFont *  next_font;      /* Pointer to next font in face */
} GFont;


#if defined __GNUC__
#define Swapw(v) __asm__( "rorw #8,%0" : "=d" ((unsigned short)(v)) : "0" ((unsigned short)(v)) )
#define Swapl(v) __asm__( "rorw #8,%0; swap %0; rorw #8,%0" \
                           : "=d" ((unsigned long)(v)) : "0" ((unsigned long)(v)) )
#else
#define Swapw(v)        (v) = ((v)<<8) | ((v)>>8)&0x00FF
#define Swapl(v)        { register char t, *vp = (char *)&(v); \
                          t = vp[0]; vp[0] = vp[3]; vp[3] = t; \
                          t = vp[1]; vp[1] = vp[2]; vp[2] = t; }
#endif

typedef unsigned short WORD;

char errstr[64];
GFont hdr;
unsigned int coff_tbl[256];
int hoff_tbl[256];
struct _dta  *dtap;

static void check_files( const char *file_name )
{
int fd;
int is_mot;
long file_size;
int nch;
long x;
int coff_size, hoff_size;
register int i;

   if (Fsfirst( file_name, 0) == 0) {
      do {
         if( (fd = open( dtap->dta_name, 2, 0 )) < 0) {
            sprintf( errstr, "can't open %s", dtap->dta_name );
            perror( errstr );
            continue;
         } /* if */
   
         /* read file header */
         if( read(fd, &hdr, sizeof(hdr) ) != sizeof(hdr) ) {
            sprintf( errstr, "error reading %s", dtap->dta_name );
            perror( errstr );
            close( fd );
            continue;
         } /* if */
        
         is_mot = (hdr.flags&MOT_FLAG) != 0;
        
         if (!is_mot) {

            /* swap header words and longs */
            Swapw(hdr.font_id);              Swapw(hdr.size);
            Swapw(hdr.first_ade);            Swapw(hdr.last_ade);
            Swapw(hdr.top);                  Swapw(hdr.ascent);
            Swapw(hdr.half);                 Swapw(hdr.descent);
            Swapw(hdr.bottom);
            Swapw(hdr.max_char_width);       Swapw(hdr.max_cell_width);
            Swapw(hdr.loffset);              Swapw(hdr.roffset);
            Swapw(hdr.thicken);              Swapw(hdr.ul_size);
            Swapw(hdr.flags);                Swapl(hdr.hoff_base);
            Swapl(hdr.coff_base);            Swapl(hdr.form_base); 
            Swapw(hdr.form_width);           Swapw(hdr.form_height);
            hdr.flags |= MOT_FLAG;
            
         } /* if */
         
         printf( "%s: \"%.32s\" at %d pts, id is %d\n",
                  dtap->dta_name, hdr.name, hdr.size, hdr.font_id );
                  
         if( hdr.max_char_width > hdr.max_cell_width ) {
            printf( "error: max char width is larger than max cell width\n" );
         } /* if */

         nch = hdr.last_ade - hdr.first_ade + 1;
         if( nch <= 0 ) printf( "warning: last ADE <= first ADE\n" );
         if( hdr.last_ade > 255 ) printf( "warning: last ade is %d\n", hdr.last_ade );
         if( hdr.first_ade < 32 ) printf( "warning: first ade is %d\n", hdr.first_ade );

         /* read & check char offset tbl */
         coff_size = sizeof(int)*(nch+1);
         if( lseek( fd, hdr.coff_base, SEEK_SET ) > 0 ) {
            if( read(fd, coff_tbl, coff_size) != coff_size ) {
               sprintf( errstr, "error reading character offset table in %s", dtap->dta_name );
               perror( errstr );
            }
            else {
	       if( !is_mot ) {
		  for( i=0; i<=nch; i++ ) {
		       Swapw(coff_tbl[i]);
		  } /* for */
	       } /* if */

               if( coff_tbl[nch] > (hdr.form_width*8) ) {
                  printf( "error: last char offset extends past form Width\n" );
                  printf( "offset for last character is %d, formWidth is %d\n", coff_tbl[nch], hdr.form_width*8 );
               }
               else if( coff_tbl[nch]+15 < (hdr.form_width*8) ) {
                  printf( "warning: form Width too large\t" );
                  printf( "offset for last character is %d, formWidth is %d\n", coff_tbl[nch], hdr.form_width*8 );
               } /* if */
                                      
               if( coff_tbl[0] != 0 ) {
                  printf( "font format error: char offset table must start with zero entry\n" );
               } /* if */

               for( i=hdr.first_ade; i<=hdr.last_ade; i++ ) {
               int cell_wid = coff_tbl[i-hdr.first_ade+1] - coff_tbl[i-hdr.first_ade];
                  if( cell_wid < 0 ) {
                     printf( "font format error: character %c (%d) has -ve width\n", i, i );
                  } /* if */
                  if( cell_wid > hdr.max_cell_width ) {
                     printf( "font format error: character %c (%d) has width (%d) greater than max cell width (%d)\n", i, i, cell_wid, hdr.max_cell_width );
                  } /* if */
               } /* for */
            } /* if */
         } /* if */

         file_size = dtap->dta_size;
         
         if( hdr.coff_base < sizeof(GFont) ) {
            printf( "warning: character offset table overlaps header\n" );
         } /* if */
         if( hdr.form_base < sizeof(GFont) ) {
            printf( "warning: font data table overlaps header\n" );
         } /* if */

         if( (hdr.flags&HOR_FLAG) != 0 ) {
            printf( "this font has a horizontal offset table\n" );

            if( hdr.hoff_base < sizeof(GFont) ) {
               printf( "warning: horizontal offset table overlaps header\n" );
            } /* if */

            /* read & check char hoffset tbl */
            hoff_size = sizeof(int)*nch;
            if( lseek( fd, hdr.hoff_base, SEEK_SET ) > 0 ) {
               if( read(fd, hoff_tbl, hoff_size) != hoff_size ) {
                  sprintf( errstr, "error reading horizontal offset table in %s", dtap->dta_name );
                  perror( errstr );
               }
               else {
		  if( !is_mot ) {
		     for( i=0; i<nch; i++ ) {
		        Swapw(hoff_tbl[i]);
		     } /* for */
		  } /* if */

                  for( x = 0, i=hdr.first_ade; i<=hdr.last_ade; i++ ) {
                     x |= hoff_tbl[i-hdr.first_ade];
                  } /* for */
                  if( x==0 ) {
                        printf( "warning: horizontal offset table is all zeros\n" );
                     } /* if */
               } /* if */
            } /* if */

            if( (hdr.coff_base > hdr.form_base) && (hdr.coff_base > hdr.hoff_base) ) {
               if( hdr.coff_base + coff_size >= file_size )
                  printf( "warning: character offset table extends beyond end of file\n"
                        "coff_base is %ld\n", hdr.coff_base );
               if( hdr.hoff_base > hdr.form_base ) {
                  if( hdr.form_base + (long)hdr.form_width*hdr.form_height > hdr.hoff_base )
                     printf( "warning: data table extends into horizontal offset table\n"
                           "data table starts at %ld, size is %ld, form width is %d, form height is %d\n",
                           hdr.form_base, (long)hdr.form_width*hdr.form_height, hdr.form_width, hdr.form_height );
               }
               else {
                  if( hdr.hoff_base + hoff_size > hdr.form_base )
                     printf( "warning: horizontal offset table extends into font data\n"
                           "data table starts at %ld, size is %ld, form width is %d, form height is %d\n",
                           hdr.form_base, (long)hdr.form_width*hdr.form_height, hdr.form_width, hdr.form_height );
               } /* if */
            }
            else if( (hdr.form_base > hdr.coff_base) && (hdr.form_base > hdr.hoff_base) ) {
               if( hdr.form_base + (long)hdr.form_width*hdr.form_height > file_size )
                  printf( "warning: data table extends beyond end of file\n"
                        "file size is %ld, data table starts at %ld, size is %ld, form width is %d, form height is %d\n",
                        file_size, hdr.form_base, (long)hdr.form_width*hdr.form_height, hdr.form_width, hdr.form_height );

               if( hdr.coff_base > hdr.hoff_base ) {
                  if( hdr.coff_base + coff_size > hdr.form_base )
                     printf( "warning: character offset table extends into font data\n"
                           "coff_base is %ld, length is %d, data starts at %ld\n", hdr.coff_base, coff_size, hdr.form_base );
                  if( hdr.hoff_base + hoff_size > hdr.coff_base )
                     printf( "warning: horizontal offset table extends into character offset table\n"
                           "coff_base is %ld, length is %d, data starts at %ld\n", hdr.coff_base, coff_size, hdr.form_base );
               }
               else { /* horizontal offset table follows char offset table */
                  if( hdr.hoff_base + hoff_size > hdr.form_base )
                     printf( "warning: horizontal offset table extends into font data\n"
                           "hoff_base is %ld, length is %d, data starts at %ld\n", hdr.hoff_base, hoff_size, hdr.form_base );
                  if( hdr.coff_base + coff_size > hdr.hoff_base )
                     printf( "warning: character offset table extends into horizontal offset table\n"
                           "coff_base is %ld, length is %d, hoff_base is %ld\n", hdr.coff_base, coff_size, hdr.hoff_base );
               } /* if */
            } /* if */
         }
         else {  /* no horizontal offset table ... */
            if( hdr.coff_base > hdr.form_base ) {
               if( hdr.coff_base + coff_size >= file_size )
                  printf( "warning: character offset table extends beyond end of file\n"
                        "coff_base is %ld\n", hdr.coff_base );
               if( hdr.form_base + (long)hdr.form_width*hdr.form_height > hdr.coff_base )
                  printf( "warning: data table extends into character offset table\n"
                        "data table starts at %ld, size is %ld, form width is %d, form height is %d\n",
                        hdr.form_base, (long)hdr.form_width*hdr.form_height, hdr.form_width, hdr.form_height );
            } 
            else {
               if( hdr.form_base + (long)hdr.form_width*hdr.form_height > file_size )
                  printf( "warning: data table extends beyond end of file\n"
                        "file size is %ld, data table starts at %ld, size is %ld, form width is %d, form height is %d\n",
                        file_size, hdr.form_base, (long)hdr.form_width*hdr.form_height, hdr.form_width, hdr.form_height );
               if( hdr.coff_base + coff_size > hdr.form_base )
                  printf( "warning: character offset table extends into font data\n"
                        "coff_base is %ld, length is %d, data starts at %ld\n", hdr.coff_base, coff_size, hdr.form_base );
            } /* if */
         } /* if */
            
         close(fd);

      } while (Fsnext() == 0);
   }
   else {
      printf( "no '%s' font files found\n", file_name );
   } /* if */

} /* check_files() */


/******************
* scan thru arg list, call check func for each arg
* default to *.fnt if no args
*/
int main( int argc, char *argv[] )
{

   dtap = (struct _dta*)Fgetdta();
   if( argc == 1 ) check_files( "*.fnt" );
   else {
      while( --argc>0 ) check_files(*++argv);
   } /* if */

   Cconws( "finished! press a key ..." );   
   while( Cconis() == 0 );
   (void)Cconin();

   return 0;
     
} /* main() */

/********************** end of ifonts.c *************************/

