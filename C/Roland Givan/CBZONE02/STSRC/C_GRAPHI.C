#include "c_includes.h"
/*
 * cbzone_graphics.c
 *  -- Todd W Mummert, December 1990, CMU
 *
 * ATARI Mods - Roland Givan Summer/Autumn 1993
 *
 * RCS Info
 *  $Header: c_graphics.c,v 1.1 91/01/12 02:03:33 mummert Locked $
 */

#ifndef ATARI
Font controlfont, titlefont, generalfont;
#else
int controlfont, titlefont, generalfont;
extern char shot[];
extern char siren[];
extern void set_front(void);
extern void set_back(void);
#endif

void message(number, bell)
     int number;
     Bool bell;
{
  static int xpt = 70;
  static int ypt[] = {507, 567, 627};
  static char* messages[] = {"ENEMY TANK IN FIRING ARC",
                               "MOVEMENT BLOCKED BY OBJECT",
                               "SALVO FIRED BY ENEMY TANK"};
  int ind;
  char text[41];

#ifdef ATARI
  set_front();
#endif  
  ind = abs(number) - 1;
#ifndef ATARI
  if (number < 0) 
    sprintf(text,"%-40s"," ");
  else
    sprintf(text,"%-40s",messages[ind]);
#else
/* These strings don't need to be so long as they interfere
   with the scanner. Reduced to 30 */
  if (number < 0) 
    sprintf(text,"%-30s"," ");
  else
    sprintf(text,"%-30s",messages[ind]);
#endif
  gprsetclippingactive(False);
  printstring(xpt, ypt[ind], text, 40);
  gprsetclippingactive(True);
#ifndef ATARI
  if (bell)
    tonetime();
#else
  if (bell){
	if (ind == 2){
	  sound(shot);
	}else{
	  tonetime();
	}
  }
  set_back();
#endif
}

void screeninit()
{
#ifndef ATARI
  controlfont = gprloadfontfile(CONTROLFONT);
  titlefont = gprloadfontfile(TITLEFONT);
  generalfont = gprloadfontfile(GENERALFONT);
#else
	controlfont=titlefont=generalfont=1;
#endif
  staticscreen();
}

