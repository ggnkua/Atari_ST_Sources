/*
 *		Cookies unit prototypes's functions
 *
 *	Autho	: FunShip
 *	File	: PCcookie.h
 *	Date	: 8 D‚cembre 1993
 *	Revision: 9 Novembre 1994
 *	Version	: 1.00
 *	Release	: 1.00
 *	Language: Pure C
 */
 
#ifndef __COOKIE__
#define __COOKIE__  __COOKIE__


/*
 *-------------------- D‚claration des constantes ------------------------
 */

#define	M68000		0x0000			/* Processeurs */
#define	M68010		0x000A
#define	M68020		0x0014
#define	M68030		0x001E

#define	ST		0x00000L		/* Machines */
#define	STE		0x10000L
#define	MSTE		0x10010L
#define	TT		0x20000L
#define	FALCON30	0x30000L

#define	KEYB_USA	0x0			/* Clavier */
#define	KEYB_D		0x1
#define	KEYB_F		0x2
#define	KEYB_GB		0x3
#define	KEYB_SP		0x4
#define	KEYB_I		0x5
#define	KEYB_CHD	0x7
#define	KEYB_CHF	0x8

#define	LG_USA		0x0			/* Langue */
#define	LG_D		0x1
#define	LG_F		0x2
#define	LG_GB		0x3
#define	LG_SP		0x4
#define	LG_I		0x5
#define	LG_CHD		0x7
#define	LG_CHF		0x8

#define	SHIFTER_ST	0x00000L		/* Circuit Video */
#define	SHIFTER_STE	0x10000L
#define	SHIFTER_TT	0x20000L
#define	VIDEL_FALCON	0x30000L

#define	MATRICE		0x08			/* Systeme sonore */
#define	DSP		0x04
#define	CODEC		0x02
#define	PSG		0x01

#define	NO_FPU		0			/* Copro. Math. */
#define	SFP004		1
#define	C68881_2	2
#define	C68881_2_SFP	3
#define	C68881		4
#define	C68881_SFP	5
#define	C68882		6
#define	C68882_SFP	7
#define	C68040		8
#define	C68040_SFP	9

#define	DATE_MJA	0			/* Format date */
#define	DATE_JMA	1
#define	DATE_AMJ	2
#define	DATE_AJM	3

#define	TIME_12		0			/* Format horaire */
#define	TIME_24		1

/*
 *------------- D‚claration d'un type cookie des Cookies Jar -------------
 */
 
typedef struct {
   		 char identification[4];			
		 union {
			 long mot_long;	  /* Au choix le type de l'info */
			 int  mot[2];
			 char octet[4];
		       } information;
	        } Type_Cookie;
			   
/*
 *--------------------------- Primitives publiques -----------------------
 */			   

Type_Cookie	*J_GetAdr(void);
int	J_Exist(void);
int	J_Read(Type_Cookie *liste);
int	J_Install(int nombre_slots);
int	J_Number(void);
long	J_Size(void);
int	J_Search(char identification[4],Type_Cookie *cookie);
int	J_Insert(Type_Cookie *new_cookie);
int	J_Delete(char identification[4]);

#endif
