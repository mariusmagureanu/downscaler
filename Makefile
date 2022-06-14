.PHONY: all artifact clean

all:
	@cd src && $(MAKE)

clean:
	@cd src && make clean