#include "extern.h"

#define POW_BLK 1024
#define POW_BITS 10
#define MIN_VAL 8
#define MIN_DIV 150

long pow_copy[POW_BLK / 2], smp_test[POW_BLK];

/* ----------------
	 | SGN-function |
	 ---------------- */
int lsgn(long val)
{
if (!val)
	return 0;

if (val > 0)
	return 1;

return -1;
}

/* -------------------------
   | Make a power spectrum |
   ------------------------- */
long get_spectrum(char *p, long n)
{
int j;
long a, s, i, k;

s = n / POW_BLK;
for (i = 0, j = 0; j < POW_BLK; i += s, j++) 
	{
	for (k = 0, a = 0L; k < s; a += p[i + k++]);
	a /= s;
	
	smp_test[j] = (a + 1L) * 3000L;						/* -128..127 */
	}

dfht(smp_test, POW_BITS, 0, 0);							/* DFHT-Analyse */
return power(smp_test, pow_dat);	
}

/* --------------------
   | Naturialize wave |
   -------------------- */
void flatten_spec(long *pow_wrk)
{
int i, chg = 11;
int s1, s2;

while (chg > 10)
	{
	chg = 0;
	for (i = 0; i < POW_BLK / 2 - 2; i++)
		{
		s1 = lsgn(pow_wrk[i + 1] - pow_wrk[i]);
		s2 = lsgn(pow_wrk[i + 2] - pow_wrk[i + 1]);

		if (s1 != s2 && s1 && s2)
			{
			pow_wrk[i + 1] = (pow_wrk[i] + pow_wrk[i + 2]) >> 1;
			chg++;
			}
		}
	}
}

/* ------------------------------
   | Durchschnittlicher Abstand |
   ------------------------------ */
int compare_both(long maxp, long maxp2)
{
long q1, q2;
long dx;
int i, akt, akt1, akt2, wave1, wave2, flg1, flg2;

akt = 0;
akt1 = 0;
akt2 = 0;
wave1 = 0;
wave2 = 0;
flg1 = 1;
flg2 = 1;
maxp++;
maxp2++;
dx = 0L;
for (i = 0; i < POW_BLK / 2; i++)
	{
	q1 = pow_dat[i] + 1L;
	q2 = pow_copy[i] + 1L;

	if (q1 > maxp / MIN_DIV || q2 > maxp2 / MIN_DIV)
		{
		akt++;

		if (q1 > maxp / MIN_DIV)
			{
			akt1++;
			if (!flg1)
				{
				wave1++;
				flg1 = 1;
				}
			}
		else
			flg1 = 0;
			
		if (q2 > maxp2 / MIN_DIV)
			{
			akt2++;
			if (!flg2)
				{
				wave2++;
				flg2 = 1;
				}
			}
		else
			flg2 = 0;
			
		dx += labs(q1 - q2);
		}
	else
		{
		flg1 = 0;
		flg2 = 0;
		}
	}			

i = (int)(dx / 333L / akt / maxp);

if (i < MIN_VAL && wave1 == wave2 && abs(akt1 - akt2) <= 10)
	return i;
else
	return 9999;
}

/* -----------------------
   | Sequenz comparision |
   ----------------------- */
void sequenz_cmp(void)
{
int i, j, flg = 0;
long maxp, maxp2;
int *min_val, cmp_val;
int *min_name;

min_val = (int *)malloc(sizeof(int) * seq_num);
if (!min_val)
	return;
	
min_name = (int *)malloc(sizeof(int) * seq_num);
if (!min_name)
	{
	free(min_val);
	return;
	}
memset(min_name, -1, sizeof(int) * seq_num);

for (i = 0; i < seq_num; i++)
	{
	flg = 0;
		
	for (j = i + 1; j < seq_num; j++)
		if (labs(seq_data[i].len - seq_data[j].len) < 256)
			{
			if (!flg)
				{
				maxp = get_spectrum(seq_data[i].pos + o_bytes, seq_data[i].len);
				flatten_spec(pow_dat);
				memcpy(pow_copy, pow_dat, POW_BLK / 2 * sizeof(long));
				flg = 1;
				}
							
			maxp2 = get_spectrum(seq_data[j].pos + o_bytes, seq_data[j].len);
			flatten_spec(pow_dat);
			cmp_val = compare_both(maxp, maxp2);
			
			if (cmp_val < MIN_VAL && (cmp_val < min_val[j] || min_name[j] == -1))
				{
				min_name[j] = i;
				min_val[j] = cmp_val;
				}
			}
	}

for (i = 0; i < seq_num; i++)
	if (min_name[i] > -1)
		play_list[i] = play_list[min_name[i]];
				
free(min_val);
free(min_name);
}

