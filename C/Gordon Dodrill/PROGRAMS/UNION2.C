#define AUTO 1
#define BOAT 2
#define PLANE 3
#define SHIP 4

main()
{
struct automobile {  /* structure for an automobile         */
   int tires;
   int fenders;
   int doors;
};

typedef struct {     /* structure for a boat or ship        */
   int displacement;
   char length;
} BOATDEF;

struct {
   char vehicle;         /* what type of vehicle?           */
   int weight;           /* gross weight of vehicle         */
   union {               /* type-dependent data             */
      struct automobile car;      /* part 1 of the union    */
      BOATDEF boat;               /* part 2 of the union    */
      struct {
         char engines;
         int wingspan;
      } airplane;                 /* part 3 of the union    */
      BOATDEF ship;               /* part 4 of the union    */
   } vehicle_type;
   int value;            /* value of vehicle in dollars     */
   char owner[32];       /* owners name                     */
} ford, sun_fish, piper_cub;   /* three variable structures */   

       /* define a few of the fields as an illustration     */

   ford.vehicle = AUTO;
   ford.weight = 2742;              /* with a full gas tank */
   ford.vehicle_type.car.tires = 5;  /* including the spare */
   ford.vehicle_type.car.doors = 2;

   sun_fish.value = 3742;           /* trailer not included */
   sun_fish.vehicle_type.boat.length = 20;

   piper_cub.vehicle = PLANE;
   piper_cub.vehicle_type.airplane.wingspan = 27;

   if (ford.vehicle == AUTO) /* which it is in this case */
      printf("The ford has %d tires.\n",ford.vehicle_type.car.tires);

   if (piper_cub.vehicle == AUTO) /* which it is not in this case */
      printf("The plane has %d tires.\n",piper_cub.vehicle_type.
             car.tires);
}