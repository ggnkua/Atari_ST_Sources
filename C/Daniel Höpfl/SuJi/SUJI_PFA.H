#ifndef __DH_SUJI_PFA_H_
#define __DH_SUJI_PFA_H_

int analyse_parameter(int argc,char *argv[],void **search_pfade);void free_pfade(void *search_pfade);
char *get_pfad(void *pfade,int i);
int get_max_breite_pfade(void *pfade);
int unterpfade(const char *a,const char *b);
unsigned int remove_double_paths(void **pfade);
int add_a_new_path(struct SUCHINFORMATIONEN *suji, char *this);
int remove_selected_paths(struct SUCHINFORMATIONEN *suji);
int count_deselected(void *pfade);
int count_selected(void *pfade);


struct pfadkette {
	struct pfadkette *next;		/* Verkettung */
	int selected;				/* FÅr die Liste */

	char pfad[1];
};

int change_a_path(struct SUCHINFORMATIONEN *suji,struct pfadkette *this);

#endif