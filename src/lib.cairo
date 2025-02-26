mod dlords;
mod dlords_reward_pool;
mod velords;

pub mod interfaces {
    pub mod IERC20;
    pub mod IVE;
    pub mod IDLordsRewardPool;
}

// only used in tests, but can't be #[cfg(test)]
pub mod mocks {
    pub mod erc20;
}

#[cfg(test)]
mod tests {
    pub mod common;
    mod test_velords;
}
