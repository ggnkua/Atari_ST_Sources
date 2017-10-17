/*
 * TOC_WIN.C - Fenêtre de lecture de TOC et d'extraction de piste
 *
 * Copyright 2004 Francois Galea
 * AU/SND and AIFFs files management by Yvan Doyeux ( 26/04/07 )
 * This file is part of CDLab.
 *
 * CDLab is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CDLab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <windom.h>
#include "rsc/cdlab.h"
#include "main.h"
#include "misc.h"
#include "prefs.h"
#include "device.h"
#include "common.h"
#include "dao.h"
#include "log.h"
#include "dev_win.h"
#include "toc_win.h"


#define LIST_HEIGHT 500
#define MAX_FRED_TOC 40
#define TW_MAGIC 'TOCW'

#define BUFSIZE 0x20000L    /* Taille du buffer pour l'extraction audio */

struct _field
{
  char tno[3];
  char beg_time[7];
  char end_time[7];
  TEDINFO beg_ted;
  TEDINFO end_ted;
};

struct _toc_data
{
  struct ext_toc toc;
  int n_tracks;       /* Nombre de pistes */
  int n_obj;          /* Nombre d'objets constituant une entrée dans l'arbre */
  OBJECT * tree;      /* Arbre de la liste des entrées */
  struct _field * f;  /* Adresse du texte de chaque TEDINFO */
};

struct popup_item fmt_popup_items[] =
{
  "AVR                      ", NULL,
  "TRK (big-endian)(RAW)    ", NULL,  /* YD 26/04/07 */
  "RAW (little-endian)      ", NULL,
  "WAVE                     ", NULL,
  "AU/SND                   ", NULL,  /* YD 26/04/07 */
  "AIFF                     ", NULL,  /* YD 26/04/07 */
  "AIFF Cubase Audio        ", NULL   /* YD 26/04/07 */
};
struct popup_str fmt_popup = { TTB_FORMAT, fmt_popup_items, 7, 0 };/* YD 26/04/07 */

struct popup_item toc_popup_items[ MAX_DEVICES ];
struct popup_str toc_popup;

struct
{
  char toc_fred[ MAX_FRED_TOC + 1 ];
  char toc_file[ 256 ];
} toc_info;


WINDOW * toc_win = NULL;

/* Retourne l'adresse logique à partir d'une position MSF en ASCII */
long toc_address( const char * txt )
{
  int m, s, f;
  char val[ 3 ];
  strncpy( val, txt, 2 );
  m = atoi( val );
  strncpy( val, txt+2, 2 );
  s = atoi( val );
  strncpy( val, txt+4, 2 );
  f = atoi( val );
  return logical( m, s, f );
}

