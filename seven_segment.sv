module seven_segment (
    input  logic [3:0] digit_in,     // 4-bit binary input digit (0–9 or special cases)
    output logic [6:0] seven_out     // 7-segment display output (active-low segments)
);

    // Maps binary digits to corresponding 7-segment display patterns
    always_comb begin
        case (digit_in)
            4'd0: seven_out = 7'b1000000; // Displays "0"
            4'd1: seven_out = 7'b1111001; // Displays "1"
            4'd2: seven_out = 7'b0100100; // Displays "2"
            4'd3: seven_out = 7'b0110000; // Displays "3"
            4'd4: seven_out = 7'b0011001; // Displays "4"
            4'd5: seven_out = 7'b0010010; // Displays "5"
            4'd6: seven_out = 7'b0000010; // Displays "6"
            4'd7: seven_out = 7'b1111000; // Displays "7"
            4'd8: seven_out = 7'b0000000; // Displays "8"
            4'd9: seven_out = 7'b0010000; // Displays "9"
            4'hF: seven_out = 7'b0001110; // Displays "F" (used for invalid state)
            default: seven_out = 7'b1111111; // All segments off (blank display)
        endcase
    end

endmodule
