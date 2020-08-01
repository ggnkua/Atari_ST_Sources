                                        (* Chapter 11 - Program 3 *)
MODULE VarRec;

FROM InOut   IMPORT WriteString, WriteInt, WriteLn;

TYPE   KindOfVehicle = (Car,Truck,Bicycle,Boat);

       Vehicle = RECORD
         OwnerName   : ARRAY[0..25] OF CHAR;
         GrossWeight : CARDINAL;
         Value       : REAL;
         CASE WhatKind : KindOfVehicle OF
           Car     : Wheels  : CARDINAL;
                     Engine  : ARRAY[0..12] OF CHAR |
           Truck   : Motor   : ARRAY[0..8] OF CHAR;
                     Tires   : CARDINAL;
                     PayLoad : CARDINAL            |
           Bicycle : Tyres   : INTEGER             |
           Boat    : PropBlades : INTEGER;
                     Sail    : BOOLEAN;
                     Power   : ARRAY[0..8] OF CHAR;
         END; (* of CASE *)
       END;   (* of record *)

VAR   Sunfish, Ford, Schwinn, Mac : Vehicle;

BEGIN
   Ford.OwnerName := "Walter";         (* Fields defined in order *)
   Ford.GrossWeight := 5750;
   Ford.Value := 2595.00;
   Ford.WhatKind := Truck;
   Ford.Motor := "V8";
   Ford.Tires := 18;
   Ford.PayLoad := 12000;

   WITH Sunfish DO
      WhatKind := Boat;      (* Fields defined in random order *)
      Sail := TRUE;
      PropBlades := 3;
      Power := "Wind";
      GrossWeight := 375;
      Value := 1300.00;
      OwnerName := "Herman and George";
   END;

   Ford.Engine := "Flathead";         (* Tag-field not defined yet *)
   Ford.WhatKind := Car;              (* but it must be before it  *)
                                      (* can be referred to        *)
   Ford.Wheels := 4;        (* Notice that the non-variant part is *)
                            (* not redefined here.                 *)

   Mac := Sunfish;    (* Entire record copied, including tag-field *)

   IF Ford.WhatKind = Car THEN                (* This should print *)
      WriteString(Ford.OwnerName);
      WriteString(" owns the car with the ");
      WriteString(Ford.Engine);
      WriteString(' engine.');
      WriteLn;
   END;

   IF Sunfish.WhatKind = Bicycle THEN     (* This should not print *)
      WriteString("The sunfish is a bicycle");
      WriteLn;
   END;

   IF Mac.WhatKind = Boat THEN                (* This should print *)
      WriteString("The Mac is now a boat with");
      WriteInt(Mac.PropBlades,2);
      WriteString(" propeller blades.");
      WriteLn;
   END;
END VarRec.
