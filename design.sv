// Code your design here

//STATE MACHINE CODES
//alag alag states of processor
`define fetch1 0 
`define fetch2 1 
`define decode 2 
`define NOT1 3
`define execute1 4
`define execute2 5
`define read1 6
`define write1 7
`define read2 8
`define write2 9
`define branch1 10
`define branch2 11
`define stop 12
`define buffer 13

//OPCODES     
`define LD 0
`define ST 1
`define MI 2
`define MR 3
`define SUM 4
`define SB 5
`define ANR 6
`define CM 7
`define ORR 8
`define ORI 9
`define XRR 10
`define XRI 11
`define SMI 12
`define SBI 13
`define ANI 14
`define CMI 15

//General purpose registers
`define R0 0
`define R1 1
`define R2 2
`define R3 3

//load only a control signal
//load = high then data load kar rhe hai

module register(clk,reset,in,load,out);
   
 input clk,reset;
 input [7:0] in;
 input load;
 
 output [7:0] out;
 
 reg [7:0] out;
 
 always @(posedge clk,posedge reset)
 begin
 if(reset)
 out <= 0;
 else if(load)
 out <= in;
 else
 out <= out;
 end

endmodule


module gp_registers(clk,reset,in,load0,load1,load2,load3,out0,out1,out2,out3);//general purpose registers
   
 input clk,reset;
 input [7:0] in;
 input load0,load1,load2,load3;
 
  output [7:0] out0,out1,out2,out3;//corresponds to R0, R1, R2, R3
 
 reg [7:0] out0,out1,out2,out3;
 
 always @(posedge clk,posedge reset)
 begin
 if(reset) begin
 out0 <= 0;
 out1 <= 0;
 out2 <= 0;
 out3 <= 0;
 end
 else if(load0) begin
 out0 <= in;
 end
 else if(load1) begin
 out1 <= in;
 end
 else if(load2) begin
 out2 <= in;
 end
 else if(load3) begin
 out3 <= in;
 end
end

endmodule

// module memory(clk,IN,OUT,ADDR,write);

// input clk,write;
// input [7:0] IN;
// input [7:0] ADDR;

// output [7:0] OUT;

// reg [7:0] MEM [255:0];

// initial
// begin
//   $readmemb("testvalue.bin", MEM);
// end

// always @(posedge clk) 
// begin
// if(write)
// MEM[ADDR] = IN;
// end

// assign OUT = MEM[ADDR];
 
// endmodule

module program_counter(clk,reset,in,load,inc,out);

input clk,reset;
input [7:0] in;
input load,inc;

output [7:0] out;

reg [7:0] out;

always @(posedge clk,posedge reset)
begin
if(reset)
out <= 0;
else if(load)
out <= in;
  else if(inc)//if inc high then ek value se address badhani hai
out <= out + 1'b1;
end

endmodule



module ALU (alu_in1,alu_in2,opcode,zero, carry,alu_out);

 input [7:0] alu_in1,alu_in2;
 input [3:0] opcode;
 
 output reg zero;
 output reg carry;
 output [7:0] alu_out;
 
 reg [7:0] alu_out;
 
  assign zero = ~|(alu_out);//jab alu out 0 hoga toh zero flag 1 ho jayega
 //nor
 //carry to be implemented- aage hai
 
  always @(*)//hamesha check karega irrespective
 begin
 case(opcode)
// `MR: aku_out=alu_in1;
`SUM: {carry,alu_out} = alu_in1 + alu_in2;
`SB: {carry,alu_out} = alu_in2 - alu_in1; 
`ANR: alu_out = alu_in1 & alu_in2;
`CM: begin
    if(alu_in1 == alu_in2) alu_out=8'b0;
    else if(alu_in1> alu_in2) 
        begin 
            carry=0;
            alu_out=8'b1;
        end
    else carry=1;
end
`ORR: alu_out=alu_in1 | alu_in2;
`ORI: alu_out=alu_in1 | alu_in2;
`XRR: alu_out=alu_in1 ^ alu_in2;
`XRI: alu_out=alu_in1 ^ alu_in2;
`SMI: {carry,alu_out} = alu_in1 + alu_in2;
`SBI: {carry,alu_out} = alu_in2 - alu_in1;
`ANI: alu_out = alu_in1 & alu_in2;
`CMI: begin
    if(alu_in1 == alu_in2) alu_out=8'b0;
    else if(alu_in1> alu_in2) 
        begin 
            carry=0;
            alu_out=8'b1;//so that zero flag low ho jaye
        end
    else carry=1;
