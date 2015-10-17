
DEFINITION MODULE Characters;

CONST

  (* Standard ASCII-Namen fÅr Control-Zeichen *)
  NUL = 000C;    BS  = 010C;    DLE = 020C;    CAN = 030C;
  SOH = 001C;    HT  = 011C;    DC1 = 021C;    EM  = 031C;
  STX = 002C;    LF  = 012C;    DC2 = 022C;    SUB = 032C;
  ETX = 003C;    VT  = 013C;    DC3 = 023C;    ESC = 033C;
  EOT = 004C;    FF  = 014C;    DC4 = 024C;    FS  = 034C;
  ENQ = 005C;    CR  = 015C;    NAK = 025C;    GS  = 035C;
  ACK = 006C;    SO  = 016C;    SYN = 026C;    RS  = 036C;
  BEL = 007C;    SI  = 017C;    ETB = 027C;    US  = 037C;

  DEL = 177C;

  (* Alternative Namen fÅr Control-Zeichen *)
  TAB = 011C; (* Ctrl-I *)
  EOF = 032C; (* Ctrl-Z *)

TYPE

  ASCII  = SET OF [0C..377C];

CONST

  ASCII7   = ASCII {0C..177C};                  (* Alle "echten" ASCII-Z. *)
  Letters  = ASCII {' '..176C,200C..377C};      (* Alle druckbaren Zeichen *)
  Controls = ASCII {0C..37C,177C};              (* Alle Ctrl-Zeichen und DEL *)
  Spaces   = ASCII {' ',11C..15C};              (* 'white space' *)
  Digits   = ASCII {'0'..'9'};                  (* Alle Ziffern *)
  HexDigits= ASCII {'0'..'9','A'..'F','a'..'f'};(* Alle hexadez. Ziffern *)
  Alphas   = ASCII {'A'..'Z','a'..'z',          (* Alle Buchstaben *)
                   'Ä'..'ö','û','†'..'ß','∞'..'∏','¿'..'¡'};
  Lowers   = ASCII {'a'..'z','Å'..'ç','ë',      (* Alle Kleinbuchstaben *)
                   'ì'..'ò','û','†'..'§','¶','ß','∞','±','≥','¥','¿'};
  Uppers   = ASCII {'A'..'Z','Ä','é','è','ê',   (* Alle Groûbuchstaben *)
                   'í','ô','ö','•','≤','µ','∂','∑','∏','¡'};
  Greeks   = ASCII {'‡','·','‚','„','‰','Â',    (* Alle griech. Buchstaben *)
                   'Ê','Á','Ë','È','Í','Î','Ï','Ì','Ó','Ô'};

PROCEDURE IsASCII7 (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein echtes ASCII-Zeichen (7 Bit) ist *)

PROCEDURE IsLetter (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein druckbares Zeichen ist *)

PROCEDURE IsControl (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein Ctrl-Zeichen oder DEL ist *)

PROCEDURE IsDigit (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' eine Ziffer ist *)

PROCEDURE IsHexDigit (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' eine hexadez. Ziffer ist *)

PROCEDURE IsNum (c: CHAR): BOOLEAN;
  (* Wie 'IsDigit' *)

PROCEDURE IsAlpha (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein Buchstabe ('a'-'z', 'A'-'Z' u. Umlaute) ist *)

PROCEDURE IsAlphaNum (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein Buchstabe oder eine Ziffer ist *)

PROCEDURE IsSpace (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein Space, FF, LF, CR, HT oder VT ist *)

PROCEDURE IsUpper (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein Gro·buchstabe ist *)

PROCEDURE IsLower (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein Kleinbuchstabe ist *)

PROCEDURE IsGreek (c: CHAR): BOOLEAN;
  (* Liefert TRUE, wenn 'c' ein griechischer Buchstabe ist *)


END Characters.
