#[cfg(test)]
mod tests {
    use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank};
    use starkcord::token::StarkCordToken;
    use starknet::{ContractAddress, get_caller_address};

    fn setup() -> (ContractAddress, ContractAddress) {
        // Deploy token contract
        let contract = declare('StarkCordToken');
        let owner = contract_address_const::<0x123>();
        let deployed = contract.deploy(@array![
            'StarkCord', 
            'STRC', 
            1000000000000000000000000_u256.into(), 
            owner.into()
        ]).unwrap();

        (deployed, owner)
    }

    #[test]
    fn test_deployment() {
        let (address, owner) = setup();
        let dispatcher = IERC20Dispatcher { contract_address: address };
        
        assert(dispatcher.name() == 'StarkCord', 'Wrong name');
        assert(dispatcher.symbol() == 'STRC', 'Wrong symbol');
        assert(dispatcher.total_supply() == 1000000000000000000000000_u256, 'Wrong supply');
        assert(dispatcher.balance_of(owner) == 1000000000000000000000000_u256, 'Wrong balance');
    }

    #[test]
    fn test_transfer() {
        let (address, owner) = setup();
        let dispatcher = IERC20Dispatcher { contract_address: address };
        let recipient = contract_address_const::<0x456>();
        
        start_prank(address, owner);
        dispatcher.transfer(recipient, 1000_u256);
        stop_prank(address);

        assert(dispatcher.balance_of(recipient) == 1000_u256, 'Transfer failed');
    }

    #[test]
    fn test_minting() {
        let (address, owner) = setup();
        let dispatcher = IERC20Dispatcher { contract_address: address };
        let recipient = contract_address_const::<0x456>();
        
        start_prank(address, owner);
        dispatcher.mint(recipient, 1000_u256);
        stop_prank(address);

        assert(dispatcher.balance_of(recipient) == 1000_u256, 'Mint failed');
    }
}