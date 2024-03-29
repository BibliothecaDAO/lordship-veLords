use core::serde::Serde;
use lordship::interfaces::IVE::{IVEDispatcher, IVEDispatcherTrait};
use lordship::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};
use snforge_std::{ContractClass, ContractClassTrait, CheatTarget, declare, start_prank, start_warp, stop_prank};
use starknet::{ContractAddress, contract_address_const};

pub const ONE: u256 = 1000000000000000000; // 10**18
const LORDS_SUPPLY: u256 = 500_000_000 * ONE; // 500M LORDS

pub const TS: u64 = 1710000000;
pub const YEAR: u64 = 365 * 86400;

pub fn lords_owner() -> ContractAddress {
    contract_address_const::<'lords owner'>()
}

pub fn velords_owner() -> ContractAddress {
    contract_address_const::<'velords owner'>()
}

pub fn blobert() -> ContractAddress {
    contract_address_const::<'blobert'>()
}

pub fn badguy() -> ContractAddress {
    contract_address_const::<'badguy'>()
}

fn LORDS() -> ContractAddress {
    // Starknet mainnet LORDS token address
    contract_address_const::<0x124aeb495b947201f5fac96fd1138e326ad86195b98df6dec9009158a533b49>()
}

pub fn deploy_lords() -> ContractAddress {
    let cls = declare("erc20");

    let mut calldata: Array<felt252> = Default::default();
    let name: ByteArray = "Lords";
    let symbol: ByteArray = "LORDS";
    let supply: u256 = LORDS_SUPPLY.into();
    let owner: ContractAddress = lords_owner();
    name.serialize(ref calldata);
    symbol.serialize(ref calldata);
    supply.serialize(ref calldata);
    owner.serialize(ref calldata);

    cls.deploy_at(@calldata, LORDS()).expect('lords deploy failed')
}

pub fn deploy_velords() -> ContractAddress {
    let cls = declare("velords");
    let calldata: Array<felt252> = array![
        velords_owner().into()
    ];
    cls.deploy(@calldata).expect('velords deploy failed')
}

pub fn velords_setup() -> (IVEDispatcher, IERC20Dispatcher) {
    let velords = IVEDispatcher { contract_address: deploy_velords() };
    let lords = IERC20Dispatcher { contract_address: deploy_lords() };
    start_warp(CheatTarget::All, TS);

    (velords, lords)
}

pub fn fund_lords(recipient: ContractAddress, amount: Option<u256>) {
    let default_amount: u256 = ONE * 10_000_000; // 10M LORDS
    let amount: u256 = amount.unwrap_or(default_amount);
    let lords: ContractAddress = LORDS();

    start_prank(CheatTarget::One(lords), lords_owner());
    IERC20Dispatcher { contract_address: lords }.transfer(recipient, amount);
    stop_prank(CheatTarget::One(lords));
}

pub fn floor_to_week(ts: u64) -> u64 {
    let week: u64 = 604800;
    (ts / week) * week
}