end
 default: alu_out = 0;
 endcase
 end

endmodule




module processor(clk,reset,Mem_IN,Mem_OUT,Mem_ADDR,write, zero, carry, error);
  


input clk,reset;

input [7:0] Mem_OUT;

output [7:0] Mem_IN,Mem_ADDR;
output write;
output error;
wire [2:0] sel_BUS;
//changed

output wire zero; 
output wire carry;
reg [1:0]  flag;
reg [7:0] instruction;
wire [7:0] inst_dummy;
  wire [3:0] opcode = instruction[7:4];//7,6,5,4 of instruction array 
  reg [7:0] inst_add;
wire [7:0] alu_in1,alu_in2,alu_out;
wire [7:0] pc_OUT;
wire [7:0] R0_out,R1_out,R2_out,R3_out;
wire [7:0] bus;
              
reg [3:0] state, next_state;
reg load_OP1,load_OP2,load_AR,load_IR,load_flag,load_PC;
reg inc_PC,load_R0,load_R1,load_R2,load_R3;
reg error;
reg write; 

reg sel_MEM, sel_PC, sel_ALU, sel_inst;
reg sel_R0, sel_R1, sel_R2, sel_R3;

  reg [1:0] dest; //rd 2-bit
  reg [1:0] src;//rs 2-bit
// changed

ALU alu (alu_in1,alu_in2,opcode,zero,carry,alu_out);
register OP1 (clk,reset,bus,load_OP1,alu_in1);
register OP2 (clk,reset,bus,load_OP2,alu_in2);
register IR (clk,reset,bus,load_IR,inst_dummy);
register AR (clk,reset,bus,load_AR,Mem_ADDR);
program_counter PC (clk,reset,bus,load_PC,inc_PC,pc_OUT);
gp_registers GP (clk,reset,bus,load_R0,load_R1,load_R2,load_R3,R0_out,R1_out,R2_out,R3_out);


assign Mem_IN = bus;//8 cases hai bus ko chalane ke
  //ek hi cheez karegi bus at a time so usko choose karne ke liye cases bana rhe hai

  
  //directly 2 codes ki jagah ek mein kar sakte hai like if sel mem = 1 then bus = mem out
assign sel_BUS = sel_MEM ? 3'b000 :
                  sel_R0 ? 3'b001 :
                  sel_R1 ? 3'b010 :
                  sel_R2 ? 3'b011 :
                  sel_R3 ? 3'b100 :
                  sel_PC ? 3'b101 :
                 sel_ALU ? 3'b110 :
                 sel_inst ? 3'b111: 3'bx;
  
  //sel bus multiplexer hai kind of
                 
