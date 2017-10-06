
#include <e_gem.h>
#include <string.h>
#include <stdio.h>

#define LOADED		1
#define ERROR		0
#define DISC_ERR	-1
#define MEM_ERR		-2

#define NO_FILE	0
#define ASCII	1
#define DUMP	2
#define IMAGE	3

typedef	unsigned char byte;

/* Font-Information (ID,Grîûe,Farbe) */
typedef struct
{
	int	id,size,color;
} FONT;

/* Setup */
typedef struct
{
	int	tab;
	FONT dump,text;
	GRECT start;
} SETUP;

/* Header einer Image-Datei */
typedef struct
{
	int	version;
	int	headlength;
	int	nplanes;
	int patlen;
	int pixwidth;
	int	pixheight;
	int	width;
	int height;
} IMG;

/* Struktur fÅr Text-/Dumpzeilen */
typedef struct
{
	byte	*text;		/* Zeiger auf Text */
	int		len,tabs;	/* LÑnge der Zeile und Anzahl der Tabulatoren */
	int		max_len;	/* max. LÑnge der expandierten Zeile */
} TEXT;

typedef struct
{
	WIN		*win;				/* Zeiger auf Fenster-Struktur */

	SCROLL  sc;					/* SCROLL-Struktur */

	char	fname[MAX_PATH];	/* Pfad und Dateiname der Datei */
	char	info[128];			/* Infozeile des Fensters */

	byte	valid,flag;
	byte	*mem,*data;
	long	size;

/* nur gÅltig, wenn flag==ASCII oder flag==DUMP */
	TEXT	*text;

#ifdef CURSOR
	char	find,insens,words,back,search[256];
	long	crs_line,crs_y;
	int		crs_row,crs_lastrow,crs_x,crs_w,crs_on,crs_valid,crs_len;
	int		crs_width[256];
	long	mrk_line[10];
	int		mrk_row[10];
#endif

	long	lines;
	int		rows,max_rows,tabs,tab_size;
	FONT	font;
	int		font_prop,font_cw,font_spw,font_ch;

/* nur gÅltig, wenn flag==IMAGE */
	byte	*img_mem;
	MFDB	img;
	int		width,height;
} DATA;

extern SETUP set;

char *getcwd(char *,int);

void error(int,char *);
void ClearData(DATA *);
int LoadData(DATA *,char *,char *,long);
void DrawData(int,WIN *,GRECT *);

void CalcText(DATA *);
void SetFont(DATA *,boolean);

#ifdef CURSOR
byte *MakeString(DATA *,TEXT *,int *,byte **);
void DrawCursor(DATA *);
int StringWidth(DATA *,byte *,int);
int CharWidth(DATA *,byte);
#endif
