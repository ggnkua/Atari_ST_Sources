/*****************************************************************************/
/*                                                                           */
/*                      VDI SAMPLER and C PRIMER                             */
/*                                                                           */
/*                           by  JIM LUCZAK                                  */
/*                                                                           */
/*    The intent of this program is to demonstrate a few of the many VDI     */
/*    functions, how to call the functions, and in some cases what           */
/*    parameters are valid. The program also demonstrates some of the        */
/*    basics of programming in C. This is by no means a "well written        */
/*    C program". At best it is very crude, however it gets the job done.    */
/*                                                                           */
/*    COMPILING and LINKING source code takes quite a bit of time. Before    */
/*    Compiling a program check your syntax. Look for forgotten semi-colons  */
/*    missing commas ect. This simple precaution can save you a lot of       */
/*    frustration. If you are writing a large program, build the program     */
/*    in modules. In writing this program the first module I built was       */
/*    BASE PROGRAM. All this module does is opens the workstation, provides  */
/*    a place for other modules, and closes and exits the workstation.       */
/*    As I wrote each module, I saved it under its own filename. To test     */
/*    the module I combined the BASE PROGRAM and the module I wanted to      */
/*    test. After the module was running the way I wanted it to, I saved     */
/*    the final version of that module, and started the next module. When    */
/*    all of the modules were built I combined all the modules into one      */
/*    program and compiled it. This may sound a bit cumbersome, but with     */
/*    the amount of memory avaiable it is the only way to compile programs   */
/*    in a reasonable amount of time. RAM DISKS and more memory help compile */
/*    times a lot. Of course when HARD DISKS are avaiable, programming in C  */
/*    will a lot nicer.                                                      */
/*                                                                           */
/*****************************************************************************/

 
/*************************** BASE PROGRAM ************************************/

#include "alpha.h"           /* UPPER & LOWER CASE LETTERS & #'S FOR PROGRAM */
#include "portab.h"
#include "obdefs.h"
#include "osbind.h"

int contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
int buffer[5], rgb_in[3], pxy[4], dum1[2], dum2[6];
int handle, ai, gr_2, px, py;
int prx = 65, pry = 190, tsz = 5, cell_w, cell_h, cell_h1;

                       /* DATA FOR COLOR REGISTERS */      

int newc[48] = {0,0,0,1000,1000,1000,1000,0,0,0,1000,0,0,0,1000,0,1000,1000,
                    1000,1000,0,1000,0,1000,714,714,714,428,428,428,1000,428,
                    428,428,1000,428,428,428,1000,428,1000,1000,1000,1000,428,
                    1000,428,1000};

static char   prompt[] = "PRESS ANY KEY TO CONTINUE";

double num1;


main()
{
int     l_intin[11], l_out[57], rgb_out[3];
int index;
int     gr_1, gr_3, gr_4;
int oldc[48];

appl_init();

handle=graf_handle(&gr_1, &gr_2, &gr_3, &gr_4);
v_hide_c(handle);
v_clrwk(handle);

/*-------------------------- OPEN WORKSTATION --------------------------------*/

l_intin[0] = 1;
for (ai = 1; ai < 10; ai++)
l_intin[ai] = 1;
l_intin[10] = 2;
v_opnvwk(l_intin, &handle, l_out);

/*------------------ SAVE OLD COLORS AND SET TO NEW VALUES -------------------*/
px=0;
for (ai=0; ai < 16; ai++)
{
vq_color(handle, ai, 1, rgb_out);
oldc[px]=rgb_out[0]; ++px;
oldc[px]=rgb_out[1]; ++px;
oldc[px]=rgb_out[2]; ++px;
}
px=0;
for (ai=0; ai < 16; ai++)
{
rgb_in[0] = newc[px]; px++;
rgb_in[1] = newc[px]; px++;
rgb_in[2] = newc[px]; px++;
index = ai;
vs_color(handle, index, rgb_in);
}
vst_height( handle, gr_2, &dum1, &dum1, &dum1, &cell_h1);

/*------------------- CHECK TO SEE IF WE ARE IN MED REZ ----------------------*/

if (l_out[13] < 5)
{
vst_height( handle, 20, &dum1, &dum1, &cell_w, &dum1);
vst_color(handle, 1);                                    
v_gtext(handle, 100 + (cell_w * 5), 75, "Sorry this is a LOW RES demo");
v_gtext(handle, 100, 100, "Switch to LOW RES and restart program");
v_gtext(handle, 100 + (cell_w * 14), 125, "THANK YOU");
key_wait();
}
else

/*-------------------------- PROGRAM MODULE AREA -----------------------------*/

{
intro();
menu();
}

/*------------------------------- RESET COLORS ------------------------------*/

px=0;
for (ai=0; ai < 16; ai++)
{
rgb_in[0] = oldc[px]; px++;
rgb_in[1] = oldc[px]; px++;
rgb_in[2] = oldc[px]; px++;
index = ai;
vs_color(handle, index, rgb_in);
}

/*---------------------------- CLOSE WORKSTATION -----------------------------*/

v_clrwk(handle);
v_clsvwk(handle);
appl_exit();

}

