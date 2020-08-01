                                 // Chapter 6 - Program 2
#include <iostream.h>

class box {
   int length;
   int width;
   char *line_of_text;
public:
   box(char *input_line);             //Constructor
   void set(int new_length, int new_width);
   int get_area(void);
};


box::box(char *input_line)        //Constructor implementation
{
   length = 8;
   width = 8;
   line_of_text = input_line;
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
   cout << line_of_text << "= ";
   return (length * width);
}


main()
{
box small("small box "),           //Three boxes to work with
    medium("medium box "),
    large("large box ");

   small.set(5, 7);
   large.set(15, 20);
   
   cout << "The area of the ";
   cout << small.get_area() << "\n";
   cout << "The area of the ";
   cout << medium.get_area() << "\n";
   cout << "The area of the ";
   cout << large.get_area() << "\n";
   
}




// Result of execution
//
// The area of the small box = 35
// The area is the medium box = 64
// The area is the large box = 300
