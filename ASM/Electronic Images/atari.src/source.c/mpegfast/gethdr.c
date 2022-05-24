/* gethdr.c, header decoding                                                */

/* Copyright (C) 1994, MPEG Software Simulation Group. All Rights Reserved. */

/*
 * Disclaimer of Warranty
 *
 * These software programs are available to the user without any license fee or
 * royalty on an "as is" basis.  The MPEG Software Simulation Group disclaims
 * any and all warranties, whether express, implied, or statuary, including any
 * implied warranties or merchantability or of fitness for a particular
 * purpose.  In no event shall the copyright-holder be liable for any
 * incidental, punitive, or consequential damages of any kind whatsoever
 * arising from the use of these programs.
 *
 * This disclaimer of warranty extends to the user of these programs and user's
 * customers, employees, agents, transferees, successors, and assigns.
 *
 * The MPEG Software Simulation Group does not represent or warrant that the
 * programs furnished hereunder are free of infringement of any third-party
 * patents.
 *
 * Commercial implementations of MPEG-1 and MPEG-2 video, including shareware,
 * are subject to royalty fees to patent holders.  Many of these patents are
 * general enough such that they are unavoidable regardless of implementation
 * design.
 *
 */

#include <stdio.h>

#include "config.h"
#include "global.h"

/* private prototypes */
static int gethdr _ANSI_ARGS_((void));
static void getseqhdr _ANSI_ARGS_((void));
static void getgophdr _ANSI_ARGS_((void));
static void getpicturehdr _ANSI_ARGS_((void));
static void ext_user_data _ANSI_ARGS_((void));
static void sequence_extension _ANSI_ARGS_((void));
static void sequence_display_extension _ANSI_ARGS_((void));
static void quant_matrix_extension _ANSI_ARGS_((void));
static void sequence_scalable_extension _ANSI_ARGS_((void));
static void picture_display_extension _ANSI_ARGS_((void));
static void picture_coding_extension _ANSI_ARGS_((void));
static void picture_spatial_scalable_extension _ANSI_ARGS_((void));
static void picture_temporal_scalable_extension _ANSI_ARGS_((void));
static void ext_bit_info _ANSI_ARGS_((void));


/* decode headers from all input streams */

int getheader()
{
  int ret;

  ld = &base;
  ret = gethdr();
  if (twostreams)
  {
    ld = &enhan;
    if (gethdr()!=ret && !quiet)
      fprintf(stderr,"streams out of sync\n");
    ld = &base;
  }

  return ret;
}


/*
 * decode headers from one input stream
 * until an End of Sequence or picture start code
 * is found
 */

static int gethdr()
{
  unsigned int code;

  for (;;)
  {
    /* look for startcode */
    startcode();
    code = getbits32();
    switch (code)
    {
    case SEQ_START_CODE:
      getseqhdr();
      break;
    case GOP_START_CODE:
      getgophdr();
      break;
    case PICTURE_START_CODE:
      getpicturehdr();
      return 1;
      break;
    case SEQ_END_CODE:
      return 0;
      break;
    default:
      if (!quiet)
        fprintf(stderr,"Unexpected startcode %08x (ignored)\n",code);
      break;
    }
  }
}


/* align to start of next startcode */

void startcode()
{
  /* byte align */
  flushbits(ld->incnt&7);
  while (showbits(24)!=1l)
    flushbits(8);
}


/* decode sequence header */

