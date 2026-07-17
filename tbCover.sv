`include "covergroups.sv"
class rand_inputs;
// inputs
  rand logic [2:0] req; 
  rand logic [2:0] done;
  rand logic rst;

  constraint no_simulataneous_req_done{
    req[0] ^ done[0];
    req[1] ^ done[1];
    req[2] ^ done[2];
  }

endclass: rand_inputs

module tbCover();
  
  // M3,M2,M1
  parameter ixONE = 0;
  parameter ixTWO = 1;
  parameter ixTHR = 2;
  
// inputs

  logic [2:0] req; 
  logic [2:0] done;
  logic clk, rst;

// outputs
  logic [7:0] mstate;
  logic [1:0] accmodule;
  logic [4:0] nb_interrupts;
  logic mod_priority;

  parameter CLK_PERIOD = 10;
  always #(CLK_PERIOD/2) clk = ~clk;

  /*cg_priority         cg_priority_inst;
  cg_m1_high_priority cg_m1_high_priority_inst;
  cg_m1_indef_access  cg_m1_indef_access_inst;
  rand_inputs dut_inputs;*/


  controller iDUT(.req(req), .done(done), .reset(rst), .clk(clk), .mstate(mstate), .accmodule(accmodule), .nb_interrupts(nb_interrupts), .mod_priority(mod_priority));
  //bind controller functional_cov ctrl_funct_covg_inst(.req(req), .done(done), .reset(rst), .clk(clk), .mstate(mstate), .accmodule(accmodule), .nb_interrupts(nb_interrupts), .mod_priority(mod_priority));
  bind controller properties ctrl_sva_inst (.req(req), .accmodule(accmodule), .mstate(mstate), .clk(clk), .mod_priority(mod_priority), .reset(rst), .done(done)); 

  cg_priority cg_0 = new;
  cg_m1_high_priority cg_1 = new;
  cg_m1_indef_access cg_2 = new;
  rand_inputs dut_inputs = new;

  parameter NUM_ITERATIONS = 90000;

initial begin
  clk = 0;
  req = 3'd0;
  done = 3'd0;
  rst = 0;


  dut_inputs.rst = 1;
  dut_inputs.req = 3'b000;
  dut_inputs.done = 3'b000;
  #(CLK_PERIOD) dut_inputs.rst = 0;

  repeat(NUM_ITERATIONS) begin // acheives 100% coverage with ModelSim
    if (dut_inputs.randomize()) begin
        req = dut_inputs.req;
        done = dut_inputs.done;
        rst = dut_inputs.rst;
    end
    #(CLK_PERIOD); // progress 1 clock cycle
    // include additional lines for observing DUT behavior
  end


  
  #(CLK_PERIOD) $dumpflush;
  $stop;

end

initial begin
  $dumpfile("test.vcd");
  $dumpvars(1, tbCover);
  //$monitor("%t: clk %1b, reset %1b, req %3b, done %3b, accmodule %2b, mstate %8b, nb_interrupts %5b", $time, iDUT.clk, iDUT.reset, iDUT.req, iDUT.done, iDUT.accmodule, iDUT.mstate, iDUT.nb_interrupts);
end


endmodule: tbCover
