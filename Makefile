SRC = test.v
TEST = #test.v

OPTS = -full64

async:
	vcs -full64 +vpi +cli+3 -use_vpiobj vpi.o $(SRC)

VCS: $(SRC) $(TEST)
	vcs $(OPTS) -v $(SRC) $(TEST)

run:
	./simv

clean:
	rm -rf simv* *.vcd *.key csrc 
