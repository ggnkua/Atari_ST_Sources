/************************************************************************/
/*	_ecvt(), _fcvt(), _gcvt() fuer printf.				*/
/*	Unabhaengig von der Implementierung der Flieskommazahlen.	*/
/*	gcvt() hinzugefuegt.						*/
/*	Volker Seebode 14.5.90						*/
/*	Letzte Aenderung: 23.9.91					*/
/************************************************************************/
#ifndef	NO_FLOAT

#include <stddef.h>

#define MAXEC	20
#define	MAXEXP	14

#if ((defined(__STDC__)) && (!defined(__NO_PROTO__)))
char *gcvt(double value, int digits, char *buff);
char *_ecvt(char *p, double x, int prec);
char *_fcvt(char *p, double x, int prec);
char *_gcvt(char *p, double x, int prec);
int  logten(double *num);
#else
char *gcvt(), *_ecvt(), *_fcvt(), *_gcvt();
#endif /* __STDC__ */

#ifdef dLibs
void fp_print(x, fmtc, prec, ptmp)
double x;
int fmtc, prec;
char *ptmp;
{
  switch (fmtc & 0xff) {
  case 'E':
  case 'e':
  	_ecvt(ptmp, x, prec);
  	break;
  case 'F':
  case 'f':
  	_fcvt(ptmp, x, prec);
  	break;
  case 'G':
  case 'g':
  	_gcvt(ptmp, x, prec);
  	break;
  default:
  	write(2,"Fehler: default in fp_print()\n", 30);
  }
}
#endif /* dLibs */

char *gcvt(value,digits,buff)
double value;
int digits;
char *buff;
{
  return (_gcvt(buff,value,digits));
}

char *_ecvt( p, x, prec)
char *p;
double x;
int prec;
{
  register int i, fint, exp;
  register char *tp = p;
  char temp[32];

  if (prec>MAXEC || prec < 0)	/* prec ist Anzahl Nachkommaziffern + 1 */
  	prec = MAXEC;
  if (x == 0.0) {
  	*tp++ = '0';
  	*tp++ = '.';
  	*tp++ = '0';
  	*tp = '\0';
  	return tp;
  }
  if (x < 0.0) {
  	*tp++ = '-';
  	x = -x;
  }

  exp = logten(&x);
  temp[0] = '0';
  for (i=1; i<=prec+1; i++) {		/* Vorkomma + Nachkomma + Rundung */
  	fint = (int) x;
	if ((fint<0) || (fint>9))
		printf("\nKonvertierungsfehler bei %d: %x\n",i,fint);
  	temp[i] = fint + '0';
  	x = x - (double) fint;
  	x = x * 10.0;
  }
  if (temp[--i] >= '5')
  	while(--i >= 0)
  		if (temp[i] == '9')
  			temp[i] = '0';
  		else {
  			temp[i]++;
  			break;
  		}
  if (i==0)
  	exp++;
  else
  	i = 1;
  *tp++ = temp[i];
  *tp++ = '.';
  strncpy(tp, &temp[i+1], prec-1);
  tp += prec-1;
  *tp++ = 'e';
  if (exp>=0)
  	*tp++ = '+';
  else {
  	*tp++ = '-';
  	exp = -exp;
  }
  if (exp > 99) {
  	*tp++ = exp/100+'0';
  	exp = exp%100;
  }
  *tp++ = exp/10+'0';
  *tp++ = exp%10+'0';
  *tp = '\0';
  return tp;
}

char *_fcvt( p, x, prec)
char *p;
double x;
int prec;
{
  register int i, j, fint, exp;
  register char *tp = p;
  char temp[48];
  
  tp =temp;
  j = 0;
  if (prec > MAXEC || prec < 0)
  	prec = MAXEC;
  if (x == 0.0) {
  	*p++ = '0';
  	*p++ = '.';
  	*p++ = '0';
  	*p = '\0';
  	return p;
  }
  if (x < 0.0) {
	*p++ = '-';
    	x = -x;
  }
  exp = logten(&x);
  if (exp > MAXEXP) {
  	*p++ = '?';
  	*p++ = '.';
  	*p++ = '?';
  	*p = '\0';
  	return p;
  }
  temp[0] = '0';
  for (i=1; i<=exp+1; i++) {
  	fint = (int) x;
  	tp[i] = fint + '0';
  	x = x - (double) fint;
  	x = x * 10.0;
  }
  for (j=0; j<prec+1; j++) {		/* Nachkomma + Rundungsziffer */
	fint = (int) x;
	tp[i+j] = fint + '0';
	x = x - (double) fint;
	x = x * 10.0;
  }
  i += j;
  tp[i] = '\0';
  if (tp[--i] >= '5')
  	while(--i >= 0)
  		if (tp[i] == '9')
  			tp[i] = '0';
  		else {
  			tp[i]++;
  			break;
  		}
  if (i==0)
  	exp++;
  else
  	i = 1;
  for ( ;i<=exp+1; i++)
  	*p++ = tp[i];
  if (prec)
  	*p++ = '.';
  for (j=0; j<prec; j++)
  	*p++ = tp[i+j];
  *p = '\0';
  return p;
}

char *_gcvt( p, x, prec)
char *p;
double x;
int prec;
{
  char ebuf[48], fbuf[48], *ep, *fp;
  ep = _ecvt(ebuf, x, prec+1);
  fp = _fcvt(fbuf, x, prec);
  if (fbuf[0] == '?' && fbuf[1] == '.' && fbuf[2] == '?')
  	ep = ebuf;
  else
  	ep = ep < fp ? ebuf : fbuf;
  strcpy(p, ep);
  return p + strlen(p);
}

#define	ffpformat	9
static int twopot[9] = { 1, 2, 4, 8, 16, 32, 64, 128, 256 };
static long tenpot[18] = {
	0x40240000,	0x00000000,	/*   1 */
	0x40590000,	0x00000000,	/*   2 */
	0x40C38800,	0x00000000,	/*   4 */
	0x4197D784,	0x00000000,	/*   8 */
        0x4341C379,	0x37E08000,	/*  16 */
        0x4693B8B5,	0xB5056E17,	/*  32 */
        0x4D384F03,	0xE93FF9F5,	/*  64 */
        0x5A827748,	0xF9301D32,	/* 128 */
        0x75154FDD,	0x7F73BF3C	/* 256 */
};

int logten(num)
double *num;
{
  int i,erg;
  double dhelp;

  erg = 0;
  dhelp = *num;

  if (dhelp >= 1.0) {		 	/* Zahl groesser 1? */
	for (i=ffpformat-1; i >= 0; i--) {
		dhelp = *num/((double *) tenpot)[i];
		if (dhelp >= 1.0) {
			*num = dhelp;
			erg += twopot[i];
		}
	}
	return(erg);
  } else {
  	for (i=ffpformat-1; i>=0; i--) {
		dhelp = *num * ((double *) tenpot)[i];
  		if (dhelp < 10.0) {
  			*num = dhelp;
  			erg += twopot[i];
  		}
  	}
  	return(-erg);
  }
}
#endif /* NO_FLOAT */