void toc_extract( WINDOW * win )
{
  static const char * ext[] = { "avr", "trk", "raw", "wav", "snd", "aif", "aif" }; /* YD 26/04/07 */
  char pathname[ 256 ];
  char prog_info[ 64 ];
  char buf[ 512 ]; /* YD 26/04/07 */
  struct avr_header * avrh;
  struct wave_header * wavh;
  struct snd_header * sndh; /* YD 26/04/07 */
  struct aiff_header * aiffh; /* YD 26/04/07 */
  struct audio_entry entry;
  struct audio_stream * as;
  struct _toc_data * data;
  struct device_info * info;
  OBJECT * ck;
  int format, i, max, track_no;
  int fd, swap;
  long offset, length, position, end, progress, total_length, aiff_cubase_totalsize, aiff_cubase_currentsize, octets_a_remplir; /* YD 26/04/07 */
  long max_buf_blocks, nblocks;
  void * buffer;
  char fname[13] = ""; /* 26/04/07 */

  if( !fileselect( preferences.toc_dest, "", "TXT_EXTDEST" ) )
    return;

  strncpy ( fname, &strrchr( preferences.toc_dest, '\\' )[1] , 6 ); /* YD 26/04/07 */
  if ( strncmp ( "", fname, 6 ) == 0 )
  {
     strcpy( fname, "track" );
  }
  
  strrchr( preferences.toc_dest, '\\' )[1] = '\0';

  data = DataSearch( win, TW_MAGIC );
  max = data->n_tracks;
  format = fmt_popup.selected;
  total_length = 0;
  buffer = alloc_comm_buffer( BUFSIZE );
  if( !buffer )
    return;
  for( i = 0; i < max; i++ )
  {
    ck = data->tree + 1 + TF_CK + i * data->n_obj;
    if( ! (ck->ob_state & SELECTED) )
      continue;
    offset = toc_address( data->f[i].beg_time );
    length = toc_address( data->f[i].end_time ) + 1 - offset;
    if( length > 0 )
      total_length += length;
  }
  max_buf_blocks = BUFSIZE / 2352;

  progress = 0;
  progress_init( get_string( "TXT_EXTMSG" ), total_length );
  progress_activate_cancel( 1 );
  progress_init_timer();

  log_begin();
  log_printf( "*** Begin of a track extraction session\n\n" );
  as = NULL;
  for( i = 0; i < max; i++ )
  {
    ck = data->tree + 1 + TF_CK + i * data->n_obj;
    if( ! (ck->ob_state & SELECTED) )
      continue;
    offset = toc_address( data->f[i].beg_time );
    length = toc_address( data->f[i].end_time ) + 1 - offset;
    if( length <= 0 )
      continue;
    track_no = i + 1;
    position = get_track_offset( &data->toc, track_no, &end );
    if( toc_popup.selected == 0 )
      gen_daoimg_entry( &entry, toc_info.toc_file, track_no,
                        offset - position, end - offset - length );
    else
    {
      info = (struct device_info*)toc_popup.item[toc_popup.selected].info;
      gen_cd_entry( &entry, info, track_no, offset - position, end - offset - length );
    }
    if( as )
      as = audio_reopen( as, &entry );
    else
      as = audio_open( &entry );
    if( as == NULL )
      continue;

    sprintf( prog_info, get_string( "TXT_EXTTRK" ), track_no );
    progress_setinfo( prog_info );

    sprintf( pathname, "%s%s%02d.%s", preferences.toc_dest, fname, track_no, ext[ format ] );/* 26/04/07 */
    fd = open( pathname, O_WRONLY|O_CREAT|O_TRUNC );
    if( fd == -1 )
    {
      audio_close( as );
      alert_msg( "AL_FILERR", 1, pathname );
      goto error;
    }
    switch( format )
    {
    case 0:        /* AVR */
      avrh = (struct avr_header *) buf;
      avrh->avr_id = '2BIT';
      memset( avrh->name, 0, 8 );
      avrh->num_voices = 0xFFFF;
      avrh->num_bits = 16;
      avrh->signe = 0xffff;
      avrh->loop = 0;
      avrh->midi = 0xffff;
      avrh->freq_type.frequence = 0xff00ac44L;
      avrh->length = length * (2352 / 2);
      avrh->beg_loop = 0;
      avrh->end_loop = avrh->length;
      memset( avrh->reserved, 0, 26 + 64 );
      write( fd, avrh, sizeof( *avrh ) );
      swap = as->little_endian;
      break;
    case 1:        /* RAW big-endian */
      swap = as->little_endian;
      break;
    case 2:        /* RAW little-endian */
      swap = !as->little_endian;
      break;
    case 3:        /* WAVE */
      wavh = (struct wave_header *) buf;
      wavh->riff_id = 'RIFF';
      wavh->riff_len = swap_long( length * 2352 + 36 );
      wavh->wave_id = 'WAVE';
      wavh->fmt_id = 'fmt ';
      wavh->fmt_size = 0x10000000L;
      wavh->fmt_compression_code = 0x0100;
      wavh->fmt_channels = 0x0200;
      wavh->fmt_freq = 0x44ac0000L;
      wavh->fmt_bytes_sec = 0x10b10200L;
      wavh->fmt_block_align = 0x0400;
      wavh->fmt_num_bits = 0x1000;
      wavh->data_id = 'data';
      wavh->data_size = swap_long( length * 2352 );
      write( fd, wavh, sizeof( *wavh ) );
      swap = !as->little_endian;
      break;
    case 4:        /* AU/SND */ /* YD 26/04/07 */
      sndh = (struct snd_header *) buf;
      sndh->magic = '.snd';
      sndh->dataLocation = sizeof(struct snd_header);
      sndh->dataSize = length * 2352;
      sndh->dataFormat = 3L;
      sndh->samplingRate = 0xac44L; /* 44100 Hz */
      sndh->channelCount = 2L;
      memset( sndh->info, 0, 4 );
      write( fd, sndh, sizeof( *sndh ) );
      swap = as->little_endian;
      break;
    case 6:        /* AIFF Cubase Audio  */ 
      aiff_cubase_currentsize= 512L + (length * 2352);
      aiff_cubase_totalsize= aiff_cubase_currentsize & 0xFFFFFC00L; /* multiple 1024 */
      if ( aiff_cubase_totalsize != aiff_cubase_currentsize )
      {
          aiff_cubase_totalsize = aiff_cubase_totalsize + 0x400L;
      }
      octets_a_remplir= aiff_cubase_totalsize- aiff_cubase_currentsize; 
    case 5:        /* AIFF */ /* YD 26/04/07 */
	aiffh = (struct aiff_header *) buf;
	strcpy ( aiffh->type, "FORM" );
	aiffh->taille_a = (length * 2352) - 8;
	strcpy ( aiffh->type_a, "AIFF" );	
	strcpy ( aiffh->type_b, "COMM" );
	aiffh->taille_b = 18L;
	aiffh->piste = 2;
	aiffh->nsf = (length * 2352) / 4 ;	
	aiffh->tsample = 16;
	*(double *)&aiffh->SampleRate = (double) 44100.0;
	strcpy ( aiffh->nom_c, "SSND" );
	aiffh->taille_c = (length * 2352) - 46;
	aiffh->offset = 458L;	
	aiffh->blocsize = 512L;
	memset( aiffh->nul, 0, 458L );
	write( fd, aiffh, sizeof( *aiffh ) );
	swap = as->little_endian;
	break;
    }
    while( length > 0 )
    {
      if( yield() )
      {
        audio_close( as );
        alert_msg( "AL_EXTINT", 1 );
        goto error;
      }
      nblocks = MIN( length, max_buf_blocks );
      if( audio_read( as, buffer, nblocks ) == 0 )
      {
        audio_close( as );
        goto error;
      }
      if( swap )
        swap_endian( buffer, nblocks * 2352 );
      if( write( fd, buffer, nblocks * 2352 ) == -1 )
      {
        close( fd );
        audio_close( as );
        alert_msg( "AL_FWRTERR", 1, pathname );
        goto error;
      }
      length -= nblocks;
      progress += nblocks;
      progress_setcount( progress );
    }
    if ( format == 6 )  /* Si AIFF Cubase Audio */ /* YD 26/04/07 */
    {
    			if ( octets_a_remplir )
    			{
						char *zero;
						zero=malloc(1024L);
						memset( zero, 0, 1024L );
    				write( fd, zero, octets_a_remplir );
    				free(zero);
    			}
    }
    close( fd );
  }
  audio_close( as );
error:
  log_printf( "*** End of the track extraction session\n\n" );
  log_end();
  progress_exit();
  free_comm_buffer( buffer );

}

