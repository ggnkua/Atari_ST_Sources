/*					Calculate FIR-filter coefficients					*/
/*	main routines from 'firdemo' by Frank Kiesow and	*/
/*	shell written by Roel van de Kraats								*/

/* tabsize=2	*/

#include <stdio.h>
#include <stdlib.h> 
#include <tos.h>
#include <math.h>
#include <ext.h>
#include <string.h>
#include <aes.h>
#include "calccoef.h"

#define FALSE 				0
#define TRUE  				1
#define	MAX_COEFF 		1000
#define STFILELEN     13    /* Maximale LÑnge eines Filenamens     */
#define STPATHLEN     64    /* Maximale LÑnge eines Pfades         */
#define EOS           '\0'  /* Ende eines Strings                  */
#define BACKSLASH     '\\'

typedef char DSP_WORD[3];

long		get_value(OBJECT *tree,int obj);
int 		new_filter(void);
int 		fpfix(float src,DSP_WORD dest);
void 		fir_tp(int n,double ta,double wg);
void   	fir_hp(int n,double ta,double wg);
int   	fir_bp(int n,double ta,double low_wg,double up_wg);
int   	fir_bs(int n,double ta,double low_wg,double up_wg);
void 		fir_hamming_win(int ordnung);
void 		fir_hanning_win(int ordnung);
void 		fir_blackman_win(int ordnung);
void 		fir_bartlett_win(int ordnung,double smpl_freq);
void 		fir_lanczos_win(int ordnung);
void 		fir_fejer_win(int ordnung);
void		mouse_on( void );
void		mouse_off( void );
void		event_loop( void );
void		build_fname( char *dest, char *s1, char *s2 );
int			op_fbox( char *string );
void		save_filter(void);

char Path[STPATHLEN];
char Name[STPATHLEN + STFILELEN];

DSP_WORD	coeff[MAX_COEFF]; 	/* Maximal xx Koeffizienten a' 3 Bytes		  	*/
double		a_k[MAX_COEFF];		/* Maximal 100 Filterkoeffizienten						*/
OBJECT		*maintree;

double 	smpl_freq,
				lower_freq,
				upper_freq;
int 		n_coeff;

int main(void)
{
	int x,y,w,h, exit_obj;
	if ( appl_init( ) >=0 )
	{
		graf_mouse(ARROW,0);
		if (rsrc_load("CALCCOEF.RSC")!=0)
		{
			Path[0]=(char)(Dgetdrv()+65);
			strcat(Path,":");
			Dgetpath(Name,0);
			strcat(Path,Name);
			strcat(Path,"\\*.FTR");

			rsrc_gaddr(0,MAINTREE,&maintree);

			form_center(maintree,&x,&y,&w,&h);
			form_dial(FMD_START,0,0,0,0,x,y,w,h);
			objc_draw(maintree,ROOT,MAX_DEPTH,x,y,w,h);
			do
			{
				exit_obj = form_do(maintree,0);
				switch(exit_obj)
				{
					case	LOWPASS  	:	maintree[LOWERFREQ].ob_state |= DISABLED;
														maintree[UPPERFREQ].ob_state &= ~DISABLED;
														maintree[LOWERFREQ].ob_flags &= ~EDITABLE;
														maintree[UPPERFREQ].ob_flags |= EDITABLE;
														objc_draw(maintree,LOWERFREQ,MAX_DEPTH,x,y,w,h);
														objc_draw(maintree,UPPERFREQ,MAX_DEPTH,x,y,w,h);
														break;
					case	HIGHPASS 	:	maintree[LOWERFREQ].ob_state &= ~DISABLED;
														maintree[UPPERFREQ].ob_state |= DISABLED;
														maintree[LOWERFREQ].ob_flags |= EDITABLE;
														maintree[UPPERFREQ].ob_flags &= ~EDITABLE;
														objc_draw(maintree,LOWERFREQ,MAX_DEPTH,x,y,w,h);
														objc_draw(maintree,UPPERFREQ,MAX_DEPTH,x,y,w,h);
														break;
					case	BANDPASS 	:	
					case 	BANDSTOP 	:	maintree[LOWERFREQ].ob_state &= ~DISABLED;
														maintree[UPPERFREQ].ob_state &= ~DISABLED;
														maintree[LOWERFREQ].ob_flags |= EDITABLE;
														maintree[UPPERFREQ].ob_flags |= EDITABLE;
														objc_draw(maintree,LOWERFREQ,MAX_DEPTH,x,y,w,h);
														objc_draw(maintree,UPPERFREQ,MAX_DEPTH,x,y,w,h);
														break;
				}											
			}
			while((exit_obj != CALCBUT) && (exit_obj != CANCELBUT));
			if (exit_obj==CALCBUT)
			{
				new_filter();
				if (op_fbox("Save Filter Data")==1)
					save_filter();
			}
			form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);

			rsrc_free( );
		}
		else
			form_alert(1,"[3][RSC-File not found][Exit]");
		appl_exit( );
	}
	return(0);
}

