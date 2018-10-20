
typedef struct
{
	unsigned char	prev;		/* Stufe (6 aus 256) fÅr 0-Bit */
	unsigned char next;		/* Stufe fÅr 1-Bit */
	unsigned char	field[8]; /* 8*8 Bit Raster */
}DITHER_PRE_FIELD;

typedef struct
{
	unsigned char	field[64]; /* 8*8 Byte Raster */
}DITHER_FIELD;

extern DITHER_FIELD *r_dither_table[256];
extern DITHER_FIELD *g_dither_table[256];
extern DITHER_FIELD *b_dither_table[256];

extern DITHER_PRE_FIELD r_dither[256];
extern DITHER_PRE_FIELD g_dither[256];
extern DITHER_PRE_FIELD b_dither[256];

extern DITHER_FIELD rr_dither[256];
extern DITHER_FIELD gg_dither[256];
extern DITHER_FIELD bb_dither[256];

void	make_fifdith(void);
