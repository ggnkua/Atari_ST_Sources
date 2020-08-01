                                     // Chapter 5 - Program 3
#include <iostream.h>

int area(int rec_height, int rec_width);

struct rectangle {
   int height;
   int width;
};

struct pole {
   int length;
   int depth;
};

int area(int rec_height, int rec_width)  //Area of a rectangle
{
   return rec_height * rec_width;
}


main()
{
rectangle box, square;
pole flag_pole;

   box.height = 12;
   box.width = 10;
   square.height = square.width = 8;

   flag_pole.length = 50;
   flag_pole.depth = 6;

   cout << "The area of the box is " << 
                       area(box.height, box.width) << "\n";
   cout << "The area of the square is " << 
                       area(square.height, square.width) << "\n";
   cout << "The funny area is " << 
                       area(square.height, box.width) << "\n";
   cout << "The bad area is " << 
                       area(square.height, flag_pole.depth) << "\n";
}




// Result of execution
//
// The area of the box is 120
// The area of the square is 64
// The funny area is 80
// The bad area is 48
