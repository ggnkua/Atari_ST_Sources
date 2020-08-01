MODULE OCAss; (* SJ  20.5.94 *)


(*
 * the assembler included in STJ-Oberon-2
 *)


IMPORT
  S:=SYSTEM, Sym:=OCSymbol, Scan:=OCScan, Err:=OCErr, Com:=OCCom,
  Scr:=OCSymScan, Par:=OCPar, Stat:=OCStat, Expr:=OCExpr, OCH:=OCH2,
  Coder:=OCCoder, Assembler:=OCAssembler, OCStatScan, IO, Strings;



CONST
  (* symbol forms *)
  Def=Sym.Def; Var=Sym.Var; Fld=Sym.Fld; Typ=Sym.Typ; LProc=Sym.LProc;
  SProc=Sym.SProc; CProc=Sym.CProc; IProc=Sym.IProc; Mod=Sym.Mod;
  Con=Sym.Con; Tbp=Sym.Tbp; Ind=Sym.Ind; Cpy=Sym.Cpy; Head=Sym.Head;
  Sep=Sym.Sep;

  (*structure forms*)
  Undef=Sym.Undef; Byt=Sym.Byte; Bool=Sym.Bool; Char=Sym.Char;
  SInt=Sym.SInt; Int=Sym.Int; LInt=Sym.LInt; Real=Sym.Real;
  LReal=Sym.LReal; Set=Sym.Set; String=Sym.String; NilTyp=Sym.NilTyp;
  NoTyp=Sym.NoTyp; AnyPtr=Sym.AnyPtr; Pointer=Sym.Pointer;
  ProcTyp=Sym.ProcTyp; Array=Sym.Array; DynArr=Sym.DynArr;
  OpenArr=Sym.OpenArr; Record=Sym.Record; TbpStr=Sym.TbpStr;
  ProcStr=Sym.ProcStr;

  (*symbol values*)
  nosym=Scan.nosym; times=Scan.times; slash=Scan.slash; div=Scan.div;
  mod=Scan.mod; andb=Scan.andb; ands=Scan.and; plus=Scan.plus;
  minus=Scan.minus; ior=Scan.ior; xor=Scan.xor; shl=Scan.shl; shr=Scan.shr;
  ors=Scan.or; eql=Scan.eql; neq=Scan.neq; lss=Scan.lss; leq=Scan.leq;
  gtr=Scan.gtr; geq=Scan.geq; in=Scan.in; is=Scan.is; arrow=Scan.arrow;
  period=Scan.period; comma=Scan.comma; colon=Scan.colon; upto=Scan.upto;
  rparen=Scan.rparen; rbrak=Scan.rbrak; rbrace=Scan.rbrace; of=Scan.of;
  then=Scan.then; do=Scan.do; to=Scan.to; lparen=Scan.lparen;
  lbrak=Scan.lbrak; lbrace=Scan.lbrace; nots=Scan.not; becomes=Scan.becomes;
  number=Scan.number; nil=Scan.nil; string=Scan.string; ident=Scan.ident;
  semicolon=Scan.semicolon; bar=Scan.bar; end=Scan.end; else=Scan.else;
  elsif=Scan.elsif; until=Scan.until; if=Scan.if; case=Scan.case;
  while=Scan.while; repeat=Scan.repeat; loop=Scan.loop; with=Scan.with;
  exit=Scan.exit; return=Scan.return; array=Scan.array; record=Scan.record;
  pointer=Scan.pointer; begin=Scan.begin; const=Scan.const; type=Scan.type;
  var=Scan.var; procedure=Scan.procedure; import=Scan.import;
  module=Scan.module; eof=Scan.eof; assembler=Scan.assembler; for=Scan.for;
  by=Scan.by; notb=Scan.notb;

  (* assembler symbols *)
  elsec=Scan.elsec; elsifc=Scan.elsifc; align=Scan.align; macro=Scan.macro;
  endm=Scan.endm; irp=Scan.irp; rept=Scan.rept; def=Scan.def;
  endc=Scan.endc; on=Scan.on; off=Scan.off; include=Scan.include;
  message=Scan.message; warning=Scan.warning; error=Scan.error;
  fatal=Scan.fatal; b=Scan.b; w=Scan.w; l=Scan.l; s=Scan.s; d=Scan.d;
  cap=Scan.cap; upstring=Scan.upstring; local=Scan.local;
  supmode=Scan.supmode; eol=Scan.eol; equ=Scan.equ; set=Scan.set;
  charset=Scan.charset; cpu=Scan.cpu; hi=Scan.hi; ls=Scan.ls; hs=Scan.hs;
  lo=Scan.lo; ne=Scan.ne; eq=Scan.eq; vc=Scan.vc; vs=Scan.vs; pl=Scan.pl;
  mi=Scan.mi; ge=Scan.ge; lt=Scan.lt; gt=Scan.gt; le=Scan.le; sfc=Scan.sfc;
  dfc=Scan.dfc; cacr=Scan.cacr; usp=Scan.usp; vbr=Scan.vbr; caar=Scan.caar;
  msp=Scan.msp; isp=Scan.isp; segment=Scan.segment; code=Scan.code;
  data=Scan.data; bss=Scan.bss; even=Scan.even; d0=Scan.d0; a0=Scan.a0;
  fp0=Scan.fp0; pc=Scan.pc; sr=Scan.sr; ccr=Scan.ccr; ifc=Scan.ifc;

  (* assembler expressions *)
  Dn=Expr.Dn; An=Expr.An; ARI=Expr.ARI; API=Expr.API; APD=Expr.APD;
  DA=Expr.DA; DAX=Expr.DAX; AbsW=Expr.AbsW; AbsL=Expr.AbsL; Mem=Expr.Mem;
  MIPo=Expr.MIPo; MIPr=Expr.MIPr; PCD=Expr.PCD; PCDI=Expr.PCDI;
  PCPo=Expr.PCPo; PCPr=Expr.PCPr; Imm=Expr.Imm; DDn=Expr.DDn; FPn=Expr.FPn;
  Rlst=Expr.Rlst; FRlst=Expr.FRlst; CCR=Expr.CCR; SR=Expr.SR; USP=Expr.USP;
  SFR=Expr.SFR; PC=Expr.PC;

  (* error codes *)
  ext2only = 119; sizeexp = 171; noasscom = 172; aregexp = 173;
  xregexp = 174; not68000 = 175; scaleexp = 176; illaddr = 177;
  addr030only = 178; com030only = 179; comfpuonly = 180;
  intonly = 116; locvaruse = -3; linkreg = 183; unknown = 127;
  illfac = 112; notimpl = 191; dregexp = 195; nolstmix = 196;
  labelexp = 199;

  IntTypes = {SInt, Int, LInt}; RealTypes = {Real, LReal};
  SimpleTypes = {SInt,Int,LInt,Char,Bool,Byt,Set,Real,LReal,AnyPtr,Pointer,ProcTyp};

  (* size codes in assembler statements *)
  Byte=Stat.Byte; Word=Stat.Word; Long=Stat.Long; Single=Stat.Single;
  Double=Stat.Double; NoSize=Stat.NoSize;

  (* codes for parameter "use" in Checkwsd *)
  normal = 0; xcode = 1; fpu = 2;

  (* **** RRR* SS** *rrr *)
  abcd = Scan.abcd;  addx = Scan.addx;  sbcd = Scan.sbcd;
  subx = Scan.subx;  cmpm = Scan.cmpm;

  (* **** DDD* SSee eeee *)
  add = Scan.add;   and = Scan.andm;   or = Scan.orm;
  sub = Scan.sub;   cmp = Scan.cmp;

  eor = Scan.eor;

  (* **** RRRs **ee eeee *)
  adda = Scan.adda;   cmpa = Scan.cmpa;
  lea = Scan.lea;   suba = Scan.suba;

  (* **** **** SSEE EEEE *)
  addi = Scan.addi;   andi = Scan.andi;
  cmpi = Scan.cmpi;   eori = Scan.eori;
  ori = Scan.ori;   subi = Scan.subi;

  (* **** qqq* SSEE EEEE *)
  addq = Scan.addq;     subq = Scan.subq;

  (* **** ddd* SS** *DDD *)
  asl = Scan.asl;      asr = Scan.asr;
  lsr = Scan.lsr;       lsl = Scan.lsl;
  rol = Scan.rol;       ror = Scan.ror;
  roxl = Scan.roxl;     roxr = Scan.roxr;

  (* **** rrr* **EE EEEE *)
  bchg = Scan.bchg;     bclr = Scan.bclr;     bset = Scan.bset;
  btst = Scan.btst;     exg = Scan.exg;

  (* **** DDD* *see eeee *)
  chk = Scan.chk;

  (* **** **** SSEE EEEE *)
  clr = Scan.clr;       neg = Scan.neg;
  negx = Scan.negx;     not = Scan.notm;
  tst = Scan.tst;

  (* **** **** **EE EEEE *)
  jmp = Scan.jmp;     jsr = Scan.jsr;
  pea = Scan.pea;     nbcd = Scan.nbcd;
  st = Scan.st;       sf = Scan.sf;
  shi = Scan.shi;     sls = Scan.sls;
  shs = Scan.shs;     slo = Scan.slo;
  sne = Scan.sne;     seq = Scan.seq;   svc = Scan.svc;
  svs = Scan.svs;     spl = Scan.spl;
  smi = Scan.smi;     sge = Scan.sge;
  slt = Scan.slt;     sgt = Scan.sgt;
  sle = Scan.sle;     tas = Scan.tas;

  (* **** **** *sEE EEEE *)
  ext = Scan.ext;     extb = Scan.extb;

  (* **** **** **** *RRR *)
  unlk = Scan.unlk;   link = Scan.link;
  swap = Scan.swap;

  (* **** DDD* **ee eeee *)
  divs = Scan.divs;   divu = Scan.divu;
  muls = Scan.muls;   mulu = Scan.mulu;

  (* **** 1100 **ee eeee  0DDD r000 0000 0DDD *)
  divsl = Scan.divsl;   divul = Scan.divul;
  mulsl = Scan.mulsl;   mulul = Scan.mulul;

  (* **** **** **** **** *)
  rts = Scan.rts;          illegal = Scan.illegal;
  nop = Scan.nop;          reset = Scan.reset;
  rte = Scan.rte;          rtr = Scan.rtr;
  stop = Scan.stop;        trapv = Scan.trapv;
  rtd = Scan.rtd;

  (* **XX RRRM MMee eeee *)
  move = Scan.move;        movea = Scan.movea;

  (* **** **** *sEE EEEE + RegList *)
  movem = Scan.movem;

  (* **** ddd* *s** *AAA *)
  movep = Scan.movep;

  (* **** DDD* qqqq qqqq *)
  moveq = Scan.moveq;

  (* **** **** **** ***r  RRRR ssss ssss ssss *)
  movec = Scan.movec;

  (* **** **** **** VVVV *)
  trap = Scan.trap;

  (* from here to fbst 2 words base code *)

  (* **** *SS* **ee eeee  RRRR **** **** **** *)
  chk2 = Scan.chk2;     cmp2 = Scan.cmp2;

  (* **** **** **** **** ***f ffFF F*** ****  size fehlt!? *)
  fmove = Scan.fmove;       fint = Scan.fint;
  fsinh = Scan.fsinh;       fintrz = Scan.fintrz;
  fsqrt = Scan.fsqrt;       flognp1 = Scan.flognp1;
  fetoxm1 = Scan.fetoxm1;   ftanh = Scan.ftanh;
  fatan = Scan.fatan;       fasin = Scan.fasin;
  fatanh = Scan.fatanh;     fsin = Scan.fsin;
  ftan = Scan.ftan;         fetox = Scan.fetox;
  ftwotox = Scan.ftwotox;   ftentox = Scan.ftentox;
  flogn = Scan.flogn;       flog10 = Scan.flog10;
  flog2 = Scan.flog2;       fabs = Scan.fabs;
  fcosh = Scan.fcosh;       fneg = Scan.fneg;
  facos = Scan.facos;       fcos = Scan.fcos;
  fgetexp = Scan.fgetexp;   fgetman = Scan.fgetman;
  fdiv = Scan.fdiv;         fmod = Scan.fmod;
  fadd = Scan.fadd;         fmul = Scan.fmul;
  fsgldiv = Scan.fsgldiv;   frem = Scan.frem;
  fscale = Scan.fscale;     fsglmul = Scan.fsglmul;
  fsub = Scan.fsub;         fcmp = Scan.fcmp;

  fsincos = Scan.fsincos;

  (* **** **** **** ****  ***f ff?? ?*** **** *)
  ftest = Scan.ftest;

  (* **** **** **EE EEEE ???????????????????? *)
  fmovem = Scan.fmovem;

  (* all codes higher or same fbf are label commands *)

  (* **** **** *soo oooo **** **** **** **** *)
  fbf = Scan.fbf;         fbeq = Scan.fbeq;
  fbogt = Scan.fbogt;     fboge = Scan.fboge;
  fbolt = Scan.fbolt;     fbole = Scan.fbole;
  fbogl = Scan.fbogl;     fbor = Scan.fbor;
  fbun = Scan.fbun;       fbueq = Scan.fbueq;
  fbugt = Scan.fbugt;     fbuge = Scan.fbuge;
  fbult = Scan.fbult;     fbule = Scan.fbule;
  fbne = Scan.fbne;       fbt = Scan.fbt;
  fbsf = Scan.fbsf;       fbseq = Scan.fbseq;
  fbgt = Scan.fbgt;       fbge = Scan.fbge;
  fblt = Scan.fblt;       fble = Scan.fble;
  fbgl = Scan.fbgl;       fbgle = Scan.fbgle;
  fbngle = Scan.fbngle;   fbngl = Scan.fbngl;
  fbnle = Scan.fbnle;     fbnlt = Scan.fbnlt;
  fbnge = Scan.fbnge;     fbngt = Scan.fbngt;
  fbsneq = Scan.fbsneq;   fbst = Scan.fbst;

  (* **** **** OOOO OOOO *)
  bra = Scan.bra;         bsr = Scan.bsr;
  bhi = Scan.bhi;         bls = Scan.bls;
  bhs = Scan.bhs;         blo = Scan.blo;
  bne = Scan.bne;         beq = Scan.beq;
  bvc = Scan.bvc;         bvs = Scan.bvs;
  bpl = Scan.bpl;         bmi = Scan.bmi;
  bge = Scan.bge;         blt = Scan.blt;
  bgt = Scan.bgt;         ble = Scan.ble;

  (* **** **** **** *DDD *)
  dbt = Scan.dbt;         dbf = Scan.dbf;
  dbhi = Scan.dbhi;       dbls = Scan.dbls;
  dbhs = Scan.dbhs;       dblo = Scan.dblo;
  dbne = Scan.dbne;       dbeq = Scan.dbeq;
  dbvc = Scan.dbvc;       dbvs = Scan.dbvs;
  dbpl = Scan.dbpl;       dbmi = Scan.dbmi;
  dbge = Scan.dbge;       dblt = Scan.dblt;
  dbgt = Scan.dbgt;       dble = Scan.dble;

  (* special commands *)
  label = Scan.label;     dc = Scan.dc;
  ds = Scan.ds;           base = Scan.base;
  nocom = Scan.nocom;



