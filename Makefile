SRC = test.v
DC_SRC = test_dc_1.v
TEST = #test.v

OPTS = -full64

async:
	vcs -full64 +vpi +cli+3 -use_vpiobj vpi.o $(SRC)

dc_async:
	vcs -full64 -V +libverbose +vpi +cli+3 -use_vpiobj vpi.o $(DC_SRC)  | tee dc_async.log

VCS: $(SRC) $(TEST)
	vcs $(OPTS) -v $(SRC) $(TEST)

run:
	./simv | tee simv.log

clean:
	rm -rf simv* *.vcd *.key csrc 
