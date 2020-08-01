                                       // Chapter 6 - Program 7
#include <iostream.h>

class mail_info {
   int shipper;
   int postage;
public:
   void set(int in_class, int in_postage)
           {shipper = in_class; postage = in_postage; }
   int get_postage(void) {return postage;}
};

class box {
   int length;
   int width;
   mail_info label;
public:
   void set(int l, int w, int s, int p) {
         length = l; 
         width = w;
         label.set(s, p); }
   int get_area(void) {return length * width;}
};


main()
{
box small, medium, large;

   small.set(2, 4, 1, 35);
   medium.set(5, 6, 2, 72);
   large.set(8, 10, 4, 98);

   cout << "The area is " << small.get_area() << "\n";
   cout << "The area is " << medium.get_area() << "\n";
   cout << "The area is " << large.get_area() << "\n";
}




// Result of Execution
//
// The area is 8
// The area is 30
// The area is 80
