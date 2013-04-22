//#include <iostream>
//#include <fstream>
//#include <vector>
//#include <common/book.h>
//#include <limits.h>
//#include <fstream>
//#include <time.h>
//
//
//#define MAX 25000000
//
//using namespace std;
//
//__global__ void minimum(int *elements, int sz) {
//	__shared__ int tmp[4096];
//	int idx_x = threadIdx.x + blockIdx.x * blockDim.x;
//	int idx_y = threadIdx.y+blockIdx.y*blockDim.y;
//	int idx = idx_x+idx_y*blockDim.x*gridDim.x;
//	int local_index = threadIdx.x;
//	int row_idx = blockIdx.x * blockDim.x;
//
//	tmp[local_index] = elements[idx];
//
//	__syncthreads();
//
//	int size = (blockDim.x) / 2;
//	if (idx < sz)
//		while (size) {
//			if (local_index < size) {
//				if (tmp[local_index + size] <= tmp[local_index]) {
//					tmp[local_index] = tmp[local_index + size];
//				}
//			}
//			size /= 2;
//			__syncthreads();
//		}
//
//	if (local_index == 0) {
//		elements[row_idx] = tmp[0];
//	}
//
//}
//
//__global__ void minimum_with_index(int *elements, int *indexes, int sz) {
//	__shared__ int elements_shared[2048];
//	__shared__ int indexes_shared[2048];
//	int idx_x = threadIdx.x + blockIdx.x * blockDim.x;
//	int idx_y = threadIdx.y+blockIdx.y*blockDim.y;
//	int idx = idx_x+idx_y*blockDim.x*gridDim.x;
//	int local_index = threadIdx.x;
//	int row_idx = blockIdx.x * blockDim.x;
//
//	elements_shared[local_index] = elements[idx];
//	indexes_shared[local_index] = idx;
//
//	__syncthreads();
//
//	int size = (blockDim.x) / 2;
//	if (idx < sz)
//		while (size) {
//			if (local_index < size) {
//				if (elements_shared[local_index + size]
//						<= elements_shared[local_index]) {
//					elements_shared[local_index] = elements_shared[local_index
//							+ size];
//					indexes_shared[local_index] = indexes_shared[local_index
//							+ size];
//				}
//			}
//			size /= 2;
//			__syncthreads();
//		}
//
//	if (local_index == 0) {
//		elements[row_idx] = elements_shared[0];
//		indexes[row_idx] = indexes_shared[0];
//	}
//
//}
//
//__global__ void minimum_with_index_N(int *elements, int *indexes, int sz) {
//	__shared__ int elements_shared[2048];
//	__shared__ int indexes_shared[2048];
//	int idx_x = threadIdx.x + blockIdx.x * blockDim.x;
//	int idx_y = threadIdx.y+blockIdx.y*blockDim.y;
//	int idx = idx_x+idx_y*blockDim.x*gridDim.x;
//	int local_index = threadIdx.x;
//	int row_idx = blockIdx.x * blockDim.x;
//
//	elements_shared[local_index] = elements[idx];
//	indexes_shared[local_index] = idx;
//
//	__syncthreads();
//
//	int size = (blockDim.x) / 2;
//	if (idx < sz)
//		while (size) {
//			if (local_index < size) {
//				if (elements_shared[local_index + size]
//						<= elements_shared[local_index]) {
//					elements_shared[local_index] = elements_shared[local_index
//							+ size];
//					indexes_shared[local_index] = indexes_shared[local_index
//							+ size];
//				}
//			}
//			size /= 2;
//			__syncthreads();
//		}
//
//	if (local_index == 0) {
//		elements[row_idx] = elements_shared[0];
//		indexes[blockIdx.x] = indexes_shared[0];
//	}
//
//}
//
//int main() {
//	ofstream fout("out.txt");
//	cudaDeviceProp deviceProp;
//	cudaGetDeviceProperties(&deviceProp, 0);
//	cout<<deviceProp.name<<" has compute capability "<<deviceProp.major<<","<< deviceProp.minor<<endl<<"Shared Memory available: "<<deviceProp.sharedMemPerBlock<<endl;
//	int size = MAX;
//
//	int *elements_host = new int[size * size];
//	int *elements_device;
//	cudaMalloc(&elements_device, size * size * sizeof(int));
//
//	int *indexes_host = new int[size * size];
//	int *indexes_device;
//	cudaMalloc(&indexes_device, size * size * sizeof(int));
//
//	for (int i = 0; i < 2000; i++) {
//		elements_host[i] = INT_MAX;
//		indexes_host[i] = i; //for fun
//
//	}
//
//	float time;
//	int time_total = 0;
//
//	cudaEvent_t start, stop;
//	cudaEventCreate(&start);
//	cudaEventCreate(&stop);
//
//
//	cudaDeviceSynchronize();
//	dim3 blocks(size/512,size/512);
//	dim3 threads(512,512);
//	sleep(3);
//	size=0;
//	while (size <= MAX) {
//
//		fout<<size<<"\t";
//
//
//		cudaEventRecord(start, 0);
//		//GPU code
//		cudaMemcpy((void *) elements_device, elements_host,
//				size * size * sizeof(int), cudaMemcpyHostToDevice);
//		minimum<<<blocks, threads>>>(elements_device, size * size);
//		cudaMemcpy(elements_host, (void *) elements_device,
//				size * size * sizeof(int), cudaMemcpyDeviceToHost); // end of GPU code
//		cudaEventRecord(stop, 0);
//		cudaEventSynchronize(stop);
//		cudaEventElapsedTime(&time, start, stop);
//		cudaDeviceSynchronize();
//
//		fout << time<<"\t";
//		///////////////////////////////////////////////////////////////////////////
//		cudaEventRecord(start, 0);
//		//GPU code
//		cudaMemcpy((void *) elements_device, elements_host,
//				size * size * sizeof(int), cudaMemcpyHostToDevice);
//		minimum_with_index<<<blocks, threads>>>(elements_device, indexes_device,
//				size * size);
//		cudaMemcpy(elements_host, (void *) elements_device,
//				size * size * sizeof(int), cudaMemcpyDeviceToHost);
//		cudaMemcpy(indexes_host, (void *) indexes_device,
//				size * size * sizeof(int), cudaMemcpyDeviceToHost); // end of GPU code
//		cudaEventRecord(stop, 0);
//		cudaEventSynchronize(stop);
//		cudaEventElapsedTime(&time, start, stop);
//		cudaDeviceSynchronize();
//
//
//		fout << time<<"\t";
//		////////////////////////////////////////////////////////////////////////////
//		cudaEventRecord(start, 0);
//		//GPU code
//		cudaMemcpy((void *) elements_device, elements_host,
//				size * size * sizeof(int), cudaMemcpyHostToDevice);
//		minimum_with_index_N<<<blocks, threads>>>(elements_device, indexes_device,
//				size * size);
//		cudaMemcpy(elements_host, (void *) elements_device,
//				size * size * sizeof(int), cudaMemcpyDeviceToHost);
//		cudaMemcpy(indexes_host, (void *) indexes_device,
//				size * sizeof(int), cudaMemcpyDeviceToHost); // end of GPU code
//		cudaEventRecord(stop, 0);
//		cudaEventSynchronize(stop);
//		cudaEventElapsedTime(&time, start, stop);
//		time_total += time;
//		cudaDeviceSynchronize();
//
//
//		fout << time<<"\n";
//
//		size += 5000000;
//
//	}
//	return 0;
//}
#include <stdio.h>

const int N=10;

__global__ void add(int *a, int *b, int *c) {
    int tid = threadIdx.x;
    c[tid] = a[tid] + b[tid];
}


int main(){

int a[N], b[N], c[N];
    int *dev_a, *dev_b, *dev_c;

    cudaMalloc( (void**)&dev_a, N * sizeof(int) );
    cudaMalloc( (void**)&dev_b, N * sizeof(int) );
    cudaMalloc( (void**)&dev_c, N * sizeof(int) );

    for (int i=0; i<N; i++) {
        a[i] = -i; b[i] = i * i;
    }
    cudaMemcpy ( dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice );
    cudaMemcpy ( dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice );

    add<<<1,N>>>(dev_a, dev_b, dev_c);

    cudaMemcpy(c, dev_c, N * sizeof(int),cudaMemcpyDeviceToHost );

    for (int i=0; i<N; i++) {
        printf("%d + %d = %d\n", a[i],b[i],c[i]);
    }

    cudaFree (dev_a); cudaFree (dev_b); cudaFree (dev_c);

    return 0;

}
