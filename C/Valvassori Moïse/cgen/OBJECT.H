 /************************************
 *    D‚finition des objects
 */
 
typedef	enum
{
	t_donnee,			/*	donn‚e	*/
	t_t_type,			/*	Type		*/
	t_appel_proc,
   t_d_procedure,    /*  D‚claration prototype  */
	t_procedure,		/*	D‚claration procedure	*/
	t_constante,		
	t_expression,		/*	 une op‚ration math‚matique ou autre chose	*/
	t_commentaire,
	t_bloc,				/*	Un bloc qui contient ce qu'il veut	*/
	t_vide				/*	vide,dernier objet	*/
}C_OBJ_TYPE;

typedef enum
{
	t_int,
	t_char,
	t_reel,
	t_struct,
	t_enum,
	t_union,
	t_nul,
	t_autre
}TYPE_D;

typedef	struct
{
	TYPE_D	d_type;      /* d_type=char,int,...     */
	char		*d_nom;     /* Nom de la donn‚e        */
	char		*d_vi;      /* Valeur initiale (texte) */
	long		d_tab;		/* Nbre d'‚l‚ment du tableau   si
	                     ==0 -> pas un tableau   */
	int	  d_flag;   /* Bit 0: Pointeur
	                         1: Extern
	                         2: Long
	                         3: unsigned           */
	void		*d_autre;	/* autre type C_OBJ *		*/
}DONNEE;
#define L_DONNEE 20

typedef struct
{
	TYPE_D	tt_type;     /* enum,struct...    */
	char		*tt_nom;    /* Nom du type       */
	int		tt_flag;   /* Bit 2: Long
	                         3: unsigned           */
   void		*tt_autre;	/* autre type C_OBJ	*/
}TYPE;
#define L_TYPE 8

typedef struct
{
	char  *ap_nom; /* nom de la proc‚dure … appeler */
}AP_PROC;
#define L_AP_PROC 4

typedef struct
{
	char		*pr_nom;       /* nom de la proc‚dure  */
	TYPE_D	pr_type;
	int	 	 pr_flag;   /* Bit 0: Pointeur
	                         1: Extern
	                         2: Long
	                         3: unsigned           */
	void		*pr_autre;	/* autre type C_OBJ *		*/
}PROC;
#define L_PROC	16

typedef struct
{
	char	*cts_nom;
	char  *cts_constante;   /* texte de la constante   */
}CTS;
#define L_CTS	8

typedef struct
{
	char  *epr_expression;  /* texte de l'expr‚ssion   */
}EXPR;
#define L_EXPR	4

#define L_vide	2
typedef union
{
	DONNEE	donnee;
	TYPE		type;
	AP_PROC	ap_proc;
	PROC		proc;
	CTS		cts;
	EXPR		expr;
	char*		bloc;		/*	Pointe sur le "nom du bloc"	*/
	int		vide;
}SPEC;

typedef struct
      {
         char  *commentaire;
         C_OBJ_TYPE  type;				/* type de l'objet                     */
         void			*prec;			/* grosse liste chain‚                 */
         void			*suivant;		/*	normalement tout les void* sont		*/
         void			*fils;			/*	en fait de C_OBJ * mais le				*/
         void			*pere;			/*	compilateur n'aime pas.					*/
         SPEC			spec;				/* pointe sur une structure sp‚ciale   */
      }C_OBJ;
/* L_C_OBJ = longeur C_OBJ + max (autre longeur)	= L_DONNEE (20)*/
#define L_C_OBJ	42
/* #define L_C_OBJ	22	*/

typedef enum
{
	op_ov_parent,		/*	parenthŠse */
	op_fr_parent,
   op_affect,
   op_plus,
   op_moins,
   op_mult,
   op_div,
   op_et,
   op_ou,
   op_xou,
   op_not,
   op_legal,        /*     operateur logique	*/
   op_lnegal,
   op_inf,
   op_sup,
   op_infe,				/*	Inf ou egal	*/
   op_supe,
   op_let,
   op_lou,
   op_lxou,
   op_lnot,
   op_var,      /*    Variable */
   op_varp,     /*    Variable pointeur */
   op_cts,      /*    constante			*/
   op_fin_exp   /*    Fin de l'xpr‚ssion  */
}OPERATOR;
#define N_OPERATOR 20