void staticscreen()
{
  static int window[2][2] = {70, 75, 860, 350};
  int pt[2], radius;
#ifdef ATARI
  char text[40];
#else
  char text[30];
#endif
  static short line[] = {58, 66, 66, 58, 56, 438, 68, 438, 938, 56,
                           938, 68, 942, 442, 934, 434, 56, 472, 68, 472,
                           934, 468, 942, 476, 58, 644, 66, 652, 932, 648,
                           944, 648};
  static short scan[] = {500, 495, 500, 500, 500, 625, 500, 620, 435, 560,
                           440, 560, 565, 560, 560, 560};
  static short scrn[] = {75, 64, 925, 64, 936, 75, 936, 425, 925, 436,
                           75, 436, 64, 425, 64, 75, 75, 64};
#ifdef ATARI
	set_front();
#endif
  gprsetclippingactive(False);
  gprsettextbackgroundvalue(opt->cpi[COLOR_BG]);
  gprsetdrawvalue(opt->cpi[COLOR_FG]);
  gprsettextvalue(opt->cpi[COLOR_TEXT]);
  drawrectangle(50, 50, 900, 400);      /* draw the outer top rectangle */
  drawrectangle(53, 53, 894, 394);      /*          inner top           */
  drawrectangle(50, 460, 900, 200);     /*          outer bottom        */
  drawrectangle(53, 463, 894, 194);     /*          inner bottom        */
  polyline(scrn, 9);                    /*       inner top frame        */
  pt[0] = 62;
  pt[1] = 62;
  radius = 6;
  gprcircle(pt, radius);                /* now let's draw some screws   */
  pt[0] = 938;
  gprcircle(pt, radius);
  pt[1] = 438;
  gprcircle(pt, radius);
  pt[0] = 62;
  gprcircle(pt, radius);
  pt[0] = 62;
  pt[1] = 472;
  gprcircle(pt, radius);
  pt[0] = 938;
  gprcircle(pt, radius);
  pt[1] = 648;
  gprcircle(pt, radius);
  pt[0] = 62;
  gprcircle(pt, radius);
  multiline(line, 8);                   /*        now the slots         */
  pt[0] = 500;
  pt[1] = 560;
  radius = 65;
  gprsetdrawvalue(opt->cpi[COLOR_SCANNER]);
  gprcircle(pt, radius);                /*      radar screen            */
  radius = 64;
  gprcircle(pt, radius);
  multiline(scan, 4);
  pt[0] = 855;
  pt[1] = 560;
  radius = 65;
  gprsetdrawvalue(opt->cpi[COLOR_JOYSTICK]);
  gprcircle(pt, radius);                /*      joystick screen         */
  radius = 64;
  gprcircle(pt, radius);
  gprsetdrawvalue(opt->cpi[COLOR_TEXT]);
#ifndef ATARI
  drawrectangle(590, 570, 55, 30);      /*      missile warning         */
  drawrectangle(655, 570, 55, 30);      /*      lander warning          */
#else
  drawrectangle(590, 570, 90, 30);      /*      missile warning         */
  drawrectangle(684, 570, 90, 30);      /*      lander warning          */
#endif
  drawrectangle(590, 520, 120, 30);     /*         score box            */
  gprsettextfont(titlefont);
#ifndef ATARI
  strcpy(text, "BATTLEZONE V2.0c");
#else
  strcpy(text, "BATTLEZONE V2.0c - ATARI v0.2 RMG 1993");
#endif
  printstring(50, 45, text, strlen(text));
  gprsettextvalue(opt->cpi[COLOR_JOYSTICK]);
  strcpy(text, "F");                    /* directions for the joystick  */
  printstring(850, 503, text, 1);
  strcpy(text, "B");
  printstring(850, 630, text, 1);
  strcpy(text, "R");
  printstring(913, 570, text, 1);
  strcpy(text, "L");
  printstring(785, 570, text, 1);
  gprsettextvalue(opt->cpi[COLOR_TEXT]);
  gprsettextfont(controlfont);
#ifndef ATARI
  strcpy(text, "Missile");              /*      warning messages        */
  printstring(595, 590, text, 7);
  strcpy(text, "Lander");
  printstring(664, 590, text, 6);
#endif
  strcpy(text, "H");                    /*      switch positions        */
  printstring(920, 608, text, 1);
  strcpy(text, "L");
  printstring(920, 642, text, 1);
  gprsetclipwindow(window);             /* define the playing field     */
  gprsettextfont(generalfont);
  pt[0] = 500;
  pt[1] = 355;
  gprsetcursorposition(pt);
  gprsetclippingactive(True);
#ifdef ATARI
	set_back();
#endif
}

void updatedisplay (missile, lander, score, numleft, sens, reset)
     Bool missile, lander, sens, reset;
     int score, numleft;
{
  char text[11];
  static Bool flasher[] = {False, False};
  static int currentnumleft = 0;
  static int currentscore = -1;
  static int bswitch[] = {918, 612};
#ifndef ATARI	/* RMG 31/10/93 */
  static int wind1[][2] = {591, 571, 54, 29};
  static int wind2[][2] = {656, 571, 54, 29};
#endif
  static int origin[][2] = {733, 493, 733, 533, 733, 573, 733, 613};
  static Bool currentsens = True;

#ifdef ATARI
	set_front();
#endif
  gprsetclippingactive(False);
  if (reset) {
    flasher[0] = flasher[1] = False;
    currentsens = True;
  }
#ifndef ATARI  
  if ((flasher[0] && !missile) ||       /* change the missile warning */
      (!flasher[0] && missile)) {
    flasher[0] = missile;
    bitblt(wind1);
  }

  if ((flasher[1] && !lander) ||        /* change the lander warning */
      (!flasher[1] && lander)) {
    flasher[1] = lander;
    bitblt(wind2);
  }
#else
/* Quick fix for the Atari */
  if (flasher[0] && !missile){        /* change the lander warning */
    printstring(594, 590, "       ", 6);
    flasher[0] = False;
  }
  if (!flasher[0] && missile){
    printstring(594, 590, "Missile", 6);
    flasher[0] = True;
  }
  if (flasher[1] && !lander){        /* change the lander warning */
    printstring(690, 590, "      ", 6);
    flasher[1] = False;
  }
  if (!flasher[1] && lander){
    printstring(690, 590, "Lander", 6);
    flasher[1] = True;
    sound(siren);
  }
#endif
  if (score != currentscore) {          /*     change the score      */
    currentscore = score;
#ifndef ATARI
    sprintf(text,"%10d",score);
    printstring(608, 542, text, strlen(text));
#else
    sprintf(text,"%8d",score);
    printstring(596, 542, text, strlen(text));
#endif
  }
  if (numleft < currentnumleft && numleft >= 0)    /* remove tank(s) */
    while (numleft != currentnumleft)
      removepixmap(4, origin[--currentnumleft]);
  if (numleft > currentnumleft)                    /*  add tank(s)   */
    while (numleft != currentnumleft && currentnumleft < 4)
      putpixmap(4, origin[currentnumleft++]);
  if (sens && !currentsens) {           /* change to high gear       */
    putpixmap(2, bswitch);
    currentsens = sens;
  }
  else if (!sens && currentsens) {      /* change to low gear        */
    putpixmap(3, bswitch);
    currentsens = sens;
  }
  gprsetclippingactive(True);
#ifdef ATARI
set_back();
#endif
}

