/**********************************************************/
/*                                                        */
/* Verbessertes Random-Walk-Verfahren zur statistischen   */
/* Parameteroptimierung.                                  */
/*                                                        */
/*              Rainer Storn, Mai 1990                    */
/*                                                        */
/**********************************************************/

# include <stdio.h>
# include <math.h>

# define maxdim 30
# define ngauss 200
# define pi     3.141592654

/*-----------------Globale Variablen----------------------*/

  int   dim;
  float gauss[ngauss], ugauss[ngauss], zz[maxdim];
  unsigned long seed1, seed2, seed3;

/*-----------------Funktionsdeklarationen-----------------*/

float zuf();
float phi();
void  table();
void  ran1();
float zielf();

/*-----------------Funktionsdefinitionen------------------*/

         float zuf()
/*****************************************/
/*                                       */
/* zuf() erzeugt eine im Intervall [0,1] */
/* gleichverteilte Zufallszahl.          */
/*                                       */
/*****************************************/
{
  unsigned long m1, m2, m3, a1, a2, a3, c1, c2, c3;
  float x;
  
  m1 = 259200;
  m2 = 134456;
  m3 = 243000;
  a1 = 7141;
  a2 = 8121;
  a3 = 4561;
  c1 = 54773;
  c2 = 28411;
  c3 = 51349;
  
  seed1 = (seed1*a1 + c1)%m1;
  seed2 = (seed2*a2 + c2)%m2;
  seed3 = (seed3*a3 + c3)%m3;
    
  
  if ((float)seed3/(float)m3 > 0.5)
    {
      return((float)seed1/(float)m1);
    }
  else
    {
      return((float)seed2/(float)m2);
    }
}/*------Ende von zuf()--------------------------*/

         
         float phi(x)
/****************************************/
/*                                      */
/* Berechnung von phi(x)=0.5*(1-erf(x)) */
/* mit Hilfe der Simpson-Integration    */
/* fr positive x. phi(x) ist die Ver-  */
/* teilungsfunktion der Gauss'schen     */
/* Standard-Normalverteilung.           */
/*                                      */
/****************************************/
  float x;
{
  int   n, i;
  float am, b, g, h, h1, error, e1, s, x1, xn, y;
  
/*----Untergrenze 0, Obergrenze b von erf(x)-----*/
  
  b = fabs(x);  
  if (b < 1.e-9)
    {
      y = 0.5;
      goto ende;
    }
  error = 1.e-9;
  
/*----Berechnung der Streifenzahl n--------------*/

  am = b/2.0;
  h1 = b/40.0;
  
  e1 = 0.0;               /*--Fehlerrechnung--*/
  x1 = am - 2.0*h1;
  e1 = e1 + exp(-x1*x1);
  x1 = am - h1;
  e1 = e1 - 4.0*exp(-x1*x1);
  x1 = am;
  e1 = e1 + 6.0*exp(-x1*x1);
  x1 = am + h1;
  e1 = e1 - 4.0*exp(-x1*x1);
  x1 = am + 2.0*h1;
  e1 = e1 + exp(-x1*x1);
  e1 = fabs(e1)/(h1*h1*h1*h1);
  
  xn = sqrt(sqrt(b*b*b*b*b*e1/error/180.0));
  xn = 2.0*floor(xn/2.0 + 1.0);
  n  = (int)xn;
  
/*------------Auswertung der Simpson-Formel-----------------*/    

  s  = 1.0 + exp(-b*b);
  g  = 4.0;
  h  = b/xn;
  
  for (i=1; i<= (n-1); i=i+1)
    {
      x1 = (float)i;
      x1 = x1*h;
      s  = s + g*exp(-x1*x1);
      g  = 6.0 - g;
    }
    
/*------------Bestimmung von phi(x) = 0.5(1+erf(x))---------*/

  y = 0.5*(1.0 + (2.0*s*h/3.0)/1.772453851);
  if (x < 0.0)
    {
      y = 1.0 - y;
    }
    
  ende: return(y);  
}/*------Ende der Funktion phi(x)---------------------------*/

         void table()
