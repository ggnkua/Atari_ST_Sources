#if !defined LEVELSDRAW_H
#define LEVELSDRAW_H

#include <aes.h>
#include <vdi.h>

#include "levels.h"
#include "score.h"
#include "windows.h"

void levels_draw (int app_handle, struct win_data * wd, struct scores * score_table, int x, int y, int w, int h);

#endif
