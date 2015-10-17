MODULE HDPack;
(* Optimiere Festplattenbelegung:
   - Sortiere Verzeichnisse so, daû Unterverzeichnisse vor den Files stehen
   - Speichere alle (Unter-)Verzeichnisse ab dem 'Anfang' der Festplatte
   - Speichere alle Datenfiles ab dem 'Ende' der Festplatte

   Florian Matthes 18.10.1987  (TDI-Modula Version 3.0)
   Thomas Tempelmann 6.4.88    (Anpassung f. Megamax M-2 V1)
*)

IMPORT TOSIO;
FROM SYSTEM IMPORT ADR, ADDRESS, TSIZE, VAL;
FROM InOut  IMPORT WriteCard, WriteString, WriteLn, Write, Read;
IMPORT BIOS;

CONST (* Spezielle EintrÑge in der FAT:                                   *)
      FreeCluster   = 0;         (* dieser Cluster ist unbelegt           *)
      FirstCluster  = 2;         (* Offset zur Umwandlung Cluster-Sektor  *)
      BadCluster    = 0FFF7H;    (* dieser Cluster ist defekt             *)
                                 (* z.B. Plattenfehler (nicht verwenden)  *)
      EOFCluster    = 0FFF8H;    (* Cluster mit diesem oder einem hîheren *)
                                 (* Index sind der letzte Cluster eines   *)
                                 (* Files                                 *)
      MaxPhysCluster= 03FFFH;    (* maximale Clustergrîûe fÅr HDPack      *)
                                 (* ==> FAT ist kleiner als 64K           *)
      MaxCluster    = 0FFFFH;    (* theoretisches Maximum und auch        *)
                                 (* von ATARI-BIOS tatsÑchlich erwartetes *)
                                 (* EOFCluster                            *)
                              
      MaxDirectoryBlocks = 64;   (* beschrÑnkt Sektorgrîûe in HDPack auf  *)
                                 (* 64*TSIZE(DirectoryRecord)= 64K        *)
                              
      (* der Inhalt des ersten Buchstabens eines Filenamens in einem      *)
      (* Directory kennzeichnet dessen Typ:                               *)
      FreeName      = 0H;        (* Eintrag noch nie benutzt              *)
      UnusedName    = 0E5H;      (* Eintrag nicht mehr benutzt            *)
      SpecialName   = 02EH;      (* = ORD('.') reservierte Namen:         *)
                                 (* '.'   zeigt auf lfd. Directory        *)
                                 (* '..'  zeigt auf VaterDirectory        *)

TYPE ClusterIndex = [0..MaxCluster];
     ClusterIndex8086 = CARDINAL;
                    (* Wie bei 80xxx Prozessoren: H und L-Byte vertauscht *)
     attributset =  SET OF (readonlyattr,
                            hiddenattr,
                            systemattr,
                            volumeattr,
                            subdirattr,  (* dieses File ist ein Directory *)
                            archivattr);
     DirectoryRecord    = RECORD
                            Name        : ARRAY[0..10] OF CHAR;
                                                (* Filename und Extension *)
                            Attr        : attributset;
                                                (* Typ des Files          *)
                            res         : ARRAY[0..13] OF CHAR;
                                                (* reserviert             *)
                            StartCluster: ClusterIndex;
                                                (* 1. Cluster des Files   *)
                            Size        : LONGCARD;
                                                (* Filegrîûe in Bytes     *)
                          END;
     DirectoryArray     = ARRAY[0..MaxDirectoryBlocks-1] OF DirectoryRecord;
                          (* Struktur eines Sektors in einem Directory    *)
  