/***************************************************/
/*                                                 */       
/* table erstellt eine Tabelle fr die Umkehrfunk- */
/* tion von phi(x).                                */ 
/*                                                 */
/***************************************************/
{
  int   mgn1, mgn2, mean, k, i;
  float xphi, xsig, yinc, error;  

  xsig = 4.0;
  
/*------Erzeugen einer Tabelle von phi(x) im Feld gauss[]------*/

  for (i=0; i<ngauss; i=i+1)
    {
      xphi     = -xsig + 2.0*xsig*((float)i)/((float)(ngauss-1));
      gauss[i] = phi(xphi);
    }
    
/*------Erzeugen der Umkehrfunktionstabelle zu phi(x).---------*/
/*------Hierzu wird eine Bin„rsuche und lineare Interpolation--*/
/*------verwendet.---------------------------------------------*/

  for (i=0; i<ngauss; i=i+1)
    {
      yinc  = ((float)i)/((float)(ngauss-1));
      mgn1  = 0;
      mgn2  = ngauss;
      mean  = (mgn1 + mgn2)/2;
      
/*-------------------Bin„rsuche--------------------------------*/

cont: k     = mean;
      error = gauss[k] - yinc;
      if (error <= 0.0) 
        {
          mgn1 = k;
        }
      else
        {
          mgn2 = k;
        }
      mean  = (mgn1 + mgn2)/2;
      if (k != mean) goto cont;
      
/*-------------------Interpolation-----------------------------*/

      if (error <= 0.0)
        {
          if (k >= (ngauss-1))
            {
              ugauss[i] = xsig;
            }
          else
            {
              ugauss[i] = 2.0*xsig*((float)k + (yinc-gauss[k])/
                          (gauss[k+1]-gauss[k]))/(float)ngauss-xsig;
            }
        }
      else
        {
          if (k <= 0)
            {
              ugauss[i] = - xsig;
            }              
          else
            {
              ugauss[i] = 2.0*xsig*((float)(k-1) + (yinc-gauss[k-1])/
                          (gauss[k]-gauss[k-1]))/(float)ngauss-xsig;
            }
        }
    }/*-------Ende der for-Schleife---------------------------------*/        
}/*--------Ende der Funktion table()--------------------------------*/

         void ran1()
/***************************************************/
/*                                                 */       
/* ran1() erzeugt einen standard-normalverteilten  */
/* Zufallsvektor zz[i] der Dimension dim.          */
/* D.h. jedes Vektorelement ist normalverteilt mit */
/* Mittelwert 0 und Standardabweichung 1.          */ 
/*                                                 */
/***************************************************/
{
  int   i, j1, j2;
  float x, x1;
  
/*---Erzeugen eines Zufallsvektors mit gleichverteilten-----*/
/*---Vektorelementen aus dem Intervall [0,1].---------------*/

  for (i=0; i<dim; i=i+1)
    {
      zz[i]  = zuf();
    }
    
/*---Umwandlung des gleichverteilten Zufallsvektors in------*/
/*---einen standard-normalverteilten Zufallsvektor.---------*/

  for (i=0; i<dim; i=i+1)
    {
      x  = (float)ngauss*zz[i];
      x1 = floor(x);
      j1 = (int)x;
      j2 = j1 + 1;
      if (j1 >= ngauss)
        {
          zz[i] = ugauss[ngauss-1];
        }
      else
        {
          zz[i] = ugauss[j1] + (ugauss[j2]-ugauss[j1])*(x-x1);
        }
    }
}/*-------Ende der Funktion ran1()--------------------------*/


         float zielf()
