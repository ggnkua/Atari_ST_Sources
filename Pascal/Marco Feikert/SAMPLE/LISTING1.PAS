(* Laden und Abspielen von Soundsamples auf   *)
(* Atari STE und TT Computer                  *)
(* (w) Marco Feikert (10'92) & (1'93)         *)

{$X+}
UNIT sample;

INTERFACE

USES tos;

CONST
    max_samples = 150;
    
    stop = 0;
    einmal = 1;
    dauernd = 3;
    
    mono = 1;
    stereo= 0;
    
    fr_6 = 0;
    fr_12 = 1;
    fr_25 = 2;
    fr_50 = 3;

VAR
    i: INTEGER;
    
FUNCTION sam_load(name: STRING): INTEGER;
PROCEDURE sam_free(was: INTEGER);
PROCEDURE sam_play(id, wie_oft, frequenz, 
                   mono_stereo: INTEGER);

(* ------------------------------------------ *)

IMPLEMENTATION

TYPE        
    sam_arr = RECORD
        start: POINTER;    (* Startadresse *)
        len: LONGINT;      (* L„nge *)
    END;
     
VAR 
    sam: ARRAY[0 .. max_samples] OF sam_arr;

(* L„dt Sample name, return: Id-Nummer bzw.  *)
(* -1: Datei nicht gefunden,                 *)
(* -2: Speicherreservierungsfehler           *)
(* -3: Einladefehler                         *)
(* -4: Recordarray vollst„ndig belegt        *)
FUNCTION sam_load(name: STRING): INTEGER;
VAR
    frei, i, fh, return: INTEGER;
    amount, len: LONGINT;
    p: POINTER;
    dat: DTAPtr;
BEGIN
  P:=NIL;
  len:=0;
  return:=-4;
  i:=0;
(* Freien Platz suchen *)
  REPEAT      
    IF sam[i].start=NIL THEN
      return:=i
    ELSE
      INC(i);
  UNTIL (i>max_samples) OR (return<>-4);
  IF return<>-4 THEN BEGIN
(* Dateil„nge bestimmen *)
    i:=FSFIRST(name,0);
    IF i=0 THEN BEGIN
      dat:=FGETDTA;
      len:=dat^.d_length;
    END;
(* Dateil„nge=0 => nicht gefunden *)
    IF len=0 THEN 
      return:=-1
    ELSE BEGIN
      frei:=return;
(* Speicherplatz reservieren *)
      p:=Malloc(len);
      IF p=NIL THEN
        return:=-2
      ELSE BEGIN
        return:=-3;
        fh:=Fopen(name,FO_READ);
        IF fh>0 THEN BEGIN
(* Sample einlesen *)
          amount:=Fread(fh,len,p);
          IF amount=len THEN BEGIN
            sam[frei].start:=p;
            sam[frei].len:=len;      
            return:=frei;
          END;
          Fclose(fh);
        END;
      END;
    END;
  END;
(* Einladefehler, Speicher freigeben *)
  IF return=-3 THEN
    Mfree(p);
  sam_load:=return;
END;

(* Speicherplatz von Samples freigeben  *)
(* was: >=0: Fr ein Sample freigeben   *)
(*       -1: Fr alle Samples freigeben *)
PROCEDURE sam_free(was: INTEGER);
VAR
    i: INTEGER;
BEGIN
  IF was>=0 THEN
    BEGIN
      IF sam[was].start<>NIL THEN BEGIN
        Mfree(sam[was].start);
        sam[was].start:=NIL;
        sam[was].len:=0;
      END;
    END
  ELSE BEGIN
    i:=0;
    REPEAT
      IF sam[i].start<>NIL THEN BEGIN
        Mfree(sam[i].start);
        sam[i].start:=NIL;
        sam[i].len:=0;
      END;
      INC(i);
    UNTIL i>max_samples;
  END;    
END;

(* 1 Longint in 4 Bytes aufteilen *)
(* b1: Highbyte ... b4: Lowbyte   *)
PROCEDURE split_var(v: LONGINT; 
                    VAR b1, b2, b3, b4: BYTE);
VAR
    p: POINTER;
BEGIN
  p:=ADDR(v);
  b1:=BYTE(p^);
  b2:=BYTE(POINTER(LONGINT(p)+1)^);
  b3:=BYTE(POINTER(LONGINT(p)+2)^);
  b4:=BYTE(POINTER(LONGINT(p)+3)^);
END;

(* Sample abspielen                       *)
(* id: Samplekennung aus sam_load()       *)
(* wie_oft: 0: Stop, 1: Einmal, 3: Endlos *)
(* frequenz: 0: 6.25 Khz, 1: 12.5 Khz,    *)
(* 2: 25 Khz, 3: 50 Khz                   *)
(* mono_stereo: 0: Stereo, 1: Mono        *)
(* bzw. Konstantenvereinbarungen aus      *)
(* Programmkopf benutzen                  *)
PROCEDURE sam_play(id, wie_oft, frequenz, 
                   mono_stereo: INTEGER);
VAR
    l, start, ende, os: LONGINT;
    b1, b2, b3, b4: BYTE;
BEGIN
  IF sam[id].len>0 THEN BEGIN  (* Gltige Id ? *)
(* Supervisormodus an *)
    os:=Super(NIL);
(* Startadresse eintragen *)
    l:=$ff8902;
    start:=LONGINT(sam[id].start);
    split_var(start,b1,b2,b3,b4);
    BYTE(POINTER(l+1)^):=b2;
    BYTE(POINTER(l+3)^):=b3;
    BYTE(POINTER(l+5)^):=b4;
(* Endadresse eintragen *)
    l:=$ff890e;
    ende:=LONGINT(sam[id].start)+sam[id].len;
    split_var(ende,b1,b2,b3,b4);
    BYTE(POINTER(l+1)^):=b2;
    BYTE(POINTER(l+3)^):=b3;
    BYTE(POINTER(l+5)^):=b4;
(* Frequenz eintragen *)
    l:=$ff8920;
    IF mono_stereo=1 THEN
      INC(frequenz,128);
    WORD(POINTER(l)^):=frequenz;
(* Abspielen starten/stoppen *)
    l:=$ff8900;
    WORD(POINTER(l)^):=wie_oft;
(* Supervisormodus aus *)
    Super(POINTER(os));
  END;
END;

BEGIN
(* Record initialisieen *)
  i:=0;
  REPEAT
    sam[i].start:=NIL;
    sam[i].len:=0;
    INC(i);
  UNTIL i>max_samples;
END.
