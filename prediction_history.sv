
`include "prediction.pkg"

// A queue to store past prediction requests
module prediction_history #(LENGTH)(
    input logic reset, clk, is_stalling,
    input history_entry_t current_history,
    input logic[INDEX_LEN-1:0] query_index,
    output history_entry_t query_history
);
    history_entry_t[LENGTH-1:0] queue;
    always_comb begin
        query_history = 0; // Default value if not found
        for (int i = 0; i < LENGTH; i++) begin
            if (query_index == queue[i].index) begin
                query_history = queue[i];
            end
        end
    end

    always_ff @ (posedge clk, negedge reset) begin
        if (!reset) begin
            queue = '{default:0};
        end
        else if(!is_stalling) begin
            queue <= (queue << $bits(history_entry_t));
            queue[0] <= current_history;
        end
    end
endmodule