/*****************************************/
/*                                       */
/*       Toleranzschemaeinpassung        */
/*       ------------------------        */
/*                                       */
/* zielf() liefert den Zielfunktionswert */
/* y zurck, den es zu minimieren gilt.  */
/*                                       */
/* Ben”tigte globale Variablen:          */
/* zz[maxdim], dim.                      */
/*                                       */
/*****************************************/
{
  int   i, n;
  float delta1, delta2, delta3, x, y, maxdev;

/*----Untersuche Bereich fr Argument zwischen -1 und 1------*/

  delta1 = 0.0;
  maxdev = 0.0;
  for (i=0; i<=100; i=i+1)
    {
      y = 0.0;
      x = -1.0 + (float)i/50;
      for (n=dim-1; n>0; n=n-1)
        {
          y = (y + zz[n])*x;
        }
      y = y + zz[0];
      if (fabs(y) > 1.0) maxdev = (1-fabs(y))*(1-fabs(y));
      if (maxdev > delta1) delta1 = maxdev; 
    }
    
/*-----Untersuche Argumentenwert +1.2-------------------------*/

  delta2 = 0.0;
  x      = 1.2;
  y      = 0.0;
  for (n=dim-1; n>0; n=n-1)
    {
      y = (y + zz[n])*x;
    }
  y = y + zz[0];
  if (y < 5.9) delta2 = (y-5.9)*(y-5.9);
  
/*-----Untersuche Argumentenwert -1.2-------------------------*/

  delta3 = 0.0;
  x      = -1.2;
  y      = 0.0;
  for (n=dim-1; n>0; n=n-1)
    {
      y = (y + zz[n])*x;
    }
  y = y + zz[0];
  if (y < 5.9) delta3 = (y-5.9)*(y-5.9);
  
  return(sqrt(delta1+delta2+delta3));
  
}/*---------Ende von zielf()----------------------------------*/
          

/*******************************************************************/
/*                                                                 */
/*                H  A  U  P  T  P  R  O  G  R  A  M  M            */
/*                                                                 */
/*******************************************************************/

