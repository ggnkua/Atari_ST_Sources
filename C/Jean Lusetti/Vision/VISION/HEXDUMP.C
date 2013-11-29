#include <string.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <ext.h>

#include "..\tools\gwindows.h"
#include "hexdump.h"
#include "actions.h"
#include "visionio.h"
#include "touches.h"
#include "defs.h"

#define CURSOR_TIMER 400

#define DT_BYTE    0
#define DT_WORD    1
#define DT_LONG    2
#define DT_MIXED   3

typedef struct
{
  char          filename[2*PATH_MAX] ;
  unsigned char *raw_data ;
  long          len ;
  long          modulo ;

  unsigned char **formatted_txt ;
  long          ystart_fmt ;

  long selection_index ;
  long selection_len ;

  long xcursor ;
  long ycursor ;

  int  nb_digits ;
  char fmt[300] ;
  int  nb_bytes_for_hexa_dump ;
  int  w_char, h_char ;
  int  total_nb_char_on_line, nb_char_on_line ;
  long nb_lines_on_window, nb_max_lines_on_window, total_nb_lines ;
  long ystart ;
  int  interline ;
  int  xstart ;

  TEXT_TYPE ttype ;

  char modif ;
  char has_focus ;
  char sel_is_xor ;
  char display_type ;
  int  nb_raw_bytes_on_line ;

  char   *raw_offset_array ;
  size_t sizeof_raw_offset_array ;
}
HEX_DUMP ;


/* Format de la ligne (apres affichage de l'offset) :         */
/* xx xx xx xx xx xx xx xx  xx xx xx xx xx xx xx xx  aaaaaaaa */
static char mixed_roa[] = {/* 0  1   2  3  4   5  6  7   8  9 10  11 12 13  14 15 16  17 18 19  20 21 22  23 */
                              0, 0, -1, 1, 1, -1, 2, 2, -1, 3, 3, -1, 4, 4, -1, 5, 5, -1, 6, 6, -1, 7, 7, -1,
                           /* 24                                                                             */
                              -1,
                           /*25 26  27 28 29  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44  45  46  47  48 */
                              8, 8, -1, 9, 9, -1, 10, 10, -1, 11, 11, -1, 12, 12, -1, 13, 13, -1, 14, 14, -1, 15, 15, -1,
                           /* 49                                                                             */
                              -1,
                           /*50                                                  */
                             0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
                         } ;

/* xxxx xxxx xxxx xxxx  xxxx xxxx xxxx xxxx */
static char word_roa[] = {
                            0, 0, 1, 1, -1, 2, 2, 3, 3, -1, 4, 4, 5, 5, -1, 6, 6, 7, 7, -1,
                           -1,
                            8, 8, 9, 9, -1, 10, 10, 11, 11, -1, 12, 12, 13, 13, -1, 14, 14, 15, 15
                         } ;

/* xxxxxxxx xxxxxxxx  xxxxxxxx xxxxxxxx */
static char long_roa[] = {
                            0, 0, 1, 1, 2, 2, 3, 3, -1, 4, 4, 5, 5, 6, 6, 7, 7, -1,
                           -1,
                            8, 8, 9, 9, 10, 10, 11, 11, -1, 12, 12, 13, 13, 14, 14, 15, 15
                         } ;

static char *GetRawOffsetArray(char display_type, size_t *sizeofarray)
{
  char *raw_offset_array ;

  switch( display_type )
  {
    case DT_WORD : raw_offset_array = word_roa ;
                   *sizeofarray     = sizeof(word_roa) ;
                   break ;

    case DT_LONG : raw_offset_array = long_roa ;
                   *sizeofarray     = sizeof(long_roa) ;
                   break ;

    default      : raw_offset_array = mixed_roa ;
                   *sizeofarray     = sizeof(mixed_roa) ;
                   break ;
  }

  return( raw_offset_array ) ;
}

static int GetRawOffsetForXCursor(HEX_DUMP *hex_dump, long xcursor)
{
  int raw_offset = -2 ;

  if ( ( xcursor >= 0 ) && ( xcursor < hex_dump->sizeof_raw_offset_array ) ) raw_offset = hex_dump->raw_offset_array[xcursor] ;

  return( raw_offset ) ;
}

static long GetOffset(HEX_DUMP *hex_dump, long x, long y)
{
  return( y * hex_dump->nb_raw_bytes_on_line + x ) ;
}

static void CheckXCursorValid(HEX_DUMP *hex_dump, int plus)
{
  long offset ;
  int  raw_offset ;

  raw_offset = GetRawOffsetForXCursor( hex_dump, hex_dump->xcursor ) ;
  switch( raw_offset )
  {
    case -2 : if ( plus ) hex_dump->xcursor = hex_dump->sizeof_raw_offset_array - 1 ;
              else        hex_dump->xcursor = 0 ;
              break ;

    case -1 : if ( plus ) hex_dump->xcursor++ ;
              else        hex_dump->xcursor-- ;
              raw_offset = GetRawOffsetForXCursor( hex_dump, hex_dump->xcursor ) ; /* Possibilite de deux -1 adjacents */
              if ( raw_offset == -1 )
              {
                if ( plus ) hex_dump->xcursor++ ;
                else        hex_dump->xcursor-- ;
              }
    default : 
              break ;
  }

  offset = GetOffset( hex_dump, raw_offset, hex_dump->ycursor ) ;
  while ( ( offset >= hex_dump->len ) && ( hex_dump->xcursor > 0 ) )
  {
    do
    {
      hex_dump->xcursor-- ;
      raw_offset = GetRawOffsetForXCursor( hex_dump, hex_dump->xcursor ) ;
    }
    while ( ( raw_offset < 0 ) && ( hex_dump->xcursor > 0 ) ) ;
    offset = GetOffset( hex_dump, raw_offset, hex_dump->ycursor ) ;
  }
}

