module pulse_generator (
    input  logic clk,                  // System clock
    input  logic reset,               // Active-high reset
    input  logic enable,              // Enable signal for motor movement
    input  logic direction,           // Rotation direction
    input  logic step_size,           // Step mode: 1 = full step, 0 = half step
    input  logic [2:0] speed_value,   // Speed selector value (0–5)
    output logic [3:0] pulses_out,    // Output pulse pattern to motor driver
    output logic       step_pulse     // One clock pulse per motor step (used for quarter rotation)
);

    logic [2:0] state;                // Current step state
    logic [2:0] next_state;           // Next state in step sequence
    logic [31:0] counter;             // Clock cycle counter
    logic [31:0] delay_cycles;        // Delay (in clock cycles) between steps
    logic prev_step_size;            // Previous value of step_size (to detect changes)

    // Calculate delay between steps based on speed and step size
    always_comb begin
        case (speed_value)
            3'd0: delay_cycles = (step_size) ? 32'd1500000 : 32'd750000;   // 10 RPM
            3'd1: delay_cycles = (step_size) ? 32'd750000  : 32'd375000;   // 20 RPM
            3'd2: delay_cycles = (step_size) ? 32'd500000  : 32'd250000;   // 30 RPM
            3'd3: delay_cycles = (step_size) ? 32'd375000  : 32'd187500;   // 40 RPM
            3'd4: delay_cycles = (step_size) ? 32'd300000  : 32'd150000;   // 50 RPM
            3'd5: delay_cycles = (step_size) ? 32'd250000  : 32'd125000;   // 60 RPM
            default: delay_cycles = (step_size) ? 32'd1500000 : 32'd750000;
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state          <= 0;
            counter        <= 0;
            pulses_out     <= 4'b0000;
            step_pulse     <= 0;
            prev_step_size <= step_size;
        end else begin
            // Detect change in step_size and reset state
            if (step_size != prev_step_size) begin
                state <= 0;
                prev_step_size <= step_size;
            end

            if (enable) begin
                if (counter >= delay_cycles) begin
                    counter <= 0;
                    step_pulse <= 1;

                    // Update next_state based on current step_size and direction
                    if (step_size) begin // Full-step mode (4-step sequence)
                        case (state)
                            3'd0: next_state = direction ? 3'd1 : 3'd3;
                            3'd1: next_state = direction ? 3'd2 : 3'd0;
                            3'd2: next_state = direction ? 3'd3 : 3'd1;
                            3'd3: next_state = direction ? 3'd0 : 3'd2;
                            default: next_state = 3'd0;
                        endcase
                    end else begin // Half-step mode (8-step sequence)
                        case (state)
                            3'd0: next_state = direction ? 3'd1 : 3'd7;
                            3'd1: next_state = direction ? 3'd2 : 3'd0;
                            3'd2: next_state = direction ? 3'd3 : 3'd1;
                            3'd3: next_state = direction ? 3'd4 : 3'd2;
                            3'd4: next_state = direction ? 3'd5 : 3'd3;
                            3'd5: next_state = direction ? 3'd6 : 3'd4;
                            3'd6: next_state = direction ? 3'd7 : 3'd5;
                            3'd7: next_state = direction ? 3'd0 : 3'd6;
                            default: next_state = 3'd0;
                        endcase
                    end

                    state <= next_state;

                    // Generate output pulse pattern based on the new step state
                    if (step_size) begin // Full-step mode
                        case (next_state)
                            3'd0: pulses_out <= 4'b1000;
                            3'd1: pulses_out <= 4'b0010;
                            3'd2: pulses_out <= 4'b0100;
                            3'd3: pulses_out <= 4'b0001;
                        endcase
                    end else begin // Half-step mode
                        case (next_state)
                            3'd0: pulses_out <= 4'b1000;
                            3'd1: pulses_out <= 4'b1010;
                            3'd2: pulses_out <= 4'b0010;
                            3'd3: pulses_out <= 4'b0110;
                            3'd4: pulses_out <= 4'b0100;
                            3'd5: pulses_out <= 4'b0101;
                            3'd6: pulses_out <= 4'b0001;
                            3'd7: pulses_out <= 4'b1001;
                        endcase
                    end

                end else begin
                    // Wait for next step interval
                    counter <= counter + 1;
                    step_pulse <= 0;
                end
            end else begin
                // When disabled, maintain current state and outputs
                // Optionally: set pulses_out <= 0 to avoid heating the motor
            end
        end
    end

endmodule
