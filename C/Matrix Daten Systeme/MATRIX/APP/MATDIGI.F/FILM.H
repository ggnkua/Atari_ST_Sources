# define MAXframesPerSequence	500

typedef struct
{
	uword 	*data ;
	uword	delay ;
	uword	reserved ;
} IMAGE ;

# define USEcurrent	((uword)-2)
# define USEdefault	((uword)-1)
# define BLKformat	0
# define TGAformat	'T'
# define RGBformat	'B'
# define JPGformat	'J'
# define TICformat	'C'
# define TIFformat	'I'

# define DEFformat	JPGformat

/*
	current : points to current displayed image
	current >= valid : points to malloced, but not defined frame
    0 <= current < frames
*/

typedef struct
{
	int		 		frames, valid, current ;
	long	 		framesize ;
	TBlitWindow 	blitwind ;
	POINT 			zoom ;
	uword			format ;
	uword			reserved ;
	IMAGE			images[MAXframesPerSequence] ;
} SEQUENCE ;

# define SequenceEmpty(seq)		((seq)->valid == 0)
# define SequenceNotEmpty(seq)	((seq)->valid > 0)

# define SEQend			-2
# define SEQnotSynced	-1

# define _DataValid(s,i) ((i)>=0 && (i)<(s)->valid)
typedef enum { FR_INVALID, FR_DATAVALID, FR_BUFFERVALID } TValid ;
