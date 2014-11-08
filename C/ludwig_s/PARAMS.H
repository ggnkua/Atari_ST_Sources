/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

	global variable declarations for parameter structures

******************************************************************************/

/* note to myself: !!! marks unfinished code */

/* parameters displayed as */

char *vchar[8]= { "PPP", "PP ", "P  ", "MP ", "MF ", "F  ","FF ","FFF" };
char *int1char[10]= { "0","1","2","3","4","5","6","7","8","9" };
char *int2char[100]= {
"00","01","02","03","04","05","06","07","08","09",
"10","11","12","13","14","15","16","17","18","19",
"20","21","22","23","24","25","26","27","28","29",
"30","31","32","33","34","35","36","37","38","39",
"40","41","42","43","44","45","46","47","48","49",
"50","51","52","53","54","55","56","57","58","59",
"60","61","62","63","64","65","66","67","68","69",
"70","71","72","73","74","75","76","77","78","79",
"80","81","82","83","84","85","86","87","88","89",
"90","91","92","93","94","95","96","97","98","99" };

long p_func[N_OPERS],r_func[N_OPERS];

char *p_opers[N_OPERS] = {
	"U ", "> ", "< ", "? ", "+ ", "A ", "RF", "EX", "HL" ,"AC",
	"RV", "X ", "TA", "TB", "EO", "WM", "DU", "DD", "FD", "UC",
	"NR", "DR", "SR", "I ", "M ", "EC", "CU", "CD", "HA", "HB"
};
char *r_opers[N_OPERS]= {
	"U ", "> ", "< ", "? ", "+ ", "A ", "DM", "DU", "RN", "LS",
	"RV", "X ", "TA", "TB", "EV", "OD", "RT", "WR", "RD", "RO",
	"NR", "DR", "SR", "I ", "M ", "EC", "SP", "PD", "B ", "SW"
};

int p_hlim[N_OPERS]= {
	95, 99, 99, 95, 16,  4, 89, 19,  2, 89,
	32,  1, 32, 32,  1, 99, 89, 89,  8, 32,
	99, 32, 32,  1, 99, 31, 99, 99, 89, 89
};
int r_hlim[N_OPERS]= {
	95, 99, 99, 95, 16,  4, 19, 32,  1, 99,
	32,  1, 32, 32,  1,  1, 19, 99, 31, 99,
	99, 32, 32, 32, 99, 31,  8, 32, 32, 99
};
int *oper_hlim[2]= { p_hlim, r_hlim };

char *orderchar[3]= { ">>", "??", "<<" } ;
char *selectp[NR_OPERS]= { "-", "=", "+", "R", "M", "&", "r", "m",	"C", "D",
									"c", "d" } ;
char *selectr[NR_OPERS]= { "-", "=", "n", "N", "r", "R", "e", "E",
									"~", "D", "d", "?" };
char *syncchar[4]= { " Off  ","Pitch ","Rhythm", "Either" };
char *yesnochar[2]= { "No ","Yes" };
char *plusminus[3]= { "+/-"," + "," - " };
char *stepchar[2]= { "Chord","Time " };
char *timechar[33]= {
	" 1/32", " 1/16", " 3/32", " 1/8 ", " 5/32", " 3/16", " 7/32", " 1/4 ",
	" 9/32", " 5/16", "11/32", " 3/8 ", "13/32", " 7/16", "15/32", " 1/2 ",
	"17/32", " 9/16", "19/32", " 5/8 ", "21/32", "11/16", "23/32", " 3/4 ",
	"25/32", "13/16", "27/32", " 7/8 ", "29/32", "15/16", "31/32", " 1/1 ",
	"  X  " } ;

char *chromachar[13]= { "C ","C#","D ","D#","E ","F ","F#","G ","G#","A ",
								"A#","B ","X " };

/* parameter structures */
int nparams[3]= { NPPARAMS, NRPARAMS, NVPARAMS };
	/* offset,nbytes  ,row, col,     ncols, low, high,  dial,ndigits,encode */
