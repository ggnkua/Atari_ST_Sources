                                 // Chapter 6 - Program 4
#include <iostream.h>

class box {
   int length;
   int width;
public:
   box(void);             //Constructor
   void set(int new_length, int new_width);
   int get_area(void);
};


box::box(void)        //Constructor implementation
{
   length = 8;
   width = 8;
}


// This method will set a box size to the two input parameters
void box::set(int new_length, int new_width)
{
   length = new_length;
   width = new_width;
}


// This method will calculate and return the area of a box instance
int box::get_area(void)
{
   return (length * width);
}


main()
{
box small, medium, large;          //Three boxes to work with
box *point;                        //A pointer to a box

   small.set(5, 7);
   large.set(15, 20);

   point = new box;   // Use the defaults supplied by the constructor

   cout << "The small box area is " << small.get_area() << "\n";
   cout << "The medium box area is " << medium.get_area() << "\n";
   cout << "The large box area is " << large.get_area() << "\n";

   cout << "The new box area is " << point->get_area() << "\n";
   point->set(12, 12);
   cout << "The new box area is " << point->get_area() << "\n";

   delete point;
}




// Result of execution
//
// The small box area is 35
// The medium box area is 64
// The large box area is 300
// The new box area is 64
// The new box area is 144