static void getseqhdr()
{
  int i;
  int aspect_ratio, picture_rate, vbv_buffer_size;
  int constrained_parameters_flag;
  int load_intra_quantizer_matrix, load_non_intra_quantizer_matrix;
  int bit_rate;
  int pos;

  pos = ld->bitcnt;
  horizontal_size = getbits(12);
  vertical_size = getbits(12);
  aspect_ratio = getbits(4);
  picture_rate = getbits(4);
  bit_rate = getbits(18);
  flushbits(1); /* marker bit (=1) */
  vbv_buffer_size = getbits(10);
  constrained_parameters_flag = getbits(1);

  if (load_intra_quantizer_matrix = getbits(1))
  {
    for (i=0; i<64; i++)
      ld->intra_quantizer_matrix[zig_zag_scan[i]] = getbits(8);
  }
  else
  {
    for (i=0; i<64; i++)
      ld->intra_quantizer_matrix[i] = default_intra_quantizer_matrix[i];
  }

  if (load_non_intra_quantizer_matrix = getbits(1))
  {
    for (i=0; i<64; i++)
      ld->non_intra_quantizer_matrix[zig_zag_scan[i]] = getbits(8);
  }
  else
  {
    for (i=0; i<64; i++)
      ld->non_intra_quantizer_matrix[i] = 16;
  }

  /* copy luminance to chrominance matrices */
  for (i=0; i<64; i++)
  {
    ld->chroma_intra_quantizer_matrix[i] =
      ld->intra_quantizer_matrix[i];

    ld->chroma_non_intra_quantizer_matrix[i] =
      ld->non_intra_quantizer_matrix[i];
  }

  if (verbose>0)
  {
    printf("sequence header (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      printf("  horizontal_size=%d\n",horizontal_size);
      printf("  vertical_size=%d\n",vertical_size);
      printf("  aspect_ratio=%d\n",aspect_ratio);
      printf("  picture_rate=%d\n",picture_rate);
      printf("  bit_rate=%d\n",bit_rate);
      printf("  vbv_buffer_size=%d\n",vbv_buffer_size);
      printf("  constrained_parameters_flag=%d\n",constrained_parameters_flag);
      printf("  load_intra_quantizer_matrix=%d\n",load_intra_quantizer_matrix);
      printf("  load_non_intra_quantizer_matrix=%d\n",load_non_intra_quantizer_matrix);
    }
  }

  ext_user_data();
}


/* decode group of pictures header */

static void getgophdr()
{
  int drop_flag, hour, minute, sec, frame, closed_gop, broken_link;
  int pos;

  pos = ld->bitcnt;
  drop_flag = getbits(1);
  hour = getbits(5);
  minute = getbits(6);
  flushbits(1);
  sec = getbits(6);
  frame = getbits(6);
  closed_gop = getbits(1);
  broken_link = getbits(1);

  if (verbose>0)
  {
    printf("group of pictures (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      printf("  drop_flag=%d\n",drop_flag);
      printf("  timecode %d:%02d:%02d:%02d\n",hour,minute,sec,frame);
      printf("  closed_gop=%d\n",closed_gop);
      printf("  broken_link=%d\n",broken_link);
    }
  }

  ext_user_data();
}


/* decode picture header */

static void getpicturehdr()
{
  int temp_ref, vbv_delay;
  int pos;

  ld->pict_scal = 0; /* unless overwritten by pict. spat. scal. ext. */

  pos = ld->bitcnt;
  temp_ref = getbits(10);
  pict_type = getbits(3);
  vbv_delay = getbits(16);
  if (pict_type==P_TYPE || pict_type==B_TYPE)
  {
    full_forw = getbits(1);
    forw_r_size = getbits(3) - 1;
  }
  if (pict_type==B_TYPE)
  {
    full_back = getbits(1);
    back_r_size = getbits(3) - 1;
  }

  if (verbose>0)
  {
    printf("picture header (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      printf("  temp_ref=%d\n",temp_ref);
      printf("  pict_type=%d\n",pict_type);
      printf("  vbv_delay=%d\n",vbv_delay);
      if (pict_type==P_TYPE || pict_type==B_TYPE)
      {
        printf("  full_forw=%d\n",full_forw);
        printf("  forw_r_size=%d\n",forw_r_size);
      }
      if (pict_type==B_TYPE)
      {
        printf("  full_back=%d\n",full_back);
        printf("  back_r_size=%d\n",back_r_size);
      }
    }
  }
  ext_bit_info();
  ext_user_data();
}

/* decode slice header */

int getslicehdr()
{
  int slice_vertical_position_extension, intra_slice;
  int qs;
  int pos;

  pos = ld->bitcnt;
  slice_vertical_position_extension =
    (ld->mpeg2 && vertical_size>2800) ? getbits(3) : 0;

  if (ld->scalable_mode==SC_DP)
    ld->pri_brk = getbits(7);

  qs = getbits(5);
  ld->quant_scale =
    ld->mpeg2 ? (ld->qscale_type ? non_linear_mquant_table[qs] : qs<<1) : qs;

  if (getbits(1))
  {
    intra_slice = getbits(1);
    flushbits(7);
    ext_bit_info();
  }
  else
    intra_slice = 0;

  if (verbose>2)
  {
    printf("slice header (byte %d)\n",(pos>>3)-4);
    if (verbose>3)
    {
      if (ld->mpeg2 && vertical_size>2800)
        printf("  slice_vertical_position_extension=%d\n",slice_vertical_position_extension);
      if (ld->scalable_mode==SC_DP)
        printf("  priority_breakpoint=%d\n",ld->pri_brk);
      printf("  quantizer_scale_code=%d\n",qs);
    }
  }
  return slice_vertical_position_extension;
}