void joystick (position, sens, pl)
     int* position;
     Genericp pl;
     Bool sens;
{
  static float sscale[] = {0.06, 0.03};
  static float rscale[] = {0.00013, 0.000065};
  static int destorigin[] = {845, 550};
  static short stick[8] = {0};
  static Bool first = True;
  static Bool draw = True;
  int ind;
  float scrot, sctot, scale, xl, yl, tl, xoff, yoff;

#ifdef ATARI
set_front();
#endif
  if (sens)
    ind = 0;
  else
    ind = 1;
  pl->speed = -(position[1] - 355.0) * sscale[ind];
  pl->rotate = (position[0] - 500.0) * rscale[ind];
  if (fabs(pl->speed) > 10.0)
    pl->speed = sign(10.0, pl->speed);
  if (fabs(pl->rotate) > 0.030)
    pl->rotate = sign(0.030, pl->rotate);
  scrot = pl->rotate * 10.0 / 0.030;
  sctot = sqrt(pl->speed*pl->speed + scrot*scrot);
  if (sctot > 10.0) {
    scale = 10.0 / sctot;
    pl->speed *= scale;
    pl->rotate *= scale;
  }
  if (draw) {
    gprsetclippingactive(False);
    if (!first) {
      gprsetdrawvalue(opt->cpi[COLOR_BG]);
      removepixmap(1, destorigin);
      multiline(stick, 2);
    }
    else
      first = False;
    destorigin[0] =  35.0 * (pl->rotate / 0.03) + 845.0;
    destorigin[1] = -35.0 * (pl->speed  / 10.0)  + 550.0;
    putpixmap(1, destorigin);
    xl = pl->rotate / 0.030;
    yl = pl->speed / 10.0;
    tl = sqrt(xl*xl + yl*yl);
    if (tl > 0.05) {
      yoff = xl / tl * 9.0;
      xoff = yl / tl * 9.0;
    }
    else {
      yoff = 0.0;
      xoff = 0.0;
    }
    stick[0] = stick[4] = 855;
    stick[2] = destorigin[0] + 10 + xoff / 2;
    stick[6] = destorigin[0] + 10 - xoff / 2;
    stick[1] = stick[5] = 560;
    stick[3] = destorigin[1] + 10 + yoff / 2;;
    stick[7] = destorigin[1] + 10 - yoff / 2;
    gprsetdrawvalue(opt->cpi[COLOR_JOYSTICK]);
    multiline(stick, 2);
    gprsetclippingactive(True);
  }
  draw = !draw;
  pl->rotate = -pl->rotate;
#ifdef ATARI
set_back();
#endif
}

