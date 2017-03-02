//Defines the CUDA API functions and built-in variables
#include<cuda.h>

#include <iostream>


void myVecAddSec(float* A, float* B, float* C, int n){
	for(int i = 0; i < n; i++){
		C[i] = A[i] + B[i];
	}

}

// Compute vector sum C = A+B
// Each thread performs one pair-wise addition
//Executed on the device, and only callable from the host
__global__
void vecAddKernel(float* A, float* B, float* C, int n){
	//threadIdx.x, blockDim.x, blockIdx.x are hardware registers. could be ignore this line?
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	if(i<n) C[i] = A[i] + B[i];
}

void vecAdd(float* A, float*B, float* C, int n){
	int size = n* sizeof(float);
	float *d_A, *d_B, *d_C;

	/*
	Part 1:
	 Allocate device memory for A, B, and C
	 copy A and B to device 	memory

	– Allocates object in the device global memory
	– Two parameters
	• Address of a pointer to the allocated object
	• Size of allocated object in terms of bytes
	*/
	cudaMalloc((void ** )&d_A, size);
	cudaMalloc((void **)&d_B,size);
	cudaMalloc((void **)&d_C,size);
	/*
	cudaMemcpy()
	– memory data transfer
	– Requires four parameters
	• Pointer to destination
	• Pointer to source
	• Number of bytes copied
	• Type/Direction of transfer
	*/
	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);



	/*
	Part 2:
	 Kernel launch code – to have the device
	 to perform the actual vector addition
	The first configuration parameter gives the number of thread blocks in the grid.
	The second specifies the number of threads in each thread block.
	*/
	vecAddKernel<<<ceil(n/256.0), 256>>> (d_A, d_B, d_C, n);

	//Part 3:
	// copy C from the device memory (Global Memory)
	// Free device vectors
	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
	//free the storage space for the vector from the device global memory
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
}



int main(){
	int n = 700000;
	float A[700000];// = {1,2};
	float B[700000];// = {4,5};
	float C[n];

	for(int i = 0; i < n; ++i)
	{
	  A[i] = rand() % 80 + 1;
	  B[i] = rand() % 80 + 1;
	}
	long startTime = (unsigned long)time(NULL);

	//Sequential
	//myVecAddSec(A,B,C,n);
	//CUDA
	vecAdd(A,B,C,n);
	long finishTime = (unsigned long)time(NULL);

	std::cout<<"Sum between "<<A[51]<<" and "<<B[51]<<" : "<<C[51]<<"\n";
	std::cout<<"computing time: "<<finishTime-startTime;
	return 0;
}
