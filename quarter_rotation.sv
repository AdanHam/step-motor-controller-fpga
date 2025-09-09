module quarter_rotation (
    input  logic clk,                 // System clock
    input  logic reset,              // Active-high reset
    input  logic quarter,            // Quarter-rotation trigger (KEY1)
    input  logic sw2_enabled,        // Continuous motion enable (SW2)
    input  logic step_pulse,         // Pulse indicating a step has occurred
    input  logic step_size,          // Step mode: 1 = full step (1.8°), 0 = half step (0.9°)
    output logic quarter_active      // Indicates quarter rotation is in progress
);

    logic quarter_prev;              // Holds previous state of quarter input
    logic [9:0] step_counter;        // Counts number of steps for 1/4 rotation
    logic quarter_spin_started;     // Internal flag: is quarter rotation active?
    logic [9:0] quarter_steps_latched; // Number of steps for a 1/4 turn (latched)

    // Detect falling edge on the quarter input
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            quarter_prev <= 1'b1;
        else
            quarter_prev <= quarter;
    end

    logic quarter_falling_edge;
    assign quarter_falling_edge = (quarter_prev && ~quarter);

    // Main control logic for quarter rotation
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            quarter_spin_started    <= 1'b0;
            step_counter            <= 0;
            quarter_steps_latched   <= 10'd50; // Default to full step (1/4 of 200)
        end else begin
            // Start quarter rotation only if SW2 is OFF and not already running
            if (~sw2_enabled && quarter_falling_edge && ~quarter_spin_started) begin
                quarter_spin_started  <= 1'b1;
                step_counter          <= 0;
                // Latch step count for a 1/4 rotation based on step size
                quarter_steps_latched <= (step_size) ? 10'd50 : 10'd100;
            end
            // While spinning, count step pulses until reaching quarter turn
            else if (quarter_spin_started && step_pulse) begin
                if (step_counter >= quarter_steps_latched - 1) begin
                    quarter_spin_started <= 1'b0; // Finish the 1/4 rotation
                end else begin
                    step_counter <= step_counter + 1;
                end
            end
        end
    end

    // Output flag indicating quarter rotation is in progress
    assign quarter_active = quarter_spin_started;

endmodule
