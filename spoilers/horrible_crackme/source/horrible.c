/*
 *  Compile with sccz80
 *  zcc +cpm -O3 horrible.c -o horrible.bin -create-app
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <cpm.h>

// flag: DISOBEY[compilers, eh?]

main() {
	char password[32];
	char key[] = {0xC9, 0xF3, 0xEF, 0xE7, 0xCD, 0xCB, 0x93, 0x9F, 0x8F, 0xA7, 0xBB, 0xA1, 0xB3, 0xB9, 0x8B, 0xAD, 0xAF, 0x39, 0x01, 0x8B, 0xB1, 0xC7, 0x9B};
	char xor = 0x76;
	char add = -25 + sizeof(key) -1;
	char zero = 0;

	for (char i = 0; i < sizeof(password); i++) {
		password[i] = 0;
	}

	printf("Enter password:\n");

	char l = 0;

	while (1) {
		char in = getk();
		if (in == 0) {
			xor = 0x55;
			continue;
		}
		if (in == '\r') {
			break;
		}
		password[l] = in;
		l++;
		if (l == sizeof(password)) {
			printf("Error - trying too hard!\n");
			return 1;
		}
	}

	add += l;

	if (l != sizeof(key)) {
		printf("Error - not trying the right amount of hard\n");
		return 1;
	}

	printf("\n");
	char ok = 1;

	for (char i = 0; i < l; i++) {
		char p = (password[i] << 1) + add;
		char k = key[i];

		if ((k & 0xff) != ((p ^ xor) & 0xFF)) {
			// printf("\nErr: i = %d key %2X != input %2X\n", i, key[i] & 0xFF, ((p ^ xor) & 0xFF));
			ok = zero;
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

