import re

def is_valid_email(email: str) -> bool:
    """Utility function to validate email format using the same regex as in load_to_postgres."""
    email_regex = r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
    return re.match(email_regex, email or "") is not None

def test_valid_email():
    assert is_valid_email("john.doe@example.com") is True

def test_invalid_email_missing_at():
    assert is_valid_email("john.doeexample.com") is False

def test_invalid_email_empty_string():
    assert is_valid_email("") is False

def test_invalid_email_none():
    assert is_valid_email(None) is False