static void CheckYCursorValid(HEX_DUMP *hex_dump)
{
  if ( hex_dump->ycursor >= hex_dump->total_nb_lines ) hex_dump->ycursor = hex_dump->total_nb_lines - 1 ;
  if ( hex_dump->ycursor < 0 ) hex_dump->ycursor = 0 ;

  if ( hex_dump->ycursor < hex_dump->ystart ) hex_dump->ystart = hex_dump->ycursor ;
  if ( hex_dump->ycursor >= hex_dump->ystart + hex_dump->nb_lines_on_window )
    hex_dump->ystart = 1 + hex_dump->ycursor - hex_dump->nb_lines_on_window ;
}

static void SetModif(GEM_WINDOW *gwnd, char modif)
{
  HEX_DUMP *hex_dump = (HEX_DUMP *) gwnd->Extension ;

  if ( hex_dump->modif != modif )
  {
    char buf[300] ;

    hex_dump->modif = modif ;
    if ( modif ) sprintf( buf, "* %s", hex_dump->filename ) ;
    else         sprintf( buf, "%s", hex_dump->filename ) ;
    GWSetWindowCaption( gwnd, buf ) ;
  }
}

static void SaveFile(GEM_WINDOW *gwnd, int save_as)
{
  HEX_DUMP *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  FILE     *stream ;
  int      err = 0 ;
  char     filename[2*PATH_MAX] ;

  if ( save_as == 0 ) strcpy( filename, hex_dump->filename ) ;
  else
  {
    char path[2*PATH_MAX] ;

    if ( *last_path == 0 ) sprintf( path, "%s\\*.*", config.path_img ) ;
    else                   sprintf( path, "%s\\*.*", last_path ) ;

    if ( file_name( path, "", filename ) == 0 ) return ;
  }

  stream = fopen( filename, "wb" ) ;
  if ( stream == NULL ) form_stop(1, msg[MSG_WRITEERROR]) ;
  else
  {
    if ( hex_dump->len < 512L*1024L ) err = ( fwrite( hex_dump->raw_data, hex_dump->len, 1, stream ) != 1 ) ;
    else
    {
      size_t offset = 0 ;
      size_t packet_size = 64L*1024L ;
      int    pc ;

      while ( !err && ( offset < hex_dump->len ) )
      {
        if ( offset + packet_size > hex_dump->len )
          packet_size = hex_dump->len - offset ;
        err = ( fwrite( &hex_dump->raw_data[offset], sizeof(char), packet_size, stream ) != packet_size ) ;
        offset += packet_size ;
        pc      = (int) (( 100L * offset ) / hex_dump->len) ;
        gwnd->ProgPc( gwnd, pc, "" ) ;
      }
      GWSetWindowInfo( gwnd, "" ) ;
    }
    if ( err ) form_stop(1, msg[MSG_WRITEERROR]) ;
  }

  if ( !err ) SetModif( gwnd, 0 ) ;

  if ( stream) fclose( stream ) ;
}

static int OnClose(void *wnd)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  int        code = GW_EVTCONTINUEROUTING ;

  if ( hex_dump->modif )
  {
    if ( form_interrogation(1, msg[MSG_IMAGECHANGE] ) == 1 )
      SaveFile( gwnd, 0 ) ;
  }

  free( hex_dump->formatted_txt ) ;
  free( hex_dump->raw_data ) ;
  GWOnClose( gwnd ) ;

  return( code ) ;
}

static void CheckValid(HEX_DUMP *hex_dump)
{
  if ( hex_dump->xstart + hex_dump->nb_char_on_line >= hex_dump->total_nb_char_on_line )
    hex_dump->xstart = hex_dump->total_nb_char_on_line - hex_dump->nb_char_on_line ;
  if ( hex_dump->xstart < 0 ) hex_dump->xstart = 0 ;

  if ( hex_dump->ystart + hex_dump->nb_lines_on_window >= hex_dump->total_nb_lines )
    hex_dump->ystart = hex_dump->total_nb_lines - hex_dump->nb_lines_on_window ;

  if ( hex_dump->ystart < 0 ) hex_dump->ystart = 0 ;

  if ( hex_dump->ycursor < hex_dump->ystart ) hex_dump->ycursor = hex_dump->ystart ;
  if ( hex_dump->ycursor >= hex_dump->ystart + hex_dump->nb_lines_on_window )
    hex_dump->ycursor = hex_dump->ystart + hex_dump->nb_lines_on_window - 1 ;
}

static int SetupNbLines(HEX_DUMP *hex_dump, int h)
{
  int htline, h_result ;

  htline                       = hex_dump->h_char + hex_dump->interline ;
  hex_dump->nb_lines_on_window = h / htline ;
  if ( hex_dump->nb_lines_on_window > hex_dump->total_nb_lines )
    hex_dump->nb_lines_on_window = hex_dump->total_nb_lines ;
  h_result = (int) (hex_dump->nb_lines_on_window * htline) ;

  CheckValid( hex_dump ) ;

  return( h_result ) ;
}

static void UpdateVSlider(GEM_WINDOW *gwnd)
{
  HEX_DUMP *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  int      pos, size ;

  pos  = (int) (1000L*hex_dump->ystart/(hex_dump->total_nb_lines-hex_dump->nb_lines_on_window-1)) ;
  GWSetVSlider( gwnd, pos ) ;
  size = (int) (1000L*hex_dump->nb_lines_on_window/hex_dump->total_nb_lines) ;
  GWSetVSliderSize( gwnd, size ) ;
}

