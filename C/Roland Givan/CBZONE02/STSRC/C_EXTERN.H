/*
 * c_externs.h
 *  -- Todd W Mummert, December 1990, CMU
 *
 * Mostly a garbage file.  If all the world would get
 * ANSI compilers, this file could actually be useful
 * as we could then do argument checking.  Actually, I should
 * #ifdef the arguments, but haven't gotten around to it yet.
 */

#ifndef FunctionPrototypes
#define FunctionPrototypes 0
#endif

/* now some externs from c_gpr.c */
extern Bool gprcondeventwait(
#if FunctionPrototypes
        char* /* key */,
        Position_t* /* posn */
#endif
);
extern void bitblt(
#if FunctionPrototypes
        Window_t* /* window */
#endif
);
extern void clearentirescreen(
#if FunctionPrototypes
#endif
);
extern void clearrectangle(
#if FunctionPrototypes
        Window_t* /* window */,
        Position_t* /* dsto */
#endif
);
extern void drawrectangle(
#if FunctionPrototypes
        int /* x */,
        int /* y */,
        int /* width */,
        int /* height */
#endif
);
extern void flushwindow(
#if FunctionPrototypes
#endif
);
extern void gprcircle(
#if FunctionPrototypes
        Position_t* /* center */,
        int /* radius */
#endif
);
extern void gprcirclefilled(
#if FunctionPrototypes
        Position_t* /* center */,
        int /* radius */
#endif
);
extern void gprinqconfig(
#if FunctionPrototypes
        int* /* argc */,
        char** /* argv */
#endif
);
extern void gprinqcursor(
#if FunctionPrototypes
        Position_t* /* posn */
#endif
);

#ifndef ATARI
extern Font gprloadfontfile(
#if FunctionPrototypes
        char* /* name */
#endif
);
#endif

extern void gprsetclippingactive(
#if FunctionPrototypes
        Bool /* flag */
#endif
);
extern void gprsetclipwindow(
#if FunctionPrototypes
        Window_t* /* window */
#endif
);
extern void gprsetcursorposition(
#if FunctionPrototypes
        Position_t* /* posn */
#endif
);
extern void gprsetdrawvalue(
#if FunctionPrototypes
        int /* index */
#endif
);
extern void gprsettextbackgroundvalue(
#if FunctionPrototypes
        int /* index */
#endif
);
extern void gprsettextfont(
#if FunctionPrototypes
        Font /* font */
#endif
);
extern void gprsettextvalue(
#if FunctionPrototypes
        int /* index */
#endif
);
extern void multiline(
#if FunctionPrototypes
        XSegment* /* segments */,
        int /* number */
#endif
);
extern void polyline(
#if FunctionPrototypes
        XPoint* /* points */,
        int /* number */
#endif
);
extern void printstring(
#if FunctionPrototypes
        int /* x */,
        int /* y */,
        char* /* string */,
        int /* nchars */
#endif
);
extern void putpixmap(
#if FunctionPrototypes
        int /* i */,
        int* /* p */
#endif
);
extern void removepixmap(
#if FunctionPrototypes
        int /* i */,
        int* /* p */
#endif
);
extern void timeclock(
#if FunctionPrototypes
        struct timeval* /* tval */
#endif
);
extern void tonetime(
#if FunctionPrototypes
#endif
);
extern void waitforkey(
#if FunctionPrototypes
        char /* c */
#endif
);

/* now some externs from c_graphics.c */
extern void clearscreen(
#if FunctionPrototypes
#endif
);
extern void drawcracks(
#if FunctionPrototypes
#endif
);
extern void drawhorizon(
#if FunctionPrototypes
        float /* azm */
#endif
);
extern void joystick(
#if FunctionPrototypes
        int* /* position */,
        Genericp /* pl */,
        Bool /* sens */
#endif
);
extern void message(
#if FunctionPrototypes
        int /* number */,
        Bool /* bell */
#endif
);
extern void scanner(
#if FunctionPrototypes
        Genericp /* o */
#endif
);
extern void screeninit(
#if FunctionPrototypes
#endif
);
extern void staticscreen(
#if FunctionPrototypes
#endif
);
extern void updatedisplay(
#if FunctionPrototypes
        Bool /* missile */,
        Bool /* lander */,
        int /* score */,
        int /* numleft */,
        Bool /* sens */,
        Bool /* reset */
#endif
);
extern void xhairs(
#if FunctionPrototypes
        Bool /* aligned */
#endif
);

/* now some externs from c_explode.c */
extern void explodeobject(
#if FunctionPrototypes
#endif
);
extern void explodesalvo(
#if FunctionPrototypes
        Genericp /* g */,
        Genericp /* pl */
#endif
);

/* now some externs from c_move.c */
extern void movecopter(
#if FunctionPrototypes
        Genericp /* g */,
        Genericp /* pl */
#endif
);
extern void movelander(
#if FunctionPrototypes
        Genericp /* g */,
        Genericp /* pl */
#endif
);
extern void movemissile(
#if FunctionPrototypes
        Genericp /* g */,
        Genericp /* pl */
#endif
);
extern void movesuper(
#if FunctionPrototypes
        Genericp /* g */,
        Genericp /* pl */
#endif
);
extern void movetank(
#if FunctionPrototypes
        Genericp /* g */,
        Genericp /* pl */
#endif
);
extern void placeobjects(
#if FunctionPrototypes
        Genericp /* o */,
        Bool /* missilerun */,
        int /* score */
#endif
);

/* now some externs from c_draw.c */
extern void drawobject(
#if FunctionPrototypes
        Genericp /* g */,
        Genericp /* pl */
#endif
);
extern void displayobject(
#if FunctionPrototypes
        DCp /* dc */
#endif
);

/* now some externs from c_scores.c */
extern int scores(
#if FunctionPrototypes
        int /* score */
#endif
);

/* now some externs from c_parseopts.c */
extern void parseopt(
#if FunctionPrototypes
        int /* argc */,
        char** /* argv */,
        Bool /* status */
#endif
);

/* let everybody know the options exist */
extern Optionp opt;

/* also need to know if the player is paused */
extern Bool paused;
