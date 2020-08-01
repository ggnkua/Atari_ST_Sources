                                 // Chapter 6 - Program 1
#include <iostream.h>

class box {
   int length;
   int width;
   static int extra_data;   // Declaration of extra_data
public:
   box(void);             //Constructor
   void set(int new_length, int new_width);
   int get_area(void);
   int get_extra(void) {return extra_data++;}
};


int box::extra_data;        // Definition of extra_data


box::box(void)        //Constructor implementation
{
   length = 8;
   width = 8;
   extra_data = 1;
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
box small, medium, large, group[4];        //Seven boxes to work with

   small.set(5, 7);
   large.set(15, 20);
   
   for (int index = 1 ; index < 4 ; index++)  //group[0] uses default
      group[index].set(index + 10, 10);

   cout << "The small box area is " << small.get_area() << "\n";
   cout << "The medium box area is " << medium.get_area() << "\n";
   cout << "The large box area is " << large.get_area() << "\n";

   for (index = 0 ; index < 4 ; index++)
      cout << "The array box area is " << 
                                     group[index].get_area() << "\n";

   cout << "The extra data value is " << small.get_extra() << "\n";
   cout << "The extra data value is " << medium.get_extra() << "\n";
   cout << "The extra data value is " << large.get_extra() << "\n";
   cout << "The extra data value is " << group[0].get_extra() << "\n";
   cout << "The extra data value is " << group[3].get_extra() << "\n";
}




// Result of execution
//
// The small box area is 35
// The medium box area is 64
// The large box area is 300
// The array box area is 64
// The array box area is 110
// The array box area is 120
// The array box area is 130
// The extra data value is 1
// The extra data value is 2
// The extra data value is 3
// The extra data value is 4
// The extra data value is 5
