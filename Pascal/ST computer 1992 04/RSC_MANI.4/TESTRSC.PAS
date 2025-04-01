
(*************************************************
*               Listing 9                        *
*                                                *
*      Kleines Testprogramm fÅr das Ergebnis     *
*      des Programmes PictureInRSC.              *
*      Nur wegen der Korrekturprozedur  wichtig  *
*                                                *
*************************************************)

PROGRAM TestRsc;

Uses Dos, AES,VDI, GEM, GrafBase;
(* Unit TEST auch 'usen', wenn diese mit
   dem RSCMaker aus Folge 1 erzeugt wurde *)

(* TYPE Rectangle = 
           RECORD x,y,w,h:INTEGER END;
           in Unit GrafBase               *)

VAR
     handle                  : INTEGER;
     ok                      : BOOLEAN;
     ecke, little            : Rectangle;
     baum                    : PtrObjTree;
     pbb                     : PtrBitBlock;
     Button, kwb,kwh         : INTEGER;
     CurDir                  : STRING;

(*************************************************
* Bei groûen Bitbildern macht der Editor Mist.   *
* Bilder bis maximal 99 * 128 Pixel bedÅrfen     *
* keiner Korrektur. DarÅber mÅssen die           *
* Rechteckwerte im Objekt korrigiert werden.     *
* Die Grafik ist immer das erste Objekt im Baum. *
*************************************************)

PROCEDURE Korrigieren;
BEGIN
  pbb := baum^[2].spec.more; (* ^ auf BitBlock  *)
  kwb := pbb^.bytes;         (* die Imagebreite *)
                             (* in Bytes        *)
  baum^[2].space.w := kwb * 8; (* in Pixel an   *)
                             (*  an Objekt      *)
  kwh := pbb^.h ;            (* die Imagehîhe   *)
  baum^[2].space.h := kwh;   (* an Objekt       *)
END (* Korrigieren *);



BEGIN   (* Hauptteil, alles wie gehabt *)
  InitGem(RC,handle,ok);
  IF ok THEN BEGIN
     IF ~AES.GemError  THEN BEGIN
     WITH little DO BEGIN
        x := 0; y := 0; w := 10; h := 10;
     END;
      HideCursor(handle);
      ClearWorkstation(handle);
      ShowCursor(handle,TRUE);
      LoadResource('F:\pascal\maxon\abild.rsc'); 
      (* weglasssen, wenn RSCMaker verwandt *)
      
      IF AES.GemError THEN BEGIN
        WriteLn('RSC-File nicht gefunden !'); HALT;
      END
      ELSE BEGIN
       baum := ResourceAddr(treeRsrc,0); 
      (* oder
         baum := TreeAddr^[0];
         wenn RSC_Maker verwandt *)
       
       Korrigieren;  (* wichtig ! *)
     
       FormCenter(baum,ecke);
       FormDial(reserveForm, little, ecke);

       DrawObject(baum,0,8,ecke);
       FormDo(baum,0,Button);
       FormDial(freeForm, little, ecke);
       FreeResource; 
       (* FreeRes.. nur, wenn RSC-Load angewandt *)
      END;
     END;
     ExitGem(handle);
  END;
END (*TestRscPict*).

(************************************************)

