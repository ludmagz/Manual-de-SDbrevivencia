// módulo 'counter4s', que implementa uma FSM; que incrementa a saída M em 1 a cada 4 segundos
// M inicia em 0, zera a cada pulso de RST (0->1->0) e, ao passar de 65, volta a 0
module counter4s(
    input RST,          // entrada de reset (1 bit)
    input clk,          // clock principal (2 MHz)
    output reg [6:0] M = 0  // saída de 7 bits (0 a 65) do contador
);

    // --- parâmetros de Estado ---
    parameter WAIT_TIMER   = 0,  // conta o tempo; espera os 4 segundos ou o RST
              WAIT_RELEASE = 1,  // RST foi pressionado (0->1); espera ser solto (1->0)
              INCREMENT    = 2,  // se M = 65, M = 0; senão M = M + 1
              RESET        = 3;  // zera M 

    // --- sinais internos ---
    // registrador de 2 bits para armazenar o estado atual da FSM
    reg [1:0] state = WAIT_TIMER;

    // contador de 32 bits usado como temporizador
    reg [31:0] counter = 0;

    // --- bloco 1: temporizador de 4 segundos ---
    always @(posedge clk) begin
	     // clock de 2 MHz
		  // 2.000.000 * 4 (segundos) = 8.000.000 ciclos
	     if (counter < 8000001)
            counter <= counter + 1; // incrementa o contador em 1
        else
            counter <= 0;
    end

    // --- bloco 2: estados da FSM ---
    always @(posedge clk) begin
        case (state)
            // se RST for pressionado, espera ele ser solto. se passaram 4 segundos, incrementa no contador.
            WAIT_TIMER:   begin state <= (RST) ? WAIT_RELEASE : (counter == 8000000) ? INCREMENT : state; end

            // se o RST for solto, zera o contador; senão, permanece no mesmo estado.
            WAIT_RELEASE: begin state <= (~RST) ? RESET : state; end

            // após incrementar o contador em 1, volta para o estado inicial
            INCREMENT:    state <= WAIT_TIMER;
				
				// após zerar o contador, volta para o estado inicial
            RESET:        state <= WAIT_TIMER;
        endcase
    end

    // --- bloco 3: saída ---
    always @(posedge clk) begin
	 
        // M é incrementado no INCREMENT e zera quando M = 65.
        if (state == INCREMENT) begin
            if (M == 65)
                M <= 0;
            else
                M <= M + 1;
        end
		  
        // M é zerado no RESET.
        else if (state == RESET)
            M <= 0;
    end

endmodule