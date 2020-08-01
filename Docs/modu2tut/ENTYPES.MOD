                                        (* Chapter 10 - Program 1 *)
MODULE Entypes;

FROM InOut IMPORT WriteString, WriteLn;
FROM RealInOut IMPORT WriteReal;

TYPE Days = (mon,tue,wed,thu,fri,sat,sun);
     TimeOfDay = (morning,afternoon,evening,night);

VAR Day             : Days;
    Time            : TimeOfDay;
    RegularRate     : REAL;
    EveningPremium  : REAL;
    NightPremium    : REAL;
    WeekendPremium  : REAL;
    TotalPay        : REAL;

BEGIN    (* Main program *)
   WriteString('                         Pay rate table');
   WriteLn;
   WriteLn;
   WriteString('  DAY       Morning    Afternoon');
   WriteString('    Evening      Night');
   WriteLn;

   RegularRate := 12.00;      (* This is the normal pay rate *)
   EveningPremium := 1.10;    (* 10 percent extra for working late *)
   NightPremium := 1.33;      (* 33 percent extra for graveyard *)
   WeekendPremium := 1.25;    (* 25 percent extra for weekends *)

   FOR Day := mon TO sun DO

      CASE Day OF
        mon : WriteString('Monday   '); |
        tue : WriteString('Tuesday  '); |
        wed : WriteString('Wednesday'); |
        thu : WriteString('Thursday '); |
        fri : WriteString('Friday   '); |
        sat : WriteString('Saturday '); |
        sun : WriteString('Sunday   ');
      END;    (* of CASE statment *)

      FOR Time := morning TO night DO
         CASE Time OF
           morning   : TotalPay := RegularRate; |
           afternoon : TotalPay := RegularRate; |
           evening   : TotalPay := RegularRate * EveningPremium; |
           night     : TotalPay := RegularRate * NightPremium;
         END;  (* of CASE statement *)

         CASE Day OF
           sat : TotalPay := TotalPay * WeekendPremium; |
           sun : TotalPay := TotalPay * WeekendPremium;
         ELSE (* Do nothing *)
         END;  (* of CASE statement *)

         WriteReal(TotalPay,12);
      END;  (* of Time loop *)
      WriteLn;
   END;  (* of FOR loop *)

END Entypes.
