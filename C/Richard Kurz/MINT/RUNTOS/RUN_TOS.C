/* 
 * RUN_TOS
 *
 * Startet TOS/TTP Programme Åber die TOSRUN-Pipe
 *
 * Oktober 1992 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * FÅr's TOS-Magazin
 */

#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define TRUE 1
#define FALSE 0

int gem_main(int argc,char *argv[])
{
    static char s[512],pfad[256],name[256];
    int fp;
    long i;
    char *p;
    
    if(argc<=1) return(FALSE);
    
    strcpy(name,argv[1]);
    strcpy(pfad,argv[1]);
    p=strrchr(pfad,'\\');
    if(p)
    {
        *(++p)=0;
    }
    else
    {
        strcpy(name,pfad);
        pfad[0]=0;
    }       
    strcpy(s,pfad);
    strcat(s," ");
    strcat(s,name);
    for(i=2;i<argc;i++)
    {
        strcat(s," ");
        strcat(s,argv[i]);
    }

    fp=Fopen("U:\\PIPE\\TOSRUN",FO_WRITE);
    if(fp<0)
    {
        form_alert(1,"[3][TOSRUN|U:\\PIPE\\TOSRUN|konnte nicht geîffnet|werden][ OK ]");
        return(FALSE);
    }
    i=strlen(s)+1;
    if(Fwrite(fp,i,s)!=i)
    {
        form_alert(1,"[3][TOSRUN|Fehler beim schreiben][ OK ]");
        return(FALSE);
    }
    Fclose(fp);
    return(TRUE);
}/* gem_main */

void main(int argc,char *argv[])
{
    if(appl_init()<0)
    {
        Cconout('\a');
        puts(" TOSRUN AES-Anmeldung fehlgeschlagen");
        exit(1);
    }
    graf_mouse(ARROW,0);
    if(gem_main(argc,argv))
    {
        appl_exit();
        exit(0);
    }
    appl_exit();
    exit(1);
} /* main */

