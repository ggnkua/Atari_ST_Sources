 '*****************************************************************************
 '*                                                                           *
 '*        Programm zur Verwaltung des abstrakten Datentyps 'Person'          *
 '*                                                                           *
 '* (c) 1990 Sven Krppel                                                     *
 '*                                                                           *
 '*****************************************************************************

 ' Initialisierungen der Variable Personendaten vom abstrakten Datentyp Person
 Personendaten_Maxanzahl#=100' Maximale Personenzahl, die gespeichert wird
 DIM Personendaten_Name$(Personendaten_Maxanzahl#-1)
 DIM Personendaten_Vorname$(Personendaten_Maxanzahl#-1)
 DIM Personendaten_Alter%(Personendaten_Maxanzahl#-1)
 DIM Personendaten_Telnr%L(Personendaten_Maxanzahl#-1)

 'Hauptprogramm (nur zu Test- und Demonstrationszwecken)
 Speichere_Personendaten(0,"Mustermann","Paul",45,4156)
 Speichere_Personendaten(1,"Schuster","Klara",38,6138)
 Speichere_Personendaten(2,"Hermanns","Ira",18,2345)
 Kopiere_Personendaten(2,3)
 Speichere_Personendaten(3,"","Tanja",20,0)' Die „ltere Schwester von Ira
 Vertausche_Personendaten(0,1)

 FOR I%=0 TO 3
   Lies_Personendaten(I%,N$,V$,A%,T%L)
   PRINT N$,V$,A%,T%L
 NEXT I%
 END

 '*****************************************************************************
 ' Der Zugriff auf die Personendaten sollte nur ber die folgenden Prozeduren
 ' erfolgen
 '*****************************************************************************

 DEF PROC Speichere_Personendaten(Index%,Name$,Vorname$,Alter%,Telnr%L)
 ' Schreibt die bergebenen Werte in die Elemente mit dem Index Index% von Feld
 ' Personendaten. Leerstrings bei den Stringkomponenten und der Wert null
 ' bei den Zahlenwerten bedeuten, daž die Komponente nicht ver„ndert wird.

   IF Index%>=0 AND Index%<Personendaten_Maxanzahl# THEN
      IF Name$<>"" THEN Personendaten_Name$(Index%)=Name$
      IF Vorname$<>"" THEN Personendaten_Vorname$(Index%)=Vorname$
      IF Alter%<>0 THEN Personendaten_Alter%(Index%)=Alter%
      IF Telnr%L<>0 THEN Personendaten_Telnr%L(Index%)=Telnr%L
   ELSE
      PRINT "Index aužerhalb des zul„ssigen Bereiches"
   ENDIF
 RETURN ' Speichere_Personendaten


 DEF PROC Lies_Personendaten(Index%,R Name$,R Vorname$,R Alter%,R Telnr%L)
 ' Gibt die Werte in den Komponenten des Elementes mit dem Index Index%
 ' von Feld Personenendaten zurck.

   IF Index%>=0 AND Index%<Personendaten_Maxanzahl# THEN
      Name$=Personendaten_Name$(Index%)
      Vorname$=Personendaten_Vorname$(Index%)
      Alter%=Personendaten_Alter%(Index%)
      Telnr%L=Personendaten_Telnr%L(Index%)
   ELSE
      PRINT "Index aužerhalb des zul„ssigen Bereiches"
   ENDIF
 RETURN ' Lies_Personendaten


 DEF PROC Kopiere_Personendaten(Quell_Index%,Ziel_Index%)
 ' Kopiert s„mtliche Komponenten an Stelle Quell_Index% nach Ziel_Index%

   IF Quell_Index%>=0 AND Quell_Index%<Personendaten_Maxanzahl# THEN
     IF Ziel_Index%>=0 AND Ziel_Index%<Personendaten_Maxanzahl# THEN
       Personendaten_Name$(Ziel_Index%)=Personendaten_Name$(Quell_Index%)
       Personendaten_Vorname$(Ziel_Index%)=Personendaten_Vorname$(Quell_Index%)
       Personendaten_Alter%(Ziel_Index%)=Personendaten_Alter%(Quell_Index%)
       Personendaten_Telnr%L(Ziel_Index%)=Personendaten_Telnr%L(Quell_Index%)
     ELSE
       PRINT "Zielindex aužerhalb des zul„ssigen Bereiches"
     ENDIF
   ELSE
     PRINT "Quellindex aužerhalb des zul„ssigen Bereiches"
   ENDIF
 RETURN ' Kopiere_Personendaten


 DEF PROC Vertausche_Personendaten(Index1%,Index2%)
 ' Vertauscht s„mtliche Komponenten der Stellen Index1% und Index2%

   LOCAL Name$,Vorname$,Alter%,Telnr%L
   IF Index1%>=0 AND Index1%<Personendaten_Maxanzahl# THEN
     IF Index2%>=0 AND Index2%<Personendaten_Maxanzahl# THEN
       Name$=Personendaten_Name$(Index2%)
       Vorname$=Personendaten_Vorname$(Index2%)
       Alter%=Personendaten_Alter%(Index2%)
       Telnr%L=Personendaten_Telnr%L(Index2%)

       Personendaten_Name$(Index2%)=Personendaten_Name$(Index1%)
       Personendaten_Vorname$(Index2%)=Personendaten_Vorname$(Index1%)
       Personendaten_Alter%(Index2%)=Personendaten_Alter%(Index1%)
       Personendaten_Telnr%L(Index2%)=Personendaten_Telnr%L(Index1%)

       Personendaten_Name$(Index1%)=Name$
       Personendaten_Vorname$(Index1%)=Vorname$
       Personendaten_Alter%(Index1%)=Alter%
       Personendaten_Telnr%L(Index1%)=Telnr%L
     ELSE
       PRINT "Index2 aužerhalb des zul„ssigen Bereiches"
     ENDIF
   ELSE
     PRINT "Index1 aužerhalb des zul„ssigen Bereiches"
   ENDIF
 RETURN ' Vertausche_Personendaten

