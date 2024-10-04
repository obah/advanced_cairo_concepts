// solve a * b * c^2
use core::circuit::{
    AddInputResultTrait, CircuitElement, CircuitInput, CircuitModulus, CircuitInputs,
    CircuitOutputsTrait, EvalCircuitTrait, circuit_mul, u384
};

fn main() {
    let a = CircuitElement::<CircuitInput<0>> {};
    let b = CircuitElement::<CircuitInput<1>> {};
    let c = CircuitElement::<CircuitInput<2>> {};

    let squared = circuit_mul(c, c);
    let mul = circuit_mul(a, b);
    let mul2 = circuit_mul(mul, squared);

    let output = (mul2,);

    let mut inputs = output.new_inputs();
    inputs = inputs.next([5, 0, 0, 0]);
    inputs = inputs.next([10, 0, 0, 0]);
    inputs = inputs.next([2, 0, 0, 0]);

    let instance = inputs.done();

    let bn254_modulus = TryInto::<
        _, CircuitModulus
    >::try_into([0x6871ca8d3c208c16d87cfd47, 0xb85045b68181585d97816a91, 0x30644e72e131a029, 0x0])
        .unwrap();

    let res = instance.eval(bn254_modulus).unwrap();

    let squared_output = res.get_output(squared);
    let circuit_output = res.get_output(mul2);

    assert!(squared_output == u384 { limb0: 4, limb1: 0, limb2: 0, limb3: 0 }, "squaring wrong");
    assert!(circuit_output == u384 { limb0: 200, limb1: 0, limb2: 0, limb3: 0 }, "equation wrong");

    (squared_output, circuit_output);

    println!("Squared output is {:?}", squared_output);
    println!("Circuit output is {:?}", circuit_output);
}