/******************************** END MAIN ************************************/



/**************************** WAIT FOR KEY PRESS ******************************/

key_wait()
{
vst_height( handle, tsz, &dum1, &dum1, &dum1, &dum1); /* SET CHARACTER HEIGHT */
vst_color(handle, GREEN );                            /* SET CHARACTER COLOR  */
v_gtext(handle, prx, pry, prompt );                 /* WRITE IN GRAPHICS MODE */
vsin_mode(handle, 4, 1);                          /* SET INPUT MODE TO STRING */
vrq_string(handle, 1, 0, dum1, &dum2);             /* WAIT FOR KEYBOARD INPUT */
vst_height( handle, gr_2, &dum1, &dum1, &dum1, &dum1);
v_clrwk( handle );                                       /* CLEAR WORKSTATION */
}

/****************************** END KEY WAIT ********************************/


/**************************** INTRODUCTION SCREEN *****************************/

intro()
{
                           
static char line1[] = "VDI SAMPLER";
static char line2[] = "and C PRIMER";
static char line3[] = "for the";
static char line4[] = "ATARI";
static char line5[] = "520 ST";

v_clrwk(handle);
px=80;

/*---------------------------- DRAW BACKGROUND -------------------------------*/

for (ai=5; ai<100; ai=ai+4)
{
vsl_color(handle, YELLOW);                            /* SET POLYLINE COLOR */
v_arc(handle, 160, 199, ai, 0, 1800);                 /* DRAW ARC */
vsl_color(handle, RED);
v_arc(handle, 0, 100, ai, 2700, 900);
vsl_color(handle, BLUE);
v_arc(handle, 160, 0, ai, 1800, 0);
vsl_color(handle, GREEN);
v_arc(handle, 319, 100, ai, 900, 2700);
}

vswr_mode(handle, 2);                        /* SET WRITE MODE TO TRANSPARENT */
vsf_interior(handle, 2);                     /* SET INTERIOR TYPE TO PATTERN */
vsf_style(handle, 20);                       /* SET INTERIOR FILL STYLE */
vsf_color(handle, MAGENTA);                  /* SET INTERIOR COLOR */
v_circle(handle, 160, 100, 110);             /* DRAW CIRCLE */

/*--------------------------- WRITE HEADER ON SCREEN ------------------------*/


vst_height(handle, 30, &dum1, &dum1, &dum1, &dum1);
vst_color(handle, CYAN);
vst_effects(handle, 4);                         /* SET TEXT EFFECTS TO SKEWED */
v_gtext(handle, px - 12, 50, line1);
v_gtext(handle, px - 22, 80, line2);
vst_height(handle, gr_2, &dum1, &dum1, &dum1, &dum1);
vst_color(handle, 1);
vst_effects(handle, 8);                     /* SET TEXT EFFECTS TO UNDERLINED */
v_gtext(handle, px + 45, 97, line3);
vst_effects(handle, 1);                     /* SET TEXT EFFECTS TO THICKENED */
vst_height(handle, 30, &dum1, &dum1, &dum1, &dum1);
vst_color(handle, LYELLOW);
v_gtext(handle, px + 40, 140, line4);
v_gtext(handle, px + 33, 170, line5);
vst_height(handle, tsz, &dum1, &dum1, &dum1, &dum1);
vst_effects(handle, 0);                     /* RESET TEXT EFFECTS TO NORMAL */
vswr_mode(handle, 1);                       /* RESET WRITE MODE TO REPLACE */

/*------------------------- WAIT FOR KEY PRESS -------------------------------*/

key_wait();


/*--------------------------- CLEAR SCREEN & RESET ---------------------------*/

rgb_in[0] = 1000;
rgb_in[1] = 1000;
rgb_in[2] = 1000;
vs_color(handle, 1, rgb_in);

v_clrwk(handle);
vst_height(handle, gr_2, &dum1, &dum1, &dum1, &dum1);

}

