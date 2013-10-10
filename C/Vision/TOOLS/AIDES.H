#ifndef __AIDES__
#define __AIDES__

/*POUR 1STGUIDE*/
#define AC_HELP          1025
#define HELP_FILE_MAGIC  0x1993

/********************** GESTION DES BULLES D'AIDES ***********************/
int bulle_aide(int m_x, int m_y, char *txt) ;
OBJECT *creer_bulle(OBJECT *piece_bulle, int nb_ligne, int nb_cara, int m_x, int m_y, int *num_1er_item);
void init_obj_bulle(OBJECT *bulle, OBJECT *piece_bulle, int i, int icone, int pos_x, int pos_y);
void init_obj_box_bulle(OBJECT *bulle, int i, int pos_x, int pos_y, int w, int h);
int txt_bulle(char *txt, int objet);
void test_bulle_inf(char chemin[], OBJECT *menu, int item);
void gestion_activation_bulle(char chemin[], OBJECT *menu, int item);
void sauve_inf_bulle(char chemin[], int actif);
int  charge_inf_bulle(char chemin[]);
/********************** GESTION DES AIDES EN LIGNE ***********************/
void Help_1ST(char *keyword, char *indexfile);
void Help_STG(char *pattern);
int BHelpSetRSCFile(char *file) ;

#endif __AIDES__