use aws_lc_rs::digest;

fn greeting() -> &'static str {
    "Hello, Rust!"
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
    fn greeting_says_hello_rust() {
        assert_eq!(greeting(), "Hello, Rust!");
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
    fn greeting_contains_rust() {
        assert!(greeting().contains("Rust"));
    }

    #[test]
    fn greeting_is_stable_across_calls() {
        assert_eq!(greeting(), greeting());
    }

    #[test]
    fn greeting_has_expected_length() {
        assert_eq!(greeting().len(), "Hello, Rust!".len());
    }

    #[test]
    fn greeting_sha256_hex_matches_known_digest() {
        assert_eq!(
            greeting_sha256_hex(),
            "12a967da1e8654e129d41e3c016f14e81e751e073feb383125bf82080256ca19"
        );
    }
}
