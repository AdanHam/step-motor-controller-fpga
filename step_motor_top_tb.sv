`timescale 1ns/1ps

module step_motor_top_tb;

  // Inputs
  logic clk, resetb, direction, speed_sel, on, quarter, step_size;

  // Outputs
  logic [6:0] sev_seg_o, sev_seg_t;
  logic [3:0] pulses_out;

  // Instantiate the Design Under Test (DUT)
  step_motor_top dut (
    .clk(clk),
    .resetb(resetb),
    .direction(direction),
    .speed_sel(speed_sel),
    .on(on),
    .quarter(quarter),
    .step_size(step_size),
    .sev_seg_o(sev_seg_o),
    .sev_seg_t(sev_seg_t),
    .pulses_out(pulses_out)
  );

  // 50 MHz Clock generation: toggles every 10ns → 20ns period = 50 MHz
  initial clk = 0;
  always #10 clk = ~clk;

  // Helper task: simulates a short press on the speed selector button
  task press_speed_key;
    begin
      speed_sel = 1;
      #20;
      speed_sel = 0;
    end
  endtask

  // Helper task: simulates a short press on the quarter-step button
  task press_quarter;
    begin
      quarter = 1;
      #20;
      quarter = 0;
    end
  endtask

  initial begin
    // Initial state: all inputs set to default values
    resetb = 0;
    direction = 0;
    speed_sel = 0;
    on = 0;
    quarter = 0;
    step_size = 1; // full-step mode
    #100;

    // Case 1: Reset the system
    resetb = 1;
    #100;

    // Case 2: Set direction to CW and turn motor ON
    direction = 1;
    on = 1;
    #500;

    // Case 3: Go from 10 to 60 RPM and back to 10
    repeat (5) begin press_speed_key(); #100; end // Increase speed
    repeat (6) begin press_speed_key(); #100; end // Decrease back

    // Case 4: Try pressing beyond minimum speed (should be ignored or reversed)
    press_speed_key(); #100;

    // Case 5: Switch to half-step mode
    step_size = 0;
    #500;

    // Case 6: Change direction to CCW
    direction = 0;
    #500;

    // Case 7: Apply reset in the middle of operation
    resetb = 0;
    #50;
    resetb = 1;
    #300;

    // Case 8: Turn motor OFF – expect pulses_out to stop
    on = 0;
    #300;

    // Case 9: Trigger quarter-step while OFF – should rotate 1/4 turn
    press_quarter();
    #2000;

    // Case 10: Try pressing quarter again during active quarter-spin – should be ignored
    press_quarter();
    #100;

    // Case 11: Change direction during quarter-spin – should not affect current motion
    direction = 1;
    #1000;

    // Case 12: Attempt quarter-step while motor is ON – should be ignored
    on = 1;
    #200;
    press_quarter();
    #500;

    // Case 13: Press speed button a few times to verify display update (observe waveform)
    repeat (3) begin press_speed_key(); #100; end
    // At this point, HEX display should show 40 RPM

    // End simulation
    $stop;
  end

endmodule