VAR (* Die 'File Allocation Table' enthÑlt folgende Informationen:
       Index 0   Format Version
             1   unbenutzt
             2..MaxPhysCluster  Belegung des jeweiligen Clusters
       OrgFAT : FAT vor dem Optimieren
       NewFAT : FAT nach dem Optimieren
    *)
    OrgFAT, NewFAT           : ARRAY [0..MaxPhysCluster] OF ClusterIndex8086;
    NewPos, OldPos           : ARRAY [0..MaxPhysCluster] OF ClusterIndex;
    (* NewPos[i] liefert die momentane Position des ehemals i-ten Cluster
       OldPos[i] liefert die ehemalige Position des momentan i-ten Cluster
    *)
    BPBPtr                   : BIOS.BPBPtr;
    (* Zeiger auf BIOS Parameterblock fÅr dev. Die Deklaration in BIOS ist:
                    POINTER TO RECORD
                                 recsiz, clsiz, clsizb, rdlen, fsiz,
                                 fatrec, datrec, numcl, bflags: CARDINAL;
                               END;
     *)
    dev                      : CARDINAL;(* GerÑtenummer 0 = 'A:', 1 ='B:' *)
    (* aus BPBPtr^ abgeleitete Grîûen:                                    *)
    SectorsPerCluster        : CARDINAL;
    FirstDataSector          : CARDINAL;
    DirectoryRecordsPerSector: CARDINAL;
    FirstDirectorySector     : CARDINAL;
  
