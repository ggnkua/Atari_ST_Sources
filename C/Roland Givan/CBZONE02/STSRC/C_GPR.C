#include "c_includes.h"
/*
 * cbzone_gpr.c
 *  -- Todd W Mummert, December 1990, CMU
 *
 * ATARI Mods - Roland Givan Summer/Autumn/Winter 1993
 *
 * RCS info
 *  $Header: c_gpr.c,v 1.1 91/01/12 02:03:32 mummert Locked $
 *
 * emulate gpr/ftn on top of X11.
 *
 * I don't know who originally wrote this emulation routine, but
 * I've seriously changed it anyway.  Therefore, it should not
 * be used with any expectation that it will do anything similiar
 * to the original gpr routines.
 * Almost all of the routines have had their arguments shortened.
 * And why bother returning status when it's always the same.  Most
 * importantly I removed the mallocs that were in polyline and
 * mulitiine.
 *
 * Added support for window managers, iconification, color, etc...
 * Now, it's basically a file full of one line functions...except
 * for the event handling and initialization.
 *
 * let's define how we are going to use the GC's...
 * Erase GC...both foreground and background the color of the game
 *   background...
 * Text GC...foreground is red...as all text is currently
 * Draw GC...will be changed often...usually just the color
 * BitBlt GC...it will handle the printing of the
 *           lander/missile warning boxes after they are initially
 *           placed.
 */

#ifndef ATARI
#include "bitmaps/moon.bits"
#include "bitmaps/joystick.bits"
#include "bitmaps/hswitch.bits"
#include "bitmaps/lswitch.bits"
#include "bitmaps/tank.bits"
#include "bitmaps/cursor.bits"
#include "bitmaps/cshape.bits"


typedef struct {
  char name[14];                /* the color will be stored as  */
} Colorname;                    /*      #RRRRGGGGBBBB           */

typedef struct {
  int width;
  int height;
  char* bits;
  Pixmap p;
  unsigned int color;
} Bmap;

Display *d;
Window w, root;
GC BitBltGC, DrawGC, TextGC, EraseGC;
XRectangle clipr;                     /* defines the main viewscreen       */
Colormap cmap, dcmap;                 /* private & default colormaps       */
int ufc, unfc;                        /* number of fading/nonfading colors */
int cw, cr;                           /* number of colors wanted/received  */
Screen* screen;
Pixel* pixels = NULL;                 /* the actual pixel values we obtain */
Colorname* bases = NULL;              /* names of the base colors          */
Colorname* fcnames = NULL;            /* names of the fading colors        */
int screen_num;
#endif

#ifdef ATARI
static short q;					/* fornext counter */
static GEM_SIZE clipr[4];				/* clipping rectangle	*/
static GEM_SIZE pxarray[100];			/* coords array */
static char last = 'R';
extern char ping[30];
#endif

int wid, hei, depth;
Position_t mouse_posn;

#ifndef ATARI
#define NUMPIXMAPS 5
Bmap bmaps[NUMPIXMAPS] = {
  moon_width, moon_height, moon_bits, None, COLOR_MOON,
  joystick_width, joystick_height, joystick_bits, None, COLOR_JOYSTICK,
  hswitch_width, hswitch_height, hswitch_bits, None, COLOR_TEXT,
  lswitch_width, lswitch_height, lswitch_bits, None, COLOR_TEXT,
  tank_width, tank_height, tank_bits, None, COLOR_TEXT
  };
#endif

#ifndef ATARI
void grabpointer()
{
  while (XGrabPointer(d, w, False,
                      ButtonPressMask|ButtonReleaseMask|PointerMotionMask,
                      GrabModeAsync,
                      GrabModeAsync,
                      w,
                      None,
                      CurrentTime) != GrabSuccess);
}
#endif

#ifndef ATARI
void ungrabpointer()
{
  XUngrabPointer(d, CurrentTime);
}
#endif

void setmonomap()
{
  int i;

#ifndef ATARI  
  cmap = dcmap;
  pixels = (Pixel*) malloc(2 * sizeof(Pixel));
  opt->cpi[COLOR_BG] = 0;
  pixels[0] = BlackPixelOfScreen(screen);
  opt->cpi[COLOR_FG] = 1;
  pixels[1] = WhitePixelOfScreen(screen);
  opt->fading_colors = 1;
  for (i=2; i<MAX_COLORS; i++)
    opt->cpi[i] = 1;
  cw = cr = 2;
#else
  opt->fading_colors = 1;
  for (i=0; i<MAX_COLORS; i++){
    opt->cpi[i] = 1;
  }
  opt->cpi[COLOR_BG] = 0;
  opt->cpi[COLOR_FG] = 1;
#endif
}

