#ifndef _BLIT_H_
#define _BLIT_H_

extern void vro_notcpy(int *pxy, MFDB *source, MFDB *dest);
extern void clear_back(int *pxy);
extern void cpy_2_back(int *pxy, MFDB *source, MFDB *mask);
extern void cpy_2_dest(int *pxy, MFDB *dest, MFDB *source, MFDB *mask);
extern void add_rect(int x,int y,int w,int h);
extern int rect_intersect( GRECT *r1, GRECT *r2, int winx, int winy );
extern void update_rects(void);
extern void disp_fx_field_melt( int target_win );

#endif