VAR CH:CHAR;

  PROCEDURE Abort(x: ARRAY OF CHAR; nochanges: BOOLEAN);
  (* Programmabbruch mit Fehlermeldung
  *)
  BEGIN
    WriteLn; WriteString(x); WriteLn;
    IF nochanges THEN
      WriteString('Keine énderungen auf Platte durchgefÅhrt.');
    ELSE
      WriteString('Leider sind wahrscheinlich einige Files zerstîrt worden.');
    END;
    WriteLn;
    WriteString('weiter mit einer beliebigen Taste...'); WriteLn;
    Read(CH);
    HALT;  (* Beende ProgrammausfÅhrung mit Fehlermeldung *)
  END Abort;

  PROCEDURE SwapLH(x:CARDINAL): CARDINAL;
  (* Tausche Low und High-Byte (Umwandlung zwischen 80xx - 68000 Format)
  *)
  BEGIN
    RETURN 256 * (x MOD 256) + (x DIV 256)
  END SwapLH;

  PROCEDURE ClusterToSector(x: ClusterIndex): CARDINAL;
  (* Berechne den ersten Sektor, in dem der Cluster x beginnt
  *)
  BEGIN
    RETURN (x-FirstCluster) * SectorsPerCluster + FirstDataSector;
  END ClusterToSector;

  PROCEDURE SectorToCluster(x: CARDINAL): ClusterIndex;
  (* Berechne den Cluster, in dem sich der Sektor x befindet
  *)
  BEGIN
    RETURN (x-FirstDataSector) DIV SectorsPerCluster + FirstCluster;
  END SectorToCluster;

  PROCEDURE Next(x:ClusterIndex): ClusterIndex;
  (* liefere den Nachfolger des Clusters gemÑû FAT
  *)
  BEGIN
    RETURN SwapLH(OrgFAT[x]);
  END Next;

  PROCEDURE ReadAbs(buf          : ADDRESS;  (* in diesen Puffer         *)
                    count        : CARDINAL; (* Anzahl der Sektoren      *)
                    recno        : CARDINAL; (* Index erster Sektor      *)
                    VAR errorcode: CARDINAL);(* BIOS-Erfolgsmeldung      *)
  BEGIN
    errorcode:= VAL (CARDINAL,BIOS.RWAbs(BIOS.Read,buf,count,recno,dev));
  END ReadAbs;

  PROCEDURE WriteAbs(buf         : ADDRESS;  (* in diesen Puffer         *)
                    count        : CARDINAL; (* Anzahl der Sektoren      *)
                    recno        : CARDINAL; (* Index erster Sektor      *)
                    VAR errorcode: CARDINAL);(* BIOS-Erfolgsmeldung      *)
  BEGIN
    errorcode:= VAL (CARDINAL,BIOS.RWAbs(BIOS.Write,buf,count,recno,dev));
  END WriteAbs;

  PROCEDURE LocateDirectoryRecord(Cluster, Index  : CARDINAL;
                              VAR Sector, Offset  : CARDINAL): BOOLEAN;
  (* Lokalisiere indizierten Directory-Eintrag auf der Platte. Beachte
     bereits stattgefundene Tauschoperationen.
     Das Funktionsergebnis ist FALSE, falls dieser Eintrag nicht existiert.
     Eingabe:
       Cluster:  1. Cluster des zu bearbeitenden Directories (Position
                 vor dem Optimieren). Ist Cluster = 0, so handelt es sich
                 um das Wurzelverzeichnis.
       Index  :  Index des gewÅnschten Eintrages (ab 0 gezÑhlt)
     Ausgabe:
       Sector :  Sektor, in dem sich der Eintrag auf Platte befindet
       Offset :  Index des Eintrages in diesem Sector (ab 0 gezÑhlt)
     Beispiel :
       LocateDirectoryRecord(1234, 15, sec, offs)
       bestimmt den Sektor, in dem der 16. Filenamen des Unterverzeichnisses
       steht, das im Cluster 1234 beginnt. Innerhalb dieses Sektors (sec)
       steht der Filenamen an der Position offs.
   *)
  BEGIN
    IF Cluster = 0 THEN                (* Suche im Wurzelverzeichnis      *)
      Sector:= Index DIV DirectoryRecordsPerSector;
      IF Sector+1>BPBPtr^.rdlen THEN   (* nicht Åber das Ende hinausgehen *)
        RETURN FALSE
      END;
      INC(Sector, FirstDirectorySector);
    ELSE
      LOOP                        (* durchlaufe das Directory sektorweise *)
        IF Cluster>= EOFCluster THEN   (* nicht Åber das Ende hinausgehen *)
          RETURN FALSE
        END;
        IF Index<DirectoryRecordsPerSector*SectorsPerCluster THEN
          EXIT;
        END;
        Cluster:= Next(Cluster);
        DEC(Index, DirectoryRecordsPerSector*SectorsPerCluster);
      END;
      Sector:= ClusterToSector(NewPos[Cluster]) +
               Index DIV DirectoryRecordsPerSector;
    END;
    Offset:= Index MOD DirectoryRecordsPerSector;
    RETURN TRUE;
  END LocateDirectoryRecord;

  PROCEDURE GetDirectoryRecord(Cluster: CARDINAL;
                               Index  : CARDINAL;
                               VAR r  : DirectoryRecord): BOOLEAN;
  (* Hole Eintrag r mit diesem Index (0...).
     Ergebnis = FALSE, falls dieser Eintrag nicht existiert.
  *)
     VAR Sector, Offset : CARDINAL;
         DirectorySector: DirectoryArray;
         errorcode      : CARDINAL;
  BEGIN
    IF LocateDirectoryRecord(Cluster, Index, Sector, Offset) THEN
      ReadAbs(ADR(DirectorySector),1,Sector,errorcode);
      r:= DirectorySector[Offset];
      RETURN (errorcode=0) AND (ORD(r.Name[0]) # FreeName);
    ELSE
      RETURN FALSE;
    END;
  END GetDirectoryRecord;

  PROCEDURE PutDirectoryRecord(Cluster: CARDINAL;
                               Index  : CARDINAL;
                               r      : DirectoryRecord): BOOLEAN;
  (* Schreibe Eintrag mit diesem Index (0...).
     Ergebnis = FALSE, falls dieser Eintrag nicht existiert.
  *)
     VAR Sector, Offset : CARDINAL;
         DirectorySector: DirectoryArray;
         errorcode      : CARDINAL;
  BEGIN
    IF LocateDirectoryRecord(Cluster, Index, Sector, Offset) THEN
      ReadAbs(ADR(DirectorySector),1,Sector,errorcode);
      IF errorcode#0 THEN
        RETURN FALSE;
      END;
      DirectorySector[Offset]:= r;
      WriteAbs(ADR(DirectorySector),1,Sector,errorcode);
      RETURN errorcode=0;
    ELSE
      RETURN FALSE;
    END;
  END PutDirectoryRecord;

  PROCEDURE SortDirectory(StartCl: CARDINAL);
  (* Sortiere (Unter-)Verzeichnisse so, daû Unterverzeichnisnamen vor
     den 'normalen' Filenamen auftreten: Dabei ist kein Update der FAT
     nîtig, da alle Vertauschungen innerhalb des Files stattfinden.
     Sortieralgorithmus: Direktes EinfÅgen
  *)
    VAR r,r2   : DirectoryRecord;
        i,j,x,y: CARDINAL;
  BEGIN
    (* ZunÑchst rekursiv alle Sîhne sortieren: *)
    i:= 0;
    WHILE GetDirectoryRecord(StartCl,i,r) DO
      WITH r DO
        x:= ORD(Name[0]);
        IF (x <> UnusedName) AND (x <> SpecialName) AND
           (subdirattr IN Attr) THEN
          SortDirectory(SwapLH(StartCluster));
        END;
      END;
      INC(i);
    END; (* WHILE *)
 
    (* jetzt eigenes Directory sortieren: *)
    i:= 0;
    WHILE GetDirectoryRecord(StartCl,i,r) DO
      WITH r DO
       x:= ORD(Name[0]);
        IF (x <> UnusedName) AND (x <> SpecialName) AND
          NOT(subdirattr IN Attr) THEN
          (* i zeigt auf den ersten Eintrag im Directory, der keinen
             Unterverzeichnisnamen enthÑlt
          *)
          j:= i+1;
          LOOP
            IF NOT GetDirectoryRecord(StartCl,j,r2) THEN
              RETURN;
              (* Sortierung beendet, da kein Unterverzeichniseintrag
                 mehr gefunden wurde.
               *)
            END;
            y:= ORD(r2.Name[0]);
            IF (y <> UnusedName) AND (y <> SpecialName)
            AND (subdirattr IN r2.Attr) THEN
              (* j zeigt auf den ersten Unterverzeichnisnamen nach i
              *)
              WriteString('Tausche Directory-EintrÑge: ');
              WriteString(Name); WriteString(' mit ');
              WriteString(r2.Name); WriteLn;
              IF NOT PutDirectoryRecord(StartCl, j, r) THEN
                WriteString(r.Name);
                WriteString(" kann nicht geschrieben werden ");
                WriteLn; Read (CH); RETURN;
              ELSIF NOT PutDirectoryRecord(StartCl, i, r2) THEN
                WriteString(r2.Name);
                WriteString(" kann nicht geschrieben werden ");
                WriteLn; Read (CH); RETURN;
              END;
              EXIT;
            END;
            INC(j);
          END;
        END; (* IF *)
      END; (* WITH *)
      INC(i);
    END; (* WHILE *)
  END SortDirectory;

  PROCEDURE CountFree(): CARDINAL;
  (* zÑhle die unbelegten Cluster auf der Platte
  *)
     VAR i,Free: CARDINAL;
  BEGIN
    Free:= 0;
    FOR i:= FirstCluster TO BPBPtr^.numcl-1 DO
      IF OrgFAT[i]=FreeCluster THEN INC(Free); END;
    END;
    RETURN Free;
  END CountFree;

  (* Die folgenden Variablen werden global von der Prozedur MoveFile
     verÑndert:
  *)
  VAR DestCluster         : ClusterIndex; (* Ziel fÅr nÑchsten Cluster    *)
      FirstFreeDestCluster: ClusterIndex; (* Ziel fÅr ersten Datencluster *)

  PROCEDURE MoveFile(Cluster: CARDINAL);
  (* Tausche alle Cluster des Files mit den Clustern ab DestCluster,
     Als Seiteneffekt wird DestCluster erhîht und Cluster in NewFAT
     verkettet.
  *)
    TYPE Operation = (wr,rd);

    VAR SourceCluster: ClusterIndex; (* tatsÑchliche Position fÅr Cluster *)
        OldDest      : ClusterIndex; (* ehemalige Position fÅr DestCluster*)
        Predecessor  : ClusterIndex; (* zuletzt geschriebener Cluster     *)
        Current      : ClusterIndex; (* ehemalige Position lfd. Cluster   *)
        A,B          : DirectoryArray; (* Puffer fÅr je einen Cluster     *)

     PROCEDURE OK(Op   : Operation;
                  VAR X: DirectoryArray;
                     Cl: ClusterIndex): BOOLEAN;
       VAR err: CARDINAL;
       
     BEGIN
       IF Op = rd THEN
         ReadAbs(ADR(X), SectorsPerCluster, ClusterToSector(Cl), err);
         IF err#0 THEN
           WriteString('Warnung: Fehler beim Lesen von Cluster ');
           WriteCard(Cl,1);
           WriteString(' (Cluster nicht verschoben) ');
           Read (CH)
         END;
       ELSE
         WriteAbs(ADR(X), SectorsPerCluster, ClusterToSector(Cl), err);
         IF err#0 THEN
           WriteString('Warnung: Fehler beim Schreiben von Cluster ');
           WriteCard(Cl,1);
           WriteString(' (Cluster nicht verschoben) ');
           Read (CH)
         END;
       END;
       RETURN err=0;
     END OK;
    
  BEGIN
    Predecessor:= 0;
    WHILE Cluster<EOFCluster DO
      LOOP
       (* Lasse defekte Cluster als Ziel aus: *)
        WHILE SwapLH(OrgFAT[DestCluster])=BadCluster DO
          INC(DestCluster)
        END;
        IF DestCluster<BPBPtr^.numcl THEN EXIT END;
        (* sollte eigentlich nicht passieren: *)
        WriteLn;
        WriteString('Warnung: Zu wenige freie Cluster ');
        WriteLn;
        Read (CH);
        IF FirstFreeDestCluster = 0 THEN
          (* vermeide Endlosschleife: *)
          Abort('Fataler Fehler: Keine freien Cluster mehr gefunden', FALSE);
        ELSE
          DestCluster:= FirstFreeDestCluster;
          FirstFreeDestCluster:= 0;
        END;
      END;

      (* Tausche jetzt NewPos[Cluster] mit DestCluster:                   *)
      SourceCluster:= NewPos[Cluster];
      OldDest:= OldPos[DestCluster];
      Current:= SourceCluster;
      (* vorlÑufig, wird Åberschrieben, falls Block-Austausch erfolgreich *)
      IF OrgFAT[OldDest]=FreeCluster THEN
        (* Ziel-Cluster ist frei, kann direkt Åberschrieben werden *)
        WriteCard(SourceCluster,6); WriteString('->');
        IF OK(rd,A,SourceCluster) AND OK(wr,A,DestCluster) THEN
          NewPos[Cluster]:= DestCluster;
          NewPos[OldDest]:= SourceCluster;
          OldPos[SourceCluster]:= OldDest;
          OldPos[DestCluster]:= Cluster;
          Current:= DestCluster;
        END;
      ELSIF SourceCluster#DestCluster THEN
        WriteCard(SourceCluster,6); WriteString('<>');
        IF OK(rd,A,SourceCluster) THEN
          IF OK(rd,B,DestCluster) THEN
            IF OK(wr,B,SourceCluster) THEN
              IF OK(wr,A,DestCluster) THEN
                NewPos[Cluster]:= DestCluster;
                NewPos[OldDest]:= SourceCluster;
                OldPos[SourceCluster]:= OldDest;
                OldPos[DestCluster]:= Cluster;
                Current:= DestCluster;
              ELSE
                (* mache vorherigen Schreibvorgang rÅckgÑngig: *)
                IF NOT OK(wr,A,SourceCluster) AND
                   NOT OK(wr,A,SourceCluster) THEN (* 2-mal *)
                  WriteLn;
                  WriteString('Fataler Fehler: Inhalt des Clusters ');
                  WriteCard(SourceCluster,4);
                  WriteString(' zerstîrt');
                  WriteLn;
                  Read (CH)
                END;
              END;
            END;
          END;
        END;
      END; (* IF unused *)

      (* Verkette mit VorgÑnger *)
      IF Predecessor#0 THEN
        IF NewFAT[Predecessor]#FreeCluster THEN
          WriteLn; WriteString('Warnung: Cluster doppelt belegt ');
          WriteCard(Predecessor,4); WriteLn;
          Read (CH)
        END;
        NewFAT[Predecessor]:= SwapLH(Current);
      END;
      Predecessor:= Current;
      Cluster:= Next(Cluster);
      INC(DestCluster);
    END; (* WHILE *)

    IF Predecessor#0 THEN
        IF NewFAT[Predecessor]#FreeCluster THEN
          WriteLn; WriteString('Warnung: Cluster doppelt belegt ');
          WriteCard(Predecessor,4); WriteLn;
          Read (CH)
        END;
      NewFAT[Predecessor]:= SwapLH(MaxCluster);
    END;
  END MoveFile;
  
  PROCEDURE CompactDirectory (StartCl: CARDINAL);
  (* Schreibe Subdirectories adjazent ab Cluster 2, aktualisiere NewFAT
  *)
    VAR i,x: CARDINAL;
        r  : DirectoryRecord;

  BEGIN
    (* Nur falls nicht Wurzelverzeichnis ist Verschieben mîglich:        *)
    IF StartCl#0 THEN MoveFile(StartCl); END;

    (* Verschiebe jetzt die geschachtelten Verzeichnisse:                *)
    i:= 0;
    WHILE GetDirectoryRecord(StartCl,i,r) DO
      WITH r DO
        x:= ORD(Name[0]);
        IF (x <> UnusedName) AND
           (x <> SpecialName) AND                (* nicht '.' und '..' ! *)
           (subdirattr IN Attr) THEN
          WriteLn; WriteString(Name); Write(':'); WriteLn;
          CompactDirectory(SwapLH(StartCluster));
        END;
      END;
      INC(i);
    END; (* WHILE *)
  END CompactDirectory;

  PROCEDURE CompactFiles (StartCl: CARDINAL);
  (* schreibe Datenfiles adjazent bis zum Plattenende, aktualisiere NewFAT
   *)
    VAR i,x: CARDINAL;
        r  : DirectoryRecord;

  BEGIN
    i:= 0;
    WHILE GetDirectoryRecord(StartCl,i,r) DO
      WITH r DO
        x:= ORD(Name[0]);
        IF (x <> UnusedName) AND (x <> SpecialName) THEN
          IF subdirattr IN Attr THEN     (* rekursiv die Sîhne bearbeiten *)
            CompactFiles(SwapLH(StartCluster));
          ELSE
            WriteLn; WriteString(Name); Write(':'); WriteLn;
            IF Size#0L THEN
              MoveFile(SwapLH(StartCluster));
            END;
          END;
        END;
      END;
      INC(i);
    END; (* WHILE *)
  END CompactFiles;

  PROCEDURE UpdateLinks (StartCl: CARDINAL);
  (* ersetzte Eintrag StartCluster fÅr jedes File und Unterverzeichnis
     durch seinen neuen Wert.
  *)
    VAR i,x, Start: CARDINAL;
        r         : DirectoryRecord;

  BEGIN
    i:= 0;
    WHILE GetDirectoryRecord(StartCl,i,r) DO
      WITH r DO
        x:= ORD(Name[0]);
        Start:= SwapLH(StartCluster);
        IF (x <> UnusedName) THEN            (* auch fÅr '.' und '..' ! *)
          IF (subdirattr IN Attr) AND (x<>SpecialName) THEN
            UpdateLinks(Start);
          END;
          WriteLn; WriteString(Name); Write(':');
          IF (Start>=FirstCluster) AND (Start<=MaxPhysCluster) THEN
            StartCluster:=SwapLH(NewPos[Start]);
            WriteCard(SwapLH(StartCluster),4);
            IF NOT PutDirectoryRecord(StartCl,i,r) THEN
              WriteLn;
              WriteString('Fehler: StartCluster fÅr File ');
              WriteString(Name);
              WriteString(' konnte nicht auf den Wert ');
              WriteCard(SwapLH(StartCluster),4);
              WriteString(' aktualisiert werden!'); WriteLn;
              Read (CH)
            END;
          END;
        END;
      END;
      INC(i);
    END; (* WHILE *)
  END UpdateLinks;

  PROCEDURE MakeNewFAT;
  (* Erzeuge leere NewFAT, in der fehlerhafte Cluster bereits markiert sind
  *)
  VAR i: CARDINAL;
  BEGIN
    NewFAT[0]:= OrgFAT[0];
    NewFAT[1]:= OrgFAT[1];
    FOR i:= FirstCluster TO BPBPtr^.numcl-1 DO
      IF SwapLH(OrgFAT[i])=BadCluster THEN
        NewFAT[i]:= SwapLH(BadCluster);
      ELSE
        NewFAT[i]:= FreeCluster;
      END;
    END;
  END MakeNewFAT;
   
  VAR i         : CARDINAL;
      errorcode : CARDINAL;
      NumberFree: CARDINAL;
   
BEGIN (* Hauptprogramm *)
  Write(CHR(27)); Write('v'); Write(CHR(27)); Write('E');
  WriteString('HDPack:'); WriteLn;
  WriteString('-------'); WriteLn; WriteLn;
  WriteString('Version 1.2  18.10.1987  Florian Matthes'); WriteLn; WriteLn;
  REPEAT
    CH:='0'; WriteLn;
    WriteString("Buchstabe des logischen Laufwerkes (z.B. 'C') ==>");
    Read(CH); CH:= CAP(CH); Write(CH); WriteLn;
  UNTIL (CH>='A') AND (CH<='Z');
  dev:= ORD(CH)-ORD("A");

  WriteLn;
  WriteString('Bitte bestÑtigen Sie die Optimierung fÅr Laufwerk ');
  Write(CHR(dev+ORD('A'))); WriteString(': '); WriteLn;
  WriteString("durch die Eingabe des Buchstabens 'P'!"); WriteLn;
  WriteLn; WriteString('W A R N U N G'); WriteLn;
  WriteString("Unterbrechen Sie keinesfalls den Programmablauf nach der");
  WriteLn;
  WriteString("Eingabe von 'P', da dies sicher zum Verlust von Dateien und ");
  WriteLn;
  WriteString('Directories fÅhren wÅrde!'); WriteLn; WriteLn;
  WriteString('==>'); Read(CH); Write(CH); WriteLn;
  IF CAP(CH)#'P' THEN
    Abort('OK: Programmabbruch durch den Benutzer', TRUE);
  END;

  BPBPtr:= BIOS.GetBPB(dev);
  IF ADDRESS(BPBPtr) = ADDRESS(0L) THEN
    Abort('Parameter Block nicht gefunden (Laufwerksbuchstabe prÅfen)!', TRUE);
  END;
  (* bestimme die gerÑteabhÑngingen Parameter und speichere sie global: *)
  WITH BPBPtr^ DO
    SectorsPerCluster        := clsiz;
    FirstDataSector          := datrec;
    DirectoryRecordsPerSector:= recsiz DIV SHORT (TSIZE(DirectoryRecord));
    FirstDirectorySector     := BPBPtr^.fatrec+BPBPtr^.fsiz;
    IF numcl>MaxCluster THEN
      Abort('Platte besitzt zu viele (>16384) Cluster!', TRUE);
    (*
    ELSIF numcl<4096 THEN
      Abort(
      'FAT ist nicht wortweise organisiert. HDPack lÑuft nicht fÅr Floppies',      TRUE);
    *)
    ELSIF DirectoryRecordsPerSector>MaxDirectoryBlocks THEN
      Abort('Sectorgrîûe auf dem Laufwerk zu groû (>65355 Bytes)', TRUE);
    END;
  END;
  WriteString('Parameter Block gelesen...'); WriteLn;

  ReadAbs(ADR(OrgFAT),           (* hole FAT                     *)
          BPBPtr^.fsiz,          (* Anzahl Sektoren = Laenge FAT *)
          1, errorcode);         (* 1. Sektor = 1. Sektor FAT    *)
  IF errorcode#0 THEN
    WriteString('Errorcode ='); WriteCard(errorcode,4); WriteLn;
    Abort('Fehler beim Lesen von FAT 1.', TRUE);
  END;
  WriteString('FAT 1 gelesen...'); WriteLn;

  ReadAbs(ADR(OldPos),           (* hole 2.FAT                   *)
          BPBPtr^.fsiz,          (* Anzahl Sektoren = Laenge FAT *)
          BPBPtr^.fatrec,        (* 1. Sektor = 1. Sektor FAT    *)
          errorcode);
  IF errorcode#0 THEN
    WriteString('Errorcode ='); WriteCard(errorcode,4); WriteLn;
    Abort('Fehler beim Lesen von FAT 2.', TRUE);
  END;
  WriteString('FAT 2 gelesen...'); WriteLn;
  
  errorcode:= 0;
  FOR i:= 0 TO BPBPtr^.numcl-1 DO
    IF OrgFAT[i] # OldPos[i] THEN
      INC(errorcode);
      WriteCard(i,6); WriteCard(OrgFAT[i],6); WriteCard(OldPos[i],6);
      WriteLn;
    END;
  END;
  IF errorcode=0 THEN
    WriteString('Gleichheit von FAT 1 und FAT 2 ÅberprÅft...'); WriteLn;
  ELSE
    Abort('FAT1 unterscheidet sich von FAT2 in den obigen Clustern', TRUE);
  END;

  FOR i:= 0 TO BPBPtr^.numcl-1 DO
    NewPos[i]:= i; OldPos[i]:= i;
  END;

  NumberFree:= CountFree();
  WriteCard(NumberFree,1);
  WriteString(' Cluster noch unbelegt...');
  WriteLn;

  WriteString('Sortiere Directories...'); WriteLn;
  SortDirectory(0);

  WriteLn; WriteString('Erstelle leere FAT...');
  MakeNewFAT;
  WriteLn;

  DestCluster:= FirstCluster;
  FirstFreeDestCluster:= 0; (* noch nicht bestimmt *)
  CompactDirectory(0);
  WriteLn;

  FirstFreeDestCluster:= DestCluster;
  (* erstes Cluster nach den Directories *)
  DestCluster:= FirstFreeDestCluster + NumberFree;
  CompactFiles(0);

  WriteLn;
  WriteString('Aktualisiere Anfangscluster...'); WriteLn;
  UpdateLinks(0);
  WriteLn;

  WriteAbs(ADR(NewFAT),          (* Schreibe FAT                 *)
          BPBPtr^.fsiz,          (* Anzahl Sektoren = Laenge FAT *)
          1, errorcode);         (* 1. Sektor = 1. Sektor FAT    *)
  IF errorcode#0 THEN
    WriteString('Fehler beim Schreiben von FAT 1: Code =');
    WriteCard(errorcode,4); WriteLn;
  END;
  WriteString('FAT 1 geschrieben...'); WriteLn;

  WriteAbs(ADR(NewFAT),          (* schreibe 2.FAT               *)
          BPBPtr^.fsiz,          (* Anzahl Sektoren = Laenge FAT *)
          BPBPtr^.fatrec,        (* 1. Sektor = 1. Sektor FAT    *)
          errorcode);
  IF errorcode#0 THEN
    WriteString('Fehler beim Schreiben von FAT2: Code =');
    WriteCard(errorcode,4); WriteLn;
  END;
  WriteString('FAT 2 geschrieben...'); WriteLn;
  WriteString('HDPACK erfolgreich beendet.'); WriteLn; WriteLn;
  WriteString('Bitte drÅcken Sie <RESET> um das System erneut zu booten!');
  WriteLn;
  WriteString('(dies ist zur Initialisierung des DESKTOP erforderlich)');
  WriteLn;
  LOOP END; (* Endlosschleife *)
END HDPack.

(* $00004738$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$000030E5$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9$FFF6C6C9Ä$00005460T.......T.......T.......T.......T.......T....T..T.......T.......T.......T.......$000043DF$00005205$000038FF$00003A30$00003C30$00004550$000046DD$00000180$FFF673D6$00002A76$00001399$0000135B$0000134D$00005460$000030EA$000031C0∏ÄÅ*)
