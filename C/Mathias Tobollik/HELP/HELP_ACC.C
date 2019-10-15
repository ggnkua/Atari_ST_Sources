/*------------------------------------------------------*/
/* HELP_ACC.C                                           */
/* Programm: Hilfe-ACCessory HELP!                      */
/* Sprache:  Turbo-C 2.0                                */
/* Autor:    (C)1990 Mathias Tobollik                   */
/*------------------------------------------------------*/
#include <help.h>

void open_work( void );


/*------------------------------------------------------*/
/* Hauptprogramm                                        */
/*------------------------------------------------------*/
void main( void )
{
int menu_id, msg[8], fs_xbut;
char file[MAXDIR], path[MAXDIR], f[13];

/* ACC anmelden und warten... --------------------------*/
    ap_id = appl_init();
    
/* Der folgende Aufruf dient dem Zweck, den Speicher fÅr
   die Hilfetexte zu reservieren, bevor irgendeine andere
   Anwendung (z.B. 1st Word Plus) auf die Idee kommen kann,
   den ganzen Speicher fÅr sich zu reservieren:         */
   
    get_mem( 4L );
    
/* Schauen Sie sich die ErklÑrung zu get_mem() an, und Sie
   werden verstehen, warum ich das hier so mache! */
   
    menu_id = menu_register( ap_id, "  Help ! " );
    evnt_mesag( msg );         /* ... Aufruf abwarten... */
    
/* Pfade voreinstellen. Falls wir spÑter die Fileselect-Box
   aufrufen, brauchen wir die folgenden Strings: --------*/
    strcpy( path, " :\\*.*" );
    strcpy( file, " :\\HELP.*" );
    *path = *file = (char)Dgetdrv() + 'A';
    strcpy( f, "HELP.*" );
    
/* Auflîsung ermitteln / Fenster vorbereiten: ----------*/
    open_work();      
    v_clsvwk( handle );
    hwo_w = x_res;     hwo_h = y_res-cell_h;
    hwo_x = 0;         hwo_y = cell_h;
    
/* Die Hauptschleife: ----------------------------------*/
    do{
        if( msg[0] == AC_OPEN && msg[4] == menu_id )
        {   
            open_work();
            if( help( "öbersicht", file, EXTERN ) < 0 )
            {
                fsel_input( path, f, &fs_xbut );
                strcpy( file, path );
                strcpy( strrchr( file, (int)'\\' )+1, f );
                if( fs_xbut )
                    help( "öbersicht", file, EXTERN );
            }
            v_clsvwk( handle );
        }
        evnt_mesag( msg );
    }while( TRUE );
}


/* Die Funktion open_vwork() aus GEM_INI.H îffnet leider
sofort die Workstation. Das wollen wir aber erst beim 
Aufruf des Accessories tun, deshalb basteln wir uns 
folgende Funktion: -------------------------------------*/

void open_work( void )
{
int i;
    for ( i=1; i<10; work_in[i++]=1 );
    
    work_in[10]=2;
    phys_handle=graf_handle( &char_w, &char_h, 
                             &cell_w, &cell_h);
    work_in[0]=handle=phys_handle;
    v_opnvwk(work_in, &handle,work_out);
    
    x_res=work_out[0];
    y_res=work_out[1];
}
/*------------------- Ende HELP_ACC.C ------------------*/

