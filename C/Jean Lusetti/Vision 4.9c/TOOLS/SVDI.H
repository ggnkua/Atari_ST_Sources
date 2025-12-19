#ifndef _SVDI_H
#define _SVDI_H

void svro_cpyfmSO(int* pxyarray, MFDB* psrcMFDB, MFDB* pdesMFDB) ;
void svro_cpyfmSOS(int* pxyarray, MFDB* psrcMFDB) ;
void svro_cpyfm(short vr_mode, int* pxyarray, MFDB* psrcMFDB, MFDB* pdesMFDB) ;
void svr_trnfm(MFDB* psrcMFDB, MFDB* pdesMFDB) ; 

void svs_clipON(int* pxyarray) ;
void svs_clipOFF(int* pxyarray) ;

short svswr_mode(short mode) ;

short svq_color(short color_index, short set_flag, int* rgb) ; 

void  svs_color(short index, int* rgb_in) ;

short svsf_color(short color_index) ;
short svsf_interior(short style) ;
short svsf_perimeter(short per_vis) ;

short svsl_color(short color_index) ;
short svsl_width(short width) ;
short svsl_type(short type) ;
void  svsl_ends(short beg_style, short end_style) ;

void svr_recfl(int* pxyarray) ; 
void sv_pline(short count, int* pxyarray) ;

void svst_alignment(short hor_in, short vert_in, int* hor_out, int* vert_out) ;

#endif