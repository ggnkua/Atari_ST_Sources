/* **[Badgers]****************** */
/* *                           * */
/* * Variables Globales        * */
/* * 24/10/2015 MaJ 25/08/2025 * */
/* ***************************** */


/* les variables globales spécifique à l'animation Badgers */
/* sont présente dans <badgers_global.h>                   */


/* active le redemarrage avec TRUE */
int16  global_app_restart;

/* pour eviter de redemmarer en boucle infini si plus assez de RAM en cas de redemarrage */
int16  global_nb_redemarrage_succesif;


static char win_info_texte[80] = "";

/* Chemin pour les donn‚es */
char chemin_data[TAILLE_CHEMIN_DATA];


/* AES appl_write() message */
static int16 tube_gem[8];


