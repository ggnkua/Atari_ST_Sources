
Unit FORMDOR;

(* Version der Resource-Datei: $0000 *)

(* Umsetzung mit einem Programm nach *)
(* einer Idee von Bruno Volkmer      *)

(*F+*)
INTERFACE

Uses Bios, GemDecl, GemAES, UtilAes;


CONST
   nObjects =    50;
   nTrees   =     3;
   nTeds    =    11;
   xObjects =  1518;
   xTrees   =  2718;
   xTeds    =  1210;

TYPE
     TreeArray    =Array[0..nTrees]   of Pointer;
     TedInfoArray =Array[0..nTeds]    of TedInfo;
     ObjAddrArray =Array[0..nObjects] of Object;


VAR
    TreeAddr   : ^TreeArray;
    TedInfoAddr: ^TedInfoArray;
    ObjectAddr : ^ObjAddrArray;


IMPLEMENTATION


CONST GBOX     = 20;
      GIBOX    = 25;
      USERBLK  = 24;
      GBOXCHAR = 27;


VAR
    i, chW, chH, rezol: Integer;
    RSDATA, rsdta     : Pointer;


procedure rscdata; Assembler;
ASM
        LEA      @start, A0
        MOVE.L   A0, rsdta
        BRA      @fertig
@start:
        DC.W $0000,$05EE,$04BA,$04BA,$04BA,$0000
        DC.W $0024,$04BA,$0000,$0A9E,$0032,$0003
        DC.W $000B,$0000,$0000,$0000,$0000,$0AAA
        DC.W $416E,$7265,$6465,$3A00,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$005F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F00,$5858,$5858,$5858
        DC.W $5858,$5858,$004E,$616D,$6531,$3A00
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$005F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F00,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$004E,$616D
        DC.W $6532,$3A00,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$005F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F00,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $0056,$6F72,$6E61,$6D65,$3A00,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$005F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F00
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$0053,$7472,$619E
        DC.W $653A,$005F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F00,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$0058,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5800
        DC.W $506F,$7374,$6661,$6368,$3A00,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$005F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F00,$3939,$3939
        DC.W $3939,$3939,$3939,$3939,$3939,$3939
        DC.W $0050,$6F73,$746C,$6569,$747A,$6168
        DC.W $6C3A,$005F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$005F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$0058
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$004F,$7274,$3A00,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$005F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F00,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$0054,$656C,$6566,$6F6E
        DC.W $3A00,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$005F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F00,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$0046
        DC.W $6178,$3A00,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$005F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F00,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $0041,$6E73,$7072,$6563,$6870,$6172
        DC.W $746E,$6572,$3A00,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $005F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F5F,$5F5F,$5F5F
        DC.W $5F5F,$5F5F,$5F5F,$5F00,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$5858,$5858,$5858,$5858,$5858
        DC.W $5858,$0020,$5665,$7261,$7262,$6569
        DC.W $7465,$6E20,$0041,$6262,$7275,$6368
        DC.W $0020,$0E0F,$0020,$4441,$5445,$4920
        DC.W $0020,$209A,$6265,$7220,$6461,$7320
        DC.W $5072,$6F67,$7261,$6D6D,$2000,$2D2D
        DC.W $2D2D,$2D2D,$2D2D,$2D2D,$2D2D,$2D2D
        DC.W $2D2D,$2D2D,$2D2D,$0031,$0032,$0033
        DC.W $0034,$0035,$0036,$0020,$2051,$7569
        DC.W $7420,$2020,$2020,$2020,$0020,$2041
        DC.W $6472,$6573,$7365,$6E20,$6265,$6172
        DC.W $6265,$6974,$656E,$2000,$2D2D,$2D2D
        DC.W $2D2D,$2D2D,$2D2D,$2D2D,$2D2D,$2D2D
        DC.W $2D2D,$2D2D,$2D2D,$0054,$686F,$6D61
        DC.W $7320,$4B72,$6965,$6765,$7200,$436F
        DC.W $7079,$7269,$6768,$7420,$2843,$2920
        DC.W $3139,$3932,$0057,$2D38,$3435,$3020
        DC.W $416D,$6265,$7267,$004F,$4B00,$0000
        DC.W $002C,$0000,$0037,$0000,$0042,$0003
        DC.W $0006,$0000,$1180,$0000,$FFFF,$000B
        DC.W $000B,$0000,$0054,$0000,$0073,$0000
        DC.W $0092,$0003,$0006,$0000,$1180,$0000
        DC.W $FFFF,$001F,$001F,$0000,$00B8,$0000
        DC.W $00D7,$0000,$00F6,$0003,$0006,$0000
        DC.W $1180,$0000,$FFFF,$001F,$001F,$0000
        DC.W $011E,$0000,$013D,$0000,$015C,$0003
        DC.W $0006,$0000,$1180,$0000,$FFFF,$001F
        DC.W $001F,$0000,$0183,$0000,$01A2,$0000
        DC.W $01C1,$0003,$0006,$0000,$1180,$0000
        DC.W $FFFF,$001F,$001F,$0000,$01EA,$0000
        DC.W $01FB,$0000,$020C,$0003,$0006,$0000
        DC.W $1180,$0000,$FFFF,$0011,$0011,$0000
        DC.W $022B,$0000,$023B,$0000,$024B,$0003
        DC.W $0006,$0000,$1180,$0000,$FFFF,$0010
        DC.W $0010,$0000,$0260,$0000,$027F,$0000
        DC.W $029E,$0003,$0006,$0000,$1180,$0000
        DC.W $FFFF,$001F,$001F,$0000,$02C6,$0000
        DC.W $02E5,$0000,$0304,$0003,$0006,$0000
        DC.W $1180,$0000,$FFFF,$001F,$001F,$0000
        DC.W $0328,$0000,$0347,$0000,$0366,$0003
        DC.W $0006,$0000,$1180,$0000,$FFFF,$001F
        DC.W $001F,$0000,$0396,$0000,$03B5,$0000
        DC.W $03D4,$0003,$0006,$0000,$1180,$0000
        DC.W $FFFF,$001F,$001F,$FFFF,$0001,$0018
        DC.W $0014,$0000,$0000,$00FF,$1100,$0000
        DC.W $0000,$0033,$0012,$0002,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$0024,$0009
        DC.W $0002,$0007,$0001,$0003,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$04BA,$0013
        DC.W $0002,$000B,$0001,$0004,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$004D,$000A
        DC.W $0003,$0006,$0001,$0005,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$04D6,$0013
        DC.W $0003,$001E,$0001,$0006,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$00B1,$000A
        DC.W $0004,$0006,$0001,$0007,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$04F2,$0013
        DC.W $0004,$001E,$0001,$0008,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$0115,$0008
        DC.W $0005,$0008,$0001,$0009,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$050E,$0013
        DC.W $0005,$001E,$0001,$000A,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$017B,$0009
        DC.W $0006,$0007,$0001,$000B,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$052A,$0013
        DC.W $0006,$001E,$0001,$000C,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$01E0,$0007
        DC.W $0007,$0009,$0001,$000D,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$0546,$0013
        DC.W $0007,$0010,$0001,$000E,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$021D,$0003
        DC.W $0008,$000D,$0001,$000F,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$0562,$0013
        DC.W $0008,$000F,$0001,$0010,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$025B,$000C
        DC.W $0009,$0004,$0001,$0011,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$057E,$0013
        DC.W $0009,$001E,$0001,$0012,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$02BD,$0009
        DC.W $000B,$0008,$0001,$0013,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$059A,$0013
        DC.W $000B,$001E,$0001,$0014,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$0323,$000D
        DC.W $000C,$0004,$0001,$0015,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$05B6,$0013
        DC.W $000C,$001E,$0001,$0016,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$0385,$0001
        DC.W $000D,$0010,$0001,$0017,$FFFF,$FFFF
        DC.W $001D,$0008,$0000,$0000,$05D2,$0013
        DC.W $000D,$001E,$0001,$0018,$FFFF,$FFFF
        DC.W $001A,$0005,$0000,$0000,$03F3,$0001
        DC.W $0010,$000D,$0001,$0000,$FFFF,$FFFF
        DC.W $001A,$0025,$0000,$0000,$0401,$0024
        DC.W $0010,$000D,$0001,$FFFF,$0001,$0005
        DC.W $0019,$0000,$0000,$0000,$0000,$0000
        DC.W $0000,$005A,$0019,$0005,$0002,$0002
        DC.W $0014,$0000,$0000,$0000,$1100,$0000
        DC.W $0000,$005A,$0201,$0001,$0003,$0004
        DC.W $0019,$0000,$0000,$0000,$0000,$0002
        DC.W $0000,$000A,$0301,$0004,$FFFF,$FFFF
        DC.W $0020,$0000,$0000,$0000,$0409,$0000
        DC.W $0000,$0003,$0301,$0002,$FFFF,$FFFF
        DC.W $0020,$0000,$0000,$0000,$040D,$0003
        DC.W $0000,$0007,$0301,$0000,$0006,$000F
        DC.W $0019,$0000,$0000,$0000,$0000,$0000
        DC.W $0301,$0050,$0013,$000F,$0007,$000E
        DC.W $0014,$0000,$0000,$00FF,$1100,$0002
        DC.W $0000,$0014,$0008,$0008,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0415,$0000
        DC.W $0000,$0014,$0001,$0009,$FFFF,$FFFF
        DC.W $001C,$0000,$0008,$0000,$042A,$0000
        DC.W $0001,$0014,$0001,$000A,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$043F,$0000
        DC.W $0002,$0014,$0001,$000B,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0441,$0000
        DC.W $0003,$0014,$0001,$000C,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0443,$0000
        DC.W $0004,$0014,$0001,$000D,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0445,$0000
        DC.W $0005,$0014,$0001,$000E,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0447,$0000
        DC.W $0006,$0014,$0001,$0006,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0449,$0000
        DC.W $0007,$0014,$0001,$0005,$0010,$0012
        DC.W $0014,$0000,$0000,$00FF,$1100,$0005
        DC.W $0000,$0016,$0003,$0011,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$044B,$0000
        DC.W $0002,$0016,$0001,$0012,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0459,$0000
        DC.W $0000,$0016,$0001,$000F,$FFFF,$FFFF
        DC.W $001C,$0020,$0008,$0000,$0470,$0000
        DC.W $0001,$0016,$0001,$FFFF,$0001,$0005
        DC.W $0014,$0000,$0000,$00FF,$1142,$0000
        DC.W $0000,$0019,$000A,$0005,$0002,$0004
        DC.W $0014,$0000,$0000,$00FF,$1100,$0002
        DC.W $0001,$0015,$0006,$0003,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0487,$0002
        DC.W $0003,$000E,$0001,$0004,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$0496,$0002
        DC.W $0001,$0012,$0001,$0001,$FFFF,$FFFF
        DC.W $001C,$0000,$0000,$0000,$04A9,$0002
        DC.W $0004,$000D,$0001,$0000,$FFFF,$FFFF
        DC.W $001A,$0027,$0000,$0000,$04B7,$0002
        DC.W $0008,$0015,$0001,$0000,$05EE,$0000
        DC.W $0846,$0000,$0A0E
