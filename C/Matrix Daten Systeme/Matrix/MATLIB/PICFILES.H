/* picfiles.h	/ MATRIX / WA 23.03.91	*/
/* last version :          WA 17.12.91  */

# define PICerrBase	500

# define OK			0

# define NOmemory	(1+PICerrBase)
# define CANTopen	(2+PICerrBase)
# define CANTread	(3+PICerrBase)
# define WRONGsize	(4+PICerrBase)
# define ILLformat	(5+PICerrBase)
# define CANTcreate	(6+PICerrBase)
# define CANTwrite	(7+PICerrBase)
# define NOcolorChr	(8+PICerrBase)
# define DECOMPerr	(9+PICerrBase)
# define ARGcount	(10+PICerrBase)

# define MAXpicError	(11+PICerrBase)

extern char *pic_error ( int error ) ;

typedef struct
{
	int x, y ;
} Point ;

/* file types */

# define UNDEFfile	0
# define MOGfile	1
# define MOCfile	2
# define ESMfile	3
# define TIFfile	4
# define RGBfile	5
# define VIDfile	6
# define IMGfile	7
# define BITfile	8
# define I16file	9
# define MCCfile   10
# define INFfile   11
# define T16file   12
# define R16file	13
# define G16file	14
# define B16file	15
# define YCfile		16
# define PPMfile	17
# define JPGfile	18

# define MAXfType  18

typedef unsigned PICfileType ;

/*=== MOC / ESM ===*/

# define ESMmagic "TMS"

# define ESMgrayArt	2

typedef struct
{
   char  kennung[4];
   int   head_size;
   int   breite;
   int   hoehe;
   int   tiefe;
   int   bildart;
   int   tiefe_rot;
   int   tiefe_gruen;
   int   tiefe_blau;
   int   tiefe_schwarz;
   int   reserved[10];
} PIChead ;

# ifndef TRUE
typedef struct { byte rsrvd,r,g,b ; } RGB ;

typedef RGB PALETTE[256] ;
# endif

/* 	RRRG.GGBB - color index	*/
# define COLindex(r,g,b) ((r&0xe0)|((g&0xe0)>>3)|((b&0xc0 )>>6))
# define Rval(p) ((p&0xe0)|((g&0xe0)>>3)|((b&0xc0 )>>6))

# define ESMtiefe	24
# define YCtiefe	16
# define MOCtiefe	 8

# define DEFAULTesmHead \
{ ESMmagic, 0x2a, 1280, 960, ESMtiefe, 3,   8, 8, 8, 0, { 0,0,0,0,0,0,0,0,0,0 } }


typedef struct
{
	PIChead	*head ;
	byte	*data ;
} ESMpic ;

# define MOCmagic	"MOC"

typedef struct
{
	PIChead *head ;
	PALETTE	*palette ;
	byte	*data ;
} MOCpic ;

typedef struct
{
	PIChead *head ;
	PALETTE	*palette ;
	byte	*data ;
	long	size,
			used ;
} MCCpic ;


# define DEFAULTmocHead \
{ MOCmagic, 0x2a, 1280, 960, MOCtiefe, 3,   8, 8, 8, 0, { 0,0,0,0,0,0,0,0,0,0 } }


typedef struct { byte Y,C ; } YC ;

# define YCmagic	"Y-C"

typedef ESMpic YCpic ;	/*	head->bildart == n <=> 4:n:n	*/

# define free_yc_pic(pic)	free_esm_pic(pic)
# define clear_yc_pic(pic)	clear_esm_pic(pic)

# define YC_411	1
# define YC_422	2

# define DEFAULTycHead \
{ YCmagic, 0x2a, 1280, 960, YCtiefe, 3,   8, 8, 8, YC_422, { 0,0,0,0,0,0,0,0,0,0 } }


/*=== TIF ===*/

typedef struct
{
   byte  h1[30];
   int   breite;
   byte  h2[10];
   int   hoehe;
   byte  h3[38];
} TIFhead ;


typedef struct
{
	TIFhead *head ;
	byte	*data ;
} TIFpic ;

# define R 0
# define G 1
# define B 2

typedef TIFpic RGBtifs[3] ; 		/* 3 TIF files == 24 Bit data	*/


