                                     // Chapter 11 - Program 5
#include <iostream.h>
#include "person.h"
#include "supervsr.h"

person *staff[10];

main()
{
supervisor *suppt;
programmer *progpt;
secretary *secpt;

   cout << "XYZ Staff -- note salary is monthly.\n\n";

   suppt = new supervisor;
   suppt->init_data("Big John", 5100, "President");
   staff[0] = suppt;

   progpt = new programmer;
   progpt->init_data("Joe Hacker", 3500, "debugger", "Pascal");
   staff[1] = progpt;

   progpt = new programmer;
   progpt->init_data("OOP Wizard", 7700, "senior analyst", "C++");
   staff[2] = progpt;

   secpt = new secretary;
   secpt->init_data("Tillie Typer", 2200, 1, 85);
   staff[3] = secpt;

   suppt = new supervisor;
   suppt->init_data("Tom talker", 5430, "Sales manager");
   staff[4] = suppt;

   progpt = new programmer;
   progpt->init_data("Dave Debugger", 5725, "code maintainer", 
                                                "assembly language");
   staff[5] = progpt;

   for (int index = 0 ; index < 6 ; index++ )
      staff[index]->display();

   cout << "End of employee list.\n";
}




// Result of execution

// XYZ Staff -- note salary is monthly.
//
// Supervisor --> Big John's salary is 5100 and is the President.
//
// Programmer --> Joe Hacker's salary is 3500 and is debugger.
//                Joe Hacker's specialty is Pascal.
//
// Programmer --> OOP Wizard's salary is 7700 and is senior analyst.
//                OOP Wizard's specialty is C++.
//
// Secretary ---> Tillie Typer's salary is 2200.
//                Tillie typer types 85 per minute and can take shorthand.
//
// Supervisor --> Tom Talker's salary is 5430 and is the sales manager.
//
// Programmer --> Dave Debugger's salary is 5725 and is code maintainer.
//                Dave Debugger's specialty is assembly language.
//
// End of employee list.