static void FormatLine(HEX_DUMP *hex_dump, long line)
{
  long           i, j ;
  long           offset = line * (long)hex_dump->nb_raw_bytes_on_line ;
  unsigned char  *buf   = hex_dump->formatted_txt[line-hex_dump->ystart_fmt] ;
  unsigned char  *c     = &hex_dump->raw_data[offset] ;
  unsigned short *w ;
  unsigned long  *l ;

  switch( hex_dump->display_type )
  {
    case DT_MIXED : sprintf( (char*)buf, hex_dump->fmt, offset, c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15] ) ;
                    j = hex_dump->nb_bytes_for_hexa_dump - 3 ;
                    if ( offset + hex_dump->nb_raw_bytes_on_line >= hex_dump->len )
                    {
                      for ( i = 0; i < hex_dump->modulo; i++, j-- )
                      {
                        if ( i == 8 ) j-- ;
                        buf[j--] = ' ' ;
                        buf[j--] = ' ' ;
                      }
                    }
                    j = hex_dump->nb_bytes_for_hexa_dump ;
                    for ( i = 0; i < hex_dump->nb_raw_bytes_on_line; i++, j++ )
                    if ( isprint( c[i] ) ) buf[j] = c[i] ;
                    else                   buf[j] = '.' ;
                    buf[j] = 0 ;
                    break ;

    case DT_WORD  : w = (unsigned short *) c ;
                    sprintf( (char*)buf, hex_dump->fmt, offset, w[0], w[1], w[2], w[3], w[4], w[5], w[6], w[7] ) ;
                    break ;

    case DT_LONG  : l = (unsigned long *) c ;
                    sprintf( (char*)buf, hex_dump->fmt, offset, l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7] ) ;
                    break ;
  }
}

static void ShowCursor(GEM_WINDOW *gwnd, char show)
{
  HEX_DUMP *hex_dump = (HEX_DUMP *) gwnd->Extension ;

  if ( hex_dump->sel_is_xor != show )
  {
    int xy[8] ;
    int x, y, w, h, htline ;

    htline = hex_dump->h_char + hex_dump->interline ;
    GWGetWorkXYWH( gwnd, &x, &y, &w, &h ) ;
    xy[0] = xy[4] = x + ( hex_dump->nb_digits + 2 + (int)hex_dump->xcursor ) * hex_dump->w_char ;
    xy[1] = xy[5] = y + (int)(hex_dump->ycursor - hex_dump->ystart)* htline ;
    xy[2] = xy[6] = xy[0] + hex_dump->w_char - 1 ;
    xy[3] = xy[7] = xy[1] + hex_dump->h_char - 1 ;
    v_hide_c( handle ) ;
    vro_cpyfm( handle, D_INVERT, xy, &screen, &screen ) ;
    v_show_c( handle, 1 ) ;
    hex_dump->sel_is_xor = show ;
  }
}

static void OnDraw(void *wnd, int xywh[4])
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  char       *txt ;
  int        x, y, w, h ;
  int        htline ;
  long       line, sline, eline, char_offset ;

  set_texttype( &hex_dump->ttype ) ;
  vswr_mode( handle, MD_REPLACE ) ;
  sline  = eline = hex_dump->ystart ;
  htline = hex_dump->h_char + hex_dump->interline ;
  GWGetWorkXYWH( gwnd, &x, &y, &w, &h ) ;
  sline += ( xywh[1] - y ) / htline ;
  eline += ( xywh[1] - y + xywh[3] - 1 ) / htline ;
  y          += (int)(sline - hex_dump->ystart) * htline ;
  char_offset = ( xywh[0] - x ) / hex_dump->w_char ;
  x          += (int)char_offset * hex_dump->w_char ;
  if ( ( hex_dump->ycursor >= sline ) && ( hex_dump->ycursor <= eline ) )
    ShowCursor( gwnd, 0 ) ;
  for ( line = sline; line <= eline; line++, y += htline )
  {
    txt  = (char*) hex_dump->formatted_txt[line-hex_dump->ystart] ;
    txt += char_offset ;
    v_gtext( handle, x, y, txt ) ;
  }
}

static void SmartRePaint(GEM_WINDOW *gwnd, long old_ystart)
{
  HEX_DUMP      *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  long          i, dy, line_size ;
  int           xy[8], xyr[8], xyc[4] ;
  int           rx, ry, rw, rh, x, y, w, h  ;
  int           htline ;
  int           smart_possible = 0 ;
  unsigned char *fmt_txt = (unsigned char*)hex_dump->formatted_txt + hex_dump->nb_max_lines_on_window * sizeof(char*) ;

  wind_get( gwnd->window_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh ) ;
  GWGetWorkXYWH( gwnd, &x, &y, &w, &h ) ;
  if ( ( rx == x ) && ( ry == y ) && ( rw == w ) && ( rh == h ) ) smart_possible = 1 ;

  hex_dump->ystart_fmt = hex_dump->ystart ;
  if ( smart_possible )
  {
    line_size = 1L + hex_dump->total_nb_char_on_line ;
    htline    = hex_dump->h_char + hex_dump->interline ;
    dy        = hex_dump->ystart - old_ystart ;
    if ( labs( dy ) < hex_dump->nb_lines_on_window )
    {
      xy[0]  = xy[4] = xyr[0] = x ;
      xy[2]  = xy[6] = xyr[2] = x + w - 1 ;
      if ( dy > 0 )
      {
        xy[1]  = y + (int)dy * htline ;
        xy[3]  = y + (int)hex_dump->nb_lines_on_window * htline - 1 ;
        xy[5]  = y ;
        xy[7]  = y + (int)( hex_dump->nb_lines_on_window - dy ) * htline - 1 ;
        xyr[1] = 1 + xy[7] ;
        xyr[3] = (int)dy * htline - 1 ;
        memmove( fmt_txt, fmt_txt + dy * line_size, ( hex_dump->nb_lines_on_window - dy ) * line_size ) ;
        for ( i = dy; i > 0; i-- ) FormatLine( hex_dump, old_ystart + hex_dump->nb_lines_on_window + i - 1 ) ;
      }
      else
      {
        xy[1]  = y ;
        xy[3]  = y + (int)( hex_dump->nb_lines_on_window + dy ) * htline - 1 ;
        xy[5]  = y - (int)dy * htline ;
        xy[7]  = y + (int)hex_dump->nb_lines_on_window * htline - 1 ;
        xyr[1] = xy[1] ;
        xyr[3] = (int)( hex_dump->nb_lines_on_window + dy ) * htline  - 1 ;
        memmove( fmt_txt - dy * line_size, fmt_txt, ( hex_dump->nb_lines_on_window + dy ) * line_size ) ;
        for ( i = dy; i < 0; i++ ) FormatLine( hex_dump, old_ystart + i ) ;
      }
      v_hide_c( handle ) ;
      vro_cpyfm( handle, S_ONLY, xy, &screen, &screen ) ;
      xyc[0] = x ; xyc[1] = y ; xyc[2] = x + w - 1 ; xyc[3] = y + h - 1 ;
      vs_clip( handle, 1, xyc ) ;
      OnDraw( gwnd, xyr ) ;
      vs_clip( handle, 0, xyc ) ;
      v_show_c( handle, 1 ) ;
    }
    else smart_possible = 0 ;
  }

  if ( !smart_possible )
  {
    for ( i = hex_dump->ystart_fmt; i < hex_dump->ystart_fmt + hex_dump->nb_lines_on_window; i++ )
      FormatLine( hex_dump, i ) ;
    GWRePaint( gwnd ) ;
  }
  UpdateVSlider( gwnd ) ;
}

