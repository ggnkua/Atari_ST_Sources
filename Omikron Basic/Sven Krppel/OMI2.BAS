 '*****************************************************************************
 '*                                                                           *
 '*  Operationen auf ungeordnete lineare Listen im Feld Wl. Diese Routinen    *
 '*  betreffen nur die Verzeigerung. Infokomponenten werden nicht berÅhrt.    *
 '*  (!) Die Prozeduren enthalten keine Mechanismen gegen fehlerhafte öber-   *
 '*  gabeparameter.                                                           *
 '*                                                                           *
 '*****************************************************************************

 DEF PROC Ll_Anhaengen(R Anfang%,R Ende%,P%)
   'HÑngt das Element, auf das P% zeigt, an das Ende der Liste an, die durch
   'Anfang% und Ende% charakterisiert ist.
   'Um unabhÑngig von den Infokomponenten zu bleiben, muû der Speicherplatz
   'fÅr das Element vor dem Aufruf mit Allocate_Wl(P%) angefordert worden sein.
   IF Anfang%=0 THEN Anfang%=P%' Liste war bislang leer
   Wl_Next%(P%)=0'    Ende der verlÑngerten Liste markieren
   Wl_Next%(Ende%)=P%' neues Element anhÑngen
   Ende%=P%'          Cursor auf das Listenende umbiegen
 RETURN 'Ll_Anhaengen

 DEF PROC Ll_Einfuegen_Am_Kopf(R Anfang%,R Ende%,P%)
   'FÅgt das Element, auf das P% zeigt, am Kopf der durch Anfang% und Ende%
   'charakterisierten Liste ein.
   'Um unabhÑngig von den Infokomponenten zu bleiben, muû der Speicherplatz
   'fÅr das Element vor dem Aufruf mit Allocate_Wl(P%) angefordert worden sein.
   IF Ende%=0 THEN Ende%=P%' Liste war bislang leer
   Wl_Next%(P%)=Anfang%
   Anfang%=P%
 RETURN 'Ll_Einfuegen_Am_Kopf

 DEF PROC Ll_Kopf_Loeschen(R Anfang%,R Ende%)
   'Das erste Listenelement wird gelîscht.
   LOCAL P%
   P%=Anfang%'               Listenkopf zwischenspeichern
   Anfang%=Wl_Next%(Anfang%)' Listenkopf neusetzen
   Deallocate_Wl(P%)'       Speicherplatz freigeben
   IF Ende%=P% THEN Ende%=0'  Liste wird leer
 RETURN 'Ll_kopf_loeschen

 DEF PROC Ll_Ende_Loeschen(R Anfang%,R Ende%)
   'Das letzte Listenelement wird gelîscht.
   LOCAL P%
   ' Liste durchlaufen, um das vorletzte Element zu suchen
   Wl_Next%(0)=Anfang%' Trick: starte mit leerem nullten Element
   P%=0
   WHILE Wl_Next%(P%)<>Ende%
      P%=Wl_Next%(P%)
   WEND
   'P% zeigt nun auf den VorgÑnger von Ende
   Deallocate_Wl(Ende%)' Freigabe des Speicherplatzes
   Wl_Next%(P%)=0' neues Listenende markieren
   Ende%=P%' Zeiger auf neues Listenende
   IF Ende%=0 THEN Anfang%=0' Liste war leer oder enthielt nur noch ein Element
 RETURN 'Ll_Ende_loeschen

