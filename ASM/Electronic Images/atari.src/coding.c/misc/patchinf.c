#include <stdio.h>
#include <string.h>
#include "patch.h"
 
#ifndef SEEK_CUR
#define SEEK_CUR   1L
#endif
 
#ifndef __MSDOS__
#define UINT       unsigned int
#define ULONG      unsigned long
#define strupr(a)  a
#define swapi(a)   (( (UINT) a & 0xFF) << 8) | ( (UINT) a >> 8)
#define swapl(a)   (( (ULONG) a & 0xFF) << 24) | (( (ULONG) a & 0xFF00) << 8) | (( (ULONG) a & 0xFF0000) >> 8) | ( (ULONG) a >> 24)
#endif
 
/* reads and displays information from the .PAT file */
void read_patch( char *patch )
{
  FILE *fil;
  PATCHHEADER header;
  INSTRUMENTDATA ins;
  LAYERDATA layer;
  PATCHDATA sample;
  int i,j;
 
  if ( (fil = fopen( patch, "rb" )) != NULL )
  {
    #ifdef __MSDOS__
    /* read patch header and instrument info */
    fread( &header, sizeof(header), 1, fil );
    fread( &ins, sizeof(ins), 1, fil );
    fread( &layer, sizeof(layer), 1, fil );
    #else
    /* Unix based routines, assume big-endian machine */
    /* read header */
    fread( &header.header, sizeof(header.header), 1, fil );
    fread( &header.gravis_id, sizeof(header.gravis_id), 1, fil );
    fread( &header.description, sizeof(header.description), 1, fil );
    fread( &header.instruments, sizeof(header.instruments), 1, fil );
    fread( &header.voices, sizeof(header.voices), 1, fil );
    fread( &header.channels, sizeof(header.channels), 1, fil );
    fread( &header.wave_forms, sizeof(header.wave_forms), 1, fil );
    header.wave_forms = swapi( header.wave_forms );
    fread( &header.master_volume, sizeof(header.master_volume), 1, fil );
    header.master_volume = swapi( header.master_volume );
    fread( &header.data_size, sizeof(header.data_size), 1, fil );
    header.data_size = swapl( header.data_size );
    fread( &header.reserved, sizeof(header.reserved), 1, fil );
    /* read instrument header */
    fread( &ins.instrument, sizeof(ins.instrument), 1, fil );
    fread( &ins.instrument_name, sizeof(ins.instrument_name), 1, fil );
    fread( &ins.instrument_size, sizeof(ins.instrument_size), 1, fil );
    ins.instrument_size = swapl( ins.instrument_size );
    fread( &ins.layers, sizeof(ins.layers), 1, fil );
    fread( &ins.reserved, sizeof(ins.reserved), 1, fil );
    /* read layer header */
    fread( &layer.layer_duplicate, sizeof(layer.layer_duplicate), 1, fil );
    fread( &layer.layer, sizeof(layer.layer), 1, fil );
    fread( &layer.layer_size, sizeof(layer.layer_size), 1, fil );
    layer.layer_size = swapl( layer.layer_size );
    fread( &layer.samples, sizeof(layer.samples), 1, fil );
    fread( &layer.reserved, sizeof(layer.reserved), 1, fil );
    #endif
 
    printf( "\n\n" );
    if ( strcmp( header.gravis_id, "ID#000002" ) == 0 )
    {
      printf( "%s\n", strupr( patch ) );
      printf( "Name: %s\n", ins.instrument_name );
      printf( "Description: %s\n", header.description );
      printf( "Number of samples: %u\n", header.wave_forms );
      printf( "Total patch size: %lu bytes\n", header.data_size );
 
      /* read sample information */
      for ( i = 0; i < layer.samples; i++ )
      {
        #ifdef __MSDOS__
        fread( &sample, sizeof(sample), 1, fil );
        #else
        fread( &sample.wave_name, sizeof(sample.wave_name), 1, fil );
        fread( &sample.fractions, sizeof(sample.fractions), 1, fil );
        fread( &sample.wave_size, sizeof(sample.wave_size), 1, fil );
        sample.wave_size = swapl( sample.wave_size );
        fread( &sample.start_loop, sizeof(sample.start_loop), 1, fil );
        fread( &sample.end_loop, sizeof(sample.end_loop), 1, fil );
        fread( &sample.sample_rate, sizeof(sample.sample_rate), 1, fil );
        sample.sample_rate = swapi( sample.sample_rate );
        fread( &sample.low_frequency, sizeof(sample.low_frequency), 1, fil );
	sample.low_frequency = swapl(sample.low_frequency);
        fread( &sample.high_frequency, sizeof(sample.high_frequency), 1, fil );
	sample.high_frequency = swapl(sample.high_frequency);
        fread( &sample.root_frequency, sizeof(sample.root_frequency), 1, fil );
	sample.root_frequency = swapl(sample.root_frequency);
        fread( &sample.tune, sizeof(sample.tune), 1, fil );
	sample.tune = swapi(sample.tune);
        fread( &sample.balance, sizeof(sample.balance), 1, fil );
        fread( &sample.envelope_rate, sizeof(sample.envelope_rate), 1, fil );
        fread( &sample.envelope_offset, sizeof(sample.envelope_offset), 1, fil );
        fread( &sample.tremolo_sweep, sizeof(sample.tremolo_sweep), 1, fil );
        fread( &sample.tremolo_rate, sizeof(sample.tremolo_rate), 1, fil );
        fread( &sample.tremolo_depth, sizeof(sample.tremolo_depth), 1, fil );
        fread( &sample.vibrato_sweep, sizeof(sample.vibrato_sweep), 1, fil );
        fread( &sample.vibrato_rate, sizeof(sample.vibrato_rate), 1, fil );
        fread( &sample.vibrato_depth, sizeof(sample.vibrato_depth), 1, fil );
        fread( &sample.modes, sizeof(sample.modes), 1, fil );
        fread( &sample.scale_frequency, sizeof(sample.scale_frequency), 1, fil );
	sample.scale_frequency = swapi(sample.scale_frequency);
        fread( &sample.scale_factor, sizeof(sample.scale_factor), 1, fil );
        sample.scale_factor = swapi( sample.scale_factor );
        fread( &sample.reserved, sizeof(sample.reserved), 1, fil );
        #endif

        fseek( fil, sample.wave_size, SEEK_CUR );
        if ( sample.scale_factor == 0 ) printf( "Percussion " );
        printf( "Wave name: %s [%ld bytes]\n", sample.wave_name, sample.wave_size );
        printf( "  %s bit, %u Hz\n", (sample.modes & 1) ? "16" : "8", sample.sample_rate );
        if ( sample.modes & 32 ) printf( "  Sustained, " );
        else
          printf( "  " );
        if ( sample.modes & 64 ) printf( "Enveloped, " );
        if ( sample.modes & 4 == 0 ) printf( "Non-looping" );
        else
        if ( sample.modes & 8 ) printf( "Bidirectional-looping" );
        else
        if ( sample.modes & 16 ) printf( "Backward-looping" );
        else
        if ( sample.modes & 4 ) printf( "Looping" );

        if ( sample.tremolo_depth ) printf( ", Tremolo ON" );
        if ( sample.vibrato_depth ) printf( ", Vibrato ON" );
        printf( "\n" );
	printf("low:%X high:%X root:%X scale:%X factor:%X tune:%X\n",
		sample.low_frequency,sample.high_frequency,sample.root_frequency,sample.scale_frequency,sample.scale_factor,sample.tune);
	for (j=0 ; j <= 5 ; j++)
		printf("%X %X ",sample.envelope_offset[j],sample.envelope_rate[j]);
        printf( "\n" );

      }
    }
    else
      printf( "Not a patch file!\n" );
 
    fclose( fil );
  }
  else
    printf( "Error accessing file!\n" );
}
 
/* main program */
void main( char argc, char **argv )
{
  if ( argc > 1 )
  {
    printf( "Reading Patch..." );
    read_patch( argv[ 1 ] );
  }
  else
    printf( "Filename not supplied.\n" );
  getchar();
}
