/* ICFS.H 0.11
 */

#define ICF_GETSIZE  0x0000
#define ICF_GETPOS   0x0001
#define ICF_FREEPOS  0x0002
#define ICF_FREEALL  0x0100
#define ICF_INFO     0x0200
#define ICF_CONFIG   0x0201
#define ICF_SETSIZE  0x0202
#define ICF_SETSPACE 0x0203

#define ICFS_COOKIE	0x49434653UL	/* 'ICFS' */

struct _config
{
 unsigned reserved : 13; /* unbenutzt, sollte 0 sein */
 unsigned yfirst   : 1;  /* Bit 2: 1=zuerst in y-Richtung */
 unsigned right    : 1;  /* Bit 1: 1=rechts anfangen */
 unsigned top      : 1;  /* Bit 0: 1=oben anfangen */
};

typedef struct
{
 unsigned int version;  /* Versionsnummer als BCD (0x0010 fÅr 0.10) */
 struct _config config; /* Config., siehe oben */
 int xsize, ysize,      /* Breite und Hîhe des Fensters, default=72 */
     xspace, yspace;    /* Abstand zwischen Fenstern, default=0 */
} ICFSCONFIG;
