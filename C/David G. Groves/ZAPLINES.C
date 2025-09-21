/* 
 * Newsin.c by David G. Groves
 * A modification of Sound.c and
 * Color Sinewave Program
 * By Patrick Bass
 * (c) 1985, ANTIC PUBLISHING
 */

#include "portab.h"
#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"

int contrl[12], intin[256], ptsin[256], intout[256], ptsout[256],
 l_intin[20], l_ptsin[20], l_out[100], temp[100],
 color, max_color, handle, xres, yres,
 i, k, iter, loop, times, dummy, port_state,
 sin_amplitude, cos_amplitude,
 sin_period, cos_period, step,
 key_state, port_state, x_note, y_note,
 write_command=128, read_command=0, volume=10,
 chana_lo=0, chana_hi=1, chanb_lo=2, chanb_hi=3, off=0,
 chan_enable=7, chana_volume=8, chanb_volume=9,
 hi_mask=0x0F00, lo_mask=0x00FF, twelve=4096;

char note_lo, note_hi, buffer[80], newline[]={ 10, 13, 0 };

long screen;

double number, xpoint, m_state, number1, number2, number3;

extern double  sin(), cos(), random(), giaccess();
/*----------------------------------------------------------------------*/
main()
{
 appl_init();

 handle=graf_handle( &dummy, &dummy, &dummy, &dummy );

 for(i=0; i<10; l_intin[ i++ ]=1 ); l_intin[10]=2;

 v_opnvwk(l_intin, &handle, l_out);
 xres=l_out[0]; yres=l_out[1]; max_color=l_out[13];
 
 Cconws( newline );
 Cconws( "Newsin.c" ); Cconws( newline );
 Cconws( "Based on Antic programs by Patrick Bass." ); Cconws( newline );
 Cconws( "Adapted by David G. Groves" ); Cconws( newline );
 Cconws( "(c) 1985 Antic Publishing" ); Cconws( newline );
 Cconws( newline );
 evnt_keybd();

 temp[0]=0; temp[1]=0; temp[2]=0;
 vs_color( handle, 0, temp );
 vs_color( handle, 3, temp );

 Giaccess( volume, chana_volume+write_command );
 Giaccess( volume, chanb_volume+write_command );
 port_state=Giaccess( port_state, chan_enable+read_command );
 Giaccess( 60, chan_enable+write_command );

 for( loop=0; loop < 1; loop=loop + 0 )
 {
  do
  { color=Random() & 15; } while( color > max_color );  
  vsl_color( handle, color );

  step=( Random() &  2 ) + 2;

  do
  { sin_amplitude=( Random() & 255 ) + 10; }
  while( sin_amplitude > (yres/2) );

  do
  { cos_amplitude=( Random() & 255 ) + 10; }
  while( cos_amplitude > (yres/2) );

  do
  { sin_period=( Random() & 127 ) + 10; }
  while( sin_period > 100 );

  do
  { cos_period=( Random() & 127 ) + 10; }
  while( cos_period > 100 );

  volume=( Random() & 2 ) + 9;
  Giaccess( volume, chana_volume+write_command );
  Giaccess( volume, chanb_volume+write_command ); 

  for( iter=1; iter<xres; iter=iter+step )
  {
      xpoint=iter;
      ptsin[0]=xpoint;
      ptsin[1]=(sin(xpoint/sin_period) * sin_amplitude)+(yres/2);
      ptsin[2]=(xres-xpoint);
      ptsin[3]=(cos(xpoint/cos_period) * cos_amplitude)+(yres/2);

 x_note=(((sin(xpoint/sin_period)*(twelve/(xres+1))) * 56 ) + 720 );
 y_note=(((cos(xpoint/cos_period)*(twelve/(xres+1))) * 72 ) + 880 );

      note_hi=(x_note & hi_mask) >> 8;
      note_lo=(x_note & lo_mask);
      Giaccess( note_lo, chana_lo+write_command );
      Giaccess( note_hi, chana_hi+write_command );

      note_hi=(y_note & hi_mask) >> 8;
      note_lo=(y_note & lo_mask );
      Giaccess( note_lo, chanb_lo+write_command );
      Giaccess( note_hi, chanb_hi+write_command );

      v_pline( handle, 2, ptsin );
  }
 do
 { vq_key_s( handle, &key_state ); 
   Giaccess( off, chana_volume+write_command );
   Giaccess( off, chanb_volume+write_command );  
          Giaccess( 60, chan_enable+write_command );
 } while( key_state == 0 );
 if ( key_state == 4 ) erase_screen();
 if ( key_state == 8 ) loop=2;
    }
 Giaccess( off, chana_volume+write_command );
 Giaccess( off, chanb_volume+write_command );
 Giaccess( port_state, chan_enable+write_command );

 temp[1]=1000;
 vs_color( handle, 3, temp );
 temp[0]=1000; temp[2]=1000;
 vs_color( handle, 0, temp );

 v_clsvwk( handle );
 appl_exit();
}

/*---------------------------------------------------------------------*/
erase_screen()
{
char *toscreen;
int counter;

 toscreen=Physbase();
 for( counter=0; counter<32000; *(toscreen+(counter++))=0 );
} 

   b HG <   ‡[     k   g Nu~ Nu <  o D & .  <  `   