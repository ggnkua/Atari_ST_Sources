                                   // Chapter 9 - Program 1
#include <iostream.h>

class moving_van {
protected:
   float payload;
   float gross_weight;
   float mpg;
public:
   void initialize(float pl, float gw, float in_mpg) {
	    payload = pl;
	    gross_weight = gw;
	    mpg = in_mpg; };
   float efficiency(void) {
	    return(payload / (payload + gross_weight)); };
   float cost_per_ton(float fuel_cost) {
	    return(fuel_cost / (payload / 2000.0)); };
};


class driver {
protected:
   float hourly_pay;
public:
   void initialize(float pay) {hourly_pay = pay; };
   float cost_per_mile(void) {return(hourly_pay / 55.0); } ;
};


class driven_truck : public moving_van, public driver {
public:
   void initialize_all(float pl, float gw, float in_mpg, float pay)
	    { payload = pl;
	      gross_weight = gw;
	      mpg = in_mpg;
	      hourly_pay = pay; };
   float cost_per_full_day(float cost_of_gas) {
	      return(8.0 * hourly_pay +
				8.0 * cost_of_gas * 55.0 / mpg); };
};


main()
{
driven_truck chuck_ford;

   chuck_ford.initialize_all(20000.0, 12000.0, 5.2, 12.50);

   cout << "The efficiency of the Ford is " <<
	       chuck_ford.efficiency() << "\n";

   cout << "The cost per mile for Chuck to drive is " <<
	       chuck_ford.cost_per_mile() << "\n";

   cout << "The cost of Chuck driving the Ford for a day is " <<
	       chuck_ford.cost_per_full_day(1.129) << "\n";
}




// Result of execution
//
// The efficiency of the Ford is .625
// The cost per mile for Chuck to drive is 0.227273
// The cost of Chuck driving the Ford for a day is 195.530762
