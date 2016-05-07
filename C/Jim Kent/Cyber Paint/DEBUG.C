
#include <osbind.h>
#include "flicker.h"

flash_red()
{
flash_bg(0x700);
}

flash_bg(col)
WORD col;
{
WORD save_col;

save_col = Setcolor(0, -1);
Setcolor(0, col);
wait_a_jiffy(10);
Setcolor(0, save_col);
}

restore_bg()
{
Setcolor(0, sys_cmap[0]);
wait_a_jiffy(1);
}

poke_bg(col)
WORD col;
{
Setcolor(0, col);
wait_a_jiffy(1);
}
