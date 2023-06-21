import pytest
from calculator import Calculator

# fixture is a function that runs before each test
@pytest.fixture
def calculator():
    return Calculator()

# parameterize decorator allows us to run the same test with different data
@pytest.mark.parametrize('a,b,expected', [(2,2, 4), (5,-2, 3), (-3,6, 3),(6,-6,0)])
def test_add(calculator, a, b, expected):
    result = calculator.add(a,b)
    assert result == expected

def test_subtract(calculator):
    result = calculator.subtract(10, 5)
    assert result == 5

def test_multiply(calculator):
    result = calculator.multiply(4, 5)
    assert result == 20

def test_divide(calculator):
    result = calculator.divide(10, 2)
    assert result == 5

def test_divide_by_zero(calculator):
    with pytest.raises(ValueError):
        # check to make sure that ValueError is raised when dividing by zero
        calculator.divide(10, 0)

