module UART #(
    parameter CLK_FREQ_HZ = 50_000_000,
    parameter BAUD = 115200,
    parameter DBITS = 8,
    parameter STOP_BIT = 1
)(
    input logic clk, rst_n,
    //transmitter interface 
    input logic [DBITS-1:0] tx_data,
    input logic tx_start,
    output logic tx_on,
    output logic tx_serial_out,
    //receiver interface 
    input logic rx_serial_in,
    output logic rx_on,
    output logic [DBITS-1:0] rx_data,
    output logic framing_error
);
    //Baudrate generator 
    localparam integer BAUD_DIV = CLK_FREQ_HZ/BAUD;
    localparam integer CNTW = $clog2(BAUD_DIV);
    logic [CNTW-1:0] baud_cnt;
    logic baud_tick;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
            baud_cnt <= 0;
        end else begin
            if (baud_cnt == BAUD_DIV - 1) baud_cnt <= 0;
            else baud_cnt <= baud_cnt + 1;
        end
    end 
    
    assign baud_tick = (baud_cnt == BAUD_DIV - 1);
    
    //TRANSMITTER
    typedef enum logic [2:0]{
        TX_IDLE,
        TX_START,
        TX_DATA,
        TX_STOP
    } tx_state_t;
    
    tx_state_t tx_state;
    logic [3:0] tx_bitcnt;
    logic [DBITS-1:0] tx_shift;
    
    always_ff @(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin
            tx_state <= TX_IDLE;
            tx_serial_out <= 1'b1;
            tx_on <= 0;
        end else begin
            if(baud_tick) begin 
                case(tx_state)
                TX_IDLE: if(tx_start) begin 
                    tx_shift <= tx_data;
                    tx_bitcnt <= 0;
                    tx_on <= 1;
                    tx_serial_out <= 0;
                    tx_state <= TX_START;
                end 
                TX_START: begin
                    tx_serial_out <= 0;  // Start bit
                    tx_state <= TX_DATA;
                end
                TX_DATA: if (tx_bitcnt < DBITS) begin 
                    tx_serial_out <= tx_shift[0];
                    tx_shift <= tx_shift >> 1;
                    tx_bitcnt <= tx_bitcnt + 1;
                end else begin 
                    tx_serial_out <= 1;
                    tx_state <= TX_STOP;
                end 
                TX_STOP: begin
                    tx_serial_out <= 1;  // Stop bit
                    tx_state <= TX_IDLE;
                    tx_on <= 0;
                end
                endcase
            end
            if(tx_state == TX_IDLE) tx_on <= 0;
        end
    end 
    
    //RECEIVER 
    typedef enum logic [1:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP
    } rx_state_t;
    
    rx_state_t rx_state;
    logic [$clog2(DBITS):0] rx_bitcnt;
    logic [DBITS-1:0] rx_shift;
    logic [2:0] sample_cnt;
    logic sample_mid;
    
    always_ff @(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin 
            rx_state <= RX_IDLE;
            sample_cnt <= 0;
            framing_error <= 0;
            rx_on <= 0;
        end else begin
            rx_on <= 0;  // Default value
            if(baud_tick) begin 
                case(rx_state) 
                RX_IDLE: if(!rx_serial_in) begin 
                    sample_cnt <= 0;
                    rx_state <= RX_START;
                end 
                RX_START: if(sample_cnt == 3) begin 
                    rx_state <= RX_DATA;
                    rx_bitcnt <= 0;
                    sample_cnt <= 0;
                end else sample_cnt <= sample_cnt + 1;
                RX_DATA: if(sample_cnt == 3) begin 
                    rx_shift <= {
                        rx_serial_in,
                        rx_shift[DBITS-1:1]
                    };
                    sample_cnt <= 0;
                    if(rx_bitcnt < DBITS - 1)
                        rx_bitcnt <= rx_bitcnt + 1;
                    else
                        rx_state <= RX_STOP;
                end else sample_cnt <= sample_cnt + 1;
                RX_STOP: if(sample_cnt == 3) begin
                    rx_on <= 1;
                    framing_error <= (rx_serial_in != 1);
                    rx_data <= rx_shift;
                    rx_state <= RX_IDLE;
                end else sample_cnt <= sample_cnt + 1;
                endcase
            end
        end
    end
endmodule










