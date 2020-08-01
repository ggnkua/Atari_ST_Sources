                                 // Chapter 6 - Program 3
#include <iostream.h>

class box {
   int length;
   int width;
   int *point;
public:
   box(void);         //Constructor
   void set(int new_length, int new_width, int stored_value);
   int get_area(void) {return length * width;}  // Inline
   int get_value(void) {return *point;}         // Inline
   ~box();            //Destructor
};


box::box(void)        //Constructor implementation
{
   length = 8;
   width = 8;
   point = new int;
   *point = 112;
}


// This method will set a box size to the input parameters
void box::set(int new_length, int new_width, int stored_value)
{
   length = new_length;
   width = new_width;
   *point = stored_value;
}


box::~box(void)       //Destructor
{
   length = 0;
   width = 0;
   delete point;
}


main()
{
box small, medium, large;          //Three boxes to work with

   small.set(5, 7, 177);
   large.set(15, 20, 999);
   
   cout << "The small box area is " << small.get_area() << "\n";
   cout << "The medium box area is " << medium.get_area() << "\n";
   cout << "The large box area is " << large.get_area() << "\n";
   cout << "The small box stored value is " << 
                                          small.get_value() << "\n";
   cout << "The medium box stored value is " << 
                                          medium.get_value() << "\n";
   cout << "The large box stored value is " << 
                                          large.get_value() << "\n";
}




// Result of execution
//
// The small box area is 35
// The medium box area is 64
// The large box area is 300
// The small box stored value is 177
// The medium box stored value is 112
// The large box stored value is 999

