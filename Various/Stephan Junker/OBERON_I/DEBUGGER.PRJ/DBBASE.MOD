MODULE DbBase;


IMPORT
  S:=SYSTEM, Sys, VC:=VDIControl, VA:=VDIAttribute, VQ:=VDIInquiry,
  Str:=Strings, NumStr, FN:=Filename, Env:=Environment, Menus,
  ObnPar:=OCPar, Paths, File, ObjFile, O2Modules, Fsel;


CONST
  bss = 0; text = 1; data = 2; extern = 3; reglist = 4;
  global = 5; equate = 6; defined = 7;

  Decimal* = 0; SignedHex* = 1; UnsignedHex* = 2;


TYPE
  ModuleName*= ARRAY 10 OF CHAR;
  Module*    = O2Modules.Module;
  Exception* = POINTER TO ExcepDesc;
  ExcepDesc* = RECORD
                modList* : Module;
                basepage*: Sys.basepage;
                excAddr* : S.PTR;
                excSR*   : INTEGER;
                excRegs* : ARRAY 16 OF LONGINT;
                excType* : INTEGER;
              END;
  symptr*   = POINTER TO symbol;
  symstr*   = ARRAY 8 OF CHAR;
  symbol*   = RECORD
                Name*    : symstr;
                SymType* : SHORTINT;
                Magic*   : SHORTINT;
                Value*   : LONGINT;
                Extend*  : ARRAY 14 OF CHAR;
              END(*RECORD*);
  Source    = POINTER TO SrcDesc;
  SrcDesc   = RECORD
                next  : Source;
                name  : ARRAY 10 OF CHAR;
                begad : S.PTR;
                length: LONGINT;
              END;


VAR
  station- : INTEGER;
  exc*     : Exception;
  menu*    : Menus.Menu;
  editor*  : FN.path;
  Mod*     : Module;
  Begad*, Endad* : LONGINT;
  maxX*, maxY* : INTEGER;
  sources  : Source;


PROCEDURE LoadSource*(VAR name : ARRAY OF CHAR; VAR begad : S.PTR;
                      VAR length : LONGINT) : BOOLEAN;
(* Loads the source file with given name and returns it's start address
 * and length. If it is found, true is returned. If it was loaded
 * earlier, it will not be loaded again.
 *)
  VAR
    s : Source;
    path, mod : FN.path;
 BEGIN
  s := sources;
  WHILE s # NIL DO
    IF s.name = name THEN
      begad := s.begad; length := s.length;
      RETURN TRUE
    END;
    s := s.next;
  END;
  COPY(name, mod); mod[8] := 0X;
  FN.SetExt("MOD", mod);
  IF ~Paths.Get(ObnPar.ModPaths, mod, {}, mod) THEN
    path := "*.MOD";
    IF ~Fsel.ExInput(path, mod, "Load source file") THEN RETURN FALSE END;
  END;
  IF File.Load(mod, 0, 1, begad, length) THEN
    S.PUT( begad+length, 0);
    NEW(s); s.next := sources; sources := s;
    s.begad := begad; s.length := length;
    COPY(name, s.name);
    RETURN TRUE
  END;
  RETURN FALSE;
 END LoadSource;


PROCEDURE Convert*(number : LONGINT; dsp,len : SHORTINT; VAR s : ARRAY OF CHAR);
 BEGIN
  IF dsp = Decimal THEN
    NumStr.LIntTo( number, 10, s);
  ELSIF dsp = UnsignedHex THEN
    NumStr.LCardTo( number, 16, s);
    Str.Adjust( Str.right, len, "0", s); Str.AppendC("H", s);
  ELSIF dsp = SignedHex THEN
    NumStr.LIntTo( number, 16, s);
    Str.AppendC("H", s);
  ELSE
    HALT(100);
  END;
 END Convert;


PROCEDURE NextSymbol(VAR Ptr : symptr);
 BEGIN
  IF Ptr.Magic = 48H THEN INC(Ptr,28) ELSE INC(Ptr,14) END;
 END NextSymbol;


PROCEDURE TestSymType(Sym : symptr; Bit : INTEGER) : BOOLEAN;
 BEGIN
  RETURN Bit IN S.VAL(SET,LONG(LONG(Sym.SymType)))
 END TestSymType;


PROCEDURE MergeName(Ptr : symptr; VAR Name : ARRAY OF CHAR);
 BEGIN
  COPY(Ptr.Name,Name); Name[8] := 0X;
  IF Ptr.Magic = 48H THEN Str.Append(Ptr.Extend,Name) END;
 END MergeName;


PROCEDURE GetModProc*(addr : S.PTR; VAR mod, proc : ARRAY OF CHAR;
                      VAR modOff, procOff : LONGINT);
  VAR
    procadr, modadr, nextadr : S.PTR;
    module : O2Modules.Module;

  PROCEDURE~ SearchModuleAtAddress( mod: O2Modules.Module);
   BEGIN
    IF (addr >= mod.obj.TextAdr()) & (addr < mod.obj.DataAdr()) THEN
      module := mod;
    END;
   END SearchModuleAtAddress;

  PROCEDURE~ SearchProcedureAtAddress(VAR sym: ObjFile.Symbol);
    VAR
      adr: S.PTR;
   BEGIN
    IF ObjFile.Text IN sym.type THEN
      adr := sym.value + module.obj.TextAdr();
      IF (adr < addr) & (adr > procadr) THEN
        procadr := adr;
        COPY(sym.name, proc);
      END;
      IF (adr >= addr) & (adr < nextadr) THEN
        nextadr := adr;
      END;
    END;
   END SearchProcedureAtAddress;

 BEGIN
  module := NIL;
  O2Modules.Do( SearchModuleAtAddress);
  IF module # NIL THEN
    COPY( module.name, mod);
    modadr := module.obj.TextAdr();
    proc := ""; procadr := modadr;
    nextadr := modadr + module.obj.TextSize();
    module.obj.SymbolsDo( SearchProcedureAtAddress);
    modOff := addr - modadr;
    procOff := addr - procadr;
    Begad := procadr; Endad := nextadr;
    Mod := module;
  ELSE
    modOff := -1
  END;
 END GetModProc;


PROCEDURE GetFontData*(VAR dbt, charW, charH : INTEGER);
  VAR
    d,dbb : INTEGER;
    c : CHAR;
 BEGIN
  VQ.VqtFontinfo(station,c,c,dbb,d,d,d,dbt,charW,d,d,d);
  charH := dbt + dbb + 1;
 END GetFontData;


PROCEDURE Init*;
 BEGIN
 END Init;


PROCEDURE Exit*;
 BEGIN
  exc := NIL;
  Mod := NIL;
  sources := NIL;
 END Exit;


PROCEDURE InitMod;
  VAR
    Workin  : VC.workin;
    Workout : VC.workout;
 BEGIN
  station := 1;
  Workin.Id := 1; Workin.LineType := 1;
  Workin.LineColor := 1; Workin.MarkType := 1;
  Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 0;
  Workin.FillPat := 0; Workin.FillColor := 1;
  Workin.KoorType := 2;
  VC.VOpnvwk(Workin,station,Workout);
  VA.VswrMode(station,VA.REPLACE);
  VA.VsfPerimeter(station,FALSE);
  maxX := Workout.MaxX;
  maxY := Workout.MaxY;
 END InitMod;


BEGIN
  InitMod;
END DbBase.