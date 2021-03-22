MODULE TextDemo;


(*      Megamax Modula-2 Demo zur VDI-Textausgabe
 *      Bei installiertem GDOS werden auch die zuladbaren Fonts verwendet.
 *
 *      Autor: Manuel Chakravarty, erstellt 2. Dezember 1987
 *      Erweiterungen (GDOS-Fonts) von Th. Tempelmann am 25.2.91
 *
 *      Dieses Programm lÑuft, Dank den Nachfragefunktionen des GEM,
 *      in allen Auflîsungen.
 *)

FROM SYSTEM IMPORT ASSEMBLER;

FROM GrafBase IMPORT black, white, Rectangle, Point, WritingMode,
                     Pnt, Rect, RelZoomRect;

FROM GEMGlobals IMPORT TEffectSet, TextEffect, GemChar, FillType,
                       THorJust, TVertJust;

FROM GEMEnv IMPORT RC, DeviceHandle, GemHandle, PtrDevParm,
                   DeviceParameter, GemError, GDOSAvailable,
                   InitGem, ExitGem, CurrGemHandle;

FROM VDIControls IMPORT LoadFonts, UnloadFonts, SetClipping, DisableClipping;

FROM VDIOutputs IMPORT GrafText, FillRectangle;

FROM VDIAttributes IMPORT SetTextColor, SetTextEffects, SetFillType,
                          SetFillColor, SetAbsTHeight, SetPtsTHeight,
                          SetTextFace;

FROM VDIInquires IMPORT GetTextStyle, GetFaceName, TextExtent, GetFaceInfo;

FROM AESGraphics IMPORT GrafMouse, arrow, mouseOn, mouseOff;

FROM AESEvents IMPORT KeyboardEvent;

FROM AESWindows IMPORT DeskHandle, WSizeMode, WindowElement, WElementSet,
                       WindowSize, CreateWindow, OpenWindow, CloseWindow,
                       DeleteWindow, UpdateWindow;

IMPORT GEMBase;

FROM Strings IMPORT Append, Copy;
FROM StrConv IMPORT CardToStr;

CONST   maxSizes = 64;

VAR     dev     : DeviceHandle;         (* VDI-GerÑtekennung *)
        hdl     : GemHandle;            (* GEM-Kennung *)
        devpar  : PtrDevParm;

        success         : BOOLEAN;
        gemch           : GemChar;
        voidC,top,fonts : CARDINAL;
        voidI           : INTEGER;
        window, fontNr  : CARDINAL;
        size, c         : CARDINAL;
        minCH, maxCH, ch: CHAR;
        windSize, rect  : Rectangle;
        hor             : THorJust;
        vert            : TVertJust;
        mode            : WritingMode;
        height, sizes   : CARDINAL;
        width, line     : CARDINAL;
        charsPerLine    : CARDINAL;
        ypos            : INTEGER;
        fontName        : ARRAY [0..32] OF CHAR;
        fontHandle      : INTEGER;
        aespb           : GEMBase.AESPB;
        vdipb           : GEMBase.VDIPB;
        fontSize        : ARRAY [1..maxSizes] OF INTEGER;
        allchars, str   : ARRAY [0..256] OF CHAR;
        ok              : BOOLEAN;
        

PROCEDURE getFontSizes (VAR n: CARDINAL);
  (*
   * Ermittelt die einstellbaren Font-Grîûen und liefert die Anzahl.
   * In "fontSize" sind die mîglichen Grîûen enthalten, die grîûte steht
   * im ersten Feld, die kleinste im letzten.
   *)
  VAR prev, size: INTEGER; prevH, cellH: CARDINAL;
  BEGIN
    size:= 24;
    prevH:= 0;
    n:= 0;
    LOOP
      prev:= size;
      SetPtsTHeight (dev, size-1, voidC,voidC,voidC,cellH); (* Grîûe setzen *)
      IF GemError () THEN END;          (* GemError-Flag ggf. rÅcksetzen *)
      size:= vdipb.iooff^[0];           (* nÑchstpassende Grîûe ermitteln *)
      IF size = prev THEN EXIT END;     (* alle Grîûen ermittelt *)
      IF cellH # prevH THEN INC (n) END;
      fontSize[n]:= size;
      IF n = maxSizes THEN EXIT END;
      prevH:= cellH
    END;
  END getFontSizes;

PROCEDURE setFontSize (size: CARDINAL; VAR cellW, cellH: CARDINAL);
  (*
   * Setzt eine Font-Grîûe.
   *)
  BEGIN
    SetPtsTHeight (dev, size, voidC, voidC, cellW, cellH); (* Grîûe setzen *)
    IF GemError () THEN END;              (* GemError-Flag ggf. rÅcksetzen *)
  END setFontSize;

PROCEDURE getFontRange (VAR min, max: CHAR);
  VAR c: CARDINAL; i: INTEGER; mi, ma: CARDINAL;
  BEGIN
    GetFaceInfo (dev, mi, ma, c, c, c, c, c, i, i, i, i);
    min:= CHR (mi); max:= CHR (ma);
  END getFontRange;

PROCEDURE termination;
  (*
   * Fonts freigeben und GEM abmelden
   *)
  BEGIN
  END termination;

