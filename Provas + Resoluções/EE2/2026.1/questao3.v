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
        // zera no RESET ou no INCREMENT para recomeçar a contagem
        if (state == RESET || state == INCREMENT)
            counter <= 0;
        else if (counter < 8000001)
            counter <= counter + 1; // incrementa o contador em 1
        else
            counter <= 0;
    end

    // --- bloco 2: estados da FSM ---
    always @(posedge clk) begin
        case (state)
            // se RST for pressionado, espera ele ser solto.
            // se passaram 4 segundos, vai incrementar M.
            WAIT_TIMER: begin
                if (RST)
                    state <= WAIT_RELEASE;
                else if (counter == 8000000)
                    state <= INCREMENT;
            end

			// espera o RST ser solto (1 -> 0) para ir zerar M.
            WAIT_RELEASE: begin
                if (~RST)
                    state <= RESET;
            end

            // após incrementar M, volta a contar o tempo.
            INCREMENT: begin
                state <= WAIT_TIMER;
            end

            // após zerar M, volta a contar o tempo.
            RESET: begin
                state <= WAIT_TIMER;
            end
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
