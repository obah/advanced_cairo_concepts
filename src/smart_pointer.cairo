#[derive(Drop, Copy, Debug)]
enum BinaryTree {
    Leaf: u32,
    Node: (u32, Box<BinaryTree>, Box<BinaryTree>)
}

#[derive(Drop)]
struct Cart {
    paid: bool,
    items: usize,
    buyer: ByteArray
}

fn pass_data(cart: Cart) {
    println!("{} is shopping and bought {} items", cart.buyer, cart.items)
}

fn pass_pointer(cart: Box<Cart>) {
    let cart = cart.unbox();
    println!("{} is shopping and bought {} items", cart.buyer, cart.items)
}

fn main() {
    let leaf1 = BinaryTree::Leaf(1);
    let leaf2 = BinaryTree::Leaf(2);
    let leaf3 = BinaryTree::Leaf(3);
    let node = BinaryTree::Node((4, BoxTrait::new(leaf1), BoxTrait::new(leaf2)));
    let _root = BinaryTree::Node((5, BoxTrait::new(leaf3), BoxTrait::new(node)));

    println!("Root node is {:?}", _root);

    let cart_struct = Cart { paid: false, items: 40, buyer: "Oba" };
    pass_data(cart_struct);

    let cart_box = BoxTrait::new(Cart { paid: true, items: 10, buyer: "Olori" });
    pass_pointer(cart_box);
}
//this implementation throws an error becuase of it's infinite size in the recursion.
//to fix this, we use a box


