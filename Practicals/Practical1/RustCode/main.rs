
fn encrypt_sting(input: &str) ->String{
    const XOR_KEY: u32 = 0x73113777;
    let mut encrypted_string = String::new();

    for ch in input.chars(){
        let mut char_value = ch as u32;
        char_value = (char_value << 4) | (char_value >> (8-4));
        char_value ^= XOR_KEY;
        let encrypted_char = (char_value ) as u8 as char;
        encrypted_string.push(encrypted_char);
    }

    encrypted_string
}

pub fn decrypt_string(encrypted: &str) -> String {
    const XOR_KEY: u32 = 0x73113777;
    let mut decrypted_string = String::new();

    for ch in encrypted.chars() {
        let mut char_value = ch as u32;
        char_value ^= XOR_KEY;
        char_value = (char_value >> 4) | (char_value << (8 - 4));
        let decrypted_char = (char_value & 0xFF) as u8 as char;
        decrypted_string.push(decrypted_char);
    }

    decrypted_string
}

fn main() {
    let input: &str = "move";
    let encrypted = encrypt_sting(input);
    println!("Encrypted String: {}",encrypted);
}
