/* Fontliste	*/

#define GDOS_BITMAPFONT 0
#define GDOS_VECTORFONT 1

#define GDOS_TYPEFACE_LEN 32

typedef struct _font
{
	struct _font	*next,*prev;
	int				type;
	int				id;
	char			typeface[GDOS_TYPEFACE_LEN+1];
}FONT;

typedef FONT* FONTLIST;
