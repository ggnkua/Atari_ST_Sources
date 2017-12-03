/************************************************/
/*  Programme d'interruption dans la queue VBL  */
/*      Laser C      VBLQUEUE.C     */
/************************************************/

#include <osbind.h>

char *shiftptr;
int  *nvbls;
long *queue_ptr;
long *vbl_queue;

long save_screen[8000];   /* 32000 octets */

routine()       /* Fonction qui doit ˆtre une routine d'interruption */
{
int  i;
long *screen;

  if ((*shiftptr & 15) == 11)    /* Alt + 2x Shift? */
  {
    screen = (long *) 0x44e;     /* Pointeur sur la RAM-Vid‚o  */
    screen = (long *) *screen;  
    
    for (i=0; i<8000; i++)       /* Sauvegarde de l'‚cran*/
      save_screen[i] = *(screen+i);
    
    Cconws ("\33E\12\12");       /* ClrScr et 2 fois LineFeed */
    Cconws ("  Votre ordre est en cours de traitement.\15\12\12");
    Cconws ("  Un peu de patience, SVP...");
    
    while ((*shiftptr & 15) != 4);   /* Attendre Control */
    
    for (i=0; i<8000; i++)       /* R‚cup‚rer l'‚cran */
      *(screen+i) = save_screen[i];
  }
}


int init_vbl()
{
long *long_ptr,
     save_ssp;
int  i,
     *int_ptr,
     trouve;

  save_ssp = Super (0L);  /* Passer en mode superviseur */
  
  /* Passer l'adresse de l'‚tat des touches sp‚ciales: */
  
  shiftptr = (char *) 0xe1bL;  /* Adresse avec l'ancien TOS */
  int_ptr = (int *) 0xfc0002;  /* Quelle version du TOS? */
  if (*int_ptr > 0x100)        /* Plus grande que l'ancien TOS? */
  {
    long_ptr = (long *) 0xfc0024;  /* Voici o— se trouve l'adresse */
    shiftptr = (char *) *long_ptr;
  }

  /* Entr‚e dans la queue VBL */

  nvbls = (int *) 0x454L;
  queue_ptr = (long *) 0x456L;
  vbl_queue = (long *) *queue_ptr;
  
  i=0; trouve=0;
  
  do
  {
    if (*(vbl_queue+i) == 0L)
    {
      *(vbl_queue+i) = (long) routine;  /* Installer routine */
      trouve = -1;
    }
    i++;
  }
  while (!trouve && i < *nvbls);

  Super (save_ssp);      /* Retour en mode utilisateur */
  return (trouve);
}


main()
{
  if (init_vbl())
    Ptermres (65536L, 0); 
}
