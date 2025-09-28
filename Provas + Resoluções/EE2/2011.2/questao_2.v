// o código abaixo nada mais é do que uma das técnicas mais importantes para
// a leitura de botões, o debounce, que trata o ruído gerado quando um botão
// é apertado, isso ocorre devido à propridades físicas do botão em si
module debounce(
	input clk, btn,
	output reg S
);
	// btn = botao que vai ser tratado com o debounce

	// registrador que vai armazenar a info do estado
	reg [1:0] state = 0;
	
	// definição dos estados
	parameter UNPRESS = 0,
				 DEBOUNCE = 1,
				 PRESS = 2,
				 WAIT_UNPRESS = 3;
				 
	// contador que servirá para temporizar o debounce
	reg [31:0] count = 0;
	
	always @(posedge clk) begin
		case(state)
			// se o botão for precionado, o tratamento do debounce entre em ação
			UNPRESS: begin state <= (btn)? DEBOUNCE : state; end
			// espera até que o tempo de 30ms seja alcançado, o que 
			// equivale a 120000 ciclos do clock, explicação
			// 4MHz = 4M ciclos por 1s, fazendo os calculos -> 120K ciclos por 30ms
			DEBOUNCE: begin state <= (count == 120000)? PRESS : state; end
			// verifica se o botão realmente foi apertado, aqui há o tratamento de pulsos
			// que na maioria dos casos, não necessariamente significam que o botão foi pressionado
			PRESS: state <= (btn)? WAIT_UNPRESS : UNPRESS;
			// espera o botão ser solto para reiniciar o tratamento
			// para um ocasional pressionamento do botão
			WAIT_UNPRESS: begin state <= (btn)? state : UNPRESS; end
		endcase
	end
	
	always @(posedge clk) begin
		case(state)
			UNPRESS: count = 0; // o contador deve ser zerado para evitar erros na contagem do proximo estado
			DEBOUNCE: count = count + 1; // o contador é incrementado, pondo a contagem em execução
			PRESS: S = ~S; // a variável S tem seu valor invertido após a confirmação do pressionamento do botão
		endcase
	end	
	
endmodule
