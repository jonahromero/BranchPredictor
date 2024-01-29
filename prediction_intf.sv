
`include "prediction.pkg"

interface prediction_intf(input logic reset, clk);
    query_t query;
    update_t update;
    response_t response;
    logic is_stalling;

    modport data_in(
        input reset, clk,
        input query, update, is_stalling,
        output response
    );
endinterface