/*
 * scanner
 *
 * draws the radar scan...
 */
 void scanner(o)
     Genericp o;
{
  static float scale = 0.03;
  static XSegment scanline[] = {500, 560, 500, 560};
  static Bool init = True;
  static XSegment* dot;
  static float ca = 1.0;        /* keep track of where the scanner line */
  static float sa = 0.0;        /* is currently positioned */
  static float sda = 0.087156;
  static float cda = 0.996195;
  static int ind = 0;           /* number of enemies last on scanner */
  float temp;
  Genericp g;
  XSegment* nextdot;
  XSegment* curdot;

#ifdef ATARI
set_front();
#endif
  if (init) {
    dot = (XSegment*) malloc(sizeof(XSegment)*2*opt->mobjects);
    if (dot == NULL) {
      printf("Malloc failed...too many objects?\n");
#ifdef ATARI
      gem_close_down();
#endif
      exit(1);
    }
    init = False;
  }

  gprsetclippingactive(False);
  gprsetdrawvalue(opt->cpi[COLOR_BG]);
#ifdef ATARI
  if (!opt->fast)
#endif
  multiline(scanline, 1);               /*       erase scan line       */
  if (ind)                              /* erase enemies, if necessary */
    multiline(dot, ind);
#ifdef ATARI
if (!opt->fast){
#endif
  temp = ca;
  ca = ca * cda - sa * sda;
  sa = sa * cda + sda * temp;
  scanline->x2 = 60.0 * ca + 500;
  scanline->y2 = 60.0 * sa + 560;
  gprsetdrawvalue(opt->cpi[COLOR_SCANNER]);
  multiline(scanline, 1);               /*     draw scanline           */
#ifdef ATARI
}else{
  gprsetdrawvalue(opt->cpi[COLOR_SCANNER]);
}
#endif
  ind = 0;
  curdot = dot;
  for (g=o+opt->estart; g<o+opt->lstart; g++)
    if (g->attr & IS_ALIVE && g->range <= 2000.0 && g->range != 0.0) {
      nextdot = curdot + 1;
      nextdot->x1 = curdot->x1 = 500 + g->prox * scale - 1;
      nextdot->y2 = curdot->y1 = 560 - g->proy * scale + 1;
      nextdot->x2 = curdot->x2 = curdot->x1 + 2;
      nextdot->y1 = curdot->y2 = curdot->y1 - 2;
      ind += 2;
      curdot += 2;
    }
  if (ind){
    multiline(dot, ind);                /* draw enemies, if necessary  */
  }
  gprsetclippingactive(True);
#ifdef ATARI
set_back();
#endif
}

void xhairs (aligned)
     Bool aligned;
{
  static Bool last = False;
  static short pt1[] = {500, 215, 500, 235, 500, 285, 500, 305, 475, 240,
                          475, 235, 475, 235, 525, 235, 525, 235, 525, 240,
                          475, 280, 475, 285, 475, 285, 525, 285, 525, 285,
                          525, 280};
  static short pt2[] = {500, 215, 500, 235, 500, 285, 500, 305, 475, 245,
                          500, 235, 500, 235, 525, 245, 475, 275, 500, 285,
                          500, 285, 525, 275};
#ifndef ATARI
  static Bool draw = True;
  if (draw) {
#endif
    if (aligned) {
      if (!last) {
#ifndef ATARI
        gprsetdrawvalue(opt->cpi[COLOR_BG]);       /* erase the old */
        multiline(pt1, 8);
#endif
        last = True;
      }
      gprsetdrawvalue(opt->cpi[COLOR_XHAIR]);        /* draw the new */
      multiline(pt2, 6);
    }
    else {
      if (last) {
#ifndef ATARI
        gprsetdrawvalue(opt->cpi[COLOR_BG]);       /* erase the old */
        multiline(pt2, 6);
#endif
        last = False;
      }
      gprsetdrawvalue(opt->cpi[COLOR_XHAIR]);        /* draw the new */
      multiline(pt1, 8);
    }
#ifndef ATARI
  }
  draw = !draw;
#endif
}

