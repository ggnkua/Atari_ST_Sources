
#ifndef __main_h
#define __main_h


#include "datatypes.h"

#define PI 3.1415926f

#define tex_x 128
#define tex_y 128



#define RENDER_TEXMAPPED		1
#define RENDER_FLAT_LIGHT		2
#define RENDER_LINES_HIDDEN		3
#define RENDER_LINES			4


extern int display_mode;



extern char obj_fname[512];



extern u8 texture0[tex_y][tex_x];

extern u32 texture_tc_256x256[256*256];

void Fill_Test_RGB();
void Fill_Test_CHUNKY();


#endif