/* decode extension and user data */

static void ext_user_data()
{
  int code,ext_ID;

  startcode();

  while ((code = showbits(32))==EXT_START_CODE || code==USER_START_CODE)
  {
    if (code==EXT_START_CODE)
    {
      flushbits32();
      ext_ID = getbits(4);
      switch (ext_ID)
      {
      case SEQ_ID:
        sequence_extension();
        break;
      case DISP_ID:
        sequence_display_extension();
        break;
      case QUANT_ID:
        quant_matrix_extension();
        break;
      case SEQSCAL_ID:
        sequence_scalable_extension();
        break;
      case PANSCAN_ID:
        picture_display_extension();
        break;
      case CODING_ID:
        picture_coding_extension();
        break;
      case SPATSCAL_ID:
        picture_spatial_scalable_extension();
        break;
      case TEMPSCAL_ID:
        picture_temporal_scalable_extension();
        break;
      default:
        fprintf(stderr,"reserved extension start code ID %d\n",ext_ID);
        break;
      }
      startcode();
    }
    else
    {
      if (verbose)
        printf("user data\n");
      flushbits32();
      startcode();
    }
  }
}


/* decode sequence extension */

static void sequence_extension()
{
  int prof_lev;
  int horizontal_size_extension, vertical_size_extension;
  int bit_rate_extension, vbv_buffer_size_extension, low_delay;
  int frame_rate_extension_n, frame_rate_extension_d;
  int pos;

  pos = ld->bitcnt;
  ld->mpeg2 = 1;
  ld->scalable_mode = SC_NONE; /* unless overwritten by seq. scal. ext. */
  prof_lev = getbits(8);
  prog_seq = getbits(1);
  chroma_format = getbits(2);
  horizontal_size_extension = getbits(2);
  vertical_size_extension = getbits(2);
  bit_rate_extension = getbits(12);
  flushbits(1);
  vbv_buffer_size_extension = getbits(8);
  low_delay = getbits(1);
  frame_rate_extension_n = getbits(2);
  frame_rate_extension_d = getbits(5);

  horizontal_size = (horizontal_size_extension<<12) | (horizontal_size&0x0fff);
  vertical_size = (vertical_size_extension<<12) | (vertical_size&0x0fff);

  if (verbose>0)
  {
    printf("sequence extension (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      printf("  profile_and_level_indication=%d\n",prof_lev);
      if (prof_lev<128)
      {
        printf("    profile=%d, level=%d\n",prof_lev>>4,prof_lev&15);
      }
      printf("  progressive_sequence=%d\n",prog_seq);
      printf("  chroma_format=%d\n",chroma_format);
      printf("  horizontal_size_extension=%d\n",horizontal_size_extension);
      printf("  vertical_size_extension=%d\n",vertical_size_extension);
      printf("  bit_rate_extension=%d\n",bit_rate_extension);
      printf("  vbv_buffer_size_extension=%d\n",vbv_buffer_size_extension);
      printf("  low_delay=%d\n",low_delay);
      printf("  frame_rate_extension_n=%d\n",frame_rate_extension_n);
      printf("  frame_rate_extension_d=%d\n",frame_rate_extension_d);
    }
  }
}


/* decode sequence display extension */

static void sequence_display_extension()
{
  int video_format, colour_description;
  int colour_primaries, transfer_characteristics;
  int display_horizontal_size, display_vertical_size;
  int pos;

  pos = ld->bitcnt;
  video_format = getbits(3);
  colour_description = getbits(1);

  if (colour_description)
  {
    colour_primaries = getbits(8);
    transfer_characteristics = getbits(8);
    matrix_coefficients = getbits(8);
  }

  display_horizontal_size = getbits(14);
  flushbits(1);
  display_vertical_size = getbits(14);

  if (verbose>0)
  {
    printf("sequence display extension (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      printf("  video_format=%d\n",video_format);
      printf("  colour_description=%d\n",colour_description);
      if (colour_description)
      {
        printf("    colour_primaries=%d\n",colour_primaries);
        printf("    transfer_characteristics=%d\n",transfer_characteristics);
        printf("    matrix_coefficients=%d\n",matrix_coefficients);
      }
      printf("  display_horizontal_size=%d\n",display_horizontal_size);
      printf("  display_vertical_size=%d\n",display_vertical_size);
    }
  }
}