void drawhorizon(azm)
     float azm;
{

  static short horizon[] = {500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240,
                              500, 240, 500, 240, 500, 240, 500, 240};
  static int number = 0;
  static float rdc = 0.01745329251;
  static float scale = 15.0;
  static int numclust[] = {8, 12, 10, 12, 10, 10};
  static int clustux[][12] = {150, 140, 150, 60, 85, -100, -50, -150, 0, 0,
                                0, 0, 150, 50, 75, 0, 0, 7, 0, -40, 0, -110,
                                -25, -150, 150, 115, 115, 105, 115, -10, 0,
                                -125, -85, -150, 0, 0, 150, 130, 150, 10, 25,
                                -35, -35, 0, -35, -140, -110, -150, 150, -10,
                                25, -70, -50, -125, -125, -100, -125, -150,
                                0, 0, 150, 100, 140, 0, 0, -30, 0, -120, -60,
                                -150, 0, 0};
  static int clustuy[][12] = {160, 220, 160, 250, 225, 245, 250, 240, 0, 0, 0,
                                0, 240, 227, 245, 190, 190, 215, 190, 225, 190,
                                213, 240, 200, 200, 189, 189, 225, 189, 244,
                                250, 165, 213, 135, 0, 0, 135, 200, 135, 210,
                                225, 165, 165, 230, 165, 228, 210, 215, 215,
                                217, 230, 195, 210, 150, 150, 210, 150, 173,
                                0, 0, 173, 209, 225, 170, 170, 225, 170, 230,
                                200, 160, 0, 0};
  static int pt[2];
  static Bool moon = False;

  float center, xoff;
  float deg, degmin, degmax;
  int indmin, indmax, i, i1, j;
  Bool flag1, flag2;
  short* current;

#ifdef ATARI
if (!opt->fast){
#endif
#ifndef ATARI
  gprsetdrawvalue(opt->cpi[COLOR_BG]);
  multiline(horizon, number);           /* erase horizon */
#endif
	
  if (moon)
    removepixmap(0, pt);                /* erase moon    */
  gprsetdrawvalue(opt->cpi[COLOR_HORIZON]);
  deg = azm / rdc;
  if (deg >= 360.0)
    deg -= 360.0;
  degmin = deg - 30.0;
  degmax = deg + 30.0;
  flag1 = False;
  flag2 = False;
  if (degmin < 0.0) {
    degmin += 360.0;
    flag1 = True;
  }
  if (degmax >= 360.0) {
    degmax -= 360.0;
    flag2 = True;
  }
  indmin = (int) (degmin / 20.0);
  indmax = (int) (degmax / 20.0) + 1;
  number = 0;
  current = horizon;
  if (!flag1 && !flag2){
    for (i=indmin; i<indmax; i++) {
      center = 10.0 + i * 20.0;
      xoff = (deg - center) * scale + 500.0;
      i1 = i % 6;
      for (j= 0; j<numclust[i1]; j++){
        *current++ = clustux[i1][j] + xoff;
        *current++ = clustuy[i1][j];
        number++;
      }
    }
  }else if (flag1) {
    for (i= indmin; i<18; i++) {
      center = 10.0 + i * 20.0;
      xoff = (360.0 + deg - center) * scale + 500.0;
      i1 = i % 6;
      for (j=0; j<numclust[i1]; j++) {
        *current++ = clustux[i1][j] + xoff;
        *current++ = clustuy[i1][j];
        number++;
      }
    }
    for (i=0; i<indmax; i++) {
      center = 10.0 + i * 20.0;
      xoff = (deg - center) * scale + 500.0;
      i1 = i % 6;
      for (j=0; j<numclust[i1]; j++) {
        *current++ = clustux[i1][j] + xoff;
        *current++ = clustuy[i1][j];
        number++;
      }
    }
  }
  else {
    for (i=indmin; i<18; i++) {
      center = 10.0 + i * 20.0;
      xoff = (deg - center) * scale + 500.0;
      i1 = i % 6;
      for (j=0; j<numclust[i1]; j++) {
        *current++ = clustux[i1][j] + xoff;
        *current++ = clustuy[i1][j];
        number++;
      }
    }
    for (i=0; i<indmax; i++) {
      center = 10.0 + i * 20.0;
      xoff = (deg - 360.0 - center) * scale + 500.0;
      i1 = i % 6;
      for (j=0; j<numclust[i1]; j++) {
        *current++ = clustux[i1][j] + xoff;
        *current++ = clustuy[i1][j];
        number++;
      }
    }
  }
  number >>= 1;
  multiline(horizon, number);           /* draw horizon */
  if (deg <= 360.0 && deg >= 270.0) {
    moon = True;
    pt[0] = 500 + (deg - 315.0) * scale - 20;
    pt[1] = 105 - 20;
    putpixmap(0, pt);                   /* draw moon    */
  }
  else
    moon = False;
#ifdef ATARI
}
#endif
}

void drawcracks()
{
  static short pt[] = {190, 75, 270, 175, 270, 175, 230, 265, 240, 243,
                         330, 290, 310, 280, 390, 235, 370, 246, 380, 195,
                         200, 425, 290, 365, 270, 378, 300, 325, 630, 425,
                         560, 335, 580, 361, 626, 295, 570, 348, 510, 355,
                         520, 354, 490, 275, 500, 301, 440, 290, 810, 75,
                         720, 125, 720, 125, 695, 205, 700, 200, 590, 210,
                         630, 206, 620, 256, 710, 157, 780, 245, 770, 232,
                         730, 305, 740, 287, 760, 315};

  gprsetdrawvalue(opt->cpi[COLOR_CRACKS]);
  multiline(pt, 19);                    /* draw cracks */
}

void clearscreen ()
{
  static int destorigin[] = {70, 75};
  static int window[][2] = {70, 75, 860, 350};

  clearrectangle(window, destorigin);        /* erase the main viewscreen */
}
