/*******************************************

tv6.c - test with 2 separate virtual workstations
        each has different attributes

*  $Id: tv6.c 3276 2021-08-29 16:35:41Z trevor $
*******************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <osbind.h>
#include <aesbind.h>
#include <vdibind.h>
#include <sysvars.h>

#define QUIET 1
#define dprintf QUIET ? (void)(0) : (void)printf

FILE *fout;
int work_in[80];
int work_out[80];
int pxyarray[26];

volatile void quit( char *msg)
{
     printf( "%s - quitting.   Press a key ...\n", msg );
     (void)Cnecin();
     exit(-1);
} /* quit() */


int main(void) {
int wkstn1, wkstn2;
int ghandle;
long wid1, height1;
long wid2, height2;
int junk;

int swiss_pts, dutch_pts;
int swiss_index, dutch_index;
char swiss_name[33], dutch_name[33];
char text[100];

int i;

int r;
time_t tp;

   fout = fopen("tv6.log", "w");
   if( setvbuf( fout, NULL, _IOLBF, 128 ) != 0 ) {
      fprintf( stderr, "can't buffer tv1.out correctly\n" );
   } /* if */
   tp = time(NULL);
   fprintf( fout, __FILE__ " gdos tests,  %s\n", ctime(&tp) );

   fprintf( fout, "%d: TOS version: %0x  gdos version: ", (int)__LINE__,
            ((OSHEADER *)get_sysvar(_sysbase))->os_version );
   switch( vq_vgdos() ) {
   case -2:
      fprintf( fout, "gdos not installed!!\n" );
      fprintf( stderr, "%d: gdos not installed!!\n", (int)__LINE__ );
      exit(-1);
   case 0x0007E88A:
        fprintf( fout, "GDOS 1.1 from Atari Corp\n" );
        break;
   case 0x0007E864:
        fprintf( fout, "AMC-GDOS from Arnd Beissner\n" );
        break;
   case 0x0007E8BA:
        fprintf( fout, "GEMINI-special GDOS from Arnd Beissner\n" );
        break;
   case 0x5F464E54:  /* '_FNT' */
        fprintf( fout, "FONTGDOS\n" );
        break;
   case 0x5F46534D:  /* '_FSM' */
        fprintf( fout, "FSMGDOS\n" );
        break;
   case 0x66564449:  /* 'fVDI' */
        fprintf( fout, "fVDI\n" );
        break;
    default :    {
         long *p = (long *)vq_vgdos();
         if( ((int)p&1) == 0
               && p <= (long *)get_sysvar(phystop)
               && p >= (long *)0x800 /* bot of mem */
               && *p == 0x3e5d0957L )

              fprintf( fout, "ttf-gdos\n" );
         else
              fprintf( fout, "GDOS 1.0 or 1.2, vq_vgdos() is %08lx\n", vq_vgdos() );
      }
   } /* switch */

   ghandle = graf_handle(&junk, &junk, &junk, &junk );
   fprintf(fout, "graf handle is %d\n", ghandle);

   ghandle = 0;

   /* open 1st vwkstn */
   work_in[0] = Getrez() + 2;    /* physical device id */
   work_in[1] = 1;               /* line type := solid */
   work_in[2] = 1;               /* line colour */
   work_in[3] = 1;               /* marker type */
   work_in[4] = 1;               /* marker colour */
   work_in[5] = 14;              /* font id := dutch (serif) */
   work_in[6] = 1;               /* text colout */
   work_in[7] = 2;               /* fill interior, 2 = pattern */
   work_in[8] = 14;              /* fill style */
   work_in[9] = 1;               /* fill colour */
   work_in[10] = 0;              /* 0 = NDC coords */
   wkstn1 = ghandle;
   v_opnvwk(work_in, &wkstn1, work_out);
   if( wkstn1 <= 0 ) {
        quit( "could not open workstation 1" );
   } /* if */

   wid1 = work_out[0];          /* if raster coords */
   height1 = work_out[1];
   fprintf(fout,  "wkstn 1 handle is %d width is %d, height is %d \n", wkstn1, work_out[0], work_out[1] );
   switch ( work_in[10] ) {
   case 0: {
        fprintf(fout, "wkstn1 is ndc coords\n");
        wid1 = 32767;          /* NDC coords */
        height1 = 32767;
        break;
   }
   case 2: {
        fprintf(fout, "wkstn1 is raster coords\n");
        break;
   }
   default:
        fprintf(fout, "wkstn1 coord system is unknown\n");
   } /* switch */

   /* open 2nd vwkstn */
   work_in[0] = Getrez() + 2;    /* physical device id */
   work_in[1] = 4;               /* line type := dash dot */
   work_in[2] = 1;               /* line colour */
   work_in[3] = 1;               /* marker type */
   work_in[4] = 1;               /* marker colour */
   work_in[5] = 2;               /* font 2 := swiss (sans serif) */
   work_in[6] = 1;               /* text colout */
   work_in[7] = 0;               /* fill interior, 0 = hollow */
   work_in[8] = 1;               /* fill style */
   work_in[9] = 1;               /* fill colour */
   work_in[10] = 2;              /* 2 = raster coords */
   wkstn2 = ghandle;
   v_opnvwk(work_in, &wkstn2, work_out);
   if( wkstn2 <= 0 ) {
      quit( "could not open workstation 2" );
   } /* if */

   wid2 = work_out[0];
   height2 = work_out[1];
   fprintf( fout, "wkstn 2 handle is %d, width is %d, height is %d \n", wkstn2, work_out[0], work_out[1] );

   /* each workstation draws a box with text
      v_rfbox() uses fill area attributes set by v_opnwk()
      v_box()   uses line attributes set by v_opnwk()
   */
   /* raster coords, origin is top left */
   pxyarray[0] = wid2*1/10;
   pxyarray[1] = height2*9/10;
   pxyarray[2] = wid2*9/10;
   pxyarray[3] = height2*6/10;
   v_rfbox( wkstn2, pxyarray );                /* wkstn2 draws dotted box underneath */
   v_rbox( wkstn2, pxyarray );                 /* wkstn2 draws dotted box underneath */

   /* NDC coords, origin is bottom left */
   pxyarray[0] = wid1/10;
   pxyarray[1] = height1*6/10;
   pxyarray[2] = wid1*9/10;
   pxyarray[3] = height1*9/10;
   v_rfbox( wkstn1, pxyarray );                 /* wkstn1 draws solid box at the top */
   v_rbox( wkstn1, pxyarray );                  /* wkstn1 draws solid box at the top */
   fprintf( fout, "%d: boxes drawn\n", __LINE__);

   r = vst_load_fonts(wkstn2, 0);
   fprintf( fout, "%d: loaded %2 fonts for wkstn2\n", __LINE__, r);
   for( i=1; i<=r; i++ ) {
        if( vqt_name(wkstn2, i, swiss_name) == 2 ) {
             swiss_index = i;
             break;
        } /* if */
   } /* for */
   if( i > r ) quit("missing sans serif font");
   fprintf( fout, "%d: swiss (sans serif) font is \"%s\", index %d\n", __LINE__, swiss_name, swiss_index);

   r = vst_load_fonts(wkstn1, 0);
   fprintf( fout, "%d: loaded %2 fonts for wkstn1\n", __LINE__, r);
   for( i=1; i<=r; i++ ) {
        if( vqt_name(wkstn1, i, dutch_name) == 14 ) {
             dutch_index = i;
             break;
        } /* if */
   } /* for */
   if( i > r ) quit("missing serif font");
   fprintf( fout, "%d: dutch (serif) font is \"%s\", index %d\n", __LINE__, dutch_name, dutch_index);

   r = vst_font(wkstn2, 2); /* select Swiss, sans serif */
   fprintf( fout, "%d: selected font id %d for wkstn2\n", __LINE__, r);
   r = vst_font(wkstn1, 14); /* Dutch, serif */
   fprintf( fout, "%d: selected font id %d for wkstn1\n", __LINE__, r);

   swiss_pts = r = vst_point(wkstn2, 10, &junk, &junk, &junk, &junk);
   fprintf( fout, "%d: selected %d point font for wkstn2\n", __LINE__, r);
   dutch_pts = r = vst_point(wkstn1, 18, &junk, &junk, &junk, &junk);
   fprintf( fout, "%d: selected %d point font for wkstn1\n", __LINE__, r);

   fprintf(fout, "%d: swiss name is \"%s\"\n", __LINE__, swiss_name);

   sprintf(text, "work station 2, %s, %d points", swiss_name, swiss_pts);
   v_gtext(wkstn2, wid2*2/10, height2*7/10, text);
   fprintf( fout, "%d: printed text for wkstn 2 \"%s\"\n", __LINE__, text);
   sprintf(text, "work station 1, %s, %d points", dutch_name, dutch_pts);
   v_gtext(wkstn1, wid1*2/10, height1*8/10, text);
   fprintf( fout, "%d: printed text for wkstn 1 \"%s\"\n", __LINE__, text);

   sprintf(text, "white backgound, dotted line border");
   v_gtext(wkstn2, wid2*2/10, height2*3/4, text);
   fprintf( fout, "%d: printed text for wkstn 2 \"%s\"\n", __LINE__, text);
   sprintf(text, "patterned background, solid border");
   v_gtext(wkstn1, wid1*2/10, height1*7/10, text);
   fprintf( fout, "%d: printed text for wkstn 1 \"%s\"\n", __LINE__, text);
   v_gtext(wkstn2, wid2*3/10, height2*8/10, "press a key to quit");
   fprintf( fout, "%d: printed text for wkstn 2 \"%s\"\n", __LINE__, text);

   v_updwk( wkstn1 );
   fprintf( fout, "%d\n", __LINE__);
   v_updwk( wkstn2 );
   fprintf( fout, "%d\n", __LINE__);

#if 0
   pxyarray[0] = 10000;
   pxyarray[1] = 10000;
   pxyarray[2] = 20000;
   pxyarray[3] = 20000;
   pxyarray[4] = 20000;
   pxyarray[5] = 10000;

    for( pxyarray[4] = 20000; pxyarray[4] < 30000; pxyarray[4]+=37 )
      v_pline(wkstn1, 3, pxyarray);
#endif

   v_clsvwk(wkstn1);
   v_clsvwk(wkstn2);
   Cconin();
   exit(0);

} /* main */
