#include <stdio.h>
#include <math.h>

//void conversion_test(double);

void conversion_test(double n) {
	printf("n is %lu bytes long\n", sizeof(n));
	printf("Printing value of n: %f\n", n);
}

int main() {
/*	printf("%lu\n", sizeof(char));

	printf("%lu\n", sizeof(int));
	printf("%lu\n", sizeof(float));

	printf("%lu\n", sizeof(double));
	printf("%lu\n", sizeof(long));

	printf("%lu\n", sizeof(long double));*/

	int i = 2;
	double x = sqrt((double)i);
	printf("%f\n", x);
	return 0;
}