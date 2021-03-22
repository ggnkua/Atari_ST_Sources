DEFINITION MODULE GEMGlobals;


(*      Allgemeine Definitionen der Megamax Modula-2 GEM Library
 *
 *      geschrieben von Manuel Chakravarty
 *
 *      Version 0.11    V#0140      Erstellt MÑrz-Oktober 1987
 *)


FROM SYSTEM     IMPORT ADDRESS, WORD, BYTE, LONGWORD;

FROM GrafBase   IMPORT Point, Rectangle, WordBitSet, PtrBitPattern;


CONST   (*  Diverses Konstanten
         *)

        NoObject        = 65535;    (*  Wert fÅr nicht vorhandene Objekte  *)

        StandardFont    = 3;        (*  Normaler Zeichensatz            *)
        SmallFont       = 5;        (*  Verkleinerter Zeichensatz (6x6) *)

        MaxDepth        = 8;        (*  Maximale Such- oder Zeichentiefe fÅr
                                     *  ObjektbÑume ('DrawObject', 'FindObject')
                                     *)
        Root            = 0;        (*  Wurzelobjekt eines Objektbaumes *)


TYPE    (*  Allgemeine Typen
         *)


        MaxStr          = ARRAY [0..255] OF CHAR;
        PtrMaxStr       = POINTER TO MaxStr;

        GemChar         = RECORD
                            scan : BYTE;        (*  IBM-Scancode der Taste  *)
                            ascii: CHAR;        (*  Falls vorhanden, zuge-  *)
                          END;                  (*  hîriger ASCII-Code      *)


                (*  Definitionen zur Objektbehandlung  *)
                (*  =================================  *)

        ObjType         = (boxObj, textObj, boxTextObj, imageObj, progDefObj,
                           iBoxObj, buttonObj, boxCharObj, stringObj, fTextObj,
                           fBoxTextObj, iconObj, titleObj);

        ObjFlag         = (selectFlg, defaultFlg, selectExitFlg, editFlg,
                           radioButFlg, lastObjFlg, touchExitFlg, hideTreeFlg,
                           indirectFlg, flag10Flg, flag11Flg, flag12Flg,
                           flag13Flg, flag14Flg, flag15Flg, flag16Flg);
        OFlagSet        = SET OF ObjFlag;

        ObjState        = (selectObj, crossObj, checkObj, disableObj,
                           outlineObj, shadowObj, state7Obj, state8Obj,
                           state9Obj, state10Obj, state11Obj, state12Obj,
                           state13Obj, state14Obj, state15Obj, state16Obj);
        OStateSet       = SET OF ObjState;

        TEdInfo         = RECORD
                            textPtr              : PtrMaxStr;
                            tmpltPtr             : PtrMaxStr;
                            validPtr             : PtrMaxStr;
                            font                 : CARDINAL;
                            res1                 : WORD;
                            just                 : CARDINAL;
                            color                : CARDINAL;
                            res2                 : WORD;
                            thickness            : INTEGER;
                            textLen              : CARDINAL;
                            tmpltLen             : CARDINAL;
                          END;
        PtrTEdInfo      = POINTER TO TEdInfo;

        IconBlock       = RECORD
                            mask                 : PtrBitPattern;
                            data                 : PtrBitPattern;
                            text                 : PtrMaxStr;
                            color                : BYTE;
                            oneChar              : CHAR;
                            charPos              : Point;
                            iconFrame            : Rectangle;
                            textFrame            : Rectangle;
                          END;
        PtrIconBlock    = POINTER TO IconBlock;

        BitBlock        = RECORD
                            data                 : PtrBitPattern;
                            bytes                : INTEGER;
                            h                    : INTEGER;
                            x                    : INTEGER;
                            y                    : INTEGER;
                            color                : CARDINAL;
                          END;
        PtrBitBlock     = POINTER TO BitBlock;

        ApplBlock       = RECORD
                            code                 : ADDRESS;
                            parm                 : LONGWORD;
                          END;
        PtrApplBlock    = POINTER TO ApplBlock;

        ObjSpec         = RECORD
                            CASE :BOOLEAN OF
                              FALSE :letter      : CHAR;
                                     thickness   : BYTE;
                                     color       : CARDINAL       |
                              TRUE  :more        : ADDRESS;
                            END;
                          END;
        PtrObjSpec      = POINTER TO ObjSpec;

        Object          = RECORD
                            next                 : CARDINAL;
                            head                 : CARDINAL;
                            tail                 : CARDINAL;
                            type                 : CARDINAL;
                            flags                : WordBitSet;
                            state                : WordBitSet;
                            spec                 : ObjSpec;
                            space                : Rectangle;
                          END;
        PtrObject       = POINTER TO Object;
        PtrObjTree      = POINTER TO ARRAY[0..MaxCard] OF Object;

        ParmBlock       = RECORD
                            tree                 : PtrObjTree;
                            index                : CARDINAL;
                            prevState            : WordBitSet;
                            curState             : WordBitSet;
                            space                : Rectangle;
                            clip                 : Rectangle;
                            parameter            : LONGWORD;
                          END;


                (*  Typen fÅr die Eingabeoperationen  *)
                (*  ================================  *)

        MouseButton     = (msBut1, msBut2, msBut3, msBut4, msBut5, msBut6,
                           msBut7, msBut8);
        MButtonSet      = SET OF MouseButton;

        SpecialKey      = (rightShiftKey, leftShiftKey, controlKey,
                           alternateKey);
        SpecialKeySet   = SET OF SpecialKey;


                (*  Typen fÅr die Ausgabeoperationen  *)
                (*  ================================  *)

        LineType        = (solidLn, longDashLn, dottedLn, dashDotLn, dashedLn,
                           dashDotDotLn, userLn);

        LineEnding      = (edgedLn, arrowedLn, roundedLn);

        MarkerType      = (pointMark, plusMark, starMark, squareMark, crossMark,
                           diamondMark);

        TextEffect      = (thickText, lightText, slantText, underlineText,
                           outlineText, shadowText);
        TEffectSet      = SET OF TextEffect;

        TVertJust       = (baseJust, halfJust, ascentJust, bottomJust,
                           descentJust, topJust);

        THorJust        = (leftJust, centerJust, rightJust);

        FillType        = (hollowFill, solidFill, dottPattern, hatchPattern,
                           userPattern);


END GEMGlobals.
