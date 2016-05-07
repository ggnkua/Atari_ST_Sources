
struct	font_hdr {

int	id;
int	size;
char	facename[32];
int	ADE_lo;
int	ADE_hi;
int	top_dist;
int	asc_dist;
int	hlf_dist;
int	des_dist;
int	bot_dist;
int	wchr_wdt;
int	wcel_wdt;
int	lft_ofst;
int	rgt_ofst;
int	thckning;
int	undrline;
int	lghtng_m;
int	skewng_m;
int	flags;
char	*hz_ofst;
int	*ch_ofst;
int	*fnt_dta;
int	frm_wdt;
int	frm_hgt;
struct font_hdr	*nxt_fnt;
}; 

/* face identifer for font loaded from disk... */
#define CYP_CUSTOM_FONT	0xabc

extern struct font_hdr cfont;
