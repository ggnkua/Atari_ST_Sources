#include <stdlib.h>
#include <stdio.h>
#include <tos.h>

/*#include <alloc.h>*/
#define BLK_MAX_NBR 64 /* nombre de bloc memoire gere au maxi */
typedef enum {libre=0 , occupe=1 } t_flag;


/* Definition de la structure d'entete d'un bloc memoire */
/* On utilise une liste doublement chaine non boucle     */
typedef struct {
			void *blk_next;   /* pointeur sur bloc suivant      */
			void *blk_prec;   /* pointeur sur bloc precedent    */
unsigned long blk_num;     /* numero du bloc                 */
unsigned long blk_size;    /* Taille du bloc alloue          */
		 t_flag blk_state;   /* Etat du bloc (occupe ou libre) */
}mem_blk;

/* Pointeur sur le premier bloc memoire de la chaine */
mem_blk *blk_tete;
/* Table des bloc occupe : si un indexe du tableau est a 0, numero de bloc est libre */
/* Celui-ci permet a l'applicatif de connaitre l'adresse des bloc de donnees en
	utilisant un pointeur sur pointeur. Le bloc peu alors se deplacer, l'appli est
	au courant !!! */
void *blk_tbl[BLK_MAX_NBR];

/* Quelques statistique a jours en permanence */
unsigned long free_mem;      /* Taille totale restant en memoire         */
unsigned long blk_free_nbr;  /* Nombre de bloc libre present en memoire  */
unsigned long blk_occup_nbr; /* Nombre de bloc occupe present en memoire */

/* Fonction d'initialisation du gros bloc memoire principale */
void xaloc_init(unsigned long mem_init_size){
long i;
/* Allocation d'un gros bloc memoire : a remplacer par des adresse en dur
	dans le cas d'un gestionnaire de memoire pour un systeme d'expoloitation */
mem_init_size+=sizeof(mem_blk);
blk_tete=(mem_blk *)Malloc(mem_init_size);
/* Initialisation des infos de base */
free_mem=mem_init_size-sizeof(mem_blk);
blk_free_nbr=1;
blk_occup_nbr=0;
/* Initialisation d'un seul et unique bloc libre dans la liste */
blk_tete->blk_num=0;
blk_tete->blk_next=NULL;
blk_tete->blk_prec=NULL;
blk_tete->blk_size=free_mem;
blk_tete->blk_state=libre;
for(i=0;i<BLK_MAX_NBR;i++)
	blk_tbl[i]=NULL;
return;
}

