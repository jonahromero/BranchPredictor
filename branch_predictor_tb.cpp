
#include "verilated.h"
#include <iostream>
#include <vector>
#include <string>
#include <random>

template<typename VType>
void save_vmodel(std::string_view path, VType&& model) {
    VerilatedSave os;
    os.open(path.data());
    os << model;
}

template<typename VType>
std::unique_ptr<VType> restore_vmodel(std::string_view path) {
    VerilatedRestore is;
    is.open(path.data());
    std::unique_ptr<VType> retval = std::make_unique<VType>();
    is >> *retval;
    return retval;
}

uint32_t random_int() {
    static std::mt19937 gen32;
    return gen32();
}
/*
void reset_bp(Vbranch_predictor& bp) {
    bp.reset = true;
    bp.clk = 0;
    bp.update = false;
    bp.eval();
    bp.reset = false;
    bp.eval();
    bp.reset = true;
}

using ModelPtr = std::unique_ptr<Vbranch_predictor>;

void test_bp(ModelPtr& bp_ptr) {
    // initialize similar counter scheme
    std::vector<int> should_take = std::vector<int>(size_t(1 << 12), 2);
    reset_bp(*bp_ptr);
    save_vmodel("./temp.vm", std::move(*bp_ptr));
    for (int iters = 0; iters < 1; iters++) {
        for (uint32_t pc = 0; pc < should_take.size(); pc++) {
            bp_ptr = restore_vmodel<Vbranch_predictor>("./temp.vm");
            auto& bp = *bp_ptr;
            bp.clk = 1;
            bp.pc = pc << 2; // 4 byte aligned pc
            bp.eval();
            bool taken_guess = bp.taken;
            bool taken_actual = should_take[pc] > 1;
            bool was_taken = random_int() % 2;
            if (taken_guess != taken_actual) {
                std::cout << "["<< pc << "] guessed: "<< taken_guess << ", but should be:"<< taken_actual << ". taken:["<<was_taken<<"]" << std::endl;
                return;
            }
            // update with what new branch history
            if (should_take[pc] != 3 && was_taken) {
                should_take[pc]++;
            }
            else if(should_take[pc] != 0 && !was_taken) {
                should_take[pc]--;
            }
            std::cout << bp.counter << std::endl;
            bp.update = true;
            bp.update_pc = pc << 2;
            bp.was_taken = was_taken;
            bp.clk = 0;
            bp.eval();
            save_vmodel("./temp.vm", std::move(bp));
        }
    }
}*/

int main(int argc, char** argv) {
    /*
    Verilated::commandArgs(argc, argv);
    std::cout << "Starting branch predictor" << std::endl;
    ModelPtr bp = std::make_unique<Vbranch_predictor>();
    test_bp(bp);*/
}