VAR
  comsize: INTEGER;
  linkReg: INTEGER;



PROCEDURE SizeType(size: INTEGER) : Sym.Struct;
 BEGIN
  CASE size OF
    Byte: RETURN Sym.sinttyp;
  | Word: RETURN Sym.inttyp;
  | Long: RETURN Sym.linttyp;
  | Single: RETURN Sym.realtyp;
  | Double: RETURN Sym.lrltyp;
  | NoSize: RETURN Sym.notyp;
  END;
 END SizeType;


PROCEDURE GetSize() : INTEGER;
 BEGIN
  IF (Scr.sym >= b) AND (Scr.sym <= d) THEN
    RETURN Scr.sym - b
  END;
  Err.Mark(sizeexp);
  RETURN NoSize
 END GetSize;


PROCEDURE SetLinkReg(e: Expr.Expr);
  VAR
    reg: INTEGER;
 BEGIN
  IF (e.form = Expr.Sym) & (e.sym.form IN {Var, Ind, Cpy}) & (e.sym.lev > 0) THEN
    reg := 7 - e.sym.lev;
    IF (linkReg # -1) & (reg # linkReg) THEN Err.Mark(linkreg) END;
    linkReg := reg;

  ELSIF (e.form >= Expr.FSingle) THEN
    SetLinkReg(e.op1);
    IF (e.form >= Expr.FDual) THEN SetLinkReg(e.op2) END;

  END;
 END SetLinkReg;


PROCEDURE ConstExpression(VAR x: Expr.Expr);
 BEGIN
  Scr.Expression(x);
  IF ~Coder.IsConst(x) THEN Err.Mark(const) END;
  IF (x.typ.form = Sym.String) & (comsize = Stat.Byte) THEN
    OCH.StringToChar(x);
  END;
  SetLinkReg(x);
 END ConstExpression;


PROCEDURE GetItem(VAR item : Expr.Expr);
  VAR
    x,y : Expr.Expr;
    val : LONGINT;
    label : BOOLEAN;

  PROCEDURE IsRegister(sym: INTEGER; VAR x: Expr.Expr) : BOOLEAN;
   BEGIN
    IF (sym >= d0) AND (sym <= d0+7) THEN
      x := Com.Dn( sym-d0, Sym.notyp);
    ELSIF (sym >= a0) AND (sym <= a0+7) THEN
      x := Com.An( sym-a0, Sym.notyp);
    ELSIF (sym >= fp0) AND (sym <= fp0+7) THEN
      x := Com.FPn( sym-fp0, Sym.notyp);
    ELSE
      RETURN FALSE;
    END;
    RETURN TRUE
   END IsRegister;

  PROCEDURE GetRegister(VAR x: Expr.Expr) : BOOLEAN;
    VAR
      y, z: Expr.Expr;
      fpn : BOOLEAN;

    PROCEDURE GetReg(VAR y: Expr.Expr);
     BEGIN
      Scan.Get(Scr.sym);
      IF IsRegister(Scr.sym, y) THEN
        IF (y.form = FPn) & ~fpn OR (y.form # FPn) & fpn THEN
          Err.Mark(nolstmix);
        END;
        Scan.Get(Scr.sym);
      ELSE
        Err.Mark(illaddr);
        y := Com.Dn(0, Sym.notyp);
      END;
     END GetReg;

    PROCEDURE GetRegRange(VAR x: Expr.Expr);
      VAR
        y: Expr.Expr;
     BEGIN
      IF Scr.sym = minus THEN
        Expr.New( Expr.Sub, y, Sym.notyp);
        GetReg(y.op2); y.op1 := x;
        x := y;
      END;
     END GetRegRange;

   BEGIN
    IF IsRegister(Scr.sym, x) THEN
      fpn := x.form = FPn;
      Scan.Get(Scr.sym);
      IF (Scr.sym = Scan.minus) OR (Scr.sym = Scan.slash) THEN(* register list *)
        z := x; GetRegRange(z);
        WHILE Scr.sym = slash DO
          Expr.New( Expr.RDv, y, Sym.notyp);
          GetReg(y.op2); y.op1 := z;
          GetRegRange(y.op2); z := y;
        END;
        IF fpn THEN Expr.New(FRlst, x, Sym.notyp)
        ELSE Expr.New(Rlst, x, Sym.notyp)
        END;
        x.op1 := z;
      ELSIF Scr.sym = colon THEN
        Expr.New(DDn, y, Sym.notyp);
        GetReg(y.op2); y.op1 := x;
        IF (y.op1.form # Dn) OR (y.op2.form # Dn) THEN
          Err.Mark(dregexp)
        END;
        x := y;
      END;
      RETURN TRUE
    END;
    RETURN FALSE
   END GetRegister;

  PROCEDURE Displace(VAR x : Expr.Expr; y: Expr.Expr);
    VAR
      disp: Expr.Expr;
   BEGIN
    IF x = NIL THEN x := y
    ELSE
      Expr.New(Expr.Disp, disp, Sym.notyp);
      disp.op1 := x; disp.op2 := y; x := disp;
    END;
   END Displace;

  PROCEDURE GetIndexReg(VAR inx: Expr.Expr);
    VAR
      x, y, mul: Expr.Expr;
   BEGIN
    Scan.Get(Scr.sym);
    IF Scr.sym = period THEN
      Scan.Get(Scr.sym);
      inx.typ := SizeType( GetSize() );
      Scan.Get(Scr.sym);
      Expr.New( Expr.XReg, x, inx.typ);
      x.op1 := inx; inx := x;
    END;
    IF Scr.sym = times THEN
      ConstExpression(y);
      IF ~(y.typ.form IN IntTypes) OR (y.form # Expr.Con) THEN
        Err.Mark(intonly)
      END;
      IF ~(y.a0 IN {1, 2, 4, 8}) THEN Err.Mark(scaleexp) END;
      Expr.New( Expr.Mul, mul, Sym.notyp);
      mul.op1 := inx; mul.op2 := y;
      inx := mul;
    END;
   END GetIndexReg;

  PROCEDURE GetParen(VAR x: Expr.Expr);
    VAR
      y, z, d, disp, inx, ind, base: Expr.Expr;
   BEGIN
    inx := NIL; disp := NIL; ind := NIL; base := NIL;
    Expr.New(MIPo, x, Sym.notyp); x.op1 := NIL;
    Scan.Get(Scr.sym);
    LOOP	(* to exit *)
      IF Scr.sym = lbrak THEN
        LOOP	(* to exit *)
          Expr.New( Expr.Ind, ind, Sym.notyp); ind.op1 := NIL;
          Scan.Get(Scr.sym);
          IF Scr.sym = pc THEN
            Expr.New(PC, base, Sym.notyp);
            ind.op1 := base;
            IF Scr.sym = comma THEN Scan.Get(Scr.sym);
            ELSE EXIT;
            END;
          END;
          IF IsRegister(Scr.sym, y) THEN
            GetIndexReg(y);
            IF (base # NIL) OR (y.form # An) THEN inx := y
            ELSE base := y
            END;
            Displace( ind.op1, y);
            IF Scr.sym = comma THEN Scan.Get(Scr.sym);
            ELSE EXIT;
            END;
          END;
          IF (inx = NIL) & IsRegister(Scr.sym, y) THEN
            GetIndexReg(y); inx := y;
            Displace(ind.op1, y);
            IF Scr.sym = comma THEN Scan.Get(Scr.sym);
            ELSE EXIT;
            END;
          END;
          ConstExpression(y);
          Displace(ind.op1, y);
          EXIT;
        END;
        x.op1 := ind;
        Scr.CheckSym(rbrak);
        IF Scr.sym = comma THEN Scan.Get(Scr.sym);
        ELSE EXIT;
        END;
      END;
      IF (ind = NIL) & (Scr.sym = pc) THEN
        Expr.New(PC, base, Sym.notyp);
        x.op1 := base;
        Scan.Get(Scr.sym);
        IF Scr.sym = comma THEN Scan.Get(Scr.sym);
        ELSE EXIT;
        END;
      END;
      IF (ind = NIL) & (base = NIL) & IsRegister(Scr.sym, y) THEN
        GetIndexReg(y);
        Displace( x.op1, y);
        IF y.form # An THEN inx := y ELSE base := y END;
        IF Scr.sym = comma THEN Scan.Get(Scr.sym);
        ELSE EXIT;
        END;
      END;
      IF (inx = NIL) & IsRegister(Scr.sym, inx) THEN
        GetIndexReg(inx);
        Displace(x.op1, inx);
        IF Scr.sym = comma THEN Scan.Get(Scr.sym);
        ELSE EXIT;
        END;
      END;
      ConstExpression(disp);
      Displace(x.op1, disp);
      EXIT
    END;
    Scr.CheckSym(rparen);
    IF (ind = NIL) & (base # NIL) THEN
      IF inx = NIL THEN
        IF base.form = PC THEN x.form := PCD
        ELSIF disp = NIL THEN x.form := ARI
        ELSE x.form := DA
        END;
      ELSIF base.form = PC THEN x.form := PCDI
      ELSE x.form := DAX
      END;
    ELSIF (ind = NIL) & (disp = NIL) & (inx = NIL) THEN
      Err.Mark(illaddr)
    ELSIF inx = NIL THEN
      x.form := MIPr;
    END;
   END GetParen;

  PROCEDURE GetNumber(VAR x: Expr.Expr);
    VAR
      y: Expr.Expr;
      d: LONGINT;
      i: INTEGER;
   BEGIN
    IF Scr.sym = Scan.lparen THEN
      GetParen(y);
      IF y.form = ARI THEN
        y.form := DA; Displace(y.op1, x);
      ELSIF (y.form = DAX) & (y.op1.op1.form # Expr.Disp) THEN
        Displace(y.op1, x);
      ELSIF (y.form = PCD) OR (y.form = PCDI) THEN
        Displace(y.op1, x);
      ELSE
        Err.Mark(illaddr)
      END;
      x := y;
    ELSIF Scr.sym = period THEN
      Scan.Get( Scr.sym);
      i := GetSize();
      Scan.Get( Scr.sym);
      IF i = Word THEN
        Expr.New( Expr.AbsW, y, x.typ);
      ELSIF i = Long THEN
        Expr.New( Expr.AbsL, y, x.typ);
      ELSE
        Err.Mark(illaddr); RETURN ;
      END;
      y.op1 := x; x := y;
    ELSIF x.form = Expr.Con THEN
      Expr.New( Expr.Mem, y, x.typ);
      y.op1 := x; x := y;
    END;
   END GetNumber;

 BEGIN
  x := NIL;
  IF Scr.sym # eol THEN
    linkReg := -1;
    IF GetRegister(x) THEN
    ELSIF Scr.sym = neq THEN		(* immediate *)
      Scan.Get(Scr.sym);
      ConstExpression(y);
      Expr.New( Imm, x, SizeType(comsize));
      x.op1 := y;
    ELSIF Scr.sym = ccr THEN
      Expr.New(CCR, x, Sym.notyp); Scan.Get(Scr.sym);
    ELSIF Scr.sym = sr THEN
      Expr.New(SR, x, Sym.notyp); Scan.Get(Scr.sym);
    ELSIF Scr.sym = usp THEN
      Expr.New(USP, x, Sym.notyp); Scan.Get(Scr.sym);
    ELSIF (Scr.sym >= sfc) AND (Scr.sym <= isp) THEN
      Expr.New(SFR, x, Sym.notyp); x.a0 := Scr.sym;
      Scan.Get(Scr.sym);
    ELSIF Scr.sym = lparen THEN
      GetParen(x);
      IF (Scr.sym = plus) & (x.form = ARI) THEN
        x.form := API; Scan.Get(Scr.sym);
      END;
    ELSIF Scr.sym = minus THEN
      Scan.Get(Scr.sym);
      IF Scr.sym = lparen THEN
        GetParen(x);
        IF x.form = ARI THEN x.form := APD
        ELSE Err.Mark(illaddr)
        END;
      ELSE
        ConstExpression(x);
        x := Com.Neg(x);
        GetNumber(x);
      END;
    ELSE
      ConstExpression(x);
      GetNumber(x);
    END;
    IF (x # NIL) AND (linkReg # -1) THEN
      IF x.form = Expr.DA THEN
        IF Coder.BaseReg(x) # linkReg THEN Err.Mark(linkreg) END;
      ELSE
        Expr.New( Expr.Def, y, x.typ); y.op2 := x;
        y.form := Expr.Disp;
        y.op1 := Com.An(linkReg, Sym.notyp);
        x := Com.OneOpExpr( DA, Sym.notyp, y);
      END;
    END;
  END;
  item := x;
 END GetItem;


PROCEDURE StoreCommand(mnem, size : INTEGER; src, dest : Expr.Expr);
  CONST
    bwl  = {Byte, Word, Long};
    wl   = {Word, Long};
    sd   = {Single, Double};
    read = {Dn..Imm};
    mem  = {ARI..MIPr};
    alt  = {Dn..MIPr};
    dalt = {Dn,ARI..MIPr};
    adr  = {ARI,DA..PCPr};
  VAR
    fnd : BOOLEAN;
    x   : Expr.Expr;
    s   : Stat.Stat;

  PROCEDURE Checkwsd(newm, use, default: INTEGER; sizes, srcs, dests : SET;
                     msg : BOOLEAN);
   BEGIN
    IF NOT fnd THEN
      IF NOT (size IN sizes) AND (size # NoSize)
         OR (src = NIL) AND (srcs # {})
         OR (dest = NIL) AND (dests # {})
         OR (src # NIL) AND NOT (src.form IN srcs)
            & ((src.form # Expr.Sym) OR ~(Mem IN srcs))
         OR (dest # NIL) AND NOT (dest.form IN dests)
            & ((dest.form # Expr.Sym) OR ~(Mem IN dests)) THEN
        IF msg THEN Err.Mark(noasscom) END;
      ELSE
        IF size = NoSize THEN size := default END;
        fnd := TRUE; mnem := newm;
        IF src # NIL THEN
(*          IF NOT Par.xcode AND (src.form IN {MIPo, MIPr, PCPo, PCPr, DDn}) THEN
            Err.Mark(addr030only)
          END;*)
          src.typ := SizeType(size)
        END;
        IF dest # NIL THEN
(*          IF NOT Par.xcode AND (dest.form IN {MIPo, MIPr, PCPo, PCPr, DDn}) THEN
            Err.Mark(addr030only)
          END;*)
          dest.typ := SizeType(size)
        END;
(*        IF (use = fpu) AND NOT Par.fpu THEN
          Err.Mark(comfpuonly)
        END;
        IF (use = xcode) AND NOT Par.xcode THEN
          Err.Mark(com030only)
        END;*)
      END;
    END;
   END Checkwsd;

 BEGIN
  IF mnem = dc THEN
    LOOP
      GetItem(x);
      Stat.New(mnem, s); Stat.Add(s);
      Assembler.ReplaceAss(s, mnem, SizeType(size), x, NIL);
      IF Scr.sym = comma THEN Scan.Get(Scr.sym) ELSE EXIT END(*IF*);
    END(*LOOP*);
  ELSE
    fnd := FALSE;
    CASE mnem OF
      abcd,sbcd:
        Checkwsd(mnem, normal, Byte, {Byte}, {Dn}, {Dn}, FALSE);
        Checkwsd(mnem, normal, Byte, {Byte}, {APD}, {APD}, TRUE);
    | addx, subx:
        Checkwsd(mnem, normal, Word, bwl, {Dn}, {Dn}, FALSE);
        Checkwsd(mnem, normal, Word, bwl, {APD}, {APD}, TRUE);
    | cmpm:
        Checkwsd(cmpm, normal, Word, bwl, {API}, {API}, TRUE);
    | add, sub:
        Checkwsd(mnem, normal, Word, bwl, read, {Dn}, FALSE);
        Checkwsd(mnem, normal, Word, bwl, {Dn}, mem, FALSE);
        Checkwsd(mnem+(addi-add), normal, Word, bwl, {Imm}, dalt, FALSE);
        Checkwsd(mnem+(adda-add), normal, Long, wl, read, {An}, TRUE);
    | and, or:
        Checkwsd(mnem, normal, Word, bwl, read, {Dn}, FALSE);
        Checkwsd(mnem, normal, Word, bwl, {Dn}, mem, FALSE);
        Checkwsd(mnem+(andi-and), normal, Word, bwl, {Imm}, dalt, TRUE);
    | cmp:
        Checkwsd(cmp, normal, Word, bwl, read, {Dn}, FALSE);
        Checkwsd(cmpi, normal, Word, bwl, {Imm}, dalt, FALSE);
        Checkwsd(cmpa, normal, Long, wl, read, {An}, TRUE);
    | eor:
        Checkwsd(eor, normal, Word, bwl, {Dn}, dalt, FALSE);
        Checkwsd(eori, normal, Word, bwl, {Imm}, dalt, FALSE);
        Checkwsd(eori, normal, Byte, {Byte}, {Imm}, {CCR}, FALSE);
        Checkwsd(eori, normal, Word, {Word}, {Imm}, {SR}, TRUE);
    | adda, cmpa, suba:
        Checkwsd(mnem, normal, Long, wl, read, {An}, TRUE);
    | lea:
        Checkwsd(mnem, normal, Long, {Long}, adr, {An}, TRUE);
    | addi, subi, cmpi:
        Checkwsd(mnem, normal, Word, bwl, {Imm}, dalt, TRUE);
    | andi, eori, ori:
        Checkwsd(mnem, normal, Word, bwl, {Imm}, dalt, FALSE);
        Checkwsd(mnem, normal, Byte, {Byte}, {Imm}, {CCR}, FALSE);
        Checkwsd(mnem, normal, Word, {Word}, {Imm}, {SR}, TRUE);
    | addq, subq:
        Checkwsd(mnem, normal, Word, bwl, {Imm}, alt, TRUE);
        src.typ := Sym.notyp;
    | asl, asr, lsr, lsl, ror, rol, roxr, roxl:
        Checkwsd(mnem, normal, Word, bwl, {Dn, Imm}, {Dn}, FALSE);
        Checkwsd(mnem, normal, Word, {Word}, {Imm}, mem, FALSE);
        Checkwsd(mnem, normal, Word, {Word}, mem, {}, TRUE);
        IF (src.form = Imm) THEN src.typ := Sym.notyp END;
    | bchg, bclr, bset, btst:
        Checkwsd(mnem, normal, Byte, {Byte}, {Dn, Imm}, mem, FALSE);
        Checkwsd(mnem, normal, Long, {Long}, {Dn, Imm}, {Dn}, TRUE);
        IF (src.form = Imm) THEN src.typ := Sym.inttyp END;
    | chk:
        Checkwsd(mnem, normal, Word, {Word}, read-{An}, {Dn}, FALSE);
        Checkwsd(mnem, xcode, Long, {Long}, read-{An}, {Dn}, TRUE);
    | clr:
        Checkwsd(mnem, normal, Word, bwl, dalt, {}, TRUE);
    | jmp, jsr:
        Checkwsd(mnem, normal, NoSize, {}, adr, {}, TRUE);
    | ext:
        Checkwsd(mnem, normal, Word, wl, {Dn}, {}, TRUE);
    | nbcd:
        Checkwsd(mnem, normal, Byte, {Byte}, dalt, {}, TRUE);
    | neg, negx, not, tst:
        Checkwsd(mnem, normal, Word, bwl, dalt, {}, TRUE);
    | pea:
        Checkwsd(mnem, normal, Long, {Long}, adr, {}, TRUE);
    | st..sle, tas:
        Checkwsd(mnem, normal, Byte, {Byte}, dalt, {}, TRUE);
    | swap:
        Checkwsd(mnem, normal, Word, {Word}, {Dn}, {}, TRUE);
    | unlk:
        Checkwsd(mnem, normal, NoSize, {}, {An}, {}, TRUE);
    | extb:
        Checkwsd(mnem, normal, Long, {Long}, {Dn}, {}, TRUE);
    | divs..mulu:
        Checkwsd(mnem, normal, Word, wl, read-{An}, {Dn}, TRUE);
    | exg:
        Checkwsd(mnem, normal, Long, {Long}, {Dn, An}, {Dn, An}, TRUE);
    | rts..trapv:
        Checkwsd(mnem, normal, NoSize, {}, {}, {}, TRUE);
    | link:
        Checkwsd(mnem, normal, Word, {Word}, {An}, {Imm}, FALSE);
        Checkwsd(mnem, xcode, Long, {Long}, {An}, {Imm}, TRUE);
    | move:
        Checkwsd(mnem, normal, Word, bwl, read, dalt, FALSE);
        Checkwsd(mnem, normal, Word, {Word}, read-{An}, {SR,CCR}, FALSE);
        Checkwsd(mnem, normal, Word, {Word}, {SR,CCR}, dalt, FALSE);
        Checkwsd(mnem, normal, Long, {Long}, {An}, {USP}, FALSE);
        Checkwsd(mnem, normal, Long, {Long}, {USP}, {An}, FALSE);
        Checkwsd(movea, normal, Long, wl, read, {An}, TRUE);
    | movea:
        Checkwsd(mnem, normal, Long, wl, read, {An}, TRUE);
    | movem:
        Checkwsd(mnem, normal, Long, wl, adr+{API}, {Rlst}, FALSE);
        Checkwsd(mnem, normal, Long, wl, {Rlst}, mem-{API}, TRUE);
    | movep:
        Checkwsd(mnem, normal, Word, wl, {Dn}, {DA}, FALSE);
        Checkwsd(mnem, normal, Word, wl, {DA}, {Dn}, TRUE);
    | moveq:
        Checkwsd(mnem, normal, Long, {Long}, {Imm}, {Dn}, TRUE);
        IF (src.form = Imm) THEN src.typ := Sym.notyp END;
    | trap:
        Checkwsd(mnem, normal, NoSize, {}, {Imm}, {}, TRUE);
        IF (src.form = Imm) THEN src.typ := Sym.notyp END;
    | divsl, divul, mulsl, mulul:
        Checkwsd(mnem, xcode, Long, {Long}, read-{An}, {DDn}, TRUE);
    | chk2, cmp2:
        Checkwsd(mnem, xcode, Word, bwl, adr, {Dn}, TRUE);
    | fmove:
        Checkwsd(fmove, fpu, Single, sd, {FPn}, {FPn}, FALSE);
        Checkwsd(fmove, fpu, Single, bwl+sd, read, {FPn}, FALSE);
        Checkwsd(fmove, fpu, Single, bwl+sd, {FPn}, dalt+{FPn}, TRUE);
    | fint..fsincos:
        Checkwsd(mnem, fpu, Single, sd, {FPn}, {FPn}, FALSE);
        Checkwsd(mnem, fpu, Single, sd, {FPn}, {}, FALSE);
        Checkwsd(mnem, fpu, Single, sd, read, {FPn}, TRUE);
    | fmovem:
        Checkwsd(mnem, fpu, NoSize, {}, adr+{APD}, {Rlst}, FALSE);
        Checkwsd(mnem, fpu, NoSize, {}, {Rlst}, mem-{APD}, TRUE);
    | fbf..fbst:
        Checkwsd(mnem, fpu, Word, wl, {Mem}, {}, TRUE);
    | bra..ble:
        Checkwsd(mnem, normal, Word, {Byte,Word}, {Mem}, {}, TRUE);
    | dbt..dble:
        Checkwsd(mnem, normal, NoSize, {}, {Dn}, {Mem}, TRUE);
    | ds:
        Checkwsd(mnem, normal, Byte, bwl, {AbsW,AbsL}, {}, TRUE);
    ELSE
        Err.Mark(notimpl);
    END;
    IF fnd THEN
      Stat.New(mnem, s); Stat.Add(s);
      Assembler.ReplaceAss(s, mnem, SizeType(size), src, dest);
    END;
  END(*IF*);
 END StoreCommand;


PROCEDURE AssCommand;
  VAR
    obj, obj2 : Sym.Symbol;
    size, mnem, i: INTEGER;
    src, dest : Expr.Expr;
    global, export: BOOLEAN;
    lab, s: Stat.Stat;
 BEGIN
  IF Scr.sym >= even THEN
    Stat.New(Scr.sym, s); Stat.Add(s);
    s.expr := NIL; s.expr2 := NIL;
    Scan.Get(Scr.sym);
    IF Scr.sym = base THEN
      ConstExpression(src);
      IF (src.form # Expr.Sym) OR (src.sym.form # Sym.Label) THEN
        Err.Mark(labelexp);
      END;
      s.expr := src;
    END;
  ELSIF Scr.sym >= abcd THEN
    mnem := Scr.sym;
    Scan.Get(Scr.sym);
    IF Scr.sym = period THEN		(* size given *)
      Scan.Get(Scr.sym); size := GetSize();
      Scan.Get(Scr.sym);
    ELSE
      size := NoSize
    END;
    comsize := size;
    IF mnem # dc THEN
      GetItem(src);
      IF Scr.sym = comma THEN
        Scan.Get(Scr.sym); GetItem(dest);
      ELSE
        dest := NIL;
      END;
    END(*IF*);
    StoreCommand(mnem, size, src, dest);
  ELSIF Scr.sym = Scan.return THEN
    OCStatScan.ReturnStat();
  ELSIF Scr.sym = ident THEN
    Scan.Get(Scr.sym);
    global := Scr.sym = times;
    IF global THEN Scan.Get(Scr.sym) END;
    export := Scr.sym = times;
    IF export THEN Scan.Get(Scr.sym) END;
    IF Scr.sym = colon THEN
      Sym.NewSym(Sym.Label, obj); obj.a1 := 0; obj.typ := Sym.linttyp;
      Sym.Insert(obj);
      IF obj.a1 = 0 THEN	(* not used yet *)
        Com.NewLabel(lab); lab.a0 := 0;
        obj.a1 := S.VAL(LONGINT, lab.expr);
      ELSE
        Stat.New(Stat.Label, lab); lab.a0 := 0;
      END;
      Expr.New( Expr.Sym, lab.expr, Sym.linttyp); lab.expr.sym := obj;
      Com.GetLabel(obj.name);
      IF global & (Sym.level > 0) THEN
        Sym.Remove(obj);
        Sym.InsertIn(Sym.global, obj);
        INC(lab.a0);
        IF export THEN
          INC(lab.a0); obj.mark := Sym.Export
        END;
      END;
      Stat.Add(lab);
      Scan.Get(Scr.sym);
    ELSE
      Err.Mark(colon)
    END;
  ELSE
    Err.Mark(ident); Scan.Get(Scr.sym);
  END;
 END AssCommand;


PROCEDURE ScanAssembler;
 BEGIN
  IF NOT Par.ext THEN Err.Mark(ext2only) END;
(*  Scan.Options( S.ADR( "-p ") );*)
  Scan.inAss := TRUE;
  Scan.Get(Scr.sym);
  WHILE (Scr.sym # end) AND (Scr.sym # eof) DO
    IF Scr.sym # eol THEN AssCommand
    ELSE Scan.Get(Scr.sym)
    END;
  END;
  Scan.inAss := FALSE;
(*  Scan.Options( S.ADR( "=p ") );*)
  Scr.CheckSym(end);
 END ScanAssembler;


BEGIN
  OCStatScan.AssemblerCode:= ScanAssembler;
END OCAss.