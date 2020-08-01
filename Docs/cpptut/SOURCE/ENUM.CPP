                                   // Chapter 2 - Program 1
#include <iostream.h>

enum game_result {win, lose, tie, cancel};

main()
{
game_result result;
enum game_result omit = cancel;

   for (result = win;result <= cancel;result++) {
      if (result == omit) 
         cout << "The game was cancelled\n";
      else {
         cout << "The game was played ";
         if (result == win)
            cout << "and we won!";
         if (result == lose)
            cout << "and we lost.";
         cout << "\n";
      }
   }
}




// Result of execution
//
// The game was played and we won!
// The game was played and we lost.
// The game was played
// The game was cancelled

