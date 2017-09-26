#include <portab.h>

#define fix31 long

/* Strukturdefinitionen */ 

typedef struct 
{ 
   WORD  red;              /* Rot-IntensitÑt in Promille (0-1000) */ 
   WORD  green;            /* GrÅn-IntensitÑt in Promille (0-1000) */ 
   WORD  blue;             /* Blau-IntensitÑt in Promille (0-1000) */ 
} RGB1000; 
 
typedef struct 
{ 
   LONG  size;             /* LÑnge der Struktur, muû vor vqt_xfntinfo() gesetzt werden */ 
   WORD  format;           /* Fontformat, z.B. 4 fÅr TrueType */ 
   WORD  id;               /* Font-ID, z.B. 6059 */ 
   WORD  index;            /* Index */ 
   BYTE  font_name[50];    /* vollstÑndiger Fontname, z.B. "Century 725 Italic BT" */ 
   BYTE  family_name[50];  /* Name der Fontfamilie, z.B. "Century725 BT" */ 
   BYTE  style_name[50];   /* Name des Fontstils, z.B. "Italic" */ 
   BYTE  file_name1[200];  /* Name der 1. Fontdatei, z.B. "C:\FONTS\TT1059M_.TTF" */ 
   BYTE  file_name2[200];  /* Name der optionalen 2. Fontdatei */ 
   BYTE  file_name3[200];  /* Name der optionalen 3. Fontdatei */ 
   WORD  pt_cnt;           /* Anzahl der Punkthîhen fÅr vst_point(), z.B. 10 */ 
   WORD  pt_sizes[64];     /* verfÅgbare Punkthîhen, 
                              z.B. { 8, 9, 10, 11, 12, 14, 18, 24, 36, 48 } */ 
} XFNT_INFO; 
 
/* Funktionsprototypen */ 
void  vdi_str_to_c( UWORD *src, UBYTE *des, WORD len ); 
WORD  c_str_to_vdi( UBYTE *src, UWORD *des ); 
WORD  fix31_to_pixel( fix31 a ); 
/*
void  vs_color( WORD handle, WORD index, RGB1000 *rgb_in ); 
WORD  vq_color( WORD handle, WORD color_index, WORD flag, RGB1000 *rgb_out ); 
*/
WORD  vs_calibrate( WORD handle, WORD flag, RGB1000 *table ); 
WORD  vq_calibrate( WORD handle, WORD *flag ); 
void  v_opnbm( WORD *work_in, MFDB *bitmap, WORD *handle, WORD *work_out ); 
void  v_clsbm( WORD handle ); 
void  vq_scrninfo( WORD handle, WORD *work_out ); 
WORD  vq_devinfo2( WORD handle, WORD device, WORD *dev_exists, BYTE *file_name, BYTE *real_name ); 
WORD  vq_ext_devinfo( WORD handle, WORD device, WORD *dev_exists, 
                      BYTE *file_path, BYTE *file_name, BYTE *name ); 
/*
WORD  vqt_name( WORD handle, WORD index, BYTE *name, UWORD *font_format, UWORD *flags ); 
*/
void  vst_width( WORD handle, WORD width, WORD *char_width, WORD *char_height, 
                 WORD *cell_width, WORD *cell_height ); 
void  vst_track_offset( WORD handle, fix31 offset, WORD pair_mode, WORD *tracks, WORD *pairs ); 
void  vqt_real_extent( WORD handle, WORD x, WORD y, BYTE *string, WORD *extent ); 
WORD  vqt_xfntinfo( WORD handle, WORD flags, WORD id, WORD index, XFNT_INFO *info ); 
WORD vst_name( WORD handle, WORD font_format, BYTE *font_name, BYTE *ret_name ); 
WORD  vqt_name_and_id( WORD handle, WORD font_format, BYTE *font_name, BYTE *ret_name ); 
