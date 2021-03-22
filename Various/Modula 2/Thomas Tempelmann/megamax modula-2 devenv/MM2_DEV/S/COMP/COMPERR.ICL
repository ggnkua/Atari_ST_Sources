(*
         Fehlernummern des Compilers
         
         énderungs-Geschichte:

         20.06.90  neue Ordnung fÅr Compiler 4
*)
CONST
        rModXp = 100;
        rIdXp  = 101;
        rImpXp = 102;
        rMdDXp = 103;
        rBdQal = 104;
        rIdMis = 105;
        rBdCom = 106;
        rBdOpt = 107;
        rEoInp = 108;
        
        rDecl  = 200;
        rId2   = 201;
        rId2x  = 202;
        rRedef = 203;
        rTypDc = 204;
        rIdUn  = 205;
        rBdSym = 206;
        rSemXp = 207;
        rColXp = 208;
        rEqlXp = 209;
        rPdsXp = 210;
        rBrcXp = 211;
        rBrkXp = 212;
        rOFXp  = 213;
        rEndXp = 214;
        rScIdx = 215;
        rScBas = 216;
        rBdOpq = 217;
        rLowHi = 218;
        rBouRg = 219; (* bounds out of range *)
        rCarXp = 220;
        rBdSuf = 221;
        rUnFw  = 222;
        rStCXp = 223; (* String-const expected *)
        rLBrcX = 224; (* '{' expected *)
        rFwPtr = 225;
        rFwPrc = 226;
        rRealF = 227; (* different real formats specified *)
        rRlLat = 228; (* $F too late: REAL already used *)
        rNoReg = 229; (* no register variable with this type *)
        rTyDXp = 230; (* type exp. *)
        rFwTyp = 231; (* frwd type not decl. yet *)
        rFwTyX = 232; (* frwd type not decl. yet (with name) *)
        rAbsAd = 233;
        
        rConXp = 300;
        rConTp = 301;
        rNrOv  = 302;
        rNrFmt = 303;
        rManOv = 304;
        rExnOv = 305;
        
        rStatm = 400;
        rDoXp  = 401;
        rUntXp = 402;
        rTheXp = 403;
        rToXp  = 404;
        rAsgXp = 405;
        rPerXp = 406;
        rBolXp = 407;
        rNoLop = 408;
        rNoRet = 409;
        rReDXp = 410;
        rCase2 = 411;
        rScCas = 412;
        rCaStr = 413;
        rVarXp = 414;
        rNoFun = 415; (* procedure expected, function found *)
        rNoCas = 416; (* empty CASE *)
        
        rScLop = 420;
        rIntSt = 421; (* FOR/BY: whole number const exp. *)
        rForVr = 422; (* Schleifenvariable muû einfache Variable sein. *)
        rForAc = 423; (* Auf Schleifenvariable wurde in lokaler Prozedur zug.*)
        rForTo = 424; (* Obere Schleifengrenze muû identisch mit Variable sein *)
        
        rByNum = 430; (* array constr: whole number const exp. *)
        rByCnt = 431; (* array constr: BY value out of range *)
        
        rParTy = 500;
        
        rFactr = 502;
        rBdMin = 503;
        rLPaXp = 504;
        rParXp = 505;
        rComXp = 506;
        
        rNumXp = 510; (* number (card/int/real) expected *)
        rChrXp = 511; (* CHAR-Typ erwartet *)
        rWhNXp = 512; (* whole number (card/int) expected *)
        rIoRXp = 513; (* signed number (int/real) expected *)
        rReaXp = 514; (* real type expected *)
        rOoRXp = 515; (* ordinal or real expected *)
        rSclXp = 516;
        rArrXp = 517; (* Dieser Bezeichner ist nicht vom ARRAY-Typ *)
        rRecXp = 518; (* Dieser Bezeichner ist nicht vom RECORD-Typ *)
        rPtrXp = 519; (* Dieser Bezeichner ist nicht vom POINTER-Typ *)
        rBinXp = 520; (* bitnum-set-type expected *)
        rNoPrc = 521; (* this is not a proc *)
        rVoCXp = 522; (* var or const expected *)
        rStrXp = 523; (* string type exp. *)
        rVarSz = 524; (* Var auf 4 Byte beschrÑnkt *)
        rScAdX = 525; (* scalar or address exp *)
        rStrLn = 526;
        rBdIdx = 527;
        rNotFn = 528; (* function expected, procedure found *)
        rValCs = 529; (* value constructor: only SET, ARRAY, RECORD-types *)
        rBdPro = 530;
        rReOfs = 531; (* Feldoffset zu niedrig *)
        rZopt  = 532;
        rBdPtr = 533;
        rParOp = 534;

        rBdTyp = 540;
        rOpTyp = 541;
        rOpqOp = 542;
        rNegTp = 543; (* negation only with Integer types *)
        
        rParNr = 550;
        rVPaTy = 551;
        rBdHig = 552;
        rSizVr = 553; (* SIZE may not be applied to open arrays *)
        rOp2Op = 554; (* open array only to open array *)
        rArDXp = 555; (* Argument hat zu wenig Array-Dimensionen *)
        rOddAr = 556; (* Array-Grîûe muû ganzes Vielfaches von Joker-Grîûe sein*)
        rLgAOv = 557; (* LONGARRAY kann nicht an Short-Index Åbergeben werden*)
        rBdPar = 558;
        rBdRtn = 559;
        rBdPrc = 560;
        rNoCnv = 561; (* conversion not possible *)
        rConv  = 562;
        rCast  = 563; (* CAST nicht mîglich *)
        
        rRefRs = 570; (* read-only-var not allowed here (z.B. f. ADR) *)
        rRdOnl = 571; (* no asn to read only-variable (ehemals 'rRefPa') *)
        rRegVa = 572; (* no register variable allowed here *)
        rLocVa = 573; (* no access of reg-var in lok. proc *)
        rNoIni = 574; (* var is not init. yet *)
        
        rConRg = 580; (* constant range error (const too large for assign) *)
        rDvNul = 581; (* division by zero in constant expr *)
        rSCoOv = 582; (* String constant overflow *)
        rReaRg = 583; (* real range error *)
        rCExpr = 584; (* error (runtime error) in const expr *)
        rConOp = 585; (* Konstante liegt auûerhalb des Operandenbereichs *)
        rAriOv = 586; (* arithm. overflow *)
        rIdxRg = 587; (* Index liegt auûerhalb des Feldbereichs *)
        rSubrg = 588; (* Index/Subrange-Bereiche Åberschneiden sich nicht *)
        rNoTag = 589; (* Zu diesem Wert existiert keine Variante *)
        
        rExpUn = 700;
        rBdExp = 701;
        rReExp = 702;
        rPrIpl = 703;
        rBdIpl = 704;
        rPerva = 705;
        rImpor = 706;
        rNoDef = 707;
        rMyDef = 708;
        rRuDef = 709;
        rNoExp = 710;
        rNoRun = 711;
        rBdFrm = 712;
        rBdLay = 713;
        rDblEx = 714;
        rId2Im = 715;
        
        rStrOv = 800;
        rArrLg = 801; (* Array zu groû *)
        rSetOv = 802;
        rExpOv = 803;
        rImpOv = 804;
        rDefOv = 805;
        rIntOv = 806;
        rIdOv  = 807;
        rIncOv = 808;
        rStruc = 809;
        rBranc = 810;
        rSpace = 811; (* code buffer or ID tree overflow *)
        rOpAOv = 812;
        rExOvr = 813; (* expr too complicated *)
        rConLg = 814; (* const too large (max 32K byte) *)
        rSCoLg = 815; (* string const too large (max 256 byte) *)
        rRestr = 816; (* LONGINT not allowed here *)
        rLocTb = 817;
        rBlkOv = 818; (* Blockschachtelungstiefe zu groû *)
        rNoRgs = 819; (* CALLSYS/CALLEXT: no spilling possible *)
        rLblOv = 820; (* Out of labels - bool expr too complex *)
        rParOv = 821; (* parms max. 32 KB *)
        rMPass = 822; (* multi-pass dep. *)
        rDaSpc = 823; (* data buffer overflow *)
        
        rNImpY = 850; (* not implemented yet *)
        rIntEr = 851; (* internal verification error *)
        rFatlR = 852; (* fatal internal error *)
        rTmpRs = 853; (* temporary restriction *)
        rIntSP = 854; (* internal error: stacks inconsistent *)
        rIntRg = 855; (* internal error: tempRegs inconsistent *)
        rEnuEx = 856;
        rEnuIm = 857;
        rTree  = 858; (* error in ID-tree *)
        rTree2 = 859; (* error in ID-tree *)
        rFetch = 860; (* used in LocalSeach/SearchLocalItem *)
