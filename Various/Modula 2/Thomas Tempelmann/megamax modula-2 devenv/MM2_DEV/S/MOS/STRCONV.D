DEFINITION MODULE StrConv;

(*
 * Umwandlungsfunktionen zw. Zahlen und Strings
 *)

FROM SYSTEM IMPORT LONGWORD, WORD;

FROM Strings IMPORT String;


PROCEDURE StrToLCard ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                       VAR valid : BOOLEAN ): LONGCARD;

PROCEDURE StrToCard  ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                       VAR valid: BOOLEAN ): CARDINAL;

PROCEDURE StrToLInt  ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                       VAR valid: BOOLEAN ): LONGINT;

PROCEDURE StrToInt   ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                       VAR valid: BOOLEAN ): INTEGER;

  (*
     Wenn 'valid' nach dem Aufruf FALSE ist, bedeutet das, daû der
     geforderte Wert nicht ermittelt werden konnte.

     'pos' ist vor dem Aufruf auf die Stringposition zu setzen, ab der
     die Zahl gelesen werden soll. Nach dem Aufruf liefert 'pos' die
     Position im String, hinter der die umgewandelte Zahl endete.
     Endet der String nach der Zahl, ist 'pos' = Length(str).
     In der Regel ist 'pos' also vor dem Aufruf auf Null zu setzen!

     FÅr die vier StrTo...-Funktionen gilt:

     - fÅhrende Blanks werden ignoriert, innerhalb der Zahl dÅrfen
       dann keine Leerzeichen mehr vorkommen.
     - ein eventuell vorangestelltes '+' wird ignoriert.
     - PrÑfixe steuern die Interpretation der folgenden Zeichen:
       '$' fÅr Hexadezimal, '%' fÅr BinÑr, kein PrÑfix bedeutet
       dezimal.
     - Bei StrToInt bzw. StrToLInt muû das '-' zuerst stehen, erst
       dann darf der PrÑfix folgen
       
     Beispiele: StrToCard ('  123 12') = 123
                StrToLInt ('-$80') = -128L
  *)

PROCEDURE StrToLNum (REF str   : ARRAY OF CHAR;
                         base  : CARDINAL; (* [2..36] *)
                     VAR pos   : CARDINAL;
                     VAR valid : BOOLEAN ): LONGCARD;

PROCEDURE StrToNum (REF str   : ARRAY OF CHAR;
                        base  : CARDINAL; (* [2..36] *)
                    VAR pos   : CARDINAL;
                    VAR valid : BOOLEAN ): CARDINAL;


PROCEDURE StrToReal ( REF str: ARRAY OF CHAR; VAR pos: CARDINAL;
                      VAR valid: BOOLEAN ): LONGREAL;

  (*
    StrToReal liefert den Wert einer reellen Zahl. Dabei darf entweder der
    Nachkommateil (einschlieûlich '.') oder der Vorkommateil fehlen. Ebenfalls
    braucht kein Exponent angegeben werden. Ein eventueller Skalierungsfaktor
    wird durch ein vorangestelltes 'E' erkannt und darf im Bereich von -1232
    bis +1232 liegen.

    Es gilt:
    
    - fÅhrende Blanks werden ignoriert, innerhalb der Zahl dÅrfen
      dann keine Leerzeichen mehr vorkommen.
    - ein eventuell vorangestelltes '+' wird ignoriert.
    - 'ThousandsChar' werden Åberlesen.
    
    z.B. : StrToReal ('123E12') = 1.23 E14
           StrToReal ('.012E-23') = 1.2 E-25
  *)



(* ======================================================================= *
 * Es folgen Funktionen zur Umwandlung von Zahlen in Strings. Dabei gilt   *
 * allgemein:                                                              *
 * - 'spc' bestimmt die MindestlÑnge des resultierenden Strings 'str'.     *
 * ======================================================================= *)


PROCEDURE CardToStr ( v: LONGCARD; spc: CARDINAL): String;
PROCEDURE IntToStr  ( v: LONGINT;  spc: CARDINAL): String;

  (*
    Die ...ToStr-Funktionen wandeln eine Zahl in einen String um. Dabei steht
    ein eventuelles Minuszeichen direkt vor der ersten Ziffer. Falls die Zahl
    weniger Stellen (inklusive Vorzeichen) als in 'spc' angegeben haben sollte,
    so werden entsprechend viele Leerzeichen vorangestellt.
    
    z.B. : CardToStr (123,10) = '       123'
           IntToStr (-2345,2) = '-2345'
  *)

