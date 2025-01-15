use starknet::ContractAddress;
use starknet::{get_caller_address, get_contract_address};
use openzeppelin::token::erc20::ERC20Component;
use starknet::storage_access::StorageAccess;

#[starknet::contract]
mod StarkCordToken {
    use super::ContractAddress;
    use super::get_caller_address;
    use openzeppelin::token::erc20::ERC20Component;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        minters: LegacyMap::<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        initial_supply: u256,
        recipient: ContractAddress
    ) {
        self.erc20.initializer(name, symbol);
        self.erc20._mint(recipient, initial_supply);
        self.minters.write(recipient, true);
    }

    #[abi(per_item)]
    impl ERC20Impl = ERC20Component::IERC20<ContractState>;

    #[abi(per_item)]
    #[generate_trait]
    impl MinterImpl of IMinterTrait {
        #[external(v0)]
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            assert(self.minters.read(caller), 'Not a minter');
            self.erc20._mint(recipient, amount);
        }

        #[external(v0)]
        fn add_minter(ref self: ContractState, new_minter: ContractAddress) {
            let caller = get_caller_address();
            assert(self.minters.read(caller), 'Not a minter');
            self.minters.write(new_minter, true);
        }
    }
}