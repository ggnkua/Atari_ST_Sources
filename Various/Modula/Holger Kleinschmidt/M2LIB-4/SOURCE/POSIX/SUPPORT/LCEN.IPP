IMPLEMENTATION MODULE LCen;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(****************************************************************************)
(* 23-Dez-95, Holger Kleinschmidt                                           *)
(****************************************************************************)

FROM SYSTEM IMPORT
(* PROC *) ADR;
#if (defined MM2)
FROM SYSTEM IMPORT CADR;
#endif

FROM LCTypes IMPORT
(* TYPE *) LCCtype, LCTime, LCNumeric, LCMonetary, LCMessages, CType,
           CClass, CClasses, CTrans;

IMPORT LCPOSIX;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  decimalPoint = ".";
  thousandsSep = ",";
  Grouping     = "3";

CONST
  intCurrSymbol   = "USD ";
  currencySymbol  = "$";
  monDecimalPoint = ".";
  monThousandsSep = ",";
  monGrouping     = "3";
  positiveSign    = "";
  negativeSign    = "-";

  intFracDigits   = 4; (* ?? *)
  fracDigits      = 2; (* ?? *)
  pCsPrecedes     = 1; (* ?? *)
  pSepBySpace     = 1; (* ?? *)
  nCsPrecedes     = 1; (* ?? *)
  nSepBySpace     = 0; (* ?? *)
  pSignPosn       = 1; (* ?? *)
  nSignPosn       = 1; (* ?? *)

TYPE
  VNumeric = RECORD
    Vdecimalpoint : ARRAY [0..1] OF CHAR;
    Vthousandssep : ARRAY [0..1] OF CHAR;
    Vgrouping     : ARRAY [0..1] OF CHAR;
  END;

  VMonetary = RECORD
    Vintcurrsymbol   : ARRAY [0..5] OF CHAR;
    Vcurrencysymbol  : ARRAY [0..1] OF CHAR;
    Vmondecimalpoint : ARRAY [0..1] OF CHAR;
    Vmonthousandssep : ARRAY [0..1] OF CHAR;
    Vmongrouping     : ARRAY [0..1] OF CHAR;
    Vpositivesign    : ARRAY [0..0] OF CHAR;
    Vnegativesign    : ARRAY [0..1] OF CHAR;
  END;

#if ((defined MM2) && !(defined MM2_43c)) || (defined HM2)
CONST
 vctype = LCCtype{
   CClasses{
     CClass{IScntrl}                                           BY 9,
     CClass{IScntrl,ISspace,ISblank}                           BY 1,
     CClass{IScntrl,ISspace}                                   BY 4,
     CClass{IScntrl}                                           BY 18,
     CClass{ISspace,ISblank,ISprint}                           BY 1,
     CClass{ISpunct,ISgraph,ISprint}                           BY 15,
     CClass{ISdigit,ISodigit,ISxdigit,ISalnum,ISgraph,ISprint} BY 8,
     CClass{ISdigit,ISxdigit,ISalnum,ISgraph,ISprint}          BY 2,
     CClass{ISpunct,ISgraph,ISprint}                           BY 7,
     CClass{ISxdigit,ISupper,ISalpha,ISalnum,ISgraph,ISprint}  BY 6,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}           BY 20,
     CClass{ISpunct,ISgraph,ISprint}                           BY 6,
     CClass{ISxdigit,ISlower,ISalpha,ISalnum,ISgraph,ISprint}  BY 6,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 20,
     CClass{ISpunct,ISgraph,ISprint}                           BY 4,
     CClass{IScntrl}                                           BY 1,
     CClass{ISgraph,ISprint}                                   BY 128
   },
   CTrans{
     0C,1C,2C,3C,4C,5C,6C,7C,10C,11C,
     12C,13C,14C,15C,16C,17C,20C,21C,22C,23C,
     24C,25C,26C,27C,30C,31C,32C,33C,34C,35C,
     36C,37C,40C,41C,42C,43C,44C,45C,46C,47C,
     50C,51C,52C,53C,54C,55C,56C,57C,60C,61C,
     62C,63C,64C,65C,66C,67C,70C,71C,72C,73C,
     74C,75C,76C,77C,100C,101C,102C,103C,104C,105C,
     106C,107C,110C,111C,112C,113C,114C,115C,116C,117C,
     120C,121C,122C,123C,124C,125C,126C,127C,130C,131C,
     132C,133C,134C,135C,136C,137C,140C,101C,102C,103C,
     104C,105C,106C,107C,110C,111C,112C,113C,114C,115C,
     116C,117C,120C,121C,122C,123C,124C,125C,126C,127C,
     130C,131C,132C,173C,174C,175C,176C,177C,200C,201C,
     202C,203C,204C,205C,206C,207C,210C,211C,212C,213C,
     214C,215C,216C,217C,220C,221C,222C,223C,224C,225C,
     226C,227C,230C,231C,232C,233C,234C,235C,236C,237C,
     240C,241C,242C,243C,244C,245C,246C,247C,250C,251C,
     252C,253C,254C,255C,256C,257C,260C,261C,262C,263C,
     264C,265C,266C,267C,270C,271C,272C,273C,274C,275C,
     276C,277C,300C,301C,302C,303C,304C,305C,306C,307C,
     310C,311C,312C,313C,314C,315C,316C,317C,320C,321C,
     322C,323C,324C,325C,326C,327C,330C,331C,332C,333C,
     334C,335C,336C,337C,340C,341C,342C,343C,344C,345C,
     346C,347C,350C,351C,352C,353C,354C,355C,356C,357C,
     360C,361C,362C,363C,364C,365C,366C,367C,370C,371C,
     372C,373C,374C,375C,376C,377C
   },
   CTrans{
     0C,1C,2C,3C,4C,5C,6C,7C,10C,11C,
     12C,13C,14C,15C,16C,17C,20C,21C,22C,23C,
     24C,25C,26C,27C,30C,31C,32C,33C,34C,35C,
     36C,37C,40C,41C,42C,43C,44C,45C,46C,47C,
     50C,51C,52C,53C,54C,55C,56C,57C,60C,61C,
     62C,63C,64C,65C,66C,67C,70C,71C,72C,73C,
     74C,75C,76C,77C,100C,141C,142C,143C,144C,145C,
     146C,147C,150C,151C,152C,153C,154C,155C,156C,157C,
     160C,161C,162C,163C,164C,165C,166C,167C,170C,171C,
     172C,133C,134C,135C,136C,137C,140C,141C,142C,143C,
     144C,145C,146C,147C,150C,151C,152C,153C,154C,155C,
     156C,157C,160C,161C,162C,163C,164C,165C,166C,167C,
     170C,171C,172C,173C,174C,175C,176C,177C,200C,201C,
     202C,203C,204C,205C,206C,207C,210C,211C,212C,213C,
     214C,215C,216C,217C,220C,221C,222C,223C,224C,225C,
     226C,227C,230C,231C,232C,233C,234C,235C,236C,237C,
     240C,241C,242C,243C,244C,245C,246C,247C,250C,251C,
     252C,253C,254C,255C,256C,257C,260C,261C,262C,263C,
     264C,265C,266C,267C,270C,271C,272C,273C,274C,275C,
     276C,277C,300C,301C,302C,303C,304C,305C,306C,307C,
     310C,311C,312C,313C,314C,315C,316C,317C,320C,321C,
     322C,323C,324C,325C,326C,327C,330C,331C,332C,333C,
     334C,335C,336C,337C,340C,341C,342C,343C,344C,345C,
     346C,347C,350C,351C,352C,353C,354C,355C,356C,357C,
     360C,361C,362C,363C,364C,365C,366C,367C,370C,371C,
     372C,373C,374C,375C,376C,377C
   }
 };
