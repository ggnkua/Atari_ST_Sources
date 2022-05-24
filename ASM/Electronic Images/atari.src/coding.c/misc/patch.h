/***************************************************************************
**	NAME:  PATCH.H
**	COPYRIGHT:
**	"Copyright (c) 1991,1992, by FORTE
**
**       "This software is furnished under a license and may be used,
**       copied, or disclosed only in accordance with the terms of such
**       license and with the inclusion of the above copyright notice.
**       This software or any other copies thereof may not be provided or
**       otherwise made available to any other person. No title to and
**       ownership of the software is hereby transfered."
****************************************************************************
*  CREATION DATE: 07/01/92
*--------------------------------------------------------------------------*
*     VERSION	DATE	   NAME		DESCRIPTION
*>	1.0	07/01/92		Original
***************************************************************************/
 
#define ENVELOPES	6	
 
/* This is the definition for what FORTE's patch format is. All .PAT */
/* files will have this format. */
 
#define HEADER_SIZE	12
#define ID_SIZE		10
#define DESC_SIZE 	60
#define RESERVED_SIZE	40
#define PATCH_HEADER_RESERVED_SIZE 36
#define LAYER_RESERVED_SIZE	40
#define PATCH_DATA_RESERVED_SIZE	36
#define GF1_HEADER_TEXT	"GF1PATCH110"
 
typedef struct
{
	char		header[ HEADER_SIZE ];	
	char		gravis_id[ ID_SIZE ];	/* Id = "ID#000002" */
	char		description[ DESC_SIZE ];
	unsigned char	instruments;
	char		voices;
	char		channels;
	unsigned short	wave_forms;
	unsigned short	master_volume;
	unsigned long	data_size;
	char		reserved[ PATCH_HEADER_RESERVED_SIZE ];
} PATCHHEADER;
 
typedef struct
{
	unsigned short	instrument;
	char		instrument_name[ 16 ];
	long		instrument_size;
	char		layers;
	char		reserved[ RESERVED_SIZE ];	
} INSTRUMENTDATA;
 
typedef struct
{
	char		layer_duplicate;
	char		layer;
	long		layer_size;
	char		samples;
	char		reserved[ LAYER_RESERVED_SIZE ];	
} LAYERDATA;
 
typedef struct
{
	char		wave_name[7];
 
	unsigned char	fractions;
	long		wave_size;
	long		start_loop;
	long		end_loop;
 
	unsigned short	sample_rate;
	long		low_frequency;
	long		high_frequency;
	long		root_frequency;
	short		tune;
	
	unsigned char	balance;
 
	unsigned char	envelope_rate[ ENVELOPES ];
	unsigned char	envelope_offset[ ENVELOPES ];	
 
	unsigned char	tremolo_sweep;
	unsigned char	tremolo_rate;
	unsigned char	tremolo_depth;
	
	unsigned char	vibrato_sweep;
	unsigned char	vibrato_rate;
	unsigned char	vibrato_depth;
	
 
/* bit 0 = 8 or 16 bit wave data. */
/* bit 1 = Signed - Unsigned data. */
/* bit 2 = looping enabled-1. */
/* bit 3 = Set is bidirectional looping. */
/* bit 4 = Set is looping backward. */
/* bit 5 = Turn sustaining on. (Env. pts. 3)*/
/* bit 6 = Enable envelopes - 1 */
	char		modes;
 
	short		scale_frequency;
	unsigned short	scale_factor;		/* from 0 to 2048 or 0 to 2 */
	
	char		reserved[ PATCH_DATA_RESERVED_SIZE ];
} PATCHDATA;