long get_value(OBJECT *tree,int obj)
{
	char s[10];
	int i;
	strcpy(s,tree[obj].ob_spec.tedinfo->te_ptext);
	for (i=0;i<9;i++)
	{
		if (s[i]=='_')
			s[i]=' ';
	}
	return atol(s);
}
int fpfix(float src,DSP_WORD dest)
{
	float x;
	unsigned long *y1;					/* Alias fÅr (float) x											*/
	unsigned long	y0;
	char *ptr;									/* Alias fÅr (unsigned long) y0							*/
	y1 = (unsigned long *)&x;
	ptr = (char *)&y0;
	if(fabs(src) >= 2.0e-7)
	{ 
		x = src;
		y0 = *y1<<8;							/* Mantisse (fast)ganz nach links schieben	*/
	
		*y1 >>= 23;								/* Exponent in LSB													*/
		*y1 &= 0xffL;							/* Vorzeichen rausschmeissen								*/
		*y1 = 0x7fL - *y1;				/* Anzahl der Rechtsshifts berechnen				*/
	
		y0 |= 0x80000000uL;				/* FÅhrende '1' einfÅgen										*/
		y0 >>= *y1;					  		/* Denormalisieren...												*/
		if(src < 0.0)							/* (Float) x < 0.0 ?												*/
		  y0 = ~y0;								/* Dann 1'er Komplement bilden							*/
		y0 >>= 7;									/* ... 24 Bit Wert erzeugen									*/
		if(y0 & 0x01L)						/* Letzte rausgeschobene Stelle  = 1?				*/
			y0++;										/* ...dann aufrunden												*/	
		y0 >>= 1;	
	}	
	else
	  y0 = 0L;
	dest[0] = ptr[1];
	dest[1] = ptr[2];
	dest[2] = ptr[3];
	return 1; 
}


void fir_tp(int n, double ta, double wg)  /* FIR Tiefpass berechnen       */
{
  int k;
  double omega;
  double si;
  double si_k;
  double *coeff_ptr = a_k;
  omega = 2.0 * (wg/ta);
  si = M_PI * omega;
  *coeff_ptr++ = omega;       /* omega * Si(0) = omega * 1.0      				*/
  for(k=1;k<n;k++)
  {
  	si_k = (double)k * si;
    *coeff_ptr++ = omega * sin(si_k)/(si_k);
  } 
}

void fir_hp(int n, double ta, double wg) /* FIR Hochpass berechnen        */
{
  int k;
  fir_tp(n,ta,wg);                       /* Zuerst den entsprechenden     */
  a_k[0] = 1.0 - a_k[0]; 								 /* Tiefpass berechnen ... dann   */
  for (k=1;k<n;k++)                      /*  von Allpass(= 1)subtrahieren */
    a_k[k] = -a_k[k];
}

