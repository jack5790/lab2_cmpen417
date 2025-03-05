`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2025 03:10:32 PM
// Design Name: 
// Module Name: part3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Complex number multiplier with DSP slices for 32-bit numbers
//////////////////////////////////////////////////////////////////////////////////

module part3 # (
      parameter AWIDTH = 32,
      parameter BWIDTH = 32
  )(
      input clk,
      input signed [AWIDTH-1:0] ar, ai,      
      input signed [BWIDTH-1:0] br, bi,      
      output signed [(AWIDTH + BWIDTH - 1):0] pr, pi  
  );
  
  // Break inputs into high and low parts
  reg signed [15:0] ar_high, ai_high, br_high, bi_high;
  reg signed [16:0] ar_low, ai_low, br_low, bi_low;
  
  // Partial products
  reg signed [31:0] ar_br_high, ai_bi_high;
  reg signed [31:0] ar_br_low, ai_bi_low, ar_br_hl, ar_br_lh, ai_bi_hl, ai_bi_lh;
  reg signed [31:0] ar_bi_high, ar_bi_low, ar_bi_hl, ar_bi_lh;
  reg signed [31:0] ai_br_high, ai_br_low, ai_br_hl, ai_br_lh;
  
  // Aligned results (final sum after all multiplications)
  reg signed [63:0] sum_real, sum_imag;
  
  // Pipeline stage 1: Split inputs into high and low 16-bit parts
  always @(posedge clk) begin
      ar_high <= ar[31:16];
      ar_low  <= {1'b0, ar[15:0]}; // zero-extended lower 16 bits
      ai_high <= ai[31:16];
      ai_low  <= {1'b0, ai[15:0]}; // zero-extended lower 16 bits
      br_high <= br[31:16];
      br_low  <= {1'b0, br[15:0]}; // zero-extended lower 16 bits
      bi_high <= bi[31:16];
      bi_low  <= {1'b0, bi[15:0]}; // zero-extended lower 16 bits
  end
  
  // Pipeline stage 2: Perform multiplications and accumulate
  always @(posedge clk) begin
      // Multiplications for the real part components
      ar_br_high <= ar_high * br_high;  // High x High
      ar_br_low  <= ar_low  * br_low;    // Low x Low
      ar_br_hl   <= ar_high * br_low;    // High x Low
      ar_br_lh   <= ar_low  * br_high;   // Low x High
  
      // Multiplications for the imaginary part components
      ai_bi_high <= ai_high * bi_high;  // High x High
      ai_bi_low  <= ai_low  * bi_low;    // Low x Low
      ai_bi_hl   <= ai_high * bi_low;    // High x Low
      ai_bi_lh   <= ai_low  * bi_high;   // Low x High
  
      // Multiplications for cross terms (for the imaginary result)
      ar_bi_high <= ar_high * bi_high;  // High x High
      ar_bi_low  <= ar_low  * bi_low;    // Low x Low
      ar_bi_hl   <= ar_high * bi_low;    // High x Low
      ar_bi_lh   <= ar_low  * bi_high;   // Low x High
  
      ai_br_high <= ai_high * br_high;  // High x High
      ai_br_low  <= ai_low  * br_low;    // Low x Low
      ai_br_hl   <= ai_high * br_low;    // High x Low
      ai_br_lh   <= ai_low  * br_high;   // Low x High
  end
  
  // Pipeline stage 3: Combine the partial products.
  always @(posedge clk) begin
      sum_real <= ({{32{ar_br_high[31]}}, ar_br_high} << 32) +
                  ({{16{ar_br_hl[31]}}, ar_br_hl} << 16) +
                  ({{16{ar_br_lh[31]}}, ar_br_lh} << 16) +
                  ar_br_low -
                  (
                  ({{32{ai_bi_high[31]}}, ai_bi_high} << 32) +
                  ({{16{ai_bi_hl[31]}}, ai_bi_hl} << 16) +
                  ({{16{ai_bi_lh[31]}}, ai_bi_lh} << 16) +
                  ai_bi_low
                  );
                  
      sum_imag <= ({{32{ar_bi_high[31]}}, ar_bi_high} << 32) +
                  ({{16{ar_bi_hl[31]}}, ar_bi_hl} << 16) +
                  ({{16{ar_bi_lh[31]}}, ar_bi_lh} << 16) +
                  ar_bi_low +
                  ({{32{ai_br_high[31]}}, ai_br_high} << 32) +
                  ({{16{ai_br_hl[31]}}, ai_br_hl} << 16) +
                  ({{16{ai_br_lh[31]}}, ai_br_lh} << 16) +
                  ai_br_low;
  end
  
  // Output assignments.
  assign pr = sum_real;
  assign pi = sum_imag;

endmodule
