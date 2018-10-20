#include <vdi.h>
#include <xvdi.h>

int    contrl[15];
int    intin[132];
int    intout[140];
int    ptsin[145];
int    ptsout[145];

VDIPB pb=
{
	contrl,
	intin,
	ptsin,
	intout,
	ptsout
};

/* VDI-String in einen C-String umwandeln */ 
void  vdi_str_to_c( UWORD *src, UBYTE *des, WORD len ) 
{ 
   while ( len > 0 ) 
   { 
      *des++ = (UBYTE) *src++;   /* nur das Low-Byte kopieren */ 
      len--; 
   } 
   *des++ = 0;                   /* Ende des Strings */ 
} 
 
/* C-String in einen VDI-String umwandeln */ 
WORD  c_str_to_vdi( UBYTE *src, UWORD *des ) 
{ 
   WORD  len=0; 
 
   while (( *des++ = *src++ ) != 0 ) 
      len++; 
 
   return( len );                /* LÑnge des Strings ohne Null-Byte */ 
} 
 
/* Positionsangabe in fix31-Darstellung in Pixel-Koordinate umrechnen */ 
WORD  fix31_to_pixel( fix31 a ) 
{ 
   WORD  b; 
 
   b = (WORD) (( a + 32768L ) >> 16 ); /* runden !! */ 
   return( b );                        /* Pixelwert zurÅckgeben */ 
} 
 /*
void  vs_color( WORD handle, WORD index, RGB1000 *rgb_in ) 
{ 
   intin[0] = index; 
   intin[1] = rgb_in->red; 
   intin[2] = rgb_in->green; 
   intin[3] = rgb_in->blue; 
 
   contrl[0] = 14; 
   contrl[1] = 0; 
   contrl[3] = 4; 
   contrl[5] = 0; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
} 
 
WORD  vq_color( WORD handle, WORD color_index, WORD flag, RGB1000 *rgb_out ) 
{ 
   intin[0] = color_index; 
   intin[1] = flag; 
 
   contrl[0] = 26; 
   contrl[1] = 0; 
   contrl[3] = 2; 
   contrl[5] = 0; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   *rgb_out = *(RGB1000 *) (intout + 1); 
   return( intout[0] ); 
} 
*/ 
WORD  vs_calibrate( WORD handle, WORD flag, RGB1000 *table ) 
{ 
   *(RGB1000 **)intin = table; 
   intin[2] = flag; 
 
   contrl[0] = 5; 
   contrl[1] = 0; 
   contrl[3] = 3; 
   contrl[5] = 76; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   return( intout[0] ); 
} 
 
WORD  vq_calibrate( WORD handle, WORD *flag ) 
{ 
   contrl[0] = 5; 
   contrl[1] = 0; 
   contrl[3] = 0; 
   contrl[5] = 77; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   if ( contrl[4] > 0 ) 
   { 
      *flag = intout[0]; 
      return( 1 ); 
   } 
   else 
   { 
      *flag = 0 ;
      return( 0 ); 
   } 
} 
 
void  v_opnbm( WORD *work_in, MFDB *bitmap, WORD *handle, WORD *work_out ) 
{ 
   /* Wenn work_in[15..19] 0 enthalten, wird eine Bitmap im gerÑtespezifischen 
      Format oder mit nur 1 Ebene erzeugt (hÑngt vom MFDB ab). Anderfalls wird 
      versucht eine Bitmap mit der Farbanzahl <work_in[15..16]>, <work_in[17]> 
      Ebenen, dem Pixelformat <work_in[18]> und der Bitreihenfolge <work_in[19]> 
      anzulegen. Falls kein passender Offscreen-Treiber vorhanden ist, kann die 
      Bitmap nicht geîffnet werden. 
   */ 
 
   pb.intin = work_in; 
   pb.intout = work_out; 
   pb.ptsout = work_out + 45; 
 
   contrl[0] = 100; 
   contrl[1] = 0; 
   contrl[3] = 20; 
   contrl[5] = 1; 
   *(MFDB**)&(contrl[7]) = bitmap; 
 
   vdi( &pb ); 
 
   *handle = contrl[6]; 
   pb.intin = intin; 
   pb.intout = intout; 
   pb.ptsout = ptsout; 
} 
 
