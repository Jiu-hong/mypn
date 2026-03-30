fn main() {
    println!("Hello, world!");
    use casper_types::{CLValue, StoredValue, U512, bytesrepr::ToBytes};

    let amount = U512::from(4_804_372_849_045_287_000u64);
    let stored = StoredValue::CLValue(CLValue::from_t(amount).unwrap());
    let encoded = base64::encode(stored.to_bytes().unwrap());
    println!("{}", encoded);
    // → "AAgAAAAHADCw7ayJIwg="
}
