#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define BSIZE 1024

__global__
void kernel(uint* dvec, uint size, uint* dres)
{


    uint x = threadIdx.x;
    if (x< size)
    {
        for (uint i = 1; i < size; i*=2)
        {
            if (x%2*i == 0)
            {
              printf("THREAD N° %u : Somme avant %u\n", x, *dres);
              printf("THREAD N° %u : Elem du vecteur : %u\n", x, dvec[x]);
              dvec[x]+=dvec [x+i];
            }
            __syncthreads(); //waiting for all the other threads to finish
        }       
    }
        printf("THREAD N° %u : Somme actuelle %u\n", x, *dres);
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

    uint* dres = 0; // res de la somme on device
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

    kernel<<<(size +1023 )/BSIZE, BSIZE>>>(dvec, size, dres);

    cudaMemcpy(&res, dres, sizeof(int), cudaMemcpyDeviceToHost);
    // dst, src, byte, kind of copy

    // Objectif : obtenir 34 avec file1
    printf("Somme = %u", res);

    cudaFree(dvec);
    cudaFree(dres);
}
