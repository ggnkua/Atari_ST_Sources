#include "extern.h"

/* Anzahl der Stufen der Transformation */
static int stages	= 0;			/* DFHT: Momentane Tiefe */

/* Modulglobale Variablen, die das Leben vereinfachen */
static int n;						/* Anzahl Elemente */
static int n_d2;

static int m2[14] = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024,
										 2048, 4096, 8192};
static int sin_d4[2049];								/* Viertels-Sinus +1 Tabelle */

static long work_buf[MAX_BLK];					/* Arbeitsbuffer */

long dhft_add(int sin, int cos, long c, long b, long a);
long dhft_pow(long a, int div);

/* ----------------------
   | L„dt Sinus-Tabelle |
   ---------------------- */
void load_sinus(void)
{
long fd;

if ((fd = Fopen("SND_TOOL.TAB", 0)) < 0)
	{
	error("SND_TOOL.TAB fehlt!", "\0", 0xA);
	exit(-1);
	}
	
if (Fread((int)fd, 4098L, sin_d4) < 4098L)
	{
	error("SND_TOOL.TAB defekt", "\0", 0xA);
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

/* Cosinus(x) = Sinus(x+pi/2) */
int cosinus(int step)
{
return sinus(step + 2048);
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

void stage_x(long *sfeld, long *dfeld, int ist_x)		/* Stufe 3,4,5... */
{																								/* Welche Stufe?  */
int stub, stub_d2, stub_d2m1; 									/* Stufenbreite etc. */
int n_cnt, n_cnt2;															/* Zaehlt... Blocks */
int i_cnt, i_cnt2;															/* Matrizenelement */

int tri_s;																			/* Trigonom Schrittweite */
int tri_p=0;																		/* Trig. Pos. */

stub = m2[ist_x];																/* Stufenbreite */
stub_d2 = stub >> 1;														/* Halbe Stufenbreite */
stub_d2m1 = stub_d2 - 1;												/* Zum 'Unden' */
tri_s = 8192 / stub;														/* Pro Block ein Durchl. */

/* Dieses Monster berechnet einen ganzen Block der Stufen-Matrix */

for (n_cnt = 0; n_cnt < n; n_cnt += stub)
	{
	n_cnt2 = n_cnt + stub_d2;

	for (i_cnt = 0; i_cnt < stub; i_cnt++, tri_p += tri_s)
		{
		i_cnt2 = i_cnt & stub_d2m1;

		dfeld[n_cnt + i_cnt] = dhft_add(sinus(tri_p), sinus(tri_p + 2048),
																		sfeld[n_cnt + i_cnt2],
																		sfeld[n_cnt2 + i_cnt2],
																		sfeld[n_cnt2 + (-i_cnt & stub_d2m1)]);

/*		dfeld[n_cnt + i_cnt] = sfeld[n_cnt + i_cnt2]
			 									 + sfeld[n_cnt2 + i_cnt2] / 30000
			 									 * c
			 									 + (sfeld[n_cnt2 + i_cnt2] % 30000)
			 									 * c / 30000
												 + sfeld[n_cnt2 + (-i_cnt & stub_d2m1)] / 30000
			 									 * s
												 + (sfeld[n_cnt2 + (-i_cnt & stub_d2m1)] % 30000)
			 									 * s / 30000;*/
		}
	}
}

/***********************************************************************
*
* void dfht(pdaten, stellen, richtung): Die DFHT
* 				Die DFHT wird INPLACE durchgefuehrt. Allerdings wird
* 				trotzdem ein Arbeitsspeicher vom Betriebssystem angefordert,
* 				ein 'echtes' INPLACE-Programm waere etwas laenger geworden.
*
* 				CLCTYP pdaten[]: Zeigt auf die zu transformierenden Daten
* 				int stellen: Logarithmus Dualis der Anzahl der Daten
*		  int richtung: 0: Hin- <>0: Rueck-transformation
* 				Kein Rueckgabewert, Fehler werden abgefangen!
*
***********************************************************************/
void dfht(long *pdaten, int stellen, int richtung, int disp)
															/* pdaten ->	Zeigt auf das Datenfeld */
															/* stellen -> Potenz von 2, (= Feldgr”sse) */
{															/* richtung -> 0: Hin- <>0: Rueck-transformat. */
long *z0, *z1, *zt;					/* Wechseln: Buffer, Daten */
int i;
int j;

init_dfht(stellen);
if (disp)
	set_stage();

bit_reverse(pdaten);											/* Daten permutieren */
if (disp)
	set_stage();

if (stellen & 1)
	{																				/* Ende: Daten in pdaten[] */
	stage_1(pdaten, pdaten);								/* Ungerade: stage_1: Inplace */
	if (disp)
		set_stage();
	z0=work_buf;
	z1=pdaten;
	}
else
	{
	stage_1(pdaten, work_buf);							/* Gerade: stage_1: Transport */
	if (disp)
		set_stage();
	z1=work_buf;
	z0=pdaten;
	}

stage_2(z1, z0);													/* Sonst: Abwechseln! */
if (disp)
	set_stage();

for (i = 3; i <= stellen; i++)
	{
	stage_x(z0, z1, i);
	if (disp)
		set_stage();

	zt = z0;
	z0 = z1;
	z1 = zt;
	}

if (!richtung)
	for(j = 0; j < n; pdaten[j++] >>= stellen);

if (disp)	
	set_stage();
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
long maxp;
long p;
int i;

/*maxp = dfeld[0] = sfeld[0] * sfeld[0] / 1500L;*/	/* Sonderfall bei Ausschnitt */
/*for(i = 1; i < n_d2 ; i++)
	{
	p = (sfeld[i] * sfeld[i] / 3000L) + (sfeld[n - i] * sfeld[n - i] / 3000L);
	dfeld[i] = p;
	
	if (p > maxp)
	  maxp = p;
	}*/

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
