OUT_DIR=./build

all: build

build: clean
	mkdir -p $(OUT_DIR)
	p4c -o $(OUT_DIR) /shared/p4src/qlr.p4

clean:
	rm -rf ./build