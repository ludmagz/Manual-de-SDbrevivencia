// o código a seguir nada mais é do que um protocolo bem simples
// para a leitura de teclas, de um teclado por exemplo, só que 
// de forma bem mais simplificada, a qual temos apenas duas teclas
module protocolo(
	input clk, data, rst,
	output reg S
);

	// rst = botao de reset
	
	reg [2:0] state = 0; // registrador que vai armazenar a info sobre o estado
	
	// enumeração dos estados
	parameter INIT = 0,
				 R_DATA0 = 1,
				 R_DATA1 = 2,
				 R_DATA2 = 3,
				 R_DATA3 = 4,
				 COMPARE = 5,
				 RESET = 6;
				 
	// vetor que armazenará os valores temporários de 'data' após o start	 
	reg [3:0] vector = 0;
	
	always @(negedge clk) begin
		case(state)
			// analisa se data = 1 pra iniciar o protocolo
			INIT: 	begin state <= (data)? state : R_DATA0; end
			// se rst = 1, reseta o protocolo, se não continua
			R_DATA0: begin state <= (rst)? RESET : R_DATA1; end
			R_DATA1: begin state <= (rst)? RESET : R_DATA2; end
			R_DATA2: begin state <= (rst)? RESET : R_DATA3; end
			R_DATA3: begin state <= (rst)? RESET : COMPARE; end
			// compara os valores armazenados em vector com '1001' ou '1010'
			// e volta para o inicio do protocolo
			COMPARE: state <= INIT;
			// reseta o protocolo voltando pra o inicio
			RESET: state <= INIT;
		endcase
	end
	
	always @(negedge clk) begin
		case(state)
			// armazena os valores temporários de data
			R_DATA0: vector[0] = data;
			R_DATA1: vector[1] = data;
			R_DATA2: vector[2] = data;
			R_DATA3: vector[3] = data;
			// compara vector com '1010' ou '1001', alterando se para 1 ou 0, respectivamente
			COMPARE: begin
				if (vector == 4'b1001)
					S = 1;
				else if (vector == 4'b1010)
					S = 0;
				else
					S = S; // caso seja diferente, mantém o valor de S igual o anterior
			end
			// zera o vetor e a saída S e reinicia o protolo
			RESET: begin vector = 4'b0000; S = 0; end 
		endcase
	end
endmodule
		
		
