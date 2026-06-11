// `timescale 1ns/1ns
module tb();
  
  // M3,M2,M1
  parameter ixONE = 0;
  parameter ixTWO = 1;
  parameter ixTHR = 2;
  
  logic [2:0] req; 
  logic [2:0] done;
  logic clk, rst;  // Input signals to the DUT.

  logic [7:0] mstate;
  logic [2:0] accmodule;
  logic [4:0] nb_interrupts;
  logic mod_priority;

  controller iDUT(.req(req), .done(done), .reset(rst), .clk(clk), .mstate(mstate), .accmodule(accmodule), .nb_interrupts(nb_interrupts), .mod_priority(mod_priority));
  bind controller functional_cov ctrl_funct_covg_inst(.req(req), .done(done), .reset(rst), .clk(clk), .mstate(mstate), .accmodule(accmodule), .nb_interrupts(nb_interrupts), .mod_priority(mod_priority));
  bind controller properties ctrl_sva_inst (.req(req), .accmodule(accmodule), .mstate(mstate), .clk(clk), .mod_priority(mod_priority), .reset(rst), .done(done)); 

  parameter PERIOD = 20;
  always begin
    #(PERIOD/2) clk = ~clk;
  end

  //cg_priority         cg_priority_inst;
  //cg_m1_high_priority cg_m1_high_priority_inst;
  //cg_m1_indef_access  cg_m1_indef_access_inst;

initial begin

  //cg_priority_inst = new;
  //cg_m1_high_priority_inst = new;
  //cg_m1_indef_access_inst = new;

  clk = 0;
  rst = 1;
  req = 3'b000;
  done = 3'b000;

  # PERIOD rst = 0;

  // [1] Module 1 requests and is done
  #2 req = 'b001;
  #PERIOD req = 'b000;
  #(3*PERIOD) done = 'b001;
  #(PERIOD/2) done = 'b000;
  
  // [2] Module 1 requests, module 2 tries to interupts but fails.
  # 2 req = 3'b001;
  # PERIOD req = 3'b000;
  # (2*PERIOD) req = 3'b010;
  # PERIOD req = 3'b000;

  # PERIOD done = 3'b001;
  # (PERIOD) done = 3'b000;

  // [3] Module 2 requests, module 1 interupts.
  # (2*PERIOD) req = 3'b010;
  # PERIOD req = 3'b000;

  # PERIOD req = 3'b001;
  # PERIOD req = 3'b000;

  # (3*PERIOD) done = 3'b001;
  # (PERIOD) done = 3'b000;

  // [4] Module 2 and module 3 both request, access given to module 2.
  # (2*PERIOD) req = 3'b110;
  # PERIOD req = 3'b000;

  # 15 done = 3'b010;
  # PERIOD done = 3'b000;

  // [5] Module 2 and module 3 both request again, access given to module 3.

  # PERIOD req = 3'b110;
  # PERIOD req = 3'b000;

  # (1.5*PERIOD) done = 3'b110;
  # (PERIOD) done = 3'b000;

  // [6] Module 2 and module 3 both request again, access given to module 2.
  # PERIOD req = 3'b110;
  # PERIOD req = 3'b000;  
  # (1.5*PERIOD) done = 3'b110;
  # (PERIOD) done = 3'b000;

  // [6] Module 2 and module 3 both request again, access given to module 3.
  # PERIOD req = 3'b110;
  # PERIOD req = 3'b000;
  # (1.5*PERIOD) done = 3'b100;
  # (PERIOD) done = 3'b000;

  // [6] Glitch on module 2 request - nothing should happen
  #PERIOD req = 3'b010;
  #1 req = 3'b000;
  
  // reset for fun
  #PERIOD rst = 1'b1;
  #PERIOD rst = 1'b0;
  
  // [7] M2 takes the memory and doesn't give it up - FSM must cut it off after 2 cycles
  # PERIOD req = 3'b010;
  # PERIOD req = 3'b000;
  # (3*PERIOD);
  # (PERIOD) done = 3'b000;
  
  // [8] M1 takes the memory but things are reset.
  # PERIOD req = 3'b001;
  # PERIOD req = 3'b000;
  # (2*PERIOD) rst = 1;
  # (PERIOD) rst = 0;
  
  // [9] more reset  fun (just to see things on the waveform)
  #PERIOD rst = 1'b1;
  #PERIOD rst = 1'b0;

  // [10] M3 only accesses memory for 1 cycle, returns to IDLE
  # PERIOD req = 3'b100;
  # PERIOD req = 3'b000; done = 3'b100;
  # PERIOD done = 3'b000;

  // [11] M3 gets interrupted during its first cycle
  # PERIOD req = 3'b100;
  # PERIOD req = 3'b001; done = 3'b100;
  # PERIOD req = 3'b000; done = 3'b001;  // M1 relinquishes access after 1 cycle after interrupting another module
  # PERIOD done = 3'b000;

  // [12] M2 only accesses memory for 1 cycle
  # PERIOD req = 3'b010;
  # PERIOD req = 3'b000; done = 3'b010;
  # PERIOD done = 3'b000;

  // [13] M2 gets interrupted by M1 after 1 cycle
  # PERIOD req = 3'b010;
  # PERIOD req = 3'b001; done = 3'b010;
  # PERIOD req = 3'b000;
  # (PERIOD) done = 3'b001;
  # PERIOD done = 3'b000;

  // [14] M3 gets interrupted during its second cycle of access
  # PERIOD req = 3'b100;
  # PERIOD req = 3'b000;
  # (PERIOD) req = 3'b001; done = 3'b100;
  # PERIOD req = 3'b000;
  # (PERIOD) done = 3'b001;
  # PERIOD done = 3'b000;

  
  # 20 $dumpflush;
  $stop;

end

initial begin
  $dumpfile("test.vcd");
  $dumpvars(1, tb);
  $monitor("%t: clk %1b, reset %1b, req %3b, done %3b, accmodule %2b, mstate %8b, nb_interrupts %5b", $time, iDUT.clk, iDUT.reset, iDUT.req, iDUT.done, iDUT.accmodule, iDUT.mstate, iDUT.nb_interrupts);
end



endmodule
