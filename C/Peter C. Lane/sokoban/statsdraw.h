#if !defined STATSDRAW_H
#define STATSDRAW_H

#include <aes.h>
#include <vdi.h>

#include "score.h"
#include "windows.h"

void stats_draw (int app_handle, struct win_data * wd, struct scores * score_table, int x, int y, int w, int h);

#endif