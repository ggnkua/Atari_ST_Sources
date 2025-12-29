 IMPLEMENTATION MODULE Atari2Ascii;
(*                                 ASCII Tabelle

    | 0  1  2  3  4  5  6  7  8  9      | 0  1  2  3  4  5  6  7  8  9
----------------------------------  ----------------------------------
  0 |                   TAB 130 | Ç  É  Ñ  Ö  Ü  á  à  â  ä  ã
 10 | LF     CR             140 | å  ç  é  è  ê  ë  í  ì  î  ï
 20 |                     150 | ñ  ó  ò  ô  ö  õ  ú  ù  û  ü
 30 |    SPC !  "  #  $  %  &  '  160 | †  °  ¢  £  §  •  ¶  ß  ®  ©
 40 | (  )  *  +  ,  -  .  /  0  1  170 | ™  ´  ¨  ≠  Æ  Ø  ∞  ±  ≤  ≥
 50 | 2  3  4  5  6  7  8  9  :  ;  180 | ¥  µ  ∂  ∑  ∏  π  ∫  ª  º  Ω
 60 | <  =  >  ?  @  A  B  C  D  E  190 | æ  ø  ¿  ¡  ¬  √  ƒ  ≈  ∆  «
 70 | F  G  H  I  J  K  L  M  N  O  200 | »  …     À  Ã  Õ  Œ  œ  –  —
 80 | P  Q  R  S  T  U  V  W  X  Y  210 | “  ”  ‘  ’  ÷  ◊  ÿ  Ÿ  ⁄  €
 90 | Z  [  \  ]  ^  _  `  a  b  c  220 | ‹  ›  ﬁ  ﬂ  ‡  ·  ‚  „  ‰  Â
100 | d  e  f  g  h  i  j  k  l  m  230 | Ê  Á  Ë  È  Í  Î  Ï  Ì  Ó  Ô
110 | n  o  p  q  r  s  t  u  v  w  240 |   Ò  Ú  Û  Ù  ı  ˆ  ˜  ¯  ˘
120 | x  y  z  {  |  }  ~    Ä  Å  250 | ˙  ˚  ¸  ˝  ˛  ˇ
----------------------------------- ----------------------------------
    | 0  1  2  3  4  5  6  7  8  9        0  1  2  3  4  5   6  7  8  9
*)

PROCEDURE CorkConvert( VAR Buffer : ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
   i:=0;
   WHILE ((Buffer[i] # 0C) AND (i< HIGH(Buffer))) DO
   IF (ORD(Buffer[i])>127)  THEN
   CASE ORD(Buffer[i]) OF
     128 : Buffer [i] :="C"  (*Ä*)
     |129 : Buffer [i] :="u" (*Å*)
     |130 : Buffer [i] :="e" (*Ç*)
     |131 : Buffer [i] :="a" (*É*)
     |132 : Buffer [i] :="a" (*Ñ*)
     |133 : Buffer [i] :="a" (*Ö*)
     |134 : Buffer [i] :="a" (*Ü*)
     |135 : Buffer [i] :="c" (*á*)
     |136 : Buffer [i] :="e" (*à*)
     |137 : Buffer [i] :="e" (*â*)
     |138 : Buffer [i] :="e" (*ä*)
     |139 : Buffer [i] :="i" (*ã*)
     |140 : Buffer [i] :="i" (*å*)
     |141 : Buffer [i] :="i" (*ç*)
     |142 : Buffer [i] :="A" (*é*)
     |143 : Buffer [i] :="A" (*è*)
     |144 : Buffer [i] :="E" (*ê*)
     |145 : Buffer [i] :="a" (*ë*) (* ae *)
     |146 : Buffer [i] :="A" (*í*) (* AE *)
     |147 : Buffer [i] :="o" (*ì*)
     |148 : Buffer [i] :="o" (*î*)
     |149 : Buffer [i] :="o" (*ï*)
     |150 : Buffer [i] :="u" (*ñ*)
     |151 : Buffer [i] :="u" (*ó*)
     |152 : Buffer [i] :="y" (*ò*)
     |153 : Buffer [i] :="o" (*ô*)
     |154 : Buffer [i] :="U" (*ö*)
     |155 : Buffer [i] :="U" (*õ*)
     |156 : Buffer [i] :="L" (*ú*)
     |157 : Buffer [i] :="y" (*ù*)
     |158 : Buffer [i] :="s" (*û*) (* ss *)
     |159 : Buffer [i] :="a" (*ü*)
     |160 : Buffer [i] :="a" (*†*)
     |161 : Buffer [i] :="i" (*°*)
     |162 : Buffer [i] :="o" (*¢*)
     |163 : Buffer [i] :="u" (*£*)
     |164 : Buffer [i] :="n" (*§*)
     |165 : Buffer [i] :="N" (*•*)
     |166 : Buffer [i] :="U" (*¶*)
     |167 : Buffer [i] :="o" (*ß*)
     |168 : Buffer [i] :="?" (*®*)
     |169 : Buffer [i] :="o" (*©*)
     |170 : Buffer [i] :="o" (*™*)
     |171 : Buffer [i] :="D" (*´*)
     |172 : Buffer [i] :="a" (*¨*)
     |173 : Buffer [i] :="i" (*≠*)
     |174 : Buffer [i] :="I" (*Æ*)
     |175 : Buffer [i] :="I" (*Ø*)
     |176 : Buffer [i] :="a" (*∞*)
     |177 : Buffer [i] :="o" (*±*)
     |178 : Buffer [i] :="O" (*≤*)
     |179 : Buffer [i] :="o" (*≥*)
     |180 : Buffer [i] :="o" (*¥*)  (* oe *)
     |181 : Buffer [i] :="O" (*µ*)  (* OE *)
     |182 : Buffer [i] :="A" (*∂*)
     |183 : Buffer [i] :="A" (*∑*)
     |184 : Buffer [i] :="O" (*∏*)
     |185 : Buffer [i] :="I" (*π*)
     |186 : Buffer [i] :="A" (*∫*)
     |187 : Buffer [i] :="E" (*ª*)
     |188 : Buffer [i] :="U" (*º*)
     |189 : Buffer [i] :="y" (*Ω*)
     |190 : Buffer [i] :="b" (*æ*)  (* ?? *)
     |191 : Buffer [i] :="B" (*ø*)  (* ?? *)
     |192 : Buffer [i] :="i" (*¿*)  (* ij *)
     |193 : Buffer [i] :="I" (*¡*)  (* IJ *)
     |194 : Buffer [i] :="C" (*¬*)
     |195 : Buffer [i] :="C" (*√*)
     |196 : Buffer [i] :="D" (*ƒ*)
     |197 : Buffer [i] :="E" (*≈*)
     |198 : Buffer [i] :="E" (*∆*)
     |199 : Buffer [i] :="G" (*«*)
     |200 : Buffer [i] :="L" (*»*)
     |201 : Buffer [i] :="L" (*…*)
     |202 : Buffer [i] :="L" (*…*)
     |203 : Buffer [i] :="N" (*À*)
     |204 : Buffer [i] :="N" (*Ã*)
     |205 : Buffer [i] :="N" (*Õ*)
     |206 : Buffer [i] :="O" (*Œ*)
     |207 : Buffer [i] :="R" (*œ*)
     |208 : Buffer [i] :="R" (*–*)
     |209 : Buffer [i] :="S" (*—*)
     |210 : Buffer [i] :="S" (*“*)
     |211 : Buffer [i] :="S" (*”*)
     |212 : Buffer [i] :="T" (*‘*)
     |213 : Buffer [i] :="T" (*’*)
     |214 : Buffer [i] :="U" (*÷*)
     |215 : Buffer [i] :="U" (*◊*)
     |216 : Buffer [i] :="I" (*ÿ*)
     |217 : Buffer [i] :="Z" (*Ÿ*)
     |218 : Buffer [i] :="Z" (*⁄*)
     |219 : Buffer [i] :="Z" (*€*)
     |220 : Buffer [i] :="A" (*‹*)
     |221 : Buffer [i] :="›" (*›*)
     |222 : Buffer [i] :="A" (*ﬁ*)
     |223 : Buffer [i] :="d" (*ﬂ*)  (* dt *)
     |224 : Buffer [i] :="a" (*‡*)
     |225 : Buffer [i] :="s" (*·*)  (* ss *)
     |226 : Buffer [i] :="c" (*‚*)
     |227 : Buffer [i] :="c" (*„*)
     |228 : Buffer [i] :="d" (*‰*)
     |229 : Buffer [i] :="e" (*Â*)
     |230 : Buffer [i] :="e" (*Ê*)
     |231 : Buffer [i] :="g" (*Á*)
     |232 : Buffer [i] :="i" (*Ë*)
     |233 : Buffer [i] :="l" (*È*)
     |234 : Buffer [i] :="l" (*Í*)
     |235 : Buffer [i] :="n" (*Î*)
     |236 : Buffer [i] :="n" (*Ï*)
     |237 : Buffer [i] :="n" (*Ì*)
     |238 : Buffer [i] :="o" (*Ó*)
     |239 : Buffer [i] :="r" (*Ô*)
     |240 : Buffer [i] :="r" (**)
     |241 : Buffer [i] :="s" (*Ò*)
     |242 : Buffer [i] :="s" (*Ú*)
     |243 : Buffer [i] :="s" (*Û*)
     |244 : Buffer [i] :="t" (*Ù*)
     |245 : Buffer [i] :="t" (*ı*)
     |246 : Buffer [i] :="u" (*ˆ*)
     |247 : Buffer [i] :="u" (*˜*)
     |248 : Buffer [i] :="Y" (*¯*)
     |249 : Buffer [i] :="z" (*˘*)
     |250 : Buffer [i] :="z" (*˙*)
     |251 : Buffer [i] :="z" (*˚*)
     |252 : Buffer [i] :="A" (*¸*)
     |253 : Buffer [i] :="E" (*˝*)
     |254 : Buffer [i] :="E" (*˛*)
     |255 : Buffer [i] :="I" (*ˇ*)
   ELSE
      HALT;(* Darf -- kann eigentlich nie passieren! *)  
   END(*CASE*);
   END(*IF*);   
   i:=i+1;
   END(*WHILE*);
 (**)
END CorkConvert;

PROCEDURE ErrConvert( VAR Buffer : ARRAY OF CHAR; Length : INTEGER):BOOLEAN;
VAR i : INTEGER;
BEGIN
   IF (Length > HIGH(Buffer)) THEN
       RETURN FALSE;
   END(*IF*);
   FOR i:=0 TO Length DO
       IF ((ORD(Buffer[i]) > 15) AND (ORD(Buffer[i]) < 26)) THEN
          Buffer[i]:= CHR(ORD(Buffer[i])+32)
       END(*IF*);
   END(*FOR*);
   RETURN TRUE
END ErrConvert;

END Atari2Ascii.
