/*
 *  Compile with sccz80
 *  zcc +cpm -O3 simple.c -o simple.bin -create-app
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <cpm.h>

// flag: DISOBEY[CP/M hacking]


unsigned password[32];
unsigned key[] = {0xF0, 0xFE, 0x92, 0x8A, 0xEC, 0xF6, 0x9E, 0xA2, 0xF2, 0x88, 0xCA, 0x86, 0x28, 0xB8, 0xAE, 0xB2, 0x142, 0xBE, 0x144, 0xBA, 0xA6};
unsigned in;
int ok = 1;
int l = 0;
unsigned p;
unsigned k;
unsigned i;

int main() {
	for (i = 0; i < 32; i++) {
		password[i] = 0;
	}

	printf("Enter password:\n");

	while (1) {
		in = getk();
		if (in == 0) {
			continue;
		}
		if (in == '\r') {
			break;
		}
		password[l] = in;
		l++;
		if (l == 32) {
			printf("Error - trying too hard!\n");
			return 1;
		}
	}

	if (l != 21) {
		printf("Error - not trying the right amount of hard\n");
		return 1;
	}

	printf("\n");
	for (i = 0; i < l; i++) {
		p = password[i];
		p = p << 1;
		p = p + 42;
		p = p ^ 0x42;
		k = key[i];

		if (k  != p  ) {
			// printf("\nErr: i = %d key %2X != input %2X\n", i, key[i], p);
			ok = 0;
		};
		// printf("0x%2X, ", key[i] & 0xFF);
	}

	if (ok == 1) {
		printf("Correct!\n");
		return 0;
	} else {
		printf("Error - try harder\n");
		return 1;
	}
	// printf("\n");

	return 0;
}

