/**********************************************************************/
/*   Fichier Include pour proc‚dure standard d'annonce (AES et VDI)   */
/*   Megamax Laser C             GEM_INEX.C   */
/**********************************************************************/

int  contrl[12],         /* Ces tableaux doivent TOUJOURS ˆtre */
     intin[128],         /* d‚clar‚s dans les programmes destin‚s */
     ptsin[128],         /* … exploiter les fonctions VDI */
     intout[128],
     ptsout[128];
     
int  ap_id,                    /* Variables utilisables dans */
     handle,                   /* chaque application */
     x_max,
     y_max;


void gem_init()               /* Appel‚ une fois au d‚but */
{
int  work_in[11],             /* Ces tableaux sont n‚cessaires … v_opnvwk */
     work_out[57],                                    
     i;                       /* Variable de stockage temporaire */

  ap_id = appl_init();                      /* Initialise l'AES */
  
  for (i=0; i<10; work_in[i++] = 1);        /* [0-9] mis … 1 */
  work_in[10] = 2;        /* Drapeau de coordonn‚es, doit toujours ˆtre 2 */

  v_opnvwk (work_in, &handle, work_out);    /* Initialise la VDI */

  x_max = work_out[0];                      /* Stocker la r‚solution */
  y_max = work_out[1];
}

void gem_exit()              /* N'appeler cette fonction qu'… la fin */
{                            /* de l'application */
  v_clsvwk (handle);
  appl_exit(); 
}
