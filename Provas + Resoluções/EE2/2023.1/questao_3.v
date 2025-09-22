// Módulo 'register6s', que implementa um registrador/contador de 4 bits
// que incrementa seu valor a cada 6 segundos, condicionado por uma entrada.
module register6s(
    input S1,      // Entrada de 1 bit, provavelmente um botão de acionamento.
    input clk,     // Clock principal para sincronizar o circuito.
    output reg [3:0] P // Saída de 4 bits que armazena o valor do contador.
);

    // --- Parâmetros de Estado ---
    // Nomes legíveis para os estados da máquina de estados finitos (FSM).
    parameter INIT = 0,         // Estado inicial.
              BLOCK = 1,        // Estado de bloqueio ou espera inicial.
              WAIT_PRESS = 2,   // Espera o botão ser solto (nome pode confundir).
              WAIT_UNPRESS = 3, // Espera o botão ser pressionado novamente.
              WAIT_TIMER = 4,   // Espera o temporizador de 6 segundos.
              INCREMENT = 5;    // Estado onde o incremento da saída ocorre.

    // --- Sinais Internos ---
    // Registrador de 3 bits para armazenar o estado atual da FSM.
    reg [2:0] state = INIT;

    // Contador de 32 bits usado como um temporizador.
    reg [31:0] counter = 0;

    // --- Bloco 1: Lógica do Temporizador de 6 Segundos ---
    // Este bloco 'always' implementa um contador que avança a cada ciclo de clock.
    always @(posedge clk) begin
        // O contador avança até atingir 300.000.000.
        // Assumindo um clock de 50 MHz (comum em FPGAs):
        // 300.000.000 ciclos / 50.000.000 ciclos/seg = 6 segundos.
        if (counter < 300000001)
            counter <= counter + 1;
        else
            counter <= 0; // O contador é zerado após atingir o limite.
    end

    // --- Bloco 2: Lógica de Transição de Estados (FSM) ---
    // Este bloco descreve como a máquina muda de estado a cada ciclo de clock.
    always @(posedge clk) begin
        case (state)
            // No estado inicial, verifica se S1 já está pressionado.
            // Se sim, inicia a sequência. Senão, vai para um estado de bloqueio.
            INIT:         begin state <= (S1) ? WAIT_PRESS : BLOCK; end

            // Fica bloqueado até que o timer de 6s expire (timeout) ou S1 seja pressionado.
            BLOCK:        begin state <= (counter == 300000000) ? INIT : (S1) ? WAIT_PRESS : state; end

            // Espera o botão S1 ser solto. Se o timer de 6s expirar, reinicia a FSM.
            WAIT_PRESS:   begin state <= (counter == 300000000) ? INIT : (~S1) ? WAIT_UNPRESS : state; end

            // Após S1 ser solto, espera que seja pressionado novamente para iniciar a contagem.
            WAIT_UNPRESS: begin state <= (counter == 300000000) ? INIT : (S1) ? WAIT_TIMER : state; end

            // Uma vez acionado, espera o contador chegar a 6 segundos.
            // Se chegar, avança para o estado de incremento.
            WAIT_TIMER:   begin state <= (counter == 300000000) ? INCREMENT : state; end

            // Estado de ação: dura apenas um ciclo de clock e então retorna ao início.
            INCREMENT:    state <= INIT;
        endcase
    end

    // --- Bloco 3: Lógica de Saída ---
    // Este bloco controla a ação principal do módulo: o incremento do contador P.
    always @(posedge clk) begin
        // O registrador de saída 'P' só é incrementado quando a FSM
        // entra no estado 'INCREMENT'.
        if (state == INCREMENT)
            P = P + 1;
    end

endmodule
