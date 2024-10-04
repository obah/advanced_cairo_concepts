// use circuit::AddInputResultTrait;
// use circuit::CircuitInputs;
//a circuit that computes a * ( a + b ) over BN254 prime field
use core::circuit::{
    CircuitInputs, AddInputResultTrait, CircuitElement, CircuitInput, CircuitModulus,
    CircuitOutputsTrait, EvalCircuitTrait, circuit_add, circuit_mul, u384
};

fn main() {
    //define inputs
    let a = CircuitElement::<CircuitInput<0>> {};
    let b = CircuitElement::<CircuitInput<1>> {};
    //these 2 inputs can be combined with a gate to form CircuitElement<AddModGate<a, b>>

    //combine inputs with arithmetic operations to form gates
    let add = circuit_add(a, b);
    let mul = circuit_mul(a, add); // a degree 0 gate

    let output = (mul,);
    //from this point up, all these variables make up the circuit and its output

    //initialitize a and b by assigning values to them -> a fixed array of 4 u94 values
    let mut inputs = output.new_inputs();
    inputs = inputs.next([10, 0, 0, 0]); //next assigns value to inputs on CircuitInputAccumulator
    inputs = inputs.next([20, 0, 0, 0]);

    let instance = inputs
        .done(); //after initialisation, use done() to finalize the circuit CircuitData<c>
    //new_inputs and next function return a variant of the AddInputResult enum

    //define the modulus the circuit uses
    let bn254_modulus = TryInto::<
        _, CircuitModulus
    >::try_into([0x6871ca8d3c208c16d87cfd47, 0xb85045b68181585d97816a91, 0x30644e72e131a029, 0x0])
        .unwrap();

    //evaluate the circuit
    let res = instance.eval(bn254_modulus).unwrap();

    //retrieve outputs
    let add_output = res.get_output(add);
    let circuit_output = res.get_output(mul);

    assert(add_output == u384 { limb0: 30, limb1: 0, limb2: 0, limb3: 0 }, 'add_output');
    assert(circuit_output == u384 { limb0: 300, limb1: 0, limb2: 0, limb3: 0 }, 'add_output');

    (add_output, circuit_output);

    println!("The outputs are {:?}", circuit_output);
}
