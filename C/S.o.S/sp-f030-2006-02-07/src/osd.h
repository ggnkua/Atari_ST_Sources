
#ifndef _OSD_H_
#define _OSD_H_

#include <mint/falcon.h>
#include <sys/time.h>
#include "psg.h"
#include "shared.h"
#include "main.h"
#include "ikbd.h"
#include "loadrom.h"

#include "drv_VIDEL5.h"
#include "drv_VIDEL16.h"

int (*Open_screendriver) (unsigned long int gg_flag, unsigned char* bm_ptr);
int (*Close_screendriver) ();
int (*Update_screendriver) (unsigned long int skip);
int (*Palette_screendriver) (unsigned char* source_pal);

#endif /* _OSD_H_ */
