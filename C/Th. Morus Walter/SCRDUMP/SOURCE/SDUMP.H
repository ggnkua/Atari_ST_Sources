#define BUF_SIZE	1024
#define IMG_WIDTH	1024
#define MAX_LINE_LEN 1024

typedef struct
{
	int red;
	int green;
	int blue;
} COLOR;

/*
	store_img:
		name: dateiname
		buffer: mfdb auf zu speichernde bitmap
				buffer->fd_addr == 0l -> trage screen (aus linea!!) ein
		wid:  breite (0->maximal)
		hght: h”he (0->maximal)
		col:  zeiger auf farbtabelle
		xflag: ximg-flag 1 -> ximg, 0 -> img
*/

typedef struct {
	char file[40];
	char  ximg;
} INST;

typedef struct {
	char file[40];
	char ximg;
	char althelp;
} XINST;

typedef struct {
	long magic;
	INST inst;
	unsigned int  nr;
	void (*make_name)(char *name);
	int (*store_img)(char *name,MFDB *buffer,int wid,int hght,COLOR *col,int xflag);
} SCREEN_DUMP;


typedef struct {
	char *pic_buf;
	int bwid;		/* breite des bildausschnittes in bytes */
	int hght;		/* h”he des bildausschnittes in punkten */
	int pic_bwid;	/* breite des ges.bildes (gr”er, falls bild zu breit) */
	long plane_size;	/* gr”e der plane */
	int planes;		/* anzahl der bitmaps */
	int standard;	/* 0 st-screen, 1 -> standard */
	int flag;
	char *pic_line;
	int line_nr;
	char *line;
} SAVE_IMG;

typedef struct {		/* fr save/load gem-image */
	int ver_num;
	int head_len;
	int plane_num;
	int pat_len;
	int pix_wid;
	int pix_hght;
 	int pix_num;
	int scan_num;
} IMG_HEAD;


