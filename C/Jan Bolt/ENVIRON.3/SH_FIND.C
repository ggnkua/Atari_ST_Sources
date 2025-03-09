/*===============================================================*
 *                                                               *
 * sh_find.c                                                     *
 *                                                               *
 * Demo shel_find                                                *
 *                                                               *
 * 21.01.90 Jan Bolt  Version 210990                             *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/

#include <stdio.h> 
#include <aes.h>

void alert(char *str, int k)
     {
     char tmp[128];
     
     sprintf(tmp, "[0][%s |%d ][ OK ]", str, k);
     form_alert(1, tmp);
     }

/*======================= Hauptprogramm =========================*/

int main()
    {
    int s;
    static char path[PATH_MAX] = "find_me.prg";

    if (appl_init() < 0)
       return 1;
       
    s = shel_find(path);
    alert(path, s);

    return (appl_exit() == 0);
    }


