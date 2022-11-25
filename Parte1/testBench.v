module testBench();

	reg clock, write, hit, reset;
	wire [2:0] mensagemBus;
	wire writeBack;
	wire [1:0] estado;
	
	Emissor emissor(clock, write, hit, mensagemBus, writeBack);
	Receptor receptor(clock, reset, mensagemBus, writeBack, estado); 
	
	
endmodule