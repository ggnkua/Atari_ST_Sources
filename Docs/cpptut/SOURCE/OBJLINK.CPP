                                 // Chapter 6 - Program 6
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


// This method returns the box that this one points to
box *box::get_next(void)
{
   return another_box;
}


main()
{
box *start = NULL;    // Always points to the start of the list
box *temp;            // Working pointer
box *box_pointer;     // Used for box creation

                                           // Generate the list
   for (int index = 0 ; index < 10 ; index++ ) {
      box_pointer = new box;
      box_pointer->set(index + 1, index + 3);
      if (start == NULL)
         start = box_pointer;              // First element in list
      else
         temp->point_at_next(box_pointer); // Additional element
      temp = box_pointer;
   }

                                           // Print the list out
   temp = start;
   do {
      cout << "The area is " << temp->get_area() << "\n";
      temp = temp->get_next();
   } while (temp != NULL);

                                           // Delete the list
   temp = start;
   do {
      temp = temp->get_next();
      delete start;
      start = temp;
   } while (temp != NULL);
}




// Result of execution
//
// The area is 3
// The area is 8
// The area is 15
// The area is 24
// The area is 35
// The area is 48
// The area is 63
// The area is 80
// The area is 99
// The area is 120

