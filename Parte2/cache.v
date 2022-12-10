`define INVALID 3'b000
`define SHARED 3'b001
`define EXCLUSIVE 3'b010

`define READ_MISS  2'b10
`define READ_HIT  2'b11
`define WRITE_MISS  2'b00
`define WRITE_HIT  2'b01

`define WRITE_MISS_ON_BUS 3'b001
`define READ_MISS_ON_BUS 3'b010
`define INVALIDATE_ON_BUS 3'b011

`define BUS_TAG 14:12
`define BUS_MSG 11:9
`define BUS_VALID 8
`define BUS_DATA 7:0

`define CACHE_TAG 13:11
`define CACHE_STATE 10:8
`define CACHE_DATA 7:0

`define INSTRUCTION_PID 13:12
`define INSTRUCTION_R_OR_W 11
`define INSTRUCTION_TAG 10:8
`define INSTRUCTION_DATA 7:0

/*
TAG -> TAG   Bloco
100 -> 000	  0
108 -> 001	  1
110 -> 010	  2
118 -> 011	  3
120 -> 100	  0
128 -> 101	  1
130 -> 110	  2
*/

module cache(ID,clock,instruction,memory_in,bus_IN,bus_EM_OUT, bus_R_OUT,wr_bus,memory_out,memory_tag_out,write_back);
	input clock;
	input [13:0] instruction; //P<x> (2b) | R/W (1b) | TAG (3b) | data (8b).
	input [14:0] bus_IN; // [TAG (3b) | MSG (3b) | Válido (1b) | dado (8b)] = 15 bits
	input [1:0] ID;
	input [7:0] memory_in;
	
	output reg wr_bus,write_back; //Avisa que esta cache escreveu no barramento.
	output reg [14:0] bus_EM_OUT, bus_R_OUT; //Mensagem escrita no barramento.
	output reg [7:0] memory_out;
	output reg [2:0] memory_tag_out;
	/*
		cache de 4 blocos de uma palavra.
		[TAG (3b)|STATE (3b)|DATA (8b)] = 14 bits
	*/
	
	reg [13:0] cache_data [3:0]; // 4x14 - [TAG (3b)|STATE (3b)|DATA (8b)] = 14 bits
	
	reg isEmissor; //Determina quem é o emissor.
	reg [1:0] op;
	reg [1:0] index;
	reg counter;
	
	initial begin
		counter = 0;
		isEmissor = 0;
		bus_EM_OUT = 15'b0;
		bus_R_OUT = 15'b0;
		op = ID;
		
		
	end

	always @() begin
		memory_tag_out = 3'bx;
		write_back = 0;

		case(counter)
			1'b0: begin //Borda de subida
				write_back = 0;
				//Primeiro: Lê a mensagem do barramento antes de escreve-lo.
				index = bus_IN[13:12]; //Os bits menos significativos da tag representam o indice do bloco. 
				
				if(isEmissor) begin
					if(bus_IN[`BUS_MSG] == `READ_MISS_ON_BUS) begin //O emissor deu read miss
						
						if(bus_IN[`BUS_VALID] == 1) begin //Deu Read Miss e outra cache repassou o dado
							//Substitui os dados naquele bloco e estado = SHARED
							cache_data[index][`CACHE_STATE] = `SHARED;
							cache_data[index][`CACHE_TAG] = bus_IN[`BUS_TAG];
							cache_data[index][`CACHE_DATA] = bus_IN[`BUS_DATA];
						end else begin 
							//Deu read miss e nenhuma cache repassou o bloco: Estado = Exclusive
							cache_data[index][`CACHE_STATE] = `EXCLUSIVE;
							cache_data[index][`CACHE_TAG] = bus_IN[`BUS_TAG];
							cache_data[index][`CACHE_DATA] = memory_in;
						end
					end
				
					
				end
				
				
				//Depois, lê a instrucao para saber o que escrever no barramento ------ COMECO
				isEmissor = 0;
				wr_bus = 0;
				index = instruction[9:8];
				bus_EM_OUT = 15'b0;
				
				if(ID == instruction[`INSTRUCTION_PID]) begin
					isEmissor = 1;
					if(instruction[`INSTRUCTION_R_OR_W] == 1) begin //Read
					
						if(cache_data[index][`CACHE_TAG] == instruction[`INSTRUCTION_TAG] && cache_data[index][`CACHE_STATE] != `INVALID) begin //Read hit
							//Não manda nada no barramento
							bus_EM_OUT[`BUS_TAG] = instruction[`INSTRUCTION_TAG];
							bus_EM_OUT[`BUS_MSG] = 3'b0;
							wr_bus = 1;
							
						end else begin
							//Read miss
							
							if(cache_data[index][`CACHE_STATE] == `MODIFIED) begin //Se deu Read miss e o bloco é modificado, tem que fazer write back.
								write_back = 1;
								memory_out = cache_data[index][`CACHE_DATA];
								memory_tag_out = cache_data[index][`CACHE_TAG];
							end
							wr_bus = 1;
							bus_EM_OUT[`BUS_TAG] = instruction[`INSTRUCTION_TAG];
							bus_EM_OUT[`BUS_MSG] = `READ_MISS_ON_BUS;
							bus_EM_OUT[`BUS_VALID] = 1'bx;
							bus_EM_OUT[`BUS_DATA] = 8'bx;
						end
						
					end else begin //Write
						if(cache_data[index][`CACHE_TAG] == instruction[`INSTRUCTION_TAG] && cache_data[index][`CACHE_STATE] != `INVALID) begin //Write hit
							//Invalidate on bus
							wr_bus = 1;
							bus_EM_OUT[`BUS_TAG] = instruction[`INSTRUCTION_TAG];
							bus_EM_OUT[`BUS_MSG] = `INVALIDATE_ON_BUS;
							bus_EM_OUT[`BUS_VALID] = 1'bx;
							bus_EM_OUT[`BUS_DATA] = 8'bx;
							
							//Escreve o dado na cache
							cache_data[index][`CACHE_STATE] = `MODIFIED;
							cache_data[index][`CACHE_TAG] = instruction[`INSTRUCTION_TAG];
							cache_data[index][`CACHE_DATA] = instruction[`INSTRUCTION_DATA];
							
						end else begin
							//Write miss
							if(cache_data[index][`CACHE_STATE] == `MODIFIED) begin //Se deu Write miss e o bloco é modificado, tem que fazer write back.
								write_back = 1;
								memory_out = cache_data[index][`CACHE_DATA];
								memory_tag_out = cache_data[index][`CACHE_TAG];
							end
							
							wr_bus = 1;
							bus_EM_OUT[`BUS_TAG] = instruction[`INSTRUCTION_TAG];
							bus_EM_OUT[`BUS_MSG] = `INVALIDATE_ON_BUS;
							bus_EM_OUT[`BUS_VALID] = 1'bx;
							bus_EM_OUT[`BUS_DATA] = 8'bx;
							
							//Escreve o dado na cache
							cache_data[index][`CACHE_STATE] = `MODIFIED;
							cache_data[index][`CACHE_TAG] = instruction[`INSTRUCTION_TAG];
							cache_data[index][`CACHE_DATA] = instruction[`INSTRUCTION_DATA];
						end
						
					end
			
				end
			end
				
			
			1'b1: begin //Borda de descida
				index = bus_IN[13:12];
				bus_R_OUT = 15'b0;
				
				wr_bus = 0;
		
				if(isEmissor == 0) begin //Apenas as caches receptoras vão agir
					case(bus_IN[`BUS_MSG])
						
						`READ_MISS_ON_BUS: begin
							if(cache_data[index][`CACHE_TAG] == bus_IN[`BUS_TAG] && cache_data[index][`CACHE_STATE] != `INVALID) begin
								//Repassa o dado para o barramento
								if(cache_data[index][`CACHE_STATE] == `EXCLUSIVE) begin
									cache_data[index][`CACHE_STATE] = `SHARED;
								end
								
								if(cache_data[index][`CACHE_STATE] == `MODIFIED) begin
									write_back = 1;
									memory_out = cache_data[index][`CACHE_DATA];
									memory_tag_out = cache_data[index][`CACHE_TAG];
									cache_data[index][`CACHE_STATE] = `SHARED;
								end
								
								bus_R_OUT[`BUS_TAG] = bus_IN[`BUS_TAG];
								bus_R_OUT[`BUS_MSG] = bus_IN[`BUS_MSG];
								bus_R_OUT[`BUS_VALID] = 1'b1;
								bus_R_OUT[`BUS_DATA] = cache_data[index][`CACHE_DATA];
								
							end
						end
						
						`INVALIDATE_ON_BUS: begin
							if(cache_data[index][`CACHE_STATE] == `MODIFIED) begin
								write_back = 1;
								memory_out = cache_data[index][`CACHE_DATA];
								memory_tag_out = cache_data[index][`CACHE_TAG];
								cache_data[index][`CACHE_STATE] = `INVALID;
								
							end else begin
								cache_data[index][`CACHE_STATE] = `INVALID;
							end
						end
					endcase
				
				end
			end
			
			default: begin
			end
		endcase
		
		counter = counter + 1'b1;
	end


endmodule