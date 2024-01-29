

// General module for predicting
module predictor #(INDEX_LEN)(
    prediction_intf.data_in bus
);
    localparam ENTRIES = 2 ** INDEX_LEN;
    typedef logic[INDEX_LEN-1:0] index_t;
    typedef enum logic[1:0] { 
        STRONGLY_NOT_TAKEN = 2'b00, WEAKLY_NOT_TAKEN = 2'b01,
        WEAKLY_TAKEN       = 2'b10, STRONGLY_TAKEN   = 2'b11
    } saturation_t;

    saturation_t saturation_table[ENTRIES];
    saturation_t current_saturation;
    index_t update_index;

    always_comb begin
        update_index = bus.update.index[INDEX_LEN-1:0];
        current_saturation = saturation_table[update_index];
        bus.response.take = saturation_table[bus.query.index[INDEX_LEN-1:0]][1];
    end

    always_ff @ (posedge bus.clk, negedge bus.reset) begin
        if (!bus.reset) begin
            saturation_table <= '{ default:WEAKLY_TAKEN };
        end
        else begin
            if (bus.update.enable && !bus.is_stalling) begin
                if (current_saturation != current_saturation.first && !bus.update.taken) begin
                    saturation_table[update_index] <= current_saturation.prev();
                end
                else if (current_saturation != current_saturation.last && bus.update.taken) begin
                    saturation_table[update_index] <= current_saturation.next();
                end
            end
        end
    end
endmodule
