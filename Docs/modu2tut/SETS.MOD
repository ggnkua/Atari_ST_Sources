                                        (* Chapter 10 - Program 3 *)
MODULE Sets;

FROM InOut IMPORT WriteString, WriteLn;

TYPE Goodies = (IceCream,WhippedCream,Banana,Nuts,Cherry,
                ChocSyrup,StrawBerries,Caramel,SodaWater,
                Salt,Pepper,Cone,Straw,Spoon,Stick);

     Treat = SET OF Goodies;

VAR  Sundae       : Treat;
     BananaSplit  : Treat;
     Soda         : Treat;
     IceCreamCone : Treat;
     NuttyBuddy   : Treat;
     Mixed        : Treat;
     Index        : Treat;

BEGIN
        (* Define all ingredients used in each treat *)
IceCreamCone := Treat{IceCream,Cone};
Soda := Treat{Straw,SodaWater,IceCream,Cherry};
BananaSplit := Treat{IceCream..Caramel};
BananaSplit := BananaSplit + Treat{Spoon};
NuttyBuddy := Treat{Cone,IceCream,ChocSyrup,Nuts};
Sundae := Treat{IceCream,WhippedCream,Nuts,Cherry,ChocSyrup,
           Spoon};

                (* Combine for a list of all ingredients used *)
Mixed := IceCreamCone + Soda + BananaSplit + NuttyBuddy +
         Sundae;

                (* Now find what ingredients are not used *)

Mixed := Treat{IceCream..Stick} - Mixed;

   IF IceCream     IN Mixed THEN
                  WriteString('Ice cream not used');
                  WriteLn; END;
   IF WhippedCream IN Mixed THEN
                  WriteString('Whipped Cream not used');
                  WriteLn; END;
   IF Banana       IN Mixed THEN
                  WriteString('Bananas not used');
                  WriteLn; END;
   IF Nuts         IN Mixed THEN
                  WriteString('Nuts not used');
                  WriteLn; END;
   IF Cherry       IN Mixed THEN
                  WriteString('Cherries not used');
                  WriteLn; END;
   IF ChocSyrup    IN Mixed THEN
                  WriteString('Chocolate Syrup not used');
                  WriteLn; END;
   IF StrawBerries IN Mixed THEN
                  WriteString('Strawberries not used');
                  WriteLn; END;
   IF Caramel      IN Mixed THEN
                  WriteString('Caramel not used');
                  WriteLn; END;
   IF SodaWater    IN Mixed THEN
                  WriteString('SodaWater not used');
                  WriteLn; END;
   IF Salt         IN Mixed THEN
                  WriteString('Salt not used');
                  WriteLn; END;
   IF Pepper       IN Mixed THEN
                  WriteString('Pepper not used');
                  WriteLn; END;
   IF Cone         IN Mixed THEN
                  WriteString('Cone not used');
                  WriteLn; END;
   IF Straw        IN Mixed THEN
                  WriteString('Straw not used');
                  WriteLn; END;
   IF Spoon        IN Mixed THEN
                  WriteString('Spoon not used');
                  WriteLn; END;
   IF Stick        IN Mixed THEN
                  WriteString('Stick not used');
                  WriteLn; END;
END Sets.
