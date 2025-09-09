module enable_controller (
    input  logic on_switch,          // Continuous motion control (SW2)
    input  logic quarter_active,     // Indicates active quarter-rotation
    output logic motor_enable        // Output enable signal for the motor
);

    // Enable the motor if either continuous mode is on or quarter-rotation is active
    always_comb begin
        motor_enable = on_switch || quarter_active;
    end

endmodule
