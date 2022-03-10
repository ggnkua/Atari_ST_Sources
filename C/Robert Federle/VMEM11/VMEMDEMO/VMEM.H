/*******************************/
/* INCLUDE-Datei fÅr VMEM 1.1: */
/*******************************/

#define _NULL           (0L)

typedef unsigned int    WORD;
typedef unsigned long   V_ADR;

#define V_INFO          struct v_info
#define TAB             struct tab

#define SIZE_1024       0   /* Seiten-Typen */
#define SIZE_2048       1
#define SIZE_4096       2
#define SIZE_8192       3
#define SIZE_16384      4
#define SIZE_32768      5

/************************
 * Funktions-Meldungen: *
 ************************/

#define OK                  0
#define ILLEGAL_FUNCTION    -0x1234

/* vm_config: */

#define	NO_LIST             1
#define	NOT_FOUND           4
#define WRONG_CACHE_SIZE    -256
#define WRONG_PAGE_TYPE     -257
#define OUT_OF_MEMORY       -258
#define FILE_ERROR          -259
#define ILLEGAL_DRIVE       -260
#define ILLEGAL_FATSIZE     -265

/* vm_free: */

#define NOT_OK              -261

/* vm_address / vm_fill / vm_copy / vm_load / vm_save / vm_read / vm_write: */

#define ILLEGAL_ADDRESS     -262
#define ILLEGAL_COUNT       -263
#define ILLEGAL_MODE        -264

/************************/
/* Funktions-Parameter: */
/************************/

#define DRIVE_C             3   /* vm_config */
#define DRIVE_D             4
#define DRIVE_E             5
#define DRIVE_F             6
#define DRIVE_G             7

#define READ_MODE           2   /* vm_address */
#define WRITE_MODE          4

/***************/
/* Strukturen: */
/***************/

V_INFO                      /* fÅr vm_info */
{
    WORD    version;        /* Versionsnummer des Programms */

    WORD    count_page;     /* Maximalanzahl an Seiten */

    WORD    count_blocks;   /* Maximale Anzahl an Blîcken */
    WORD    free_blocks;    /* Anzahl der noch verfÅgbaren Blîcke */

    int     fill_value;     /* FÅllwert */

    long    cache_size;     /* Grîûe des Caches in Bytes */
    WORD    cache_count;    /* Grîûe des Caches in Seiten */

    long    page_size;      /* Grîûe einer Seite in Bytes */

    long    max_size;       /* Maximalgrîûe des virtuellen Speichers */
    long    max_alloc;      /* Maximalgrîûe eines einzelnen Blocks */

    int     drive_no;       /* TMP-Laufwerk (C=3, D=4, E=5, ...) */
    long    drive_free;     /* freier Speicher auf dem TMP-Laufwerk */
};

TAB                         /* fÅr vm_config */
{
    WORD    version;
    WORD    count_page;
    WORD    cache_size;
    WORD    page_type;
    int     fill_value;
    int     drive_no;
};

/***************************/
/* Prototypen fÅr Turbo C: */
/***************************/

int     vm_config   (TAB *parameter);
void    vm_close    (void);
V_INFO  *vm_info    (void);
void    vm_clrcache (void);
V_ADR   vm_alloc    (long size);
int     vm_free     (V_ADR address);
char    *vm_address (V_ADR address, long *window_size, int mode);
long    vm_fill     (V_ADR address, long count, int value);
long    vm_load     (V_ADR source, char *destination, long count);
long    vm_save     (char *source, V_ADR destination, long count);
long    vm_write    (int handle, long count, V_ADR source);
long    vm_read     (int handle, long count, V_ADR destination);
