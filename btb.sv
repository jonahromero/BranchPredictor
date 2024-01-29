
// Assumes that instructions are 4 byte aligned

module btb(
    // prediction
    input logic[31:0] pc,
    output logic taken,
    output logic[31:0] next_pc,
    // updating
    input logic[31:0] update_pc,
    input logic was_taken,
    input logic[31:0] actual_next_pc
);


endmodule : btb