#ifndef ATARI
void createfadedcolors()
{
  XColor color;
  int i, j;
  float factor;
  int num = 0;

  if (fcnames != NULL)
    free(fcnames);
  fcnames =
    (Colorname *) malloc(ufc*opt->fading_colors*sizeof(Colorname));
  for (i=LF_COLOR; i>LN_COLOR; i--)
    if (opt->cpi[i] == i) {
      XParseColor(d, dcmap, bases[i].name, &color);
      sprintf(fcnames[num++].name, "#%04x%04x%04x",
              color.red, color.green, color.blue);
      for (j=1; j<opt->fading_colors; j++) {
        factor = 1.0 - 0.5*j/(opt->fading_colors-1);
        sprintf(fcnames[num++].name, "#%04x%04x%04x",
                (int) (factor*color.red), (int) (factor*color.green),
                (int) (factor*color.blue));
      }
    }
}
#endif

#ifndef ATARI
void setcoloroptvalues()
{
  int i;
  int num = 0;
  
  for (i=L_COLOR; i>=0; i--)
    if (opt->cpi[i] == i) {
      opt->cpi[i] = num;
      if (i>LN_COLOR)
        num += opt->fading_colors;
      else
        num++;
    }
    else
      opt->cpi[i] = opt->cpi[opt->cpi[i]];
}
#endif

#ifndef ATARI
void standardizecolors(v)
     Visual* v;
{
  XColor color;
  int i;
  int num = 0;

  if (bases != NULL)
    free(bases);
  bases = (Colorname *) malloc(MAX_COLORS*sizeof(Colorname));
  for (i=0; i<MAX_COLORS; i++) {
    XParseColor(d, dcmap, opt->cname[i], &color);
    if (v->class == StaticGray || v->class == GrayScale)
      color.red = color.green = color.blue = color.red > color.green ?
        (color.red > color.blue ? color.red : color.blue) :
          (color.green > color.blue ? color.green : color.blue);
    sprintf(bases[num++].name,
            "#%04x%04x%04x", color.red, color.green, color.blue);
  }
}
#endif

#ifndef ATARI
int writecolormap(status)
     Bool* status;
{
  int i, j;
  XColor color;
  int ind = 0;
  int num = 0;

  *status = True;
  if (pixels != NULL)
    free(pixels);
  pixels = (Pixel*) calloc(cw, sizeof(Pixel));
  for (i=L_COLOR; *status && i>=0; i--)
    if (opt->cpi[i] == i)
      if (opt->fading_colors < 2 || i<FF_COLOR) {
        XParseColor(d, cmap, bases[i].name, &color);
        if (XAllocColor(d, cmap, &color)) 
          pixels[num++] = color.pixel;
        else
          *status = False;
      }
      else
        for (j=0; *status && j<opt->fading_colors; j++) {
          XParseColor(d, cmap, fcnames[ind++].name, &color);
          if (XAllocColor(d, cmap, &color))
            pixels[num++] = color.pixel;
          else
            *status = False;
        }
  return num;
}
#endif

#ifndef ATARI
void countcolors()
{
  int i, j;

  ufc = unfc = 0;
  if (opt->mono) {
    cr = cw = unfc = 2;
    return;
  }
  for (i=L_COLOR; i>=0; i--) {
    for (j=L_COLOR; j>i && strcmp(bases[i].name,bases[j].name); j--);
    opt->cpi[i] = j;
    if (i == j) 
      if (opt->fading_colors==1 || i<FF_COLOR)
        unfc++;
      else 
        ufc++;
  }
  cw = unfc+ufc*opt->fading_colors;
}
#endif

