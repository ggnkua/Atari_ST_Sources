main()
{
  double d = 2.0;
  int i;

  for (i=0; i<20; i++) {
    d += 2.0;
    printf("i=%d, %lx,%lx,  %.9f,   %.9g\n", i, d, d, d);
  }
  d = 2.0;
  printf("%lx,%lx\n", d);
  printf("%lx,%lx\n", *(long *) &d, *(((long *) &d)+1));
}
