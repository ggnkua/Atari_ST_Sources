/*********************************************/
/*                                           */
/*  tek.h defines fÅr tektronix emulation    */
/*                                           */
/*********************************************/

#define   HIY  0x20 /* High Y- Coordinaten */
#define   EB   0x60 /* Extra Byte (Enhanced Graphic Option */
#define   LOY  0x60 /* Low Y Coordinaten */
#define   HIX  0x20 /* High X Coordinaten */
#define   LOX  0x40 /* Low X Coordinaten */

#define   TEK_ALPHA 0x1  /* Alpha Mode */
#define   TEK_GRAPH 0x2  /* Graphics Mode */
#define   TEK_POINT 0x4  /* Point Plot Mode */
#define   TEK_INCREMENT  0x8 /* Incremental Plot Mode */
#define   TEK_VECTOR 0x10     /* Vector Plot Mode */
#define   TEK_BYPASS     0x20 /* Bypass in Plot Mode */
#define   TEK_GIN        0x40 /* Cursor input */
#define   TEK_Y_CHANGE   0x80 /* y coordinates changed */
#define   TEK_Y_COORD    0x100     /* Y-Coordinate to be get */
#define   TEK_LOY   0x200     /* Last byte was LOY */
#define   TEK_WRITE 0x400     /* Vectors really to be written */
#define   TEK_IWRITE 0x800    /* Increment write-mode memory */
#define   TEK_ESC   0x1000    /* Escape get */


struct tek_coord {
     char hiy;
     char eb;
     char loy;
     char hix;
     char lox;
};

struct int_coord {
     int  x;
     int  y;
};

