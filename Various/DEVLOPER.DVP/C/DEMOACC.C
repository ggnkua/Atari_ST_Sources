/*******************************************************/
/*   En-tˆte d'accessoire (… linker comme accessoire)  */
/*   Megamax Laser C                 DEMOACC.C  */
/*******************************************************/

#include "gem_inex.c"

int  ac_id,
     tampon[8];
     
     
void go_accessory()
{
  form_alert (1,"[1][S U P E R - A C C E S S O R Y|Veuillez choisir:][Fin|Sortie|Quitte]");
}
     
     
main()
{
  gem_init();
  
  /* gem_init retourne le num‚ro d'application dans la variable */
  /* globale ap_id qui est d‚clar‚e dans le fichier Include     */
  
  ac_id = menu_register (ap_id, "  D‚mo-accessoire");
  
  /* Boucle sans fin d'attente */
  
  while (1)
  {
    evnt_mesag (tampon);
  
    if (tampon[0] == 40)          /* Accessoire demand‚? */
      if (tampon[4] == ac_id)     /* notre accessoire? */
        go_accessory();           /* alors appeler le sous-programme */
  }
}
