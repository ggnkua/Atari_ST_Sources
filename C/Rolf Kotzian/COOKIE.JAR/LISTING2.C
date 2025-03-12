/*                                              
    Programm : Extended TOS Library
    Modul    : cookie.c
    Funktion : allgemeine Routinen zur Verwaltung
               von Cookie Jars
               
    Edit     : 01.04.90
    Autor    : Rolf Kotzian, D-4790 Paderborn
    
    Copyright: (c) MAXON Computer GmbH
*/



/*  Includes  */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>


/*  Defines  */

#define TRUE                (0 == 0)
#define FALSE               (0 == 1)


/*  Typ-Vereinbarungen  */

typedef int boolean;
typedef struct
{
    char cookie_id[4];      /*  Cookie-ID    */
    long cookie_value;      /*  Cookie-Wert  */
    
}COOKIE;



/*  
    CREATE_COOKIE:  installiert in der Variablen
                    'cookie' einen Cookie; als
                    weitere Parameter werden die
                    ID des Cookies sowie dessen
                    Wert Åbergeben.
*/

void create_cookie (COOKIE *cookie, char *id,
                    long value)
{
    strncpy (cookie->cookie_id, id, 4);
    cookie->cookie_value = value;
    
}  /*  create_cookie  */



/*
    NEW_COOKIE:  trÑgt neuen Cookie in den Jar 
                 ein.
                 
    Achtung ! 
    Der Fall des bereits vollen Jars wird hier
    noch nicht abgefangen; es muss dann ent-
    sprechend Speicher alloziert, und die ge-
    samte Tabelle umkopiert werden.
*/

boolean new_cookie (COOKIE *entry)
{
    int act_row = 0;
    long old_stack, *cookiejar;
    
    
    /*  Zeiger auf CookieJar holen  */
    
    old_stack = Super (0L);
    cookiejar = *((long **) 0x5a0L);
    Super ((void *) old_stack);
    
    
    /*  Ist der Jar Åberhaupt vorhanden ? */
    
    if (!cookiejar)
        return (FALSE);
        
        
    /*  NULL-Cookie suchen  */    
    while (cookiejar[0])  
    {
        ++act_row;
        cookiejar = &(cookiejar[2]);
    }
    
    
    /*  
        der neue Cookie kann nur eingetragen
        werden, wenn der CookieJar noch aus-
        reichend Platz bietet...
    */     
      
    if (act_row < cookiejar[1])
    {
        /*  NULL-Cookie weiterschieben  */
        cookiejar[2] = cookiejar[0];
        cookiejar[3] = cookiejar[1];
        
        /*  neuen Cookie eintragen  */
        strncpy ((char *)cookiejar, 
                entry->cookie_id, 4);
                
        cookiejar[1] = entry->cookie_value;
                
        return (TRUE);
    }
    
    return (FALSE);
    
}  /*  new_cookie  */



/*
    GET_COOKIE:  fragt den Wert eines Cookies
                 ab. Als Parameter werden dabei
                 die ID des zu suchenden Cookies
                 sowie ein Zeiger auf den ge-
                 fundenen Wert Åbergeben.
                 
                 Die Routine liefert den Wert
                 FALSE falls der angegebene
                 Cookie nicht existiert...
*/

boolean get_cookie (char *cookie, long *value)
{
    long old_stack;
    long *cookiejar;
    
    
    /*  Zeiger auf Cookie Jar holen  */
    
    old_stack = Super (0L);
    cookiejar = *((long **) 0x5a0L);
    Super ((void *) old_stack);
    
    
    /*  Ist der Jar Åberhaupt vorhanden ?  */
    
    if (!cookiejar)
        return (FALSE);
        
    do
    {
        if (!strncmp ((char *)cookiejar,
            cookie, 4))
        {
        
            /*  nur eintragen, wenn kein
                NULL-Zeiger
            */
            
            if (value)
            {
                *value = cookiejar[1];
                return (TRUE);
            }
        }    
            
        else
        /*  nÑchsten Cookie nehmen  */
        cookiejar = &(cookiejar[2]);
        
    } while (cookiejar[0]);  /* NULL-Cookie ? */
    
    return (FALSE);
    
}  /*  get_cookie  */



/*
    REMOVE_COOKIE:  entfernt den mit 'cookie_id'
                    bezeichneten Cookie aus dem
                    Jar.
*/

