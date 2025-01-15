use starknet::{ContractAddress, get_caller_address};

#[starknet::interface]
trait IStarkCordInvestment<TContractState> {
    fn invest(ref self: TContractState, project_id: felt252, amount: u256) -> bool;
    fn release(ref self: TContractState, project_id: felt252, recipient: ContractAddress) -> bool;
    fn add_validator(ref self: TContractState, validator: ContractAddress);
}

#[starknet::contract]
mod StarkCordInvestment {
    use super::{ContractAddress, get_caller_address, IStarkCordInvestment};

    #[storage]
    struct Storage {
        token: ContractAddress,
        investments: LegacyMap::<felt252, u256>,
        validators: LegacyMap::<ContractAddress, bool>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Invested: Invested,
        Released: Released
    }

    #[derive(Drop, starknet::Event)]
    struct Invested {
        project_id: felt252,
        investor: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Released {
        project_id: felt252,
        amount: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState, token_address: ContractAddress) {
        self.token.write(token_address);
        self.validators.write(get_caller_address(), true);
    }

    #[abi(embed_v0)]
    impl StarkCordInvestmentImpl of IStarkCordInvestment<ContractState> {
        fn invest(
            ref self: ContractState,
            project_id: felt252,
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            let current_amount = self.investments.read(project_id);
            self.investments.write(project_id, current_amount + amount);
            
            self.emit(Event::Invested(Invested { 
                project_id,
                investor: caller,
                amount 
            }));
            true
        }

        fn release(
            ref self: ContractState,
            project_id: felt252,
            recipient: ContractAddress
        ) -> bool {
            let caller = get_caller_address();
            assert(self.validators.read(caller), 'Not authorized');
            
            let amount = self.investments.read(project_id);
            assert(amount > 0, 'No investment found');
            self.investments.write(project_id, 0);
            
            self.emit(Event::Released(Released { 
                project_id,
                amount 
            }));
            true
        }

        fn add_validator(ref self: ContractState, validator: ContractAddress) {
            let caller = get_caller_address();
            assert(self.validators.read(caller), 'Not authorized');
            self.validators.write(validator, true);
        }
    }
}