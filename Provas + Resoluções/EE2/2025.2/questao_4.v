// módulo 'fsm_ecu', que implementa uma FSM de controle de um veículo
// condição anormal: veículo ligado (IG = 1) + alguma porta aberta (P1 = 0 | P2 = 0 | M = 0) -> sirene acionada a cada 1s, lanternas apagadas (LD = LE = 0)
// condição normal: veículo ligado (IG = 1) + todas as portas fechadas (P1 = P2 = M = 1) -> sirene desligada, lanternas ligadas (LD = LE = 1)
// porta aberta quando P1, P2 ou M = 0
module fsm_ecu(
    input RST,          // entrada de reset, ativo em 1
    input clk,          // clock principal (2 MHz)
    input IG,           // chave de ignição (1 = ligado)
    input P1,           // porta 1 (0 = aberta)
    input P2,           // porta 2 (0 = aberta)
    input M,            // porta M (0 = aberta)
    output reg S = 0,   // sirene (1 = ligada)
    output reg LD = 0,  // lanterna direita
    output reg LE = 0   // lanterna esquerda
);

    // --- parâmetros de estado ---
    parameter DESLIGADO = 0,        // veículo desligado (IG = 0 || RST = 1): tudo apagado
              NORMAL = 1,           // ligado e portas fechadas: lâmpadas acesas (LD = LE = 1)
              ALARME_LIGADO = 2,    // ligado com porta aberta: sirene ligada por 1 s
              ALARME_DESLIGADO = 3; // ligado com porta aberta: sirene desligada por 1 s

    // --- sinais internos ---
    // registrador de 2 bits para armazenar o estado atual da FSM
    reg [1:0] estado = DESLIGADO;

    // contador de 32 bits usado como temporizador
    reg [31:0] counter = 0;

    // alguma porta aberta
    wire portas_abertas = ~P1 | ~P2 | ~M;

    // --- bloco 1: temporizador de 1 segundo ---
    always @(posedge clk) begin
        // clock de 2 MHz: 2.000.000 * 1 (segundo) = 2.000.000 ciclos
        // zera fora dos estados de alarme e ao completar 1s
        if ((estado == DESLIGADO || estado == NORMAL) || counter == 2000000)
            counter <= 0;
        else
            counter <= counter + 1; // incrementa o contador em 1
    end

    // --- bloco 2: estados da FSM ---
    always @(posedge clk) begin
        // IG desligado ou reset: volta para DESLIGADO
        if (RST || !IG)
            estado <= DESLIGADO;
        else begin
            case (estado)
                // ligado: se alguma porta estiver aberta vai para o alarme, senão vai para NORMAL
                DESLIGADO: begin
                    if (portas_abertas)
                        estado <= ALARME_LIGADO;
                    else
                        estado <= NORMAL;
                end

                // portas fechadas: se alguma abrir, entra no alarme
                NORMAL: begin
                    if (portas_abertas)
                        estado <= ALARME_LIGADO;
                end

                // alarme com sirene ligada: se fechar as portas volta ao NORMAL
                // se passou 1s, desliga a sirene
                ALARME_LIGADO: begin
                    if (!portas_abertas)
                        estado <= NORMAL;
                    else if (counter == 2000000)
                        estado <= ALARME_DESLIGADO;
                end

                // alarme com sirene desligada: se fechar as portas volta ao NORMAL
                // se passou 1s, liga a sirene
                ALARME_DESLIGADO: begin
                    if (!portas_abertas)
                        estado <= NORMAL;
                    else if (counter == 2000000)
                        estado <= ALARME_LIGADO;
                end

                default: estado <= DESLIGADO;
            endcase
        end
    end

    // --- bloco 3: saídas ---
    always @(posedge clk) begin
        case (estado)
            // tudo apagado
            DESLIGADO: begin
                S  <= 0;
                LD <= 0;
                LE <= 0;
            end

            // condição normal: lanternas ligadas, sirene desligada
            NORMAL: begin
                S  <= 0;
                LD <= 1;
                LE <= 1;
            end

            // condição anormal: sirene ligada, lanternas apagadas
            ALARME_LIGADO: begin
                S  <= 1;
                LD <= 0;
                LE <= 0;
            end

            // condição anormal: sirene desligada, lanternas apagadas
            ALARME_DESLIGADO: begin
                S  <= 0;
                LD <= 0;
                LE <= 0;
            end

            default: begin
                S  <= 0;
                LD <= 0;
                LE <= 0;
            end
        endcase
    end

endmodule