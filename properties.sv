module properties(	input [2:0] req, accmodule,
					input [7:0] mstate,
					input clk,
					input mod_priority,
					input reset,
					input [2:0] done);

	sequence seq_1;
		reset == 1 ##1 reset == 0;
	endsequence
	//rst_0: assume property(@(posedge clk) seq_1);

// I.D. 2: "Each state machine must be one-hot encoded"; mstate
	mstate_onehot: assert property(@(posedge clk) $onehot0(mstate)) else $error("state machine NOT 1-hot encoded");


// I.D. 22: "The memory is granted to a module only if its req line is asserted"; accmodule, req
	sequence m1_requested;
		req[0] == 1;
	endsequence
	sequence m1_granted;
		accmodule == 2'b01;
	endsequence
	m1_grant: assert property(
		@(posedge clk) disable iff (reset)
		(m1_requested |-> ##1 m1_granted)
	);

	m2_grant: assert property(
		@(posedge clk)
		((req == 3'b010 && mod_priority)) |-> accmodule == 2'b10
	)else $error("m2_grant failed");

	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	m2_grant_LLM_generated: assert property(
		@(posedge clk) disable iff (~mod_priority)
		(req[1] && !req[0]) && (mstate == 8'b0000_1000 || mstate == 8'b1000_0000) |=> accmodule == 2'b10
	) else $error("m2_grant_LLM_generated failed");

	m3_grant: assert property(
		@(posedge clk)
		((req == 3'b100 && !mod_priority) ##1 !$stable(accmodule)) |-> accmodule == 2'b11
	)else $error("m3_grant failed");

	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	m3_grant_LLM_generated: assert property(
		@(posedge clk) disable iff (mod_priority)
		(req[2] && !req[0] && (mstate == 8'b0000_1000 || mstate == 8'b0010_0000)) |=> accmodule == 2'b11
	) else $error("m3_grant_LLM_generated failed");


// I.D. 7: "A request line is asserted for one clk cycle only."; req
	m1_req: assume property(
		@(posedge clk)
		req[0] |=> $fell(req[0])
	)else $error("m1's req was over 1 cycle failed");
	
	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	m1_req_fired_LLM: cover property(
		@(posedge clk) req[0]  // confirms antecedent was exercised
	);

	m2_req: assume property(
		@(posedge clk)
		req[1] |=> $fell(req[1])
	)else $error("m2's req was over 1 cycle");
	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	m2_req_fired_LLM_generated: cover property(
    @(posedge clk) req[1]
	);

	m3_req: assume property(
		@(posedge clk)
		req[2] |=> $fell(req[2])
	)else $error("m3's req was over 1 cycle");
	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	m3_req_fired_LLM_generated: cover property(
		@(posedge clk) req[2]
	);

	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	mutex_LLM_generated: assert property(
		@(posedge clk)
		!(accmodule == 2'b01 && accmodule == 2'b10)  // always true, use mstate instead
	) else $error("mutex violation");

	no_req_during_access: assume property(
		@(posedge clk)
		(accmodule == 2'b01 ^ req[0]) | (accmodule == 2'b10 ^ req[1]) | (accmodule == 2'b11 ^ req[2])
	);

// I.D. XX: done signal lasts for one clock cycle
// TODO: EDIT ASSERTION NAMES AND DEFINITIONS TO MATCH DONE SIGNAL FIRING, AND
// ONLY LASTING ONE CLOCK CYCLE
	m1_done: assume property(
		@(posedge clk)
		done[0] |=> $fell(done[0])
	)else $error("m1's req was over 1 cycle failed");
	
	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	m1_done_fired: cover property(
		@(posedge clk) done[0]  // confirms antecedent was exercised
	);

	m2_done: assume property(
		@(posedge clk)
		done[1] |=> $fell(done[1])
	)else $error("m2's req was over 1 cycle");
	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	m2_done_fired: cover property(
    @(posedge clk) done[1]
	);

	m3_done: assume property(
		@(posedge clk)
		done[2] |=> $fell(done[2])
	)else $error("m3's done was over 1 cycle");
	// ******THIS ASSERTION IS LLM GENERATED THROUGH CLAUDE'S FREE PLAN*******
	m3_done_fired: cover property(
		@(posedge clk) done[2]
	);


	// test assertion to fire on every most clock edges
	// prop_violation: assert property (@(posedge clk) req == 3'b000) else $error("prop_violation failed");

endmodule
