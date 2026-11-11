// módulo 'counter2s', que implementa uma FSM; que incrementa a saída S em 1 a cada 2 segundos
// S inicia em 0, zera a cada pulso de RST (0->1->0) e, ao passar de 120, volta a 0
module counter2s(
    input RST,          // entrada de reset (1 bit)
    input clk,          // clock principal (4 MHz)
    output reg [6:0] S = 0  // saída de 7 bits (0 a 120) do contador
);

    // --- parâmetros de Estado ---
    parameter WAIT_TIMER   = 0,  // conta o tempo; espera os 2 segundos ou o RST
              WAIT_RELEASE = 1,  // RST foi pressionado (0->1); espera ser solto (1->0)
              INCREMENT    = 2,  // se S = 120, S = 0; senão S = S + 1
              RESET        = 3;  // zera S

    // --- sinais internos ---
    // registrador de 2 bits para armazenar o estado atual da FSM
    reg [1:0] state = WAIT_TIMER;

    // contador de 32 bits usado como temporizador
    reg [31:0] counter = 0;

    // --- bloco 1: temporizador de 2 segundos ---
    always @(posedge clk) begin
        // clock de 4 MHz
        // 4.000.000 * 2 (segundos) = 8.000.000 ciclos
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
            // se passaram 2 segundos, vai incrementar S.
            WAIT_TIMER: begin
                if (RST)
                    state <= WAIT_RELEASE;
                else if (counter == 8000000)
                    state <= INCREMENT;
            end

            // espera o RST ser solto (1 -> 0) para ir zerar S.
            WAIT_RELEASE: begin
                if (~RST)
                    state <= RESET;
            end

            // após incrementar S, zera o contador e volta a contar o tempo.
            INCREMENT: begin
                state <= WAIT_TIMER;
            end

            // após zerar S, zera o contador e volta a contar o tempo.
            RESET: begin
                state <= WAIT_TIMER;
            end
        endcase
    end

    // --- bloco 3: saída ---
    always @(posedge clk) begin
        // S é incrementado no INCREMENT e zera quando S = 120.
        if (state == INCREMENT) begin
            if (S == 120)
                S <= 0;
            else
                S <= S + 1;
        end

        // S é zerado no RESET.
        else if (state == RESET)
            S <= 0;
    end

endmodule