assign bus = (sel_BUS == 3'b000) ? Mem_OUT :
             (sel_BUS == 3'b001) ? R0_out :
             (sel_BUS == 3'b010) ? R1_out :
             (sel_BUS == 3'b011) ? R2_out :
             (sel_BUS == 3'b100) ? R3_out :
             (sel_BUS == 3'b101) ? pc_OUT :
             (sel_BUS == 3'b110) ? alu_out :
             (sel_BUS == 3'b111) ? inst_add: 8'bx;       

  
  //khud daala hai behen ke lode ne
  //dummy input diya hai toh dummy instruction follow karega
always@(inst_dummy or posedge clk) begin
    instruction=inst_dummy;
end 
  

always @(posedge clk) begin
if(reset) begin
flag <= 2'b0;
end
  else if(load_flag) begin//agaar load flag hai high then flag mein concatenate hoke dono zero and carry flag ki values aa jaengi 
flag <= {zero, carry};
end
end
      
always @(posedge clk)
begin
  if(reset) //sirf initialize karne ke liye
state <= `fetch1;//fetch1 default state hai kind of shayad
else
state <= next_state;
end
    
  always @(state or opcode or instruction or flag)//jab bhi kuch change hoga inn charo mein se then yeh sab initialize ho jayenge
begin
load_OP1 = 0;
load_OP2 = 0;
load_PC = 0;
inc_PC = 0;
load_IR = 0;
load_AR = 0;
load_flag = 0;
load_R0 = 0;
load_R1 = 0;
load_R2 = 0;
load_R3 = 0;
sel_PC = 0;
sel_MEM = 0;
sel_ALU = 0;
sel_R0 = 0;
sel_R1 = 0;
sel_R2 = 0;
sel_R3 = 0;
write = 0;
error = 0;
next_state = state;
case(state)

  
  //fetch cycle complete karne ke liye fetch1 and 2 hai
`fetch1: begin//agar fetch1 hai toh yeh sab hoga....pc se connect karta hai for first instruction
next_state = `fetch2;
sel_PC = 1;//select pc 1 kar diya because processor and pc connect hua and then load ar se load ho gya address that was in pc to address register mein
load_AR = 1;//load address register signal high kar diya
end //fetch1

  //ab address aa gya jahan pe instruction hai
  //ab voh address use karke instruction access karenge and then usko decode karenge in `decode
`fetch2: begin
next_state = `decode;
sel_MEM =1;//memory se connect kar diya processor ko and ir mein address mein jo hai address voh memory mein access karte hai and ir mein daal dete hai
load_IR = 1;//instruction register mein store hoga jo instuction mila hai after using its address
inc_PC = 1;//increase karenge pc because kaam ho gya uss instruction address ka
end //fetch2

  //decode karenge ab
`decode:
  if(&(instruction)==1) next_state=`buffer;//halt (11111111) ke liye hai alag se state buffer...bitwise & hai from right to left
else begin
  case(opcode)//abhi opcode is of the binary form 8-bit jes tb.bin mein hai
`LD:  begin//agar 0 hai binary to decimal mein toh LD hai opcode
  dest = instruction[3:2];//instruction array ke 2 msb leftmost 2 after 7,6,5,4 instruction ke opcode mein chale gye
  src = instruction[1:0];//instruction array ke rightmost 2
  inst_add= {dest[1],dest[1],dest[1],dest[1],dest,src};//imm ko 8 bit mein convert karne ke liye dest ka msb....instantaneous address
        next_state = `read2;//memory se read karne ke liye that is to be loaded in accumulator
        sel_inst = 1;//select instantaneous....ar mein instataneous address daalna hai isliye high kar diya 
        load_AR = 1;//load kar diya ar
dest=2'b00;//destination 0 kar diya....assuming R0 ko accumulator
        end 
// load from instanteous address to RO
`ST:   begin//same as ld bas read ki jagah write karna hai opposite hai of ld as memory mein write kar rhe hai accumulator ka data
   dest = instruction[3:2];
	  src = instruction[1:0];
    inst_add= {dest[1],dest[1],dest[1],dest[1],dest,src};
        next_state = `write2;
        sel_inst = 1;
        load_AR = 1;
  src=2'b00;//isme source 0 kar diya rather than destination because voh hamesha accumulator ka hi lega
        end 
// store from R0 to instantaneous add
`MI: begin//move immediate
   dest = instruction[3:2];
	  src = instruction[1:0];
  inst_add= {src[1],src[1],src[1],src[1],src[1],src[1],src};//address bana rhe hai 6-bit extend karke
    next_state = `read2;
        sel_inst = 1;
        load_AR = 1;
    end 
`MR: begin
    next_state= `fetch1;
	  dest = instruction[3:2];
	  src = instruction[1:0];
  case(dest)//dest rd hai 2-bit toh 0,1,2,3 mein se hi ho sakta hai
        `R0: load_R0 = 1;
        `R1: load_R1 = 1;
        `R2: load_R2 = 1;
        `R3: load_R3 = 1;
        default: error = 1;//error check karne ke liye agar out of 0,1,2,3 kuch aur diya toh
    endcase  
  case(src)//same as dest rd
        `R0: sel_R0 = 1;
        `R1: sel_R1 = 1;
        `R2: sel_R2 = 1;
        `R3: sel_R3 = 1;
        default: error = 1;
    endcase 
end
`SUM, `SB, `ANR, `CM, `ORR, `XRR : begin//club kar diye non immediate....alu ki zaroorat hai
        next_state = `execute1;
        load_OP1 = 1;//buffer register ki tarah hai op1 and op2, operand 1
 		 dest = instruction[3:2];
		 src = instruction[1:0];
  case(src)//src because destination mein hi change karna hai
        `R0: sel_R0 = 1;
        `R1: sel_R1 = 1;
        `R2: sel_R2 = 1;
        `R3: sel_R3 = 1;
        default: error = 1;
        endcase
        end
`XRI,`SMI,`SBI,`ANI,`CMI, `ORI: begin//club kar diya immediate vale
  inst_add= {src[1],src[1],src[1],src[1],src[1],src[1],src};//address
    next_state = `buffer;//address se data uthane ke liye ek clock cycle extra lagegi alu mein bhejnse se pehle because memory mein jaake address pe jaana hoga
        sel_inst = 1;
        load_AR = 1;
    end 

default: next_state = `fetch1;//agar kuch bhi nhi tha opcode toh default hai ki next state fetch 1 hogi
endcase  //decode
end 

`buffer:begin
  if(&(instruction)==1) next_state=`buffer;//agar halt hai toh upar jese mention kiya hai 
else begin
next_state=`execute1;//ab as usual rd rs vala hoga process
load_OP1 =1;//operand 1 mein memory ka address daalna hai 
sel_MEM=1;//memory ka data use karna hai
end
end


`execute1: begin
next_state = `execute2;
load_OP2 = 1;//load the data of rd
  dest = instruction[3:2];
	  src = instruction[1:0];
  case(dest)//ab rs hai apne paas toh rd chahiye
`R0: sel_R0 = 1;
`R1: sel_R1 = 1;
`R2: sel_R2 = 1;
`R3: sel_R3 = 1;
default: error = 1;
endcase
end //execute1

`execute2: begin
next_state = `fetch1;//deafult becasuse khatam ho jaega
sel_ALU = 1;//ab alu se connect kar diya after getting rs and rd
load_flag = 1;//jo bhi flags the carry, zero vale jo change hue the voh latest flag register mein store kar liye
  dest = instruction[3:2];
	  src = instruction[1:0];
  if(opcode!=`CM && opcode!=`CMI) begin//kuch daalna nhi hota rd mein sirf flag change karna hota hai compare mein so include nhi karna inko
    case(dest)//alu se jo result aaega vo rd mein hi store karna hai
`R0: load_R0 = 1;
`R1: load_R1 = 1;
`R2: load_R2 = 1;
`R3: load_R3 = 1;
default: error = 1;
endcase
  end
end //execute2

  
  //use nhi ho rha 
`read1: begin//read 1 hai instruction address read karne ke liye
next_state = `read2;//read 2 hai actual instruction jo address ke andar hai voh read karne ke liye
inc_PC = 1;//isliye pc ko badhaya hai ek se
  //agar read 1 se read 2 jaa rhe hai toh pc + 1 hoga varna direct memory ko read karenge 
  dest = instruction[3:2];
	  src = instruction[1:0];
end //read1

  
  //use nhi ho rha
`write1: begin
dest = instruction[3:2];
	  src = instruction[1:0];
  next_state = `write2;
sel_MEM = 1;
load_AR = 1;
inc_PC = 1;
end //write1

`read2: begin
next_state = `fetch1;//default pe chala gya after the work is done
sel_MEM = 1;//memory se connect kar liya and utha rhe hai data that is selected from the ar
  
  case(dest)//memory se data utha liya and load kar diya respective rd mein
`R0: load_R0 = 1;
`R1: load_R1 = 1;
`R2: load_R2 = 1;
`R3: load_R3 = 1;
default: error = 1;
endcase
end //read2

`write2: begin
next_state = `fetch1;//default chala gya
write = 1;//write ka control signal high kar diya
  
  case(src)//kahan write karna hai voh iss se pta chalega
`R0: sel_R0 = 1;
`R1: sel_R1 = 1;
`R2: sel_R2 = 1;
`R3: sel_R3 = 1;
default: error = 1;
endcase
end //write2

default: next_state = `fetch1; 

endcase
end

endmodule
