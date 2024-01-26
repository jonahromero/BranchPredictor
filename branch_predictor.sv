

module counter(
    input logic reset, clk,
    output logic[31:0] counter
);
    always_ff @ (posedge clk, negedge reset) begin
        if (!reset) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end
endmodule

module branch_predictor #(LOG_ENTRIES = 12)(
    input logic reset, clk,
    // prediction
    input logic[31:0] pc,
    output logic taken,
    //updating
    input logic update,
    input logic[31:0] update_pc,
    input logic was_taken,
    // counter test
    output logic[31:0] counter
);
    localparam ENTRIES = 2 ** LOG_ENTRIES; // = 2, ENTRIES=4,
    typedef logic[LOG_ENTRIES-1:0] index_t;
    typedef enum logic[1:0] { 
        STRONGLY_NOT_TAKEN = 2'b00, WEAKLY_NOT_TAKEN = 2'b01,
        WEAKLY_TAKEN       = 2'b10, STRONGLY_TAKEN   = 2'b11
    } saturation_t;

    counter my_counter(reset, clk, counter);

    saturation_t saturation_table[ENTRIES];
    saturation_t current_saturation;
    index_t update_index;
    always_comb begin
        update_index = update_pc[LOG_ENTRIES-1+2:2];
        current_saturation = saturation_table[update_index];
        taken = saturation_table[pc[LOG_ENTRIES-1+2:2]][1];
    end

    always_ff @ (posedge clk, negedge reset) begin
        if (!reset) begin
            saturation_table <= '{ default:WEAKLY_TAKEN };
        end
        else begin
            if (update) begin
                //$display("Updating:%d, with: %b, from: %s", update_pc >> 2, was_taken, current_saturation.name());
                if (current_saturation != current_saturation.first && !was_taken) begin
                    //$display("to: %s", current_saturation.prev().name());
                    saturation_table[update_index] <= current_saturation.prev();
                end
                else if (current_saturation != current_saturation.last && was_taken) begin
                    //$display("to: %s", current_saturation.next().name());
                    saturation_table[update_index] <= current_saturation.next();
                end
            end
        end
    end
endmodule

// Assumes that instructions are 4 byte aligned
/*
module pc_predictor(
    // prediction
    input logic[31:0] pc,
    output logic taken,
    output logic[31:0] next_pc,
    // updating
    input logic[31:0] update_pc,
    input logic was_taken,
    input logic[31:0] actual_next_pc
);


endmodule : pc_predictor
*/