#ifndef ATARI
void reducecolors()
{
  int i, firstcolor, lastcolor;
  static int attempt = 0;
  static int groupings[][2] = {
    F1_COLOR, L1_COLOR, F2_COLOR, L2_COLOR, F3_COLOR, L3_COLOR,
    F4_COLOR, L4_COLOR, F5_COLOR, L5_COLOR, F6_COLOR, L6_COLOR,
    F7_COLOR, L7_COLOR, F8_COLOR, L8_COLOR, F9_COLOR, L9_COLOR };

  while (cw > cr) {
    switch(attempt++) {
    case 0:                     /* reduce # of fading colors */
      opt->fading_colors = (cr-unfc)/ufc;
      if (opt->fading_colors < 1)
        opt->fading_colors = 1;
      break;
    case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9:
      /* now start combining color groups */
      firstcolor = groupings[attempt-1][0];
      lastcolor = groupings[attempt-1][1];
      for (i=lastcolor; i>firstcolor; i--)
        strcpy(bases[i].name, bases[firstcolor].name);
      break;
    case 10:
      opt->mono = True;
      break;
    }
    countcolors();
  }
}
#endif

#ifndef ATARI
void setcolormap()
{
  int dallocated, pallocated;
  Bool success = False;
  Visual* visual;
  
  if (opt->mono || depth == 1) {        /* mono? */
    setmonomap();
    return;
  }

  visual = DefaultVisual(d, screen_num);
  standardizecolors(visual);

  if (opt->max_colors < 2) 
    if (depth<8)
      cr = 1>>depth;
    else
      cr = 256;
  else
    cr = opt->max_colors;

  if (opt->fading_colors < 1)
    opt->fading_colors = cr;

  do {
    countcolors();
    reducecolors();

    if (opt->mono) {
      setmonomap();
      return;
    }

    if (opt->fading_colors > 1)
      createfadedcolors();

    if (DisplayCells(d, screen_num) >= cw) {
      cmap = dcmap;
      dallocated = writecolormap(&success);
    }
    else
      dallocated = DisplayCells(d, screen_num);

    pallocated = 0;
    if (!success) {
      XFreeColors(d, cmap, pixels, dallocated, 0);
      if (!opt->defaultcolormap) {
        cmap = XCreateColormap(d, root, visual, AllocNone);
        pallocated = writecolormap(&success);
        if (!success) {
          XFreeColors(d, cmap, pixels, pallocated, 0);
          XFreeColormap(d, cmap);
        }
      }
    }
      
    cr = dallocated>pallocated ? dallocated : pallocated;
  } while (!success);

  setcoloroptvalues();
}
#endif
  
#ifndef ATARI
void gprinit ()
{
  XEvent ev;

  XSelectInput(d, w, ExposureMask|PointerMotionMask|ButtonPressMask
               |ButtonReleaseMask|KeyPressMask|StructureNotifyMask);
  XMapRaised(d, w);
  XWindowEvent(d, w, StructureNotifyMask, &ev);
  grabpointer();
}
#endif

#ifndef ATARI
void buildgcs()
{
  XGCValues xgcv;
  XColor BColor, FColor;
  Font f;
  
  xgcv.foreground = pixels[opt->cpi[COLOR_FG]];
  xgcv.background = pixels[opt->cpi[COLOR_BG]];
  DrawGC = XCreateGC(d, w, GCForeground | GCBackground, &xgcv);
  xgcv.foreground = pixels[opt->cpi[COLOR_TEXT]];
  TextGC = XCreateGC(d, w, GCForeground | GCBackground, &xgcv);
  xgcv.foreground = pixels[opt->cpi[COLOR_BG]];
  EraseGC = XCreateGC(d, w, GCForeground | GCBackground, &xgcv);
  xgcv.function = GXxor;
  xgcv.foreground = pixels[opt->cpi[COLOR_TEXT]] ^ pixels[opt->cpi[COLOR_BG]];
  BitBltGC = XCreateGC(d, w, GCFunction | GCForeground | GCBackground, &xgcv);
  FColor.pixel = pixels[opt->cpi[COLOR_CURSOR]];
  XQueryColor(d, cmap, &FColor);
  BColor.pixel = pixels[opt->cpi[COLOR_BG]];
  XQueryColor(d, cmap, &BColor);
  if (opt->cursor) 
    XDefineCursor(d, w,
                  XCreatePixmapCursor(d,
                                      XCreateBitmapFromData(d, w, cursor_bits,
                                                            16, 16),
                                      XCreateBitmapFromData(d, w, cshape_bits,
                                                            16, 16),
                                      &FColor, &BColor, 8, 10 ));
  else {
    f = XLoadFont(d, "fixed");
    XDefineCursor(d, w,
                  XCreateGlyphCursor(d, f, f, ' ', ' ', &FColor, &BColor));
  }
}
#endif

