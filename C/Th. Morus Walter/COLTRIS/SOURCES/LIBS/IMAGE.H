/*
	image.h

		headerdatei zur image-lade-bibliothek

	geschrieben von Th. Morus Walter

	(c) 1994/95 by Th. Morus Walter
*/

#include <vdi.h>

typedef struct
{
	int red;
	int green;
	int blue;
} IMG_COLOR;

typedef struct {
	int ver_num;
	int head_len;
	int plane_num;
	int pat_len;
	int pix_wid;
	int pix_hght;
 	int pix_num;
	int scan_num;
} IMG_HEADER;

typedef enum {
	IMG_OK,			/* 0 */
	IMG_ERROR,		/* 1 */
	IMG_MEMORY,		/* 2 */
	IMG_FORMAT,		/* 3 */
} IMG_ERR;

typedef enum {
	TRFM_OK,		/* 0 */
	TRFM_ERROR,		/* 1 */
	TRFM_MEMORY,	/* 2 */
} TRFM_ERR;

IMG_ERR load_img(char *name,MFDB *mfdb);
IMG_ERR load_ximg(char *name,MFDB *mfdb,IMG_COLOR **coltab);
IMG_ERR xload_img(IMG_HEADER *head,char *name,MFDB *mfdb);
IMG_ERR xload_ximg(IMG_HEADER *head,char *name,MFDB *mfdb,IMG_COLOR **coltab);

TRFM_ERR transform_img(MFDB *pic,int planes,int vdi_handle);

