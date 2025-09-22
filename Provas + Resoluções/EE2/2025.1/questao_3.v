// Módulo 'register5s', que implementa um registrador/contador de 4 bits
// que incrementa seu valor a cada 6 segundos, condicionado por uma entrada.
module register5s(
    input RST,      // Entrada de 1 bit, botão que reseta a contagem.
    input clk,     // Clock principal para sincronizar o circuito.
    output reg [7:0] P // Saída de 8 bits que armazena o valor do contador.
);

    // --- Parâmetros de Estado ---
    // Nomes legíveis para os estados da máquina de estados finitos (FSM).
    parameter INIT = 0,         // Estado inicial.
              BLOCK = 1,        // Estado de bloqueio ou espera inicial.
              WAIT_PRESS = 2,   // Espera o botão ser solto (nome pode confundir).
              WAIT_UNPRESS = 3, // Espera o botão ser pressionado novamente.
              WAIT_TIMER = 4,   // Espera o temporizador de 6 segundos.
              INCREMENT = 5,    // Estado onde o incremento da saída ocorre.
				  RESET = 6;        // Estado onde a saída S é zerada

    // --- Sinais Internos ---
    // Registrador de 3 bits para armazenar o estado atual da FSM.
    reg [2:0] state = INIT;

    // Contador de 32 bits usado como um temporizador.
    reg [31:0] counter = 0;

    // --- Bloco 1: Lógica do Temporizador de 6 Segundos ---
    // Este bloco 'always' implementa um contador que avança a cada ciclo de clock.
    always @(posedge clk) begin
        // O contador avança até atingir 300.000.000.
        // Assumindo um clock de 2 MHz:
        // 10.000.000 ciclos / 2.000.000 ciclos/seg = 5 segundos.
        if (counter < 10000001)
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
            INIT:         begin state <= (RST) ? WAIT_PRESS : BLOCK; end

            // Fica bloqueado até que o timer de 6s expire (timeout) ou S1 seja pressionado.
            BLOCK:        begin state <= (counter == 10000000) ? INCREMENT : (RST) ? WAIT_PRESS : state; end

            // Espera o botão S1 ser solto. Se o timer de 6s expirar, reinicia a FSM.
            WAIT_PRESS:   begin state <= (counter == 10000000) ? INCREMENT : (~RST) ? WAIT_UNPRESS : state; end

            // Após S1 ser solto, espera que seja pressionado novamente para iniciar a contagem.
            WAIT_UNPRESS: begin state <= (counter == 10000000) ? INCREMENT : (RST) ? WAIT_TIMER : state; end

            // Uma vez acionado, espera o contador chegar a 6 segundos.
            // Se chegar, avança para o estado de reset.
            WAIT_TIMER:   begin state <= (counter == 10000000) ? RESET : state; end

            // Estado de ação: dura apenas um ciclo de clock e então retorna ao início.
            INCREMENT:    state <= INIT;
				RESET:    	  state <= INIT;
        endcase
    end

    // --- Bloco 3: Lógica de Saída ---
    // Este bloco controla a ação principal do módulo: o incremento do contador P.
    always @(posedge clk) begin
        // O registrador de saída 'P' só é incrementado quando a FSM
        // entra no estado 'INCREMENT'.
		  // E é zerado quando P = 200
        if (state == INCREMENT)
				if (P == 200)
					P = 0;
				else
					P = P + 1;
		  // Reseta a saída P
		  else if (state == RESET)
				P = 0;
    end

endmodule
