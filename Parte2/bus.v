`define BUS_TAG 14:12
`define BUS_MSG 11:9
`define BUS_VALID 8
`define BUS_DATA 7:0

module bus(wr_bus,bus_EM_OUT_0,bus_R_OUT_0,bus_EM_OUT_1,bus_R_OUT_1,bus_EM_OUT_2,bus_R_OUT_2, bus_OUT);
	
	input [2:0] wr_bus;
	input [14:0] bus_EM_OUT_0,bus_R_OUT_0,bus_EM_OUT_1,bus_R_OUT_1,bus_EM_OUT_2,bus_R_OUT_2;
	output reg [14:0] bus_OUT;
	
	initial begin
		bus_OUT = 15'b0;
	end

	always@(wr_bus) begin
		
		case(wr_bus) //Bit 1 remete ao emissor
			3'b100: bus_OUT = bus_EM_OUT_0;
			3'b010: bus_OUT = bus_EM_OUT_1;
			3'b001: bus_OUT = bus_EM_OUT_2;
			3'b000: begin //Se não há emissores, então quem escreve no barramento é a cache ouvinte
				if(bus_R_OUT_0[`BUS_VALID] == 1) begin
					bus_OUT[`BUS_VALID] = 1;
					bus_OUT[`BUS_DATA] = bus_R_OUT_0[`BUS_DATA];
				end
				else if(bus_R_OUT_1[`BUS_VALID] == 1) begin
					bus_OUT[`BUS_VALID] = 1;
					bus_OUT[`BUS_DATA] = bus_R_OUT_1[`BUS_DATA];
				end
				else if(bus_R_OUT_2[`BUS_VALID] == 1) begin
					bus_OUT[`BUS_VALID] = 1;
					bus_OUT[`BUS_DATA] = bus_R_OUT_2[`BUS_DATA];
				end
				else begin
					bus_OUT[`BUS_VALID] = 0;
					bus_OUT[`BUS_DATA] = 8'bx;
				end
			end
			
		endcase
		
	end
endmodule