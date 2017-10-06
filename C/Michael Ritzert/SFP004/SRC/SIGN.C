double sign (x, y)
double x;
double y;
{
    if (x > 0.0) {
	if (y > 0.0) {
	    return(x);
	} else {
	    return(-x);
	}
    } else {
	if (y < 0.0) {
	    return(x);
	} else {
	    return(-x);
	}
    }
}
