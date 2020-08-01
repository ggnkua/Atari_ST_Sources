                                 // Chapter 6 - Program 5
#include <iostream.h>

class box {
   int length;
   int width;
   box *another_box;
public:
   box(void);             //Constructor
   void set(int new_length, int new_width);
   int get_area(void);
   void point_at_next(box *where_to_point);
   box *get_next(void);
};


box::box(void)        //Constructor implementation
{
   length = 8;
   width = 8;
   another_box = NULL;
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


// This method causes the pointer to point to the input parameter
void box::point_at_next(box *where_to_point)
{
   another_box = where_to_point;
}


// This method returns the box the current one points to
box *box::get_next(void)
{
   return another_box;
}


main()
{
box small, medium, large;          //Three boxes to work with
box *box_pointer;                      //A pointer to a box

   small.set(5, 7);
   large.set(15, 20);
   
   cout << "The small box area is " << small.get_area() << "\n";
   cout << "The medium box area is " << medium.get_area() << "\n";
   cout << "The large box area is " << large.get_area() << "\n";

   small.point_at_next(&medium);
   medium.point_at_next(&large);

   box_pointer = &small;
   box_pointer = box_pointer->get_next();
   cout << "The box pointed to has area " << 
                                  box_pointer->get_area() << "\n";
}




// Result of execution
//
// The small box area is 35
// The medium box area is 64
// The large box area is 300
// The box pointed to has area 64
