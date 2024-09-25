#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define BSIZE 1024


int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: <filename>\n");
        exit(-1);
    }
    unsigned int log2size, size;
    unsigned int *vec;
    FILE *f = fopen(argv[1], "r");
    fscanf(f, "%d\n", &log2size);
    if (log2size > 10) {
        printf("Size (%u) is too large: size is limited to 2^10\n", log2size);
        exit(-1);
    }
    size = 1 << log2size;
    unsigned int bytes = size * sizeof(unsigned int);
    vec = (unsigned int *) malloc(bytes);
    assert(vec);
    for (unsigned int i = 0; i < size; i++) {
        fscanf(f, "%u\n", &(vec[i]));
    }
    fclose(f);
}