void  v_clsbm( WORD handle ) 
{ 
   contrl[0] = 101; 
   contrl[1] = 0; 
   contrl[3] = 0; 
   contrl[5] = 1; 
   contrl[6] = handle; 
   vdi( &pb ); 
} 
 
void  vq_scrninfo( WORD handle, WORD *work_out ) 
{ 
   pb.intout = work_out; 
 
   intin[0] = 2; 
   contrl[0] = 102; 
   contrl[1] = 0; 
   contrl[3] = 1; 
   contrl[5] = 1; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   pb.intout = intout; 
} 
 
WORD  vq_devinfo2( WORD handle, WORD device, WORD *dev_exists, BYTE *file_name, BYTE *real_name ) 
{ 
   contrl[0] = 248;                 /* Funktionsnummer */ 
   contrl[1] = 0; 
   contrl[3] = 1;                   /* ID wird Åbergeben */ 
   contrl[5] = 0; 
   contrl[6] = handle; 
   intin[0] = device;               /* GerÑt */ 
 
   vdi( &pb ); 
 
   *dev_exists = 0;                 /* Treiber ist nicht vorhanden */ 
   *file_name = 0; 
   *real_name = 0; 
 
   if ( contrl[4] && intout[0] )    /* Treiber vorhanden? */ 
   { 
      WORD  i; 
      WORD  len; 
 
      *dev_exists = 1;              /* Treiber ist vorhanden */ 
 
      for ( i = 0; i < contrl[4]; i++ ) 
      { 
         *file_name = (BYTE) intout[i]; 
         if ( *file_name == ' ' )    /* Trennung durch Leerzeichen? */ 
         { 
            /* letztes Leerzeichen? */ 
            if (( i < contrl[4] ) && ( intout[i+1] != ' ' )) 
            { 
               *file_name = '.';    /* Leerzeichen ersetzen */ 
               file_name++; 
            } 
         } 
         else 
            file_name++; 
      } 
      *file_name++ = 0;             /* Endeeeee */ 
 
      if (( contrl[2] == 1 ) && ( contrl[1] > 0 )) /* !?+*~"›)%&#/(^= */ 
         len = contrl[1]; 
      else 
         len = contrl[2] - 1; 
 
      for ( i = 1; i <= len; i++ )  /* Klartextnamen kopieren */ 
         *((WORD *)real_name)++ = ptsout[i]; 
      *real_name++ = 0;             /* sicherheitshalber */ 
   } 
 
   return( ptsout[0] );             /* Treiber geîffnet oder nicht */ 
} 
 
WORD  vq_ext_devinfo( WORD handle, WORD device, WORD *dev_exists, 
                      BYTE *file_path, BYTE *file_name, BYTE *name ) 
{ 
   intin[0] = device; 
   *(BYTE **)&intin[1] = file_path; 
   *(BYTE **)&intin[3] = file_name; 
   *(BYTE **)&intin[5] = name; 
 
   contrl[0] = 248; 
   contrl[1] = 0; 
   contrl[3] = 7; 
   contrl[5] = 4242; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   *dev_exists = intout[0]; 
   return( intout[1] ); 
} 
/* 
WORD  vqt_name( WORD handle, WORD index, BYTE *name, UWORD *font_format, UWORD *flags ) 
{ 
   intin[0] = index; 
   intin[1] = 0; 
 
   contrl[0] = 130; 
   contrl[1] = 0; 
   contrl[3] = 2; 
   contrl[5] = 1; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   vdi_str_to_c( (UWORD *)&intout[1], (UBYTE *) name, 31 ); 
 
   if ( contrl[4] <= 34 ) 
   { 
      *flags = 0; 
      *font_format = 0; 
      if ( contrl[4] == 33 ) 
         name[32] = 0; 
      else 
         name[32] = (BYTE) intout[33]; 
   } 
   else 
   { 
      name[32] = intout[33]; 
      *flags = (intout[34] >> 8) & 0xff; 
      *font_format = intout[34] & 0xff; 
   } 
 
   return( intout[0] ); 
} 
*/ 
void  vst_width( WORD handle, WORD width, WORD *char_width, WORD *char_height, 
                 WORD *cell_width, WORD *cell_height )
{ 
   ptsin[0] = width; 
 
   contrl[0] = 231; 
   contrl[1] = 1; 
   contrl[3] = 0; 
   contrl[5] = 0; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   *char_width = ptsout[0]; 
   *char_height = ptsout[1]; 
   *cell_width = ptsout[2]; 
   *cell_height = ptsout[3]; 
} 
 
