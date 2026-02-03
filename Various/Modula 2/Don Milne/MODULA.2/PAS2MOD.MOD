TITLE: Pascal to M2 Conversion
MODULE pasmod;

(*
Ron Sprunger : 5/23/86 : routines for initial processing of Pascal file to
 make conformant to Modula-2 syntax
Note that this module uses the String routines provided by TDI.
This module badly needs enhancements:
      1) it shouldn't modify literals
      2) it should ignore case for matches
      3) it should do some interpretation on some constructs (e.g. string[n])

This module will have to be modified to match your style of programming.  I do
not use caps, except for constants.  M2 is driving me crazy with the shift key
thing, to the point where I'm wondering whether it's worth the trouble.

Anyone interested has my permission to use and improve this.  If any
significant improvements, please post.
*)

FROM InOut      IMPORT  Done, OpenOutput, OpenInput, termCH, EOL,
                        CloseInput, CloseOutput, Read, WriteLn, WriteString;
IMPORT Terminal;
FROM String     IMPORT  Insert, Delete, Length, Pos, Assign,
                InitStringModule, Copy, Concat;

CONST
        slen    = 132;                  (* maximum line length to handle *)
        comlen  = 2;                    (* length of a comment character *)
        maxcmp  = 34;                   (* number of replacement strings *)
TYPE
        s       = ARRAY[0..10] OF CHAR; (* for replacement work *)
VAR
        tch,                            (* checks for ^C *)
        ch      : CHAR;
        instr,
        outstr,
        wrkstr  : ARRAY[0..slen] OF CHAR;
        find,
        repl    : ARRAY[0..35] OF s;
        comlev,                         (* nexting level of comments *)
        lct,                            (* count of lines processed *)
        ptr     : CARDINAL;             (* position no line *)
        comstr1,
        comstr2 : s;                    (* m2 comment delimiter *)
        pascom1,
        pascom2 : ARRAY[0..0] OF CHAR;

PROCEDURE closefiles;
BEGIN
  CloseInput;                           (* close the input file *)
  CloseOutput;
END closefiles;

PROCEDURE clrstr(VAR s : ARRAY OF CHAR); (* clear string to nulls *)
VAR i   : CARDINAL;
BEGIN
  FOR i := 0 TO slen DO                 (* really only need to null s[0] *)
    s[i] := CHR(0);
  END;
END clrstr;

PROCEDURE initialize;
BEGIN
  InitStringModule;
  pascom1 := "{";
  pascom2 := "}";
  clrstr(instr);
  clrstr(outstr);
  clrstr(wrkstr);
  lct := 0;
  ptr := 0;
  comlev := 0;
  comstr1 := '(*';
  Assign(comstr2,"*)");
  Assign(find[0],pascom1);
  Assign(repl[0],comstr1);
  Assign(find[1],pascom2);
  Assign(repl[1],comstr2);
  Assign(find[2],'begin');
  Assign(repl[2],'BEGIN');
  Assign(find[3],'end');
  Assign(repl[3],'END');
  Assign(find[4],'while');
  Assign(repl[4],'WHILE');
  Assign(find[5],' do');
  Assign(repl[5],' DO');
  Assign(find[6],'for ');
  Assign(repl[6],'FOR ');
  Assign(find[7],' to ');
  Assign(repl[7],' TO ');
  Assign(find[8],'repeat');
  Assign(repl[8],'REPEAT');
  Assign(find[9],'until');
  Assign(repl[9],'UNTIL');
  Assign(find[10],'case ');
  Assign(repl[10],'CASE ');
  Assign(find[11],' of');
  Assign(repl[11],' OF');
  Assign(find[12],'var');
  Assign(repl[12],'VAR');
  Assign(find[13],'const');
  Assign(repl[13],'CONST');
  Assign(find[14],'type');
  Assign(repl[14],'TYPE');
  Assign(find[15],'if ');
  Assign(repl[15],'IF ');
  Assign(find[16],' then');
  Assign(repl[16],' THEN');
  Assign(find[17],'else');
  Assign(repl[17],'ELSE');
  Assign(find[18],'function');
  Assign(repl[18],'PROCEDURE');
  Assign(find[19],'procedure');
  Assign(repl[19],'PROCEDURE');
  Assign(find[20],'array');
  Assign(repl[20],'ARRAY');
  Assign(find[21],' mod ');
  Assign(repl[21],' MOD ');
  Assign(find[22],' in ');
  Assign(repl[22],' IN ');
  Assign(find[23],' not');
  Assign(repl[23],' NOT');
  Assign(find[24],' or ');
  Assign(repl[24],' OR ');
  Assign(find[25],' and ');
  Assign(repl[25],' AND ');
  Assign(find[26],'record');
  Assign(repl[26],'RECORD');
  Assign(find[27],'set ');
  Assign(repl[27],'SET ');
  Assign(find[28],'with ');
  Assign(repl[28],'WITH ');
  Assign(find[29],'byte;');
  Assign(repl[29],'CARDINAL');
  Assign(find[30],'integer;');
  Assign(repl[30],'INTEGER;');
  Assign(find[31],'real;');
  Assign(repl[31],'REAL;');
  Assign(find[32],'char;');
  Assign(repl[32],'CHAR;');
  Assign(find[33],'string[');
  Assign(repl[33],'ARRAY[0..');
  Assign(find[34],'program');
  Assign(repl[34],'MODULE');