static void SmartInfos(GEM_WINDOW *gwnd)
{
  HEX_DUMP *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  long     offset ;
  int      raw_offset ;
  char     buf[60] ;
  char     hexa_ascii ;

  raw_offset = hex_dump->raw_offset_array[hex_dump->xcursor] ;
  offset     = GetOffset( hex_dump, raw_offset, hex_dump->ycursor ) ;
  hexa_ascii = ( hex_dump->xcursor >= hex_dump->sizeof_raw_offset_array - hex_dump->nb_raw_bytes_on_line ) ? 'A' : 'H' ;
  sprintf( buf, "%c[%d,%ld], offset %ld ($%lX)", hexa_ascii, raw_offset, hex_dump->ycursor, offset, offset ) ;
  GWSetWindowInfo( gwnd, buf ) ;
}

static int KeyPressed(HEX_DUMP *hex_dump, long offset, int key, unsigned char *new_val)
{
  int input_valid = 0 ;

  if ( ( hex_dump->display_type == DT_MIXED ) && ( hex_dump->xcursor >= 50 ) )
    if ( isprint( key ) ) input_valid = 2 ;

  if ( input_valid != 2 )
  {
    key = toupper( key ) ;
    if ( isdigit( key ) )
    {
      input_valid = 1 ;
      key        -= '0' ;
    }
    else if ( ( key >= 'A' ) && ( key <= 'F' ) )
    {
      input_valid = 1 ;
      key        -= 'A' ;
      key        += 0x0A ;
    }
  }

  if ( input_valid == 1 )
  {
    *new_val = hex_dump->raw_data[offset] ;
    if ( ( hex_dump->xcursor != 0 ) && ( hex_dump->raw_offset_array[hex_dump->xcursor-1] == hex_dump->raw_offset_array[hex_dump->xcursor] ) )
      *new_val &= 0xF0 ;
    else
    {
      *new_val &= 0x0F ;
      key     <<= 4 ;
    }
    *new_val |= (unsigned char) key ;
  }
  else if ( input_valid == 2 ) *new_val = (unsigned char) key ;

  return( input_valid ) ;
}

static long SearchNextBlock(HEX_DUMP *hex_dump, long xcursor, long add)
{
  long new_xcursor = -1 ;
  char *roa = hex_dump->raw_offset_array ;

  while ( ( xcursor >= 0 ) && ( xcursor < hex_dump->sizeof_raw_offset_array ) && ( new_xcursor == -1 ) )
  {
    if ( roa[xcursor] == -1 )
    {
      new_xcursor = xcursor + add ;
      while ( ( new_xcursor >= 0 ) && ( new_xcursor < hex_dump->sizeof_raw_offset_array ) && ( roa[new_xcursor] == -1 ) )
        new_xcursor += add ;
    }
    else xcursor    += add ;
  }

  if ( new_xcursor <= 0 ) new_xcursor = 0 ;
  else if ( new_xcursor > hex_dump->sizeof_raw_offset_array-1 ) new_xcursor = hex_dump->sizeof_raw_offset_array-1 ;

  return( new_xcursor ) ;
}

