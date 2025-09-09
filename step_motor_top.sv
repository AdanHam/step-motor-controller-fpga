module step_motor_top (
    input  logic clk,                  // System clock (50MHz)
    input  logic resetb,              // Active-low reset signal
    input  logic direction,           // Direction control switch (SW1)
    input  logic speed_sel,           // Speed selector input (KEY3)
    input  logic on,                  // Continuous rotation enable (SW2)
    input  logic quarter,             // Quarter-step control (KEY1)
    input  logic step_size,           // Step size control: 1 = full step, 0 = half step (SW3)
    output logic [6:0] sev_seg_o,     // Seven segment display - ones digit (HEX0)
    output logic [6:0] sev_seg_t,     // Seven segment display - tens digit (HEX1)
    output logic [3:0] pulses_out     // Pulse output to motor driver
);

    // Internal signals
    logic [2:0] speed_value;          // Encoded speed value (0 to 5)
    logic [3:0] tens_digit;           // Tens digit for 7-segment display
    logic direction_out;             // Processed direction signal
    logic quarter_active;            // Indicates active quarter-step operation
    logic motor_enable;              // Motor enable signal
    logic [9:0] steps_per_rev;       // Number of steps per revolution (200 or 400)
    logic step_pulse;                // Single step pulse used for quarter rotation

    // Speed control module – handles speed increment/decrement via KEY3
    speed_control speed_ctrl (
        .clk(clk),
        .reset(~resetb),
        .speed_sel(speed_sel),
        .speed_value(speed_value)
    );

    // Map speed value to display tens digit (10, 20, ..., 60 RPM)
    always_comb begin
        case (speed_value)
            3'd0: tens_digit = 4'd1;
            3'd1: tens_digit = 4'd2;
            3'd2: tens_digit = 4'd3;
            3'd3: tens_digit = 4'd4;
            3'd4: tens_digit = 4'd5;
            3'd5: tens_digit = 4'd6;
            default: tens_digit = 4'hF; // Invalid case
        endcase
    end

    // Display 0 on HEX0 (ones digit always 0)
    assign sev_seg_o = 7'b1000000;

    // Seven segment display driver for tens digit (HEX1)
    seven_segment hex1_driver (
        .digit_in(tens_digit),
        .seven_out(sev_seg_t)
    );

    // Direction control logic – processes debounced direction input
    direction_control dir_ctrl (
        .clk(clk),
        .reset(~resetb),
        .direction_switch(direction),
        .direction_out(direction_out)
    );

    // Select step resolution: 200 (full step) or 400 (half step)
    always_comb begin
        if (step_size)
            steps_per_rev = 10'd200;
        else
            steps_per_rev = 10'd400;
    end

    // Quarter rotation controller – generates a pulse sequence for precise 1/4 turn
    quarter_rotation quarter_rot (
        .clk(clk),
        .reset(~resetb),
        .quarter(quarter),
        .sw2_enabled(on),
        .step_pulse(step_pulse),
        .step_size(step_size),
        .quarter_active(quarter_active)
    );

    // Enable motor if continuous mode (SW2) is ON or a quarter rotation is requested
    assign motor_enable = on | quarter_active;

    // Pulse generator module – creates step pulses based on speed, direction, and step size
    pulse_generator pulse_gen (
        .clk(clk),
        .reset(~resetb),
        .enable(motor_enable),
        .direction(direction_out),
        .step_size(step_size),
        .speed_value(speed_value),
        .pulses_out(pulses_out),
        .step_pulse(step_pulse)
    );

endmodule