/************************ END INTRODUCTION SCREEN *****************************/


/******************************** MENU ***************************************/


/*--------- WAIT FOR KEYBOARD INPUT, PREFORM APPROPRIATE FUNCTION -----------*/

menu()

{

int     ev_k, chk_kbd = 0;

/*----------------------- CHECK KEYBOARD FOR INPUT ------------------------*/

while ( chk_kbd == 0 )
{
write_menu();

ev_k = evnt_keybd();                                /* GET KEY RESPONSE */

if ( ev_k == aa || ev_k == AA)
{ v_clrwk(handle); text_size(); }
else if ( ev_k == bb || ev_k == BB)
{ v_clrwk(handle); base_line(); }
else if ( ev_k == cc || ev_k == CC)
{ v_clrwk(handle); text_effects(); }
else if ( ev_k == dd || ev_k == DD)
{ v_clrwk(handle); vpline_demo(); }
else if ( ev_k == ee || ev_k == EE)
{ v_clrwk(handle); fill_demo(); }
else if ( ev_k == ff || ev_k == FF)
chk_kbd=1;
else
chk_kbd=0;

}
}

/******************************** END MENU ************************************/



/******************************** WRITE MENU **********************************/

write_menu()
{

px = 75, py = 50;

pxy[0]=319; pxy[1]=199; pxy[2]=0; pxy[3]=0;
vsf_color(handle, BLUE);
vsf_interior(handle, 2);
vsf_style(handle, 21);
vr_recfl(handle, pxy);
vswr_mode(handle, 2);
vst_color(handle, LWHITE);
v_gtext(handle, 25, 20, "ATARI C PROGRAMMING PRIMER");
vst_color(handle, YELLOW);
v_gtext(handle, px, py, "A) TEXTSIZE DEMO");
vst_color(handle, LRED);
v_gtext(handle, px, py + cell_h1 + 2, "B) BASELINE DEMO");
vst_color(handle, MAGENTA);
v_gtext(handle, px, py + (cell_h1 + 2) * 2, "C) TEXT EFFECTS DEMO");
vst_color(handle, LGREEN);
v_gtext(handle, px, py + (cell_h1 + 2) * 3, "D) LINE DRAWING DEMO");
vst_color(handle, RED);
v_gtext(handle, px, py + (cell_h1 + 2) * 4, "E) FILL AREA DEMO");
vst_color(handle, CYAN);
v_gtext(handle, px, py + (cell_h1 + 2) * 5, "F) END DEMO");
vswr_mode(handle, 1);

}

/***************************** END WRITE MENU *********************************/


/***************************** BASE LINE DEMO ********************************/

