`timescale 1ns / 1ps

module tb_UART();

    // Parameters - match your UART module
    parameter CLK_FREQ_HZ = 50_000_000;
    parameter BAUD = 115200;
    parameter DBITS = 8;
    parameter STOP_BIT = 1;
    
    // Calculate timing parameters
    localparam CLK_PERIOD = 1_000_000_000 / CLK_FREQ_HZ; // in ns
    localparam BAUD_PERIOD = 1_000_000_000 / BAUD;       // in ns
    localparam BAUD_DIV = CLK_FREQ_HZ / BAUD;
    
    // DUT signals
    logic clk, rst_n;
    logic [DBITS-1:0] tx_data;
    logic tx_start;
    logic tx_on;
    logic tx_serial_out;
    logic rx_serial_in;
    logic rx_on;
    logic [DBITS-1:0] rx_data;
    logic framing_error;
    
    // Test variables
    logic [DBITS-1:0] test_data;
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Instantiate DUT
    UART #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD(BAUD),
        .DBITS(DBITS),
        .STOP_BIT(STOP_BIT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_on(tx_on),
        .tx_serial_out(tx_serial_out),
        .rx_serial_in(rx_serial_in),
        .rx_on(rx_on),
        .rx_data(rx_data),
        .framing_error(framing_error)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Connect TX to RX for loopback testing
    assign rx_serial_in = tx_serial_out;
    
    // Test stimulus
    initial begin
        // Initialize
        $display("=== UART Testbench Starting ===");
        $display("Clock Frequency: %0d Hz", CLK_FREQ_HZ);
        $display("Baud Rate: %0d", BAUD);
        $display("Data Bits: %0d", DBITS);
        $display("Clock Period: %0d ns", CLK_PERIOD);
        $display("Baud Period: %0d ns", BAUD_PERIOD);
        $display("Baud Divider: %0d", BAUD_DIV);
        
        rst_n = 0;
        tx_start = 0;
        tx_data = 8'h00;
        
        // Reset sequence
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(10) @(posedge clk);
        
        $display("\n=== Starting Tests ===");
        
        // Wait for baud generator to stabilize
        $display("Waiting for baud tick to synchronize...");
        repeat(BAUD_DIV + 10) @(posedge clk);
        
        // Test 1: Basic transmission tests
        test_basic_transmission(8'h55);
        test_basic_transmission(8'hAA);
        test_basic_transmission(8'h00);
        test_basic_transmission(8'hFF);
        
        // Test 2: Additional pattern tests
        test_basic_transmission(8'h01);
        test_basic_transmission(8'h02);
        test_basic_transmission(8'h04);
        test_basic_transmission(8'h08);
        
        // Final results
        $display("\n=== Test Results ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED! ***");
        end else begin
            $display("*** SOME TESTS FAILED! ***");
        end
        
        $finish;
    end
    
    // Task: Basic transmission test
    task test_basic_transmission;
        input [DBITS-1:0] data;
        integer timeout_count;
        begin
            test_count = test_count + 1;
            $display("\nTest %0d: Transmitting 0x%02X", test_count, data);
            
            // Send data - hold tx_start for multiple clock cycles
            tx_data = data;
            tx_start = 1;
            repeat(5) @(posedge clk);  // Hold tx_start for 5 clock cycles
            tx_start = 0;
            
            $display("  TX start signal sent at time %0t", $time);
            
            // Wait for transmission to start with timeout
            timeout_count = 0;
            while (tx_on != 1 && timeout_count < (BAUD_DIV * 5)) begin
                @(posedge clk);
                timeout_count = timeout_count + 1;
            end
            
            if (tx_on != 1) begin
                $display("  ERROR: TX never started!");
                fail_count = fail_count + 1;
                return;
            end
            
            $display("  TX started at time %0t", $time);
            
            // Wait for transmission to complete
            timeout_count = 0;
            while (tx_on != 0 && timeout_count < (BAUD_DIV * 15)) begin
                @(posedge clk);
                timeout_count = timeout_count + 1;
            end
            
            if (tx_on != 0) begin
                $display("  ERROR: TX never completed!");
                fail_count = fail_count + 1;
                return;
            end
            
            $display("  TX completed at time %0t", $time);
            
            // Wait for reception to complete with timeout
            timeout_count = 0;
            while (rx_on != 1 && timeout_count < (BAUD_DIV * 15)) begin
                @(posedge clk);
                timeout_count = timeout_count + 1;
            end
            
            if (rx_on != 1) begin
                $display("  ERROR: RX never completed!");
                fail_count = fail_count + 1;
                return;
            end
            
            @(posedge clk);
            $display("  RX completed at time %0t", $time);
            
            // Check results
            if (rx_data == data && framing_error == 0) begin
                $display("  PASS: Received 0x%02X (expected 0x%02X)", rx_data, data);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: Received 0x%02X (expected 0x%02X), framing_error=%0b", 
                        rx_data, data, framing_error);
                fail_count = fail_count + 1;
            end
            
            // Wait before next test
            repeat(BAUD_DIV * 2) @(posedge clk);
        end
    endtask
    
    // Simple monitor for key events
    always @(posedge clk) begin
        if (tx_start) 
            $display("Time: %0t | TX_START asserted, tx_data=0x%02X", $time, tx_data);
        if (tx_on && $past(!tx_on)) 
            $display("Time: %0t | TX_ON went high", $time);
        if (!tx_on && $past(tx_on)) 
            $display("Time: %0t | TX_ON went low", $time);
        if (rx_on && $past(!rx_on)) 
            $display("Time: %0t | RX_ON went high, rx_data=0x%02X", $time, rx_data);
    end
    
    // Timeout watchdog
    initial begin
        #(BAUD_PERIOD * 1000); // Reasonable timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule