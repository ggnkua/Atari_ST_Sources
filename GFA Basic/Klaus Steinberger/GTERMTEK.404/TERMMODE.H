/*
 * this header file defines the setup modes
 */


struct t_mode {
     int  general;
     int  comm;
     int  graphic;
     int  display;
};

/*
 *   mode bits allgemein
 */
#define   M_ONLINE  0x1  /* online/local state */
#define   M_CRLF    0x2  /* CR = CR/LF */

/*
 *   mode bits fuer graphik
 */
#define   M_G_LHAIR     0x1   /* Long cross-hair */
#define   M_G_DEL       0x2   /* Delete = LOY */
#define   M_G_CR        0x4   /* CR as Terminator */
#define   M_G_EOT        0x8  /* EOT as Terminator */

/*
 *   mode bits communication
 */

#define   M_CSBAUD  0xf       /* Maske fuer baudrate */
#define   M_CS19200 0x0       /* 19,2 kBaud */
#define   M_CS9600  0x1       /* 9600 Baud */
#define   M_CS4800  0x2       /* 4800 Baud */
#define   M_CS3600  0x3       /* 3600 Baud */
#define   M_CS2400  0x4       /* 2400 Baud */
#define   M_CS2000  0x5       /* 2000 Baud */
#define   M_CS1800  0x6       /* 1800 Baud */
#define   M_CS1200  0x7       /* 1200 Baud */
#define   M_CS600   0x8       /* 600 Baud */
#define   M_CS300   0x9       /* 300 Baud */
#define   M_CS200   0xa       /* 200 Baud */
#define   M_CS150   0xb       /* 150 Baud */
#define   M_CS134   0xc       /* 134 Baud */
#define   M_CS110   0xd       /* 110 Baud */
#define   M_CS75    0xe       /* 75 Baud */
#define   M_CS50    0xf       /* 50 Baud */

#define   M_IXON    0x10      /* xon/xoff */
#define   M_RTS     0x20      /* rts/cts */
#define   M_LECHO   0x40      /* Local Echo */
#define   M_SLOW    0x80      /* slow send for gin */