int fir_bp(int n, double ta, double low_wg,double up_wg)
{                               /* FIR Bandpass berechnen                 */
  int k;                        /* Ergibt sich als Differenz zweier       */
  double *h_vec;                /* Tiefpasse                              */  
  h_vec = (double *)Malloc((n+1) * sizeof(double));/* Hilfsvector erzeugen*/
  if(h_vec == 0L)
  {
  	form_alert(1,"[3][Out of Memory][Exit]");
    return FALSE;
  }  
  fir_tp(n,ta,low_wg);          /* Zuerst untere Grenzfrequenz berechnen  */
  for (k=0;k<n;k++)
    h_vec[k] = a_k[k];					/* ... und sichern                        */
  fir_tp(n,ta,up_wg);           /* Obere Grenzfrequenz berechnen          */
  for (k=0;k<n;k++)
    a_k[k] -= h_vec[k];						/* Differenz bilden                     */
  Mfree(h_vec);
  return TRUE;
}

int fir_bs(int n, double ta, double low_wg,double up_wg)
{                               /* FIR Bandsperre berechnen               */
  int k;                        /* Ergibt sich aus der Differenz eines    */
  if(!fir_bp(n,ta,low_wg,up_wg))/* Allpass(=1) und eines Bandpass         */
    return FALSE;
  a_k[0] =  1.0 - a_k[0];
  for (k=1;k<n;k++)
    a_k[k] = -a_k[k];
  return TRUE;  
}


void fir_hamming_win(int ordnung)   /* Fensterfunktion                    */
{
  int n;
  for (n=0;n<ordnung;n++)
    a_k[n] *= (0.54+0.46*cos(M_PI*n/ordnung));
}


void fir_hanning_win(int ordnung)   /* Fensterfunktion                    */
{
  int n;
  for (n=0;n<ordnung;n++)
    a_k[n] *= (0.5+0.5*cos(M_PI*n/ordnung));
}


void fir_blackman_win(int ordnung)  /* Fensterfunktion                    */
{
  int n;
  for (n=0;n<ordnung;n++)
    a_k[n] *= (0.42+0.5*cos(M_PI*n/ordnung)+
                         0.08*cos(2*M_PI*n/ordnung));
}


void fir_bartlett_win(int ordnung,double smpl_freq)
{                                   /* Fensterfunktion                    */
  int n;
  double nenner;
  nenner = ordnung * smpl_freq;
  for (n=0;n<ordnung;n++)
    a_k[n] *= (1-fabs(n*smpl_freq)/nenner);
}


void fir_lanczos_win(int ordnung)   /* Fensterfunktion                    */
{
  int n;
  for (n=1;n<ordnung;n++)
    a_k[n] *= (sin(M_PI*n/ordnung)/(M_PI*n/ordnung));
}


void fir_fejer_win(int ordnung)     /* Fensterfunktion                    */
{
  int n;
  for (n=0;n<ordnung;n++)
    a_k[n] *= (1-fabs(n/ordnung));
}

