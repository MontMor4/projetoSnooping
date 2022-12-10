module Parte2(clock, instruction);
	
	input [13:0] instruction;
	input clock;
	
	wire [7:0] memory_out;             //Saída da memória e entrada nas caches
	wire [14:0] bus_OUT;               //Saída do barramento e entrada nas caches
	wire [14:0] bus_EM_OUT_0,bus_R_OUT_0,bus_EM_OUT_1,bus_R_OUT_1,bus_EM_OUT_2,bus_R_OUT_2;
	wire wr_bus0,wr_bus1,wr_bus2;      //Escrita da cache emissora
	wire [2:0] wr_bus;                 //Concatenaçao de wr_bus
	wire [2:0] tag_0,tag_1,tag_2;      //Saida da tag das caches
	wire [7:0] data_0, data_1, data_2; //Saída dos dados das caches
	wire wb_0,wb_1,wb_2;               //Sinal de write-back das caches
	
	
	//cache(ID,clock,instruction,memory_in,bus_IN,bus_EM_OUT, bus_R_OUT,wr_bus,memory_out,memory_tag_out,write_back);
	cache c0(2'b00,clock,instruction,memory_out,bus_OUT,bus_EM_OUT_0, bus_R_OUT_0,wr_bus0,data_0,tag_0,wb_0);
	
	cache c1(2'b01,clock,instruction,memory_out,bus_OUT,bus_EM_OUT_1, bus_R_OUT_1,wr_bus1,data_1,tag_1,wb_1);
	
	cache c2(2'b10,clock,instruction,memory_out,bus_OUT,bus_EM_OUT_2, bus_R_OUT_2,wr_bus2,data_2,tag_2,wb_2);
	
	//memory(bus_IN,tag_0,tag_1,tag_2, data_0, data_1, data_2,wb_0,wb_1,wb_2, memory_out);
	memory m(bus_OUT,tag_0,tag_1,tag_2, data_0, data_1, data_2,wb_0,wb_1,wb_2, memory_out);
	
	assign wr_bus = {wr_bus0,wr_bus1,wr_bus2};
	
	//bus(wr_bus,bus_EM_OUT_0,bus_R_OUT_0,bus_EM_OUT_1,bus_R_OUT_1,bus_EM_OUT_2,bus_R_OUT_2, bus_OUT);
	bus b(wr_bus,bus_EM_OUT_0,bus_R_OUT_0,bus_EM_OUT_1,bus_R_OUT_1,bus_EM_OUT_2,bus_R_OUT_2, bus_OUT);
	
endmodule