IMPLEMENTATION MODULE EvntMgr;

(*
AES Event Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES    IMPORT c,IntIn,IntOut,Addr,Integer,crystal;
FROM RcMgr  IMPORT GRect,GPnt;
FROM PORTAB IMPORT SIGNEDWORD,UNSIGNEDWORD,ANYTYPE;
FROM SYSTEM IMPORT ADR;
AES_SYSTEM_IMPORT

#if Seimet
CONST F20 = 014000100H;
      F21 = 015030500H;
      F22 = 016050500H;
      F23 = 017000101H;
      F24 = 018020100H;
      F25 = 019100701H;
      F26 = 01A020100H;
#endif

PROCEDURE EvntKeybd(): ScanWord;
BEGIN
  crystal(20,0,1,0);
  RETURN IntOut[0];
END EvntKeybd;

PROCEDURE EvntButton(    Clicks : UNSIGNEDWORD;
                         Mask   : MouseButton;
                         State1 : MouseButton;
                     VAR XY     : GPnt;
                     VAR State2 : MouseButton;
                     VAR Special: SpecialKey): UNSIGNEDWORD;
BEGIN
  WITH IntIn DO
    Array[0]:= Clicks;
    Array[1]:= CAST(Integer,Mask);
    Array[2]:= CAST(Integer,State1);
  END;
  crystal(21,3,5,0);
  XY.GX:= IntOut[1];
  XY.GY:= IntOut[2];
  State2:= CAST(MouseButton,IntOut[3]);
  Special:= CAST(SpecialKey,IntOut[4]);
  RETURN IntOut[0];
END EvntButton;

PROCEDURE EvntMouse(    Flag   : BOOLEAN;
                        Rect   : GRect;
                    VAR XY     : GPnt;
                    VAR Button : MouseButton;
                    VAR Special: SpecialKey);
BEGIN
  WITH IntIn DO
    Array[0]:= ORD(Flag);
    WITH Rect DO
      Array[1]:= GX;
      Array[2]:= GY;
      Array[3]:= GW;
      Array[4]:= GH;
    END;
  END;
  crystal(22,5,5,0);
  XY.GX:= IntOut[1];
  XY.GY:= IntOut[2];
  Button:= CAST(MouseButton,IntOut[3]);
  Special:= CAST(SpecialKey,IntOut[4]);
END EvntMouse;

PROCEDURE EvntMesag(VAR PBuffer: ARRAY OF ANYTYPE);
BEGIN
  Addr[0]:= ADR(PBuffer);
  crystal(23,0,1,1);
END EvntMesag;

PROCEDURE EvntTimer(LoCount: UNSIGNEDWORD;
                    HiCount: UNSIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= LoCount;
    Array[1]:= HiCount;
  END;
  crystal(24,2,1,0);
END EvntTimer;

PROCEDURE evntmulti(    Flags   : Event;
                        Clicks  : UNSIGNEDWORD;
                        Mask    : MouseButton;
                        State   : MouseButton;
                        Mo1Flag : BOOLEAN;
                        Mo1Rect : GRect;
                        Mo2Flag : BOOLEAN;
                        Mo2Rect : GRect;
                    VAR Msg     : ARRAY OF ANYTYPE;
                        LoCount : UNSIGNEDWORD;
                        HiCount : UNSIGNEDWORD;
                    VAR XY      : GPnt;
                    VAR Button  : MouseButton;
                    VAR SpecRet : SpecialKey;
                    VAR KeybdRet: Key;
                    VAR ButRet  : UNSIGNEDWORD): Event;
BEGIN
  WITH IntIn DO
    Array[0]:= CAST(Integer,Flags);
    Array[1]:= Clicks;
    Array[2]:= CAST(Integer,Mask);
    Array[3]:= CAST(Integer,State);

    Array[4]:= ORD(Mo1Flag);

    WITH Mo1Rect DO
      Array[5]:= GX;
      Array[6]:= GY;
      Array[7]:= GW;
      Array[8]:= GH;
    END;

    Array[9]:= ORD(Mo2Flag);

    WITH Mo2Rect DO
      Array[10]:= GX;
      Array[11]:= GY;
      Array[12]:= GW;
      Array[13]:= GH;
    END;

    Array[14]:= LoCount;
    Array[15]:= HiCount;
  END;
  Addr[0]:= ADR(Msg);
  crystal(25,16,7,1);
  XY.GX:= IntOut[1];
  XY.GY:= IntOut[2];
  Button:= CAST(MouseButton,IntOut[3]);
  SpecRet:= CAST(SpecialKey,IntOut[4]);
#if packing
  KeybdRet.ScanCode:= IntOut[5];
#else
  KeybdRet:= IntOut[5];
#endif
  ButRet:= IntOut[6];
  RETURN CAST(Event,IntOut[0]);
END evntmulti;

PROCEDURE evntevent(VAR PMEvent: MEvent): Event;

(* just another way of EvntMulti() which will look like X/GEM *)

BEGIN
  c.PIntIn:= ADR(PMEvent);
  c.PIntOut:= ADR(PMEvent.EEvent); (* new! *)
  Addr[0]:= PMEvent.EMePBuf;
  crystal(25,16,7,1);
  c.PIntIn:= ADR(IntIn);
  c.PIntOut:= ADR(IntOut); (* new *)

(*
  WITH PMEvent DO
    EMXY.GX:= IntOut[1];
    EMXY.GY:= IntOut[2];
    EMB:= CAST(MouseButton,IntOut[3]);
    EKS:= CAST(SpecialKey,IntOut[4]);
    EKR.ScanCode:= IntOut[5];
    EBR:= IntOut[6];
  END;

  RETURN CAST(Event,IntOut[0]);
*)

  RETURN PMEvent.EEvent; (* new *)
END evntevent;

PROCEDURE EvntDClick(Rate  : UNSIGNEDWORD;
                     GetSet: BOOLEAN): UNSIGNEDWORD;
BEGIN
  WITH IntIn DO
    Array[0]:= Rate;
    Array[1]:= ORD(GetSet);
  END;
  crystal(26,2,1,0);
  RETURN IntOut[0];
END EvntDClick;

BEGIN
  EvntMulti:= evntmulti;
  EvntEvent:= evntevent;
END EvntMgr.