static int OnKeyPressed(void *wnd, int key)
{
  GEM_WINDOW    *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP      *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  long          old_xcursor, old_ycursor, old_ystart, offset ;
  int           htline, code = GW_EVTCONTINUEROUTING ;
  unsigned char new_val, input_valid = 0, plus = 0 ;

  old_xcursor = hex_dump->xcursor ;
  old_ycursor = hex_dump->ycursor ;
  old_ystart  = hex_dump->ystart ;
  ShowCursor( gwnd, 0 ) ;
  switch( key )
  {
	case FERMER      : gwnd->OnClose( gwnd ) ;
                       code = GW_EVTSTOPROUTING ;
				  	   break ;

	case SAUVE       : SaveFile( gwnd, 0 ) ;
                       code = GW_EVTSTOPROUTING ;
					   break ;

	case SAUVES      : SaveFile( gwnd, 1 ) ;
                       code = GW_EVTSTOPROUTING ;
  					   break ;

    case CURSOR_RT :   hex_dump->xcursor++ ;
                       if ( hex_dump->xcursor >= hex_dump->sizeof_raw_offset_array ) hex_dump->xcursor = hex_dump->sizeof_raw_offset_array - 1 ;
                       plus = 1 ;
                       code = GW_EVTSTOPROUTING ;
                       break ;

    case CURSOR_SLT :  hex_dump->xcursor = SearchNextBlock( hex_dump, hex_dump->xcursor, -1L ) ;
                       code = GW_EVTSTOPROUTING ;
                       break ;

    case CURSOR_LT :   hex_dump->xcursor-- ;
                       if ( hex_dump->xcursor < 0 ) hex_dump->xcursor = 0 ;
                       code = GW_EVTSTOPROUTING ;
                       break ;

    case CURSOR_SRT :  hex_dump->xcursor = SearchNextBlock( hex_dump, hex_dump->xcursor, 1L ) ;
                       code = GW_EVTSTOPROUTING ;
                       break ;

    case CURSOR_UP :   hex_dump->ycursor-- ;
                       if ( hex_dump->ycursor < 0 ) hex_dump->ycursor = 0 ;
                       code = GW_EVTSTOPROUTING ;
                       break ;

    case CURSOR_SUP :  hex_dump->ystart  -= hex_dump->nb_lines_on_window ;
                       hex_dump->ycursor -= hex_dump->nb_lines_on_window ;
                       code = GW_EVTSTOPROUTING ;
                       break ; 

    case CURSOR_DN :   hex_dump->ycursor++ ;
                       if ( hex_dump->ycursor > hex_dump->total_nb_lines ) hex_dump->ycursor = hex_dump->total_nb_lines ;
                       code = GW_EVTSTOPROUTING ;
                       break ;

    case CURSOR_SDN :  hex_dump->ystart  += hex_dump->nb_lines_on_window ;
                       hex_dump->ycursor += hex_dump->nb_lines_on_window ;
                       code = GW_EVTSTOPROUTING ;
                       break ; 

    default         :  offset = GetOffset( hex_dump, GetRawOffsetForXCursor( hex_dump, hex_dump->xcursor ), hex_dump->ycursor ) ;
                       key   &= 0xFF ;
                       input_valid = KeyPressed( hex_dump, offset, key, &new_val ) ;
                       if ( input_valid )
                       {
                         int xy[4] ;

                         hex_dump->raw_data[offset] = new_val ;
                         FormatLine( hex_dump, hex_dump->ycursor ) ;
                         hex_dump->xcursor++ ;
                         if ( hex_dump->xcursor >= hex_dump->sizeof_raw_offset_array ) hex_dump->xcursor = hex_dump->sizeof_raw_offset_array - 1 ;
                         htline = hex_dump->h_char + hex_dump->interline ;
                         GWGetWorkXYWH( gwnd, &xy[0], &xy[1], &xy[2], &xy[3] ) ;
                         xy[1] += (int)( hex_dump->ycursor - hex_dump->ystart ) * htline ;
                         xy[3]  = htline ;
                         v_hide_c( handle ) ;
                         OnDraw( gwnd, xy ) ;
                         v_show_c( handle, 1 ) ;
                         plus = 1 ;
                         SetModif( gwnd, 1 ) ;
                         code = GW_EVTSTOPROUTING ;
                       }
                       break ;
  }

  CheckYCursorValid( hex_dump ) ;
  CheckXCursorValid( hex_dump, plus ) ;
  CheckValid( hex_dump ) ;

  if ( ( old_xcursor != hex_dump->xcursor ) || ( old_ycursor != hex_dump->ycursor ) ) SmartInfos( gwnd ) ;
  if ( old_ystart != hex_dump->ystart ) SmartRePaint( gwnd, old_ystart ) ;

  return( code ) ;
}

static int OnMenuSelected(void *wnd, int t_id, int m_id)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  int        code = GW_EVTSTOPROUTING ;

  switch( m_id )
  {
	case M_FERME : gwnd->OnClose( wnd ) ;
                   break ;

	case M_SAUVE : SaveFile( gwnd, 0 ) ;
	               break ;

	case M_SAUVES : SaveFile( gwnd, 1 ) ;
	                break ;

    default       : code = GW_EVTCONTINUEROUTING ;
                    break ;
  }

  GWOnMenuSelected( t_id, m_id ) ;

  return( code ) ;
}

static void OnArrow(void *wnd, int action)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  long       old_xcursor, old_ycursor, old_ystart ;

  old_xcursor = hex_dump->xcursor ;
  old_ycursor = hex_dump->ycursor ;
  old_ystart  = hex_dump->ystart ;

  switch( action )
  {
    case WA_UPPAGE : OnKeyPressed( wnd, CURSOR_SUP ) ;
                     break ;

    case WA_DNPAGE : OnKeyPressed( wnd, CURSOR_SDN ) ;
                     break ;

    case WA_UPLINE : if ( hex_dump->ystart > 0 ) hex_dump->ystart-- ;
                     break ;

    case WA_DNLINE : if ( hex_dump->ystart < hex_dump->total_nb_lines - hex_dump->nb_lines_on_window ) hex_dump->ystart++ ;
                     break ;
  }

  CheckValid( hex_dump ) ;

  if ( ( old_xcursor != hex_dump->xcursor ) || ( old_ycursor != hex_dump->ycursor ) ) SmartInfos( gwnd ) ;
  if ( old_ystart != hex_dump->ystart ) SmartRePaint( gwnd, old_ystart ) ;
}

static void OnVSlider(void *wnd, int pos)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  long       old_xcursor, old_ycursor, old_ystart ;

  old_xcursor = hex_dump->xcursor ;
  old_ycursor = hex_dump->ycursor ;
  old_ystart  = hex_dump->ystart ;

  hex_dump->ystart = ((long)pos * ( hex_dump->total_nb_lines - hex_dump->nb_lines_on_window )) / 1000L ;

  CheckValid( hex_dump ) ;

  if ( ( old_xcursor != hex_dump->xcursor ) || ( old_ycursor != hex_dump->ycursor ) ) SmartInfos( gwnd ) ;
  if ( old_ystart != hex_dump->ystart ) SmartRePaint( gwnd, old_ystart ) ;
}

static void OnSize(void *wnd, int xywh[4])
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  long       old_xcursor, old_ycursor, old_ystart ;
  int        x, y, w, h, w_max ;

  old_xcursor = hex_dump->xcursor ;
  old_ycursor = hex_dump->ycursor ;
  old_ystart  = hex_dump->ystart ;

  GWGetCurrXYWH( gwnd, &x, &y, &w, &h ) ;
  wind_calc( WC_WORK, gwnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &x, &y, &w, &h ) ;
  w_max = hex_dump->nb_char_on_line * hex_dump->w_char ;
  h     = SetupNbLines( hex_dump, h ) ;

  CheckValid( hex_dump ) ;

  if ( ( old_xcursor != hex_dump->xcursor ) || ( old_ycursor != hex_dump->ycursor ) ) SmartInfos( gwnd ) ;
  if ( old_ystart != hex_dump->ystart ) SmartRePaint( gwnd, old_ystart ) ;

  if ( w > w_max ) w = w_max ;
  wind_calc( WC_BORDER, gwnd->window_kind, x, y, w, h, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  GWOnSize( wnd, xywh ) ;
  UpdateVSlider( gwnd ) ;
}