PARAM pparams[NPPARAMS]= {
	S_PSERIES+0,  1,0, X_SERIES,    2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+1,  1,1, X_SERIES,    2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+2,  1,0, X_SERIES+3,  2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+3,  1,1, X_SERIES+3,  2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+4,  1,0, X_SERIES+6,  2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+5,  1,1, X_SERIES+6,  2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+6,  1,0, X_SERIES+9,  2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+7,  1,1, X_SERIES+9,  2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+8,  1,0, X_SERIES+12, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+9,  1,1, X_SERIES+12, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+10, 1,0, X_SERIES+15, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+11, 1,1, X_SERIES+15, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+12, 1,0, X_SERIES+18, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+13, 1,1, X_SERIES+18, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+14, 1,0, X_SERIES+21, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+15, 1,1, X_SERIES+21, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+16, 1,0, X_SERIES+24, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+17, 1,1, X_SERIES+24, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+18, 1,0, X_SERIES+27, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+19, 1,1, X_SERIES+27, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+20, 1,0, X_SERIES+30, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+21, 1,1, X_SERIES+30, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+22, 1,0, X_SERIES+33, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+23, 1,1, X_SERIES+33, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+24, 1,0, X_SERIES+36, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+25, 1,1, X_SERIES+36, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+26, 1,0, X_SERIES+39, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+27, 1,1, X_SERIES+39, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+28, 1,0, X_SERIES+42, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+29, 1,1, X_SERIES+42, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+30, 1,0, X_SERIES+45, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+31, 1,1, X_SERIES+45, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+32, 1,2, X_SERIES+ 0, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+33, 1,3, X_SERIES+ 0, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+34, 1,2, X_SERIES+ 3, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+35, 1,3, X_SERIES+ 3, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+36, 1,2, X_SERIES+ 6, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+37, 1,3, X_SERIES+ 6, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+38, 1,2, X_SERIES+ 9, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+39, 1,3, X_SERIES+ 9, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+40, 1,2, X_SERIES+12, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+41, 1,3, X_SERIES+12, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+42, 1,2, X_SERIES+15, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+43, 1,3, X_SERIES+15, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+44, 1,2, X_SERIES+18, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+45, 1,3, X_SERIES+18, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+46, 1,2, X_SERIES+21, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+47, 1,3, X_SERIES+21, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+48, 1,2, X_SERIES+24, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+49, 1,3, X_SERIES+24, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+50, 1,2, X_SERIES+27, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+51, 1,3, X_SERIES+27, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+52, 1,2, X_SERIES+30, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+53, 1,3, X_SERIES+30, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+54, 1,2, X_SERIES+33, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+55, 1,3, X_SERIES+33, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+56, 1,2, X_SERIES+36, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+57, 1,3, X_SERIES+36, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+58, 1,2, X_SERIES+39, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+59, 1,3, X_SERIES+39, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+60, 1,2, X_SERIES+42, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+61, 1,3, X_SERIES+42, 2, 0,        -2,-1, 2, int2char ,
	S_PSERIES+62, 1,2, X_SERIES+45, 2, 0, N_OPERS-1, P_DIAL, 1, p_opers ,
	S_PSERIES+63, 1,3, X_SERIES+45, 2, 0,        -2,-1, 2, int2char ,

	/* offset,nbytes ,row,      col,ncols,lo,hi,dial,ndigits,encode */
	S_PRAND+P_RCOPY,  2,0, X_RANDOM+13, 2, 0, 95, -1, 2, int2char,
	S_PRAND+P_RNCOL1, 2,1, X_RANDOM+ 0, 3, 0,  2, -1, 1, plusminus,
	S_PRAND+P_RNCOL2, 2,1, X_RANDOM+ 5, 2, 0, 31, -1, 2, int2char,
	S_PRAND+P_RORDER, 2,1, X_RANDOM+10, 2, 0,  2, -1, 1, orderchar,

	/* offset    ,nbytes,row,      col,ncols,lo,hi,dial,ndigits,encode */
	S_PRAND+P_RNSEL+ 0, 1,2, X_RANDOM- 2,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+ 1, 1,2, X_RANDOM- 1,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+ 2, 1,2, X_RANDOM+ 0,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+ 3, 1,2, X_RANDOM+ 1,1,0,NR_OPERS-1,PR_DIAL,1,selectp,

	S_PRAND+P_RNSEL+ 4, 1,2, X_RANDOM+ 3,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+ 5, 1,2, X_RANDOM+ 4,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+ 6, 1,2, X_RANDOM+ 5,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+ 7, 1,2, X_RANDOM+ 6,1,0,NR_OPERS-1,PR_DIAL,1,selectp,

	S_PRAND+P_RNSEL+ 8, 1,2, X_RANDOM+ 8,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+ 9, 1,2, X_RANDOM+ 9,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+10, 1,2, X_RANDOM+10,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+11, 1,2, X_RANDOM+11,1,0,NR_OPERS-1,PR_DIAL,1,selectp,

	S_PRAND+P_RNSEL+12, 1,2, X_RANDOM+13,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+13, 1,2, X_RANDOM+14,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+14, 1,2, X_RANDOM+15,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+15, 1,2, X_RANDOM+16,1,0,NR_OPERS-1,PR_DIAL,1,selectp,

	S_PRAND+P_RNSEL+16, 1,3, X_RANDOM- 2,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+17, 1,3, X_RANDOM- 1,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+18, 1,3, X_RANDOM+ 0,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+19, 1,3, X_RANDOM+ 1,1,0,NR_OPERS-1,PR_DIAL,1,selectp,

	S_PRAND+P_RNSEL+20, 1,3, X_RANDOM+ 3,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+21, 1,3, X_RANDOM+ 4,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+22, 1,3, X_RANDOM+ 5,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+23, 1,3, X_RANDOM+ 6,1,0,NR_OPERS-1,PR_DIAL,1,selectp,

	S_PRAND+P_RNSEL+24, 1,3, X_RANDOM+ 8,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+25, 1,3, X_RANDOM+ 9,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+26, 1,3, X_RANDOM+10,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+27, 1,3, X_RANDOM+11,1,0,NR_OPERS-1,PR_DIAL,1,selectp,

	S_PRAND+P_RNSEL+28, 1,3, X_RANDOM+13,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+29, 1,3, X_RANDOM+14,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+30, 1,3, X_RANDOM+15,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
	S_PRAND+P_RNSEL+31, 1,3, X_RANDOM+16,1,0,NR_OPERS-1,PR_DIAL,1,selectp,
};

