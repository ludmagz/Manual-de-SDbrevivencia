module divFreq(
    input clk,      // Sinal de clock de entrada.
    output reg s16, // esta saída irá dividir o clock por 4.
    output reg s4,  // esta saída irá dividir o clock por 8.
    output reg s1   // esta saída irá dividir o clock por 32.
);

// Registradores de estado para controlar quando cada saída deve mudar.
reg stateS16;
reg stateS4;
reg stateS1;

// Um contador de 5 bits [4:0], que conta de 0 a 31.
reg [4:0] counter;

// Parâmetros para tornar o código da máquina de estados mais legível.
parameter WAIT = 0,   // Estado de espera.
          CHANGE = 1; // Estado que indica que a saída deve ser invertida.

// --- Bloco de Inicialização ---
// Executado apenas uma vez, no início da simulação.
initial begin
    stateS16 = 0;
    stateS4 = 0;
    stateS1 = 0;
    counter = 0;
end

// --- Bloco de Controle ---
// Este bloco síncrono é executado a cada borda de subida do clock.
always @(posedge clk) begin
    // O contador avança a cada ciclo e volta a 0 naturalmente após 31.
    counter = counter + 1;
    // Máquina de estados para a saída s16.
    // Esta lógica faz o estado 'stateS16' inverter a cada ciclo de clock.
    case(stateS16)
        WAIT: stateS16 <= CHANGE;
        CHANGE: stateS16 <= WAIT;
    endcase
    // Máquina de estados para a saída s4.
    // Gera um pulso 'CHANGE' de um ciclo sempre que o contador for um múltiplo de 4.
    case(stateS4)
        WAIT: stateS4 <= (counter%4) ? stateS4 : CHANGE;
        CHANGE: stateS4 <= WAIT;
    endcase
    // Máquina de estados para a saída s1.
    // Gera um pulso 'CHANGE' de um ciclo sempre que o contador for um múltiplo de 16.
    case(stateS1)
        WAIT: stateS1 <= (counter%16) ? stateS1 : CHANGE;
        CHANGE: stateS1 <= WAIT;
    endcase
end

// --- Bloco de Geração de Saída ---
// Este bloco também é síncrono e atualiza as saídas.
always @(posedge clk) begin
    // Esta lógica funciona como um T-Flip-Flop (toggle).
    // 'stateS16' é CHANGE em ciclos ímpares (1, 3, 5...).
    // 's16' inverte a cada 2 ciclos. Período = 4 ciclos. Frequência = F_clk / 4.
    if (stateS16 == CHANGE)
        s16 = ~s16;

    // 'stateS4' é CHANGE a cada 4 ciclos.
    // 's4' inverte a cada 4 ciclos. Período = 8 ciclos. Frequência = F_clk / 8.
    if (stateS4 == CHANGE)
        s4 = ~s4;

    // 'stateS1' é CHANGE a cada 16 ciclos.
    // 's1' inverte a cada 16 ciclos. Período = 32 ciclos. Frequência = F_clk / 32.
    if (stateS1 == CHANGE)
        s1 = ~s1;
end

endmodule