base_line()
{

int xc, yc, xc1, yc1, zc;
int st_py = 30;

/*-------------------- SETUP HEADER & TEXTSIZE & COLOR ----------------------*/

vst_height( handle, tsz, &dum1, &dum1, &cell_w, &dum1 );
vst_color( handle, LYELLOW );
v_gtext(handle, 60, 10, "TEXT BASELINE DEMONSTRATION");
vst_color( handle, CYAN );
vst_height( handle, gr_2, &dum1, &dum1, &cell_w, &dum1 );

/*----------------------------- BASELINE LOOP -------------------------------*/

for( ai=0; ai < 3601; ai = ai + 900)
{
num1 = (ai - 900 ); zc = (ai - 900);  /* CONVERT INT TO FLOAT */
ftoa( num1, buffer, 0); buffer[5] = 0;  /* PUT INTO STRING */

/*------------------------------ SET BASELINE --------------------------------*/

if (zc < 900) {
xc = prx; yc = st_py; xc1 = xc + (cell_w * 12); yc1 = yc; }
else if (zc < 1800) {
xc = prx - 30; yc = st_py + 150; xc1 = xc; yc1 = yc - (cell_w * 12); }
else if (zc < 2700) {
xc = prx + (cell_w * 17); yc = st_py + 130; xc1 = xc - (cell_w * 12);
yc1 = yc; }
else {
xc = (prx + 50) + (cell_w * 16); yc = (st_py + 150) - (cell_w * 16);
xc1 = xc; yc1 = yc + (cell_w * 12); }

v_gtext( handle, xc, yc, "BASELINE = "); /* PRINT BASELINE COORDINATES */
v_gtext( handle, xc1, yc1, buffer);
vst_rotation( handle, ai);                      /* SET BASELINE COORDINATES */
}

/*-------- RESET TEXTSIZE & COLOR & BASELINE & WAIT FOR KEYPRESS ------------*/


vst_rotation(handle, 0);                       /* RESET BASELINE TO NORMAL */
key_wait();


}

/******************************* END BASE LINE ********************************/


/*********************** TEXT SPECIAL EFFECTS DEMO **************************/

text_effects()
{

int adinc, attrib[10], y_res = 0;

static char title[] = "EFFECT style ";

/*----------------------- TEXT EFFECT DEMO --------------------------------*/

vst_height( handle, tsz, &dum1, &dum1, &dum1, &dum1 );
vst_color(handle, RED );
v_gtext(handle, 70, 10, "TEXT EFFECT DEMONSTRATION" );
vst_color(handle, YELLOW );
y_res = 20; adinc = 2;
vst_height( handle, 15, &dum1, &dum1, &cell_w, &cell_h );

for ( ai = 1; ai < 33; ai = ai + ai)
{

/*--------------------------- SET TEXT EFFECT --------------------------------*/

vst_effects(handle, ai );                      /* SET EFFECT STYLE */
num1 = ai;           /* MAKE ai A FLOAT # */
y_res = y_res + cell_h + adinc;         /* INC Y COORDINATE */
ftoa( num1, buffer, 0 ); buffer[5] = 0;        /* MAKE FLOAT # INTO CHAR STRG */
v_gtext( handle, 100, y_res, title );          /* PRINT title STRING */
v_gtext( handle, (cell_w * 13) + 100, y_res, buffer ); /* PRINT buffer STRING */
}


vst_height( handle, gr_2, &dum1, &dum1, &cell_w, &dum1 );
adinc = adinc + cell_h + y_res;
vst_color(handle, LBLUE );
vst_effects(handle, 9);
v_gtext( handle, 40, adinc, "These fonts ");
vst_effects(handle, 3);
v_gtext( handle, (cell_w * 12) + 40, adinc, "can be used ");
vst_effects(handle, 12);
v_gtext( handle, 50, adinc + cell_h, "in any ");
vst_effects(handle, 0);
v_gtext( handle, (cell_w * 7) + 50, adinc + cell_h, "COMBINATION !!");

/*--------------------------- WAIT FOR KEY -----------------------------------*/

key_wait();

}

/**************************** END TEXT EFFECTS DEMO ***************************/


/************ TEXT SIZE DEMO & FLOATING POINT # TO STRING DEMO **************/

