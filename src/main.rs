fn greeting() -> &'static str {
    "Hello, world!"
}

fn main() {
    println!("{}", greeting());
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
}