static int OnFulled(void *wnd)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  long       old_xcursor, old_ycursor, old_ystart ;
  int        xywh[4], cxywh[4] ;
  int        w_max ;

  old_xcursor = hex_dump->xcursor ;
  old_ycursor = hex_dump->ycursor ;
  old_ystart  = hex_dump->ystart ;

  cxywh[0] = xdesk ; cxywh[1] = ydesk ;
  cxywh[2] = wdesk ; cxywh[3] = hdesk ;
  wind_calc( WC_WORK, gwnd->window_kind, cxywh[0], cxywh[1], cxywh[2], cxywh[3], &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  xywh[3] = SetupNbLines( hex_dump, xywh[3] ) ;

  CheckValid( hex_dump ) ;

  if ( ( old_xcursor != hex_dump->xcursor ) || ( old_ycursor != hex_dump->ycursor ) ) SmartInfos( gwnd ) ;
  if ( old_ystart != hex_dump->ystart ) SmartRePaint( gwnd, old_ystart ) ;

  w_max = hex_dump->nb_char_on_line * hex_dump->w_char ;
  if ( xywh[2] > w_max ) xywh[2] = w_max ;
  wind_calc( WC_BORDER, gwnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &cxywh[0], &cxywh[1], &cxywh[2], &cxywh[3] ) ;
  GWOnFulled( wnd, cxywh ) ;
  UpdateVSlider( gwnd ) ;

  return( 0 ) ;
}

static int OnRestoreFulled(void *wnd)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  long       old_xcursor, old_ycursor, old_ystart ;
  int        xywh[4], cxywh[4] ;

  old_xcursor = hex_dump->xcursor ;
  old_ycursor = hex_dump->ycursor ;
  old_ystart  = hex_dump->ystart ;
  ShowCursor( gwnd, 0 ) ;

  wind_get( gwnd->window_handle, WF_PREVXYWH, &cxywh[0], &cxywh[1], &cxywh[2], &cxywh[3] ) ;
  wind_calc( WC_WORK, gwnd->window_kind, cxywh[0], cxywh[1], cxywh[2], cxywh[3], &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  xywh[3] = SetupNbLines( hex_dump, xywh[3] ) ;

  CheckValid( hex_dump ) ;

  if ( ( old_xcursor != hex_dump->xcursor ) || ( old_ycursor != hex_dump->ycursor ) ) SmartInfos( gwnd ) ;
  if ( old_ystart != hex_dump->ystart ) SmartRePaint( gwnd, old_ystart ) ;

  wind_calc( WC_BORDER, gwnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &cxywh[0], &cxywh[1], &cxywh[2], &cxywh[3] ) ;
  GWOnRestoreFulled( wnd, cxywh ) ;
  UpdateVSlider( gwnd ) ;

  return( GW_EVTSTOPROUTING ) ;
}

static int OnIconify(void *wnd, int xywh[4])
{
  GWOnIconify( wnd, xywh ) ;

  return( 0 ) ;
}

static int OnUnIconify(void *wnd, int xywh[4])
{
  GWOnUnIconify( wnd, xywh ) ;
  PostMessage( wnd, WM_TOPPED, NULL ) ;

  return( GW_EVTSTOPROUTING ) ;
}
#pragma warn -par

static int OnLButtonDown(void *wnd, int mk_state, int xm, int ym)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;
  int        x, y, w, h, htline ;
  long       xcursor, ycursor ;
  long       old_xcursor, old_ycursor ;

  if ( gwnd->is_icon ) return( 0 ) ;

  old_xcursor = hex_dump->xcursor ;
  old_ycursor = hex_dump->ycursor ;
  GWGetWorkXYWH( gwnd, &x, &y, &w, &h ) ;
  ShowCursor( gwnd, 0 ) ;
  htline   = hex_dump->h_char + hex_dump->interline ;
  xcursor  = xm / hex_dump->w_char ;
  xcursor -= hex_dump->nb_digits + 2 ;
  ycursor  = hex_dump->ystart + ym / htline ;
  hex_dump->xcursor = xcursor ;
  hex_dump->ycursor = ycursor ;
  CheckYCursorValid( hex_dump ) ;
  CheckXCursorValid( hex_dump, 0 ) ;

  if ( ( old_xcursor != hex_dump->xcursor ) || ( old_ycursor != hex_dump->ycursor ) ) SmartInfos( gwnd ) ;

  return( GW_EVTSTOPROUTING ) ;
}

static int OnDLButtonDown(void *wnd, int mk_state, int x, int y)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;

  if ( gwnd->is_icon ) return( 0 ) ;

  return( GW_EVTSTOPROUTING ) ;
}

static int OnRButtonDown(void *w, int mk_state, int x, int y)
{
  GEM_WINDOW *wnd = w ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) wnd->Extension ;
  OBJECT     *popup ;
  int        clicked ;
  int        i, mx, my, dummy ;

  popup = popup_make( 4, 15 ) ;
  if ( popup == NULL ) return( 0 ) ;

  i = 0 ;
  strcpy( popup[++i].ob_spec.free_string, "  Byte    " ) ;
  strcpy( popup[++i].ob_spec.free_string, "  Word    " ) ;
  strcpy( popup[++i].ob_spec.free_string, "  Long    " ) ;
  strcpy( popup[++i].ob_spec.free_string, "  Find... " ) ;

  if ( ( hex_dump->display_type >= DT_BYTE ) && ( hex_dump->display_type <= DT_MIXED ) )
    popup[hex_dump->display_type].ob_spec.free_string[0] = 8 ;

  graf_mkstate( &mx, &my, &dummy, &dummy ) ;
  clicked = popup_formdo( &popup, mx-16, my, 1, 0 ) ;
  popup_kill( popup, 4 ) ;

  if ( clicked >= 0 )
  {
  }

  return( GW_EVTSTOPROUTING ) ;
}
#pragma warn +par