text_size()
{

int     y_res = 0;

static char title[] = "TEXTSIZE =";

/* --------------------------- TEXT SIZE DEMO -------------------------------*/

vst_height( handle, tsz, &dum1, &dum1, &dum1, &dum1 );
vst_color(handle, YELLOW );
v_gtext(handle, 70, 10, "TEXT SIZE DEMONSTRATION" );
vst_color(handle, MAGENTA );
y_res = 20;

for ( ai = 5; ai < 35; ai = ai + 5)
{
/* ---------------------------- SET TEXT HEIGHT  -----------------------------*/
vst_height( handle, ai, &dum1, &dum1, &cell_w, &cell_h );
num1 = ai;           /* MAKE ai A FLOAT # */
y_res = y_res + cell_h;                 /* INC Y COORDINATE */
ftoa( num1, buffer, 0 ); buffer[5] = 0;        /* MAKE FLOAT # INTO CHAR STRG */
v_gtext( handle, 0, y_res, title );            /* PRINT title STRING */
v_gtext( handle, cell_w * 11, y_res, buffer ); /* PRINT buffer STRING */
}

/*--------------------------- WAIT FOR KEY ---------------------------------- */

key_wait();

}

/*************************** END TEXT SIZE DEMO *******************************/


/*************************** V_PLINE DEMO SCREEN ******************************/