BEGIN

        (* Anmeldung beim GEM, liefert GerÑtekennung 'dev' *)

  InitGem (RC, dev, success);
  IF success THEN             (* Falls Anmeldung erfolgreich, ... *)
  
    hdl:=CurrGemHandle ();      (* GEM-Kennung fÅr Abmeldung ermitteln *)
    
    GrafMouse (arrow, NIL);     (* Mauszeiger zum Pfeil machen *)

    GEMBase.GetPBs (hdl, vdipb, aespb); (* fÅr "GetFaceName" *)
    
        (* Weitere eventuelle Fonts laden, wenn GDOS installiert ist *)

    IF GDOSAvailable () THEN
      LoadFonts (dev, 0, fonts)
    ELSE
      fonts:= 0;
    END;
    devpar:= DeviceParameter (dev);
    INC (fonts, devpar^.fonts); (* Anzahl der Fonts: Systemfonts mitzÑhlen *)
  
        (*  Melde ein Fenster beim AES an.
         *  Die Fensterkennung wird vom AES in 'window' geliefert.
         *  Und îffne das Fenster anschlieûend (Fenster wird sichtbar).
         *)
    CreateWindow (WElementSet {}, WindowSize (DeskHandle, workSize), window);
    OpenWindow (window, RelZoomRect (WindowSize (DeskHandle, workSize),
                                     900, 900) );

        (* Nun im Fenster den Text mit jedem vorhandenen Font anzeigen *)

    FOR fontNr:= 1 TO fonts DO

        (* Vorbereitungen zum Beschreiben des Windows *)

      UpdateWindow (TRUE);        (* Melde Start der Ausgabe in das Fenster *)
      GrafMouse (mouseOff, NIL);  (* Mauszeiger unsichtbar machen *)
      
      windSize:=WindowSize (window, workSize); (* Arbeitsbereich ermitteln *)
      SetClipping (dev, windSize);             (* Ausgabebegrenzung *)

        (* Font wÑhlen *)

      GetFaceName (dev, fontNr, fontName);     (* Namen des Fonts ermitteln *)
      fontHandle:= vdipb.iooff^[0];            (* ID des Fonts ermitteln *)
      SetTextFace (dev, fontHandle);           (* Font fÅr Ausgabe wÑhlen *)
      getFontSizes (sizes);                    (* Grîûen des Fonts ermitteln *)
      
      IF sizes > 0 THEN
      
          (* Fontgrîûe einstellen: zuerst einmal die kleinste Grîûe *)
  
        setFontSize (fontSize[sizes], width, height);
        ypos:= 2*height;                         (* Startzeile fÅr Textausgabe *)
  
          (* Das Fenster wird weiû gefÅllt *)
  
        SetFillColor (dev, white);
        SetFillType (dev, solidFill);
        FillRectangle (dev, windSize);
  
          (* Text im Fenster normal und ausgeben *)
  
        SetTextColor (dev, black);            (* Textfarbe  : schwarz *)
        SetTextEffects (dev, TEffectSet{});   (* Texteffekte: keine *)
        GrafText (dev, Pnt(windSize.x,windSize.y + ypos), fontName);
      
          (* Text fett und unterstrichen ausgeben *)
      
        SetTextEffects (dev, TEffectSet {thickText, underlineText});
        INC (ypos, height+2);
        GrafText (dev, Pnt(windSize.x,windSize.y + ypos), fontName);
      
          (* Text umrahmt ausgeben.  *)
        
        SetTextEffects (dev, TEffectSet {outlineText});
        INC (ypos, height+2);
        GrafText (dev, Pnt(windSize.x,windSize.y + ypos), fontName);
        
          (* VerfÅgbare Font-Grîûen anzeigen *)
        
        SetTextEffects (dev, TEffectSet {});
        str:= "VerfÅgbare Font-Grîûen:";
        FOR size:= sizes TO 1 BY -1 DO
          Append (" ", str, ok);
          Append (CardToStr (fontSize[size], 0), str, ok);
        END;
        INC (ypos, height+6);
        GrafText (dev, Pnt(windSize.x,windSize.y + ypos), str);
        
          (* Und nun den kompletten Font in allen Grîûen zeigen *)
      
        (* zuerst einen String mit allen vorhandenen Zeichen erzeugen *)
        getFontRange (minCH, maxCH); (* ermittelt erstes und letztes Zeichen *)
        IF minCH = 0C THEN minCH:= 1C END; (* 0C darf nicht in String vorkommen *)
        allchars:= '';
        c:= 0;
        FOR ch:= minCH TO maxCH DO
          allchars[c]:= ch;
          INC (c);
        END;
        allchars[c]:= ''; (* String-Terminierung *)
        SetTextEffects (dev, TEffectSet {});
        FOR size:= sizes TO 1 BY -1 DO
          INC (ypos, 4);
          setFontSize (fontSize[size], width, height);
          (* Anzahl Zeichen, die in eine Zeile passen, berechnen: *)
          charsPerLine:= ORD (windSize.w) DIV width;
          line:= 0;
          LOOP (* alle Zeichen ggf. in mehreren Zeilen darstellen *)
            Copy (allchars, line*charsPerLine, charsPerLine, str, ok);
            IF LENGTH (str) = 0 THEN EXIT END;
            INC (ypos, height+2);
            GrafText (dev, Pnt(windSize.x,windSize.y + ypos), str);
            INC (line);
          END;
        END;
      
      END;
      
      DisableClipping (dev);    (* Ausgabebegrenzung ausschalten *)
      
      UpdateWindow (FALSE);     (* Ausgabe in das Fenster beendet *)
      GrafMouse (mouseOn, NIL); (* Mauszeiger wieder sichtbar machen *)
      
      KeyboardEvent (gemch);       (* Warte auf einen Tastendruck *)
    
    END;

    CloseWindow (window);     (* Fenster schlieûen (Unsichtbar machen) *)
    DeleteWindow (window);    (* und anschlieûend lîschen *)
    
    IF GDOSAvailable () THEN
      UnloadFonts (dev, 0)
    END;
    
    ExitGem (hdl);          (* Beim GEM abmelden; hier wird 'hdl' gebraucht *)
    
  END;
END TextDemo.
