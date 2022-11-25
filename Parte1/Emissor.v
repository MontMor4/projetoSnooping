
//estados
`define INVALIDO 2'b00
`define SHARED 2'b01
`define MODIFIED 2'b10
//`define EXCLUSIVE 2'b11 vai ter esse estado? não né?
 
 //resultado da operacao
`define READ_MISS  2'b00
`define READ_HIT  2'b01
`define WRITE_MISS  2'b10
`define WRITE_HIT  2'b11

//mensagens bus
`define WRITE_MISS_ON_BUS 3'b001
`define READ_MISS_ON_BUS 3'b010
`define INVALIDATE_ON_BUS 3'b011

module Emissor(clock, write, hit, shared, mensagemBus, writeBack);
	input clock, 
	write, // 1 para write, 0 para read
	hit, // 1 para hit, 0 para miss 
	shared; // 1 para shared, 0 para modified
	
	output reg [2:0] mensagemBus;
	output reg writeBack;
	reg [1:0] estado, operCode;
	
	
	initial begin
		estado = `INVALIDO; //comeca com o estado invalido
	end
	
	always@(posedge clock) begin
	
	mensagemBus = 0;
	writeBack = 0;
	operCode = {write, hit};

	case(estado)
		`INVALIDO: begin
			case (operCode)
				`WRITE_MISS: begin
					estado = `MODIFIED;
					mensagemBus = `WRITE_MISS_ON_BUS;
				end
				
				
				`READ_MISS: begin
					/* precisa fazer isso? 
					
					//para read miss devemos verificar se o bloco é shared ou modified
					case (shared)
						1'b1: begin //shared
							estado = `SHARED;
						end
						
						1'b0:	begin //modified
							
						end
						
					*/
					
					estado = `SHARED;
					mensagemBus = `READ_MISS_ON_BUS;
				end
				
			endcase
			
		end
		
		`SHARED: begin 
			case(operCode)
				`READ_HIT: begin
				
				end
				
				`WRITE_HIT: begin
				
				end
				
				`READ_MISS: begin
				
				end
				
				`WRITE_MISS: begin
				
				end
			endcase
		end
		
		`MODIFIED: begin
			case(operCode)
				`READ_HIT: begin
				
				end
				
				`WRITE_HIT: begin
				
				end
				
				`READ_MISS: begin
				
				end
				
				`WRITE_MISS: begin
				
				end
			endcase
		end
	
	endcase
	
	end
endmodule