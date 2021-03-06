
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "Vector.h"
#include "Timing.h"


void mapmap(long lens, long* uvec, long* out1, long* out2)
{
	for (long i = 0; i != lens; ++i) {
		long x = uvec[i] * 2;
		long y = x + 50;
		long z = x - 50;
		out1[i] = y;
		out2[i] = y;
	}
}

int main(int argc, char** argv)
{
	// Parse cmd line args.
	int	pointCount	= 0;

	if(argc == 2) {
		pointCount	= atoi(argv[1]);
	}
	else {
		printf("usage: quickhull <points>\n");
		exit(1);
	}

	long* uvec		= malloc(pointCount * sizeof(long));

	long* out1		= malloc(pointCount * sizeof(long));
	long* out2		= malloc(pointCount * sizeof(long));

	for (int i = 0; i < pointCount; i++) {
		uvec[i] = i;
	}

	// Timing setup
        struct timeval start, finish;
        struct rusage start_ru, finish_ru;

        gettimeofday( &start, NULL );
        getrusage( RUSAGE_SELF, &start_ru );

	// Do the deed.
	mapmap(pointCount, uvec, out1, out2);

	// Print how long it took.
        gettimeofday( &finish, NULL );
        getrusage( RUSAGE_SELF, &finish_ru );

//	printf("depth          = %d\n", depth);
//	printf("points on hull = %d\n", hull->length);

        sub_timeval( &finish, &start );
        sub_timeval( &finish_ru.ru_utime, &start_ru.ru_utime );
        sub_timeval( &finish_ru.ru_stime, &start_ru.ru_stime );
        add_timeval( &finish_ru.ru_utime, &finish_ru.ru_stime );

	printf("elapsedTimeMS   = ");
        print_timeval( &finish ); putchar( '\n' );

 	printf("cpuTimeMS       = ");
        print_timeval( &finish_ru.ru_utime); putchar( '\n' );
}

