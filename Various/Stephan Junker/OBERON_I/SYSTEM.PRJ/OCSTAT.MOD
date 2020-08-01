MODULE OCStat; (* SJ 24.9.94 *)

(*
 The type Stat is needed for any kind of statement used in Oberon
 source code.
 What you must do to add new statements:
 Choose a form constant and enter it in CONST. If necessary, enter the
 usage of the universal record fields in the comment table. Maybe you also
 need to add fields to StatD.
 Then some procedures here must be extended:
   Output: Implement a suitable ascii output (if it will appear at the
           end of the first scanning process).
 *)


IMPORT
  S:=SYSTEM, Expr:=OCExpr, Sym:=OCSymbol, Scan:=OCScan, IO:=OCOutput,
  Par:=OCPar, Strings;



CONST
  (* statement forms *)
  Ret* = 2;		(* RETURN *)
  Options* = 3;		(* compiler options in the source *)
  OutCtrl* = 4;		(* output enable *)
  Code* = 5;		(* translated code *)
  Mod* = 6;		(* the module *)
  Proc* = 7;		(* a procedure *)
  End* = 8;		(* end of block *)
  Call* = 11;		(* proc(pars) *)		(* 10-29 expr *)
  Begin* = 12;		(* begin of block *)
  Bra* = 13;		(* branch unconditionally *)
  Label* = 14;		(* a label *)
  Base* = 15;		(* BASE label *)
  Dcw* = 16;		(* DC.W word *)
  Asgn* = 20;		(* dest := src *)		(* 20-29 expr2 *)
  Bct* = 21;		(* branch conditionally *)
  Bcf* = 22;		(* branch conditionally *)

  Ass* = 200;		(* first assembler code *)

  (* size codes in assembler statements *)
  Byte* = 0; Word* = 1; Long* = 2; Single* = 3; Double* = 4; NoSize* = 5;

  (* codes for OutCtrl.a0 *)
  OCOut* = 0;		(* enable output *)
  OCInh* = 1;		(* disable output *)



(* record field usage:

Stat
form	expr	expr2	a0	len
--------------------------------------------------------------------------
Ret			level	comlen
Options			^text	comlen=0
OutCtrl			enable
Code			^data	comlen
Mod				comlen=0
Proc			1=body	comlen=0
End				comlen
Call	call
Begin	Alabel		varpos	comlen
Bra	label
Label	label		glb/exp
Base	label
Dcw	word
Asgn	dest	src
Bct	label	cond
Bcf	label	cond

>=Ass	src	dest	size	comlen

*)


TYPE
  Stat*     = POINTER TO StatD;
  StatD*    = RECORD
                form* : INTEGER;
                next*, prev* : Stat;		(* a list of statements *)
                expr*, expr2* : Expr.Expr;
                a0*  : LONGINT;
                len* : INTEGER;
                sym* : Sym.Symbol;		(* Mod / Proc *)
              END;

  StringPtr = POINTER TO ARRAY 10000 OF CHAR;


VAR
  stats-, last-, insert* : Stat;
  procStack-: ARRAY 10 OF Sym.Symbol; psx-: INTEGER; (* for RETURN *)
  insertNum : INTEGER;
  symbol : Sym.Symbol;
  freeStats: Stat;



PROCEDURE New*(form: INTEGER; VAR stat: Stat);
(*
 Allocate a new statement. Set form.
 *)
 BEGIN
  IF freeStats = NIL THEN
    Sym.Alloc( SIZE(StatD), stat);
  ELSE
    stat := freeStats; freeStats := stat.next;
  END;
  stat.form := form;
 END New;