PARAM rparams[NRPARAMS]= {
	/* offset,  nbytes,row,      col,ncols,lo,         hi,dial,ndigits,encode */
	S_RSERIES+0,  1,0, X_SERIES,    2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+1,  1,1, X_SERIES,    2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+2,  1,0, X_SERIES+3,  2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+3,  1,1, X_SERIES+3,  2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+4,  1,0, X_SERIES+6,  2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+5,  1,1, X_SERIES+6,  2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+6,  1,0, X_SERIES+9,  2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+7,  1,1, X_SERIES+9,  2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+8,  1,0, X_SERIES+12, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+9,  1,1, X_SERIES+12, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+10, 1,0, X_SERIES+15, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+11, 1,1, X_SERIES+15, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+12, 1,0, X_SERIES+18, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+13, 1,1, X_SERIES+18, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+14, 1,0, X_SERIES+21, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+15, 1,1, X_SERIES+21, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+16, 1,0, X_SERIES+24, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+17, 1,1, X_SERIES+24, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+18, 1,0, X_SERIES+27, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+19, 1,1, X_SERIES+27, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+20, 1,0, X_SERIES+30, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+21, 1,1, X_SERIES+30, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+22, 1,0, X_SERIES+33, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+23, 1,1, X_SERIES+33, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+24, 1,0, X_SERIES+36, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+25, 1,1, X_SERIES+36, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+26, 1,0, X_SERIES+39, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+27, 1,1, X_SERIES+39, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+28, 1,0, X_SERIES+42, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+29, 1,1, X_SERIES+42, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+30, 1,0, X_SERIES+45, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+31, 1,1, X_SERIES+45, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+32, 1,2, X_SERIES+ 0, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+33, 1,3, X_SERIES+ 0, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+34, 1,2, X_SERIES+ 3, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+35, 1,3, X_SERIES+ 3, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+36, 1,2, X_SERIES+ 6, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+37, 1,3, X_SERIES+ 6, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+38, 1,2, X_SERIES+ 9, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+39, 1,3, X_SERIES+ 9, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+40, 1,2, X_SERIES+12, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+41, 1,3, X_SERIES+12, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+42, 1,2, X_SERIES+15, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+43, 1,3, X_SERIES+15, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+44, 1,2, X_SERIES+18, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+45, 1,3, X_SERIES+18, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+46, 1,2, X_SERIES+21, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+47, 1,3, X_SERIES+21, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+48, 1,2, X_SERIES+24, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+49, 1,3, X_SERIES+24, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+50, 1,2, X_SERIES+27, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+51, 1,3, X_SERIES+27, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+52, 1,2, X_SERIES+30, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+53, 1,3, X_SERIES+30, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+54, 1,2, X_SERIES+33, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+55, 1,3, X_SERIES+33, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+56, 1,2, X_SERIES+36, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+57, 1,3, X_SERIES+36, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+58, 1,2, X_SERIES+39, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+59, 1,3, X_SERIES+39, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+60, 1,2, X_SERIES+42, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+61, 1,3, X_SERIES+42, 2, 0,        -1,-1, 2, int2char ,
	S_RSERIES+62, 1,2, X_SERIES+45, 2, 0, N_OPERS-1, R_DIAL, 1, r_opers ,
	S_RSERIES+63, 1,3, X_SERIES+45, 2, 0,        -1,-1, 2, int2char ,

	/* offset,  nbytes, row,   col,ncols,lo,         hi,dial,ndigits,encode */
	S_RRAND+R_RCOPY,  2,0, X_RANDOM+13, 2, 0, 95, -1, 2, int2char,
	S_RRAND+R_RNCOL1, 2,1, X_RANDOM+ 0, 3, 0,  2, -1, 1, plusminus,
	S_RRAND+R_RNCOL2, 2,1, X_RANDOM+ 5, 2, 0, 31, -1, 2, int2char,
	S_RRAND+R_RORDER, 2,1, X_RANDOM+10, 2, 0,  2, -1, 1, orderchar,

	/* offset,nbytes,  row,      col,ncols,lo,         hi,dial,ndigits,encode */
	S_RRAND+R_RNSEL+ 0, 1,2, X_RANDOM- 2,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+ 1, 1,2, X_RANDOM- 1,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+ 2, 1,2, X_RANDOM+ 0,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+ 3, 1,2, X_RANDOM+ 1,1,0,NR_OPERS-1,RR_DIAL,1,selectr,

	S_RRAND+R_RNSEL+ 4, 1,2, X_RANDOM+ 3,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+ 5, 1,2, X_RANDOM+ 4,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+ 6, 1,2, X_RANDOM+ 5,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+ 7, 1,2, X_RANDOM+ 6,1,0,NR_OPERS-1,RR_DIAL,1,selectr,

	S_RRAND+R_RNSEL+ 8, 1,2, X_RANDOM+ 8,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+ 9, 1,2, X_RANDOM+ 9,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+10, 1,2, X_RANDOM+10,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+11, 1,2, X_RANDOM+11,1,0,NR_OPERS-1,RR_DIAL,1,selectr,

	S_RRAND+R_RNSEL+12, 1,2, X_RANDOM+13,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+13, 1,2, X_RANDOM+14,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+14, 1,2, X_RANDOM+15,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+15, 1,2, X_RANDOM+16,1,0,NR_OPERS-1,RR_DIAL,1,selectr,

	S_RRAND+R_RNSEL+16, 1,3, X_RANDOM- 2,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+17, 1,3, X_RANDOM- 1,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+18, 1,3, X_RANDOM+ 0,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+19, 1,3, X_RANDOM+ 1,1,0,NR_OPERS-1,RR_DIAL,1,selectr,

	S_RRAND+R_RNSEL+20, 1,3, X_RANDOM+ 3,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+21, 1,3, X_RANDOM+ 4,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+22, 1,3, X_RANDOM+ 5,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+23, 1,3, X_RANDOM+ 6,1,0,NR_OPERS-1,RR_DIAL,1,selectr,

	S_RRAND+R_RNSEL+24, 1,3, X_RANDOM+ 8,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+25, 1,3, X_RANDOM+ 9,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+26, 1,3, X_RANDOM+10,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+27, 1,3, X_RANDOM+11,1,0,NR_OPERS-1,RR_DIAL,1,selectr,

	S_RRAND+R_RNSEL+28, 1,3, X_RANDOM+13,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+29, 1,3, X_RANDOM+14,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+30, 1,3, X_RANDOM+15,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
	S_RRAND+R_RNSEL+31, 1,3, X_RANDOM+16,1,0,NR_OPERS-1,RR_DIAL,1,selectr,
};
PARAM vparams[NVPARAMS]= {
	/* offset,nbytes,  row,      col,ncols,lo,         hi,dial,ndigits,encode */
	S_VSERIES+  0, 1,0, X_SERIES+ 0,3,0,7,-1,1,vchar, 
	S_VSERIES+  1, 1,0, X_SERIES+ 4,3,0,7,-1,1,vchar, 
	S_VSERIES+  2, 1,0, X_SERIES+ 8,3,0,7,-1,1,vchar, 
	S_VSERIES+  3, 1,0, X_SERIES+12,3,0,7,-1,1,vchar, 
	S_VSERIES+  4, 1,0, X_SERIES+16,3,0,7,-1,1,vchar, 
	S_VSERIES+  5, 1,0, X_SERIES+20,3,0,7,-1,1,vchar, 
	S_VSERIES+  6, 1,0, X_SERIES+24,3,0,7,-1,1,vchar, 
	S_VSERIES+  7, 1,0, X_SERIES+28,3,0,7,-1,1,vchar, 
	S_VSERIES+  8, 1,0, X_SERIES+32,3,0,7,-1,1,vchar, 
	S_VSERIES+  9, 1,0, X_SERIES+36,3,0,7,-1,1,vchar, 
	S_VSERIES+ 10, 1,0, X_SERIES+40,3,0,7,-1,1,vchar, 
	S_VSERIES+ 11, 1,0, X_SERIES+44,3,0,7,-1,1,vchar, 
	S_VSERIES+ 12, 1,0, X_SERIES+48,3,0,7,-1,1,vchar, 
	S_VSERIES+ 13, 1,0, X_SERIES+52,3,0,7,-1,1,vchar, 
	S_VSERIES+ 14, 1,0, X_SERIES+56,3,0,7,-1,1,vchar, 
	S_VSERIES+ 15, 1,0, X_SERIES+60,3,0,7,-1,1,vchar, 
   S_VSERIES+ 16, 1,1, X_SERIES+ 0,3,0,7,-1,1,vchar, 
	S_VSERIES+ 17, 1,1, X_SERIES+ 4,3,0,7,-1,1,vchar, 
	S_VSERIES+ 18, 1,1, X_SERIES+ 8,3,0,7,-1,1,vchar, 
	S_VSERIES+ 19, 1,1, X_SERIES+12,3,0,7,-1,1,vchar, 
	S_VSERIES+ 20, 1,1, X_SERIES+16,3,0,7,-1,1,vchar, 
	S_VSERIES+ 21, 1,1, X_SERIES+20,3,0,7,-1,1,vchar, 
	S_VSERIES+ 22, 1,1, X_SERIES+24,3,0,7,-1,1,vchar, 
	S_VSERIES+ 23, 1,1, X_SERIES+28,3,0,7,-1,1,vchar, 
	S_VSERIES+ 24, 1,1, X_SERIES+32,3,0,7,-1,1,vchar, 
	S_VSERIES+ 25, 1,1, X_SERIES+36,3,0,7,-1,1,vchar, 
	S_VSERIES+ 26, 1,1, X_SERIES+40,3,0,7,-1,1,vchar, 
	S_VSERIES+ 27, 1,1, X_SERIES+44,3,0,7,-1,1,vchar, 
	S_VSERIES+ 28, 1,1, X_SERIES+48,3,0,7,-1,1,vchar, 
	S_VSERIES+ 29, 1,1, X_SERIES+52,3,0,7,-1,1,vchar, 
	S_VSERIES+ 30, 1,1, X_SERIES+56,3,0,7,-1,1,vchar, 
	S_VSERIES+ 31, 1,1, X_SERIES+60,3,0,7,-1,1,vchar,
/* offset,nbytes,  row,      col,ncols,lo,         hi,dial,ndigits,encode */
	S_VOPTS+S_VSYNC,1,3,X_VSYNC,6,0,3,-1,1,syncchar,
	S_VOPTS+S_VREST,1,3,X_VREST,3,0,1,-1,1,yesnochar,
	S_VOPTS+S_VRAND,1,3,X_VRAND,3,0,2,-1,1,plusminus,
	S_VOPTS+S_VRAMT,1,3,X_VRAMT,2,0,99,-1,2,int2char,
	S_VOPTS+S_VSTEP,1,3,X_VSTEP,5,0,1,-1,1,stepchar,
	S_VOPTS+S_VTIME,1,3,X_VTIME,5,0,31,-1,1,timechar,
	S_VOPTS+S_VATON,1,3,X_VATON,2,0,12,-1,1,chromachar,
	S_VOPTS+S_VADUR,1,3,X_VADUR,5,0,32,-1,1,timechar,
	S_VOPTS+S_VUTON,1,3,X_VUTON,2,0,12,-1,1,chromachar,
	S_VOPTS+S_VUDUR,1,3,X_VUDUR,5,0,32,-1,1,timechar
};
PARAM *params[3]= { pparams, rparams, vparams };

/************************************* EOF ***********************************/
