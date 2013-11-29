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

/***************************************************************
	Liste des erreurs d'impression 
****************************************************************
*		 5 	= Pas de papier							|	SLM_NOPAPER
*		 3 	= Pas de toner							|	SLM_NOTONER
*		 2 	= Erreur g‚n‚rale						|	SLM_ERROR
*		 0	= Ok pas d'erreurs					|	PRINTER_OK
*		-1 	=	Erreur g‚n‚rale						|	PRINTER_ERROR
*		-2	= P‚riph‚rique pas pret			|	PRINTER_NOTREADY
*		-9	= Pas de papier							|	PRINTER_NOPAPER
*		-15	= P‚riph‚rique non existant	|	DRIVER_NOEXIST
****************************************************************/
#define	SLM_NOPAPER					5
#define	SLM_NOTONER					3
#define	SLM_ERROR						2
#define	PRINTER_OK					0
#define	PRINTER_ERROR				-1
#define	PRINTER_NOTREADY		-2
#define	PRINTER_NOPAPER			-9
#define	DRIVER_NOEXIST			-15

int vq_driver_info(int handle,int *lib,int *drv,int *plane,int *attr, char name[27]);
int vq_margin(int handle,int *top,int *bot,int *lft,int *rgt,int *xdpi,int *ydpi);
int vq_bit_image(int handle,int *ver,int *maximg,int *form);
int vs_page_info(int handle,int type,char txt[60]);
int vs_crop(int handle,int ltx1,int lty1,int ltx2,int lty2,int ltlen,int ltoffset);
int vq_image_type(int handle,char *file,BIT_IMAGE *img);
int vs_save_disp_list(int handle,char *name);
int vs_load_disp_list(int handle,char *name);

