#ifndef __IMGLFMT_H
#define __IMGLFMT_H

typedef long IID ;

/* Helper to have a readable format string */
#define LR(x) ((IID)(x) << 8)

#define IID_UNKNOWN 0
#define IID_JPEG    LR('JPG')
#define IID_PNG     LR('PNG')
#define IID_TIFF    LR('TIF')
#define IID_GIF     LR('GIF')
#define IID_TARGA   LR('TGA')
#define IID_BMP     LR('BMP')
#define IID_IMG     LR('IMG')
#define IID_ART     LR('ART')
#define IID_NEO     LR('NEO')
#define IID_MAC     LR('MAC')
#define IID_DEGAS   LR('DEG')
#define IID_HEXDUMP LR('HEX')

#endif
