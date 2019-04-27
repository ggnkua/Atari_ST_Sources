#if !defined POSNDRAW_H
#define POSNDRAW_H

#include <aes.h>
#include <vdi.h>

#include "position.h"
#include "windows.h"

/* Code for drawing a Sokoban position on screen */

enum type {ALL, UPDATE, MOVE};

void position_draw (int app_handle, struct position * posn, int x, int y, int w, int h, int offset_x, int offset_y, int type, int cell_h, int cell_w, int num_colours);

#endif
