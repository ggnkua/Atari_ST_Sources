                                  // Chapter 9 - Program 2
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
   float cost_per_full_day(float cost_of_gas) {
	    return(8.0 * cost_of_gas * 55.0 / mpg); };
};


class driver {
protected:
   float hourly_pay;
public:
   void initialize(float pay) {hourly_pay = pay; };
   float cost_per_mile(void) {return(hourly_pay / 55.0); } ;
   float cost_per_full_day(float overtime_premium) {
	    return(8.0 * hourly_pay); };
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

   cout << "The cost per day for the Ford is " <<
	       chuck_ford.moving_van::cost_per_full_day(1.129) <<
	       "\n";

   cout << "The cost of Chuck for a full day is " <<
	       chuck_ford.driver::cost_per_full_day(15.75) <<
	       "\n";

   cout << "The cost of Chuck driving the Ford for a day is " <<
	       chuck_ford.driven_truck::cost_per_full_day(1.129) <<
	       "\n";
}




// Result of execution
//
// The efficiency of the Ford is .625
// The cost per mile for Chuck to drive is 0.227273
// The cost per day for the Ford is 95.530769
// The cost of Chuck for a full day is 100.0
// The cost of Chuck driving the Ford for a day is 195.530762
