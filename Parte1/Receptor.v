
//estados
`define INVALID 2'b00
`define SHARED 2'b01
`define EXCLUSIVE 2'b10
 
//mensagens bus
`define WRITE_MISS_BUS 3'b001
`define READ_MISS_BUS 3'b010
`define INVALIDATE_BUS 3'b011

module Receptor(clock, reset, mensagemBus, writeBack, estado);
	input clock, reset;
	input [2:0] mensagemBus;
	output reg writeBack;
	output reg [1:0] estado;

	initial begin
		estado = `SHARED;
		writeBack = 0;
	end
	
	always@(posedge clock) begin
		
		writeBack = 0;
		
		case(estado)
			`SHARED: begin
				case(mensagemBus)
					`WRITE_MISS_BUS: begin 
						estado = `INVALID;
					end
					
					`INVALIDATE_BUS: begin
						estado = `INVALID;
					end
					
					`READ_MISS_BUS: begin
						//estado não é alterado
					end

				endcase
			end
			
			`EXCLUSIVE: begin 
				case(mensagemBus)
					`READ_MISS_BUS: begin
						estado = `SHARED;
						writeBack = 1;
						// DÚVIDA DO QUE FAZER COM O WRITEBACK ***************************
					end
					
					`WRITE_MISS_BUS: begin 
						estado = `INVALID;
						writeBack = 1;
						// DÚVIDA DO QUE FAZER COM O WRITEBACK ***************************
					end
					
				endcase
			end
			
		endcase
		
		/* DÚVIDA SE PRECISA DESSA LÓGICA DO RESET ************************************
		
		if(reset) begin
			estado = `EXCLUSIVE;
		end
		*/
		
	end
	
	
endmodule