/*=== I16 ===*/

# define PALETTE_START 100
# define DATA_START 1024

typedef struct {  /*      offset          meaning 		*/
	int _tablen;   /*         0         ; L„nge der Tabelle	*/
	int _res;      /*         2         ; Interne Aufl”sung	*/
	int _bpp;      /*         4         ; Bits pro Pixel	*/
	int _bpc;      /*         6         ; Bits pro Farbe	*/
	int _xres;     /*         8         ; x-Aufl”sung	*/
	int _yres;     /*         10        ; y-Aufl”sung	*/
	int _xbytes;   /*         12        ; Bytes pro Zeile	*/
# if 0
	int _piclen;   /*         14        ; Bildl„nge in Bytes	*/
	int _dummy;
# else
	long _piclenl ;
# endif
	int _colors;   /*         18        ; Anzahl Farben	*/
	int _maxgrey;  /*         20        ; Max. Graustufe	*/
	int _pallen;   /*         22        ; L„nge einer Palette in Bytes	*/
} I16head ;

# define I16palSize	3*256

typedef char I16palette[I16palSize] ;

typedef struct {
	I16head		*head ;
	I16palette	*palette ;
			char dum1[ PALETTE_START-sizeof(I16head) ];
			char dum2[ DATA_START-sizeof(I16palette)-PALETTE_START ];
	byte		*data ;
} I16pic ;



# define BUF_SIZE (DISPLAY_SIZE+(long)DATA_START)



extern unsigned int pic_file_type ( char *file_name ) ;
extern char *pic_file_ext ( int ftyp ) ;
extern void p_free ( void **p ) ;
# define pfree(pp) p_free ( (void **)(pp) )



/*=== ESM / MOC ===*/

extern void print_pic_head ( PIChead *head ) ;
extern long pic_data_size ( PIChead *head ) ;


/*=== ESM ===*/

extern void free_esm_pic ( ESMpic *esm ) ;
extern void clear_esm_pic ( ESMpic *esm ) ;
extern int malloc_esm_pic ( ESMpic *esm, int w, int h ) ;
extern int read_esm_picture ( const char *name, ESMpic *esm ) ;
extern int write_esm_picture ( const char *name, ESMpic *esm ) ;
extern void window_to_esm ( byte *start, unsigned bpl,
							 int x, int y, int w, int h,
							 ESMpic *esmpic ) ;
extern void disti_esm ( ESMpic *esmpic,
						 byte *rp, byte *gp, byte *bp,
						 int x, int y, int w, int h,
						 unsigned bpl ) ;
extern int collect_esm ( ESMpic *esmpic,
				 byte *rp, byte *gp, byte *bp,
				 int x, int y, int w, int h,
				 unsigned bpl ) ;

extern void init_rgb6 ( void ) ;
extern void esm_to_6window ( ESMpic *esmpic,
					  byte *dp,
					  int x, int y, int w, int h,
				 	  unsigned bpl ) ;
extern void init_rgb6 ( void ) ;


/*=== YC ===*/

extern int malloc_yc_pic ( YCpic *yc, int w, int h ) ;
extern int read_yc_picture ( const char *name, YCpic *yc ) ;
extern int write_yc_picture ( const char *name, YCpic *yc ) ;
extern int yc_to_esm ( YCpic *yc, ESMpic *esm ) ;
extern void fill_yc ( YCpic *yc, int y, int cb, int cr ) ;
					
extern bool init_yc_to_rgb ( void ) ;
extern void yc_print_pixel ( YCpic *yc, int x, int y ) ;
extern void esm_print_pixel ( ESMpic *esm, int x, int y ) ;
extern void byte_print_pixel ( byte *base, int x, int y, int bpl ) ;
extern void print_yc_conv ( int y, int cb, int cr ) ;

/*=== MOC ===*/

extern void free_moc_pic ( MOCpic *moc ) ;
extern void clear_moc_pic ( MOCpic *moc ) ;
extern int malloc_moc_pic ( MOCpic *moc, int w, int h ) ;
extern int read_moc_picture ( const char *name, MOCpic *moc ) ;
extern int write_moc_picture ( const char *name, MOCpic *moc ) ;

