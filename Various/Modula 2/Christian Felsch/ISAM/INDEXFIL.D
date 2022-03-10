DEFINITION MODULE IndexFiles;

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


 (* Modul zur Verwaltung der Indexdateien    *)
 
 (* ErlÑuterungen zu den zu Åbergebenden Variablen:       *)
 
 (*  I  : Eingabewerte vom Benutzer                       *)
 (*  o  : nur interne Statusinformationen werden geÑndert *)
 (*  O  : relevante Informationen werden zurÅckgeliefert  *)
 
 
 FROM IsamGlobals IMPORT IndexType, IdxFile,IsamKeyStr;
 FROM SYSTEM      IMPORT BYTE;
 
 
 PROCEDURE IndexMake(VAR Index  : IdxFile;                 (* O *)
                         FName  : ARRAY OF CHAR;           (* I *)
                         KeyLen : BYTE;                    (* I *)
                         Typ    : IndexType);              (* I *)

  (* Kreiert neue Indexdatei *)
  
  
 PROCEDURE IndexOpen(VAR Index  : IdxFile;                 (* O *)
                         FName  : ARRAY OF CHAR;           (* I *) 
                         KeyLen : BYTE;                    (* I *)
                         Typ    : IndexType);              (* I *)

  (* ôffnet Indexdatei *)
  
  
 PROCEDURE IndexReset(VAR Index : IdxFile);                (* I/o *)

  (* Ein folgendes IndexNext liefert den ersten, ein folgendes IndexPrev *)
  (* den letzten Index. *)
  
  
 PROCEDURE IndexFlush(VAR Index : IdxFile);                (* I/o *)

  (* FÅhrt ein Flush auf Indexdatei aus *)


 PROCEDURE IndexClose(VAR Index : IdxFile);                (* I *)

  (* Schlieût Indexdatei *)
  
  
 PROCEDURE IndexErase(VAR Index : IdxFile);                (* I *)

  (* Lîscht Indexdatei *)
  
  
 PROCEDURE IndexAdd(VAR Index      : IdxFile;              (* I/o *)
                        DataRecNum : LONGINT;              (* I *)
                        ProcKey    : ARRAY OF CHAR);       (* I *)

  (* FÅgt einen neuen Index ein *)
  

 PROCEDURE IndexDel(VAR Index      : IdxFile;              (* I/o *)
                        DataRecNum : LONGINT;              (* I *)
                        ProcKey    : ARRAY OF CHAR);       (* I *)

  (* Lîscht einen Index. Bei Dups: man muû erst die DataRecNum ermitteln *)
  (* und dann Åbergeben um den richtigen von mehreren gleichen ProcKeys  *)
  (* zu lîschen . *)
  

 PROCEDURE IndexFind(VAR Index      : IdxFile;             (* I/o *)
                     VAR DataRecNum : LONGINT;             (* O *)
                         ProcKey    : IsamKeyStr);         (* I *)

  (* Findet ein Listeneintrag. Der Eintrag muû garantiert in der    *)
  (* Liste enthalten sein, sonst gibt es einen Fehler !             *)
  (* Bei Dups wird der passende Index mit der kleinsten DataRecNum  *)
  (* zurÅckgeliefert. *)
  

 PROCEDURE IndexRefind(VAR Index      : IdxFile;           (* I/o *)
                           DataRecNum : LONGINT;           (* I *)
                           ProcKey    : IsamKeyStr);       (* I *)

  (* Wie IndexFind, zuzÑtzlich wird DataRecNum berÅcksichtigt.  *)
  (* Dient zum Wiederaufsetzen an einem zuvor gefundenen Index. *)
  (* Wenn der IndexZeiger durch z.B. ein Abspeichern verbogen ist *)
  (* kann man ihn hiermit wieder auf den vorherigen Index setzen  *)


 PROCEDURE IndexSearch(VAR Index      : IdxFile;           (* I/o *)
                       VAR DataRecNum : LONGINT;           (* O *)
                       VAR ProcKey    : ARRAY OF CHAR);    (* I/O *)

  (* Sucht nach einem Eintrag in der Liste. Wird keiner gefunden  *)
  (* wird derjenige zurÅckgegeben, der alphabet. nach dem gesuchten folgt.  *)
  (* Es reicht den Anfang vom ProcKey anzugeben. *)
  (* Sollte der Gesuchte nach dem Letzten der Liste folgen *)
  (* so wird ProcKey nicht geÑndert und fFileNotFound wird geliefert *)
  

 PROCEDURE IndexNext(VAR Index      : IdxFile;             (* I/o *)
                     VAR DataRecNum : LONGINT;             (* O *)
                     VAR ProcKey    : ARRAY OF CHAR);      (* O *)

  (* Liefert den alphabet. Nachfolger zurÅck. Zuvor muû mit IndexFind/Search *)
  (* ( und ggf. IndexNext/Prev ) der interne Zeiger gesetzt werden. *)
                                            

 PROCEDURE IndexPrev(VAR Index      : IdxFile;             (* I/o *)
                     VAR DataRecNum : LONGINT;             (* O *)
                     VAR ProcKey    : ARRAY OF CHAR);      (* O *)

  (* Liefert den alphabet. VorgÑnger zurÅck. Zuvor muû mit IndexFind/Search *)
  (* ( und ggf. IndexNext/Prev ) der interne Zeiger gesetzt werden. *)


END IndexFiles.