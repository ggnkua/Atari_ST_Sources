/****************************************************************
*
* $Id: mot2int.c 1.2 1999/10/22 21:40:02 tbb Exp tbb $
* int2mot   -- convert font files from intel to motorola format
*  
*  it converts all fonts in the current directory
*  usage: int2mot [arg]
*  where arg is a list of files, default is *.fnt
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unixlib.h>
#include <osbind.h>

#define FALSE (0!=0)
#define TRUE (0==0)
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
static struct _dta  *dtap;
static int   do_all_flag = FALSE;

static void convert_files( const char file_name[] )
{
int fd, i, nr_entries;
WORD *char_tbl;
int is_mot;
GFont hdr;
register WORD* fp;
long  size;
char  out_str[128];
int convert_flag;
   
   if (Fsfirst( file_name, 0) == 0) {
      do {
         if( (fd = open( dtap->dta_name, 2, 0 )) < 0) {
	    printf( "can't open %s\n", dtap->dta_name );
	    exit(-1);
	 } /* if */
   
	 /* read file */
	 if( lread(fd, &hdr, sizeof(hdr) ) != sizeof(hdr) ) {
	    printf( "error reading  %s\n", dtap->dta_name );
	    exit(-1);
	 } /* if */
        
	 is_mot = hdr.flags&MOT_FLAG;
        
	 if (!is_mot) {
	 int query_flag;
	    if( !do_all_flag) {
	       sprintf( out_str, "convert %s ? (Yes/No/All/Quit) ... ", dtap->dta_name );
	       write( 1, out_str, strlen(out_str) );
	       query_flag = FALSE;
	       do {
	       char ch;
		  read(0, &ch, 1); /* stdin */
		  switch( ch ) {
		  case 'A':
		  case 'a': do_all_flag = TRUE;
		  case 'Y':
		  case 'y': convert_flag = TRUE;
			    break;
		  case 'N':
		  case 'n': printf( "\bskipped\n" );
			    convert_flag = FALSE;
			    break;
		  case 'Q':
		  case 'q': exit(0);
		  default:
			    query_flag = TRUE;
	                    write( 1, "\b\a", 2 );
		  } /* switch */
	       } while( query_flag );
	    } /* if */

	    /* swap header words and longs */
	    if( convert_flag ) {
	       printf( "\rconverting %s\n", dtap->dta_name );
	       Swapw(hdr.font_id);		Swapw(hdr.size);
	       Swapw(hdr.first_ade);		Swapw(hdr.last_ade);
	       Swapw(hdr.top);			Swapw(hdr.ascent);
	       Swapw(hdr.half); 		Swapw(hdr.descent);
	       Swapw(hdr.bottom);
	       Swapw(hdr.max_char_width);	Swapw(hdr.max_cell_width);
	       Swapw(hdr.loffset);		Swapw(hdr.roffset);
	       Swapw(hdr.thicken);		Swapw(hdr.ul_size);
	       Swapw(hdr.flags);		Swapl(hdr.hoff_base);
	       Swapl(hdr.coff_base);		Swapl(hdr.form_base); 
	       Swapw(hdr.form_width);		Swapw(hdr.form_height);
	       hdr.flags |= MOT_FLAG;
	       
	       lseek( fd, 0, 0 );
	       if( lwrite(fd, &hdr, sizeof( hdr) ) != sizeof( hdr) ) {
	          printf( "error writing %s\n", dtap->dta_name );
		  exit(-1);
	       } /* if */
   
	       nr_entries = hdr.last_ade - hdr.first_ade + 2;
	       size = nr_entries * sizeof(WORD);
      
	       fp = (WORD*)malloc( size );
	       if (fp == NULL) {
		  printf( "not enough memory to load %s\n", dtap->dta_name );
		  exit(-1);
	       } /* if */
	 
	       lseek( fd, hdr.coff_base, 0 );
	       /* read file */
	       if( lread(fd, fp, size ) != size ) {
		  printf( "error reading  %s\n", dtap->dta_name );
		  exit(-1);
	       } /* if */

	       /* convert char wid table */
	       char_tbl = fp;
	       for (i = nr_entries; i > 0; i--) {
		    Swapw(*char_tbl);
		    char_tbl++;
	       } /* for */
	       lseek( fd, hdr.coff_base, 0 );
	       if( lwrite(fd, fp, size) != size) {
	          printf( "error writing %s\n", dtap->dta_name );
		  exit(-1);
	       } /* if */
	       free(fp);
	       lseek( fd, 0, 2 );
	    } /* if */
	 }
	 else {
	 printf( "%s is already motorola format\n", dtap->dta_name );
	 } /* if */	   

	 close(fd);
      } while (Fsnext() == 0);
   }
   else {
      printf( "no '%s' font files found\n", file_name );
   } /* if */

} /* convert_files() */


/******************
* scan thru arg list, call convert func for each arg
* default to *.fnt if no args
*/
int main( int argc, char *argv[]  )
{

   dtap = (struct _dta*)Fgetdta();
   if( argc == 1 ) convert_files( "*.fnt" );
   else {
      while( --argc>0 ) convert_files(*++argv);
   } /* if */
   
   Cconws( "finished! press a key ..." );   
   while( Cconis() == 0 );
   (void)Cconin();

   return 0;
     
} /* main_font() */

/********************** end of int2mot.c *************************/

