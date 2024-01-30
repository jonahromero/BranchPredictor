
`include "prediction.pkg"

module tournament_predictor(input logic clk, reset);
    // declare the bus since we cant have it as top module name in verilator
    prediction_intf#(.INDEX_LEN(INDEX_LEN)) bus(.clk(clk), .reset(reset));

    // initialize modules for generating current global/local history vectors
    logic[GLOBAL_HIST_LEN-1:0] global_hist;
    logic[LOCAL_HIST_LEN-1:0] local_hist;
    global_history global_hist_mod(
        .bus(bus), .history(global_hist)
    );
    local_history local_hist_mod(
        .bus(bus), .history(local_hist)
    );

    // create 3 interfaces that are used to talk to predictor tables for global/local/choser
    prediction_intf#(.INDEX_LEN(LOCAL_HIST_LEN)) local_driver(.clk(bus.clk), .reset(bus.reset));
    prediction_intf#(.INDEX_LEN(GLOBAL_HIST_LEN)) global_driver(.clk(bus.clk), .reset(bus.reset));
    prediction_intf#(.INDEX_LEN(GLOBAL_HIST_LEN)) choser_driver(.clk(bus.clk), .reset(bus.reset));

    // global/local/choser table to store saturation bits
    predictor#(.INDEX_LEN(LOCAL_HIST_LEN)) local_table(local_driver);
    predictor#(.INDEX_LEN(GLOBAL_HIST_LEN)) global_table(global_driver);
    // taken corresponds to taking the global decision
    predictor#(.INDEX_LEN(GLOBAL_HIST_LEN)) best_choser(choser_driver);

    // we create a queue of queries we've done in these saturation tables.
    // The length of this queue is just the max # of cycles we could be waiting for
    // a branch to be resolved in execute stage.
    // current_history: current state to save. update_history: the history at update index
    history_entry_t current_history, update_history;
    assign current_history = '{
        index : bus.update.index,
        local_hist : local_hist,
        global_hist : global_hist,
        had_guessed_global : choser_driver.response.take,
        guesses_were_same : global_driver.response.take == local_driver.response.take
    };
    prediction_history#(.LENGTH(MAX_ROLLBACK_CYCLES_INCL)) prediction_hist(
        .reset(bus.reset), .clk(bus.clk), .is_stalling(bus.is_stalling),
        .current_history(current_history), .query_history(update_history),
        .query_index(bus.update.index)
    );

    // set up drivers for tables, and produce a taken output
    always_comb begin
        local_driver.query.index = local_hist;
        local_driver.update = '{
            enable: bus.update.enable,
            index: update_history.local_hist,
            taken: bus.update.taken,
            is_rollback : bus.update.is_rollback,
            no_stall_rollback_cycles : bus.update.no_stall_rollback_cycles
        };

        global_driver.query.index = global_hist;
        global_driver.update = '{
            enable: bus.update.enable,
            index: update_history.global_hist,
            taken: bus.update.taken,
            is_rollback : bus.update.is_rollback,
            no_stall_rollback_cycles : bus.update.no_stall_rollback_cycles
        };

        choser_driver.query.index = global_hist;
        choser_driver.update.index = update_history.global_hist;
        // if we want to update after a branch and we wouldve chosen differently, we update the choser
        if (bus.update.enable && !update_history.guesses_were_same) begin
            choser_driver.update.enable = 1;
            // set it to 1, if global was correct or local was incorrect
            choser_driver.update.taken = update_history.had_guessed_global ^ bus.update.is_rollback;
        end
        else begin
            choser_driver.update.enable = 0;
        end
        
        bus.response.take = choser_driver.response.take ?
                            global_driver.response.take :
                            local_driver.response.take;
    end
endmodule
