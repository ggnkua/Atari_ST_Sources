/****************************************************/ 
/*   D‚mo evnt_button    (Gestion des ‚vŠnements)   */ 
/*   Megamax Laser C        BOUTON.C   */ 
/****************************************************/ 
 
#include <osbind.h> 
#include "gem_inex.c" 
 int  x, y, k, 
     clics, 
     swtch;  /* Nom "sp‚cial" parce que "switch" est r‚serv‚ */ 
 

main() 
{ 
  gem_init(); 
  graf_mouse (0, 0L);   /* Pointeur souris: flŠche */ 
                        /* (L'abeille est encore l… aprŠs le chargement) */ 
                        /* 0L est pratiquement sans int‚rˆt pour vous */ 
                         
  Cconws ("\33E");  /* Effacer l'‚cran */

 
  vswr_mode (handle,2);    /* Mode transparent */ 
   
  do 
  { 
    clics = evnt_button (2, 1, 1, &x, &y, &k, &swtch); 
     
    if (clics == 1)   /* Combien de clics? */ 
      v_gtext (handle, x, y, "x"); 
    else 
      v_gtext (handle, x, y, "X"); 
  } 
  while (swtch == 0); 
   
  gem_exit(); 
}




