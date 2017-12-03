/***********************************************************/
/* D‚tecteur de virus (d‚tecte un secteur Boot ex‚cutable) */
/*   Megamax Laser C            VIRUS.C   */
/***********************************************************/

#include <osbind.h>

#define  TRACK  0
#define  SECTEUR 1
#define  DEVICE 0
#define  SIDE   0

int  tampon[256];            /* 512 octets pour un secteur */
int  somme = 0;
int  back;
int  i;
char ouinon;

main()
{
  Cconws ("Ins‚rez une disquette dans le lecteur A: SVP\15\12");
   Crawcin();      /* Attente frappe d'une touche */

                   /* lit le secteur boot (1 = lire un seul secteur) */
  back = Floprd (tampon, 0L, DEVICE, SECTEUR, TRACK, SIDE, 1);

   if (back < 0)
    Cconws ("Disquette endommag‚e!\15\12");
  else
  {
    for (i = 0;  i < 256;  i++)
      somme += tampon[i];

    if (somme == 0x1234)           /* $1234 --> ex‚cutable */
    {
      Cconws ("Le secteur boot est ex‚cutable.15\12");
      Cconws ("Dois-je le modifier? ");
      
      do
        ouinon = Crawcin();
      while (!(ouinon=='j' || ouinon=='n'));
      
      if (ouinon=='j')
      {
        Cconws ("Oui\15\12");
                ++tampon[255];         /* Augmenter le dernier mot de un */

                                       /* R‚‚crire le secteur */
        back = Flopwr (tampon, 0L, DEVICE, SECTEUR, TRACK, SIDE, 1);

         if (back == -13)
          Cconws ("La disquette est prot‚g‚e contre l'‚criture\15\12");
        else
          if (back < 0)
            Cconws ("Disk-Error\15\12");
      }
    }
    else
      Cconws ("Le secteur boot n'est pas ex‚cutable!\15\12");
  }

  Cconws ("\15\12\12Touche= Fin...");
  Crawcin();                   /* Attend une touche */
}
