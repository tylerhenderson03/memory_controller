module functional_cov(
  input clk,
  input reset,
  input [2:0] req,
  input [2:0] done,
  input logic [7:0] mstate, // 1-hot encoded
  input logic [2:0] accmodule,
  input integer nb_interrupts,  // nb of interruptions
  input logic mod_priority
);

  covergroup cg_priority @(posedge clk);
    cp_req: coverpoint req{
      bins req_0 = {1};
    }
    cp_accmodule: coverpoint accmodule{
      bins accmod_2 = (3'b010 => 3'b001);
      bins accmod_3 = (3'b100 => 3'b001);
    }
    cp_priority_0: cross cp_req, cp_accmodule;

  endgroup: cg_priority

  covergroup cg_m1_high_priority @(posedge clk);

    // Was M1 able to interrupt M2 in its first cycle?
    cp_m1_interrupts_m2_one: coverpoint mstate {
      bins m1_interrupts_m2_one = (8'b0001_0000 => 8'b0000_0100);
    }

    // Was M1 able to interrupt M2 in its second cycle?
    cp_m1_interrupts_m2_two: coverpoint mstate {
      bins m1_interrupts_m2_two = (8'b0001_0000 => 8'b0000_0100);
    }

    // Was M1 able to interrupt M3 in its first cycle?
    cp_m1_interrupts_m3_one: coverpoint mstate {
      bins m1_interrupts_m3_one = (8'b0100_0000 => 8'b0000_0100);
    }

    // Was M1 able to interrupt M3 in its second cycle?
    cp_m1_interrupts_m3_two: coverpoint mstate {
      bins m1_interrupts_m3_two = (8'b1000_0000 => 8'b0000_0100);
    }

    // Forbidden: M2 or M3 should never interrupt M1
    /*cp_no_m2_interrupt_m1: coverpoint mstate {
      forbidden_bins m2_cannot_interrupt_m1 =
        (8'b0000_0010 => 8'b0001_0000),
        (8'b0000_0010 => 8'b0010_0000),
        (8'b0000_0100 => 8'b0001_0000),
        (M1_int_two => 8'b0001_0000);
    }*/

    /*cp_no_m3_interrupt_m1: coverpoint mstate {
      forbidden_bins m3_cannot_interrupt_m1 =
        (8'b0000_0010 => 8'b0100_0000),
        (8'b0000_0010 => 8'b1000_0000),
        (8'b0000_0100 => 8'b0100_0000),
        (8'b0000_1000 => 8'b0100_0000);
    }*/

  endgroup

  covergroup cg_m1_indef_access @(posedge clk);

    // Coverpoint 1: M1 requested while memory was idle (free access condition)
    cp_m1_free_request: coverpoint req[0] {
      bins m1_req_while_idle = {1'b1} iff (tb.iDUT.ps == 8'b0000_0001);
    }

    // Coverpoint 2: FSM entered the indefinite hold state (not interrupt state)
    cp_m1_free_state: coverpoint mstate {
      bins entered_m1_free = (8'b0000_0001 => 8'b0000_0010);
    }

    // Coverpoint 3: M1 stays in M1_free for multiple cycles (proving indefinite)
    cp_m1_indef_hold: coverpoint mstate {
      bins m1_holds_3plus_cycles =
        (8'b0000_0010 => 8'b0000_0010 => 8'b0000_0010);
    }

    // Coverpoint 4: M1 exits only via done, not FSM cutoff
    cp_m1_free_exit: coverpoint mstate {
      bins m1_exits_on_done =
        (8'b0000_0010 => 8'b0000_0001) iff (tb.iDUT.done[0] == 1'b1);
    }

    // Forbidden: M1_free should never self-transition to an interrupt state
    // (would mean M1 somehow interrupted itself, which is illegal)
    /*cp_m1_free_no_interrupt: coverpoint mstate {
      forbidden_bins m1_free_never_goes_to_int =
        (8'b0000_0010 => 8'b0000_0100),
        (8'b0000_0010 => 8'b0000_1000);
    }*/

  endgroup
endmodule: functional_cov