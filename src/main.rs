use aws_lc_rs::digest;

fn greeting() -> &'static str {
    "Hello, world! aaaaaa"
}

fn greeting_sha256_hex() -> String {
    let digest = digest::digest(&digest::SHA256, greeting().as_bytes());
    digest
        .as_ref()
        .iter()
        .map(|byte| format!("{byte:02x}"))
        .collect()
}

fn main() {
    println!("{}", greeting());
    println!("sha256: {}", greeting_sha256_hex());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn greeting_says_hello_world() {
        assert_eq!(greeting(), "Hello, world!");
    }

    #[test]
    fn greeting_is_not_empty() {
        assert!(!greeting().is_empty());
    }

    #[test]
    fn greeting_ends_with_exclamation_mark() {
        assert!(greeting().ends_with('!'));
    }

    #[test]
    fn greeting_contains_world() {
        assert!(greeting().contains("world"));
    }

    #[test]
    fn greeting_is_stable_across_calls() {
        assert_eq!(greeting(), greeting());
    }

    #[test]
    fn greeting_has_expected_length() {
        assert_eq!(greeting().len(), "Hello, world!".len());
    }

    #[test]
    fn greeting_sha256_hex_matches_known_digest() {
        assert_eq!(
            greeting_sha256_hex(),
            "315f5bdb76d078c43b8ac0064e4a0164612b1fce77c869345bfc94c75894edd3"
        );
    }
}
