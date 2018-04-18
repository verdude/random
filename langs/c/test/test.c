#include <stdio.h>
#include <math.h>

int main() {
/*	printf("%lu\n", sizeof(char));

	printf("%lu\n", sizeof(int));
	printf("%lu\n", sizeof(float));

	printf("%lu\n", sizeof(double));
	printf("%lu\n", sizeof(long));

	printf("%lu\n", sizeof(long double));*/

	int i = 83;
    i &= (i - 1);
	printf("%i\n", i);
	return 0;
}
