#if 0
void
Do3D( void )
{
     int i;
     
     ActiveTree( ad_active );
     ObType( REMOVE ) |= DRAW3D2;
     ObType( QUIT )   |= DRAW3D2;
     ObH( REMOVE )   = ObH( QUIT )    = 16;

     ObX( REMOVE ) += 1;
     ObY( REMOVE ) += 2;
     ObW( REMOVE ) -= 2;
     ObH( REMOVE ) -= 3;

     ObX( QUIT ) += 1;
     ObY( QUIT ) += 2;
     ObW( QUIT ) -= 2;
     ObH( QUIT ) -= 3;

     ObType( XUP ) |= DRAW3D2;
     ObType( XDOWN ) |= DRAW3D2;
     ObType( UP )    |= DRAW3D2;
     ObType( DOWN )  |= DRAW3D2;
     ObType( XDEVICE ) |= DRAW3D2;
     ObType( SLIDER )  |= DRAW3D2;
     ObType( BASE )    |= DRAW3D2;
     
     ObH( UP ) = ObH( DOWN ) = ObH( XUP ) = ObH( XDOWN ) = 16;

     ObIndex( XUP ) = ( ObIndex( XUP ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( XDOWN ) = ( ObIndex( XDOWN ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( UP ) = ( ObIndex( UP ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( DOWN ) = ( ObIndex( DOWN ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( SLIDER ) = ( ObIndex( SLIDER ) & 0xffffff70 ) | LWHITE | 0x70;


     ObH( XUP ) = ObH( XDOWN ) = ObH( XDEVICE ) = ObH( XDRIVER );     
     ObY( UP ) = ObY( LINEBASE ) + 2;
     ObY( DOWN ) = ObY( LINEBASE ) + ObH( LINEBASE ) - ObH( DOWN ) - 2;
     ObX( DOWN ) = ObX( BASE ) = ObX( UP ) = ObX( LINEBASE ) + ObW( LINEBASE ) + 3;
     ObW( UP ) -= 3;
     ObW( DOWN ) = ObW( BASE ) = ObW( SLIDER ) = ObW( UP );
     
     ObY( BASE ) = ObY( UP ) + ObH( UP ) + 5;
     ObH( BASE ) = ( ObY( DOWN ) - 5 ) - ObY( BASE );
     TedColor( XDEVICE ) = ( TedColor( XDEVICE ) & 0xff70 ) | LWHITE | 0x70;

     ObX( XUP ) += 1;
     ObY( XUP ) += 2;
     ObW( XUP ) -= 3;
     ObH( XUP ) -= 4;

     ObX( XDOWN ) += 1;
     ObY( XDOWN ) += 2;
     ObW( XDOWN ) -= 3;
     ObH( XDOWN ) -= 4;

     ObX( XDEVICE ) += 1;
     ObY( XDEVICE ) += 2;
     ObW( XDEVICE ) -= 3;
     ObH( XDEVICE ) -= 4;


     ActiveTree( ad_front );
     ObType( FDRAFT ) |= DRAW3D1;
     ObType( FFINAL ) |= DRAW3D1;
     ObType( FSAVE ) |= DRAW3D2;
     ObType( FOPTIONS ) |= DRAW3D2;
     ObType( FEXIT ) |= DRAW3D2;     
     ObH( FSAVE ) = ObH( FOPTIONS ) = ObH( FEXIT ) = 16;
     ObH( FDRAFT ) = ObH( FFINAL ) = 16;
     
     ObX( FSAVE ) += 1;
     ObY( FSAVE ) += 1;
     ObW( FSAVE ) -= 2;
     ObH( FSAVE ) -= 3;
     
     ObX( FOPTIONS ) += 1;
     ObY( FOPTIONS ) += 2;
     ObW( FOPTIONS ) -= 2;
     ObH( FOPTIONS ) -= 3;
     
     ObX( FEXIT ) += 1;
     ObY( FEXIT ) += 2;
     ObW( FEXIT ) -= 2;
     ObH( FEXIT ) -= 3;
     
     ObX( FDRAFT ) += 1;
     ObY( FDRAFT ) += 2;
     ObW( FDRAFT ) -= 2;
     ObH( FDRAFT ) -= 3;

     ObX( FFINAL ) += 1;
     ObY( FFINAL ) += 2;
     ObW( FFINAL ) -= 2;
     ObH( FFINAL ) -= 3;

     ActiveTree( ad_menu );
     ObType( MDRIVER ) |= DRAW3D2;
     ObType( MFONT )   |= DRAW3D2;
     ObType( MPATH )   |= DRAW3D2;
     ObType( MTOP )    |= DRAW3D2;
     ObH( MDRIVER ) = ObH( MFONT ) = ObH( MPATH ) = ObH( MTOP ) = 16;
     ObX( MTOP ) += 1;
     ObY( MTOP ) += 2;
     ObW( MTOP ) -= 2;
     ObH( MTOP ) -= 3;

     for( i = MDRIVER; i<= MPATH; i++ )
     {
       TedColor( i ) = ( TedColor( i ) & 0xff70 ) | LWHITE | 0x70;
       ObX( i ) += 1;
       ObY( i ) += 2;
       ObW( i ) -= 2;
       ObH( i ) -= 3;
     }  
     
     
     ActiveTree( ad_path );
     ObType( PLEFT )   |= DRAW3D2;
     ObType( PRIGHT )  |= DRAW3D2;
     ObType( PBASE )   |= DRAW3D2;
     ObType( PEXIT )   |= DRAW3D2;
     ObType( PCANCEL ) |= DRAW3D2;    
     ObIndex( PLEFT ) = ( ObIndex( PLEFT ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( PRIGHT ) = ( ObIndex( PRIGHT ) & 0xffffff70 ) | LWHITE | 0x70;
     TedColor( PBASE ) = ( TedColor( PBASE ) & 0xff70 ) | LWHITE | 0x70;
     ObW( PLEFT )  -= 1;
     ObW( PRIGHT ) -= 1;
     ObX( PRIGHT ) += 1;
     ObX( PLEFT ) -= 1;
     
     ActiveTree( ad_inactive );
     ObType( OXUP )     |= DRAW3D2;
     ObType( OXDOWN )   |= DRAW3D2;
     ObType( XTRANSFR ) |= DRAW3D2;
     ObType( OUP )      |= DRAW3D2;
     ObType( ODOWN )    |= DRAW3D2;
     ObType( OBASE )    |= DRAW3D2;
     ObType( OSLIDE )   |= DRAW3D2;
     ObType( IQUIT )    |= DRAW3D2;
 
     ObX( IQUIT ) += 1;
     ObY( IQUIT ) += 2;
     ObW( IQUIT ) -= 2;
     ObH( IQUIT ) -= 3;

     ObX( XTRANSFR ) += 1;
     ObY( XTRANSFR ) += 2;
     ObW( XTRANSFR ) -= 2;
     ObH( XTRANSFR ) -= 3;
    
     ObIndex( OXUP ) = ( ObIndex( OXUP ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( OXDOWN ) = ( ObIndex( OXDOWN ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( OUP ) = ( ObIndex( OUP ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( ODOWN ) = ( ObIndex( ODOWN ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( OSLIDE ) = ( ObIndex( OSLIDE ) & 0xffffff70 ) | LWHITE | 0x70;

     ObX( OXUP ) += 1;
     ObY( OXUP ) += 2;
     ObW( OXUP ) -= 3;
     ObH( OXUP ) -= 4;

     ObX( OXDOWN ) += 2;
     ObY( OXDOWN ) += 2;
     ObW( OXDOWN ) -= 3;
     ObH( OXDOWN ) -= 4;
 
 
     ObY( OUP ) = ObY( OLBASE ) + 2;
     ObY( ODOWN ) = ObY( OLBASE ) + ObH( OLBASE ) - ObH( ODOWN ) - 2;
     ObX( ODOWN ) = ObX( OBASE ) = ObX( OUP ) = ObX( OLBASE ) + ObW( OLBASE ) + 3;
     ObW( OUP ) -= 3;
     ObW( ODOWN ) = ObW( OBASE ) = ObW( OSLIDE ) = ObW( OUP );

     ObY( OBASE ) = ObY( OUP ) + ObH( OUP ) + 5;
     ObH( OBASE ) = ( ObY( ODOWN ) - 5 ) - ObY( OBASE );


     ActiveTree( ad_edit );
     ObType( CURUP )   |= DRAW3D2;
     ObType( CURDOWN ) |= DRAW3D2;
     ObType( AUP )     |= DRAW3D2;
     ObType( ADOWN )   |= DRAW3D2;
     ObType( EEXIT )   |= DRAW3D2;
     ObType( EADD )    |= DRAW3D2;
     ObType( EDELETE ) |= DRAW3D2;
     ObType( CURROM )  |= DRAW3D1;
     ObType( CURRES )  |= DRAW3D1;
     ObType( AROM )    |= DRAW3D1;
     ObType( ARES )    |= DRAW3D1;
     ObIndex( CURUP ) = ( ObIndex( CURUP ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( CURDOWN ) = ( ObIndex( CURDOWN ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( AUP ) = ( ObIndex( AUP ) & 0xffffff70 ) | LWHITE | 0x70;
     ObIndex( ADOWN ) = ( ObIndex( ADOWN ) & 0xffffff70 ) | LWHITE | 0x70;

     ObX( CURUP ) += 1;
     ObY( CURUP ) += 2;
     ObW( CURUP ) -= 3;
     ObH( CURUP ) -= 4;

     ObX( CURDOWN ) += 2;
     ObY( CURDOWN ) += 2;
     ObW( CURDOWN ) -= 3;
     ObH( CURDOWN ) -= 4;

     ObX( AUP ) += 1;
     ObY( AUP ) += 2;
     ObW( AUP ) -= 3;
     ObH( AUP ) -= 4;

     ObX( ADOWN ) += 2;
     ObY( ADOWN ) += 2;
     ObW( ADOWN ) -= 3;
     ObH( ADOWN ) -= 4;

     ObX( CURROM ) += 1;
     ObY( CURROM ) += 2;
     ObW( CURROM ) -= 2;
     ObH( CURROM ) -= 4;

     ObX( CURRES ) += 1;
     ObY( CURRES ) += 3;
     ObW( CURRES ) -= 2;
     ObH( CURRES ) -= 4;

     ObX( AROM ) += 1;
     ObY( AROM ) += 2;
     ObW( AROM ) -= 2;
     ObH( AROM ) -= 4;

     ObX( ARES ) += 1;
     ObY( ARES ) += 2;
     ObW( ARES ) -= 2;
     ObH( ARES ) -= 4;

     ObX( EEXIT ) += 1;
     ObY( EEXIT ) += 2;
     ObW( EEXIT ) -= 2;
     ObH( EEXIT ) -= 3;

     ObX( EADD ) += 1;
     ObY( EADD ) += 2;
     ObW( EADD ) -= 2;
     ObH( EADD ) -= 3;

     ObX( EDELETE ) += 1;
     ObY( EDELETE ) += 2;
     ObW( EDELETE ) -= 2;
     ObH( EDELETE ) -= 3;
     
}
#endif