vpline_demo()
{

int sx, sy, sx1, sy1, ax, ay, ax1, ay1;
int dt=0, ev_k, inc, cl, cl1, clm, incm1=0;

/*---------------------------- CHOOSE COLOR ----------------------------------*/

px=10; py=40;

while (dt == 0)

{

sx = 0; sy = 199; sx1 = 319; sy1 = 199;
ax = 319; ay = 199; ax1 = 0; ay1 = 199;
cl=15; clm=0;
pxy[0] = 319; pxy[1] = 199; pxy[2] = 0; pxy[3] = 0;

v_clrwk(handle);
vsf_interior(handle, 2);
vsf_color(handle, RED);
vsf_style(handle, 10);
vr_recfl(handle, pxy);
vswr_mode(handle, 2);
vst_height(handle, tsz, &dum1, &dum1, &cell_w, &cell_h);
vst_color(handle, CYAN);
v_gtext(handle, 90, 10, "Line Drawing Demo");
vst_height(handle, gr_2, &dum1, &dum1, &cell_w, &cell_h);
vst_color(handle, GREEN);
v_gtext(handle, 40, 30, "Choose color for demo");
vst_color(handle, BLACK);
v_gtext(handle, px, py + cell_h + 2, "A - ALL Colors");
vst_color(handle, RED);
v_gtext(handle, px + (cell_w * 15), py + cell_h + 2, "B - Red");
vst_color(handle, GREEN);
v_gtext(handle, px, py + (cell_h + 2) * 2, "C - Green");
vst_color(handle, BLUE);
v_gtext(handle, px + (cell_w * 15), py + (cell_h + 2) * 2, "D - Blue");
vst_color(handle, CYAN);
v_gtext(handle, px, py + (cell_h + 2) * 3, "E - Cyan");
vst_color(handle, YELLOW);
v_gtext(handle, px + (cell_w * 15), py + (cell_h + 2) * 3, "F - Yellow");
vst_color(handle, MAGENTA);
v_gtext(handle, px, py + (cell_h + 2) * 4, "G - Magenta");
vst_color(handle, LWHITE);
v_gtext(handle, px + (cell_w * 15), py + (cell_h + 2) * 4, "H - L White");
vst_color(handle, LRED);
v_gtext(handle, px, py + (cell_h + 2) * 5, "I - L Red");
vst_color(handle, LGREEN);
v_gtext(handle, px + (cell_w * 15), py + (cell_h + 2) * 5, "J - L Green");
vst_color(handle, LBLUE);
v_gtext(handle, px, py + (cell_h + 2) * 6, "K - L Blue");
vst_color(handle, LCYAN);
v_gtext(handle, px + (cell_w * 15), py + (cell_h + 2) * 6, "L - L Cyan");
vst_color(handle, LYELLOW);
v_gtext(handle, px, py + (cell_h + 2) * 7, "M - L Yellow");
vst_color(handle, LMAGENTA);
v_gtext(handle, px + (cell_w * 15), py + (cell_h + 2) * 7, "N - L Magenta");
vst_color(handle, GREEN);
v_gtext(handle, px, py + (cell_h + 2) * 8, "Q - QUIT");

while (incm1 == 0)
{
incm1=1;

ev_k=evnt_keybd();

if (ev_k == aa || ev_k == AA)
clm = 1;
else if (ev_k == bb || ev_k == BB)
{ cl = 2; cl1 = 11; }
else if (ev_k == cc || ev_k == CC)
{ cl = 3; cl1 = 14; }
else if (ev_k == dd || ev_k == DD)
{ cl = 4; cl1 = 10; }
else if (ev_k == ee || ev_k == EE)
{ cl = 5; cl1 = 15; }
else if (ev_k == ff || ev_k == FF)
{ cl = 6; cl1 = 12; }
else if (ev_k == gg || ev_k == GG)
{ cl = 7; cl1 = 13; }
else if (ev_k == hh || ev_k == HH)
{ cl = 8; cl1 = 2; }
else if (ev_k == ii || ev_k == II)
{ cl = 10; cl1 = 6; }
else if (ev_k == jj || ev_k == JJ)
{ cl = 11; cl1 = 8; }
else if (ev_k == kk || ev_k == KK)
{ cl = 12; cl1 = 3; }
else if (ev_k == ll || ev_k == LL)
{ cl = 13; cl1 = 7; }
else if (ev_k == mm || ev_k == MM)
{ cl = 14; cl1 = 5; }
else if (ev_k == nn || ev_k == NN)
{ cl = 15; cl1 = 14; }
else if (ev_k == qq || ev_k == QQ)
{ dt = 1; incm1=1; }
else
incm1=0;
}

/*--------------------------- CHOOSE STEP VALUE -----------------------------*/

if (dt == 0)
{ 
v_gtext(handle, px, py + (cell_h + 2) * 10, "Choose Step 1 - 9");
incm1=0;

while (incm1 == 0)
{
incm1=1;

ev_k=evnt_keybd();

if (ev_k == ONE)
inc=1;
else if (ev_k == TWO)
inc=2;
else if (ev_k == THREE)
inc=3;
else if (ev_k == FOUR)
inc=4;
else if (ev_k == FIVE)
inc=5;
else if (ev_k == SIX)
inc=6;
else if (ev_k == SEVEN)
inc=7;
else if (ev_k == EIGHT)
inc=8;
else if (ev_k == NINE)
inc=9;
else
incm1=0;
}
}

/*---------------------------- DRAW LINES -----------------------------------*/

if (dt == 0)
{
incm1=0;
v_clrwk(handle);
vswr_mode(handle, 1);

while (ay > 0)
{
vsl_color(handle, cl);                           /* SET LINE COLOR */
pxy[0]=sx; pxy[1]=sy; pxy[2]=ax; pxy[3]=ay;      /* SET LINE COORDINATES */
v_pline(handle, 2, pxy);                         /* DRAW LINE */
if (clm != 1)
vsl_color(handle, cl1); 
pxy[0]=sx1; pxy[1]=sy1; pxy[2]=ax1; pxy[3]=ay1;
v_pline(handle, 2, pxy);
ay = ay - inc; ay1 = ay;

if (clm == 1)
{
cl--;
if (cl < 1)
cl = 15;
}
}

while (ax > 160)
{
vsl_color(handle, cl);
pxy[0]=sx; pxy[1]=sy; pxy[2]=ax; pxy[3]=ay;
v_pline(handle, 2, pxy);
if (clm != 1)
vsl_color(handle, cl1);
pxy[0]=sx1; pxy[1]=sy1; pxy[2]=ax1; pxy[3]=ay1;
v_pline(handle, 2, pxy);
ax = ax - inc; ax1 = ax1 + inc;

if (clm == 1)
{
cl--;
if (cl < 1)
cl = 15;
}
}

/*------------------------- WAIT FOR KEYPRESS -------------------------------*/

key_wait();
}
}
v_clrwk(handle);
vswr_mode(handle, 1);
}