#ifndef ATARI
void buildpixmaps()
{
  int i;
  
  for (i=0; i<NUMPIXMAPS; i++) 
    bmaps[i].p =
      XCreatePixmapFromBitmapData(d, w, bmaps[i].bits,
                                  bmaps[i].width, bmaps[i].height,
                                  pixels[opt->cpi[bmaps[i].color]],
                                  pixels[opt->cpi[COLOR_BG]],
                                  depth);
}
#endif

#ifndef ATARI
static XrmOptionDescRec CbzoneOptions[] = {
  {"-delay", "*delay", XrmoptionSepArg, NULL},
  {"-blocks", "*blocks", XrmoptionSepArg, NULL},
  {"-landers", "*landers", XrmoptionSepArg, NULL},
  {"-tanks", "*tanks", XrmoptionSepArg, NULL},
  {"-missiles", "*missiles", XrmoptionSepArg, NULL},
  {"-salvos", "*salvos", XrmoptionSepArg, NULL},
  {"-coptersonly", "*coptersonly", XrmoptionNoArg, "True"},
  {"-quiet", "*quiet", XrmoptionNoArg, "False"},
  {"-scores", "*scores", XrmoptionNoArg,  "True"},
  {"-original", "*original", XrmoptionNoArg, "True"},
  {"-version", "*version", XrmoptionNoArg, "True"},
  {"-help", "*help", XrmoptionNoArg, "True"},
  {"-nooutput", "*output", XrmoptionNoArg, "False"},
  {"-mono", "*mono", XrmoptionNoArg, "True"},
  {"-cursor", "*cursor", XrmoptionNoArg, "True"},
  {"-nofullscreen", "*fullscreen", XrmoptionNoArg, "False"},
  {"-defaultcolormap", "*defaultcolormap", XrmoptionNoArg, "True"}
};

static XtResource CbzoneResources[] = {
  {"delay", "Delay", XtRInt, sizeof(int),
     XtOffset(Optionp, delay), XtRImmediate, (caddr_t) DELAY},
  {"blocks", "Blocks", XtRInt, sizeof(int),
     XtOffset(Optionp, mblocks), XtRImmediate, (caddr_t) MBLOCKS},
  {"landers", "Landers", XtRInt, sizeof(int),
     XtOffset(Optionp, mlanders), XtRImmediate, (caddr_t) MLANDERS},
  {"tanks", "Tanks", XtRInt, sizeof(int),
     XtOffset(Optionp, mtanks), XtRImmediate, (caddr_t) MTANKS},
  {"missiles", "Missiles", XtRInt, sizeof(int),
     XtOffset(Optionp, mmissiles), XtRImmediate, (caddr_t) MMISSILES},
  {"salvos", "Salvos", XtRInt, sizeof(int),
     XtOffset(Optionp, msalvos), XtRImmediate, (caddr_t) MSALVOS},
  {"coptersonly", "Coptersonly", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, copters), XtRString, "False"},
  {"quiet", "Quiet", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, loud), XtRString, "True"},
  {"scores", "Scores", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, scores), XtRString, "False"},
  {"original", "Original", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, original), XtRString, "False"},
  {"version", "Version", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, version), XtRString, "False"},
  {"help", "Help", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, help), XtRString, "False"},
  {"output", "Output", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, output), XtRString, "True"},
  {"mono", "Mono", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, mono), XtRString, "False"},
  {"bgcolor", "BgColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_BG]),
     XtRString, "black"},
  {"fgcolor", "FgColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_FG]),
     XtRString, "skyblue"},
  {"textcolor", "TextColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_TEXT]),
     XtRString, "red"},
  {"esalvocolor", "SalvoColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_ESALVO]),
     XtRString, "red"},
  {"psalvocolor", "SalvoColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_PSALVO]),
     XtRString, "skyblue"},
  {"joystickcolor", "JoystickColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_JOYSTICK]),
     XtRString, "red"},
  {"scannercolor", "ScannerColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_SCANNER]),
     XtRString, "green"},
  {"horizoncolor", "HorizonColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_HORIZON]),
     XtRString, "gray50"},
  {"mooncolor", "MoonColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_MOON]),
     XtRString, "gray50"},
  {"xhaircolor", "XHairColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_XHAIR]),
     XtRString, "gray50"},
  {"cursorcolor", "CursorColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_CURSOR]), XtRString, "skyblue"},
  {"crackcolor", "CrackColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_CRACKS]),
     XtRString, "skyblue"},
  {"tankcolor", "EnemyColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_TANK]),
     XtRString, "green"},
  {"supercolor", "EnemyColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_SUPER]),
     XtRString, "green"},
  {"missilecolor", "EnemyColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_MISSILE]),
     XtRString, "green"},
  {"coptercolor", "EnemyColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_COPTER]),
     XtRString, "green"},
  {"landercolor", "LanderColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_LANDER]),
     XtRString, "green"},
  {"cubecolor", "BlockColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_CUBE]),
     XtRString, "yellow"},
  {"pyramidcolor", "BlockColor", XtRString, sizeof(String),
     XtOffset(Optionp, cname[COLOR_PYRAMID]),
     XtRString, "yellow"},
  {"maxcolors", "MaxColors", XtRInt, sizeof(int),
     XtOffset(Optionp, max_colors), XtRImmediate, (caddr_t) 0},
  {"fadingcolors", "FadingColors", XtRInt, sizeof(int),
     XtOffset(Optionp, fading_colors), XtRImmediate, (caddr_t) 0},
  {"cursor", "Cursor", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, cursor), XtRString, "False"},
  {"fullscreen", "Fullscreen", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, fullscreen), XtRString, "True"},
  {"defaultcolormap", "DefaultColormap", XtRBoolean, sizeof(Boolean),
     XtOffset(Optionp, defaultcolormap), XtRString, "False"}
};
#endif