PROCEDURE LHexToStr ( v: LONGWORD; spc: CARDINAL): String;
PROCEDURE HexToStr  ( v: WORD;     spc: CARDINAL): String;
PROCEDURE LBinToStr ( v: LONGWORD; spc: CARDINAL): String;
PROCEDURE BinToStr  ( v: WORD;     spc: CARDINAL): String;

  (*
    Die Hex- und Bin-Funktionen erzeugen, wie der Name sagt, Strings in
    hexadezimaler bzw. binÑrer ReprÑsentation. Es werden nur positive Zahlen
    erzeugt. Zu Beachten ist, daû den Zahlen dabei ein '$' bzw. '%' vorange-
    stellt wird und dieses Zeichen auch mit zur MindestlÑngenangabe 'spc' zÑhlt.
    Ggf. ist das vorangestellte Zeichen mit der Funktion 'Strings.Delete' zu
    entfernen. FÅhrende Nullen werden nicht unterdrÅckt.
    
    z.B.: HexToStr (128,4)  = '$080'
          HexToStr (128,0)  = '$80'
          LHexToStr (-1L,0) = '$FFFFFFFF' (8 Ziffern)
          BinToStr (100,9)  = '%01100100'
          LBinToStr (-1L,1) = '%11111111111111111111111111111111' (32 Ziffern)
  *)

PROCEDURE LNumToStr (    lnum : LONGWORD;
                         base : CARDINAL; (* [2..36] *)
                         space: CARDINAL;
                         fill : CHAR    ): String;

PROCEDURE NumToStr (    num  : WORD;
                        base : CARDINAL; (* [2..36] *)
                        space: CARDINAL;
                        fill : CHAR    ): String;
  (*
   * 'fill' bestimmt das Zeichen, mit dem ggf. vorn aufgefÅllt wird.
   *)

PROCEDURE FloatToStr ( v: LONGREAL; spc, n:CARDINAL): String;

  (*
    Durch diese Funktion wird die Zahl 'v' in wissenschaftlicher Notation dar-
    gestellt. Es wird eine Vorkommastelle und 'n' Nachkommastellen, gefolgt von
    'E', dem Vorzeichen des Skalierungsfaktors und dem vierstelligen Wert.
    Ggf. wird der String links mit Leerzeichen bis zur LÑnge 'spc' aufgefÅllt.
    
    z.B. : FloatToStr (0.0123,12,1) = '   1.2E-0002'
           FloatToStr (9.9,0,10) = '9.9000000000E+0000'
  *)

PROCEDURE FixToStr ( v: LONGREAL; spc, n:CARDINAL): String;

  (*
    Diese Funktion stellt 'v' in Festpunktnotation dar, wobei entsprechend viele
    Vorkommastellen, jedoch nur genau 'n' Nachkommastellen gebracht werden.
    Wenn der String kÅrzer als 'spc' sein sollte, so werden entsprechend viele
    Leerzeichen vorangestellt.
    
    z.B. : FixToStr (0.0123,12,1) = '         0.0'
           FixToStr (9.9,0,10) = '9.9000000000'
  *)

PROCEDURE RealToStr( v: LONGREAL; spc, n: CARDINAL): String;

  (*
    Diese Prozedur verwendet je nach Lage des Wertes 'v' innerhalb der Werte
    von FixToFloatMin und FixToFloatMax (aus 'MOSConfig') das Festkomma- oder
    Flieûkomma-Format zur Darstellung von 'v'.
  *)
  
PROCEDURE EngToStr ( v: LONGREAL; spc, n:CARDINAL): String;

  (*
    Durch diese Funktion wird die Zahl 'v' in Ingenieur-Notation dargestellt.
    Es werden bis zu drei Vorkommastellen und 'n' Nachkommastellen, gefolgt
    von 'E', dem Vorzeichen des Skalierungsfaktors und dem vierstelligen Wert,
    der immer ein Vielfaches von Drei ist. Ggf. wird der String links mit Leer-
    zeichen bis zur LÑnge 'spc' aufgefÅllt.
    
    z.B. : EngToStr (0.0123,12,1) = '  12.3E-0003'
           EngToStr (9.9,0,10) = '9.9000000000E+0000'
  *)

END StrConv.
