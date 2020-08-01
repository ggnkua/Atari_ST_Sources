                                 // Chapter 5 - Program 6
#include <iostream.h>

class box {
   int length;
   int width;
public:
   box(void);         //Constructor
   void set(int new_length, int new_width);
   int get_area(void) {return (length * width);}
   ~box(void);        //Destructor
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


box::~box(void)       //Destructor
{
   length = 0;
   width = 0;
}


main()
{
box small, medium, large;          //Three boxes to work with

   small.set(5, 7);
                          // Note that the medium box uses the values
                          // supplied by the constructor
   large.set(15, 20);
   
   cout << "The small box area is " << small.get_area() << "\n";
   cout << "The medium box area is " << medium.get_area() << "\n";
   cout << "The large box area is " << large.get_area() << "\n";
   
}




// Result of execution
//
// The small box area is 35
// The medium box area is 64
// The large box area is 300
