/*
 * Listing 3.10, Datei : passwd.c
 * Programm            : PASSWD - Žndern von
 *                       Pažw”rtern
 * Modifikationsdatum  : 27-Dez-90
 * Abh„ngigkeiten      : stdio.h, osbind.h, local.h,
 *                       usermain.h, crypt.h
 */

#include <stdio.h>
#include <osbind.h>
#include "local.h"
#include "usermain.h"
#include "crypt.h"

/*
 * Funktion     : passwd
 *
 * Parameter    : ok = passwd(argc, argv);
 *                BOOLEAN passwd;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos PASSWD.
 */

#define MAXSTR 100

static char random_char()
{   unsigned char c;

    c = rand();
    c = c % 94 + 33;
    return(c);
}

BOOLEAN passwd(argc, argv)
short argc;
char  *argv[];
{   USER_LIST list;
    char      oldpasswd1[MAXSTR],
              oldpasswd2[MAXSTR],
              newpasswd1[MAXSTR],
              newpasswd2[MAXSTR],
              salt[3],
              *erg;

    if (argc == 2) {
        load_user_data();
        list = find_user(argv[1]);
        input("old password?", oldpasswd1, FALSE);
        input("retype old password!", oldpasswd2,
              FALSE);
        if (strcmp(oldpasswd1, oldpasswd2) != 0) {
            printf("old passwords are different\n");
            return(FALSE);
        }
        input("new password?", newpasswd1, FALSE);
        input("retype new password!", newpasswd2,
              FALSE);
        if (strcmp(newpasswd1, newpasswd2) != 0) {
            printf("new passwords are different\n");
            return(FALSE);
        }
        if (list != NULL) {
            if (strcmp(list->passwd, "ohne") == 0 ||
                strcmp(list->passwd, 
                       crypt(oldpasswd1,
                       list->passwd)) == 0) {
                srand(Gettime());
                salt[0] = random_char();
                salt[1] = random_char();
                salt[2] = 0;
                erg = crypt(newpasswd1, salt);
                free(list->passwd);
                list->passwd = malloc(strlen(erg)
                                      + 1);
                strcpy(list->passwd, erg);
                set_modification_bit();
            }
            else
                printf("incorrect old password\n");
        }
        else {
            crypt("Mit irgendwas", "ausbremsen");
            printf("unknown user\n");
        }
        save_user_data();
    }
    else {
        fprintf(stderr, "SYNOPSIS: passwd user\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if(!passwd(argc, argv))
        exit(1);
    exit(0);
}