int new_filter(void)
{
	double sum_coeff; 
	int i;
	n_coeff = (int)get_value(maintree,ORDER);
	lower_freq = get_value(maintree,LOWERFREQ);
	upper_freq = get_value(maintree,UPPERFREQ);
	smpl_freq = get_value(maintree,SAMPLEFREQ);
	sum_coeff = 0.0;
	if(maintree[LOWPASS].ob_state == SELECTED)
		fir_tp(n_coeff,smpl_freq,upper_freq);
	else	
		if(maintree[HIGHPASS].ob_state == SELECTED)
			fir_hp(n_coeff,smpl_freq,lower_freq);
		else
		  if(maintree[BANDPASS].ob_state == SELECTED)
		  {
				if(!fir_bp(n_coeff,smpl_freq,lower_freq,upper_freq))
					return FALSE;
			}	
			else
			  if(maintree[BANDSTOP].ob_state == SELECTED)
					if(!fir_bs(n_coeff,smpl_freq,lower_freq,upper_freq))
					  return FALSE;
	
	if(maintree[BARTLETT].ob_state == SELECTED)
		fir_bartlett_win(n_coeff,smpl_freq);
	else	
		if(maintree[BLACKMAN].ob_state == SELECTED)
			fir_blackman_win(n_coeff);	
		else	
			if(maintree[FEJER].ob_state == SELECTED)
				fir_fejer_win(n_coeff);	
			else	
				if(maintree[HAMM].ob_state == SELECTED)
					fir_hamming_win(n_coeff);
				else
					if(maintree[HANN].ob_state == SELECTED)
						fir_hanning_win(n_coeff);
					else
						if(maintree[LANCZOS].ob_state == SELECTED)
							fir_lanczos_win(n_coeff);
						else	
							if(maintree[RECT].ob_state == SELECTED)		/* Default		*/
								;
	for(i=0;i<n_coeff;i++)				/* Betrag der Filterkoefizienten = 1			*/
	  sum_coeff += fabs(a_k[i]);
	sum_coeff = 1.0/sum_coeff;  
	for(i=0;i<n_coeff;i++)				/* Koeffizienten von Double- in						*/
	{															/* 24 Bit Festpunktformat wandeln					*/	
		a_k[i] *= sum_coeff;
		fpfix((float)a_k[i],coeff[i]);
	}
/*
	for(i=0;i<10/*n_coeff*/;i++)
		printf("%i: Floating Point: %f    DSP Word: $%02x%02x%02x\n",i,a_k[i],(int)coeff[i][0] & 0xff,(int)coeff[i][1] & 0xff,(int)coeff[i][2] & 0xff);
*/
	return TRUE;
}			
int op_fbox( char *string )
{
   char n[STFILELEN];                  /* Buffer fÅr Dateinamen         */
   int  b;                             /* EnthÑlt Code des Buttons der  */
                                       /* zum Abbruch der Dateiauswahl  */
                                       /* fÅhrte.                       */

   int version;

   *n = EOS;                           /* Dateinamen lîschen.           */

   version = Sversion ( );             /* Berechne die GEMDOS-Version,  */
   version >>= 8;                      /* da fsel_exinput erst ab  */
                                       /* Version 1.40 zur VerfÅgung    */
                                       /* steht.                        */

   if ( version <= 20 )
                                       /* Dateiauswahl.                 */
      fsel_input( Path, n, &b );
   else
      fsel_exinput( Path, n, &b, string );

   build_fname( Name, Path, n );

   return ( b );
}

/* -------------------------------------------------------------------- */
/*                                                  build a file name   */
/*       void build_fname( char *dest, char *s1, char *s2 );            */
/*                                                                      */
/*       Konkatoniere Pfadnamen und Dateinamen.                         */
/*                                                                      */
/*       -> dest                 Zielstring.                            */
/*          s1                   Pfadname.                              */
/*          s2                   Dateiname.                             */
/*                                                                      */
/*       <-                      Ergebnis befindet sich in 'dest'.      */
/* -------------------------------------------------------------------- */

