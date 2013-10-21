/* header.h  (header pour les modules de base)

Guillaume LAMONOCA
Supelec (94)
*/

/* choisissez: AVEC ou SANS prototypes ? (SANS pour K&R) */

#define AVEC prototypes

/* definissez EXTENSION pour pcvga.c,x11.c,x11local.c et falcon.c */

/*
#define EXTENSION
*/

/* Pour la compatibilite avec les PC, definir huge
 comme un simple commentaire sur les autres machines */


#define huge huge

#define FOND 0x100
#define MASK 0x1ff


#ifdef EXTENSION

/**********************************************************************/
/* certains modules (pcvga, x11, falcon, ...) ont une palette etendue */

extern void setbigcolor(int n,unsigned int r,unsigned int v,unsigned int b);
extern void getbigcolor(int n,unsigned int *r,unsigned int *v,unsigned int *b);
extern void setbigpalette(int no,int nb,unsigned int *ptr);
extern void getbigpalette(int no,int nb,unsigned int *ptr);

#endif


#ifdef AVEC
#include <stdio.h>		/* tres utile! */

/********************************************************************/
/* variables globales utiles */

extern int mousex,mousey,mousek,vblclock; /* mise a jour perpetuelle    */
extern int msex,msey,msek,mclk;           /* mise a jour par getmouse() */
extern char keymap[256];

/**********************************************************************/
/* tables trigonometriques 14 bits (en 256emes de tour) */

extern int *sn; /* definie entre 0 et 255 */
extern int *cs; /* definie entre 0 et 255 */
extern int *tg; /* definie entre -32 et +32 */

/************************************************************/
/* initialisation du systeme */

extern int initsystem(void);
extern void killsystem(void);


/***************************************************************/
/* gestion des 16 couleurs (emulation par tramage sur N&B) */

extern void setcolor(int c);
extern void getpalette(unsigned int *pal);
extern void setpalette(unsigned int *pal);


/************************************************************/
/* instructions de gestion des ecrans graphiques */

extern void simplescreen(void);
extern void doublescreen(void);
extern void cls(void);
extern void copyscreen(void);
extern void refresh(void);
extern void swap(void);


/******************************************************************/
/* instructions graphiques de base */

extern void pellipse(int x,int y,int lx,int ly,int c);
extern void pbox(int x,int y,int lx,int ly,int c);
extern void plot(int x,int y,int c);
extern void vline(int x,int y,int y2,int c);
extern void hline(int x,int y,int x2,int c);
extern void dline(int x1,int y1,int x2,int y2,int c);
extern void rline(int x1,int y1,int x2,int y2,int c);
extern void dbox(int x,int y,int lx,int ly,int c);
extern void polyline(int n,int *tp,int c);
extern void polyfill(int n,int *tp,int c);


/*****************************************************************/
/* instructions d'allocation memoire                             */

extern long ramfree(void);
extern void *memalloc(long size);
extern void memfree(void **ptr);


/**************************************************************/
/* transferts de blocs memoire */

extern void bmove(void *src,void *dst,long len);


/*****************************************************************/
/* instructions de gestion d'horloge                             */

extern unsigned long systime(void);
extern void waitdelay(unsigned int n);


/*****************************************************************/
/* fonctions aleatoires                                          */

extern int randint(void);
extern int randval(int n);


/**************************************************************/
/* gestion des fichiers */


extern long bsize(char *nom);
extern int bexist(char *nom);
extern int bsave(char *nom,void *adr,long offset,long len);
extern int bload(char *nom,void *adr,long offset,long len);
extern int bmake(char *nom,void *adr,long len);
extern int bopen(char *nom);
extern int bread(int f,void *adr,long len);
extern int bclose(int f);
extern int bcreate(char *nom);
extern int bwrite(int f,void *adr,long len);


/**************************************************************/
/* gestion de la souris et du clavier */

extern void hide(void);
extern void show(void);
extern int getmouse(void);
extern int buthit(void);
extern char getch(void);
extern int kbhit(void);
extern int keyhit(void);
extern void confirm(void);
extern void empty(void);


/***************************************************************/
/* gestion de blocs graphiques */

extern void initbloc(void **blocptr);
extern void freebloc(void **blocptr);
extern void getbloc(void **blocptr,int x,int y,int lx,int ly);
extern void copybloc(void **blocptrs,int xs,int ys,int lxs,int lys,void **blocptrd,int xd,int yd);
extern void getmask(void **blocptr,int x,int y);
extern void putbloc(void **blocptr,int x,int y);
extern void putpbloc(void **blocptr,int x,int y,int xs,int ys,int lxs,int lys);


/*****************************************************************/
/* instructions de gestion de fonte */

extern void affchar(int x,int y,char c);
extern void afftext(int x,int y,char *s);
extern void printchar(char c);
extern void print(char *s);


/*******************************************************************/
/* gestion des samples */

extern void playsample(void *adr,long len,long freq);
extern void stopsample(void);
extern void fixsample(void *adr,long len);

#endif

#ifdef SANS

/********************************************************************/
/* variables globales utiles */

extern int mousex,mousey,mousek,vblclock; /* mise a jour perpetuelle    */
extern int msex,msey,msek,mclk;           /* mise a jour par getmouse() */
extern char keymap[256];

/**********************************************************************/
/* tables trigonometriques 14 bits (en 256emes de tour) */

extern int *sn; /* definie entre 0 et 255 */
extern int *cs; /* definie entre 0 et 255 */
extern int *tg; /* definie entre -32 et +32 */

/************************************************************/
/* initialisation du systeme */

extern int initsystem();
extern void killsystem();


/***************************************************************/
/* gestion des 16 couleurs (emulation par tramage sur N&B) */

extern void setcolor();
extern void getpalette();
extern void setpalette();


/************************************************************/
/* instructions de gestion des ecrans graphiques */

extern void simplescreen();
extern void doublescreen();
extern void cls();
extern void copyscreen();
extern void refresh();
extern void swap();


/******************************************************************/
/* instructions graphiques de base */

extern void pellipse();
extern void pbox();
extern void plot();
extern void vline();
extern void hline();
extern void dline();
extern void rline();
extern void dbox();
extern void polyline();
extern void polyfill();


/*****************************************************************/
/* instructions d'allocation memoire                             */

extern long ramfree();
extern void *memalloc();
extern void memfree();


/**************************************************************/
/* transferts de blocs memoire */

extern void bmove();


/*****************************************************************/
/* instructions de gestion d'horloge                             */

extern unsigned long systime();
extern void waitdelay();



/*****************************************************************/
/* fonctions aleatoires                                          */

extern int randint();
extern int randval();


/**************************************************************/
/* gestion des fichiers */


extern long bsize();
extern int bexist();
extern int bsave();
extern int bload();
extern int bmake();
extern int bopen();
extern int bread();
extern int bclose();
extern int bcreate();
extern int bwrite();


/**************************************************************/
/* gestion de la souris et du clavier */

extern void hide();
extern void show();
extern int getmouse();
extern int buthit();
extern char getch();
extern int kbhit();
extern int keyhit();
extern void confirm();
extern void empty();


/***************************************************************/
/* gestion de blocs graphiques */


extern void initbloc();
extern void freebloc();
extern void getbloc();
extern void copybloc();
extern void getmask();
extern void putbloc();
extern void putpbloc();


/*****************************************************************/
/* instructions de gestion de fonte */

extern void affchar();
extern void afftext();
extern void printchar();
extern void print();


/*******************************************************************/
/* gestion des samples */

extern void playsample();
extern void stopsample();
extern void fixsample();

#endif
 
