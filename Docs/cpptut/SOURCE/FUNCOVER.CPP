                                 // Chapter 6 - Program 9
#include <iostream.h>

class many_names {
   int length;
   int width;
public:
   many_names(void);             // Constructors
   many_names(int len);
   many_names(int len, int wid);
   void display(void);           // Display functions
   void display(int one);
   void display(int one, int two);
   void display(float number);
};



many_names::many_names(void)
{
   length = 8;
   width = 8;
}



many_names::many_names(int len)
{
   length = len;
   width = 8;
}



many_names::many_names(int len, int wid)
{
   length = len;
   width = wid;
}



void many_names::display(void)
{
   cout << "From void display function, area = " << 
                                          length * width << "\n";
}



void many_names::display(int one)
{
   cout << "From int display function, area = " << 
                                         length * width << "\n";
}



void many_names::display(int one, int two)
{
   cout << "From two int display function, area = " << 
                                          length * width << "\n";
}



void many_names::display(float number)
{
   cout << "From float display function, area = " << 
                                          length * width << "\n";
}



main()
{
many_names small, medium(10), large(12, 15);
int gross = 144;
float pi = 3.1415, payroll = 12.50;

   small.display();
   small.display(100);
   small.display(gross,100);
   small.display(payroll);

   medium.display();
   large.display(pi);
}




// Result of execution
//
// From void display function, area = 64
// From int display function, area = 64
// From two int display function, area = 64
// From float display function, area = 64
// From void display function, area = 80
// From float display function, area = 180
