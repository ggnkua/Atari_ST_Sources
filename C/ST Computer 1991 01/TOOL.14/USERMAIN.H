/*
 * Listing 3.7, Datei : usermain.h
 * Modul              : USERMAIN - Benutzer-
 *                      Verwaltung
 * Modifikationsdatum : 27-Dez-1990
 * Abh„ngigkeiten     : stdio.h, string.h, local.h
 */

typedef struct user_list_node *USER_LIST;

typedef struct user_list_node {
    char      *user,
              *passwd,
              *shell;
    USER_LIST next;
} USER_LIST_NODE;

extern void      load_user_data();
extern USER_LIST find_user();
extern void      insert_replace_user(),
                 delete_user(),
                 set_modification_bit(),
                 save_user_data(),
                 input();

