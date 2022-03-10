IMPLEMENTATION MODULE SetObject;

(*
Manipulating AES Object Structure.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM RcMgr  IMPORT GRect,GPnt;
FROM PORTAB IMPORT UNSIGNEDBYTE,SIGNEDWORD,UNSIGNEDWORD,WORDSET;
CAST_IMPORT

IMPORT AES;

PROCEDURE Next(Tree : AES.TreePtr;
               Index: AES.ObjectIndex;
               Next : AES.ObjectPtr);
BEGIN
#if not UNIX
  Tree^[Index].ObNext:= Next;
#else

#endif
END Next;

PROCEDURE Head(Tree : AES.TreePtr;
               Index: AES.ObjectIndex;
               Head : AES.ObjectPtr);
BEGIN
#if not UNIX
  Tree^[Index].ObHead:= Head;
#else

#endif
END Head;

PROCEDURE Tail(Tree : AES.TreePtr;
               Index: AES.ObjectIndex;
               Tail : AES.ObjectPtr);
BEGIN
#if not UNIX
  Tree^[Index].ObTail:= Tail;
#else

#endif
END Tail;

PROCEDURE Extnd(Tree : AES.TreePtr;
                Index: AES.ObjectIndex;
                Extnd: UNSIGNEDWORD);
BEGIN
#if not UNIX
#if (defined LPRM2) || (defined SPCM2)
  Tree^[Index].ObExtnd:= CHR(Extnd);
#elif not packing
  (* call once only *)
  Tree^[Index].ObType:= CAST(UNSIGNEDWORD,CAST(WORDSET,Tree^[Index].ObType) + CAST(WORDSET,Extnd * 256));
#else
  Tree^[Index].ObExtnd:= CAST(UNSIGNEDBYTE,CHR(Extnd));
#endif
#else

#endif
END Extnd;

PROCEDURE Type(Tree : AES.TreePtr;
               Index: AES.ObjectIndex;
               Type : AES.ObjectTypes);
BEGIN
#if not UNIX
#if (defined MM2)
  Tree^[Index].ObType:= CAST(UNSIGNEDBYTE,CHR(ORD(Type)));
#elif not packing
 Tree^[Index].ObType:= CAST(UNSIGNEDWORD,CAST(WORDSET,Tree^[Index].ObType) - CAST(WORDSET,000FFH));
 Tree^[Index].ObType:= CAST(UNSIGNEDWORD,CAST(WORDSET,Tree^[Index].ObType) + CAST(WORDSET,ORD(Type)));
#else
  Tree^[Index].ObType:= Type;
#endif
#else

#endif
END Type;

PROCEDURE Flags(Tree : AES.TreePtr;
                Index: AES.ObjectIndex;
                Flags: AES.ObjectFlag);
BEGIN
#if not UNIX
  Tree^[Index].ObFlags:= Flags;
#else

#endif
END Flags;

PROCEDURE State(Tree : AES.TreePtr;
                Index: AES.ObjectIndex;
                State: AES.ObjectState);
BEGIN
#if not UNIX
  Tree^[Index].ObState:= State;
#else

#endif
END State;

PROCEDURE Spec(Tree : AES.TreePtr;
               Index: AES.ObjectIndex;
               Info : AES.ObjectSpec);

BEGIN
#if not UNIX
  IF NOT(AES.Indirect IN Tree^[Index].ObFlags) THEN
    Tree^[Index].ObSpec:= Info;
  ELSE
    Tree^[Index].ObSpec.Extension^.Spec:= Info;
  END;
#else

#endif
END Spec;

PROCEDURE X(Tree : AES.TreePtr;
            Index: AES.ObjectIndex;
            XPos : SIGNEDWORD);
BEGIN
#if not UNIX
  Tree^[Index].ObX:= XPos;
#else

#endif
END X;

PROCEDURE Y(Tree : AES.TreePtr;
            Index: AES.ObjectIndex;
            YPos : SIGNEDWORD);
BEGIN
#if not UNIX
  Tree^[Index].ObY:= YPos;
#else

#endif
END Y;

PROCEDURE Width(Tree : AES.TreePtr;
                Index: AES.ObjectIndex;
                Width: SIGNEDWORD);
BEGIN
#if not UNIX
  Tree^[Index].ObWidth:= Width;
#else

#endif
END Width;

PROCEDURE Height(Tree  : AES.TreePtr;
                 Index : AES.ObjectIndex;
                 Height: SIGNEDWORD);
BEGIN
#if not UNIX
  Tree^[Index].ObHeight:= Height;
#else

#endif
END Height;

PROCEDURE Pnt(Tree : AES.TreePtr;
              Index: AES.ObjectIndex;
              Pos  : GPnt);
BEGIN
#if not UNIX
  WITH Tree^[Index] DO
    WITH Pos DO
      ObX:= GX;
      ObY:= GY;
    END;
  END;
#else

#endif
END Pnt;

PROCEDURE Rect(    Tree : AES.TreePtr;
                   Index: AES.ObjectIndex;
               VAR Rect : GRect);

BEGIN
#if not UNIX
  WITH Tree^[Index] DO
    WITH Rect DO
      ObX:= GX;
      ObY:= GY;
      ObWidth:= GW;
      ObHeight:= GH;
    END;
  END;
#else

#endif
END Rect;

PROCEDURE StringPtr(Tree : AES.TreePtr;
                    Index: AES.ObjectIndex;
                    Ptr  : AES.StringPtr);
BEGIN
#if not UNIX
#if (defined MM2)
  CASE VAL(AES.ObjectTypes,ORD(Tree^[Index].ObType)) OF
#elif not packing
  CASE VAL(AES.ObjectTypes,Tree^[Index].ObType) OF
#else
  CASE Tree^[Index].ObType OF
#endif
    AES.GButton,AES.GString,AES.GTitle:
      IF AES.Indirect IN Tree^[Index].ObFlags THEN
        Tree^[Index].ObSpec.Extension^.Spec.String:= Ptr;
      ELSE
        Tree^[Index].ObSpec.String:= Ptr;
      END;
  | AES.GText,AES.GFText,AES.GBoxText,AES.GFBoxText:
      IF AES.Indirect IN Tree^[Index].ObFlags THEN
        Tree^[Index].ObSpec.Extension^.Spec.TEdInfo^.TEPText:= Ptr;
      ELSE
        Tree^[Index].ObSpec.TEdInfo^.TEPText:= Ptr;
      END;
  ELSE
    ;
  END;
#else

#endif
END StringPtr;

PROCEDURE String(    Tree : AES.TreePtr;
                     Index: AES.ObjectIndex;
                 VAR Str  : AES.String);

VAR i: AES.StringRange;

BEGIN
#if not UNIX
#if (defined MM2)
  CASE VAL(AES.ObjectTypes,ORD(Tree^[Index].ObType)) OF
#elif not packing
  CASE VAL(AES.ObjectTypes,Tree^[Index].ObType) OF
#else
  CASE Tree^[Index].ObType OF
#endif
    AES.GButton,AES.GString,AES.GTitle:
      WITH Tree^[Index].ObSpec DO
        i:= 0;
        REPEAT
          String^[i]:= Str[i];
          INC(i)
        UNTIL Str[i] = 0C;
        String^[i]:= 0C;
      END;
  | AES.GText,AES.GFText,AES.GBoxText,AES.GFBoxText:
      WITH Tree^[Index].ObSpec.TEdInfo^ DO
        i:= 0;
        REPEAT
          TEPText^[i]:= Str[i];
          INC(i)
        UNTIL Str[i] = 0C;
        TEPText^[i]:= 0C;
     END;
  ELSE
    ;
  END;
#else

#endif
END String;

END SetObject.