void gprinqconfig(argc, argv)
     int* argc;
     char* argv[];
{
#ifndef ATARI
  Widget cbzone;
  XWMHints wmhints;
  XSizeHints shints;
  XtAppContext cbzonecontext;
  int i;
  
  XtToolkitInitialize();
  cbzonecontext = XtCreateApplicationContext();
  if ((d = XtOpenDisplay(cbzonecontext, NULL,
                         "cbzone", "Cbzone",
                         CbzoneOptions, XtNumber(CbzoneOptions),
                         argc, argv)) == NULL) {
    parseopt(*argc, argv, False); 
    printf("can't open display! bye.\n");
    exit(0);
  }
  cbzone = XtAppCreateShell("cbzone", "Cbzone",
                            applicationShellWidgetClass, d, NULL, 0);
  XtGetApplicationResources(cbzone, opt, CbzoneResources,
                            XtNumber(CbzoneResources), NULL, 0);
  parseopt(*argc, argv, True);

  screen = DefaultScreenOfDisplay(d);
  depth = DisplayPlanes(d, screen_num);
  screen_num = DefaultScreen(d);
  dcmap = DefaultColormap(d, screen_num); 
  root = DefaultRootWindow(d);
  setcolormap();

  if (opt->fullscreen) {
    shints.width = wid = WidthOfScreen(screen)+10;
    shints.height = hei = HeightOfScreen(screen)+10;
    shints.x = shints.y = 0;
    shints.flags = USPosition | USSize;
  }
  else {
    wid = 1000;
    hei = 710;
    shints.flags = 0;
  }

  w = XCreateSimpleWindow (d, root, 0, 0, wid, hei, 0,
                           pixels[opt->cpi[COLOR_BG]],
                           pixels[opt->cpi[COLOR_BG]]);
  XSetWindowColormap(d, w, cmap);

  wmhints.input = True;
  wmhints.flags = InputHint;
  XSetWMHints(d, w, &wmhints);
  XSetNormalHints(d, w, &shints);
  XStoreName(d, w,"Cbzone");
  XSetIconName(d, w, "Cbzone");

  gprinit();
  buildgcs();
  buildpixmaps();
#else
	/* This little lot should cope with most things! */
	gem_setup();
	parseopt(*argc, argv, True); 
        /* Colours are *real* complicated ;-).
	Here is a quick fix to get us along */
        setmonomap();
	wid = 1000;
	hei = 710;
#endif
}