void remove_cookie (char *cookie_id)
{
    long old_stack, *cookiejar;
    
    
    /*  Zeiger auf Cookie Jar holen  */
    
    old_stack = Super (0L);
    cookiejar = *((long **) 0x5a0L);
    Super ((void *) old_stack);
    
    
    /*  Ist der Jar Åberhaupt vorhanden ?  */
    
    if (!cookiejar)
        return;
   
    /*  suche den zu lîschenden Cookie in
        der Tabelle...
    */
    
    while ((cookiejar[0]) && (strncmp((char *)
           cookiejar, cookie_id, 4)))
           
           cookiejar = &(cookiejar[2]);
           

    /*  wurde der gewÅnschte Cookie gefunden,
        oder ist bereits das Ende der Tabelle
        (NULL-Cookie) erreicht ?
    */
    
    if (cookiejar[0])
    {
        /*  der Cookie wurde gefunden !  */
        
        do
        {
            /*  jetzt werden die Åbrigen Cookies
                einfach eine Position nach oben
                gezogen...
            */
            
            cookiejar[0] = cookiejar[2];
            cookiejar[1] = cookiejar[3];
            
            cookiejar = &(cookiejar[2]);
            
        } while (cookiejar[0]);
    }
    
}  /*  remove_cookie  */



/*
    MOVE_COOKIEJAR:  verschiebt (kompletten) Jar
                     an eine neue Speicherstelle.
                     Als Parameter werden die
                     neue Adresse des Jars sowie
                     seine Grîsse, d.h. die
                     Anzahl der in ihn hinein-
                     passenden Cookies Åbergeben.
*/

void move_cookiejar (long *dest, long size)
{
    long old_stack, *cookiejar, *dest_cop;
    
    /*  Zeiger auf Cookie Jar holen  */
    
    old_stack = Super (0L);
    cookiejar = *((long **) 0x5a0L);
    
    /*  Alte Adresse merken  */
    dest_cop = dest;
    
    /*  Ist der Jar Åberhaupt vorhanden ?  */
    
    if (!cookiejar)
       return;
     
       
    do 
    {
        /*  Cookie's kopieren  */
        dest[0] = cookiejar[0];
        dest[1] = cookiejar[1];
        
        dest      = &(dest[2]);
        cookiejar = &(cookiejar[2]);
        
    }while (cookiejar[0]);
    
    /*  NULL-Cookie und seinen neuen (?) Wert
        eintragen...
    */
    dest[0] = cookiejar[0];
    dest[1] = size;
    
    /*  _p_cookies auf neue Adresse setzen  */
    
    cookiejar  = (long *) 0x5a0L;
    *cookiejar = (long) dest_cop;
    
    Super ((void *) old_stack);
        
}  /*  move_cookiejar  */            



/*
    COOKIE_SIZE:  liefert die Grîsse des in-
                  stallierten Jars, d.h. die
                  Anzahl der maximal mîglichen
                  EintrÑge.
*/

long cookie_size (void)
{
    long old_stack, *cookiejar;
    
    
    /*  Zeiger auf Cookie Jar holen  */
    
    old_stack = Super (0L);
    cookiejar = *((long **) 0x5a0L);
    Super ((void *) old_stack);
    
    
    /*  Ist der Jar Åberhaupt vorhanden ?  */
    
    if (!cookiejar)
        return (0L);
        
    /*  suche den NULL-Cookie  */
    while (cookiejar[0])
        cookiejar = &(cookiejar[2]);
        
    return (cookiejar[1]);
    
}  /*  cookie_size  */



/*
    PRINT_COOKIEJAR:  gibt den Inhalt des Jars
                      auf die Standard-Ausgabe
                      aus.
*/

void print_cookiejar (void)
{
    long old_stack, *cookiejar;
    
    
    /*  Zeiger auf Cookie Jar holen  */
    
    old_stack = Super (0L);
    cookiejar = *((long **) 0x5a0L);
    Super ((void *) old_stack);
    
    /*  Ist der Jar Åberhaupt vorhanden ?  */
    
    if (!cookiejar)
        return;
        
    do
    {
        /*  Jar auf 'stdout' ausgeben  */
        
        printf ("%08lx    %08lx\n", 
        cookiejar[0], cookiejar[1]);
        
        cookiejar = &(cookiejar[2]);
        
    } while (cookiejar[0]);
    
}  /*  print_cookiejar  */


/*  Listing 2  */            