END initialize;

PROCEDURE replace(VAR s, take, put : ARRAY OF CHAR);
(*      if take is in s, replace with put
*)
VAR     rpos    : CARDINAL;
BEGIN
  WHILE (Pos(s,take,0,rpos)) DO
    Delete(s,rpos,Length(take));
    IF (rpos >= Length(s)) THEN
      Concat(s,put,s)
    ELSE
      Insert(put,s,rpos);
    END;        (* endif rpos *)
  END;  (* enwhile *)
END replace;

PROCEDURE spacesonly(VAR s : ARRAY OF CHAR) : BOOLEAN;
VAR     i       : CARDINAL;
BEGIN
  i := 0;
  WHILE (i <= (Length(s)-1)) DO
    IF NOT (s[i] = " ") AND NOT (s[i] = CHR(9)) THEN
      RETURN FALSE;
    END;
    INC(i,1);
  END;          (* endwhile *)
  RETURN TRUE;
END spacesonly;

PROCEDURE processline;
(*      line from read routine is in instr - substitute in non-commented
        portions of instr only, and write to output
*)
VAR     i       : CARDINAL;
        linedone: BOOLEAN;

  PROCEDURE comment() : BOOLEAN;
  (*    checks whether current text is in a comment and at what level.
        Returns commentlevel at end of line if no uncommented text,
        otherwise returns text up to next comment start in wrkstr
  *)
  VAR   upfirst,
        up1,
        both,
        neither,
        dn1     : BOOLEAN;              (* inc or dec comlev? *)
        tstup,                          (* position of change *)
        tstdn   : CARDINAL;

    PROCEDURE ckup(start : CARDINAL);
    VAR tmp     : ARRAY[0..30] OF CHAR;
        snum    : ARRAY[0..3] OF CHAR;
    BEGIN
      up1 := FALSE;tstup := 0;upfirst := FALSE;
      IF (Pos(instr,comstr1,start,tstup)) THEN
        up1 := TRUE;
        upfirst := TRUE;
      END;              (* endif   *)
    END ckup;

    PROCEDURE ckdn(start : CARDINAL);
    VAR tmp     : ARRAY[0..30] OF CHAR;
        snum    : ARRAY[0..3] OF CHAR;
    BEGIN
      dn1 := FALSE;tstdn := 0;
      IF (Pos(instr,comstr2,start,tstdn)) THEN
        dn1 := TRUE;
      END;              (* endif   *)
    END ckdn;

    PROCEDURE ckboth;
    BEGIN
      IF (up1) AND (dn1) THEN
        upfirst := (tstup < tstdn);
        both := TRUE;
      ELSE
        both := FALSE;
      END;      (* endif up1 AND dn1 *)
      IF (NOT up1) AND (NOT dn1) THEN
        neither := TRUE
      ELSE
        neither := FALSE;
      END;      (* endif both or neither *)
    END ckboth;

    PROCEDURE copycom;  (* copy comment into wrkstr *)
    (*  this procedure is called if:
                1)      comlev = 0 AND start comment is first thing
                2)      comlev > 0
    *)
    VAR to      : CARDINAL;             (* can copy to char number to *)
        done    : BOOLEAN;
        tmp     : ARRAY[0..30] OF CHAR;
        snum    : ARRAY[0..3] OF CHAR;
    BEGIN
      to := 0;
      done := FALSE;
      IF (comlev = 0) THEN              (* first comlen chars are start com *)
        INC(comlev,1);                  (* up the comment level *)
        to := comlen;
      END;      (* endif comlev *)
      REPEAT
        IF (to >= Length(instr)) THEN
          done := TRUE;
        ELSE
          ckup(to);                     (* see if another up level *)
          ckdn(to);                     (* also check for down *)
          ckboth;
          IF neither THEN
            to := Length(instr);
          ELSIF both THEN
            IF upfirst THEN
              INC(comlev,1);
              to := tstup+comlen;
            ELSE
              DEC(comlev,1);
              to := tstdn+comlen;
            END;        (* endif upfirst *)
          ELSIF up1 THEN        (* elsif only up *)
            INC(comlev,1);
            to := tstup+comlen;
          ELSE  (* else only down *)
            DEC(comlev,1);
            to := tstdn+comlen;
            IF (comlev = 0) THEN
              done := TRUE;
            END;        (* endif comlev *)
          END;  (* endif neither etc *)
        END;    (* endif to *)
      UNTIL done;
      IF (to >= Length(instr)) THEN
        Assign(wrkstr,instr);
        clrstr(instr);
      ELSE
        Copy(instr,0,to,wrkstr);
        Copy(instr,to,(Length(instr)-to),instr);
      END;
    END copycom;

