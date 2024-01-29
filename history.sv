
`include "prediction.pkg"

module global_history (
    prediction_intf.data_in bus,
    output logic[GLOBAL_HIST_LEN-1:0] history
);
    logic[GLOBAL_HIST_LEN+MAX_ROLLBACK_CYCLES_INCL-1:0] internal_history;
    assign history = internal_history[GLOBAL_HIST_LEN-1:0];

    always_ff @ (posedge bus.clk, negedge bus.reset) begin
        if (!bus.reset) begin
            internal_history <= 0;
        end
        if (!bus.is_stalling) begin
            if (bus.update.enable && bus.update.is_rollback) begin
                internal_history <= (internal_history >> bus.update.no_stall_rollback_cycles);
            end
            else begin
                internal_history <= (internal_history << 1) | bus.update.taken;
            end
        end
    end
endmodule

module local_history (
    prediction_intf.data_in bus,
    output logic[LOCAL_HIST_LEN-1:0] history
);
    logic[INDEX_LEN-1:0][LOCAL_HIST_LEN-1:0] history_table;
    logic[LOCAL_HIST_LEN-1:0] update_index_slice;

    always_comb begin
        update_index_slice = bus.update.index[LOCAL_HIST_LEN-1:0];
        history = history_table[bus.query.index[LOCAL_HIST_LEN-1:0]];
    end

    always_ff @ (posedge bus.clk, negedge bus.reset) begin
        if (!bus.reset) begin
            history <= 0;
        end
        else if (bus.update.enable && !bus.is_stalling) begin
            history_table[update_index_slice] <= (INDEX_LEN'(history_table[update_index_slice]) << 1'h1) | INDEX_LEN'(bus.update.taken);
        end
    end
endmodule