IMPLEMENTATION MODULE GetObject;

(*
Manipulating AES Object Structure.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM RcMgr  IMPORT GRect,GPnt;
FROM PORTAB IMPORT ANYPOINTER,SIGNEDWORD,UNSIGNEDWORD,ANYWORD;
CAST_IMPORT

IMPORT AES;

PROCEDURE Next(Tree : AES.TreePtr;
               Index: AES.ObjectIndex): AES.ObjectPtr;
BEGIN
#if not UNIX
#if long
  RETURN CAST(AES.ObjectPtr,LONG(Tree^[Index].ObNext));
#else
  RETURN Tree^[Index].ObNext;
#endif
#else

#endif
END Next;

PROCEDURE Head(Tree : AES.TreePtr;
               Index: AES.ObjectIndex): AES.ObjectPtr;
BEGIN
#if not UNIX
#if long
  RETURN CAST(AES.ObjectPtr,LONG(Tree^[Index].ObHead));
#else
  RETURN Tree^[Index].ObHead;
#endif
#else

#endif
END Head;

PROCEDURE Tail(Tree : AES.TreePtr;
               Index: AES.ObjectIndex): AES.ObjectPtr;
BEGIN
#if not UNIX
#if long
  RETURN CAST(AES.ObjectPtr,LONG(Tree^[Index].ObTail));
#else
  RETURN Tree^[Index].ObTail;
#endif
#else

#endif
END Tail;

PROCEDURE Extnd(Tree : AES.TreePtr;
                Index: AES.ObjectIndex): UNSIGNEDWORD;
BEGIN
#if not UNIX
#if packing
  RETURN ORD(CAST(CHAR,Tree^[Index].ObExtnd));
#else
  RETURN Tree^[Index].ObType DIV 256;
#endif
#else

#endif
END Extnd;

PROCEDURE Type(Tree : AES.TreePtr;
               Index: AES.ObjectIndex): AES.ObjectTypes;
BEGIN
#if not UNIX
#if (defined MM2)
  RETURN VAL(AES.ObjectTypes,ORD(Tree^[Index].ObType));
#else
#if packing
  RETURN Tree^[Index].ObType;
#else
  RETURN VAL(AES.ObjectTypes,Tree^[Index].ObType MOD 256);
#endif
#endif
#else

#endif
END Type;
#if no_set_return
PROCEDURE Flags(Tree : AES.TreePtr;
                Index: AES.ObjectIndex): ANYWORD;
#else
PROCEDURE Flags(Tree : AES.TreePtr;
                Index: AES.ObjectIndex): AES.ObjectFlag;
#endif
BEGIN
#if not UNIX
#if no_set_return
  RETURN CAST(ANYWORD,Tree^[Index].ObFlags);
#else
  RETURN Tree^[Index].ObFlags;
#endif
#else

#endif
END Flags;
#if no_set_return
PROCEDURE State(Tree : AES.TreePtr;
                Index: AES.ObjectIndex): ANYWORD;
#else
PROCEDURE State(Tree : AES.TreePtr;
                Index: AES.ObjectIndex): AES.ObjectState;
#endif
BEGIN
#if not UNIX
#if no_set_return
  RETURN CAST(ANYWORD,Tree^[Index].ObState);
#else
  RETURN Tree^[Index].ObState;
#endif
#else

#endif
END State;

PROCEDURE Spec(Tree : AES.TreePtr;
               Index: AES.ObjectIndex): ANYPOINTER;

BEGIN
  (* do NOT handle GUserDef here *)
#if not UNIX
  IF NOT(AES.Indirect IN Tree^[Index].ObFlags) THEN
    RETURN Tree^[Index].ObSpec.Address;
  ELSE
    RETURN Tree^[Index].ObSpec.Extension^.Spec.Address;
  END;
#else

#endif
END Spec;

PROCEDURE X(Tree : AES.TreePtr;
            Index: AES.ObjectIndex): SIGNEDWORD;
BEGIN
#if not UNIX
  RETURN Tree^[Index].ObX;
#else

#endif
END X;

PROCEDURE Y(Tree : AES.TreePtr;
            Index: AES.ObjectIndex): SIGNEDWORD;
BEGIN
#if not UNIX
  RETURN Tree^[Index].ObY;
#else

#endif
END Y;

PROCEDURE Width(Tree : AES.TreePtr;
                Index: AES.ObjectIndex): UNSIGNEDWORD;
BEGIN
#if not UNIX
  RETURN Tree^[Index].ObWidth;
#else

#endif
END Width;

PROCEDURE Height(Tree : AES.TreePtr;
                 Index: AES.ObjectIndex): UNSIGNEDWORD;
BEGIN
#if not UNIX
  IF Type(Tree,Index) = AES.GIcon THEN
    WITH Tree^[Index].ObSpec.IconBlk^ DO
      RETURN IBHIcon + IBHText;
    END;
  ELSIF Type(Tree,Index) = AES.GImage THEN
    WITH Tree^[Index].ObSpec.BitBlk^ DO
      RETURN BIHL;
    END;
  ELSE
    RETURN Tree^[Index].ObHeight;
  END;
#else

#endif
END Height;

PROCEDURE Pnt(    Tree : AES.TreePtr;
                  Index: AES.ObjectIndex;
              VAR Pnt  : GPnt);
BEGIN
#if not UNIX
  WITH Tree^[Index] DO
    WITH Pnt DO
      GX:= ObX;
      GY:= ObY;
    END;
  END;
#else

#endif
END Pnt;

PROCEDURE Rect(    Tree : AES.TreePtr;
                   Index: AES.ObjectIndex;
               VAR Rect : GRect);
BEGIN
  WITH Rect DO
#if not UNIX
    WITH Tree^[Index] DO
      GX:= ObX;
      GY:= ObY;
      GW:= ObWidth;
      GH:= ObHeight;
    END;
#else

#endif
  END;
END Rect;

PROCEDURE Color(    Tree : AES.TreePtr;
                    Index: AES.ObjectIndex;
                VAR Inf  : ColorInfo);

VAR SpecInfo    : AES.ObjectSpec;
    ComplexColor: AES.ObjectField;

BEGIN
  SpecInfo.Address:= Spec(Tree,Index);
  CASE Type(Tree,Index) OF
    AES.GBox,AES.GIBox,AES.GBoxChar:
#if packing
      ComplexColor:= SpecInfo.Color;
#else
      ComplexColor:= CAST(AES.ObjectField,SHORT(SpecInfo.Color DIV 65536));
#endif
  | AES.GText,AES.GBoxText,AES.GFText,AES.GFBoxText:
      ComplexColor:= SpecInfo.TEdInfo^.TEColor;
  ELSE
    RETURN;
  END;

#undef CAST

#if (defined LPRM2) || (defined SPCM2)
  WITH Inf DO
    FrameColor:= VAL(AES.ObjectColors,
                     VAL(UNSIGNEDWORD,
                         ComplexColor - AES.ObjectField{0..(AES.FrameShift - 1)})
                         DIV AES.FrameOffset);
    TextColor:= VAL(AES.ObjectColors,
                    VAL(UNSIGNEDWORD,ComplexColor - AES.ObjectField{0..(AES.TextShift - 1),AES.FrameShift..15})
                        DIV AES.TextOffset);
    Mode:= VAL(AES.InsideModes,
               VAL(UNSIGNEDWORD,ComplexColor - AES.ObjectField{0..(AES.ModeShift - 1),AES.TextShift..15})
                   DIV AES.ModeOffset);
    Pattern:= VAL(AES.InsidePatterns,
              VAL(UNSIGNEDWORD,ComplexColor - AES.ObjectField{0..(AES.PatternShift - 1),AES.ModeShift..15})
                  DIV AES.PatternOffset);
    InsideColor:= VAL(AES.ObjectColors,
                  VAL(UNSIGNEDWORD,ComplexColor - AES.ObjectField{AES.PatternShift..15})
                     );
  END;
#elif (defined MM2) || (defined HM2) || (defined ISOM2)
  WITH Inf DO
    FrameColor:= VAL(AES.ObjectColors,
                     CAST(UNSIGNEDWORD,
                          ComplexColor - AES.ObjectField{0..(AES.FrameShift - 1)})
                          DIV AES.FrameOffset);
    TextColor:= VAL(AES.ObjectColors,
                    CAST(UNSIGNEDWORD,ComplexColor - AES.ObjectField{0..(AES.TextShift - 1),AES.FrameShift..15})
                         DIV AES.TextOffset);
    Mode:= VAL(AES.InsideModes,
               CAST(UNSIGNEDWORD,ComplexColor - AES.ObjectField{0..(AES.ModeShift - 1),AES.TextShift..15})
                    DIV AES.ModeOffset);
    Pattern:= VAL(AES.InsidePatterns,
              CAST(UNSIGNEDWORD,ComplexColor - AES.ObjectField{0..(AES.PatternShift - 1),AES.ModeShift..15})
                   DIV AES.PatternOffset);
    InsideColor:= VAL(AES.ObjectColors,
                  CAST(UNSIGNEDWORD,ComplexColor - AES.ObjectField{AES.PatternShift..15})
                      );
  END;
#else
  WITH Inf DO
    FrameColor:= VAL(AES.ObjectColors,
                     UNSIGNEDWORD(ComplexColor - AES.ObjectField{0..(AES.FrameShift - 1)})
                     DIV AES.FrameOffset);
    TextColor:= VAL(AES.ObjectColors,
                    UNSIGNEDWORD(ComplexColor - AES.ObjectField{0..(AES.TextShift - 1),AES.FrameShift..15})
                    DIV AES.TextOffset);
    Mode:= VAL(AES.InsideModes,
               UNSIGNEDWORD(ComplexColor - AES.ObjectField{0..(AES.ModeShift - 1),AES.TextShift..15})
               DIV AES.ModeOffset);
    Pattern:= VAL(AES.InsidePatterns,
                  UNSIGNEDWORD(ComplexColor - AES.ObjectField{0..(AES.PatternShift - 1),AES.ModeShift..15})
                  DIV AES.PatternOffset);
    InsideColor:= VAL(AES.ObjectColors,
                      UNSIGNEDWORD(ComplexColor - AES.ObjectField{AES.PatternShift..15})
                      );
  END;
#endif
END Color;

PROCEDURE StringPtr(Tree : AES.TreePtr;
                    Index: AES.ObjectIndex): AES.StringPtr;
BEGIN
#if not UNIX
  CASE Type(Tree,Index) OF
    AES.GButton,AES.GString,AES.GTitle:
#if no_set_return
      IF AES.Indirect IN CAST(AES.ObjectFlag,Flags(Tree,Index)) THEN
#else
      IF AES.Indirect IN Flags(Tree,Index) THEN
#endif
        RETURN Tree^[Index].ObSpec.Extension^.Spec.String;
      ELSE
        RETURN Tree^[Index].ObSpec.String;
      END;
  | AES.GText,AES.GFText,AES.GBoxText,AES.GFBoxText:
#if no_set_return
      IF AES.Indirect IN CAST(AES.ObjectFlag,Flags(Tree,Index)) THEN
#else
      IF AES.Indirect IN Flags(Tree,Index) THEN
#endif
        RETURN Tree^[Index].ObSpec.Extension^.Spec.TEdInfo^.TEPText;
      ELSE
        RETURN Tree^[Index].ObSpec.TEdInfo^.TEPText;
      END;
  ELSE
    RETURN NIL;
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
  CASE Type(Tree,Index) OF
    AES.GButton,AES.GString,AES.GTitle:
      WITH Tree^[Index].ObSpec DO
        i:= 0;
        REPEAT
          Str[i]:= String^[i];
          INC(i)
        UNTIL String^[i] = 0C;
        Str[i]:= 0C;
      END;
  | AES.GText,AES.GFText,AES.GBoxText,AES.GFBoxText:
      WITH Tree^[Index].ObSpec.TEdInfo^ DO
        i:= 0;
        REPEAT
          Str[i]:= TEPText^[i];
          INC(i)
        UNTIL TEPText^[i] = 0C;
        Str[i]:= 0C;
     END;
  ELSE
    Str:= "";
  END;
#else

#endif
END String;

END GetObject.