void  vst_track_offset( WORD handle, fix31 offset, WORD pair_mode, WORD *tracks, WORD *pairs ) 
{ 
   contrl[0] = 237; 
   contrl[1] = 0; 
   contrl[3] = 4; 
   contrl[6] = handle; 
 
   intin[0] = 255; 
   intin[1] = pair_mode; 
   *(fix31 *)&intin[2] = offset; 
 
   vdi( &pb ); 
 
   *tracks = intout[0]; 
   *pairs = intout[1]; 
} 
 
void  vqt_real_extent( WORD handle, WORD x, WORD y, BYTE *string, WORD *extent ) 
{ 
   WORD  len; 
   WORD  i; 
 
   ptsin[0] = x; 
   ptsin[1] = y; 
 
   len = c_str_to_vdi( (UBYTE *) string, (UWORD *) intin ); 
 
   contrl[0] = 240; 
   contrl[1] = 1; 
   contrl[3] = len; 
   contrl[5] = 4200; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   for ( i = 0; i < 8; i++ ) 
      *extent++ = ptsout[i]; 
} 
 
WORD  vqt_xfntinfo( WORD handle, WORD flags, WORD id, WORD index, XFNT_INFO *info ) 
{ 
   info->size = (LONG) sizeof( XFNT_INFO ); 
 
   intin[0] = flags; 
   intin[1] = id; 
   intin[2] = index; 
   *(XFNT_INFO **)&intin[3] = info; 
 
   contrl[0] = 229; 
   contrl[1] = 0; 
   contrl[3] = 5; 
   contrl[5] = 0; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   return( intout[1] ); 
} 
 
WORD  vst_name( WORD handle, WORD font_format, BYTE *font_name, BYTE *ret_name ) 
{ 
   WORD  len; 
 
   intin[0] = font_format; 
   len = c_str_to_vdi( (UBYTE *) font_name, (UWORD *)&intin[1] ); 
 
   contrl[0] = 230; 
   contrl[1] = 0; 
   contrl[3] = 1 + len; 
   contrl[5] = 0; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   if ( ret_name ) 
      vdi_str_to_c( (UWORD *)&intout[1], ret_name, contrl[4] ); 
 
   return( intout[0] ); 
} 
 
WORD  vqt_name_and_id( WORD handle, WORD font_format, BYTE *font_name, BYTE *ret_name ) 
{ 
   WORD  len; 
 
   intin[0] = font_format; 
   len = c_str_to_vdi( (UBYTE *) font_name, (UWORD *) intin + 1 ); 
 
   contrl[0] = 230; 
   contrl[1] = 0; 
   contrl[3] = 1 + len; 
   contrl[5] = 100; 
   contrl[6] = handle; 
 
   vdi( &pb ); 
 
   if ( ret_name ) 
      vdi_str_to_c( (UWORD *)&intout[1], ret_name, contrl[4] ); 
 
   return( intout[0] ); 
} 
 
 
