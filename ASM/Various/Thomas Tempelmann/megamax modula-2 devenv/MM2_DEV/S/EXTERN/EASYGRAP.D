DEFINITION MODULE EasyGraphics;


(*  --------------------------------------------------------------------------
 *  System-Version: MOS 1.1
 *  --------------------------------------------------------------------------
 *  Version       : 0.01
 *  --------------------------------------------------------------------------
 *  Text-Version  : V#0002
 *  --------------------------------------------------------------------------
 *  Modul-Holder  : Manuel Chakravarty
 *  --------------------------------------------------------------------------
 *  Copyright February 89 by Manuel Chakravarty
 *  Vertriebsrechte fÅr ATARI ST unter MEGAMAX Modula-2
 *                  liegen bei Application Systems Heidelberg
 *  --------------------------------------------------------------------------
 *  MCH : Manuel Chakravarty
 *  --------------------------------------------------------------------------
 *  Modul-Beschreibung:
 *
 *  Grundlegende Grafikroutinen in einem Fenster.
 *  --------------------------------------------------------------------------
 *)

PROCEDURE Clear ();

PROCEDURE Dot (x, y: INTEGER);

PROCEDURE SetPen (x, y: INTEGER);

PROCEDURE TurnTo (d: INTEGER);

PROCEDURE Turn (d: INTEGER);

PROCEDURE Move (d: INTEGER);

PROCEDURE MoveTo (x, y: INTEGER);

PROCEDURE Circle (x, y, r: INTEGER);

PROCEDURE Write (ch: CHAR);

PROCEDURE WriteString (str: ARRAY OF CHAR);

PROCEDURE IdentifyPos (VAR x, y: INTEGER);

END EasyGraphics.
(* $FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BEÅ$000005C7T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000005D8$FFED2A52$00000398$FFED2A52$000005C7$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BE$FFED51BEîÄÅ*)
