#include <obdefs.h>
#include <osbind.h>
#include "insicn.h"

main()
{
   int x,y,w,h;
   long baum;          /* Anfangsadresse der Dialogbox-Objektstruktur */
   long ins_icn();     /* ICON-Einfgeroutine */

   appl_init();     /* bei AES anmelden */

   if (!rsrc_load("insicn.rsc")) /* Demo-RSC-Datei laden */
   {                             /* hat nicht funktioniert */
      appl_exit();               /* bei AES abmelden */
      return(0);                 /* Programm verlassen */
   }
   rsrc_gaddr(0,BAUM,&baum);     /* Adresse der Dialogbox */
   
   if (ins_icn("test.dat",baum,ICON)==-1L) /* Einfgen des ICONs */
      return(-1);                /* Bei Fehler -> Abbruch */

   form_center(baum,&x,&y,&w,&h); /* Box zentrtieren */
   objc_draw(baum,0,MAX_DEPTH,x,y,x+w,y+h); /* zeichnen */
   form_do(baum,0);                 /* Bearbeiten */
        
   clr_icn(baum,ICON);            /* Icon wieder l”schen */
   
   appl_exit();                   /* Applikation abmelden */
}

long ins_icn(name,tree,ob_index) /* Einfgeroutine fr Icons */
char *name;                      /* Dateiname des Icons */
long tree;                       /* Baumstrukturadresse */         
int ob_index;                    /* Objektnummer */
{
   int fd,i=-1;
   ICONBLK *icon;
   OBJECT obj, *ob;
   int *data, *mask;
   long block_size;
   char strin[30], *string;

   /* Speicherbereich in Gr”že eines ICONBLKs reservieren */
   icon= (ICONBLK*) Malloc((long)sizeof(ICONBLK)); 
   if (!icon) 
     return(-1L);   /* Nicht genug Speicher frei -> zurck */
   
   fd= Fopen(name,0);  /* Datei ”ffnen */

   Fread(fd,(long)sizeof(ICONBLK),icon); /* ICONBLK lesen */
   Fread(fd,(long)sizeof(OBJECT),&obj);  /* OBJECT-Strukur lesen */
   /* Ermitteln der Gr”že der Datenmenge von DATA und MASKE */
   block_size = (icon->ib_wicon)/8*(icon->ib_hicon); 
   mask= (int*) Malloc(block_size);   /* Maskenspeicher reservieren */

   if (!mask) /* kein Speicher frei */
   {
      Mfree(icon); /* anderen Speicher wieder freigeben */
      return(-1L);  /* zurck */
   }
   data= (int*) Malloc(block_size); /* Speicher fr Bilddaten */
   if (!data)                       /* Genug Speicher da ? */ 
   {
      Mfree(icon);                  /* Nein, vorher reservierten */
      Mfree(mask);                  /* Speicher wieder freigeben */
      return(-1L);
   }
   Fread(fd,block_size,mask);       /* Lesen von Maske und Bild */
   Fread(fd,block_size,data);
   
   do                               /* Icon-String einlesen */
   {
      i++;
      Fread(fd,1L,&strin[i]);
   }while (strin[i]);               /* I = L„nge des Strings */
   string= (char*) Malloc((long)i); /* Speicher reservieren */

   if (!string)                     /* Speicher da ? */
   {
      Mfree(icon);                  /* Nein */
      Mfree(mask);                  /* Speicher */
      Mfree(data);                  /* freigeben */
      return(-1L);
   }
   strcpy(string,strin);            /* String in Speicher kopieren */

   Fclose(fd);                      /* Datei schliežen */
 
   ob= (OBJECT*) (tree+24*ob_index); /* Adresse des Objekts */
   ob->ob_spec= (char*) icon;        /* ICONBLK eintragen */
   ob->ob_width = obj.ob_width;      /* Objektumrandung */
   ob->ob_height = obj.ob_height;    /* aus geladener OBJECT- */
   ob->ob_state = obj.ob_state;      /* struktur bernehmen */
   ob->ob_flags = obj.ob_flags;      
   icon->ib_pmask= mask;             /* Maskendaten eintragen */
   icon->ib_pdata= data;             /* Bilddaten eintragen */
   icon->ib_ptext= string;           /* String eintragen */

   return((long)icon);               /* Adresse auf Iconblk zurckgeben */
}

clr_icn(tree,ob_index) /* L”scht alle reservierten Speicher */
long tree;             /* ACHTUNG: restauriert OBJEKT nicht !! */
int ob_index;          /* Danach kein Aufruf des Objektes mehr !!! */
{
   ICONBLK *icon;      /* Zeiger auf Iconblk */
   OBJECT *obj;        /* Zeiger auf Objekt */

   obj= (OBJECT*) (tree+24*ob_index); /* Objektadresse */
   icon= (ICONBLK*) obj->ob_spec;     /* ICONBLK-Adresse */
   Mfree(icon->ib_pmask);             /* Maskenspeicher freigeben */
   Mfree(icon->ib_pdata);             /* Bilddaten freigeben */
   Mfree(icon->ib_ptext);             /* String freigeben */
   Mfree(icon);                       /* ICONBLK freigeben */
}