extern void image_to_window ( UBYTE *start, unsigned bpl,
				 			  int x, int y, int w, int h,
							  UBYTE *data ) ;
# define moc_to_window(s,l,x,y,w,h,moc) image_to_window (s,l,x,y,w,h,moc->data)
extern void window_to_image ( UBYTE *start, unsigned bpl,
				 			  int x, int y, int w, int h,
							  UBYTE *data  ) ;
# define window_to_moc(s,l,x,y,w,h,moc) window_to_image (s,l,x,y,w,h,moc->data)

/*=== PPM ===*/

typedef struct
{
	int	 components, width, height, depth ;
	byte *data ;
} PPMpic ;

extern int malloc_ppm_pic ( PPMpic *ppm, int c, int w, int h, int d ) ;
extern void free_ppm_pic  ( PPMpic *ppm ) ;
extern void clear_ppm_pic ( PPMpic *ppm ) ;
extern int read_ppm_picture ( const char *name,  PPMpic *ppm ) ;
extern int write_ppm_picture ( const char *name, PPMpic *ppm ) ;
extern int ppm_to_esm ( PPMpic *ppm, ESMpic *esm ) ;
extern int esm_to_ppm ( ESMpic *esm, PPMpic *ppm ) ;

/*=== TIF ===*/

extern void free_tif_pic ( TIFpic *tif ) ;
extern void clear_tif_pic ( TIFpic *tif ) ;
extern void print_tif_head ( TIFhead *head ) ;
extern long tif_data_size ( TIFhead *head ) ;
extern int read_tif_picture ( const char *name, TIFpic *tif ) ;


/*=== TIFs ===*/

# define COLchar '#'

extern void clear_rgb_tifs ( RGBtifs tifs ) ;
extern void free_rgb_tifs ( RGBtifs tifs ) ;
extern int read_rgb_tifs ( const char *name, RGBtifs tifs ) ;


/*=== MCC ===*/

extern void free_mcc_pic ( MCCpic *mcc ) ;
extern void clear_mcc_pic ( MCCpic *mcc ) ;
extern int read_mcc_picture ( const char *name, MCCpic *mcc ) ;
extern int write_mcc_picture ( const char *name, MCCpic *mcc ) ;

extern int malloc_mcc_pic ( MCCpic *mcc, int w, int h ) ;
extern byte *compress_line ( byte *source, byte *dest, byte *maxdest, int length ) ;
extern byte *uncompress_line ( byte *source, byte *dest, byte *maxused, int length ) ;
extern int compress_window ( byte *display, unsigned bpl,
							 int x, int y, int w, int h,
							 MCCpic *mccpic ) ;
extern int uncompress_window ( byte *start, unsigned bpl,
							   int x, int y,
							   MCCpic *mccpic ) ;

extern void disti_moc  ( MOCpic *mocpic,
				 byte *rp, byte *gp, byte *bp,
				 int flags, int x, int y, int w, int h,
				 int mincol, int maxcol,
				 unsigned bpl ) ;


/*=== I16 ===*/

extern void free_i16_pic ( I16pic *i16 ) ;
extern void clear_i16_pic ( I16pic *i16 ) ;
extern int read_i16_picture ( const char *name, I16pic *i16pic ) ;
extern void t16_to_window ( I16pic *i16pic,
					 byte *rp, byte *gp, byte *bp,
					 int x, int y, int w, int h,
					 unsigned bpl ) ;


/*=== conversion procedures ===*/

extern int i16_to_moc ( I16pic *i16, MOCpic *moc ) ;
extern int mcc_to_moc ( MCCpic *mcc, MOCpic *moc ) ;
extern void flat_esm_picture ( PIChead *head, byte *data, int bits ) ;
extern int tifs_to_esm ( RGBtifs *tifs, ESMpic *esm ) ;
extern int moc_to_esm ( PIChead *moc_head, PALETTE *palette, byte *moc_data,
				 PIChead **esm_head, byte **esm_data ) ;
extern void index_to_rgb ( int color, RGB *pp ) ;
extern int pack_esm_file ( const char *esmnam, const char *mocnam ) ;
extern int compress_moc_file ( const char *mocnam, const char *mccnam ) ;
extern int uncompress_mcc_file ( const char *mccnam, const char *mocnam ) ;
