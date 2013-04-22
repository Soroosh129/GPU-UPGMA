################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../main.fatbin.c 

CU_SRCS += \
../main.cu 

CU_DEPS += \
./main.d 

OBJS += \
./main.o \
./main.fatbin.o 

C_DEPS += \
./main.fatbin.d 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	nvcc -G -g -O0 -gencode arch=compute_12,code=sm_12 -gencode arch=compute_13,code=sm_13 -gencode arch=compute_20,code=sm_20 -gencode arch=compute_20,code=sm_21 -odir "" -M -o "$(@:%.o=%.d)" "$<"
	nvcc --compile -G -O0 -g -gencode arch=compute_12,code=compute_12 -gencode arch=compute_12,code=sm_12 -gencode arch=compute_13,code=compute_13 -gencode arch=compute_13,code=sm_13 -gencode arch=compute_20,code=compute_20 -gencode arch=compute_20,code=sm_20 -gencode arch=compute_20,code=sm_21  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

%.o: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	nvcc -G -g -O0 -gencode arch=compute_12,code=sm_12 -gencode arch=compute_13,code=sm_13 -gencode arch=compute_20,code=sm_20 -gencode arch=compute_20,code=sm_21 -odir "" -M -o "$(@:%.o=%.d)" "$<"
	nvcc -G -g -O0 --compile  -x c -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