/************************** END V_PLINE DEMO SCREEN ***************************/


/***************************** FILL PATTERN DEMO *****************************/

fill_demo()
{

int inc = 0, stls = 0, tnm = 24, type = 2;
int ev_k, much;

/* --------------------- WRITE FILL INTRO SCREEN ---------------------------*/

px=90, py=80;
pxy[0]=319; pxy[1]=199; pxy[2]=0; pxy[3]=0;
v_clrwk(handle);
vsf_interior(handle, 2);
vsf_color(handle, BLUE);
vsf_style(handle, 13);
vr_recfl(handle, pxy);
vswr_mode(handle, 2);
vst_height(handle, tsz, &dum1, &dum1, &cell_w, &dum1);
vst_color(handle, YELLOW);
v_gtext(handle, 100, 10, "FILL AREA DEMO");
vst_height(handle, gr_2, &dum1, &dum1, &cell_w, &cell_h);
vst_color(handle, RED);
v_gtext(handle, px, py, "A");
vst_color(handle, CYAN);
v_gtext(handle, cell_w + px, py, "utomatic step");
vst_color(handle, RED);
v_gtext(handle, px, py + (cell_h + 2), "M");
vst_color(handle, CYAN);
v_gtext(handle, cell_w  + px, py + (cell_h + 2), "anual step");
vst_color(handle, RED);
v_gtext(handle, px, py + (cell_h + 2) * 2, "Q");
vst_color(handle, CYAN);
v_gtext(handle, cell_w + px, py + (cell_h + 2) * 2, "uit");

while (stls == 0)
{

ev_k=evnt_keybd();
stls=1;

if (ev_k == aa || ev_k == AA)
much=1;
else if (ev_k == mm || ev_k == MM)
much=2;
else if (ev_k == qq || ev_k == QQ)
much=3;
else 
stls=0;
}
v_clrwk(handle);

if (much == 1)
{
for (stls=1; stls < 37; ++stls)
{
++inc;
if (inc > 24)
{ type = 3; inc = 1; tnm = 12; }
do_screen(type, inc, tnm);                  /* THIS IS HOW TO PASS PARAMETERS */
evnt_timer(2000, 0);                        /* WAIT FOR 2 SECONDS */
} 
key_wait();
}

if (much == 2)
{
type=2; inc=1; tnm=24;

while (much != 3)
{

do_screen(type, inc, tnm);
stls=0;

vswr_mode(handle, 1);
vst_color(handle, GREEN);
v_gtext(handle, 10, 190, "N");
vst_color(handle, LWHITE);
v_gtext(handle, 10 + cell_w, 190, "ext");
vst_color(handle, GREEN);
v_gtext(handle, 10 + (cell_w * 6), 190, "P");
vst_color(handle, LWHITE);
v_gtext(handle, 10 + (cell_w * 7), 190, "revious");
vst_color(handle, GREEN);
v_gtext(handle, 10 + (cell_w * 15), 190, "Q");
vst_color(handle, LWHITE);
v_gtext(handle, 10 + (cell_w * 16), 190, "uit");

while (stls == 0)
{
stls=1;

ev_k=evnt_keybd();

if (ev_k == nn || ev_k == NN)
++inc;
else if (ev_k == pp || ev_k == PP)
--inc;
else if (ev_k == qq || ev_k == QQ)
much=3;
else 
stls=0;
}

if ( much != 3 )
{
if (inc < 1 && type == 2)
{ inc=12; type=3; tnm=12; }
if (inc < 1 && type == 3)
{ inc=24; type=2; tnm=24; }
if (inc > 12 && type == 3)
{ inc=1; type=2; tnm=24; }
if (inc > 24)
{ inc=1; type=3; tnm=12; }

}
}
}
v_clrwk(handle);
vswr_mode(handle, 1);

}

