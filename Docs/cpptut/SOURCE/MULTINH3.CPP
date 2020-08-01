                                 // Chapter 9 - Program 3
#include <iostream.h>

class moving_van {
protected:
   float payload;
   float weight;
   float mpg;
public:
   void initialize(float pl, float gw, float in_mpg) {
	    payload = pl;
	    weight = gw;
	    mpg = in_mpg; };
   float efficiency(void) {
	    return(payload / (payload + weight)); };
   float cost_per_ton(float fuel_cost) {
	    return(fuel_cost / (payload / 2000.0)); };
};


class driver {
protected:
   float hourly_pay;
   float weight;
public:
   void initialize(float pay, float in_weight) {
	     hourly_pay = pay;
	     weight = in_weight; };
   float cost_per_mile(void) {return(hourly_pay / 55.0); } ;
   float drivers_weight(void) {return(weight); };
};


class driven_truck : public moving_van, public driver {
public:
   void initialize_all(float pl, float gw, float in_mpg, float pay)
	    { payload = pl;
	      moving_van::weight = gw;
	      mpg = in_mpg;
	      hourly_pay = pay; };
   float cost_per_full_day(float cost_of_gas) {
	      return(8.0 * hourly_pay +
				8.0 * cost_of_gas * 55.0 / mpg); };
   float total_weight(void) {
	      return(moving_van::weight + driver::weight); };
};


main()
{
driven_truck chuck_ford;

   chuck_ford.initialize_all(20000.0, 12000.0, 5.2, 12.50);
   chuck_ford.driver::initialize(15.50, 250.0);

   cout << "The efficiency of the Ford is " <<
	       chuck_ford.efficiency() << "\n";

   cout << "The cost per mile for Chuck to drive is " <<
	       chuck_ford.cost_per_mile() << "\n";

   cout << "The cost of Chuck driving the Ford for a day is " <<
	       chuck_ford.cost_per_full_day(1.129) << "\n";

   cout << "The total weight is " << chuck_ford.total_weight() <<
	       "\n";
}




// Result of execution
//
// The efficiency of the Ford is .625
// The cost per mile for Chuck to drive is 0.227273
// The cost of Chuck driving the Ford for a day is 195.530762
// The total weight is 12250
