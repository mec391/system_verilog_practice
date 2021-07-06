/* systemverilog practice - 7/5/2021

*/

/*one bit adder w/ carry - gate level using primatives
primitive syntax:
	<gate type> <delay> cinstance name>  (<outputs>,  <inputs>);

 <delay> is a propogation delay that increases the time from a change on a gate into to a change in a gate output
   two delays means that one is for if input is transitioning from 0 to 1 (left) or 1 to 0 (right)
*/

module gate_adder(
input wire a, b, ci,
output wire sum, co
	);
timeunit 1ns; timeprecision 1ns;

wire n1, n2, n3;

xor xor0(n1, a, b);
and and0(n2, a, b);
and and1(n3, n1, ci);
xor #1.3 xor1(sum, n1, ci);
or #(1.5, 1.8) or0(co, n3, n2);

endmodule : gate_adder

// one bit adder w/ carry - RTL level 

module rtl_adder(
input logic a, b, ci,
output logic sum, co
	);

assign {co, sum} = a + b + ci;
endmodule : rtl_adder

//32 bit adder/subtractor with synchronous logic
module rtl_add_sub(
input logic clk,
input logic mode,
input logic [31:0] a,
input logic [31:0] b,
output logic [31:0] sum
	);
always_ff@(posedge clk)begin
if(mode == 0) sum <= a+b;
else sum <= a-b;
end

endmodule : rtl_add_sub

//testbench for 32 bit adder/subtractor
module rtl_add_sub_TB(
output logic [31:0] a,
output logic [31:0] b,
output logic mode,
input logic [31:0] sum,
input logic clk
);

timeunit 1ns; timeprecision 1ns;

//generate stimulus
initial begin
repeat(10) begin
@(negedge clk) ;
void'(std::randomize(a) with {a >= 10; a <= 20;});
void'(std::randomize(b)with {b <= 10;});
void'(std::randomize(mode));
@(negedge clk) check_results;
end
@(negedge clk) $finish;
end

//verify results
task check_results;
$display("At %0d: \t a=%0d b=%0d mode=%b sum=%0d", $time, a, b, mode, sum);
case(mode)
1'b0: if (sum !== a + b)
$error("expected sum = %0d", a + b);
1'b1: if(sum !== a - b)
$error("expected sum = %0d", a - b);
endcase 
endtask

endmodule : rtl_add_sub_TB

//top module for combining the previous testbench and UUT
module rtl_add_sub_top;
timeunit 1ns; timeprecision 1ns;
logic [31:0] a, b;
logic mode;
logic [31:0] sum;
logic clk;

test test(.*); //autoroutes if signals have same name and word size
rtl_add_sub dut(.*); // " "

initial begin
	clk <= 0;
	forever #5 clk = ~clk;
end
endmodule : rtl_add_sub_top