/*************************** END FILL PATTERN DEMO ****************************/


/***************************** DO SCREEN ROUTINE ******************************/

do_screen(type, inc, tnm)                /* THIS IS HOW TO RECEIVE PARAMETERS */

int type, inc, tnm;
{

int cl;

num1 = inc;
ftoa ( num1, buffer, 0 ); buffer[5] = 0;

vswr_mode(handle, 1);
vst_height(handle, gr_2, &dum1, &dum1, &cell_w, &dum1);
vst_color(handle, YELLOW);

if (type == 2)
v_gtext(handle, 10, 15, "PATTERN");
else
v_gtext(handle, 10, 15, "HATCH  ");

vst_color(handle, LGREEN);
v_gtext(handle, (cell_w * 9) + 10, 15, "Style");
v_gtext(handle, (cell_w * 15) + 10, 15, buffer);
v_gtext(handle, (cell_w * 18) + 10, 15, "of ");
num1 = tnm;
ftoa ( num1, buffer, 0 ); buffer[5] = 0;
v_gtext(handle, 240, 15, buffer);

/*-------------------------------- DRAW BOXES --------------------------------*/
                                         /* - TOP BOX - */
vsf_interior(handle, 1);
cl=BLUE;
pxy[0] = 319; pxy[1] = 70;
pxy[2] = 0; pxy[3] = 20;
do_box(cl, pxy);
                                         /* - BOTTOM BOX - */
cl=CYAN;
pxy[0] = 319; pxy[1] = 180;
pxy[2] = 0; pxy[3] = 130;
do_box(cl, pxy);
                                         /* - LEFT BOX - */
cl=RED;
pxy[0] = 100; pxy[1] = 130;
pxy[2] = 0; pxy[3] = 70;
do_box(cl, pxy);
                                         /* - RIGHT BOX - */
cl=GREEN;
pxy[0] = 319; pxy[1] = 130;
pxy[2] = 220; pxy[3] = 70;
do_box(cl, pxy);
                                         /* - CENTER BOX - */
cl=0;
pxy[0] = 220; pxy[1] = 130;
pxy[2] = 100; pxy[3] = 70;
do_box(cl, pxy);

/*----------------------------- DRAW OVERLAYS --------------------------------*/

vswr_mode(handle, 2);
                                         /* - TOP OVERLAY - */
cl=LCYAN;
set_ovl(type, inc, cl);
v_ellipse(handle, 160, 45, 155, 20);
                                         /* - BOTTOM OVERLAY - */
cl=BLUE;
set_ovl(type, inc, cl);
v_ellipse(handle, 160, 155, 155, 20);
                                         /* - LEFT OVERLAY - */
cl=YELLOW;
set_ovl(type, inc, cl);
v_ellipse(handle, 50, 100, 45, 25);
                                         /* - RIGHT OVERLAY - */
cl=RED;
set_ovl(type, inc, cl);
v_ellipse(handle, 270, 100, 45, 25);
                                         /* - CENTER OVERLAY - */
cl=LMAGENTA;
set_ovl(type, inc, cl);
v_ellipse(handle, 160, 100, 45, 25);
}

/*************************** END DO SCREEN ROUTINE ****************************/


/****************************** DRAW BOX ROUTINE ******************************/

do_box(cl, pxy)
int cl, pxy[4];

{
vsf_color(handle, cl);
v_rfbox(handle, pxy);
}

/**************************** END DRAW BOX ROUTINE ****************************/

/***************************** DO OVERLAY ROUTINE *****************************/

set_ovl(type, inc, cl)
int type, inc, cl;

{
vsf_interior(handle, type);
vsf_style(handle, inc);
vsf_color(handle, cl);
}

/*************************** END DO OVERLAY ROUTINE ***************************/


dddddddddddddddddddddddddddd