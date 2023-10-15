/* APFEL_R.C
 *
 * Der C-Rechenteil zur FPU-Demonstration
 *
 * (c) April 1993 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * Maus UN
 * CompuServe 100025,2263
 *
 * Erstellt mit Pure C  
 * Vertrieb nur durch das TOS-Magazin!
 */

#include <tos.h>
#define TRUE 1
#define FALSE 0

/* Prototypen */
void draw_zeile(int *z,int mx, int y);
int mandel_line(double r_cons,double i_cons,double r_delta, long t, long x, long g, int *erg);

int check_break(void)
/* Testet, ob eine Taste gedrckt wurde */
{
    if(Cconis())
    {
        while(Cconis()) Cconin();
        return(TRUE);
    }
    return(FALSE);
}/* check_break */

void do_mandel(int xw,int yw,double r_max,double r_cons,double i_max,double i_cons, long g, int t)
/* Berechnet das Apfelm„nnchen */
{
    static int erg[1280];   /* Hier wird eine komplette Zeile abgelegt */
    int y;
    double r_delta, i_delta;
    
    r_delta=(r_max-r_cons)/xw;
    i_delta=(i_max-i_cons)/yw;
    xw--; yw--; 

    for(y=yw;y>=0;y--)
    {
        mandel_line(r_cons,i_cons,r_delta,t,xw,g,erg);
        draw_zeile(erg,xw,y);
        i_cons+=i_delta;
        if(check_break()) break;
    }   
} /* do_mandel */

