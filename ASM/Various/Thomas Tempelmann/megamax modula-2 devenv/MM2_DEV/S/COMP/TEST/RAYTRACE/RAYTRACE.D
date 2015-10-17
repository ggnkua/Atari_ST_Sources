DEFINITION MODULE RayTrace;


CONST Unendlich=1.0E+20;
      MaxObj   =5;
      
TYPE  LFeld=ARRAY [0..MaxObj] OF LONGREAL;

      
(* ------------------------------------------------ *)

PROCEDURE Ebene1schn (VAR Pktz,Vecz:LONGREAL ; VAR Index:INTEGER ;
                      VAR Lambda:LFeld );
   

PROCEDURE Ebene1weiter (VAR Pktx,Pkty,Vecx,Vecy:LONGREAL ;
                        VAR Lambda:LFeld ;
                        VAR Index,Farbe,Untersuchungsende:INTEGER );


PROCEDURE Kugel1schn (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                          Kug1pktx,Kug1pkty,Kug1pktz,Kug1rquad:LONGREAL;
                      VAR Lambda:LFeld;
                      VAR Index :INTEGER );
                      

PROCEDURE Kugel1weiter (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                            Kug1pktx,Kug1pkty,Kug1pktz,Kug1rquad:LONGREAL;
                        VAR Lambda:LFeld;
                        VAR Index,Farbversch:INTEGER );

PROCEDURE Ebene2schn ( VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                           Zyl1pktx,Zyl1pkty,Zyl1rquad,Zyl1hoehe:LONGREAL ;
                       VAR Lambda:LFeld;
                       VAR Index :INTEGER );
                       

PROCEDURE Ebene2weiter ( VAR Untersuchungsende,Farbe:INTEGER );


PROCEDURE Glasz1schn (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                          Zyl1pktx,Zyl1pkty,Zyl1rquad,Zyl1hoehe:LONGREAL;
                      VAR Lambda:LFeld;
                      VAR Index :INTEGER );
                      

PROCEDURE Glasz1weiter (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                            Zyl1pktx,Zyl1pkty,Zyl1rquad,
                            Brechindex:LONGREAL;
                        VAR Lambda:LFeld;
                        VAR Index,Farbversch:INTEGER );


PROCEDURE Zylin1schn (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                          Zyl1pktx,Zyl1pkty,Zyl1hoehe,Zyl1rquad:LONGREAL;
                      VAR Lambda:LFeld;
                      VAR Index :INTEGER );
                      

PROCEDURE Zylin1weiter (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                            Zyl1pktx,Zyl1pkty,Zyl1rquad:LONGREAL;
                        VAR Lambda:LFeld;
                        VAR Farbversch,Index:INTEGER );
                        

PROCEDURE Drehk1schn (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                          Dk1pktx,Dk1pkty,Dk1stquad,Dk1hoehe:LONGREAL;
                      VAR Lambda:LFeld;
                      VAR Index :INTEGER );
                      

PROCEDURE Drehk1weiter (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                            Dk1pktx,Dk1pkty,Dk1steig:LONGREAL;
                        VAR Lambda:LFeld;
                        VAR Index,Farbversch:INTEGER);
                        
PROCEDURE Plot_Sw (X,Y,Farbe:INTEGER);


PROCEDURE Plot (X,Y,Farbe:INTEGER);


END RayTrace.
