`define BUS_TAG 14:12
`define BUS_MSG 11:9
`define BUS_VALID 8
`define BUS_DATA 7:0

module memory(bus_IN,tag_0,tag_1,tag_2, data_0, data_1, data_2,wb_0,wb_1,wb_2, memory_out);
	
	input wb_0,wb_1,wb_2;
	input [2:0] tag_0,tag_1,tag_2;
	input [7:0] data_0, data_1, data_2;
	input [14:0] bus_IN;
	
	output reg [7:0] memory_out;
	
	reg [7:0] mem [9:0];
	initial begin
		$readmemb("F:/SAMUEL/Escola/CEFETMG/Softwares/ProjetosQuartus/AOC II/Pratica 4/Parte 2/Snooping/mem.txt",mem);
	end

	always@(*) begin
		
		memory_out = mem[bus_IN[`BUS_TAG]];
		
		if(wb_0) begin
			mem[tag_0] = data_0;
		end
		
		if(wb_1) begin
			mem[tag_1] = data_1;
		end
		
		if(wb_2) begin
			mem[tag_2] = data_2;
		end
		
	end
	
endmodule