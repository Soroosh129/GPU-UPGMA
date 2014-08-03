#include <iostream>
#include <fstream>
#include <vector>
#include <stdlib.h>
//#include <common\book.h>

#define DIM 512
#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, char *file, int line, bool abort=true)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr,"\nGPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

using namespace std;

#define min(a,b) (a<b)?a:b


__global__ void kernel(float *index,int *min_holder)
{
	__shared__ float tmp[DIM];
	int idx = threadIdx.x+blockIdx.x*blockDim.x;
	int local_index = threadIdx.x;
	int row_idx = blockIdx.x;
	__shared__ int min_index[DIM];




	int size = DIM/2;

	tmp[local_index] = index[idx];
	min_index[local_index] = local_index;
	__syncthreads();
	while(size)
	{
		if(local_index<size)
		{
			if(tmp[local_index+size]<tmp[local_index])
			{
				tmp[local_index]= tmp[local_index+size];
				min_index[local_index] = min_index[local_index+size];
			}
		}
		size/=2;
		__syncthreads();
	}

	if(local_index==0)
	{
		min_holder[row_idx] = min_index[0];
	}

}


int main()
{
	char file_name[255];// = "in.txt";
	ofstream fout("out.txt");
	cout<<"Please enter the file path to the distance matrix: ";
	cin.getline(file_name,255);
	std::vector<char> buffer(64 * 1024 * 1024);
	fstream fin;
	fin.rdbuf()->pubsetbuf(&buffer[0],buffer.size());
	fin.open(file_name);
	//cudaDeviceProp deviceProp;
	//cudaGetDeviceProperties(&deviceProp, 0);
	//cout<<deviceProp.name<<" has compute capability "<<deviceProp.major<<","<< deviceProp.minor<<endl;
	int size = INT_MIN;

	int r=0,c=0;
	fin>>size;

	int pitch=ceil((double)size/DIM);
	float *indexs=new float[size*size];
	int *min_holder = new int[size*pitch];
	float *indexes_d;
	int *min_holder_d;
	cudaMalloc(&indexes_d,size*size*sizeof(float));
	cudaMalloc(&min_holder_d,(size*pitch)*sizeof(int));
	bool *mark = new bool[size+1];

	for(int i=0; i<2000; i++)
	{
		indexs[i]=INT_MAX;

	}

	for(int i=0; i<size+1; i++)
		mark[i]=true;
	r=c=0;
	char tmp[255];
	cout<<"Reading input file";
	fin>>tmp;
	//cout<<tmp;
	while(1)
	{
		/*fin>>r>>c;
		r--;
		c--;*/

		fin>>indexs[r*size+c];
		c++; //:D
		//cout<<".";
		if(c==size)
		{
			mark[r]=false;
			r++;
			c=0;
			//cout<<endl;
			if(r<size)
			{
				fin>>tmp;
			}
			else
				break;
		}
	}

	cout<<" ..."<<endl;
	//cout<<size<<endl;
	//size--;
	int index=0;
	int handler=size;


	float min;
	float time;
	float time_total=0;
	cout<<"Working ";
	dim3 blocks(size*pitch);
	dim3 threads(512);
	while(handler)
	{
		cout<<".";
		min= INT_MAX;
		cudaEvent_t start,stop;
		cudaEventCreate(&start);
		cudaEventCreate(&stop);
		cudaEventRecord(start,0);

		//GPU code
		cudaMemcpy(indexes_d,indexs,size*size*sizeof(float),cudaMemcpyHostToDevice);
		kernel<<<blocks,threads>>>(indexes_d,min_holder_d);
		gpuErrchk(cudaMemcpy(min_holder,min_holder_d,(size*pitch)*sizeof(int),cudaMemcpyDeviceToHost));// end of GPU code
		cudaEventRecord(stop,0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&time,start,stop);
		time_total+=time;
		if(time==0)
		{
			cout<<"\nSomething went wrong on GPU."<<endl;
			exit(0);
		}
		//cout<<"Time this round: "<<time<<endl;
		//for(int i=0; i<size*size ; i ++ )
		//cout<<i<<": "<<indexs[i]<<"  ";
		//cout<<endl;
		//getwchar();
		bool flag=false;
		int trow=-1;
		int row=0;
		int col=0;
		for(int k=0; k<size*pitch; k++)
		{
			if((k%(pitch))==0)
				trow++;
			int i = trow*size + min_holder[k];
			if(indexs[i]<min)
			{
				min=indexs[i];
				col = pitch*DIM+min_holder[k];
				row = trow;
				flag=true;
			}

		}

		//cout<<min<<endl;
		if(flag)
		{
			//cout<<row+1<<endl;
			fout<<row+1<<endl;
			//cout<<col+1<<endl;
			fout<<col+1<<endl;
		}
		//merging two rows and columns

		for(int i=0; i<size; i++)
		{
			indexs[col*size+i]= indexs[row*size+i]=(indexs[row*size+i]+indexs[col*size+i])/2;
			indexs[i*size+row]= indexs[i*size+col]=(indexs[i*size+row]+indexs[i*size+col])/2;
			indexs[i*size+i]=INT_MAX;

		}

		indexs[row*size+col] = indexs[col*size+row] = INT_MAX;
		handler--;
	}
	cout<<"\nTime: "<<time_total<<"ms"<<endl;
	cout<<"Press Enter to exit.";
	getchar();
	return 0;
}
