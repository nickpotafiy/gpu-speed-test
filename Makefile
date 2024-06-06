NVCC = nvcc
TARGET = speed
SOURCES = speed.cu
NVCC_FLAGS = -O2 \
	-gencode arch=compute_86,code=sm_86 \
	-gencode arch=compute_89,code=sm_89 \
	-gencode arch=compute_90,code=sm_90
LIBRARIES = -lcudart -lcurand

all: $(TARGET)
	@echo "Build is complete."

$(TARGET): $(SOURCES)
	$(NVCC) $(NVCC_FLAGS) $(SOURCES) -o $(TARGET) $(LIBRARIES)

clean:
	rm -f $(TARGET)

.PHONY: all clean