/* decode quant matrix entension */

static void quant_matrix_extension()
{
  int i;
  int load_intra_quantiser_matrix, load_non_intra_quantiser_matrix;
  int load_chroma_intra_quantiser_matrix;
  int load_chroma_non_intra_quantiser_matrix;
  int pos;

  pos = ld->bitcnt;

  if (load_intra_quantiser_matrix = getbits(1))
  {
    for (i=0; i<64; i++)
    {
      ld->chroma_intra_quantizer_matrix[zig_zag_scan[i]]
      = ld->intra_quantizer_matrix[zig_zag_scan[i]]
      = getbits(8);
    }
  }

  if (load_non_intra_quantiser_matrix = getbits(1))
  {
    for (i=0; i<64; i++)
    {
      ld->chroma_non_intra_quantizer_matrix[zig_zag_scan[i]]
      = ld->non_intra_quantizer_matrix[zig_zag_scan[i]]
      = getbits(8);
    }
  }

  if (load_chroma_intra_quantiser_matrix = getbits(1))
  {
    for (i=0; i<64; i++)
      ld->chroma_intra_quantizer_matrix[zig_zag_scan[i]] = getbits(8);
  }

  if (load_chroma_non_intra_quantiser_matrix = getbits(1))
  {
    for (i=0; i<64; i++)
      ld->chroma_non_intra_quantizer_matrix[zig_zag_scan[i]] = getbits(8);
  }

  if (verbose>0)
  {
    printf("quant matrix extension (byte %d)\n",(pos>>3)-4);
    printf("  load_intra_quantiser_matrix=%d\n",
      load_intra_quantiser_matrix);
    printf("  load_non_intra_quantiser_matrix=%d\n",
      load_non_intra_quantiser_matrix);
    printf("  load_chroma_intra_quantiser_matrix=%d\n",
      load_chroma_intra_quantiser_matrix);
    printf("  load_chroma_non_intra_quantiser_matrix=%d\n",
      load_chroma_non_intra_quantiser_matrix);
  }
}


/* decode sequence scalable extension */

static void sequence_scalable_extension()
{
  int layer_id;
  int pos;

  pos = ld->bitcnt;
  ld->scalable_mode = getbits(2) + 1; /* add 1 to make SC_DP != SC_NONE */
  layer_id = getbits(4);

  if (ld->scalable_mode==SC_SPAT)
  {
    llw = getbits(14); /* lower_layer_prediction_horizontal_size */
    flushbits(1);
    llh = getbits(14); /* lower_layer_prediction_vertical_size */
    hm = getbits(5);
    hn = getbits(5);
    vm = getbits(5);
    vn = getbits(5);
  }

  if (ld->scalable_mode==SC_TEMP)
    error("temporal scalability not implemented\n");

  if (verbose>0)
  {
    printf("sequence scalable extension (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      printf("  scalable_mode=%d\n",ld->scalable_mode-1);
      printf("  layer_id=%d\n",layer_id);
      if (ld->scalable_mode==SC_SPAT)
      {
        printf("    lower_layer_prediction_horiontal_size=%d\n",llw);
        printf("    lower_layer_prediction_vertical_size=%d\n",llh);
        printf("    horizontal_subsampling_factor_m=%d\n",hm);
        printf("    horizontal_subsampling_factor_n=%d\n",hn);
        printf("    vertical_subsampling_factor_m=%d\n",vm);
        printf("    vertical_subsampling_factor_n=%d\n",vn);
      }
    }
  }
}


/* decode picture display extension */

static void picture_display_extension()
{
  int i,n;
  short frame_centre_horizontal_offset[3];
  short frame_centre_vertical_offset[3];
  int pos;

  pos = ld->bitcnt;

  if (prog_seq || pict_struct!=FRAME_PICTURE)
    n = 1;
  else
    n = repeatfirst ? 3 : 2;

  for (i=0; i<n; i++)
  {
    frame_centre_horizontal_offset[i] = (short)getbits(16);
    flushbits(1);
    frame_centre_vertical_offset[i] = (short)getbits(16);
    flushbits(1);
  }

  if (verbose>0)
  {
    printf("picture display extension (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      for (i=0; i<n; i++)
      {
        printf("  frame_centre_horizontal_offset[%d]=%d\n",i,
          frame_centre_horizontal_offset[i]);
        printf("  frame_centre_vertical_offset[%d]=%d\n",i,
          frame_centre_vertical_offset[i]);
      }
    }
  }
}


