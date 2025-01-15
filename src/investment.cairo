use starknet::{ContractAddress, get_caller_address, get_contract_address};
use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

#[starknet::contract]
mod StarkCordInvestment {
    use super::{ContractAddress, get_caller_address, get_contract_address, IERC20Dispatcher, IERC20DispatcherTrait};

    #[derive(Drop, Serde, starknet::Store)]
    struct Investment {
        amount: u256,
        investor: ContractAddress
    }

    #[storage]
    struct Storage {
        token: ContractAddress,
        investments: LegacyMap::<felt252, Investment>,
        validators: LegacyMap::<ContractAddress, bool>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        InvestmentMade: InvestmentMade,
        FundsReleased: FundsReleased
    }

    #[derive(Drop, starknet::Event)]
    struct InvestmentMade {
        project_id: felt252,
        investor: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct FundsReleased {
        project_id: felt252,
        amount: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState, token_address: ContractAddress) {
        self.token.write(token_address);
    }

    #[generate_trait]
    #[abi(per_item)]
    impl InvestmentImpl of IInvestment {
        #[external(v0)]
        fn invest(
            ref self: ContractState,
            project_id: felt252,
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            
            let token = IERC20Dispatcher { contract_address: self.token.read() };
            token.transfer_from(caller, get_contract_address(), amount);
            
            let investment = Investment { 
                amount,
                investor: caller 
            };
            self.investments.write(project_id, investment);
            
            self.emit(Event::InvestmentMade(InvestmentMade { 
                project_id,
                investor: caller,
                amount
            }));
            true
        }

        #[external(v0)]
        fn release_funds(
            ref self: ContractState,
            project_id: felt252,
            recipient: ContractAddress
        ) -> bool {
            let caller = get_caller_address();
            assert(self.validators.read(caller), 'Not authorized');
            
            let investment = self.investments.read(project_id);
            let token = IERC20Dispatcher { contract_address: self.token.read() };
            
            token.transfer(recipient, investment.amount);
            
            self.emit(Event::FundsReleased(FundsReleased { 
                project_id,
                amount: investment.amount
            }));
            true
        }
    }
}