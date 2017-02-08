#include<cuda.h>
#include <iostream>

void myVecAdd(float* A, float* B, float* C, int n){
	for(int i = 0; i < n; i++){
		C[i] = A[i] + B[i];
	}

}

int main(){
	int n = 2;
	float A[2] = {1,2};
	float B[2] = {4,5};
	float C[n];
	myVecAdd(A,B,C,n);
	std::cout<<"hola "<<C[0];

	return 0;
}
