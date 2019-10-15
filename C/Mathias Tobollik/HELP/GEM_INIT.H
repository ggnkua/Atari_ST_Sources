/*------------------------------------------------------*/
/*      Include-File fÅr An- und Abmelden beim VDI      */
/*------------------------------------------------------*/
#define FALSE 0
#define TRUE  1

int work_in[12], work_out[57],
    handle,                   /* VDI-handle */
    phys_handle;
int char_w, char_h,           /* Zeichenbreite / -hîhe  */
    cell_w, cell_h;
int ap_id;                    /* AES-Applikationsnummer */
int x_res, y_res;             /* Bildschirmauflîsung    */

/* Funktionsprototypen: --------------------------------*/
int open_vwork( void );
void close_vwork( void );


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
/*------------------ Ende GEM_INIT.H -------------------*/
