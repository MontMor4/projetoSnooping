
//estados
`define INVALID 2'b00
`define SHARED 2'b01
`define EXCLUSIVE 2'b10
 
 //resultado da operacao
`define READ_MISS  2'b10
`define READ_HIT  2'b11
`define WRITE_MISS  2'b00
`define WRITE_HIT  2'b01

//mensagens bus
`define WRITE_MISS_BUS 3'b001
`define READ_MISS_BUS 3'b010
`define INVALIDATE_BUS 3'b011

module Emissor(clock, write, hit, mensagemBus, writeBack);
	input clock, 
	write, // 1 para write, 0 para read
	hit; // 1 para hit, 0 para miss 
	
	output reg [2:0] mensagemBus;
	output reg writeBack;
	reg [1:0] estado, operCode;
	
	initial begin
		estado = `INVALID; //comeca com o estado invalido
	end
	
	always@(posedge clock) begin
	
		mensagemBus = 0;
		writeBack = 0;
		operCode = {write, hit};

		case(estado)
			`INVALID: begin
				case (operCode)
					`WRITE_MISS: begin
						estado = `EXCLUSIVE;
						mensagemBus = `WRITE_MISS_BUS;
					end
					
					`READ_MISS: begin
						estado = `SHARED;
						mensagemBus = `READ_MISS_BUS;
					end
					
				endcase
				
			end
			
			`SHARED: begin 
				case(operCode)
					`READ_HIT: begin
						//estado não é alterado
						mensagemBus = 0;
					end
					
					`WRITE_HIT: begin
						estado = `EXCLUSIVE; //em caso de write hit, o dado escrito será exclusivo daquela cache
						mensagemBus = `INVALIDATE_BUS; //invalida todas as outras caches
					end
					
					`READ_MISS: begin
						//estado não é alterado
						mensagemBus = `READ_MISS_BUS;
					end
					
					`WRITE_MISS: begin
						estado = `EXCLUSIVE;
						mensagemBus = `WRITE_MISS_BUS;
					end
				endcase
			end
			
			`EXCLUSIVE: begin
				case(operCode)
					`READ_HIT: begin
						//estado nao muda
						mensagemBus = 0;
					end
					
					`WRITE_HIT: begin
						//estado nao muda
						mensagemBus = 0;
					end
					
					`READ_MISS: begin
						estado = `SHARED;
						mensagemBus = `READ_MISS_BUS; 
						writeBack = 1;
						// DÚVIDA DO QUE FAZER COM O WRITEBACK ***************************
					end
					
					`WRITE_MISS: begin
						//estado nao muda
						mensagemBus = `WRITE_MISS_BUS;
						writeBack = 1;
						// DÚVIDA DO QUE FAZER COM O WRITEBACK ***************************
					end
				endcase
			end
		
		endcase
	
	end
endmodule