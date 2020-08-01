                                      // Chapter 4 - Program 4
#include <iostream.h>
#include <stdio.h>

int get_volume(int length, int width = 2, int height = 3);

main()
{
int x = 10, y = 12, z = 15;

   cout << "Some box data is " << get_volume(x, y, z) << "\n";
   cout << "Some box data is " << get_volume(x, y) << "\n";
   cout << "Some box data is " << get_volume(x) << "\n";

   cout << "Some box data is ";
   cout << get_volume(x, 7) << "\n";
   cout << "Some box data is ";
   cout << get_volume(5, 5, 5) << "\n";
   
}

int get_volume(int length, int width, int height)
{
   printf("%4d %4d %4d   ", length, width, height);
   return length * width * height;
}




// Result of execution
//
//   10   12   15Some box data is   1800
//   10   12    3Some box data is    360
//   10    2    3Some box data is     60
// Some box data is   10    7    3   210
// Some box data is    5    5    5   125