@fertig:
END;



begin
   rscdata;

   (* Liste der Objektbaum-Adressen relozieren *)

   RSDATA   := rsdta;
   TreeAddr := Pointer(LongInt(RSDATA) +
                       LongInt(xTrees));

   for
     i := 0 to nTrees-1
   do
      TreeAddr^[i] :=
          Pointer(LongInt(TreeAddr^[i]) +
                  LongInt(RSDATA));

   (* Adressen innerhalb TedInfos relozieren *)

   TedInfoAddr := Pointer(LongInt(RSDATA) +
                          LongInt(xTeds));

   for
     i := 0 to nTeds-1
   do
   begin
      with
         TedInfoAddr^[i]
      do
      begin
         te_pvalid:=
               Pointer(LongInt(te_pvalid) +
                       LongInt(RSDATA));
         te_ptmplt:=
               Pointer(LongInt(te_ptmplt) +
                       LongInt(RSDATA));
         te_ptext :=
               Pointer(LongInt(te_ptext)  +
                       LongInt(RSDATA));
      end;
   end;

   (* Object-Specs relozieren, falls notwendig *)

   ObjectAddr := Pointer(LongInt(RSDATA) +
                         LongInt(xObjects));

   for
      i := 0 to nObjects-1
   do
   begin
      with
         ObjectAddr^[i]
      do
      begin
         if
            (o_type <> GBOX) and
            (o_type <> GIBOX) and
            (o_type <> USERBLK) and 
            (o_type <> GBOXCHAR)
         then
         begin
            case
               o_type
            of
            g_text,
            g_ftext,
            g_boxtext,
            g_fboxtext:
               o_spec.t  :=
                    Pointer(LongInt(o_spec.t) +
                            LongInt(RSDATA));
            g_string,
            g_title,
            g_button:
               o_spec.s  :=
                    Pointer(LongInt(o_spec.s) +
                            LongInt(RSDATA));
            g_image:
               o_spec.im :=
                    Pointer(LongInt(o_spec.im) +
                            LongInt(RSDATA));
            g_userdef:
               o_spec.u  :=
                    Pointer(LongInt(o_spec.u) +
                            LongInt(RSDATA));
            g_icon:
               o_spec.ic :=
                    Pointer(LongInt(o_spec.ic) +
                            LongInt(RSDATA));
            end;
         end;

         chW   := 8;
         chH   := 16;
         rezol := GetRez;

         if
            rezol < 2
         then
            chH := 8;

         o_y := (o_y mod 256) * chH +
                (o_y div 256);
         o_x := (o_x mod 256) * chW +
                (o_x div 256);
         o_h := (o_h mod 256) * chH +
                (o_h div 256);
         o_w := (o_w mod 256) * chW +
                (o_w div 256);
      end;
   end;
end.

