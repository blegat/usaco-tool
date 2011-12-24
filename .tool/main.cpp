/*
ID: <USER>
PROG: <PROGNAME>
LANG: C++
*/

#include <stdio.h>
#include <assert.h>

int main (void) {
	FILE *fin = fopen("<PROGNAME>.in", "r");
	FILE *fout = fopen("<PROGNAME>.out", "w");
	assert(fin != NULL && fout != NULL);

	fclose(fin);
	fclose(fout);
	return 0;
}
