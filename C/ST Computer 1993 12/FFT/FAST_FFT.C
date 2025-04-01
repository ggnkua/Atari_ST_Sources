/* Die Scannerdaten werden bereits von der Einleseroutine auf einen 
   Wertebereich von -32 bis +31 skaliert und direkt in das Arbeitsarray
   a[] geschrieben (ohne Fixkommaerweiterung (!) sonst wÅrden die Werte
   zu groû; wir rechnen also eigentlich mit Kommazahlen!);
   
   Alle Rechnungen erfolgen mit Fixkomma-Arithmetik; ersichtlich wird das
   eigentlich nur bei der Multiplikation (Macro MUL);
   
   Die pytagorÑische Addition wird durch eine einfache Addition der
   BetrÑge von Real- und ImaginÑrteil gebildet.
   
   FÅr N==256 und FIX==4 sind die komplexen Wurzeln bereits vorberechnet
   und werden durch bedingte Compilierung eingebunden. Bei anderen Werten
   sollte das entsprechende Datenfeld im Assemblerteil gelîscht werden.
*/


#include <aes.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <vdi.h>

#define FALSE		(0)
#define TRUE		(!FALSE)
#define	ADDR(a)		(int)((long)(a) >> 16), (int)((long)(a) & 0xffff)
#define SETPXY(p, a, b, c, d, e, f, g, h)\
					p[0] = (a), p[1] = (b), p[2] = (c), p[3] = (d),\
					p[4] = (e), p[5] = (f), p[6] = (g), p[7] = (h)



#define FIX		4
#define EXP		8
#define N		(1 << EXP)

#define SUBW	N
#define SUBH	260


typedef struct	{	int		r;
					int		i;
				}	complex;


void	wfft(unsigned);
void	fft(complex [], unsigned, unsigned);	
void	line(void *, unsigned, unsigned);
void	set_line(unsigned);
void	cntrcs(void *, unsigned);
int		open_vwork(void);
void	close_vwork(void);
void	process(void);


int work_in[12], work_out[57], handle,
    phys_handle, gl_hchar, gl_wchar, gl_hbox,
    gl_wbox, gl_apid;


static MFDB screen =	{NULL, 0, 0, 0, 1, 0, 0, 0, 0},
			sub =		{NULL, SUBW, SUBH, SUBW >> 4, 1, 1, 0, 0, 0};

const char title[] = "Frequenzspektrum";



#if	((N==256) && (FIX==4))
	extern complex w[];				/*	fertige Werte importieren	*/
#else
	complex w[N];					/*	Array fÅr Berechnung 		*/
#endif



complex a[N], t[N];



void process(void)
{	void *base;
	int i, linx, wx, wy, ww, wh, copy[8], delete[8], window, x, y;
	
	if ((sub.fd_addr = malloc((SUBW >> 3) * SUBH)) == NULL)
	{	form_alert(1, "[1][Out of memory!][  Abort  ]");
		return;
	}
		
	set_line(-(SUBW >> 3));
	base = (void *)((long)sub.fd_addr + (SUBW >> 3) * (SUBH - 3));
	
	x = (work_out[0] - SUBW) / 2;
	y = (work_out[1] - SUBH) / 2;
	SETPXY(delete, 0, 0, SUBW - 1, SUBH - 1, 0, 0, SUBW - 1, SUBH - 1);
	SETPXY(copy, 0, 0, SUBW - 1, SUBH - 1, x, y, x + SUBW - 1, y + SUBH - 1);

	if ((window = wind_create(NAME, 0, 0, work_out[0], work_out[1])) >= 0)
	{	graf_mouse(M_OFF, NULL);
		wind_set(window, WF_NAME, ADDR(title));
		wind_calc(WC_BORDER, NAME, x, y, SUBW, SUBH, &wx, &wy, &ww, &wh);
		wind_open(window, wx, wy, ww, wh);



#if	((N==256) && (FIX==4))	/*	FÅr diesen Fall	nichts tun			*/
#else	
	wfft(N);				/*	hier muû noch gerechnet werden		*/
#endif

		
		while ((char)Crawio(0xff) != 'q')
		{	vro_cpyfm(handle, ALL_WHITE, delete, &sub, &sub);
			cntrcs(a, N - 1);
			fft(a, N, 0);
			for (linx = 1, i = 0; i < SUBW / 2; i++, linx += 2)
			{	unsigned height = (unsigned)((abs(a[i].r) >> (FIX - 1)) + (abs(a[i].i) >> (FIX - 1)));
				line(base, linx, height & 255);
			}
			vro_cpyfm(handle, S_OR_NOTD, copy, &sub, &screen);
		}
		wind_close(window);
		wind_delete(window);
		graf_mouse(M_ON, NULL);
	}
	free(sub.fd_addr);
}






#define ASS(v, x)		(*(long *)&(v).r = *(long *)&(x).r)
#define CMX(v, rp, ip)	((v).r = (rp)), ((v).i = (ip))
#define ADD(v, x, y)	((v).r = (x).r + (y).r), ((v).i = (x).i + (y).i)
#define SUB(v, x, y)	((v).r = (x).r - (y).r), ((v).i = (x).i - (y).i)
#define MUL(v, x, y)	((v).r = (((x).r * (y).r) >> FIX) - (((x).i * (y).i) >> FIX)),\
						((v).i = (((x).r * (y).i) >> FIX) + (((x).i * (y).r) >> FIX))



void wfft(unsigned n)
{	double d;
	int j;
	
	for (j = 0; j < n; j++)
	{	d = (2 * M_PI * j) / n;
		CMX(w[j], (int)(cos(d) * (1 << FIX)), (int)(sin(d) * (1 << FIX)));
	}
}




void fft(complex p[], unsigned n, unsigned k)
{	unsigned i, j, ndiv2 = n >> 1;
	complex a, b;

	if (n == 2)
	{	ASS(b, p[k]);
		ASS(a, p[k + 1]);
		ADD(p[k], b, a);
		SUB(p[k + 1], b, a);
	}
	else
	{	for (i = 0; i < ndiv2; i++)
		{	j = k + i * 2;
			ASS(t[i], p[j]);
			ASS(t[i + ndiv2], p[j + 1]);
		}
		
		for (i = 0; i < n; i++)
			ASS(p[k + i], t[i]);
			
		fft(p, ndiv2, k);
		fft(p, ndiv2, k + ndiv2);
		
		j = N / n;
		for (i = 0; i < ndiv2; i++)
		{	MUL(b, w[i * j], p[k + ndiv2 + i]);
			ADD(t[i], p[k + i], b);
			SUB(t[i + ndiv2], p[k + i], b);
		}
		
		for (i = 0; i < n; i++)
			ASS(p[k + i], t[i]);
	}
}








int open_vwork(void)
{  int i;
   if ((gl_apid = appl_init()) != -1)
   {  for (i = 1; i < 10; work_in[i++] = 1);
      work_in[10] = 2;
      phys_handle = graf_handle(&gl_wchar,
               &gl_hchar, &gl_wbox, &gl_hbox);
      work_in[0] = handle = phys_handle;
      v_opnvwk(work_in, &handle, work_out);
      return TRUE;
   }
   else
      return FALSE;
}





void close_vwork(void)
{  v_clsvwk(handle);
   appl_exit();
}





int main(void)
{  if (open_vwork() == FALSE)
        return -1;

   process();
   close_vwork();
   return 0;
}


