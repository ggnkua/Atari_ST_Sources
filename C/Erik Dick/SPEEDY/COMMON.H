/*************************************************
 Allgemeine defines
 *************************************************/

#define FALSE	0
#define TRUE	1

#define min(a,b) ((a)>(b) ? (b) : (a))
#define max(a,b) ((a)>(b) ? (a) : (b))
#define between(a,b,c) ((a <= b) && (b <= c))

/*************************************************
 Defines fr's AES
 *************************************************/

#define MB_UP		0x0000
#define MB_DN		0x0001
#define L_BUTT		0x0001
#define R_BUTT		0x0002
#define NICHT		0x0100
#define S_CLICK		0x0001
#define D_CLICK		0x0002
#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_CTRL		0x0004
#define K_ALT		0x0008

typedef struct rect			/* Rechteck			*/
{
	int		X,
			Y,
			W,
			H;
}RECT;

/*************************************************
 Fr's Projekt
 *************************************************/

typedef struct
{
	int		handle;				/* Der vdi_handle der Arbeitsstation	*/
	int		x_res,y_res;		/* Die Aufl”sung						*/
	int		x_off,y_off;		/* Offsets zu einer DIN A4-Page			*/
	int		x_scale,y_scale;	/* Die Gr”že eines Pixels				*/
}DEV_STRUCT;

/*************************************************
 Prototypen
 *************************************************/

long count_fonts(FONTLIST Fonts);
FONT *get_font(FONTLIST Fonts,long Index);

int speedo_active(void);
int magix_active(void);
int mtos_active(void);

void Clip(int ScreenVHandle,RECT *Rect,int Mode);
int Intersect(RECT *Rect1, RECT *Rect2);
void set_system_font( int VDI_Handle );

int slider_calc_size(int Winddim,long Contdim);
int slider_calc_pos(int Winddim,long Contdim,long Offset);
long slider_get_pos(int Winddim,long Contdim,int Position);
int isinrect(int px,int py,RECT *Rect);

/*************************************************
 Globale Variablen
 *************************************************/

extern 
	int	ApplicationID,
		ScreenVHandle,
		CharW,CharH,CellW,CellH;

extern
	int KNOWS_APPL_GETINFO;

/********************************************************************************
 *							E N D - O F - F I L E								*
 ********************************************************************************/
