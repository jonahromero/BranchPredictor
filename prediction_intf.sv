
`include "prediction.pkg"

interface prediction_intf#(INDEX_LEN)(input logic reset, clk);
    `query_t(INDEX_LEN) query;
    `update_t(INDEX_LEN) update;
    response_t response;
    logic is_stalling;

    modport data_in(
        input reset, clk,
        input query, update, is_stalling,
        output response
    );
endinterface
