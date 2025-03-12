/* (c) 1992 MAXON Computer */

#include <aes.h>
#include <ctype.h>
#include <string.h>
#include <tos.h>


long DoRamSearch( long adr, char *string,
                  int forward, int wholeword,
                  int checkuplow )
{
   int      _do, i;
   char     *ptr, *strptr, *maxptr,
            *minptr, *str, *lastch, *contptr,
            prevch, nextch;
   long     sttop, tttop, oldspst, len;


   /* Variablen initialisieren */
   len    = strlen( string );
   _do    = 1;
   ptr    = (char*)adr + (forward ? 1L : -1L);

   oldspst = Super( (void*)1L )
             ? 0L : Super( (void*)0L );
   sttop  = * (long*) 1070L;
   tttop  = * (long*) 1444L;
   if( oldspst )
      Super( (void*)adr );

   str = Malloc( len + 1L );
   if( !str )
      return( -1L );
   strcpy( str, string );
   if( !checkuplow )
      for( i = 0; i < len; i++ )
         str[i] = toupper( str[i] );
   strptr = str;

   if( (long)ptr >= sttop &&
       (long)ptr < 0x1000000L && tttop )
      (long)ptr = (long)ptr - sttop + 0x1000000L;

   maxptr =
   (char*)( (( (long)ptr >= 0x1000000L && tttop )
             ? tttop : sttop) - 1L );
   minptr =
   (char*)( (( (long)ptr >= 0x1000000L && tttop )
             ? 0x1000000L : 0L) );
   lastch = &str[len-1];

   if( ptr > maxptr || ptr < minptr )
      return( -1L );

   graf_mouse( HOURGLASS, 0L );
   oldspst = Super( (void*)1L )
             ? 0L : Super( (void*)0L );


   /**********************************/
   /* Vorw„rts suchen mit            */
   /* Grož-/Kleinschreibung beachten */
   /**********************************/
   if( forward && checkuplow )
      do
      {
         /* Erstes Zeichen suchen */
         while( (*ptr != *strptr)&&(ptr < maxptr) )
            ++ptr;
   
         /* Erstes Zeichen gefunden */
         if( *ptr == *strptr )
         {
            /* Beim zweiten Zeichen weiter
               vergleichen */
            while( (ptr < maxptr) &&
                   (*ptr == *strptr) &&
                   (strptr != lastch) )
            {
               ++ptr;
               ++strptr;
            }

            /* String komplett gefunden */
            if( strptr == lastch && *ptr == *strptr )
            {
               /* Als ganzes Wort suchen */
               if( wholeword && ptr < maxptr )
               {
                  if( (long)ptr - len < 0x1000000L &&
                      (long)ptr >= 0x1000000L )
                     prevch =
                         *(char*)(sttop - ( 0x1000000L
                                - ((long)ptr - len)) );
                  else
                     prevch = ptr[-len];
                  nextch = ptr[1];

                  if( !isalnum( prevch ) &&
                      !isalnum( nextch ) )
                     _do = 0;
                  else
                     strptr = str;
               }
               else
                  _do = 0;
            }
            else
            {
               if( *ptr != *strptr )
                  strptr = str;
               else
                  ++strptr;
            }
         }


         if( ptr == maxptr && strptr != lastch )
         {
            /* Evtl. im TT-Ram weitersuchen */
            if( tttop && ((long)ptr < 0x1000000L) )
            {
               ptr    = (char*)0x1000000L;
               maxptr = (char*)(tttop - 1L);
            }
            else
               _do = 0;
         }
      }
      while( _do );



   /**********************************/
   /* Vorw„rts suchen ohne           */
   /* Grož-/Kleinschreibung beachten */
   /**********************************/
   if( forward && !checkuplow )
      do
      {
         /* Erstes Zeichen suchen */
         while( (toupper(*ptr) != *strptr) &&
                (ptr < maxptr) )
            ++ptr;
   
         /* Erstes Zeichen gefunden */
         if( toupper(*ptr) == *strptr )
         {
            /* Beim zweiten Zeichen weiter
               vergleichen */
            while( (ptr < maxptr) &&
                   (toupper(*ptr) == *strptr) &&
                   (strptr != lastch) )
            {
               ++ptr;
               ++strptr;
            }


            /* String komplett gefunden */
            if( strptr == lastch &&
                toupper(*ptr) == *strptr )
            {
               /* Als ganzes Wort suchen */
               if( wholeword && ptr < maxptr )
               {
                  if( (long)ptr - len < 0x1000000L &&
                      (long)ptr >= 0x1000000L )
                     prevch =
                         *(char*)(sttop - ( 0x1000000L
                                 - ((long)ptr - len)) );
                  else
                     prevch = ptr[-len];
                  nextch = ptr[1];

                  if( !isalnum( prevch ) &&
                      !isalnum( nextch ) )
                     _do = 0;
                  else
                     strptr = str;
               }
               else
                  _do = 0;
            }
            else
               if( *ptr != *strptr )
                  strptr = str;
               else
                  ++strptr;
         }


         if( ptr == maxptr && strptr != lastch )
         {
            /* Evtl. im TT-Ram weitersuchen */
            if( tttop && ((long)ptr < 0x1000000L) )
            {
               ptr    = (char*)0x1000000L;
               maxptr = (char*)(tttop - 1L);
            }
            else
               _do = 0;
         }
      }
      while( _do );



   /**********************************/
   /* Rckw„rts suchen mit           */
   /* Grož-/Kleinschreibung beachten */
   /**********************************/
   if( !forward && checkuplow )
      do
      {
         /* Erstes Zeichen suchen */
         while( (*ptr != *strptr)&&(ptr > minptr) )
            --ptr;

         /* Erstes Zeichen gefunden */
         if( *ptr == *strptr )
         {
            contptr =
                ptr > minptr ? ptr - 1L : minptr;

            /* Beim zweiten Zeichen weiter
               vergleichen */
            while( (*ptr == *strptr) &&
                   (strptr != lastch) )
            {
               ++ptr;
               if( (long)ptr == sttop )
                  (long)ptr = 0x1000000L;
               ++strptr;
            }


            /* String komplett gefunden */
            if( strptr == lastch && *ptr == *strptr )
            {
               /* Als ganzes Wort suchen */
               if( wholeword && ptr < maxptr )
               {
                  if( (long)ptr - len < 0x1000000L &&
                      (long)ptr >= 0x1000000L )
                     prevch =
                         *(char*)(sttop - ( 0x1000000L
                                 - ((long)ptr - len)) );
                  else
                     prevch = ptr[-len];
                  nextch = ptr[1];

                  if( !isalnum( prevch ) &&
                      !isalnum( nextch ) )
                     _do = 0;
                  else
                  {
                     strptr = str;
                     ptr    = contptr;
                  }
               }
               else
                  _do = 0;
            }
            else
            {
               if( *ptr != *strptr )
               {
                  strptr = str;
                  ptr    = contptr;
               }
               else
                  ++strptr;
            }
         }


         if( ptr == minptr && strptr != lastch )
         {
            /* Evtl. im ST-Ram weitersuchen */
            if( minptr )
            {
               ptr    = (char*)(sttop - 1L);
               minptr = 0L;
               maxptr = ptr;
            }
            else
               _do = 0;
         }
      }
      while( _do );



   /**********************************/
   /* Rckw„rts suchen ohne          */
   /* Grož-/Kleinschreibung beachten */
   /**********************************/
   if( !forward && !checkuplow )
      do
      {
         /* Erstes Zeichen suchen */
         while( (toupper(*ptr) != *strptr) &&
                (ptr > minptr) )
            --ptr;

         /* Erstes Zeichen gefunden */
         if( toupper(*ptr) == *strptr )
         {
            contptr =
                ptr > minptr ? ptr - 1L : minptr;

            /* Beim zweiten Zeichen weiter
               vergleichen */
            while( (toupper(*ptr) == *strptr) &&
                   (strptr != lastch) )
            {
               ++ptr;
               if( (long)ptr == sttop )
                  (long)ptr = 0x1000000L;
               ++strptr;
            }


            /* String komplett gefunden */
            if( strptr == lastch &&
                toupper(*ptr) == *strptr )
            {
               /* Als ganzes Wort suchen */
               if( wholeword && ptr < maxptr )
               {
                  if( (long)ptr - len < 0x1000000L &&
                      (long)ptr >= 0x1000000L )
                     prevch =
                         *(char*)(sttop - ( 0x1000000L
                                 - ((long)ptr - len)) );
                  else
                     prevch = ptr[-len];
                  nextch = ptr[1];

                  if( !isalnum( prevch ) &&
                      !isalnum( nextch ) )
                     _do = 0;
                  else
                  {
                     strptr = str;
                     ptr    = contptr;
                  }
               }
               else
                  _do = 0;
            }
            else
            {
               if( *ptr != *strptr )
               {
                  strptr = str;
                  ptr    = contptr;
               }
               else
                  ++strptr;
            }
         }


         if( ptr == minptr && strptr != lastch )
         {
            /* Evtl. im ST-Ram weitersuchen */
            if( minptr )
            {
               ptr    = (char*)(sttop - 1L);
               minptr = 0L;
               maxptr = ptr;
            }
            else
               _do = 0;
         }
      }
      while( _do );




   if( oldspst )
      Super( (void*)adr );

   graf_mouse( ARROW, 0L );


   /* Den Rckgabewert erzeugen */
   if( (ptr == maxptr || ptr == minptr) &&
       strptr != lastch )
      ptr = (char*)-1L;
   else
   {
      ptr -= len - 1;

      if( (long)ptr >= sttop && (long)ptr < 0x1000000L )
         (long)ptr = sttop - (0x1000000L - (long)ptr);
   }


   /* Speicher freigeben */
   Mfree( str );

   return( (long)ptr );
}
