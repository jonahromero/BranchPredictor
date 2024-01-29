
`include "prediction.pkg"

module tournament_predictor(input logic clk, reset);
    // declare the bus since we cant have it as top module name in verilator
    prediction_intf bus(.clk(clk), .reset(reset));

    logic[GLOBAL_HIST_LEN-1:0] global_hist;
    logic[LOCAL_HIST_LEN-1:0] local_hist;
    global_history global_hist_mod(
        .bus(bus), .history(global_hist)
    );
    local_history local_hist_mod(
        .bus(bus), .history(local_hist)
    );

    prediction_intf local_driver(.clk(bus.clk), .reset(bus.reset)),
                  global_driver(.clk(bus.clk), .reset(bus.reset)),
                  choser_driver(.clk(bus.clk), .reset(bus.reset));
    predictor#(.INDEX_LEN(LOCAL_HIST_LEN)) local_table(local_driver);
    predictor#(.INDEX_LEN(GLOBAL_HIST_LEN)) global_table(global_driver);

    // take corresponds to taking the global decision
    predictor#(.INDEX_LEN(GLOBAL_HIST_LEN)) best_choser(choser_driver);
    logic local_global_guessed_same, guessed_with_global;
    prediction_history#(.LENGTH(MAX_ROLLBACK_CYCLES_INCL)) prediction_hist(
        .reset(bus.reset), .clk(bus.clk), .is_stalling(bus.is_stalling),
        .current_index(bus.query.index), .query_index(bus.update.index),
        .had_guessed_global(guessed_with_global), .guess_global(choser_driver.response.take),
        .local_equal_global(global_driver.response.take == local_driver.response.take),
        .were_equal(local_global_guessed_same)
    );

    always_comb begin
        local_driver.query.index = local_hist;
        global_driver.query.index = global_hist;
        choser_driver.query.index = global_hist;
        bus.response.take = choser_driver.response.take ? 
                            global_driver.response.take : 
                            local_driver.response.take;
        local_driver.update = bus.update;
        global_driver.update = bus.update;

        choser_driver.update.index = bus.update.index;
        // if we want to update after a branch and we wouldve chosen differently, we update the choser
        if (bus.update.enable && !local_global_guessed_same) begin
            choser_driver.update.enable = 1;
            // set it to 1, if global was correct or local was incorrect
            choser_driver.update.taken = guessed_with_global ^ bus.update.is_rollback;
        end
        else begin
            choser_driver.update.enable = 0;
        end
    end
endmodule
