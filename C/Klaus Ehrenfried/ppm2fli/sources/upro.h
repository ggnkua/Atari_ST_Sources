/****************************************************************
 * upro.h
 ****************************************************************/

/******
  Copyright (C) 1995 by Klaus Ehrenfried. 

  Permission to use, copy, modify, and distribute this software
  is hereby granted, provided that the above copyright notice appears 
  in all copies and that the software is available to all free of charge. 
  The author disclaims all warranties with regard to this software, 
  including all implied warranties of merchant-ability and fitness. 
  The code is simply distributed as it is.
*******/

#define FLI_MAXFRAMES (4000)	  /* Max number of frames... */

#define FLI_FILE_MAGIC 0xaf11	  /* File header Magic old FLI */
#define FLC_FILE_MAGIC 0xaf12	  /* File header Magic new FLC */

#define FLI_FRAME_MAGIC 0xf1fa		/* Frame Magic FLI/FLC */

#define FILE_HEAD_SIZE 128
#define FRAME_HEAD_SIZE 16
#define CHUNK_HEAD_SIZE 6

/* types of chunk in a fli_frame */

#define FLI_256_COLOR 4
#define FLI_DELTA 7
#define FLI_COLOR 11
#define FLI_LC	12
#define FLI_BLACK 13
#define FLI_BRUN 15
#define FLI_COPY 16

#define MAXCOLORS 256

#define PPM_RAW    6
#define PPM_ASCII  3
#define FBM_MAPPED 101

int unfli(FILE *input,char *out_name_base,char *out_name_ext,int outtype,\
	  int start_frame,int end_frame,int verbose, int compress_flag);

int buffer_brun_chunk(unsigned char *pcc, unsigned char *image_cbuff,\
		      int image_height, int image_width);
int buffer_delta_chunk(unsigned char *pcc, unsigned char *image_cbuff,\
		      int image_height, int image_width);
int buffer_lc_chunk(unsigned char *pcc, unsigned char *image_cbuff,\
		      int image_height, int image_width);

int out_image(unsigned char *image_buffer, unsigned char *color_table,\
	    int width, int height, int outtype, char *name_base,\
	    char *name_ext, int digits, int num, int compress_flag);