(****** comment() does evaluation work on incoming line ******)

  BEGIN         (* start function procedure comment() *)
    linedone := FALSE;
    IF (Length(instr) = 0) THEN         (* no more text to process? *)
      linedone := TRUE;
      RETURN FALSE;
    END;                (* endif nothing there *)
    upfirst := FALSE;
    ckup(0);
    ckdn(0);
    ckboth;
    IF (neither) THEN           (* no change in comment status *)
      Assign(wrkstr,instr);             (* handle all *)
      clrstr(instr);                    (* clear instr to nulls *)
      linedone := FALSE;                (* will have to come back *)
      IF (comlev = 0) THEN
        RETURN FALSE                    (* not in comment *)
      ELSE
        RETURN TRUE;                    (* yes, in comment *)
      END;      (* endif *)
    END;        (* endif neither *)
(***** neithers and nulls are out of the way now *****)

    IF (comlev = 0) THEN                (* if not now commenting *)
      IF (NOT upfirst) THEN
        closefiles;
        Terminal.WriteString("End comment before start comment");
        Terminal.WriteLn;
        Terminal.Write(CHR(7));
        HALT;
      END;      (* endif *)

(***** now know that first change is up *****)
      IF (tstup > 0) THEN               (* text before comment? *)
        Copy(instr,0,tstup,wrkstr);     (* copy up to comment *)
        Copy(instr,tstup,(Length(instr)-tstup),instr);
        RETURN FALSE;
      END;      (* endif tstup>0 *)
    END;        (* endif comlev 0 *)
    copycom;
    RETURN TRUE;
  END comment;

BEGIN           (* start procedure processline *)
  IF (Length(instr) > 0) THEN 
    FOR i := 0 TO 1 DO
      replace(instr,find[i],repl[i]);   (* start with comment chars *)
    END;        (* endfor *)
    LOOP                                (* do as separate work strings *)
      IF NOT (comment()) THEN           (* comment() provides wrkstr *)
        IF (linedone) THEN
          EXIT
        ELSE
          IF NOT (spacesonly(wrkstr)) THEN
            FOR i := 2 TO maxcmp DO     (* now look at replacing *)
              replace(wrkstr,find[i],repl[i]);
            END;        (* endfor    *)
          END;  (* endif not spacesonly *)
        END;    (* endif linedone *)
      END;      (* endif NOT comment() *)
      Concat(outstr,wrkstr,outstr);     (* add workstring to out *)
      clrstr(wrkstr);                   (* clear workstring *)
    END;        (* endloop *)
    WriteString(outstr);
  END;  (* endif length *)
  WriteLn;
  clrstr(instr);
  INC(lct,1);                           (* and count lines *)
END processline;

BEGIN
  REPEAT
    OpenInput("");                      (* find out whence input *)
    IF (termCH = 03C) THEN
      HALT;
    END;
  UNTIL Done;                           (* don't give up *)
  REPEAT
    OpenOutput("");                     (* where to? *)
    IF (termCH = 03C) THEN
      HALT;
    END;
  UNTIL Done;
  initialize;                           (* setup substitution list *)
  Read(ch);                             (* read from input file *)
  LOOP
    IF NOT Done THEN
      EXIT;
    END;
    IF (ch = EOL) THEN                  (* this line complete? *)
      Terminal.WriteString(instr);      (* show unprocessed line *)
      Terminal.WriteLn;
      processline;                      (* make substitutions *)
      IF (Length(outstr) > 0) THEN
        Terminal.WriteString(outstr);   (* show result on screen *)
        clrstr(outstr);
      END;      (* endif Length *)
      Terminal.WriteLn;
      Terminal.BusyRead(tch);           (* see if key pressed *)
      IF (tch = 03C) THEN               (* is it ^C? *)
        EXIT;                           (* time to quit *)
      END;
      ptr := 0;                         (* reset pointer *)
    ELSE
      instr[ptr] := ch;                 (* add to in string *)
      INC(ptr,1);
    END;
    Read(ch);                           (* and read next character *)
  END;                                  (* end loop *)
END pasmod.

