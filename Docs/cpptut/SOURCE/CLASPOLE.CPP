                                     // Chapter 5 - Program 4
#include <iostream.h>

class rectangle {              // A simple class
   int height;
   int width;
public:
   int area(void);             // with two methods
   void initialize(int, int);
};

int rectangle::area(void)      //Area of a rectangle
{
   return height * width;
}

void rectangle::initialize(int init_height, int init_width)
{
   height = init_height;
   width = init_width;
}


struct pole {
   int length;
   int depth;
};



main()
{
rectangle box, square;
pole flag_pole;

// box.height = 12;
// box.width = 10;
// square.height = square.width = 8;

   box.initialize(12, 10);
   square.initialize(8, 8);

   flag_pole.length = 50;
   flag_pole.depth = 6;

   cout << "The area of the box is " << 
                       box.area() << "\n";
   cout << "The area of the square is " << 
                       square.area() << "\n";
// cout << "The funny area is " << 
//                     area(square.height, box.width) << "\n";
// cout << "The bad area is " << 
//                     area(square.height, flag_pole.depth) << "\n";
}




// Result of execution
//
// The area of the box is 120
// The area of the square is 64
