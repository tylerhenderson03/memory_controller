// Code your design here
module controller(
  input clk,
  input reset,
  input [2:0] req,
  input [2:0] done,
  output logic [7:0] mstate, // 1-hot encoded
  output logic [1:0] accmodule,
  output integer nb_interrupts,  // nb of interruptions
  output logic mod_priority
);
  
  // parameters used to index done[] and req[]
  parameter M1 = 0;
  parameter M2 = 1;
  parameter M3 = 2;
  
  // 1 for when M2 has priority, 0 for when M3 has priority
  //logic mod_priority;

  int counter[1:0];

  enum logic [7:0]{
    // These enums are used to index into the 1-hot encoded ps
    IDLE        = 8'b0000_0001, /* no module has access to the memory */
    M1_free     = 8'b0000_0010, /* M1 doesn't interrupt another module, retains memory indefinitely */
    M1_int_one  = 8'b0000_0100, /* M1 interrupts another module, first cycle of access */
    M1_int_two  = 8'b0000_1000, /* == == ... ==, 2nd/last cycle */
    M2_one      = 8'b0001_0000, /* M2 gains access(either through tiebreaker, or free access), 1st cycle */
    M2_two      = 8'b0010_0000, /* == == ... ==, 2nd/last cycle*/
    M3_one      = 8'b0100_0000, /* M3 gains access(either through tiebreaker, or free access), 1st cycle */
    M3_two      = 8'b1000_0000  /* == == ... ==, 2nd/last cycle*/
  } ps, ns; // present state AND next state

  // set ps to ns, reset, whatever other stuff..
  always_ff @(posedge clk, posedge reset) begin // ff-based logic
    if(reset) ps <= IDLE;
    else      ps <= ns;
  end


  // 1 for when M2 has priority, 0 for when M3 has priority
  always_ff @(posedge clk or posedge reset) begin
      if (reset)
          mod_priority <= 0;
      else if (req[M2] && req[M3]) // flip mod_priority ever time a tie between M2/M3 occurs
          mod_priority <= ~mod_priority;
  end
  
  // increase interrupt counter
  always_ff @(edge mod_priority, posedge reset) begin // ff-based logic
    if (reset) nb_interrupts = 0;
    else nb_interrupts <= nb_interrupts+1;
  end
    
  // next state logic
  always_comb begin // combinational logic
      case(ps)
        IDLE: begin
        // no collision occurs
          if(req[M1])  ns = M1_free; // when M1 receives free access to memory
          else if(req[M2] == 1 && req[M3] == 1) begin // when a tie occurs
            if(mod_priority) ns = M2_one;
            else ns = M3_one;
          end
          else if (req[M2] == 1)    ns = M2_one; // only M2 requests
          else if (req[M3] == 1)    ns = M3_one; // only M3 requests
          else                      ns = IDLE;   // stay in IDLE
        end
        M1_free: begin
          // M1 is allowed to access memory indefinitely when not interrupting other modules
		  if(done[M1] == 1) begin // if done, end memory access
			if (req[M2] && req[M3]) begin
			  if(mod_priority) ns = M2_one;
              else ns = M3_one;
			end
			else if(req[M2]) ns = M2_one;
			else if(req[M3]) ns = M3_one;
			else ns = IDLE;
		  end
		  else              ns = M1_free;   // stay in M1
        end
        M1_int_one: begin
		  if(done[M1] == 1) begin // if done, end memory access
			if (req[M2] && req[M3]) begin
			  if(mod_priority) ns = M2_one;
              else ns = M3_one;
			end
			else if(req[M2]) ns = M2_one;
			else if(req[M3]) ns = M3_one;
			else ns = IDLE;
		  end
          else  ns = M1_int_two;// continue to 2nd CLK cycle for M1's memory access
        end
        M1_int_two: begin
			if(req[0]) ns = M1_free; // if done, end memory access
			else if(req[1]) ns = M2_one;
			else if(req[2]) ns = M3_one;
			else ns = IDLE;
		  //end
          //else ns = IDLE;      // 2 clock cycles have passed since M1 interrupted another module, end access
        end
        M2_one: begin
          if(req[M1] == 1 && done[M2] == 0)  ns = M1_int_one;// for when M1 interrupts another module
		  else if(done[M2] == 1)  begin// M2 is done with memory after 1 CLK cycle
			if(req[M1]) ns = M1_free;
		    else if(req[M3]) ns = M3_one;
		    else ns = IDLE;
		  end
          else ns = M2_two;                 // continue to 2nd CLK cycle of permitted access
        end
        M2_two: begin
          //if(req[M1] == 1) ns = M1_int_one; // interrupted by M1
		  //else if(done[M2] == 1)  begin // M2 is done with memory after 1 CLK cycle
			if(req[0]) ns = M1_free;
		    else if(req[2]) ns = M3_one;
		    else ns = IDLE;
		  //end // end access for M2 after 2nd cycle
        end
        M3_one: begin
          if(req[M1] == 1 && done[M3] == 0) ns = M1_int_one; // interrupted by M1 
		  else if(done[M3] == 1)  begin // M2 is done with memory after 1 CLK cycle
			if(req[M1]) ns = M1_free;
		    else if(req[M2]) ns = M2_one;
		    else ns = IDLE;
		  end // end access for M3 after 2nd cycle
          else ns = M3_two;                 // continue to next state/last cycle of access
        end
        M3_two: begin
          //if(req[M1] == 1) ns = M1_int_one; // interrupted by M1
		  //else if(done[M3] == 1)  begin // M2 is done with memory after 1 CLK cycle
			if(req[0]) ns = M1_free;
		    else if(req[1]) ns = M2_one;
		    else ns = IDLE;
		  //end // end access for M3 after 2nd cycle
		 // else ns = IDLE;
		end
        default: ns = ps;                   // default case
      endcase
  end

  // output logic/control signals
  always_comb begin // combinational logic
    // Set outputs to initial values
    if(reset) begin
      mstate 		    = IDLE;
      accmodule 	  = 2'b01;
    end
    else begin
      case(ps)
        IDLE: begin
          accmodule = 2'b00;
          mstate =  IDLE;
        end
        M1_free: begin
          accmodule = 2'b01;
          mstate =  M1_free;
        end
        M1_int_one: begin
          accmodule = 2'b01;
          mstate =  M1_int_one;
        end
        M1_int_two: begin
          accmodule = 2'b01;
          mstate =  M1_int_two;
        end
        M2_one: begin
          accmodule = 2'b10;
          mstate =  M2_one;
        end
        M2_two: begin
          accmodule = 2'b10;
          mstate =  M2_two;
        end
        M3_one: begin
          accmodule = 2'b11;
          mstate =  M3_one;
        end
        M3_two: begin
          accmodule = 2'b11;
          mstate =  M3_two;
        end
        default: mstate = IDLE;
      endcase
    end
  end
endmodule
