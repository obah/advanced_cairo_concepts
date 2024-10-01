use core::num::traits::WrappingAdd;
use core::dict::Felt252Dict;

//mutable db
struct UserDatabase<T> {
    user_updates: u64,
    balances: Felt252Dict<T>
}

trait UserDatabaseTrait<T> {
    fn new() -> UserDatabase<T>;
    fn update_user<+Drop<T>>(ref self: UserDatabase<T>, name: felt252, balance: T);
    fn get_user<+Copy<T>>(ref self: UserDatabase<T>, name: felt252) -> T;
}

impl UserDatabaseImpl<T, +Felt252DictValue<T>> of UserDatabaseTrait<T> {
    fn new() -> UserDatabase<T> {
        UserDatabase { user_updates: 0, balances: Default::default() }
    }

    fn update_user<+Drop<T>>(ref self: UserDatabase<T>, name: felt252, balance: T) {
        self.balances.insert(name, balance);
        self.user_updates += 1;
    }

    fn get_user<+Copy<T>>(ref self: UserDatabase<T>, name: felt252) -> T {
        self.balances.get(name)
    }
}

//this is done beccause of the Felt252Dict type
impl UserDatabaseDestruct<T, +Drop<T>, +Felt252DictValue<T>> of Destruct<UserDatabase<T>> {
    fn destruct(self: UserDatabase<T>) nopanic {
        self.balances.squash();
    }
}

//mutable & dynamic array
struct MemoryVec<T> {
    data: Felt252Dict<Nullable<T>>,
    len: usize
}

trait MemoryVecTrait<V, T> {
    fn new() -> V;
    fn get(ref self: V, index: usize) -> Option<T>;
    fn at(ref self: V, index: usize) -> T;
    fn push(ref self: V, value: T) -> ();
    fn set(ref self: V, index: usize, value: T);
    fn len(self: @V) -> usize;
}

impl MemoryVecImpl<T, +Drop<T>, +Copy<T>> of MemoryVecTrait<MemoryVec<T>, T> {
    fn new() -> MemoryVec<T> {
        MemoryVec { data: Default::default(), len: 0 }
    }

    fn get(ref self: MemoryVec<T>, index: usize) -> Option<T> {
        if index < self.len() {
            Option::Some(self.data.get(index.into()).deref())
        } else {
            Option::None
        }
    }

    fn at(ref self: MemoryVec<T>, index: usize) -> T {
        assert!(self.len() > index, "out of bounds");
        self.data.get(index.into()).deref()
    }

    fn push(ref self: MemoryVec<T>, value: T) -> () {
        self.data.insert(self.len.into(), NullableTrait::new(value));
        self.len.wrapping_add(1_usize);
    }

    fn set(ref self: MemoryVec<T>, index: usize, value: T) {
        assert!(self.len() > index, "out of bounds");
        self.data.insert(index.into(), NullableTrait::new(value));
    }

    fn len(self: @MemoryVec<T>) -> usize {
        *self.len
    }
}

//this is done beccause of the Felt252Dict type
impl MemoryVecDestruct<T, +Drop<T>> of Destruct<MemoryVec<T>> {
    fn destruct(self: MemoryVec<T>) nopanic {
        self.data.squash();
    }
}

//simulating stack with dict
//LIFO
//Push an item to the top of the stack.
//Pop an item from the top of the stack.
//Check whether there are still any elements in the stack.
struct NullableStack<T> {
    data: Felt252Dict<Nullable<T>>,
    len: usize
}

trait NullableStackTrait<S, T> {
    fn push(ref self: S, value: T);
    fn pop(ref self: S) -> Option<T>;
    fn is_empty(self: @S) -> bool;
}

impl NUllableStackImpl<T, +Copy<T>, +Drop<T>> of NullableStackTrait<NullableStack<T>, T> {
    fn push(ref self: NullableStack<T>, value: T) {
        self.data.insert(self.len.into(), NullableTrait::new(value));
        self.len += 1;
    }

    fn pop(ref self: NullableStack<T>) -> Option<T> {
        if self.is_empty() {
            Option::None
        } else {
            self.len -= 1;
            Option::Some(self.data.get(self.len.into()).deref())
        }
    }

    fn is_empty(self: @NullableStack<T>) -> bool {
        *self.len == 0
    }
}

impl NullaleStaackDestruct<T, +Drop<T>> of Destruct<NullableStack<T>> {
    fn destruct(self: NullableStack<T>) nopanic {
        self.data.squash();
    }
}

fn main() {
    let mut db = UserDatabaseTrait::<u64>::new();

    db.update_user('Oba', 100);
    db.update_user('Olori', 80);

    db.update_user('Oba', 40);
    db.update_user('Olori', 10);

    let oba_balance = db.get_user('Oba');
    let olori_balance = db.get_user('Olori');

    println!("Oba current balance is {oba_balance}");
    println!("Olori current balance is {olori_balance}");
}
