/*      b:sound.c                       */
/*      By Patrick Bass    Nov. 85      */
/*      (c) 1985 Antic Publishing       */

#include <portab.h>
#include <obdefs.h>
#include <define.h>
#include <gemdefs.h>
#include <osbind.h>

int    contrl[12], intin[256], ptsin[256], intout[256], ptsout[256],
       l_intin[20], l_ptsin[20], l_out[100],
       handle, xres, yres,
       i, mx, my, loop, dummy, key_state, port_state,
       x_note, y_note, 
       write_command = 128, read_command = 0, volume = 10,
       chana_lo = 0, chana_hi = 1,
       chanb_lo = 2, chanb_hi = 3,
       chan_enable = 7, chana_volume = 8, chanb_volume = 9,
       x_note_line = 80, y_note_line = 100, volume_line = 120,
       question_column = 15, answer_column = 115, twelve_bits = 4096,
       hi_mask = 0x0F00, lo_mask = 0x00FF, pointing_finger = 3,
       off = 0, thick = 1, skewed = 4, underlined = 8;

char   note_lo, note_hi, buffer[80],
       copyright[] = " copyright 1985 Antic - the ATARI Resource.";
 
double m_state, number1, number2, number3;

main()
   {
    appl_init();

    handle = graf_handle( &dummy, &dummy, &dummy, &dummy );
    graf_mouse( pointing_finger, 0x0L );

    for( i=0; i<10; l_intin[ i++ ] = 1 );  l_intin[10] = 2;

    v_opnvwk( l_intin, &handle, l_out );
    xres = l_out[0];   yres = l_out[1];

    vst_effects( handle, skewed ); vst_color( handle, BLUE );
    v_gtext( handle, 10, 20, " Antic - The ATARI Resource." );
    
    vst_effects( handle, thick );  vst_color( handle, GREEN );
    v_gtext( handle, 30, 40, " 'Sound Mouse' " );
    
    vst_effects( handle, underlined );  vst_color( handle, MAGENTA );
    v_gtext( handle, question_column, x_note_line, " Channel A: " );
    
    vst_effects( handle, underlined );  vst_color( handle, LMAGENTA );
    v_gtext( handle, question_column, y_note_line, " Channel B: " );

    vst_effects( handle, off );   vst_color( handle, YELLOW );
    v_gtext( handle, question_column, volume_line, "    Volume:  " );

    evnt_timer( 1500,0 );    /*  give the drives some time to stop  */
    
    Giaccess( volume, chana_volume + write_command );
    Giaccess( volume, chanb_volume + write_command );

    port_state = Giaccess( port_state, chan_enable + read_command );
    Giaccess( 60, chan_enable + write_command );

    do
       {
        vq_key_s( handle, &key_state );
    
        if ( key_state & K_ALT )
             { 
              volume++;
              for( loop = 0;  loop < 4000;  loop++ );
             }
        
        if ( key_state & K_LSHIFT )
             {
              volume--;
              for( loop = 0;  loop < 4000;  loop++ );
             }
     
        if ( volume > 15 )  volume = 15;
        if ( volume < 0 )   volume = 0;

        Giaccess( volume, chana_volume + write_command );
        Giaccess( volume, chanb_volume + write_command );
        

        vq_mouse( handle, &m_state, &mx, &my );
        x_note = ( mx * ( twelve_bits / ( xres+1 )));
        note_hi = ( x_note & hi_mask ) >> 8;
        note_lo = ( x_note & lo_mask );
        Giaccess( note_lo, chana_lo + write_command );
        Giaccess( note_hi, chana_hi + write_command );

        y_note = ( my * ( twelve_bits / ( yres+1 )));
        note_hi = ( y_note & hi_mask ) >> 8;
        note_lo = ( y_note & lo_mask );
        Giaccess( note_lo, chanb_lo + write_command );
        Giaccess( note_hi, chanb_hi + write_command );

        number1 = x_note;
        ftoa( number1, buffer, 0 );  buffer[79] = 0;
        vst_effects( handle, underlined ); vst_color( handle, MAGENTA );
        v_gtext( handle, answer_column, x_note_line, buffer );

        number2 = y_note;
        ftoa( number2, buffer, 0 );  buffer[79] = 0;
        vst_color( handle, LMAGENTA );
        v_gtext( handle, answer_column, y_note_line, buffer );

        number3 = volume;
        ftoa( number3, buffer, 0 );  buffer[79] = 0;
        vst_effects( handle, off ); vst_color( handle, YELLOW );
        v_gtext( handle, answer_column, volume_line, buffer );

       }
    while( m_state == off );

    Giaccess( off, chana_volume + write_command );
    Giaccess( off, chanb_volume + write_command );
    Giaccess( port_state, chan_enable + write_command );    

    v_clsvwk( handle );
    appl_exit();
   }