int toc_gen_tree( struct _toc_data * data )
{
  OBJECT * form;
  struct _field *f;
  int i, j, obj;
  int y, h;
  int index;
  rsrc_gaddr( 0, TRACK_FR, &form );

  obj = 0;
  while( ! (form[ obj ].ob_flags & LASTOB) )
    obj++;
  data->n_obj = obj + 1;

  free( data->tree );
  free( data->f );

  data->tree = xmalloc( ( data->n_tracks * data->n_obj + 1 ) * sizeof( struct _field ));
  if( !data->tree ) goto memerror;
  data->f = xmalloc( data->n_tracks * sizeof( struct _field ) );
  if( !data->f ) goto memerror2;

  data->tree[0].ob_type = G_IBOX;
  data->tree[0].ob_flags = NONE;
  data->tree[0].ob_state = NORMAL;
  data->tree[0].ob_spec.index = 0;
  data->tree[0].ob_next = -1;
  data->tree[0].ob_head = 1;
  data->tree[0].ob_tail = 1 + data->n_obj * (data->n_tracks - 1);
  y = 2;
  h = form[ 0 ].ob_height + 4;
  data->tree[0].ob_width = form[ 0 ].ob_width;
  data->tree[0].ob_height = data->n_tracks * h;

  index = 1;
  for( i=0; i<data->n_tracks; i++ )
  {
    memcpy( data->tree + index, form, data->n_obj * sizeof( OBJECT ) );
    for( j = index; j < (index + data->n_obj); j++ )
    {
      data->tree[j].ob_next += index;
      if( data->tree[j].ob_head >= 0 ) data->tree[j].ob_head += index;
      if( data->tree[j].ob_tail >= 0 ) data->tree[j].ob_tail += index;
    }
    f = data->f + i;
    f->beg_ted = *form[ TF_BEGIN ].ob_spec.tedinfo;
    f->beg_ted.te_ptext = f->beg_time;
    f->end_ted = *form[ TF_END ].ob_spec.tedinfo;
    f->end_ted.te_ptext = f->end_time;
    data->tree[index + TF_BEGIN].ob_spec.tedinfo = &f->beg_ted;
    data->tree[index + TF_END].ob_spec.tedinfo = &f->end_ted;

    data->tree[index].ob_next = index + data->n_obj;
    data->tree[index].ob_y = y;

    y += h;
    index += data->n_obj;
    data->tree[index - 1].ob_flags &= ~LASTOB;
  }
  index = 1 + (data->n_tracks - 1) * data->n_obj;
  data->tree[ index ].ob_next = 0;
  data->tree[ index + data->n_obj - 1 ].ob_flags |= LASTOB;

  return 0;
memerror2:
  free( data->tree );
memerror:
  return -1;
}

