`define TAM 20
`define CACHE_TAG 13:11
`define CACHE_STATE 10:8
`define CACHE_DATA 7:0

`define INVALID 3'b000
`define SHARED 3'b001
`define EXCLUSIVE 3'b010
`define MODIFIED 3'b011
module parte2_tb();

	integer i;
	integer j;
	
	reg [13:0] instruction;
	reg clock;
	reg [13:0] queue [8:0];
	reg [7:0] state;
	Parte2 dut(clock, instruction);
	
	initial begin
		#10;
		queue[0] = 14'b001000xxxxxxxx; //P0: read 100
		queue[1] = 14'b011000xxxxxxxx; //P1: read 100
		queue[2] = 14'b01000000011110; //P1: write 100 <-30
		queue[3] = 14'b00000000101000; //P0: write 100 <-40
		queue[4] = 14'b011000xxxxxxxx; //P1: read 100
		queue[5] = 14'b011010xxxxxxxx; //P1: read 110
		queue[6] = 14'b10001000111100; //P3: write 110 <- 60
		queue[7] = 14'b011110xxxxxxxx; //P1: read 130
		queue[8] = 14'b01011000101000; //P1: write 130 <-40
		
		//                       TAG  STATE   DATA
		dut.c0.cache_data[0] = 14'b00000000001010; //I|100|00 10
		dut.c0.cache_data[1] = 14'b00100100001000; //S|108|00 08
		dut.c0.cache_data[2] = 14'b01001100011110; //M|110|00 30
		dut.c0.cache_data[3] = 14'b01100000001010; //I|118|00 10
		
		dut.c1.cache_data[0] = 14'b00000000001010; //I|100|00 10
		dut.c1.cache_data[1] = 14'b10101101000100; //M|128|00 68
		dut.c1.cache_data[2] = 14'b01000000001010; //I|110|00 10
		dut.c1.cache_data[3] = 14'b01100100010010; //S|118|00 18
		
		dut.c2.cache_data[0] = 14'b10000100010100; //S|120|00 20
		dut.c2.cache_data[1] = 14'b00100100001000; //S|108|00 08
		dut.c2.cache_data[2] = 14'b01000000001010; //I|110|00 10
		dut.c2.cache_data[3] = 14'b01100000001010; //I|118|00 10
		
		//instruction = queue[0];
		instruction = queue[0]; clock = 0; #10;
		clock = 1; #10;
		instruction = queue[1]; clock = 0; #10;
		clock = 1; #10;
		instruction = queue[2]; clock = 0; #10;
		clock = 1; #10;
		instruction = queue[3]; clock = 0; #10;
		clock = 1; #10;
		instruction = queue[4]; clock = 0; #10;
		clock = 1; #10;
		instruction = queue[5]; clock = 0; #10;
		clock = 1; #10;
		instruction = queue[6]; clock = 0; #10;
		clock = 1; #10;
		instruction = queue[7]; clock = 0; #10;
		clock = 1; #10;
		instruction = queue[8]; clock = 0; #10;
		clock = 1; #10;
		
		//clock = ~clock; #10;
	end
	
	always@(clock) begin
			//instruction = queue[i];
			$display("\n[%3d] - clock = %b, instr = %b barramento = %b, wr_bus = %b, c0.Em = %b,c1.Em = %b, c2.Em = %b \n",$time, clock,
			instruction,dut.bus_OUT,dut.wr_bus,dut.c0.isEmissor,dut.c1.isEmissor,dut.c2.isEmissor);
			
			$display("P0:");
			for(j = 0; j < 4; j = j + 1) begin //C0
				case(dut.c0.cache_data[j][`CACHE_STATE])
					`INVALID: state = "I";
					`SHARED: state = "S";
					`MODIFIED: state = "M";
					`EXCLUSIVE: state = "E";
				endcase
				$display("B%0d = [%b][%s][%d]",j,dut.c0.cache_data[j][`CACHE_TAG],state,dut.c0.cache_data[j][`CACHE_DATA]);
			end
			
			$display("\nP1:");
			for(j = 0; j < 4; j = j + 1) begin //C1
				case(dut.c1.cache_data[j][`CACHE_STATE])
					`INVALID: state = "I";
					`SHARED: state = "S";
					`MODIFIED: state = "M";
					`EXCLUSIVE: state = "E";
				endcase
				$display("B%0d = [%b][%s][%d]",j,dut.c1.cache_data[j][`CACHE_TAG],state,dut.c1.cache_data[j][`CACHE_DATA]);
			end
			
			$display("\nP3:");
			for(j = 0; j < 4; j = j + 1) begin //C2
				case(dut.c2.cache_data[j][`CACHE_STATE])
					`INVALID: state = "I";
					`SHARED: state = "S";
					`MODIFIED: state = "M";
					`EXCLUSIVE: state = "E";
				endcase
				$display("B%0d = [%b][%s][%d]",j,dut.c2.cache_data[j][`CACHE_TAG],state,dut.c2.cache_data[j][`CACHE_DATA]);
			end
			
			$display("\nMEM:");
			for(j = 0; j < 7; j = j + 1) begin //MEM
				$display("mem[%3b] = [%d]",j,dut.m.mem[j]);
			end
	end
	
	
endmodule