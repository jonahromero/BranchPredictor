
#include "verilated.h"
#include "Vtournament_predictor.h"
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

int main(int argc, char** argv) {}