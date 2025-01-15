use starknet::{ContractAddress, get_caller_address};
use starknet::storage_access::StorageAccess;

#[derive(Drop, Serde, starknet::Store)]
struct Project {
    id: felt252,
    owner: ContractAddress,
    total_funding: u256,
    current_milestone: u256,
    active: bool
}

#[derive(Drop, Serde, starknet::Store)]
struct Milestone {
    id: u256,
    description: felt252,
    required_funding: u256,
    completed: bool,
    approved: bool,
    deadline: u64
}

#[derive(Drop, Serde, starknet::Store)]
struct Collaborator {
    address: ContractAddress,
    weight: u256,
    active: bool
}

#[starknet::contract]
mod StarkCord {
    use super::{ContractAddress, get_caller_address, Project, Milestone, Collaborator};

    #[storage]
    struct Storage {
        projects: LegacyMap::<felt252, Project>,
        project_count: u256,
        owner: ContractAddress,
        validators: LegacyMap::<ContractAddress, bool>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ProjectCreated: ProjectCreated,
        MilestoneUpdated: MilestoneUpdated,
    }

    #[derive(Drop, starknet::Event)]
    struct ProjectCreated {
        project_id: felt252,
        owner: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct MilestoneUpdated {
        project_id: felt252,
        milestone_id: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.owner.write(get_caller_address());
        self.project_count.write(0);
    }

    #[generate_trait]
    #[abi(per_item)]
    impl StarkCordImpl of IStarkCord {
        #[external(v0)]
        fn create_project(
            ref self: ContractState,
            project_id: felt252,
            required_funding: u256
        ) -> bool {
            let caller = get_caller_address();
            
            let project = Project {
                id: project_id,
                owner: caller,
                total_funding: 0,
                current_milestone: 0,
                active: true
            };
            
            self.projects.write(project_id, project);
            self.project_count.write(self.project_count.read() + 1);
            
            self.emit(Event::ProjectCreated(ProjectCreated { 
                project_id, 
                owner: caller 
            }));
            true
        }

        #[external(v0)]
        fn update_milestone(
            ref self: ContractState, 
            project_id: felt252,
            milestone_id: u256
        ) -> bool {
            let caller = get_caller_address();
            assert(self.validators.read(caller), 'Not authorized');
            
            let project = self.projects.read(project_id);
            assert(project.active, 'Project not active');
            
            self.emit(Event::MilestoneUpdated(MilestoneUpdated { 
                project_id,
                milestone_id,
            }));
            true
        }

        #[external(v0)]
        fn get_project(self: @ContractState, project_id: felt252) -> Project {
            self.projects.read(project_id)
        }
    }
}