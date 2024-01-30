
`include "prediction.pkg"

module global_history (
    prediction_intf.data_in bus,
    output logic[GLOBAL_HIST_LEN-1:0] history
);
    localparam INTERNAL_LEN = GLOBAL_HIST_LEN+MAX_ROLLBACK_CYCLES_INCL;
    logic[INTERNAL_LEN-1:0] internal_history;
    assign history = internal_history[GLOBAL_HIST_LEN-1:0];

    always_ff @ (posedge bus.clk, negedge bus.reset) begin
        if (!bus.reset) begin
            internal_history <= 0;
        end
        if (!bus.is_stalling) begin
            // global history is speculatively changed, and on a rollback, we undo any shifting.
            if (bus.update.enable && bus.update.is_rollback) begin
                internal_history <= (internal_history >> bus.update.no_stall_rollback_cycles);
            end
            else begin
                internal_history <= (internal_history << 1) | INTERNAL_LEN'(bus.update.taken);
            end
        end
    end
endmodule

module local_history (
    prediction_intf.data_in bus,
    output logic[LOCAL_HIST_LEN-1:0] history
);
    logic[INDEX_LEN-1:0][LOCAL_HIST_LEN-1:0] history_table;

    always_comb begin
        history = history_table[bus.query.index];
    end

    always_ff @ (posedge bus.clk, negedge bus.reset) begin
        if (!bus.reset) begin
            history_table <= 0;
        end
        else if (bus.update.enable && !bus.is_stalling) begin
            history_table[bus.update.index] <= (history_table[bus.update.index] << 1'h1) | LOCAL_HIST_LEN'(bus.update.taken);
        end
    end
endmodule