void destroy_toc_data( struct _toc_data * data )
{
  if( data )
  {
    free( data->tree );
    free( data->f );
    free( data );
  }
}

struct _toc_data * new_toc_data( void )
{
  struct _toc_data * data;

  data = xmalloc( sizeof( struct _toc_data ) );

  return data;
}

void toc_destroy( WINDOW *win );
int toc_readtoc( WINDOW * win )
{
  struct _toc_data * data;
  struct idao_stream * in;
  const static char * type[] = { "Audio", "Data mode 1", "Data mode 2", "Data" };
  long beg, end;
  int m, s, f;
  int i, entry, mode;

  data = DataSearch( win, TW_MAGIC );
  if( data == NULL )
  {
    data = new_toc_data( );
    if( !data ) return -1;
  }

  busybee();

  if( toc_popup.selected == 0 )
    in = idao_open_file( toc_info.toc_file );
  else
    in = idao_open_cd( toc_popup.item[toc_popup.selected].info );
  if( !in ) goto readerr;

  data->toc = in->toc;

  /* Analyse de la toc */
  entry = get_toc_entry( &data->toc, 0xa1, data->toc.head.last_track );
  data->n_tracks = desc( data->toc, entry ).pmin;

  if( toc_gen_tree( data ) ) goto readerr2;

  for( i=0; i<data->n_tracks; i++ )
  {
    sprintf( data->f[i].tno, "%2d", i + 1 );
    beg = get_track_offset( &data->toc, i + 1, &end );
    msf( beg, &m, &s, &f );
    sprintf( data->f[i].beg_time, "%02d%02d%02d", m, s, f );
    msf( end - 1, &m, &s, &f );
    mode = get_mode( &data->toc, i + 1 );
    if( mode < 0 ) mode = 3;
    objc_enable( data->tree, i*data->n_obj + 1 + TF_CK, mode == 0 /*mode != 3*/ );
    data->tree[ i*data->n_obj + 1 + TF_TYPE ].ob_spec.free_string = type[ mode ];
    sprintf( data->f[i].end_time, "%02d%02d%02d", m, s, f );
    data->tree[ i*data->n_obj + 1 + TF_TNO ].ob_spec.free_string = data->f[i].tno;
  }
  idao_close( in );

  FormAttach( win, data->tree, form_mgr );
  DataAttach( win, TW_MAGIC, data );
  EvntAttach( win, WM_DESTROY, toc_destroy );

  wind_center( win, -1, data->tree->ob_height );
  objc_redraw( data->tree, 0 );

  arrow();
  return 0;
readerr2:
  idao_close( in );
readerr:
  free( data );
  arrow();
  alert_msg( "AL_CANTREAD", 1 );
  return -1;
}

void toc_gestion_acces( WINDOW * win )
{
  struct _toc_data * data;
  OBJECT * tool;
  int i, enable;
  tool = TOOL( win );
  data = DataSearch( win, TW_MAGIC );

  enable = toc_popup.selected != 0;
  objc_lock( tool, TTB_LOAD, !enable );
  objc_lock( tool, TTB_EJECT, !enable );

  if( data )
  {
    enable = 0;
    i = 0;
    while( i < data->n_tracks && !enable )
      enable = data->tree[ 2 + data->n_obj * i++ ].ob_state & SELECTED;
    objc_lock( tool, TTB_EXTRACT, !enable );
  }
  else
    objc_lock( tool, TTB_EXTRACT, 1 );
}