static int OnProgPc(void *wnd, int pc, char *txt)
{
  char buf[100] ;

  if ( ( pc < 100 ) && txt ) sprintf( buf, "%s (%d %%)...", txt, pc ) ;
  else                       buf[0] = 0 ;

  GWSetWindowInfo( wnd, buf ) ;

  return( 0 ) ;
}

static int OnTopped(void *wnd)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;

  hex_dump->has_focus = 1 ;
  GWOnTopped( wnd ) ;
  GWSetTimer( gwnd, CURSOR_TIMER ) ;
  SmartInfos( gwnd ) ;

  return( 0 ) ;
}

static int OnUnTopped(void *wnd)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;

  hex_dump->has_focus = 0 ;
  GWKillTimer( gwnd ) ;
  ShowCursor( gwnd, 0 ) ;
  GWSetWindowInfo( gwnd, "" ) ;

  return( 0 ) ;
}

#pragma warn -par
static int OnTimer(void *wnd, int mx, int my)
{
  GEM_WINDOW *gwnd = (GEM_WINDOW *) wnd ;
  HEX_DUMP   *hex_dump = (HEX_DUMP *) gwnd->Extension ;

  if ( !gwnd->is_icon && hex_dump->has_focus ) ShowCursor( gwnd, 1 - hex_dump->sel_is_xor ) ;

  return( 0 ) ;
}
#pragma warn +par

static void AttachHexDumpToWindow(GEM_WINDOW *gwnd)
{
  HEX_DUMP *hex_dump = (HEX_DUMP *) gwnd->Extension ;

  /* R‚ponses aux ‚v‚nements */
  gwnd->OnClose         = OnClose ;
  gwnd->OnKeyPressed    = OnKeyPressed ;
  gwnd->OnMenuSelected  = OnMenuSelected ;
  gwnd->OnDraw          = OnDraw ;
  gwnd->OnArrow         = OnArrow ;
  gwnd->OnVSlider       = OnVSlider ;
  gwnd->OnSize          = OnSize ;
  gwnd->OnFulled        = OnFulled ;
  gwnd->OnRestoreFulled = OnRestoreFulled ;
  gwnd->OnIconify       = OnIconify ;
  gwnd->OnUnIconify     = OnUnIconify ;
  gwnd->OnLButtonDown   = OnLButtonDown ;
  gwnd->OnRButtonDown   = OnRButtonDown ;
  gwnd->OnDLButtonDown  = OnDLButtonDown ;
  gwnd->OnTopped        = OnTopped ;
  gwnd->OnUnTopped      = OnUnTopped ;
  gwnd->OnTimer         = OnTimer ;
  gwnd->ProgPc          = OnProgPc ;
  gwnd->flags          |= FLG_MUSTCLIP ;

  GWSetWindowCaption( gwnd, hex_dump->filename ) ;
  GWSetHSlider( gwnd, 0 ) ;
  GWSetHSliderSize( gwnd, 1000 ) ;
  UpdateVSlider( gwnd ) ;
}

void CreateTestFile(char *filename)
{
  FILE          *stream = fopen( filename, "wb" ) ;
  long          i ;
  unsigned char c = 0 ;

  if ( stream )
  {
    for ( i = 0; i < 64L*1024L + 17L; i++ ) fputc( c++, stream ) ;
    fclose( stream ) ;
  }
}

static int BuildFormatLine(HEX_DUMP *hex_dump, char display_type)
{
  int  nb_char_on_line ;
  char dfmtc[]  = "%.02X %.02X %.02X %.02X %.02X %.02X %.02X %.02X" ;
  char dfmtw[]  = "%.04X %.04X %.04X %.04X" ;
  char dfmtl[]  = "%.08lX %.08lX" ;
  char offfmt[] = "%.08lX:" ;

  hex_dump->display_type = display_type ;
  switch( display_type )
  {
    case DT_MIXED : sprintf( hex_dump->fmt, "%s %s  %s  ", offfmt, dfmtc, dfmtc ) ;
                    hex_dump->nb_raw_bytes_on_line = 16 ;
                    nb_char_on_line                = (2+1)*8 + 1 + (2+1)*8 + 2 + hex_dump->nb_raw_bytes_on_line ;
                    break ;

    case DT_WORD  : sprintf( hex_dump->fmt, "%s %s  %s", offfmt, dfmtw, dfmtw ) ;
                    hex_dump->nb_raw_bytes_on_line = 16 ;
                    nb_char_on_line                = (4+1)*4 + 1 + (4+1)*4 ;
                    break ;

    case DT_LONG  : sprintf( hex_dump->fmt, "%s %s  %s", offfmt, dfmtl, dfmtl ) ;
                    hex_dump->nb_raw_bytes_on_line = 16 ;
                    nb_char_on_line                = (8+1)*2 + 1 + (8+1)*2 ;
                    break ;
  }
  hex_dump->fmt[3]           = '0' + hex_dump->nb_digits ;
  hex_dump->nb_char_on_line  = nb_char_on_line + 1 + hex_dump->nb_digits ;
  hex_dump->raw_offset_array = GetRawOffsetArray( display_type, &hex_dump->sizeof_raw_offset_array ) ;

  return( nb_char_on_line ) ;
}

