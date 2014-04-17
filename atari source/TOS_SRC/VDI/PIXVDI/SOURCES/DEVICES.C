#include	"portab.h"
#include	"fontdef.h"
#include	"attrdef.h"
#include	"scrndev.h"
#include	"vardefs.h"
#include	"lineavar.h"
#include	"gsxdef.h"
#include	"gsxextrn.h"

static SCREENDEF   devSTLow  = {
			    "ST LOW", 2, 4, 160, 320,
			    200, 278, 278, INTERLEAVED, &ram8x8,
			    16, 1, 4096, 1, &STSoftList,
			    &STHardList, &STSoftList, NULL
			};

static SCREENDEF   devSTMed  = {
			    "ST MEDIUM", 3, 2, 160, 640,
			    200, 278, 556, INTERLEAVED, &ram8x8,
			    4, 1, 4096, 1, &STSoftList,
			    &STHardList, &STSoftList, NULL
			};

static SCREENDEF   devSTHigh = {
			    "ST HIGH", 4, 1, 80, 640,
			    400, 278, 278, INTERLEAVED, &ram8x16,
			    2, 1, 4096, 1, &STSoftList,
			    &STHardList, &STSoftList, NULL
			};

static SCREENDEF   devTTLow  = {
			    "TT LOW", 9, 8, 320, 320,
			    480, 556, 278, INTERLEAVED, &ram8x16,
			    256, 1, 4096, 1, &STSoftList,
			    &STHardList, &STSoftList, NULL
			};

static SCREENDEF   devTTMed  = {
			    "TT MEDIUM", 6, 4, 320, 640,
			    480, 278, 278, INTERLEAVED, &ram8x16,
			    16, 1, 4096, 1, &STSoftList,
			    &STHardList, &STSoftList, NULL
			};

static SCREENDEF   devTTHigh = {
			    "TT HIGH", 8, 1, 160, 1280,
			    960, 278, 278, INTERLEAVED, &ram8x16,
			    2, 1, 2, 0, &STSoftList,
			    &STHardList, &STSoftList, NULL
			};


static SCREENDEF   dev512x400x32  = {
			    "MATRIX", 12, 32, 2048, 512,
			    400, 278, 278, PIXPACKED, &ram8x16,
			    256, 1, 0, 0, &PixSoftList,
			    &PixHardList, &PixSoftList, 0xFEC00800L
			};

static SCREENDEF   dev640x480x16  = {
			    "XGA 640x480", 11, 16, 1280, 640, 
			    480, 278, 278, PIXPACKED, &ram8x16,
			    256, 1, 0, 0, &SPPixSoftList,
			    &SPPixHardList, &SPPixSoftList, NULL
			};

static SCREENDEF   dev8Bit   = {
			    "640x480x8 pixel packed", 10, 8, 640, 640,
			    480, 278, 278, PIXPACKED, &ram8x16,
			    256, 1, 0, 1, &PixSoftList,
			    &PixHardList, &PixSoftList, NULL
			};

static SCREENDEF   _dev640x480x8 = {
			    "640x480x8 interleaved", 13, 8, 640, 640,
			    480, 278, 278, INTERLEAVED, &ram8x16,
			    256, 1, 4096, 1, &STSoftList,
			    &STHardList, &STSoftList, NULL
			};

static SCREENDEF   dev320x200x16 = {
			    "XGA 320x200", 14, 16, 640, 320, 
			    200, 278, 278, PIXPACKED, &ram8x8,
			    256, 1, 0, 0, &SPPixSoftList,
			    &SPPixHardList, &SPPixSoftList, NULL
			};

static SCREENDEF   _dev320x200x8 = {
			    "320x200x8 interleaved", 16, 8, 320, 320,
			    200, 278, 278, INTERLEAVED, &ram8x8,
			    256, 1, 0, 1, &STSoftList,
			    &STHardList, &STSoftList, NULL
			};

SCREENDEF   *devices[]	= {
			&devSTLow, &devSTMed, &devSTHigh,
			&devTTLow, &devTTMed, &devTTHigh,
			&dev512x400x32, &dev640x480x16, &dev8Bit,
			&_dev640x480x8, &dev320x200x16, &_dev320x200x8,
			NULL	
	    };
