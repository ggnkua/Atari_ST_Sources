/* Drehbarer Vektor - DrahtwÅrfel, Rechen- und Zeichenteil */

#include <math.h>
#include <linea.h>
#include <osbind.h>

#define RADIUS 173.20508075
#define RAD_Q  30000.0
#define XM 320
#define YM 200
#define sign(x) (((x)<0)?(-1):(1))
#define PREC 4.0
#define PER 1732      /* 10 Radien */

void new_cube(), clear();

extern int screen[2];


void new_cube(a_chg, b_chg)
double *a_chg, *b_chg;
{
   static double a_A = -PI/4.0;
   double b_A;
   static double a_C = 3.0*PI/4.0;
   double b_C;
   static double phi_A = -0.61547970865;
   static double phi_C = -0.61547970865;
   double x_A, x_C;
   short  xO, yO, zO, xOB, yOB, zOB;
   short  xA, yA, zA, xB,  yB,  zB;
   short  xC, yC, zC, xD,  yD,  zD;
   short  xE, yE, zE, xF, yF, zF, xG, yG, zG, xH, yH, zH;
   char help;
   double cos_b_A;
   double tan_b_A;
   double cos_b_C;
   double tan_b_C;
   short abs_zA, abs_zC;
   double abs_x_A, abs_x_C;


   a_A += *a_chg;                            /* A - Winkel update */

   b_A = atan2(tan(phi_A), cos(a_A));
   if ((help=sign(phi_A)) != sign(b_A)) b_A += PI * help;

   x_A = RADIUS * cos(phi_A) * sin(a_A);

   b_A += *b_chg;

   a_A = atan2(x_A, sqrt(RAD_Q-x_A*x_A) * abs(cos_b_A=cos(b_A)));
   if (cos_b_A < 0) a_A = sign(x_A) * PI - a_A;

   phi_A = atan((tan_b_A=tan(b_A)) * cos(a_A));


   a_C += *a_chg;                            /* C - Winkel update */

   b_C = atan2(tan(phi_C), cos(a_C));
   if ((help=sign(phi_C)) != sign(b_C)) b_C += PI * help;

   x_C = RADIUS * cos(phi_C) * sin(a_C);

   b_C += *b_chg;

   a_C = atan2(x_C, sqrt(RAD_Q-x_C*x_C) * abs(cos_b_C=cos(b_C)));
   if (cos_b_C < 0) a_C = sign(x_C) * PI - a_C;

   phi_C = atan((tan_b_C=tan(b_C)) * cos(a_C));


   xA = (short)x_A;
   xC = (short)x_C;
   zA = (short) - RADIUS * sin(phi_A);               /* restliche Koordinaten */
   yA = (short) ((abs_zA=abs(zA)) > (abs_x_A=abs(x_A)))
                ? ((abs_zA  > PREC) ? (zA / tan_b_A) : (-sign(cos_b_A)*RADIUS))
                : ((abs_x_A > PREC) ? (- x_A / tan(a_A)) : (-sign(cos_b_A)*RADIUS));
   zC = (short) - RADIUS * sin(phi_C);
   yC = (short) ((abs_zC=abs(zC)) > (abs_x_C=abs(x_C)))
                ? ((abs_zC  > PREC) ? (zC / tan_b_C) : (-sign(cos_b_C)*RADIUS))
                : ((abs_x_C > PREC) ? (- x_C / tan(a_C)) : (-sign(cos_b_C)*RADIUS));

   xO = (xA+xC) / 2;                            /* Vektor MO */
   yO = (yA+yC) / 2;
   zO = (zA+zC) / 2;

   xOB = (yA*zC - zA*yC) / 200;                 /* Vektor OB */
   yOB = (zA*xC - xA*zC) / 200;
   zOB = (xA*yC - yA*xC) / 200;

   xB = xO + xOB;                          /* Koords von B */
   yB = yO + yOB;
   zB = zO + zOB;

   xD = xO - xOB;                          /* Koords von D */
   yD = yO - yOB;
   zD = zO - zOB;

   xE = -xC;  yE = PER-yC;  zE = -zC;  /* Koords spiegeln */
   xF = -xD;  yF = PER-yD;  zF = -zD;
   xG = -xA;  yG = PER-yA;  zG = -zA;
   xH = -xB;  yH = PER-yB;  zH = -zB;

   yA += PER; yB += PER; yC += PER; yD += PER;

   xA *= (PER-RADIUS) / yA;  zA *= (PER-RADIUS) / yA;
   xB *= (PER-RADIUS) / yB;  zB *= (PER-RADIUS) / yB;
   xC *= (PER-RADIUS) / yC;  zC *= (PER-RADIUS) / yC;
   xD *= (PER-RADIUS) / yD;  zD *= (PER-RADIUS) / yD;
   xE *= (PER-RADIUS) / yE;  zE *= (PER-RADIUS) / yE;
   xF *= (PER-RADIUS) / yF;  zF *= (PER-RADIUS) / yF;
   xG *= (PER-RADIUS) / yG;  zG *= (PER-RADIUS) / yG;
   xH *= (PER-RADIUS) / yH;  zH *= (PER-RADIUS) / yH;

   xA += XM;  zA += YM;                          /* fehlende Offsets */
   xB += XM;  zB += YM;
   xC += XM;  zC += YM;
   xD += XM;  zD += YM;
   xE += XM;  zE += YM;
   xF += XM;  zF += YM;
   xG += XM;  zG += YM;
   xH += XM;  zH += YM;


   {                                   /* zeichnen */
      static int scrno = 0;

      scrno ^= 1;
      lineaa();
      Setscreen(screen[scrno], -1, -1);
      clear();
      COLBIT0 = 1;
      LNMASK = 0xFFFF;

      X1 = xA;  Y1 = zA;
      X2 = xB;  Y2 = zB;
      linea3();

      X2 = xD;  Y2 = zD;
      linea3();

      X2 = xE;  Y2 = zE;
      linea3();

      X1 = xC;  Y1 = zC;
      X2 = xB;  Y2 = zB;
      linea3();

      X2 = xD;  Y2 = zD;
      linea3();

      X2 = xG;  Y2 = zG;
      linea3();

      X1 = xF;  Y1 = zF;
      X2 = xB;  Y2 = zB;
      linea3();

      X2 = xE;  Y2 = zE;
      linea3();

      X2 = xG;  Y2 = zG;
      linea3();

      X1 = xH;  Y1 = zH;
      X2 = xD;  Y2 = zD;
      linea3();

      X2 = xE;  Y2 = zE;
      linea3();

      X2 = xG;  Y2 = zG;
      linea3();

      Vsync();
      Setscreen(-1, screen[scrno], -1);
      linea9();
   }
}

void clear()
{
   COLBIT0 = 0;

   X1 = (short)XM-RADIUS-1;
   Y1 = (short)YM-RADIUS-1;
   X2 = (short)XM+RADIUS+1;
   Y2 = (short)YM+RADIUS+1;

   linea5();
}

