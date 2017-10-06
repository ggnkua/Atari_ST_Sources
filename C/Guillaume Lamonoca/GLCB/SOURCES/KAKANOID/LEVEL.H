/* Chaque tableau fait 13x2 colonne x 15 lignes */
/* Premier caractere : couleur, Deuxieme nb de cout est couleur G */

typedef char *Niveau[17];

#define MAX_LEVEL 20
extern Niveau Levels[MAX_LEVEL];
extern Niveau G_NiveauActif;
