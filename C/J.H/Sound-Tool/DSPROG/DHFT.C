#include "extern.h"

																				/* Anzahl der Stufen der Transformation */
static int stages	= 0;									/* DFHT: Momentane Tiefe */

																				/* Modulglobale Variablen, die das Leben vereinfachen */
static int n;														/* Anzahl Elemente */
static int n_d2;

static int m2[14] = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024,
										 2048, 4096, 8192};
static int sin_d4[2049];								/* Viertels-Sinus +1 Tabelle */
/*static long work_buf[MAX_BLK];	*/				/* Arbeitsbuffer */

static int dhft_stub, 
					 dhft_stub_d2, 
					 dhft_stub_d2m1; 							/* Stufenbreite etc. */
static int dhft_n_cnt; 
static int dhft_tri_s;									/* Trigonom Schrittweite */
static int dhft_tri_p;									/* Trig. Pos. */

long dhft_add(int sin, int cos, long c, long b, long a);
long dhft_pow(long a, int div);

/* ----------------------
   | L„dt Sinus-Tabelle |
   ---------------------- */
void load_sinus(void)
{
long fd;

if ((fd = Fopen("DSPROG.TAB", 0)) < 0)
	{
	error("DSPROG.TAB fehlt!", "\0", 0xA);
	exit(-1);
	}
	
if (Fread((int)fd, 4098L, sin_d4) < 4098L)
	{
	error("DSPROG.TAB defekt", "\0", 0xA);
	exit(-1);
	}
	
Fclose((int)fd);
}

/***********************************************************
* init_dfht(): Initialisierung durchfuehren
***********************************************************/
void init_dfht(int new_stages)
{
stages = new_stages;									/* merken */
n = m2[stages];												/* Soviele Elemente ueberhaupt */
n_d2 = n >> 1;												/* Elem. /2 */
}

/**************************************************************
* sinus(), cosinus(): Berechnung Trigonometrie
**************************************************************/
int sinus(int step)
{
int tmp;
																							/* Quadrant bestimmen */
if (step & 2048)
	tmp= sin_d4[2048 - (step & 2047)];  			/* Q 0,2 */
else
	tmp= sin_d4[step & 2047];								/* Q 1,3 */

if (step & 4096)
	return -tmp;
else
	return tmp;
}

/*****************************************************************
* bit_reverse(): Zahlenfeld permutieren, 'perfect shuffle'
* (Anm: Die Permutation geht erst in Assembler so richtig schnell,
* besonders dann, wenn man sich die Tausch-Indizes merkt!)
*****************************************************************/
void bit_reverse(long *pfeld)
{																/* pfeld zeigt auf die Daten */
int n_cnt;											/* Counter */
int ind_s;											/* Sourceindex */
int ind_r;									 	 /* Reversierter Index */
int bits;												/* Soviele Bits zum Revers. */
long swap_tmp;									/* Zum Austauschen */

for (n_cnt = 0; n_cnt < n; n_cnt++)
	{															/* Alle Elemente durchzaehlen */
	ind_s = n_cnt;
	ind_r = 0;
	for(bits = stages; bits; bits--)
		{ 																		/* Soviele Bits sinds... */
		ind_r <<= 1;													/* Platz machen im Ziel */
		ind_r |= ind_s & 1;										/* Bit transferieren */
		ind_s >>= 1;													/* Naechstes Bit */
		}

	if (ind_r > n_cnt)
		{																			/* Nur Tauschen, wenn Ziel- */
		swap_tmp = pfeld[ind_r];							/* index > als Quelle! */
		pfeld[ind_r] = pfeld[n_cnt];
		pfeld[n_cnt] = swap_tmp;
		}
	}
}

