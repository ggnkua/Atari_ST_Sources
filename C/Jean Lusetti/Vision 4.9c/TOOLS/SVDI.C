/*               Smart VDI               */
/* To avoid exposing VDI handle everyone */
/* And save some code size               */
#include "xgem.h"


void svro_cpyfm(short vr_mode, int* pxyarray, MFDB* psrcMFDB, MFDB* pdesMFDB)
{
  vro_cpyfm( handle, vr_mode, pxyarray, psrcMFDB, pdesMFDB ) ;
}

void svro_cpyfmSO(int* pxyarray, MFDB* psrcMFDB, MFDB* pdesMFDB)
{
  svro_cpyfm( S_ONLY, pxyarray, psrcMFDB, pdesMFDB ) ;
}

void svro_cpyfmSOS(int* pxyarray, MFDB* psrcMFDB)
{
  svro_cpyfmSO( pxyarray, psrcMFDB, &screen ) ;
}

void svr_trnfm(MFDB* psrcMFDB, MFDB* pdesMFDB)
{
  vr_trnfm( handle, psrcMFDB, pdesMFDB ) ;
}

void svs_clipON(int* pxyarray)
{
  vs_clip( handle, 1, pxyarray ) ;
}

void svs_clipOFF(int* pxyarray)
{
  vs_clip( handle, 0, pxyarray ) ;
}

short svswr_mode(short mode)
{
  return vswr_mode( handle, mode ) ;
}

short svq_color(short color_index, short set_flag, int* rgb)
{
  return vq_color( handle, color_index, set_flag, rgb ) ;
}

void svs_color(short index, int* rgb_in)
{
  vs_color( handle, index, rgb_in ) ;
}

short svsl_width(short width)
{
  return vsl_width( handle, width ) ;
}

short svsl_type(short type)
{
  return vsl_type( handle, type ) ;
}

short svsl_color(short color_index)
{
  return vsl_color( handle, color_index ) ;
}

void svsl_ends(short beg_style, short end_style)
{
  vsl_ends( handle, beg_style, end_style ) ;
}

short svsf_color(short color_index)
{
  return vsf_color( handle, color_index ) ;
}

short svsf_interior(short style)
{
  return vsf_interior( handle, style ) ;
}

short svsf_perimeter(short per_vis)
{
  return vsf_perimeter( handle, per_vis ) ;
}

void svr_recfl(int* pxyarray)
{
  vr_recfl( handle, pxyarray ) ;
}

void sv_pline(short count, int* pxyarray)
{
  v_pline( handle, count, pxyarray ) ;
}

void svst_alignment(short hor_in, short vert_in, int* hor_out, int* vert_out)
{
  vst_alignment( handle, hor_in, vert_in, hor_out, vert_out ) ;
}
