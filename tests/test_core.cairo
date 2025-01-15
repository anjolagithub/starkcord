#[cfg(test)]
mod tests {
    use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank};
    use starkcord::core::StarkCord;
    use starknet::ContractAddress;

    fn setup() -> (ContractAddress, ContractAddress) {
        let contract = declare('StarkCord');
        let owner = contract_address_const::<0x123>();
        let deployed = contract.deploy(@array![]).unwrap();
        
        (deployed, owner)
    }

    #[test]
    fn test_create_project() {
        let (address, owner) = setup();
        let dispatcher = IStarkCordDispatcher { contract_address: address };
        
        start_prank(address, owner);
        let result = dispatcher.create_project(1_felt252, 1000_u256);
        stop_prank(address);

        assert(result == true, 'Project creation failed');
        
        let project = dispatcher.get_project(1_felt252);
        assert(project.owner == owner, 'Wrong owner');
        assert(project.total_funding == 1000_u256, 'Wrong funding');
        assert(project.active == true, 'Not active');
    }

    #[test]
    fn test_update_milestone() {
        let (address, owner) = setup();
        let dispatcher = IStarkCordDispatcher { contract_address: address };
        
        // Create project first
        start_prank(address, owner);
        dispatcher.create_project(1_felt252, 1000_u256);
        
        // Update milestone
        let result = dispatcher.update_milestone(1_felt252, 1_u256);
        stop_prank(address);

        assert(result == true, 'Milestone update failed');
        
        let project = dispatcher.get_project(1_felt252);
        assert(project.current_milestone == 1_u256, 'Wrong milestone');
    }
}