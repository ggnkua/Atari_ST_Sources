
#include "datatypes.h"

int convert_arj_file();

int write_file_to_disk(char *fname);

void write32(u8 *p,u32 v);
void write16(u8 *p,u16 v);

u16 read16(u8 *p);
u32 read32(u8 *p);
