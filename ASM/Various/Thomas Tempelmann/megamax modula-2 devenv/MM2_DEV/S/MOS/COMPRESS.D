DEFINITION MODULE Compressions;

FROM    SYSTEM  IMPORT  ADDRESS;


CONST   DestOverhead = 6L;
        (*
         * Um soviel Bytes sollte der Kodierungs-Puffer grîûer als der
         * Ausgangspuffer sein, damit die Komprimierung nicht fehlschlagen
         * kann.
         *)

PROCEDURE Encode (    type:      CARDINAL;
                      source:    ADDRESS;
                      sourceLen: LONGCARD;
                      dest:      ADDRESS;
                      destLen:   LONGCARD;
                  VAR codeLen:   LONGCARD );
  (*
   * Komprimiert beliebige Daten
   *
   * Eingabe:
   *  'type':      Bei Null wird die optimale Komprimierung ausgesucht (bisher
   *               nur LZW), ist sie Eins, wird eine Lempel-Ziv-Welch-Kodierung
   *               vorgenommen, sonst wird wie bei Null vorgegangen.
   *  'source':    Adresse der Originaldaten
   *  'sourceLen': LÑnge der Originaldaten
   *  'dest':      Zieladresse fÅr komprimierte Daten
   *  'destLen':   LÑnge des Puffers fÅr komprimierte Daten, muû um Sechs
   *               grîûer sein, damit Komprimierung IMMER erfolgreich ist.
   *               Bei der Kodierung wird keinesfalls Åber diesen Puffer
   *               hinausgeschrieben.
   * RÅckgabe:
   *  'codeLen':   LÑnge der komprimierten Daten, egal, ob sie in den Puffer
   *               passen oder nicht. Ist 'codeLen' Null oder grîûer als
   *               'destLen', sind die Daten im dest-Puffer nicht gÅltig.
   *               Dies kann nur passieren, wenn 'destLen' nicht um Sechs
   *               grîûer als 'sourceLen' ist.
   *
   * Sonderfall:
   *  Ist 'dest' NIL oder 'destLen' Null, wird keine Komprimierung
   *  vorgenommen, 'codeLen' enthÑlt dann trotzdem die theoritische
   *  LÑnge der komprimierten Daten.
   *
   * Ist die Komprimierung erfolgreich, werden im komprimierten Code
   * die Informationen Åber dessen Komprimierungsart und OriginallÑnge
   * abgelegt.
   *)

PROCEDURE GetInfo (     code:   ADDRESS;
                    VAR type:   CARDINAL;
                    VAR length: LONGCARD );
  (*
   * Eingabe:
   *   'source': Puffer der mit 'Encode' kodierten Daten.
   * RÅckgabe:
   *   'type': 0 -> nicht komprimiert
   *           1 -> Lempel-Ziv-Welch-Kodierung
   *   'length': OriginallÑnge
   *)

PROCEDURE Decode (    code:    ADDRESS;
                      codeLen: LONGCARD;
                      orig:    ADDRESS;
                      origLen: LONGCARD;
                  VAR success: BOOLEAN );
  (*
   * Dekomprimiert die Daten wieder.
   * Es muû noch mind. 8 KB Speicher frei sein!
   *
   * Eingabe:
   *   'code': Adresse der kodierten Daten
   *   'codeLen': LÑnge der kodierten Daten
   *   'orig': Zieladresse fÅr Originaldaten
   *   'origLen': Vermeintliche LÑnge der Originaldaten
   *              (kann von 'sourceLen'-Parameter bei 'Encode' Åbernommen
   *               oder Åber 'GetInfo' ermittelt werden).
   * RÅckgabe:
   *   'success': Wenn 'origLen' nicht mit der internen Information
   *              Åbereinstimmt oder wenn ein unbekannter Koprimierungs-
   *              algorithmus verwendet wurde, liefert 'success' FALSE,
   *              sonst TRUE.
   *)

(*
 * Beispiel:
 *
 *   (* Zuerst die Daten komprimieren *)
 *   (* 'data' zeigt auf die Daten im Speicher, 'len' ist ihre LÑnge *)
 *   destLen:= len + DestOverhead;
 *   ALLOCATE (destData, destLen);
 *   Encode (0, data, len, destData, destLen, codeLen);
 *   (* Hierbei kann kein Fehler aufgetreten sein *)
 *   (* Der Code ist nun 'codeLen' Bytes lang *)
 *
 *   Der Code kann abgespeichert werden...
 *
 *   (* Nun wieder dekomprimieren *)
 *   GetInfo (destData, len);
 *   Decode (destData, destLen, data, len, ok);
 *   IF NOT ok THEN Fehler END;
 *)

END Compressions.
