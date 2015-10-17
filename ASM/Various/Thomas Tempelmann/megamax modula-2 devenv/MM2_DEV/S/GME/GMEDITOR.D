DEFINITION MODULE GMEditor;
(*$Z+*)

(* Bemerkung: StringZeilen werden als >>Zeile<<, Pointer-Objekte
   als >>Line<< bezeichnet *)

FROM GMEBase IMPORT einPufferPointer, eineInfo, einLinePointer;
FROM GMEConfig IMPORT einTasteneintrag;
 
PROCEDURE Editieren (Puff: einPufferPointer;
                     VAR RetPuff: einPufferPointer;
                     VAR termch: einTasteneintrag;
                     infozeile: ARRAY OF CHAR;
                     Level: CARDINAL);

(* DEFINITION MODULE EditLook; *)

PROCEDURE SuchwortHolen (Puff: einPufferPointer; VAR suchwort: ARRAY OF CHAR);
PROCEDURE WortSuchen (Puff: einPufferPointer;
                      holen: BOOLEAN; VAR suchwort: ARRAY OF CHAR);
PROCEDURE SuchTauschen (Puff: einPufferPointer; holen: BOOLEAN;
                        VAR suchwort, tauschwort: ARRAY OF CHAR);

(* END EditLook. *)

END GMEditor.
