module speed_control (
    input  logic clk,                    // System clock
    input  logic reset,                 // Active-high reset
    input  logic speed_sel,            // Speed selection input (KEY3)
    output logic [2:0] speed_value     // Current speed level (3 bits: 0 to 5)
);

    logic direction_up;                // Indicates if speed is currently increasing
    logic speed_sel_prev;             // Stores previous value of speed_sel
    logic pressed;                    // Detects rising edge (button press)
    logic skip_first_press;           // Skips first press after reset

    // Detect rising edge of speed_sel (button press)
    always_comb begin
        pressed = speed_sel & ~speed_sel_prev;
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            speed_value       <= 3'd0;      // Start at speed level 0 (10 RPM)
            direction_up      <= 1'b1;      // Begin by increasing speed
            speed_sel_prev    <= 1'b0;
            skip_first_press  <= 1'b1;      // Avoid reacting to initial unstable input
        end else begin
            speed_sel_prev <= speed_sel;

            if (pressed) begin
                if (skip_first_press) begin
                    // First press after reset is ignored to stabilize behavior
                    skip_first_press <= 1'b0;
                end else begin
                    if (direction_up) begin
                        // Increase speed until reaching max (5)
                        if (speed_value < 3'd5)
                            speed_value <= speed_value + 3'd1;
                        else begin
                            // At max speed, start decreasing
                            speed_value  <= speed_value - 3'd1;
                            direction_up <= 1'b0;
                        end
                    end else begin
                        // Decrease speed until reaching min (0)
                        if (speed_value > 3'd0)
                            speed_value <= speed_value - 3'd1;
                        else begin
                            // At min speed, start increasing
                            speed_value  <= speed_value + 3'd1;
                            direction_up <= 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule
