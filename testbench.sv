// Code your testbench here
// or browse Examples
`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module processor_tb;

    reg clk, reset ;
    reg [7:0]Mem_OUT;
    wire [7:0]Mem_IN, Mem_ADDR;
    wire write;
    wire zero, carry, error;

    reg [7:0] MEM [255:0];
    initial
    begin
      $readmemb("tb.bin", MEM);
      clk=1'b0;
    end

    processor p1 (clk, reset,Mem_IN,Mem_OUT,Mem_ADDR,write, zero, carry, error);
    
    always #1 clk = !clk;//clock define har time baad time change

    always @(posedge clk) 
    begin
      if(write)//agar write (control signal) high hai toh memomry mein write
        MEM[Mem_ADDR] = Mem_IN;
    end

  assign Mem_OUT = MEM[Mem_ADDR];//jo le rhe hai stored in mem out

    initial 
        begin
            $dumpfile("processor.vcd");
            $dumpvars(0,processor_tb);
          	reset=1;//1 se clear
          	#10 reset=0;//iss se karne se chal rha tha 
          //0 se start
          	
            // values for a and b
        end
  initial #200 $finish;
endmodule
