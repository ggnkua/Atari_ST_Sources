double d3;
fun()
{
  double d1, d2, fun1();
  
  d1 = 4.0;
  d2 = d1;
  d3 = d2;
  d2 = d3;
  d3 = fun1() * d2;
  return (d3);
}