main()
{
  int   i, itemp, itry, idet, iacc, ntemp, maxtry, msucc;
  int   flag, isucc;
  float beta, xi[maxdim], sigma[maxdim], xphi, z, level;
  float acratio, tfactr, temp, best, actual, delta, xran;
  float reduct;
  
/*---Initialisierungen------------------------------------*/

  FILE   *fpin;
  FILE   *fpout;
  fpin   = fopen("INPUT.DAT" ,"r");
  fpout  = fopen("OUTPUT.DAT","w");
  seed1  = 1723;         /*---Initialisierung von zuf()----------*/
  seed2  = 1541;         /*---Initialisierung von zuf()----------*/
  seed3  = 205;          /*---Initialisierung von zuf()----------*/
  tfactr = 0.9;          /*---Reduktionsfaktor fr "Temperatur"--*/
  reduct = 0.5;          /*---Reduktionsfaktor fr sigma[]-------*/
  temp   = 0.5;          /*---Anfangstemperatur------------------*/
  best   = 1.0e20;       /*---bester Anfangs-Zielfunktionswert---*/
  
/*---Lese Eingabedaten vom File INPUT.DAT-----------------*/

  fscanf(fpin,"%d",&dim);  /*---Anzahl Vektorelemente------------*/
  fscanf(fpin,"%d",&ntemp);/*---Anzahl Temperaturschritte--------*/

  maxtry = 100*dim;      /*---Maximalzahl an neuen Parametervek--*/
                         /*---toren pro Temperaturschritt--------*/
  msucc  = 10*dim;       /*---Maximalzahl neugenerierter Nominal-*/
                         /*---vektoren pro Temperaturschritt-----*/
  level  = 1.0/(float)maxtry;   /*--Schwelle fr Akzeptanzverh.--*/

  fscanf(fpin,"%f",&beta);

  for (i=0;i<dim;i=i+1)
    {
     fscanf(fpin,"%f",&xi[i]);  /*---Nominalwert des Parametervektors */
    }
    
  for (i=0;i<dim;i=i+1)
    {
     fscanf(fpin,"%f",&sigma[i]);  /*---Standardabweichungen---*/
    }
    
/*---Erzeuge Gauss-Umwandlungstabelle--------------------------*/

  printf("********************************************\n");
  printf("*                                          *\n");
  printf("* Verbessertes Random-Walk-Verfahren zur   *\n");
  printf("* Parameteroptimierung.                    *\n");
  printf("*                                          *\n");
  printf("*      Von Rainer Storn, Mai 1990          *\n");
  printf("*                                          *\n");
  printf("********************************************\n\n");
  printf("Gausstabelle wird erzeugt\n");
  printf("Rechner arbeitet\n\n");
  table();
  printf("Gausstabelle generiert\n");
  printf("Optimierung beginnt\n\n");
  
/*---Starte Optimierungsroutine--------------------------------*/

  for (itemp=0; itemp<ntemp; itemp=itemp+1)
    {
      itry  = 0;
      isucc = 0;
      iacc  = 0;
      idet  = 0; 

con1: itry  = itry + 1;

/*----Erzeuge neuen Parametervektor----------------------------*/

      ran1();
      for (i=0; i<dim; i=i+1)
        {
          zz[i] = zz[i]*sigma[i];
          zz[i] = zz[i] + xi[i];
        }

/*----Werte Zielfunktion aus-----------------------------------*/

      actual = zielf();
      delta  = actual - best;
      
/*----Entscheide, ob der neue Parametervektor als neuer--------*/
/*----Nominalwert akzeptiert werden soll.----------------------*/

      if (delta < 0.0)
        {
          flag = 1;
          iacc = iacc + 1;
        }
      else
        {
          idet = idet + 1;
          if (temp >= 0.000001)  /*--Bercksichtigung der einge- --*/
            {                    /*--schr„nkten Genauigkeit des----*/
                                 /*--Datentyps float---------------*/
              if (zuf() < exp(-delta*beta/temp))
                {
                  flag = 1;
                  iacc = iacc + 1;
                }
              else
                {
                  flag = 0;
                }
            }
          else
            {
              flag = 0;
            }      
        }
        
/*----Falls flag=1 wird der Parametervektor als neuer----------*/
/*----Nominalwert akzeptiert.----------------------------------*/

      if (flag == 1)
        {
          for (i=0; i<dim; i=i+1)
            {
              xi[i] = zz[i];
            }
          best  = actual;
          isucc = isucc + 1;
        }
        
/*----Prfe, ob bereits genug Zufalls„nderungen erfolgt sind.--*/

      if ((itry < maxtry) && (isucc < msucc)) goto con1;
      
/*----Falls ja, gehe zur n„chstniedrigeren Temperatur.---------*/
 
      temp     = temp*tfactr;
      acratio  = (float)iacc/(float)itry;
      if (acratio < level)
        {
          for (i=0; i<dim; i=i+1)
            {
              sigma[i] = sigma[i]*reduct;
            }
        }
        
/*----Gebe Optimierungsdaten des gegenw„rtigen Iterations- ----*/
/*----schrittes aus.-------------------------------------------*/

      printf("\n");
      for (i=0; i<dim; i=i+1)
        {
          printf("xi(%d) = %f\n",i,xi[i]);
        }
      for (i=0; i<dim; i=i+1)
        {
          printf("sigma(%d) = %f\n",i,sigma[i]);
        }
      printf("Temperaturschritt           = %d\n",itemp);
      printf("Temperatur                  = %f\n",temp);
      printf("Zahl der Zufallsaenderungen = %d\n",itry);
      printf("Akzeptanzverhaeltnis        = %f\n",acratio);
      printf("Zielfunktionswert           = %f\n",best);
      if (actual <= 1.0e-6) goto fin;
    
    }/*----Ende for(itemp...)-Schleife-------------------------*/  
  
/*---Schreibe Eingabedaten auf File OUTPUT.DAT-----------------*/

fin:  fprintf(fpout,"\n");
      for (i=0; i<dim; i=i+1)
        {
          fprintf(fpout,"xi(%d) = %f\n",i,xi[i]);
        }
      for (i=0; i<dim; i=i+1)
        {
          fprintf(fpout,"sigma(%d) = %f\n",i,sigma[i]);
        }
      fprintf(fpout,"Temperaturschritt           = %d\n",itemp);
      fprintf(fpout,"Temperatur                  = %f\n",temp);
      fprintf(fpout,"Zahl der Zufallsaenderungen = %d\n",itry);
      fprintf(fpout,"Akzeptanzverhaeltnis        = %f\n",acratio);
      fprintf(fpout,"Zielfunktionswert           = %f\n",best);

      fclose(fpin);
      fclose(fpout);
} /*-------------------Ende von main()----------------------------*/
