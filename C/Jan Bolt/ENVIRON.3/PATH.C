/*===============================================================*
 *                                                               *
 * path.c                                                        *
 *                                                               *
 * Anzeigen der AES Environment Variablen PATH                   *
 *                                                               *
 * 31.12.89 Jan Bolt  Version 210990                             *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/

#include <stdio.h> 
#include <aes.h>

void alert(char *str)
     {
     char tmp[128];
     
     sprintf(tmp, "[0][%s ][ OK ]", str);
     form_alert(1, tmp);
     }

/*======================= Hauptprogramm =========================*/

int main()
    {
    char *path;
    
    if (appl_init() < 0)
       return 1;

    shel_envrn(&path, "PATH=");
    if (path != NULL)
       alert(path);

    return (appl_exit() == 0);
    }


