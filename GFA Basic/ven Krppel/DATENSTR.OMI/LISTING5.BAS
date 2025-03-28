 '********************************************
 '*                Listing 5                 *
 '* Sven KrÅppel, 2.1.91, (c) MAXON Computer *
 '********************************************

 DEF PROC Ll_Verbinden(R Anfang1%,R Ende1%,Anfang2%,Ende2%)
   'HÑngt die durch Anfang2% und Ende2%
   'definierte Liste an die durch Anfang1% und
   'Ende1% definierte Liste.
   IF Anfang1%=0 THEN '   1. Liste ist leer.
      Anfang1%=Anfang2%' funktioniert auch,
      Ende1%=Ende2%'     wenn beide leer
   ELSE ' 1. Liste ist nicht leer
      IF Anfang2%<>0 THEN '2. Liste nicht leer
         Wl_Next%(Ende1%)=Anfang2%' verbinden
         Ende1%=Ende2%
      ENDIF
   ENDIF
 RETURN 'Ll_Verbinden

