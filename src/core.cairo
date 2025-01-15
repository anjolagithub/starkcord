use starknet::{ContractAddress, get_caller_address};

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Project {
    owner: ContractAddress,
    total_funding: u256,
    current_milestone: u256,
    active: bool
}

#[starknet::interface]
trait IStarkCord<TContractState> {
    fn create_project(ref self: TContractState, project_id: felt252, required_funding: u256) -> bool;
    fn get_project(self: @TContractState, project_id: felt252) -> Project;
    fn update_milestone(ref self: TContractState, project_id: felt252, milestone_id: u256) -> bool;
}

#[starknet::contract]
mod StarkCord {
    use super::{ContractAddress, get_caller_address, Project, IStarkCord};

    #[storage]
    struct Storage {
        projects: LegacyMap::<felt252, Project>,
        project_count: u256,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ProjectCreated: ProjectCreated,
        MilestoneUpdated: MilestoneUpdated
    }

    #[derive(Drop, starknet::Event)]
    struct ProjectCreated {
        project_id: felt252,
        owner: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct MilestoneUpdated {
        project_id: felt252,
        milestone_id: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.owner.write(get_caller_address());
        self.project_count.write(0);
    }

    #[abi(embed_v0)]
    impl StarkCordImpl of IStarkCord<ContractState> {
        fn create_project(
            ref self: ContractState,
            project_id: felt252,
            required_funding: u256
        ) -> bool {
            let caller = get_caller_address();
            
            let project = Project {
                owner: caller,
                total_funding: required_funding,
                current_milestone: 0,
                active: true
            };
            
            self.projects.write(project_id, project);
            self.project_count.write(self.project_count.read() + 1);
            
            self.emit(Event::ProjectCreated(ProjectCreated { project_id, owner: caller }));
            true
        }

        fn get_project(self: @ContractState, project_id: felt252) -> Project {
            self.projects.read(project_id)
        }

        fn update_milestone(
            ref self: ContractState,
            project_id: felt252,
            milestone_id: u256
        ) -> bool {
            let mut project = self.projects.read(project_id);
            assert(project.active, 'Project not active');
            
            let updated_project = Project {
                owner: project.owner,
                total_funding: project.total_funding,
                current_milestone: milestone_id,
                active: project.active
            };
            self.projects.write(project_id, updated_project);
            
            self.emit(Event::MilestoneUpdated(MilestoneUpdated { project_id, milestone_id }));
            true
        }
    }
}