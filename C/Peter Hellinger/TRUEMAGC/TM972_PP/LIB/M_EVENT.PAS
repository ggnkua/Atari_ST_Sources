UNIT M_Event;

INTERFACE

USES M_Types, Basics;

CONST MUMOVED = Bit15;
      MURECT  = Bit14;

FUNCTION InstMUKEYBD  (handler: HandleEvent): INTEGER;
FUNCTION InstMUBUTTON (handler: HandleEvent): INTEGER;
FUNCTION InstMUMESAG  (handler: HandleEvent): INTEGER;
FUNCTION InstMURECT   (handler: HandleEvent; rect: tRect): INTEGER;
FUNCTION InstMUMOVED  (handler: HandleEvent): INTEGER;
FUNCTION InstMUTIMER  (handler: HandleEvent; time: LONGINT): INTEGER;
PROCEDURE RemoveMUKEYBD  (id: INTEGER);
PROCEDURE RemoveMUBUTTON (id: INTEGER);
PROCEDURE RemoveMUMESAG  (id: INTEGER);
PROCEDURE RemoveMURECT   (id: INTEGER);
PROCEDURE RemoveMUMOVED  (id: INTEGER);
PROCEDURE RemoveMUTIMER  (id: INTEGER);
PROCEDURE ChangeMURECT (handlerID: INTEGER; rect: tRect);
PROCEDURE LazyMUMOVED (val: INTEGER);
PROCEDURE DisableEvent (event: Wordbits);
PROCEDURE EnableEvent (event: Wordbits);
FUNCTION  SetPriority (which: WordBits; id: INTEGER): INTEGER;
PROCEDURE CentralDispatcher;

IMPLEMENTATION

USES M_Sys, AES;

VAR p: ^HandleEvent;
    

FUNCTION SetPriority (which: WordBits; id: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (which);
 App^.MagicPB^.IntIn[1]:= id;
 CallMagic (1314);
 SetPriority:= App^.MagicPB^.IntOut[0];
END (*SetPriority*);

FUNCTION InstMUKEYBD (handler: HandleEvent): INTEGER;
BEGIN
 p:= ADDR (App^.MagicPB^.AddrIn[0]);  p^:= handler;
 CallMagic (1300);
 InstMUKEYBD:= App^.MagicPB^.IntOut[0];
END (*InstMUKEYBD*);

FUNCTION InstMUBUTTON (handler: HandleEvent): INTEGER;
BEGIN
 p:= ADDR (App^.MagicPB^.AddrIn[0]);  p^:= handler;
 CallMagic (1301);
 InstMUBUTTON:= App^.MagicPB^.IntOut[0];
END (*InstMUBUTTON*);

FUNCTION InstMUMESAG (handler: HandleEvent): INTEGER;
BEGIN
 p:= ADDR (App^.MagicPB^.AddrIn[0]);  p^:= handler;
 CallMagic (1302);
 InstMUMESAG:= App^.MagicPB^.IntOut[0];
END (*InstMUMESAG*);

FUNCTION InstMURECT (handler: HandleEvent; rect: tRect): INTEGER;
BEGIN
 p:= ADDR (App^.MagicPB^.AddrIn[0]);  p^:= handler;
 App^.MagicPB^.AddrIn[1]:= ADDR (rect);
 CallMagic (1303);
 InstMURECT:= App^.MagicPB^.IntOut[0];
END (*InstMURECT*);

PROCEDURE ChangeMURECT (handlerID: INTEGER; rect: tRect);
BEGIN
 App^.MagicPB^.IntIn[0]:= handlerID;
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 CallMagic (1318);
END (*ChangeMURECT*);

PROCEDURE LazyMUMOVED (val: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= val;
 CallMagic (1319);
END (*LazyMUMOVED*);

FUNCTION InstMUMOVED (handler: HandleEvent): INTEGER;
BEGIN
 p:= ADDR (App^.MagicPB^.AddrIn[0]);  p^:= handler;
 CallMagic (1304);
 InstMUMOVED:= App^.MagicPB^.IntOut[0];
END (*InstMUMOVED*);

FUNCTION InstMUTIMER (handler: HandleEvent; time: LONGINT): INTEGER;
BEGIN
 p:= ADDR (App^.MagicPB^.AddrIn[0]);  p^:= handler;
 App^.MagicPB^.LongIn[0]:= time;
 CallMagic (1305);
 InstMUTIMER:= App^.MagicPB^.IntOut[0];
END (*InstMUTIMER*);

PROCEDURE EnableEvent (event: Wordbits);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (event);  CallMagic (1313);
END (*EnableEvent*);

PROCEDURE DisableEvent (event: Wordbits);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (event);  CallMagic (1312);
END (*DisableEvent*);

PROCEDURE RemoveMUKEYBD (id: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= id;  CallMagic (1306);
END (*RemoveMUKEYBD*);

PROCEDURE RemoveMUBUTTON (id: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= id;  CallMagic (1307);
END (*RemoveMUBUTTON*);

PROCEDURE RemoveMUMESAG (id: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= id;  CallMagic (1308);
END (*RemoveMUMESAG*);

PROCEDURE RemoveMUMOVED (id: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= id;  CallMagic (1310);
END (*RemoveMUMOVED*);

PROCEDURE RemoveMURECT (id: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= id;  CallMagic (1309);
END (*RemoveMURECT*);

PROCEDURE RemoveMUTIMER (id: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= id;  CallMagic (1311);
END (*RemoveMUTIMER*);

(*----------------------------------------------------------------------*
 * Mr. Dispatcher pers”nlich...                                         *
 *----------------------------------------------------------------------*)

PROCEDURE CentralDispatcher;
BEGIN
 CallMagic (1316);
 AESCALL (25, 16, 7, 1, 0);
 CallMagic (1317);
END (*CentralDispatcher*);

END (*mpEvents*).