/* decode picture coding extension */

static void picture_coding_extension()
{
  int chroma_420_type, composite_display_flag;
  int v_axis, field_sequence, sub_carrier, burst_amplitude, sub_carrier_phase;
  int pos;

  pos = ld->bitcnt;

  h_forw_r_size = getbits(4) - 1;
  v_forw_r_size = getbits(4) - 1;
  h_back_r_size = getbits(4) - 1;
  v_back_r_size = getbits(4) - 1;
  dc_prec = getbits(2);
  pict_struct = getbits(2);
  topfirst = getbits(1);
  frame_pred_dct = getbits(1);
  conceal_mv = getbits(1);
  ld->qscale_type = getbits(1);
  intravlc = getbits(1);
  ld->altscan = getbits(1);
  repeatfirst = getbits(1);
  chroma_420_type = getbits(1);
  prog_frame = getbits(1);
  composite_display_flag = getbits(1);
  if (composite_display_flag)
  {
    v_axis = getbits(1);
    field_sequence = getbits(3);
    sub_carrier = getbits(1);
    burst_amplitude = getbits(7);
    sub_carrier_phase = getbits(8);
  }

  if (verbose>0)
  {
    printf("picture coding extension (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      printf("  forward_horizontal_f_code=%d\n",h_forw_r_size+1);
      printf("  forward_vertical_f_code=%d\n",v_forw_r_size+1);
      printf("  backward_horizontal_f_code=%d\n",h_back_r_size+1);
      printf("  backward_vertical_f_code=%d\n",v_back_r_size+1);
      printf("  intra_dc_precision=%d\n",dc_prec);
      printf("  picture_structure=%d\n",pict_struct);
      printf("  top_field_first=%d\n",topfirst);
      printf("  frame_pred_frame_dct=%d\n",frame_pred_dct);
      printf("  concealment_motion_vectors=%d\n",conceal_mv);
      printf("  q_scale_type=%d\n",ld->qscale_type);
      printf("  intra_vlc_format=%d\n",intravlc);
      printf("  alternate_scan=%d\n",ld->altscan);
      printf("  repeat_first_field=%d\n",repeatfirst);
      printf("  chroma_420_type=%d\n",chroma_420_type);
      printf("  progressive_frame=%d\n",prog_frame);
      printf("  composite_display_flag=%d\n",composite_display_flag);
      if (composite_display_flag)
      {
        printf("    v_axis=%d\n",v_axis);
        printf("    field_sequence=%d\n",field_sequence);
        printf("    sub_carrier=%d\n",sub_carrier);
        printf("    burst_amplitude=%d\n",burst_amplitude);
        printf("    sub_carrier_phase=%d\n",sub_carrier_phase);
      }
    }
  }
}


/* decode picture spatial scalable extension */

static void picture_spatial_scalable_extension()
{
  int pos;

  pos = ld->bitcnt;

  ld->pict_scal = 1; /* use spatial scalability in this picture */

  lltempref = getbits(10);
  flushbits(1);
  llx0 = getbits(15);
  if (llx0>=16384)
    llx0-= 32768;
  flushbits(1);
  lly0 = getbits(15);
  if (lly0>=16384)
    lly0-= 32768;
  stwc_table_index = getbits(2);
  llprog_frame = getbits(1);
  llfieldsel = getbits(1);
  if (verbose>0)
  {
    printf("picture spatial scalable extension (byte %d)\n",(pos>>3)-4);
    if (verbose>1)
    {
      printf("  lower_layer_temporal_reference=%d\n",lltempref);
      printf("  lower_layer_horizontal_offset=%d\n",llx0);
      printf("  lower_layer_vertical_offset=%d\n",lly0);
      printf("  spatial_temporal_weight_code_table_index=%d\n",
        stwc_table_index);
      printf("  lower_layer_progressive_frame=%d\n",llprog_frame);
      printf("  lower_layer_deinterlaced_field_select=%d\n",llfieldsel);
    }
  }
}


/* decode picture temporal scalable extension
 *
 * not implemented
 */

static void picture_temporal_scalable_extension()
{
  error("temporal scalability not supported\n");
}


/* decode extra bit information */

static void ext_bit_info()
{
  while (getbits1())
    flushbits(8);
}
