`timescale 1ps / 1ps

module vc_Reg
#(
  parameter p_nbits = 32,
  parameter p_reset_value = 0
)(
  input  wire clk, // Clock input
  input  wire reset,
  output reg [p_nbits-1:0] q,   // Data output
  input  wire [p_nbits-1:0] d    // Data input
);

  always @( posedge clk )
    q <= reset? p_reset_value : d;

endmodule

module mul_add
#(
  parameter p_nbits = 32,
  parameter p_reset_value = 0
)(
  input wire clk1,
  input wire clk2,
  input wire reset,
  input wire [p_nbits-1:0]a,
  input wire [p_nbits-1:0]b,
  output reg [p_nbits-1:0]out
);

  // Stage 1
  wire [p_nbits-1:0]a_s1;
  wire [p_nbits-1:0]b_s1;
  reg [p_nbits-1:0]out_s1;

  // Stage 2
  wire [p_nbits-1:0]in_s2;
  wire [p_nbits-1:0]acc_s2;

  // Sage 1  
  vc_Reg #(p_nbits, p_reset_value) areg_stage1
  (
   .clk ( clk1 ),
   .reset ( reset ),
   .q ( a_s1 ),
   .d ( a )
  );

  vc_Reg #(p_nbits, p_reset_value) breg_stage1
  (
   .clk ( clk1 ),
   .reset ( reset ),
   .q ( b_s1 ),
   .d ( b )
  );

  // Stage 2
  vc_Reg #(p_nbits, p_reset_value) accreg_stage2
  (
   .clk ( clk2 ),
   .reset ( reset ),
   .q ( acc_s2 ),
   .d ( out )
  );

  vc_Reg #(p_nbits, p_reset_value) outreg_stage2
  (
   .clk ( clk2 ),
   .reset ( reset ),
   .q ( in_s2 ),
   .d ( out_s1 )
  );

  // Stage 1
  always@(a_s1,b_s1)  begin
    out_s1 = a_s1 * b_s1;
  end

  // Stage 2
  always@(acc_s2, in_s2) begin
    out = acc_s2 + in_s2;
  end

endmodule
/*
module delay 
#( parameter del
)
(
  input wire in,
  output reg out
);  

  always @(in) begin
    #del out = in;
  end

endmodule
*/
module test;
  reg R1b, R2b;
  wire L2b, Ldb;
  reg trigger;
  reg nsR, npR;
  reg clk1;
  reg clk2;
  integer counter = 0;
 // wire clk1;
 // wire clk2;
  reg reset;
  reg [ 9 : 0 ] a;
  reg [ 9 : 0 ] b;
  wire [ 9 : 0 ] out;

  integer a_in[4:0];
  integer b_in[4:0];

  mul_add #( 10, 0 )dut (
    .clk1 ( clk1 ),
    .clk2 ( clk2 ),
    .reset ( reset ),
    .a ( a ),
    .b ( b ),
    .out ( out )
  );


  initial begin
     $prsim("clock.prs");

//     $to_prsim ("L2b", "L2.b");
//     $to_prsim ("Ldb", "Ld.b");
     $to_prsim ("nsR", "g._sReset");
     $to_prsim ("npR", "g._pReset");

     $from_prsim ( "L1.a", "clk1" );
     $from_prsim ( "L2.a", "clk2" );
//     $from_prsim ( "R1.b", "R1b" );
//     $from_prsim ( "R2.b", "R2b" );
     $from_prsim ( "L1.b", "trigger" );

  end
/*
  delay #(100) dR1b( .in(R1b),
	      .out(L2b)
	    );
  delay #(100) dR2b( .in(R2b),
	      .out(Rdb)
            );
*/
  initial begin

    counter = 0;
    a_in[0] = 1;
    a_in[1] = 3;
    a_in[2] = 10;
    a_in[3] = 2;
    a_in[4] = 5;

    b_in[0] = 2;
    b_in[1] = 10;
    b_in[2] = 1;
    b_in[3] = 12;
    b_in[4] = 13;

    nsR = 0;
    #90 npR = 1;
    #90 npR = 0;
    #90 npR = 1;
    #90 nsR <= 1;
    #30 reset = 1;
    #100 reset = 0;
    #1000 $finish;  
  end
 
  always @(posedge trigger) begin
          a = a_in[counter];
          b = b_in[counter]; 
  end
  
  always @(posedge clk1) begin
       if ( reset == 0 ) begin
          counter = counter + 1;
       end
  end 

  initial begin
    $dumpfile("mul_add.vcd");
    $dumpvars;
  end

  initial begin
    $display("\t\ttime,\treset,\tclk1,\tclk2,\ta,\tb,\t\out");
    $monitor("%d,\t%b,\t%b,\t%d,\t%d,\t%d",$time,reset,clk1,clk2,a,b,out);
  end


endmodule 
