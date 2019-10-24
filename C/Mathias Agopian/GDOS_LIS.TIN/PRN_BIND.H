#define IMG_MASK	0x1
#define IMG_OK		0x1

#define TGA_MASK	0x00000110
#define	TGA_TYPE_2	0x4

#define APPL		0
#define DOC		1
#define CREAT		2
#define REM		3


typedef struct
{
	int	nbplanes;
	int	width;
	int	height;
}BIT_IMAGE;

int vq_driver_info(int handle,int *lib,int *drv,int *plane,int *attr, char name[27]);
int vq_margin(int handle,int *top,int *bot,int *lft,int *rgt,int *xdpi,int *ydpi);
int vq_bit_image(int handle,int *ver,int *maximg,int *form);
int vs_page_info(int handle,int type,char txt[60]);
int vs_crop(int handle,int ltx1,int lty1,int ltx2,int lty2,int ltlen,int ltoffset);
int vq_image_type(int handle,char *file,BIT_IMAGE *img);

/* Don't use the following functions */

int vs_save_disp_list(int handle,char *name);
int vs_load_disp_list(int handle,char *name);
int vs_lum(int handle,int cont1000,int lum1000);
