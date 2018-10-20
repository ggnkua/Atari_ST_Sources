typedef struct
{
	char	name[11];	/* 10 Zeichen Name 0-terminiert */
	int		type;			/* 0=24 Bit Paint, 1=8 Bit Maske */
	int		visible;	/* !=0: sichtbar */
	int		width;
	int		height;
	int		word_width;
	void	*red;
	void	*yellow;
	void	*blue;
}LAYER;

typedef struct _LAY_LIST
{
	struct	_LAY_LIST *prev;
	LAYER		this;
	struct 	_LAY_LIST	*next;
}LAY_LIST;

LAY_LIST	first_lay, act_lay;

struct
{
	int off;	/* Offset (ab 0) */
	int	sel;	/* Nummer des selektierten */
}layers;
