/*********************************************/
/*   Les accessoires se parlent (êmetteur)   */
/*   Laser C           ENVOIE.C   */
/*********************************************/

#include "gem_inex.c"

int  ac_id,
     typ,
     listen_id,
     tampon[8];
     
long *longs;

char message[100];
     
main()
{
  longs = (long *) tampon;
  
  gem_init();
  
  ac_id = menu_register (ap_id, "  êmetteur");
  
  while (1)       /* Boucle sans fin */
  {
    evnt_mesag (tampon);

    /* Cet accessoire ne peut àtre activÇ que par un clic dans le menu */
    /* Bureau. Nous pouvons donc nous contenter de comparer simplement */
    /* le message au type 40: */

    /* Test: Notre accessoire? */
    if (tampon[0] == 40 && tampon[4] == ac_id) 
    {
      /* Le message sera affichÇ plus tard par appl_write. Nous devons      */
      /* donc connaåtre l'ID d'application du rÇcepteur. appl_find s'en     */
      /* chargera. Cela nous permet d'ailleurs de vÇrifier que l'accessoire */
      /* Çmetteur a bien ÇtÇ chargÇ. */
      
      listen_id = appl_find ("RECOIT  "); 
      
      if (listen_id == -1)     /* Pas trouvÇ? */
        form_alert (1, "[3][Le recepteur n'est pas |encore chargÇ en mÇmoire][Ah bon?]");
      else
      {
        typ = form_alert (0, "[2][Quel message dÇsirez-vous?| |1. Salut rÇcepteur|2. Beau temps aujourd'hui!|3. ATARI est super!][1|2|3]");
        switch (typ)
        {
          case 1: strcpy (message, "Salut rÇcepteur");
                  break;
           
          case 2: strcpy (message, "Beau temps aujourd'hui!");
                  break;
            
          case 3: strcpy (message, "ATARI est super!");
                  break;
        }

        /* Nous pouvons maintenant envoyer le message. Nous Çcrivons    */
        /* notre "code secret" (99) dans le tampon[0]. Le code indique  */
        /* Ö l'Çmetteur ce que nous voulons faire. L'adresse du message */
        /* est stockÇe dans le tampon[2] et [3] (par longs, voir        */
        /* commentaire dans le listing de LISTEN.C). */

        tampon[0]  = 99;              /* Code de communication privÇe */
        *(longs+1) = (long) message;  /* identique Ö tampon[2] et [3] */
      
        appl_write (listen_id, 16, tampon);  /* Envoyer 16 octets */
      }
    }
  }
}
