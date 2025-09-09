module direction_control (
    input  logic clk,                 // System clock
    input  logic reset,              // Active-high reset
    input  logic direction_switch,   // Input switch for motor direction (SW1)
    output logic direction_out       // Output signal representing processed direction
);

    // Latches the direction_switch value on each clock cycle
    // On reset, defaults direction to clockwise (1)
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            direction_out <= 1'b1;
        else
            direction_out <= direction_switch;
    end

endmodule
