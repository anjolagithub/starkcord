#[cfg(test)]
mod tests {
    use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank};
    use starkcord::investment::StarkCordInvestment;
    use starkcord::token::StarkCordToken;
    use starknet::ContractAddress;

    fn setup() -> (ContractAddress, ContractAddress, ContractAddress) {
        // Deploy token
        let token_contract = declare('StarkCordToken');
        let owner = contract_address_const::<0x123>();
        let token = token_contract.deploy(@array![
            'StarkCord', 
            'STRC', 
            1000000000000000000000000_u256.into(), 
            owner.into()
        ]).unwrap();

        // Deploy investment contract
        let investment_contract = declare('StarkCordInvestment');
        let investment = investment_contract.deploy(@array![token.into()]).unwrap();
        
        (investment, token, owner)
    }

    #[test]
    fn test_invest() {
        let (investment_address, token_address, owner) = setup();
        let investment = IStarkCordInvestmentDispatcher { contract_address: investment_address };
        let token = IERC20Dispatcher { contract_address: token_address };
        
        // Approve tokens
        start_prank(token_address, owner);
        token.approve(investment_address, 1000_u256);
        
        // Make investment
        let result = investment.invest(1_felt252, 1000_u256);
        stop_prank(token_address);

        assert(result == true, 'Investment failed');
    }

    #[test]
    fn test_release_funds() {
        let (investment_address, token_address, owner) = setup();
        let investment = IStarkCordInvestmentDispatcher { contract_address: investment_address };
        
        start_prank(investment_address, owner);
        let result = investment.release(1_felt252, owner);
        stop_prank(investment_address);

        assert(result == true, 'Release failed');
    }
}