#else
VAR
  vctype : LCCtype;
#endif

VAR
  vnumeric  : VNumeric;
  vmonetary : VMonetary;

VAR
  numeric  : LCNumeric;
  monetary : LCMonetary;

VAR
  c : CHAR;

BEGIN (* LCen *)
#if (defined HM2) || (defined MM2)
 vnumeric := VNumeric{decimalPoint,thousandsSep,Grouping};
#else
 WITH vnumeric DO
   Vdecimalpoint := decimalPoint;
   Vthousandssep := thousandsSep;
   Vgrouping     := Grouping;
 END;
#endif
 WITH numeric DO WITH vnumeric DO
   decimalpoint := ADR(Vdecimalpoint);
   thousandssep := ADR(Vthousandssep);
   grouping     := ADR(Vgrouping);
 END; END;

#if (defined HM2) || (defined MM2)
 vmonetary := VMonetary{intCurrSymbol,currencySymbol,monDecimalPoint,
                        monThousandsSep,monGrouping,positiveSign,negativeSign};
#else
 WITH vmonetary DO
   Vintcurrsymbol   := intCurrSymbol;
   Vcurrencysymbol  := currencySymbol;
   Vmondecimalpoint := monDecimalPoint;
   Vmonthousandssep := monThousandsSep;
   Vmongrouping     := monGrouping;
   Vpositivesign    := positiveSign;
   Vnegativesign    := negativeSign;
 END;
#endif
 WITH monetary DO WITH vmonetary DO
   intcurrsymbol   := ADR(Vintcurrsymbol);
   currencysymbol  := ADR(Vcurrencysymbol);
   mondecimalpoint := ADR(Vmondecimalpoint);
   monthousandssep := ADR(Vmonthousandssep);
   mongrouping     := ADR(Vmongrouping);
   positivesign    := ADR(Vpositivesign);
   negativesign    := ADR(Vnegativesign);

   intfracdigits   := intFracDigits;
   fracdigits      := fracDigits;
   pcsprecedes     := pCsPrecedes;
   psepbyspace     := pSepBySpace;
   ncsprecedes     := nCsPrecedes;
   nsepbyspace     := nSepBySpace;
   psignposn       := pSignPosn;
   nsignposn       := nSignPosn;
 END; END;

#if !((defined HM2) || ((defined MM2) && !(defined MM2_43c)))
 WITH vctype DO
   class := LCPOSIX.Ctype^.class;
   FOR c := 200C TO 377C DO
     class[c] := CClass{ISgraph,ISprint};
   END;

   toupper := LCPOSIX.Ctype^.toupper;
   tolower := LCPOSIX.Ctype^.tolower;
 END;
#endif

 Numeric  := ADR(numeric);
 Monetary := ADR(monetary);
 Time     := LCPOSIX.Time;
 Ctype    := CADR(vctype);
 Messages := LCPOSIX.Messages;
END LCen.
