/* Type Definitions */

typedef unsigned char byte;

typedef struct
{
	int ice,len,olen;
}ice_head;

/* Hash Defines */

#define TRUE  1
#define FALSE 0
#define FREQDIV  *(char *)0x00FF8935
#define VBASEHI  *(byte *)0x00FF8201
#define VBASEMID *(byte *)0x00FF8203
#define VBASELO  *(byte *)0x00FF820D


/* Prototypes */

void __regargs deice(char *);      /* Depacks a packed buffer */
byte *load_ice(char *,int *);      /* loads a file, depacks if req. */
void __regargs mod_init(void);
void __regargs mod_play(char,char far *); /* Plays a module */