void toc_default( OBJECT * tool )
{
  struct device_info * info;
  int i;

  strncpy( toc_info.toc_file, preferences.toc_file, 255 );
  for( i=1; i<toc_popup.item_count; i++ )
  {
    info = (struct device_info *)toc_popup.item[i].info;
    if( info->id == preferences.dev_toc_id
        && info->bus_no == preferences.dev_toc_bus )
      toc_popup.selected = i;
  }
  if( toc_popup.selected )
    tool[ TTB_SOURCE ].ob_spec.free_string = toc_popup.item[ toc_popup.selected ].text;
  else
  {
    tool[ TTB_SOURCE ].ob_spec.free_string = toc_info.toc_fred;
    reduce_name( toc_info.toc_fred, toc_info.toc_file, MAX_FRED_TOC );
  }

  fmt_popup.selected = preferences.audio_format;
  tool[ TTB_FORMAT ].ob_spec.free_string = fmt_popup.item[ fmt_popup.selected ].text;
}

void toc_valid( OBJECT * form ) 
{
  struct device_info * info;
  info = (struct device_info *)toc_popup.item[ toc_popup.selected ].info;
  strncpy( preferences.toc_file, toc_info.toc_file, 255 );
  preferences.dev_toc_id = info ? info->id : -1;
  preferences.dev_toc_bus = info ? info->bus_no : -1;
  preferences.audio_format = fmt_popup.selected;
}

void toc_toolbar( WINDOW * win )
{
  OBJECT * tool;
  int obj;
  tool = TOOL( win );
  obj = evnt.buff[4];
  switch( obj )
  {
  case TTB_SOURCE:
  case TTB_SRCCYC:
    if( popup_mgr( win, &toc_popup, obj ) == 0 )
    {
      fileselect( toc_info.toc_file, "*.cd", "TXT_DAOFILE" );
      tool[ TTB_SOURCE ].ob_spec.free_string = toc_info.toc_fred;
      reduce_name( toc_info.toc_fred, toc_info.toc_file, MAX_FRED_TOC );
      ObjcDraw( OC_TOOLBAR, win, TTB_SOURCE, MAX_DEPTH );
    }
    toc_gestion_acces( win );
    break;
  case TTB_EXTRACT:
    toc_extract( win );
    break;
  case TTB_FORMAT:
  case TTB_FRMTCYC:
    popup_mgr( win, &fmt_popup, obj );
    break;
  case TTB_LOAD:
  case TTB_EJECT:
    dev_insert_open( toc_popup.item[toc_popup.selected].info, obj == TTB_EJECT );
    break;
  case TTB_READTOC:
    toc_readtoc( win );
    toc_gestion_acces( win );
    break;
  case TTB_CANCEL:
    ApplWrite( app.id, WM_DESTROY, win->handle );
    break;
  }
}

void toc_clicked( WINDOW * win )
{
/*
  OBJECT * form;
  int obj;
  form = FORM(win);
  obj = evnt.buff[4];
*/
  toc_gestion_acces( win );
}


void toc_destroy( WINDOW *win )
{
  toc_valid( TOOL( win ) );
  destroy_toc_data( DataSearch( win, TW_MAGIC ) );
  WindClose( win );
  WindDelete( win );
  toc_win = NULL;
}

void toc_open( void )
{
  OBJECT *tool;
  WINDOW * win;
  int w, h, dummy;

  if( toc_win )
  {
    WindSet( toc_win, WF_TOP );
  }
  else
  {
    rsrc_gaddr( 0, TRACK_TB, &tool );

    toc_win = WindCreate( DEFAULT_FLAGS|SIZER|UPARROW|DNARROW|VSLIDE, 0, 0, 0, 0 );
    win = toc_win;
    if( win )
    {
      toc_popup.object = TTB_SOURCE;
      toc_popup.item = toc_popup_items;
      gen_dev_popup( &toc_popup, 0, 1 );
      toc_default( tool );

      WindCalc( WC_BORDER, win, 0, 0, 472, tool->ob_height,
                &dummy, &dummy, &w, &h );
      WindSet( win, WF_NAME, get_string( "TXT_TOCWIN" ) );
      WindSet( win, WF_TOOLBAR, tool, toolbar_mgr );
      win->w_min = w;
      win->h_min = h;
      win->w_max = w;
      win->h_max = h;

      WindOpen( win, -1, -1, w, h );

      EvntAttach( win, WM_DESTROY, toc_destroy );
      EvntAttach( win, UE_CLICKED, toc_clicked );
      EvntAttach( win, UE_TOOLBAR, toc_toolbar );

      toc_gestion_acces( win );
    }
  }
}