void gprsettextfont(font)
#ifndef ATARI
     Font font;
{
  XSetFont(d, TextGC, font);
#else
	int font;
{
	/* set gem font */
	GEM_SIZE chh,chw,clh,clw;

	vst_height(handle,4,&chh,&chw,&clh,&clw);
#endif
}

void printstring(x, y, string, nchars)
     int x, y;
     char* string;
     int nchars;
{
#ifndef ATARI
  XDrawImageString (d, w, TextGC, x, y, string, nchars);
#else
	v_gtext(handle,x>>1,y>>1,string);
#endif
}

#if 0
void polyline(points, number)
     XPoint *points;
     int number;
{
/* This is the inefficient version for the Atari. Its easier to
understand though */
#ifndef ATARI
  XDrawLines(d, w, DrawGC, points, number, CoordModeOrigin);
#else
	for (q=0; q<number; q++){
        	pxarray[q<<1]=(points->x)>>1;
	        pxarray[(q<<1)+1]=(points->y)>>1;
		points++;
	}

	v_pline(handle,number,pxarray);
#endif
}
#endif


void polyline(points, number)
#ifndef ATARI
     XPoint *points;
#else
	short *points;
#endif
     int number;
{
#ifndef ATARI
  XDrawLines(d, w, DrawGC, points, number, CoordModeOrigin);
#else
	GEM_SIZE *ptr = &pxarray[0];

	for (q=0; q<number; q++){
        	*(ptr++)=(*(points++))>>1;
        	*(ptr++)=(*(points++))>>1;
	}

	v_pline(handle,number,pxarray);
#endif
}

#if 0
void multiline(segments, number)
     XSegment *segments;
     int number;
{
/* This is the inefficient version for the Atari. Its easier to
understand though */
#ifndef ATARI
  XDrawSegments (d, w, DrawGC, segments, number);
#else

	for (q=0; q<number; q++){
        	pxarray[0]=(segments->x1)>>1;
	        pxarray[1]=(segments->y1)>>1;
        	pxarray[2]=(segments->x2)>>1;
	        pxarray[3]=(segments->y2)>>1;

		v_pline(handle,2,pxarray);

		segments++;
	}
#endif
}
#endif


void multiline(segments, number)
#ifndef ATARI
     XSegment *segments;
#else
	short *segments;
#endif

     int number;
{
#ifndef ATARI
  XDrawSegments (d, w, DrawGC, segments, number);
#else
	GEM_SIZE *ptr;

	ptr = &pxarray[0];

	for (q=0; q<number; q++){

		*ptr = (*(segments++))>>1;
		*(ptr+1) = (*(segments++))>>1;
		*(ptr+2) = (*(segments++))>>1;
		*(ptr+3) = (*(segments++))>>1;

		v_pline(handle,2,pxarray);

	}
#endif
}

void drawrectangle(x, y, width, height)
     int x, y, width, height;
{

#ifndef ATARI
  XDrawRectangle (d, w, DrawGC, x, y, width, height);
#else

        pxarray[0]=x>>1;
        pxarray[1]=y>>1;

        pxarray[2]=(x>>1)+(width>>1);
        pxarray[3]=y>>1;

        pxarray[4]=(x>>1)+(width>>1);
        pxarray[5]=(y>>1)+(height>>1);

        pxarray[6]=x>>1;
        pxarray[7]=(y>>1)+(height>>1);

        pxarray[8]=x>>1;
        pxarray[9]=y>>1;

        v_pline(handle,5,pxarray);

#endif
}

#ifndef ATARI
void bitblt(window)
     Window_t *window;
{
  XFillRectangle(d, w, BitBltGC, window->base.x, window->base.y,
                 window->size.x, window->size.y);
}
#endif


void clearrectangle(window, dsto)
     Window_t *window;
     Position_t *dsto;
{

#ifndef ATARI
  XFillRectangle(d,w,EraseGC,dsto->x, dsto->y,
                 window->size.x, window->size.y);
#else
        pxarray[0]=(dsto->x)>>1;
        pxarray[1]=(dsto->y)>>1;
        pxarray[2]=(dsto->x+window->size.x)>>1;
        pxarray[3]=(dsto->y+window->size.y)>>1;

        vsf_color(handle,0);  /* fill colour = white */
        vr_recfl(handle,pxarray); 

#endif
}

void gprsetclippingactive(flag)
     Bool flag;
{
#ifndef ATARI
  if (flag) {
    XSetClipRectangles (d, DrawGC, 0, 0, &clipr, 1, YXBanded);
    XSetClipRectangles (d, EraseGC, 0, 0, &clipr, 1, YXBanded);
  } else {
    XSetClipMask (d, DrawGC, None);
    XSetClipMask (d, EraseGC, None);		
  }
#else
	if (flag) {
		vs_clip(handle,1,clipr);
	}else{
		vs_clip(handle,0,clipr);
	}
#endif
}

void tonetime()
{
#ifndef ATARI
  if (opt->loud)
    XBell(d, 0);
#else
	sound(ping);
#endif
}

void timeclock(tval)
     struct timeval* tval;
{
#ifndef ATARI
  XSync(d, False);
#endif
  gettimeofday(tval, 0);
}

void gprinqcursor(posn)
     Position_t *posn;
{
  *posn = mouse_posn;
}

#ifndef ATARI
Bool paused = False;

Bool gprcondeventwait(key, posn)
     char* key;
     Position_t *posn;
{

  static unsigned long flag[16]={0};
  XEvent ev;
  char keystr;
  Bool return_val = False;
  Bool motion = False;

  while (XPending(d) || paused) {
    XNextEvent(d, &ev);
    switch(ev.type) {
    case Expose:
      if (((XExposeEvent*) &ev)->count) break;
      if (!paused)
        grabpointer();
      mouse_posn.x = ev.xexpose.x;
      mouse_posn.y = ev.xexpose.y;
      *key = 'R';
      return_val = True;
      break;
    case UnmapNotify:
      paused = True;
      break;
    case MapNotify:
      paused = False;
      break;
    case KeyPress:
      if (XLookupString(&ev.xkey,&keystr,1,(KeySym *) 0,
                        (XComposeStatus *) 0) == 1)
        switch (keystr) {
        case 'p': case 'P':
          ungrabpointer();
          paused = True;
          break;
        case 'c': case 'C':
          grabpointer();
          paused = False;
          break;
        case 'i': case 'I': case ' ':
          XIconifyWindow(d, w, screen_num);
          break;
        case 'r': case 'R':
          *key = 'R';
          return_val = True;
          break;
        case '\003': case 'q': case 'Q':
          *key = 'Q';
          return_val = True;
          break;
        }
      if (return_val) {
        mouse_posn.x = ev.xkey.x;
        mouse_posn.y = ev.xkey.y;
      }
      break;
    case MotionNotify:
      motion = True;
      mouse_posn.x = ev.xmotion.x;
      mouse_posn.y = ev.xmotion.y;
      break;
    case ButtonPress:
      mouse_posn.x = ev.xbutton.x;
      mouse_posn.y = ev.xbutton.y;	    
      *key = ev.xbutton.button + 'a' - 1;
      flag[ev.xbutton.button]=1;
      return_val = True;
      break;
    case ButtonRelease:
      mouse_posn.x = ev.xbutton.x;
      mouse_posn.y = ev.xbutton.y;	    
      *key = ev.xbutton.button + 'A' - 1;
      flag[ev.xbutton.button]=0;
      return_val = True;
      break;
    }
    if (return_val)
      break;
  }
  if(flag[1]&&flag[3]) {
    *key = 'Q';
    return_val = True;
  }
  if (!paused) {
    *posn = mouse_posn;
  }
  return return_val;

}
#else

Bool gprcondeventwait(key, posn)
     char* key;
     Position_t *posn;
{
	char keystr;
	Bool return_val = False;

	GEM_SIZE x,y;
	GEM_SIZE pstatus;

	vq_mouse(handle,&pstatus,&x,&y);
	mouse_posn.x = x<<1;
	mouse_posn.y = y<<1;

	/* Try and debounce mouse key */
	if (last == 'a'){
		*key = 'A';
		return_val = True;
		last = 'A';
		return return_val;
	}
	if (pstatus){
		*key = 'a';
		return_val = True;
	}else{
		*key = 'R';
		return_val = False;
	}

	if (Bconstat(2)){
		keystr=(char)(Bconin(2));
	        switch (keystr) {
        	case 'p': case 'P':
				pause_dialog();	/* Just stop everything with an alert! */
          		break;
        	case 'c': case 'C':
          		break;
        	case 'r': case 'R':
          		*key = 'R';
          		return_val = True;
          		break;
        	case 27: case 'q': case 'Q':	/* 27 = ESC */
          		*key = 'Q';
          		return_val = True;
          		break;
        	}
	}
    last = *key;
    return return_val;
}
#endif


void gprsetcursorposition(posn)
     Position_t *posn;
{
#ifndef ATARI
  XWarpPointer (d, None, w, 0, 0, 0, 0, posn->x, posn->y);
#else
	/* This is a little tricky to do - need some assembler! */
#endif
}

#ifndef ATARI
Font gprloadfontfile(name)
     char* name;
{
  XFontStruct *xfs;

  if ((xfs = XLoadQueryFont(d, name)) == NULL)
    return XLoadFont(d, "fixed");
  else
    return xfs->fid;
}
#endif

void gprsettextvalue(index)
     int index;
{
#ifndef ATARI
  XSetForeground(d, TextGC, pixels[index]);
#else
        vst_color(handle,index);
#endif
}

void gprsettextbackgroundvalue(index)
     int index;
{
#ifndef ATARI
  XSetBackground(d, TextGC, pixels[index]);
#endif
}

void gprsetdrawvalue(index)
     int index;
{
#ifndef ATARI
  XSetForeground(d, DrawGC, pixels[index]);
#else
#ifdef DEBUG
debug_log("set colour = %d\n",index);
#endif
        vsl_color(handle,index);  /* line colour */
#endif
}

void gprcircle(center, radius)
     Position_t *center;
     int radius;
{
#ifndef ATARI
  XDrawArc (d, w, DrawGC,
            center->x - radius, center->y - radius,
            radius+radius, radius+radius, 0, 360*64);
#else

	v_arc(handle,(center->x)>>1,(center->y)>>1,radius>>1,0,3600);
#endif
}

void gprcirclefilled(center, radius)
     Position_t *center;
     int radius;
{
#ifndef ATARI
  XFillArc (d, w, DrawGC,
            center->x - radius, center->y - radius,
            radius+radius, radius+radius, 0, 360*64);
#else
	v_circle(handle,(center->x)>>1,(center->y)>>1,radius>>1);
#endif
}

void gprsetclipwindow(window)
     Window_t *window;
{
#ifndef ATARI
  clipr.x = window->base.x;
  clipr.y = window->base.y;
  clipr.width = window->size.x;
  clipr.height =  window->size.y;
#else
/* Note 'clipr' is an array *not* a structure */
	clipr[0] = (window->base.x)>>1;
	clipr[1] = (window->base.y)>>1;
	clipr[2] = ((window->base.x)+(window->size.x))>>1;
	clipr[3] = ((window->base.y)+(window->size.y))>>1;
#endif
}

void clearentirescreen()
{
#ifndef ATARI
  XClearWindow(d, w);
#else
	v_clrwk(handle);
#endif
}

void flushwindow()
{
#ifndef ATARI
  XFlush(d);
#else
	/* No need to flush a virtual workstation */
#endif
}

void waitforkey(c)
     char c;
{

  char keystr;
#ifndef ATARI
  XEvent ev;
  
  XFlush(d);                    /* out with the old */
  while (XPending(d))
    XNextEvent(d, &ev);
                                /* now wait for the new */
  while (1) {
    XWindowEvent(d, w, KeyPressMask|ButtonPressMask, &ev);
    switch(ev.type) {
    case KeyPress:
      if (!c || XLookupString(&ev.xkey,&keystr,1,(KeySym *) 0,
                        (XComposeStatus *) 0) == 1 &&
          keystr == c)
        return;
      break;
    case ButtonPress:
      if (!c)
        return;
      break;
    }
  }
#else
	keystr=(char)(Bconin(2));
#endif
}

void putpixmap(i, p)
     int i;
     int* p;
{
#ifndef ATARI
  XCopyArea(d, bmaps[i].p, w, DrawGC, 0, 0,
            bmaps[i].width, bmaps[i].height, p[0], p[1]);
#endif
}


void removepixmap(i, p)
     int i;
     int* p;
{
#ifndef ATARI
  XFillRectangle(d, w, EraseGC, p[0], p[1],
                 bmaps[i].width, bmaps[i].height);
#endif
}
