                                 // Chapter 5 - Program 7

class box {
   int length;
   int width;
public:
   box(void);         //Constructor
   void set(int new_length, int new_width);
   int get_area(void) {return (length * width);}
   ~box(void);        //Destructor
};




// Result of execution
//
// This header file cannot be compiled or executed
