					   // Chapter 1 - Program 4
#include <iostream.h>
#include <fstream.h>
#include <process.h>

void main()
{
ifstream infile;
ofstream outfile;
ofstream printer;
char filename[20];

   cout << "Enter the desired file to copy ----> ";

   cin >> filename;

   infile.open(filename, ios::nocreate);
   if (!infile) {
      cout << "Input file cannot be opened.\n";
      exit(1);
   }

   outfile.open("copy");
   if (!outfile) {
      cout << "Output file cannot be opened.\n";
      exit(1);
   }

   printer.open("PRN");
   if (!printer) {
      cout << "There is a problem with the printer.\n";
      exit(1);
   }

   cout << "All three files have been opened.\n";

char one_char;

   printer << "This is the beginning of the printed copy.\n\n";

   while (infile.get(one_char)) {
      outfile.put(one_char);
      printer.put(one_char);
   }

   printer << "\n\nThis is the end of the printed copy.\n";

   infile.close();
   outfile.close();
   printer.close();

}



// Result of execution
//
// (The input file is copied to the file named "COPY")
// (The input file is printed on the printer