void build_fname( char *dest, char *s1, char *s2 )
{
	char *cptr;

	strcpy( dest, s1 );                 /* Pfad kopieren.                */
	cptr = strrchr( dest, (int) BACKSLASH);
	if (strrchr( s2, (int) '.')==0)
		strcat(s2,".FTR");
	strcpy( ++cptr, s2);                /* Schlieûlich den Dateinamen    */
}                                      /* dranhÑngen.                   */
void save_filter(void)
{
	char s[256];
	int handle,i,j;

	handle=(int)Fcreate(Name,0);
	if (handle<0)
	{
		form_alert(1,"[3][Cannot open File][Cancel]");
		return;
	}
	if(maintree[LOWPASS].ob_state == SELECTED)
		sprintf(s,";Lowpass Filter, upper frequency: %.0f Hz.\r\n",upper_freq);
	else	
		if(maintree[HIGHPASS].ob_state == SELECTED)
			sprintf(s,";Highpass Filter, lower frequency: %.0f Hz.\r\n",lower_freq);
		else
		  if(maintree[BANDPASS].ob_state == SELECTED)
				sprintf(s,";Bandpass Filter, lower frequency: %.0f Hz. upper frequency: %.0f Hz.\r\n",lower_freq,upper_freq);
			else
			  if(maintree[BANDSTOP].ob_state == SELECTED)
					sprintf(s,";Bandstop Filter, upper frequency: %.0f Hz. lower frequency: %.0f Hz.\r\n",upper_freq,lower_freq);
	Fwrite(handle,strlen(s),s);
	sprintf(s,";Sample frequency: %.0f Hz.\r\n;%d coefficients\r\n",smpl_freq,n_coeff);
	Fwrite(handle,strlen(s),s);
	if(maintree[BARTLETT].ob_state == SELECTED)
		sprintf(s,";Using Bartlett Windowing\r\n");
	else	
		if(maintree[BLACKMAN].ob_state == SELECTED)
			sprintf(s,";Using Blackman Windowing\r\n");
		else	
			if(maintree[FEJER].ob_state == SELECTED)
				sprintf(s,";Using Fejer Windowing\r\n");
			else	
				if(maintree[HAMM].ob_state == SELECTED)
					sprintf(s,";Using Hamming Windowing\r\n");
				else
					if(maintree[HANN].ob_state == SELECTED)
						sprintf(s,";Using Hanning Windowing\r\n");
					else
						if(maintree[LANCZOS].ob_state == SELECTED)
							sprintf(s,";Using Lanczos Windowing\r\n");
						else	
							if(maintree[RECT].ob_state == SELECTED)		/* Default		*/
								sprintf(s,";No Windowing\r\n");
	Fwrite(handle,strlen(s),s);
	if (strrchr( Name, (int) BACKSLASH)!=0)
		strcpy(s,strrchr( Name, (int) BACKSLASH)+1);
	else
		strcpy(s,Name);
	if (strrchr( s, (int) '.')!=0)
		strcpy(strrchr( s, (int) '.'),"\r\n");
	else
		strcat(s,"\r\n");
	Fwrite(handle,strlen(s),s);
	i=0;
	while (i+10<=n_coeff)
	{
		sprintf(s,"        dc ");
		Fwrite(handle,strlen(s),s);
		for (j=0;j<9;j++)
		{
			sprintf(s,"$%02x%02x%02x,",(int)coeff[i][0] & 0xff,(int)coeff[i][1] & 0xff,(int)coeff[i][2] & 0xff);
			Fwrite(handle,strlen(s),s);
			i++;
		}
		sprintf(s,"$%02x%02x%02x\r\n",(int)coeff[i][0] & 0xff,(int)coeff[i][1] & 0xff,(int)coeff[i][2] & 0xff);
		Fwrite(handle,strlen(s),s);
		i++;
	}
	if (i<n_coeff)
	{
		sprintf(s,"        dc ");
		Fwrite(handle,strlen(s),s);
		if (i<n_coeff-1)
		{
			for (j=0;j<n_coeff-i-1;j++)
			{
				sprintf(s,"$%02x%02x%02x,",(int)coeff[i+j][0] & 0xff,(int)coeff[i+j][1] & 0xff,(int)coeff[i+j][2] & 0xff);
				Fwrite(handle,strlen(s),s);
			}
		}
		sprintf(s,"$%02x%02x%02x\r\n",(int)coeff[n_coeff-1][0] & 0xff,(int)coeff[n_coeff-1][1] & 0xff,(int)coeff[n_coeff-1][2] & 0xff);
		Fwrite(handle,strlen(s),s);
	}
	Fclose(handle);
}
