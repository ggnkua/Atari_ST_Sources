DEFINITION MODULE FixFiles;

(*                             Von Michael H.                               *)
(*  portiert nach M-2 August '91 von Christian Felsch und Peter Oleski.     *)       
(*  Diese ISAM ist Public Domain und darf von jedem fÅr zivile Aufgaben     *)
(*  benutzt werden. Eine Nutzung fÅr militÑrische Zwecke ist untersagt !    *)
(*                         Diese ISAM ist Peace-Ware !                      *)
(*                         ---------------------------                      *)
(*  Diese ISAM darf verÑndert und erweitert werden. Bei guten Erweiterungen *)
(*  und Fehlern benachrichtigung bitte an uns senden.                       *)
(*  Die ISAM hat unsere Platte NICHT zerstîrt aber wir Åbernehmen keine     *)
(*  Verantwortung fÅr nichts.                                               *)
(*  Wir bitten aber, falls diese ISAM einmal eine Verwendung findet, uns    *)
(*  mit dem Satz ' ISAM by Jau-Team ' zu erwÑhnen.                          *)
(*  Wird mit dieser Bibliothek ein kommerzielles Programm erstellt, so ist  *)
(*  uns ein kostenloses Exemplar zuzusenden                                 *)
(*  Zu erreichen unter:                                                     *)
(*                                                                          *)
(*      E-Mail: Peter Oleski        oder   Christian Felsch @ HH (MausNet)  *)
(*  gelbe Post: Eiûendorfergrenzweg 83a     Bevenser Weg 18                 *)
(*                             2100 Hamburg 90                              *)


 (* Modul zur Verwaltung der Datendateien  *)
  
 (* ErlÑuterungen zu den zu Åbergebenden Variablen:       *)
  
 (*  I  : Eingabewerte vom Benutzer                       *)
 (*  o  : nur interne Statusinformationen werden geÑndert *)
 (*  O  : relevante Informationen werden zurÅckgeliefert  *)
  
  
 FROM SYSTEM      IMPORT LOC;
 FROM IsamGlobals IMPORT FixFile;


 PROCEDURE FixMake(VAR Datei      : FixFile;               (* O *)
                       FName      : ARRAY OF CHAR;         (* I *)
                       RecLen     : CARDINAL;              (* I *)
                       ZaehlStart : CARDINAL);             (* I *)
                       
  (* Kreiert neue Datendatei, max. Anzahl der Zugriffe in <ZaehlStand< *)
                                                   
                                                      
 PROCEDURE FixOpen(VAR Datei   : FixFile;                  (* O *)
                       FName   : ARRAY OF CHAR;            (* I *)
                       RecLen  : CARDINAL;                 (* I *)
                       MaxCount: CARDINAL);                (* I *)
                       
  (* ôffnet eine Datendatei *)
  

 PROCEDURE FixFlush(VAR Datei : FixFile);                  (* I/o *)
 
  (* FÅhrt ein Flush auf Datendatei aus *)
  
 
 PROCEDURE FixClose(VAR Datei : FixFile);                  (* I/o *)
 
  (* Schlieût eine Datendatei *)
  
 
 PROCEDURE FixErase(VAR Datei : FixFile);                  (* I/o *)
 
  (* Lîscht eine Datendatei *)
  

 PROCEDURE FixRename(VAR Datei : FixFile;                  (* I/O *)
                         fNeu  : ARRAY OF CHAR);           (* I *)
                         
  (* Benennt eine Datendatei um *)
  

 PROCEDURE FixNew(VAR Datei  : FixFile;                    (* I/o *)
                  VAR SatzNr : LONGINT);                   (* O *)
                  
  (* Legt einen neuen leeren Datensatz an *)
  

 PROCEDURE FixAdd(VAR Datei  : FixFile;                    (* I/o *)
                  VAR SatzNr : LONGINT;                    (* O *)
                  VAR Buffer : ARRAY OF LOC);              (* I *)
                  
  (* FÅgt einen neuen Datensatz in eine Datendatei ein *)


 PROCEDURE FixDel(VAR Datei  : FixFile;                    (* I/o *)
                      SatzNr : LONGINT);                   (* I *)
                      
  (* Lîscht einen Datensatz aus einer Datendatei *)


 PROCEDURE FixGet(VAR Datei  : FixFile;                    (* I/o *)
                      SatzNr : LONGINT;                    (* I *)
                  VAR Buffer : ARRAY OF LOC;               (* O *)
                      Anz    : CARDINAL);                  (* I *)
                      
  (* Liest <Anz>  DatensÑtze aus einer Datendatei *)


 PROCEDURE FixPut(VAR Datei  : FixFile;                    (* I/o *)
                      SatzNr : LONGINT;                    (* I *)
                  VAR Buffer : ARRAY OF LOC);              (* I *)
                  
  (* Schreibt einen Datensatz in eine Datendatei *)


 PROCEDURE FixSize(VAR Datei : FixFile): LONGINT;          (* I *)
 
  (* Liefert gesamte Grî·e einer Datendatei in Bytes *)


 PROCEDURE FixTotal(VAR Datei : FixFile) : LONGINT;        (* I *)
 
  (* Liefert Anzahl aller DatensÑtze (benutzt und unbenutz), inkl. Status *)


 PROCEDURE FixUsed(VAR Datei : FixFile) : LONGINT;         (* I *)
 
  (* Liefert Anzahl der benutzten DatensÑtze *)


 PROCEDURE FixCounter(VAR Datei : FixFile) : CARDINAL;     (* I *)
 
  (* Liefert den ZÑhlerstand fÅr Demo-Version *)


 PROCEDURE FixRecSize(DateiName : ARRAY OF CHAR) : LONGINT; (* I *)
 
  (* Liefert die Grî·e eines Datensatzes in Bytes *)


 PROCEDURE FixflushAll;


END FixFiles.