PROCEDURE HasExpr1*(stat: Stat) : BOOLEAN;
 BEGIN
  RETURN (stat.form >= Ass) & (stat.expr # NIL)
         OR (stat.form >= 10) & (stat.form <= 29) & (stat.form # Begin);
 END HasExpr1;


PROCEDURE HasExpr2*(stat: Stat) : BOOLEAN;
 BEGIN
  RETURN (stat.form >= Ass) & (stat.expr2 # NIL)
         OR (stat.form >= 20) & (stat.form <= 29);
 END HasExpr2;


PROCEDURE Dispose*(stat: Stat);
 BEGIN
  stat.next := freeStats; freeStats := stat;
 END Dispose;


PROCEDURE Insert*(stat, next: Stat);
(*
 Inserts stat into the statement list so that next is its successor.
 *)
 BEGIN
  stat.prev := next.prev; stat.next := next;
  next.prev := stat; stat.prev.next := stat;
 END Insert;


PROCEDURE Add*(stat: Stat);
(*
 Add a statement at the end of the current statement list
 *)
 BEGIN
  IF insert = NIL THEN
    stat.next := NIL; stat.prev := last;
    IF last # NIL THEN last.next := stat
    ELSE stats := stat;
    END;
    last := stat;
  ELSE
    Insert(stat, insert)
  END;
 END Add;


PROCEDURE Unchain*(s: Stat);
 BEGIN
  IF s.prev # NIL THEN s.prev.next := s.next;
  ELSE stats := stats.next
  END;
  IF s.next # NIL THEN s.next.prev := s.prev
  ELSE last := last.prev
  END;
 END Unchain;


PROCEDURE Remove*(VAR stat: Stat);
(*
 Remove stat from the statement list. Return the previous statement in stat
 so that stat.next stays the same.
 *)
  VAR
    s: Stat;
 BEGIN
  s := stat; stat := s.prev;
  Unchain(s); Dispose(s);
 END Remove;


PROCEDURE DisposeExpr*(begin: Stat);
(*
 Dispose all expressions which are not used anymore.
 *)
  VAR
    s: Stat;
 BEGIN
  s := begin.next;
  WHILE (s # NIL) & (s.form # End) DO
    IF HasExpr1(s) THEN Expr.MarkUsed(s.expr) END;
    IF HasExpr2(s) THEN Expr.MarkUsed(s.expr2) END;
    s := s.next;
  END;
  Expr.DisposeAll;
 END DisposeExpr;


PROCEDURE ReadOptions*(VAR s: Stat);
  VAR
    d : BOOLEAN;
    sp : StringPtr;
 BEGIN
  WHILE (s # NIL) & (s.form = Options) DO
    sp := S.VAL( StringPtr, s.a0);
    d := Par.ReadOptions(sp^);
    s := s.next;
  END;
 END ReadOptions;


PROCEDURE Environment*(begStat: Stat; VAR symbol: Sym.Symbol;
                       VAR firstNewStat: Stat);
  VAR
    s: Stat;
    sym: Sym.Symbol;
 BEGIN
  procStack[0] := NIL; psx := 1;
  s := stats;
  firstNewStat := s;
  LOOP
    ReadOptions(s);
    IF s = begStat THEN EXIT END;
    CASE s.form OF
      End:
  	sym := sym.syms.a0;
  	firstNewStat := s.next;
  	IF psx > 1 THEN DEC(psx) END;

    | Mod:
        sym := s.sym;

    | Proc:
        IF s.a0 = 1 THEN
          s.sym.syms.a0 := S.VAL(LONGINT, sym);
          sym := s.sym;
          procStack[psx] := sym; INC(psx);
        END;

    ELSE
    END;
    s := s.next
  END;
  symbol := sym;
  Sym.symbols := sym.syms;
  IF sym.form IN {Sym.Mod, Sym.Tbp} THEN Sym.level := 0
  ELSE Sym.level := sym.lev+1;
  END;
 END Environment;


PROCEDURE IncInsert;
 BEGIN
  INC(insertNum, 2);
 END IncInsert;


PROCEDURE DecInsert;
 BEGIN
  DEC(insertNum, 2);
 END DecInsert;


PROCEDURE InsertSpace;
  VAR
    i : INTEGER;
 BEGIN
  FOR i := insertNum-1 TO 0 BY -1 DO
    IO.WriteChar( " ");
  END;
 END InsertSpace;


PROCEDURE InsertSpace1;
  VAR
    i : INTEGER;
 BEGIN
  FOR i := insertNum-2 TO 0 BY -1 DO
    IO.WriteChar( " ");
  END;
 END InsertSpace1;


PROCEDURE^ WriteTyp(typ : Sym.Struct; tryName: BOOLEAN);


PROCEDURE WritePar(sym: Sym.Symbol; single: BOOLEAN);
 BEGIN
  IF sym.form # Sym.Tbp THEN
    IF ~single THEN IO.WriteLn END;
    InsertSpace;
    IF sym.form = Sym.Ind THEN IO.WriteString( "VAR ") END;
    IO.WriteString( sym.name);
    IO.WriteString( ": ");
    IF (sym.form = Sym.Ind) OR (sym.form = Sym.Cpy) THEN
      WriteTyp(sym.typ.base, TRUE)
    ELSE WriteTyp(sym.typ, TRUE)
    END;
    IF ~single & (sym.next # NIL) & (sym.next.form # Sym.Sep) THEN
      IO.WriteChar( ";");
    END;
  END;
 END WritePar;


PROCEDURE WritePars(sym: Sym.Symbol);
 BEGIN
  IncInsert;
  WHILE (sym # NIL) & (sym.form # Sym.Sep) DO
    WritePar(sym, FALSE);
    sym := sym.next;
  END;
  DecInsert;
 END WritePars;


PROCEDURE WriteTyp(typ : Sym.Struct; tryName: BOOLEAN);
  VAR
    sym : Sym.Symbol;
 BEGIN
  IF tryName & Expr.SymbolOf(typ, sym) THEN
    Expr.TryWriteModule(sym);
    IO.WriteString( sym.name);
  ELSE
    CASE typ.form OF
      Sym.Byte:
        IO.WriteString( "SYSTEM.BYTE");
    | Sym.Bool:
        IO.WriteString( "BOOLEAN");
    | Sym.Char:
        IO.WriteString( "CHAR");
    | Sym.SInt:
        IO.WriteString( "SHORTINT");
    | Sym.Int:
        IO.WriteString( "INTEGER");
    | Sym.LInt:
        IO.WriteString( "LONGINT");
    | Sym.Real:
        IO.WriteString( "REAL");
    | Sym.LReal:
        IO.WriteString( "LONGREAL");
    | Sym.Set:
        IO.WriteString( "SET");
    | Sym.AnyPtr:
        IO.WriteString( "SYSTEM.PTR");
    | Sym.Pointer:
        IO.WriteString( "POINTER TO ");
        WriteTyp(typ.base, TRUE);
    | Sym.ProcTyp:
        IO.WriteString( "PROCEDURE (");
        WritePars(typ.syms.next);
        IO.WriteChar( ")");
        IF (typ.base # NIL) & (typ.base.form # Sym.NoTyp) THEN
          IO.WriteString( " : ");
          WriteTyp(typ.base, TRUE);
        END;
    | Sym.Array:
        IO.WriteString( "ARRAY ");
        IO.WriteInt( typ.n);
        IO.WriteString( " OF ");
        WriteTyp(typ.base, TRUE);
    | Sym.DynArr, Sym.OpenArr:
        IO.WriteString( "ARRAY OF ");
        WriteTyp(typ.base, TRUE);
    | Sym.Record:
        IO.WriteString( "RECORD");
        IF (typ.base # NIL) THEN
          IO.WriteChar( "(");
          WriteTyp(typ.base, TRUE);
          IO.WriteChar( ")");
        END;
        WritePars(typ.syms.next);
        IO.WriteLn;
        InsertSpace;
        IO.WriteString( "END");
    ELSE
        IO.WriteString( "Undefined type #");
        IO.WriteInt( typ.form);
    END;
  END;
 END WriteTyp;


PROCEDURE WriteMnem(com: INTEGER);
(*
 Write the mnemonics of assembler command com.
 *)
 BEGIN
  CASE com OF
    Scan.abcd: IO.WriteString("ABCD");
  | Scan.addx: IO.WriteString("ADDX");
  | Scan.cmpm: IO.WriteString("CMPM");
  | Scan.sbcd: IO.WriteString("SBCD");
  | Scan.subx: IO.WriteString("SUBX");
  | Scan.add: IO.WriteString("ADD");
  | Scan.andm: IO.WriteString("AND");
  | Scan.cmp: IO.WriteString("CMP");
  | Scan.orm: IO.WriteString("OR");
  | Scan.sub: IO.WriteString("SUB");
  | Scan.adda: IO.WriteString("ADDA");
  | Scan.cmpa: IO.WriteString("CMPA");
  | Scan.lea: IO.WriteString("LEA");
  | Scan.suba: IO.WriteString("SUBA");
  | Scan.addi: IO.WriteString("ADDI");
  | Scan.andi: IO.WriteString("ANDI");
  | Scan.cmpi: IO.WriteString("CMPI");
  | Scan.eori: IO.WriteString("EORI");
  | Scan.ori: IO.WriteString("ORI");
  | Scan.subi: IO.WriteString("SUBI");
  | Scan.addq: IO.WriteString("ADDQ");
  | Scan.subq: IO.WriteString("SUBQ");
  | Scan.asl: IO.WriteString("ASL");
  | Scan.asr: IO.WriteString("ASR");
  | Scan.lsr: IO.WriteString("LSR");
  | Scan.lsl: IO.WriteString("LSL");
  | Scan.rol: IO.WriteString("ROL");
  | Scan.ror: IO.WriteString("ROR");
  | Scan.roxl: IO.WriteString("ROXL");
  | Scan.roxr: IO.WriteString("ROXR");
  | Scan.bchg: IO.WriteString("BCHG");
  | Scan.bclr: IO.WriteString("BCLR");
  | Scan.bset: IO.WriteString("BSET");
  | Scan.btst: IO.WriteString("BTST");
  | Scan.chk: IO.WriteString("CHK");
  | Scan.clr: IO.WriteString("CLR");
  | Scan.jmp: IO.WriteString("JMP");
  | Scan.jsr: IO.WriteString("JSR");
  | Scan.ext: IO.WriteString("EXT");
  | Scan.nbcd: IO.WriteString("NBCD");
  | Scan.neg: IO.WriteString("NEG");
  | Scan.negx: IO.WriteString("NEGX");
  | Scan.notm: IO.WriteString("NOT");
  | Scan.pea: IO.WriteString("PEA");
  | Scan.st: IO.WriteString("ST");
  | Scan.sf: IO.WriteString("SF");
  | Scan.shi: IO.WriteString("SHI");
  | Scan.sls: IO.WriteString("SLS");
  | Scan.shs: IO.WriteString("SHS");
  | Scan.slo: IO.WriteString("SLO");
  | Scan.sne: IO.WriteString("SNE");
  | Scan.seq: IO.WriteString("SEQ");
  | Scan.svc: IO.WriteString("SVC");
  | Scan.svs: IO.WriteString("SVS");
  | Scan.spl: IO.WriteString("SPL");
  | Scan.smi: IO.WriteString("SMI");
  | Scan.sge: IO.WriteString("SGE");
  | Scan.slt: IO.WriteString("SLT");
  | Scan.sgt: IO.WriteString("SGT");
  | Scan.sle: IO.WriteString("SLE");
  | Scan.swap: IO.WriteString("SWAP");
  | Scan.tas: IO.WriteString("TAS");
  | Scan.tst: IO.WriteString("TST");
  | Scan.unlk: IO.WriteString("UNLK");
  | Scan.extb: IO.WriteString("EXTB");
  | Scan.divs: IO.WriteString("DIVS");
  | Scan.divu: IO.WriteString("DIVU");
  | Scan.muls: IO.WriteString("MULS");
  | Scan.mulu: IO.WriteString("MULU");
  | Scan.eor: IO.WriteString("EOR");
  | Scan.exg: IO.WriteString("EXG");
  | Scan.rts: IO.WriteString("RTS");
  | Scan.illegal: IO.WriteString("ILLEGAL");
  | Scan.nop: IO.WriteString("NOP");
  | Scan.reset: IO.WriteString("RESET");
  | Scan.rte: IO.WriteString("RTE");
  | Scan.rtr: IO.WriteString("RTR");
  | Scan.stop: IO.WriteString("STOP");
  | Scan.trapv: IO.WriteString("TRAPV");
  | Scan.link: IO.WriteString("LINK");
  | Scan.move: IO.WriteString("MOVE");
  | Scan.movea: IO.WriteString("MOVEA");
  | Scan.movem: IO.WriteString("MOVEM");
  | Scan.movep: IO.WriteString("MOVEP");
  | Scan.moveq: IO.WriteString("MOVEQ");
  | Scan.trap: IO.WriteString("TRAP");
  | Scan.divsl: IO.WriteString("DIVSL");
  | Scan.divul: IO.WriteString("DIVUL");
  | Scan.mulsl: IO.WriteString("MULSL");
  | Scan.mulul: IO.WriteString("MULUL");
  | Scan.chk2: IO.WriteString("CHK2");
  | Scan.cmp2: IO.WriteString("CMP2");
  | Scan.fmove: IO.WriteString("FMOVE");
  | Scan.fint: IO.WriteString("FINT");
  | Scan.fsinh: IO.WriteString("FSINH");
  | Scan.fintrz: IO.WriteString("FINTRZ");
  | Scan.fsqrt: IO.WriteString("FSQRT");
  | Scan.flognp1: IO.WriteString("FLOGNP1");
  | Scan.fetoxm1: IO.WriteString("FETOXM1");
  | Scan.ftanh: IO.WriteString("FTANH");
  | Scan.fatan: IO.WriteString("FATAN");
  | Scan.fasin: IO.WriteString("FASIN");
  | Scan.fatanh: IO.WriteString("FATANH");
  | Scan.fsin: IO.WriteString("FSIN");
  | Scan.ftan: IO.WriteString("FTAN");
  | Scan.flogn: IO.WriteString("FLOGN");
  | Scan.flog10: IO.WriteString("FLOG10");
  | Scan.flog2: IO.WriteString("FLOG2");
  | Scan.fabs: IO.WriteString("FABS");
  | Scan.fcosh: IO.WriteString("FCOSH");
  | Scan.fneg: IO.WriteString("FNEG");
  | Scan.facos: IO.WriteString("FACOS");
  | Scan.fcos: IO.WriteString("FCOS");
  | Scan.fgetexp: IO.WriteString("FGETEXP");
  | Scan.fgetman: IO.WriteString("FGETMAN");
  | Scan.fdiv: IO.WriteString("FDIV");
  | Scan.fmod: IO.WriteString("FMOD");
  | Scan.fadd: IO.WriteString("FADD");
  | Scan.fmul: IO.WriteString("FMUL");
  | Scan.fsgldiv: IO.WriteString("FSGLDIV");
  | Scan.frem: IO.WriteString("FREM");
  | Scan.fscale: IO.WriteString("FSCALE");
  | Scan.fsglmul: IO.WriteString("FSGLMUL");
  | Scan.fsub: IO.WriteString("FSUB");
  | Scan.fcmp: IO.WriteString("FCMP");
  | Scan.ftest: IO.WriteString("FTEST");
  | Scan.fsincos: IO.WriteString("FSINCOS");
  | Scan.fmovem: IO.WriteString("FMOVEM");
  ELSE			(* V1.24 reached maximum of case labels *)
    CASE com OF
      Scan.fetox: IO.WriteString("FETOX");
    | Scan.ftwotox: IO.WriteString("FTWOTOX");
    | Scan.ftentox: IO.WriteString("FTENTOX");
    | Scan.bra: IO.WriteString("BRA");
    | Scan.bsr: IO.WriteString("BSR");
    | Scan.bhi: IO.WriteString("BHI");
    | Scan.bls: IO.WriteString("BLS");
    | Scan.bhs: IO.WriteString("BHS");
    | Scan.blo: IO.WriteString("BLO");
    | Scan.bne: IO.WriteString("BNE");
    | Scan.beq: IO.WriteString("BEQ");
    | Scan.bvc: IO.WriteString("BVC");
    | Scan.bvs: IO.WriteString("BVS");
    | Scan.bpl: IO.WriteString("BPL");
    | Scan.bmi: IO.WriteString("BMI");
    | Scan.bge: IO.WriteString("BGE");
    | Scan.blt: IO.WriteString("BLT");
    | Scan.bgt: IO.WriteString("BGT");
    | Scan.ble: IO.WriteString("BLE");
    | Scan.fbf: IO.WriteString("FBF");
    | Scan.fbeq: IO.WriteString("FBEQ");
    | Scan.fbogt: IO.WriteString("FBOGT");
    | Scan.fboge: IO.WriteString("FBOGE");
    | Scan.fbolt: IO.WriteString("FBOLT");
    | Scan.fbole: IO.WriteString("FBOLE");
    | Scan.fbogl: IO.WriteString("FBOGL");
    | Scan.fbor: IO.WriteString("FBOR");
    | Scan.fbun: IO.WriteString("FBUN");
    | Scan.fbueq: IO.WriteString("FBUEQ");
    | Scan.fbugt: IO.WriteString("FBUGT");
    | Scan.fbuge: IO.WriteString("FBUGE");
    | Scan.fbult: IO.WriteString("FBULT");
    | Scan.fbule: IO.WriteString("FBULE");
    | Scan.fbne: IO.WriteString("FBNE");
    | Scan.fbt: IO.WriteString("FBT");
    | Scan.fbsf: IO.WriteString("FBSF");
    | Scan.fbseq: IO.WriteString("FBSEQ");
    | Scan.fbgt: IO.WriteString("FBGT");
    | Scan.fbge: IO.WriteString("FBGE");
    | Scan.fblt: IO.WriteString("FBLT");
    | Scan.fble: IO.WriteString("FBLE");
    | Scan.fbgl: IO.WriteString("FBGL");
    | Scan.fbgle: IO.WriteString("FBGLE");
    | Scan.fbngle: IO.WriteString("FBNGLE");
    | Scan.fbngl: IO.WriteString("FBNGL");
    | Scan.fbnle: IO.WriteString("FBNLE");
    | Scan.fbnlt: IO.WriteString("FBNLT");
    | Scan.fbnge: IO.WriteString("FBNGE");
    | Scan.fbngt: IO.WriteString("FBNGT");
    | Scan.fbsneq: IO.WriteString("FBSNEQ");
    | Scan.fbst: IO.WriteString("FBST");
    | Scan.fsf: IO.WriteString("FSF");
    | Scan.fseq: IO.WriteString("FSEQ");
    | Scan.fsogt: IO.WriteString("FSOGT");
    | Scan.fsoge: IO.WriteString("FSOGE");
    | Scan.fsolt: IO.WriteString("FSOLT");
    | Scan.fsole: IO.WriteString("FSOLE");
    | Scan.fsogl: IO.WriteString("FSOGL");
    | Scan.fsor: IO.WriteString("FSOR");
    | Scan.fsun: IO.WriteString("FSUN");
    | Scan.fsueq: IO.WriteString("FSUEQ");
    | Scan.fsugt: IO.WriteString("FSUGT");
    | Scan.fsuge: IO.WriteString("FSUGE");
    | Scan.fsult: IO.WriteString("FSULT");
    | Scan.fsule: IO.WriteString("FSULE");
    | Scan.fsne: IO.WriteString("FSNE");
    | Scan.fst: IO.WriteString("FST");
    | Scan.fssf: IO.WriteString("FSSF");
    | Scan.fsseq: IO.WriteString("FSSEQ");
    | Scan.fsgt: IO.WriteString("FSGT");
    | Scan.fsge: IO.WriteString("FSGE");
    | Scan.fslt: IO.WriteString("FSLT");
    | Scan.fsle: IO.WriteString("FSLE");
    | Scan.fsgl: IO.WriteString("FSGL");
    | Scan.fsgle: IO.WriteString("FSGLE");
    | Scan.fsngle: IO.WriteString("FSNGLE");
    | Scan.fsngl: IO.WriteString("FSNGL");
    | Scan.fsnle: IO.WriteString("FSNLE");
    | Scan.fsnlt: IO.WriteString("FSNLT");
    | Scan.fsnge: IO.WriteString("FSNGE");
    | Scan.fsngt: IO.WriteString("FSNGT");
    | Scan.fssneq: IO.WriteString("FSSNEQ");
    | Scan.fsst: IO.WriteString("FSST");
    | Scan.dbt:  IO.WriteString("DBT");
    | Scan.dbf:  IO.WriteString("DBF");
    | Scan.dbhi: IO.WriteString("DBHI");
    | Scan.dbls: IO.WriteString("DBLS");
    | Scan.dbhs: IO.WriteString("DBHS");
    | Scan.dblo: IO.WriteString("DBLO");
    | Scan.dbne: IO.WriteString("DBNE");
    | Scan.dbeq: IO.WriteString("DBEQ");
    | Scan.dbvc: IO.WriteString("DBVC");
    | Scan.dbvs: IO.WriteString("DBVS");
    | Scan.dbpl: IO.WriteString("DBPL");
    | Scan.dbmi: IO.WriteString("DBMI");
    | Scan.dbge: IO.WriteString("DBGE");
    | Scan.dblt: IO.WriteString("DBLT");
    | Scan.dbgt: IO.WriteString("DBGT");
    | Scan.dble: IO.WriteString("DBLE");
    | Scan.dc: IO.WriteString("DC");
    | Scan.ds: IO.WriteString("DS");
    | Scan.base: IO.WriteString("BASE");
    END;
  END;
 END WriteMnem;


PROCEDURE WriteExport(mark: INTEGER);
 BEGIN
  IF mark = Sym.Export THEN IO.WriteChar( "*")
  ELSIF mark = Sym.ReadOnly THEN IO.WriteChar( "-");
  END;
 END WriteExport;


PROCEDURE OutputStat*(s: Stat);
(*
 Output one statement on IO
 *)
  VAR
    f, size, i : INTEGER;
    sym : Sym.Symbol;
    sp: StringPtr;

  PROCEDURE BehindSep(sym: Sym.Symbol) : Sym.Symbol;
   BEGIN
    WHILE (sym.next # NIL) & (sym.form # Sym.Sep) DO
      sym := sym.next;
    END;
    RETURN sym.next;
   END BehindSep;

  PROCEDURE OutputDecl(sym: Sym.Symbol);
    VAR
      seg: INTEGER;
      sp : StringPtr;
   BEGIN
    IncInsert;
    seg := -1;
    WHILE sym # NIL DO
      CASE sym.form OF
        Sym.Mod:
          IF seg # Sym.Mod THEN
            IO.WriteLn; InsertSpace;
            IO.WriteString( "IMPORT");
            IO.WriteLn; seg := Sym.Mod;
          END;
          IncInsert;
          REPEAT
            InsertSpace;
            IO.WriteString( sym.name);
            sp := S.VAL( StringPtr, sym.a0);
            IF sp^ # sym.name THEN
              IO.WriteString( ":=");
              IO.WriteString( sp^);
            END;
            IF sym.mark = 1 THEN IO.WriteChar( "*") END;
            sym := sym.next;
            IF (sym # NIL) & (sym.form = Sym.Mod) THEN
              IO.WriteChar( ","); IO.WriteLn;
            END;
          UNTIL (sym = NIL) OR (sym.form # Sym.Mod);
          IO.WriteChar( ";"); IO.WriteLn;
          DecInsert;

      | Sym.Var:
          IF sym.lev >= 0 THEN
            IF seg # Sym.Var THEN
              IO.WriteLn; InsertSpace;
              IO.WriteString( "VAR");
              IO.WriteLn; seg := Sym.Var;
            END;
            IncInsert;
            REPEAT
              InsertSpace;
              IO.WriteString( sym.name);
              WriteExport(sym.mark);
              WHILE (sym.next # NIL) & (sym.next.form = Sym.Var) &
                    (sym.next.typ = sym.typ) DO
                IO.WriteString( ", ");
                sym := sym.next;
                IO.WriteString( sym.name);
                WriteExport(sym.mark);
              END;
              IO.WriteString( ": ");
              WriteTyp(sym.typ, TRUE);
              IO.WriteChar( ";"); IO.WriteLn;
              sym := sym.next;
            UNTIL (sym = NIL) OR (sym.form # Sym.Var);
            DecInsert;
          ELSE
            sym := sym.next;
          END;

      | Sym.Typ:
          IF sym.lev >= 0 THEN
            IF seg # Sym.Typ THEN
              IO.WriteLn; InsertSpace;
              IO.WriteString( "TYPE");
              IO.WriteLn;
              seg := Sym.Typ;
            END;
            IncInsert;
            InsertSpace;
            IO.WriteString( sym.name);
            WriteExport(sym.mark);
            IO.WriteString( " = ");
            WriteTyp(sym.typ, FALSE);
            IO.WriteChar( ";"); IO.WriteLn;
            sym := sym.next;
            DecInsert;
          ELSE
            sym := sym.next;
          END;

      | Sym.Con:
          IF sym.lev >= 0 THEN
            IF seg # Sym.Con THEN
              IO.WriteLn; InsertSpace;
              IO.WriteString( "CONST");
              IO.WriteLn;
              seg := Sym.Con;
            END;
            IncInsert;
            InsertSpace;
            IO.WriteString( sym.name);
            WriteExport(sym.mark);
            IO.WriteString( " = ");
            Expr.Output( S.VAL(Expr.Expr, sym.a1), TRUE);
            IO.WriteChar( ";"); IO.WriteLn;
            sym := sym.next;
            DecInsert;
          ELSE
            sym := sym.next;
          END;

      ELSE
        sym := sym.next;
      END;
    END;
    DecInsert;
   END OutputDecl;

 BEGIN
  CASE s.form OF

    Asgn:
      InsertSpace;
      Expr.Output( s.expr, TRUE);
      IO.WriteString(" := ");
      Expr.Output( s.expr2, TRUE);
      IO.WriteChar( ";");
      IO.WriteLn;

  | Call:
      InsertSpace;
      Expr.Output(s.expr, TRUE);
      IO.WriteChar( ";");
      IO.WriteLn;

  | Mod:
      IO.WriteLn;
      IO.WriteString( "MODULE ");
      IF s.sym = NIL THEN IO.WriteString( "NIL");
      ELSE IO.WriteString( s.sym.name);
      END;
      IO.WriteChar( ";");
      IO.WriteLn;
      IF s.sym # NIL THEN
        symbol := s.sym; Expr.symbol := symbol;
        OutputDecl( BehindSep(s.sym.syms) );
      END;

  | Proc:
      IO.WriteLn;
      InsertSpace;
      IO.WriteString( "PROCEDURE");
      f := s.sym.form;
      sym := s.sym.syms.next;
      IF f = Sym.CProc THEN
        IO.WriteString( "- ")
      ELSIF f = Sym.IProc THEN
        IO.WriteString( "+ ")
      ELSIF f = Sym.AProc THEN
        IO.WriteString( "~ ")
      ELSIF f = Sym.Tbp THEN
        IO.WriteString( " (");
        WritePar(sym, TRUE); sym := sym.next;
        IO.WriteString( ") ");
      ELSIF s.a0 = 0 THEN
        IO.WriteString( "^ ");
      ELSE
        IO.WriteChar( " ");
      END;
      IO.WriteString( s.sym.name);
      WriteExport(s.sym.mark);
      IO.WriteChar( "(");
      WritePars(sym);
      IO.WriteChar( ")");
      IF s.sym.typ.form # Sym.NoTyp THEN
        IO.WriteString( " : ");
        WriteTyp(s.sym.typ, TRUE);
      END;
      IF f = Sym.CProc THEN
        IO.WriteChar( " ");
        IO.WriteInt( s.sym.a1);
        IO.WriteChar( ",");
        IO.WriteInt( s.sym.a0);
      END;
      IO.WriteChar( ";");
      IO.WriteLn;
      IF s.a0 = 1 THEN
        s.sym.syms.a0 := S.VAL(LONGINT, symbol);
        symbol := s.sym; Expr.symbol := symbol;
        OutputDecl( BehindSep(sym) );
      ELSE
        IO.WriteLn;
      END;

  | End:
      DecInsert;
      InsertSpace;
      IO.WriteString( "END;");	(* end assembler *)
      IO.WriteLn;
      InsertSpace1;
      IO.WriteString( "END ");
      IO.WriteString( symbol.name);
      IF symbol.form = Sym.Mod THEN
        IO.WriteChar( ".");
      ELSE
        IO.WriteChar( ";");
      END(*IF*);
      symbol := S.VAL(Sym.Symbol, symbol.syms.a0);
      Expr.symbol := symbol;
      DecInsert;
      IO.WriteLn; IO.WriteLn;

  | Begin:
      IncInsert;
      InsertSpace1;
      IO.WriteString( "BEGIN"); IO.WriteLn;
      InsertSpace;
      IO.WriteString( "ASSEMBLER"); IO.WriteLn;
      IncInsert;

  | Bra:
      InsertSpace;
      IO.WriteString( "BRA ");
      Expr.Output(s.expr, TRUE);
      IO.WriteLn;

  | Bct:
      InsertSpace;
      IO.WriteString( "BCT ");
      Expr.Output(s.expr2, TRUE);
      IO.WriteChar( ",");
      Expr.Output(s.expr, TRUE);
      IO.WriteLn;

  | Bcf:
      InsertSpace;
      IO.WriteString( "BCF ");
      Expr.Output(s.expr2, TRUE);
      IO.WriteChar( ",");
      Expr.Output(s.expr, TRUE);
      IO.WriteLn;

  | Label:
      DecInsert;
      InsertSpace;
      Expr.Output(s.expr, TRUE);
      IF s.a0 > 0 THEN
        IO.WriteChar( "*");
        IF s.a0 > 1 THEN IO.WriteChar( "*") END;
      END;
      IO.WriteChar( ":");
      IO.WriteLn;
      IncInsert;

  | Base:
      InsertSpace;
      IO.WriteString( "BASE ");
      Expr.Output(s.expr, TRUE);
      IO.WriteLn;

  | Dcw:
      InsertSpace;
      IO.WriteString( "DC.W ");
      Expr.Output(s.expr, TRUE);
      IO.WriteLn;

  | Ret:
      InsertSpace;
      IO.WriteString( "RETURN");
      IF symbol.form # Sym.Mod THEN
        IF symbol.form = Sym.Tbp THEN i := 1
        ELSE i := symbol.lev+1
        END;
        DEC(i, SHORT( s.a0));
        WHILE i > 0 DO
          IO.WriteChar( "^"); DEC(i);
        END;
      END;
      IO.WriteLn;

  | Options:
      sp := S.VAL(StringPtr, s.a0-3);
      IO.WriteString( "(*$");
      i := 3;
      REPEAT
        IO.WriteChar( sp[i]);
        INC(i);
      UNTIL (sp[i-2] = "*") & (sp[i-1] = ")");
      IO.WriteLn;

  ELSE
      IF s.form = Scan.label THEN
        DecInsert; InsertSpace;
        Expr.Output(s.expr, TRUE); IO.WriteChar( ":");
        IO.WriteLn; IncInsert;
      ELSIF s.form = Scan.even THEN
        InsertSpace;
        IO.WriteString( "EVEN"); IO.WriteLn;
      ELSIF s.form >= Ass THEN
        InsertSpace;
        WriteMnem( s.form );
        size := SHORT( s.a0);
        IF size # NoSize THEN
          IO.WriteChar( ".");
          CASE size OF
            Byte: IO.WriteChar( "B");
          | Word: IO.WriteChar( "W");
          | Long: IO.WriteChar( "L");
          | Single: IO.WriteChar( "S");
          | Double: IO.WriteChar( "D");
          END;
        END;
        IO.WriteChar( " ");
        IF s.expr # NIL THEN
          Expr.Output( s.expr, TRUE);
          IF s.expr2 # NIL THEN
            IO.WriteChar( ",");
            Expr.Output( s.expr2, TRUE);
          END;
        END;
        IO.WriteLn;
      ELSE
        InsertSpace;
        IO.WriteString("Unknown statement #"); IO.WriteInt(s.form);
        IO.WriteLn;
      END;

  END;
 END OutputStat;


PROCEDURE Output*(begStat: Stat; fileno: INTEGER);
(*
 Output the statement sequence on IO
 *)
  VAR
    s: Stat;
    outputEnable: BOOLEAN;
 BEGIN
  IO.SetFile(fileno);
  Environment(begStat, symbol, s);
  Expr.symbol := symbol;
  outputEnable := TRUE;
  LOOP
    IF s = NIL THEN EXIT END;
    IF (s.form = OutCtrl) THEN
      IF (s.a0 = OCOut) THEN
        outputEnable := TRUE;
      ELSIF s.a0 = OCInh THEN
        outputEnable := FALSE
      END;
    ELSIF outputEnable THEN
      OutputStat(s);
    END;
    IF s.form = End THEN EXIT END;
    s := s.next;
  END;
 END Output;


PROCEDURE OptionsStat(ptr: S.PTR);
  VAR
    s : Stat;
 BEGIN
  New(Options, s); s.a0 := ptr;
  Add(s);
 END OptionsStat;


PROCEDURE Init*;
 BEGIN
 END Init;


PROCEDURE Exit*;
 BEGIN
  stats := NIL; last := NIL; insert := NIL;
  symbol := NIL; freeStats := NIL;
 END Exit;


BEGIN
  Scan.Options := OptionsStat;
END OCStat.