/*------------------------------------------------------*/
/*	GEM_INIT.C											*/
/*														*/
/*	An- und abmelden einer VDI-Workstation mit			*/
/*	Deklaration und Initialisierung von wichtigen 		*/
/*	globalen Variablen									*/
/*------------------------------------------------------*/
/* (C)1990 Mathias Tobollik								*/
/*------------------------------------------------------*/


#include <aes.h>
#include <vdi.h>
#include <gem_init.h>

int work_in[12], work_out[57],
    handle,                 /* VDI-handle */
    phys_handle;
int char_w, char_h,         /* Zeichenbreite / -h”he  */
    cell_w, cell_h;

int ap_id;                  /* AES-Applikationsnummer */
int x_res, y_res;           /* Bildschirmaufl”sung    */

int clip[4];				/*	Clipping-Rechteck */


/* Anmeldung beim AES/VDI ------------------------------*/
int open_vwork( void )
{
int i;                     
    if ( -1!=(ap_id=appl_init()) )
    {
        for ( i = 1; i < 10; work_in[i++] = 1 );
        work_in[10] = 2;
        phys_handle = graf_handle( &char_w, &char_h,
                                   &cell_w, &cell_h );
        work_in[0] = handle = phys_handle;
        v_opnvwk( work_in, &handle, work_out );
        x_res = work_out[0];
        y_res = work_out[1];
        
        /* Clipping gleich begrenzen:	*/
        clip[0] = 0;
        clip[1] = 0;
        clip[2] = x_res;
        clip[3] = y_res;
        vs_clip( handle, 1, clip );
        
        return ( TRUE );
    }
    else
        return ( FALSE );
}



/* Abmelden beim AES/VDI -------------------------------*/
void close_vwork( void )
{
    v_clsvwk( handle );
    appl_exit( );
}
