

#define PI 3.1415926f


#include "datatypes.h"
#include "filestuff.h"
#include "display.h"


void Fill_Test_RGB();
void Fill_Test_CHUNKY();


int Window_Update();


u32 read32_LE(u8 *ptr);
u16 read16_LE(u8 *ptr);

int get_yes_no();

extern char bmp_fname[512];

