/**********************************************/
/*   Les accessoires se parlent (r‚cepteur)   */
/*   Laser C          RECOIT.C    */
/**********************************************/

#include "gem_inex.c"

int  ac_id,      /* Num‚ro d'identification de l'accessoire */
     tampon[8];  /* Comme d'habitude: tampon des messages AES */
     
long *longs;     /* Pointeur sur tampon, v. ci-dessous */

char str[100],   /* Nous allons stocker une chaŒne */
     *message;   /* Le message arrive ici */
     
main()
{
  /* ProblŠme: Il nous faut des mots et des long-mots dans un  */
  /* mˆme tableau. Solution: nous affectons l'adresse (presque */
  /* un pointeur) du premier tableau … un deuxiŠme. Les deux   */
  /* tableaux sont formellement diff‚rents (1 = entiers,       */
  /* 2 = long-mots) mais ils pointent sur les mˆmes donn‚es.   */
  
  longs = (long *) tampon; 
  
  gem_init();
  
  ac_id = menu_register (ap_id, "  R‚cepteur");   /* Annoncer l'ACC */
  
  while (1)       /* Boucle sans fin */
  {
    evnt_mesag (tampon);   /* Attendre un message de l'AES */

    switch (tampon[0])     /* Identification du type d'‚vŠnement */
    {
      /* Possibilit‚ 1: */
      /* L'utilisateur a cliqu‚ normalement l'entr‚e du menu Bureau. */
      /* Le tampon[0] contient alors 40, comme il se doit. Nous      */
      /* faisons simplement une petite remarque: */
      
      case 40:                         /* Accessoire demand‚? */
        if (tampon[4] == ac_id)        /* Notre accessoire? */
          form_alert (1,"[1][Je suis le r‚cepteur.|Veuillez m'envoyer|un message!][Tout de suite!]");
      break;
      
      /* Possibilit‚ 2: */
      /* Notre "code secret" 99 est dans le tampon[0]. L'AES ne connaŒt */
      /* pas ce message, il doit donc venir de l'accessoire ‚metteur.   */
      /* Dans les mots 2 et 3 (ou dans le deuxiŠme long-mot) du message */
      /* se trouve un pointeur sur la chaŒne qui contient le message    */
      /* transmis: */
        
      case 99:                /* Aha! Message de l'‚metteur! */

        message = (char*) *(longs+1);   /* DeuxiŠme long-mot */
        strcpy (str, "[1][Le r‚cepteur a re‡u le message:| |");
        strcat (str, message);           /* Voici le message */
        strcat (str, "][Compris.]");
      
        form_alert (1, str);       /* Afficher le tout, SVP! */
        break;
    }    
  }
}
