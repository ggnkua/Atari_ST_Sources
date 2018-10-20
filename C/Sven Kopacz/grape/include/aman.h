typedef struct
{
	long		date;
	
	int			*dcolor_a;  /* Farbe aktives Fenster */
	int			*dcolor_b;  /* Farbe andere Fenster */
	int     *workxywh;  /* Gr”že */
	int			*kind;
	int			*owner;
	char		**name;
	char		**info;
	unsigned char	*menu_id;
	OBJECT	**menu_tree;
	int			*flags; /* Bit 0 = Ge”ffnet, Bit 1 = Ikonifiziert */
	int			*vslpos;
	int			*vslsiz;
	int			*hslpos;
	int			*hslsiz;
}A_MAN;