/* Fonction d'allocation memoire : meme parametres que malloc() */
void **xaloc_aloc(unsigned long taille_bloc,void *app_ptr){
int i=0;
unsigned long recherche_size;
mem_blk *new_bloc;
mem_blk *recherche;
void *return_value;
if(taille_bloc>free_mem)
	return(0);
recherche_encore:
recherche=blk_tete;
recherche_size=taille_bloc+sizeof(mem_blk);
/* Recherche d'un bloc libre (metode = first fit) */
while( (recherche_size>(recherche->blk_size) || (recherche->blk_state)==occupe)
						&& recherche->blk_next!=NULL)
	recherche=recherche->blk_next;
/* Si on entre dans le if, c'est qu'on a besoin d'un compactage */
if(recherche_size>recherche->blk_size||recherche->blk_state==occupe){
	mem_blk *courant;
	mem_blk *suivant;
	mem_blk temp_entete;
	unsigned long i;
	char *copy_ptr1,*copy_ptr2;
	/* Recherche du premier bloc libre a partir de la tete */
	courant=blk_tete;
	while(courant->blk_next!=NULL && courant->blk_state==occupe)
		courant=courant->blk_next;

	 /* Echange du bloc courant (libre) avec le bloc (occupe) suivant */
	suivant=courant->blk_next;
	temp_entete=*courant;
	courant->blk_next=courant+suivant->blk_size;
	courant->blk_state=occupe;
	courant->blk_size=suivant->blk_size;
	courant->blk_num=suivant->blk_num;
	temp_entete.blk_next=suivant->blk_next;
	copy_ptr1=(char *)courant+sizeof(mem_blk);
	copy_ptr2=(char *)suivant+sizeof(mem_blk);
	for(i=0;i<courant->blk_size;i++)
		  copy_ptr1[i]=copy_ptr2[i];
	suivant=courant->blk_next;
	*suivant=temp_entete;








	/* Si les 2 blocs suivant le bloc qui vient d'etre deplace
		 sont libre, alors on les regroupe en 1 seul */
	courant=suivant;
	suivant=suivant->blk_next;
	if(suivant->blk_state==libre){
		courant->blk_size+=(suivant->blk_size)+(sizeof(mem_blk));
		courant->blk_next=suivant->blk_next;
		courant->blk_state=libre;
		if(suivant->blk_next!=NULL){
			suivant=suivant->blk_next;
			suivant->blk_prec=courant;}
		free_mem+=sizeof(mem_blk);
		blk_free_nbr--;}
	goto recherche_encore; /* On a fini le compactage, on peut donc
		reessayer de faire un malloc */}
/* Si on arrive ici, c'est qu'on a trouve un bloc libre assez grand */
else{
	/* Calcul de l'adresse du nouveau bloc memoire libre */
	new_bloc=(long)recherche+(long)recherche_size;

	/* Initialisation des infos de celui-ci */
	new_bloc->blk_next =recherche->blk_next;
	new_bloc->blk_prec =recherche;
	new_bloc->blk_size =recherche->blk_size-recherche_size;
	new_bloc->blk_state=libre;

	/* Update du bloc suivant le nouveau bloc libre (new_bloc) */
	if(recherche->blk_next!=NULL){
		mem_blk *yop;
		yop=recherche->blk_next;
		yop->blk_prec=new_bloc;
		}
	/* Update du bloc occupe */
	recherche->blk_next =new_bloc;  /* prec ne change pas */
	recherche->blk_size =taille_bloc;
	recherche->blk_state=occupe;

	/* Recherche d'un numero de bloc occupe dans le tableau */
	while(blk_tbl[i]!=NULL){
		i++;
		if(i==BLK_MAX_NBR)
			return(0);}
	blk_tbl[i]=app_ptr;
	recherche->blk_num=i;

	/* Update des infos generales */
	free_mem-=recherche_size;
	blk_occup_nbr++;

	return_value=recherche+sizeof(mem_blk);
	return(return_value);
	}
}

void xaloc_fusion(mem_blk *bloc1, mem_blk *bloc2){
mem_blk *suiv_bloc1;

bloc1->blk_next=bloc2->blk_next;
bloc1->blk_size+=bloc2->blk_size+sizeof(mem_blk);

suiv_bloc1=bloc2->blk_next;
if(suiv_bloc1!=NULL)
	suiv_bloc1->blk_prec=bloc1;

return;
}

void xaloc_free(void *adresse_blk){
mem_blk *recherche;
mem_blk *precedent;
mem_blk *suivant;
mem_blk *next_mem;

/* Recherche du bloc passe en parametre */
recherche=blk_tete;
while(recherche+sizeof(mem_blk)!=adresse_blk && (recherche->blk_next)!=NULL)
	  recherche=recherche->blk_next;
/* Si on a trouve le bloc, alors on le libere en l'unifiant avec le bloc
	libre de gauche et de droite si ils existent et si ils sont libres */
precedent=recherche->blk_prec;
suivant=recherche->blk_next;
free_mem+=recherche->blk_size;
recherche->blk_state=libre;
blk_tbl[recherche->blk_num]=NULL;

blk_occup_nbr--;
blk_free_nbr++;

if(!(precedent==NULL && suivant==NULL)){
	if(precedent!=NULL){
			next_mem=(void *)precedent;
			next_mem=(long)next_mem+(long)sizeof(mem_blk);
			next_mem=(long)next_mem+(long)precedent->blk_size;

		if((next_mem==recherche)&&(precedent->blk_state==libre)){
			free_mem+=sizeof(mem_blk);
			blk_free_nbr--;
			xaloc_fusion(precedent,recherche);
			recherche=precedent;
			}
		}

	if(suivant!=NULL){
			next_mem=(void *)recherche;
			next_mem=(long)next_mem+(long)sizeof(mem_blk);
			next_mem=(long)next_mem+(long)recherche->blk_size;
		if((next_mem==suivant)&&(suivant->blk_state==libre)){
			free_mem+=sizeof(mem_blk);
			blk_free_nbr--;
			xaloc_fusion(recherche,suivant);}
		}
	}
return;
}
