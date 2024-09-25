#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define BSIZE 1024

__global__
void kernel(uint* dvec, uint size, uint* dres)
{
    uint x = threadIdx.x;
    if (x<size)
    {
        *dres += dvec[x];
        printf("%u\n", dvec[x]);
    }
    __syncthreads();
}

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
    size = 1 << log2size; // taille du tab
    unsigned int bytes = size * sizeof(unsigned int); // taille des élém du tableau
    vec = (unsigned int *) malloc(bytes); // notre vecteur d'éléments
    assert(vec);
    for (unsigned int i = 0; i < size; i++) {
        fscanf(f, "%u\n", &(vec[i])); // ajout des élem dans vec
    }
    fclose(f);

    uint* dres; // res de la somme on device
    uint res;
    uint* dvec;

    cudaError_t err = cudaMalloc((void**)&dvec,bytes); //reserve la taille du tab dans la mémoire 
    if (err != cudaSuccess){
        printf("%s in %s at line %d\n",
        cudaGetErrorString(err), __FILE__, __LINE__);
        exit(EXIT_FAILURE);
    }

    cudaMemcpy(dvec, vec, bytes, cudaMemcpyHostToDevice);
    // dst, src, byte, kind of copy

    err = cudaMalloc((void**)&dres, sizeof(int)); // alloc taille res
    if (err != cudaSuccess){
        printf("%s in %s at line %d\n",
        cudaGetErrorString(err), __FILE__, __LINE__);
        exit(EXIT_FAILURE);
    }

    kernel<<<1, BSIZE>>>(dvec, size, dres);

    cudaMemcpy(&res, dres, sizeof(int), cudaMemcpyDeviceToHost);
    // dst, src, byte, kind of copy

    // Objectif : obtenir 34 avec file1
    printf("Somme = %u", res);

    cudaFree(dvec);
    cudaFree(dres);
}