GEM_WINDOW *CreateHexDump(char *filename)
{
  HEX_DUMP      tmp_hex_dump ;
  GEM_WINDOW    *gwnd ;
  long          i, size, modulo ;
  int           xywh[4], cxywh[4] ;
  int           wkind ;
  char          buf[300] ;
  unsigned char *c ;

  wkind = NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE ;
  if ( !config.w_info ) wkind &= ~INFO ;
  wkind |= SMALLER ;
  gwnd   = GWCreateWindow( wkind, sizeof(HEX_DUMP), HEXDUMP_CLASSNAME ) ;
  if ( gwnd )
  {
    HEX_DUMP *hex_dump = (HEX_DUMP *) gwnd->Extension ;
    FILE     *stream ;
    long     len, alloc_size ;
    int      w, h, xo, yo, wo, ho ;

    strcpy( hex_dump->filename, filename ) ;
    stream = fopen( filename, "rb" ) ;
    if ( stream == NULL )
    {
      GWDestroyWindow( gwnd ) ;
      form_stop(1, msg[MSG_FILENOTEXIST]) ;
      return( NULL ) ;
    }
    hex_dump->len = filelength( fileno( stream ) ) ;
    for ( len = hex_dump->len, w = 0; w < 8; w++, len >>= 4, hex_dump->nb_digits++ )
      if ( len == 0 ) break ;

    BuildFormatLine( hex_dump, DT_MIXED ) ;
    alloc_size                 = hex_dump->len ;
    modulo                     = alloc_size % hex_dump->nb_raw_bytes_on_line ;
    if ( modulo ) alloc_size  += hex_dump->nb_raw_bytes_on_line ;
    hex_dump->raw_data         = (unsigned char *) malloc( alloc_size ) ;
    if ( hex_dump->raw_data == NULL )
    {
      fclose( stream ) ;
      GWDestroyWindow( gwnd ) ;
      form_error( 8 ) ;
      return( NULL ) ;
    }

    if ( modulo )
    {
      modulo = hex_dump->nb_raw_bytes_on_line - modulo ;
      memset( &hex_dump->raw_data[hex_dump->len], ' ', modulo ) ;
      hex_dump->modulo = modulo ;
    }
    hex_dump->ttype.hcar      = 13 ;
    hex_dump->ttype.angle     = 0 ;
    hex_dump->ttype.font      = 1 ;
    hex_dump->ttype.color     = 1 ;
    hex_dump->ttype.attribute = 0 ;
    hex_dump->ttype.hdisp     = 0 ;
    hex_dump->ttype.vdisp     = 5 ;
    set_texttype( &hex_dump->ttype ) ;
    hex_dump->w_char                = hex_dump->ttype.wcell ;
    hex_dump->h_char                = hex_dump->ttype.hcell ;
    hex_dump->interline             = 0 ;
    hex_dump->total_nb_char_on_line = hex_dump->nb_char_on_line ;
    hex_dump->total_nb_lines        = hex_dump->len / (long)hex_dump->nb_raw_bytes_on_line ;
    if ( hex_dump->len % hex_dump->nb_char_on_line ) hex_dump->total_nb_lines++ ;
    c = hex_dump->raw_data ;
    sprintf( buf, hex_dump->fmt, 0L, c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15] ) ;
    hex_dump->nb_bytes_for_hexa_dump = (int) strlen( buf ) ;

    BuildFormatLine( hex_dump, DT_MIXED ) ;
    w = hex_dump->nb_char_on_line * hex_dump->w_char ;
    h = (int) ((90L * (long)(Ymax-yopen)) / 100L) ;
    h = SetupNbLines( hex_dump, h ) ;

    cxywh[0] = xdesk ; cxywh[1] = ydesk ;
    cxywh[2] = wdesk ; cxywh[3] = hdesk ;
    wind_calc( WC_WORK, gwnd->window_kind, cxywh[0], cxywh[1], cxywh[2], cxywh[3], &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
    memcpy( &tmp_hex_dump, hex_dump, sizeof(HEX_DUMP) ) ;
    SetupNbLines( &tmp_hex_dump, xywh[3] ) ;
    hex_dump->nb_max_lines_on_window = tmp_hex_dump.nb_lines_on_window ;

    size = (sizeof(char*) + (long)hex_dump->total_nb_char_on_line + 1L) * hex_dump->nb_max_lines_on_window ;
    hex_dump->formatted_txt = (unsigned char**) calloc( 1, size ) ;
    if ( hex_dump->formatted_txt == NULL )
    {
      free( hex_dump->raw_data ) ;
      GWDestroyWindow( gwnd ) ;
      form_error( 8 ) ;
      return( NULL ) ;
    }
    open_where( gwnd->window_kind, w, h, &xo, &yo, &wo, &ho ) ;
    if ( GWOpenWindow( gwnd, xo, yo, wo, ho ) != 0 )
    {
      free( hex_dump->formatted_txt ) ;
      free( hex_dump->raw_data ) ;
      GWDestroyWindow( gwnd ) ;
      form_stop(1, msg[MSG_NOMOREWINDOW]) ;
      return( NULL ) ;
    }

    AttachHexDumpToWindow( gwnd ) ;

    if ( hex_dump->len > 512L*1024L )
    {
      size_t offset = 0 ;
      size_t packet_size = 64L*1024L ;
      int    pc ;

      while ( !feof( stream) && ( offset < hex_dump->len ) )
      {
        offset += fread( &hex_dump->raw_data[offset], sizeof(char), packet_size, stream ) ;
        pc      = (int) (( 100L * offset ) / hex_dump->len) ;
        gwnd->ProgPc( gwnd, pc, "" ) ;
      }
      GWSetWindowInfo( gwnd, "" ) ;
    }
    else fread( hex_dump->raw_data, hex_dump->len, 1, stream ) ;
    fclose( stream ) ;

    c = (unsigned char*) hex_dump->formatted_txt + hex_dump->nb_max_lines_on_window * sizeof(char*) ;
    hex_dump->ystart_fmt = 0 ;
    for ( i = hex_dump->ystart_fmt; i < hex_dump->ystart_fmt + hex_dump->nb_max_lines_on_window; i++, c += 1L + hex_dump->total_nb_char_on_line )
    {
      hex_dump->formatted_txt[i] = c ;
      FormatLine( hex_dump, i ) ;
    }
/*    CreateTestFile( "I:\\DUMP.HEX" ) ;*/
  }

  return( gwnd ) ;
}
