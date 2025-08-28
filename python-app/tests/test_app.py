import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SECRET_KEY'] = 'test_secret_key'  # Set a secret key for testing
    with app.test_client() as client:
        yield client

def test_index_get(client):
    """Test that the index page loads with a GET request."""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Number Guessing Game' in response.data

def test_index_post_invalid(client):
    """Test POST with invalid data."""
    response = client.post('/', data={'guess': 'not a number'})
    assert response.status_code == 200
    assert b'Invalid input' in response.data

def test_index_post_valid(client):
    """Test POST with a valid number. Since the number is random, we check for expected responses."""
    # First, make a GET request to initialize the session
    client.get('/')
    # Post a valid guess
    response = client.post('/', data={'guess': '50'})
    assert response.status_code == 200
    # The response should contain one of these messages
    assert b'Too low' in response.data or b'Too high' in response.data or b'You got it' in response.data