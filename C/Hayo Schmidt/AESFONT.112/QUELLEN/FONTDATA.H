/* Typedefs */
/* -------- */

typedef struct 
{
	int fontid;
	int chwdt;
	int chhgt;
	int clwdt;
	int clhgt;
	int fsm;
}
FONT_ATTR;

typedef struct
{
	long	af_magic;
	int	version;
	int	installed;
	int	cdecl (*getinfo)(int af_gtype, int *af_gout1, int *af_gout2,
													 int *af_gout3, int *af_gout4);
}AFNT;


/* Prototypen */
/* ---------- */

int 	get_fontinfo(int handle, FONT_ATTR *Default, FONT_ATTR *Ibm,
								  FONT_ATTR *Small, int *Addfnt);
int 	appl_getinfo(int ap_gtype, int *ap_gout1, int *ap_gout2,
											int *ap_gout3, int *ap_gout4);
int 	afnt_getinfo(int af_gtype, int *af_gout1, int *af_gout2,
										 	int *af_gout3, int *af_gout4);
#ifndef BOOLE
 #define BOOLE
 typedef enum               /* Boole'sche Variablen */
 {
    FALSE,
    TRUE
 }
 boolean;
#endif

boolean	getcookie(long cookie_magic, long *p_value);
