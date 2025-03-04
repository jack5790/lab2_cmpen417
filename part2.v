`timescale 1ns / 1ps

module part2 #(parameter AWIDTH = 18, BWIDTH = 18)(
    input wire clk,
    input wire signed [17:0] ar, ai,
    input wire signed [17:0] br, bi,
    output wire signed [(AWIDTH+BWIDTH)-1:0] pr, pi
);
    
    // Pipeline registers
    reg signed [(AWIDTH)-1:0] Ain,ain;
    reg signed [(BWIDTH)-1:0] Bin,bin;
    reg signed [(AWIDTH+BWIDTH)-1:0] ABmul, abmul, Abmul, aBmul;
    reg signed [(AWIDTH+BWIDTH)-1:0] sum_real, sum_imag;
    
    initial begin
        Ain = 0;
        ain = 0;
        Bin = 0;
        bin = 0;
    end
    
    always @(posedge clk) begin
        // Input Registers
        Ain <= ar;
        ain <= ai;
        Bin <= br;
        bin <= bi;
        
        // Multiplications
        ABmul <= Ain * Bin; 
        abmul <= ain * bin;  
        Abmul <= Ain * bin;  
        aBmul <= ain * Bin;  

        // Summation 
        sum_real <= ABmul - abmul;  // Real part
        sum_imag <= Abmul + aBmul;  // Imaginary part
    end
    
    // Output assignment
   
    assign pr = sum_real;
    assign pi = sum_imag;
    
endmodule
