
`include "prediction.pkg"

module prediction_history #(LENGTH)(
    input logic reset, clk, is_stalling,
    input logic[INDEX_LEN-1:0] current_index,
    input logic local_equal_global,
    input logic guess_global,

    input logic[INDEX_LEN-1:0] query_index,
    output logic had_guessed_global,
    output logic were_equal
);
    typedef struct packed {
        logic[INDEX_LEN-1:0] index;
        logic local_equal_global;
        logic had_guessed_global;
    } element_t;
    element_t[LENGTH-1:0] queue;

    genvar i;
    generate
        // we want to pick the value closest to the end of queue
        for (i = 0; i < LENGTH-1; i++) begin
            always_comb begin
                if (query_index == queue[i].index) begin
                    were_equal = queue[i].local_equal_global;
                    had_guessed_global = queue[i].had_guessed_global;
                end
            end
        end
    endgenerate

    always_ff @ (posedge clk, negedge reset) begin
        if (!reset) begin
            queue = '{default:0};
        end
        else if(!is_stalling) begin
            queue <= (queue << $bits(element_t));
            queue[0] <= '{
                index:current_index,
                local_equal_global:local_equal_global,
                had_guessed_global:had_guessed_global
            };
        end
    end
endmodule