/***********************************************************************
* stage_1(), stage_2(), stage_x(): Die Transformations-Stufen
***********************************************************************/
void stage_1(long *sfeld, long *dfeld)			/* Stufe 1		  */
{																							/* Von Quelle...	 zum Ziel!			*/
int n_cnt;
long f0, f1;

/* Wichtig: Stufe 1: Wahlweise INPLACE oder TRANSPORT wegen Buffer */
for (n_cnt = 0; n_cnt < n; n_cnt += 2)
	{
	f0 = sfeld[n_cnt];					/* Stufe 1: Nur Addieren! */
	f1 = sfeld[n_cnt + 1];
	dfeld[n_cnt] = f0 + f1;
	dfeld[n_cnt + 1] = f0 - f1;
	}
}

void stage_2(long *sfeld, long *dfeld)			/* Stufe 2		  */
{																							/* Von Quelle ...  zum Ziel!			*/
int n_cnt;
long f0, f1;

for(n_cnt = 0; n_cnt < n; n_cnt += 4)
	{
	f0 = sfeld[n_cnt];										/* Stufe 2: Nur Addieren! */
	f1 = sfeld[n_cnt + 2];
	dfeld[n_cnt] = f0 + f1;
	dfeld[n_cnt + 2] = f0 - f1;

	f0 = sfeld[n_cnt + 1];
	f1 = sfeld[n_cnt + 3];
	dfeld[n_cnt + 1] = f0 + f1;
	dfeld[n_cnt + 3] = f0 - f1;
	}
}

/* -------------------------
   | Stage 3 - x berechnen |
   ------------------------- */
int stage_x(long *sfeld, long *dfeld, int ist_x, int flg)
{																							/* Welche Stufe?  */
int n_cnt2;																		/* Zaehlt... Blocks */
int i_cnt, i_cnt2;											 			/* Matrizenelement */
long cl_m;

if (!flg)
	{
	dhft_tri_p = 0;
	dhft_stub = m2[ist_x];												/* Stufenbreite */
	dhft_stub_d2 = dhft_stub >> 1;								/* Halbe Stufenbreite */
	dhft_stub_d2m1 = dhft_stub_d2 - 1;						/* Zum 'Unden' */
	dhft_tri_s = 8192 / dhft_stub;								/* Pro Block ein Durchl. */
	dhft_n_cnt = 0;
	}

cl_m = clock() + CLK_TCK/3;
while (dhft_n_cnt < n && clock() - cl_m < 0L)
		{
		n_cnt2 = dhft_n_cnt + dhft_stub_d2;

		for (i_cnt = 0; i_cnt < dhft_stub; i_cnt++, dhft_tri_p += dhft_tri_s)
			{
			i_cnt2 = i_cnt & dhft_stub_d2m1;
               
			dfeld[dhft_n_cnt + i_cnt] = 
														 dhft_add(sinus(dhft_tri_p), sinus(dhft_tri_p + 2048),
																			sfeld[dhft_n_cnt + i_cnt2],
																			sfeld[n_cnt2 + i_cnt2],
																			sfeld[n_cnt2 + (-i_cnt & dhft_stub_d2m1)]);
			}
		dhft_n_cnt += dhft_stub;
		}

if (dhft_n_cnt >= n)
	return 0;
return 1;
}

/***********************************************************************
*
* power(): Powerspektrum berechnen
* 				 CLCTYP sfeld[]: Die Koeffizienten der Hartley-Transf.
* 				 CLCTYP dfeld[]: Hierdrin das Spektrum (!!! Halbe Groesse !!!)
* 				 Return: Wert des groessten Elements.
*
************************************************************************/

long power(long *sfeld, long *dfeld)
{
long maxp = 0L;
long p;
int i;

maxp = dfeld[0] = dhft_pow(sfeld[0], 1500);	/* Sonderfall bei Ausschnitt */
for(i = 1; i < n_d2 ; i++)
	{
	p = dhft_pow(sfeld[i], 3000) + dhft_pow(sfeld[n - i], 3000);
	dfeld[i] = p;
	
	if (p > maxp)
	  maxp = p;
	}

return maxp;
}
