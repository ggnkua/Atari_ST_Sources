                                       // Chapter 6 - Program 8
#include <iostream.h>

class box {
   int length;
   int width;
public:
   void set(int l, int w) {length = l; width = w;}
   int get_area(void) {return length * width;}
   friend box operator+(box a, box b);   // Add two boxes
   friend box operator+(int a, box b);   // Add a constant to a box
   friend box operator*(int a, box b);   // Multiply a box by a constant
};


box operator+(box a, box b)   // Add two boxes' widths together
{
box temp;
   temp.length = a.length;
   temp.width = a.width + b.width;
   return temp;
}


box operator+(int a, box b)   // Add a constant to a box
{
box temp;
   temp.length = b.length;
   temp.width = a + b.width;
   return temp;
}


box operator*(int a, box b)   // Multiply a box by a constant
{
box temp;
   temp.length = a * b.length;
   temp.width = a * b.width;
   return temp;
}


main()
{
box small, medium, large;
box temp;

   small.set(2, 4);
   medium.set(5, 6);
   large.set(8, 10);

   cout << "The area is " << small.get_area() << "\n";
   cout << "The area is " << medium.get_area() << "\n";
   cout << "The area is " << large.get_area() << "\n";

   temp = small + medium;
   cout << "The new area is " << temp.get_area() << "\n";
   temp = 10 + small;
   cout << "The new area is " << temp.get_area() << "\n";
   temp = 4 * large;
   cout << "The new area is " << temp.get_area() << "\n";
}




// Result of Execution
//
// The area is 8
// The area is 30
// The area is 80
// The new area is 20
// The new area is 28
// The new area is 1280
