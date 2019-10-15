#include <ext.h>    
#include <stdio.h>
#include <graphics.h>
#include <math.h>
#include <process.h>
#include <stdlib.h>

#define WORLD_WIDTH     1000    /* Groesse des */
#define WORLD_HEIGHT    1000    /* Weltsystems */
#define BGI_PATH        "" 	    /* Dummy String */

float x,y,z;    /* 3D Raumkoordinaten */
int sx;         /* sx,sy Bildschirmkoordinaten */
float sz,sy;
int maxx, minx=0, maxy, miny=0;
float screen_x, screen_y;   /* Bildschirmausma·e */

float d=750.0;  /* Focal distance */
float mx=0.0, my=0.0, mz=-350;  /* Betrachterpos. */
int graphdriver = DETECT, graphmode;

/* Variablen fÅr rotation(), calc_3d(), window() */

float xa=0.0, ya=0.0, za=0.0;
double r1=0,r2=0,r3=0;  /* Drehung des Krd.Systems */
double sr1=0,sr2=0,sr3=0;
double cr1=0, cr2=0, cr3=0;
float rx=0.0, ry=0.0;

/* Function Prototypes */

void calc_3d(void),rotation(void),window(void);
void initbgi(void);

/* MAIN : Demonstration der drei 3-D Funktionen! */

int main() 
{
  #define LINES 11
  float xs[] = {-200,-150,-50,50,-50,-50,
                100,100,100,200,100},
        xe[] = {-100,-150,50,50,50,-50,
                200,100,200,200,200},
        ys[] = {100,100,100,100,-100,-100,
                100,100,0,0,-100},
        ye[] = {100,-100,100,-100,-100,
                100,100,0,0,-100,-100},
        zk[] = {0,0,-50,-50,-50,-50,
                -100,-100,-100,-100,-100};
  int i,x1,y1,
    ox1[LINES],ox2[LINES],oy1[LINES],oy2[LINES];
  static float dx = 0.05,dy = 0.07, dz = -2.1;
  static float dr1 = 0.01, dr2 = 0.012, dr3 = 0.018;

    initbgi();  /* BGI-Treiber init. */
    setcolor(getmaxcolor());
    setwritemode(XOR_PUT);
    while (!kbhit()) { /* bis Tastendruck */
        for (i = 0; i < LINES; i++) {
            x = xs[i]; y = ys[i]; z = zk[i];
            rotation(); calc_3d(); window();
            x1 = sx; y1 = (int)sy;
            x = xe[i]; y = ye[i]; z = zk[i];
            calc_3d(); window();
            line(ox1[i],oy1[i],ox2[i],oy2[i]);
            line(ox1[i] = x1,oy1[i] = y1,
                ox2[i] = sx,oy2[i] = (int)sy);
        }
        mx += dx; my += dy; mz += dz;
        r1 += dr1; r2 += dr2; r3 += dr3;
    }
    getch(); closegraph(); return 0;
}

/* Berechnet Rotationswerte fuer calc_3d() */

void rotation (void) {
    sr1 = sin(r1); sr2 = sin(r2); sr3 = sin(r3);
    cr1 = cos(r1); cr2 = cos(r2); cr3 = cos(r3);
}

/* Berechnet die 2-D-Koordinaten aus den
   3-D Weltkoordinaten (x,y,z), die zuvor noch
   mit den Werten von rotation() rotiert werden */

void calc_3d (void) {
    x = (-1)*x;
    xa = cr1*x-sr1*z;
    za = sr1*x+cr1*z;
    x = cr2*xa+sr2*y;
    ya = cr2*y-sr2*xa;
    z = cr3*za-sr3*ya;
    y = sr3*za+cr3*ya;
    x += mx; y += my; z += mz;
    sx = d*x/z; sy = d*y/z;
}

/* Rechnet die Bildschirmkoordinaten aus den
   2-D-Koordinaten und legt sie in (sx,sy) ab */

void window (void) {
    sx += (WORLD_WIDTH/2-1);
    sy += (WORLD_HEIGHT/2-1);
    rx = screen_x/(WORLD_WIDTH-1);
    ry = screen_y/(WORLD_HEIGHT-1);
    sx *= rx; sy *= ry;
}

/* Initialisiert das BGI vorschriftsmaessig */

void initbgi (void) 
{
  int errorcode;
    initgraph (&graphdriver, &graphmode, BGI_PATH);
    errorcode = graphresult();  /* Alles OK? */
    if (errorcode != grOk) { /* Init. missglueckt */
        printf("Grafikfehler: %s\n",
            grapherrormsg(errorcode));
        printf("DrÅcken Sie eine bel. Taste!");
        getch(); exit(1); /* Ende mit Fehlercode */
    }
    screen_x = getmaxx()-1; screen_y = getmaxy()-1;
    maxx = screen_x; maxy = screen_y+1;
}
