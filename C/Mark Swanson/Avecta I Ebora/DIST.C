
extern int dist(x1,y1,h1,x2,y2,h2)
int x1,y1,h1,x2,y2,h2;
{
int min,max,range,x = abs(x1-x2),y = abs(y1-y2);
min = (x < y ? x : y );
max = (x > y ? x : y );
if(max != 0)
  range = max + ((min*min)/(2*max));
else
  range = 0;
return(range);
}
